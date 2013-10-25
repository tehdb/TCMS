

app.service "AlbumService", ['$http', '$log', '$timeout', '$q', 'settings', (http, log, to, q, sttgs)->
	getAlbum : (id) ->
		defer = q.defer()
		http(
			method : 'GET'
			url : "/album/#{id}"
		).success((data, status, headers, config)->
			data.info = {
				totalImages : 0
				totalVideos : 0
			}
			
			coverTotal = data.galleries.length
			coverLoaded = 0

			# info data
			for g, gi in data.galleries
				thumbsPath = g.path + sttgs.thumbsPath
				for elem in g.elements
					# adds path to thumbnails to element objects
					# TODO: add more file types with regex!!!
					elem.thumbSrc = thumbsPath + elem.file.replace('.jpg', '_thumb.jpg')
					if elem.type is 'image'
						data.info.totalImages++
						elem.imgSrc = g.path + elem.file
					else if m.type is 'video'
						data.info.totalVideos++

				# preload cover
				img = new Image()
				img.onload = ->
					data.galleries[this.gidx].coverImg = this
					if ++coverLoaded >= coverTotal
						defer.resolve(data)
				img.src = g.elements[g.cover].thumbSrc
				img.gidx = gi

		).error((data, status, headers, config )->
			# log.warn( data, status, headers, config )
			defer.reject(status, config)
		)

		return defer.promise


	preloadThumbs : (album, gidx) ->
		defer = q.defer()

		if album.galleries[gidx].thumbsLoaded 
			to( ->
				defer.resolve( album )
			,11)
		else
			thumbsTotal = album.galleries[gidx].elements.length
			thumbsLoaded = 0

			for elem, eidx in album.galleries[gidx].elements
				thumb = new Image()
				thumb.onload = ->
					album.galleries[gidx].elements[this.idx].thumbImg = this
					if ++thumbsLoaded >= thumbsTotal
						album.galleries[gidx].thumbsLoaded = true
						defer.resolve( album )
				thumb.src = elem.thumbSrc
				thumb.idx = eidx

		return defer.promise

	# check if allready loaded, if not load it
	preloadImage : (album, gidx, iidx) ->
		defer = q.defer()

		gpath = scope.album.galleries[gidx].path

		img = new Image()
		img.onload = ->
			album.elements[gidx].elements[iidx].fileImg = this
			defer.resolve( album )

		img.onerror = ->
			defer.reject(status, config)


		img.src = gpath + album.elements[gidx].elements[iidx].file
		return defer.promise
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