util = require('util')
db = require('./../db.coffee')

#
# * GET home page.
# 
exports.index = (req, res) ->
	res.render "index",
		title: "Express"

exports.gallery = (req, res) ->
	res.render "gallery",
		title : "Gallery"

exports.gallery2 = (req, res) ->
	res.render("gallery2",
		title : "Gallery v2"
	)	

exports.album = (req, res) ->
	res.format
		http : ->
			res.send("404 error")
		json : ->
			res.json( db.getAlbum(req.params.id) )
