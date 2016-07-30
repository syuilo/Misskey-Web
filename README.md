![](./web.png)
-----------------------------

[![][travis-badge]][travis-link]
[![][dependencies-badge]][dependencies-link]
[![][mit-badge]][mit]

*Misskey* official client for the Web.

## External dependencies
* Node.js
* npm
* MongoDB
* GraphicsMagick (for trimming, compress, etc etc)

## How to build
1. `git clone git://github.com/syuilo/misskey-web.git`
2. `cd misskey-web`
3. `npm install`
4. `npm run dtsm`
4. `./node_modules/.bin/bower install --allow-root`
5. `npm run build`

## How to launch
`npm start`

## Show options
`npm start -- -h`

## Configuration

``` yaml
# Misskey Web Configuration

# サーバーの管理者情報
# ex) "Your Name <youremail@example.com>"
maintainer: <string>

# アクセスするときのドメイン
host: "misskey.xyz"

# アクセスするときのポート
# サーバー内部でlistenするポートではありません。ブラウザでアクセスするときの最終的なポートです。
# 内部でプロキシを使用していたりなどの理由で、リクエストを待ち受けるポートを指定する場合は bindPorts の項目を設定してください。
port: 80

# Listen時の設定
bindIp: null
bindPort: 80

# TLS設定
https:
  enable: <boolean>
  # 以下証明書設定。 enable が false の場合は省略
  key: <string>
  cert: <string>

# よく分からない
cookiePass: <string>

# よく分からない
sessionSecret: <string>

# MongoDB
mongo:
  uri: <string>
  options:
   user: <string>
   pass: <string>

# Redis
redis:
  host: <string>
  port: <number>

# APIサーバー設定
api:
  host: <string>
  port: <string>
  secure: <boolean>
  pass: <string>

# reCAPTCHA設定
# SEE: https://www.google.com/recaptcha/intro/index.html
recaptcha:
  siteKey: <string>
  secretKey: <string>

```

## People

The original author of Misskey is [syuilo](https://github.com/syuilo)

The current lead maintainer is [syuilo](https://github.com/syuilo)

[List of all contributors](https://github.com/syuilo/misskey-web/graphs/contributors)

## License
[MIT](LICENSE)

[mit]:                http://opensource.org/licenses/MIT
[mit-badge]:          https://img.shields.io/badge/license-MIT-444444.svg?style=flat-square
[travis-link]:        https://travis-ci.org/syuilo/misskey-web
[travis-badge]:       http://img.shields.io/travis/syuilo/misskey-web.svg?style=flat-square
[dependencies-link]:  https://gemnasium.com/syuilo/misskey-web
[dependencies-badge]: https://img.shields.io/gemnasium/syuilo/misskey-web.svg?style=flat-square
