(function() {
	"use strict";

	const contextPath =
		document.currentScript.dataset.contextPath || "";

	const currentUrl = new URL(window.location.href);

	const routes = [
		{
			list: "/schedules",
			detail: "/schedules/detail",
			grid: "#scheduleCardGrid"
		},
		{
			list: "/tips",
			detail: "/tipDetail",
			grid: "[data-card-grid]"
		},
		{
			list: "/mates",
			detail: "/mateDetail",
			grid: "[data-card-grid]"
		}
	];

	const route = routes.find(function(item) {
		return currentUrl.pathname === contextPath + item.list
			|| currentUrl.pathname === contextPath + item.detail;
	});

	if (!route) return;

	// 목록 화면: 상세 링크에 현재 검색 조건을 포함한 주소 추가
	if (currentUrl.pathname === contextPath + route.list) {
		const grid = document.querySelector(route.grid);
		if (!grid) return;

		const returnUrl =
			currentUrl.pathname + currentUrl.search + currentUrl.hash;

		function updateLinks(root) {
			const links = Array.from(
				root.querySelectorAll("a[href]")
			);

			// 추가된 카드 자체가 a 태그인 경우도 처리
			if (root.matches && root.matches("a[href]")) {
				links.unshift(root);
			}

			links.forEach(function(link) {
				const detailUrl = new URL(link.href, currentUrl);

				if (detailUrl.origin !== currentUrl.origin
					|| detailUrl.pathname
					!== contextPath + route.detail) {
					return;
				}

				detailUrl.searchParams.set("returnUrl", returnUrl);
				link.href = detailUrl.href;
			});
		}

		updateLinks(grid);

		// 무한 스크롤로 추가된 카드에도 동일하게 적용
		const observer = new MutationObserver(function(records) {
			records.forEach(function(record) {
				record.addedNodes.forEach(function(node) {
					if (node.nodeType === 1) {
						updateLinks(node);
					}
				});
			});
		});

		observer.observe(grid, {
			childList: true,
			subtree: true
		});

		return;
	}

	// 상세 화면: 목록으로 버튼에 원래 목록 주소 적용
	const returnUrl = currentUrl.searchParams.get("returnUrl");
	if (!returnUrl) return;

	try {
		const targetUrl = new URL(returnUrl, currentUrl.origin);

		// 같은 사이트의 해당 목록 주소만 허용
		if (targetUrl.origin !== currentUrl.origin
			|| targetUrl.pathname !== contextPath + route.list) {
			return;
		}

		const backButton =
			document.querySelector("[data-list-back]");

		if (backButton) {
			backButton.href =
				targetUrl.pathname + targetUrl.search + targetUrl.hash;
		}
	} catch (error) {
		console.warn("목록 복귀 주소 확인 실패:", error);
	}
})();