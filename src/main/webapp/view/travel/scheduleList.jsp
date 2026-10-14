<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%
request.setAttribute("activePage", "travel");
%>

<!DOCTYPE html>
<html lang="ko">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width,initial-scale=1">
	<link rel="stylesheet" href="${pageContext.request.contextPath}/view/assets/css/travel/scheduleList.css">
	<title>여행일정 | Planb</title>
	<jsp:include page="/common/headStyles.jsp" />
<style>
.schedule-infinite-scroll {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: 32px 0;
}

.schedule-scroll-status {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 8px;
}

.schedule-scroll-status[hidden],
.schedule-scroll-sentinel[hidden] {
    display: none;
}

.schedule-loading-spinner {
    width: 28px;
    height: 28px;
    border: 3px solid #e5e7eb;
    border-top-color: #6369d1;
    border-radius: 50%;
    animation: schedule-spin .7s linear infinite;
}

@keyframes schedule-spin {
    from { transform: rotate(0deg); }
    to { transform: rotate(360deg); }
}

.schedule-scroll-title {
    margin: 0;
    color: #6b7280;
    font-size: 12px;
    font-weight: 600;
}

.schedule-scroll-count {
    margin: 0;
    color: #9ca3af;
    font-size: 11px;
}

.schedule-scroll-complete .schedule-scroll-title {
    color: #6369d1;
    font-weight: 700;
}

.schedule-scroll-sentinel {
    width: 100%;
    height: 1px;
}


/* ================================
   최상단 이동 버튼 - 여행꿀팁과 동일
================================ */

.schedule-scroll-top-btn {
    position: fixed;

    right: clamp(16px, 2.5vw, 36px);
    bottom: clamp(20px, 3vw, 40px);

    width: clamp(44px, 4vw, 52px);
    height: clamp(44px, 4vw, 52px);

    display: flex;
    align-items: center;
    justify-content: center;

    border: 1px solid #e0e1ff;
    border-radius: 50%;

    background: #ffffff;
    color: #6369D1;

    box-shadow: 0 6px 20px rgba(99, 105, 209, 0.18);

    cursor: pointer;
    z-index: 100;

    opacity: 0;
    visibility: hidden;
    transform: translateY(10px);

    transition:
        opacity 0.25s ease,
        transform 0.25s ease,
        visibility 0.25s ease,
        background 0.2s ease;
}

.schedule-scroll-top-btn svg {
    width: 22px;
    height: 22px;
}

.schedule-scroll-top-btn.show {
    opacity: 1;
    visibility: visible;
    transform: translateY(0);
}

.schedule-scroll-top-btn:hover {
    background: #f0f1ff;
    transform: translateY(-2px);
}


@media (max-width: 720px) {
    .schedule-scroll-top-btn { right: 16px; bottom: 20px; width: 44px; height: 44px; }
}
.schedule-load-retry {
    margin-top: 8px;
    padding: 9px 14px;
    border: 1px solid #D1D2F9;
    border-radius: 10px;
    background: #fff;
    color: #6369D1;
    font: inherit;
    font-size: 12px;
    cursor: pointer;
}
.schedule-load-retry[hidden] { display: none; }
.schedule-load-retry:focus-visible, .schedule-scroll-top-btn:focus-visible {
    outline: 3px solid #D1D2F9;
    outline-offset: 3px;
}
.travel-list-sidebar .continent-panel { border-left: 0; }
#scheduleCardGrid .jsp-schedule-card { position: relative; cursor: pointer; }
#scheduleCardGrid .schedule-card-detail-link { position: static; }
#scheduleCardGrid .schedule-card-detail-link::after {
    content: "";
    position: absolute;
    inset: 0;
    z-index: 1;
    border-radius: 16px;
}
#scheduleCardGrid .schedule-card-detail-link:focus-visible::after {
    outline: 3px solid #6369D1;
    outline-offset: -3px;
}
#scheduleCardGrid [data-schedule-bookmark] { z-index: 2; }

</style>
</head>
<body class="site-shell">
	<jsp:include page="/common/header.jsp" />
	<div class="flex" style="min-height: calc(100vh - 68px)">
		<aside class="travel-list-sidebar shrink-0 w-48 flex-col gap-1 bg-white py-5 px-2 border-r overflow-y-auto" style="border-color: #ebebf5">
			<div class="text-xs font-bold text-gray-400 uppercase tracking-widest px-3 mb-1">여행 일정</div>
			<a href="${pageContext.request.contextPath}/profile/myProfile"
			class="flex items-center justify-between px-3 py-2.5 rounded-lg transition-colors group">
				<span class="flex items-center gap-2 text-sm font-semibold text-gray-700">
					<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
						<path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z" />
						<polyline points="14 2 14 8 20 8" />
					</svg>
					내가 작성한 글
				</span>
			</a>
			<div class="border-t border-gray-100 mb-3">
			</div>
			
			<!-- 전체보기 버튼 -->
			<a href="${pageContext.request.contextPath}/schedules"
			class="w-full flex items-center justify-between px-3 py-2.5 rounded-xl transition-all mb-1"
			style="background: #6369D1; color: #fff">
			    <span class="flex items-center gap-2 text-sm font-semibold">
			        <svg width="16" height="16"
			            viewBox="0 0 24 24"
			            fill="none"
			            stroke="#fff"
			            stroke-width="2">
			
			            <circle cx="12" cy="12" r="10" />
			            <line x1="2" y1="12" x2="22" y2="12" />
			            <path d="M12 2a15.3 15.3 0 0 1 4 10
			                     15.3 15.3 0 0 1-4 10
			                     15.3 15.3 0 0 1-4-10
			                     15.3 15.3 0 0 1 4-10z" />
			        </svg>
			        전체보기
			    </span>
			</a>
			
			<div class="text-xs font-bold text-gray-400 uppercase tracking-widest px-3 mb-1 mt-1">
				여행 지역
			</div>
			
			<div class="border-t border-gray-100 mb-3"></div>
			
			<div class="text-xs font-bold text-gray-400 uppercase tracking-widest px-3 mb-1">
				국가별 보기
			</div>
			
			<div>
				<!-- 아시아 버튼 -->
				<button type="button" class="continent-toggle w-full flex items-center justify-between px-3 py-2.5 rounded-xl transition-all" data-continent-toggle>
					<span class="flex items-center gap-2.5 text-sm font-semibold">
						<svg viewBox="0 0 48 48" width="24" height="24" aria-hidden="true">
							<path d="M10 8L18 5L27 6L36 9L40 15L37 21L40 27L34 32L29 38L22 40L17 35L11 34L7 27L6 19Z" fill="#6369D1" opacity=".88" />
						</svg>
						아시아
					</span>
					<svg class="continent-chevron w-3.5 h-3.5 shrink-0 transition-transform" viewBox="0 0 24 24" fill="none" stroke="#9ca3af" stroke-width="2.5">
						<path d="m6 9 6 6 6-6" />
					</svg>
				</button>
				<!-- 아시아 국가별 버튼 -->
				<div class="continent-panel ml-2 mb-1 flex-col gap-0.5 pl-3 pt-1">
					<button type="button" data-schedule-country="대한민국" class="text-left text-sm py-1.5 px-2 rounded-md text-gray-500 hover:text-[#6369D1]">🇰🇷 대한민국</button>
					<button type="button" data-schedule-country="일본" class="text-left text-sm py-1.5 px-2 rounded-md text-gray-500 hover:text-[#6369D1]">🇯🇵 일본</button>
					<button type="button" data-schedule-country="중국" class="text-left text-sm py-1.5 px-2 rounded-md text-gray-500 hover:text-[#6369D1]">🇨🇳 중국</button>
					<button type="button" data-schedule-country="대만" class="text-left text-sm py-1.5 px-2 rounded-md text-gray-500 hover:text-[#6369D1]">🇹🇼 대만</button>
					<button type="button" data-schedule-country="홍콩" class="text-left text-sm py-1.5 px-2 rounded-md text-gray-500 hover:text-[#6369D1]">🇭🇰 홍콩</button>
					<button type="button" data-schedule-country="태국" class="text-left text-sm py-1.5 px-2 rounded-md text-gray-500 hover:text-[#6369D1]">🇹🇭 태국</button>
					<button type="button" data-schedule-country="베트남" class="text-left text-sm py-1.5 px-2 rounded-md text-gray-500 hover:text-[#6369D1]">🇻🇳 베트남</button>
					<button type="button" data-schedule-country="필리핀" class="text-left text-sm py-1.5 px-2 rounded-md text-gray-500 hover:text-[#6369D1]">🇵🇭 필리핀</button>
					<button type="button" data-schedule-country="싱가포르" class="text-left text-sm py-1.5 px-2 rounded-md text-gray-500 hover:text-[#6369D1]">🇸🇬 싱가포르</button>
					<button type="button" data-schedule-country="말레이시아" class="text-left text-sm py-1.5 px-2 rounded-md text-gray-500 hover:text-[#6369D1]">🇲🇾 말레이시아</button>
					<button type="button" data-schedule-country="인도네시아" class="text-left text-sm py-1.5 px-2 rounded-md text-gray-500 hover:text-[#6369D1]">🇮🇩 인도네시아</button>
				</div>
			</div>
			
			<div>
				<!-- 유럽 버튼 -->
				<button type="button" class="continent-toggle w-full flex items-center justify-between px-3 py-2.5 rounded-xl transition-all" data-continent-toggle>
					<span class="flex items-center gap-2.5 text-sm font-semibold">
						<svg viewBox="0 0 48 48" width="24" height="24" aria-hidden="true">
							<path d="M10 8L18 5L27 6L36 9L40 15L37 21L40 27L34 32L29 38L22 40L17 35L11 34L7 27L6 19Z" fill="#8B5CF6" opacity=".88" />
						</svg>
						유럽
					</span>
					<svg class="continent-chevron w-3.5 h-3.5 shrink-0 transition-transform" viewBox="0 0 24 24" fill="none" stroke="#9ca3af" stroke-width="2.5">
						<path d="m6 9 6 6 6-6" />
					</svg>
				</button>
				<!-- 유럽 국가별 버튼 -->
				<div class="continent-panel ml-2 mb-1 flex-col gap-0.5 pl-3 pt-1">
					<button type="button" data-schedule-country="독일" class="text-left text-sm py-1.5 px-2 rounded-md text-gray-500 hover:text-[#6369D1]">🇩🇪 독일</button>
					<button type="button" data-schedule-country="포르투갈" class="text-left text-sm py-1.5 px-2 rounded-md text-gray-500 hover:text-[#6369D1]">🇵🇹 포르투갈</button>
					<button type="button" data-schedule-country="프랑스" class="text-left text-sm py-1.5 px-2 rounded-md text-gray-500 hover:text-[#6369D1]">🇫🇷 프랑스</button>
					<button type="button" data-schedule-country="그리스" class="text-left text-sm py-1.5 px-2 rounded-md text-gray-500 hover:text-[#6369D1]">🇬🇷 그리스</button>
					<button type="button" data-schedule-country="스페인" class="text-left text-sm py-1.5 px-2 rounded-md text-gray-500 hover:text-[#6369D1]">🇪🇸 스페인</button>
					<button type="button" data-schedule-country="영국" class="text-left text-sm py-1.5 px-2 rounded-md text-gray-500 hover:text-[#6369D1]">🇬🇧 영국</button>
					<button type="button" data-schedule-country="이탈리아" class="text-left text-sm py-1.5 px-2 rounded-md text-gray-500 hover:text-[#6369D1]">🇮🇹 이탈리아</button>
				</div>
			</div>
			
			<div>
				<!-- 북아메리카 버튼 -->
				<button type="button" class="continent-toggle w-full flex items-center justify-between px-3 py-2.5 rounded-xl transition-all" data-continent-toggle>
					<span class="flex items-center gap-2.5 text-sm font-semibold">
						<svg viewBox="0 0 48 48" width="24" height="24" aria-hidden="true">
							<path d="M10 8L18 5L27 6L36 9L40 15L37 21L40 27L34 32L29 38L22 40L17 35L11 34L7 27L6 19Z" fill="#10B981" opacity=".88" />
						</svg>
						북아메리카
					</span>
					<svg class="continent-chevron w-3.5 h-3.5 shrink-0 transition-transform" viewBox="0 0 24 24" fill="none" stroke="#9ca3af" stroke-width="2.5">
						<path d="m6 9 6 6 6-6" />
					</svg>
				</button>
				<!-- 북아메리카 국가별 버튼 -->
				<div class="continent-panel ml-2 mb-1 flex-col gap-0.5 pl-3 pt-1">
					<button type="button" data-schedule-country="멕시코" class="text-left text-sm py-1.5 px-2 rounded-md text-gray-500 hover:text-[#6369D1]">🇲🇽 멕시코</button>
					<button type="button" data-schedule-country="미국" class="text-left text-sm py-1.5 px-2 rounded-md text-gray-500 hover:text-[#6369D1]">🇺🇸 미국</button>
					<button type="button" data-schedule-country="캐나다" class="text-left text-sm py-1.5 px-2 rounded-md text-gray-500 hover:text-[#6369D1]">🇨🇦 캐나다</button>
				</div>
			</div>
			
			<div>
				<!-- 남아메리카 버튼 -->
				<button type="button" class="continent-toggle w-full flex items-center justify-between px-3 py-2.5 rounded-xl transition-all" data-continent-toggle>
					<span class="flex items-center gap-2.5 text-sm font-semibold">
						<svg viewBox="0 0 48 48" width="24" height="24" aria-hidden="true">
							<path d="M10 8L18 5L27 6L36 9L40 15L37 21L40 27L34 32L29 38L22 40L17 35L11 34L7 27L6 19Z" fill="#F59E0B" opacity=".88" />
						</svg>
						남아메리카
					</span>
					<svg class="continent-chevron w-3.5 h-3.5 shrink-0 transition-transform" viewBox="0 0 24 24" fill="none" stroke="#9ca3af" stroke-width="2.5">
						<path d="m6 9 6 6 6-6" />
					</svg>
				</button>
				<!-- 남아메리카 국가별 버튼 -->
				<div class="continent-panel ml-2 mb-1 flex-col gap-0.5 pl-3 pt-1">
					<button type="button" data-schedule-country="브라질" class="text-left text-sm py-1.5 px-2 rounded-md text-gray-500 hover:text-[#6369D1]">🇧🇷 브라질</button>
					<button type="button" data-schedule-country="아르헨티나" class="text-left text-sm py-1.5 px-2 rounded-md text-gray-500 hover:text-[#6369D1]">🇦🇷 아르헨티나</button>
					<button type="button" data-schedule-country="칠레" class="text-left text-sm py-1.5 px-2 rounded-md text-gray-500 hover:text-[#6369D1]">🇨🇱 칠레</button>
					<button type="button" data-schedule-country="페루" class="text-left text-sm py-1.5 px-2 rounded-md text-gray-500 hover:text-[#6369D1]">🇵🇪 페루</button>
				</div>
			</div>
			
			<div>
				<!-- 아프리카 버튼 -->
				<button type="button" class="continent-toggle w-full flex items-center justify-between px-3 py-2.5 rounded-xl transition-all" data-continent-toggle>
					<span class="flex items-center gap-2.5 text-sm font-semibold">
						<svg viewBox="0 0 48 48" width="24" height="24" aria-hidden="true">
							<path d="M10 8L18 5L27 6L36 9L40 15L37 21L40 27L34 32L29 38L22 40L17 35L11 34L7 27L6 19Z" fill="#EF4444" opacity=".88" />
						</svg>
						아프리카
					</span>
					<svg class="continent-chevron w-3.5 h-3.5 shrink-0 transition-transform" viewBox="0 0 24 24" fill="none" stroke="#9ca3af" stroke-width="2.5">
						<path d="m6 9 6 6 6-6" />
					</svg>
				</button>
				<!-- 아프리카 국가별 버튼 -->
				<div class="continent-panel ml-2 mb-1 flex-col gap-0.5 pl-3 pt-1">
					<button type="button" data-schedule-country="남아프리카" class="text-left text-sm py-1.5 px-2 rounded-md text-gray-500 hover:text-[#6369D1]">🇿🇦 남아프리카</button>
					<button type="button" data-schedule-country="모로코" class="text-left text-sm py-1.5 px-2 rounded-md text-gray-500 hover:text-[#6369D1]">🇲🇦 모로코</button>
					<button type="button" data-schedule-country="이집트" class="text-left text-sm py-1.5 px-2 rounded-md text-gray-500 hover:text-[#6369D1]">🇪🇬 이집트</button>
					<button type="button" data-schedule-country="케냐" class="text-left text-sm py-1.5 px-2 rounded-md text-gray-500 hover:text-[#6369D1]">🇰🇪 케냐</button>
				</div>
			</div>
			
			<div>
				<!-- 오세아니아 버튼 -->
				<button type="button" class="continent-toggle w-full flex items-center justify-between px-3 py-2.5 rounded-xl transition-all" data-continent-toggle>
					<span class="flex items-center gap-2.5 text-sm font-semibold">
						<svg viewBox="0 0 48 48" width="24" height="24" aria-hidden="true">
							<path d="M10 8L18 5L27 6L36 9L40 15L37 21L40 27L34 32L29 38L22 40L17 35L11 34L7 27L6 19Z" fill="#06B6D4" opacity=".88" />
						</svg>
						오세아니아
					</span>
					<svg class="continent-chevron w-3.5 h-3.5 shrink-0 transition-transform" viewBox="0 0 24 24" fill="none" stroke="#9ca3af" stroke-width="2.5">
						<path d="m6 9 6 6 6-6" />
					</svg>
				</button>
				<!-- 오세아니아 국가별 버튼 -->
				<div class="continent-panel ml-2 mb-1 flex-col gap-0.5 pl-3 pt-1">
					<button type="button" data-schedule-country="뉴질랜드" class="text-left text-sm py-1.5 px-2 rounded-md text-gray-500 hover:text-[#6369D1]">🇳🇿 뉴질랜드</button>
					<button type="button" data-schedule-country="피지" class="text-left text-sm py-1.5 px-2 rounded-md text-gray-500 hover:text-[#6369D1]">🇫🇯 피지</button>
					<button type="button" data-schedule-country="호주" class="text-left text-sm py-1.5 px-2 rounded-md text-gray-500 hover:text-[#6369D1]">🇦🇺 호주</button>
				</div>
			</div>
			
			<div>
				<!-- 중동 버튼 -->
				<button type="button" class="continent-toggle w-full flex items-center justify-between px-3 py-2.5 rounded-xl transition-all" data-continent-toggle>
					<span class="flex items-center gap-2.5 text-sm font-semibold">
						<svg viewBox="0 0 48 48" width="24" height="24" aria-hidden="true">
							<path d="M10 8L18 5L27 6L36 9L40 15L37 21L40 27L34 32L29 38L22 40L17 35L11 34L7 27L6 19Z" fill="#D97706" opacity=".88" />
						</svg>
						중동
					</span>
					<svg class="continent-chevron w-3.5 h-3.5 shrink-0 transition-transform" viewBox="0 0 24 24" fill="none" stroke="#9ca3af" stroke-width="2.5">
						<path d="m6 9 6 6 6-6" />
					</svg>
				</button>
				<!-- 중동 국가별 버튼 -->
				<div class="continent-panel ml-2 mb-1 flex-col gap-0.5 pl-3 pt-1">
					<button type="button" data-schedule-country="UAE" class="text-left text-sm py-1.5 px-2 rounded-md text-gray-500 hover:text-[#6369D1]">🇦🇪 UAE</button>
					<button type="button" data-schedule-country="이스라엘" class="text-left text-sm py-1.5 px-2 rounded-md text-gray-500 hover:text-[#6369D1]">🇮🇱 이스라엘</button>
					<button type="button" data-schedule-country="터키" class="text-left text-sm py-1.5 px-2 rounded-md text-gray-500 hover:text-[#6369D1]">🇹🇷 터키</button>
				</div>
			</div>
		</aside>
		
		<main class="flex-1 px-6 py-8 min-w-0">
			<form id="scheduleSearchForm"
      			action="${pageContext.request.contextPath}/schedules"
      			method="get"
      			class="mb-6 relative max-w-2xl">
      			
      			<input type="hidden"
       				id="scheduleCountry"
       				name="country"
       				value="<c:out value='${country}'/>">
       				
       			<input type="hidden"
       				id="scheduleSort"
       				name="sort"
       				value="<c:out value='${sort}'/>">
       			
       			<!-- 일정 검색창 -->	
				<div id="scheduleSearchBar"
					class="flex items-center gap-2.5 bg-white border-2 rounded-xl px-4 py-2.5 shadow-sm transition-all cursor-text"
					style="border-color: #D1D2F9">
					<svg class="w-4 h-4 shrink-0" style="color: #94a3b8" fill="none"
						stroke="currentColor" viewBox="0 0 24 24">
						<path stroke-linecap="round" stroke-linejoin="round"
							stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" /></svg>
					<input type="text" id="scheduleKeyword" name="keyword" value="<c:out value='${keyword}'/>"
   						class="flex-1 text-[13px] outline-none text-gray-800 placeholder-gray-400 bg-transparent"
    					placeholder="제목, 닉네임, 인원, 예산 검색">
    				<!-- 상세 조회 버튼 -->
					<button type="button"
        					id="scheduleFilterToggle"
        					aria-expanded="false"
        					aria-controls="scheduleFilterPanel"
        					class="shrink-0 flex items-center gap-1 text-[11px] font-medium transition-colors"
        					style="color: #94a3b8">
						<svg class="w-4 h-4 transition-transform" fill="none"
							stroke="currentColor" viewBox="0 0 24 24">
							<path stroke-linecap="round" stroke-linejoin="round"
								stroke-width="2" d="M19 9l-7 7-7-7" /></svg>
						상세조건
					</button>
				</div>
				<!-- 상세 조회 패널 -->
				<div id="scheduleFilterPanel"
					class="hidden absolute left-0 right-0 top-full mt-1.5 bg-white border rounded-2xl shadow-xl z-30 overflow-hidden"
					style="border-color: #D1D2F9">
					<div class="p-5 grid grid-cols-3 gap-6 border-b"
						style="border-color: #D1D2F9">
						<div>
							<p class="text-[10px] font-bold text-gray-500 uppercase tracking-wider mb-3">여행 기간</p>
							<div class="flex flex-col gap-2">
    							<label class="flex items-center gap-2.5 cursor-pointer">
        							<input type="checkbox" name="durations" value="1">
        							<span class="text-[12px]">당일치기</span>
    							</label>		

    							<label class="flex items-center gap-2.5 cursor-pointer">
        							<input type="checkbox" name="durations" value="2">
        							<span class="text-[12px]">1박 2일</span>
    							</label>
				
    							<label class="flex items-center gap-2.5 cursor-pointer">
        							<input type="checkbox" name="durations" value="3">
        							<span class="text-[12px]">2박 3일</span>
    							</label>

    							<label class="flex items-center gap-2.5 cursor-pointer">
        							<input type="checkbox" name="durations" value="4">
        							<span class="text-[12px]">3박 4일</span>
    							</label>

    							<label class="flex items-center gap-2.5 cursor-pointer">
        							<input type="checkbox" name="durations" value="5">
        							<span class="text-[12px]">4박 5일</span>
    							</label>
    							
    							<label class="flex items-center gap-2.5 cursor-pointer">
        							<input type="checkbox" name="durations" value="6">
        							<span class="text-[12px]">5박 이상</span>
    							</label>
							</div>
						</div>
						
						<div>
							<p class="text-[10px] font-bold text-gray-500 uppercase tracking-wider mb-3">여행 인원</p>
							<div class="flex flex-col gap-2">
    							<label class="flex items-center gap-2.5 cursor-pointer">
        							<input type="checkbox" name="travelers" value="1">
        							<span class="text-[12px]">1인</span>
    							</label>

    							<label class="flex items-center gap-2.5 cursor-pointer">
        							<input type="checkbox" name="travelers" value="2">
        							<span class="text-[12px]">2인</span>
    							</label>
		
    							<label class="flex items-center gap-2.5 cursor-pointer">
        							<input type="checkbox" name="travelers" value="3">
        							<span class="text-[12px]">3인</span>
    							</label>

    							<label class="flex items-center gap-2.5 cursor-pointer">
        							<input type="checkbox" name="travelers" value="4">
        							<span class="text-[12px]">4인</span>
    							</label>
	
							    <label class="flex items-center gap-2.5 cursor-pointer">
        							<input type="checkbox" name="travelers" value="5">
        							<span class="text-[12px]">5인</span>
    							</label>
			
    							<label class="flex items-center gap-2.5 cursor-pointer">
        							<input type="checkbox" name="travelers" value="6">
        							<span class="text-[12px]">6인 이상</span>
    							</label>
		
							</div>
						</div>
						<div>
							<p class="text-[10px] font-bold text-gray-500 uppercase tracking-wider mb-3">여행 경비</p>
							<div class="flex flex-col gap-2">
								<label class="flex items-center gap-2.5 cursor-pointer">
									<input type="checkbox" name="budgets" value="1">
									<span class="text-[12px]">100만원 이하</span>
								</label>
								
								<label class="flex items-center gap-2.5 cursor-pointer">
									<input type="checkbox" name="budgets" value="2">
									<span class="text-[12px]">100만원 초과~200만원 이하</span>
    							</label>
    							
    							<label class="flex items-center gap-2.5 cursor-pointer">
	        						<input type="checkbox" name="budgets" value="3">
        							<span class="text-[12px]">200만원 초과~300만원 이하</span>
    							</label>
    							
    							<label class="flex items-center gap-2.5 cursor-pointer">
	        						<input type="checkbox" name="budgets" value="4">
        							<span class="text-[12px]">300만원 초과~400만원 이하</span>
    							</label>
    							
    							<label class="flex items-center gap-2.5 cursor-pointer">
	        						<input type="checkbox" name="budgets" value="5">
        							<span class="text-[12px]">400만원 초과~500만원 이하</span>
    							</label>
    							
    							<label class="flex items-center gap-2.5 cursor-pointer">
	        						<input type="checkbox" name="budgets" value="6">
        							<span class="text-[12px]">500만원 초과</span>
    							</label>
							</div>
						</div>
					</div>
					<div
						class="px-5 py-3.5 flex items-center justify-between bg-gray-50">
						<button type="button" id="scheduleFilterReset" class="text-[12px] text-gray-400 hover:text-gray-600 font-medium flex items-center gap-1.5">
    						초기화
						</button>
						<button type="submit"
							class="px-6 py-2 text-[12px] font-bold text-white rounded-xl"
							style="background: #6369D1">검색하기</button>
					</div>
				</div>
			</form>
			
			<!-- 최신순, 조회순, 좋아요순 정렬 버튼 -->
			<div class="flex items-center justify-between mb-5">
				<p class="text-[12px] font-medium text-gray-500">
    				총
    				<span class="font-bold" style="color: #6369D1">
        				<fmt:formatNumber value="${totalCount}" pattern="#,##0" />
    				</span>
    				개의 여행 일정
				</p>
				
				<div class="flex gap-4">
					<button type="button" data-schedule-sort="latest" class="text-sm pb-0.5 transition-colors">
						최신순
    				</button>

    				<button type="button" data-schedule-sort="views" class="text-sm pb-0.5 transition-colors">
        				조회순
    				</button>
				
    				<button type="button" data-schedule-sort="likes" class="text-sm pb-0.5 transition-colors">
        				인기순
    				</button>
				</div>
			</div>
			
			<!-- 일정 카드 표시 공간 -->
			<div id="scheduleCardGrid" class="grid gap-5" style="grid-template-columns: repeat(4, minmax(0, 1fr))">
				<!-- 카드 목록 -->
				<jsp:include page="/view/travel/scheduleCards.jsp" />
				
				<c:if test="${empty scheduleList}">
    				<div style="grid-column: 1 / -1;" class="py-12 text-center text-gray-500 text-sm">
        				조건에 맞는 여행 일정이 없습니다.
    				</div>
				</c:if>

			</div>
		

            <!-- 카트와 동일한 로딩·완료 표시 -->
            <div id="scheduleInfiniteScroll" class="schedule-infinite-scroll"
                data-load-url="${pageContext.request.contextPath}/schedules/load"
                data-loaded-count="${fn:length(scheduleList)}"
                data-total-count="${totalCount}">
                <div id="scheduleLoading" class="schedule-scroll-status" role="status" hidden>
                    <div class="schedule-loading-spinner" aria-hidden="true"></div>
                    <p class="schedule-scroll-title">여행 일정을 불러오는 중...</p>
                    <p class="schedule-scroll-count">
                        <span id="scheduleCurrentCount">${fn:length(scheduleList)}</span>
                        / 총 <span>${totalCount}</span>개
                    </p>
                </div>
                <button type="button" id="scheduleLoadRetry" class="schedule-load-retry" hidden>
                    불러오지 못했습니다. 다시 시도
                </button>
                <div id="scheduleLoadComplete" class="schedule-scroll-status schedule-scroll-complete" role="status" hidden>
                    <p class="schedule-scroll-title">모든 여행 일정을 확인했습니다 ✓</p>
                    <p class="schedule-scroll-count">
                        <span id="scheduleCompleteCount">${fn:length(scheduleList)}</span>
                        / 총 ${totalCount}개
                    </p>
                </div>
                <div id="scheduleScrollSentinel" class="schedule-scroll-sentinel" aria-hidden="true"></div>
            </div>

		</main>
	</div>
<button type="button" id="scheduleScrollTopBtn" class="schedule-scroll-top-btn" aria-label="페이지 최상단으로 이동">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" aria-hidden="true">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.2" d="M12 19V5M5 12l7-7 7 7" />
    </svg>
</button>
	<script
		src="${pageContext.request.contextPath}/view/assets/js/auth/tripily.js">
	</script>
	<script
		src="${pageContext.request.contextPath}/view/assets/js/travel/scheduleList.js?v=10">
	</script>
</body>
</html>