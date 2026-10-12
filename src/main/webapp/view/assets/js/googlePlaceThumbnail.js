(function () {
    'use strict';

    var scriptEl = document.currentScript
        || document.querySelector('script[data-google-place-thumbnail-loader]');
    var apiKey = scriptEl && scriptEl.dataset
        ? String(scriptEl.dataset.googleMapsKey || '').trim()
        : '';

    var placePhotoCache = Object.create(null);
    var observedImages = typeof WeakSet === 'function' ? new WeakSet() : null;

    function ensurePlacesLibrary() {
        if (window.google
                && google.maps
                && typeof google.maps.importLibrary === 'function') {
            return google.maps.importLibrary('places');
        }

        if (!apiKey) {
            return Promise.reject(new Error('Google Maps API key가 없습니다.'));
        }

        if (!window.__planbGoogleMapsBasePromise) {
            window.__planbGoogleMapsBasePromise = new Promise(function (resolve, reject) {
                var existing = document.querySelector(
                    'script[data-planb-google-maps-base], script[src*="maps.googleapis.com/maps/api/js"]'
                );

                function waitUntilReady() {
                    var attempts = 0;
                    var timer = window.setInterval(function () {
                        attempts += 1;
                        if (window.google
                                && google.maps
                                && typeof google.maps.importLibrary === 'function') {
                            window.clearInterval(timer);
                            resolve();
                        } else if (attempts >= 120) {
                            window.clearInterval(timer);
                            reject(new Error('Google Maps JavaScript API를 불러오지 못했습니다.'));
                        }
                    }, 50);
                }

                if (existing) {
                    waitUntilReady();
                    return;
                }

                var script = document.createElement('script');
                script.async = true;
                script.defer = true;
                script.dataset.planbGoogleMapsBase = '1';
                script.src = 'https://maps.googleapis.com/maps/api/js?key='
                    + encodeURIComponent(apiKey)
                    + '&v=weekly&loading=async';
                script.onload = waitUntilReady;
                script.onerror = function () {
                    reject(new Error('Google Maps JavaScript API를 불러오지 못했습니다.'));
                };
                document.head.appendChild(script);
            });
        }

        return window.__planbGoogleMapsBasePromise.then(function () {
            return google.maps.importLibrary('places');
        });
    }

    function placeIdFromImage(img) {
        if (!img || img.tagName !== 'IMG') return '';

        var explicit = String(img.dataset.googlePlaceId || '').trim();
        if (explicit) return explicit;

        var raw = String(img.getAttribute('src') || '');
        var marker = 'gplace:';
        var index = raw.indexOf(marker);
        if (index < 0) return '';

        var value = raw.substring(index + marker.length);
        value = value.split('#')[0].split('?')[0];

        try {
            value = decodeURIComponent(value);
        } catch (ignore) {
        }

        return value.trim();
    }

    function countryCodeFromImage(img) {
        if (!img || img.tagName !== 'IMG') return '';

        var explicit = String(img.dataset.countryFlagCode || '').trim().toUpperCase();
        if (/^[A-Z]{2}$/.test(explicit)) return explicit;

        var raw = String(img.getAttribute('src') || '');

        /*
         * 새 저장 형식: flag:KR
         * 기존 JSP가 contextPath를 붙여 /Planbflag:KR 로 렌더링해도
         * 문자열 안에서 flag: 토큰을 찾아 복원한다.
         */
        var tokenMatch = raw.match(/flag:([a-z]{2})(?:[^a-z]|$)/i);
        if (tokenMatch) return tokenMatch[1].toUpperCase();

        /*
         * 이미 DB에 저장된 과거 값(https://flagcdn.com/w640/kr.png)도 호환한다.
         * JSP가 /Planbhttps://... 로 잘못 붙인 경우에도 src 문자열에서 코드 추출.
         */
        var cdnMatch = raw.match(/flagcdn\.com\/w(?:80|160|320|640|1280|2560)\/([a-z]{2})\.png/i);
        if (cdnMatch) return cdnMatch[1].toUpperCase();

        return '';
    }

    function hydrateFlagImage(img) {
        if (!img || img.dataset.countryFlagThumbnailState) return false;

        var countryCode = countryCodeFromImage(img);
        if (!countryCode) return false;

        img.dataset.countryFlagThumbnailState = 'ready';
        img.dataset.countryFlagCode = countryCode;
        img.src = 'https://flagcdn.com/w640/' + countryCode.toLowerCase() + '.png';
        return true;
    }

    function fetchPlacePhoto(placeId) {
        if (placePhotoCache[placeId]) {
            return placePhotoCache[placeId];
        }

        placePhotoCache[placeId] = ensurePlacesLibrary()
            .then(function (placesLib) {
                if (!placesLib || !placesLib.Place) {
                    throw new Error('Places 라이브러리를 사용할 수 없습니다.');
                }

                var place = new placesLib.Place({ id: placeId });
                return place.fetchFields({ fields: ['photos'] }).then(function () {
                    if (!place.photos || !place.photos.length) {
                        throw new Error('장소 사진이 없습니다.');
                    }

                    var photo = place.photos[0];
                    var uri = photo.getURI({
                        maxWidth: 1200,
                        maxHeight: 900
                    });

                    if (!uri) {
                        throw new Error('장소 사진 URI가 없습니다.');
                    }

                    return {
                        uri: uri,
                        attributions: Array.isArray(photo.authorAttributions)
                            ? photo.authorAttributions
                            : []
                    };
                });
            })
            .catch(function (error) {
                delete placePhotoCache[placeId];
                throw error;
            });

        return placePhotoCache[placeId];
    }

    function addAttributionTitle(img, info) {
        if (!img || !info) return;

        var names = (info.attributions || []).map(function (attr) {
            return attr && attr.displayName ? String(attr.displayName) : '';
        }).filter(Boolean);

        img.title = names.length
            ? 'Google Maps · 사진: ' + names.join(', ')
            : 'Google Maps';
    }

    function hydrateImage(img) {
        if (!img || img.dataset.googlePlaceThumbnailState) return;

        var placeId = placeIdFromImage(img);
        if (!placeId) return;

        img.dataset.googlePlaceThumbnailState = 'loading';
        img.dataset.googlePlaceId = placeId;

        var previousVisibility = img.style.visibility;
        img.style.visibility = 'hidden';

        fetchPlacePhoto(placeId)
            .then(function (info) {
                img.onload = function () {
                    img.dataset.googlePlaceThumbnailState = 'ready';
                    img.style.visibility = previousVisibility || 'visible';
                };

                img.onerror = function () {
                    img.dataset.googlePlaceThumbnailState = 'error';
                    img.style.visibility = 'hidden';
                };

                addAttributionTitle(img, info);
                img.src = info.uri;
            })
            .catch(function () {
                img.dataset.googlePlaceThumbnailState = 'error';
                img.style.visibility = 'hidden';
            });
    }

    function scan(root) {
        if (!root) return;

        if (root.nodeType === 1 && root.tagName === 'IMG') {
            if (hydrateFlagImage(root)) {
                if (observedImages) observedImages.add(root);
            } else if (placeIdFromImage(root)) {
                if (!observedImages || !observedImages.has(root)) {
                    if (observedImages) observedImages.add(root);
                    hydrateImage(root);
                }
            }
        }

        if (!root.querySelectorAll) return;

        root.querySelectorAll('img').forEach(function (img) {
            if (observedImages && observedImages.has(img)) return;

            if (hydrateFlagImage(img)) {
                if (observedImages) observedImages.add(img);
                return;
            }

            if (!placeIdFromImage(img)) return;
            if (observedImages) observedImages.add(img);
            hydrateImage(img);
        });
    }

    function start() {
        scan(document);

        if ('MutationObserver' in window && document.body) {
            new MutationObserver(function (mutations) {
                mutations.forEach(function (mutation) {
                    mutation.addedNodes.forEach(scan);
                });
            }).observe(document.body, {
                childList: true,
                subtree: true
            });
        }
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', start);
    } else {
        start();
    }
})();
