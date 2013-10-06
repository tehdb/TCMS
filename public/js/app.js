(function() {
  var app;

  app = angular.module("TGallery", ["ngAnimate"]);

  app.constant('settings', {
    dynamicBackground: false,
    slideshowDur: 3,
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
      var thumbsLoadedCount;
      scope.galleryIndex = -1;
      scope.elementIndex = -1;
      thumbsLoadedCount = 0;
      scope.thumbsLoaded = false;
      scope.gallsShow = settings.galleriesShow;
      scope.thumbsShow = settings.thumbnailsShow;
      scope.background = '';
      scope.slideshow = false;
      as.getAlbum(1, function(data) {
        scope.album = data;
        return scope.switchGallery(0);
      });
      scope.onThumbLoaded = function() {
        thumbsLoadedCount++;
        if (thumbsLoadedCount === scope.elements.length) {
          return scope.thumbsLoaded = true;
        }
      };
      scope.switchGallery = function(id) {
        if (scope.galleryIndex === id) {
          return false;
        }
        scope.galleryIndex = id;
        scope.elementIndex = -1;
        thumbsLoadedCount = 0;
        scope.thumbsLoaded = false;
        scope.slideshow = false;
        return scope.switchImage(0, function() {
          scope.gallery = scope.album.galleries[scope.galleryIndex];
          return scope.elements = scope.gallery.elements;
        });
      };
      scope.nextImage = function(slideshow) {
        var id;
        if (slideshow == null) {
          slideshow = false;
        }
        if (slideshow !== true) {
          scope.slideshow = false;
        }
        id = scope.elementIndex + 1;
        if (id > (scope.elements.length - 1)) {
          id = 0;
        }
        return scope.switchImage(id);
      };
      scope.prevImage = function() {
        var id;
        scope.slideshow = false;
        id = scope.elementIndex - 1;
        if (id < 0) {
          id = scope.elements.length - 1;
        }
        return scope.switchImage(id);
      };
      scope.switchImage = function(id, callback) {
        if (scope.elementIndex === id) {
          return false;
        }
        scope.elementIndex = id;
        scope.$image.addClass('veil');
        return timeout(function() {
          if (typeof callback === 'function') {
            callback();
          }
          return scope.image = scope.elements[scope.elementIndex];
        }, 300);
      };
      return scope.safeApply = function(fn) {
        var phase;
        phase = this.$root.$$phase;
        if (phase === '$apply' || phase === '$digest') {
          if (fn && (typeof fn === 'function')) {
            return fn();
          }
        } else {
          return scope.$apply(fn);
        }
      };
    }
  ]);

  'use strict';

  app.directive("dynamicBackground", function() {
    return {
      restrict: 'A',
      link: function(scope, element, attrs) {
        if (attrs.dynamicBackground != null) {
          return scope.$watch(attrs.dynamicBackground, function(newVal, oldVal) {
            return $(element).css({
              "background-color": newVal
            });
          }, false);
        }
      }
    };
  });

  app.directive("stageImg", [
    'ImageService', 'settings', function(imgs, sttgs) {
      return {
        restrict: 'A',
        link: function(scope, element, attrs) {
          scope.$image = element;
          return scope.$watch(function() {
            return scope.image;
          }, function(newVal, oldVal) {
            var colorPromise;
            if (newVal === oldVal) {
              return;
            }
            if (sttgs.dynamicBackground === true) {
              colorPromise = imgs.getImageColor(scope.gallery.path + scope.image.file);
              return colorPromise.then(function(color) {
                scope.background = "rgb(" + color.join(',') + ")";
                return element.removeClass('veil');
              }, function(error) {
                return element.removeClass('veil');
              });
            } else {
              return element.removeClass('veil');
            }
          }, false);
        }
      };
    }
  ]);

  app.directive("imageOnLoad", function() {
    return {
      restrict: 'A',
      link: function(scope, element, attrs) {
        return element.bind('load', function() {
          return scope.$apply(attrs.imageOnLoad);
        });
      }
    };
  });

  app.directive("scroller", function() {
    return {
      restrict: 'A',
      controller: function($scope) {
        var _factor, _scroller, _topY;
        _scroller = $('<div>').addClass('scroller veil');
        _factor = 1;
        _topY = 0;
        $scope.scroller = _scroller;
        this.init = function(elementH, contentH, top) {
          _factor = elementH / contentH;
          _topY = top;
          return _scroller.height(_factor * elementH).css('y', _topY);
        };
        this.setPos = function(y) {
          return _scroller.css('y', -y * _factor + _topY);
        };
        this.show = function() {
          return _scroller.removeClass('veil');
        };
        return this.hide = function() {
          return _scroller.addClass('veil');
        };
      },
      link: function(scope, element, attrs) {
        return scope.scroller.appendTo(element);
      }
    };
  });

  app.directive("slider", [
    '$timeout', function(timeout) {
      return {
        restrict: 'A',
        require: '?scroller',
        link: function(scope, element, attrs, scrollerCtrl) {
          var $content, contentPosition, limits, mouseDragDropScrolling, mouseWheelScrolling, scrolling, setLimits, _blenderBtm, _blenderTop;
          element = element;
          _blenderTop = $('<div>').addClass('blender blender-top veil').appendTo(element);
          _blenderBtm = $('<div>').addClass('blender blender-btm').appendTo(element);
          $content = element.find('ul').first();
          limits = {
            top: 0,
            bottom: 0
          };
          setLimits = function() {
            limits = {
              top: 0,
              bottom: 0
            };
            return timeout(function() {
              var contentH, elementH, elementPaddingBtm, elementPaddingTop;
              elementH = element.actual('outerHeight');
              elementPaddingTop = parseInt(element.css('padding-top'), 10);
              elementPaddingBtm = parseInt(element.css('padding-bottom'), 10);
              elementH = elementH - elementPaddingTop - elementPaddingBtm;
              contentH = $content.actual('outerHeight');
              limits.bottom = elementH - contentH;
              _blenderTop.addClass('veil');
              _blenderBtm.addClass('veil');
              if (0 > limits.bottom) {
                scrolling(true);
                scrollerCtrl.init(elementH, contentH, elementPaddingTop);
                return _blenderBtm.removeClass('veil');
              }
            }, 400);
          };
          scrolling = function(status, elementH, contentH) {
            if (status == null) {
              status = false;
            }
            if (elementH == null) {
              elementH = 0;
            }
            if (contentH == null) {
              contentH = 0;
            }
            if (status === true) {
              mouseWheelScrolling();
              return mouseDragDropScrolling();
            } else {
              element.unbind('mousewheel mouseenter mouseleave');
              return $content.css('y', limits.top);
            }
          };
          mouseWheelScrolling = function() {
            return element.mousewheel(function(event, delta, deltaX, deltaY) {
              var y;
              event.preventDefault;
              event.stopPropagation;
              y = parseInt($content.css('y'), 10) + (delta * 20);
              contentPosition(y);
              return false;
            });
          };
          contentPosition = function(y) {
            if (y > limits.top) {
              y = limits.top;
              _blenderTop.addClass('veil');
            } else if (y < limits.bottom) {
              y = limits.bottom;
              _blenderBtm.addClass('veil');
            } else {
              _blenderTop.removeClass('veil');
              _blenderBtm.removeClass('veil');
            }
            $content.css('y', y);
            return scrollerCtrl.setPos(y);
          };
          mouseDragDropScrolling = function() {
            return element.mouseenter(function(event) {
              event.preventDefault;
              event.stopPropagation;
              return scrollerCtrl.show();
            }).mouseleave(function(event) {
              event.preventDefault;
              event.stopPropagation;
              return scrollerCtrl.hide();
            });
          };
          if (attrs.sliderDepend != null) {
            return scope.$watch(attrs.sliderDepend, function(newVal, oldVal) {
              if (newVal === oldVal) {
                return;
              }
              scrolling(false);
              if (newVal === true) {
                return setLimits();
              }
            }, false);
          }
        }
      };
    }
  ]);

  app.directive("progressbar", [
    'settings', function(settings) {
      return {
        restrict: 'A',
        link: function(scope, element, attrs) {
          var progressAni;
          progressAni = function() {
            return element.width(0).animate({
              width: '100%'
            }, settings.slideshowDur * 1000, 'linear', function() {
              if (scope.slideshow) {
                scope.nextImage(true);
                return progressAni();
              }
            });
          };
          if (attrs.progressbar != null) {
            return scope.$watch(attrs.progressbar, function(newVal, oldVal) {
              if (newVal) {
                return progressAni();
              } else {
                return element.stop().width(0);
              }
            }, false);
          }
        }
      };
    }
  ]);

  app.directive("dropzone", [
    'settings', function(settings) {
      return {
        restrict: 'A',
        link: function(scope, element, attrs) {
          $.event.props.push('dataTransfer');
          return element.bind('dragenter dragover', false).bind('drop', function(event) {
            event.preventDefault();
            event.stopPropagation();
            $.each(event.dataTransfer.files, function(index, file) {
              var fr;
              fr = new FileReader();
              fr.onload = function(file) {
                return console.log(file);
                /*
                					(event) ->
                						element.append( $('<img>').attr('src'))
                */

              };
              return fr.readAsDataURL(file);
            });
            return console.log(event.dataTransfer.files);
          });
        }
      };
    }
  ]);

}).call(this);
