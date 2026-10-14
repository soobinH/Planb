(function() {
	const root = document.querySelector("[data-notification-header]");

	// 로그인 상태가 아니면 헤더 알림 컨테이너가 없을 수 있음
	if (!root) {
		return;
	}

	const contextPath = root.dataset.contextPath || "";
	const headerUrl = root.dataset.headerUrl;
	const readUrl = root.dataset.readUrl;
	const toggleButton = root.querySelector("[data-notification-toggle]");
	const popover = root.querySelector("[data-notification-popover]");
	const badge = root.querySelector("[data-notification-count]");
	const itemsContainer = root.querySelector("[data-notification-items]");

	if (!toggleButton || !popover || !badge || !itemsContainer) {
		return;
	}

	function showError(message) {
		if (typeof window.tripilyToast === "function") {
			window.tripilyToast(message);
		} else {
			window.alert(message);
		}
	}

	function updateBadge(count) {
		const unreadCount = Number(count) || 0;

		if (unreadCount <= 0) {
			badge.hidden = true;
			badge.textContent = "";
			return;
		}

		badge.hidden = false;
		badge.textContent = unreadCount > 99 ? "99+" : String(unreadCount);
	}

	function makeNotificationItem(notification) {
		const anchor = document.createElement("a");
		const isUnread = notification.read !== true;

		anchor.className =
			"site-notification-item" + (isUnread ? " unread" : "");

		anchor.dataset.notificationRow = "";
		anchor.dataset.notificationId =
			String(notification.notificationId || "");
		anchor.dataset.notificationUrl =
			contextPath + (notification.targetUrl || "#");
		anchor.dataset.unread = String(isUnread);
		anchor.href = anchor.dataset.notificationUrl;

		const symbol = document.createElement("span");
		symbol.className = "site-notification-symbol";

		const isComment =
			notification.notificationType === "COMMENT";
		const isReport =
			notification.notificationType === "REPORT_RECEIVED";

		symbol.classList.add(
			isComment ? "comment" : isReport ? "report" : "like"
		);
		symbol.textContent =
			isComment ? "💬" : isReport ? "⚑" : "♥";

		const textWrapper = document.createElement("span");

		const label = document.createElement("strong");
		label.textContent = notification.label || "새 알림";

		const message = document.createElement("small");
		message.textContent = notification.message || "";

		textWrapper.append(label, message);
		anchor.append(symbol, textWrapper);

		return anchor;
	}

	function renderNotifications(data) {
		const notifications = Array.isArray(data.recentNotifications)
			? data.recentNotifications
			: [];

		updateBadge(data.unreadCount);

		itemsContainer.replaceChildren();

		if (notifications.length === 0) {
			const empty = document.createElement("p");
			empty.className = "site-notification-empty";
			empty.textContent = "새 알림이 없습니다.";
			itemsContainer.appendChild(empty);
			return;
		}

		notifications.forEach(function(notification) {
			itemsContainer.appendChild(
				makeNotificationItem(notification)
			);
		});
	}

	async function loadNotifications() {
		if (!headerUrl) {
			return;
		}

		try {
			const response = await fetch(headerUrl, {
				method: "GET",
				credentials: "same-origin",
				cache: "no-store",
				headers: {
					"Accept": "application/json"
				}
			});

			const data = await response.json();

			if (!response.ok || data.success !== true) {
				throw new Error(data.message || "알림을 불러오지 못했습니다.");
			}

			renderNotifications(data);
		} catch (error) {
			console.error("헤더 알림 조회 실패:", error);
		}
	}

	function setPopoverOpen(open) {
		popover.hidden = !open;

		toggleButton.setAttribute("aria-expanded", String(open));
		toggleButton.classList.toggle("active", open);
	}

	toggleButton.addEventListener("click", function() {
		const isOpen =
			toggleButton.getAttribute("aria-expanded") === "true";

		setPopoverOpen(!isOpen);

		if (!isOpen) {
			loadNotifications();
		}
	});

	document.addEventListener("click", function(event) {
		if (!root.contains(event.target)) {
			setPopoverOpen(false);
		}
	});

	document.addEventListener("keydown", function(event) {
		if (event.key === "Escape") {
			setPopoverOpen(false);
		}
	});

	// 헤더 알림 클릭: 읽음 처리 후 알림 대상 화면으로 이동
	itemsContainer.addEventListener("click", async function(event) {
		const anchor = event.target.closest("[data-notification-row]");

		if (!anchor) {
			return;
		}

		event.preventDefault();

		const targetUrl = anchor.dataset.notificationUrl;
		const isUnread = anchor.dataset.unread === "true";

		if (!isUnread) {
			window.location.assign(targetUrl);
			return;
		}

		try {
			const params = new URLSearchParams();
			params.set("notificationId", anchor.dataset.notificationId);

			const response = await fetch(readUrl, {
				method: "POST",
				credentials: "same-origin",
				headers: {
					"Content-Type":
						"application/x-www-form-urlencoded;charset=UTF-8",
					"Accept": "application/json"
				},
				body: params.toString()
			});

			const data = await response.json();

			if (!response.ok || data.success !== true) {
				throw new Error(data.message || "읽음 처리에 실패했습니다.");
			}

			// 누른 알림을 제외하고 다음 미읽음 알림으로 채움
			renderNotifications(data);

			window.location.assign(targetUrl);
		} catch (error) {
			console.error("알림 읽음 처리 실패:", error);
			showError(error.message || "알림 처리 중 오류가 발생했습니다.");
		}
	});

	// 전체 알림 페이지에서 모두 읽음 처리 후 헤더 배지를 새로고침
	window.addEventListener("notifications-updated", function() {
		console.log("[헤더] 갱신 이벤트 수신");
		loadNotifications();
	});

	// 처음 화면이 열릴 때 배지 수를 조회
	loadNotifications();
})();