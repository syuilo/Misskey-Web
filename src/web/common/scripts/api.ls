riot = require \riot

spinner = null
api-stack = 0

net = riot.observable!

riot.mixin \net do
	net: net

module.exports = (i, endpoint, data) ->
	api-stack++

	if typeof i == \object then i = i._web

	body = []

	for k, v of data
		if v != undefined
			v = encodeURIComponent v
			body.push "#k=#v"

	if i?
		body.push "_i=#i"

	web = (endpoint.index-of '://') > -1

	opts =
		method: \POST
		headers:
			'Content-Type': 'application/x-www-form-urlencoded; charset=utf-8'
		body: body.join \&

	if web
		ep = endpoint
		opts.credentials = \include
	else
		ep = "#{CONFIG.api.url}/#{endpoint}"

	if api-stack == 1
		spinner := document.create-element \div
			..set-attribute \id \wait
		document.body.append-child spinner

	new Promise (resolve, reject) ->
		timer = set-timeout ->
			net.trigger \detected-slow-network
		, 5000ms
		fetch ep, opts
		.then (res) ->
			api-stack--
			clear-timeout timer
			if api-stack == 0
				spinner.parent-node.remove-child spinner

			if res.status == 200
				res.json!
			else if res.status == 204
				resolve!
			else
				res.json!.then (err) ->
					reject err.error
		.then (data) ->
			resolve data
		.catch (e) ->
			reject e
