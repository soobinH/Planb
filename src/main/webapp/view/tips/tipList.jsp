<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%
request.setAttribute("activePage", "tips");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<title>Planb</title>
	<jsp:include page="/common/headStyles.jsp" />
	<script>
		window.selectedCountry = "${country}";
	</script>
	<link rel="stylesheet" href="${pageContext.request.contextPath}/view/assets/css/tips/tipList.css?v=20261016-highlight">
	<script defer src="${pageContext.request.contextPath}/view/assets/js/tips/tipList.js"></script>
</head>
<body class="site-shell tip-list-page">
	<jsp:include page="/common/header.jsp" />
	<div class="tips-page-layout">
		<div class="flex" style="min-height: calc(100vh - 68px)">
		<aside class="tip-list-sidebar shrink-0 w-48 flex-col gap-1 bg-white py-5 px-2 border-r overflow-y-auto" style="border-color: #ebebf5">
				<div class="text-xs font-bold text-gray-400 uppercase tracking-widest px-3 mb-1">여행 꿀팁</div>
				<a href="${pageContext.request.contextPath}/tipWriteList"
					class="flex items-center justify-between px-3 py-2.5 rounded-lg transition-colors group">
					<span class="flex items-center gap-2 text-sm font-semibold text-gray-700">
						<svg width="16" height="16" viewBox="0 0 24 24" fill="none"
							 stroke="currentColor" stroke-width="2">
							<path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z" />
							<polyline points="14 2 14 8 20 8" />
						</svg>
						내가 작성한 글
					</span>
				</a>
				
				<div class="border-t border-gray-100 mb-3"></div>
				
				<a href="${pageContext.request.contextPath}/tips"
					class="w-full flex items-center justify-between px-3 py-2.5 rounded-xl transition-all mb-1"
					style="background: var(--brand); color: #fff;">
					<span class="flex items-center gap-2 text-sm font-semibold">
						<svg width="16" height="16"
							viewBox="0 0 24 24"
							fill="none"
							stroke="#fff"
							stroke-width="2">
							<circle cx="12" cy="12" r="10" />
							<line x1="2" y1="12" x2="22" y2="12" />
							<path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z" />
						</svg>
						전체보기
					</span>
				</a>
				
				<div class="border-t border-gray-100 mb-3"></div>
				
				<div class="text-xs font-bold text-gray-400 uppercase tracking-widest px-3 mb-1">국가별 보기</div>
				
				<div>
					<button type="button" class="continent-toggle w-full flex items-center justify-between px-3 py-2.5 rounded-xl transition-all"
						data-continent-toggle="asia">
						<span class="flex items-center gap-2.5 text-sm font-semibold">
							<img src="${pageContext.request.contextPath}/view/assets/images/continent/asia_silhouette.png" alt="" aria-hidden="true" class="w-5 h-5 shrink-0 object-contain">
							아시아
						</span>
						<svg class="continent-chevron w-3.5 h-3.5 shrink-0 transition-transform" viewBox="0 0 24 24" fill="none" stroke="#9ca3af" stroke-width="2.5">
							<path d="m6 9 6 6 6-6" />
						</svg>
					</button>
					<div class="continent-panel hidden pl-8 pr-2 py-1 space-y-1" data-continent-panel="asia">
						<a href="${pageContext.request.contextPath}/tips?country=대한민국&sort=${sort}"
							class="block w-full text-left px-3 py-2 rounded-lg text-sm text-gray-600 hover:bg-indigo-50 hover:text-indigo-600">
							🇰🇷 대한민국
						</a>
						<a href="${pageContext.request.contextPath}/tips?country=일본&sort=${sort}"
							class="block w-full text-left px-3 py-2 rounded-lg text-sm text-gray-600 hover:bg-indigo-50 hover:text-indigo-600">
							🇯🇵 일본
						</a>
						<a href="${pageContext.request.contextPath}/tips?country=중국&sort=${sort}"
							class="block w-full text-left px-3 py-2 rounded-lg text-sm text-gray-600 hover:bg-indigo-50 hover:text-indigo-600">
							🇨🇳 중국
						</a>
						<a href="${pageContext.request.contextPath}/tips?country=대만&sort=${sort}"
							class="block w-full text-left px-3 py-2 rounded-lg text-sm text-gray-600 hover:bg-indigo-50 hover:text-indigo-600">
							🇹🇼 대만
						</a>
						<a href="${pageContext.request.contextPath}/tips?country=홍콩&sort=${sort}"
							class="block w-full text-left px-3 py-2 rounded-lg text-sm text-gray-600 hover:bg-indigo-50 hover:text-indigo-600">
							🇭🇰 홍콩
						</a>
						<a href="${pageContext.request.contextPath}/tips?country=태국&sort=${sort}"
							class="block w-full text-left px-3 py-2 rounded-lg text-sm text-gray-600 hover:bg-indigo-50 hover:text-indigo-600">
							🇹🇭 태국
						</a>
						<a href="${pageContext.request.contextPath}/tips?country=베트남&sort=${sort}"
							class="block w-full text-left px-3 py-2 rounded-lg text-sm text-gray-600 hover:bg-indigo-50 hover:text-indigo-600">
							🇻🇳 베트남
						</a>
						<a href="${pageContext.request.contextPath}/tips?country=필리핀&sort=${sort}"
							class="block w-full text-left px-3 py-2 rounded-lg text-sm text-gray-600 hover:bg-indigo-50 hover:text-indigo-600">
							🇵🇭 필리핀
						</a>
						<a href="${pageContext.request.contextPath}/tips?country=싱가포르&sort=${sort}"
							class="block w-full text-left px-3 py-2 rounded-lg text-sm text-gray-600 hover:bg-indigo-50 hover:text-indigo-600">
							🇸🇬 싱가포르
						</a>
						<a href="${pageContext.request.contextPath}/tips?country=말레이시아&sort=${sort}"
							class="block w-full text-left px-3 py-2 rounded-lg text-sm text-gray-600 hover:bg-indigo-50 hover:text-indigo-600">
							🇲🇾 말레이시아
						</a>
						<a href="${pageContext.request.contextPath}/tips?country=인도네시아&sort=${sort}"
							class="block w-full text-left px-3 py-2 rounded-lg text-sm text-gray-600 hover:bg-indigo-50 hover:text-indigo-600">
							🇮🇩 인도네시아
						</a>
					</div>
				</div>
				<!-- 유럽 -->
				<div>
					<button type="button" class="continent-toggle w-full flex items-center justify-between px-3 py-2.5 rounded-xl transition-all"
						data-continent-toggle="europe">
						<span class="flex items-center gap-2.5 text-sm font-semibold">
							<img src="${pageContext.request.contextPath}/view/assets/images/continent/europe_silhouette.png" alt="" aria-hidden="true" class="w-5 h-5 shrink-0 object-contain">
							유럽
						</span>
						<svg class="continent-chevron w-3.5 h-3.5 shrink-0 transition-transform" viewBox="0 0 24 24" fill="none" stroke="#9ca3af"
							stroke-width="2.5">
							<path d="m6 9 6 6 6-6" />
						</svg>
					</button>
					<div class="continent-panel hidden pl-8 pr-2 py-1 space-y-1"data-continent-panel="europe">
						<a href="${pageContext.request.contextPath}/tips?country=독일&sort=${sort}"
							class="block w-full text-left px-3 py-2 rounded-lg text-sm text-gray-600 hover:bg-indigo-50 hover:text-indigo-600">
							🇩🇪 독일
						</a>
						<a href="${pageContext.request.contextPath}/tips?country=포르투갈&sort=${sort}"
							class="block w-full text-left px-3 py-2 rounded-lg text-sm text-gray-600 hover:bg-indigo-50 hover:text-indigo-600">
							🇵🇹 포르투갈
						</a>
						<a href="${pageContext.request.contextPath}/tips?country=프랑스&sort=${sort}"
							class="block w-full text-left px-3 py-2 rounded-lg text-sm text-gray-600 hover:bg-indigo-50 hover:text-indigo-600">
							🇫🇷 프랑스
						</a>
						<a href="${pageContext.request.contextPath}/tips?country=그리스&sort=${sort}"
							class="block w-full text-left px-3 py-2 rounded-lg text-sm text-gray-600 hover:bg-indigo-50 hover:text-indigo-600">
							🇬🇷 그리스
						</a>
						<a href="${pageContext.request.contextPath}/tips?country=스페인&sort=${sort}"
							class="block w-full text-left px-3 py-2 rounded-lg text-sm text-gray-600 hover:bg-indigo-50 hover:text-indigo-600">
							🇪🇸 스페인
						</a>
						<a href="${pageContext.request.contextPath}/tips?country=영국&sort=${sort}"
							class="block w-full text-left px-3 py-2 rounded-lg text-sm text-gray-600 hover:bg-indigo-50 hover:text-indigo-600">
							🇬🇧 영국
						</a>
						<a href="${pageContext.request.contextPath}/tips?country=이탈리아&sort=${sort}"
							class="block w-full text-left px-3 py-2 rounded-lg text-sm text-gray-600 hover:bg-indigo-50 hover:text-indigo-600">
							🇮🇹 이탈리아
						</a>
					</div>
				</div>
				<!-- 북아메리카 -->
				<div>
					<button type="button" class="continent-toggle w-full flex items-center justify-between px-3 py-2.5 rounded-xl transition-all"
						data-continent-toggle="north-america">
						<span class="flex items-center gap-2.5 text-sm font-semibold">
							<img src="${pageContext.request.contextPath}/view/assets/images/continent/north_america_silhouette.png" alt="" aria-hidden="true" class="w-5 h-5 shrink-0 object-contain">
							북아메리카
						</span>
						<svg class="continent-chevron w-3.5 h-3.5 shrink-0 transition-transform" viewBox="0 0 24 24" fill="none" stroke="#9ca3af"
							stroke-width="2.5">
							<path d="m6 9 6 6 6-6" />
						</svg>
					</button>
					<div class="continent-panel hidden pl-8 pr-2 py-1 space-y-1" data-continent-panel="north-america">
						<a href="${pageContext.request.contextPath}/tips?country=멕시코&sort=${sort}"
							class="block w-full text-left px-3 py-2 rounded-lg text-sm text-gray-600 hover:bg-indigo-50 hover:text-indigo-600">
							🇲🇽 멕시코
						</a>
						<a href="${pageContext.request.contextPath}/tips?country=미국&sort=${sort}"
							class="block w-full text-left px-3 py-2 rounded-lg text-sm text-gray-600 hover:bg-indigo-50 hover:text-indigo-600">
							🇺🇸 미국
						</a>
						<a href="${pageContext.request.contextPath}/tips?country=캐나다&sort=${sort}"
							class="block w-full text-left px-3 py-2 rounded-lg text-sm text-gray-600 hover:bg-indigo-50 hover:text-indigo-600">
							🇨🇦 캐나다
						</a>
					</div>
				</div>
				<!-- 남아메리카 -->
				<div>
					<button type="button" class="continent-toggle w-full flex items-center justify-between px-3 py-2.5 rounded-xl transition-all"
						data-continent-toggle="south-america">
						<span class="flex items-center gap-2.5 text-sm font-semibold">
							<img src="${pageContext.request.contextPath}/view/assets/images/continent/south_america_silhouette.png" alt="" aria-hidden="true" class="w-5 h-5 shrink-0 object-contain">
							남아메리카
						</span>
						<svg class="continent-chevron w-3.5 h-3.5 shrink-0 transition-transform" viewBox="0 0 24 24" fill="none" stroke="#9ca3af"
							stroke-width="2.5">
							<path d="m6 9 6 6 6-6" />
						</svg>
					</button>
					<div class="continent-panel hidden pl-8 pr-2 py-1 space-y-1" data-continent-panel="south-america">
						<a href="${pageContext.request.contextPath}/tips?country=브라질&sort=${sort}"
							class="block w-full text-left px-3 py-2 rounded-lg text-sm text-gray-600 hover:bg-indigo-50 hover:text-indigo-600">
							🇧🇷 브라질
						</a>
						<a href="${pageContext.request.contextPath}/tips?country=아르헨티나&sort=${sort}"
							class="block w-full text-left px-3 py-2 rounded-lg text-sm text-gray-600 hover:bg-indigo-50 hover:text-indigo-600">
							🇦🇷 아르헨티나
						</a>
						<a href="${pageContext.request.contextPath}/tips?country=칠레&sort=${sort}"
							class="block w-full text-left px-3 py-2 rounded-lg text-sm text-gray-600 hover:bg-indigo-50 hover:text-indigo-600">
							🇨🇱 칠레
						</a>
						<a href="${pageContext.request.contextPath}/tips?country=페루&sort=${sort}"
							class="block w-full text-left px-3 py-2 rounded-lg text-sm text-gray-600 hover:bg-indigo-50 hover:text-indigo-600">
							🇵🇪 페루
						</a>
					</div>
				</div>
				<!-- 아프리카 -->
				<div>
					<button type="button" class="continent-toggle w-full flex items-center justify-between px-3 py-2.5 rounded-xl transition-all"
						data-continent-toggle="africa">
						<span class="flex items-center gap-2.5 text-sm font-semibold">
							<img src="${pageContext.request.contextPath}/view/assets/images/continent/africa_silhouette.png" alt="" aria-hidden="true" class="w-5 h-5 shrink-0 object-contain">
							아프리카
						</span> 
						<svg class="continent-chevron w-3.5 h-3.5 shrink-0 transition-transform" viewBox="0 0 24 24" fill="none" stroke="#9ca3af"
							stroke-width="2.5">
							<path d="m6 9 6 6 6-6" />
						</svg>
					</button> 
					<div class="continent-panel hidden pl-8 pr-2 py-1 space-y-1" data-continent-panel="africa">
						<a href="${pageContext.request.contextPath}/tips?country=남아프리카&sort=${sort}"
							class="block w-full text-left px-3 py-2 rounded-lg text-sm text-gray-600 hover:bg-indigo-50 hover:text-indigo-600">
							🇿🇦 남아프리카
						</a>
						<a href="${pageContext.request.contextPath}/tips?country=모르코&sort=${sort}"
							class="block w-full text-left px-3 py-2 rounded-lg text-sm text-gray-600 hover:bg-indigo-50 hover:text-indigo-600">
							🇲🇦 모로코
						</a>
						<a href="${pageContext.request.contextPath}/tips?country=이집트&sort=${sort}"
							class="block w-full text-left px-3 py-2 rounded-lg text-sm text-gray-600 hover:bg-indigo-50 hover:text-indigo-600">
							🇪🇬 이집트
						</a>
						<a href="${pageContext.request.contextPath}/tips?country=케냐&sort=${sort}"
							class="block w-full text-left px-3 py-2 rounded-lg text-sm text-gray-600 hover:bg-indigo-50 hover:text-indigo-600">
							🇰🇪 케냐
						</a>
					</div>
				</div>
				<!-- 오세아니아 -->
				<div>
					<button type="button" class="continent-toggle w-full flex items-center justify-between px-3 py-2.5 rounded-xl transition-all"
						data-continent-toggle="oceania">
						<span class="flex items-center gap-2.5 text-sm font-semibold">
							<img src="${pageContext.request.contextPath}/view/assets/images/continent/oceania_silhouette.png" alt="" aria-hidden="true" class="w-5 h-5 shrink-0 object-contain">
							오세아니아
						</span>
						<svg class="continent-chevron w-3.5 h-3.5 shrink-0 transition-transform" viewBox="0 0 24 24" fill="none" stroke="#9ca3af"
							stroke-width="2.5">
							<path d="m6 9 6 6 6-6" />
						</svg>
					</button>
					<div class="continent-panel hidden pl-8 pr-2 py-1 space-y-1" data-continent-panel="oceania">
						<a href="${pageContext.request.contextPath}/tips?country=뉴질랜드&sort=${sort}"
							class="block w-full text-left px-3 py-2 rounded-lg text-sm text-gray-600 hover:bg-indigo-50 hover:text-indigo-600">
							🇳🇿 뉴질랜드
						</a>
						<a href="${pageContext.request.contextPath}/tips?country=피지&sort=${sort}"
							class="block w-full text-left px-3 py-2 rounded-lg text-sm text-gray-600 hover:bg-indigo-50 hover:text-indigo-600">
							🇫🇯 피지
						</a>
						<a href="${pageContext.request.contextPath}/tips?country=호주&sort=${sort}"
							class="block w-full text-left px-3 py-2 rounded-lg text-sm text-gray-600 hover:bg-indigo-50 hover:text-indigo-600">
							🇦🇺 호주
						</a>
					</div>
				</div>
				<!-- 중동 -->
				<div>
					<button type="button" class="continent-toggle w-full flex items-center justify-between px-3 py-2.5 rounded-xl transition-all"
						data-continent-toggle="middle-east">
						<span class="flex items-center gap-2.5 text-sm font-semibold">
							<img src="${pageContext.request.contextPath}/view/assets/images/continent/middle_east_silhouette.png" alt="" aria-hidden="true" class="w-5 h-5 shrink-0 object-contain">
							중동
						</span>
						<svg class="continent-chevron w-3.5 h-3.5 shrink-0 transition-transform" viewBox="0 0 24 24" fill="none" stroke="#9ca3af"
							stroke-width="2.5">
							<path d="m6 9 6 6 6-6" />
						</svg>
					</button>
					<div class="continent-panel hidden pl-8 pr-2 py-1 space-y-1" data-continent-panel="middle-east">
						<a href="${pageContext.request.contextPath}/tips?country=아랍에미리트&sort=${sort}"
							class="block w-full text-left px-3 py-2 rounded-lg text-sm text-gray-600 hover:bg-indigo-50 hover:text-indigo-600">
							🇦🇪 UAE
						</a>
						<a href="${pageContext.request.contextPath}/tips?country=이스라엘&sort=${sort}"
							class="block w-full text-left px-3 py-2 rounded-lg text-sm text-gray-600 hover:bg-indigo-50 hover:text-indigo-600">
							🇮🇱 이스라엘
						</a>
						<a href="${pageContext.request.contextPath}/tips?country=터키&sort=${sort}"
							class="block w-full text-left px-3 py-2 rounded-lg text-sm text-gray-600 hover:bg-indigo-50 hover:text-indigo-600">
							🇹🇷 터키
						</a>
					</div>
				</div>
			</aside>
			<main class="flex-1 px-6 py-8 min-w-0">
				<!-- 여행꿀팁 검색 -->
				<form action="${pageContext.request.contextPath}/tips" method="get" class="mb-6 relative w-full max-w-2xl">
					<input type="hidden" name="country" value="${country}">
					<input type="hidden" name="sort" value="${sort}">
					<div id="scheduleSearchBar"
						class="flex items-center gap-2.5 bg-white border-2 rounded-xl px-4 py-2.5 shadow-sm transition-all cursor-text"
						style="border-color: #D1D2F9">
						<svg class="w-4 h-4 shrink-0"
							style="color: #94a3b8"
							fill="none"
							stroke="currentColor"
							viewBox="0 0 24 24">
							<path
								stroke-linecap="round"
								stroke-linejoin="round"
								stroke-width="2"
								d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
						</svg>
						<input
							type="text"
							name="keyword"
							value="${keyword}"
							class="flex-1 min-w-0 text-[13px] outline-none text-gray-800 placeholder-gray-400 bg-transparent"
							placeholder="어떤 여행 정보가 궁금하신가요?">
					</div>
				</form>
				<div class="flex items-center justify-between mb-5 gap-4 flex-wrap">
					<!-- 왼쪽 : 게시글 수 -->
					<p class="text-[12px] font-medium text-gray-500">
				        총 
				        <span class="font-bold" style="color: #6369D1">
				        	<span>${tipList.size()}</span>
				        </span>
				        개의 여행 꿀팁
				    </p>
				    <!-- 오른쪽 : 정렬 + 글쓰기 -->
				    <div class="flex items-center gap-4 flex-wrap">	
						<!-- 정렬 -->
					    <div class="flex gap-4">
				            <!-- 최신순 -->
							<a href="${pageContext.request.contextPath}/tips?country=${country}&sort=latest"
								class="text-sm pb-0.5 transition-colors"
								style="${sort == 'latest' ? 'color:#6369D1; font-weight:600; border-bottom:2px solid #6369D1' : 'color:#9ca3af'}">
								최신순
							</a>
						
							<!-- 조회순 -->
							<a href="${pageContext.request.contextPath}/tips?country=${country}&sort=views"
								class="text-sm pb-0.5 transition-colors"
								style="${sort == 'views' ? 'color:#6369D1; font-weight:600; border-bottom:2px solid #6369D1' : 'color:#9ca3af'}">
								조회순
							</a>
						
							<!-- 좋아요순 -->
							<a href="${pageContext.request.contextPath}/tips?country=${country}&sort=likes"
								class="text-sm pb-0.5 transition-colors"
								style="${sort == 'likes' ? 'color:#6369D1; font-weight:600; border-bottom:2px solid #6369D1' : 'color:#9ca3af'}">
								인기순
							</a>
				        </div>
					    <!-- 글쓰기 -->
					    <a href="${pageContext.request.contextPath}/tipWrite"
					        class="flex items-center gap-2 px-4 py-2 text-white text-sm font-semibold rounded-lg transition-colors shrink-0"
					        style="background: #6369D1">
					        <svg width="14" height="14"
					            viewBox="0 0 24 24"
					            fill="none"
					            stroke="currentColor"
					            stroke-width="2.5">
					            <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7" />
								<path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z" />
							 </svg>
							글쓰기
					    </a>
				    </div>
				</div>
				<div class="grid gap-5" style="grid-template-columns: repeat(4, minmax(0, 1fr))" data-card-grid>
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
				<!-- 무한 스크롤 로딩 영역 -->
				<c:if test="${totalCount > 0}">
					<div id="tipInfiniteScroll" class="flex flex-col items-center justify-center py-8"
						data-current-count="${tipList.size()}"
						data-total-count="${totalCount}"
						data-current-page="${page}"
						data-page-size="${pageSize}">
				
						<!-- 다음 페이지 로딩 중에 표시 -->
						<div id="tipLoading" class="hidden flex-col items-center gap-2">
							<div class="tip-loading-spinner"></div>
							<p class="text-[12px] font-medium text-gray-500">
								여행 꿀팁을 불러오는 중...
							</p>
							<p class="text-[11px] text-gray-400">
								<span id="tipCurrentCount">${tipList.size()}</span>
								/
								총 <span id="tipTotalCount">${totalCount}</span>개
							</p>
						</div>
						<!-- 마지막 페이지 -->
						<div id="tipLoadComplete"
							class="${tipList.size() >= totalCount ? 'flex' : 'hidden'} flex-col items-center gap-1">
							<p class="text-[12px] font-semibold" style="color: #6369D1;">
								모든 여행 꿀팁을 확인했습니다 ✓
							</p>
							<p class="text-[11px] text-gray-400">
								<span id="tipCompleteCount">${tipList.size()}</span>
								/
								총 ${totalCount}개
							</p>
						</div>
						<!-- 스크롤 감지 지점 -->
						<div id="tipScrollSentinel" class="${tipList.size() < totalCount ? 'block' : 'hidden'}"
							style="width: 100%; height: 1px;">
						</div>
					</div>
				</c:if>
				<c:if test="${empty tipList}">
					<div class="py-20 text-center">
						<p class="text-sm font-medium text-gray-500">
							조건에 맞는 여행 꿀팁이 없습니다.
						</p>
						<p class="mt-2 text-xs text-gray-400">
							다른 지역이나 검색어로 찾아보세요.
						</p>
					</div>
				</c:if>
			</main>
	</div>
	<jsp:include page="/common/footer.jsp" />
	<!-- 최상단 이동 버튼 -->
	<button type="button"  id="tipScrollTopBtn" class="tip-scroll-top-btn" aria-label="페이지 최상단으로 이동">
		<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" aria-hidden="true">
			<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.2" d="M12 19V5M5 12l7-7 7 7" />
		</svg>
	</button>
</body>
</html>
