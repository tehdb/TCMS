
app.controller("GalleryCtrl", [ "$scope", "$timeout", "$q", "AlbumService", 'settings',  (scope, timeout, q, as, sttgs)->
	scope.galleryIndex = 0
	scope.elementIndex = 0

	scope.album = null
	scope.dialogShow = false

	do _loadAlbum = ( idx=1)->
		albumPromise = as.getAlbum( 1 )
		albumPromise.then (album) ->
			thumbsPromise = _preloadThumbs( album.galleries[scope.galleryIndex].elements )
			thumbsPromise.then (elements)->
				album.galleries[scope.galleryIndex].elements = elements
				scope.album = album

	_prepareAlbumInfo = () ->		
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

	_preloadThumbs = ( elements ) ->
		defer = q.defer()
		thumbsTotal = elements.length
		thumbsLoaded = 0

		for elem, eidx in elements
			thumb = new Image()
			thumb.onload = ->
				elements[this.idx].thumbImg = this
				thumbsLoaded++
				if thumbsLoaded >= thumbsTotal
					defer.resolve(elements)
			thumb.src = elem.thumbSrc
			thumb.idx = eidx

		return defer.promise


	scope.openGallery = ->
		console.log("open gallery")
		scope.dialogShow = true

])