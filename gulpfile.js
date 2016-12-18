'use strict';

Error.stackTraceLimit = Infinity;

const gulp = require('gulp');
const gutil = require('gulp-util');
const glob = require('glob');
const browserify = require('browserify');
const source = require('vinyl-source-stream');
const buffer = require('vinyl-buffer');
const es = require('event-stream');
const replace = require('gulp-replace');
const stylus = require('gulp-stylus');
const cssnano = require('gulp-cssnano');
const uglify = require('gulp-uglify');
const ls = require('browserify-livescript');
const aliasify = require('aliasify');
const riotify = require('riotify');
const transformify = require('syuilo-transformify');
const pug = require('gulp-pug');
const git = require('git-last-commit');

const env = process.env.NODE_ENV;
const isProduction = env === 'production';
const isDebug = !isProduction;

const argv = require('yargs').argv;

const config = {
	url: argv['url'],
	themeColor: '#f76d6c',
	recaptcha: {
		siteKey: argv['recaptcha-sitekey']
	}
};

config.host = config.url.substr(config.url.indexOf('://') + 3);
config.scheme = config.url.substr(0, config.url.indexOf('://'));

/*
 * Browserifyのモジュールエイリアス
 */
const aliasifyConfig = {
	"aliases": {
		"fetch": "./node_modules/whatwg-fetch/fetch.js",
		"page": "./node_modules/page/page.js",
		"NProgress": "./node_modules/nprogress/nprogress.js",
		"velocity": "./node_modules/velocity-animate/velocity.js",
		"chart.js": "./node_modules/chart.js/src/chart.js",
		"textarea-caret-position": "./node_modules/textarea-caret/index.js",
		"misskey-text": "./node_modules/misskey-text/src/index.js",
		"strength.js": "./node_modules/syuilo-password-strength/strength.js",
		"cropper": "./node_modules/cropperjs/dist/cropper.js",
		"Sortable": "./node_modules/sortablejs/Sortable.js",
		"fuck-adblock": "./node_modules/fuckadblock/fuckadblock.js",
		"reconnecting-websocket": "./node_modules/reconnecting-websocket/dist/index.js"
	},
	appliesTo: {
		"includeExtensions": ['.js', '.ls']
	}
};

gulp.task('build', [
	'build:scripts',
	'build:styles',
	'build:pug',
	'build-copy'
], () => {
	gutil.log('ビルドが終了しました。');

	if (isDebug) {
		gutil.log('■　注意！　開発モードでのビルドです。');
	}
});

gulp.task('test', ['build']);

//////////////////////////////////////////////////
// Pugのビルド
gulp.task('build:pug', ['build:scripts', 'build:styles'], () => {
	gutil.log('Pugをコンパイルします...');

	return gulp.src([
		'./src/*/view.pug'
	])
		.pipe(pug({
			locals: {
				themeColor: config.themeColor
			}
		}))
		.pipe(gulp.dest('./built/'));
});

//////////////////////////////////////////////////
// スクリプトのビルド
gulp.task('build:scripts', done => {
	gutil.log('スクリプトを構築します...');

	// Get commit info
	git.getLastCommit((err, commit) => {
		glob('./src/*/script.ls', (err, files) => {
			const tasks = files.map(entry => {
				let bundle =
					browserify({
						entries: [entry]
					})
					.transform(ls)
					.transform(aliasify, aliasifyConfig)

					.transform(transformify((source, file) => {
						if (file.substr(-4) !== '.tag') return source;
						console.log(file);
						return source;
					}))

					// tagの{}の''を不要にする (その代わりスタイルの記法は使えなくなるけど)
					.transform(transformify((source, file) => {
						if (file.substr(-4) !== '.tag') return source;

						const tag = new Tag(source);
						const html = tag.sections.filter(s => s.name == 'html')[0];

						html.lines = html.lines.map(line => {
							if (line.replace(/\t/g, '')[0] === '|') {
								return line;
							} else {
								return line.replace(/([+=])\s?\{(.+?)\}/g, '$1"{$2}"');
							}
						});

						const styles = tag.sections.filter(s => s.name == 'style');

						if (styles.length == 0) {
							return tag.compile();
						}

						styles.forEach(style => {
							let head = style.lines.shift();
							head = head.replace(/([+=])\s?\{(.+?)\}/g, '$1"{$2}"');
							style.lines.unshift(head);
						});

						return tag.compile();
					}))

					// tagの@hogeをref='hoge'にする
					.transform(transformify((source, file) => {
						if (file.substr(-4) !== '.tag') return source;

						const tag = new Tag(source);
						const html = tag.sections.filter(s => s.name == 'html')[0];

						html.lines = html.lines.map(line => {
							if (line.indexOf('@') === -1) {
								return line;
							} else if (line.replace(/\t/g, '')[0] === '|') {
								return line;
							} else {
								while (line.match(/[^\s']@[a-z-]+/) !== null) {
									const match = line.match(/@[a-z-]+/);
									let name = match[0];
									if (line[line.indexOf(name) + name.length] === '(') {
										line = line.replace(name + '(', '(ref=\'' + camelCase(name.substr(1)) + '\',');
									} else {
										line = line.replace(name, '(ref=\'' + camelCase(name.substr(1)) + '\')');
									}
								}
								return line;
							}
						});

						return tag.compile();

						function camelCase(str) {
							return str.replace(/-([^\s])/g, (match, group1) => {
								return group1.toUpperCase();
							});
						}
					}))

					// tagのchain-caseをcamelCaseにする
					.transform(transformify((source, file) => {
						if (file.substr(-4) !== '.tag') return source;

						const tag = new Tag(source);
						const html = tag.sections.filter(s => s.name == 'html')[0];

						html.lines = html.lines.map(line => {
							(line.match(/\{.+?\}/g) || []).forEach(x => {
								line = line.replace(x, camelCase(x));
							});
							return line;
						});

						return tag.compile();

						function camelCase(str) {
							str = str.replace(/([a-z\-]+):/g, (match, group1) => {
								return group1.replace(/\-/g, '###') + ':';
							});
							str = str.replace(/'(.+?)'/g, (match, group1) => {
								return "'" + group1.replace(/\-/g, '###') + "'";
							});
							str = str.replace(/-([^\s0-9])/g, (match, group1) => {
								return group1.toUpperCase();
							});
							str = str.replace(/###/g, '-');

							return str;
						}
					}))

					// tagのstyleの属性
					.transform(transformify((source, file) => {
						if (file.substr(-4) !== '.tag') return source;

						const tag = new Tag(source);

						const styles = tag.sections.filter(s => s.name == 'style');

						if (styles.length == 0) {
							return tag.compile();
						}

						styles.forEach(style => {
							let head = style.lines.shift();
							if (style.attr) {
								style.attr = style.attr + ', type=\'stylus\', scoped';
							} else {
								style.attr = 'type=\'stylus\', scoped';
							}
							style.lines.unshift(head);
						});

						return tag.compile();
					}))

					// tagのstyleの定数
					.transform(transformify((source, file) => {
						if (file.substr(-4) !== '.tag') return source;

						const tag = new Tag(source);

						const styles = tag.sections.filter(s => s.name == 'style');

						if (styles.length == 0) {
							return tag.compile();
						}

						styles.forEach(style => {
							const head = style.lines.shift();
							style.lines.unshift('$theme-color = ' + config.themeColor);
							style.lines.unshift('$theme-color-foreground = #fff');
							style.lines.unshift(head);
						});

						return tag.compile();
					}))

					// tagのstyleを暗黙的に:scopeにする
					.transform(transformify((source, file) => {
						if (file.substr(-4) !== '.tag') return source;

						const tag = new Tag(source);

						const styles = tag.sections.filter(s => s.name == 'style');

						if (styles.length == 0) {
							return tag.compile();
						}

						styles.forEach((style, i) => {
							if (i != 0) {
								return;
							}
							const head = style.lines.shift();
							style.lines = style.lines.map(line => {
								return '\t' + line;
							});
							style.lines.unshift(':scope');
							style.lines.unshift(head);
						});

						return tag.compile();
					}))

					// tagのtheme styleのパース
					.transform(transformify((source, file) => {
						if (file.substr(-4) !== '.tag') return source;

						const tag = new Tag(source);

						const styles = tag.sections.filter(s => s.name == 'style');

						if (styles.length == 0) {
							return tag.compile();
						}

						styles.forEach((style, i) => {
							if (i == 0) {
								return;
							} else if (style.attr.substr(0, 6) != 'theme=') {
								return;
							}
							const head = style.lines.shift();
							style.lines = style.lines.map(line => {
								return '\t' + line;
							});
							style.lines.unshift(':scope');
							style.lines = style.lines.map(line => {
								return '\t' + line;
							});
							style.lines.unshift('html[data-' + style.attr.match(/theme='(.+?)'/)[0] + ']');
							style.lines.unshift(head);
						});

						return tag.compile();
					}))

					// tagのstyleおよびscriptのインデントを不要にする
					.transform(transformify((source, file) => {
						if (file.substr(-4) !== '.tag') return source;
						const tag = new Tag(source);

						tag.sections = tag.sections.map(section => {
							if (section.name != 'html') {
								section.indent++;
							}
							return section;
						});

						return tag.compile();
					}))

					// スペースでインデントされてないとエラーが出る
					.transform(transformify((source, file) => {
						if (file.substr(-4) !== '.tag') return source;
						return source.replace(/\t/g, '  ');
					}))

					.transform(transformify((source, file) => {
						return source
							.replace(/VERSION/g, `'${commit.hash}'`)
							.replace(/CONFIG\.theme-color/g, `'${config.themeColor}'`)
							.replace(/CONFIG\.themeColor/g, `'${config.themeColor}'`)
							.replace(/CONFIG\.api\.url/g, `'${config.scheme}://api.${config.host}'`)
							.replace(/CONFIG\.urls\.about/g, `'${config.scheme}://about.${config.host}'`)
							.replace(/CONFIG\.urls\.dev/g, `'${config.scheme}://dev.${config.host}'`)
							.replace(/CONFIG\.url/g, `'${config.url}'`)
							.replace(/CONFIG\.host/g, `'${config.host}'`)
							.replace(/CONFIG\.recaptcha\.siteKey/g, `'${config.recaptcha.siteKey}'`)
							;
					}))

					.transform(riotify, {
						template: 'pug',
						type: 'livescript',
						expr: false,
						compact: true
					})
					// Riotが謎の空白を挿入する
					.transform(transformify((source, file) => {
						if (file.substr(-4) !== '.tag') return source;
						return source.replace(/\s<mk\-ellipsis>/g, '<mk-ellipsis>');
					}))
					/*
					// LiveScruptがHTMLクラスのショートカットを変な風に生成するのでそれを修正
					.transform(transformify((source, file) => {
						if (file.substr(-4) !== '.tag') return source;
						return source.replace(/class="\{\(\{(.+?)\}\)\}"/g, 'class="{$1}"');
					}))*/
					.bundle()
					.pipe(source(entry.replace('src', 'resources').replace('.ls', '.js')));

				if (isProduction) {
					bundle = bundle
						.pipe(buffer())
						.pipe(uglify({
							compress: true
						}));
				}

				return bundle
					.pipe(gulp.dest('./built'));
			});

			es.merge(tasks).on('end', done);
		});
	});
});

//////////////////////////////////////////////////
// フロントサイドのスタイルのビルド
gulp.task('build:styles', () => {
	gutil.log('フロントサイドスタイルを構築します...');

	return gulp.src('./src/**/*.styl')
		.pipe(stylus({
			'include css': true
		}))
		.pipe(isProduction
			? cssnano({
				safe: true // 高度な圧縮は無効にする (一部デザインが不適切になる場合があるため)
			})
			: gutil.noop())
		.pipe(gulp.dest('./built/resources/'));
});

//////////////////////////////////////////////////
// その他のリソースのコピー
gulp.task('build-copy', [
	'build:scripts',
	'build:styles'
], () => {
	gutil.log('必要なリソースをコピーします...');

	return es.merge(
		gulp.src('./resources/**/*').pipe(gulp.dest('./built/resources/')),
		gulp.src('./src/desktop/resources/**/*').pipe(gulp.dest('./built/resources/desktop/')),
		gulp.src('./src/mobile/resources/**/*').pipe(gulp.dest('./built/resources/mobile/')),
		gulp.src('./src/dev/resources/**/*').pipe(gulp.dest('./built/resources/dev/')),
		gulp.src('./src/auth/resources/**/*').pipe(gulp.dest('./built/resources/auth/'))
	);
});

class Tag {
	constructor(source) {
		this.sections = [];

		source = source
			.replace(/\r\n/g, '\n')
			.replace(/\n(\t+?)\n/g, '\n')
			.replace(/\n+/g, '\n');

		const html = {
			name: 'html',
			indent: 0,
			lines: []
		};

		let flag = false;
		source.split('\n').forEach((line, i) => {
			const indent = line.lastIndexOf('\t') + 1;
			if (i != 0 && indent == 0) {
				flag = true;
			}
			if (!flag) {
				source = source.replace(/^.*?\n/, '');
				html.lines.push(i == 0 ? line : line.substr(1));
			}
		});

		this.sections.push(html);

		while (source != '') {
			const line = source.substr(0, source.indexOf('\n'));
			const root = line.match(/^\t*([a-z]+)(\.|\()?/)[1];
			const beginIndent = line.lastIndexOf('\t') + 1;
			flag = false;
			const section = {
				name: root,
				attr: (line.match(/\((.+?)\)/) || [null, null])[1],
				indent: beginIndent,
				lines: []
			};
			source.split('\n').forEach((line, i) => {
				const currentIndent = line.lastIndexOf('\t') + 1;
				if (i != 0 && (currentIndent == beginIndent || currentIndent == 0)) {
					flag = true;
				}
				if (!flag) {
					if (i == 0 && line[line.length - 1] == '.') {
						line = line.substr(0, line.length - 1);
					}
					if (i == 0 && line.indexOf('(') != -1) {
						line = line.substr(0, line.indexOf('('));
					}
					source = source.replace(/^.*?\n/, '');
					section.lines.push(i == 0 ? line.substr(beginIndent) : line.substr(beginIndent + 1));
				}
			});
			this.sections.push(section);
		};
	}

	compile() {
		let dist = '';
		this.sections.forEach((section, j) => {
			dist += section.lines.map((line, i) => {
				if (i == 0) {
					const attr = section.attr != null ? '(' + section.attr + ')' : '';
					const tail = j != 0 ? '.' : '';
					return '\t'.repeat(section.indent) + line + attr + tail;
				} else {
					return '\t'.repeat(section.indent + 1) + line;
				}
			}).join('\n') + '\n';
		});
		return dist;
	}
}
