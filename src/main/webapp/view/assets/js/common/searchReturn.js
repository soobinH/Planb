(function () {
    "use strict";
    const script = document.currentScript;
    const context = script ? script.dataset.contextPath || "" : "";
    const current = new URL(window.location.href);
    const searchPath = context + "/search";
    const detailPaths = [context + "/schedules/detail", context + "/tipDetail", context + "/mateDetail"];
    if (current.pathname === searchPath) {
        document.querySelectorAll("a[href]").forEach(function (link) {
            const url = new URL(link.href, current);
            if (url.origin === current.origin && detailPaths.includes(url.pathname)) {
                url.searchParams.set("returnTo", current.pathname + current.search + current.hash);
                link.href = url.href;
            }
        });
        return;
    }
    const value = current.searchParams.get("returnTo");
    if (!value) return;
    try {
        const target = new URL(value, current.origin);
        if (target.origin !== current.origin || target.pathname !== searchPath) return;
        document.querySelectorAll("[data-search-return]").forEach(function (link) {
            link.href = target.pathname + target.search + target.hash;
        });
        const input = document.querySelector('.header-search-form input[name="q"]');
        if (input) input.value = target.searchParams.get("q") || "";
    } catch (ignore) {
        // 정상적인 목록 링크를 유지한다.
    }
})();
