app = angular.module "TGallery", ["ngAnimate"]


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
	

app.controller "GalleryCtrl", ["$scope", "AlbumService", (scope, as)->
	galleryIndex = -1
	scope.elementIndex = -1

	scope.gallsShow = false
	scope.thumbsShow = false
	scope.background = 'rgb(0,0,0)'

	as.getAlbum( 1, (data)->
		scope.album = data
		scope.switchGallery(0)
	)

	scope.switchGallery = (id) ->
		return false if galleryIndex is id 	

		galleryIndex = id
		scope.elementIndex = 0
		
		scope.gallery = scope.album.galleries[galleryIndex]
		scope.elements = scope.gallery.elements

		scope.$image.addClass('veil')
		scope.image = scope.elements[scope.elementIndex]
		scope.safeApply()

	scope.nextImage = ()->
		id = scope.elementIndex+1
		if id > (scope.elements.length-1)
			id = 0
		scope.switchImage(id)

	scope.prevImage = ()->
		id = scope.elementIndex-1
		if id < 0
			id = (scope.elements.length-1)
		scope.switchImage(id)

	scope.switchImage = (id) ->
		return false if scope.elementIndex is id 
		scope.elementIndex = id
		scope.$image.addClass('veil')
		window.setTimeout(->
			scope.image = scope.elements[scope.elementIndex]
			scope.safeApply()
		,300)
		

	scope.safeApply = (fn) ->
		phase = this.$root.$$phase
		if phase is '$apply' or phase is '$digest'
			if fn and (typeof fn is 'function')
				fn()
		else
			scope.$apply(fn)

]

app.directive "dynbg", ->
	restrict: 'A'
	link : (scope, element, attrs) ->
		if attrs.dynbg?
			scope.$watch( attrs.dynbg, (newVal, oldVal) ->
				$(element).css({
					"background-color" : newVal
				})
			, false )

app.directive "stageimg", ->
	restrict: 'A'
	link : (scope, element, attrs) ->
		#$img = element.find('img')
		#scope.$image = $img
		scope.$image = element
		loadImage = ->
			hist = {}
			img = new Image()
			img.onload = ->
				Pixastic.process(
					img, 
					"colorhistogram", 
					{
						paint: false
						returnValue: hist
					}, ->
						evalHist( hist )
				)
			img.src = scope.gallery.path + scope.image.file
			

		evalHist = (hist) ->
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

			rgb = [
				getMax(hist.rvals),
				getMax(hist.gvals),
				getMax(hist.bvals)
			]
			
			###
			$(element).parent().css({
				background : "rgb(" + rgb.join(',') + ")"
			})
			###
			scope.background = "rgb(" + rgb.join(',') + ")"
			element.removeClass('veil')
			scope.safeApply()

		scope.$watch( ->
			scope.image
		, (newVal, oldVal) ->
			return if newVal is oldVal
			loadImage()
		, false )


app.directive "slider", ->
	restrict: 'A'
	link : (scope, element, attrs) ->
		$element = element
		$content = $element.find('ul').first()

		limits = {
			top : 0
			bottom : 0
		}


		checkImgsLoaded = ->
			$imgs = $content.find('img')
			loaded = 0
			count = $imgs.length
			if count > 0
				$imgs.each (index)->
					$(this).bind('load', ->
						loaded++
						console.log( loaded + " of " + count)
						setLimits() if loaded is count
					)
			else
				setLimits()


		setLimits = ->
			limits.top = 0
			limits.bottom =  $element.actual('outerHeight') - $content.actual('outerHeight') - 2*parseInt($element.css('padding'), 10)
			console.log( limits.bottom )
			mouseWeelScroll() if 0 > limits.bottom
			#animateElements()

		###
		animateElements = ->
			$els = $content.find('li')
			$els.addClass('veil')
			count = $els.length
			index = 0
			animateEl = (el) ->
				$(el).removeClass('veil')
				window.setTimeout(->
					index++
					if index isnt count
						animateEl($els.get(index))
				,100)

			window.setTimeout(->
				animateEl($els.get(index))
			,1000)
		###


		mouseWeelScroll = ->
			console.log("scroll")
			$element.mousewheel (event, delta, deltaX, deltaY ) ->
				event.preventDefault
				event.stopPropagation
				y = parseInt($content.css('y'), 10) + (delta*20)

				y = limits.top if y > limits.top
				y = limits.bottom if y < limits.bottom
				$content.css('y', y )

		if attrs.sliderDepend?
			scope.$watch( attrs.sliderDepend, (newVal, oldVal) ->
				console.log( "***",  attrs.sliderDepend )
				#return if newVal is oldVal

				$element.unbind('mousewheel')
				$content.css('y', limits.top )
				checkImgsLoaded()
			, false )

		$element.find('.toggle').click (event)->
			event.preventDefault
			event.stopPropagation
			element.toggleClass(attrs.slider)

		#mouseWeelScroll()
