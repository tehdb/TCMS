

app.controller "GalleryCtrl", [ "$scope", "$timeout", "AlbumService", 'settings',  (scope, timeout, as, settings)->
	scope.galleryIndex = 0
	scope.mediaElementIndex = 0


	as.getAlbum 1, (data) ->
		scope.album = data
		scope.gallery = scope.album.galleries[scope.galleryIndex]
		scope.mediaElements = scope.gallery.elements
		scope.mediaElement = scope.mediaElements[scope.mediaElementIndex]


	scope.showGallery = ( index) ->
		scope.galleryIndex = index
		scope.gallery = scope.album.galleries[scope.galleryIndex]
		scope.mediaElements = scope.gallery.elements
		scope.showMediaElement(0)

	scope.showMediaElement = ( index ) ->
		scope.mediaElementIndex = index
		scope.mediaElement = scope.mediaElements[scope.mediaElementIndex]

	scope.onStageImgLoaded = (msg = 'default')->
		#console.log( msg )



]
