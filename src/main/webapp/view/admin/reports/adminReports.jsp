<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"
    import="java.util.List"
    import="java.text.SimpleDateFormat"
    import="dto.report.ReportDto" %>

<%!
private String escapeHtml(String value) {
    if (value == null) {
        return "";
    }

    return value
            .replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace("\"", "&quot;")
            .replace("'", "&#39;");
}
%>

<%
request.setAttribute("activePage", "reports");

String ctx = request.getContextPath();

@SuppressWarnings("unchecked")
List<ReportDto> reports =
        (List<ReportDto>) request.getAttribute("reports");

if (reports == null) {
    reports = new java.util.ArrayList<ReportDto>();
}

String currentTab =
        (String) request.getAttribute("currentTab");

if (currentTab == null || currentTab.trim().isEmpty()) {
    currentTab = "PENDING";
}

Integer pendingCount =
        (Integer) request.getAttribute("pendingCount");

Integer deletedCount =
        (Integer) request.getAttribute("deletedCount");

Integer rejectedCount =
        (Integer) request.getAttribute("rejectedCount");

Integer totalCount =
        (Integer) request.getAttribute("totalCount");

if (pendingCount == null) {
    pendingCount = 0;
}

if (deletedCount == null) {
    deletedCount = 0;
}

if (rejectedCount == null) {
    rejectedCount = 0;
}

if (totalCount == null) {
    totalCount = 0;
}

SimpleDateFormat dateFormat =
        new SimpleDateFormat("yyyy.MM.dd HH:mm");

String result =
        request.getParameter("result");
%>

<!DOCTYPE html>

<html lang="ko">

<head>

<meta charset="UTF-8">

<meta
    name="viewport"
    content="width=device-width, initial-scale=1">

<title>신고 관리 | Tripily</title>

<jsp:include
    page="/common/headStyles.jsp" />

<link
    rel="stylesheet"
    href="<%=ctx%>/view/assets/css/admin/adminReports.css?v=1">

</head>

<body class="site-shell">

<jsp:include
    page="/common/header.jsp" />


<main class="admin-reports-page">


    <!-- =====================================================
         상단
    ====================================================== -->

    <section class="admin-reports-head">

        <div>

            <span class="admin-reports-eyebrow">
                ADMIN · REPORTS
            </span>

            <h1>
                신고 관리
            </h1>

            <p>
                접수된 신고 내용을 검토하고
                문제 없음, 콘텐츠 삭제, 계정 정지 등의 조치를 처리합니다.
            </p>

        </div>


        <div class="admin-reports-head-summary">

            <span>
                처리 대기
            </span>

            <strong>
                <%=pendingCount%>
            </strong>

        </div>

    </section>


    <!-- =====================================================
         처리 결과 메시지
    ====================================================== -->

    <%
    if ("success".equals(result)) {
    %>

    <div class="admin-reports-result success">

        <span class="admin-reports-result-icon">

            <svg viewBox="0 0 24 24" aria-hidden="true">
                <path d="m5 12 4 4L19 6" />
            </svg>

        </span>

        <div>
            <strong>처리가 완료되었습니다.</strong>
            <span>신고 상태가 정상적으로 변경되었습니다.</span>
        </div>

    </div>

    <%
    } else if ("fail".equals(result)) {
    %>

    <div class="admin-reports-result error">

        <span class="admin-reports-result-icon">

            <svg viewBox="0 0 24 24" aria-hidden="true">
                <circle cx="12" cy="12" r="8" />
                <path d="M12 8v5M12 16.5h.01" />
            </svg>

        </span>

        <div>
            <strong>신고 처리에 실패했습니다.</strong>
            <span>잠시 후 다시 시도해 주세요.</span>
        </div>

    </div>

    <%
    }
    %>


    <!-- =====================================================
         요약 카드
    ====================================================== -->

    <section class="admin-reports-summary-grid">


        <a
            href="<%=ctx%>/admin/reports?tab=PENDING"
            class="admin-reports-summary-card <%="PENDING".equals(currentTab) ? "selected" : ""%>">

            <span class="admin-reports-summary-icon purple">

                <svg viewBox="0 0 24 24" aria-hidden="true">
                    <circle cx="12" cy="12" r="8" />
                    <path d="M12 7v5l3 2" />
                </svg>

            </span>

            <div>
                <span>처리 대기</span>
                <strong><%=pendingCount%></strong>
            </div>

        </a>


        <a
            href="<%=ctx%>/admin/reports?tab=DELETED"
            class="admin-reports-summary-card <%="DELETED".equals(currentTab) ? "selected" : ""%>">

            <span class="admin-reports-summary-icon red">

                <svg viewBox="0 0 24 24" aria-hidden="true">
                    <path d="M4 7h16" />
                    <path d="M9 7V4h6v3" />
                    <path d="M7 7l1 13h8l1-13" />
                </svg>

            </span>

            <div>
                <span>삭제 처리</span>
                <strong><%=deletedCount%></strong>
            </div>

        </a>


        <a
            href="<%=ctx%>/admin/reports?tab=REJECTED"
            class="admin-reports-summary-card <%="REJECTED".equals(currentTab) ? "selected" : ""%>">

            <span class="admin-reports-summary-icon green">

                <svg viewBox="0 0 24 24" aria-hidden="true">
                    <path d="m5 12 4 4L19 6" />
                </svg>

            </span>

            <div>
                <span>문제 없음</span>
                <strong><%=rejectedCount%></strong>
            </div>

        </a>


        <a
            href="<%=ctx%>/admin/reports?tab=ALL"
            class="admin-reports-summary-card <%="ALL".equals(currentTab) ? "selected" : ""%>">

            <span class="admin-reports-summary-icon gray">

                <svg viewBox="0 0 24 24" aria-hidden="true">
                    <path d="M6 5h12M6 12h12M6 19h12" />
                </svg>

            </span>

            <div>
                <span>전체 신고</span>
                <strong><%=totalCount%></strong>
            </div>

        </a>


    </section>


    <!-- =====================================================
         상태 탭
    ====================================================== -->

    <section class="admin-reports-toolbar">

        <nav
            class="admin-reports-tabs"
            aria-label="신고 상태">

            <a
                class="<%="PENDING".equals(currentTab) ? "active" : ""%>"
                href="<%=ctx%>/admin/reports?tab=PENDING">

                처리 대기
                <span><%=pendingCount%></span>

            </a>

            <a
                class="<%="DELETED".equals(currentTab) ? "active" : ""%>"
                href="<%=ctx%>/admin/reports?tab=DELETED">

                삭제 처리
                <span><%=deletedCount%></span>

            </a>

            <a
                class="<%="REJECTED".equals(currentTab) ? "active" : ""%>"
                href="<%=ctx%>/admin/reports?tab=REJECTED">

                문제 없음
                <span><%=rejectedCount%></span>

            </a>

            <a
                class="<%="ALL".equals(currentTab) ? "active" : ""%>"
                href="<%=ctx%>/admin/reports?tab=ALL">

                전체
                <span><%=totalCount%></span>

            </a>

        </nav>


        <div class="admin-reports-toolbar-note">

            <svg viewBox="0 0 24 24" aria-hidden="true">
                <circle cx="12" cy="12" r="8" />
                <path d="M12 10v6M12 7h.01" />
            </svg>

            처리 대기 신고만 조치할 수 있습니다.

        </div>

    </section>


    <!-- =====================================================
         신고 목록
    ====================================================== -->

    <section class="admin-reports-list">


        <%
        if (!reports.isEmpty()) {

            for (ReportDto report : reports) {

                String targetType =
                        report.getTargetType();

                String typeName =
                        "신고";

                String typeClass =
                        "default";

                String viewButtonText =
                        "게시글 보기";

                String targetUrl =
                        "#";


                /* =============================================
                   대상별 링크
                ============================================= */

                if ("ITINERARY".equals(targetType)) {

                    typeName = "여행일정";
                    typeClass = "itinerary";

                    targetUrl =
                            ctx
                            + "/schedules/detail?id="
                            + report.getViewTargetId();

                } else if ("TIP".equals(targetType)) {

                    typeName = "여행꿀팁";
                    typeClass = "tip";

                    targetUrl =
                            ctx
                            + "/tipDetail?tipId="
                            + report.getViewTargetId();

                } else if ("MATE".equals(targetType)) {

                    typeName = "여행메이트";
                    typeClass = "mate";

                    targetUrl =
                            ctx
                            + "/mateDetail?mateId="
                            + report.getViewTargetId();

                } else if ("TIP_COMMENT".equals(targetType)) {

                    typeName = "여행꿀팁 댓글";
                    typeClass = "comment";

                    viewButtonText =
                            "원글 보기";

                    targetUrl =
                            ctx
                            + "/tipDetail?tipId="
                            + report.getViewTargetId();

                } else if ("MATE_COMMENT".equals(targetType)) {

                    typeName = "여행메이트 댓글";
                    typeClass = "comment";

                    viewButtonText =
                            "원글 보기";

                    targetUrl =
                            ctx
                            + "/mateDetail?mateId="
                            + report.getViewTargetId();

                } else if ("ITINERARY_COMMENT".equals(targetType)) {

                    typeName = "일정 댓글";
                    typeClass = "comment";

                    viewButtonText =
                            "원글 보기";

                    targetUrl =
                            ctx
                            + "/schedules/detail?id="
                            + report.getViewTargetId();

                } else if ("USER".equals(targetType)) {

                    typeName = "사용자 프로필";
                    typeClass = "user";

                    viewButtonText =
                            "프로필 보기";

                    targetUrl =
                            ctx
                            + "/profile/userProfile?userId="
                            + report.getViewTargetId();

                } else if ("POST".equals(targetType)) {

                    typeName = "게시글";
                    typeClass = "post";

                    targetUrl = "#";

                } else if ("COMMENT".equals(targetType)) {

                    typeName = "댓글";
                    typeClass = "comment";

                    viewButtonText =
                            "원글 보기";

                    targetUrl = "#";
                }


                /* =============================================
                   상태
                ============================================= */

                String statusName =
                        "처리 완료";

                String statusClass =
                        "done";


                if ("PENDING".equals(report.getStatus())) {

                    statusName =
                            "처리 대기";

                    statusClass =
                            "pending";

                } else if ("REJECTED".equals(report.getStatus())) {

                    statusName =
                            "문제 없음";

                    statusClass =
                            "rejected";

                } else if (
                    "CONTENT_DELETE".equals(
                            report.getActionType()
                    )
                ) {

                    statusName =
                            "삭제 처리";

                    statusClass =
                            "deleted";

                } else if (
                    "USER_SUSPEND".equals(
                            report.getActionType()
                    )
                ) {

                    statusName =
                            "계정 정지";

                    statusClass =
                            "suspended";
                }


                /* =============================================
                   신고 대상 회원
                ============================================= */

                String targetUser =
                        report.getTargetNickname();

                if (
                    targetUser == null
                    ||
                    targetUser.trim().isEmpty()
                ) {

                    targetUser =
                            report.getTargetLoginId();
                }

                if (
                    targetUser == null
                    ||
                    targetUser.trim().isEmpty()
                ) {

                    targetUser =
                            "알 수 없음";
                }


                /* =============================================
                   신고자
                ============================================= */

                String reporter =
                        report.getReporterLoginId();

                if (
                    reporter == null
                    ||
                    reporter.trim().isEmpty()
                ) {

                    reporter =
                            "탈퇴 회원";
                }


                /* =============================================
                   제목
                ============================================= */

                String targetTitle =
                        report.getTargetTitle();

                if (
                    targetTitle == null
                    ||
                    targetTitle.trim().isEmpty()
                ) {

                    targetTitle =
                            "신고 대상";
                }


                String createdAtText =
                        "";

                if (report.getCreatedAt() != null) {

                    createdAtText =
                            dateFormat.format(
                                    report.getCreatedAt()
                            );
                }
        %>


        <article class="admin-report-card">


            <!-- =================================================
                 왼쪽 타입 영역
            ================================================== -->

            <div class="admin-report-type-panel <%=typeClass%>">

                <span class="admin-report-type-icon">

                    <svg viewBox="0 0 24 24" aria-hidden="true">

                        <path d="M5 21V4" />
                        <path d="M5 4h11l-2 3 2 3H5" />

                    </svg>

                </span>

                <span class="admin-report-type-name">
                    <%=escapeHtml(typeName)%>
                </span>

                <span class="admin-report-id">
                    REPORT #<%=report.getReportId()%>
                </span>

            </div>


            <!-- =================================================
                 본문
            ================================================== -->

            <div class="admin-report-body">


                <div class="admin-report-title-row">


                    <div class="admin-report-title-copy">


                        <div class="admin-report-meta-top">

                            <span class="admin-report-status <%=statusClass%>">
                                <%=escapeHtml(statusName)%>
                            </span>

                            <%
                            if (!createdAtText.isEmpty()) {
                            %>

                            <span class="admin-report-created">
                                <%=escapeHtml(createdAtText)%>
                            </span>

                            <%
                            }
                            %>

                        </div>


                        <h2>
                            <%=escapeHtml(targetTitle)%>
                        </h2>


                    </div>


                    <%
                    if (!"#".equals(targetUrl)) {
                    %>

                    <a
                        href="<%=targetUrl%>"
                        class="admin-report-detail-link">

                        <%=escapeHtml(viewButtonText)%>

                        <svg viewBox="0 0 24 24" aria-hidden="true">
                            <path d="m9 18 6-6-6-6" />
                        </svg>

                    </a>

                    <%
                    }
                    %>


                </div>


                <!-- =================================================
                     핵심 정보
                ================================================== -->

                <div class="admin-report-info-grid">


                    <div>

                        <span>
                            신고 사유
                        </span>

                        <strong>
                            <%=escapeHtml(report.getReasonName())%>
                        </strong>

                    </div>


                    <div>

                        <span>
                            신고 대상
                        </span>

                        <strong>
                            <%=escapeHtml(targetUser)%>
                        </strong>

                    </div>


                    <div>

                        <span>
                            신고자
                        </span>

                        <strong>
                            <%=escapeHtml(reporter)%>
                        </strong>

                    </div>


                </div>


                <!-- =================================================
                     상세 내용
                ================================================== -->

                <%
                if (
                    report.getDetail() != null
                    &&
                    !report.getDetail().trim().isEmpty()
                ) {
                %>

                <div class="admin-report-detail-box">

                    <span>
                        상세 내용
                    </span>

                    <p>
                        <%=escapeHtml(report.getDetail())%>
                    </p>

                </div>

                <%
                } else {
                %>

                <div class="admin-report-detail-box empty">

                    <span>
                        상세 내용
                    </span>

                    <p>
                        별도로 작성된 상세 내용이 없습니다.
                    </p>

                </div>

                <%
                }
                %>


                <!-- =================================================
                     하단 / 액션
                ================================================== -->

                <div class="admin-report-footer">


                    <span class="admin-report-footer-note">

                        <svg viewBox="0 0 24 24" aria-hidden="true">
                            <circle cx="12" cy="12" r="8" />
                            <path d="M12 10v6M12 7h.01" />
                        </svg>

                        신고 내용을 확인한 뒤 조치를 선택해 주세요.

                    </span>


                    <div class="admin-report-actions">


                        <%
                        if ("PENDING".equals(report.getStatus())) {
                        %>


                        <!-- 문제 없음 -->

                        <form
                            action="<%=ctx%>/admin/reports/process"
                            method="post"
                            onsubmit="return confirm('이 신고를 문제 없음으로 처리하시겠습니까?');">

                            <input
                                type="hidden"
                                name="reportId"
                                value="<%=report.getReportId()%>">

                            <input
                                type="hidden"
                                name="action"
                                value="REJECT">

                            <button
                                type="submit"
                                class="admin-report-outline-action">

                                문제 없음

                            </button>

                        </form>


                        <%
                        if ("USER".equals(targetType)) {
                        %>


                        <!-- 계정 정지 -->

                        <form
                            action="<%=ctx%>/admin/reports/process"
                            method="post"
                            onsubmit="return confirm('이 회원의 계정을 정지하시겠습니까?');">

                            <input
                                type="hidden"
                                name="reportId"
                                value="<%=report.getReportId()%>">

                            <input
                                type="hidden"
                                name="action"
                                value="SUSPEND">

                            <button
                                type="submit"
                                class="admin-report-danger-action">

                                계정 정지

                            </button>

                        </form>


                        <%
                        } else if (
                            !"POST".equals(targetType)
                            &&
                            !"COMMENT".equals(targetType)
                        ) {
                        %>


                        <!-- 콘텐츠 삭제 -->

                        <form
                            action="<%=ctx%>/admin/reports/process"
                            method="post"
                            onsubmit="return confirm('신고된 콘텐츠를 삭제하시겠습니까?');">

                            <input
                                type="hidden"
                                name="reportId"
                                value="<%=report.getReportId()%>">

                            <input
                                type="hidden"
                                name="action"
                                value="DELETE">

                            <button
                                type="submit"
                                class="admin-report-danger-action">

                                <%=
                                    targetType != null
                                    &&
                                    targetType.contains("COMMENT")
                                    ? "댓글 삭제"
                                    : "삭제 조치"
                                %>

                            </button>

                        </form>


                        <%
                        }
                        %>


                        <%
                        } else {
                        %>

                        <span class="admin-report-completed-label">
                            처리 완료
                        </span>

                        <%
                        }
                        %>


                    </div>


                </div>


            </div>


        </article>


        <%
            }

        } else {
        %>


        <div class="admin-reports-empty">

            <span class="admin-reports-empty-icon">

                <svg viewBox="0 0 24 24" aria-hidden="true">
                    <path d="M5 21V4" />
                    <path d="M5 4h11l-2 3 2 3H5" />
                </svg>

            </span>

            <strong>
                해당 상태의 신고 내역이 없습니다.
            </strong>

            <p>
                새로운 신고가 접수되면 이곳에 표시됩니다.
            </p>

        </div>


        <%
        }
        %>


    </section>


</main>


<jsp:include
    page="/common/footer.jsp" />


</body>

</html>
