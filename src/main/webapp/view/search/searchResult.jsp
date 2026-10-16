<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<%
request.setAttribute("activePage", "search");

String keyword = (String) request.getAttribute("keyword");
String displayQ = (keyword == null || keyword.trim().isEmpty()) ? "전체" : keyword;
%>

<!DOCTYPE html>
<html lang="ko">

<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">

	<title>통합 검색 · Tripily</title>

	<jsp:include page="/common/headStyles.jsp" />
	<script
		src="${pageContext.request.contextPath}/view/assets/js/search/searchResult.js">
	</script>
	
<script defer data-context-path="${pageContext.request.contextPath}" src="${pageContext.request.contextPath}/view/assets/js/common/searchReturn.js?v=20261016"></script>
<style>
.search-card-refresh .search-schedule-grid .jsp-schedule-card { position: relative; cursor: pointer; }
.search-card-refresh .search-schedule-grid .schedule-card-detail-link { position: static; }
.search-card-refresh .search-schedule-grid .schedule-card-detail-link::after {
    content: "";
    position: absolute;
    inset: 0;
    z-index: 1;
    border-radius: 16px;
}
.search-card-refresh .search-schedule-grid .schedule-card-detail-link:focus-visible::after {
    outline: 3px solid #6369D1;
    outline-offset: -3px;
}
.search-card-refresh .search-schedule-grid [data-schedule-bookmark] { z-index: 2; }
.search-card-refresh .search-schedule-grid .jsp-schedule-card {
    border-color: #e6e6f2 !important; box-shadow: 0 2px 10px rgba(47,50,91,.045) !important;
}
.search-card-refresh .search-schedule-grid .jsp-schedule-card:hover {
    border-color: #D1D2F9 !important; box-shadow: 0 7px 20px rgba(99,105,209,.11) !important;
}
.search-card-refresh .search-schedule-grid .schedule-card-country {
    background: rgba(209,210,249,.79) !important; color: #494da4; box-shadow: 0 2px 8px rgba(99,105,209,.09);
    backdrop-filter: blur(8px); -webkit-backdrop-filter: blur(8px);
}
.search-card-refresh .search-schedule-grid .schedule-card-duration {
    background: rgba(255,212,71,.79); color: #554718; box-shadow: 0 2px 7px rgba(70,59,12,.08);
    backdrop-filter: blur(8px); -webkit-backdrop-filter: blur(8px);
}
.search-card-refresh .search-schedule-grid .schedule-card-author {
    border-color: #D1D2F9 !important; background: transparent;
}
.search-card-refresh .search-schedule-grid [data-schedule-bookmark] {
    background: rgba(255,255,255,.79); backdrop-filter: blur(8px); -webkit-backdrop-filter: blur(8px);
}
.search-card-refresh .search-schedule-grid [data-schedule-bookmark]:hover { background: rgba(255,255,255,.94); }
.search-card-refresh .tip-schedule-card {
    font-family: inherit; border-color: #e6e6f2 !important;
    box-shadow: 0 2px 10px rgba(47,50,91,.045) !important;
    transition: all .2s cubic-bezier(.4,0,.2,1);
}
.search-card-refresh .tip-schedule-card:hover {
    border-color: #D1D2F9 !important;
    box-shadow: 0 7px 20px rgba(99,105,209,.11) !important;
    transform: translateY(-3px) !important;
}
.search-card-refresh .tip-schedule-card .tip-card-title { font-size: 14px; font-weight: 700; line-height: 1.375; color: #18181b; }
.search-card-refresh .tip-schedule-card .tip-card-summary { font-size: 12px; line-height: 20px; color: #6b7280; }
.search-card-refresh .tip-schedule-card .tip-card-author-name { font-size: 11px; font-weight: 500; color: #6b7280; }
.search-card-refresh .tip-schedule-card .tip-card-stats { font-size: 11px; color: #9ca3af; }
.search-card-refresh .tip-schedule-card .tip-card-stats svg { width: 12px; height: 12px; }
.search-card-refresh .tip-schedule-card .tip-card-time { font-size: 10px; color: #9ca3af; }
</style>
</head>

<body class="site-shell">

	<jsp:include page="/common/header.jsp" />

	<main class="search-card-refresh w-full max-w-6xl mx-auto px-4 sm:px-6 py-8 sm:py-10">

		<!-- =========================
		     검색 결과 상단
		========================= -->
		<div class="mb-8">
			<p class="text-xs font-bold tracking-widest text-[#6369D1]">
				GLOBAL SEARCH
			</p>
		
			<div class="flex items-center gap-3 mt-2">
				<h1 class="text-2xl sm:text-3xl font-black">
					“<%=displayQ%>” 통합 검색
				</h1>
			
				<span class="text-sm sm:text-base font-semibold text-gray-400">
					총 ${totalCount}건
				</span>
			</div>
		
			<p id="searchDescription" class="text-sm text-gray-500 mt-2">
				여행일정 · 여행꿀팁 · 여행 메이트를 한 번에 검색합니다.
			</p>
		</div>

		<!-- 검색 결과 탭 -->
		<div class="flex flex-wrap gap-2 mb-8" id="searchTabs">
		
			<button
				type="button"
				class="search-tab px-4 py-2 rounded-full text-sm font-bold bg-[#6369D1] text-white"
				data-search-tab="all">
				전체
			</button>
		
			<button
				type="button"
				class="search-tab px-4 py-2 rounded-full text-sm font-bold border border-gray-200 bg-white text-gray-600"
				data-search-tab="schedule">
				여행일정
			</button>
		
			<button
				type="button"
				class="search-tab px-4 py-2 rounded-full text-sm font-bold border border-gray-200 bg-white text-gray-600"
				data-search-tab="tip">
				여행꿀팁
			</button>
		
			<button
				type="button"
				class="search-tab px-4 py-2 rounded-full text-sm font-bold border border-gray-200 bg-white text-gray-600"
				data-search-tab="mate">
				여행 메이트
			</button>
		
		</div>


			<!-- ==================================================
			     여행일정
			     실제 DB 검색 결과
			     PC 2열 / 모바일 1열 / 최대 4개
			================================================== -->
			<section class="mb-10" data-search-section="schedule">
		
				<div class="flex items-center justify-between gap-4 mb-3">
		
					<h2 class="text-lg font-black shrink-0">
						여행일정
						<span class="text-[#6369D1]">
							${scheduleTotalCount}
						</span>
					</h2>
		
					<c:url var="scheduleListUrl" value="/schedules">
						<c:param name="keyword" value="${keyword}" />
					</c:url>
		
					<a
						href="${scheduleListUrl}"
						class="text-sm font-bold text-[#6369D1] text-right">
						상세 조건으로 더 보기 →
					</a>
		
				</div>
		
		
				<c:choose>
		
					<c:when test="${not empty scheduleList}">
		
						<div class="search-schedule-grid grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
		
							<jsp:useBean id="scheduleCardNow" class="java.util.Date" scope="request"/>
<c:forEach var="schedule" items="${scheduleList}">
	<c:url var="scheduleDetailUrl" value="/schedules/detail">
		<c:param name="id" value="${schedule.itineraryId}" />
	</c:url>

	<article
		class="jsp-schedule-card bg-white rounded-2xl overflow-hidden transition-all duration-200 border group"
		style="border-color: #D1D2F9; box-shadow: 0 2px 8px rgba(0, 0, 0, .07)">

		<div class="relative overflow-hidden" style="aspect-ratio: 4/3">

			<a href="${scheduleDetailUrl}" class="block w-full h-full"> <c:choose>
					<c:when test="${not empty schedule.thumbnailImg}">

						<!-- 이미지 경로에 프로젝트 경로를 붙임 -->
						<c:choose>
							<c:when test="${schedule.thumbnailImg.startsWith('/')}">
								<c:url var="thumbnailUrl" value="${schedule.thumbnailImg}" />
							</c:when>

							<c:otherwise>
								<c:url var="thumbnailUrl" value="/${schedule.thumbnailImg}" />
							</c:otherwise>
						</c:choose>

						<img src="<c:out value='${thumbnailUrl}'/>"
							alt="<c:out value='${schedule.title}'/>"
							class="w-full h-full object-cover transition-transform duration-300 group-hover:scale-105">

					</c:when>

					<c:otherwise>
						<div class="w-full h-full flex items-center justify-center"
							style="background: #F0F0FF; color: #6369D1">여행 일정</div>
					</c:otherwise>
				</c:choose>
			</a>

			<!-- 시트별 대륙·국가·핀 도시를 요약한 위치 배지 -->
			<span
				class="schedule-card-country absolute top-2.5 left-2.5 text-[10px] font-bold px-2 py-0.5 rounded-full"
				style="background: rgba(209,210,249,.79); color: #494da4"> <c:out
					value="${schedule.locationLabel}" />
			</span>

			<!-- 비로그인 또는 타인 일정에서만 북마크 버튼 표시 -->
			<c:if
				test="${empty sessionScope.user or schedule.userId ne sessionScope.user.userId}">
				<button type="button" data-schedule-bookmark
					data-login-url="${pageContext.request.contextPath}/auth/login"
					data-bookmark-url="${pageContext.request.contextPath}/itinerary/bookmark"
					data-itinerary-id="${schedule.itineraryId}"
					data-logged-in="${not empty sessionScope.user}"
					aria-pressed="${schedule.bookmarked}" aria-label="북마크"
					class="absolute top-2.5 right-2.5 w-7 h-7 rounded-full bg-white/90 backdrop-blur-sm flex items-center justify-center shadow-sm transition-all hover:scale-110">

					<svg width="13" height="13" viewBox="0 0 24 24"
						fill="${schedule.bookmarked ? '#6369D1' : 'none'}"
						stroke="${schedule.bookmarked ? '#6369D1' : '#9ca3af'}"
						stroke-width="2">

                        <path stroke-linecap="round"
							stroke-linejoin="round"
							d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" />
                    </svg>
				</button>
			</c:if>

			<!-- 여행 기간: n박 m일 -->
			<span
				class="schedule-card-duration absolute bottom-2.5 left-2.5 text-white text-[11px] font-bold bg-black/50 rounded-full px-2.5 py-1">
				<c:out value="${schedule.dayDurationText}" />
			</span>

		</div>

		<div class="p-3.5">

			<a href="${scheduleDetailUrl}" class="schedule-card-detail-link">
				<h3
					class="font-bold text-[14px] leading-snug mb-1 line-clamp-2 transition-colors group-hover:text-[#6369D1]"
					style="color: #18181b">
					<c:out value="${schedule.title}" />
				</h3>
			</a>

			<p class="text-gray-500 text-[12px] mb-2.5"
				style="height: 20px; line-height: 20px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
				<c:out value="${schedule.summary}" />
			</p>

			<!-- 좋아요·댓글·조회수 -->
			<div class="flex items-center gap-2.5 text-[11px] text-gray-400 mb-3">
				<span
					class="schedule-card-stat inline-flex items-center gap-1 whitespace-nowrap"
					title="좋아요"> <svg width="12" height="12" viewBox="0 0 24 24"
						fill="${schedule.liked ? '#ef4444' : 'none'}"
						stroke="${schedule.liked ? '#ef4444' : '#9ca3af'}"
						stroke-width="2" aria-hidden="true">

    					<path stroke-linecap="round" stroke-linejoin="round"
							d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78Z" />
						</svg> <fmt:formatNumber value="${schedule.likeCount}" pattern="#,##0" />
				</span> <span
					class="schedule-card-stat inline-flex items-center gap-1 whitespace-nowrap"
					title="댓글"> <svg width="12" height="12" viewBox="0 0 24 24"
						fill="none" stroke="#9ca3af" stroke-width="2" aria-hidden="true">

                        <path stroke-linecap="round"
							stroke-linejoin="round" d="M7.9 20A9 9 0 1 0 4 16.1L2 22Z" />
                    	</svg> <fmt:formatNumber value="${schedule.commentCount}"
						pattern="#,##0" />
				</span> <span
					class="schedule-card-stat inline-flex items-center gap-1 whitespace-nowrap"
					title="조회"> <svg width="12" height="12" viewBox="0 0 24 24"
						fill="none" stroke="#9ca3af" stroke-width="2" aria-hidden="true">

                        <path stroke-linecap="round"
							stroke-linejoin="round"
							d="M2.062 12.348a1 1 0 0 1 0-.696 10.75 10.75 0 0 1 19.876 0 1 1 0 0 1 0 .696 10.75 10.75 0 0 1-19.876 0" />

                        <circle cx="12" cy="12" r="3" />
                    	</svg> <fmt:formatNumber
						value="${empty schedule.viewCount ? 0 : schedule.viewCount}"
						pattern="#,##0" />
				</span>

			</div>

			<!-- 작성자·작성일 -->
			<div class="schedule-card-author flex items-center justify-between gap-2 border-t pt-2.5"
				style="border-color: #D1D2F9">

				<!-- 작성자 프로필 사진·닉네임 -->
				<div class="flex items-center gap-1.5 min-w-0">

					<span
						style="position: relative; display: inline-flex; align-items: center; justify-content: center; width: 24px; height: 24px; flex-shrink: 0; border-radius: 50%; overflow: hidden; background: #F0F0FF; color: #6369D1;"><jsp:include page="/common/profileImage.jsp"><jsp:param name="image" value="${schedule.profileImg}"/><jsp:param name="nickname" value="${schedule.nickname}"/></jsp:include></span> <span class="text-[11px] text-gray-500 font-medium"
						style="white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
						<c:out value="${schedule.nickname}" />
					</span>
				</div>

				<!-- 등록 후 경과 시간: 기존 작성일 위치와 글씨 크기 유지 -->
				<span class="text-[10px] text-gray-400"
					style="flex-shrink: 0; white-space: nowrap;"> <c:choose>
                        <c:when test="${empty schedule.createdAt}">-</c:when>
                        <c:otherwise>
                            <c:set var="scheduleAgeSeconds" value="${(scheduleCardNow.time - schedule.createdAt.time) div 1000}" />
                            <c:choose>
                                <c:when test="${scheduleAgeSeconds lt 60}">방금 전</c:when>
                                <c:otherwise>
                                    <c:choose>
                                        <c:when test="${scheduleAgeSeconds lt 3600}">
                                            <c:set var="scheduleAgeUnit" value="60" /><c:set var="scheduleAgeSuffix" value="분 전" />
                                        </c:when>
                                        <c:when test="${scheduleAgeSeconds lt 86400}">
                                            <c:set var="scheduleAgeUnit" value="3600" /><c:set var="scheduleAgeSuffix" value="시간 전" />
                                        </c:when>
                                        <c:when test="${scheduleAgeSeconds lt 2592000}">
                                            <c:set var="scheduleAgeUnit" value="86400" /><c:set var="scheduleAgeSuffix" value="일 전" />
                                        </c:when>
                                        <c:when test="${scheduleAgeSeconds lt 31536000}">
                                            <c:set var="scheduleAgeUnit" value="2592000" /><c:set var="scheduleAgeSuffix" value="개월 전" />
                                        </c:when>
                                        <c:otherwise>
                                            <c:set var="scheduleAgeUnit" value="31536000" /><c:set var="scheduleAgeSuffix" value="년 전" />
                                        </c:otherwise>
                                    </c:choose>
                                    <fmt:formatNumber value="${(scheduleAgeSeconds - (scheduleAgeSeconds mod scheduleAgeUnit)) div scheduleAgeUnit}" pattern="0" groupingUsed="false" /><c:out value="${scheduleAgeSuffix}" />
                                </c:otherwise>
                            </c:choose>
                        </c:otherwise>
                    </c:choose>
				</span>
			</div>

		</div>
	</article>
</c:forEach>
		
						</div>
		
					</c:when>
		
		
					<c:otherwise>
		
						<div
							class="py-10 px-4 text-center text-sm text-gray-400 border border-gray-100 rounded-2xl bg-white">
		
							검색된 여행일정이 없습니다.
		
						</div>
		
					</c:otherwise>
		
				</c:choose>
		
			</section>


		<!-- ==================================================
		     여행꿀팁
		     실제 DB 검색 결과
		     PC 4열 / 태블릿 2열 / 모바일 1열
		================================================== -->
		<section class="mb-10" data-search-section="tip">

			<div class="flex items-center justify-between gap-4 mb-3">

				<h2 class="text-lg font-black shrink-0">
					여행꿀팁
					<span class="text-[#6369D1]">
						${tipTotalCount}
					</span>
				</h2>

				<c:url var="tipListUrl" value="/tips">
					<c:param name="keyword" value="${keyword}" />
				</c:url>

				<a
					href="${tipListUrl}"
					class="text-sm font-bold text-[#6369D1]">
					상세 조건으로 더 보기 →
				</a>

			</div>


			<c:choose>

				<c:when test="${not empty tipList}">

					<div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">

						<c:forEach var="tip" items="${tipList}">
						<a href="${pageContext.request.contextPath}/tipDetail?tipId=${tip.tipId}"
							class="tip-schedule-card relative bg-white rounded-2xl border border-gray-100 transition-all duration-200 cursor-pointer group overflow-hidden flex flex-col">
				
							<div class="relative shrink-0 overflow-hidden" style="aspect-ratio: 4 / 3">
								<c:choose>
									<c:when test="${not empty tip.thumbnailImg}">
										<img src="${pageContext.request.contextPath}${tip.thumbnailImg}" alt="${tip.title}"
											class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300">
									</c:when>
									<c:otherwise>
										<img src="${pageContext.request.contextPath}/view/assets/images/default/tip-default.svg" alt="여행꿀팁 기본 이미지"
											class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300">
									</c:otherwise>
								</c:choose>
							</div>
							<div class="flex flex-col flex-1 p-3 min-h-0">
								<h3 class="tip-card-title font-bold text-[14px] text-gray-900 leading-snug line-clamp-2 
									group-hover:text-brand transition-colors mb-1.5" style="min-height: 2.6em">
									<c:out value="${tip.title}" />
								</h3>
								<c:set var="tipPreview" value="${tip.content}" />
								<c:set var="tipPreview" value="${fn:replace(tipPreview, '[[IMG:1]]', ' ')}" />
								<c:set var="tipPreview" value="${fn:replace(tipPreview, '[[IMG:2]]', ' ')}" />
								<c:set var="tipPreview" value="${fn:replace(tipPreview, '[[IMG:3]]', ' ')}" />
								<c:set var="tipPreview" value="${fn:replace(tipPreview, '[[IMG:4]]', ' ')}" />
								<c:set var="tipPreview" value="${fn:replace(tipPreview, '[[IMG:5]]', ' ')}" />
								<p class="tip-card-summary text-[12px] text-gray-500 leading-relaxed line-clamp-2 flex-1">
									<c:out value="${tipPreview}" />
								</p>
								<c:if test="${not empty tip.hashtag}">
									<div class="flex flex-wrap gap-1.5 mt-2 mb-3">
										<c:forEach var="tag" items="${tip.hashtagList}">
											<span
												class="inline-flex items-center rounded-full px-2.5 py-1 text-[11px] font-semibold"
												style="background: rgba(255,212,71,.55); color: #6369D1; border: 1px solid #E0E1FF;">
												${tag}
											</span>
										</c:forEach>
									</div>
								</c:if>
								<div class="mt-auto pt-2">
                    <!-- 좋아요·댓글·조회수는 작성자 구분선 위에 표시 -->
                    <div class="tip-card-stats flex items-center gap-2.5 mb-3 text-[11px] text-gray-400">
									
									    <!-- 좋아요 -->
									    <span class="flex items-center gap-1">
									        <svg
									            width="15"
									            height="15"
									            viewBox="0 0 24 24"
									            fill="none"
									            stroke="currentColor"
									            stroke-width="2"
									            stroke-linecap="round"
									            stroke-linejoin="round">
									
									            <path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z" />
									
									        </svg>
									        <span>${tip.likeCount}</span>
									    </span>
									
									    <!-- 댓글 -->
									    <span class="flex items-center gap-1">
									        <svg
									            width="15"
									            height="15"
									            viewBox="0 0 24 24"
									            fill="none"
									            stroke="currentColor"
									            stroke-width="2"
									            stroke-linecap="round"
									            stroke-linejoin="round">
									
									            <path d="M21 11.5a8.38 8.38 0 0 1-.9 3.8 8.5 8.5 0 0 1-7.6 4.7 8.38 8.38 0 0 1-3.8-.9L3 21l1.9-5.7a8.38 8.38 0 0 1-.9-3.8 8.5 8.5 0 0 1 4.7-7.6 8.38 8.38 0 0 1 3.8-.9h.5a8.48 8.48 0 0 1 8 8v.5z" />
									
									        </svg>
									        <span>${tip.commentCount}</span>
									    </span>
									
									    <!-- 조회수 -->
									    <span class="flex items-center gap-1">
									        <svg
									            width="15"
									            height="15"
									            viewBox="0 0 24 24"
									            fill="none"
									            stroke="currentColor"
									            stroke-width="2"
									            stroke-linecap="round"
									            stroke-linejoin="round">
									
									            <path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7S2 12 2 12Z" />
									            <circle cx="12" cy="12" r="3" />
									
									        </svg>
									        <span>${tip.viewCount}</span>
									    </span>
									
									</div>
                    <div class="tip-card-author flex items-center justify-between gap-2 border-t pt-2.5" style="border-color: #D1D2F9;">
                        <div class="flex items-center gap-1.5 min-w-0">
										<!-- 작성자 프로필 이미지 -->
										<div class="w-5 h-5 rounded-full overflow-hidden flex items-center justify-center text-white font-bold shrink-0"
										     style="background: linear-gradient(135deg, #6369D1, #8B5CF6);"><jsp:include page="/common/profileImage.jsp"><jsp:param name="image" value="${tip.profileImg}"/></jsp:include></div>
										<span class="tip-card-author-name text-[11px] text-gray-500 font-medium" style="min-width: 0; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">
											<c:out value="${tip.nickname}" default="알 수 없음" />
										</span>
										
										
									</div>
                        <span class="tip-card-time text-[10px] text-gray-400" style="flex-shrink: 0; white-space: nowrap;"><c:out value="${tip.timeAgo}" /></span>
                    </div>
                </div>
							</div>
						</a>
					</c:forEach>

					</div>

				</c:when>


				<c:otherwise>

					<div class="py-10 px-4 text-center text-sm text-gray-400 border border-gray-100 rounded-2xl bg-white">
						검색된 여행꿀팁이 없습니다.
					</div>

				</c:otherwise>

			</c:choose>

		</section>


		<!-- ==================================================
		     여행 메이트
		     실제 DB 검색 결과
		     가로형 / 최대 4개
		================================================== -->
		<section class="mb-10" data-search-section="mate">

			<div class="flex items-center justify-between gap-4 mb-3">

				<h2 class="text-lg font-black shrink-0">
					여행 메이트
					<span class="text-[#6369D1]">
						${mateTotalCount}
					</span>
				</h2>

				<c:url var="mateListUrl" value="/mates">
					<c:param name="keyword" value="${keyword}" />
				</c:url>

				<a
					href="${mateListUrl}"
					class="text-sm font-bold text-[#6369D1]">
					상세 조건으로 더 보기 →
				</a>

			</div>


			<c:choose>

				<c:when test="${not empty mateList}">

					<div class="space-y-3">

						<c:forEach var="mate" items="${mateList}">

							<a
								href="${pageContext.request.contextPath}/mateDetail?mateId=${mate.mateId}"
								class="block relative bg-white rounded-2xl border border-gray-100 shadow-sm hover:shadow-md transition-all cursor-pointer group p-4 sm:p-5 hover:border-[#D1D2F9]">

								<!-- 위쪽 -->
								<div class="flex flex-col sm:flex-row sm:items-start sm:justify-between gap-3">

									<div class="flex-1 min-w-0">

										<!-- 국가 / 모집상태 -->
										<div class="flex items-center gap-2 mb-3 flex-wrap">

											<span
												class="flex items-center gap-1 text-xs font-bold px-2.5 py-1 rounded-full"
												style="background: var(--brand-soft); color: var(--brand);">

												<svg
													width="10"
													height="10"
													viewBox="0 0 24 24"
													fill="none"
													stroke="currentColor"
													stroke-width="2">

													<path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z" />
													<circle cx="12" cy="10" r="3" />

												</svg>

												<c:out value="${mate.country}" />

											</span>


											<c:choose>

												<c:when test="${mate.recruitStatus eq 'OPEN'}">

													<span
														class="inline-flex items-center gap-1 text-[11px] font-bold px-2.5 py-1 rounded-full"
														style="background: #ecfdf5; color: #059669;">

														<span
															class="inline-block w-1.5 h-1.5 rounded-full"
															style="background: #10b981;">
														</span>

														모집중

													</span>

												</c:when>


												<c:otherwise>

													<span
														class="inline-flex items-center gap-1 text-[11px] font-bold px-2.5 py-1 rounded-full"
														style="background: #fef2f2; color: #dc2626;">

														<span
															class="inline-block w-1.5 h-1.5 rounded-full"
															style="background: #ef4444;">
														</span>

														모집완료

													</span>

												</c:otherwise>

											</c:choose>

										</div>


										<!-- 제목 -->
										<h3 class="font-bold text-[15px] text-gray-900 leading-snug group-hover:text-brand transition-colors">
											<c:out value="${mate.title}" />
										</h3>

									</div>


									<!-- 모집인원 -->
									<div class="shrink-0">

										<span
											class="inline-flex text-[11px] font-semibold px-2.5 py-1 rounded-full"
											style="background: var(--brand-light); color: var(--brand);">

											👥 ${mate.recruitCount}명 모집

										</span>

									</div>

								</div>


								<!-- 아래쪽 -->
								<div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3 mt-4 pt-3 border-t border-gray-50">

									<!-- 작성자 -->
									<div class="flex items-center gap-1.5 text-xs">

										<span class="w-5 h-5 rounded-full overflow-hidden shrink-0 flex items-center justify-center text-[9px]" style="background:#F0F0FF;color:#6369D1"><jsp:include page="/common/profileImage.jsp"><jsp:param name="image" value="${mate.profileImg}"/><jsp:param name="nickname" value="${mate.nickname}"/></jsp:include></span><span class="text-gray-600 font-medium">
											<c:out value="${mate.nickname}" default="알 수 없음" />
										</span>

										<span class="text-[11px] text-gray-400">
											· ${mate.timeAgo}
										</span>

									</div>


									<!-- 통계 -->
									<div class="flex items-center gap-3 text-[11px] text-gray-400">

										<span class="flex items-center gap-1">
											♡ ${mate.likeCount}
										</span>

										<span class="flex items-center gap-1">
											<svg width="12" height="12" viewBox="0 0 24 24"
						fill="none" stroke="#9ca3af" stroke-width="2" aria-hidden="true">

                        <path stroke-linecap="round"
							stroke-linejoin="round" d="M7.9 20A9 9 0 1 0 4 16.1L2 22Z" />
                    	</svg> ${mate.commentCount}
										</span>

										<span class="flex items-center gap-1">

											<svg
												width="13"
												height="13"
												viewBox="0 0 24 24"
												fill="none"
												stroke="currentColor"
												stroke-width="2">

												<path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7S2 12 2 12Z" />
												<circle cx="12" cy="12" r="3" />

											</svg>

											${mate.viewCount}

										</span>

									</div>

								</div>

							</a>

						</c:forEach>

					</div>

				</c:when>


				<c:otherwise>

					<div class="py-10 px-4 text-center text-sm text-gray-400 border border-gray-100 rounded-2xl bg-white">
						검색된 여행 메이트가 없습니다.
					</div>

				</c:otherwise>

			</c:choose>

		</section>

	</main>

	<jsp:include page="/common/footer.jsp" />
	


<script>
(function () {
	// 클릭 이벤트
	document.addEventListener("click", function(event) {

		const button = event.target.closest("[data-schedule-bookmark]");

		if (!button) {
			return;
		}

		event.preventDefault();
		event.stopPropagation();

		/* 비로그인시 로그인 페이지로 처리.*/
		if (button.dataset.loggedIn !== "true") {
			window.location.href = button.dataset.loginUrl;
			return;
		}

		if (button.dataset.loading === "true") {
			return;
		}

		toggleBookmark(button);
	});

	async function toggleBookmark(button) {

		const itineraryId = button.dataset.itineraryId;
		const url = button.dataset.bookmarkUrl;

		if (!itineraryId || !url) {
			window.tripilyToast("북마크 요청 정보를 확인해주세요.");
			return;
		}

		button.dataset.loading = "true";
		button.disabled = true;
		button.setAttribute("aria-busy", "true");

		try {
			const params = new URLSearchParams();

			params.set("itineraryId", itineraryId);

			const response = await fetch(url, {
				method: "POST",
				credentials: "same-origin",
				headers: {
					"Content-Type": "application/x-www-form-urlencoded;charset=UTF-8",
					"Accept": "application/json"
				},
				body: params.toString()
			});

			const result = await response.json();

			if (!response.ok || result.success !== true) {
				throw new Error(result.message || "북마크 처리에 실패했습니다.");
			}

			if (typeof result.bookmarked !== "boolean") {
				throw new Error("서버 응답을 확인해주세요.");
			}

			updateBookmarkButton(button, result.bookmarked);

			window.tripilyToast(
				result.bookmarked ? "일정을 북마크했어요." : "북마크를 해제했어요."
			);

		} catch (error) {
			console.error(error);

			window.tripilyToast(
				error.message || "북마크 처리 중 오류가 발생했습니다."
			);

		} finally {
			delete button.dataset.loading;

			button.disabled = false;
			button.removeAttribute("aria-busy");
		}
	}

	function updateBookmarkButton(button, bookmarked) {

		button.setAttribute("aria-pressed", String(bookmarked));

		button.setAttribute("aria-label", bookmarked ? "북마크 해제" : "북마크 추가");

		const icon = button.querySelector("svg");

		if (icon) {
			icon.setAttribute("fill", bookmarked ? "#6369D1" : "none");
			icon.setAttribute("stroke", bookmarked ? "#6369D1" : "#9ca3af");
		}
	}


    document.querySelectorAll('.search-card-refresh .tip-card-summary').forEach(function (preview) {
        preview.textContent = preview.textContent.replace(/\[\[IMG:\d+\]\]/g, ' ').replace(/\s+/g, ' ').trim();
    });
})();
</script>
</body>
</html>