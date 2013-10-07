'use strict'

app.directive "dynamicBackground", ->
	restrict: 'A'
	link : (scope, element, attrs) ->
		if attrs.dynamicBackground?
			scope.$watch( attrs.dynamicBackground, (newVal, oldVal) ->
				$(element).css({
					"background-color" : newVal
				})
			, false )



app.directive "stageImg", ['ImageService', 'settings', (imgs, sttgs)->
	restrict: 'A'
	link : (scope, element, attrs) ->

		scope.$image = element

		
		scope.$watch( ->
			scope.image
		, (newVal, oldVal) ->
			return if newVal is oldVal

			if sttgs.dynamicBackground is true
				colorPromise = imgs.getImageColor( scope.gallery.path+scope.image.file )
				colorPromise.then(
					(color) ->
						scope.background = "rgb(" + color.join(',') + ")"
						element.removeClass('veil')
					, (error) ->
						element.removeClass('veil')
				)
			else
				element.removeClass('veil')
		, false )
]


app.directive "imageOnLoad" , ->
	restrict: 'A'
	link : (scope, element, attrs) ->
		element.bind 'load', ->
			scope.$apply( attrs.imageOnLoad )



app.directive "scroller", ->
	restrict: 'A'

	controller : ['$scope' , (scope) ->
		_scroller = $('<div>').addClass('scroller veil')
		_factor = 1
		_topY = 0

		scope.scroller = _scroller

		@init = (elementH, contentH, top) ->
			_factor = elementH/contentH
			_topY = top
			_scroller.height(  _factor * elementH ).css('y', _topY)
			
		@setPos = (y) ->
			_scroller.css('y', -y*_factor + _topY)

		@show = ->
			_scroller.removeClass('veil')

		@hide = ->
			_scroller.addClass('veil')
	]

	link : (scope, element, attrs) ->
		scope.scroller.appendTo( element )



app.directive "sliderElement" , ->
	restrict: 'A'
	link : (scope, element, attrs) ->
		_index = parseInt( attrs.sliderElementIndex, 10 )
		_count = parseInt( attrs.sliderElementCount, 10 )
		_ani = attrs.sliderElementAni
		onChange = (val) ->
			if val
				element.transition({
					opacity : 0
					x : 40
					delay : 100 * _index
					duration : 200
				})
			else
				element.transition({
					opacity : 1
					x : 0
					delay : 100 * _index
					duration : 200
					onComplete : ->
						# TODO: notify slider 
						console.log( (_index+1), _count )
						if (_index+1) == _count
							console.log( "finish")
							console.log( scope )
							scope.thumbsAni = false
						
				})

		if attrs.sliderElement?
			scope.$watch( attrs.sliderElement, (newVal, oldVal) ->
				#scope.$apply( _ani+"=true")
				scope.thumbsAni = true
				onChange(newVal )
			, false )



app.directive "slider", ['$timeout', (timeout)->
	restrict: 'A'
	require : '?scroller'
	link : (scope, element, attrs, scrollerCtrl ) ->

		_blenderTop = $('<div>').addClass('blender blender-top veil').appendTo( element )
		_blenderBtm = $('<div>').addClass('blender blender-btm').appendTo( element )
		_elementH = 0
		_scrollOffsetY = 0

		_content = element.find('ul').first()
		limits = { top : 0, bottom : 0	}


		setLimits = ->
			limits = { top : 0, bottom : 0	}
			# TODO: find a way to outsmart angular and dom renderer without timeout
			timeout( ->
				containerH = element.actual('outerHeight')
				elementPaddingTop = parseInt(element.css('padding-top'), 10)
				elementPaddingBtm = parseInt(element.css('padding-bottom'), 10)
				

				containerH = containerH - elementPaddingTop - elementPaddingBtm
				contentH = _content.actual('outerHeight') 
				limits.bottom = containerH - contentH


				#_elementH = element.find('li').first().actual('outerHeight')
				_elementH = element.find('li').first().actual( 'outerHeight', {includeMargin:true} )

				#_elementH = li.outerHeight()

				#console.log( li.height(), li.outerHeight(), li., li.css('margin') )
				_scrollOffsetY = Math.round( (containerH - _elementH)/2 )
				_blenderTop.addClass('veil')
				_blenderBtm.addClass('veil')

				if 0 > limits.bottom
					scrolling( true ) 
					scrollerCtrl.init( containerH, contentH, elementPaddingTop)
					_blenderBtm.removeClass('veil')
				
				
			, 400 )

		scrolling = ( status=false ) ->
			if status is true
				mouseWheelScrolling()
				mouseDragDropScrolling()

			else
				element.unbind('mousewheel mouseenter mouseleave')
				_content.css('y', limits.top )


		mouseWheelScrolling = ->
			element.mousewheel (event, delta, deltaX, deltaY ) ->
				event.preventDefault
				event.stopPropagation
				y = parseInt(_content.css('y'), 10) + (delta*20)
				contentPosition( y )
				return false				

		contentPosition = (y, ani=false) ->
			if y >= limits.top
				y = limits.top
				_blenderTop.addClass('veil')

			else if y <= limits.bottom
				y = limits.bottom 
				_blenderBtm.addClass('veil')

			else
				_blenderTop.removeClass('veil')
				_blenderBtm.removeClass('veil')


			if ani
				_content.transition({'y': y})
			else
				_content.css('y', y )

			scrollerCtrl.setPos( y )


		mouseDragDropScrolling = ->
			element.mouseenter((event)->
				event.preventDefault
				event.stopPropagation
				scrollerCtrl.show()
			).mouseleave( (event)->
				event.preventDefault
				event.stopPropagation
				scrollerCtrl.hide()
			)

		if attrs.onGalleryChange?
			scope.$watch( attrs.onGalleryChange, (newVal, oldVal) ->
				return if newVal is oldVal
				scrolling( false )
				if newVal is true
					setLimits()
			, false )

		if attrs.onElementChange?
			scope.$watch( attrs.onElementChange, (newVal, oldVal) ->
				
				return if newVal is oldVal
				
				y = -(_elementH*newVal) + _scrollOffsetY

				contentPosition( y, true)
				#console.log("autoscroll to #{newVal} " + (-_elementH*newVal))

			, false )

		#if attrs.sliderAni?
		console.log( scope )
		scope.$watch( scope.thumbsAni, (vnew, vold) ->
			console.log( vnew, vold )
		)
]



app.directive "progressbar", ['settings', (settings) ->
	restrict: 'A'
	link : (scope, element, attrs ) ->
		progressAni = ->
			element.width(0).transition({
				width : '100%'
			}, settings.slideshowDur*1000 , 'linear', ->
				if scope.slideshow
					scope.nextImage( true )
					progressAni()
			)

		if attrs.progressbar?
			scope.$watch( attrs.progressbar, (newVal, oldVal) ->
				if newVal
					progressAni()
				else
					element.stop().width(0)
			, false )
]

app.directive "dropzone", ['settings', (settings) ->
	restrict: 'A'
	link : (scope, element, attrs ) ->
		$.event.props.push('dataTransfer');

		element.bind('dragenter dragover', false).bind('drop', (event) ->
			event.preventDefault()
			event.stopPropagation()

			$.each( event.dataTransfer.files, (index, file)->
				fr = new FileReader()
				fr.onload = (file) ->
					console.log( file )
					###
					(event) ->
						element.append( $('<img>').attr('src'))
					###

				fr.readAsDataURL( file )
			)
			console.log( event.dataTransfer.files )



		)
]

