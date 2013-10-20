
app.controller("GalleryCtrl", [ "$scope", "$timeout", "AlbumService", 'settings',  (scope, timeout, as, sttgs)->
	scope.galleryIndex = 0
	scope.mediaElementIndex = 0
	scope.album = null
	scope.albumInfo = []
	scope.dialogShow = false

	as.getAlbum 1, (data) ->
		_prepareData(data)

	_prepareData = (data) ->
		album = data
		totalImages = 0
		totalVideos = 0

		# gallery = album.galleries[scope.galleryIndex]
		# elements = gallery.elements
		
		# prepare paths to images/thumbs and count file by type
		for g, gidx in album.galleries
			thumbsPath = g.path + sttgs.thumbsPath
			
			for m, midx in g.elements
				if m.type is 'image'
					totalImages++
					m.imgSrc = g.path + m.file
				else if m.type is 'video'
					totalVideos++

				m.thumbSrc = thumbsPath + m.thumb

		# _setData(
		# 	gallery : gallery
		# 	elements : elements
		# )
		
		scope.albumInfo.push({
			label : album.galleries.length + " Galleries"
			icon : 'glyphicon-book'
		})
		
		if totalImages > 0
			scope.albumInfo.push({
				label : totalImages + " Images"
				icon : 'glyphicon-picture'
			})

		if totalVideos > 0
			scope.albumInfo.push({
				label : totalVideos + " Videos"
				icon : 'glyphicon-film'
			})

		

	_setData = (data) ->
		console.log( data )
		# scope.$apply(->
		# 	scope.gallery = data.gallery
		# 	scope.mels = data.elements
		# )


	scope.openGallery = ->
		console.log("open gallery")
		scope.dialogShow = true

])