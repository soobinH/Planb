
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<link rel="stylesheet"
      href="${pageContext.request.contextPath}/view/assets/css/mates/mateList.css?v=20261014">

<c:forEach var="mate" items="${mateList}">

    <a
        href="${pageContext.request.contextPath}/mateDetail?mateId=${mate.mateId}"
        class="relative bg-white rounded-2xl border border-gray-100 shadow-sm hover:shadow-md transition-all cursor-pointer group p-5 hover:border-[#D1D2F9] flex flex-col min-w-0">

        <!-- 국가 / 모집 상태 -->
        <div class="flex items-center justify-between gap-2 mb-3">

            <!-- 국가 -->
            <span
                class="flex items-center gap-1 text-xs font-bold px-2.5 py-1 rounded-full min-w-0"
                style="background: var(--brand-soft); color: var(--brand)">

                <svg
                    width="10"
                    height="10"
                    viewBox="0 0 24 24"
                    fill="none"
                    stroke="currentColor"
                    stroke-width="2"
                    class="shrink-0">

                    <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z" />
                    <circle cx="12" cy="10" r="3" />

                </svg>

                <span class="truncate">
                    <c:out value="${mate.country}" />
                </span>

            </span>

            <!-- 모집 상태 -->
            <c:choose>

                <c:when test="${mate.recruitStatus eq 'OPEN'}">

                    <span
                        class="inline-flex items-center gap-1 text-[11px] font-bold px-2.5 py-1 rounded-full shrink-0"
                        style="background: #ecfdf5; color: #059669">

                        <span
                            class="inline-block w-1.5 h-1.5 rounded-full"
                            style="background: #10b981">
                        </span>

                        모집중

                    </span>

                </c:when>

                <c:otherwise>

                    <span
                        class="inline-flex items-center gap-1 text-[11px] font-bold px-2.5 py-1 rounded-full shrink-0"
                        style="background: #fef2f2; color: #dc2626">

                        <span
                            class="inline-block w-1.5 h-1.5 rounded-full"
                            style="background: #ef4444">
                        </span>

                        모집완료

                    </span>

                </c:otherwise>

            </c:choose>

        </div>

        <!-- 제목 -->
        <h3
            class="font-bold text-[15px] text-gray-900 leading-snug mb-4 group-hover:text-brand transition-colors break-words">

            <c:out value="${mate.title}" />

        </h3>

        <!-- 모집 인원 -->
        <div class="flex items-center gap-2 mb-4 flex-wrap">

            <span
                class="text-[11px] font-semibold px-2.5 py-1 rounded-full"
                style="background: var(--brand-light); color: var(--brand)">

                👥 ${mate.recruitCount}명 모집

            </span>

        </div>

        <!-- 카드 하단 -->
		<div class="mate-card-bottom">
		
		    <hr class="line">
		
		    <div class="mate-card-footer">
		
		        <!-- 작성자 정보 -->
		        <div class="mate-card-author">
		
		            <!-- 프로필 이미지 -->
		            <div class="mate-author-avatar"><jsp:include page="/common/profileImage.jsp"><jsp:param name="image" value="${mate.profileImg}"/></jsp:include></div>
		
		            <!-- 닉네임 / 작성 시간 -->
		            <div class="mate-author-info">
		
		                <span class="mate-author-name">
		                    <c:out value="${mate.nickname}" default="알 수 없음" />
		                </span>
		
		                <span class="mate-author-time">
		                    · <c:out value="${mate.timeAgo}" />
		                </span>
		
		            </div>
		
		        </div>
		
		        <!-- 좋아요 / 댓글 / 조회수 -->
		        <div class="mate-card-stats">
		
		            <!-- 좋아요 : Lucide Heart -->
		            <span class="mate-card-stat">
		
		                <svg
		                    xmlns="http://www.w3.org/2000/svg"
		                    width="14"
		                    height="14"
		                    viewBox="0 0 24 24"
		                    fill="none"
		                    stroke="currentColor"
		                    stroke-width="2"
		                    stroke-linecap="round"
		                    stroke-linejoin="round"
		                    aria-hidden="true">
		
		                    <path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z" />
		
		                </svg>
		
		                <span>${mate.likeCount}</span>
		
		            </span>
		
		            <!-- 댓글 : Lucide Message Circle -->
		            <span class="mate-card-stat">
		
		                <svg
		                    xmlns="http://www.w3.org/2000/svg"
		                    width="14"
		                    height="14"
		                    viewBox="0 0 24 24"
		                    fill="none"
		                    stroke="currentColor"
		                    stroke-width="2"
		                    stroke-linecap="round"
		                    stroke-linejoin="round"
		                    aria-hidden="true">
		
		                    <path d="M7.9 20A9 9 0 1 0 4 16.1L2 22Z" />
		
		                </svg>
		
		                <span>${mate.commentCount}</span>
		
		            </span>
		
		            <!-- 조회수 : Lucide Eye -->
		            <span class="mate-card-stat">
		
		                <svg
		                    xmlns="http://www.w3.org/2000/svg"
		                    width="14"
		                    height="14"
		                    viewBox="0 0 24 24"
		                    fill="none"
		                    stroke="currentColor"
		                    stroke-width="2"
		                    stroke-linecap="round"
		                    stroke-linejoin="round"
		                    aria-hidden="true">
		
		                    <path d="M2.062 12.348a1 1 0 0 1 0-.696 10.75 10.75 0 0 1 19.876 0 1 1 0 0 1 0 .696 10.75 10.75 0 0 1-19.876 0" />
		                    <circle cx="12" cy="12" r="3" />
		
		                </svg>
		
		                <span>${mate.viewCount}</span>
		
		            </span>
		
		        </div>
		
		    </div>
		
		</div>

    </a>

</c:forEach>
