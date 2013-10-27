
app.controller("GalleryCtrl", [ "$scope", "$timeout", "$q", "AlbumService", 'settings',  (scope, to, q, as, sttgs)->
	scope.album = null
	scope.galleryIndex = null
	scope.elementIndex = null
	scope.slideshow = false

	scope.control = {
		thumbsShow : false
		galleriesShow : false
	}

	do scope.loadAlbum = ( idx=0)->
		albumPromise = as.getAlbum( 1 )
		albumPromise.then (album) ->
			scope.album = album
			scope.galleryIndex = null
			scope.selectGallery(0)


	scope.selectGallery = (idx) ->
		promise = as.preloadThumbs( idx )
		promise.then () ->
			scope.galleryIndex = idx
			scope.elementIndex = null
			scope.selectImage(0)


	scope.selectImage = (idx) ->
		as.loadImage( scope.galleryIndex, idx ).then () ->
			scope.elementIndex = idx


	scope.nextImage = () ->
		idx = scope.elementIndex
		if ++idx > scope.album.galleries[scope.galleryIndex].elements.length-1
			idx = 0

		scope.selectImage(idx)


	scope.prevImage = () ->
		idx = scope.elementIndex
		if --idx < 0
			idx = scope.album.galleries[scope.galleryIndex].elements.length-1

		scope.selectImage(idx)

			

	scope.safeApply = (fn) ->
		phase = this.$root.$$phase
		if phase is '$apply' or phase is '$digest'
			if fn and (typeof fn is 'function')
				fn()
		else
			scope.$apply(fn)



	# _prepareAlbumInfo = () ->		
	# 	scope.albumInfo.push({
	# 		label : album.galleries.length + " Galleries"
	# 		icon : 'glyphicon-book'
	# 	})
		
	# 	if totalImages > 0
	# 		scope.albumInfo.push({
	# 			label : totalImages + " Images"
	# 			icon : 'glyphicon-picture'
	# 		})

	# 	if totalVideos > 0
	# 		scope.albumInfo.push({
	# 			label : totalVideos + " Videos"
	# 			icon : 'glyphicon-film'
	# 		})

])