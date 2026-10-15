<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
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
	
</head>

<body class="site-shell">

	<jsp:include page="/common/header.jsp" />

	<main class="w-full max-w-6xl mx-auto px-4 sm:px-6 py-8 sm:py-10">

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
		
						<div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
		
							<c:forEach var="schedule" items="${scheduleList}">
		
								<c:url var="scheduleDetailUrl" value="/schedules/detail">
									<c:param name="id" value="${schedule.itineraryId}" />
								</c:url>
		
		
								<article
									class="bg-white rounded-2xl overflow-hidden border group transition-all duration-200"
									style="border-color: #D1D2F9; box-shadow: 0 2px 8px rgba(0, 0, 0, .06);">
		
									<!-- =========================
									     이미지
									========================= -->
									<div
										class="relative overflow-hidden"
										style="aspect-ratio: 4 / 3;">
		
										<a
											href="${scheduleDetailUrl}"
											class="block w-full h-full">
		
											<c:choose>
		
												<c:when test="${not empty schedule.thumbnailImg}">
		
													<c:choose>
		
														<c:when test="${schedule.thumbnailImg.startsWith('/')}">
															<c:url
																var="scheduleThumbnailUrl"
																value="${schedule.thumbnailImg}" />
														</c:when>
		
														<c:otherwise>
															<c:url
																var="scheduleThumbnailUrl"
																value="/${schedule.thumbnailImg}" />
														</c:otherwise>
		
													</c:choose>
		
													<img
														src="<c:out value='${scheduleThumbnailUrl}' />"
														alt="<c:out value='${schedule.title}' />"
														class="w-full h-full object-cover transition-transform duration-300 group-hover:scale-105">
		
												</c:when>
		
												<c:otherwise>
		
													<img
														src="${pageContext.request.contextPath}/view/assets/images/default/itinerary-default.svg"
														alt="여행일정 기본 이미지"
														class="w-full h-full object-cover transition-transform duration-300 group-hover:scale-105">
		
												</c:otherwise>
		
											</c:choose>
		
										</a>
		
		
										<!-- 국가 · 도시 -->
										<span
											class="absolute top-2.5 left-2.5 text-[10px] font-bold px-2.5 py-1 rounded-full"
											style="background: #6369D1; color: white;">
		
											<c:out value="${schedule.country}" />
		
											<c:if test="${not empty schedule.city}">
												· <c:out value="${schedule.city}" />
											</c:if>
		
										</span>
		
		
										<!-- 여행 기간 -->
										<c:if test="${not empty schedule.durationText}">
		
											<span
												class="absolute bottom-2.5 left-2.5 text-white text-[10px] font-bold bg-black/50 rounded-full px-2.5 py-1">
		
												<c:out value="${schedule.durationText}" />
		
											</span>
		
										</c:if>
		
									</div>
		
		
									<!-- =========================
									     카드 내용
									========================= -->
									<div class="p-4">
		
										<a href="${scheduleDetailUrl}">
		
											<h3
												class="font-bold text-[14px] leading-snug line-clamp-2 transition-colors group-hover:text-[#6369D1]"
												style="color: #18181b;">
		
												<c:out value="${schedule.title}" />
		
											</h3>
		
										</a>
		
		
										<p
											class="text-gray-500 text-[12px] mt-1.5 line-clamp-2"
											style="min-height: 2.8em;">
		
											<c:out value="${schedule.summary}" />
		
										</p>
		
		
										<!-- 좋아요 · 댓글 · 조회 -->
										<div class="flex items-center gap-3 text-[11px] text-gray-400 mt-3">
		
											<span class="inline-flex items-center gap-1">
		
												<svg
													width="12"
													height="12"
													viewBox="0 0 24 24"
													fill="${schedule.liked ? '#ef4444' : 'none'}"
													stroke="${schedule.liked ? '#ef4444' : '#9ca3af'}"
													stroke-width="2"
													aria-hidden="true">
		
													<path
														stroke-linecap="round"
														stroke-linejoin="round"
														d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78Z" />
		
												</svg>
		
												${schedule.likeCount}
		
											</span>
		
		
											<span class="inline-flex items-center gap-1">
		
												<svg
													width="12"
													height="12"
													viewBox="0 0 24 24"
													fill="none"
													stroke="#9ca3af"
													stroke-width="2"
													aria-hidden="true">
		
													<path
														stroke-linecap="round"
														stroke-linejoin="round"
														d="M7.9 20A9 9 0 1 0 4 16.1L2 22Z" />
		
												</svg>
		
												${schedule.commentCount}
		
											</span>
		
		
											<span class="inline-flex items-center gap-1">
		
												<svg
													width="12"
													height="12"
													viewBox="0 0 24 24"
													fill="none"
													stroke="#9ca3af"
													stroke-width="2"
													aria-hidden="true">
		
													<path
														stroke-linecap="round"
														stroke-linejoin="round"
														d="M2.062 12.348a1 1 0 0 1 0-.696 10.75 10.75 0 0 1 19.876 0 1 1 0 0 1 0 .696 10.75 10.75 0 0 1-19.876 0" />
		
													<circle
														cx="12"
														cy="12"
														r="3" />
		
												</svg>
		
												${empty schedule.viewCount ? 0 : schedule.viewCount}
		
											</span>
		
										</div>
		
		
										<!-- 작성자 -->
										<div
											class="flex items-center justify-between gap-2 border-t pt-2.5 mt-3"
											style="border-color: #D1D2F9;">
		
											<div class="flex items-center gap-1.5 min-w-0">
		
												<span
													class="inline-flex items-center justify-center w-6 h-6 rounded-full shrink-0 overflow-hidden"
													style="background: #F0F0FF; color: #6369D1;">
		
													<svg
														width="14"
														height="14"
														viewBox="0 0 24 24"
														fill="none"
														stroke="currentColor"
														stroke-width="1.8"
														aria-hidden="true">
		
														<circle
															cx="12"
															cy="8"
															r="4" />
		
														<path d="M4 21c0-4.3 3.6-7 8-7s8 2.7 8 7" />
		
													</svg>
		
												</span>
		
		
												<span
													class="text-[11px] text-gray-500 font-medium truncate">
		
													<c:out
														value="${schedule.nickname}"
														default="알 수 없음" />
		
												</span>
		
											</div>
		
		
											<span class="text-[10px] text-gray-400 shrink-0">
		
												<c:if test="${not empty schedule.createdAt}">
													${schedule.createdAt}
												</c:if>
		
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

							<a
								href="${pageContext.request.contextPath}/tipDetail?tipId=${tip.tipId}"
								class="relative bg-white rounded-2xl border border-gray-100 shadow-sm hover:shadow-md transition-shadow cursor-pointer group overflow-hidden flex flex-col">

								<!-- 이미지 -->
								<div
									class="relative shrink-0 overflow-hidden"
									style="aspect-ratio: 4 / 3;">

									<c:choose>

										<c:when test="${not empty tip.thumbnailImg}">
											<img
												src="${pageContext.request.contextPath}${tip.thumbnailImg}"
												alt="${tip.title}"
												class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300">
										</c:when>

										<c:otherwise>
											<img
												src="${pageContext.request.contextPath}/view/assets/images/default/tip-default.svg"
												alt="여행꿀팁 기본 이미지"
												class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300">
										</c:otherwise>

									</c:choose>

								</div>


								<!-- 카드 내용 -->
								<div class="flex flex-col flex-1 p-3 min-h-0">

									<h3
										class="font-bold text-[13px] text-gray-900 leading-snug line-clamp-2 group-hover:text-brand transition-colors mb-1.5"
										style="min-height: 2.6em;">

										<c:out value="${tip.title}" />

									</h3>


									<p class="text-[11px] text-gray-500 leading-relaxed line-clamp-2 flex-1">
										<c:set var="tipPreview" value="${tip.content}" />
										<c:forEach var="imgNo" begin="0" end="5">
											<c:set var="tipPreview" value="${fn:replace(tipPreview, '[[IMG:' += imgNo += ']]', ' ')}" />
										</c:forEach>
										<c:out value="${tipPreview}" />
									</p>


									<!-- 해시태그 -->
									<c:if test="${not empty tip.hashtag}">

										<div class="flex flex-wrap gap-1.5 mt-2 mb-3">

											<c:forEach var="tag" items="${tip.hashtagList}">

												<span
													class="inline-flex items-center rounded-full px-2.5 py-1 text-[11px] font-semibold"
													style="background: #FFD447; color: #6369D1; border: 1px solid #E0E1FF;">

													<c:out value="${tag}" />

												</span>

											</c:forEach>

										</div>

									</c:if>


									<!-- 작성자 -->
									<div class="pt-2 mt-auto border-t border-gray-50">

										<div class="flex items-center gap-1.5 mb-1.5">

											<div
												class="w-5 h-5 rounded-full flex items-center justify-center text-white text-[9px] font-bold shrink-0"
												style="background: #8B5CF6;">

												<c:choose>

													<c:when test="${not empty tip.nickname}">
														${tip.nickname.substring(0, 1)}
													</c:when>

													<c:otherwise>
														?
													</c:otherwise>

												</c:choose>

											</div>


											<span class="text-[10px] text-gray-500">

												<c:out
													value="${tip.nickname}"
													default="알 수 없음" />

											</span>


											<span class="text-[10px] text-gray-300">
												·
											</span>


											<span class="text-[10px] text-gray-400">
												${tip.timeAgo}
											</span>

										</div>


										<!-- 통계 -->
										<div class="flex items-center justify-between mt-2">

											<div class="flex items-center gap-3 text-[11px] text-gray-400">

												<span class="flex items-center gap-1">
													♡ ${tip.likeCount}
												</span>

												<span class="flex items-center gap-1">
													▢ ${tip.commentCount}
												</span>

											</div>


											<span class="flex items-center gap-1 text-[11px] text-gray-400">

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

												${tip.viewCount}

											</span>

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

										<span class="text-gray-600 font-medium">
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
											▢ ${mate.commentCount}
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
	

</body>
</html>