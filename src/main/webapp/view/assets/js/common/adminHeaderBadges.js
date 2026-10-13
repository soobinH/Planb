/**
 * PLANB 관리자 헤더 신고·광고·문의 알림 공통 스크립트.
 * /admin/header-badges 한 번의 요청으로 3개 상태 표시.
 */
(function () {
    "use strict";

    var currentScript = document.currentScript;
    var endpoint = currentScript ? currentScript.getAttribute("data-badges-url") : null;
    if (!endpoint) {
        console.error("[PLANB AdminBadges] data-badges-url 경로가 없습니다.");
        return;
    }

    var items = [
        {
            key: "reportPendingCount",
            buttonId: "adminReportHeaderButton",
            dotId: "adminReportDot",
            baseTitle: "신고 관리",
            countLabel: "미처리 신고"
        },
        {
            key: "adPendingCount",
            buttonId: "adminAdHeaderButton",
            dotId: "adminAdDot",
            baseTitle: "광고 관리",
            countLabel: "승인 대기 광고"
        },
        {
            key: "receivedInquiryCount",
            buttonId: "adminInquiryHeaderButton",
            dotId: "adminInquiryDot",
            baseTitle: "문의 관리",
            countLabel: "새 문의"
        }
    ];

    function prepareDots() {
        var found = false;
        items.forEach(function (item) {
            var button = document.getElementById(item.buttonId);
            if (!button) return;

            var wrapper = button.closest(".site-badge-wrap");
            if (!wrapper) return;

            found = true;
            var dot = document.getElementById(item.dotId);
            if (!dot) {
                dot = document.createElement("span");
                dot.id = item.dotId;
                wrapper.appendChild(dot);
            }

            dot.classList.add("site-admin-alert-dot", "planb-admin-badge-dot");
            dot.setAttribute("aria-hidden", "true");
            dot.hidden = true;
        });
        return found;
    }

    function setBadge(item, raw) {
        var button = document.getElementById(item.buttonId);
        var dot = document.getElementById(item.dotId);
        if (!button || !dot) return;

        if (raw === null || raw === undefined ||
            typeof raw !== "number" || !Number.isFinite(raw) || raw < 0) {
            dot.hidden = true;
            button.title = item.baseTitle + " · 알림 조회 실패";
            button.setAttribute("aria-label", button.title);
            console.warn("[PLANB AdminBadges] " + item.key + " 조회 실패. 서버 로그를 확인하세요.");
            return;
        }

        dot.hidden = raw === 0;
        var title = raw > 0
            ? item.baseTitle + " · " + item.countLabel + " " + raw + "건"
            : item.baseTitle;
        button.title = title;
        button.setAttribute("aria-label", title);
    }

    function init() {
        if (!prepareDots()) return; // 일반 회원 페이지

        var pending = false;
        async function refresh() {
            if (pending) return;
            pending = true;
            try {
                var result = await fetch(endpoint, {
                    method: "GET",
                    credentials: "same-origin",
                    cache: "no-store",
                    headers: { "Accept": "application/json" }
                });
                if (!result.ok) {
                    throw new Error("HTTP " + result.status + " - " + endpoint);
                }
                var data = await result.json();
                items.forEach(function (item) {
                    setBadge(item, data[item.key]);
                });
            } catch (error) {
                console.error("[PLANB AdminBadges] 응답 실패:", error);
                items.forEach(function (item) { setBadge(item, null); });
            } finally {
                pending = false;
            }
        }

        refresh();
        window.setInterval(refresh, 30000);
        document.addEventListener("visibilitychange", function () {
            if (!document.hidden) refresh();
        });
    }

    if (document.readyState === "loading") {
        document.addEventListener("DOMContentLoaded", init);
    } else {
        init();
    }
})();
