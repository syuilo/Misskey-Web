# Fetch me
#================================

riot = require \riot

api = require './common/scripts/api.ls'
signout = require './common/scripts/signout.ls'
generate-default-userdata = require './common/scripts/generate-default-userdata.ls'

fetchme = (token, cb) ~>
	me = null

	# Return when not signed in
	if not token? then return done!

	# Fetch user
	fetch "#{CONFIG.api.url}/i" do
		method: \POST
		headers:
			'Content-Type': 'application/x-www-form-urlencoded; charset=utf-8'
		body: "i=#token"
	.then (res) ~>
		# When failed to authenticate user
		if res.status != 200 then signout!

		i <~ res.json!.then
		me := i
		me.token = token

		# initialize it if user data is empty
		if me.data? then done! else init!
	.catch ~>
		info = document.create-element \mk-core-error
			|> document.body.append-child
		riot.mount info, do
			retry: ~> fetchme token, cb

	function done
		if cb? then cb if me? then riot.observable me else null

	function init
		data = generate-default-userdata!

		api token, \i/appdata/set do
			data: JSON.stringify data
		.then ~>
			me.data = data
			done!

module.exports = fetchme
