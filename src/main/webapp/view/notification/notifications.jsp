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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/view/assets/css/notification/notification.css">
    <jsp:include page="/common/headStyles.jsp" />
</head>
<body class="site-shell">

    <jsp:include page="/common/header.jsp" />

    <main class="max-w-4xl mx-auto px-6 py-10">
        <div class="flex items-end justify-between gap-4 mb-7">
            <div>
                <p class="text-xs font-black tracking-[.18em] text-[#6369D1]">
                    NOTIFICATIONS
                </p>
                <h1 class="text-3xl font-black mt-1">알림</h1>
                <p class="text-sm text-gray-500 mt-2">
                    댓글, 좋아요 등 내 활동과 관련된 소식을 확인합니다.
                </p>
            </div>

            <button
                type="button"
                class="px-4 py-2 rounded-xl border border-gray-200 text-sm font-bold text-gray-600"
                data-read-all
                data-read-all-url="${pageContext.request.contextPath}/notifications/read-all">
                모두 읽음
            </button>
        </div>

        <div
    		class="border border-gray-200 rounded-2xl overflow-hidden bg-white"
    		data-notification-list
    		data-context-path="${pageContext.request.contextPath}"
    		data-read-url="${pageContext.request.contextPath}/notifications/read"
    		data-more-url="${pageContext.request.contextPath}/notifications/more"
    		data-next-cursor="${nextCursor}"
    		data-has-more="${hasMore}">

            <div class="px-5 py-3 border-b bg-gray-50 text-xs font-bold text-gray-500">
                읽지 않은 알림
                <span data-unread-count>
                    <c:out value="${unreadCount}" />
                </span>개
            </div>

            <c:choose>
                <c:when test="${empty notifications}">
                    <p data-notification-empty
    					class="px-5 py-10 text-center text-sm text-gray-500">
    					읽지 않은 알림이 없습니다.
					</p>
                </c:when>

                <c:otherwise>
                    <c:forEach var="notification" items="${notifications}">
                        <a
                            data-notification-row
                            data-notification-id="${notification.notificationId}"
                            data-notification-url="${pageContext.request.contextPath}${notification.targetUrl}"
                            data-unread="true"
                            href="${pageContext.request.contextPath}${notification.targetUrl}"
                            class="w-full px-5 py-5 border-b flex gap-4 text-left hover:bg-gray-50 transition bg-[#FAFAFF]">

                            <span class="w-10 h-10 shrink-0 rounded-full flex items-center justify-center bg-[#F0F0FF] text-[#6369D1]">
                                <c:choose>
                                    <c:when test="${notification.notificationType eq 'COMMENT'}">
                                        💬
                                    </c:when>
                                    <c:when test="${notification.notificationType eq 'REPORT_RECEIVED'}">
                                        ⚑
                                    </c:when>
                                    <c:otherwise>
                                        ♥
                                    </c:otherwise>
                                </c:choose>
                            </span>

                            <span class="flex-1 min-w-0">
                                <span class="flex items-center gap-2">
                                    <strong class="text-sm">
                                        <c:out value="${notification.label}" />
                                    </strong>
                                    <span class="w-1.5 h-1.5 rounded-full bg-[#6369D1] unread-dot"></span>
                                </span>

                                <span class="block text-sm text-gray-600 mt-1">
                                    <c:out value="${notification.message}" />
                                </span>

                                <span class="block text-xs text-gray-400 mt-2">
                                    <fmt:formatDate
                                        value="${notification.createdAt}"
                                        pattern="yyyy.MM.dd HH:mm" />
                                </span>
                            </span>
                        </a>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </div>
        <div class="flex justify-center mt-6">
    		<button
        		type="button"
        		data-notification-more
        		class="px-6 py-2.5 rounded-xl border border-gray-200 text-sm font-bold text-gray-600"
        		style="${hasMore ? '' : 'display:none;'}">
        		더보기
    		</button>
		</div>
    </main>

    <jsp:include page="/common/footer.jsp" />

    <script
        src="${pageContext.request.contextPath}/view/assets/js/common/notifications.js?v=2"
        defer>
    </script>
</body>
</html>