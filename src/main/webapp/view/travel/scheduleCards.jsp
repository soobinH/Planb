<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<!-- 실제 DB 데이터로 표시하는 여행 일정 카드 -->
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

			<!-- 국가·도시 -->
			<span
				class="absolute top-2.5 left-2.5 text-[10px] font-bold px-2 py-0.5 rounded-full"
				style="background: #6369D1; color: white"> <c:out
					value="${schedule.country}" /> · <c:out value="${schedule.city}" />
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
				class="absolute bottom-2.5 left-2.5 text-white text-[11px] font-bold bg-black/50 rounded-full px-2.5 py-1">
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
			<div class="flex items-center justify-between gap-2 border-t pt-2.5"
				style="border-color: #FFD447">

				<!-- 작성자 프로필 사진·닉네임 -->
				<div class="flex items-center gap-1.5 min-w-0">

					<span
						style="position: relative; display: inline-flex; align-items: center; justify-content: center; width: 24px; height: 24px; flex-shrink: 0; border-radius: 50%; overflow: hidden; background: #F0F0FF; color: #6369D1;">

						<!-- 사진이 없거나 로딩 실패 시 표시 --> <svg width="14" height="14"
							viewBox="0 0 24 24" fill="none" stroke="currentColor"
							stroke-width="1.8" aria-hidden="true">
                <circle cx="12" cy="8" r="4" />
                <path d="M4 21c0-4.3 3.6-7 8-7s8 2.7 8 7" />
            </svg> <c:if test="${not empty schedule.profileImg}">
							<c:url var="authorImageUrl"
								value="uploads/profile/${schedule.profileImg}" />

							<img src="<c:out value='${authorImageUrl}'/>" alt=""
								loading="lazy"
								style="position: absolute; inset: 0; width: 100%; height: 100%; object-fit: cover;"
								onerror="this.style.display='none';">
						</c:if>
					</span> <span class="text-[11px] text-gray-500 font-medium"
						style="white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
						<c:out value="${schedule.nickname}" />
					</span>
				</div>

				<!-- 작성일 -->
				<span class="text-[10px] text-gray-400"
					style="flex-shrink: 0; white-space: nowrap;"> <fmt:formatDate
						value="${schedule.createdAt}" pattern="yyyy.MM.dd" />
				</span>
			</div>

		</div>
	</article>
</c:forEach>
