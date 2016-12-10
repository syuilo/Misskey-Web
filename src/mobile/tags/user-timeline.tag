mk-user-timeline
	mk-timeline(init={ init }, more={ more }, empty={ 'このユーザーはまだ投稿していないようです。' })

style.
	display block
	max-width 600px
	margin 0 auto
	background #fff

script.
	@mixin \api

	@user = @opts.user
	@event = @opts.event
	@with-media = @opts.with-media

	@init = new Promise (res, rej) ~>
		@api \users/posts do
			user_id: @user.id
			with_media: @with-media
		.then (posts) ~>
			res posts
			if @event? then @event.trigger \loaded

	@more = ~>
		@api \users/posts do
			user_id: @user.id
			with_media: @with-media
			max_id: @refs.timeline.tail!.id
