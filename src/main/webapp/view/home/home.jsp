<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>

<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
	
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
request.setAttribute("activePage", "home");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Planb</title>
<jsp:include page="/common/headStyles.jsp" />
<link rel="stylesheet"
	href="${pageContext.request.contextPath}/view/assets/css/auth/home.css">
<script defer
	src="${pageContext.request.contextPath}/view/assets/js/auth/home.js"></script>
</head>
<!-- ========================================
     HOME - 커스텀 스크롤바
========================================= -->
<!-- ========================================
     HOME - 섹션 네비게이션
========================================= -->
<div class="home-scroll-indicator">
	<button type="button" id="homeScrollDot1"
		class="home-scroll-dot active" aria-label="첫 번째 구역으로 이동"></button>

	<button type="button" id="homeScrollDot2" class="home-scroll-dot"
		aria-label="두 번째 구역으로 이동"></button>

	<button type="button" id="homeScrollDot3" class="home-scroll-dot"
		aria-label="세 번째 구역으로 이동"></button>

	<button type="button" id="homeScrollDot4" class="home-scroll-dot"
		aria-label="네 번째 구역으로 이동"></button>
</div>
<body class="site-shell">
	<jsp:include page="/common/header.jsp" />
	<main class="home-main">
		<section id="homeArea1"
			class="home-hero relative flex flex-col items-center justify-center">
			<div class="home-hero-bg absolute inset-0 bg-cover bg-center"></div>
			<div class="home-hero-overlay absolute inset-0"></div>
			<div
				class="home-hero-content relative z-10 flex flex-col items-center text-center px-4 w-full">
				<div
					class="home-hero-badge inline-flex items-center gap-2 px-3 py-1 rounded-full mb-5 text-xs font-bold tracking-widest uppercase">
					✈ Travel Plan Share</div>
				<h1 class="home-hero-title text-white leading-tight mb-3">
					Plan less.&nbsp; <span class="home-hero-title-highlight">Wander</span>
					more.
				</h1>
				<p
					class="home-hero-description text-white/80 text-sm md:text-base mb-8 font-medium">
					계획보다 중요한 건, <span class="text-white font-semibold">일단 떠나는 것</span>
					&nbsp;·&nbsp;실제로 다녀온 사람들의 진짜 이야기
				</p>
				<form action="${pageContext.request.contextPath}/search"
					method="get"
					class="home-hero-search w-full max-w-2xl rounded-full flex items-center px-5 py-3.5 gap-3 border border-white/30">
					<svg class="shrink-0 text-white/70" width="18" height="18"
						viewBox="0 0 24 24" fill="none" stroke="currentColor"
						stroke-width="2.2">
						<circle cx="11" cy="11" r="8" />
						<path d="m21 21-4.35-4.35" />
					</svg>
					<input type="text" name="q" placeholder="여행지, 일정, 꿀팁 등 무엇이든 검색해보세요"
						aria-label="전체 검색"
						class="flex-1 text-sm text-white placeholder-white/60 outline-none bg-transparent">
					<button type="submit"
						class="home-hero-search-btn shrink-0 w-9 h-9 rounded-full flex items-center justify-center text-white transition-all jsp-brand-hover"
						aria-label="검색">
						<svg width="15" height="15" viewBox="0 0 24 24" fill="none"
							stroke="white" stroke-width="2.5">
							<circle cx="11" cy="11" r="8" />
							<path d="m21 21-4.35-4.35" />
						</svg>
					</button>
				</form>
			</div>
			<button type="button"
				class="jsp-home-scroll absolute bottom-8 left-1/2 -translate-x-1/2 flex flex-col items-center gap-1 text-white/50 z-10 hover:text-white/80 transition-colors cursor-pointer bg-transparent border-none p-2"
				data-scroll-popular aria-label="아래로 스크롤">
				<svg width="20" height="20" viewBox="0 0 24 24" fill="none"
					stroke="currentColor" stroke-width="2">
					<path d="M12 5v14M5 12l7 7 7-7" />
				</svg>
			</button>
		</section>

		<section id="popularPlans" class="mt-16">
			<div class="text-center mb-8 px-4">
				<p
					class="home-popular-eyebrow text-xs font-bold tracking-widest uppercase mb-2">Popular
					Travel Plans</p>
				<h2
					class="text-2xl md:text-3xl font-extrabold text-gray-900 mb-2 home-popular-heading">지금
					가장 인기 있는 여행일정</h2>
				<p class="home-popular-description text-sm text-gray-400">전 세계
					여행자들이 사랑하는 특별한 일정을 만나보세요.</p>
			</div>
<<<<<<< HEAD
			<div class="home-popular-carousel flex items-stretch gap-6 px-12"
				data-home-carousel data-loop-width="2120">
				<a
					href="${pageContext.request.contextPath}/view/travel/scheduleDetail.jsp?id=9"
					class="jsp-home-schedule-card home-popular-card shrink-0 bg-white rounded-2xl overflow-hidden cursor-pointer border">
					<div class="home-popular-card-image relative overflow-hidden">
						<img
							src="https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=600&amp;h=400&amp;fit=crop"
							alt="파리 5박 6일 예술 &amp; 낭만"
							class="w-full h-full object-cover transition-transform duration-300">
						<div
							class="absolute inset-0 bg-gradient-to-t from-black/50 via-transparent to-transparent"></div>
						<span
							class="home-popular-location absolute top-2 left-2 text-[10px] font-bold px-2 py-0.5 rounded-full text-white">파리</span>
						<button
							class="absolute top-2 right-2 w-6 h-6 rounded-full bg-white/90 backdrop-blur-sm flex items-center justify-center shadow-sm transition-transform hover:scale-110"
							type="button" data-bookmark aria-label="북마크">
							<svg width="11" height="11" viewBox="0 0 24 24" fill="none"
								stroke="#9ca3af" stroke-width="2">
								<path stroke-linecap="round" stroke-linejoin="round"
									d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" />
							</svg>
						</button>
						<span
							class="absolute bottom-2 left-2 text-white text-[10px] font-bold bg-black/50 rounded-full px-2 py-0.5">5박
							6일 </span>
					</div>
					<div class="p-3">
						<h3
							class="home-popular-title font-bold text-[13px] leading-snug mb-0.5 line-clamp-2 transition-colors">파리
							5박 6일 예술 &amp; 낭만</h3>
						<p
							class="text-gray-500 text-[11px] line-clamp-1 mb-2 leading-relaxed">에펠탑,
							루브르, 몽마르트! 낭만의 도시 파리를 온전히 즐기는 일정.</p>
						<div
							class="flex items-center gap-2.5 text-[10px] text-gray-400 mb-2.5">
							<span class="flex items-center gap-0.5"> <svg width="10"
									height="10" viewBox="0 0 24 24" fill="none" stroke="#9ca3af"
									stroke-width="2">
									<path stroke-linecap="round" stroke-linejoin="round"
										d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" />
								</svg> <span class="font-medium">1,234</span>
							</span> <span class="flex items-center gap-0.5"> <svg width="10"
									height="10" fill="none" stroke="currentColor"
									viewBox="0 0 24 24">
									<path stroke-linecap="round" stroke-linejoin="round"
										stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
									<path stroke-linecap="round" stroke-linejoin="round"
										stroke-width="2"
										d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
								</svg>5,670
=======
			<div class="home-popular-carousel flex items-stretch gap-6 px-12" data-home-carousel data-loop-width="2120">
				<c:forEach var="itinerary" items="${itineraryList}">
					<a
						href="${pageContext.request.contextPath}/scheduleDetail?id=${itinerary.itineraryId}"
						class="jsp-home-schedule-card home-popular-card shrink-0 bg-white rounded-2xl overflow-hidden cursor-pointer border">
				
						<div class="home-popular-card-image relative overflow-hidden">
				
							<c:choose>
								<c:when test="${not empty itinerary.thumbnailImg}">
									<img
										src="${pageContext.request.contextPath}${itinerary.thumbnailImg}"
										alt="<c:out value='${itinerary.title}' />"
										class="w-full h-full object-cover transition-transform duration-300">
								</c:when>
				
								<c:otherwise>
									<div
										class="w-full h-full flex items-center justify-center bg-gray-100 text-gray-400 text-xs">
										이미지 없음
									</div>
								</c:otherwise>
							</c:choose>
				
							<div
								class="absolute inset-0 bg-gradient-to-t from-black/50 via-transparent to-transparent">
							</div>
				
							<span
								class="home-popular-location absolute top-2 left-2 text-[10px] font-bold px-2 py-0.5 rounded-full text-white">
								<c:choose>
									<c:when test="${not empty itinerary.city}">
										<c:out value="${itinerary.city}" />
									</c:when>
									<c:otherwise>
										<c:out value="${itinerary.country}" />
									</c:otherwise>
								</c:choose>
>>>>>>> branch 'origin' of https://github.com/yoooong96/Planb.git
							</span>
				
							<span
								class="absolute bottom-2 left-2 text-white text-[10px] font-bold bg-black/50 rounded-full px-2 py-0.5">
								<c:out value="${itinerary.durationText}" />
							</span>
				
						</div>
<<<<<<< HEAD
						<div
							class="home-popular-author flex items-center justify-between border-t pt-2">
							<div class="flex items-center gap-1.5">
								<img src="https://i.pravatar.cc/40?img=17" alt="파리지앵"
									class="w-4 h-4 rounded-full object-cover"> <span
									class="text-[10px] text-gray-500 font-medium">파리지앵</span>
=======
				
						<div class="p-3">
				
							<h3
								class="home-popular-title font-bold text-[13px] leading-snug mb-0.5 line-clamp-2 transition-colors">
								<c:out value="${itinerary.title}" />
							</h3>
				
							<p
								class="text-gray-500 text-[11px] line-clamp-1 mb-2 leading-relaxed">
								<c:out value="${itinerary.summary}" />
							</p>
				
							<div
								class="flex items-center gap-2.5 text-[10px] text-gray-400 mb-2.5">
				
								<span class="flex items-center gap-0.5">
									<svg
										width="10"
										height="10"
										viewBox="0 0 24 24"
										fill="none"
										stroke="#9ca3af"
										stroke-width="2">
										<path
											stroke-linecap="round"
											stroke-linejoin="round"
											d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" />
									</svg>
				
									<span class="font-medium">
										<fmt:formatNumber value="${itinerary.likeCount}" />
									</span>
								</span>
				
								<span class="flex items-center gap-0.5">
									<svg
										width="10"
										height="10"
										fill="none"
										stroke="currentColor"
										viewBox="0 0 24 24">
										<path
											stroke-linecap="round"
											stroke-linejoin="round"
											stroke-width="2"
											d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
										<path
											stroke-linecap="round"
											stroke-linejoin="round"
											stroke-width="2"
											d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
									</svg>
				
									<fmt:formatNumber value="${itinerary.viewCount}" />
								</span>
				
>>>>>>> branch 'origin' of https://github.com/yoooong96/Planb.git
							</div>
<<<<<<< HEAD
							<span class="text-[9px] text-gray-400">2026.07.10</span>
						</div>
					</div>
				</a> <a
					href="${pageContext.request.contextPath}/view/travel/scheduleDetail.jsp?id=16"
					class="jsp-home-schedule-card home-popular-card shrink-0 bg-white rounded-2xl overflow-hidden cursor-pointer border">
					<div class="home-popular-card-image relative overflow-hidden">
						<img
							src="https://images.unsplash.com/photo-1589452271712-64b8a66c7b71?w=600&amp;h=400&amp;fit=crop"
							alt="오사카 2박 3일 먹방 여행"
							class="w-full h-full object-cover transition-transform duration-300">
						<div
							class="absolute inset-0 bg-gradient-to-t from-black/50 via-transparent to-transparent"></div>
						<span
							class="home-popular-location absolute top-2 left-2 text-[10px] font-bold px-2 py-0.5 rounded-full text-white">오사카</span>
						<button
							class="absolute top-2 right-2 w-6 h-6 rounded-full bg-white/90 backdrop-blur-sm flex items-center justify-center shadow-sm transition-transform hover:scale-110"
							type="button" data-bookmark aria-label="북마크">
							<svg width="11" height="11" viewBox="0 0 24 24" fill="none"
								stroke="#9ca3af" stroke-width="2">
								<path stroke-linecap="round" stroke-linejoin="round"
									d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" />
							</svg>
						</button>
						<span
							class="absolute bottom-2 left-2 text-white text-[10px] font-bold bg-black/50 rounded-full px-2 py-0.5">2박
							3일</span>
					</div>
					<div class="p-3">
						<h3
							class="home-popular-title font-bold text-[13px] leading-snug mb-0.5 line-clamp-2 transition-colors">오사카
							2박 3일 먹방 여행</h3>
						<p
							class="text-gray-500 text-[11px] line-clamp-1 mb-2 leading-relaxed">도톤보리,
							구로몬시장, 오사카 성! 먹고 먹고 또 먹는 오사카.</p>
						<div
							class="flex items-center gap-2.5 text-[10px] text-gray-400 mb-2.5">
							<span class="flex items-center gap-0.5"><svg width="10"
									height="10" viewBox="0 0 24 24" fill="none" stroke="#9ca3af"
									stroke-width="2">
									<path stroke-linecap="round" stroke-linejoin="round"
										d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" /></svg><span
								class="font-medium">1,102</span></span> <span
								class="flex items-center gap-0.5"><svg width="10"
									height="10" fill="none" stroke="currentColor"
									viewBox="0 0 24 24">
									<path stroke-linecap="round" stroke-linejoin="round"
										stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
									<path stroke-linecap="round" stroke-linejoin="round"
										stroke-width="2"
										d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" /></svg>5,100</span>
						</div>
						<div
							class="home-popular-author flex items-center justify-between border-t pt-2">
							<div class="flex items-center gap-1.5">
								<img src="https://i.pravatar.cc/40?img=31" alt="오사카마니아"
									class="w-4 h-4 rounded-full object-cover"><span
									class="text-[10px] text-gray-500 font-medium">오사카마니아</span>
=======
				
							<div
								class="home-popular-author flex items-center justify-between border-t pt-2">
				
								<div class="flex items-center gap-1.5">
				
									<c:choose>
										<c:when test="${not empty itinerary.profileImg}">
											<img
												src="${pageContext.request.contextPath}${itinerary.profileImg}"
												alt="<c:out value='${itinerary.nickname}' />"
												class="w-4 h-4 rounded-full object-cover">
										</c:when>
				
										<c:otherwise>
											<div
												class="w-4 h-4 rounded-full bg-gray-200 flex items-center justify-center text-[8px] text-gray-500">
												<c:out value="${empty itinerary.nickname ? '?' : itinerary.nickname.substring(0, 1)}" />
											</div>
										</c:otherwise>
									</c:choose>
				
									<span class="text-[10px] text-gray-500 font-medium">
										<c:out value="${itinerary.nickname}" />
									</span>
				
								</div>
				
								<span class="text-[9px] text-gray-400">
									<fmt:formatDate
										value="${itinerary.createdAt}"
										pattern="yyyy.MM.dd" />
								</span>
				
>>>>>>> branch 'origin' of https://github.com/yoooong96/Planb.git
							</div>
				
						</div>
<<<<<<< HEAD
					</div>
				</a> <a
					href="${pageContext.request.contextPath}/view/travel/scheduleDetail.jsp?id=11"
					class="jsp-home-schedule-card home-popular-card shrink-0 bg-white rounded-2xl overflow-hidden cursor-pointer border">
					<div class="home-popular-card-image relative overflow-hidden">
						<img
							src="https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9?w=600&amp;h=400&amp;fit=crop"
							alt="뉴욕 6박 7일 도시 탐험"
							class="w-full h-full object-cover transition-transform duration-300">
						<div
							class="absolute inset-0 bg-gradient-to-t from-black/50 via-transparent to-transparent"></div>
						<span
							class="home-popular-location absolute top-2 left-2 text-[10px] font-bold px-2 py-0.5 rounded-full text-white">뉴욕</span>
						<button
							class="absolute top-2 right-2 w-6 h-6 rounded-full bg-white/90 backdrop-blur-sm flex items-center justify-center shadow-sm transition-transform hover:scale-110"
							type="button" data-bookmark aria-label="북마크">
							<svg width="11" height="11" viewBox="0 0 24 24" fill="none"
								stroke="#9ca3af" stroke-width="2">
								<path stroke-linecap="round" stroke-linejoin="round"
									d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" /></svg>
						</button>
						<span
							class="absolute bottom-2 left-2 text-white text-[10px] font-bold bg-black/50 rounded-full px-2 py-0.5">6박
							7일</span>
					</div>
					<div class="p-3">
						<h3
							class="home-popular-title font-bold text-[13px] leading-snug mb-0.5 line-clamp-2 transition-colors">뉴욕
							6박 7일 도시 탐험</h3>
						<p
							class="text-gray-500 text-[11px] line-clamp-1 mb-2 leading-relaxed">타임스퀘어,
							센트럴파크, 브루클린 브리지! 잠들지 않는 도시 뉴욕.</p>
						<div
							class="flex items-center gap-2.5 text-[10px] text-gray-400 mb-2.5">
							<span class="flex items-center gap-0.5"><svg width="10"
									height="10" viewBox="0 0 24 24" fill="none" stroke="#9ca3af"
									stroke-width="2">
									<path stroke-linecap="round" stroke-linejoin="round"
										d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" /></svg><span
								class="font-medium">987</span></span> <span
								class="flex items-center gap-0.5"><svg width="10"
									height="10" fill="none" stroke="currentColor"
									viewBox="0 0 24 24">
									<path stroke-linecap="round" stroke-linejoin="round"
										stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
									<path stroke-linecap="round" stroke-linejoin="round"
										stroke-width="2"
										d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" /></svg>4,520</span>
						</div>
						<div
							class="home-popular-author flex items-center justify-between border-t pt-2">
							<div class="flex items-center gap-1.5">
								<img src="https://i.pravatar.cc/40?img=21" alt="NYC러버"
									class="w-4 h-4 rounded-full object-cover"><span
									class="text-[10px] text-gray-500 font-medium">NYC러버</span>
							</div>
							<span class="text-[9px] text-gray-400">2026.07.28</span>
						</div>
					</div>
				</a> <a
					href="${pageContext.request.contextPath}/view/travel/scheduleDetail.jsp?id=7"
					class="jsp-home-schedule-card home-popular-card shrink-0 bg-white rounded-2xl overflow-hidden cursor-pointer border">
					<div class="home-popular-card-image relative overflow-hidden">
						<img
							src="https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=600&amp;h=400&amp;fit=crop"
							alt="도쿄 3박 4일 완전 정복"
							class="w-full h-full object-cover transition-transform duration-300">
						<div
							class="absolute inset-0 bg-gradient-to-t from-black/50 via-transparent to-transparent"></div>
						<span
							class="home-popular-location absolute top-2 left-2 text-[10px] font-bold px-2 py-0.5 rounded-full text-white">도쿄</span>
						<button
							class="absolute top-2 right-2 w-6 h-6 rounded-full bg-white/90 backdrop-blur-sm flex items-center justify-center shadow-sm transition-transform hover:scale-110"
							type="button" data-bookmark aria-label="북마크">
							<svg width="11" height="11" viewBox="0 0 24 24" fill="none"
								stroke="#9ca3af" stroke-width="2">
								<path stroke-linecap="round" stroke-linejoin="round"
									d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" /></svg>
						</button>
						<span
							class="absolute bottom-2 left-2 text-white text-[10px] font-bold bg-black/50 rounded-full px-2 py-0.5">3박
							4일</span>
					</div>
					<div class="p-3">
						<h3
							class="home-popular-title font-bold text-[13px] leading-snug mb-0.5 line-clamp-2 transition-colors">도쿄
							3박 4일 완전 정복</h3>
						<p
							class="text-gray-500 text-[11px] line-clamp-1 mb-2 leading-relaxed">시부야,
							아키하바라, 아사쿠사! 도쿄의 모든 것을 담은 알찬 일정.</p>
						<div
							class="flex items-center gap-2.5 text-[10px] text-gray-400 mb-2.5">
							<span class="flex items-center gap-0.5"><svg width="10"
									height="10" viewBox="0 0 24 24" fill="none" stroke="#9ca3af"
									stroke-width="2">
									<path stroke-linecap="round" stroke-linejoin="round"
										d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" /></svg><span
								class="font-medium">921</span></span> <span
								class="flex items-center gap-0.5"><svg width="10"
									height="10" fill="none" stroke="currentColor"
									viewBox="0 0 24 24">
									<path stroke-linecap="round" stroke-linejoin="round"
										stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
									<path stroke-linecap="round" stroke-linejoin="round"
										stroke-width="2"
										d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" /></svg>4,210</span>
						</div>
						<div
							class="home-popular-author flex items-center justify-between border-t pt-2">
							<div class="flex items-center gap-1.5">
								<img src="https://i.pravatar.cc/40?img=13" alt="재팬러버"
									class="w-4 h-4 rounded-full object-cover"><span
									class="text-[10px] text-gray-500 font-medium">재팬러버</span>
							</div>
							<span class="text-[9px] text-gray-400">2026.08.05</span>
						</div>
					</div>
				</a> <a href="https://example.com/tripstay" target="_blank"
					rel="noreferrer"
					class="jsp-home-ad-card home-popular-ad-card shrink-0 rounded-2xl overflow-hidden cursor-pointer group relative border bg-white">
					<div class="home-popular-card-image relative overflow-hidden">
						<img
							src="https://images.unsplash.com/photo-1566073771259-6a8506099945?w=900&q=80"
							alt="도쿄 숙소 최대 15% 할인"
							class="w-full h-full object-cover transition-transform duration-300">
						<div class="home-popular-ad-overlay absolute inset-0"></div>
						<span
							class="absolute top-2 left-2 text-[9px] font-bold px-2 py-0.5 rounded-full bg-yellow-400 text-gray-900">AD</span>
					</div>
					<div class="home-popular-ad-content p-3">
						<div class="text-[10px] text-gray-400 mb-0.5 font-semibold">TripStay</div>
						<h3
							class="font-bold text-[12px] text-gray-800 line-clamp-2 leading-snug mb-2">도쿄
							숙소 최대 15% 할인</h3>
						<div class="home-popular-ad-link text-[10px] font-bold">광고
							보기 →</div>
					</div>
				</a> <a
					href="${pageContext.request.contextPath}/view/travel/scheduleDetail.jsp?id=10"
					class="jsp-home-schedule-card home-popular-card shrink-0 bg-white rounded-2xl overflow-hidden cursor-pointer border">
					<div class="home-popular-card-image relative overflow-hidden">
						<img
							src="https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=600&amp;h=400&amp;fit=crop"
							alt="발리 5박 6일 힐링 휴양"
							class="w-full h-full object-cover transition-transform duration-300">
						<div
							class="absolute inset-0 bg-gradient-to-t from-black/50 via-transparent to-transparent"></div>
						<span
							class="home-popular-location absolute top-2 left-2 text-[10px] font-bold px-2 py-0.5 rounded-full text-white">발리</span>
						<button
							class="absolute top-2 right-2 w-6 h-6 rounded-full bg-white/90 backdrop-blur-sm flex items-center justify-center shadow-sm transition-transform hover:scale-110"
							type="button" data-bookmark aria-label="북마크">
							<svg width="11" height="11" viewBox="0 0 24 24" fill="none"
								stroke="#9ca3af" stroke-width="2">
								<path stroke-linecap="round" stroke-linejoin="round"
									d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" /></svg>
						</button>
						<span
							class="absolute bottom-2 left-2 text-white text-[10px] font-bold bg-black/50 rounded-full px-2 py-0.5">5박
							6일</span>
					</div>
					<div class="p-3">
						<h3
							class="home-popular-title font-bold text-[13px] leading-snug mb-0.5 line-clamp-2 transition-colors">발리
							5박 6일 힐링 휴양</h3>
						<p
							class="text-gray-500 text-[11px] line-clamp-1 mb-2 leading-relaxed">우붓
							라이스테라스, 울루와뚜 사원, 짱구 카페까지 발리 완전정복.</p>
						<div
							class="flex items-center gap-2.5 text-[10px] text-gray-400 mb-2.5">
							<span class="flex items-center gap-0.5"><svg width="10"
									height="10" viewBox="0 0 24 24" fill="none" stroke="#9ca3af"
									stroke-width="2">
									<path stroke-linecap="round" stroke-linejoin="round"
										d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" /></svg><span
								class="font-medium">892</span></span> <span
								class="flex items-center gap-0.5"><svg width="10"
									height="10" fill="none" stroke="currentColor"
									viewBox="0 0 24 24">
									<path stroke-linecap="round" stroke-linejoin="round"
										stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
									<path stroke-linecap="round" stroke-linejoin="round"
										stroke-width="2"
										d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" /></svg>3,890</span>
						</div>
						<div
							class="home-popular-author flex items-center justify-between border-t pt-2">
							<div class="flex items-center gap-1.5">
								<img src="https://i.pravatar.cc/40?img=19" alt="발리덕후"
									class="w-4 h-4 rounded-full object-cover"><span
									class="text-[10px] text-gray-500 font-medium">발리덕후</span>
							</div>
							<span class="text-[9px] text-gray-400">2026.08.22</span>
						</div>
					</div>
				</a> <a
					href="${pageContext.request.contextPath}/view/travel/scheduleDetail.jsp?id=14"
					class="jsp-home-schedule-card home-popular-card shrink-0 bg-white rounded-2xl overflow-hidden cursor-pointer border">
					<div class="home-popular-card-image relative overflow-hidden">
						<img
							src="https://images.unsplash.com/photo-1559592413-7cec4d0cae2b?w=600&amp;h=400&amp;fit=crop"
							alt="다낭 3박 4일 바다 &amp; 리조트"
							class="w-full h-full object-cover transition-transform duration-300">
						<div
							class="absolute inset-0 bg-gradient-to-t from-black/50 via-transparent to-transparent"></div>
						<span
							class="home-popular-location absolute top-2 left-2 text-[10px] font-bold px-2 py-0.5 rounded-full text-white">다낭</span>
						<button
							class="absolute top-2 right-2 w-6 h-6 rounded-full bg-white/90 backdrop-blur-sm flex items-center justify-center shadow-sm transition-transform hover:scale-110"
							type="button" data-bookmark aria-label="북마크">
							<svg width="11" height="11" viewBox="0 0 24 24" fill="none"
								stroke="#9ca3af" stroke-width="2">
								<path stroke-linecap="round" stroke-linejoin="round"
									d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" /></svg>
						</button>
						<span
							class="absolute bottom-2 left-2 text-white text-[10px] font-bold bg-black/50 rounded-full px-2 py-0.5">3박
							4일</span>
					</div>
					<div class="p-3">
						<h3
							class="home-popular-title font-bold text-[13px] leading-snug mb-0.5 line-clamp-2 transition-colors">다낭
							3박 4일 바다 &amp; 리조트</h3>
						<p
							class="text-gray-500 text-[11px] line-clamp-1 mb-2 leading-relaxed">미케
							비치, 바나힐, 호이안 올드타운까지! 베트남 중부의 진주.</p>
						<div
							class="flex items-center gap-2.5 text-[10px] text-gray-400 mb-2.5">
							<span class="flex items-center gap-0.5"><svg width="10"
									height="10" viewBox="0 0 24 24" fill="none" stroke="#9ca3af"
									stroke-width="2">
									<path stroke-linecap="round" stroke-linejoin="round"
										d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" /></svg><span
								class="font-medium">712</span></span> <span
								class="flex items-center gap-0.5"><svg width="10"
									height="10" fill="none" stroke="currentColor"
									viewBox="0 0 24 24">
									<path stroke-linecap="round" stroke-linejoin="round"
										stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
									<path stroke-linecap="round" stroke-linejoin="round"
										stroke-width="2"
										d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" /></svg>3,200</span>
						</div>
						<div
							class="home-popular-author flex items-center justify-between border-t pt-2">
							<div class="flex items-center gap-1.5">
								<img src="https://i.pravatar.cc/40?img=27" alt="다낭러버"
									class="w-4 h-4 rounded-full object-cover"><span
									class="text-[10px] text-gray-500 font-medium">다낭러버</span>
							</div>
							<span class="text-[9px] text-gray-400">2026.09.01</span>
						</div>
					</div>
				</a> <a
					href="${pageContext.request.contextPath}/view/travel/scheduleDetail.jsp?id=8"
					class="jsp-home-schedule-card home-popular-card shrink-0 bg-white rounded-2xl overflow-hidden cursor-pointer border">
					<div class="home-popular-card-image relative overflow-hidden">
						<img
							src="https://images.unsplash.com/photo-1506665531195-3566af2b548e?w=600&amp;h=400&amp;fit=crop"
							alt="방콕 4박 5일 사원 &amp; 야시장"
							class="w-full h-full object-cover transition-transform duration-300">
						<div
							class="absolute inset-0 bg-gradient-to-t from-black/50 via-transparent to-transparent"></div>
						<span
							class="home-popular-location absolute top-2 left-2 text-[10px] font-bold px-2 py-0.5 rounded-full text-white">방콕</span>
						<button
							class="absolute top-2 right-2 w-6 h-6 rounded-full bg-white/90 backdrop-blur-sm flex items-center justify-center shadow-sm transition-transform hover:scale-110"
							type="button" data-bookmark aria-label="북마크">
							<svg width="11" height="11" viewBox="0 0 24 24" fill="none"
								stroke="#9ca3af" stroke-width="2">
								<path stroke-linecap="round" stroke-linejoin="round"
									d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" /></svg>
						</button>
						<span
							class="absolute bottom-2 left-2 text-white text-[10px] font-bold bg-black/50 rounded-full px-2 py-0.5">4박
							5일</span>
					</div>
					<div class="p-3">
						<h3
							class="home-popular-title font-bold text-[13px] leading-snug mb-0.5 line-clamp-2 transition-colors">방콕
							4박 5일 사원 &amp; 야시장</h3>
						<p
							class="text-gray-500 text-[11px] line-clamp-1 mb-2 leading-relaxed">왕궁,
							왓포, 차오프라야강과 야시장까지! 방콕의 매력에 빠져봐요.</p>
						<div
							class="flex items-center gap-2.5 text-[10px] text-gray-400 mb-2.5">
							<span class="flex items-center gap-0.5"><svg width="10"
									height="10" viewBox="0 0 24 24" fill="none" stroke="#9ca3af"
									stroke-width="2">
									<path stroke-linecap="round" stroke-linejoin="round"
										d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" /></svg><span
								class="font-medium">678</span></span> <span
								class="flex items-center gap-0.5"><svg width="10"
									height="10" fill="none" stroke="currentColor"
									viewBox="0 0 24 24">
									<path stroke-linecap="round" stroke-linejoin="round"
										stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
									<path stroke-linecap="round" stroke-linejoin="round"
										stroke-width="2"
										d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" /></svg>3,100</span>
						</div>
						<div
							class="home-popular-author flex items-center justify-between border-t pt-2">
							<div class="flex items-center gap-1.5">
								<img src="https://i.pravatar.cc/40?img=15" alt="태국덕후"
									class="w-4 h-4 rounded-full object-cover"><span
									class="text-[10px] text-gray-500 font-medium">태국덕후</span>
							</div>
							<span class="text-[9px] text-gray-400">2026.08.18</span>
						</div>
					</div>
				</a> <a
					href="${pageContext.request.contextPath}/view/travel/scheduleDetail.jsp?id=12"
					class="jsp-home-schedule-card home-popular-card shrink-0 bg-white rounded-2xl overflow-hidden cursor-pointer border">
					<div class="home-popular-card-image relative overflow-hidden">
						<img
							src="https://images.unsplash.com/photo-1539037116277-4db20889f2d4?w=600&amp;h=400&amp;fit=crop"
							alt="바르셀로나 4박 5일 가우디 투어"
							class="w-full h-full object-cover transition-transform duration-300">
						<div
							class="absolute inset-0 bg-gradient-to-t from-black/50 via-transparent to-transparent"></div>
						<span
							class="home-popular-location absolute top-2 left-2 text-[10px] font-bold px-2 py-0.5 rounded-full text-white">바르셀로나</span>
						<button
							class="absolute top-2 right-2 w-6 h-6 rounded-full bg-white/90 backdrop-blur-sm flex items-center justify-center shadow-sm transition-transform hover:scale-110"
							type="button" data-bookmark aria-label="북마크">
							<svg width="11" height="11" viewBox="0 0 24 24" fill="none"
								stroke="#9ca3af" stroke-width="2">
								<path stroke-linecap="round" stroke-linejoin="round"
									d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" /></svg>
						</button>
						<span
							class="absolute bottom-2 left-2 text-white text-[10px] font-bold bg-black/50 rounded-full px-2 py-0.5">4박
							5일</span>
					</div>
					<div class="p-3">
						<h3
							class="home-popular-title font-bold text-[13px] leading-snug mb-0.5 line-clamp-2 transition-colors">바르셀로나
							4박 5일 가우디 투어</h3>
						<p
							class="text-gray-500 text-[11px] line-clamp-1 mb-2 leading-relaxed">사그라다
							파밀리아, 구엘공원, 바르셀로나 해변까지 가우디의 도시.</p>
						<div
							class="flex items-center gap-2.5 text-[10px] text-gray-400 mb-2.5">
							<span class="flex items-center gap-0.5"><svg width="10"
									height="10" viewBox="0 0 24 24" fill="none" stroke="#9ca3af"
									stroke-width="2">
									<path stroke-linecap="round" stroke-linejoin="round"
										d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" /></svg><span
								class="font-medium">634</span></span> <span
								class="flex items-center gap-0.5"><svg width="10"
									height="10" fill="none" stroke="currentColor"
									viewBox="0 0 24 24">
									<path stroke-linecap="round" stroke-linejoin="round"
										stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
									<path stroke-linecap="round" stroke-linejoin="round"
										stroke-width="2"
										d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" /></svg>2,890</span>
						</div>
						<div
							class="home-popular-author flex items-center justify-between border-t pt-2">
							<div class="flex items-center gap-1.5">
								<img src="https://i.pravatar.cc/40?img=23" alt="스페인러버"
									class="w-4 h-4 rounded-full object-cover"><span
									class="text-[10px] text-gray-500 font-medium">스페인러버</span>
							</div>
							<span class="text-[9px] text-gray-400">2026.08.08</span>
						</div>
					</div>
				</a> <a
					href="${pageContext.request.contextPath}/view/travel/scheduleDetail.jsp?id=3"
					class="jsp-home-schedule-card home-popular-card shrink-0 bg-white rounded-2xl overflow-hidden cursor-pointer border">
					<div class="home-popular-card-image relative overflow-hidden">
						<img
							src="https://images.unsplash.com/photo-1538485399081-7191377e8241?w=600&amp;h=400&amp;fit=crop"
							alt="부산 1박 2일 바다 여행"
							class="w-full h-full object-cover transition-transform duration-300">
						<div
							class="absolute inset-0 bg-gradient-to-t from-black/50 via-transparent to-transparent"></div>
						<span
							class="home-popular-location absolute top-2 left-2 text-[10px] font-bold px-2 py-0.5 rounded-full text-white">부산</span>
						<button
							class="absolute top-2 right-2 w-6 h-6 rounded-full bg-white/90 backdrop-blur-sm flex items-center justify-center shadow-sm transition-transform hover:scale-110"
							type="button" data-bookmark aria-label="북마크">
							<svg width="11" height="11" viewBox="0 0 24 24" fill="none"
								stroke="#9ca3af" stroke-width="2">
								<path stroke-linecap="round" stroke-linejoin="round"
									d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" /></svg>
						</button>
						<span
							class="absolute bottom-2 left-2 text-white text-[10px] font-bold bg-black/50 rounded-full px-2 py-0.5">1박
							2일</span>
					</div>
					<div class="p-3">
						<h3
							class="home-popular-title font-bold text-[13px] leading-snug mb-0.5 line-clamp-2 transition-colors">부산
							1박 2일 바다 여행</h3>
						<p
							class="text-gray-500 text-[11px] line-clamp-1 mb-2 leading-relaxed">해운대와
							광안리, 자갈치시장까지! 부산 핵심 코스.</p>
						<div
							class="flex items-center gap-2.5 text-[10px] text-gray-400 mb-2.5">
							<span class="flex items-center gap-0.5"><svg width="10"
									height="10" viewBox="0 0 24 24" fill="none" stroke="#9ca3af"
									stroke-width="2">
									<path stroke-linecap="round" stroke-linejoin="round"
										d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" /></svg><span
								class="font-medium">512</span></span> <span
								class="flex items-center gap-0.5"><svg width="10"
									height="10" fill="none" stroke="currentColor"
									viewBox="0 0 24 24">
									<path stroke-linecap="round" stroke-linejoin="round"
										stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
									<path stroke-linecap="round" stroke-linejoin="round"
										stroke-width="2"
										d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" /></svg>2,341</span>
						</div>
						<div
							class="home-popular-author flex items-center justify-between border-t pt-2">
							<div class="flex items-center gap-1.5">
								<img src="https://i.pravatar.cc/40?img=5" alt="바다러버"
									class="w-4 h-4 rounded-full object-cover"><span
									class="text-[10px] text-gray-500 font-medium">바다러버</span>
							</div>
							<span class="text-[9px] text-gray-400">2026.08.10</span>
						</div>
					</div>
				</a> <a
					href="${pageContext.request.contextPath}/view/travel/scheduleDetail.jsp?id=9"
					class="jsp-home-schedule-card home-popular-card shrink-0 bg-white rounded-2xl overflow-hidden cursor-pointer border">
					<div class="home-popular-card-image relative overflow-hidden">
						<img
							src="https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=600&amp;h=400&amp;fit=crop"
							alt="파리 5박 6일 예술 &amp; 낭만"
							class="w-full h-full object-cover transition-transform duration-300">
						<div
							class="absolute inset-0 bg-gradient-to-t from-black/50 via-transparent to-transparent"></div>
						<span
							class="home-popular-location absolute top-2 left-2 text-[10px] font-bold px-2 py-0.5 rounded-full text-white">파리</span>
						<button
							class="absolute top-2 right-2 w-6 h-6 rounded-full bg-white/90 backdrop-blur-sm flex items-center justify-center shadow-sm transition-transform hover:scale-110"
							type="button" data-bookmark aria-label="북마크">
							<svg width="11" height="11" viewBox="0 0 24 24" fill="none"
								stroke="#9ca3af" stroke-width="2">
								<path stroke-linecap="round" stroke-linejoin="round"
									d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" /></svg>
						</button>
						<span
							class="absolute bottom-2 left-2 text-white text-[10px] font-bold bg-black/50 rounded-full px-2 py-0.5">5박
							6일</span>
					</div>
					<div class="p-3">
						<h3
							class="home-popular-title font-bold text-[13px] leading-snug mb-0.5 line-clamp-2 transition-colors">파리
							5박 6일 예술 &amp; 낭만</h3>
						<p
							class="text-gray-500 text-[11px] line-clamp-1 mb-2 leading-relaxed">에펠탑,
							루브르, 몽마르트! 낭만의 도시 파리를 온전히 즐기는 일정.</p>
						<div
							class="flex items-center gap-2.5 text-[10px] text-gray-400 mb-2.5">
							<span class="flex items-center gap-0.5"><svg width="10"
									height="10" viewBox="0 0 24 24" fill="none" stroke="#9ca3af"
									stroke-width="2">
									<path stroke-linecap="round" stroke-linejoin="round"
										d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" /></svg><span
								class="font-medium">1,234</span></span> <span
								class="flex items-center gap-0.5"><svg width="10"
									height="10" fill="none" stroke="currentColor"
									viewBox="0 0 24 24">
									<path stroke-linecap="round" stroke-linejoin="round"
										stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
									<path stroke-linecap="round" stroke-linejoin="round"
										stroke-width="2"
										d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" /></svg>5,670</span>
						</div>
						<div
							class="home-popular-author flex items-center justify-between border-t pt-2">
							<div class="flex items-center gap-1.5">
								<img src="https://i.pravatar.cc/40?img=17" alt="파리지앵"
									class="w-4 h-4 rounded-full object-cover"><span
									class="text-[10px] text-gray-500 font-medium">파리지앵</span>
							</div>
							<span class="text-[9px] text-gray-400">2026.07.10</span>
						</div>
					</div>
				</a> <a
					href="${pageContext.request.contextPath}/view/travel/scheduleDetail.jsp?id=16"
					class="jsp-home-schedule-card home-popular-card shrink-0 bg-white rounded-2xl overflow-hidden cursor-pointer border">
					<div class="home-popular-card-image relative overflow-hidden">
						<img
							src="https://images.unsplash.com/photo-1589452271712-64b8a66c7b71?w=600&amp;h=400&amp;fit=crop"
							alt="오사카 2박 3일 먹방 여행"
							class="w-full h-full object-cover transition-transform duration-300">
						<div
							class="absolute inset-0 bg-gradient-to-t from-black/50 via-transparent to-transparent"></div>
						<span
							class="home-popular-location absolute top-2 left-2 text-[10px] font-bold px-2 py-0.5 rounded-full text-white">오사카</span>
						<button
							class="absolute top-2 right-2 w-6 h-6 rounded-full bg-white/90 backdrop-blur-sm flex items-center justify-center shadow-sm transition-transform hover:scale-110"
							type="button" data-bookmark aria-label="북마크">
							<svg width="11" height="11" viewBox="0 0 24 24" fill="none"
								stroke="#9ca3af" stroke-width="2">
								<path stroke-linecap="round" stroke-linejoin="round"
									d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" /></svg>
						</button>
						<span
							class="absolute bottom-2 left-2 text-white text-[10px] font-bold bg-black/50 rounded-full px-2 py-0.5">2박
							3일</span>
					</div>
					<div class="p-3">
						<h3
							class="home-popular-title font-bold text-[13px] leading-snug mb-0.5 line-clamp-2 transition-colors">오사카
							2박 3일 먹방 여행</h3>
						<p
							class="text-gray-500 text-[11px] line-clamp-1 mb-2 leading-relaxed">도톤보리,
							구로몬시장, 오사카 성! 먹고 먹고 또 먹는 오사카.</p>
						<div
							class="flex items-center gap-2.5 text-[10px] text-gray-400 mb-2.5">
							<span class="flex items-center gap-0.5"><svg width="10"
									height="10" viewBox="0 0 24 24" fill="none" stroke="#9ca3af"
									stroke-width="2">
									<path stroke-linecap="round" stroke-linejoin="round"
										d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" /></svg><span
								class="font-medium">1,102</span></span> <span
								class="flex items-center gap-0.5"><svg width="10"
									height="10" fill="none" stroke="currentColor"
									viewBox="0 0 24 24">
									<path stroke-linecap="round" stroke-linejoin="round"
										stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
									<path stroke-linecap="round" stroke-linejoin="round"
										stroke-width="2"
										d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" /></svg>5,100</span>
						</div>
						<div
							class="home-popular-author flex items-center justify-between border-t pt-2">
							<div class="flex items-center gap-1.5">
								<img src="https://i.pravatar.cc/40?img=31" alt="오사카마니아"
									class="w-4 h-4 rounded-full object-cover"><span
									class="text-[10px] text-gray-500 font-medium">오사카마니아</span>
							</div>
							<span class="text-[9px] text-gray-400">2026.09.08</span>
						</div>
					</div>
				</a> <a
					href="${pageContext.request.contextPath}/view/travel/scheduleDetail.jsp?id=11"
					class="jsp-home-schedule-card home-popular-card shrink-0 bg-white rounded-2xl overflow-hidden cursor-pointer border">
					<div class="home-popular-card-image relative overflow-hidden">
						<img
							src="https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9?w=600&amp;h=400&amp;fit=crop"
							alt="뉴욕 6박 7일 도시 탐험"
							class="w-full h-full object-cover transition-transform duration-300">
						<div
							class="absolute inset-0 bg-gradient-to-t from-black/50 via-transparent to-transparent"></div>
						<span
							class="home-popular-location absolute top-2 left-2 text-[10px] font-bold px-2 py-0.5 rounded-full text-white">뉴욕</span>
						<button
							class="absolute top-2 right-2 w-6 h-6 rounded-full bg-white/90 backdrop-blur-sm flex items-center justify-center shadow-sm transition-transform hover:scale-110"
							type="button" data-bookmark aria-label="북마크">
							<svg width="11" height="11" viewBox="0 0 24 24" fill="none"
								stroke="#9ca3af" stroke-width="2">
								<path stroke-linecap="round" stroke-linejoin="round"
									d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" /></svg>
						</button>
						<span
							class="absolute bottom-2 left-2 text-white text-[10px] font-bold bg-black/50 rounded-full px-2 py-0.5">6박
							7일</span>
					</div>
					<div class="p-3">
						<h3
							class="home-popular-title font-bold text-[13px] leading-snug mb-0.5 line-clamp-2 transition-colors">뉴욕
							6박 7일 도시 탐험</h3>
						<p
							class="text-gray-500 text-[11px] line-clamp-1 mb-2 leading-relaxed">타임스퀘어,
							센트럴파크, 브루클린 브리지! 잠들지 않는 도시 뉴욕.</p>
						<div
							class="flex items-center gap-2.5 text-[10px] text-gray-400 mb-2.5">
							<span class="flex items-center gap-0.5"><svg width="10"
									height="10" viewBox="0 0 24 24" fill="none" stroke="#9ca3af"
									stroke-width="2">
									<path stroke-linecap="round" stroke-linejoin="round"
										d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" /></svg><span
								class="font-medium">987</span></span> <span
								class="flex items-center gap-0.5"><svg width="10"
									height="10" fill="none" stroke="currentColor"
									viewBox="0 0 24 24">
									<path stroke-linecap="round" stroke-linejoin="round"
										stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
									<path stroke-linecap="round" stroke-linejoin="round"
										stroke-width="2"
										d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" /></svg>4,520</span>
						</div>
						<div
							class="home-popular-author flex items-center justify-between border-t pt-2">
							<div class="flex items-center gap-1.5">
								<img src="https://i.pravatar.cc/40?img=21" alt="NYC러버"
									class="w-4 h-4 rounded-full object-cover"><span
									class="text-[10px] text-gray-500 font-medium">NYC러버</span>
							</div>
							<span class="text-[9px] text-gray-400">2026.07.28</span>
						</div>
					</div>
				</a> <a
					href="${pageContext.request.contextPath}/view/travel/scheduleDetail.jsp?id=7"
					class="jsp-home-schedule-card home-popular-card shrink-0 bg-white rounded-2xl overflow-hidden cursor-pointer border">
					<div class="home-popular-card-image relative overflow-hidden">
						<img
							src="https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=600&amp;h=400&amp;fit=crop"
							alt="도쿄 3박 4일 완전 정복"
							class="w-full h-full object-cover transition-transform duration-300">
						<div
							class="absolute inset-0 bg-gradient-to-t from-black/50 via-transparent to-transparent"></div>
						<span
							class="home-popular-location absolute top-2 left-2 text-[10px] font-bold px-2 py-0.5 rounded-full text-white">도쿄</span>
						<button
							class="absolute top-2 right-2 w-6 h-6 rounded-full bg-white/90 backdrop-blur-sm flex items-center justify-center shadow-sm transition-transform hover:scale-110"
							type="button" data-bookmark aria-label="북마크">
							<svg width="11" height="11" viewBox="0 0 24 24" fill="none"
								stroke="#9ca3af" stroke-width="2">
								<path stroke-linecap="round" stroke-linejoin="round"
									d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" /></svg>
						</button>
						<span
							class="absolute bottom-2 left-2 text-white text-[10px] font-bold bg-black/50 rounded-full px-2 py-0.5">3박
							4일</span>
					</div>
					<div class="p-3">
						<h3
							class="home-popular-title font-bold text-[13px] leading-snug mb-0.5 line-clamp-2 transition-colors">도쿄
							3박 4일 완전 정복</h3>
						<p
							class="text-gray-500 text-[11px] line-clamp-1 mb-2 leading-relaxed">시부야,
							아키하바라, 아사쿠사! 도쿄의 모든 것을 담은 알찬 일정.</p>
						<div
							class="flex items-center gap-2.5 text-[10px] text-gray-400 mb-2.5">
							<span class="flex items-center gap-0.5"><svg width="10"
									height="10" viewBox="0 0 24 24" fill="none" stroke="#9ca3af"
									stroke-width="2">
									<path stroke-linecap="round" stroke-linejoin="round"
										d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" /></svg><span
								class="font-medium">921</span></span> <span
								class="flex items-center gap-0.5"><svg width="10"
									height="10" fill="none" stroke="currentColor"
									viewBox="0 0 24 24">
									<path stroke-linecap="round" stroke-linejoin="round"
										stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
									<path stroke-linecap="round" stroke-linejoin="round"
										stroke-width="2"
										d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" /></svg>4,210</span>
						</div>
						<div
							class="home-popular-author flex items-center justify-between border-t pt-2">
							<div class="flex items-center gap-1.5">
								<img src="https://i.pravatar.cc/40?img=13" alt="재팬러버"
									class="w-4 h-4 rounded-full object-cover"><span
									class="text-[10px] text-gray-500 font-medium">재팬러버</span>
							</div>
							<span class="text-[9px] text-gray-400">2026.08.05</span>
						</div>
					</div>
				</a> <a href="https://example.com/tripstay" target="_blank"
					rel="noreferrer"
					class="jsp-home-ad-card home-popular-ad-card shrink-0 rounded-2xl overflow-hidden cursor-pointer group relative border bg-white">
					<div class="home-popular-card-image relative overflow-hidden">
						<img
							src="https://images.unsplash.com/photo-1566073771259-6a8506099945?w=900&q=80"
							alt="도쿄 숙소 최대 15% 할인"
							class="w-full h-full object-cover transition-transform duration-300">
						<div class="home-popular-ad-overlay absolute inset-0"></div>
						<span
							class="absolute top-2 left-2 text-[9px] font-bold px-2 py-0.5 rounded-full bg-yellow-400 text-gray-900">AD</span>
					</div>
					<div class="home-popular-ad-content p-3">
						<div class="text-[10px] text-gray-400 mb-0.5 font-semibold">TripStay</div>
						<h3
							class="font-bold text-[12px] text-gray-800 line-clamp-2 leading-snug mb-2">도쿄
							숙소 최대 15% 할인</h3>
						<div class="home-popular-ad-link text-[10px] font-bold">광고
							보기 →</div>
					</div>
				</a> <a
					href="${pageContext.request.contextPath}/view/travel/scheduleDetail.jsp?id=10"
					class="jsp-home-schedule-card home-popular-card shrink-0 bg-white rounded-2xl overflow-hidden cursor-pointer border">
					<div class="home-popular-card-image relative overflow-hidden">
						<img
							src="https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=600&amp;h=400&amp;fit=crop"
							alt="발리 5박 6일 힐링 휴양"
							class="w-full h-full object-cover transition-transform duration-300">
						<div
							class="absolute inset-0 bg-gradient-to-t from-black/50 via-transparent to-transparent"></div>
						<span
							class="home-popular-location absolute top-2 left-2 text-[10px] font-bold px-2 py-0.5 rounded-full text-white">발리</span>
						<button
							class="absolute top-2 right-2 w-6 h-6 rounded-full bg-white/90 backdrop-blur-sm flex items-center justify-center shadow-sm transition-transform hover:scale-110"
							type="button" data-bookmark aria-label="북마크">
							<svg width="11" height="11" viewBox="0 0 24 24" fill="none"
								stroke="#9ca3af" stroke-width="2">
								<path stroke-linecap="round" stroke-linejoin="round"
									d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" /></svg>
						</button>
						<span
							class="absolute bottom-2 left-2 text-white text-[10px] font-bold bg-black/50 rounded-full px-2 py-0.5">5박
							6일</span>
					</div>
					<div class="p-3">
						<h3
							class="home-popular-title font-bold text-[13px] leading-snug mb-0.5 line-clamp-2 transition-colors">발리
							5박 6일 힐링 휴양</h3>
						<p
							class="text-gray-500 text-[11px] line-clamp-1 mb-2 leading-relaxed">우붓
							라이스테라스, 울루와뚜 사원, 짱구 카페까지 발리 완전정복.</p>
						<div
							class="flex items-center gap-2.5 text-[10px] text-gray-400 mb-2.5">
							<span class="flex items-center gap-0.5"><svg width="10"
									height="10" viewBox="0 0 24 24" fill="none" stroke="#9ca3af"
									stroke-width="2">
									<path stroke-linecap="round" stroke-linejoin="round"
										d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" /></svg><span
								class="font-medium">892</span></span> <span
								class="flex items-center gap-0.5"><svg width="10"
									height="10" fill="none" stroke="currentColor"
									viewBox="0 0 24 24">
									<path stroke-linecap="round" stroke-linejoin="round"
										stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
									<path stroke-linecap="round" stroke-linejoin="round"
										stroke-width="2"
										d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" /></svg>3,890</span>
						</div>
						<div
							class="home-popular-author flex items-center justify-between border-t pt-2">
							<div class="flex items-center gap-1.5">
								<img src="https://i.pravatar.cc/40?img=19" alt="발리덕후"
									class="w-4 h-4 rounded-full object-cover"><span
									class="text-[10px] text-gray-500 font-medium">발리덕후</span>
							</div>
							<span class="text-[9px] text-gray-400">2026.08.22</span>
						</div>
					</div>
				</a> <a
					href="${pageContext.request.contextPath}/view/travel/scheduleDetail.jsp?id=14"
					class="jsp-home-schedule-card home-popular-card shrink-0 bg-white rounded-2xl overflow-hidden cursor-pointer border">
					<div class="home-popular-card-image relative overflow-hidden">
						<img
							src="https://images.unsplash.com/photo-1559592413-7cec4d0cae2b?w=600&amp;h=400&amp;fit=crop"
							alt="다낭 3박 4일 바다 &amp; 리조트"
							class="w-full h-full object-cover transition-transform duration-300">
						<div
							class="absolute inset-0 bg-gradient-to-t from-black/50 via-transparent to-transparent"></div>
						<span
							class="home-popular-location absolute top-2 left-2 text-[10px] font-bold px-2 py-0.5 rounded-full text-white">다낭</span>
						<button
							class="absolute top-2 right-2 w-6 h-6 rounded-full bg-white/90 backdrop-blur-sm flex items-center justify-center shadow-sm transition-transform hover:scale-110"
							type="button" data-bookmark aria-label="북마크">
							<svg width="11" height="11" viewBox="0 0 24 24" fill="none"
								stroke="#9ca3af" stroke-width="2">
								<path stroke-linecap="round" stroke-linejoin="round"
									d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" /></svg>
						</button>
						<span
							class="absolute bottom-2 left-2 text-white text-[10px] font-bold bg-black/50 rounded-full px-2 py-0.5">3박
							4일</span>
					</div>
					<div class="p-3">
						<h3
							class="home-popular-title font-bold text-[13px] leading-snug mb-0.5 line-clamp-2 transition-colors">다낭
							3박 4일 바다 &amp; 리조트</h3>
						<p
							class="text-gray-500 text-[11px] line-clamp-1 mb-2 leading-relaxed">미케
							비치, 바나힐, 호이안 올드타운까지! 베트남 중부의 진주.</p>
						<div
							class="flex items-center gap-2.5 text-[10px] text-gray-400 mb-2.5">
							<span class="flex items-center gap-0.5"><svg width="10"
									height="10" viewBox="0 0 24 24" fill="none" stroke="#9ca3af"
									stroke-width="2">
									<path stroke-linecap="round" stroke-linejoin="round"
										d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" /></svg><span
								class="font-medium">712</span></span> <span
								class="flex items-center gap-0.5"><svg width="10"
									height="10" fill="none" stroke="currentColor"
									viewBox="0 0 24 24">
									<path stroke-linecap="round" stroke-linejoin="round"
										stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
									<path stroke-linecap="round" stroke-linejoin="round"
										stroke-width="2"
										d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" /></svg>3,200</span>
						</div>
						<div
							class="home-popular-author flex items-center justify-between border-t pt-2">
							<div class="flex items-center gap-1.5">
								<img src="https://i.pravatar.cc/40?img=27" alt="다낭러버"
									class="w-4 h-4 rounded-full object-cover"><span
									class="text-[10px] text-gray-500 font-medium">다낭러버</span>
							</div>
							<span class="text-[9px] text-gray-400">2026.09.01</span>
						</div>
					</div>
				</a> <a
					href="${pageContext.request.contextPath}/view/travel/scheduleDetail.jsp?id=8"
					class="jsp-home-schedule-card home-popular-card shrink-0 bg-white rounded-2xl overflow-hidden cursor-pointer border">
					<div class="home-popular-card-image relative overflow-hidden">
						<img
							src="https://images.unsplash.com/photo-1506665531195-3566af2b548e?w=600&amp;h=400&amp;fit=crop"
							alt="방콕 4박 5일 사원 &amp; 야시장"
							class="w-full h-full object-cover transition-transform duration-300">
						<div
							class="absolute inset-0 bg-gradient-to-t from-black/50 via-transparent to-transparent"></div>
						<span
							class="home-popular-location absolute top-2 left-2 text-[10px] font-bold px-2 py-0.5 rounded-full text-white">방콕</span>
						<button
							class="absolute top-2 right-2 w-6 h-6 rounded-full bg-white/90 backdrop-blur-sm flex items-center justify-center shadow-sm transition-transform hover:scale-110"
							type="button" data-bookmark aria-label="북마크">
							<svg width="11" height="11" viewBox="0 0 24 24" fill="none"
								stroke="#9ca3af" stroke-width="2">
								<path stroke-linecap="round" stroke-linejoin="round"
									d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" /></svg>
						</button>
						<span
							class="absolute bottom-2 left-2 text-white text-[10px] font-bold bg-black/50 rounded-full px-2 py-0.5">4박
							5일</span>
					</div>
					<div class="p-3">
						<h3
							class="home-popular-title font-bold text-[13px] leading-snug mb-0.5 line-clamp-2 transition-colors">방콕
							4박 5일 사원 &amp; 야시장</h3>
						<p
							class="text-gray-500 text-[11px] line-clamp-1 mb-2 leading-relaxed">왕궁,
							왓포, 차오프라야강과 야시장까지! 방콕의 매력에 빠져봐요.</p>
						<div
							class="flex items-center gap-2.5 text-[10px] text-gray-400 mb-2.5">
							<span class="flex items-center gap-0.5"><svg width="10"
									height="10" viewBox="0 0 24 24" fill="none" stroke="#9ca3af"
									stroke-width="2">
									<path stroke-linecap="round" stroke-linejoin="round"
										d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" /></svg><span
								class="font-medium">678</span></span> <span
								class="flex items-center gap-0.5"><svg width="10"
									height="10" fill="none" stroke="currentColor"
									viewBox="0 0 24 24">
									<path stroke-linecap="round" stroke-linejoin="round"
										stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
									<path stroke-linecap="round" stroke-linejoin="round"
										stroke-width="2"
										d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" /></svg>3,100</span>
						</div>
						<div
							class="home-popular-author flex items-center justify-between border-t pt-2">
							<div class="flex items-center gap-1.5">
								<img src="https://i.pravatar.cc/40?img=15" alt="태국덕후"
									class="w-4 h-4 rounded-full object-cover"><span
									class="text-[10px] text-gray-500 font-medium">태국덕후</span>
							</div>
							<span class="text-[9px] text-gray-400">2026.08.18</span>
						</div>
					</div>
				</a> <a
					href="${pageContext.request.contextPath}/view/travel/scheduleDetail.jsp?id=12"
					class="jsp-home-schedule-card home-popular-card shrink-0 bg-white rounded-2xl overflow-hidden cursor-pointer border">
					<div class="home-popular-card-image relative overflow-hidden">
						<img
							src="https://images.unsplash.com/photo-1539037116277-4db20889f2d4?w=600&amp;h=400&amp;fit=crop"
							alt="바르셀로나 4박 5일 가우디 투어"
							class="w-full h-full object-cover transition-transform duration-300">
						<div
							class="absolute inset-0 bg-gradient-to-t from-black/50 via-transparent to-transparent"></div>
						<span
							class="home-popular-location absolute top-2 left-2 text-[10px] font-bold px-2 py-0.5 rounded-full text-white">바르셀로나</span>
						<button
							class="absolute top-2 right-2 w-6 h-6 rounded-full bg-white/90 backdrop-blur-sm flex items-center justify-center shadow-sm transition-transform hover:scale-110"
							type="button" data-bookmark aria-label="북마크">
							<svg width="11" height="11" viewBox="0 0 24 24" fill="none"
								stroke="#9ca3af" stroke-width="2">
								<path stroke-linecap="round" stroke-linejoin="round"
									d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" /></svg>
						</button>
						<span
							class="absolute bottom-2 left-2 text-white text-[10px] font-bold bg-black/50 rounded-full px-2 py-0.5">4박
							5일</span>
					</div>
					<div class="p-3">
						<h3
							class="home-popular-title font-bold text-[13px] leading-snug mb-0.5 line-clamp-2 transition-colors">바르셀로나
							4박 5일 가우디 투어</h3>
						<p
							class="text-gray-500 text-[11px] line-clamp-1 mb-2 leading-relaxed">사그라다
							파밀리아, 구엘공원, 바르셀로나 해변까지 가우디의 도시.</p>
						<div
							class="flex items-center gap-2.5 text-[10px] text-gray-400 mb-2.5">
							<span class="flex items-center gap-0.5"><svg width="10"
									height="10" viewBox="0 0 24 24" fill="none" stroke="#9ca3af"
									stroke-width="2">
									<path stroke-linecap="round" stroke-linejoin="round"
										d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" /></svg><span
								class="font-medium">634</span></span> <span
								class="flex items-center gap-0.5"><svg width="10"
									height="10" fill="none" stroke="currentColor"
									viewBox="0 0 24 24">
									<path stroke-linecap="round" stroke-linejoin="round"
										stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
									<path stroke-linecap="round" stroke-linejoin="round"
										stroke-width="2"
										d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" /></svg>2,890</span>
						</div>
						<div
							class="home-popular-author flex items-center justify-between border-t pt-2">
							<div class="flex items-center gap-1.5">
								<img src="https://i.pravatar.cc/40?img=23" alt="스페인러버"
									class="w-4 h-4 rounded-full object-cover"><span
									class="text-[10px] text-gray-500 font-medium">스페인러버</span>
							</div>
							<span class="text-[9px] text-gray-400">2026.08.08</span>
						</div>
					</div>
				</a> <a
					href="${pageContext.request.contextPath}/view/travel/scheduleDetail.jsp?id=3"
					class="jsp-home-schedule-card home-popular-card shrink-0 bg-white rounded-2xl overflow-hidden cursor-pointer border">
					<div class="home-popular-card-image relative overflow-hidden">
						<img
							src="https://images.unsplash.com/photo-1538485399081-7191377e8241?w=600&amp;h=400&amp;fit=crop"
							alt="부산 1박 2일 바다 여행"
							class="w-full h-full object-cover transition-transform duration-300">
						<div
							class="absolute inset-0 bg-gradient-to-t from-black/50 via-transparent to-transparent"></div>
						<span
							class="home-popular-location absolute top-2 left-2 text-[10px] font-bold px-2 py-0.5 rounded-full text-white">부산</span>
						<button
							class="absolute top-2 right-2 w-6 h-6 rounded-full bg-white/90 backdrop-blur-sm flex items-center justify-center shadow-sm transition-transform hover:scale-110"
							type="button" data-bookmark aria-label="북마크">
							<svg width="11" height="11" viewBox="0 0 24 24" fill="none"
								stroke="#9ca3af" stroke-width="2">
								<path stroke-linecap="round" stroke-linejoin="round"
									d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" /></svg>
						</button>
						<span
							class="absolute bottom-2 left-2 text-white text-[10px] font-bold bg-black/50 rounded-full px-2 py-0.5">1박
							2일</span>
					</div>
					<div class="p-3">
						<h3
							class="home-popular-title font-bold text-[13px] leading-snug mb-0.5 line-clamp-2 transition-colors">부산
							1박 2일 바다 여행</h3>
						<p
							class="text-gray-500 text-[11px] line-clamp-1 mb-2 leading-relaxed">해운대와
							광안리, 자갈치시장까지! 부산 핵심 코스.</p>
						<div
							class="flex items-center gap-2.5 text-[10px] text-gray-400 mb-2.5">
							<span class="flex items-center gap-0.5"><svg width="10"
									height="10" viewBox="0 0 24 24" fill="none" stroke="#9ca3af"
									stroke-width="2">
									<path stroke-linecap="round" stroke-linejoin="round"
										d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" /></svg><span
								class="font-medium">512</span></span> <span
								class="flex items-center gap-0.5"><svg width="10"
									height="10" fill="none" stroke="currentColor"
									viewBox="0 0 24 24">
									<path stroke-linecap="round" stroke-linejoin="round"
										stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
									<path stroke-linecap="round" stroke-linejoin="round"
										stroke-width="2"
										d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" /></svg>2,341</span>
						</div>
						<div
							class="home-popular-author flex items-center justify-between border-t pt-2">
							<div class="flex items-center gap-1.5">
								<img src="https://i.pravatar.cc/40?img=5" alt="바다러버"
									class="w-4 h-4 rounded-full object-cover"><span
									class="text-[10px] text-gray-500 font-medium">바다러버</span>
							</div>
							<span class="text-[9px] text-gray-400">2026.08.10</span>
						</div>
					</div>
				</a>
=======
				
					</a>
				</c:forEach>
>>>>>>> branch 'origin' of https://github.com/yoooong96/Planb.git
			</div>
		</section>

		<!-- ========================================
		     HOME - 3번 구역
		     여행일정 만들기 CTA
		======================================== -->
		<section id="homeArea3" class="home-create-plan">

			<div class="home-create-plan-content">

				<div class="home-create-plan-route" aria-hidden="true">
					<span class="home-create-plan-route-point"></span> <span
						class="home-create-plan-route-line"></span> <span
						class="home-create-plan-route-plane">✈</span> <span
						class="home-create-plan-route-line"></span> <span
						class="home-create-plan-route-point"></span>
				</div>

				<!-- 상단 영문 문구 -->
				<span class="home-create-plan-eyebrow"> CREATE YOUR JOURNEY </span>

				<!-- 메인 문구 -->
				<h2 class="home-create-plan-title">
					마음에 드는 여행을 발견하셨나요? <br> 이제 나만의 여행을 만들어보세요.
				</h2>

				<!-- 설명 문구 -->
				<p class="home-create-plan-description">
					가고 싶은 장소와 일정을 자유롭게 담아 <br> 나만의 특별한 여행 계획을 완성해보세요.
				</p>

				<!-- 일정 만들기 버튼 -->
				<a
					href="${pageContext.request.contextPath}/view/itinerary/planner.jsp"
					class="home-create-plan-button"> 일정 만들기 <span
					aria-hidden="true">→</span>
				</a>

			</div>

		</section>
<<<<<<< HEAD

=======
		
		<!-- 여행 꿀팁 / 여행 메이트 -->
>>>>>>> branch 'origin' of https://github.com/yoooong96/Planb.git
		<section id="homeArea4">
			<div class="home-area4-content px-4 md:px-8 max-w-6xl mx-auto">
		
				<div class="grid grid-cols-1 md:grid-cols-2 gap-6 items-stretch">
		
					<!-- 여행 꿀팁 -->
					<div class="flex flex-col">
						<div class="flex items-end justify-between mb-6">
							<div>
								<p class="text-xs font-bold tracking-widest uppercase mb-1"
									style="color: var(- -brand)">Travel Tips</p>
								<h2 class="text-xl font-extrabold text-gray-900">여행꿀팁</h2>
								<p class="text-xs text-gray-400 mt-0.5">여행 고수들의 노하우</p>
							</div>
<<<<<<< HEAD
							<a
								href="${pageContext.request.contextPath}/view/tips/tipList.jsp"
=======
		
							<a
								href="${pageContext.request.contextPath}/tips"
>>>>>>> branch 'origin' of https://github.com/yoooong96/Planb.git
								class="jsp-more-button flex items-center gap-2 px-5 py-2.5 rounded-xl border-2 text-sm font-bold transition-all"
<<<<<<< HEAD
								style="border-color: var(- -brand); color: var(- -brand)">더보기<svg
									width="14" height="14" viewBox="0 0 24 24" fill="none"
									stroke="currentColor" stroke-width="2.5">
									<path d="M5 12h14M12 5l7 7-7 7" /></svg></a>
=======
								style="border-color: var(--brand); color: var(--brand)">
								더보기
								<svg
									width="14"
									height="14"
									viewBox="0 0 24 24"
									fill="none"
									stroke="currentColor"
									stroke-width="2.5">
									<path d="M5 12h14M12 5l7 7-7 7" />
								</svg>
							</a>
>>>>>>> branch 'origin' of https://github.com/yoooong96/Planb.git
						</div>
		
						<div data-rotate-group class="flex-1">
							<c:forEach var="page" begin="0" end="2">
								<div
									class="flex flex-col gap-3 home-rotate-page"
									style="${page == 0 ? '' : 'display: none;'}">
						
									<c:forEach
										var="tip"
										items="${tipList}"
										begin="${page * 3}"
										end="${page * 3 + 2}">
						
										<a
											href="${pageContext.request.contextPath}/tipDetail?tipId=${tip.tipId}"
											class="jsp-preview-card preview-item-enter flex gap-4 p-4 bg-white rounded-2xl border border-gray-100 shadow-sm text-left w-full group transition-all"
											style="height: 96px">
						
											<div
<<<<<<< HEAD
												class="w-4 h-4 rounded-full flex items-center justify-center text-white text-[8px] font-bold"
												style="background-color: #F59E0B">민</div>
											<span class="text-[10px] text-gray-400">민수 · 1일 전</span>
										</div>
									</div>
								</a><a
									href="${pageContext.request.contextPath}/view/tips/tipDetail.jsp?id=6"
									class="jsp-preview-card preview-item-enter flex gap-4 p-4 bg-white rounded-2xl border border-gray-100 shadow-sm text-left w-full group transition-all"
									style="height: 96px">
									<div class="shrink-0 rounded-xl overflow-hidden"
										style="width: 68px; height: 64px">
										<img
											src="https://images.unsplash.com/photo-1561501900-3701fa6a0864?crop=entropy&amp;cs=tinysrgb&amp;fit=max&amp;fm=jpg&amp;ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwyfHxob3RlbCUyMGx1eHVyeSUyMHJlc29ydCUyMGFjY29tbW9kYXRpb258ZW58MXx8fHwxNzg5MjgzNjU4fDA&amp;ixlib=rb-4.1.0&amp;q=80&amp;w=600"
											alt="발리 숙소 지역별 추천 (꾸따, 스미냑, 우붓 비교)"
											class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300">
									</div>
									<div class="flex-1 min-w-0 flex flex-col justify-center">
										<span
											class="inline-block text-[10px] font-bold px-2 py-0.5 rounded-full mb-1 self-start"
											style="color: #3B82F6; background-color: #EFF6FF">숙박</span>
										<h3
											class="font-bold text-[13px] text-gray-900 mb-0.5 line-clamp-1 group-hover:text-[#6369D1] transition-colors">발리
											숙소 지역별 추천 (꾸따, 스미냑, 우붓 비교)</h3>
										<div class="flex items-center gap-1">
											<div
												class="w-4 h-4 rounded-full flex items-center justify-center text-white text-[8px] font-bold"
												style="background-color: #10B981">한</div>
											<span class="text-[10px] text-gray-400">한우 · 3일 전</span>
										</div>
									</div>
								</a><a
									href="${pageContext.request.contextPath}/view/tips/tipDetail.jsp?id=4"
									class="jsp-preview-card preview-item-enter flex gap-4 p-4 bg-white rounded-2xl border border-gray-100 shadow-sm text-left w-full group transition-all"
									style="height: 96px">
									<div class="shrink-0 rounded-xl overflow-hidden"
										style="width: 68px; height: 64px">
										<img
											src="https://images.unsplash.com/photo-1488415032361-b7e238421f1b?crop=entropy&amp;cs=tinysrgb&amp;fit=max&amp;fm=jpg&amp;ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxub3J0aGVybiUyMGxpZ2h0cyUyMGF1cm9yYSUyMGljZWxhbmQlMjBjdWx0dXJlfGVufDF8fHx8MTc4OTI4MzY1OXww&amp;ixlib=rb-4.1.0&amp;q=80&amp;w=600"
											alt="아이슬란드 오로라 여행 팁 (시기, 준비물, 촬영방법)"
											class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300">
									</div>
									<div class="flex-1 min-w-0 flex flex-col justify-center">
										<span
											class="inline-block text-[10px] font-bold px-2 py-0.5 rounded-full mb-1 self-start"
											style="color: #10B981; background-color: #ECFDF5">문화</span>
										<h3
											class="font-bold text-[13px] text-gray-900 mb-0.5 line-clamp-1 group-hover:text-[#6369D1] transition-colors">아이슬란드
											오로라 여행 팁 (시기, 준비물, 촬영방법)</h3>
										<div class="flex items-center gap-1">
											<div
												class="w-4 h-4 rounded-full flex items-center justify-center text-white text-[8px] font-bold"
												style="background-color: #EC4899">나</div>
											<span class="text-[10px] text-gray-400">나 · 1일 전</span>
										</div>
									</div>
								</a>
							</div>
							<!-- 2번째 묶음 -->
							<div class="flex flex-col gap-3 home-rotate-page"
								style="display: none;">
								<a
									href="${pageContext.request.contextPath}/view/tips/tipDetail.jsp?id=3"
									class="jsp-preview-card preview-item-enter flex gap-4 p-4 bg-white rounded-2xl border border-gray-100 shadow-sm text-left w-full group transition-all"
									style="height: 96px">
									<div class="shrink-0 rounded-xl overflow-hidden"
										style="width: 68px; height: 64px">
										<img
											src="https://images.unsplash.com/photo-1591814468924-caf88d1232e1?crop=entropy&amp;cs=tinysrgb&amp;fit=max&amp;fm=jpg&amp;ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxyYW1lbiUyMG5vb2RsZSUyMGphcGFuZXNlJTIwZm9vZCUyMGJvd2x8ZW58MXx8fHwxNzg5MjgzNjU5fDA&amp;ixlib=rb-4.1.0&amp;q=80&amp;w=600"
											alt="후쿠오카에서 꼭 먹어야 하는 현지 음식 7가지"
											class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300">
									</div>
									<div class="flex-1 min-w-0 flex flex-col justify-center">
										<span
											class="inline-block text-[10px] font-bold px-2 py-0.5 rounded-full mb-1 self-start"
											style="color: #F59E0B; background-color: #FFFBEB">음식</span>
										<h3
											class="font-bold text-[13px] text-gray-900 mb-0.5 line-clamp-1 group-hover:text-[#6369D1] transition-colors">후쿠오카에서
											꼭 먹어야 하는 현지 음식 7가지</h3>
										<div class="flex items-center gap-1">
											<div
												class="w-4 h-4 rounded-full flex items-center justify-center text-white text-[8px] font-bold"
												style="background-color: #F59E0B">민</div>
											<span class="text-[10px] text-gray-400">민수 · 1일 전</span>
										</div>
									</div>
								</a><a
									href="${pageContext.request.contextPath}/view/tips/tipDetail.jsp?id=6"
									class="jsp-preview-card preview-item-enter flex gap-4 p-4 bg-white rounded-2xl border border-gray-100 shadow-sm text-left w-full group transition-all"
									style="height: 96px">
									<div class="shrink-0 rounded-xl overflow-hidden"
										style="width: 68px; height: 64px">
										<img
											src="https://images.unsplash.com/photo-1561501900-3701fa6a0864?crop=entropy&amp;cs=tinysrgb&amp;fit=max&amp;fm=jpg&amp;ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwyfHxob3RlbCUyMGx1eHVyeSUyMHJlc29ydCUyMGFjY29tbW9kYXRpb258ZW58MXx8fHwxNzg5MjgzNjU4fDA&amp;ixlib=rb-4.1.0&amp;q=80&amp;w=600"
											alt="발리 숙소 지역별 추천 (꾸따, 스미냑, 우붓 비교)"
											class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300">
									</div>
									<div class="flex-1 min-w-0 flex flex-col justify-center">
										<span
											class="inline-block text-[10px] font-bold px-2 py-0.5 rounded-full mb-1 self-start"
											style="color: #3B82F6; background-color: #EFF6FF">숙박</span>
										<h3
											class="font-bold text-[13px] text-gray-900 mb-0.5 line-clamp-1 group-hover:text-[#6369D1] transition-colors">발리
											숙소 지역별 추천 (꾸따, 스미냑, 우붓 비교)</h3>
										<div class="flex items-center gap-1">
											<div
												class="w-4 h-4 rounded-full flex items-center justify-center text-white text-[8px] font-bold"
												style="background-color: #10B981">한</div>
											<span class="text-[10px] text-gray-400">한우 · 3일 전</span>
										</div>
									</div>
								</a><a
									href="${pageContext.request.contextPath}/view/tips/tipDetail.jsp?id=4"
									class="jsp-preview-card preview-item-enter flex gap-4 p-4 bg-white rounded-2xl border border-gray-100 shadow-sm text-left w-full group transition-all"
									style="height: 96px">
									<div class="shrink-0 rounded-xl overflow-hidden"
										style="width: 68px; height: 64px">
										<img
											src="https://images.unsplash.com/photo-1488415032361-b7e238421f1b?crop=entropy&amp;cs=tinysrgb&amp;fit=max&amp;fm=jpg&amp;ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxub3J0aGVybiUyMGxpZ2h0cyUyMGF1cm9yYSUyMGljZWxhbmQlMjBjdWx0dXJlfGVufDF8fHx8MTc4OTI4MzY1OXww&amp;ixlib=rb-4.1.0&amp;q=80&amp;w=600"
											alt="아이슬란드 오로라 여행 팁 (시기, 준비물, 촬영방법)"
											class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300">
									</div>
									<div class="flex-1 min-w-0 flex flex-col justify-center">
										<span
											class="inline-block text-[10px] font-bold px-2 py-0.5 rounded-full mb-1 self-start"
											style="color: #10B981; background-color: #ECFDF5">문화</span>
										<h3
											class="font-bold text-[13px] text-gray-900 mb-0.5 line-clamp-1 group-hover:text-[#6369D1] transition-colors">아이슬란드
											오로라 여행 팁 (시기, 준비물, 촬영방법)</h3>
										<div class="flex items-center gap-1">
											<div
												class="w-4 h-4 rounded-full flex items-center justify-center text-white text-[8px] font-bold"
												style="background-color: #EC4899">나</div>
											<span class="text-[10px] text-gray-400">나 · 1일 전</span>
										</div>
									</div>
								</a>
							</div>
							<!-- 3번째 묶음 -->
							<div class="flex flex-col gap-3 home-rotate-page"
								style="display: none;">
								<a
									href="${pageContext.request.contextPath}/view/tips/tipDetail.jsp?id=3"
									class="jsp-preview-card preview-item-enter flex gap-4 p-4 bg-white rounded-2xl border border-gray-100 shadow-sm text-left w-full group transition-all"
									style="height: 96px">
									<div class="shrink-0 rounded-xl overflow-hidden"
										style="width: 68px; height: 64px">
										<img
											src="https://images.unsplash.com/photo-1591814468924-caf88d1232e1?crop=entropy&amp;cs=tinysrgb&amp;fit=max&amp;fm=jpg&amp;ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxyYW1lbiUyMG5vb2RsZSUyMGphcGFuZXNlJTIwZm9vZCUyMGJvd2x8ZW58MXx8fHwxNzg5MjgzNjU5fDA&amp;ixlib=rb-4.1.0&amp;q=80&amp;w=600"
											alt="후쿠오카에서 꼭 먹어야 하는 현지 음식 7가지"
											class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300">
									</div>
									<div class="flex-1 min-w-0 flex flex-col justify-center">
										<span
											class="inline-block text-[10px] font-bold px-2 py-0.5 rounded-full mb-1 self-start"
											style="color: #F59E0B; background-color: #FFFBEB">음식</span>
										<h3
											class="font-bold text-[13px] text-gray-900 mb-0.5 line-clamp-1 group-hover:text-[#6369D1] transition-colors">후쿠오카에서
											꼭 먹어야 하는 현지 음식 7가지</h3>
										<div class="flex items-center gap-1">
											<div
												class="w-4 h-4 rounded-full flex items-center justify-center text-white text-[8px] font-bold"
												style="background-color: #F59E0B">민</div>
											<span class="text-[10px] text-gray-400">민수 · 1일 전</span>
										</div>
									</div>
								</a><a
									href="${pageContext.request.contextPath}/view/tips/tipDetail.jsp?id=6"
									class="jsp-preview-card preview-item-enter flex gap-4 p-4 bg-white rounded-2xl border border-gray-100 shadow-sm text-left w-full group transition-all"
									style="height: 96px">
									<div class="shrink-0 rounded-xl overflow-hidden"
										style="width: 68px; height: 64px">
										<img
											src="https://images.unsplash.com/photo-1561501900-3701fa6a0864?crop=entropy&amp;cs=tinysrgb&amp;fit=max&amp;fm=jpg&amp;ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwyfHxob3RlbCUyMGx1eHVyeSUyMHJlc29ydCUyMGFjY29tbW9kYXRpb258ZW58MXx8fHwxNzg5MjgzNjU4fDA&amp;ixlib=rb-4.1.0&amp;q=80&amp;w=600"
											alt="발리 숙소 지역별 추천 (꾸따, 스미냑, 우붓 비교)"
											class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300">
									</div>
									<div class="flex-1 min-w-0 flex flex-col justify-center">
										<span
											class="inline-block text-[10px] font-bold px-2 py-0.5 rounded-full mb-1 self-start"
											style="color: #3B82F6; background-color: #EFF6FF">숙박</span>
										<h3
											class="font-bold text-[13px] text-gray-900 mb-0.5 line-clamp-1 group-hover:text-[#6369D1] transition-colors">발리
											숙소 지역별 추천 (꾸따, 스미냑, 우붓 비교)</h3>
										<div class="flex items-center gap-1">
											<div
												class="w-4 h-4 rounded-full flex items-center justify-center text-white text-[8px] font-bold"
												style="background-color: #10B981">한</div>
											<span class="text-[10px] text-gray-400">한우 · 3일 전</span>
										</div>
									</div>
								</a><a
									href="${pageContext.request.contextPath}/view/tips/tipDetail.jsp?id=4"
									class="jsp-preview-card preview-item-enter flex gap-4 p-4 bg-white rounded-2xl border border-gray-100 shadow-sm text-left w-full group transition-all"
									style="height: 96px">
									<div class="shrink-0 rounded-xl overflow-hidden"
										style="width: 68px; height: 64px">
										<img
											src="https://images.unsplash.com/photo-1488415032361-b7e238421f1b?crop=entropy&amp;cs=tinysrgb&amp;fit=max&amp;fm=jpg&amp;ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxub3J0aGVybiUyMGxpZ2h0cyUyMGF1cm9yYSUyMGljZWxhbmQlMjBjdWx0dXJlfGVufDF8fHx8MTc4OTI4MzY1OXww&amp;ixlib=rb-4.1.0&amp;q=80&amp;w=600"
											alt="아이슬란드 오로라 여행 팁 (시기, 준비물, 촬영방법)"
											class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300">
									</div>
									<div class="flex-1 min-w-0 flex flex-col justify-center">
										<span
											class="inline-block text-[10px] font-bold px-2 py-0.5 rounded-full mb-1 self-start"
											style="color: #10B981; background-color: #ECFDF5">문화</span>
										<h3
											class="font-bold text-[13px] text-gray-900 mb-0.5 line-clamp-1 group-hover:text-[#6369D1] transition-colors">아이슬란드
											오로라 여행 팁 (시기, 준비물, 촬영방법)</h3>
										<div class="flex items-center gap-1">
											<div
												class="w-4 h-4 rounded-full flex items-center justify-center text-white text-[8px] font-bold"
												style="background-color: #EC4899">나</div>
											<span class="text-[10px] text-gray-400">나 · 1일 전</span>
										</div>
									</div>
								</a>
							</div>
=======
												class="shrink-0 rounded-xl overflow-hidden bg-gray-100"
												style="width: 68px; height: 64px">
						
												<c:choose>
													<c:when test="${not empty tip.thumbnailImg}">
														<img
															src="${pageContext.request.contextPath}${tip.thumbnailImg}"
															alt="${tip.title}"
															class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300">
													</c:when>
						
													<c:otherwise>
														<div class="w-full h-full flex items-center justify-center text-[10px] text-gray-400">
															이미지 없음
														</div>
													</c:otherwise>
												</c:choose>
						
											</div>
						
											<div class="flex-1 min-w-0 flex flex-col justify-center">
						
												<c:if test="${not empty tip.country}">
													<span
														class="inline-block text-[10px] font-bold px-2 py-0.5 rounded-full mb-1 self-start"
														style="color: #6369D1; background-color: #F0F1FF">
														<c:out value="${tip.country}" />
													</span>
												</c:if>
						
												<h3
													class="font-bold text-[13px] text-gray-900 mb-0.5 line-clamp-1 group-hover:text-[#6369D1] transition-colors">
													<c:out value="${tip.title}" />
												</h3>
						
												<div class="flex items-center gap-1">
													<div
														class="w-4 h-4 rounded-full flex items-center justify-center text-white text-[8px] font-bold"
														style="background-color: #6369D1">
														<c:out value="${tip.nickname.substring(0, 1)}" />
													</div>
						
													<span class="text-[10px] text-gray-400">
														<c:out value="${tip.nickname}" />
													</span>
												</div>
						
											</div>
										</a>
						
									</c:forEach>
						
								</div>
							</c:forEach>
>>>>>>> branch 'origin' of https://github.com/yoooong96/Planb.git
						</div>
<<<<<<< HEAD
						<div
							class="home-progress flex items-center justify-center gap-2 mt-5">
							<button type="button"
=======
						
						<div class="home-progress flex items-center justify-center gap-2 mt-5">
							<button
								type="button"
>>>>>>> branch 'origin' of https://github.com/yoooong96/Planb.git
								class="home-progress-bar jsp-progress-active relative overflow-hidden rounded-full"
								style="width: 44px; height: 9px; background-color: #e5e7eb">
							</button>
						
							<button
								type="button"
								class="home-progress-bar relative overflow-hidden rounded-full"
								style="width: 44px; height: 9px; background-color: #e5e7eb">
							</button>
						
							<button
								type="button"
								class="home-progress-bar relative overflow-hidden rounded-full"
								style="width: 44px; height: 9px; background-color: #e5e7eb">
							</button>
						</div>
		
							<c:if test="${empty tipList}">
								<div
									class="flex items-center justify-center bg-white rounded-2xl border border-gray-100 text-sm text-gray-400"
									style="height: 96px">
									등록된 여행꿀팁이 없습니다.
								</div>
							</c:if>
					</div>
		
		
					<!-- 여행 메이트 -->
					<div class="flex flex-col">
						<div class="flex items-end justify-between mb-6">
							<div>
								<p class="text-xs font-bold tracking-widest uppercase mb-1"
									style="color: var(- -brand)">Travel Mate</p>
								<h2 class="text-xl font-extrabold text-gray-900">여행 메이트</h2>
								<p class="text-xs text-gray-400 mt-0.5">함께 여행할 동반자</p>
							</div>
		
							<a
								href="${pageContext.request.contextPath}/mates"
								class="jsp-more-button flex items-center gap-2 px-5 py-2.5 rounded-xl border-2 text-sm font-bold transition-all"
<<<<<<< HEAD
								style="border-color: var(- -brand); color: var(- -brand)">더보기<svg
									width="14" height="14" viewBox="0 0 24 24" fill="none"
									stroke="currentColor" stroke-width="2.5">
									<path d="M5 12h14M12 5l7 7-7 7" /></svg></a>
=======
								style="border-color: var(--brand); color: var(--brand)">
								더보기
								<svg
									width="14"
									height="14"
									viewBox="0 0 24 24"
									fill="none"
									stroke="currentColor"
									stroke-width="2.5">
									<path d="M5 12h14M12 5l7 7-7 7" />
								</svg>
							</a>
>>>>>>> branch 'origin' of https://github.com/yoooong96/Planb.git
						</div>
<<<<<<< HEAD
						<div data-rotate-group>
							<div class="flex flex-col gap-3 home-rotate-page">
								<a
									href="${pageContext.request.contextPath}/view/mate/mateDetail.jsp?id=4"
									class="jsp-preview-card preview-item-enter flex gap-4 p-4 bg-white rounded-2xl border border-gray-100 shadow-sm text-left w-full group transition-all"
									style="height: 96px">
									<div
										class="shrink-0 rounded-xl flex flex-col items-center justify-center gap-1 font-bold"
										style="width: 68px; height: 64px; background-color: var(- -brand-soft); color: var(- -brand)">
										<svg width="18" height="18" viewBox="0 0 24 24" fill="none"
											stroke="currentColor" stroke-width="2">
											<path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z" />
											<circle cx="12" cy="10" r="3" /></svg>
										<span
											class="text-[10px] font-bold leading-tight text-center px-1 line-clamp-2">이탈리아</span>
									</div>
									<div class="flex-1 min-w-0 flex flex-col justify-center">
										<div class="flex items-center gap-1.5 mb-0.5">
											<span class="text-[11px] font-semibold"
												style="color: var(- -brand)">이탈리아 · 로마</span><span
												class="text-[10px] font-bold px-1.5 py-0.5 rounded-full"
												style="background-color: var(- -brand-light); color: var(- -brand)">2명
												모집</span>
										</div>
										<h3
											class="font-bold text-[13px] text-gray-900 mb-0.5 line-clamp-1 group-hover:text-[#6369D1] transition-colors">🍕
											10/15-22 로마·피렌체·베네치아 맛집 여행 동행</h3>
										<div class="flex items-center gap-1">
=======
		
						<div data-rotate-group class="flex-1">
							<c:forEach var="page" begin="0" end="2">
								<div
									class="flex flex-col gap-3 home-rotate-page"
									style="${page == 0 ? '' : 'display: none;'}">
						
									<c:forEach
										var="mate"
										items="${mateList}"
										begin="${page * 3}"
										end="${page * 3 + 2}">
						
										<a
											href="${pageContext.request.contextPath}/mateDetail?mateId=${mate.mateId}"
											class="jsp-preview-card preview-item-enter flex gap-4 p-4 bg-white rounded-2xl border border-gray-100 shadow-sm text-left w-full group transition-all"
											style="height: 96px">
						
											<!-- 국가 -->
>>>>>>> branch 'origin' of https://github.com/yoooong96/Planb.git
											<div
<<<<<<< HEAD
												class="w-4 h-4 rounded-full flex items-center justify-center text-white text-[8px] font-bold"
												style="background-color: #EC4899">서</div>
											<span class="text-[10px] text-gray-400">서연 ·
												2026.09.09</span>
										</div>
									</div>
								</a><a
									href="${pageContext.request.contextPath}/view/mate/mateDetail.jsp?id=5"
									class="jsp-preview-card preview-item-enter flex gap-4 p-4 bg-white rounded-2xl border border-gray-100 shadow-sm text-left w-full group transition-all"
									style="height: 96px">
									<div
										class="shrink-0 rounded-xl flex flex-col items-center justify-center gap-1 font-bold"
										style="width: 68px; height: 64px; background-color: var(- -brand-soft); color: var(- -brand)">
										<svg width="18" height="18" viewBox="0 0 24 24" fill="none"
											stroke="currentColor" stroke-width="2">
											<path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z" />
											<circle cx="12" cy="10" r="3" /></svg>
										<span
											class="text-[10px] font-bold leading-tight text-center px-1 line-clamp-2">영국</span>
									</div>
									<div class="flex-1 min-w-0 flex flex-col justify-center">
										<div class="flex items-center gap-1.5 mb-0.5">
											<span class="text-[11px] font-semibold"
												style="color: var(- -brand)">영국 · 런던</span><span
												class="text-[10px] font-bold px-1.5 py-0.5 rounded-full"
												style="background-color: var(- -brand-light); color: var(- -brand)">3명
												모집</span>
										</div>
										<h3
											class="font-bold text-[13px] text-gray-900 mb-0.5 line-clamp-1 group-hover:text-[#6369D1] transition-colors">🎓
											11월 런던 어학연수 · 영어 회화 파트너 구해요</h3>
										<div class="flex items-center gap-1">
											<div
												class="w-4 h-4 rounded-full flex items-center justify-center text-white text-[8px] font-bold"
												style="background-color: #10B981">도</div>
											<span class="text-[10px] text-gray-400">도현 ·
												2026.09.08</span>
										</div>
									</div>
								</a><a
									href="${pageContext.request.contextPath}/view/mate/mateDetail.jsp?id=1"
									class="jsp-preview-card preview-item-enter flex gap-4 p-4 bg-white rounded-2xl border border-gray-100 shadow-sm text-left w-full group transition-all"
									style="height: 96px">
									<div
										class="shrink-0 rounded-xl flex flex-col items-center justify-center gap-1 font-bold"
										style="width: 68px; height: 64px; background-color: var(- -brand-soft); color: var(- -brand)">
										<svg width="18" height="18" viewBox="0 0 24 24" fill="none"
											stroke="currentColor" stroke-width="2">
											<path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z" />
											<circle cx="12" cy="10" r="3" /></svg>
										<span
											class="text-[10px] font-bold leading-tight text-center px-1 line-clamp-2">일본</span>
									</div>
									<div class="flex-1 min-w-0 flex flex-col justify-center">
										<div class="flex items-center gap-1.5 mb-0.5">
											<span class="text-[11px] font-semibold"
												style="color: var(- -brand)">일본 · 도쿄</span><span
												class="text-[10px] font-bold px-1.5 py-0.5 rounded-full"
												style="background-color: var(- -brand-light); color: var(- -brand)">1명
												모집</span>
										</div>
										<h3
											class="font-bold text-[13px] text-gray-900 mb-0.5 line-clamp-1 group-hover:text-[#6369D1] transition-colors">🗼
											11/10-14 도쿄 4박 · 맛집+카페+쇼핑 동행 1명</h3>
										<div class="flex items-center gap-1">
											<div
												class="w-4 h-4 rounded-full flex items-center justify-center text-white text-[8px] font-bold"
												style="background-color: #8B5CF6">지</div>
											<span class="text-[10px] text-gray-400">지민 ·
												2026.09.10</span>
										</div>
									</div>
								</a>
							</div>
							<div class="flex flex-col gap-3 home-rotate-page"
								style="display: none;">
								<a
									href="${pageContext.request.contextPath}/view/mate/mateDetail.jsp?id=4"
									class="jsp-preview-card preview-item-enter flex gap-4 p-4 bg-white rounded-2xl border border-gray-100 shadow-sm text-left w-full group transition-all"
									style="height: 96px">
									<div
										class="shrink-0 rounded-xl flex flex-col items-center justify-center gap-1 font-bold"
										style="width: 68px; height: 64px; background-color: var(- -brand-soft); color: var(- -brand)">
										<svg width="18" height="18" viewBox="0 0 24 24" fill="none"
											stroke="currentColor" stroke-width="2">
											<path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z" />
											<circle cx="12" cy="10" r="3" /></svg>
										<span
											class="text-[10px] font-bold leading-tight text-center px-1 line-clamp-2">이탈리아</span>
									</div>
									<div class="flex-1 min-w-0 flex flex-col justify-center">
										<div class="flex items-center gap-1.5 mb-0.5">
											<span class="text-[11px] font-semibold"
												style="color: var(- -brand)">이탈리아 · 로마</span><span
												class="text-[10px] font-bold px-1.5 py-0.5 rounded-full"
												style="background-color: var(- -brand-light); color: var(- -brand)">2명
												모집</span>
										</div>
										<h3
											class="font-bold text-[13px] text-gray-900 mb-0.5 line-clamp-1 group-hover:text-[#6369D1] transition-colors">🍕
											10/15-22 로마·피렌체·베네치아 맛집 여행 동행</h3>
										<div class="flex items-center gap-1">
											<div
												class="w-4 h-4 rounded-full flex items-center justify-center text-white text-[8px] font-bold"
												style="background-color: #EC4899">서</div>
											<span class="text-[10px] text-gray-400">서연 ·
												2026.09.09</span>
										</div>
									</div>
								</a><a
									href="${pageContext.request.contextPath}/view/mate/mateDetail.jsp?id=5"
									class="jsp-preview-card preview-item-enter flex gap-4 p-4 bg-white rounded-2xl border border-gray-100 shadow-sm text-left w-full group transition-all"
									style="height: 96px">
									<div
										class="shrink-0 rounded-xl flex flex-col items-center justify-center gap-1 font-bold"
										style="width: 68px; height: 64px; background-color: var(- -brand-soft); color: var(- -brand)">
										<svg width="18" height="18" viewBox="0 0 24 24" fill="none"
											stroke="currentColor" stroke-width="2">
											<path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z" />
											<circle cx="12" cy="10" r="3" /></svg>
										<span
											class="text-[10px] font-bold leading-tight text-center px-1 line-clamp-2">영국</span>
									</div>
									<div class="flex-1 min-w-0 flex flex-col justify-center">
										<div class="flex items-center gap-1.5 mb-0.5">
											<span class="text-[11px] font-semibold"
												style="color: var(- -brand)">영국 · 런던</span><span
												class="text-[10px] font-bold px-1.5 py-0.5 rounded-full"
												style="background-color: var(- -brand-light); color: var(- -brand)">3명
												모집</span>
										</div>
										<h3
											class="font-bold text-[13px] text-gray-900 mb-0.5 line-clamp-1 group-hover:text-[#6369D1] transition-colors">🎓
											11월 런던 어학연수 · 영어 회화 파트너 구해요</h3>
										<div class="flex items-center gap-1">
											<div
												class="w-4 h-4 rounded-full flex items-center justify-center text-white text-[8px] font-bold"
												style="background-color: #10B981">도</div>
											<span class="text-[10px] text-gray-400">도현 ·
												2026.09.08</span>
										</div>
									</div>
								</a><a
									href="${pageContext.request.contextPath}/view/mate/mateDetail.jsp?id=1"
									class="jsp-preview-card preview-item-enter flex gap-4 p-4 bg-white rounded-2xl border border-gray-100 shadow-sm text-left w-full group transition-all"
									style="height: 96px">
									<div
										class="shrink-0 rounded-xl flex flex-col items-center justify-center gap-1 font-bold"
										style="width: 68px; height: 64px; background-color: var(- -brand-soft); color: var(- -brand)">
										<svg width="18" height="18" viewBox="0 0 24 24" fill="none"
											stroke="currentColor" stroke-width="2">
											<path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z" />
											<circle cx="12" cy="10" r="3" /></svg>
										<span
											class="text-[10px] font-bold leading-tight text-center px-1 line-clamp-2">일본</span>
									</div>
									<div class="flex-1 min-w-0 flex flex-col justify-center">
										<div class="flex items-center gap-1.5 mb-0.5">
											<span class="text-[11px] font-semibold"
												style="color: var(- -brand)">일본 · 도쿄</span><span
												class="text-[10px] font-bold px-1.5 py-0.5 rounded-full"
												style="background-color: var(- -brand-light); color: var(- -brand)">1명
												모집</span>
										</div>
										<h3
											class="font-bold text-[13px] text-gray-900 mb-0.5 line-clamp-1 group-hover:text-[#6369D1] transition-colors">🗼
											11/10-14 도쿄 4박 · 맛집+카페+쇼핑 동행 1명</h3>
										<div class="flex items-center gap-1">
											<div
												class="w-4 h-4 rounded-full flex items-center justify-center text-white text-[8px] font-bold"
												style="background-color: #8B5CF6">지</div>
											<span class="text-[10px] text-gray-400">지민 ·
												2026.09.10</span>
										</div>
									</div>
								</a>
							</div>
							<div class="flex flex-col gap-3 home-rotate-page"
								style="display: none;">
								<a
									href="${pageContext.request.contextPath}/view/mate/mateDetail.jsp?id=4"
									class="jsp-preview-card preview-item-enter flex gap-4 p-4 bg-white rounded-2xl border border-gray-100 shadow-sm text-left w-full group transition-all"
									style="height: 96px">
									<div
										class="shrink-0 rounded-xl flex flex-col items-center justify-center gap-1 font-bold"
										style="width: 68px; height: 64px; background-color: var(- -brand-soft); color: var(- -brand)">
										<svg width="18" height="18" viewBox="0 0 24 24" fill="none"
											stroke="currentColor" stroke-width="2">
											<path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z" />
											<circle cx="12" cy="10" r="3" /></svg>
										<span
											class="text-[10px] font-bold leading-tight text-center px-1 line-clamp-2">이탈리아</span>
									</div>
									<div class="flex-1 min-w-0 flex flex-col justify-center">
										<div class="flex items-center gap-1.5 mb-0.5">
											<span class="text-[11px] font-semibold"
												style="color: var(- -brand)">이탈리아 · 로마</span><span
												class="text-[10px] font-bold px-1.5 py-0.5 rounded-full"
												style="background-color: var(- -brand-light); color: var(- -brand)">2명
												모집</span>
										</div>
										<h3
											class="font-bold text-[13px] text-gray-900 mb-0.5 line-clamp-1 group-hover:text-[#6369D1] transition-colors">🍕
											10/15-22 로마·피렌체·베네치아 맛집 여행 동행</h3>
										<div class="flex items-center gap-1">
											<div
												class="w-4 h-4 rounded-full flex items-center justify-center text-white text-[8px] font-bold"
												style="background-color: #EC4899">서</div>
											<span class="text-[10px] text-gray-400">서연 ·
												2026.09.09</span>
										</div>
									</div>
								</a><a
									href="${pageContext.request.contextPath}/view/mate/mateDetail.jsp?id=5"
									class="jsp-preview-card preview-item-enter flex gap-4 p-4 bg-white rounded-2xl border border-gray-100 shadow-sm text-left w-full group transition-all"
									style="height: 96px">
									<div
										class="shrink-0 rounded-xl flex flex-col items-center justify-center gap-1 font-bold"
										style="width: 68px; height: 64px; background-color: var(- -brand-soft); color: var(- -brand)">
										<svg width="18" height="18" viewBox="0 0 24 24" fill="none"
											stroke="currentColor" stroke-width="2">
											<path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z" />
											<circle cx="12" cy="10" r="3" /></svg>
										<span
											class="text-[10px] font-bold leading-tight text-center px-1 line-clamp-2">영국</span>
									</div>
									<div class="flex-1 min-w-0 flex flex-col justify-center">
										<div class="flex items-center gap-1.5 mb-0.5">
											<span class="text-[11px] font-semibold"
												style="color: var(- -brand)">영국 · 런던</span><span
												class="text-[10px] font-bold px-1.5 py-0.5 rounded-full"
												style="background-color: var(- -brand-light); color: var(- -brand)">3명
												모집</span>
										</div>
										<h3
											class="font-bold text-[13px] text-gray-900 mb-0.5 line-clamp-1 group-hover:text-[#6369D1] transition-colors">🎓
											11월 런던 어학연수 · 영어 회화 파트너 구해요</h3>
										<div class="flex items-center gap-1">
											<div
												class="w-4 h-4 rounded-full flex items-center justify-center text-white text-[8px] font-bold"
												style="background-color: #10B981">도</div>
											<span class="text-[10px] text-gray-400">도현 ·
												2026.09.08</span>
										</div>
									</div>
								</a><a
									href="${pageContext.request.contextPath}/view/mate/mateDetail.jsp?id=1"
									class="jsp-preview-card preview-item-enter flex gap-4 p-4 bg-white rounded-2xl border border-gray-100 shadow-sm text-left w-full group transition-all"
									style="height: 96px">
									<div
										class="shrink-0 rounded-xl flex flex-col items-center justify-center gap-1 font-bold"
										style="width: 68px; height: 64px; background-color: var(- -brand-soft); color: var(- -brand)">
										<svg width="18" height="18" viewBox="0 0 24 24" fill="none"
											stroke="currentColor" stroke-width="2">
											<path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z" />
											<circle cx="12" cy="10" r="3" /></svg>
										<span
											class="text-[10px] font-bold leading-tight text-center px-1 line-clamp-2">일본</span>
									</div>
									<div class="flex-1 min-w-0 flex flex-col justify-center">
										<div class="flex items-center gap-1.5 mb-0.5">
											<span class="text-[11px] font-semibold"
												style="color: var(- -brand)">일본 · 도쿄</span><span
												class="text-[10px] font-bold px-1.5 py-0.5 rounded-full"
												style="background-color: var(- -brand-light); color: var(- -brand)">1명
												모집</span>
										</div>
										<h3
											class="font-bold text-[13px] text-gray-900 mb-0.5 line-clamp-1 group-hover:text-[#6369D1] transition-colors">🗼
											11/10-14 도쿄 4박 · 맛집+카페+쇼핑 동행 1명</h3>
										<div class="flex items-center gap-1">
											<div
												class="w-4 h-4 rounded-full flex items-center justify-center text-white text-[8px] font-bold"
												style="background-color: #8B5CF6">지</div>
											<span class="text-[10px] text-gray-400">지민 ·
												2026.09.10</span>
										</div>
									</div>
								</a>
							</div>
=======
												class="shrink-0 rounded-xl flex flex-col items-center justify-center gap-1 font-bold"
												style="width: 68px; height: 64px; background-color: var(--brand-soft); color: var(--brand)">
						
												<svg
													width="18"
													height="18"
													viewBox="0 0 24 24"
													fill="none"
													stroke="currentColor"
													stroke-width="2">
													<path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z" />
													<circle cx="12" cy="10" r="3" />
												</svg>
						
												<span class="text-[10px] font-bold leading-tight text-center px-1 line-clamp-2">
													<c:out value="${mate.country}" />
												</span>
											</div>
						
											<!-- 내용 -->
											<div class="flex-1 min-w-0 flex flex-col justify-center">
						
												<div class="flex items-center gap-1.5 mb-0.5">
						
													<span
														class="text-[11px] font-semibold"
														style="color: var(--brand)">
														<c:out value="${mate.country}" />
													</span>
						
													<c:if test="${mate.recruitStatus eq 'OPEN'}">
														<span
															class="text-[10px] font-bold px-1.5 py-0.5 rounded-full"
															style="background-color: var(--brand-light); color: var(--brand)">
															<c:out value="${mate.recruitCount}" />명 모집
														</span>
													</c:if>
						
													<c:if test="${mate.recruitStatus eq 'CLOSED'}">
														<span
															class="text-[10px] font-bold px-1.5 py-0.5 rounded-full bg-gray-100 text-gray-400">
															모집완료
														</span>
													</c:if>
						
												</div>
						
												<h3
													class="font-bold text-[13px] text-gray-900 mb-0.5 line-clamp-1 group-hover:text-[#6369D1] transition-colors">
													<c:out value="${mate.title}" />
												</h3>
						
												<div class="flex items-center gap-1">
						
													<div
														class="w-4 h-4 rounded-full flex items-center justify-center text-white text-[8px] font-bold"
														style="background-color: #8B5CF6">
						
														<c:choose>
															<c:when test="${not empty mate.nickname}">
																<c:out value="${mate.nickname.substring(0, 1)}" />
															</c:when>
						
															<c:otherwise>
																U
															</c:otherwise>
														</c:choose>
						
													</div>
						
													<span class="text-[10px] text-gray-400">
														<c:out value="${mate.nickname}" />
													</span>
						
												</div>
						
											</div>
										</a>
						
									</c:forEach>
						
								</div>
							</c:forEach>
>>>>>>> branch 'origin' of https://github.com/yoooong96/Planb.git
						</div>
<<<<<<< HEAD
						<div
							class="home-progress flex items-center justify-center gap-2 mt-5">
							<button type="button"
=======
						
						<!-- 여행 메이트 진행바 -->
						<div class="home-progress flex items-center justify-center gap-2 mt-5">
							<button
								type="button"
>>>>>>> branch 'origin' of https://github.com/yoooong96/Planb.git
								class="home-progress-bar jsp-progress-active relative overflow-hidden rounded-full"
								style="width: 44px; height: 9px; background-color: #e5e7eb">
							</button>
						
							<button
								type="button"
								class="home-progress-bar relative overflow-hidden rounded-full"
								style="width: 44px; height: 9px; background-color: #e5e7eb">
							</button>
						
							<button
								type="button"
								class="home-progress-bar relative overflow-hidden rounded-full"
								style="width: 44px; height: 9px; background-color: #e5e7eb">
							</button>
						</div>
		
							<c:if test="${empty mateList}">
								<div
									class="flex items-center justify-center bg-white rounded-2xl border border-gray-100 text-sm text-gray-400"
									style="height: 96px">
									등록된 여행 메이트가 없습니다.
								</div>
							</c:if>
		
						</div>
					</div>
		
				</div>
		
			</div>
		</section>
	</main>
	<jsp:include page="/common/footer.jsp" />
</body>
</html>