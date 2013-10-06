
###
Module dependencies.
###
express = require("express")
routes = require("./routes")
http = require("http")
path = require("path")
app = express()

# all environments
app
	.set( "port", process.env.PORT or 3000 )
	.set( "views", __dirname + "/views" )
	.set( "view engine", "jade" )
	
	.use( express.favicon() )
	.use( express.logger("dev") )
	.use( express.bodyParser() )
	.use( express.methodOverride() )
	.use( app.router )
	.use( express.static(path.join(__dirname, "public")) )

	# development only
	.use( express.errorHandler({dumpExceptions: true, showStack: true}) )

	# routing
	.get( "/", routes.index )
	.get( "/gallery", routes.gallery )
	.get( "/album/:id", routes.album )


http.createServer(app).listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")

