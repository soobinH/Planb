<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
	<c:forEach var="tip" items="${tipList}">
		<a href="${pageContext.request.contextPath}/view/tips/tipDetail.jsp?id=${tip.tipId}"
			class="relative bg-white rounded-2xl border border-gray-100 shadow-sm hover:shadow-md 
			transition-shadow cursor-pointer group overflow-hidden flex flex-col">
			<div class="relative shrink-0 overflow-hidden" style="aspect-ratio: 4 / 3">
				<c:choose>
					<c:when test="${not empty tip.thumbnailImg}">
						<img src="${pageContext.request.contextPath}${tip.thumbnailImg}" alt="${tip.title}"
							class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300">
					</c:when>
					<c:otherwise>
						<div class="w-full h-full flex items-center justify-center bg-gray-100 text-gray-400 text-sm">이미지 없음</div>
					</c:otherwise>
				</c:choose>
			</div>
			<div class="flex flex-col flex-1 p-3 min-h-0">
				<h3 class="font-bold text-[13px] text-gray-900 leading-snug line-clamp-2 
					group-hover:text-brand transition-colors mb-1.5" style="min-height: 2.6em">
					<c:out value="${tip.title}" />
				</h3>
				<p class="text-[11px] text-gray-500 leading-relaxed line-clamp-2 flex-1">
					<c:out value="${tip.content}" />
				</p>
				<c:if test="${not empty tip.hashtag}">
					<div class="flex flex-wrap gap-1.5 mt-2 mb-3">
						<c:forEach var="tag" items="${tip.hashtagList}">
							<span class="inline-flex items-center rounded-full px-2.5 py-1 text-[11px] font-semibold"
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
						<div class="w-5 h-5 rounded-full flex items-center justify-center text-white text-[9px] font-bold shrink-0"
							 style="background: #8B5CF6">
							<c:choose>
								<c:when test="${not empty tip.nickname}">
									${tip.nickname.substring(0, 1)}
								</c:when>
								<c:otherwise>
									?
								</c:otherwise>
							</c:choose>
						</div>
							<span class="text-[10px] text-gray-500" style="min-width: 0; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">
							<c:out value="${tip.nickname}" default="알 수 없음" />
						</span>
						
						
					</div>
                        <span class="text-[10px] text-gray-400" style="flex-shrink: 0; white-space: nowrap;"><c:out value="${tip.timeAgo}" /></span>
                    </div>
                </div>
			</div>
		</a>
	</c:forEach>
</body>
</html>