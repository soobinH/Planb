(function () {
    "use strict";

    const canvas = document.getElementById("detailGoogleMap");
    const dataElement = document.getElementById("detailMapData");
    const status = document.getElementById("detailMapStatus");
    const filterButton = document.getElementById("detailMapFilterButton");
    const filterMenu = document.getElementById("detailMapFilterMenu");
    const filterLabel = document.getElementById("detailMapFilterLabel");
    const filterDot = document.getElementById("detailMapFilterDot");
    const legend = document.getElementById("detailMapDayLegend");

    if (!canvas || !dataElement) {
        return;
    }

    const dayLinePalette = ['#7C3AED','#2563EB','#F97316','#10B981','#EC4899','#06B6D4','#EF4444','#6366F1','#14B8A6','#D97706','#8B5CF6','#0EA5E9'];


    let days = [];
    let map = null;
    let markers = [];
    let lines = [];
    let activeDay = "all";
    let activeSheet = "all";
    let placesLibraryPromise = null;
    let infoSequence = 0;

    const placeDetailsCache = Object.create(null);

    function escapeHtml(value) {
        return String(value == null ? "" : value)
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
            .replace(/"/g, "&quot;")
            .replace(/'/g, "&#39;");
    }

    function showStatus(message) {
        if (!status) {
            return;
        }
        status.textContent = message || "";
        status.hidden = !message;
    }

    function showMapFallback() {
        if (canvas.dataset.fallback === "1") return;
        const root = document.getElementById("scheduleDetail");
        const query = root ? [root.dataset.mapCity, root.dataset.mapCountry].filter(Boolean).join(", ") : "";
        const iframe = document.createElement("iframe");
        iframe.title = "경로 지도";
        iframe.src = "https://maps.google.com/maps?q=" + encodeURIComponent(query || "Seoul, Korea") + "&z=11&output=embed";
        iframe.style.cssText = "width:100%;height:100%;min-height:360px;border:0;display:block";
        iframe.loading = "lazy";
        iframe.referrerPolicy = "no-referrer-when-downgrade";
        canvas.replaceChildren(iframe);
        canvas.dataset.fallback = "1";
        if (legend) legend.hidden = true;
        showStatus("");
    }
    window.detailMapLoadFailed = showMapFallback;

    function dayLineColor(number) {
        let dayNumber = parseInt(number, 10);
        if (!dayNumber || dayNumber < 1) {
            dayNumber = 1;
        }
        return dayLinePalette[(dayNumber - 1) % dayLinePalette.length];
    }

    try {
        const raw = JSON.parse(dataElement.textContent);

        if (!Array.isArray(raw)) {
            throw new Error("지도 데이터 형식이 올바르지 않습니다.");
        }

        days = raw.map(function (day) {
            const points = Array.isArray(day.points) ? day.points : [];

            return {
                number: String(day.dayNumber),
                title: day.title || "",
                sheetKey: String(day.sheetKey || "legacy-1"),
                sheetLabel: String(day.sheetLabel || "일정"),
                sheetIndex: Number(day.sheetIndex) || 1,
                points: points.filter(function (point) {
                    if (point.lat === null || point.lat === undefined
                            || point.lng === null || point.lng === undefined) {
                        return false;
                    }

                    const lat = Number(point.lat);
                    const lng = Number(point.lng);

                    return Number.isFinite(lat)
                        && Number.isFinite(lng)
                        && lat >= -90 && lat <= 90
                        && lng >= -180 && lng <= 180;
                }).map(function (point) {
                    return {
                        blockId: point.blockId,
                        sequence: point.sequence,
                        type: point.type,
                        title: point.title || point.placeName || "장소",
                        placeName: point.placeName || point.title || "장소",
                        address: point.address || "",
                        googlePlaceId: point.googlePlaceId || "",
                        lat: Number(point.lat),
                        lng: Number(point.lng)
                    };
                })
            };
        });
    } catch (error) {
        console.error(error);
        showStatus("지도 데이터를 확인해주세요.");
        return;
    }

    function setMenuOpen(open) {
        if (!filterMenu || !filterButton) {
            return;
        }
        filterMenu.hidden = !open;
        filterButton.setAttribute("aria-expanded", String(open));
    }

    function sheetLineColor(index) {
        return dayLinePalette[((Math.max(1, Number(index) || 1) - 1) % dayLinePalette.length)];
    }

    function visibleDays() {
        return days.filter(function (day) {
            return activeSheet === "all" || day.sheetKey === activeSheet;
        });
    }

    function sheetGroups() {
        const groups = [];
        const seen = new Set();
        days.forEach(function (day) {
            if (seen.has(day.sheetKey)) return;
            seen.add(day.sheetKey);
            groups.push({ key: day.sheetKey, label: day.sheetLabel, index: day.sheetIndex });
        });
        // DAY가 없는 시트도 지도 필터에 표시한다.
        const tabList = document.getElementById("detailSheetList");
        if (tabList) {
            tabList.querySelectorAll("[data-detail-sheet]").forEach(function (tab) {
                const key = tab.dataset.detailSheet;
                if (key === "all" || seen.has(key)) return;
                seen.add(key);
                groups.push({ key: key, label: tab.textContent.trim(), index: groups.length + 1 });
            });
        }
        return groups;
    }

    function decorateFilterMenu() {
        if (!filterMenu) return;
        filterMenu.replaceChildren();
        const options = [{ key: "all", label: "전체", color: null }];
        if (activeSheet === "all") {
            sheetGroups().forEach(function (sheet) {
                options.push({ key: "sheet:" + sheet.key, label: sheet.label,
                    color: sheetLineColor(sheet.index) });
            });
        } else {
            visibleDays().forEach(function (day) {
                options.push({ key: day.number, label: day.number + "일차",
                    color: dayLineColor(day.number) });
            });
        }
        options.forEach(function (option) {
            const button = document.createElement("button");
            button.type = "button";
            button.dataset.detailMapDay = option.key;
            const label = document.createElement("span");
            label.textContent = option.label;
            button.appendChild(label);
            if (option.color) {
                const swatch = document.createElement("span");
                swatch.className = "detail-map-filter-line";
                swatch.style.background = option.color;
                button.appendChild(swatch);
            }
            filterMenu.appendChild(button);
        });
    }

    function updateFilter() {
        let label = "전체";
        let color = "#6369D1";
        if (activeDay !== "all") {
            if (activeSheet === "all") {
                const group = sheetGroups().find(function (s) { return "sheet:" + s.key === activeDay; });
                if (group) { label = group.label; color = sheetLineColor(group.index); }
            } else {
                label = activeDay + "일차";
                color = dayLineColor(activeDay);
            }
        }
        if (filterLabel) filterLabel.textContent = label;
        if (filterDot) filterDot.style.background = color;
        if (filterMenu) filterMenu.querySelectorAll("[data-detail-map-day]").forEach(function (button) {
            button.setAttribute("aria-pressed", String(button.dataset.detailMapDay === activeDay));
        });
    }

    window.addEventListener("detail:sheet-change", function (event) {
        activeSheet = event.detail && event.detail.sheetKey ? String(event.detail.sheetKey) : "all";
        activeDay = "all";
        setMenuOpen(false);
        decorateFilterMenu();
        updateFilter();
        if (map) drawMap();
    });

    if (filterButton && filterMenu) {
        filterButton.addEventListener("click", function () {
            setMenuOpen(filterMenu.hidden);
        });

        filterMenu.addEventListener("click", function (event) {
            const button = event.target.closest("[data-detail-map-day]");
            if (!button) {
                return;
            }

            activeDay = button.dataset.detailMapDay || "all";
            setMenuOpen(false);
            updateFilter();

            if (map) {
                drawMap();
            }
        });

        document.addEventListener("click", function (event) {
            if (!filterButton.contains(event.target)
                    && !filterMenu.contains(event.target)) {
                setMenuOpen(false);
            }
        });

        document.addEventListener("keydown", function (event) {
            if (event.key === "Escape") {
                setMenuOpen(false);
            }
        });
    }

    function getPlacesLibrary() {
        if (placesLibraryPromise) {
            return placesLibraryPromise;
        }

        if (!window.google || !google.maps
                || typeof google.maps.importLibrary !== "function") {
            return Promise.reject(
                new Error("Google Maps JavaScript API를 불러오지 못했습니다.")
            );
        }

        placesLibraryPromise = google.maps.importLibrary("places");
        return placesLibraryPromise;
    }

    function googleMapsDetailUrl(point) {
        const placeId = point && point.googlePlaceId
            ? String(point.googlePlaceId).trim()
            : "";

        let query = point && point.placeName
            ? String(point.placeName).trim()
            : (point && point.title ? String(point.title).trim() : "");

        if (point && Number.isFinite(Number(point.lat))
                && Number.isFinite(Number(point.lng))) {
            query = (query ? query + " " : "")
                + Number(point.lat) + "," + Number(point.lng);
        }

        let url = "https://www.google.com/maps/search/?api=1";
        if (query) {
            url += "&query=" + encodeURIComponent(query);
        }
        if (placeId) {
            url += "&query_place_id=" + encodeURIComponent(placeId);
        }
        return url;
    }

    function fetchPlaceDetails(point) {
        const placeId = point && point.googlePlaceId
            ? String(point.googlePlaceId).trim()
            : "";

        if (!placeId) {
            return Promise.resolve(null);
        }

        if (placeDetailsCache[placeId]) {
            return placeDetailsCache[placeId];
        }

        placeDetailsCache[placeId] = getPlacesLibrary()
            .then(function (placesLib) {
                if (!placesLib || !placesLib.Place) {
                    return null;
                }

                const place = new placesLib.Place({ id: placeId });
                return place.fetchFields({
                    fields: [
                        "displayName",
                        "formattedAddress",
                        "rating",
                        "userRatingCount",
                        "photos",
                        "googleMapsURI"
                    ]
                }).then(function () {
                    return place;
                });
            })
            .catch(function (error) {
                delete placeDetailsCache[placeId];
                throw error;
            });

        return placeDetailsCache[placeId];
    }

    function placeInfoHtml(point, details, infoId) {
        const name = details && details.displayName
            ? details.displayName
            : (point.placeName || point.title || "장소");
        const address = details && details.formattedAddress
            ? details.formattedAddress
            : point.address;
        const rating = details && typeof details.rating === "number"
            ? details.rating
            : null;
        const ratingCount = details
            && typeof details.userRatingCount === "number"
            ? details.userRatingCount
            : null;
        const mapsUrl = details && details.googleMapsURI
            ? details.googleMapsURI
            : googleMapsDetailUrl(point);

        let photoHtml = "";

        if (details && details.photos && details.photos.length) {
            const photo = details.photos[0];
            let photoUrl = "";

            try {
                photoUrl = photo.getURI({
                    maxWidth: 320,
                    maxHeight: 180
                });
            } catch (ignore) {
                photoUrl = "";
            }

            if (photoUrl) {
                let attributionHtml = "";
                const attributions = photo.authorAttributions || [];

                if (attributions.length) {
                    attributionHtml = '<div style="position:absolute;left:8px;bottom:6px;max-width:calc(100% - 16px);padding:2px 5px;border-radius:4px;background:rgba(17,24,39,.72);font-size:9px;line-height:1.3;color:#fff;white-space:nowrap;overflow:hidden;text-overflow:ellipsis">사진: '
                        + attributions.map(function (attr) {
                            const attrName = attr && attr.displayName
                                ? escapeHtml(attr.displayName)
                                : "Google Maps 사용자";

                            if (attr && attr.uri) {
                                return '<a href="' + escapeHtml(attr.uri)
                                    + '" target="_blank" rel="noopener noreferrer" style="color:#fff;text-decoration:underline">'
                                    + attrName + '</a>';
                            }
                            return attrName;
                        }).join(", ")
                        + '</div>';
                }

                photoHtml = '<div style="position:relative;width:260px;height:130px;overflow:hidden;border-radius:9px 9px 0 0;background:#F3F4F6">'
                    + '<img src="' + escapeHtml(photoUrl)
                    + '" alt="' + escapeHtml(name)
                    + ' 사진" style="width:100%;height:100%;display:block;object-fit:cover">'
                    + attributionHtml
                    + '</div>';
            }
        }

        if (!photoHtml) {
            photoHtml = '<div style="width:260px;height:78px;display:flex;align-items:center;justify-content:center;border-radius:9px 9px 0 0;background:#F3F4F6;color:#9CA3AF;font-size:11px">'
                + (details === null && point.googlePlaceId
                    ? "장소 정보를 불러오는 중..."
                    : "등록된 사진이 없습니다.")
                + '</div>';
        }

        let ratingHtml = "";
        if (rating !== null) {
            ratingHtml = '<div style="margin-top:8px;display:flex;align-items:center;gap:5px;font-size:12px;color:#374151">'
                + '<span style="color:#F59E0B">★</span>'
                + '<strong>' + escapeHtml(rating.toFixed(1)) + '</strong>'
                + (ratingCount !== null
                    ? '<span style="color:#6B7280">평가 '
                        + escapeHtml(Number(ratingCount).toLocaleString())
                        + '개</span>'
                    : "")
                + '</div>';
        } else if (details) {
            ratingHtml = '<div style="margin-top:8px;font-size:11px;color:#9CA3AF">평점 정보 없음</div>';
        }

        return '<div id="' + escapeHtml(infoId)
            + '" style="width:260px;font-family:Arial,\'Noto Sans KR\',sans-serif">'
            + photoHtml
            + '<div style="padding:11px 12px 12px">'
            + '<div style="font-size:14px;line-height:1.35;font-weight:700;color:#111827">'
            + escapeHtml(name || "장소") + '</div>'
            + (address
                ? '<div style="margin-top:5px;font-size:11px;line-height:1.45;color:#6B7280">'
                    + escapeHtml(address) + '</div>'
                : "")
            + ratingHtml
            + '<a href="' + escapeHtml(mapsUrl)
            + '" target="_blank" rel="noopener noreferrer" style="display:inline-flex;margin-top:10px;align-items:center;font-size:12px;font-weight:700;color:#4F46E5;text-decoration:none">구글맵에서 자세히 보기 ↗</a>'
            + '</div></div>';
    }

    function clearMap() {
        markers.forEach(function (marker) {
            if (marker.__detailInfoWindow) {
                marker.__detailInfoWindow.close();
            }
            marker.setMap(null);
        });

        lines.forEach(function (line) {
            line.setMap(null);
        });

        markers = [];
        lines = [];
    }

    function addMarker(point, bounds, color) {
        const marker = new google.maps.Marker({
            map: map,
            position: { lat: point.lat, lng: point.lng },
            title: point.placeName || point.title,
            icon: {
                path: "M0,-18 C-10,-18 -18,-10 -18,0 C-18,12 0,30 0,30 C0,30 18,12 18,0 C18,-10 10,-18 0,-18 Z",
                scale: .5,
                fillColor: color,
                fillOpacity: 1,
                strokeColor: "#fff",
                strokeWeight: 2,
                anchor: new google.maps.Point(0, 30)
            }
        });

        const infoId = "detail-map-info-" + (++infoSequence);
        const infoWindow = new google.maps.InfoWindow({
            content: placeInfoHtml(point, null, infoId),
            disableAutoPan: true
        });

        marker.__detailInfoWindow = infoWindow;

        let closeTimer = null;
        let markerHovered = false;
        let infoHovered = false;

        function cancelClose() {
            if (closeTimer) {
                clearTimeout(closeTimer);
                closeTimer = null;
            }
        }

        function scheduleClose() {
            cancelClose();
            closeTimer = setTimeout(function () {
                if (!markerHovered && !infoHovered) {
                    infoWindow.close();
                }
            }, 220);
        }

        infoWindow.addListener("domready", function () {
            const infoRoot = document.getElementById(infoId);
            if (!infoRoot || infoRoot.dataset.hoverBound === "1") {
                return;
            }

            infoRoot.dataset.hoverBound = "1";
            infoRoot.addEventListener("mouseenter", function () {
                infoHovered = true;
                cancelClose();
            });
            infoRoot.addEventListener("mouseleave", function () {
                infoHovered = false;
                scheduleClose();
            });
        });

        infoWindow.addListener("closeclick", function () {
            markerHovered = false;
            infoHovered = false;
            cancelClose();
        });

        marker.addListener("mouseover", function () {
            markerHovered = true;
            cancelClose();
            infoWindow.setContent(placeInfoHtml(point, null, infoId));
            infoWindow.open(map, marker);

            fetchPlaceDetails(point)
                .then(function (details) {
                    if (markerHovered || infoHovered) {
                        infoWindow.setContent(
                            placeInfoHtml(point, details || false, infoId)
                        );
                    }
                })
                .catch(function (error) {
                    console.warn("지도 핀 상세정보 조회 실패:", error);
                    if (markerHovered || infoHovered) {
                        infoWindow.setContent(
                            placeInfoHtml(point, false, infoId)
                        );
                    }
                });
        });

        marker.addListener("mouseout", function () {
            markerHovered = false;
            scheduleClose();
        });

        markers.push(marker);
        bounds.extend(marker.getPosition());
    }

    function addLine(points, color) {
        if (points.length < 2) {
            return;
        }

        lines.push(new google.maps.Polyline({
            map: map,
            path: points.map(function (point) {
                return { lat: point.lat, lng: point.lng };
            }),
            geodesic: true,
            strokeColor: color,
            strokeOpacity: 0.82,
            strokeWeight: 5
        }));
    }

    function updateLegend() {
        if (!legend) return;
        legend.replaceChildren();
        if (activeDay !== "all") { legend.hidden = true; return; }
        const entries = activeSheet === "all"
            ? sheetGroups().map(function (group) {
                return { label: group.label, color: sheetLineColor(group.index) };
            })
            : visibleDays().map(function (day) {
                return { label: day.number + "일차", color: dayLineColor(day.number) };
            });
        entries.forEach(function (entry) {
            const row = document.createElement("div");
            const label = document.createElement("span");
            const line = document.createElement("span");
            label.textContent = entry.label;
            label.className = "detail-map-day-legend-label";
            line.className = "detail-map-day-legend-line";
            line.style.background = entry.color;
            row.appendChild(label);
            row.appendChild(line);
            legend.appendChild(row);
        });
        legend.hidden = entries.length === 0;
    }

    function drawMap() {
        clearMap();
        const bounds = new google.maps.LatLngBounds();
        let visiblePointCount = 0;
        const selectedDays = visibleDays();
        if (activeSheet === "all") {
            // 전체 보기: 시트별 동선을 독립적으로 그리고 시트마다 색상을 고정한다.
            // 다른 국가 시트 사이에는 경로를 연결하지 않는다.
            sheetGroups().forEach(function (group) {
                if (activeDay !== "all" && activeDay !== "sheet:" + group.key) return;
                const points = [];
                selectedDays.filter(function (day) { return day.sheetKey === group.key; })
                    .forEach(function (day) {
                        day.points.slice().sort(function (a, b) {
                            return Number(a.sequence) - Number(b.sequence);
                        }).forEach(function (point) { points.push(point); });
                    });
                const color = sheetLineColor(group.index);
                points.forEach(function (point) {
                    addMarker(point, bounds, color);
                    visiblePointCount++;
                });
                addLine(points, color);
            });
        } else {
            // 국가별 보기: 기존과 같이 DAY별 색상/경로를 표시한다.
            selectedDays.forEach(function (day) {
                if (activeDay !== "all" && activeDay !== day.number) return;
                const points = day.points.slice().sort(function (a, b) {
                    return Number(a.sequence) - Number(b.sequence);
                });
                const color = dayLineColor(day.number);
                points.forEach(function (point) {
                    addMarker(point, bounds, color);
                    visiblePointCount++;
                });
                addLine(points, color);
            });
        }
        updateLegend();
        if (visiblePointCount === 0) {
            showStatus("표시할 장소 좌표가 없습니다.");
            return;
        }
        showStatus("");
        if (visiblePointCount === 1) {
            map.setCenter(markers[0].getPosition());
            map.setZoom(15);
        } else {
            map.fitBounds(bounds);
        }
    }

    window.initScheduleDetailMap = function () {
        if (map) {
            return;
        }

        try {
            if (canvas.dataset.fallback === "1") canvas.replaceChildren();
            canvas.dataset.fallback = "0";
            map = new google.maps.Map(canvas, {
                center: { lat: 37.5665, lng: 126.9780 },
                zoom: 11,
                gestureHandling: "greedy",
                mapTypeControl: false,
                streetViewControl: false,
                fullscreenControl: false,
                styles: [
                    { featureType: "poi", elementType: "labels", stylers: [{ visibility: "off" }] },
                    { featureType: "transit", elementType: "labels", stylers: [{ visibility: "off" }] }
                ]
            });

            decorateFilterMenu();
            updateFilter();
            drawMap();
        } catch (error) {
            console.error(error);
            window.detailMapLoadFailed();
        }
    };

    decorateFilterMenu();
    updateFilter();
    window.setTimeout(function () { if (!map) showMapFallback(); }, 1800);

    // 다른 공통 코드에서 이미 지도를 로딩한 경우
    if (window.google && window.google.maps && window.google.maps.Map) {
        window.initScheduleDetailMap();
    }
})();
