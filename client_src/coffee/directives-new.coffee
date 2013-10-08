'use strict'

app.directive "image" , ->
	restrict: 'A'
	scope : true
	require : ['?^sliderElement' ]
	link : (scope, element, attrs, ctrls) ->
		

		element.bind 'load', (event) ->
			ctrls[0].imgLoaded( event.target ) if ctrls[0]?


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
	controller : [ '$scope', '$element', '$attrs', (scope, element, attrs ) ->
		_elsData = []
		
		this.elementReady = (elData) ->
			_elsData.push ( elData )

			if _elsData.length is scope.elements.length
				console.log("notify slider")



app.directive "slider", ->
	restrict : 'A'



