(function () {

    const canvas = document.getElementById("detailGoogleMap");
    const dataElement = document.getElementById("detailMapData");
    const status = document.getElementById("detailMapStatus");

    const filterButton =
        document.getElementById("detailMapFilterButton");
    const filterMenu =
        document.getElementById("detailMapFilterMenu");
    const filterLabel =
        document.getElementById("detailMapFilterLabel");
    const filterDot =
        document.getElementById("detailMapFilterDot");
    const legend =
        document.getElementById("detailMapDayLegend");

    if (!canvas || !dataElement) {
        return;
    }

    const dayColors = [
        "#6369D1", "#F59E0B", "#10B981", "#EC4899",
        "#06B6D4", "#8B5CF6", "#EF4444", "#14B8A6"
    ];

    const typeColors = {
        ATTRACTION: "#3B82F6",
        MEAL: "#F97316",
        LODGING: "#10B981",
        TRANSPORT: "#3B82F6",
        ACTIVITY: "#EC4899"
    };

    let days = [];
    let map = null;
    let infoWindow = null;
    let markers = [];
    let lines = [];
    let activeDay = "all";

    function showStatus(message) {
        if (status) {
            status.textContent = message;
            status.hidden = !message;
        }
    }

    window.detailMapLoadFailed = function () {
        showStatus("지도를 불러오지 못했습니다.");
    };

    function dayColor(number) {
        return dayColors[(Number(number) - 1) % dayColors.length]
            || dayColors[0];
    }

    try {
        const raw = JSON.parse(dataElement.textContent);

        if (!Array.isArray(raw)) {
            throw new Error("지도 데이터 형식이 올바르지 않습니다.");
        }

        days = raw.map(function (day) {
            const points = Array.isArray(day.points)
                ? day.points
                : [];

            return {
                number: String(day.dayNumber),
                title: day.title || "",
                points: points.filter(function (point) {
                    if (point.lat === null || point.lat === undefined
                            || point.lng === null
                            || point.lng === undefined) {
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
                        address: point.address || "",
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
        if (filterMenu && filterButton) {
            filterMenu.hidden = !open;
            filterButton.setAttribute(
                "aria-expanded",
                String(open)
            );
        }
    }

    if (filterButton && filterMenu) {
        filterButton.addEventListener("click", function () {
            setMenuOpen(filterMenu.hidden);
        });

        filterMenu.addEventListener("click", function (event) {
            const button = event.target.closest(
                "[data-detail-map-day]"
            );

            if (!button) {
                return;
            }

            activeDay = button.dataset.detailMapDay;
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

    function updateFilter() {
        if (filterLabel) {
            filterLabel.textContent = activeDay === "all"
                ? "전체"
                : activeDay + "일차";
        }

        if (filterDot) {
            filterDot.style.background = activeDay === "all"
                ? dayColors[0]
                : dayColor(activeDay);
        }

        if (filterMenu) {
            filterMenu.querySelectorAll(
                "[data-detail-map-day]"
            ).forEach(function (button) {
                button.setAttribute(
                    "aria-pressed",
                    String(button.dataset.detailMapDay === activeDay)
                );
            });
        }
    }

    function clearMap() {
        markers.forEach(function (marker) {
            marker.setMap(null);
        });

        lines.forEach(function (line) {
            line.setMap(null);
        });

        markers = [];
        lines = [];

        if (infoWindow) {
            infoWindow.close();
        }
    }

    function createInfoContent(point, day, incoming) {
        const content = document.createElement("div");

        content.style.maxWidth = "220px";
        content.style.padding = "3px";
        content.style.color = "#334155";

        const title = document.createElement("strong");
        title.textContent = point.title;
        title.style.fontSize = "13px";
        content.appendChild(title);

        const meta = document.createElement("div");
        meta.textContent = day.number + "일차 · "
            + point.sequence + "번"
            + (incoming ? " · 이전 일차 마지막 장소" : "");

        meta.style.marginTop = "5px";
        meta.style.fontSize = "11px";
        meta.style.color = "#6369D1";
        content.appendChild(meta);

        if (point.address) {
            const address = document.createElement("div");
            address.textContent = point.address;
            address.style.marginTop = "5px";
            address.style.fontSize = "11px";
            content.appendChild(address);
        }

        return content;
    }

    function addMarker(point, day, bounds, incoming) {
        const marker = new google.maps.Marker({
            map: map,
            position: { lat: point.lat, lng: point.lng },
            title: point.title,
            label: {
                text: String(point.sequence),
                color: "#fff",
                fontWeight: "bold",
                fontSize: "11px"
            },
            icon: {
                path: google.maps.SymbolPath.CIRCLE,
                scale: 14,
                fillColor: typeColors[point.type] || "#6369D1",
                fillOpacity: 1,
                strokeColor: "#fff",
                strokeWeight: 2
            }
        });

        marker.addListener("click", function () {
            infoWindow.setContent(
                createInfoContent(point, day, incoming)
            );

            infoWindow.open({
                map: map,
                anchor: marker
            });
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
            strokeWeight: 4
        }));
    }

    function updateLegend() {
        if (!legend) {
            return;
        }

        legend.replaceChildren();

        const visibleDays = days.filter(function (day) {
            return day.points.length > 0;
        });

        legend.hidden =
            activeDay !== "all" || visibleDays.length === 0;

        visibleDays.forEach(function (day) {
            const row = document.createElement("div");
            const dot = document.createElement("span");

            dot.style.width = "8px";
            dot.style.height = "8px";
            dot.style.borderRadius = "50%";
            dot.style.background = dayColor(day.number);

            const label = document.createElement("span");
            label.textContent = day.number + "일차";

            row.appendChild(dot);
            row.appendChild(label);
            legend.appendChild(row);
        });
    }

    function drawMap() {
        clearMap();

        const bounds = new google.maps.LatLngBounds();

        days.forEach(function (day) {
            if (activeDay !== "all" && activeDay !== day.number) {
                return;
            }

            day.points.forEach(function (point) {
                addMarker(point, day, bounds, false);
            });

            addLine(day.points, dayColor(day.number));
        });

        // 이전 일차 마지막 장소 → 다음 일차 첫 장소
        for (let index = 1; index < days.length; index++) {
            const previous = days[index - 1];
            const current = days[index];

            if (previous.points.length === 0
                    || current.points.length === 0) {
                continue;
            }

            if (activeDay !== "all"
                    && activeDay !== current.number) {
                continue;
            }

            const from = previous.points[previous.points.length - 1];
            const to = current.points[0];

            addLine([from, to], dayColor(current.number));

            if (activeDay !== "all") {
                addMarker(from, previous, bounds, true);
            }
        }

        updateLegend();

        if (markers.length === 0) {
            showStatus("표시할 장소 좌표가 없습니다.");
            return;
        }

        showStatus("");

        if (markers.length === 1) {
            map.setCenter(markers[0].getPosition());
            map.setZoom(15);
        } else {
            map.fitBounds(bounds, 40);
        }
    }

    window.initScheduleDetailMap = function () {
        if (map) {
            return;
        }

        try {
            map = new google.maps.Map(canvas, {
                center: { lat: 37.5665, lng: 126.9780 },
                zoom: 10,
                mapTypeControl: false,
                streetViewControl: false,
                fullscreenControl: true
            });

            infoWindow = new google.maps.InfoWindow();

            updateFilter();
            drawMap();

        } catch (error) {
            console.error(error);
            window.detailMapLoadFailed();
        }
    };

    updateFilter();

    // 다른 공통 코드에서 이미 지도를 로딩한 경우
    if (window.google && window.google.maps
            && window.google.maps.Map) {
        window.initScheduleDetailMap();
    }

})();