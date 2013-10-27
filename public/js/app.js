(function() {
  var app;

  app = angular.module("TGallery", ["ngAnimate"]);

  app.constant('settings', {
    dynamicBackground: false,
    slideshowDur: 5,
    galleriesShow: true,
    thumbsShow: true,
    thumbsPath: 'thumbs/',
    sidebarW: 165
  });

  app.service("AlbumService", [
    '$http', '$log', '$timeout', '$q', 'settings', function(http, log, to, q, sttgs) {
      return {
        albums: {},
        albumIndex: null,
        getAlbum: function(idx) {
          var defer, _this;
          defer = q.defer();
          _this = this;
          _this.albumIndex = idx;
          http({
            method: 'GET',
            url: "/album/" + idx
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
                  _this.albums[_this.albumIndex] = data;
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
        preloadThumbs: function(gidx) {
          var defer, eidx, elem, thumb, thumbsLoaded, thumbsTotal, _i, _len, _ref, _this;
          _this = this;
          defer = q.defer();
          if (_this.albums[_this.albumIndex].galleries[gidx].thumbsLoaded) {
            to(function() {
              return defer.resolve(true);
            }, 11);
          } else {
            thumbsTotal = _this.albums[_this.albumIndex].galleries[gidx].elements.length;
            thumbsLoaded = 0;
            _ref = _this.albums[_this.albumIndex].galleries[gidx].elements;
            for (eidx = _i = 0, _len = _ref.length; _i < _len; eidx = ++_i) {
              elem = _ref[eidx];
              thumb = new Image();
              thumb.onload = function() {
                _this.albums[_this.albumIndex].galleries[gidx].elements[this.idx].thumbImg = this;
                if (++thumbsLoaded >= thumbsTotal) {
                  _this.albums[_this.albumIndex].galleries[gidx].thumbsLoaded = true;
                  return defer.resolve(true);
                }
              };
              thumb.src = elem.thumbSrc;
              thumb.idx = eidx;
            }
          }
          return defer.promise;
        },
        loadImage: function(gidx, iidx) {
          var defer, gpath, img, _this;
          _this = this;
          defer = q.defer();
          gpath = _this.albums[_this.albumIndex].galleries[gidx].path;
          if (_this.albums[_this.albumIndex].galleries[gidx].elements[iidx].fileImg != null) {
            to(function() {
              return defer.resolve(true);
            }, 11);
          } else {
            img = new Image();
            img.onload = function() {
              _this.albums[_this.albumIndex].galleries[gidx].elements[iidx].fileImg = this;
              return defer.resolve(true);
            };
            img.onerror = function() {
              return defer.reject(status, config);
            };
            img.src = gpath + _this.albums[_this.albumIndex].galleries[gidx].elements[iidx].file;
          }
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
      scope.album = null;
      scope.galleryIndex = null;
      scope.elementIndex = null;
      scope.slideshow = false;
      scope.control = {
        thumbsShow: false,
        galleriesShow: false
      };
      (scope.loadAlbum = function(idx) {
        var albumPromise;
        albumPromise = as.getAlbum(1);
        return albumPromise.then(function(album) {
          scope.album = album;
          scope.galleryIndex = null;
          return scope.selectGallery(0);
        });
      })(0);
      scope.selectGallery = function(idx) {
        var promise;
        promise = as.preloadThumbs(idx);
        return promise.then(function() {
          scope.galleryIndex = idx;
          scope.elementIndex = null;
          return scope.selectImage(0);
        });
      };
      scope.selectImage = function(idx) {
        return as.loadImage(scope.galleryIndex, idx).then(function() {
          return scope.elementIndex = idx;
        });
      };
      scope.nextImage = function() {
        var idx;
        idx = scope.elementIndex;
        if (++idx > scope.album.galleries[scope.galleryIndex].elements.length - 1) {
          idx = 0;
        }
        return scope.selectImage(idx);
      };
      scope.prevImage = function() {
        var idx;
        idx = scope.elementIndex;
        if (--idx < 0) {
          idx = scope.album.galleries[scope.galleryIndex].elements.length - 1;
        }
        return scope.selectImage(idx);
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

  app.directive("thStage", [
    '$timeout', 'settings', function(to, sttgs) {
      return {
        restrict: 'A',
        scope: true,
        link: function(scope, element, attrs) {
          var _centerImg;
          _centerImg = function($img) {
            var difH, difW, imgH, imgW, imgX, imgY, scaleFactor, sidebarFactor, stageH, stageW;
            sidebarFactor = 0;
            if (scope.control.thumbsShow) {
              sidebarFactor++;
            }
            if (scope.control.galleriesShow) {
              sidebarFactor++;
            }
            stageW = element.width() - sidebarFactor * sttgs.sidebarW;
            stageH = element.height() - 20;
            imgW = $img[0].width;
            imgH = $img[0].height;
            difW = imgW / stageW;
            difH = imgH / stageH;
            scaleFactor = 1;
            if (difW > 1 || difH > 1) {
              if (difW > difH) {
                scaleFactor = difW;
              } else {
                scaleFactor = difH;
              }
              imgW = Math.round(imgW / scaleFactor);
              imgH = Math.round(imgH / scaleFactor);
            }
            imgX = (stageW - imgW) / 2;
            imgY = (stageH - imgH) / 2 + 10;
            if (scope.control.galleriesShow) {
              imgX += sttgs.sidebarW;
            }
            return $img.css({
              width: imgW,
              height: imgH,
              left: imgX,
              top: imgY
            });
          };
          scope.$watchCollection('[control.thumbsShow, control.galleriesShow]', function(nv, ov) {
            var $img;
            if (nv != null) {
              $img = element.find('img');
              if ($img.length > 0) {
                return _centerImg($img);
              }
            }
          });
          return scope.$watch('elementIndex', function(nv, ov) {
            var $img, $media;
            if (nv != null) {
              $media = element.find('img');
              $img = $(scope.album.galleries[scope.galleryIndex].elements[nv].fileImg);
              _centerImg($img);
              $img.addClass('veilin');
              if ($media.length > 0) {
                $media.addClass('veilout');
                return to(function() {
                  $media.replaceWith($img);
                  return to(function() {
                    $media.removeClass('veilout');
                    return $img.removeClass('veilin');
                  }, 150);
                }, 150);
              } else {
                element.append($img);
                return to(function() {
                  return $img.removeClass('veilin');
                }, 150);
              }
            }
          });
        }
      };
    }
  ]);

  app.directive("thSlideshowProgress", [
    'settings', function(sttgs) {
      return {
        restrict: 'A',
        scope: true,
        link: function(scope, element, attrs) {
          var _next;
          _next = function() {
            return element.animate({
              'width': '100%'
            }, sttgs.slideshowDur * 1000, 'linear', function() {
              element.width(0);
              scope.nextImage();
              if (scope.slideshow) {
                return _next();
              }
            });
          };
          return scope.$watch("slideshow", function(nv, ov) {
            if (nv) {
              return _next();
            } else {
              return element.stop().width(0);
            }
          });
        }
      };
    }
  ]);

}).call(this);
