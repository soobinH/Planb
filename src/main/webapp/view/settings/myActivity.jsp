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
int postCount = 0;
int commentCount = 0;
for (ProfileActivityDto a : activities) {
    if ("POST".equals(a.getActivityGroup())) postCount++;
    else if ("COMMENT".equals(a.getActivityGroup())) commentCount++;
}
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>내 활동 내역 · Planb</title>
    <jsp:include page="/common/headStyles.jsp" />
    <link rel="stylesheet" href="<%=ctx%>/view/assets/css/setting/settings.css">
    <link rel="stylesheet" href="<%=ctx%>/view/assets/css/setting/myActivity.css?v=1">
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
                        <div class="ma-summary-item"><span>전체 활동</span><strong><%=activities.size()%></strong></div>
                        <div class="ma-summary-item"><span>작성한 글</span><strong><%=postCount%></strong></div>
                        <div class="ma-summary-item"><span>작성한 댓글</span><strong><%=commentCount%></strong></div>
                    </section>

                    <section class="ma-section" aria-label="활동 내역 목록">
                        <div class="ma-section-head">
                            <div class="ma-section-title">활동 목록 <span id="maVisibleCount"><%=activities.size()%>건</span></div>
                            <div class="ma-filters" role="group" aria-label="활동 유형 필터">
                                <button type="button" class="active" data-ma-filter="ALL" aria-pressed="true">전체</button>
                                <button type="button" data-ma-filter="POST" aria-pressed="false">게시글</button>
                                <button type="button" data-ma-filter="COMMENT" aria-pressed="false">댓글</button>
                            </div>
                        </div>

                        <div class="ma-list" id="maList">
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
                            <a class="ma-item" href="<%=activityUrl%>" data-ma-item data-ma-group="<%=escapeHtml(group)%>">
                            <% } else { %>
                            <div class="ma-item ma-item--static" data-ma-item data-ma-group="<%=escapeHtml(group)%>">
                            <% } %>
                                <div class="ma-item-icon" aria-hidden="true">
                                    <% if (post) { %>
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"><rect x="4" y="3.5" width="16" height="17" rx="2"/><path d="M8 8h8M8 12h8M8 16h5"/></svg>
                                    <% } else { %>
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"><path d="M20 11.5a7.5 7.5 0 0 1-7.5 7.5H8l-4 2v-6a7.5 7.5 0 1 1 16-3.5Z"/><path d="M8 11h8M8 14h5"/></svg>
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
        document.addEventListener('DOMContentLoaded', function () {
            const buttons = document.querySelectorAll('[data-ma-filter]');
            const items = Array.from(document.querySelectorAll('[data-ma-item]'));
            const empty = document.getElementById('maEmpty');
            const count = document.getElementById('maVisibleCount');
            const emptyTitle = empty.querySelector('strong');
            const emptyText = empty.querySelector('p');
            buttons.forEach(function (button) {
                button.addEventListener('click', function () {
                    const filter = button.getAttribute('data-ma-filter');
                    buttons.forEach(function (item) {
                        const selected = item === button;
                        item.classList.toggle('active', selected);
                        item.setAttribute('aria-pressed', String(selected));
                    });
                    let visible = 0;
                    items.forEach(function (item) {
                        const show = filter === 'ALL' || item.getAttribute('data-ma-group') === filter;
                        item.hidden = !show;
                        if (show) visible++;
                    });
                    count.textContent = visible + '건';
                    empty.hidden = visible !== 0;
                    emptyTitle.textContent = items.length === 0 ? '아직 활동 내역이 없어요.' : '해당 활동 내역이 없어요.';
                    emptyText.textContent = items.length === 0 ? '게시글이나 댓글을 작성하면 이곳에 표시돼요.' : '다른 유형을 선택해 보세요.';
                });
            });
        });
    </script>
</body>
</html>
