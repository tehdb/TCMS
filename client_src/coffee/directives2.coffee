
app.directive "tGallery", [() ->
	restrict: 'A'
	scope : true
	templateUrl : '/partials/gallery.tpl.html'
	link : (scope, element, attrs, vs ) ->

]



app.directive( "vslider", [()->
	restrict: 'A'
	scope : true
	controller : [ '$scope', '$element', '$attrs', (scope, element, attrs ) ->
		_limits = {top:0, btm: 0, fac:1}
		_mouseWheelDeltaFactor = 20 
		_content = null
		_scroller = $('<div>').appendTo( element )
		_blenderTop = $('<div>').addClass('blenderTop').appendTo( element )
		_blenderBtm = $('<div>').addClass('blenderBtm').appendTo( element )

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
		this.contentReady = ( contentObj )->
			_content = contentObj
			_setLimits()		
			
	]
]) # vslider