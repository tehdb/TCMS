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




app.directive "slider" , [ '$timeout', (timeout)->
	restrict : 'A'
	require : '?scroller'
	controller : [ '$scope', (scope) ->
		this.callMe = ->
			scope.setLimits()
	]

	link : (scope, element, attrs, scrollerCtrl ) ->
		_blenderTop = $('<div>').addClass('blender blender-top veil').appendTo( element )
		_blenderBtm = $('<div>').addClass('blender blender-btm').appendTo( element )
		_elementH = 0
		_scrollOffsetY = 0

		_content = element.find('ul').first()
		limits = { top : 0, bottom : 0	}
		
		scope.setLimits = ->
			#console.log("set limits")
			_setLimits()

		_setLimits = ->
			limits = { top : 0, bottom : 0	}
			# TODO: find a way to outsmart angular and dom renderer without timeout
			timeout( ->
				_content = element.find('ul').first()

				containerH = element.actual('outerHeight')
				elementPaddingTop = parseInt(element.css('padding-top'), 10)
				elementPaddingBtm = parseInt(element.css('padding-bottom'), 10)
				
				

				containerH = containerH - elementPaddingTop - elementPaddingBtm
				contentH = _content.actual('outerHeight') 
				limits.bottom = containerH - contentH

				#console.log( contentH )

				#_elementH = element.find('li').first().actual('outerHeight')
				_elementH = element.find('li').first().actual( 'outerHeight', {includeMargin:true} )

				#_elementH = li.outerHeight()

				#console.log( li.height(), li.outerHeight(), li., li.css('margin') )
				_scrollOffsetY = Math.round( (containerH - _elementH)/2 )
				_blenderTop.addClass('veil')
				_blenderBtm.addClass('veil')

				#console.log( limits.bottom )
				if 0 > limits.bottom
					_scrolling( true ) 
					scrollerCtrl.init( containerH, contentH, elementPaddingTop)
					_blenderBtm.removeClass('veil')
			, 500 )

		_scrolling = ( status=false ) ->
			if status is true
				_mouseWheelScrolling()
				_mouseDragDropScrolling()

			else
				element.unbind('mousewheel mouseenter mouseleave')
				_content.css('y', limits.top )


		_mouseWheelScrolling = ->
			element.mousewheel (event, delta, deltaX, deltaY ) ->
				event.preventDefault
				event.stopPropagation
				y = parseInt(_content.css('y'), 10) + (delta*20)
				_contentPosition( y )
				return false				

		_contentPosition = (y, ani=false) ->
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


		_mouseDragDropScrolling = ->
			element.mouseenter((event)->
				event.preventDefault
				event.stopPropagation
				scrollerCtrl.show()
			).mouseleave( (event)->
				event.preventDefault
				event.stopPropagation
				scrollerCtrl.hide()
			)

		###
		if attrs.onGalleryChange?
			scope.$watch( attrs.onGalleryChange, (newVal, oldVal) ->
				return if newVal is oldVal
				console.log("change")
				_scrolling( false )
			, false )
		###

		if attrs.onElementChange?
			scope.$watch( attrs.onElementChange, (newVal, oldVal) ->
				return if newVal is oldVal
				# autoscroll 
				y = -(_elementH*newVal) + _scrollOffsetY
				_contentPosition( y, true)
			, false )
]

app.directive "sliderContent", [ '$timeout', (timeout)->
	restrict : 'A'
	scope : true
	require : '^slider'
	link : (scope, element, attrs, sliderCtrl) ->
		# scope.$watch( 'thumbsLoaded', (vnew, vold) ->
		# 	if vnew
		# 		console.log( "container height: " + element.actual('outerHeight') )
		# , false )
		
]

app.directive "imageOnLoad" , ->
	restrict: 'A'
	scope : true
	link : (scope, element, attrs) ->
		element.bind 'load', ->
			console.log( scope.elements.length )

			scope.$apply( attrs.imageOnLoad )


app.directive "sliderElement" , [ ->
	restrict: 'A'
	scope : true
	require : '^slider'
	link : (scope, element, attrs, sliderCtrl) ->

		# scope.$watch( 'thumbsLoaded', (vnew, vold) ->
		# 	if vnew
		# 		console.log( "element height: " + element.actual('outerHeight') )
		# , false )

		#console.log( scope.thumbsAni )
		onChange = (val) ->
			_index = parseInt( attrs.sliderElementIndex, 10 )
			_count = parseInt( attrs.sliderElementCount, 10 )
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
						if (_index+1) == _count
							#console.log("ani end")
							sliderCtrl.callMe()
							
						
				})

		if attrs.sliderElement?
			scope.$watch( attrs.sliderElement, (vnew, vold) ->
				onChange( vnew )
			, false )
]


app.directive "slider2", ['$timeout', (timeout)->
	restrict: 'A'
	require : '?scroller'
	scope : true

	controller : [ '$scope', (scope) ->

		this.callMe = ->
			#console.log("he he")

	]

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
				_mouseWheelScrolling()
				_mouseDragDropScrolling()

			else
				element.unbind('mousewheel mouseenter mouseleave')
				_content.css('y', limits.top )


		_mouseWheelScrolling = ->
			element.mousewheel (event, delta, deltaX, deltaY ) ->
				event.preventDefault
				event.stopPropagation
				y = parseInt(_content.css('y'), 10) + (delta*20)
				_contentPosition( y )
				return false				

		_contentPosition = (y, ani=false) ->
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


		_mouseDragDropScrolling = ->
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
				# autoscroll 
				y = -(_elementH*newVal) + _scrollOffsetY
				_contentPosition( y, true)
			, false )
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
					#console.log( file )
					###
					(event) ->
						element.append( $('<img>').attr('src'))
					###

				fr.readAsDataURL( file )
			)
			#console.log( event.dataTransfer.files )



		)
]

