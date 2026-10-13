import {
	initializeApp
} from "https://www.gstatic.com/firebasejs/13.0.0/firebase-app.js";

import {
	getMessaging,
	isSupported,
	onMessage,
	onRegistered,
	register
} from "https://www.gstatic.com/firebasejs/13.0.0/firebase-messaging.js";

async function initializeFirebaseNotifications() {
	const root =
		document.querySelector("[data-notification-header]");

	const button =
		document.querySelector("[data-firebase-enable]");

	if (!root || !button) {
		return;
	}

	function showMessage(message) {
		if (typeof window.tripilyToast === "function") {
			window.tripilyToast(message);
		} else {
			window.alert(message);
		}
	}

	if (!(await isSupported())) {
		button.disabled = true;
		button.textContent = "실시간 알림을 지원하지 않는 브라우저";
		return;
	}

	const contextPath = root.dataset.contextPath || "";

	async function saveInstallationId(installationId) {
		const params = new URLSearchParams();

		params.set("installationId", installationId);

		const response = await fetch(
			contextPath + "/notifications/device/register",
			{
				method: "POST",
				credentials: "same-origin",
				headers: {
					"Content-Type":
						"application/x-www-form-urlencoded;charset=UTF-8",
					"Accept": "application/json"
				},
				body: params.toString()
			}
		);

		const result = await response.json();

		if (!response.ok || result.success !== true) {
			throw new Error(
				result.message || "등록 정보를 저장하지 못했습니다."
			);
		}
	}

	const app = initializeApp(window.planbFirebaseConfig);
	const messaging = getMessaging(app);

	// 등록이 완료됐을 때 Firebase 등록번호를 받음
	onRegistered(messaging, async function(installationId) {
		window.planbFirebaseInstallationId = installationId;

		try {
			await saveInstallationId(installationId);

			console.log("Firebase 등록 및 DB 저장 완료");

			button.textContent = "실시간 알림 사용 중";

		} catch (error) {
			console.error("Firebase 등록 정보 저장 실패:", error);

			button.textContent = "실시간 알림 켜기";

			showMessage(
				error.message || "실시간 알림 등록에 실패했습니다."
			);
		}
	});

	// 현재 화면을 보고 있을 때 메시지를 받으면 헤더 다시 조회
	onMessage(messaging, function() {
		window.dispatchEvent(
			new CustomEvent("notifications-updated")
		);
	});

	// 서비스 워커가 전달한 갱신 신호 처리
	navigator.serviceWorker.addEventListener(
		"message",
		function(event) {
			if (event.data &&
				event.data.type === "PLANB_NOTIFICATION_REFRESH") {

				window.dispatchEvent(
					new CustomEvent("notifications-updated")
				);
			}
		}
	);

	async function connectMessaging() {
		const workerRegistration =
			await navigator.serviceWorker.register(
				contextPath + "/firebase-messaging-sw.js",
				{
					scope: contextPath + "/"
				}
			);

		await navigator.serviceWorker.ready;

		await register(messaging, {
			vapidKey: window.planbFirebaseVapidKey,
			serviceWorkerRegistration: workerRegistration
		});
	}

	button.addEventListener("click", async function() {
		if (button.disabled) {
			return;
		}

		if (Notification.permission === "denied") {
			showMessage(
				"브라우저 사이트 설정에서 알림 권한을 허용해주세요."
			);
			return;
		}

		try {
			const permission =
				Notification.permission === "granted"
					? "granted"
					: await Notification.requestPermission();

			if (permission !== "granted") {
				showMessage("실시간 알림을 사용하려면 알림 권한이 필요합니다.");
				return;
			}

			button.disabled = true;
			button.textContent = "연결 중...";

			await connectMessaging();

		} catch (error) {
			console.error("Firebase 등록 실패:", error);
			button.textContent = "실시간 알림 켜기";

			showMessage(
				"실시간 알림 연결에 실패했습니다. 콘솔 오류를 확인해주세요."
			);

		} finally {
			button.disabled = false;
		}
	});

	// 이전에 허용했다면 새 페이지에서도 자동으로 연결
	if (Notification.permission === "granted") {
		await connectMessaging();
	}
}

initializeFirebaseNotifications().catch(function(error) {
	console.error("Firebase 초기화 실패:", error);
});