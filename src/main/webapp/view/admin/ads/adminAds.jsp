<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"
    import="java.util.List"
    import="java.util.ArrayList"
    import="java.util.Map"
    import="java.text.SimpleDateFormat"
    import="dto.member.UserDto" %>

<%!
private String h(Object value) {

    if (value == null) {
        return "";
    }

    return String.valueOf(value)
            .replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace("\"", "&quot;")
            .replace("'", "&#39;");
}


private String value(Map<String, Object> ad, String key) {

    if (ad == null || ad.get(key) == null) {
        return "";
    }

    return String.valueOf(ad.get(key));
}


private long longValue(Map<String, Object> ad, String key) {

    if (ad == null || ad.get(key) == null) {
        return 0L;
    }

    Object raw = ad.get(key);

    if (raw instanceof Number) {
        return ((Number) raw).longValue();
    }

    try {
        return Long.parseLong(String.valueOf(raw));
    } catch (Exception e) {
        return 0L;
    }
}


private String positionLabel(String position) {

    if ("TRIP_CARD".equals(position)) {
        return "홈 슬라이딩 카드";
    }

    if ("TIP_SIDE".equals(position)) {
        return "여행 꿀팁 사이드";
    }

    if ("MATE_SIDE".equals(position)) {
        return "여행 메이트 사이드";
    }

    if ("MAIN_BANNER".equals(position)) {
        return "기존 메인 배너";
    }

    return position == null || position.trim().isEmpty()
            ? "광고 위치 미지정"
            : position;
}


private String statusLabel(String status) {

    if ("PENDING_APPROVAL".equals(status)) {
        return "승인 대기";
    }

    if ("PENDING_PUBLICATION".equals(status)) {
        return "게시 대기";
    }

    if ("ACTIVE".equals(status)) {
        return "게시 중";
    }

    if ("REJECTED".equals(status)) {
        return "거절";
    }

    if ("WITHDRAWN".equals(status)) {
        return "게시 철회";
    }

    if ("DELETED".equals(status)) {
        return "삭제";
    }

    if ("EXPIRED".equals(status)) {
        return "종료";
    }

    return status == null || status.trim().isEmpty()
            ? "상태 없음"
            : status;
}


private String statusClass(String status) {

    if ("PENDING_APPROVAL".equals(status)) {
        return "pending";
    }

    if ("PENDING_PUBLICATION".equals(status)) {
        return "publication";
    }

    if ("ACTIVE".equals(status)) {
        return "active";
    }

    if ("REJECTED".equals(status)) {
        return "rejected";
    }

    if ("WITHDRAWN".equals(status)) {
        return "withdrawn";
    }

    if ("DELETED".equals(status)) {
        return "deleted";
    }

    if ("EXPIRED".equals(status)) {
        return "expired";
    }

    return "default";
}


private boolean isClosedStatus(String status) {

    return "REJECTED".equals(status)
            || "WITHDRAWN".equals(status)
            || "DELETED".equals(status)
            || "EXPIRED".equals(status);
}


private String imageSrc(String ctx, String imageUrl) {

    if (imageUrl == null || imageUrl.trim().isEmpty()) {
        return "";
    }

    String url = imageUrl.trim();

    if (url.startsWith("http://")
            || url.startsWith("https://")
            || url.startsWith("data:")) {

        return url;
    }

    if (url.startsWith("/")) {
        return ctx + url;
    }

    return ctx + "/" + url;
}
%>

<%
request.setAttribute("activePage", "ads");

String ctx =
        request.getContextPath();


/* =========================================================
   관리자 권한 검사
========================================================= */

UserDto loginUser =
        (UserDto)
        session.getAttribute("user");


if (loginUser == null) {

    response.sendRedirect(
            ctx + "/auth/login"
    );

    return;
}


if (
    loginUser.getRole() == null
    ||
    !"ADMIN".equalsIgnoreCase(
            loginUser.getRole()
    )
) {

    response.sendError(
            HttpServletResponse.SC_FORBIDDEN
    );

    return;
}


/* =========================================================
   광고 목록
   추후 관리자 광고 Servlet에서
   request.setAttribute("ads", 광고목록)
   형태로 전달하면 바로 출력됨.
========================================================= */

@SuppressWarnings("unchecked")
List<Map<String, Object>> allAds =
        (List<Map<String, Object>>)
        request.getAttribute("ads");


if (allAds == null) {

    allAds =
            new ArrayList<Map<String, Object>>();
}


/* =========================================================
   상태별 개수
========================================================= */

int approvalCount = 0;
int publicationCount = 0;
int activeCount = 0;
int closedCount = 0;


for (Map<String, Object> ad : allAds) {

    String status =
            value(ad, "status");


    if ("PENDING_APPROVAL".equals(status)) {

        approvalCount++;

    } else if ("PENDING_PUBLICATION".equals(status)) {

        publicationCount++;

    } else if ("ACTIVE".equals(status)) {

        activeCount++;

    } else if (isClosedStatus(status)) {

        closedCount++;
    }
}


/* =========================================================
   현재 탭
========================================================= */

String currentTab =
        request.getParameter("tab");


if (
    currentTab == null
    ||
    currentTab.trim().isEmpty()
) {

    currentTab =
            "PENDING_APPROVAL";
}


if (
    !"PENDING_APPROVAL".equals(currentTab)
    &&
    !"PENDING_PUBLICATION".equals(currentTab)
    &&
    !"ACTIVE".equals(currentTab)
    &&
    !"CLOSED".equals(currentTab)
    &&
    !"ALL".equals(currentTab)
) {

    currentTab =
            "PENDING_APPROVAL";
}


/* =========================================================
   검색어
========================================================= */

String searchKeyword =
        request.getParameter("q");


if (searchKeyword == null) {
    searchKeyword = "";
}


String normalizedSearch =
        searchKeyword
            .trim()
            .toLowerCase();


/* =========================================================
   화면에 출력할 목록
========================================================= */

List<Map<String, Object>> visibleAds =
        new ArrayList<Map<String, Object>>();


for (Map<String, Object> ad : allAds) {

    String status =
            value(ad, "status");


    boolean tabMatch = false;


    if ("ALL".equals(currentTab)) {

        tabMatch = true;

    } else if ("CLOSED".equals(currentTab)) {

        tabMatch =
                isClosedStatus(status);

    } else {

        tabMatch =
                currentTab.equals(status);
    }


    if (!tabMatch) {
        continue;
    }


    if (!normalizedSearch.isEmpty()) {

        String target =
                (
                    value(ad, "businessName")
                    + " "
                    + value(ad, "managerName")
                    + " "
                    + value(ad, "contactEmail")
                    + " "
                    + value(ad, "contactPhone")
                    + " "
                    + value(ad, "adPosition")
                ).toLowerCase();


        if (!target.contains(normalizedSearch)) {
            continue;
        }
    }


    visibleAds.add(ad);
}
%>

<!DOCTYPE html>

<html lang="ko">

<head>

<meta charset="UTF-8">

<meta
    name="viewport"
    content="width=device-width, initial-scale=1">

<title>광고 관리 | Tripily</title>


<jsp:include
    page="/common/headStyles.jsp" />


<link
    rel="stylesheet"
    href="<%=ctx%>/view/assets/css/admin/adminAds.css">

</head>


<body class="site-shell">


<jsp:include
    page="/common/header.jsp" />



<main class="admin-ads-page">


    <!-- =====================================================
         상단
    ====================================================== -->

    <section class="admin-ads-head">


        <div>

            <span class="admin-ads-eyebrow">
                ADMIN · ADVERTISEMENTS
            </span>


            <h1>
                광고 관리
            </h1>


            <p>
                접수된 광고 문의를 확인하고
                승인, 게시 대기, 게시 중, 종료 상태를 관리합니다.
            </p>

        </div>


        <div class="admin-ads-head-summary">

            <span>
                승인 대기
            </span>

            <strong>
                <%=approvalCount%>
            </strong>

        </div>


    </section>



    <!-- =====================================================
         요약 카드
    ====================================================== -->

    <section class="admin-ads-summary-grid">


        <a
            href="<%=ctx%>/view/admin/ads/adminAds.jsp?tab=PENDING_APPROVAL"
            class="admin-ads-summary-card <%="PENDING_APPROVAL".equals(currentTab) ? "selected" : ""%>">

            <span class="admin-ads-summary-icon purple">

                <svg
                    viewBox="0 0 24 24"
                    aria-hidden="true">

                    <path
                        d="M12 3v18M3 12h18" />

                </svg>

            </span>


            <div>

                <span>
                    승인 대기
                </span>

                <strong>
                    <%=approvalCount%>
                </strong>

            </div>

        </a>



        <a
            href="<%=ctx%>/view/admin/ads/adminAds.jsp?tab=PENDING_PUBLICATION"
            class="admin-ads-summary-card <%="PENDING_PUBLICATION".equals(currentTab) ? "selected" : ""%>">

            <span class="admin-ads-summary-icon amber">

                <svg
                    viewBox="0 0 24 24"
                    aria-hidden="true">

                    <circle
                        cx="12"
                        cy="12"
                        r="8" />

                    <path
                        d="M12 7v5l3 2" />

                </svg>

            </span>


            <div>

                <span>
                    게시 대기
                </span>

                <strong>
                    <%=publicationCount%>
                </strong>

            </div>

        </a>



        <a
            href="<%=ctx%>/view/admin/ads/adminAds.jsp?tab=ACTIVE"
            class="admin-ads-summary-card <%="ACTIVE".equals(currentTab) ? "selected" : ""%>">

            <span class="admin-ads-summary-icon green">

                <svg
                    viewBox="0 0 24 24"
                    aria-hidden="true">

                    <path
                        d="m5 12 4 4L19 6" />

                </svg>

            </span>


            <div>

                <span>
                    게시 중
                </span>

                <strong>
                    <%=activeCount%>
                </strong>

            </div>

        </a>



        <a
            href="<%=ctx%>/view/admin/ads/adminAds.jsp?tab=CLOSED"
            class="admin-ads-summary-card <%="CLOSED".equals(currentTab) ? "selected" : ""%>">

            <span class="admin-ads-summary-icon gray">

                <svg
                    viewBox="0 0 24 24"
                    aria-hidden="true">

                    <path
                        d="M5 5l14 14M19 5 5 19" />

                </svg>

            </span>


            <div>

                <span>
                    종료 · 삭제
                </span>

                <strong>
                    <%=closedCount%>
                </strong>

            </div>

        </a>


    </section>



    <!-- =====================================================
         도구 영역
    ====================================================== -->

    <section class="admin-ads-toolbar">


        <nav
            class="admin-ads-tabs"
            aria-label="광고 상태">


            <a
                class="<%="PENDING_APPROVAL".equals(currentTab) ? "active" : ""%>"
                href="<%=ctx%>/view/admin/ads/adminAds.jsp?tab=PENDING_APPROVAL">

                승인 대기
                <span><%=approvalCount%></span>

            </a>


            <a
                class="<%="PENDING_PUBLICATION".equals(currentTab) ? "active" : ""%>"
                href="<%=ctx%>/view/admin/ads/adminAds.jsp?tab=PENDING_PUBLICATION">

                게시 대기
                <span><%=publicationCount%></span>

            </a>


            <a
                class="<%="ACTIVE".equals(currentTab) ? "active" : ""%>"
                href="<%=ctx%>/view/admin/ads/adminAds.jsp?tab=ACTIVE">

                게시 중
                <span><%=activeCount%></span>

            </a>


            <a
                class="<%="CLOSED".equals(currentTab) ? "active" : ""%>"
                href="<%=ctx%>/view/admin/ads/adminAds.jsp?tab=CLOSED">

                종료 · 삭제
                <span><%=closedCount%></span>

            </a>


            <a
                class="<%="ALL".equals(currentTab) ? "active" : ""%>"
                href="<%=ctx%>/view/admin/ads/adminAds.jsp?tab=ALL">

                전체
                <span><%=allAds.size()%></span>

            </a>


        </nav>



        <form
            class="admin-ads-search"
            method="get"
            action="<%=ctx%>/view/admin/ads/adminAds.jsp">


            <input
                type="hidden"
                name="tab"
                value="<%=h(currentTab)%>">


            <svg
                viewBox="0 0 24 24"
                aria-hidden="true">

                <circle
                    cx="11"
                    cy="11"
                    r="6" />

                <path
                    d="m16 16 4 4" />

            </svg>


            <input
                type="search"
                name="q"
                value="<%=h(searchKeyword)%>"
                placeholder="업체명, 담당자, 이메일 검색"
                aria-label="광고 검색">


        </form>


    </section>



    <!-- =====================================================
         목록
    ====================================================== -->

    <section class="admin-ads-list">


        <%
        if (visibleAds.isEmpty()) {
        %>


        <div class="admin-ads-empty">


            <span class="admin-ads-empty-icon">

                <svg
                    viewBox="0 0 24 24"
                    aria-hidden="true">

                    <rect
                        x="3"
                        y="5"
                        width="18"
                        height="14"
                        rx="2" />

                    <path
                        d="M7 14l3-3 2.5 2.5L15 11l3 3" />

                </svg>

            </span>


            <strong>
                해당 상태의 광고가 없습니다.
            </strong>


            <p>
                광고 문의가 접수되면 이곳에서 상태별로 확인할 수 있습니다.
            </p>


        </div>


        <%
        } else {


            for (Map<String, Object> ad : visibleAds) {


                long adId =
                        longValue(
                                ad,
                                "adId"
                        );


                String businessName =
                        value(
                                ad,
                                "businessName"
                        );


                String managerName =
                        value(
                                ad,
                                "managerName"
                        );


                String phone =
                        value(
                                ad,
                                "contactPhone"
                        );


                String email =
                        value(
                                ad,
                                "contactEmail"
                        );


                String adContent =
                        value(
                                ad,
                                "adContent"
                        );


                String adPosition =
                        value(
                                ad,
                                "adPosition"
                        );


                String startDate =
                        value(
                                ad,
                                "startDate"
                        );


                String endDate =
                        value(
                                ad,
                                "endDate"
                        );


                String status =
                        value(
                                ad,
                                "status"
                        );


                String imageUrl =
                        value(
                                ad,
                                "imageUrl"
                        );


                String linkUrl =
                        value(
                                ad,
                                "linkUrl"
                        );


                String rejectionReason =
                        value(
                                ad,
                                "rejectionReason"
                        );


                String createdAt =
                        value(
                                ad,
                                "createdAt"
                        );


                String previewImage =
                        imageSrc(
                                ctx,
                                imageUrl
                        );
        %>


        <article
            class="admin-ad-card"
            data-ad-id="<%=adId%>"
            data-business-name="<%=h(businessName)%>"
            data-manager-name="<%=h(managerName)%>"
            data-phone="<%=h(phone)%>"
            data-email="<%=h(email)%>"
            data-content="<%=h(adContent)%>"
            data-position="<%=h(adPosition)%>"
            data-position-label="<%=h(positionLabel(adPosition))%>"
            data-start-date="<%=h(startDate)%>"
            data-end-date="<%=h(endDate)%>"
            data-status="<%=h(status)%>"
            data-status-label="<%=h(statusLabel(status))%>"
            data-image-url="<%=h(previewImage)%>"
            data-link-url="<%=h(linkUrl)%>"
            data-rejection-reason="<%=h(rejectionReason)%>"
            data-created-at="<%=h(createdAt)%>">


            <!-- 이미지 -->

            <button
                type="button"
                class="admin-ad-image"
                data-ad-detail
                aria-label="<%=h(businessName)%> 광고 상세 보기">


                <%
                if (!previewImage.isEmpty()) {
                %>

                <img
                    src="<%=h(previewImage)%>"
                    alt="<%=h(businessName)%> 광고 이미지">

                <%
                } else {
                %>

                <span>

                    <svg
                        viewBox="0 0 24 24"
                        aria-hidden="true">

                        <rect
                            x="3"
                            y="5"
                            width="18"
                            height="14"
                            rx="2" />

                        <circle
                            cx="8"
                            cy="10"
                            r="1.4" />

                        <path
                            d="M5.5 16L9.5 12L12.5 15L15.5 11.5L19 16" />

                    </svg>

                    이미지 없음

                </span>

                <%
                }
                %>


                <span class="admin-ad-position">
                    <%=h(positionLabel(adPosition))%>
                </span>


            </button>



            <!-- 내용 -->

            <div class="admin-ad-body">


                <div class="admin-ad-title-row">


                    <div>

                        <div class="admin-ad-meta-top">

                            <span class="admin-ad-id">
                                AD #<%=adId%>
                            </span>

                            <span class="admin-ad-status <%=statusClass(status)%>">
                                <%=h(statusLabel(status))%>
                            </span>

                        </div>


                        <h2>
                            <%=h(businessName)%>
                        </h2>

                    </div>


                    <button
                        type="button"
                        class="admin-ad-detail-btn"
                        data-ad-detail>

                        상세 보기

                    </button>


                </div>



                <div class="admin-ad-info-grid">


                    <div>

                        <span>
                            담당자
                        </span>

                        <strong>
                            <%=h(managerName)%>
                        </strong>

                    </div>


                    <div>

                        <span>
                            연락처
                        </span>

                        <strong>
                            <%=h(phone)%>
                        </strong>

                    </div>


                    <div>

                        <span>
                            이메일
                        </span>

                        <strong>
                            <%=h(email)%>
                        </strong>

                    </div>


                    <div>

                        <span>
                            희망 기간
                        </span>

                        <strong>
                            <%=h(startDate)%>
                            <% if (!startDate.isEmpty() || !endDate.isEmpty()) { %>
                            ~
                            <% } %>
                            <%=h(endDate)%>
                        </strong>

                    </div>


                </div>



                <p class="admin-ad-description">
                    <%=h(adContent)%>
                </p>



                <div class="admin-ad-footer">


                    <span class="admin-ad-created">

                        접수
                        <%=createdAt.isEmpty() ? "-" : h(createdAt)%>

                    </span>


                    <div class="admin-ad-actions">


                        <%
                        if (!linkUrl.isEmpty()) {
                        %>

                        <a
                            href="<%=h(linkUrl)%>"
                            target="_blank"
                            rel="noopener noreferrer"
                            class="admin-ad-outline-action">

                            연결 링크

                        </a>

                        <%
                        }
                        %>


                        <%
                        /*
                         * 실제 승인/거절/철회/삭제는
                         * 관리자 광고 처리 Servlet 연결 후
                         * data-ad-action 버튼을 POST 처리로 교체하면 됨.
                         */
                        if ("PENDING_APPROVAL".equals(status)) {
                        %>


                        <button
                            type="button"
                            class="admin-ad-outline-action danger"
                            data-ad-action="REJECT"
                            data-ad-id="<%=adId%>">

                            거절

                        </button>


                        <button
                            type="button"
                            class="admin-ad-primary-action"
                            data-ad-action="APPROVE"
                            data-ad-id="<%=adId%>">

                            승인

                        </button>


                        <%
                        } else if (
                            "PENDING_PUBLICATION".equals(status)
                        ) {
                        %>


                        <button
                            type="button"
                            class="admin-ad-outline-action danger"
                            data-ad-action="WITHDRAW"
                            data-ad-id="<%=adId%>">

                            게시 철회

                        </button>


                        <button
                            type="button"
                            class="admin-ad-primary-action"
                            data-ad-action="ACTIVATE"
                            data-ad-id="<%=adId%>">

                            게시 시작

                        </button>


                        <%
                        } else if (
                            "ACTIVE".equals(status)
                        ) {
                        %>


                        <button
                            type="button"
                            class="admin-ad-outline-action"
                            data-ad-action="EXTEND"
                            data-ad-id="<%=adId%>">

                            기간 연장

                        </button>


                        <button
                            type="button"
                            class="admin-ad-outline-action danger"
                            data-ad-action="DELETE"
                            data-ad-id="<%=adId%>">

                            광고 삭제

                        </button>


                        <%
                        }
                        %>


                    </div>


                </div>


            </div>


        </article>


        <%
            }
        }
        %>


    </section>


</main>



<!-- =========================================================
     상세 모달
========================================================= -->

<div
    class="admin-ad-modal"
    id="adminAdDetailModal"
    aria-hidden="true">


    <div
        class="admin-ad-modal-backdrop"
        data-ad-modal-close>
    </div>


    <section
        class="admin-ad-modal-dialog"
        role="dialog"
        aria-modal="true"
        aria-labelledby="adminAdModalTitle">


        <div class="admin-ad-modal-head">


            <div>

                <span>
                    ADVERTISEMENT DETAIL
                </span>

                <h2 id="adminAdModalTitle">
                    광고 상세
                </h2>

            </div>


            <button
                type="button"
                class="admin-ad-modal-close"
                data-ad-modal-close
                aria-label="닫기">

                ×

            </button>


        </div>



        <div class="admin-ad-modal-content">


            <div class="admin-ad-modal-image-wrap">


                <div
                    class="admin-ad-modal-image"
                    id="modalAdImage">

                    이미지 없음

                </div>


                <div class="admin-ad-modal-badges">

                    <span
                        class="admin-ad-modal-position"
                        id="modalAdPosition">
                        -
                    </span>

                    <span
                        class="admin-ad-status"
                        id="modalAdStatus">
                        -
                    </span>

                </div>


            </div>



            <div class="admin-ad-modal-info">


                <div class="admin-ad-modal-business">

                    <span id="modalAdId">
                        AD #-
                    </span>

                    <h3 id="modalBusinessName">
                        -
                    </h3>

                </div>



                <dl class="admin-ad-detail-grid">


                    <div>
                        <dt>담당자</dt>
                        <dd id="modalManagerName">-</dd>
                    </div>


                    <div>
                        <dt>전화번호</dt>
                        <dd id="modalPhone">-</dd>
                    </div>


                    <div>
                        <dt>이메일</dt>
                        <dd id="modalEmail">-</dd>
                    </div>


                    <div>
                        <dt>접수일</dt>
                        <dd id="modalCreatedAt">-</dd>
                    </div>


                    <div class="wide">
                        <dt>희망 기간</dt>
                        <dd id="modalDateRange">-</dd>
                    </div>


                    <div class="wide">
                        <dt>광고 연결 URL</dt>
                        <dd>
                            <a
                                id="modalLinkUrl"
                                href="#"
                                target="_blank"
                                rel="noopener noreferrer">
                                -
                            </a>
                        </dd>
                    </div>


                    <div
                        class="wide"
                        id="modalRejectRow"
                        hidden>

                        <dt>거절 사유</dt>
                        <dd id="modalRejectionReason">-</dd>

                    </div>


                </dl>



                <div class="admin-ad-content-box">

                    <span>
                        광고 내용
                    </span>

                    <p id="modalAdContent">
                        -
                    </p>

                </div>


            </div>


        </div>


    </section>

</div>



<script>

document.addEventListener(
    "DOMContentLoaded",
    function () {

        const modal =
            document.getElementById(
                "adminAdDetailModal"
            );


        const modalImage =
            document.getElementById(
                "modalAdImage"
            );


        const modalStatus =
            document.getElementById(
                "modalAdStatus"
            );


        const setText =
            function (id, value) {

                const target =
                    document.getElementById(id);

                if (target) {
                    target.textContent =
                        value || "-";
                }
            };


        function openDetail(card) {

            if (!card) {
                return;
            }


            const data =
                card.dataset;


            setText(
                "modalAdId",
                "AD #" + (data.adId || "-")
            );


            setText(
                "modalBusinessName",
                data.businessName
            );


            setText(
                "modalManagerName",
                data.managerName
            );


            setText(
                "modalPhone",
                data.phone
            );


            setText(
                "modalEmail",
                data.email
            );


            setText(
                "modalCreatedAt",
                data.createdAt
            );


            setText(
                "modalAdPosition",
                data.positionLabel
            );


            setText(
                "modalAdContent",
                data.content
            );


            setText(
                "modalRejectionReason",
                data.rejectionReason
            );


            const dateRange =
                (data.startDate || "-")
                + " ~ "
                + (data.endDate || "-");


            setText(
                "modalDateRange",
                dateRange
            );


            if (modalStatus) {

                modalStatus.textContent =
                    data.statusLabel || "-";

                modalStatus.className =
                    "admin-ad-status "
                    + statusClassForJs(
                        data.status
                    );
            }


            const link =
                document.getElementById(
                    "modalLinkUrl"
                );


            if (link) {

                if (data.linkUrl) {

                    link.textContent =
                        data.linkUrl;

                    link.href =
                        data.linkUrl;

                    link.classList.remove(
                        "disabled"
                    );

                } else {

                    link.textContent =
                        "등록된 링크 없음";

                    link.removeAttribute(
                        "href"
                    );

                    link.classList.add(
                        "disabled"
                    );
                }
            }


            const rejectRow =
                document.getElementById(
                    "modalRejectRow"
                );


            if (rejectRow) {

                rejectRow.hidden =
                    !data.rejectionReason;
            }


            if (modalImage) {

                modalImage.innerHTML =
                    "";


                if (data.imageUrl) {

                    const image =
                        document.createElement(
                            "img"
                        );


                    image.src =
                        data.imageUrl;

                    image.alt =
                        (data.businessName || "광고")
                        + " 이미지";


                    modalImage.appendChild(
                        image
                    );

                } else {

                    modalImage.textContent =
                        "이미지 없음";
                }
            }


            modal.classList.add(
                "show"
            );


            modal.setAttribute(
                "aria-hidden",
                "false"
            );


            document.body.classList.add(
                "admin-ad-modal-open"
            );
        }


        function closeDetail() {

            modal.classList.remove(
                "show"
            );


            modal.setAttribute(
                "aria-hidden",
                "true"
            );


            document.body.classList.remove(
                "admin-ad-modal-open"
            );
        }


        function statusClassForJs(
            status
        ) {

            switch (status) {

                case "PENDING_APPROVAL":
                    return "pending";

                case "PENDING_PUBLICATION":
                    return "publication";

                case "ACTIVE":
                    return "active";

                case "REJECTED":
                    return "rejected";

                case "WITHDRAWN":
                    return "withdrawn";

                case "DELETED":
                    return "deleted";

                case "EXPIRED":
                    return "expired";

                default:
                    return "default";
            }
        }


        document.addEventListener(
            "click",
            function (event) {

                const detailButton =
                    event.target.closest(
                        "[data-ad-detail]"
                    );


                if (detailButton) {

                    const card =
                        detailButton.closest(
                            ".admin-ad-card"
                        );


                    openDetail(card);

                    return;
                }


                if (
                    event.target.closest(
                        "[data-ad-modal-close]"
                    )
                ) {

                    closeDetail();

                    return;
                }


                const actionButton =
                    event.target.closest(
                        "[data-ad-action]"
                    );


                if (actionButton) {

                    /*
                     * UI는 완성.
                     * 실제 상태 변경은 광고 관리 Servlet을
                     * 연결할 때 이 부분을 POST 요청으로 교체.
                     */
                    const action =
                        actionButton.getAttribute(
                            "data-ad-action"
                        );


                    const adId =
                        actionButton.getAttribute(
                            "data-ad-id"
                        );


                    alert(
                        "광고 #"
                        + adId
                        + " · "
                        + action
                        + " 처리 기능은 관리자 광고 처리 Servlet 연결 단계에서 활성화합니다."
                    );
                }
            }
        );


        document.addEventListener(
            "keydown",
            function (event) {

                if (
                    event.key === "Escape"
                    &&
                    modal.classList.contains(
                        "show"
                    )
                ) {

                    closeDetail();
                }
            }
        );

    }
);

</script>


</body>

</html>
