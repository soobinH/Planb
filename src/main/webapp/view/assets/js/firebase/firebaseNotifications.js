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

	const originalDisplay = button.style.display;
    let registrationSaved = false;
    let connecting = false;

    function updateEnableButton() {
        const permission = typeof Notification !== "undefined" ? Notification.permission : "denied";
        const enabled = registrationSaved && permission === "granted";
        button.hidden = enabled;
        button.style.display = enabled ? "none" : originalDisplay;

        if (enabled) {
            button.disabled = false;
            return;
        }
        if (permission === "denied") {
            button.disabled = true;
            button.textContent = "브라우저 설정에서 알림을 허용해주세요";
        } else if (connecting) {
            button.disabled = true;
            button.textContent = "연결 중...";
        } else {
            button.disabled = false;
            button.textContent = "실시간 알림 켜기";
        }
    }

    if (typeof Notification === "undefined" || !(await isSupported())) {
		button.disabled = true;
		button.textContent = "실시간 알림을 지원하지 않는 브라우저";
		return;
	}

	updateEnableButton();

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

			registrationSaved = true;
            connecting = false;
            updateEnableButton();

		} catch (error) {
			console.error("Firebase 등록 정보 저장 실패:", error);

			registrationSaved = false;
            connecting = false;
            updateEnableButton();

			showMessage(
				error.message || "실시간 알림 등록에 실패했습니다."
			);
		}
	});

	// 현재 화면을 보고 있을 때 메시지를 받으면 헤더 다시 조회
	onMessage(messaging, function() {
		console.log("[Firebase] 화면에서 메시지 수신");

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

				console.log("[Firebase] 서비스 워커에서 갱신 신호 수신");

				window.dispatchEvent(
					new CustomEvent("notifications-updated")
				);
			}
		}
	);

	async function connectMessaging() {
        connecting = true;
        updateEnableButton();
        try {
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
        } catch (error) {
            connecting = false;
            registrationSaved = false;
            updateEnableButton();
            throw error;
        }
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
                registrationSaved = false;
                updateEnableButton();
				showMessage("실시간 알림을 사용하려면 알림 권한이 필요합니다.");
				return;
			}

			button.disabled = true;
			button.textContent = "연결 중...";

			await connectMessaging();

		} catch (error) {
			console.error("Firebase 등록 실패:", error);
			registrationSaved = false;
            connecting = false;
            updateEnableButton();

			showMessage(
				"실시간 알림 연결에 실패했습니다. 콘솔 오류를 확인해주세요."
			);

		} finally {
            updateEnableButton();
		}
	});

	// 이전에 허용했다면 새 페이지에서도 자동으로 연결
	if (Notification.permission === "granted") {
		await connectMessaging();
	}

    // 브라우저 설정에서 권한을 바꾼 뒤 돌아오면 안내 상태를 다시 반영한다.
    document.addEventListener("visibilitychange", function() {
        if (!document.hidden) {
            if (Notification.permission !== "granted") registrationSaved = false;
            updateEnableButton();
        }
    });
}

initializeFirebaseNotifications().catch(function(error) {
	console.error("Firebase 초기화 실패:", error);
});