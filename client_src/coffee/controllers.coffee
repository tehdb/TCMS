

app.controller("GalleryCtrl", [ "$scope", "$timeout", "AlbumService", 'settings',  (scope, timeout, as, sttgs)->
	scope.galleryIndex = 0
	scope.mediaElementIndex = 0


	as.getAlbum 1, (data) ->
		_prepareData(data)
		###
		scope.album = data
		scope.gallery = scope.album.galleries[scope.galleryIndex]
		scope.mediaElements = scope.gallery.elements
		scope.mediaElement = scope.mediaElements[scope.mediaElementIndex]
		###


	#************************************************************
	#** private *************************************************
	_prepareData = (data) ->
		album = data
		gallery = album.galleries[scope.galleryIndex]
		elements = gallery.elements
		path = gallery.path+sttgs.thumbnsPath
		
		# preload thumbs
		thumbsCount = elements.length
		thumbsLoaded = 0
		for el, index in elements
			img = new Image()
			img.onload = ->
				console.log( this.src , "loaded")
				if ++thumbsLoaded >= thumbsCount
					_setData({
						gallery : gallery
						elements : elements
					})
			img.src = path+el.thumb
			elements[index].thumbSrc = img.src
			elements[index].thumbImgObj = img

	_setData = (data) ->
		scope.$apply(->
			scope.gallery = data.gallery
			scope.mels = data.elements
		)


		#mediaElements = gallery.elements
		#_preloadThumbs( gallery.elements, (gallery.path+sttgs.thumbnsPath) )

	_preloadThumbs = (els, path) ->
		thumbsCount = els.length
		thumbsLoaded = 0
		for el, index in els
			img = new Image()
			img.onload = ->
				if ++thumbsLoaded >= thumbsCount
					console.log("thumbs loaded")
			img.src = path+el.thumb

			el.thumbImgObj = img



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

]).resolve = {


}
