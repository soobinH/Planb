<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
request.setAttribute("activePage", "tips");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<title>Planb</title>
	<jsp:include page="/common/headStyles.jsp" /></head>
	<link rel="stylesheet" href="${pageContext.request.contextPath}/view/assets/css/tips/tipDetail.css">
	<script defer src="${pageContext.request.contextPath}/view/assets/js/tips/tipDetail.js"></script>
<body class="site-shell">
	<jsp:include page="/common/header.jsp" />

	<!-- [수정] 전체 폭 축소: 레이아웃을 tipDetail.css의 전용 클래스로 제어 -->
	<div class="tip-detail-page">
    	<div class="tip-detail-wrap">

			<div class="tip-detail-layout">

				<!-- [수정] 좌측 광고 (스크롤 따라다님 / sticky) -->
				<aside class="tip-ad-side tip-ad-left" aria-label="좌측 광고 영역">
					<div class="tip-ad-box">
						<div class="tip-ad-badge">AD</div>
						<p class="tip-ad-text">
							좌측 광고 영역<br>
							<span>(예: 160x600)</span>
						</p>
					</div>
				</aside>

				<!-- [수정] 본문 영역 -->
				<div class="tip-detail-main">

					<a href="${pageContext.request.contextPath}/tips"
						class="tip-back-link"><svg
							width="14" height="14" viewBox="0 0 24 24" fill="none"
							stroke="currentColor" stroke-width="2">
							<path d="M15 18l-6-6 6-6" /></svg>목록으로</a>

					<div class="tip-square-card bg-white shadow-sm border border-gray-100 overflow-hidden">
						<div class="relative overflow-hidden" style="height: 280px">
							<c:choose>
							    <c:when test="${not empty tip.thumbnailImg}">
							        <img src="${pageContext.request.contextPath}${tip.thumbnailImg}" alt="${tip.title}"
							            class="absolute inset-0 w-full h-full object-cover">
							    </c:when>
							    <c:otherwise>
							        <div class="absolute inset-0 flex items-center justify-center bg-gray-100 text-gray-400">
							            이미지 없음
							        </div>
							    </c:otherwise>
							</c:choose>
							<div class="absolute inset-0"
								style="background: linear-gradient(to top, rgba(0, 0, 0, .72) 0%, rgba(0, 0, 0, .18) 55%, transparent 100%)"></div>
							<div class="absolute bottom-6 left-7 right-7">
								<h1 class="text-white text-2xl md:text-3xl font-extrabold leading-snug">
									<c:out value="${tip.title}" />
								</h1>
							
								<c:if test="${not empty tip.country || not empty tip.city}">
							
									<div
										class="inline-flex items-center gap-1.5 mt-3 px-3 py-1.5 rounded-full text-sm font-semibold text-white"
										style="background: rgba(0, 0, 0, .45); backdrop-filter: blur(6px);">
							
										<svg
											width="14"
											height="14"
											viewBox="0 0 24 24"
											fill="none"
											stroke="currentColor"
											stroke-width="2">
							
											<path d="M21 10c0 7-9 13-9 13S3 17 3 10a9 9 0 1 1 18 0z" />
											<circle cx="12" cy="10" r="3" />
							
										</svg>
							
										<c:if test="${not empty tip.country}">
											<span>
												<c:out value="${tip.country}" />
											</span>
										</c:if>
							
										<c:if test="${not empty tip.country && not empty tip.city}">
											<span style="opacity: .65;">·</span>
										</c:if>
							
										<c:if test="${not empty tip.city}">
											<span>
												<c:out value="${tip.city}" />
											</span>
										</c:if>
							
									</div>
							
								</c:if>
							
							</div>
						</div>
						<div class="p-7">
							<div
								class="flex items-center justify-between mb-7 pb-6 border-b border-gray-100">
								<div class="flex items-center gap-3">
									<!-- 작성자 프로필 이미지 -->
									<div class="w-10 h-10 rounded-full overflow-hidden flex items-center justify-center text-white font-bold shrink-0"
									     style="background: linear-gradient(135deg, #6369D1, #8B5CF6);">
									
									    <c:choose>
									
									        <%-- 프로필 이미지가 있는 경우 --%>
									        <c:when test="${not empty tip.profileImg}">
									
									            <img
									                src="${pageContext.request.contextPath}/uploads/profile/${tip.profileImg}"
									                alt="작성자 프로필"
									                class="w-full h-full object-cover rounded-full"
									                loading="lazy"
									                onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';"
									            />
									
									            <%-- 이미지 로딩 실패 시 닉네임 첫 글자 --%>
									            <span class="w-full h-full items-center justify-center"
									                  style="display: none;">
									                <c:choose>
									                    <c:when test="${not empty tip.nickname}">
									                        <c:out value="${tip.nickname.substring(0, 1)}"/>
									                    </c:when>
									                    <c:otherwise>U</c:otherwise>
									                </c:choose>
									            </span>
									
									        </c:when>
									
									        <%-- 프로필 이미지가 없는 경우 --%>
									        <c:otherwise>
									            <span>
									                <c:choose>
									                    <c:when test="${not empty tip.nickname}">
									                        <c:out value="${tip.nickname.substring(0, 1)}"/>
									                    </c:when>
									                    <c:otherwise>U</c:otherwise>
									                </c:choose>
									            </span>
									        </c:otherwise>
									
									    </c:choose>
									
									</div>
									<!-- 작성자 정보 -->
								    <div>
								        <p class="text-sm font-semibold text-gray-800">
								            <c:out value="${tip.nickname}" />
								        </p>
								        <p class="text-xs text-gray-400">
								            <c:out value="${tip.timeAgo}" />
								        </p>
								    </div>
								</div>
								
								<div class="flex items-center gap-4 text-sm text-gray-400">
									<button
										type="button"
										id="tipReportButton"
										data-logged-in="${not empty sessionScope.user}"
										data-is-owner="${not empty sessionScope.user and tip.userId eq sessionScope.user.userId}"
										data-login-url="${pageContext.request.contextPath}/auth/login"
										aria-haspopup="dialog"
										aria-controls="tipReportModal"
										class="flex items-center gap-1 px-3 py-2 rounded-xl text-[12px] font-bold border transition-all hover:bg-[#FFE8DE] hover:border-[#FF8A5B] hover:text-[#D95B2B]"
										style="background: #FFF5F0; border-color: #FFB08A; color: #E76F3C;">
									
										<svg
											class="w-3.5 h-3.5"
											fill="none"
											stroke="currentColor"
											viewBox="0 0 24 24">
											<path
												stroke-linecap="round"
												stroke-linejoin="round"
												stroke-width="2"
												d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
										</svg>
									
										신고
									</button>
									<button
										class="flex items-center gap-1.5 hover:text-red-400 transition-colors">
										<svg width="16" height="16" viewBox="0 0 24 24" fill="none"
											stroke="currentColor" stroke-width="2">
											<path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z" /></svg>
										<span class="tip-like-count">
										    ${tip.likeCount}
										</span>
									</button>
									<span class="flex items-center gap-1.5">
									    <svg width="16"
									         height="16"
									         viewBox="0 0 24 24"
									         fill="none"
									         stroke="currentColor"
									         stroke-width="2">
									        <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z" />
									    </svg>
									    <span class="tip-comment-count">
									        ${tipCommentList.size()}
									    </span>
									</span>
								</div>
							</div>
							<div class="prose prose-gray max-w-none" id="tipContentBody">
							    <p class="text-gray-700 text-base leading-relaxed whitespace-pre-wrap" id="tipContentRaw"><c:out value="${tip.content}" /></p>
							</div>
							<!-- 추가 이미지 : 대표 이미지(sortOrder 1)는 제외 -->
							<c:if test="${not empty tipMediaList}">
							    <div class="tip-detail-images" id="tipLegacyImages">
							        <c:forEach var="media" items="${tipMediaList}" varStatus="status">
							            <!-- 첫 번째 이미지(대표 이미지)는 제외 -->
							            <c:if test="${status.index > 0 && media.mediaType eq 'IMAGE'}">
							                <img src="${pageContext.request.contextPath}${media.mediaUrl}" alt="${tip.title}" class="tip-detail-image">
							            </c:if>
							        </c:forEach>
							    </div>
							</c:if>
							<!-- 글 사이사이 사진 : 본문의 [[IMG:n]] 위치에 n번째 이미지를 끼워 넣음 -->
							<div id="tipMediaUrls" hidden>
							    <c:forEach var="media" items="${tipMediaList}">
							        <c:if test="${media.mediaType eq 'IMAGE'}">
							            <span data-url="<c:out value='${pageContext.request.contextPath}${media.mediaUrl}' />"></span>
							        </c:if>
							    </c:forEach>
							</div>
							<script>
							(function () {
							    var raw = document.getElementById("tipContentRaw");
							    var body = document.getElementById("tipContentBody");
							    if (!raw || !body) return;

							    var text = raw.textContent;
							    var pattern = /\[\[IMG:(\d+)\]\]/g;

							    // 마커가 없는 예전 글은 그대로 (기존 방식: 이미지가 아래에 나열)
							    if (!pattern.test(text)) return;
							    pattern.lastIndex = 0;

							    var urls = Array.prototype.map.call(
							        document.querySelectorAll("#tipMediaUrls [data-url]"),
							        function (el) { return el.getAttribute("data-url"); }
							    );

							    var fragment = document.createDocumentFragment();

							    function addText(value) {
							        value = value.replace(/^\n/, "").replace(/\n$/, "");
							        if (value.trim() === "") return;
							        var p = document.createElement("p");
							        p.className = "text-gray-700 text-base leading-relaxed whitespace-pre-wrap";
							        p.textContent = value;
							        fragment.appendChild(p);
							    }

							    var last = 0, match;
							    while ((match = pattern.exec(text)) !== null) {
							        addText(text.slice(last, match.index));
							        var url = urls[parseInt(match[1], 10) - 1];
							        if (url) {
							            var img = document.createElement("img");
							            img.src = url;
							            img.alt = "";
							            img.className = "tip-detail-image";
							            fragment.appendChild(img);
							        }
							        last = pattern.lastIndex;
							    }
							    addText(text.slice(last));

							    body.innerHTML = "";
							    body.classList.add("tip-content-flow");
							    body.appendChild(fragment);

							    // 하단 이미지 목록은 중복이므로 제거
							    var legacy = document.getElementById("tipLegacyImages");
							    if (legacy) legacy.remove();
							})();
							</script>
							<div class="flex flex-wrap gap-2 mt-8 pt-6 border-t border-gray-100">
							    <c:forEach var="tag" items="${tip.hashtagList}">
							        <span class="text-xs font-semibold px-3 py-1 rounded-full"
							            style="background-color: var(--brand-light); color: var(--brand);">
							            <c:choose>
							                <c:when test="${tag.startsWith('#')}">
							                    <c:out value="${tag}" />
							                </c:when>
							                <c:otherwise>
							                    #<c:out value="${tag}" />
							                </c:otherwise>
							            </c:choose>
							        </span>
							    </c:forEach>
							</div>
							<!-- 좋아요 / 게시글 관리 버튼 -->
							<div class="tip-detail-actions">
							    <!-- 좋아요 -->
							    <form action="${pageContext.request.contextPath}/tipLike" method="post" id="tipLikeForm" class="tip-like-form"
							          data-login-url="${pageContext.request.contextPath}/auth/login">
							        <input type="hidden" name="tipId" value="${tip.tipId}">
							        <button type="submit" id="tipLikeBtn" class="tip-like-btn ${liked ? 'active' : ''}">
							            <svg id="tipLikeIcon" class="tip-like-icon" viewBox="0 0 24 24" fill="${liked ? 'currentColor' : 'none'}"
							                 stroke="currentColor" stroke-width="2">
							                <path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z" />
							            </svg>
							            <span id="tipLikeText">
							                좋아요
							                <span class="tip-like-count">${tip.likeCount}</span>
							            </span>
							        </button>
							    </form>
							    <!-- 작성자 본인만 -->
							    <c:if test="${not empty sessionScope.user  && sessionScope.user.userId eq tip.userId}">
							        <a href="${pageContext.request.contextPath}/tipModify?tipId=${tip.tipId}" class="tip-detail-edit-btn">
							            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
							                <path d="M12 20h9" />
							                <path d="M16.5 3.5a2.1 2.1 0 0 1 3 3L7 19l-4 1 1-4Z" />
							            </svg>
							            수정하기
							        </a>
							        <button type="button" class="tip-detail-delete-btn" id="tipDeleteButton" data-tip-id="${tip.tipId}">
							            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
							                <path d="M3 6h18" />
							                <path d="M8 6V4h8v2" />
							                <path d="M19 6l-1 14H6L5 6" />
							            </svg>
							            삭제하기
							        </button>
							    </c:if>
							</div>
						</div>
					</div>
					<!-- 댓글 -->
					<div class="tip-square-card bg-white shadow-sm border border-gray-100 p-7 mt-4">
					    <!-- 댓글 제목 -->
					    <h3 class="flex items-center gap-2 text-base font-extrabold text-gray-900 mb-6">
					        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor"
					            stroke-width="2.2" style="color: var(--brand)">
					            <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z" />
					        </svg>
					        댓글 <span class="tip-comment-count">${tipCommentList.size()}</span>
					    </h3>
					    <!-- 댓글 목록 -->
					    <div class="flex flex-col gap-5 mb-8" id="tipCommentList">
					        <!-- 댓글이 없는 경우 -->
					        <c:if test="${empty tipCommentList}">
					            <div class="py-6 text-center text-sm text-gray-400">
					                아직 작성된 댓글이 없습니다.
					            </div>
					        </c:if>
					        <!-- 실제 DB 댓글 -->
					        <c:forEach var="comment" items="${tipCommentList}">
					            <div class="flex gap-3" data-comment-id="${comment.commentId}">
					                <!-- 프로필 -->
					                <div class="w-9 h-9 rounded-full shrink-0 flex items-center justify-center text-white text-sm font-bold"
					                     style="background-color: var(--brand)">
					                    <c:out value="${comment.nickname.substring(0, 1)}" />
					                </div>
					                <div class="flex-1 min-w-0">
					                    <!-- 작성자 / 작성일 -->
					                    <div class="flex items-center gap-2 mb-1">
					                        <span class="text-sm font-bold text-gray-900">
					                            <c:out value="${comment.nickname}" />
					                        </span>
					                        <span class="tip-comment-time text-xs text-gray-400">
											    ${comment.timeAgo}
											    <c:if test="${comment.edited}">
											        <span class="tip-comment-edited ml-1">(수정됨)</span>
											    </c:if>
											</span>
					                        <!-- 본인 댓글일 때만 수정 / 삭제 -->
					                        <c:if test="${not empty sessionScope.user && sessionScope.user.userId eq comment.userId}">
					                            <div class="flex items-center gap-2 ml-auto">
					                                <button type="button" class="tip-comment-edit text-xs text-gray-400 hover:text-gray-700">
					                                    수정
					                                </button>
					                                <button type="button" class="tip-comment-delete text-xs text-gray-400 hover:text-red-500">
					                                    삭제
					                                </button>
					                            </div>
					                        </c:if>
					                    </div>
					                    <!-- 댓글 내용 -->
					                    <p class="tip-comment-content text-sm text-gray-700 leading-relaxed">
					                        <c:out value="${comment.content}" />
					                    </p>
					                </div>
					            </div>
					        </c:forEach>
					    </div>
					    <!-- 댓글 작성 -->
					    <div class="flex items-center gap-3 pt-5 border-t border-gray-100">
					        <!-- 로그인 상태 -->
					        <c:if test="${not empty sessionScope.user}">
					            <div class="w-9 h-9 rounded-full shrink-0 flex items-center justify-center text-white text-sm font-bold"
					                style="background-color: var(--brand)">
					                <c:out value="${sessionScope.user.nickName.substring(0, 1)}" />
					            </div>
					            <form id="tipCommentForm" action="${pageContext.request.contextPath}/tipCommentWrite"
					                  method="post" class="flex items-center gap-3 flex-1">
					                <input type="hidden" name="tipId" value="${tip.tipId}">
					                <input type="text"
					                       name="content"
					                       id="tipCommentContent"
					                       placeholder="댓글을 입력해주세요..."
					                       autocomplete="off"
					                       class="jsp-focus flex-1 min-w-0 text-sm text-gray-700 placeholder-gray-400 outline-none border border-gray-200 rounded-full px-4 py-2.5 transition-all">
					                <button type="submit"
					                    class="jsp-brand-hover shrink-0 px-5 py-2.5 rounded-full text-white text-sm font-semibold transition-colors"
					                    style="background-color: var(--brand)">
					                    등록
					                </button>
					            </form>
					        </c:if>
					        <!-- 비로그인 상태 -->
					        <c:if test="${empty sessionScope.user}">
					            <div class="w-full text-center text-sm text-gray-400 py-2">
					                댓글을 작성하려면 로그인이 필요합니다.
					            </div>
					        </c:if>
					    </div>
					</div>
				</div>
				<!-- /본문 영역 -->

				<!-- [수정] 우측 광고 (스크롤 따라다님 / sticky) -->
				<aside class="tip-ad-side tip-ad-right" aria-label="우측 광고 영역">
					<div class="tip-ad-box">
						<div class="tip-ad-badge">AD</div>
						<p class="tip-ad-text">
							우측 광고 영역<br>
							<span>(예: 160x600)</span>
						</p>
					</div>
				</aside>

			</div>
		</div>
	</div>
	<jsp:include page="/common/footer.jsp" />
	<div id="tipReportToast" class="tip-report-toast">
		<svg
			width="18"
			height="18"
			viewBox="0 0 24 24"
			fill="none"
			stroke="currentColor"
			stroke-width="2">
			<path
				stroke-linecap="round"
				stroke-linejoin="round"
				d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
		</svg>
	
		<span>본인이 작성한 게시글은 신고할 수 없습니다.</span>
	</div>
	
	<!-- 꿀팁 신고 팝업 -->
	<dialog
		id="tipReportModal"
		class="tip-report-modal"
		aria-labelledby="tipReportTitle"
		aria-describedby="tipReportNotice">
	
		<div class="tip-report-header">
			<div>
				<h2 id="tipReportTitle">신고하기</h2>
				<p id="tipReportNotice">허위신고 시 불이익이 발생할 수 있습니다.</p>
			</div>
	
			<button
				type="button"
				class="tip-report-close"
				data-tip-report-close
				aria-label="신고 팝업 닫기">
	
				<svg
					width="20"
					height="20"
					viewBox="0 0 24 24"
					fill="none"
					stroke="currentColor"
					stroke-width="2"
					aria-hidden="true">
	
					<path d="M6 6l12 12M18 6L6 18" />
				</svg>
			</button>
		</div>
	
		<!-- 신고 입력 화면 -->
		<form
			id="tipReportForm"
			class="tip-report-form"
			action="${pageContext.request.contextPath}/tip/report"
			method="post">
	
			<input
				type="hidden"
				name="tipId"
				value="${tip.tipId}">
	
			<fieldset class="tip-report-reasons">
				<legend>
					신고 사유를 선택해 주세요
					<span class="tip-report-required">*</span>
				</legend>
	
				<c:forEach var="reason" items="${reportReasons}">
					<label class="tip-report-reason">
						<input
							type="radio"
							name="reasonId"
							value="${reason.reasonId}"
							required>
	
						<span>
							<c:out value="${reason.reasonName}" />
						</span>
					</label>
				</c:forEach>
	
				<c:if test="${empty reportReasons}">
					<p class="tip-report-empty">등록된 신고 사유가 없습니다.</p>
				</c:if>
			</fieldset>
	
			<div class="tip-report-detail">
				<label for="tipReportDetail">
					상세 내용
					<span>(선택)</span>
				</label>
	
				<textarea
					id="tipReportDetail"
					name="detail"
					rows="4"
					aria-describedby="tipReportLength"
					placeholder="신고 사유에 대해 자세히 설명해 주세요."></textarea>
	
				<p class="tip-report-counter">
					<span id="tipReportLength">0</span>/300
				</p>
			</div>
	
			<p
				id="tipReportError"
				class="tip-report-error"
				role="alert"
				hidden></p>
	
			<div class="tip-report-actions">
				<button
					type="button"
					class="tip-report-cancel"
					data-tip-report-close>
					취소
				</button>
	
				<button
					type="submit"
					id="tipReportSubmit"
					class="tip-report-submit"
					disabled>
					신고하기
				</button>
			</div>
		</form>
	
		<!-- 접수 성공 화면 -->
		<div
			id="tipReportSuccess"
			class="tip-report-success"
			role="status"
			hidden>
	
			<div class="tip-report-success-icon">
				<svg
					width="32"
					height="32"
					viewBox="0 0 24 24"
					fill="none"
					stroke="currentColor"
					stroke-width="2.5"
					aria-hidden="true">
	
					<path
						stroke-linecap="round"
						stroke-linejoin="round"
						d="M5 12l4 4L19 6" />
				</svg>
			</div>
	
			<h3>신고가 접수되었습니다</h3>
	
			<p>
				검토 후 적절한 조치를 취하겠습니다.
				<br>
				신고해 주셔서 감사합니다.
			</p>
	
			<button
				type="button"
				class="tip-report-confirm"
				data-tip-report-close>
				확인
			</button>
		</div>
	</dialog>
</body>
</html>
