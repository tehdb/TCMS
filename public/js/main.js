(function() {
  var app;

  app = angular.module("TGallery", ["ngAnimate"]);

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

  app.controller("GalleryCtrl", [
    "$scope", "AlbumService", function(scope, as) {
      var galleryIndex;
      galleryIndex = -1;
      scope.elementIndex = -1;
      scope.gallsShow = false;
      scope.thumbsShow = false;
      scope.background = 'rgb(0,0,0)';
      as.getAlbum(1, function(data) {
        scope.album = data;
        return scope.switchGallery(0);
      });
      scope.switchGallery = function(id) {
        if (galleryIndex === id) {
          return false;
        }
        galleryIndex = id;
        scope.elementIndex = 0;
        scope.gallery = scope.album.galleries[galleryIndex];
        scope.elements = scope.gallery.elements;
        scope.$image.addClass('veil');
        scope.image = scope.elements[scope.elementIndex];
        return scope.safeApply();
      };
      scope.nextImage = function() {
        var id;
        id = scope.elementIndex + 1;
        if (id > (scope.elements.length - 1)) {
          id = 0;
        }
        return scope.switchImage(id);
      };
      scope.prevImage = function() {
        var id;
        id = scope.elementIndex - 1;
        if (id < 0) {
          id = scope.elements.length - 1;
        }
        return scope.switchImage(id);
      };
      scope.switchImage = function(id) {
        if (scope.elementIndex === id) {
          return false;
        }
        scope.elementIndex = id;
        scope.$image.addClass('veil');
        return window.setTimeout(function() {
          scope.image = scope.elements[scope.elementIndex];
          return scope.safeApply();
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

  app.directive("dynbg", function() {
    return {
      restrict: 'A',
      link: function(scope, element, attrs) {
        if (attrs.dynbg != null) {
          return scope.$watch(attrs.dynbg, function(newVal, oldVal) {
            return $(element).css({
              "background-color": newVal
            });
          }, false);
        }
      }
    };
  });

  app.directive("stageimg", function() {
    return {
      restrict: 'A',
      link: function(scope, element, attrs) {
        var evalHist, loadImage;
        scope.$image = element;
        loadImage = function() {
          var hist, img;
          hist = {};
          img = new Image();
          img.onload = function() {
            return Pixastic.process(img, "colorhistogram", {
              paint: false,
              returnValue: hist
            }, function() {
              return evalHist(hist);
            });
          };
          return img.src = scope.gallery.path + scope.image.file;
        };
        evalHist = function(hist) {
          var getMax, rgb;
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
          rgb = [getMax(hist.rvals), getMax(hist.gvals), getMax(hist.bvals)];
          /*
          			$(element).parent().css({
          				background : "rgb(" + rgb.join(',') + ")"
          			})
          */

          scope.background = "rgb(" + rgb.join(',') + ")";
          element.removeClass('veil');
          return scope.safeApply();
        };
        return scope.$watch(function() {
          return scope.image;
        }, function(newVal, oldVal) {
          if (newVal === oldVal) {
            return;
          }
          return loadImage();
        }, false);
      }
    };
  });

  app.directive("slider", function() {
    return {
      restrict: 'A',
      link: function(scope, element, attrs) {
        var $content, $element, checkImgsLoaded, limits, mouseWeelScroll, setLimits;
        $element = element;
        $content = $element.find('ul').first();
        limits = {
          top: 0,
          bottom: 0
        };
        checkImgsLoaded = function() {
          var $imgs, count, loaded;
          $imgs = $content.find('img');
          loaded = 0;
          count = $imgs.length;
          if (count > 0) {
            return $imgs.each(function(index) {
              return $(this).bind('load', function() {
                loaded++;
                console.log(loaded + " of " + count);
                if (loaded === count) {
                  return setLimits();
                }
              });
            });
          } else {
            return setLimits();
          }
        };
        setLimits = function() {
          limits.top = 0;
          limits.bottom = $element.actual('outerHeight') - $content.actual('outerHeight') - 2 * parseInt($element.css('padding'), 10);
          console.log(limits.bottom);
          if (0 > limits.bottom) {
            return mouseWeelScroll();
          }
        };
        /*
        		animateElements = ->
        			$els = $content.find('li')
        			$els.addClass('veil')
        			count = $els.length
        			index = 0
        			animateEl = (el) ->
        				$(el).removeClass('veil')
        				window.setTimeout(->
        					index++
        					if index isnt count
        						animateEl($els.get(index))
        				,100)
        
        			window.setTimeout(->
        				animateEl($els.get(index))
        			,1000)
        */

        mouseWeelScroll = function() {
          console.log("scroll");
          return $element.mousewheel(function(event, delta, deltaX, deltaY) {
            var y;
            event.preventDefault;
            event.stopPropagation;
            y = parseInt($content.css('y'), 10) + (delta * 20);
            if (y > limits.top) {
              y = limits.top;
            }
            if (y < limits.bottom) {
              y = limits.bottom;
            }
            return $content.css('y', y);
          });
        };
        if (attrs.sliderDepend != null) {
          scope.$watch(attrs.sliderDepend, function(newVal, oldVal) {
            console.log("***", attrs.sliderDepend);
            $element.unbind('mousewheel');
            $content.css('y', limits.top);
            return checkImgsLoaded();
          }, false);
        }
        return $element.find('.toggle').click(function(event) {
          event.preventDefault;
          event.stopPropagation;
          return element.toggleClass(attrs.slider);
        });
      }
    };
  });

}).call(this);
