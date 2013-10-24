
app.directive "tGallery", [() ->
	restrict: 'A'
	scope : true
	templateUrl : '/partials/gallery.tpl.html'
	link : (scope, element, attrs, vs ) ->

]


app.directive( "vslider", [()->
	restrict: 'A'
	scope : true
	link : (scope, element, attrs ) ->
		_content = element.find('ul').first()
		_limits = {top:0, btm: 0, fac:1}
		_mouseWheelDeltaFactor = 20 
		_scroller = $('<div>').appendTo( element )
		_blenderTop = $('<div>').addClass('blenderTop veil').appendTo( element )
		_blenderBtm = $('<div>').addClass('blenderBtm veil').appendTo( element )

		if attrs.vsliderScroller is 'left'
			_scroller.addClass('scrollerLeft')
		else
			_scroller.addClass('scrollerRight')


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


		scope.$watch( 'album', (nv, ov) ->
			if nv?			
				_setLimits()
		)
]) # vslider


app.directive "thThumb", [() ->
	restrict: 'A'
	scope : true
	link : (scope, element, attrs ) ->
		idx = attrs.thThumb
		element.append( scope.album.galleries[scope.galleryIndex].elements[idx].thumbImg )
]

app.directive "thCover", [() ->
	restrict: 'A'
	scope : true
	link : (scope, element, attrs ) ->
		idx = attrs.thCover
		element.append( scope.album.galleries[idx].coverImg )
]