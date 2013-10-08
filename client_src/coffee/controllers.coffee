app.controller "GalleryCtrl", ["$scope", "$timeout", "AlbumService", 'settings',   (scope, timeout, as, settings)->
	scope.galleryIndex = -1
	scope.elementIndex = -1
	
	thumbsLoadedCount = 0
	scope.thumbsLoaded = false
	scope.gallsShow = settings.galleriesShow
	scope.thumbsShow = settings.thumbnailsShow
	scope.background = ''
	scope.slideshow = false
	scope.switchGalleryProc = false

	scope.thumbsAni = false

	as.getAlbum( 1, (data)->
		scope.album = data
		scope.switchGallery(0)
	)


	scope.onThumbLoaded = ->
		thumbsLoadedCount++
		if thumbsLoadedCount is scope.elements.length
			scope.thumbsLoaded = true
			#console.log("thumbs loaded " + scope.thumbsLoaded )


	scope.switchGallery = (id) ->
		return false if scope.galleryIndex is id 	

		scope.galleryIndex = id
		scope.elementIndex = -1
		thumbsLoadedCount = 0
		scope.thumbsLoaded = false
		scope.slideshow = false
		scope.switchGalleryProc = true
		
		scope.switchImage(0, ->
			scope.gallery = scope.album.galleries[scope.galleryIndex]
			scope.elements = scope.gallery.elements
			scope.switchGalleryProc = false
		)


	scope.nextImage = ( slideshow = false )->
		id = scope.elementIndex+1
		if id > ( scope.elements.length - 1 )
			id = 0
		scope.switchImage( id )

		if slideshow isnt true
			scope.slideshow = false


	scope.prevImage = (slideshow = false)->
		scope.slideshow = false
		id = scope.elementIndex-1
		if id < 0
			id = ( scope.elements.length - 1 )
		scope.switchImage( id )


	scope.switchImage = (id, callback) ->
		return false if scope.elementIndex is id 
		scope.elementIndex = id
		scope.$image.addClass('veil')

		timeout(->
			callback() if typeof callback is 'function'
			scope.image = scope.elements[scope.elementIndex]
		,300)
		

	scope.safeApply = (fn) ->
		phase = this.$root.$$phase
		if phase is '$apply' or phase is '$digest'
			if fn and (typeof fn is 'function')
				fn()
		else
			scope.$apply(fn)
 
] # GalleryCtrl end