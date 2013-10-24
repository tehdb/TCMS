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
    '$http', '$log', '$q', 'settings', function(http, log, q, sttgs) {
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
                g.coverImg = this;
                coverLoaded++;
                if (coverLoaded >= coverTotal) {
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
    "$scope", "$timeout", "$q", "AlbumService", 'settings', function(scope, timeout, q, as, sttgs) {
      var _loadAlbum, _preloadThumbs, _prepareAlbumInfo;
      scope.galleryIndex = 0;
      scope.elementIndex = 0;
      scope.album = null;
      scope.dialogShow = false;
      (_loadAlbum = function(idx) {
        var albumPromise;
        albumPromise = as.getAlbum(1);
        return albumPromise.then(function(album) {
          var thumbsPromise;
          thumbsPromise = _preloadThumbs(album.galleries[scope.galleryIndex].elements);
          return thumbsPromise.then(function(elements) {
            album.galleries[scope.galleryIndex].elements = elements;
            return scope.album = album;
          });
        });
      })(1);
      _prepareAlbumInfo = function() {
        scope.albumInfo.push({
          label: album.galleries.length + " Galleries",
          icon: 'glyphicon-book'
        });
        if (totalImages > 0) {
          scope.albumInfo.push({
            label: totalImages + " Images",
            icon: 'glyphicon-picture'
          });
        }
        if (totalVideos > 0) {
          return scope.albumInfo.push({
            label: totalVideos + " Videos",
            icon: 'glyphicon-film'
          });
        }
      };
      _preloadThumbs = function(elements) {
        var defer, eidx, elem, thumb, thumbsLoaded, thumbsTotal, _i, _len;
        defer = q.defer();
        thumbsTotal = elements.length;
        thumbsLoaded = 0;
        for (eidx = _i = 0, _len = elements.length; _i < _len; eidx = ++_i) {
          elem = elements[eidx];
          thumb = new Image();
          thumb.onload = function() {
            elements[this.idx].thumbImg = this;
            thumbsLoaded++;
            if (thumbsLoaded >= thumbsTotal) {
              return defer.resolve(elements);
            }
          };
          thumb.src = elem.thumbSrc;
          thumb.idx = eidx;
        }
        return defer.promise;
      };
      return scope.openGallery = function() {
        console.log("open gallery");
        return scope.dialogShow = true;
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
    function() {
      return {
        restrict: 'A',
        scope: true,
        link: function(scope, element, attrs) {
          var _blenderBtm, _blenderTop, _content, _contentPosition, _limits, _mouseMoveScrolling, _mouseWheelDeltaFactor, _mouseWheelScrolling, _scroller, _scrolling, _setLimits;
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
          return scope.$watch('album', function(nv, ov) {
            if (nv != null) {
              return _setLimits();
            }
          });
        }
      };
    }
  ]);

  app.directive("thThumb", [
    function() {
      return {
        restrict: 'A',
        scope: true,
        link: function(scope, element, attrs) {
          var idx;
          idx = attrs.thThumb;
          return element.append(scope.album.galleries[scope.galleryIndex].elements[idx].thumbImg);
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
          return element.append(scope.album.galleries[idx].coverImg);
        }
      };
    }
  ]);

}).call(this);
