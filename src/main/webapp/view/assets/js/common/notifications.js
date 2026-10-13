(function () {
    const list = document.querySelector("[data-notification-list]");
    const readAllButton = document.querySelector("[data-read-all]");

    if (!list) {
        return;
    }

    function showError(message) {
        if (typeof window.tripilyToast === "function") {
            window.tripilyToast(message);
        } else {
            window.alert(message);
        }
    }

    async function postForm(url, values) {
        const params = new URLSearchParams();

        Object.keys(values).forEach(function (key) {
            params.set(key, values[key]);
        });

        const response = await fetch(url, {
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
            throw new Error(data.message || "요청을 처리하지 못했습니다.");
        }

        return data;
    }

    function setUnreadCount(count) {
        const countElement = list.querySelector("[data-unread-count]");

        if (countElement) {
            countElement.textContent = String(Number(count) || 0);
        }
    }

    function showEmptyMessage() {
        list.querySelectorAll("[data-notification-row]").forEach(function (row) {
            row.remove();
        });

        if (!list.querySelector("[data-notification-empty]")) {
            const empty = document.createElement("p");
            empty.className = "px-5 py-10 text-center text-sm text-gray-500";
            empty.dataset.notificationEmpty = "";
            empty.textContent = "읽지 않은 알림이 없습니다.";
            list.appendChild(empty);
        }

        setUnreadCount(0);
    }

    // 읽지 않은 알림을 누르면 먼저 읽음 처리하고 대상 페이지로 이동
    list.addEventListener("click", async function (event) {
        const row = event.target.closest("[data-notification-row]");

        if (!row) {
            return;
        }

        event.preventDefault();

        const readUrl = list.dataset.readUrl;
        const notificationId = row.dataset.notificationId;
        const targetUrl = row.dataset.notificationUrl || row.href;

        if (!readUrl || !notificationId) {
            showError("알림 요청 정보를 확인해주세요.");
            return;
        }

        try {
            await postForm(readUrl, {
                notificationId: notificationId
            });

            window.location.assign(targetUrl);
        } catch (error) {
            console.error("알림 읽음 처리 실패:", error);
            showError(error.message || "읽음 처리에 실패했습니다.");
        }
    });

    if (readAllButton) {
        readAllButton.addEventListener("click", async function () {
            const readAllUrl = readAllButton.dataset.readAllUrl;

            if (!readAllUrl || readAllButton.disabled) {
                return;
            }

            readAllButton.disabled = true;

            try {
                await postForm(readAllUrl, {});

                showEmptyMessage();

                window.dispatchEvent(
                    new CustomEvent("notifications-updated")
                );
            } catch (error) {
                console.error("모두 읽음 처리 실패:", error);
                showError(error.message || "모두 읽음 처리에 실패했습니다.");
            } finally {
                readAllButton.disabled = false;
            }
        });
    }
})();