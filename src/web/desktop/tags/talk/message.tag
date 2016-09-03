mk-talk-message(data-is-me={ message._is_me })
	a.avatar-anchor(href={ CONFIG.url + '/' + message.user.username }, title={ message.user.username }, target='_blank')
		img.avatar(src={ message.user.avatar_url + '?thumbnail&size=64' }, alt='')
	div.content-container
		div.balloon
			p.read(if={ message._is_me && message.is_read }) 既読
			button.delete-button(if={ message._is_me }, title='メッセージを削除')
				img(src='/_/resources/desktop/talk/delete.png', alt='Delete')
			div.content(if={ !message.is_deleted })
				div.text(if={ message.text }) { message.text }
				div.image(if={ message.file })
					img(src={ message.file.url }, alt='image', title={ message.file.name })
			div.content(if={ message.is_deleted })
				p.is-deleted このメッセージは削除されました
		footer
			time { message.created_at }
			i.fa.fa-pencil.is-edited(if={ message.is_edited })

style.
	$me-balloon-color = #23A7B6

	display block
	position relative
	padding 10px 12px 10px 12px
	background-color transparent

	&:after
		content ""
		display block
		clear both

	> .avatar-anchor
		display block

		> .avatar
			display block
			min-width 54px
			min-height 54px
			max-width 54px
			max-height 54px
			margin 0
			border-radius 8px
			transition all 0.1s ease

	> .content-container
		display block
		box-sizing border-box
		position relative
		margin 0 12px
		padding 0
		max-width calc(100% - 78px)

		> .balloon
			display block
			float inherit
			box-sizing border-box
			position relative
			margin 0
			padding 0
			max-width 100%
			min-height 2.1em
			line-height 1.3em
			border-radius 16px

			&:before
				content ""
				pointer-events none
				display block
				position absolute
				top calc(((1.3em + (8px * 2)) / 2) - 8px)

			&:hover
				> .delete-button
					display block

			> .delete-button
				display none
				position absolute
				z-index 1
				top -4px
				right -4px
				margin 0
				padding 0
				cursor pointer
				outline none
				border none
				border-radius 0
				box-shadow none
				background transparent

				> img
					vertical-align bottom
					width 16px
					height 16px
					cursor pointer

			> .read
				display block
				position absolute
				z-index 1
				bottom -4px
				left -12px
				margin 0
				color rgba(0, 0, 0, 0.5)
				font-size 0.7em

			> .content

				> .is-deleted
					display block
					margin 0
					padding 0
					overflow hidden
					word-wrap break-word
					font-size 1em
					color rgba(0, 0, 0, 0.5)

				> .text
					display block
					margin 0
					padding 8px 16px
					overflow hidden
					word-wrap break-word
					font-size 1em
					color rgba(0, 0, 0, 0.8)

					&, *
						user-select text
						-moz-user-select text
						-webkit-user-select text
						-ms-user-select text
						cursor auto

					.url
						color $theme-color
						text-decoration none

						&, *
							cursor pointer

						&:hover
							text-decoration underline

						&:after
							content "\f14c"
							display inline-block
							padding-left 2px
							font-family FontAwesome
							font-size 0.9em
							font-weight normal
							font-style normal

						> .protocol
							opacity 0.5

						> .hostname
							font-weight normal

						> .pathname
							opacity 0.8

						> .hash
							font-style italic

						> .query
							opacity 0.5

					> p
						margin 0

					& + .file
						&.image
							> img
								border-radius 0 0 16px 16px

				> .file
					&.image
						> img
							display block
							max-width 100%
							max-height 512px
							border-radius 16px

		> footer
			display block
			clear both
			margin 0
			padding 2px
			font-size 0.65em
			color rgba(0, 0, 0, 0.4)

			> .is-edited
				margin-left 4px

	> .avatar-anchor
		float left

	> .content-container
		float left

		> .balloon
			background #eee

			&:before
				left -14px
				border-top solid 8px transparent
				border-right solid 8px #eee
				border-bottom solid 8px transparent
				border-left solid 8px transparent

		> footer
			text-align left

	&[data-is-me='true']
		> .avatar-anchor
			float right

		> .content-container
			float right

			> .balloon
				background $me-balloon-color

				&:before
					right -14px
					left auto
					border-top solid 8px transparent
					border-right solid 8px transparent
					border-bottom solid 8px transparent
					border-left solid 8px $me-balloon-color

				> .content

					> p.is-deleted
						color rgba(255, 255, 255, 0.5)

					> .text
						color #fff

						.url
							color #fff

			> footer
				text-align right

	&[data-is-deleted='true']
			> .content-container
				opacity 0.5

script.
	@message = @opts.message
	@message._is_me = @message.user.id == I.id