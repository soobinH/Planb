<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8" import="dto.member.UserDto"%>

<%
String ctx = request.getContextPath();

/* =========================
   현재 페이지
========================= */
Object activePageObj = request.getAttribute("activePage");

String activePage = activePageObj == null ? "" : String.valueOf(activePageObj);

boolean homeHeader = "home".equals(activePage);

/* =========================
   로그인 사용자
========================= */
UserDto user = (UserDto) session.getAttribute("user");

boolean loggedIn = user != null;

/* =========================
   관리자 여부
========================= */
boolean forceAdmin = Boolean.TRUE.equals(request.getAttribute("forceAdminHeader"));

boolean isAdminHeader = forceAdmin;

if (user != null && user.getRole() != null && "ADMIN".equalsIgnoreCase(user.getRole())) {

	isAdminHeader = true;
}

/* =========================
   닉네임
========================= */
String nickname = "여행자";

if (isAdminHeader) {

	nickname = "관리자";

} else if (user != null && user.getNickName() != null && !user.getNickName().trim().isEmpty()) {

	nickname = user.getNickName();
}

/* =========================
   프로필 이미지
========================= */
String profileImg = "";

if (user != null && user.getProfileImg() != null && !user.getProfileImg().trim().isEmpty()) {

	profileImg = user.getProfileImg();
}
%>


<link rel="stylesheet"
	href="<%=ctx%>/view/assets/css/common/header.css?v=5">


<header class="site-header<%=homeHeader ? " site-header--home" : ""%>">


	<div
		class="site-header-inner<%=homeHeader ? " site-header-inner--home" : ""%>">


		<!-- =========================
             로고
        ========================== -->

		<a class="site-brand" href="<%=ctx%>/home" aria-label="Planb 홈"> <span
			class="tripily-mark" aria-hidden="true"> <svg width="17"
					height="17" viewBox="0 0 24 24" fill="none">

                    <path
						d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7Z"
						fill="currentColor" />

                    <circle cx="12" cy="9" r="2.6" fill="white" />

                </svg>

		</span> <span class="site-brand-copy"> <strong> Planb </strong> <small>
					Travel Plan Share </small>

		</span>

		</a>



		<!-- =========================
             모바일 메뉴 버튼
        ========================== -->

		<button type="button" class="site-mobile-menu-btn"
			data-mobile-menu-toggle aria-label="메뉴 열기" aria-expanded="false">

			<svg width="20" height="20" viewBox="0 0 24 24" fill="none"
				stroke="currentColor" stroke-width="2" stroke-linecap="round">

                <path d="M4 6h16" />
                <path d="M4 12h16" />
                <path d="M4 18h16" />

            </svg>

		</button>



		<!-- =========================
             네비게이션
        ========================== -->

		<nav class="site-nav<%=homeHeader ? " site-nav--pill" : ""%>"
			data-mobile-nav aria-label="주요 메뉴">


			<!-- 여행 일정 -->

			<a
				class="<%=homeHeader ? "site-nav-pill" : "site-nav-link"%> <%="travel".equals(activePage) ? "active" : ""%>"
				href="<%=ctx%>/schedules"> 여행일정 </a>


			<!-- 일정 만들기 -->

			<a
				class="<%=homeHeader ? "site-nav-pill" : "site-nav-link"%> <%="planner".equals(activePage) ? "active" : ""%>"
				href="<%=ctx%>/writeplan"> 일정 만들기 </a>


			<!-- 여행 꿀팁 -->

			<a
				class="<%=homeHeader ? "site-nav-pill" : "site-nav-link"%> <%="tips".equals(activePage) ? "active" : ""%>"
				href="<%=ctx%>/tips"> 여행꿀팁 </a>


			<!-- 여행 메이트 -->

			<a
				class="<%=homeHeader ? "site-nav-pill" : "site-nav-link"%> <%="mates".equals(activePage) ? "active" : ""%>"
				href="<%=ctx%>/mates"> 여행 메이트 </a>

		</nav>



		<!-- =========================
             홈이 아닌 페이지 검색창
        ========================== -->

		<%
		if (!homeHeader) {
		%>

		<form 
			action="${pageContext.request.contextPath}/search" 
			method="get"
			class="header-search-form">

			<input 
				type="text" 
				name="q" 
				value="${param.q}"
				placeholder="여행지, 일정, 키워드로 검색해보세요." 
				autocomplete="off">

			<button 
				type="submit" 
				class="header-search-button" 
				aria-label="검색">

				<svg 
					width="17" 
					height="17" 
					viewBox="0 0 24 24" 
					fill="none"
					stroke="white" 
					stroke-width="2" 
					aria-hidden="true">
		
					<circle cx="11" cy="11" r="8" />
					<path d="m21 21-4.35-4.35" />
				</svg>
			</button>
		</form>

		<%
		}
		%>



		<!-- =========================
             오른쪽 메뉴
        ========================== -->

		<div class="site-actions">


			<!-- =========================
     관리자 전용 메뉴
========================== -->

			<%
			if (isAdminHeader) {
			%>


			<!-- =========================
     신고 관리
========================== -->

			<span class="site-badge-wrap"> <a id="adminReportHeaderButton"
				class="site-icon-btn site-admin-direct-btn
        <%="reports".equals(activePage) ? "active" : ""%>"
				href="<%=ctx%>/admin/reports" title="신고 관리" aria-label="신고 관리">
					<svg width="19" height="19" viewBox="0 0 24 24" fill="none"
						stroke="currentColor" stroke-width="1.6" stroke-linecap="round"
						stroke-linejoin="round">

            <line x1="12" y1="2" x2="12" y2="3.5" />

            <line x1="7.5" y1="3.8" x2="8.3" y2="5" />

            <line x1="16.5" y1="3.8" x2="15.7" y2="5" />

            <line x1="5" y1="7.5" x2="6.3" y2="8" />

            <line x1="19" y1="7.5" x2="17.7" y2="8" />

            <path
							d="M6 16C6 11.582 8.686 8 12 8C15.314 8 18 11.582 18 16" />

            <line x1="6" y1="16" x2="18" y2="16" />

            <rect x="7" y="17" width="10" height="2" rx="1" />

            <line x1="12" y1="19" x2="12" y2="20" />

            <line x1="9.5" y1="20" x2="14.5" y2="20" />

        </svg>

			</a> <!--
        처음에는 숨김.
        PENDING 신고가 존재할 때만 JS가 표시함.
    --> <span id="adminReportDot" class="site-admin-alert-dot"
				aria-label="새 신고 있음" hidden> </span>

			</span>



			<!-- =========================
     광고 관리
========================== -->

			<span class="site-badge-wrap"> <a id="adminAdHeaderButton"
				class="site-icon-btn site-admin-direct-btn
        <%="ads".equals(activePage) ? "active" : ""%>"
				href="<%=ctx%>/admin/ads" title="광고 관리" aria-label="광고 관리"> <svg
						width="19" height="19" viewBox="0 0 24 24" fill="none"
						stroke="currentColor" stroke-width="1.7" stroke-linecap="round"
						stroke-linejoin="round">

            <rect x="3" y="5" width="18" height="14" rx="2" />

            <circle cx="8" cy="10" r="1.5" />

            <path d="M5.5 16L9.5 12L12.5 15L15.5 11.5L19 16" />

        </svg>

			</a> <!--
        처음에는 숨김.
        PENDING_APPROVAL 광고가 있을 때만 표시.
    --> <span id="adminAdDot" class="site-admin-alert-dot"
				aria-label="새 광고 문의 있음" hidden> </span>

			</span> 
			<!-- 문의 관리 -->
			
			<span class="site-badge-wrap"> <a
				id="adminInquiryHeaderButton"
				class="site-icon-btn site-admin-direct-btn <%= "inquiries".equals(activePage) ? "active" : "" %>"
				href="<%=ctx%>/admin/support/inquiries" title="문의 관리"
				aria-label="문의 관리"> <svg width="19" height="19"
						viewBox="0 0 24 24" fill="none" stroke="currentColor"
						stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"
						aria-hidden="true">
            <path
							d="M4 5h16a2 2 0 0 1 2 2v9a2 2 0 0 1-2 2H9l-5 3v-3a2 2 0 0 1-2-2V7a2 2 0 0 1 2-2z" />
            <path d="M7 10h10M7 14h7" />
        </svg>
			</a>
			</span>

			<%
			}
			%>




			<!-- =========================
                 알림
            ========================== -->
            
			<div 
				class="site-badge-wrap site-notification-wrap"
				data-notification-header 
				data-context-path="<%=ctx%>"
				data-header-url="<%=ctx%>/notifications/header"
				data-read-url="<%=ctx%>/notifications/read">

				<button type="button" class="site-icon-btn" data-notification-toggle
					title="알림" aria-label="알림" aria-expanded="false">

					<!-- 기존 알림 SVG는 그대로 둬 -->
					<svg width="18" height="18" viewBox="0 0 24 24" fill="none"
						stroke="currentColor" stroke-width="2">
            			<path stroke-linecap="round" stroke-linejoin="round"
							d="M18 8a6 6 0 10-12 0c0 7-3 7-3 9h18c0-2-3-2-3-9" />
            			<path stroke-linecap="round" stroke-linejoin="round"
							d="M10 21h4" />
        			</svg>
				</button>

				<%
				if (loggedIn) {
				%>
				<span class="site-count-badge" data-notification-count hidden></span>

				<div class="site-notification-popover" data-notification-popover
					hidden>

					<div class="site-notification-head">
						<strong>알림</strong> <a href="<%=ctx%>/notifications">전체 보기</a>
					</div>

					<div data-notification-items>
						<p class="site-notification-empty">알림을 불러오는 중입니다.</p>
					</div>
					<div style="padding: 10px 14px; border-top: 1px solid #eee;">
						<button type="button" data-firebase-enable
							style="font-size: 12px; color: #6369D1; font-weight: 600;">
							실시간 알림 켜기</button>
					</div>
				</div>
				<%
				}
				%>
			</div>



			<!-- =========================
                 일정 장바구니
            ========================== -->

			<span class="site-badge-wrap" id="headerCart"
				data-count-url="<%=ctx%>/itinerary/cart/count"
				style="position: relative; display: inline-flex;"> <a
				class="site-icon-btn" href="<%=ctx%>/cart" title="일정 장바구니"
				aria-label="일정 장바구니"> <svg width="18" height="18" fill="none"
						stroke="currentColor" viewBox="0 0 24 24">

                        <path stroke-linecap="round"
							stroke-linejoin="round" stroke-width="2"
							d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13 5.4 5M7 13l-2.3 2.3c-.6.6-.2 1.7.7 1.7H17m0 0a2 2 0 100 4 2 2 0 000-4Zm-8 2a2 2 0 11-4 0 2 2 0 014 0Z" />

                    </svg>

			</a> <span id="headerCartBadge" class="header-cart-badge"
				style="display: none;" aria-live="polite"> </span>

			</span>



			<!-- =========================
                 로그인 상태
            ========================== -->

			<%
			if (loggedIn) {
			%>


			<a
				class="site-profile-btn site-profile-btn--user<%=isAdminHeader ? " site-profile-btn--admin" : ""%>"
				href="<%=ctx%>/profile/myProfile" title="마이페이지"> <!-- 프로필 이미지 -->

				<span class="site-profile-avatar site-profile-avatar--img"> <%
 if (!profileImg.isEmpty()) {
 %> <img src="<%=ctx%>/uploads/profile/<%=profileImg%>"
					alt="<%=nickname%>"> <%
 } else {
 %> <!-- 프로필 이미지 없는 경우 --> <svg width="16" height="16"
						viewBox="0 0 24 24" fill="none" stroke="currentColor"
						stroke-width="2">

                        <circle cx="12" cy="8" r="4" />

                        <path d="M4 21c0-4.3 3.6-7 8-7s8 2.7 8 7" />

                    </svg> <%
 }
 %>

			</span> <!-- 닉네임 --> <span class="site-profile-label"> <%=nickname%>
			</span>

			</a>


			<%
			} else {
			%>


			<!-- =========================
                 비로그인 상태
            ========================== -->

			<div class="site-auth-actions">

				<a class="site-auth-btn site-auth-btn--outline"
					href="<%=ctx%>/auth/login"> 로그인 </a> <a
					class="site-auth-btn site-auth-btn--fill"
					href="<%=ctx%>/auth/signup"> 회원가입 </a>

			</div>


			<%
			}
			%>


		</div>

	</div>

</header>


<script src="<%=ctx%>/view/assets/js/common/headerCart.js?v=3" defer></script>
<script src="<%=ctx%>/view/assets/js/common/headerNotifications.js?v=1"
	defer>
</script>
<%
if (isAdminHeader) {
%>

<script>

document.addEventListener(
    "DOMContentLoaded",
    function () {


        const reportDot =
            document.getElementById(
                "adminReportDot"
            );


        const adDot =
            document.getElementById(
                "adminAdDot"
            );


        const reportButton =
            document.getElementById(
                "adminReportHeaderButton"
            );


        const adButton =
            document.getElementById(
                "adminAdHeaderButton"
            );


        async function loadAdminHeaderBadges() {

            try {

                const response =
                    await fetch(
                        "<%=ctx%>
	/admin/header-badges", {
									method : "GET",

									headers : {
										"Accept" : "application/json"
									},

									cache : "no-store"
								});

								if (!response.ok) {

									throw new Error("관리자 알림 조회 실패");
								}

								const data = await
								response.json();

								const reportCount = Number(data.reportPendingCount || 0);

								const adCount = Number(data.adPendingCount || 0);

								/* =================================
								   신고
								================================= */

								if (reportDot) {

									reportDot.hidden = reportCount <= 0;
								}

								if (reportButton) {

									if (reportCount > 0) {

										reportButton.title = "신고 관리 · 미처리 "
												+ reportCount + "건";

										reportButton.setAttribute("aria-label",
												"신고 관리, 미처리 신고 " + reportCount
														+ "건");

									} else {

										reportButton.title = "신고 관리";

										reportButton.setAttribute("aria-label",
												"신고 관리");
									}
								}

								/* =================================
								   광고
								================================= */

								if (adDot) {

									adDot.hidden = adCount <= 0;
								}

								if (adButton) {

									if (adCount > 0) {

										adButton.title = "광고 관리 · 승인 대기 "
												+ adCount + "건";

										adButton.setAttribute("aria-label",
												"광고 관리, 승인 대기 광고 " + adCount
														+ "건");

									} else {

										adButton.title = "광고 관리";

										adButton.setAttribute("aria-label",
												"광고 관리");
									}
								}

							} catch (error) {

								console.error(error);

								/*
								 * 조회 오류가 있다고 빨간 점을 잘못
								 * 보여주면 안 되므로 숨긴다.
								 */

								if (reportDot) {

									reportDot.hidden = true;
								}

								if (adDot) {

									adDot.hidden = true;
								}
							}
						}

						/*
						 * 처음 헤더 로딩 시 바로 조회
						 */

						loadAdminHeaderBadges();

						/*
						 * 관리자가 페이지를 오래 열어둔 경우
						 * 새 신고/광고를 확인하기 위해
						 * 30초마다 다시 조회
						 */

						window.setInterval(loadAdminHeaderBadges, 30000);

					});
</script>

<%
}
%>

<% if (isAdminHeader) { %>
<link rel="stylesheet" href="<%=ctx%>/view/assets/css/common/adminHeaderBadges.css?v=20261013">
<script src="<%=ctx%>/view/assets/js/common/adminHeaderBadges.js?v=20261013"
        data-badges-url="<%=ctx%>/admin/header-badges" defer></script>
<% } %>

<script src="<%=ctx%>/view/assets/js/googlePlaceThumbnail.js?v=2"
	data-google-place-thumbnail-loader
	data-google-maps-key="AIzaSyB7ioaQS08aAzCl7gZPk6SyE1w7EeIrYhI" defer></script>

<%
if (loggedIn) {
%>
<script src="<%=ctx%>/view/assets/js/firebase/firebase-config.js?v=1"></script>

<script type="module"
	src="<%=ctx%>/view/assets/js/firebase/firebaseNotifications.js?v=1">
    </script>
<%
}
%>
