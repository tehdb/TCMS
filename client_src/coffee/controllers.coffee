
app.controller("GalleryCtrl", [ "$scope", "$timeout", "$q", "AlbumService", 'settings',  (scope, to, q, as, sttgs)->
	scope.galleryIndex = 0
	scope.elementIndex = 0
	scope.album = null
	scope.element = null

	do scope.loadAlbum = ( idx=1)->
		albumPromise = as.getAlbum( 1 )
		albumPromise.then (album) ->
			scope.selectGallery( scope.galleryIndex, album)

	scope.selectGallery = (idx, album) ->
		_album = album or scope.album
		promise = as.preloadThumbs( _album, idx )
		promise.then (album) ->
			scope.album = album
			scope.galleryIndex = idx
			scope.selectImage(0)

	# TODO: preload image
	scope.selectImage = (idx) ->
		scope.elementIndex = idx
		path = scope.album.galleries[scope.galleryIndex].path
		scope.element = path + scope.album.galleries[scope.galleryIndex].elements[idx].file


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