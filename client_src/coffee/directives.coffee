
app.directive "tGallery", [() ->
	restrict: 'A'
	scope : true
	templateUrl : '/partials/gallery.tpl.html'
	link : (scope, element, attrs, vs ) ->

]


app.directive( "vslider", [ '$timeout', (to)->
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
			_contentPosition(0)
			_scroller.height(0)
			eh = element.actual('height')
			ch = _content.actual('outerHeight', {includeMargin:true} )
			
			# console.log eh, ch

			_limits.fac = eh/ch
			_limits.btm = eh - ch


			if 0 > _limits.btm
				_scroller.height( _limits.fac * eh )
				_blenderBtm.removeClass('veil')
				_mouseWheelScrolling()
				_mouseMoveScrolling()
			else
				element.unbind('mousewheel mouseenter mouseleave')
				_contentPosition(0)

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

		scope.$watch( attrs.vslider, (nv, ov) ->
			if nv?
				to( ->
					_setLimits()
				,400)
		)
]) # vslider


app.directive "thThumb", [ '$timeout', (to) ->
	restrict: 'A'
	scope : true
	link : (scope, element, attrs ) ->
		idx = attrs.thThumb
		element.addClass('veil-delay-'+scope.$index )

		scope.$watch( 'galleryIndex', (nv, ov) ->
			if nv?
				element.addClass('veil')

				$img = element.find('img')
				if $img.length > 0
					$img.replaceWith(  $(scope.album.galleries[scope.galleryIndex].elements[idx].thumbImg) )
				else
					element.append( $(scope.album.galleries[scope.galleryIndex].elements[idx].thumbImg) )

				to(->
					element.removeClass('veil')		
				,150*(scope.$index+1))
		)
]

app.directive "thCover", [() ->
	restrict: 'A'
	scope : true
	link : (scope, element, attrs ) ->
		idx = attrs.thCover
		scope.$watch( 'album', (nv, ov) ->
			if nv?			
				element.append( scope.album.galleries[idx].coverImg )
		)
]





