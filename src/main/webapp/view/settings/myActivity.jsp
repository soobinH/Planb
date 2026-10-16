<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="java.util.List"
    import="java.util.ArrayList"
    import="dto.profile.ProfileActivityDto" %>
<%!
    // 회원이 작성한 제목/댓글은 HTML 이스케이프 처리해 출력한다.
    private String escapeHtml(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;").replace("<", "&lt;")
                    .replace(">", "&gt;").replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }
    // 시간(시:분:초)은 숨기고 작성 날짜만 표시한다.
    private String dateOnly(Object createdAt) {
        if (createdAt == null) return "";
        String value = String.valueOf(createdAt);
        return value.length() >= 10
                ? value.substring(0, 10).replace('-', '.') : value;
    }
%>
<%
request.setAttribute("activePage", "profile");
request.setAttribute("settingsPage", "activity");
String ctx = request.getContextPath();
@SuppressWarnings("unchecked")
List<ProfileActivityDto> activities =
    (List<ProfileActivityDto>) request.getAttribute("activities");
if (activities == null) activities = new ArrayList<ProfileActivityDto>();
// 목록은 첫 10건이므로 통계는 Servlet이 전달한 전체 집계값을 사용한다.
int postCount = request.getAttribute("postCount") instanceof Number
        ? ((Number) request.getAttribute("postCount")).intValue() : 0;
int commentCount = request.getAttribute("commentCount") instanceof Number
        ? ((Number) request.getAttribute("commentCount")).intValue() : 0;
int totalCount = request.getAttribute("totalCount") instanceof Number
        ? ((Number) request.getAttribute("totalCount")).intValue() : postCount + commentCount;
boolean hasMore = Boolean.TRUE.equals(request.getAttribute("hasMore"));
String nextCursor = (String) request.getAttribute("nextCursor");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>내 활동 내역 · Planb</title>
    <jsp:include page="/common/headStyles.jsp" />
    <link rel="stylesheet" href="<%=ctx%>/view/assets/css/setting/settings.css">
    <link rel="stylesheet" href="<%=ctx%>/view/assets/css/setting/myActivity.css?v=2">
    <style>
        /* notifications.jsp와 동일한 더보기 디자인. 이전 CSS의 버튼 규칙도 덮어쓴다. */
        .ma-section .ma-more { display:block; padding:20px; text-align:center; border-top:1px solid #eef0f5; }
        .ma-section .ma-more[hidden] { display:none !important; }
        .ma-section .ma-more-button { display:inline-block; min-width:0; padding:10px 28px; border:1px solid #e1e3ec; border-radius:10px; background:#fff; color:#6369d1; font:inherit; font-size:13px; cursor:pointer; transition:none; }
        .ma-section .ma-more-button:hover { background:#fff; border-color:#e1e3ec; color:#6369d1; }
        .ma-section .ma-more-button:disabled { opacity:.5; cursor:default; }
        .ma-section .ma-more-button:focus-visible { outline:3px solid #9c9fe7; outline-offset:3px; }
    </style>
</head>
<body class="site-shell">
    <jsp:include page="/common/header.jsp" />
    <div class="settings-page">
        <div class="settings-shell">
            <jsp:include page="/common/settingsSidebar.jsp" />
            <main class="settings-main">
                <div class="settings-content">
                    <header class="settings-title">
                        <span class="settings-eyebrow">MY PAGE</span>
                        <h1>내 활동 내역</h1>
                        <p>내가 작성한 게시글과 댓글을 모아볼 수 있어요.</p>
                    </header>

                    <section class="ma-summary" aria-label="활동 통계">
                        <div class="ma-summary-item"><span>전체 활동</span><strong id="maTotalCount"><%=totalCount%></strong></div>
                        <div class="ma-summary-item"><span>작성한 글</span><strong id="maPostCount"><%=postCount%></strong></div>
                        <div class="ma-summary-item"><span>작성한 댓글</span><strong id="maCommentCount"><%=commentCount%></strong></div>
                    </section>

                    <section class="ma-section" aria-label="활동 내역 목록">
                        <div class="ma-section-head">
                            <div class="ma-section-title">활동 목록 <span id="maVisibleCount"><%=totalCount%>건</span></div>
                            <div class="ma-filters" role="group" aria-label="활동 유형 필터">
                                <button type="button" class="active" data-ma-filter="ALL" aria-pressed="true">전체</button>
                                <button type="button" data-ma-filter="POST" aria-pressed="false">게시글</button>
                                <button type="button" data-ma-filter="COMMENT" aria-pressed="false">댓글</button>
                            </div>
                        </div>

                        <div class="ma-list" id="maList" data-context-path="<%=escapeHtml(ctx)%>">
                        <%
                        for (ProfileActivityDto activity : activities) {
                            String kind = activity.getActivityType();
                            String group = activity.getActivityGroup();
                            String section = "";
                            String activityUrl = "";
                            if ("TIP_POST".equals(kind) || "TIP_COMMENT".equals(kind)) {
                                section = "여행 꿀팁";
                                activityUrl = ctx + "/tipDetail?tipId=" + activity.getTargetId();
                            } else if ("MATE_POST".equals(kind) || "MATE_COMMENT".equals(kind)) {
                                section = "여행 메이트";
                                activityUrl = ctx + "/mateDetail?mateId=" + activity.getTargetId();
                            } else if ("ITINERARY_COMMENT".equals(kind)) {
                                section = "여행 일정";
                                activityUrl = ctx + "/schedules/detail?id=" + activity.getTargetId();
                            } else {
                                section = "기타 활동";
                            }
                            boolean post = "POST".equals(group);
                            String title = escapeHtml(activity.getTargetTitle());
                            String content = escapeHtml(activity.getContent());
                            String date = dateOnly(activity.getCreatedAt());
                        %>
                            <% if (!activityUrl.isEmpty()) { %>
                            <a class="ma-item" href="<%=activityUrl%>" data-ma-item data-ma-key="<%=escapeHtml(kind)%>:<%=activity.getActivityId()%>" data-ma-group="<%=escapeHtml(group)%>">
                            <% } else { %>
                            <div class="ma-item ma-item--static" data-ma-item data-ma-key="<%=escapeHtml(kind)%>:<%=activity.getActivityId()%>" data-ma-group="<%=escapeHtml(group)%>">
                            <% } %>
                                <div class="ma-item-icon" aria-hidden="true">
                                    <% if (post) { %>
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"><rect x="4" y="3.5" width="16" height="17" rx="2"/><path d="M8 8h8M8 12h8M8 16h5"/></svg>
                                    <% } else { %>
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"><path d="M7.9 20A9 9 0 1 0 4 16.1L2 22Z"/></svg>
                                    <% } %>
                                </div>
                                <div class="ma-item-content">
                                    <div class="ma-item-meta"><span class="ma-type"><%=post ? "게시글" : "댓글"%></span><span class="ma-dot">·</span><span><%=section%></span></div>
                                    <strong class="ma-item-title"><%=title.isEmpty() ? "제목 없음" : title%></strong>
                                    <% if (!post && !content.isEmpty()) { %>
                                    <p class="ma-item-description"><%=content%></p>
                                    <% } %>
                                </div>
                                <div class="ma-item-end">
                                    <% if (!date.isEmpty()) { %><time><%=escapeHtml(date)%></time><% } %>
                                    <% if (!activityUrl.isEmpty()) { %><svg aria-hidden="true" width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><path d="m9 5 7 7-7 7"/></svg><% } %>
                                </div>
                            <% if (!activityUrl.isEmpty()) { %></a><% } else { %></div><% } %>
                        <% } %>
                        </div>

                        <div class="ma-more" id="maMore" <%=hasMore ? "" : "hidden"%>>
                            <button type="button" class="ma-more-button" id="maMoreButton" aria-controls="maList"
                                data-more-url="<%=ctx%>/settings/myActivity/more"
                                data-next-cursor="<%=escapeHtml(nextCursor)%>">더보기</button>
                        </div>

                        <div class="ma-empty" id="maEmpty" <%=activities.isEmpty() ? "" : "hidden"%>>
                            <div class="ma-empty-icon" aria-hidden="true">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><rect x="5" y="4" width="14" height="16" rx="2"/><path d="M9 9h6M9 13h6"/></svg>
                            </div>
                            <strong><%=activities.isEmpty() ? "아직 활동 내역이 없어요." : "해당 활동 내역이 없어요."%></strong>
                            <p><%=activities.isEmpty() ? "게시글이나 댓글을 작성하면 이곳에 표시돼요." : "다른 유형을 선택해 보세요."%></p>
                        </div>
                    </section>
                </div>
            </main>
        </div>
    </div>
    <jsp:include page="/common/footer.jsp" />
    <script>
(function () {
    "use strict";
    const list = document.getElementById("maList");
    const moreButton = document.getElementById("maMoreButton");
    if (!list || !moreButton) return;
    const moreWrap = document.getElementById("maMore");
    const empty = document.getElementById("maEmpty");
    const count = document.getElementById("maVisibleCount");
    const filters = Array.from(document.querySelectorAll("[data-ma-filter]"));
    let activeFilter = "ALL";
    let requestedFilter = "ALL";
    let requestVersion = 0;

    function escapeHtml(value) {
        return String(value == null ? "" : value).replace(/[&<>"']/g, function (ch) {
            return {"&":"&amp;", "<":"&lt;", ">":"&gt;", '"':"&quot;", "'":"&#39;"}[ch];
        });
    }
    function setFilter(filter) {
        filters.forEach(function (button) {
            const selected = button.dataset.maFilter === filter;
            button.classList.toggle("active", selected);
            button.setAttribute("aria-pressed", String(selected));
        });
    }
    function makeRow(item) {
        const post = item.activityGroup === "POST";
        const type = item.activityType;
        let section = "기타 활동";
        let path = "";
        const id = encodeURIComponent(String(item.targetId));
        if (type === "TIP_POST" || type === "TIP_COMMENT") {
            section = "여행 꿀팁"; path = "/tipDetail?tipId=" + id;
        } else if (type === "MATE_POST" || type === "MATE_COMMENT") {
            section = "여행 메이트"; path = "/mateDetail?mateId=" + id;
        } else if (type === "ITINERARY_COMMENT") {
            section = "여행 일정"; path = "/schedules/detail?id=" + id;
        }
        const row = document.createElement(path ? "a" : "div");
        row.className = "ma-item" + (path ? "" : " ma-item--static");
        if (path) row.href = list.dataset.contextPath + path;
        row.dataset.maItem = "";
        row.dataset.maGroup = item.activityGroup;
        row.dataset.maKey = type + ":" + item.activityId;
        const icon = post
            ? '<rect x="4" y="3.5" width="16" height="17" rx="2"/><path d="M8 8h8M8 12h8M8 16h5"/>'
            : '<path d="M7.9 20A9 9 0 1 0 4 16.1L2 22Z"/>';
        const arrow = '<svg aria-hidden="true" width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><path d="m9 5 7 7-7 7"/></svg>';
        const date = item.createdAt ? String(item.createdAt).slice(0, 10).replace(/-/g, ".") : "";
        row.innerHTML = '<div class="ma-item-icon" aria-hidden="true"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round">' + icon + '</svg></div>'
            + '<div class="ma-item-content"><div class="ma-item-meta"><span class="ma-type">' + (post ? "게시글" : "댓글") + '</span><span class="ma-dot">·</span><span>' + section + '</span></div>'
            + '<strong class="ma-item-title">' + escapeHtml(item.targetTitle || "제목 없음") + '</strong>'
            + (!post && item.content ? '<p class="ma-item-description">' + escapeHtml(item.content) + '</p>' : "") + '</div>'
            + '<div class="ma-item-end">' + (date ? '<time>' + escapeHtml(date) + '</time>' : "") + (path ? arrow : "") + '</div>';
        return row;
    }
    function showError(message) {
        if (window.showToast) window.showToast(message);
        else window.alert(message);
    }
    async function loadPage(filter, replace) {
        if (!replace && (moreButton.disabled || moreWrap.hidden)) return;
        const cursor = replace ? "" : moreButton.dataset.nextCursor;
        if (!replace && !cursor) return;
        const version = ++requestVersion;
        requestedFilter = filter;
        setFilter(filter);
        moreButton.disabled = true;
        moreButton.textContent = "불러오는 중…";
        list.setAttribute("aria-busy", "true");
        try {
            const params = new URLSearchParams({filter:filter, cursor:cursor});
            const response = await fetch(moreButton.dataset.moreUrl + "?" + params, {
                credentials:"same-origin", cache:"no-store", headers:{"Accept":"application/json"}
            });
            const data = await response.json();
            if (version !== requestVersion) return;
            if (!response.ok || data.success !== true) throw new Error(data.message || "활동 내역을 불러오지 못했습니다.");
            if (replace) list.replaceChildren();
            const existing = new Set(Array.from(list.querySelectorAll("[data-ma-item]"), function (row) { return row.dataset.maKey; }));
            (data.activities || []).forEach(function (item) {
                const key = item.activityType + ":" + item.activityId;
                if (!existing.has(key)) {
                    list.appendChild(makeRow(item));
                    existing.add(key);
                }
            });
            activeFilter = filter;
            const total = filter === "POST" ? data.postCount : filter === "COMMENT" ? data.commentCount : data.totalCount;
            count.textContent = total + "건";
            document.getElementById("maTotalCount").textContent = data.totalCount;
            document.getElementById("maPostCount").textContent = data.postCount;
            document.getElementById("maCommentCount").textContent = data.commentCount;
            empty.hidden = existing.size !== 0;
            empty.querySelector("strong").textContent = data.totalCount === 0 ? "아직 활동 내역이 없어요." : "해당 활동 내역이 없어요.";
            empty.querySelector("p").textContent = data.totalCount === 0 ? "게시글이나 댓글을 작성하면 이곳에 표시돼요." : "다른 유형을 선택해 보세요.";
            moreButton.dataset.nextCursor = data.nextCursor || "";
            moreWrap.hidden = data.hasMore !== true;
        } catch (error) {
            if (version !== requestVersion) return;
            requestedFilter = activeFilter;
            setFilter(activeFilter);
            console.error("활동 내역 더보기 실패:", error);
            showError(error.message || "활동 내역을 불러오지 못했습니다.");
        } finally {
            if (version === requestVersion) {
                moreButton.disabled = false;
                moreButton.textContent = "더보기";
                list.setAttribute("aria-busy", "false");
            }
        }
    }
    filters.forEach(function (button) {
        button.addEventListener("click", function () {
            if (button.dataset.maFilter !== requestedFilter) loadPage(button.dataset.maFilter, true);
        });
    });
    moreButton.addEventListener("click", function () { loadPage(activeFilter, false); });
})();
    </script>
</body>
</html>
