<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
request.setAttribute("activePage", "mates");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<title>Planb</title>
	<link rel="stylesheet" href="${pageContext.request.contextPath}/view/assets/css/mates/mateList.css">
	<script defer src="${pageContext.request.contextPath}/view/assets/js/mates/mateList.js"></script>
	<jsp:include page="/common/headStyles.jsp" />
</head>
<body class="site-shell">
	<jsp:include page="/common/header.jsp" />
	<div class="min-h-screen bg-white">
		<div class="flex" style="min-height: calc(100vh - 68px)">
			<aside class="mate-list-sidebar shrink-0 w-48 flex-col gap-1 bg-white py-5 px-2 border-r overflow-y-auto" style="border-color: #ebebf5">
			<div class="text-xs font-bold text-gray-400 uppercase tracking-widest px-3 mb-1">여행 메이트</div>
				<a href="${pageContext.request.contextPath}/mateWriteList"
					class="flex items-center justify-between px-3 py-2.5 rounded-lg transition-colors group">
					<span class="flex items-center gap-2 text-sm font-semibold text-gray-700">
						<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
							<path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z" />
							<polyline points="14 2 14 8 20 8" />
						</svg>
						내가 작성한 글
					</span>
				</a>
				
				<div class="border-t border-gray-100 mb-3"></div>
				<a href="${pageContext.request.contextPath}/mates" 
				   class="w-full flex items-center justify-between px-3 py-2.5 rounded-xl transition-all mb-1" 
				   style="background: var(--brand); color: #fff;">
					<span class="flex items-center gap-2 text-sm font-semibold">
						<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2">
							<circle cx="12" cy="12" r="10"/>
							<line x1="2" y1="12" x2="22" y2="12"/>
							<path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/>
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
							<img src="${pageContext.request.contextPath}/view/assets/images/continent/asia.png" alt="아시아"
								class="w-10 h-10 shrink-0 object-contain">
							아시아
						</span>
						<svg class="continent-chevron w-3.5 h-3.5 shrink-0 transition-transform" viewBox="0 0 24 24" fill="none" stroke="#9ca3af" stroke-width="2.5">
							<path d="m6 9 6 6 6-6" />
						</svg>
					</button>
					<div class="continent-panel hidden pl-8 pr-2 py-1 space-y-1" data-continent-panel="asia">
						<a href="${pageContext.request.contextPath}/mates?country=대한민국&sort=${sort}"
							class="block w-full text-left px-3 py-2 rounded-lg text-sm text-gray-600 hover:bg-indigo-50 hover:text-indigo-600">
							🇰🇷 대한민국
						</a>
						<a href="${pageContext.request.contextPath}/mates?country=일본&sort=${sort}"
							class="block w-full text-left px-3 py-2 rounded-lg text-sm text-gray-600 hover:bg-indigo-50 hover:text-indigo-600">
							🇯🇵 일본
						</a>
						<a href="${pageContext.request.contextPath}/mates?country=중국&sort=${sort}"
							class="block w-full text-left px-3 py-2 rounded-lg text-sm text-gray-600 hover:bg-indigo-50 hover:text-indigo-600">
							🇨🇳 중국
						</a>
						<a href="${pageContext.request.contextPath}/mates?country=대만&sort=${sort}"
							class="block w-full text-left px-3 py-2 rounded-lg text-sm text-gray-600 hover:bg-indigo-50 hover:text-indigo-600">
							🇹🇼 대만
						</a>
						<a href="${pageContext.request.contextPath}/mates?country=홍콩&sort=${sort}"
							class="block w-full text-left px-3 py-2 rounded-lg text-sm text-gray-600 hover:bg-indigo-50 hover:text-indigo-600">
							🇭🇰 홍콩
						</a>
						<a href="${pageContext.request.contextPath}/mates?country=태국&sort=${sort}"
							class="block w-full text-left px-3 py-2 rounded-lg text-sm text-gray-600 hover:bg-indigo-50 hover:text-indigo-600">
							🇹🇭 태국
						</a>
						<a href="${pageContext.request.contextPath}/mates?country=베트남&sort=${sort}"
							class="block w-full text-left px-3 py-2 rounded-lg text-sm text-gray-600 hover:bg-indigo-50 hover:text-indigo-600">
							🇻🇳 베트남
						</a>
						<a href="${pageContext.request.contextPath}/mates?country=필리핀&sort=${sort}"
							class="block w-full text-left px-3 py-2 rounded-lg text-sm text-gray-600 hover:bg-indigo-50 hover:text-indigo-600">
							🇵🇭 필리핀
						</a>
						<a href="${pageContext.request.contextPath}/mates?country=싱가포르&sort=${sort}"
							class="block w-full text-left px-3 py-2 rounded-lg text-sm text-gray-600 hover:bg-indigo-50 hover:text-indigo-600">
							🇸🇬 싱가포르
						</a>
						<a href="${pageContext.request.contextPath}/mates?country=말레이시아&sort=${sort}"
							class="block w-full text-left px-3 py-2 rounded-lg text-sm text-gray-600 hover:bg-indigo-50 hover:text-indigo-600">
							🇲🇾 말레이시아
						</a>
						<a href="${pageContext.request.contextPath}/mates?country=인도네시아&sort=${sort}"
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
							<svg viewBox="0 0 64 64" class="w-6 h-6 shrink-0" aria-hidden="true">
								<!-- 유럽 본토 -->
								<path d="M18 23
									     L23 18
									     L29 19
									     L33 16
									     L39 18
									     L43 22
									     L49 23
									     L52 28
									     L48 32
									     L43 31
									     L40 35
									     L35 34
									     L32 39
									     L27 37
									     L24 41
									     L20 37  
									     L15 36
									     L13 31
									     L16 27
									     Z"
									  fill="#8B5CF6" />
								<!-- 스칸디나비아 -->
								<path d="M32 17
									     L34 9
									     L38 6
									     L41 10
									     L39 16
									     L36 20
									     Z"
									  fill="#8B5CF6" />
							
								<!-- 영국 -->
								<path d="M12 22
									     L15 18
									     L18 20
								   	     L17 25
									     L14 27
									     Z"
									  fill="#8B5CF6" />
								<!-- 이탈리아 반도 -->
								<path d="M34 36
									     L38 39
									     L39 44  
									     L43 47
									     L41 50
									     L37 46
									     L35 41
									     Z"
									fill="#8B5CF6" />
								<!-- 시칠리아 느낌 -->
								<circle cx="42" cy="52" r=" ="#8B5CF6" />
							</svg>
							유럽
						</span>
						<svg class="continent-chevron w-3.5 h-3.5 shrink-0 transition-transform" viewBox="0 0 24 24" fill="none" stroke="#9ca3af"
							stroke-width="2.5">
							<path d="m6 9 6 6 6-6" />
						</svg>
					</button>
					<div class="continent-panel hidden pl-8 pr-2 py-1 space-y-1"data-continent-panel="europe">
						<a href="${pageContext.request.contextPath}/mates?country=독일&sort=${sort}"
							class="block w-full text-left px-3 py-2 rounded-lg text-sm text-gray-600 hover:bg-indigo-50 hover:text-indigo-600">
							🇩🇪 독일
						</a>
						<a href="${pageContext.request.contextPath}/mates?country=포르투갈&sort=${sort}"
							class="block w-full text-left px-3 py-2 rounded-lg text-sm text-gray-600 hover:bg-indigo-50 hover:text-indigo-600">
							🇵🇹 포르투갈
						</a>
						<a href="${pageContext.request.contextPath}/mates?country=프랑스&sort=${sort}"
							class="block w-full text-left px-3 py-2 rounded-lg text-sm text-gray-600 hover:bg-indigo-50 hover:text-indigo-600">
							🇫🇷 프랑스
						</a>
						<a href="${pageContext.request.contextPath}/mates?country=그리스&sort=${sort}"
							class="block w-full text-left px-3 py-2 rounded-lg text-sm text-gray-600 hover:bg-indigo-50 hover:text-indigo-600">
							🇬🇷 그리스
						</a>
						<a href="${pageContext.request.contextPath}/mates?country=스페인&sort=${sort}"
							class="block w-full text-left px-3 py-2 rounded-lg text-sm text-gray-600 hover:bg-indigo-50 hover:text-indigo-600">
							🇪🇸 스페인
						</a>
						<a href="${pageContext.request.contextPath}/mates?country=영국&sort=${sort}"
							class="block w-full text-left px-3 py-2 rounded-lg text-sm text-gray-600 hover:bg-indigo-50 hover:text-indigo-600">
							🇬🇧 영국
						</a>
						<a href="${pageContext.request.contextPath}/mates?country=이탈리아&sort=${sort}"
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
							<svg viewBox="0 0 48 48" width="24" height="24" aria-hidden="true">
								<path d="M10 8L18 5L27 6L36 9L40 15L37 21L40 27L34 32L29 38L22 40L17 35L11 34L7 27L6 19Z" fill="#10B981" opacity=".88" />
							</svg>
							북아메리카
						</span>
						<svg class="continent-chevron w-3.5 h-3.5 shrink-0 transition-transform" viewBox="0 0 24 24" fill="none" stroke="#9ca3af"
							stroke-width="2.5">
							<path d="m6 9 6 6 6-6" />
						</svg>
					</button>
					<div class="continent-panel hidden pl-8 pr-2 py-1 space-y-1" data-continent-panel="north-america">
						<a href="${pageContext.request.contextPath}/mates?country=멕시코&sort=${sort}"
							class="block w-full text-left px-3 py-2 rounded-lg text-sm text-gray-600 hover:bg-indigo-50 hover:text-indigo-600">
							🇲🇽 멕시코
						</a>
						<a href="${pageContext.request.contextPath}/mates?country=미국&sort=${sort}"
							class="block w-full text-left px-3 py-2 rounded-lg text-sm text-gray-600 hover:bg-indigo-50 hover:text-indigo-600">
							🇺🇸 미국
						</a>
						<a href="${pageContext.request.contextPath}/mates?country=캐나다&sort=${sort}"
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
							<svg viewBox="0 0 48 48" width="24" height="24" aria-hidden="true">
								<path d="M10 8L18 5L27 6L36 9L40 15L37 21L40 27L34 32L29 38L22 40L17 35L11 34L7 27L6 19Z" fill="#F59E0B" opacity=".88" />
							</svg>
							남아메리카
						</span>
						<svg class="continent-chevron w-3.5 h-3.5 shrink-0 transition-transform" viewBox="0 0 24 24" fill="none" stroke="#9ca3af"
							stroke-width="2.5">
							<path d="m6 9 6 6 6-6" />
						</svg>
					</button>
					<div class="continent-panel hidden pl-8 pr-2 py-1 space-y-1" data-continent-panel="south-america">
						<a href="${pageContext.request.contextPath}/mates?country=브라질&sort=${sort}"
							class="block w-full text-left px-3 py-2 rounded-lg text-sm text-gray-600 hover:bg-indigo-50 hover:text-indigo-600">
							🇧🇷 브라질
						</a>
						<a href="${pageContext.request.contextPath}/mates?country=아르헨티나&sort=${sort}"
							class="block w-full text-left px-3 py-2 rounded-lg text-sm text-gray-600 hover:bg-indigo-50 hover:text-indigo-600">
							🇦🇷 아르헨티나
						</a>
						<a href="${pageContext.request.contextPath}/mates?country=칠레&sort=${sort}"
							class="block w-full text-left px-3 py-2 rounded-lg text-sm text-gray-600 hover:bg-indigo-50 hover:text-indigo-600">
							🇨🇱 칠레
						</a>
						<a href="${pageContext.request.contextPath}/mates?country=페루&sort=${sort}"
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
							<svg viewBox="0 0 48 48" width="24" height="24" aria-hidden="true">
								<path d="M10 8L18 5L27 6L36 9L40 15L37 21L40 27L34 32L29 38L22 40L17 35L11 34L7 27L6 19Z" fill="#EF4444" opacity=".88" />
							</svg>
							아프리카
						</span> 
						<svg class="continent-chevron w-3.5 h-3.5 shrink-0 transition-transform" viewBox="0 0 24 24" fill="none" stroke="#9ca3af"
							stroke-width="2.5">
							<path d="m6 9 6 6 6-6" />
						</svg>
					</button> 
					<div class="continent-panel hidden pl-8 pr-2 py-1 space-y-1" data-continent-panel="africa">
						<a href="${pageContext.request.contextPath}/mates?country=남아프리카&sort=${sort}"
							class="block w-full text-left px-3 py-2 rounded-lg text-sm text-gray-600 hover:bg-indigo-50 hover:text-indigo-600">
							🇿🇦 남아프리카
						</a>
						<a href="${pageContext.request.contextPath}/mates?country=모르코&sort=${sort}"
							class="block w-full text-left px-3 py-2 rounded-lg text-sm text-gray-600 hover:bg-indigo-50 hover:text-indigo-600">
							🇲🇦 모로코
						</a>
						<a href="${pageContext.request.contextPath}/mates?country=이집트&sort=${sort}"
							class="block w-full text-left px-3 py-2 rounded-lg text-sm text-gray-600 hover:bg-indigo-50 hover:text-indigo-600">
							🇪🇬 이집트
						</a>
						<a href="${pageContext.request.contextPath}/mates?country=케냐&sort=${sort}"
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
							<svg viewBox="0 0 48 48" width="24" height="24" aria-hidden="true">
								<path d="M10 8L18 5L27 6L36 9L40 15L37 21L40 27L34 32L29 38L22 40L17 35L11 34L7 27L6 19Z" fill="#06B6D4" opacity=".88" />
							</svg>
							오세아니아
						</span>
						<svg class="continent-chevron w-3.5 h-3.5 shrink-0 transition-transform" viewBox="0 0 24 24" fill="none" stroke="#9ca3af"
							stroke-width="2.5">
							<path d="m6 9 6 6 6-6" />
						</svg>
					</button>
					<div class="continent-panel hidden pl-8 pr-2 py-1 space-y-1" data-continent-panel="oceania">
						<a href="${pageContext.request.contextPath}/mates?country=뉴질랜드&sort=${sort}"
							class="block w-full text-left px-3 py-2 rounded-lg text-sm text-gray-600 hover:bg-indigo-50 hover:text-indigo-600">
							🇳🇿 뉴질랜드
						</a>
						<a href="${pageContext.request.contextPath}/mates?country=피지&sort=${sort}"
							class="block w-full text-left px-3 py-2 rounded-lg text-sm text-gray-600 hover:bg-indigo-50 hover:text-indigo-600">
							🇫🇯 피지
						</a>
						<a href="${pageContext.request.contextPath}/mates?country=호주&sort=${sort}"
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
							<svg viewBox="0 0 48 48" width="24" height="24" aria-hidden="true">
								<path d="M10 8L18 5L27 6L36 9L40 15L37 21L40 27L34 32L29 38L22 40L17 35L11 34L7 27L6 19Z" fill="#D97706" opacity=".88" />
							</svg>
							중동
						</span>
						<svg class="continent-chevron w-3.5 h-3.5 shrink-0 transition-transform" viewBox="0 0 24 24" fill="none" stroke="#9ca3af"
							stroke-width="2.5">
							<path d="m6 9 6 6 6-6" />
						</svg>
					</button>
					<div class="continent-panel hidden pl-8 pr-2 py-1 space-y-1" data-continent-panel="middle-east">
						<a href="${pageContext.request.contextPath}/mates?country=아랍에미리트&sort=${sort}"
							class="block w-full text-left px-3 py-2 rounded-lg text-sm text-gray-600 hover:bg-indigo-50 hover:text-indigo-600">
							🇦🇪 UAE
						</a>
						<a href="${pageContext.request.contextPath}/mates?country=이스라엘&sort=${sort}"
							class="block w-full text-left px-3 py-2 rounded-lg text-sm text-gray-600 hover:bg-indigo-50 hover:text-indigo-600">
							🇮🇱 이스라엘
						</a>
						<a href="${pageContext.request.contextPath}/mates?country=터키&sort=${sort}"
							class="block w-full text-left px-3 py-2 rounded-lg text-sm text-gray-600 hover:bg-indigo-50 hover:text-indigo-600">
							🇹🇷 터키
						</a>
					</div>
				</div>
			</aside>
			<main class="flex-1 px-6 py-8 min-w-0">
				<!-- 여행 메이트 검색 -->
				<form action="${pageContext.request.contextPath}/mates" method="get" class="mb-6 relative w-full max-w-2xl">
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
							placeholder="어떤 여행을 함께하고 싶으신가요?">
					</div>
				</form>
				<div class="flex items-center justify-between mb-5 gap-4 flex-wrap">
					<!-- 왼쪽 : 게시글 수 -->
					<p class="text-[12px] font-medium text-gray-500">
						총 <span class="font-bold" style="color: #6369D1">${totalCount}</span>개의 여행 메이트
					</p>
					<!-- 오른쪽 : 정렬 + 글쓰기 -->
					<div class="flex items-center gap-4 flex-wrap">
						<!-- 정렬 -->
						<div class="flex gap-4">
							<!-- 최신순 -->
							<a href="${pageContext.request.contextPath}/mates?country=${country}&keyword=${keyword}&sort=latest"
								class="text-sm pb-0.5 transition-colors"
								style="${sort == 'latest' ? 'color:#6369D1; font-weight:600; border-bottom:2px solid #6369D1' : 'color:#9ca3af'}">
								최신순
							</a>
							<!-- 조회순 -->
							<a href="${pageContext.request.contextPath}/mates?country=${country}&keyword=${keyword}&sort=views"
								class="text-sm pb-0.5 transition-colors"
								style="${sort == 'views' ? 'color:#6369D1; font-weight:600; border-bottom:2px solid #6369D1' : 'color:#9ca3af'}">
								조회순
							</a>
							<!-- 댓글순 -->
							<a href="${pageContext.request.contextPath}/mates?country=${country}&keyword=${keyword}&sort=likes"
								class="text-sm pb-0.5 transition-colors"
								style="${sort == 'comments' ? 'color:#6369D1; font-weight:600; border-bottom:2px solid #6369D1' : 'color:#9ca3af'}">
								인기순
							</a>
						</div>
						<!-- 글쓰기 -->
						<a href="${pageContext.request.contextPath}/mateWrite"
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
				<div
					class="mate-card-grid grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4"
					data-card-grid>
					<jsp:include page="/view/mates/mateCardFragment.jsp" />
				</div>
				<!-- 무한 스크롤 로딩 영역 -->
				<c:if test="${totalCount > 0}">
					<div id="mateInfiniteScroll" class="flex flex-col items-center justify-center py-8"
						data-current-count="${mateList.size()}"
						data-total-count="${totalCount}"
						data-current-page="${page}"
						data-page-size="${pageSize}">
				
						<!-- 다음 페이지 로딩 중에 표시 -->
						<div id="mateLoading" class="hidden flex-col items-center gap-2">
							<div class="mate-loading-spinner"></div>
				
							<p class="text-[12px] font-medium text-gray-500">
								여행 메이트를 불러오는 중...
							</p>
				
							<p class="text-[11px] text-gray-400">
								<span id="mateCurrentCount">${mateList.size()}</span>
								/
								총 <span id="mateTotalCount">${totalCount}</span>개
							</p>
						</div>
				
						<!-- 마지막 페이지 -->
						<div id="mateLoadComplete"
							class="${mateList.size() >= totalCount ? 'flex' : 'hidden'} flex-col items-center gap-1">
				
							<p class="text-[12px] font-semibold" style="color: #6369D1;">
								모든 여행 메이트를 확인했습니다 ✓
							</p>
				
							<p class="text-[11px] text-gray-400">
								<span id="mateCompleteCount">${mateList.size()}</span>
								/
								총 ${totalCount}개
							</p>
						</div>
				
						<!-- 스크롤 감지 지점 -->
						<div id="mateScrollSentinel"
							class="${mateList.size() < totalCount ? 'block' : 'hidden'}"
							style="width: 100%; height: 1px;">
						</div>
					</div>
				</c:if>
				
				<c:if test="${empty mateList}">
					<div class="py-20 text-center">
						<p class="text-sm font-medium text-gray-500">
							조건에 맞는 여행 메이트가 없습니다.
						</p>
				
						<p class="mt-2 text-xs text-gray-400">
							다른 지역이나 검색어로 찾아보세요.
						</p>
					</div>
				</c:if>
			</main>
		</div>
	</div>
	<!-- 최상단 이동 버튼 -->
	<button type="button" id="mateScrollTopBtn" class="mate-scroll-top-btn" aria-label="페이지 최상단으로 이동">
		<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" aria-hidden="true">
			<path
				stroke-linecap="round"
				stroke-linejoin="round"
				stroke-width="2.2"
				d="M12 19V5M5 12l7-7 7 7" />
		</svg>
	</button>
	<jsp:include page="/common/footer.jsp" />
</body>
</html>
