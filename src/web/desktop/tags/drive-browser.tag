mk-drive-browser
	nav
		div.path(oncontextmenu={ path-oncontextmenu })
			mk-drive-browser-nav-folder(class={ current: folder == null }, folder={ null })
			virtual(each={ folder in hierarchy-folders })
				span.separator: i.fa.fa-angle-right
				mk-drive-browser-nav-folder(folder={ folder })
			span.separator(if={ folder != null }): i.fa.fa-angle-right
			span.folder.current(if={ folder != null })
				| { folder.name }
		input.search(type='search', placeholder!='&#xf002; 検索')
	div.main@main(class={ uploading: uploads.length > 0, loading: loading }, onmousedown={ onmousedown }, ondragover={ ondragover }, ondragenter={ ondragenter }, ondragleave={ ondragleave }, ondrop={ ondrop }, oncontextmenu={ oncontextmenu })
		div.selection@selection
		div.contents@contents
			div.folders@folders-container(if={ folders.length > 0 })
				virtual(each={ folder in folders })
					mk-drive-browser-folder.folder(folder={ folder })
			div.files@files-container(if={ files.length > 0 })
				virtual(each={ file in files })
					mk-drive-browser-file.file(file={ file })
			div.empty(if={ files.length == 0 && folders.length == 0 && !loading })
				p(if={ draghover })
					| ドロップですか？いいですよ、ボクはカワイイですからね
				p(if={ !draghover && folder == null })
					strong ドライブには何もありません。
					br
					| 右クリックして「ファイルをアップロード」を選んだり、ファイルをドラッグ&ドロップすることでもアップロードできます。
				p(if={ !draghover && folder != null })
					| このフォルダーは空です
		div.loading(if={ loading }).
			<div class="spinner">
				<div class="dot1"></div>
				<div class="dot2"></div>
			</div>
	mk-uploader(controller={ uploader-controller })
	input@file-input(type='file', accept='*/*', multiple, tabindex='-1', onchange={ change-file-input })

style.
	display block

	> nav
		display block
		position relative
		z-index 2
		box-sizing border-box
		width 100%
		overflow auto
		font-size 0.9em
		color #555
		background #fff
		//border-bottom 1px solid #dfdfdf
		box-shadow 0 1px 0 rgba(0, 0, 0, 0.05)

		&, *
			-ms-user-select none
			-moz-user-select none
			-webkit-user-select none
			user-select none

		> .path
			display inline-block
			vertical-align bottom
			box-sizing border-box
			margin 0
			padding 0 8px
			width calc(100% - 200px)
			line-height 38px
			white-space nowrap

			> *
				display inline-block
				margin 0
				padding 0 8px
				line-height 38px
				cursor pointer

				i
					margin-right 4px

				*
					pointer-events none

				&:hover
					text-decoration underline

				&.current
					font-weight bold
					cursor default

					&:hover
						text-decoration none

				&.separator
					margin 0
					padding 0
					opacity 0.5
					cursor default

					> i
						margin 0

		> .search
			display inline-block
			vertical-align bottom
			-webkit-appearance none
			-moz-appearance none
			appearance none
			user-select text
			-moz-user-select text
			-webkit-user-select text
			-ms-user-select text
			cursor auto
			box-sizing border-box
			margin 0
			padding 0 18px
			width 200px
			font-size 1em
			line-height 38px
			background transparent
			outline none
			//border solid 1px #ddd
			border none
			border-radius 0
			box-shadow none
			transition color 0.5s ease, border 0.5s ease
			font-family FontAwesome, 'Meiryo UI', 'Meiryo', 'メイリオ', sans-serif

			&[data-active='true']
				background #fff

			&::-webkit-input-placeholder,
			&:-ms-input-placeholder,
			&:-moz-placeholder
				color $ui-controll-foreground-color

	> .main
		position relative
		box-sizing border-box
		padding 8px
		height calc(100% - 38px)
		overflow auto

		&, *
			-ms-user-select none
			-moz-user-select none
			-webkit-user-select none
			user-select none

		&.loading
			cursor wait !important

			*
				pointer-events none

			> .contents
				opacity 0.5

		&.uploading
			height calc(100% - 38px - 100px)

		> .selection
			display none
			box-sizing border-box
			position absolute
			top 0
			left 0
			z-index 1
			border solid 1px $theme-color
			background rgba($theme-color, 0.5)
			pointer-events none

		> .contents

			> .folders
				&:after
					content ""
					display block
					clear both

				> .folder
					float left

			> .files
				&:after
					content ""
					display block
					clear both

				> .file
					float left

			> .empty
				padding 16px
				text-align center
				color #999
				pointer-events none

				> p
					margin 0

		> .loading
			.spinner
				margin 100px auto
				width 40px
				height 40px
				position relative
				text-align center

				-webkit-animation sk-rotate 2.0s infinite linear
				animation sk-rotate 2.0s infinite linear

			.dot1, .dot2
				width 60%
				height 60%
				display inline-block
				position absolute
				top 0
				background-color rgba(0, 0, 0, 0.3)
				border-radius 100%

				-webkit-animation sk-bounce 2.0s infinite ease-in-out
				animation sk-bounce 2.0s infinite ease-in-out

			.dot2
				top auto
				bottom 0
				-webkit-animation-delay -1.0s
				animation-delay -1.0s

			@-webkit-keyframes sk-rotate { 100% { -webkit-transform: rotate(360deg) }}
			@keyframes sk-rotate { 100% { transform: rotate(360deg); -webkit-transform: rotate(360deg) }}

			@-webkit-keyframes sk-bounce {
				0%, 100% { -webkit-transform: scale(0.0) }
				50% { -webkit-transform: scale(1.0) }
			}

			@keyframes sk-bounce {
				0%, 100% {
					transform: scale(0.0);
					-webkit-transform: scale(0.0);
				} 50% {
					transform: scale(1.0);
					-webkit-transform: scale(1.0);
				}
			}

	> mk-uploader
		height 100px
		padding 16px
		background #fff

	> input
		display none

script.
	@mixin \input-dialog
	@mixin \stream

	@files = []
	@folders = []
	@hierarchy-folders = []

	@uploads = []

	# 現在の階層(フォルダ)
	# * null でルートを表す
	@folder = null

	@controller = @opts.controller
	# Note: Riot3.0.0にしたら xmultiple を multiple に変更 (2.xでは、真理値属性と判定され__がプレフィックスされてしまう)
	@multiple = if @opts.xmultiple? then @opts.xmultiple else false

	@uploader-controller = riot.observable!

	@on \mount ~>
		@stream.on \drive_file_created @on-stream-drive-file-created
		@stream.on \drive_file_updated @on-stream-drive-file-updated
		@stream.on \drive_folder_created @on-stream-drive-folder-created

		if @opts.folder?
			@move @opts.folder
		else
			@load!

	@on \unmount ~>
		@stream.off \drive_file_created @on-stream-drive-file-created
		@stream.off \drive_file_updated @on-stream-drive-file-updated
		@stream.off \drive_folder_created @on-stream-drive-folder-created

	@on-stream-drive-file-created = (file) ~>
		@add-file file, true

	@on-stream-drive-file-updated = (file) ~>
		current = if @folder? then @folder.id else null
		updated-file-parent = if file.folder? then file.folder else null
		if current != updated-file-parent
			@files = @files.filter (f) -> f.id != file.id
			@update!
		else
			@add-file file, true

	@on-stream-drive-folder-created = (folder) ~>
		@add-folder folder, true

	@onmousedown = (e) ~>
		if (contains @folders-container, e.target) or (contains @files-container, e.target)
			return true

		rect = @main.get-bounding-client-rect!

		left = e.page-x + @main.scroll-left - rect.left - window.page-x-offset
		top = e.page-y + @main.scroll-top - rect.top - window.page-y-offset

		move = (e) ~>
			@selection.style.display = \block

			cursor-x = e.page-x + @main.scroll-left - rect.left - window.page-x-offset
			cursor-y = e.page-y + @main.scroll-top - rect.top - window.page-y-offset
			w = cursor-x - left
			h = cursor-y - top

			if w > 0
				@selection.style.width = w + \px
				@selection.style.left = left + \px
			else
				@selection.style.width = -w + \px
				@selection.style.left = cursor-x + \px

			if h > 0
				@selection.style.height = h + \px
				@selection.style.top = top + \px
			else
				@selection.style.height = -h + \px
				@selection.style.top = cursor-y + \px

		up = (e) ~>
			document.document-element.remove-event-listener \mousemove move
			document.document-element.remove-event-listener \mouseup up

			@selection.style.display = \none

		document.document-element.add-event-listener \mousemove move
		document.document-element.add-event-listener \mouseup up

	@path-oncontextmenu = (e) ~>
		e.stop-immediate-propagation!
		return false

	@oncontextmenu = (e) ~>
		e.stop-immediate-propagation!
		ctx = document.body.append-child document.create-element \mk-drive-browser-base-contextmenu
		ctx-controller = riot.observable!
		riot.mount ctx, do
			controller: ctx-controller
			browser-controller: @controller
		ctx-controller.trigger \open do
			x: e.page-x - window.page-x-offset
			y: e.page-y - window.page-y-offset
		return false

	@controller.on \upload ~>
		@file-input.click!

	@controller.on \move (folder) ~>
		@move folder

	@controller.on \new-window (folder) ~>
		@new-window folder

	@controller.on \create-folder ~>
		@input-dialog do
			'フォルダー作成'
			'フォルダー名'
			null
			(name) ~>
				api 'drive/folders/create' do
					name: name
					folder: if @folder? then @folder.id else undefined
				.then (folder) ~>
					@add-folder folder, true
					@update!
				.catch (err) ~>
					console.error err

	@change-file-input = ~>
		files = @file-input.files
		for i from 0 to files.length - 1
			file = files.item i
			@upload file, @folder

	@upload = (file, folder) ~>
		if folder? and typeof folder == \object
			folder = folder.id
		@uploader-controller.trigger do
			\upload
			file
			folder

	@uploader-controller.on \uploaded (file) ~>
		@add-file file, true

	@uploader-controller.on \change-uploads (uploads) ~>
		@uploads = uploads
		@update!

	@get-selection = ~>
		@files.filter (file) -> file._selected

	@new-window = (folder-id) ~>
		browser = document.body.append-child document.create-element \mk-drive-browser-window
		browser-controller = riot.observable!
		riot.mount browser, do
			controller: browser-controller
			folder: folder-id
		browser-controller.trigger \open

	@move = (target-folder) ~>
		if target-folder? and typeof target-folder == \object
			target-folder = target-folder.id

		if target-folder == null
			@go-root!
		else
			@loading = true
			@update!

			api 'drive/folders/show' do
				folder: target-folder
			.then (folder) ~>
				@folder = folder
				@hierarchy-folders = []

				x = (f) ~>
					@hierarchy-folders.unshift f
					if f.folder?
						x f.folder

				if folder.folder?
					x folder.folder

				@update!
				@load!
			.catch (err, text-status) ->
				console.error err

	@add-folder = (folder, unshift = false) ~>
		current = if @folder? then @folder.id else null
		addee-parent = if folder.folder? then folder.folder else null
		if current != addee-parent
			return

		if (@folders.some (f) ~> f.id == folder.id)
			return

		if unshift
			@folders.unshift folder
		else
			@folders.push folder

		@update!

	@add-file = (file, unshift = false) ~>
		current = if @folder? then @folder.id else null
		addee-parent = if file.folder? then file.folder else null
		if current != addee-parent
			return

		if (@files.some (f) ~> f.id == file.id)
			# TODO: ただreturnするのではなく情報を更新する
			return

		if unshift
			@files.unshift file
		else
			@files.push file

		@update!

	@remove-file = (file) ~>
		if typeof file == \object
			file = file.id
		@files = @files.filter (f) -> f.id != file
		@update!

	@ondragover = (e) ~>
		# ドラッグされてきたものがファイルだったら
		if e.data-transfer.effect-allowed == \all
			e.stop-propagation!
			e.data-transfer.drop-effect = \copy
			return false
		else
			e.data-transfer.drop-effect = \none

	@ondragenter = (e) ~>
		# ドラッグされてきたものがファイルだったら
		if e.data-transfer.effect-allowed == \all
			@draghover = true

	@ondragleave = (e) ~>
		# ドラッグされてきたものがファイルだったら
		if e.data-transfer.effect-allowed == \all
			@draghover = false

	@ondrop = (e) ~>
		# ドラッグされてきたものがファイルだったら
		if e.data-transfer.files.length > 0
			e.stop-propagation!
			@draghover = false

			Array.prototype.for-each.call e.data-transfer.files, (file) ~>
				@upload file, @folder

			return false

	@go-root = ~>
		if @folder != null
			@folder = null
			@hierarchy-folders = []
			@update!
			@load!

	@load = ~>
		@folders = []
		@files = []
		@loading = true
		@update!

		load-folders = null
		load-files = null

		api 'drive/folders' do
			folder: if @folder? then @folder.id else null
			limit: 30
		.then (folders) ~>
			load-folders := folders
			complete!
		.catch (err, text-status) ~>
			console.error err

		api 'drive/files' do
			folder: if @folder? then @folder.id else null
			limit: 30
		.then (files) ~>
			load-files := files
			complete!
		.catch (err, text-status) ~>
			console.error err

		flag = false
		complete = ~>
			if flag
				load-folders.for-each (folder) ~>
					@add-folder folder
				load-files.for-each (file) ~>
					@add-file file
				@loading = false
				@update!
			else
				flag := true

	function contains(parent, child)
		node = child.parent-node
		while (node != null)
			if (node == parent)
				return true
			node = node.parent-node
		return false
