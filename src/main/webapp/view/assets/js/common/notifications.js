(function () {
    const list = document.querySelector("[data-notification-list]");
    const readAllButton = document.querySelector("[data-read-all]");
    const moreButton = document.querySelector("[data-notification-more]");
    const moreWrap = document.querySelector("[data-more-wrap]");

    if (!list) {
        return;
    }

    const readFilter = list.dataset.notificationFilter || "all";

    function updateEmptyState() {
        const rows = list.querySelector("[data-notification-rows]");
        if (!rows) return;
        let empty = rows.querySelector("[data-notification-empty]");
        if (rows.querySelector("[data-notification-row]")) {
            if (empty) empty.remove();
        } else if (!empty) {
            empty = document.createElement("p");
            empty.dataset.notificationEmpty = "";
            empty.textContent = readFilter === "unread" ? "읽지 않은 알림이 없습니다." :
                readFilter === "read" ? "읽은 알림이 없습니다." : "아직 도착한 알림이 없습니다.";
            rows.appendChild(empty);
        }
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
    let readVersion = 0;
    let paginationVersion = 0;

    function makeRow(item) {
        const row = document.createElement("a");
        row.className = "pb-notification-row" + (item.read ? " is-read" : "");
        row.dataset.notificationRow = "";
        row.dataset.notificationId = String(item.notificationId);
        row.dataset.unread = String(item.read !== true);
        row.dataset.notificationUrl = (list.dataset.contextPath || "") + (item.targetUrl || "#");
        row.href = row.dataset.notificationUrl;
        const icon = document.createElement("span");
        const comment = item.notificationType === "COMMENT";
        const report = item.notificationType === "REPORT_RECEIVED";
        icon.className = "pb-notification-icon" + (comment ? "" : report ? " is-report" : " is-like");
        icon.setAttribute("aria-hidden", "true");
        // 고정된 아이콘만 생성하고 서버의 문자열은 모두 textContent로 출력
        const svg = document.createElementNS("http://www.w3.org/2000/svg", "svg");
        for (const [key, value] of Object.entries({width:"22",height:"22",viewBox:"0 0 24 24",fill:"none",stroke:"currentColor","stroke-width":"1.6","stroke-linecap":"round","stroke-linejoin":"round"})) {
            svg.setAttribute(key, value);
        }
        const path = document.createElementNS("http://www.w3.org/2000/svg", "path");
        path.setAttribute("d", comment ? "M20 11.5a8 8 0 0 1-8 8H5l-3 2v-10a9 9 0 0 1 18 0Z M7 9h8 M7 13h5" : report ? "M5 21V3h14l-3 5 3 5H5" : "M20.8 4.6a5.5 5.5 0 0 0-7.8 0L12 5.7l-1.1-1.1a5.5 5.5 0 0 0-7.8 7.8L12 21l8.8-8.6a5.5 5.5 0 0 0 0-7.8Z");
        svg.appendChild(path);
        icon.appendChild(svg);
        const copy = document.createElement("span");
        copy.className = "pb-notification-copy";
        const title = document.createElement("span");
        title.className = "pb-notification-title";
        const label = document.createElement("strong");
        label.textContent = item.label || "새 알림";
        const dot = document.createElement("span");
        dot.className = "pb-notification-dot unread-dot";
        dot.setAttribute("aria-hidden", "true");
        const readLabel = document.createElement("span");
        readLabel.className = "pb-notification-read-label";
        readLabel.textContent = "읽음";
        title.append(label, dot, readLabel);
        const message = document.createElement("span");
        message.className = "pb-notification-message";
        message.textContent = item.message || "";
        const time = document.createElement("span");
        time.className = "pb-notification-time";
        time.textContent = item.createdAtText || "";
        copy.append(title, message, time);
        const arrow = document.createElement("span");
        arrow.className = "pb-notification-arrow";
        arrow.textContent = "›";
        arrow.setAttribute("aria-hidden", "true");
        row.append(icon, copy, arrow);
        return row;
    }

    if (moreButton) {
        moreButton.addEventListener("click", async function () {
            if (moreButton.disabled || (readAllButton && readAllButton.disabled)) {
                return;
            }
            const cursor = moreButton.dataset.nextCursor;
            if (!cursor || !moreButton.dataset.moreUrl) {
                return;
            }
            const paginationAtStart = paginationVersion;
            moreButton.disabled = true;
            moreButton.textContent = "불러오는 중…";
            try {
                let data;
                let version;
                do {
                    version = readVersion;
                    const params = new URLSearchParams({beforeNotificationId: cursor, filter: readFilter});
                    const response = await fetch(moreButton.dataset.moreUrl + "?" + params, {
                        credentials: "same-origin", cache: "no-store",
                        headers: {"Accept": "application/json"}
                    });
                    data = await response.json();
                    if (!response.ok || data.success !== true) {
                        throw new Error(data.message || "추가 알림을 불러오지 못했습니다.");
                    }
                } while (version !== readVersion);
                if (paginationAtStart !== paginationVersion) return;
                const rows = list.querySelector("[data-notification-rows]");
                const existing = new Set(Array.from(list.querySelectorAll("[data-notification-row]"), function (row) {
                    return row.dataset.notificationId;
                }));
                (data.notifications || []).forEach(function (item) {
                    if (existing.size < 100 && !existing.has(String(item.notificationId))) {
                        rows.appendChild(makeRow(item));
                        existing.add(String(item.notificationId));
                    }
                });
                updateEmptyState();
                setUnreadCount(data.unreadCount);
                moreButton.dataset.nextCursor = data.nextCursor || "";
                if (moreWrap) {
                    moreWrap.hidden = data.hasMore !== true || existing.size >= 100;
                }
            } catch (error) {
                console.error("알림 더보기 실패:", error);
                showError(error.message || "알림 더보기에 실패했습니다.");
            } finally {
                moreButton.disabled = false;
                moreButton.textContent = "더보기";
            }
        });
    }

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

            readVersion++;
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
                const data = await postForm(readAllUrl, {filter: readFilter});
                readVersion++;
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
                if (readFilter !== "all") {
                    paginationVersion++;
                    const rows = list.querySelector("[data-notification-rows]");
                    rows.replaceChildren();
                    (data.notifications || []).forEach(function (item) { rows.appendChild(makeRow(item)); });
                    if (moreButton) moreButton.dataset.nextCursor = data.nextCursor || "";
                    if (moreWrap) moreWrap.hidden = data.hasMore !== true;
                }
                updateEmptyState();
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