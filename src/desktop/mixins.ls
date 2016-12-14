riot = require \riot

module.exports = (me) ~>
	riot.mixin \sortable do
		Sortable: require \Sortable

	if me?
		(require './scripts/stream.ls') me

	require './scripts/user-preview.ls'

	require './scripts/open-window.ls'

	riot.mixin \notify do
		notify: require './scripts/notify.ls'

	dialog = require './scripts/dialog.ls'

	riot.mixin \dialog do
		dialog: dialog

	riot.mixin \NotImplementedException do
		NotImplementedException: ~>
			dialog do
				'<i class="fa fa-exclamation-triangle"></i>Not implemented yet'
				'要求された操作は実装されていません。<br>→<a href="https://github.com/syuilo/misskey-web" target="_blank">Misskeyの開発に参加する</a>'
				[
					text: \OK
				]

	riot.mixin \input-dialog do
		input-dialog: require './scripts/input-dialog.ls'

	riot.mixin \update-avatar do
		update-avatar: require './scripts/update-avatar.ls'

	riot.mixin \update-banner do
		update-banner: require './scripts/update-banner.ls'

	riot.mixin \update-wallpaper do
		update-wallpaper: require './scripts/update-wallpaper.ls'

	riot.mixin \autocomplete do
		Autocomplete: require './scripts/autocomplete.ls'

	riot.mixin \follow-scroll do
		Follower: require './scripts/follow-scroll.ls'
