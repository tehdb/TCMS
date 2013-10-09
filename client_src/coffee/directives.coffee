
app.directive "imgLoaded" , ->
	restrict: 'A'
	scope : true
	#require : ['?^sliderElement' ]
	link : (scope, element, attrs, ctrls) ->
		element.unbind('load').bind( 'load', (event) ->
			console.log( element.attr('alt'), 'loaded')
			scope.$eval( attrs.imgLoaded )
			# ctrls[0].imgLoaded( event.target ) if ctrls[0]?
		)


app.directive "imgsList", ->
	restrict: 'A'
	scope : true
	controller : [ '$scope', '$element', '$attrs', (scope, element, attrs ) ->
		_imgCount = 0
		_imgLoaded = 0

		attrs.$observe('imgsListSize', (val) ->
			_imgCount = parseInt( val, 10) if val
		)

		scope.onImgLoaded = () ->
			#console.log( _imgLoaded + " of " + _imgCount )
			if ++_imgLoaded >= _imgCount
				_imgLoaded = 0
				_onImgsLoaded()


		_onImgsLoaded = () ->
			# dims = {}
			# dims.width = element.actual('outerWidth', {includeMargin:true} )
			# dims.height = element.actual('outerHeight', {includeMargin:true} )

			scope.element = element
			scope.$eval( attrs.imgsListReady )
	]



app.directive "vslider", ->
	restrict: 'A'
	scope : true
	controller : [ '$scope', '$element', '$attrs', (scope, element, attrs ) ->
		_limits = {top:0, btm: 0, fac:1}
		_mouseWheelDeltaFactor = 1
		_content = null
		_scroller = $('<div>').appendTo( element )
		_blenderTop = $('<div>').addClass('blenderTop veil').appendTo( element )
		_blenderBtm = $('<div>').addClass('blenderBtm veil').appendTo( element )

		if attrs.vsliderScroller is 'left'
			_scroller.addClass('scrollerLeft')
		else
			_scroller.addClass('scrollerRight')

		#************************************************************
		#** private ************************************************* 
		_setLimits = ->
			eh = element.actual('height')
			ch = _content.actual('outerHeight', {includeMargin:true} )
			
			_limits.fac = eh/ch
			_limits.btm = eh - ch

			_scroller.height( _limits.fac * eh )

			if 0 > _limits.btm
				_blenderBtm.removeClass('veil')
				_scrolling( true ) 

		_scrolling = (status=false) ->
			console.log("scrolling")
			if status
				_mouseWheelScrolling()
				_mouseMoveScrolling()
			else
				element.unbind('mousewheel mouseenter mouseleave')
				#_scroller.unbind('mouseenter mouseleave')
				_content.css('y', _limits.top )

		_contentPosition = (y, ani=false) ->
			if y >= _limits.top
				y = _limits.top
				_blenderTop.addClass('veil')

			else if y <= _limits.btm
				y = _limits.btm 
				_blenderBtm.addClass('veil')

			else
			 	_blenderTop.removeClass('veil')
			 	_blenderBtm.removeClass('veil')

			if ani
				_content.transition({'y': y})
			else
				_content.css('y', y )

			
			_scroller.css('y', -y*_limits.fac )

			# scrollerCtrl.setPos( y )

		_mouseWheelScrolling = ->
			element.mousewheel (event, delta, deltaX, deltaY ) ->
				event.preventDefault
				event.stopPropagation
				y = parseInt(_content.css('y'), 10) + (delta*_mouseWheelDeltaFactor)
				_contentPosition( y )
				return false
		
		_mouseMoveScrolling = ->
			_scroller.mouseenter( (event) ->
				event.preventDefault
				event.stopPropagation
				_scroller.addClass('active')
			).mouseleave( (event) ->
				event.preventDefault
				event.stopPropagation
				_scroller.removeClass('active')
			)

			


		#************************************************************
		#** public ************************************************* 
		scope.contentReady = ( contentObj )->
			_content = contentObj
			_setLimits()		
			
	]

###
app.directive "sliderElement", ->
	restrict: 'A'
	scope : true
	require : ['?^sliderContent']
	controller : [ '$scope', '$element', '$attrs', (scope, element, attrs ) ->
		this.imgLoaded = ( imgObj ) ->
			scope.sliderContentCtrl.elementReady({
				width : element.height()
				height : element.width()
			})

	]

	link : (scope, element, attrs, ctrls) -> 
  		scope.sliderContentCtrl = ctrls[0] if ctrls[0]?


app.directive "sliderContent", ->
	restrict: 'A'
	scope : true
	require : ['?^slider']
	controller : [ '$scope', '$element', '$attrs', (scope, element, attrs ) ->
		_elsData = []
		
		this.elementReady = (elData) ->
			_elsData.push ( elData )

	link : (scope, element, attrs, ctrls ) ->
		if _elsData.length is scope.elements.length
				ctrls[0].setContentProps( _elsData ) if ctrls[0]?


###



