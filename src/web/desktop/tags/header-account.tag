mk-header-account
	button.header(data-active={ is-open }, onclick={ toggle })
		span.username
			| { USER.username }
			i.fa.fa-angle-down(if={ !is-open })
			i.fa.fa-angle-up(if={ is-open })
		img.avatar(src={ USER.avatar_url + '?size=64' }, alt='avatar')
	div.menu(if={ is-open })
		ul
			li: a.ui-waves-effect(href= config.url + '/' + { USER.username })
				i.fa.fa-user
				| プロフィール
				i.fa.fa-angle-right
			li(onclick={ drive }): p
				i.fa.fa-cloud
				| ドライブ
				i.fa.fa-angle-right
			li: a.ui-waves-effect(href= config.url + '/{ USER.username }/likes')
				i.fa.fa-star
				| お気に入り
				i.fa.fa-angle-right
		ul
			li: a.ui-waves-effect(href= config.url + '/i/settings')
				i.fa.fa-cog
				| 設定
				i.fa.fa-angle-right
		ul
			li: a.ui-waves-effect(href= config.signoutUrl)
				i(class='fa fa-power-off')
				| サインアウト
				i.fa.fa-angle-right

style.
	$ui-controll-background-color = #fffbfb
	$ui-controll-foreground-color = #ABA49E

	display block
	float left
	position relative

	&[data-active='true']
		> .header
			background #fff

			> .avatar
				filter saturate(200%)
				-webkit-filter saturate(200%)
				-moz-filter saturate(200%)
				-o-filter saturate(200%)
				-ms-filter saturate(200%)

	> .header
		-webkit-appearance none
		-moz-appearance none
		appearance none
		display block
		margin 0
		padding 0
		color $ui-controll-foreground-color
		border none
		background transparent
		cursor pointer

		*
			pointer-events none

		&:hover
			color darken($ui-controll-foreground-color, 20%)

		&:active
			color darken($ui-controll-foreground-color, 30%)

		> .username
			display block
			float left
			margin 0 12px 0 16px
			max-width 16em
			line-height 48px
			font-weight bold
			font-family Meiryo, sans-serif
			text-decoration none

			i
				margin-left 8px

		> .avatar
			display block
			float left
			box-sizing border-box
			min-width 32px
			max-width 32px
			min-height 32px
			max-height 32px
			margin 8px 8px 8px 0
			border-radius 4px

	> .menu
		display block
		position absolute
		top 56px
		right -2px
		width 230px
		font-size 0.8em
		background #fff
		border-radius 4px
		box-shadow 0 1px 4px rgba(0, 0, 0, 0.25)

		&:before
			content ""
			pointer-events none
			display block
			position absolute
			top -28px
			right 12px
			border-top solid 14px transparent
			border-right solid 14px transparent
			border-bottom solid 14px rgba(0, 0, 0, 0.1)
			border-left solid 14px transparent

		&:after
			content ""
			pointer-events none
			display block
			position absolute
			top -27px
			right 12px
			border-top solid 14px transparent
			border-right solid 14px transparent
			border-bottom solid 14px #fff
			border-left solid 14px transparent

		ul
			display block
			margin 10px 0
			padding 0
			list-style none

			& + ul
				padding-top 10px
				border-top solid 1px #eee

			> li
				display block
				margin 0
				padding 0

				> a
				> p
					display block
					position relative
					z-index 1
					padding 0 28px
					margin 0
					line-height 40px
					color #868C8C
					cursor pointer

					*
						pointer-events none

					> i:first-of-type
						margin-right 6px

					> i:last-of-type
						display block
						position absolute
						top 0
						right 8px
						z-index 1
						padding 0 20px
						font-size 1.2em
						line-height 40px

					&:hover, &:active
						text-decoration none
						background $theme-color
						color $theme-color-foreground

script.
	@is-open = false

	@toggle = ~>
		if @is-open
			@close!
		else
			@open!

	@open = ~>
		@is-open = true
		@update!
		all = document.query-selector-all 'body *'
		Array.prototype.for-each.call all, (el) ~>
			el.add-event-listener \mousedown @mousedown

	@close = ~>
		@is-open = false
		@update!
		all = document.query-selector-all 'body *'
		Array.prototype.for-each.call all, (el) ~>
			el.remove-event-listener \mousedown @mousedown

	@mousedown = (e) ~>
		e.prevent-default!
		if (!contains @root, e.target) and (@root != e.target)
			@close!
		return false

	@drive = ~>
		@close!
		browser = document.body.append-child document.create-element \mk-drive-browser-window
		browser-controller = riot.observable!
		riot.mount browser, do
			controller: browser-controller
		browser-controller.trigger \open

	function contains(parent, child)
		node = child.parent-node
		while (node != null)
			if (node == parent)
				return true
			node = node.parent-node
		return false
