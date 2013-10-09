(function() {
  var app;

  app = angular.module("TGallery", ["ngAnimate"]);

  app.constant('settings', {
    dynamicBackground: false,
    slideshowDur: 5,
    galleriesShow: true,
    thumbnailsShow: true
  });

  app.service("AlbumService", [
    '$http', '$log', function(http, log) {
      return {
        getAlbum: function(id, callback) {
          return http({
            method: 'GET',
            url: "/album/" + id
          }).success(function(data, status, headers, config) {
            var g, i, _i, _j, _len, _len1, _ref, _ref1;
            _ref = data.galleries;
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              g = _ref[_i];
              _ref1 = g.elements;
              for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
                i = _ref1[_j];
                i.thumb = i.file.replace('.jpg', '_thumb.jpg');
              }
            }
            return callback(data);
          }).error(function(data, status, headers, config) {
            return log.warn(data, status, headers, config);
          });
        }
      };
    }
  ]);

  app.service("ImageService", [
    '$q', function(q) {
      return {
        getImageColor: function(imgSrc) {
          var deferred, evalHist, hist, img;
          hist = {};
          deferred = q.defer();
          evalHist = function(hist) {
            var getMax;
            getMax = function(color) {
              var idx, max;
              max = 0;
              idx = 0;
              $.each(color, function(index) {
                var val;
                val = color[index];
                if (val > max) {
                  max = val;
                  return idx = index;
                }
              });
              return idx;
            };
            return [getMax(hist.rvals), getMax(hist.gvals), getMax(hist.bvals)];
          };
          img = new Image();
          img.onload = function() {
            return Pixastic.process(img, "colorhistogram", {
              paint: false,
              returnValue: hist
            }, function() {
              return deferred.resolve(evalHist(hist));
            });
          };
          img.onerror = function() {
            return deferred.reject('load error');
          };
          img.src = imgSrc;
          return deferred.promise;
        }
      };
    }
  ]);

  app.controller("GalleryCtrl", [
    "$scope", "$timeout", "AlbumService", 'settings', function(scope, timeout, as, settings) {
      scope.galleryIndex = 0;
      scope.mediaElementIndex = 0;
      as.getAlbum(1, function(data) {
        scope.album = data;
        scope.gallery = scope.album.galleries[scope.galleryIndex];
        scope.mediaElements = scope.gallery.elements;
        return scope.mediaElement = scope.mediaElements[scope.mediaElementIndex];
      });
      scope.showGallery = function(index) {
        scope.galleryIndex = index;
        scope.gallery = scope.album.galleries[scope.galleryIndex];
        scope.mediaElements = scope.gallery.elements;
        return scope.showMediaElement(0);
      };
      scope.showMediaElement = function(index) {
        scope.mediaElementIndex = index;
        return scope.mediaElement = scope.mediaElements[scope.mediaElementIndex];
      };
      return scope.onStageImgLoaded = function(msg) {
        if (msg == null) {
          msg = 'default';
        }
      };
    }
  ]);

  app.directive("imgLoaded", function() {
    return {
      restrict: 'A',
      scope: true,
      link: function(scope, element, attrs, ctrls) {
        return element.unbind('load').bind('load', function(event) {
          console.log(element.attr('alt'), 'loaded');
          return scope.$eval(attrs.imgLoaded);
        });
      }
    };
  });

  app.directive("imgsList", function() {
    return {
      restrict: 'A',
      scope: true,
      controller: [
        '$scope', '$element', '$attrs', function(scope, element, attrs) {
          var _imgCount, _imgLoaded, _onImgsLoaded;
          _imgCount = 0;
          _imgLoaded = 0;
          attrs.$observe('imgsListSize', function(val) {
            if (val) {
              return _imgCount = parseInt(val, 10);
            }
          });
          scope.onImgLoaded = function() {
            if (++_imgLoaded >= _imgCount) {
              _imgLoaded = 0;
              return _onImgsLoaded();
            }
          };
          return _onImgsLoaded = function() {
            scope.element = element;
            return scope.$eval(attrs.imgsListReady);
          };
        }
      ]
    };
  });

  app.directive("vslider", function() {
    return {
      restrict: 'A',
      scope: true,
      controller: [
        '$scope', '$element', '$attrs', function(scope, element, attrs) {
          var _blenderBtm, _blenderTop, _content, _contentPosition, _limits, _mouseMoveScrolling, _mouseWheelDeltaFactor, _mouseWheelScrolling, _scroller, _scrolling, _setLimits;
          _limits = {
            top: 0,
            btm: 0,
            fac: 1
          };
          _mouseWheelDeltaFactor = 1;
          _content = null;
          _scroller = $('<div>').appendTo(element);
          _blenderTop = $('<div>').addClass('blenderTop veil').appendTo(element);
          _blenderBtm = $('<div>').addClass('blenderBtm veil').appendTo(element);
          if (attrs.vsliderScroller === 'left') {
            _scroller.addClass('scrollerLeft');
          } else {
            _scroller.addClass('scrollerRight');
          }
          _setLimits = function() {
            var ch, eh;
            eh = element.actual('height');
            ch = _content.actual('outerHeight', {
              includeMargin: true
            });
            _limits.fac = eh / ch;
            _limits.btm = eh - ch;
            _scroller.height(_limits.fac * eh);
            if (0 > _limits.btm) {
              _blenderBtm.removeClass('veil');
              return _scrolling(true);
            }
          };
          _scrolling = function(status) {
            if (status == null) {
              status = false;
            }
            console.log("scrolling");
            if (status) {
              _mouseWheelScrolling();
              return _mouseMoveScrolling();
            } else {
              element.unbind('mousewheel mouseenter mouseleave');
              return _content.css('y', _limits.top);
            }
          };
          _contentPosition = function(y, ani) {
            if (ani == null) {
              ani = false;
            }
            if (y >= _limits.top) {
              y = _limits.top;
              _blenderTop.addClass('veil');
            } else if (y <= _limits.btm) {
              y = _limits.btm;
              _blenderBtm.addClass('veil');
            } else {
              _blenderTop.removeClass('veil');
              _blenderBtm.removeClass('veil');
            }
            if (ani) {
              _content.transition({
                'y': y
              });
            } else {
              _content.css('y', y);
            }
            return _scroller.css('y', -y * _limits.fac);
          };
          _mouseWheelScrolling = function() {
            return element.mousewheel(function(event, delta, deltaX, deltaY) {
              var y;
              event.preventDefault;
              event.stopPropagation;
              y = parseInt(_content.css('y'), 10) + (delta * _mouseWheelDeltaFactor);
              _contentPosition(y);
              return false;
            });
          };
          _mouseMoveScrolling = function() {
            return _scroller.mouseenter(function(event) {
              event.preventDefault;
              event.stopPropagation;
              return _scroller.addClass('active');
            }).mouseleave(function(event) {
              event.preventDefault;
              event.stopPropagation;
              return _scroller.removeClass('active');
            });
          };
          return scope.contentReady = function(contentObj) {
            _content = contentObj;
            return _setLimits();
          };
        }
      ]
    };
  });

  /*
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
  */


}).call(this);
