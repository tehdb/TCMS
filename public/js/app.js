(function() {
  var app;

  app = angular.module("TGallery", ["ngAnimate"]);

  app.constant('settings', {
    dynamicBackground: false,
    slideshowDur: 5,
    galleriesShow: true,
    thumbsShow: true,
    thumbsPath: 'thumbs/'
  });

  app.service("AlbumService", [
    '$http', '$log', '$timeout', '$q', 'settings', function(http, log, to, q, sttgs) {
      return {
        getAlbum: function(id) {
          var defer;
          defer = q.defer();
          http({
            method: 'GET',
            url: "/album/" + id
          }).success(function(data, status, headers, config) {
            var coverLoaded, coverTotal, elem, g, gi, img, thumbsPath, _i, _j, _len, _len1, _ref, _ref1, _results;
            data.info = {
              totalImages: 0,
              totalVideos: 0
            };
            coverTotal = data.galleries.length;
            coverLoaded = 0;
            _ref = data.galleries;
            _results = [];
            for (gi = _i = 0, _len = _ref.length; _i < _len; gi = ++_i) {
              g = _ref[gi];
              thumbsPath = g.path + sttgs.thumbsPath;
              _ref1 = g.elements;
              for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
                elem = _ref1[_j];
                elem.thumbSrc = thumbsPath + elem.file.replace('.jpg', '_thumb.jpg');
                if (elem.type === 'image') {
                  data.info.totalImages++;
                  elem.imgSrc = g.path + elem.file;
                } else if (m.type === 'video') {
                  data.info.totalVideos++;
                }
              }
              img = new Image();
              img.onload = function() {
                data.galleries[this.gidx].coverImg = this;
                if (++coverLoaded >= coverTotal) {
                  return defer.resolve(data);
                }
              };
              img.src = g.elements[g.cover].thumbSrc;
              _results.push(img.gidx = gi);
            }
            return _results;
          }).error(function(data, status, headers, config) {
            return defer.reject(status, config);
          });
          return defer.promise;
        },
        preloadThumbs: function(album, gidx) {
          var defer, eidx, elem, thumb, thumbsLoaded, thumbsTotal, _i, _len, _ref;
          defer = q.defer();
          if (album.galleries[gidx].thumbsLoaded) {
            to(function() {
              return defer.resolve(album);
            }, 11);
          } else {
            thumbsTotal = album.galleries[gidx].elements.length;
            thumbsLoaded = 0;
            _ref = album.galleries[gidx].elements;
            for (eidx = _i = 0, _len = _ref.length; _i < _len; eidx = ++_i) {
              elem = _ref[eidx];
              thumb = new Image();
              thumb.onload = function() {
                album.galleries[gidx].elements[this.idx].thumbImg = this;
                if (++thumbsLoaded >= thumbsTotal) {
                  album.galleries[gidx].thumbsLoaded = true;
                  return defer.resolve(album);
                }
              };
              thumb.src = elem.thumbSrc;
              thumb.idx = eidx;
            }
          }
          return defer.promise;
        },
        preloadImage: function(album, gidx, iidx) {
          var defer, gpath, img;
          defer = q.defer();
          gpath = scope.album.galleries[gidx].path;
          img = new Image();
          img.onload = function() {
            album.elements[gidx].elements[iidx].fileImg = this;
            return defer.resolve(album);
          };
          img.onerror = function() {
            return defer.reject(status, config);
          };
          img.src = gpath + album.elements[gidx].elements[iidx].file;
          return defer.promise;
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
    "$scope", "$timeout", "$q", "AlbumService", 'settings', function(scope, to, q, as, sttgs) {
      scope.galleryIndex = 0;
      scope.elementIndex = 0;
      scope.album = null;
      scope.element = null;
      (scope.loadAlbum = function(idx) {
        var albumPromise;
        albumPromise = as.getAlbum(1);
        return albumPromise.then(function(album) {
          return scope.selectGallery(scope.galleryIndex, album);
        });
      })(1);
      scope.selectGallery = function(idx, album) {
        var promise, _album;
        _album = album || scope.album;
        promise = as.preloadThumbs(_album, idx);
        return promise.then(function(album) {
          scope.album = album;
          scope.galleryIndex = idx;
          return scope.selectImage(0);
        });
      };
      scope.selectImage = function(idx) {
        var path;
        scope.elementIndex = idx;
        path = scope.album.galleries[scope.galleryIndex].path;
        return scope.element = path + scope.album.galleries[scope.galleryIndex].elements[idx].file;
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

  app.directive("tGallery", [
    function() {
      return {
        restrict: 'A',
        scope: true,
        templateUrl: '/partials/gallery.tpl.html',
        link: function(scope, element, attrs, vs) {}
      };
    }
  ]);

  app.directive("vslider", [
    '$timeout', function(to) {
      return {
        restrict: 'A',
        scope: true,
        link: function(scope, element, attrs) {
          var _blenderBtm, _blenderTop, _content, _contentPosition, _limits, _mouseMoveScrolling, _mouseWheelDeltaFactor, _mouseWheelScrolling, _scroller, _setLimits;
          _content = element.find('ul').first();
          _limits = {
            top: 0,
            btm: 0,
            fac: 1
          };
          _mouseWheelDeltaFactor = 20;
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
            _contentPosition(0);
            _scroller.height(0);
            eh = element.actual('height');
            ch = _content.actual('outerHeight', {
              includeMargin: true
            });
            _limits.fac = eh / ch;
            _limits.btm = eh - ch;
            if (0 > _limits.btm) {
              _scroller.height(_limits.fac * eh);
              _blenderBtm.removeClass('veil');
              _mouseWheelScrolling();
              return _mouseMoveScrolling();
            } else {
              element.unbind('mousewheel mouseenter mouseleave');
              return _contentPosition(0);
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
          return scope.$watch(attrs.vslider, function(nv, ov) {
            if (nv != null) {
              return to(function() {
                return _setLimits();
              }, 400);
            }
          });
        }
      };
    }
  ]);

  app.directive("thThumb", [
    '$timeout', function(to) {
      return {
        restrict: 'A',
        scope: true,
        link: function(scope, element, attrs) {
          var idx;
          idx = attrs.thThumb;
          element.addClass('veil-delay-' + scope.$index);
          return scope.$watch('galleryIndex', function(nv, ov) {
            var $img;
            if (nv != null) {
              element.addClass('veil');
              $img = element.find('img');
              if ($img.length > 0) {
                $img.replaceWith($(scope.album.galleries[scope.galleryIndex].elements[idx].thumbImg));
              } else {
                element.append($(scope.album.galleries[scope.galleryIndex].elements[idx].thumbImg));
              }
              return to(function() {
                return element.removeClass('veil');
              }, 150 * (scope.$index + 1));
            }
          });
        }
      };
    }
  ]);

  app.directive("thCover", [
    function() {
      return {
        restrict: 'A',
        scope: true,
        link: function(scope, element, attrs) {
          var idx;
          idx = attrs.thCover;
          return scope.$watch('album', function(nv, ov) {
            if (nv != null) {
              return element.append(scope.album.galleries[idx].coverImg);
            }
          });
        }
      };
    }
  ]);

}).call(this);
