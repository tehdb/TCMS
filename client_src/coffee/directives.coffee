
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


app.directive "thStage", ['$timeout', 'settings', (to, sttgs) ->
	restrict: 'A'
	scope : true
	link : (scope, element, attrs ) ->
		_centerImg = ( $img )->
			sidebarFactor = 0
			sidebarFactor++ if scope.control.thumbsShow
			sidebarFactor++ if scope.control.galleriesShow

			stageW = element.width() - sidebarFactor*sttgs.sidebarW
			stageH = element.height() - 20
			imgW = $img[0].width
			imgH = $img[0].height
			difW = imgW/stageW
			difH = imgH/stageH
			scaleFactor = 1

			if difW > 1 or difH > 1
				if difW > difH
					scaleFactor = difW
				else
					scaleFactor = difH

				imgW = Math.round( imgW / scaleFactor)
				imgH = Math.round( imgH / scaleFactor)


			imgX = (stageW - imgW)/2
			imgY = (stageH - imgH)/2 + 10

			imgX += sttgs.sidebarW if scope.control.galleriesShow

			$img.css({
				width : imgW
				height : imgH
				left : imgX
				top : imgY
			})

		scope.$watchCollection( '[control.thumbsShow, control.galleriesShow]', (nv, ov) ->
			if nv?
				$img =  element.find('img')
				if $img.length > 0
					_centerImg( $img )
		)

		scope.$watch( 'elementIndex', (nv, ov) ->
			if nv?
				$media = element.find('img')
				$img = $(scope.album.galleries[scope.galleryIndex].elements[nv].fileImg)
				_centerImg($img)
				$img.addClass('veilin')


				if $media.length > 0
					$media.addClass('veilout')
					to(->
						$media.replaceWith( $img )
						to(->
							$media.removeClass('veilout')
							$img.removeClass('veilin')	
						,150)
					,150)
				else
					element.append( $img )
					to(->
						$img.removeClass('veilin')	
					,150)
		)
]

app.directive "thSlideshowProgress", ['settings', (sttgs) ->
	restrict: 'A'
	scope : true
	link : (scope, element, attrs ) ->
		_next = ->

			element.animate {
				'width': '100%'			
			}, sttgs.slideshowDur*1000, 'linear', ->
				element.width(0)
				scope.nextImage()
				_next() if scope.slideshow
			

		scope.$watch "slideshow", (nv, ov) ->
			if nv
				_next()
			else
				element.stop().width(0)
]




