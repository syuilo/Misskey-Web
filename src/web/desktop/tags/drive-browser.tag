mk-drive-browser
	div.main
		div.folder(each={ folder in folders })
			p { folder.name }
		div.file(each={ file in files })
			img(src={ file.url + '/thumbnail?size=128' }, alt='')
			p { file.name }

style.
	display block

	> .main
		height 100%
		overflow auto

		&:after
			content ""
			display block
			clear both

		> .file
			float left

script.
	@files = null
	@folders = null

	# 現在の階層(フォルダ)
	# * null でルートを表す
	@folder = null

	@on \mount ~>
		@load!

	@load = ~>
		api 'drive/files' do
			folder: @folder
		.then (files) ~>
			@files = files
			@update!
		.catch (err, text-status) ->
			console.error err
