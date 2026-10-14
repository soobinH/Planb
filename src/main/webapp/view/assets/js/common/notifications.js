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

    function markRowRead(row) {
        row.dataset.unread = "false";
        row.classList.add("is-read");
    }

    const pendingRows = new WeakSet();

    // 뒤로 가기로 복원된 화면도 DB의 읽음 상태를 다시 조회
    window.addEventListener("pageshow", function (event) {
        if (event.persisted) {
            window.location.reload();
        }
    });

    // 읽지 않은 알림을 누르면 먼저 읽음 처리하고 대상 페이지로 이동
    list.addEventListener("click", async function (event) {
        const row = event.target.closest("[data-notification-row]");

        if (!row) {
            return;
        }

        event.preventDefault();

        if (pendingRows.has(row)) {
            return;
        }
        if (row.dataset.unread === "false") {
            window.location.assign(row.dataset.notificationUrl || row.href);
            return;
        }

        const readUrl = list.dataset.readUrl;
        const notificationId = row.dataset.notificationId;
        const targetUrl = row.dataset.notificationUrl || row.href;

        if (!readUrl || !notificationId) {
            showError("알림 요청 정보를 확인해주세요.");
            return;
        }

        pendingRows.add(row);
        try {
            const data = await postForm(readUrl, {
                notificationId: notificationId
            });

            markRowRead(row);
            setUnreadCount(data.unreadCount);
            window.dispatchEvent(new CustomEvent("notifications-updated"));
            window.location.assign(targetUrl);
        } catch (error) {
            console.error("알림 읽음 처리 실패:", error);
            showError(error.message || "읽음 처리에 실패했습니다.");
        } finally {
            pendingRows.delete(row);
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
                const data = await postForm(readAllUrl, {});
                // 응답의 실제 읽음 상태를 반영 (처리 도중 새로 온 알림은 미읽음 유지)
                const states = new Map((data.notifications || []).map(function (item) {
                    return [String(item.notificationId), item.read === true];
                }));
                list.querySelectorAll("[data-notification-row]").forEach(function (row) {
                    if (!states.has(row.dataset.notificationId) ||
                        states.get(row.dataset.notificationId) === true) {
                        markRowRead(row);
                    }
                });
                setUnreadCount(data.unreadCount);

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