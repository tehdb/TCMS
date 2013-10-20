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
    "$scope", "$timeout", "AlbumService", 'settings', function(scope, timeout, as, sttgs) {
      var _prepareData, _setData;
      scope.galleryIndex = 0;
      scope.mediaElementIndex = 0;
      scope.album = null;
      scope.albumInfo = [];
      scope.dialogShow = false;
      as.getAlbum(1, function(data) {
        return _prepareData(data);
      });
      _prepareData = function(data) {
        var album, g, gidx, m, midx, thumbsPath, totalImages, totalVideos, _i, _j, _len, _len1, _ref, _ref1;
        album = data;
        totalImages = 0;
        totalVideos = 0;
        _ref = album.galleries;
        for (gidx = _i = 0, _len = _ref.length; _i < _len; gidx = ++_i) {
          g = _ref[gidx];
          thumbsPath = g.path + sttgs.thumbsPath;
          _ref1 = g.elements;
          for (midx = _j = 0, _len1 = _ref1.length; _j < _len1; midx = ++_j) {
            m = _ref1[midx];
            if (m.type === 'image') {
              totalImages++;
              m.imgSrc = g.path + m.file;
            } else if (m.type === 'video') {
              totalVideos++;
            }
            m.thumbSrc = thumbsPath + m.thumb;
          }
        }
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
      _setData = function(data) {
        return console.log(data);
      };
      return scope.openGallery = function() {
        console.log("open gallery");
        return scope.dialogShow = true;
      };
    }
  ]);

}).call(this);
