mk-post-form-dialog
	div.bg@bg
	div.form@body
		header
			h1 { reply ? '返信' : '新規投稿' }
			button.close(onclick={ close }): i.fa.fa-times
			button.post(onclick={ post }, disabled={ posting })
				i.fa.fa-paper-plane-o(if={ !postiong })
				i.fa.fa-spinner.fa-pulse(if={ postiong })
		div.form
			mk-post-preview(if={ reply }, post={ reply })
			mk-post-form@form(reply={ reply })

style.
	display block

	> .bg
		position fixed
		z-index 2048
		top 0
		left 0
		width 100%
		height 100%
		background rgba(#000, 0.5)

	> .form
		position fixed
		z-index 2048
		top 16px
		left 0
		right 0
		margin 0 auto
		width calc(100% - 32px)
		max-width 500px
		max-height calc(100% - 32px)
		overflow hidden
		background #fff
		border-radius 8px
		box-shadow 0 0 16px rgba(#000, 0.3)

		> header

			> h1
				margin 0
				padding 0
				text-align center
				line-height 42px
				font-size 1em
				font-weight normal

			> .close
				position absolute
				top 0
				left 0
				line-height 42px
				width 42px

			> .post
				position absolute
				top 0
				right 0
				line-height 42px
				width 42px

		> .form
			height calc(100% - 42px)
			overflow scroll

			> mk-post-preview
				padding 16px

script.
	@mixin \window

	@reply = @opts.reply
	@posting = false

	@post = ~>
		@refs.form.post!

	@refs.form.on \before-post ~>
		@posting = true
		@update!

	@refs.form.on \after-post ~>
		@posting = false
		@update!

	@refs.form.on \post ~>
		@close!
