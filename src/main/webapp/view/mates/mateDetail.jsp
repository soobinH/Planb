<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<% request.setAttribute("activePage", "mates"); %>
<!DOCTYPE html>
<html lang="ko">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<title>여행 메이트 상세 | Planb</title>
	<jsp:include page="/common/headStyles.jsp" />
	<!-- 여행꿀팁 상세와 같은 화면 구성 : tipDetail.css 를 그대로 사용 -->
	<link rel="stylesheet" href="${pageContext.request.contextPath}/view/assets/css/tips/tipDetail.css?v=20261016-profile">
	<!-- 메이트에만 있는 요소 (모집 상태 / 모집 정보) -->
	<link rel="stylesheet" href="${pageContext.request.contextPath}/view/assets/css/mates/mateDetail.css?v=3">
	<script defer src="${pageContext.request.contextPath}/view/assets/js/mates/mateDetail.js"></script>

<script
    defer
    data-context-path="${pageContext.request.contextPath}"
    src="${pageContext.request.contextPath}/view/assets/js/common/listReturn.js?v=1">
</script>
</head>
<body class="site-shell">
	<jsp:include page="/common/header.jsp" />

	<div class="tip-detail-page">
		<div class="tip-detail-wrap">
			<div class="tip-detail-layout">

				<!-- 좌측 광고 (스크롤 따라다님 / sticky) -->
				<aside class="tip-ad-side tip-ad-left" aria-label="좌측 광고 영역">
					<div class="tip-ad-box">
						<div class="tip-ad-badge">AD</div>
						<p class="tip-ad-text">
							좌측 광고 영역<br>
							<span>(예: 160x600)</span>
						</p>
					</div>
				</aside>

				<!-- 본문 영역 -->
				<div class="tip-detail-main">
					<a data-list-back href="${pageContext.request.contextPath}/mates" class="tip-back-link"><svg
							width="14" height="14" viewBox="0 0 24 24" fill="none"
							stroke="currentColor" stroke-width="2">
							<path d="M15 18l-6-6 6-6" /></svg>목록으로</a>

					<div class="tip-square-card bg-white shadow-sm border border-gray-100 overflow-hidden">

						<!-- 대표 이미지 + 제목 -->
						<div class="relative overflow-hidden" style="height: 280px">
							<c:choose>
								<c:when test="${not empty mate.img}">
									<img src="${pageContext.request.contextPath}${mate.img}" alt="<c:out value='${mate.title}' />"
										class="absolute inset-0 w-full h-full object-cover">
								</c:when>
								<c:otherwise>
									<img src="${pageContext.request.contextPath}/view/assets/images/default/mate-default.svg" alt="여행 메이트 기본 이미지"
										class="absolute inset-0 w-full h-full object-cover" style="object-position: center 40%">
								</c:otherwise>
							</c:choose>
							<div class="absolute inset-0"
								style="background: linear-gradient(to top, rgba(0, 0, 0, .72) 0%, rgba(0, 0, 0, .18) 55%, transparent 100%)"></div>
							<div class="absolute bottom-6 left-7 right-7">
								<h1 class="text-white text-2xl md:text-3xl font-extrabold leading-snug">
									<c:out value="${mate.title}" />
								</h1>
								<div class="flex flex-wrap items-center gap-2 mt-3">
									<c:if test="${not empty mate.country}">
										<div
											class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full text-sm font-semibold text-white"
											style="background: rgba(0, 0, 0, .45); backdrop-filter: blur(6px);">
											<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
												<path d="M21 10c0 7-9 13-9 13S3 17 3 10a9 9 0 1 1 18 0z" />
												<circle cx="12" cy="10" r="3" />
											</svg>
											<span><c:out value="${mate.country}" /></span>
										</div>
									</c:if>
									<span class="mate-hero-recruit ${mate.recruitStatus eq 'OPEN' ? 'open' : 'closed'}">
										${mate.recruitStatus eq 'OPEN' ? '모집중' : '모집완료'}
									</span>
								</div>
							</div>
						</div>

						<div class="p-7">

							<!-- 작성자 / 신고 / 좋아요 수 / 댓글 수 -->
							<div class="flex items-center justify-between mb-7 pb-6 border-b border-gray-100">
								<div class="flex items-center gap-3">
									<a href="${pageContext.request.contextPath}/profile/userProfile?userId=${mate.userId}" class="w-10 h-10 rounded-full overflow-hidden flex items-center justify-center text-white font-bold shrink-0"
										style="background: linear-gradient(135deg, #6369D1, #8B5CF6);"><jsp:include page="/common/profileImage.jsp"><jsp:param name="image" value="${mate.profileImg}"/><jsp:param name="nickname" value="${mate.nickname}"/></jsp:include></a>
									<div>
										<p class="text-sm font-semibold text-gray-800"><a href="${pageContext.request.contextPath}/profile/userProfile?userId=${mate.userId}">
											<c:out value="${mate.nickname}" default="사용자" />
										</a></p>
										<p class="text-xs text-gray-400">
											<c:out value="${mate.timeAgo}" />
										</p>
									</div>
								</div>

								<div class="flex items-center gap-4 text-sm text-gray-400">
									<button
										type="button"
										id="mateReportButton"
										data-logged-in="${not empty sessionScope.user}"
										data-is-owner="${not empty sessionScope.user and mate.userId eq sessionScope.user.userId}"
										data-login-url="${pageContext.request.contextPath}/auth/login"
										aria-haspopup="dialog"
										aria-controls="mateReportModal"
										class="tip-detail-report-button">
										<svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M5 21V3M5 4h14l-3 5 3 5H5"/></svg>
										신고
									</button>
									<span class="flex items-center gap-1.5">
										<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
											<path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z" /></svg>
										<span data-mate-like-mirror><c:out value="${mateLikeCount}" /></span>
									</span>
									<span class="flex items-center gap-1.5">
										<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
											<path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z" />
										</svg>
										<span class="mate-comment-count"><c:out value="${mateCommentCount}" /></span>
									</span>
								</div>
							</div>

							<!-- 모집 정보 (메이트 전용) -->
							<dl class="mate-detail-meta">
								<div>
									<dt>여행지</dt>
									<dd><c:out value="${empty mate.country ? '-' : mate.country}" /></dd>
								</div>
								<div>
									<dt>모집 인원</dt>
									<dd><c:out value="${mate.recruitCount}" />명</dd>
								</div>
								<div>
									<dt>작성일</dt>
									<dd><c:out value="${mate.formattedCreatedAt}" /></dd>
								</div>
								<div>
									<dt>조회수</dt>
									<dd><c:out value="${mate.viewCount}" /></dd>
								</div>
							</dl>

							<!-- 본문 -->
							<div class="prose prose-gray max-w-none" id="mateContentBody">
								<p class="text-gray-700 text-base leading-relaxed whitespace-pre-wrap" id="mateContentRaw"><c:out value="${mate.content}" /></p>
							</div>

							<!-- 추가 이미지 : 대표 이미지(첫 번째)는 제외 (예전 글 : 본문에 사진 위치 표시가 없는 경우) -->
							<c:if test="${not empty mateMediaList}">
								<div class="tip-detail-images" id="mateLegacyImages">
									<c:forEach var="media" items="${mateMediaList}" varStatus="status">
										<c:if test="${status.index > 0 && media.mediaType eq 'IMAGE'}">
											<img src="${pageContext.request.contextPath}${media.mediaUrl}" alt="<c:out value='${mate.title}' />" class="tip-detail-image">
										</c:if>
									</c:forEach>
								</div>
							</c:if>

							<!-- 글 사이사이 사진 : 본문의 [[IMG:n]] 위치에 n번째 이미지를 끼워 넣음 -->
							<div id="mateMediaUrls" hidden>
								<c:forEach var="media" items="${mateMediaList}">
									<c:if test="${media.mediaType eq 'IMAGE'}">
										<span data-url="<c:out value='${pageContext.request.contextPath}${media.mediaUrl}' />"></span>
									</c:if>
								</c:forEach>
							</div>
							<script>
							(function () {
								var raw = document.getElementById("mateContentRaw");
								var body = document.getElementById("mateContentBody");
								if (!raw || !body) return;
								var text = raw.textContent;
								var pattern = /\[\[IMG:(\d+)\]\]/g;
								// 표시가 없는 예전 글은 그대로 (이미지는 아래에 나열)
								if (!pattern.test(text)) return;
								pattern.lastIndex = 0;
								var urls = Array.prototype.map.call(
									document.querySelectorAll("#mateMediaUrls [data-url]"),
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
								var legacy = document.getElementById("mateLegacyImages");
								if (legacy) legacy.remove();
							})();
							</script>

							<!-- 좋아요 / 모집 상태 / 게시글 관리 -->
							<div class="tip-detail-actions">

								<c:choose>
									<c:when test="${not empty sessionScope.user}">
										<form id="mateLikeForm" class="tip-like-form" onsubmit="return false;">
											<input type="hidden" id="mateLikeMateId" name="mateId" value="${mate.mateId}">
											<button type="button" id="mateLikeButton" class="tip-like-btn ${liked ? 'active' : ''}">
												<svg class="tip-like-icon mate-like-icon" viewBox="0 0 24 24" fill="${liked ? 'currentColor' : 'none'}"
													stroke="currentColor" stroke-width="2">
													<path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z" />
												</svg>
												<span>
													좋아요
													<span id="mateLikeCount"><c:out value="${mateLikeCount}" /></span>
												</span>
											</button>
										</form>
									</c:when>
									<c:otherwise>
										<a href="${pageContext.request.contextPath}/auth/login" class="tip-like-btn">
											<svg class="tip-like-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
												<path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z" />
											</svg>
											<span>좋아요 <c:out value="${mateLikeCount}" /></span>
										</a>
									</c:otherwise>
								</c:choose>

								<!-- 모집 상태 : 작성자는 눌러서 변경 -->
								<c:choose>
									<c:when test="${not empty sessionScope.user && sessionScope.user.userId eq mate.userId}">
										<button
											type="button"
											id="mateRecruitStatusButton"
											class="mate-recruit-badge ${mate.recruitStatus eq 'OPEN' ? 'open' : 'closed'}"
											data-mate-id="${mate.mateId}"
											data-recruit-status="${mate.recruitStatus}"
											title="눌러서 모집 상태 변경">${mate.recruitStatus eq 'OPEN' ? '모집중' : '모집완료'}</button>
									</c:when>
									<c:otherwise>
										<span class="mate-recruit-badge ${mate.recruitStatus eq 'OPEN' ? 'open' : 'closed'}">${mate.recruitStatus eq 'OPEN' ? '모집중' : '모집완료'}</span>
									</c:otherwise>
								</c:choose>

								<!-- 작성자 본인만 -->
								<c:if test="${not empty sessionScope.user && sessionScope.user.userId eq mate.userId}">
									<a href="${pageContext.request.contextPath}/mateModify?mateId=${mate.mateId}" class="tip-detail-edit-btn">
										<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
											<path d="M12 20h9" />
											<path d="M16.5 3.5a2.1 2.1 0 0 1 3 3L7 19l-4 1 1-4Z" />
										</svg>
										수정하기
									</a>
									<button type="button" class="tip-detail-delete-btn" id="mateDeleteButton" data-mate-id="${mate.mateId}">
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
						<h3 class="flex items-center gap-2 text-base font-extrabold text-gray-900 mb-6">
							<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor"
								stroke-width="2.2" style="color: var(--brand)">
								<path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z" />
							</svg>
							댓글 <span class="mate-comment-count" id="mateCommentCount"><c:out value="${mateCommentCount}" /></span>
						</h3>

						<div class="flex flex-col gap-5 mb-8" id="mateCommentList">
							<c:if test="${empty mateCommentList}">
								<div class="py-6 text-center text-sm text-gray-400">
									아직 작성된 댓글이 없습니다.
								</div>
							</c:if>

							<c:forEach var="comment" items="${mateCommentList}">
								<div class="flex gap-3" data-comment-id="${comment.commentId}">
									<a href="${pageContext.request.contextPath}/profile/userProfile?userId=${comment.userId}" class="w-9 h-9 rounded-full overflow-hidden shrink-0 flex items-center justify-center text-white text-sm font-bold"
										style="background-color: var(--brand)"><jsp:include page="/common/profileImage.jsp"><jsp:param name="image" value="${comment.profileImg}"/><jsp:param name="nickname" value="${comment.nickname}"/></jsp:include></a>
									<div class="flex-1 min-w-0">
										<div class="flex items-center gap-2 mb-1">
											<a href="${pageContext.request.contextPath}/profile/userProfile?userId=${comment.userId}" class="text-sm font-bold text-gray-900">
												<c:out value="${comment.nickname}" />
											</a>
											<span class="mate-comment-time text-xs text-gray-400">
												${comment.timeAgo}
												<c:if test="${comment.edited}">
													<span class="mate-comment-edited ml-1">(수정됨)</span>
												</c:if>
											</span>
											<c:if test="${not empty sessionScope.user && sessionScope.user.userId eq comment.userId}">
												<div class="flex items-center gap-2 ml-auto">
													<button type="button" class="mate-comment-edit text-xs text-gray-400 hover:text-gray-700">
														수정
													</button>
													<button type="button" class="mate-comment-delete text-xs text-gray-400 hover:text-red-500">
														삭제
													</button>
												</div>
											</c:if>
										</div>
										<p class="mate-comment-content text-sm text-gray-700 leading-relaxed">
											<c:out value="${comment.content}" />
										</p>
									</div>
								</div>
							</c:forEach>
						</div>

						<div class="flex items-center gap-3 pt-5 border-t border-gray-100">
							<c:if test="${not empty sessionScope.user}">
								<div class="w-9 h-9 rounded-full overflow-hidden shrink-0 flex items-center justify-center text-white text-sm font-bold"
									style="background-color: var(--brand)">
									<jsp:include page="/common/profileImage.jsp">
                                        <jsp:param name="image" value="${sessionScope.user.profileImg}"/>
                                    </jsp:include>
								</div>
								<form id="mateCommentForm" action="${pageContext.request.contextPath}/mateCommentWrite"
									method="post" class="flex items-center gap-3 flex-1">
									<input type="hidden" name="mateId" value="${mate.mateId}">
									<input type="text"
										name="content"
										id="mateCommentContent"
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
							<c:if test="${empty sessionScope.user}">
								<div class="w-full text-center text-sm text-gray-400 py-2">
									댓글을 작성하려면 로그인이 필요합니다.
								</div>
							</c:if>
						</div>
					</div>
				</div>
				<!-- /본문 영역 -->

				<!-- 우측 광고 (스크롤 따라다님 / sticky) -->
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

	<!-- 본인 글 신고 안내 -->
	<div id="mateReportToast" class="tip-report-toast">
		<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
			<path stroke-linecap="round" stroke-linejoin="round"
				d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
		</svg>
		<span>본인이 작성한 게시글은 신고할 수 없습니다.</span>
	</div>

	<!-- 메이트 신고 팝업 (여행꿀팁 신고 팝업과 같은 모양) -->
	<dialog
		id="mateReportModal"
		class="tip-report-modal"
		aria-labelledby="mateReportTitle"
		aria-describedby="mateReportNotice">

		<div id="mateReportFormView">
			<div class="tip-report-header">
				<div>
					<h2 id="mateReportTitle">신고하기</h2>
					<p id="mateReportNotice">허위신고 시 불이익이 발생할 수 있습니다.</p>
				</div>
				<button type="button" class="tip-report-close" data-mate-report-close aria-label="신고 팝업 닫기">
					<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
						<path d="M6 6l12 12M18 6L6 18" />
					</svg>
				</button>
			</div>

			<form id="mateReportForm" class="tip-report-form" action="${pageContext.request.contextPath}/mate/report" method="post">
				<input type="hidden" name="mateId" value="${mate.mateId}">

				<fieldset class="tip-report-reasons">
					<legend>
						신고 사유를 선택해 주세요
						<span class="tip-report-required">*</span>
					</legend>
					<c:forEach var="reason" items="${reportReasons}">
						<label class="tip-report-reason">
							<input type="radio" name="reasonId" value="${reason.reasonId}" required>
							<span><c:out value="${reason.reasonName}" /></span>
						</label>
					</c:forEach>
					<c:if test="${empty reportReasons}">
						<p class="tip-report-empty">등록된 신고 사유가 없습니다.</p>
					</c:if>
				</fieldset>

				<div class="tip-report-detail">
					<label for="mateReportDetail">
						상세 내용
						<span>(선택)</span>
					</label>
					<textarea id="mateReportDetail" name="detail" rows="4" maxlength="300"
						placeholder="신고 사유에 대해 자세히 설명해 주세요."></textarea>
					<p class="tip-report-counter"><span id="mateReportDetailCount">0 / 300</span></p>
				</div>

				<p id="mateReportError" class="tip-report-error" role="alert" hidden></p>

				<div class="tip-report-actions">
					<button type="button" class="tip-report-cancel" data-mate-report-close>취소</button>
					<button type="submit" id="mateReportSubmit" class="tip-report-submit" disabled>신고하기</button>
				</div>
			</form>
		</div>

		<!-- 접수 성공 화면 -->
		<div id="mateReportSuccessView" class="tip-report-success" role="status" hidden>
			<div class="tip-report-success-icon">
				<svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" aria-hidden="true">
					<path stroke-linecap="round" stroke-linejoin="round" d="M5 12l4 4L19 6" />
				</svg>
			</div>
			<h3>신고가 접수되었습니다</h3>
			<p>
				검토 후 적절한 조치를 취하겠습니다.
				<br>
				신고해 주셔서 감사합니다.
			</p>
			<button type="button" class="tip-report-confirm" data-mate-report-close>확인</button>
		</div>
	</dialog>

	<script>
	/* 작성자 줄의 좋아요 수를 좋아요 버튼 숫자와 함께 갱신 */
	(function () {
		var source = document.getElementById("mateLikeCount");
		var mirror = document.querySelector("[data-mate-like-mirror]");
		if (!source || !mirror) return;
		new MutationObserver(function () {
			mirror.textContent = source.textContent.trim();
		}).observe(source, { childList: true, characterData: true, subtree: true });
	})();

	/* 작성자가 모집 상태를 바꾸면 대표 이미지 위 배지도 함께 갱신 */
	(function () {
		var button = document.getElementById("mateRecruitStatusButton");
		var heroBadge = document.querySelector(".mate-hero-recruit");
		if (!button || !heroBadge) return;
		new MutationObserver(function () {
			var open = button.dataset.recruitStatus === "OPEN";
			heroBadge.textContent = open ? "모집중" : "모집완료";
			heroBadge.classList.toggle("open", open);
			heroBadge.classList.toggle("closed", !open);
		}).observe(button, { attributes: true, attributeFilter: ["data-recruit-status"] });
	})();
	</script>
</body>
</html>
