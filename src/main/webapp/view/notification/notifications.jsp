<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
request.setAttribute("activePage", "notifications");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>알림 · Planb</title>
    <jsp:include page="/common/headStyles.jsp" />
    <style>
        .pb-notifications {
            --pb-accent: #6369d1;
            --pb-text: #232536;
            width: min(860px, calc(100% - 48px));
            margin: 0 auto;
            padding: 64px 0 88px;
            color: var(--pb-text);
        }
        .pb-notifications *, .pb-notifications *::before,
        .pb-notifications *::after { box-sizing: border-box; }
        .pb-notifications svg { display: block; }
        .pb-notifications-heading {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 24px;
            margin-bottom: 30px;
        }
        .pb-notifications-eyebrow {
            margin: 0 0 12px;
            color: var(--pb-accent);
            font-size: 11px;
            font-weight: 700;
            letter-spacing: 2px;
        }
        .pb-notifications h1 {
            margin: 0;
            font-size: 32px;
            font-weight: 750;
            line-height: 1.35;
            letter-spacing: -1.2px;
        }
        .pb-notifications-description {
            margin: 10px 0 0;
            color: #737687;
            font-size: 14px;
            line-height: 1.7;
            word-break: keep-all;
        }
        .pb-notifications-read-all {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            flex-shrink: 0;
            padding: 11px 16px;
            border: 1px solid #e1e3ec;
            border-radius: 12px;
            background: #fff;
            color: #55596d;
            font: inherit;
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            transition: background .18s, border-color .18s;
        }
        .pb-notifications-read-all:hover {
            background: #f7f7fe;
            border-color: #c8caed;
        }
        .pb-notifications-read-all:disabled { opacity: .5; cursor: default; }
        .pb-notifications-read-all:focus-visible,
        .pb-notification-row:focus-visible {
            outline: 3px solid #9c9fe7;
            outline-offset: 3px;
        }
        .pb-notifications-panel {
            background: #fff;
            border: 1px solid #e7e8f0;
            border-radius: 20px;
            box-shadow: 0 8px 32px rgba(35, 37, 54, .035);
        }
        .pb-notifications-toolbar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 16px;
            padding: 20px 26px;
            border-bottom: 1px solid #eef0f5;
        }
        .pb-notifications-toolbar-title {
            display: inline-flex;
            align-items: center;
            gap: 9px;
            font-size: 14px;
            font-weight: 650;
        }
        .pb-notifications-count {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-width: 27px;
            padding: 3px 8px;
            border-radius: 8px;
            background: #eeeefe;
            color: var(--pb-accent);
            font-size: 12px;
            line-height: 1.5;
        }
        .pb-notifications-toolbar-hint { color: #9295a4; font-size: 12px; }
        .pb-notification-row {
            display: flex;
            align-items: center;
            gap: 18px;
            padding: 25px 26px;
            text-decoration: none;
            color: inherit;
            border-bottom: 1px solid #f0f1f6;
            transition: background .18s;
        }
        .pb-notification-row:last-child { border-bottom: 0; border-radius: 0 0 20px 20px; }
        .pb-notification-row:hover { background: #fafaff; }
        .pb-notification-row.is-read { background: #f7f8fa; }
        .pb-notification-row.is-read:hover { background: #f0f1f5; }
        .pb-notification-row.is-read .pb-notification-icon { background: #eaecef; color: #9196a3; }
        .pb-notification-row.is-read .pb-notification-title strong { color: #777d8c; font-weight: 500; }
        .pb-notification-row.is-read .pb-notification-message { color: #818796; }
        .pb-notification-row.is-read .pb-notification-dot { display: none; }
        .pb-notification-read-label { display: none; color: #7b8190; font-size: 11px; font-weight: 500; }
        .pb-notification-row.is-read .pb-notification-read-label { display: inline; }
        .pb-notification-icon {
            display: flex;
            align-items: center;
            justify-content: center;
            flex: 0 0 46px;
            height: 46px;
            border-radius: 15px;
            background: #f0f0fd;
            color: #7276d4;
        }
        .pb-notification-icon.is-like { background: #fff0f4; color: #d77897; }
        .pb-notification-icon.is-report { background: #fff6e9; color: #b98a45; }
        .pb-notification-copy { flex: 1; min-width: 0; }
        .pb-notification-title {
            display: flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 6px;
        }
        .pb-notification-title strong { font-size: 14px; font-weight: 650; line-height: 1.5; }
        .pb-notification-dot {
            flex: 0 0 5px;
            width: 5px;
            height: 5px;
            border-radius: 50%;
            background: var(--pb-accent);
        }
        .pb-notification-message {
            display: block;
            color: #696d80;
            font-size: 14px;
            line-height: 1.7;
            overflow-wrap: anywhere;
        }
        .pb-notification-time {
            display: block;
            margin-top: 9px;
            color: #8c90a1;
            font-size: 12px;
            line-height: 1.5;
            font-variant-numeric: tabular-nums;
        }
        .pb-notification-arrow { flex-shrink: 0; color: #bdc0ce; }
        .pb-notifications [data-notification-empty] {
            margin: 0;
            padding: 65px 24px 70px;
            color: #737687;
            text-align: center;
            font-size: 14px;
            line-height: 1.8;
        }
        .pb-notifications [data-notification-empty]::before {
            content: "✓";
            display: flex;
            align-items: center;
            justify-content: center;
            width: 56px;
            height: 56px;
            margin: 0 auto 18px;
            border-radius: 18px;
            background: #f0f0fd;
            color: var(--pb-accent);
            font-size: 24px;
        }
        .pb-notifications [data-notification-empty]::after {
            content: "새로운 소식이 도착하면 이곳에서 확인할 수 있어요.";
            display: block;
            margin-top: 6px;
            color: #9295a4;
            font-size: 12px;
        }
        .pb-notifications-note {
            margin: 18px 4px 0;
            color: #9295a4;
            font-size: 12px;
            line-height: 1.7;
        }
        @media (prefers-reduced-motion: reduce) {
            .pb-notification-row, .pb-notifications-read-all { transition: none; }
        }
        @media (max-width: 600px) {
            .pb-notifications { width: calc(100% - 32px); padding: 36px 0 56px; }
            .pb-notifications-heading { align-items: flex-start; flex-direction: column; gap: 18px; margin-bottom: 22px; }
            .pb-notifications h1 { font-size: 28px; }
            .pb-notifications-description { font-size: 13px; }
            .pb-notifications-toolbar { padding: 18px; }
            .pb-notifications-toolbar-hint { display: none; }
            .pb-notification-row { align-items: flex-start; padding: 22px 18px; gap: 13px; }
            .pb-notification-icon { flex-basis: 40px; height: 40px; border-radius: 13px; }
            .pb-notification-message { font-size: 13px; }
            .pb-notification-arrow { margin-top: 11px; width: 15px; }
        }
    </style>
</head>
<body class="site-shell">
    <jsp:include page="/common/header.jsp" />
    <main class="pb-notifications">
        <div class="pb-notifications-heading">
            <div>
                <p class="pb-notifications-eyebrow">NOTIFICATIONS</p>
                <h1>알림</h1>
                <p class="pb-notifications-description">내 여행 이야기에 도착한 새로운 소식을 확인해 보세요.</p>
            </div>
            <button type="button" class="pb-notifications-read-all"
                data-read-all
                data-read-all-url="${pageContext.request.contextPath}/notifications/read-all">
                <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m4 12 4 4L18 6M13 16l7-7"/></svg>
                모두 읽음
            </button>
        </div>
        <div class="pb-notifications-panel" data-notification-list
            data-read-url="${pageContext.request.contextPath}/notifications/read">
            <div class="pb-notifications-toolbar">
                <span class="pb-notifications-toolbar-title">
                    새 알림
                    <span class="pb-notifications-count" data-unread-count aria-live="polite"><c:out value="${unreadCount}" default="0" /></span>
                </span>
                <span class="pb-notifications-toolbar-hint">최근 알림 최대 100개</span>
            </div>
            <c:choose>
                <c:when test="${empty notifications}">
                    <p data-notification-empty>아직 도착한 알림이 없습니다.</p>
                </c:when>
                <c:otherwise>
                    <c:forEach var="notification" items="${notifications}">
                        <a class="pb-notification-row${notification.read ? ' is-read' : ''}" data-notification-row
                            data-notification-id="${notification.notificationId}"
                            data-notification-url="${pageContext.request.contextPath}${notification.targetUrl}"
                            data-unread="${not notification.read}"
                            href="${pageContext.request.contextPath}${notification.targetUrl}">
                            <c:choose>
                                <c:when test="${notification.notificationType eq 'COMMENT'}">
                                    <span class="pb-notification-icon" aria-hidden="true">
                                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><path d="M20 11.5a8 8 0 0 1-8 8H5l-3 2v-10a9 9 0 0 1 18 0Z"/><path d="M7 9h8M7 13h5"/></svg>
                                    </span>
                                </c:when>
                                <c:when test="${notification.notificationType eq 'REPORT_RECEIVED'}">
                                    <span class="pb-notification-icon is-report" aria-hidden="true">
                                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><path d="M5 21V3h14l-3 5 3 5H5"/></svg>
                                    </span>
                                </c:when>
                                <c:otherwise>
                                    <span class="pb-notification-icon is-like" aria-hidden="true">
                                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><path d="M20.8 4.6a5.5 5.5 0 0 0-7.8 0L12 5.7l-1.1-1.1a5.5 5.5 0 0 0-7.8 7.8L12 21l8.8-8.6a5.5 5.5 0 0 0 0-7.8Z"/></svg>
                                    </span>
                                </c:otherwise>
                            </c:choose>
                            <span class="pb-notification-copy">
                                <span class="pb-notification-title">
                                    <strong><c:out value="${notification.label}" /></strong>
                                    <span class="pb-notification-dot unread-dot" aria-hidden="true"></span>
                                    <span class="pb-notification-read-label">읽음</span>
                                </span>
                                <span class="pb-notification-message"><c:out value="${notification.message}" /></span>
                                <span class="pb-notification-time"><fmt:formatDate value="${notification.createdAt}" pattern="yyyy.MM.dd HH:mm" /></span>
                            </span>
                            <svg class="pb-notification-arrow" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m9 5 7 7-7 7"/></svg>
                        </a>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </div>
        <p class="pb-notifications-note">최근 알림을 최대 100개까지 보여드려요. 읽은 알림도 목록에 남습니다.</p>
    </main>
    <jsp:include page="/common/footer.jsp" />
    <script src="${pageContext.request.contextPath}/view/assets/js/common/notifications.js?v=2" defer></script>
</body>
</html>
