(function () {
    const list = document.querySelector("[data-notification-list]");
    const readAllButton = document.querySelector("[data-read-all]");
    const moreButton = document.querySelector("[data-notification-more]");

    if (!list) {
        return;
    }

    const contextPath = list.dataset.contextPath || "";

    let nextCursor = list.dataset.nextCursor || "";
    let hasMore = list.dataset.hasMore === "true";
    let moreLoading = false;
    let readAllLoading = false;
    let generation = 0;

    function showError(message) {
        if (typeof window.tripilyToast === "function") {
            window.tripilyToast(message);
        } else {
            window.alert(message);
        }
    }

    async function readResponse(response) {
        const data = await response.json();

        if (!response.ok || data.success !== true) {
            throw new Error(
                data.message || "요청을 처리하지 못했습니다."
            );
        }

        return data;
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

        return readResponse(response);
    }

    function updateMoreButton() {
        if (!moreButton) {
            return;
        }

        moreButton.style.display = hasMore ? "inline-flex" : "none";
        moreButton.disabled = moreLoading || readAllLoading;
        moreButton.textContent =
            moreLoading ? "불러오는 중..." : "더보기";
    }

    function setUnreadCount(count) {
        const element = list.querySelector("[data-unread-count]");

        if (element) {
            element.textContent = String(Number(count) || 0);
        }
    }

    function makeRow(notification) {
        const row = document.createElement("a");
        const targetUrl = contextPath + notification.targetUrl;

        row.dataset.notificationRow = "";
        row.dataset.notificationId =
            String(notification.notificationId);
        row.dataset.notificationUrl = targetUrl;
        row.dataset.unread = "true";
        row.href = targetUrl;

        row.className =
            "w-full px-5 py-5 border-b flex gap-4 text-left " +
            "hover:bg-gray-50 transition bg-[#FAFAFF]";

        const symbol = document.createElement("span");

        symbol.className =
            "w-10 h-10 shrink-0 rounded-full flex items-center " +
            "justify-center bg-[#F0F0FF] text-[#6369D1]";

        symbol.textContent =
            notification.notificationType === "COMMENT"
                ? "💬"
                : notification.notificationType === "REPORT_RECEIVED"
                    ? "⚑"
                    : "♥";

        const content = document.createElement("span");
        content.className = "flex-1 min-w-0";

        const titleRow = document.createElement("span");
        titleRow.className = "flex items-center gap-2";

        const label = document.createElement("strong");
        label.className = "text-sm";
        label.textContent = notification.label || "새 알림";

        const dot = document.createElement("span");

        dot.className =
            "w-1.5 h-1.5 rounded-full bg-[#6369D1] unread-dot";

        titleRow.append(label, dot);

        const message = document.createElement("span");
        message.className = "block text-sm text-gray-600 mt-1";
        message.textContent = notification.message || "";

        const date = document.createElement("span");
        date.className = "block text-xs text-gray-400 mt-2";
        date.textContent = notification.createdAtText || "";

        content.append(titleRow, message, date);
        row.append(symbol, content);

        return row;
    }

    function renderPage(data, replace) {
        if (!Array.isArray(data.notifications)) {
            throw new Error("알림 조회 응답을 확인해주세요.");
        }

        if (replace) {
            list.querySelectorAll("[data-notification-row]")
                .forEach(function (row) {
                    row.remove();
                });
        }

        list.querySelectorAll("[data-notification-empty]")
            .forEach(function (element) {
                element.remove();
            });

        const existingIds = new Set(
            Array.from(
                list.querySelectorAll("[data-notification-row]")
            ).map(function (row) {
                return row.dataset.notificationId;
            })
        );

        data.notifications.forEach(function (notification) {
            const id = String(notification.notificationId);

            if (!existingIds.has(id)) {
                list.appendChild(makeRow(notification));
                existingIds.add(id);
            }
        });

        hasMore = data.hasMore === true;
        nextCursor = data.nextCursor || "";

        setUnreadCount(data.unreadCount);
        updateMoreButton();

        if (!list.querySelector("[data-notification-row]")) {
            const empty = document.createElement("p");

            empty.dataset.notificationEmpty = "";
            empty.className =
                "px-5 py-10 text-center text-sm text-gray-500";
            empty.textContent = "읽지 않은 알림이 없습니다.";

            list.appendChild(empty);
        }
    }

    // 알림 클릭: 읽음 처리 후 해당 상세로 이동
    list.addEventListener("click", async function (event) {
        const row = event.target.closest("[data-notification-row]");

        if (!row) {
            return;
        }

        event.preventDefault();

        if (readAllLoading || row.dataset.loading === "true") {
            return;
        }

        row.dataset.loading = "true";

        try {
            const data = await postForm(list.dataset.readUrl, {
                notificationId: row.dataset.notificationId
            });

            setUnreadCount(data.unreadCount);
            row.remove();

            window.dispatchEvent(
                new CustomEvent("notifications-updated")
            );

            window.location.assign(
                row.dataset.notificationUrl || row.href
            );

        } catch (error) {
            console.error(error);
            showError(error.message);
            delete row.dataset.loading;
        }
    });

    // 5개씩 추가 조회
    if (moreButton) {
        moreButton.addEventListener("click", async function () {
            if (!hasMore || !nextCursor ||
                moreLoading || readAllLoading) {
                return;
            }

            moreLoading = true;
            updateMoreButton();

            const currentGeneration = generation;

            try {
                const url = new URL(
                    list.dataset.moreUrl,
                    window.location.origin
                );

                url.searchParams.set(
                    "beforeNotificationId",
                    nextCursor
                );

                const response = await fetch(url.toString(), {
                    method: "GET",
                    credentials: "same-origin",
                    cache: "no-store",
                    headers: {
                        "Accept": "application/json"
                    }
                });

                const data = await readResponse(response);

                // 모두 읽음 처리 전에 시작한 조회 응답은 제외
                if (currentGeneration === generation) {
                    renderPage(data, false);
                }

            } catch (error) {
                if (currentGeneration === generation) {
                    console.error(error);
                    showError(error.message);
                }

            } finally {
                moreLoading = false;
                updateMoreButton();
            }
        });
    }

    // 전체 미읽음 알림 처리: 아직 더보기로 불러오지 않은 알림도 포함
    if (readAllButton) {
        readAllButton.addEventListener("click", async function () {
            if (readAllLoading) {
                return;
            }

            readAllLoading = true;
            generation++;
            readAllButton.disabled = true;
            updateMoreButton();

            try {
                const data = await postForm(
                    readAllButton.dataset.readAllUrl,
                    {}
                );

                renderPage(data, true);

                window.dispatchEvent(
                    new CustomEvent("notifications-updated")
                );

            } catch (error) {
                console.error(error);
                showError(error.message);

            } finally {
                readAllLoading = false;
                readAllButton.disabled = false;
                updateMoreButton();
            }
        });
    }

    updateMoreButton();
})();