mk-drive-browser-base-contextmenu
	mk-contextmenu(controller={ ctx-controller })
		ul
			li: p
				i.fa.fa-folder-o
				| フォルダを作成
			li(onclick={ parent.upload }): p
				i.fa.fa-upload
				| ファイルをアップロード

script.
	@controller = @opts.controller
	@browser-controller = @opts.browser-controller
	@ctx-controller = riot.observable!

	@controller.on \open (pos) ~>
		@ctx-controller.trigger \open pos

	@ctx-controller.on \closed ~>
		@unmount!

	@upload = ~>
		@browser-controller.trigger \upload
		@ctx-controller.trigger \close
