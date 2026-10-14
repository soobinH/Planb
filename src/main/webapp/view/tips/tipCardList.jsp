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
								  style="background: #FFD447; color: #6369D1; border: 1px solid #E0E1FF;">
								  ${tag}
							</span>
						</c:forEach>
					</div>
				</c:if>
				<hr class="line">
				<div class="pt-2 mt-auto border-t border-gray-50">
					<div class="flex items-center gap-1.5 mb-1.5">
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
							<span class="text-[10px] text-gray-500">
							<c:out value="${tip.nickname}" default="알 수 없음" />
						</span>
						<span class="text-[10px] text-gray-300">·</span>
						<span class="text-[10px] text-gray-400"> ${tip.timeAgo} </span>
					</div>
					<div class="flex items-center gap-3 text-[10px] text-gray-400">
						<span>
							♡ ${tip.likeCount}
						</span>
						<span>
							▢ ${tip.commentCount}
						</span>
					</div>
				</div>
			</div>
		</a>
	</c:forEach>
</body>
</html>