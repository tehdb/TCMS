app.service "AlbumService", ['$http', '$log', (http, log)->
	getAlbum : (id, callback) ->
		http(
			method : 'GET'
			url : "/album/#{id}"
		).success((data, status, headers, config)->
			# adds path to thumbnails to element objects
			# TODO: add more file types!!!
			i.thumb = i.file.replace('.jpg', '_thumb.jpg') for i in g.elements for g in data.galleries 
			callback(data)
		).error((data, status, headers, config )->
			log.warn( data, status, headers, config )
		)
]

app.service "ImageService", ['$q', ( q ) ->
	getImageColor : ( imgSrc ) ->
		hist = {}
		deferred = q.defer()

		evalHist = ( hist ) ->
			getMax = (color) ->	
				max = 0
				idx = 0
				$.each( color, (index)->
					val = color[index]
					if val > max
						max = val
						idx = index
				)
				return idx

			return [ getMax(hist.rvals), getMax(hist.gvals), getMax(hist.bvals) ]


		img = new Image()
		
		img.onload = ->
			Pixastic.process(
				img, 
				"colorhistogram", 
				{
					paint: false
					returnValue: hist
				}, ->
					deferred.resolve( evalHist( hist ) )
				)
		img.onerror = ->
			deferred.reject('load error')

		img.src = imgSrc

		return deferred.promise
]