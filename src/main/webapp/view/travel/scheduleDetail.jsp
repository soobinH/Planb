<%@ page language="java" contentType="text/html; charset=UTF-8"
   pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%
request.setAttribute("activePage", "travel");
%>
<c:set var="detailDayCount" value="${fn:length(itinerary.days)}" />
<c:choose>
   <c:when test="${detailDayCount eq 1}">
      <c:set var="detailDurationText" value="당일치기" />
   </c:when>
   <c:when test="${detailDayCount gt 1}">
      <c:set var="detailDurationText" value="${detailDayCount - 1}박${detailDayCount}일" />
   </c:when>
   <c:otherwise>
      <c:set var="detailDurationText" value="기간 미정" />
   </c:otherwise>
</c:choose>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title><c:out value="${itinerary.title}" /> | Planb</title>
<jsp:include page="/common/headStyles.jsp" />
<link rel="stylesheet"
   href="${pageContext.request.contextPath}/view/assets/css/travel/scheduleDetail.css?v=20261015-scrollbar">
</head>
<body class="site-shell"><jsp:include page="/common/header.jsp" />
   <main id="scheduleDetail" class="detail-layout"
      data-cart-url="${pageContext.request.contextPath}/itinerary/cart/toggle"
      data-cart-state-url="${pageContext.request.contextPath}/itinerary/cart/state"
      data-itinerary-id="${itinerary.itineraryId}"
      data-map-country="<c:out value='${itinerary.country}'/>"
      data-map-city="<c:out value='${itinerary.city}'/>"
      data-logged-in="${not empty sessionScope.user}"
      data-login-url="${pageContext.request.contextPath}/auth/login">
      <!-- 좌측: 일정 정보 -->
      <aside id="detailInfoPanel" class="detail-info-panel">
         <div class="detail-panel-header detail-info-header">
            <a href="${pageContext.request.contextPath}/schedules"
               class="flex items-center gap-1.5 shrink-0 whitespace-nowrap text-[12.5px] font-semibold text-gray-500 hover:text-gray-900 transition-colors">
               <svg class="w-4 h-4" fill="none" stroke="currentColor"
                  viewBox="0 0 24 24">
                     <path stroke-linecap="round" stroke-linejoin="round"
                     stroke-width="2" d="M15 19l-7-7 7-7" /></svg>목록으로
            </a><span class="text-gray-300">|</span>
               <span
                  class="min-w-0 text-gray-700 text-[12.5px] font-medium truncate"> 
                  <c:out value="${itinerary.title}" />
               </span>
            
            <div class="ml-auto flex items-center gap-1.5 shrink-0">
               <button id="scheduleShareButton" type="button"
                  aria-label="일정 링크 복사"
                  data-share-url="${pageContext.request.contextPath}/schedules/detail?id=${itinerary.itineraryId}"
                  class="w-8 h-8 rounded-full border flex items-center justify-center text-gray-400 hover:text-gray-700 hover:border-gray-300 transition-all"
                  style="border-color: #D1D2F9" title="공유">
                  <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor"
                     viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round"
                        stroke-width="2"
                        d="M8.684 13.342C8.886 12.938 9 12.482 9 12c0-.482-.114-.938-.316-1.342m0 2.684a3 3 0 110-2.684m0 2.684l6.632 3.316m-6.632-6l6.632-3.316m0 0a3 3 0 105.367-2.684 3 3 0 00-5.367 2.684zm0 9.316a3 3 0 105.368 2.684 3 3 0 00-5.368-2.684z" /></svg>
               </button>
               <c:if
                  test="${empty sessionScope.user or itinerary.userId ne sessionScope.user.userId}">

                  <button type="button" id="scheduleBookmarkButton"
                     data-bookmark-url="${pageContext.request.contextPath}/itinerary/bookmark"
                     data-itinerary-id="${itinerary.itineraryId}"
                     data-logged-in="${not empty sessionScope.user}"
                     data-login-url="${pageContext.request.contextPath}/auth/login"
                     aria-pressed="${itinerary.bookmarked}"
                     aria-label="${itinerary.bookmarked ? '북마크 해제' : '북마크 추가'}"
                     title="${itinerary.bookmarked ? '북마크 해제' : '북마크 추가'}"
                     class="w-8 h-8 rounded-full border flex items-center justify-center transition-all"
                     style="border-color: #D1D2F9; background: white">

                     <svg class="w-3.5 h-3.5" viewBox="0 0 24 24"
                        fill="${itinerary.bookmarked ? '#6369D1' : 'none'}"
                        stroke="#6369D1" stroke-width="2" aria-hidden="true">
                           <path stroke-linecap="round" stroke-linejoin="round"
                           d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" />
                          </svg>
                  </button>

               </c:if>
            </div>
         </div>
         <div class="detail-panel-body detail-info-body">
            <div class="relative w-full overflow-hidden"
               style="aspect-ratio: 16/7; flex-shrink: 0">
               <c:choose>
                  <c:when test="${not empty itinerary.thumbnailImg}">

                     <c:choose>
                        <c:when test="${itinerary.thumbnailImg.startsWith('/')}">
                           <c:url var="detailThumbnailUrl"
                              value="${itinerary.thumbnailImg}" />
                        </c:when>

                        <c:otherwise>
                           <c:url var="detailThumbnailUrl"
                              value="/${itinerary.thumbnailImg}" />
                        </c:otherwise>
                     </c:choose>

                     <img src="<c:out value='${detailThumbnailUrl}'/>"
                        alt="<c:out value='${itinerary.title}'/>"
                        class="w-full h-full object-cover">

                  </c:when>

                  <c:otherwise>
                     <div class="w-full h-full flex items-center justify-center"
                        style="background: #F0F0FF; color: #6369D1">여행 일정</div>
                  </c:otherwise>
               </c:choose>
               <div
                  class="absolute inset-0 bg-gradient-to-t from-black/60 via-transparent to-transparent"></div>
               <span
                  class="detail-country-badge absolute top-4 left-4 text-[11px] font-bold px-2.5 py-1 rounded-full text-white"
                  style="background: #D1D2F9; color: #494da4"> 🌏 <c:out
                     value="${itinerary.country}" /> <c:if
                     test="${not empty itinerary.city}">
                       · <c:out value="${itinerary.city}" />
                  </c:if>
               </span> <%-- 썸네일 기간 배지 숨김
<span
                  class="absolute bottom-4 left-4 text-white text-xs font-bold bg-black/50 rounded-full px-2.5 py-1">
                  <c:out value="${detailDurationText}" />
               </span>
               --%>

               <!-- 썸네일 우측 하단: 좋아요 토글 -->
               <button type="button" id="scheduleLikeButton"
                  class="detail-thumbnail-like"
                  data-login-url="${pageContext.request.contextPath}/auth/login"
                  data-like-url="${pageContext.request.contextPath}/itinerary/like"
                  data-itinerary-id="${itinerary.itineraryId}"
                  data-logged-in="${not empty sessionScope.user}"
                  aria-pressed="${itinerary.liked}"
                  aria-label="${itinerary.liked ? '좋아요 취소' : '좋아요'}"
                  title="${itinerary.liked ? '좋아요 취소' : '좋아요'}"
                  style="color: ${itinerary.liked ? '#ef4444' : '#64748b'}">

                  <svg width="23" height="23" viewBox="0 0 24 24"
                     fill="${itinerary.liked ? 'currentColor' : 'none'}"
                     stroke="currentColor" stroke-width="2" stroke-linecap="round"
                     stroke-linejoin="round" aria-hidden="true">
                       <path
                        d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78Z" />
                   </svg>
               </button>
            </div>
            <div class="px-5 pt-4 pb-3 border-b" style="border-color: #D1D2F9">
               <!-- 제목 -->
               <div class="detail-title-row">
                  <h1 class="font-black text-[18px] leading-tight text-gray-900 mb-2">
                  <c:out value="${itinerary.title}" />
               </h1>
                  <button type="button" id="scheduleReportButton"
                     data-logged-in="${not empty sessionScope.user}"
                     data-is-owner="${not empty sessionScope.user and itinerary.userId eq sessionScope.user.userId}"
                     data-login-url="${pageContext.request.contextPath}/auth/login"
                     aria-haspopup="dialog" aria-controls="scheduleReportModal"
                     class="detail-report-button">
                     
                     
                     <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M5 21V3M5 4h14l-3 5 3 5H5"/></svg>
                     신고
                  </button>
               </div>
               <!-- 내용 -->
               <p class="detail-summary text-[13px] text-gray-500 leading-relaxed mb-3">
                  <c:out value="${itinerary.summary}" />
               </p>
               <!-- 여행 날짜 -->
                  <p class="detail-trip-date">
                     <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="3" y="5" width="18" height="16" rx="3"/><path d="M16 3v4M8 3v4M3 11h18"/></svg> <c:choose>
                        <c:when
                           test="${not empty itinerary.startDate and not empty itinerary.endDate}">
                           <fmt:formatDate value="${itinerary.startDate}"
                              pattern="yyyy.MM.dd" />                
                           ~
                               <fmt:formatDate value="${itinerary.endDate}"
                              pattern="yyyy.MM.dd" />
                        </c:when>
                        <c:otherwise>날짜 미정</c:otherwise>
                     </c:choose>
                  </p>

               <div class="detail-stats-row">
                  <div class="flex items-center gap-3 text-[12px] text-gray-500">

                     <!-- 좋아요 수: 항상 빨간 하트로 표시 -->
                     <span class="inline-flex items-center gap-1" title="좋아요 수">

                        <svg width="14" height="14" viewBox="0 0 24 24" fill="#ef4444"
                           stroke="#ef4444" stroke-width="2" stroke-linecap="round"
                           stroke-linejoin="round" aria-hidden="true">

                             <path
                              d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78Z" />
                         </svg> <span id="scheduleLikeCount" class="font-semibold"> <fmt:formatNumber
                              value="${itinerary.likeCount}" pattern="#,##0" />
                     </span>
                     </span>

                     <!-- 조회수 아이콘 및 표시 -->
                     <span class="flex items-center gap-1"> <svg
                           class="w-3.5 h-3.5" fill="none" stroke="currentColor"
                           viewBox="0 0 24 24">
                           <path stroke-linecap="round" stroke-linejoin="round"
                              stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                           <path stroke-linecap="round" stroke-linejoin="round"
                              stroke-width="2"
                              d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                        </svg> <fmt:formatNumber
                           value="${empty itinerary.viewCount ? 0 : itinerary.viewCount}"
                           pattern="#,##0" />
                     </span>
                  </div>
               
               </div>
               <div class="detail-travel-meta detail-travel-meta-inline">

                  <!-- 여행 기간 -->
                  <span
                     class="flex items-center gap-1 text-[12px] px-3 py-1.5 rounded-full border font-medium"
                     style="border-color: #D1D2F9; background: #f5f5ff; color: #4a4a6a">
                     <span>🗓️</span> <c:out value="${detailDurationText}" />
                  </span>

                  <!-- 여행 인원 -->
                  <span
                     class="flex items-center gap-1 text-[12px] px-3 py-1.5 rounded-full border font-medium"
                     style="border-color: #D1D2F9; background: #f5f5ff; color: #4a4a6a">
                     <span>👥</span> <c:choose>
                        <c:when test="${not empty itinerary.travelerCount}">
                           <c:out value="${itinerary.travelerCount}" />명
                           </c:when>
                        <c:otherwise>인원 미정</c:otherwise>
                     </c:choose>
                  </span>

                  <!-- 총 예산 -->
                  <span
                     class="flex items-center gap-1 text-[12px] px-3 py-1.5 rounded-full border font-medium"
                     style="border-color: #D1D2F9; background: #f5f5ff; color: #4a4a6a">
                     <span>💰</span> <c:choose>
                        <c:when test="${not empty itinerary.totalBudget}">
                           <fmt:formatNumber value="${itinerary.totalBudget}"
                              pattern="#,##0" />원
                           </c:when>
                        <c:otherwise>예산 미정</c:otherwise>
                     </c:choose>
                  </span>

               </div>
               <div class="flex gap-2">
                  <button type="button" data-cart-add="ITINERARY"
                     data-target-id="${itinerary.itineraryId}" data-cart-state="NONE"
                     aria-pressed="false"
                     class="detail-cart-full"
                     style="background: #6369D1; color: white">
                     <svg class="w-3.5 h-3.5 shrink-0" fill="none"
                        stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round"
                           stroke-width="2"
                           d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13 5.4 5M7 13l-2.3 2.3c-.6.6-.2 1.7.7 1.7H17m0 0a2 2 0 100 4 2 2 0 000-4Zm-8 2a2 2 0 11-4 0 2 2 0 014 0Z" /></svg>
                     <span data-cart-label>전체 일정 담기</span>
                  </button>
                  
               </div>
               <!-- 본인 일정에서만 수정·삭제 표시 -->
               <c:if
                  test="${not empty sessionScope.user and itinerary.userId eq sessionScope.user.userId}">
                  <c:url var="modifyPlanUrl" value="/modifyplan">
                     <c:param name="itineraryId" value="${itinerary.itineraryId}" />
                  </c:url>

                  <div class="detail-owner-actions">
                     <a href="${modifyPlanUrl}"
                        class="detail-owner-button detail-owner-edit"> <svg
                           width="14" height="14" viewBox="0 0 24 24" fill="none"
                           stroke="currentColor" stroke-width="2" stroke-linecap="round"
                           stroke-linejoin="round" aria-hidden="true">
                               <path d="m16 3 5 5-12 12-6 1 1-6Z" />
                               <path d="m14 5 5 5" />
                           </svg> 일정 수정
                     </a>

                     <button type="button" id="scheduleDeleteButton"
                        class="detail-owner-button detail-owner-delete"
                        data-delete-url="${pageContext.request.contextPath}/itinerary/delete"
                        data-itinerary-id="${itinerary.itineraryId}"
                        data-list-url="${pageContext.request.contextPath}/schedules">

                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none"
                           stroke="currentColor" stroke-width="2" stroke-linecap="round"
                           stroke-linejoin="round" aria-hidden="true">
                               <path d="M3 6h18" />
                               <path d="M9 6V4h6v2" />
                               <path d="m5 6 1 14h12l1-14" />
                               <path d="M10 10v6M14 10v6" />
                           </svg>
                        일정 삭제
                     </button>
                  </div>
               </c:if>
            </div>
            <div class="px-5 py-3 border-b flex items-center gap-3"
               style="border-color: #D1D2F9">

               <c:url var="authorProfileUrl" value="/profile/userProfile">
                  <c:param name="userId" value="${itinerary.userId}" />
               </c:url>

               <a href="${authorProfileUrl}"
                  class="flex items-center gap-2.5 flex-1 min-w-0
               hover:opacity-75 transition-opacity text-left">

                  <div
                     class="w-9 h-9 rounded-full overflow-hidden border-2 shrink-0 flex items-center justify-center"
                     style="border-color: #D1D2F9; background: #F0F0FF; color: #6369D1">

                     <c:choose>
                        <c:when test="${not empty itinerary.profileImg}">

                           <c:url var="authorImageUrl"
                              value="/uploads/profile/${itinerary.profileImg}" />

                           <img src="<c:out value='${authorImageUrl}'/>" alt="작성자 프로필"
                              class="w-full h-full object-cover">

                        </c:when>

                        <c:otherwise>
                           <svg width="20" height="20" viewBox="0 0 24 24" fill="none"
                              stroke="currentColor" stroke-width="2" aria-hidden="true">
                                    <circle cx="12" cy="8" r="4" />
                                    <path d="M4 21v-2a8 8 0 0 1 16 0v2" />
                                </svg>
                        </c:otherwise>
                     </c:choose>

                  </div>

                  <div class="min-w-0">
                     <p
                        class="text-[13px] font-bold text-gray-900 hover:underline truncate">
                        <c:out value="${itinerary.nickname}" />
                     </p>

                     <p class="text-[11px] text-gray-400">
                        <fmt:formatDate value="${itinerary.createdAt}"
                           pattern="yyyy.MM.dd" />
                        게시
                     </p>
                  </div>

               </a>
            </div>
         </div>
      </aside>

      <!-- 가운데: 일정표·댓글 -->
      <section id="detailContentPanel" class="detail-content-panel">

         <div class="detail-panel-header detail-tabs-header">

            <button type="button" data-detail-tab="schedule"
               aria-selected="true" aria-controls="detailSchedulePanel"
               class="flex-1 py-3 text-[12.5px] font-semibold relative transition-colors whitespace-nowrap"
               style="color: #6369D1">

               일정표 <span data-detail-tab-line
                  class="absolute bottom-0 left-0 right-0 h-[2.5px] rounded-t-full"
                  style="background: #6369D1"></span>
            </button>

            <button type="button" data-detail-tab="comments"
               aria-selected="false" aria-controls="detailCommentPanel"
               class="flex-1 py-3 text-[12.5px] font-semibold relative transition-colors whitespace-nowrap"
               style="color: #94a3b8">

               댓글 (<span id="scheduleCommentCount"><c:out
                     value="${itinerary.commentCount}" /></span>) <span data-detail-tab-line
                  class="hidden absolute bottom-0 left-0 right-0 h-[2.5px] rounded-t-full"
                  style="background: #6369D1"></span>
            </button>
         </div>

         <div class="detail-panel-body detail-content-body">
            <section id="detailCommentPanel" class="hidden p-4"
               data-itinerary-id="${itinerary.itineraryId}"
               data-logged-in="${not empty sessionScope.user}"
               data-login-user-id="${empty sessionScope.user ? '' : sessionScope.user.userId}"
               data-login-url="${pageContext.request.contextPath}/auth/login"
               data-context-path="${pageContext.request.contextPath}"
               data-write-url="${pageContext.request.contextPath}/itinerary/comment/write"
               data-update-url="${pageContext.request.contextPath}/itinerary/comment/update"
               data-delete-url="${pageContext.request.contextPath}/itinerary/comment/delete">
               

               <!-- 댓글 입력 -->
               <div class="rounded-2xl border p-4 mb-5"
                  style="border-color: #D1D2F9; background: #fafafa">

                  <textarea id="scheduleCommentContent" aria-label="댓글 내용"
                     placeholder="여행 일정에 대한 댓글을 남겨보세요..."
                     class="w-full bg-transparent text-[13px] outline-none resize-none"
                     style="min-height: 110px"></textarea>

                  <div class="flex items-center justify-between mt-3">
                     <span class="text-[11px] text-gray-400"> <span
                        id="scheduleCommentLength">0</span> / 1,000
                     </span>

                     <button type="button" id="scheduleCommentSubmit"
                        class="px-5 py-2 rounded-xl text-[13px] font-bold text-white transition-opacity"
                        style="background: #6369D1">등록</button>
                  </div>
               </div>

               <!-- 댓글 목록 -->
               <div id="scheduleCommentList" class="space-y-5">

                  <c:if test="${empty comments}">
                     <p class="py-5 text-center text-[12px] text-gray-400">아직 댓글이
                        없습니다.</p>
                  </c:if>

                  <c:forEach var="comment" items="${comments}">

                     <article class="flex items-start gap-3" data-comment-item
                        data-comment-id="${comment.commentId}">

                        <!-- 작성자 사진 -->
                        <div
                           class="w-10 h-10 rounded-full overflow-hidden shrink-0 flex items-center justify-center"
                           style="background: #F0F0FF; color: #6369D1">

                           <c:choose>
                              <c:when test="${not empty comment.profileImg}">

                                 <c:choose>
                                    <c:when
                                       test="${comment.profileImg.startsWith('https://')
                                    or comment.profileImg.startsWith('http://')}">
                                       <c:set var="commentProfileUrl"
                                          value="${comment.profileImg}" />
                                    </c:when>

                                    <c:when test="${comment.profileImg.startsWith('/')}">
                                       <c:url var="commentProfileUrl"
                                          value="${comment.profileImg}" />
                                    </c:when>

                                    <c:otherwise>
                                       <c:url var="commentProfileUrl"
                                          value="/uploads/profile/${comment.profileImg}" />
                                    </c:otherwise>
                                 </c:choose>

                                 <img src="<c:out value='${commentProfileUrl}'/>"
                                    alt="작성자 프로필" class="w-full h-full object-cover">
                              </c:when>

                              <c:otherwise>
                                 <svg width="22" height="22" viewBox="0 0 24 24" fill="none"
                                    stroke="currentColor" stroke-width="2" aria-hidden="true">
                                <circle cx="12" cy="8" r="4" />
                                <path d="M4 21v-2a8 8 0 0 1 16 0v2" />
                            </svg>
                              </c:otherwise>
                           </c:choose>
                        </div>

                        <div class="flex-1 min-w-0">

                           <div class="flex items-center gap-2 flex-wrap">
                              <span class="font-bold text-[13px] text-gray-900"> <c:out
                                    value="${comment.nickname}" />
                              </span> <span class="text-[11px] text-gray-400"> <fmt:formatDate
                                    value="${comment.createdAt}" pattern="yyyy.MM.dd HH:mm" />
                              </span>

                              <c:if
                                 test="${not empty comment.updatedAt and not empty comment.createdAt and comment.updatedAt.time gt comment.createdAt.time}">
                                 <span class="text-[10px] text-gray-400" data-comment-edited>수정됨
                                 </span>
                              </c:if>

                              <c:if
                                 test="${not empty sessionScope.user and comment.userId eq sessionScope.user.userId}">

                                 <div class="ml-auto flex items-center gap-2"
                                    data-comment-actions>

                                    <button type="button" data-comment-edit
                                       data-comment-id="${comment.commentId}"
                                       class="text-[11px] text-gray-400 hover:text-[#6369D1]">
                                       수정</button>

                                    <button type="button" data-comment-delete
                                       data-comment-id="${comment.commentId}"
                                       class="text-[11px] text-gray-400 hover:text-red-500">
                                       삭제</button>
                                 </div>
                              </c:if>
                           </div>

                           <p data-comment-content class="mt-1 text-[13px] text-gray-600"
                              style="white-space: pre-wrap; overflow-wrap: anywhere;"><c:out value="${comment.content}" /></p>
                        </div>
                     </article>

                  </c:forEach>
               </div>
            </section>

            <div id="detailSchedulePanel" class="p-4 space-y-3">

               <c:if test="${empty itinerary.days}">
                  <p class="py-8 text-center text-[12px] text-gray-400">등록된 세부
                     일정이 없습니다.</p>
               </c:if>

               <c:forEach var="day" items="${itinerary.days}"
                  varStatus="dayStatus">

                  <div class="rounded-2xl border overflow-hidden"
                     style="border-color: #D1D2F9">

                     <!-- 일차별 접기·펼치기 / 담기는 독립 버튼 -->
                     <div class="detail-day-header">
                        <button type="button" class="detail-day-toggle" data-detail-day-toggle
                            aria-expanded="true" aria-controls="detailDayBody_${dayStatus.index}">
                            <span class="detail-day-number">${dayStatus.count}</span>
                            <span class="detail-day-copy">
                                <span class="detail-day-meta">
                                    <span class="detail-day-label">Day ${dayStatus.count}</span>
                                    <c:if test="${not empty day.dayDate}">
                                        <span class="detail-day-date"><fmt:formatDate value="${day.dayDate}" pattern="yyyy.MM.dd (E)" /></span>
                                    </c:if>
                                </span>
                                <c:if test="${not empty day.title}">
                                    <span class="detail-day-title"><c:out value="${day.title}" /></span>
                                </c:if>
                            </span>
                            <svg class="detail-day-chevron" width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m6 9 6 6 6-6"/></svg>
                        </button>
                        <button type="button" data-cart-add="DAY"
                           data-target-id="${day.dayId}" data-cart-state="NONE"
                           aria-pressed="false" class="detail-cart-small"
                           title="이 일차의 모든 블록 담기" aria-label="${dayStatus.count}일차 전체 담기">

                           <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16"
                              viewBox="0 0 24 24" fill="none" stroke="currentColor"
                              stroke-width="2" stroke-linecap="round"
                              stroke-linejoin="round"
                              class="lucide lucide-shopping-cart-plus preview-icon">
                              <path d="M16 5h6" />
                              <path d="M19 2v6" />
                              <path
                                 d="m2.05 2.05 1.099-.028a1 1 0 011.008.815l2.69 14.347A1 1 0 007.83 18H18" />
                              <path d="M4.564 5H12" />
                              <path d="M6.25 14h12.712a2 2 0 001.991-1.57l.172-1.041" />
                              <circle cx="18" cy="20" r="2" />
                              <circle cx="8" cy="20" r="2" /></svg>

                           <span data-cart-label>담기</span>
                        </button>

                     </div>

                     <!-- 해당 일차의 블록 목록 -->
                     <div id="detailDayBody_${dayStatus.index}" class="detail-day-body px-4 pb-3 pt-1">

                        <c:if test="${empty day.blocks}">
                           <p class="py-4 text-center text-[12px] text-gray-400">등록된
                              블록이 없습니다.</p>
                        </c:if>

                        <c:forEach var="block" items="${day.blocks}"
                           varStatus="blockStatus">

                           <div class="flex gap-3 relative pt-3">

                              <!-- 일정 연결선 -->
                              <div class="flex flex-col items-center shrink-0"
                                 style="width: 18px">

                                 <div
                                    class="w-3 h-3 rounded-full border-2 border-white shrink-0"
                                    style="background: #6369D1; box-shadow: 0 0 0 2px #6369D140; margin-top: 4px">
                                 </div>

                                 <c:if test="${not blockStatus.last}">
                                    <div class="flex-1 w-0.5 mt-1"
                                       style="background: #6369D130; min-height: 28px"></div>
                                 </c:if>

                              </div>

                              <div class="detail-block-content${empty block.images ? '' : ' has-photos'}">
                                 <div class="detail-block-heading">
<!-- 블록 종류 -->
                                 <c:if test="${not empty block.blockType}">
                                    <div class="detail-block-type-row detail-block-type-inline">
                                       <span class="detail-block-type"
                                          data-block-type="<c:out value='${block.blockType}'/>">

                                          <c:choose>
                                             <c:when test="${block.blockType eq 'ATTRACTION'}">관광</c:when>
                                             <c:when test="${block.blockType eq 'MEAL'}">식사</c:when>
                                             <c:when test="${block.blockType eq 'LODGING'}">숙소</c:when>
                                             <c:when test="${block.blockType eq 'TRANSPORT'}">교통</c:when>
                                             <c:when test="${block.blockType eq 'ACTIVITY'}">활동</c:when>
                                             <c:otherwise>
                                                <c:out value="${block.blockType}" />
                                             </c:otherwise>
                                          </c:choose>
                                       </span>
                                    </div>
                                 </c:if>
<span
                                          class="detail-block-title font-bold text-[13px]
                                             text-gray-900 leading-snug"
                                          style="overflow-wrap: anywhere"> <c:out
                                             value="${empty block.title
                                        ? block.placeName : block.title}" />
                                       </span>
                                 </div>
<button type="button" data-cart-add="BLOCK"
                                       data-target-id="${block.blockId}" data-cart-state="NONE"
                                       aria-pressed="false" class="detail-cart-small detail-block-cart"
                                       title="블록 담기" aria-label="블록 담기">

                                       <svg xmlns="http://www.w3.org/2000/svg" width="12"
                                          height="12" viewBox="0 0 24 24" fill="none"
                                          stroke="currentColor" stroke-width="1"
                                          stroke-linecap="round" stroke-linejoin="round"
                                          class="lucide lucide-shopping-cart-plus preview-icon">
                                          <path d="M16 5h6" />
                                          <path d="M19 2v6" />
                                          <path
                                             d="m2.05 2.05 1.099-.028a1 1 0 011.008.815l2.69 14.347A1 1 0 007.83 18H18" />
                                          <path d="M4.564 5H12" />
                                          <path d="M6.25 14h12.712a2 2 0 001.991-1.57l.172-1.041" />
                                          <circle cx="18" cy="20" r="2" />
                                          <circle cx="8" cy="20" r="2" /></svg>
                                       <span data-cart-label>담기</span>
                                    </button>
                                 <div class="detail-block-body">
<c:if
                                          test="${not empty block.startTime
                                    or not empty block.endTime}">

                                          <span
                                             class="detail-block-time"> <c:if
                                                test="${not empty block.startTime}">
                                                <fmt:formatDate value="${block.startTime}"
                                                   pattern="HH:mm" />
                                             </c:if> <c:if
                                                test="${not empty block.startTime
                                            and not empty block.endTime}">
                                            –
                                        </c:if> <c:if
                                                test="${not empty block.endTime}">
                                                <fmt:formatDate value="${block.endTime}" pattern="HH:mm" />
                                             </c:if>

                                          </span>
                                       </c:if>
<!-- 장소 -->
                                 <c:if
                                    test="${not empty block.placeName
                                and block.placeName ne block.title}">
                                    <p class="detail-block-place mt-1 text-[11px] text-black-600">
                                       <c:out value="${block.placeName}" />
                                    </p>
                                 </c:if>

                                 <c:if test="${not empty block.placeAddress}">
                                    <p class="detail-block-address mt-1 text-[11px] text-black-500"
                                       style="overflow-wrap: anywhere">
                                       <c:out value="${block.placeAddress}" />
                                    </p>
                                 </c:if>
                                 </div>
                                 <div class="detail-block-note-body">
                                 <!-- 메모: 태그 안쪽의 불필요한 공백 제거 -->
                                 <c:if test="${not empty block.memo}">
                                    <p class="detail-block-memo"
                                       style="white-space: pre-wrap; overflow-wrap: anywhere;"><c:out value="${block.memo}" /></p>
                                 </c:if>

                                 <!-- 비용: 0원도 표시 -->
                                 <c:if test="${not empty block.cost}">
                                    <p class="mt-2 text-[11px] font-semibold"
                                       style="color: #6369D1">

                                       <fmt:formatNumber value="${block.cost}" pattern="#,##0.##" />
                                       원

                                       <c:choose>
                                          <c:when test="${block.costType eq 'PER_PERSON'}">
                                             <span class="font-normal text-gray-400"> · 1인 기준 </span>
                                          </c:when>
                                          <c:when test="${block.costType eq 'TOTAL'}">
                                             <span class="font-normal text-gray-400"> · 전체 금액 </span>
                                          </c:when>
                                       </c:choose>

                                    </p>
                                 </c:if>
                                 </div>
                                 <c:if test="${not empty block.images}">
                                    <div class="detail-block-photos" data-block-carousel>
                                        <div class="detail-block-photo-track" data-photo-track tabindex="0"
                                            role="region" aria-label="블록 사진, 좌우 방향키로 넘기기">
<c:forEach var="image" items="${block.images}" end="2">

                                          <c:if test="${not empty image.imageUrl}">
                                             <c:choose>

                                                <c:when
                                                   test="${image.imageUrl.startsWith('https://')
                                                    or image.imageUrl.startsWith('http://')}">
                                                   <c:set var="blockImageUrl" value="${image.imageUrl}" />
                                                </c:when>

                                                <c:when test="${image.imageUrl.startsWith('/')}">
                                                   <c:url var="blockImageUrl" value="${image.imageUrl}" />
                                                </c:when>

                                                <c:otherwise>
                                                   <c:url var="blockImageUrl" value="/${image.imageUrl}" />
                                                </c:otherwise>

                                             </c:choose>

                                             <a href="<c:out value='${blockImageUrl}'/>"
                                                target="_blank" rel="noopener noreferrer"
                                                class="detail-block-image">

                                                <img src="<c:out value='${blockImageUrl}'/>"
                                                alt="일정 블록 사진" loading="lazy"
                                                class="w-full h-full object-cover">
                                             </a>

                                          </c:if>
                                       </c:forEach>
                                        </div>
                                        <button type="button" class="detail-block-photo-nav is-prev" data-photo-prev aria-label="이전 사진" hidden>
                                            <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m15 6-6 6 6 6"/></svg>
                                        </button>
                                        <button type="button" class="detail-block-photo-nav is-next" data-photo-next aria-label="다음 사진" hidden>
                                            <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m9 6 6 6-6 6"/></svg>
                                        </button>
                                        <span class="detail-block-photo-count" data-photo-count hidden aria-live="polite"></span>
                                    </div>
                                 </c:if>
                              </div>
                           </div>

                        </c:forEach>
                     </div>
                  </div>

               </c:forEach>
            </div>
            <!-- detailSchedulePanel 종료 -->
         </div>
      </section>
      <!-- 가운데 패널 종료 -->

      <!-- 우측: 지도 -->
      <section class="detail-map-panel" aria-label="여행 일정 지도">

         <div class="detail-map-toolbar">
            <span class="detail-map-heading">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#6369D1" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><polygon points="3 6 9 3 15 6 21 3 21 18 15 21 9 18 3 21"/><path d="M9 3v18M15 6v18"/></svg>
                경로 지도
            </span>

            <div class="detail-map-filter">
               <button type="button" id="detailMapFilterButton"
                  aria-expanded="false" aria-controls="detailMapFilterMenu">

                  <span id="detailMapFilterDot" class="detail-map-filter-dot"></span>

                  <span id="detailMapFilterLabel">전체</span>

                  <svg width="12" height="12" viewBox="0 0 24 24" fill="none"
                     stroke="currentColor" stroke-width="2" aria-hidden="true">
                    <path d="m6 9 6 6 6-6" />
                </svg>
               </button>

               <div id="detailMapFilterMenu" class="detail-map-filter-menu" hidden>

                  <button type="button" data-detail-map-day="all">전체</button>

                  <c:forEach var="day" items="${itinerary.days}"
                     varStatus="dayStatus">
                     <button type="button" data-detail-map-day="${dayStatus.count}">
                        ${dayStatus.count}일차</button>
                  </c:forEach>
               </div>
            </div>
         </div>

         <div class="detail-map-canvas-wrap">
            <div id="detailGoogleMap"></div>

            <!-- 전체 보기의 DAY별 동선 색상 -->
            <div id="detailMapDayLegend" class="detail-map-day-legend" hidden></div>

            <div id="detailMapStatus" class="detail-map-status" role="status">
               지도를 불러오는 중입니다.</div>
         </div>
      </section>
   </main>

   <!-- 일정 신고 팝업 -->
   <dialog id="scheduleReportModal" class="schedule-report-modal"
      aria-labelledby="scheduleReportTitle"
      aria-describedby="scheduleReportNotice">

   <div class="schedule-report-header">
      <div>
         <h2 id="scheduleReportTitle">신고하기</h2>
         <p id="scheduleReportNotice">허위신고 시 불이익이 발생할 수 있습니다.</p>
      </div>

      <button type="button" class="schedule-report-close" data-report-close
         aria-label="신고 팝업 닫기">

         <svg width="20" height="20" viewBox="0 0 24 24" fill="none"
            stroke="currentColor" stroke-width="2" aria-hidden="true">
                <path d="M6 6l12 12M18 6L6 18" />
            </svg>
      </button>
   </div>

   <!-- 신고 입력 화면 -->
   <form id="scheduleReportForm" class="schedule-report-form"
      action="${pageContext.request.contextPath}/itinerary/report"
      method="post">

      <input type="hidden" name="itineraryId"
         value="${itinerary.itineraryId}">

      <fieldset class="schedule-report-reasons">
         <legend>
            신고 사유를 선택해 주세요 <span class="schedule-report-required">*</span>
         </legend>

         <c:forEach var="reason" items="${reportReasons}">
            <label class="schedule-report-reason"> <input type="radio"
               name="reasonId" value="${reason.reasonId}" required> <span>
                  <c:out value="${reason.reasonName}" />
            </span>
            </label>
         </c:forEach>

         <c:if test="${empty reportReasons}">
            <p class="schedule-report-empty">등록된 신고 사유가 없습니다.</p>
         </c:if>
      </fieldset>

      <div class="schedule-report-detail">
         <label for="scheduleReportDetail"> 상세 내용 <span>(선택)</span>
         </label>

         <textarea id="scheduleReportDetail" name="detail" rows="4"
            aria-describedby="scheduleReportLength"
            placeholder="신고 사유에 대해 자세히 설명해 주세요."></textarea>

         <p class="schedule-report-counter">
            <span id="scheduleReportLength">0</span>/300
         </p>
      </div>

      <p id="scheduleReportError" class="schedule-report-error" role="alert"
         hidden></p>

      <div class="schedule-report-actions">
         <button type="button" class="schedule-report-cancel"
            data-report-close>취소</button>

         <button type="submit" id="scheduleReportSubmit"
            class="schedule-report-submit" disabled>신고하기</button>
      </div>
   </form>

   <!-- 접수 성공 후 표시할 화면 -->
   <div id="scheduleReportSuccess" class="schedule-report-success"
      role="status" hidden>

      <div class="schedule-report-success-icon">
         <svg width="32" height="32" viewBox="0 0 24 24" fill="none"
            stroke="currentColor" stroke-width="2.5" aria-hidden="true">
                <path stroke-linecap="round" stroke-linejoin="round"
               d="M5 12l4 4L19 6" />
            </svg>
      </div>

      <h3>신고가 접수되었습니다</h3>

      <p>
         검토 후 적절한 조치를 취하겠습니다.<br> 신고해 주셔서 감사합니다.
      </p>

      <button type="button" class="schedule-report-confirm"
         data-report-close>확인</button>
   </div>

   </dialog>
   <!-- 별도 지도 JS에서 읽을 실제 일정 데이터 -->
   <div id="detailMapData" hidden>
      <c:out value="${detailMapJson}" />
   </div>
   <script
      src="${pageContext.request.contextPath}/view/assets/js/auth/tripily.js"></script>

   <script
      src="${pageContext.request.contextPath}/view/assets/js/travel/scheduleDetail.js?v=15"></script>
      
   <script
       src="${pageContext.request.contextPath}/view/assets/js/travel/scheduleDetailMap.js?v=3"></script>

   <script async
       onerror="detailMapLoadFailed()"
       src="https://maps.googleapis.com/maps/api/js?key=AIzaSyB7ioaQS08aAzCl7gZPk6SyE1w7EeIrYhI&language=ko&v=weekly&loading=async&callback=initScheduleDetailMap"></script>
</body>
</html>