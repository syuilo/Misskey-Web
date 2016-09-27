mk-user-preview
	div.banner@banner(style={ user.banner_url ? 'background-image: url(' + user.banner_url + '?thumbnail&size=1024)' : '' }, onclick={ on-update-banner })
	a.avatar(href={ CONFIG.url + '/' + user.username }, target='_blank'): img(src={ user.avatar_url + '?thumbnail&size=64' }, alt='avatar')
	div.title
		p.name { user.name }
		p.username @{ user.username }
	div.bio { user.bio }
	div.status
		div
			p 投稿
			a { user.posts_count }
		div
			p フォロー
			a { user.following_count }
		div
			p フォロワー
			a { user.followers_count }

style.
	display block
	position absolute
	z-index 2048
	width 250px
	font-family 'Meiryo', 'メイリオ', sans-serif
	background #fff
	background-clip content-box
	border solid 1px rgba(0, 0, 0, 0.1)
	border-radius 4px
	overflow hidden

	> .banner
		height 84px
		background-color #f5f5f5
		background-size cover
		background-position center

	> .avatar
		display block
		position absolute
		top 62px
		left 14px

		> img
			display block
			width 58px
			height 58px
			margin 0
			border solid 3px #fff
			border-radius 8px

	> .title
		display block
		padding 8px 0 8px 86px

		> .name
			display block
			margin 0
			font-weight bold
			line-height 16px
			color #656565

		> .username
			display block
			margin 0
			line-height 16px
			font-size 0.8em
			color #999

	> .bio
		padding 0 16px
		font-size 0.7em
		color #555

	> .status
		padding 8px 16px

		> div
			display inline-block
			width 33%

			> p
				margin 0
				font-size 0.7em
				color #aaa

			> a
				font-size 1em
				color $theme-color

	> mk-follow-button
		position absolute
		top 92px
		right 8px

script.
	@q = @opts.user
	@user = null

	@on \mount ~>
		api \users/show do
			id: if @q.0 == \@ then undefined else @q
			username: if @q.0 == \@ then @q.substr 1 else undefined
		.then (user) ~>
			@user = user
			@update!

			if SIGNIN and user.id != I.id
				e = @root.append-child document.create-element \mk-follow-button
				riot.mount e, do
					user: @user

		Velocity @root, {
			opacity: 0
			'margin-top': \-8px
		} 0ms
		Velocity @root, {
			opacity: 1
			'margin-top': 0
		} {
			duration: 200ms
			easing: \ease-out
		}

	@close = ~>
		Velocity @root, {
			opacity: 0
			'margin-top': \-8px
		} {
			duration: 200ms
			easing: \ease-out
			complete: ~> @unmount!
		}
