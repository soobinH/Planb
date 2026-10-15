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
	<title>여행꿀팁 수정 · Planb</title>
	<jsp:include page="/common/headStyles.jsp" />
	<link rel="stylesheet" href="${pageContext.request.contextPath}/view/assets/css/community/postWrite.css?v=3">
	<script defer src="${pageContext.request.contextPath}/view/assets/js/community/postEditor.js?v=1"></script>
	<script defer src="${pageContext.request.contextPath}/view/assets/js/tips/tipModify.js?v=2"></script>
</head>
<body class="site-shell">
	<jsp:include page="/common/header.jsp" />

	<main class="post-page">

		<!-- 상단 배너 -->
		<section class="post-hero">
			<div class="post-hero-bg" style="background-image: url('https://images.unsplash.com/photo-1488646953014-85cb44e25828?auto=format&fit=crop&w=1800&q=80')"></div>
			<div class="post-hero-overlay"></div>

			<div class="post-hero-inner">
				<a class="post-hero-back" href="${pageContext.request.contextPath}/tipDetail?tipId=${tip.tipId}">
					<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m15 18-6-6 6-6"/></svg>
					게시글로 돌아가기
				</a>
				<span class="post-hero-badge"><i></i>Edit Travel Tip</span>
				<h1>여행꿀팁 <em>수정하기</em></h1>
				<p>내용과 사진을 다듬어 더 도움이 되는 꿀팁으로 만들어보세요.</p>
			</div>
		</section>

		<form class="post-form" action="${pageContext.request.contextPath}/tipModify" method="post" enctype="multipart/form-data">

			<input type="hidden" name="tipId" value="${tip.tipId}">

			<div class="post-sheet">

				<!-- 글 정보 -->
				<div class="post-meta">
					<div class="post-meta-row">
						<span class="post-meta-label">여행지<span class="post-required">*</span></span>
						<div>
							<div class="post-grid-2">
								<div>
									<input type="text" id="countryInput" value="<c:out value='${tip.country}' />" autocomplete="off"
										placeholder="나라 (예: 일본, 베트남)" class="post-input" aria-label="나라">
									<input type="hidden" id="country" name="country" value="<c:out value='${tip.country}' />">
									<div id="countrySuggestions" class="post-chips"></div>
									<p id="countryError" class="post-error hidden">나라를 입력한 후 아래 목록에서 선택해주세요.</p>
								</div>
								<div>
									<input type="text" id="cityInput" value="<c:out value='${tip.city}' />" autocomplete="off"
										placeholder="도시 (예: 도쿄, 다낭)" class="post-input" aria-label="도시">
									<input type="hidden" id="city" name="city" value="<c:out value='${tip.city}' />">
									<div id="citySuggestions" class="post-chips"></div>
									<p id="cityError" class="post-error hidden">도시를 입력한 후 아래 목록에서 선택해주세요.</p>
								</div>
							</div>
							<p class="post-help">나라를 변경하면 도시도 다시 선택해주세요.</p>
						</div>
					</div>
					<div class="post-meta-row">
						<label class="post-meta-label" for="tipHashtag">해시태그<span class="optional">선택</span></label>
						<input type="text" id="tipHashtag" name="hashtag" value="<c:out value='${tip.hashtag}' />"
							class="post-input" placeholder="#교통 #맛집 #혼자여행">
					</div>
				</div>

				<!-- 제목 -->
				<div class="post-title post-field">
					<input type="text" id="tipTitle" name="title" maxlength="100" data-char-input
						class="post-title-input" placeholder="제목을 입력하세요" aria-label="제목"
						value="<c:out value='${tip.title}' />" required>
					<span class="post-counter"><span data-char-count>0</span>/100</span>
				</div>

				<!-- 툴바 -->
				<div class="post-editor-toolbar">
					<button type="button" id="postImageButton" class="post-editor-photo-btn">
						<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/><path d="m21 15-5-5L5 21"/></svg>
						사진
					</button>
					<span class="post-editor-tip">커서 위치에 사진이 들어가요 · 끌어다 놓아도 돼요</span>
					<span class="post-editor-count">사진 <span id="postImageCount">0/5</span></span>
				</div>

				<!-- 본문 -->
				<div id="postEditor"
					class="post-editor is-empty"
					contenteditable="true"
					role="textbox"
					aria-multiline="true"
					aria-label="내용"
					data-placeholder="여행에서 직접 경험한 소중한 팁을 자유롭게 적어주세요."></div>

				<!-- 기존 본문 / 기존 사진 (편집기 초기 내용) -->
				<textarea id="postContentSource" hidden><c:out value="${tip.content}" /></textarea>
				<div id="existingMediaData" hidden>
					<c:forEach var="media" items="${tipMediaList}">
						<c:if test="${media.mediaType eq 'IMAGE'}">
							<span data-media-id="${media.mediaId}"
								data-url="<c:out value='${pageContext.request.contextPath}${media.mediaUrl}' />"></span>
						</c:if>
					</c:forEach>
				</div>
				<div id="deletedMediaInputs"></div>

				<input type="hidden" name="content" id="postContent">
				<input type="file" id="postImages" name="images" multiple accept="image/*" hidden>

				<div class="post-sheet-foot">
					<p id="postContentError" class="post-error" hidden>내용을 입력해주세요.</p>
					<p class="post-help">기존 사진과 새 사진을 합쳐 최대 5장까지 넣을 수 있고, 글 맨 위 사진이 대표 이미지가 돼요. 사진의 × 버튼으로 삭제할 수 있어요.</p>
				</div>
			</div>

			<!-- 하단 발행 바 -->
			<div class="post-actions">
				<a href="${pageContext.request.contextPath}/tipDetail?tipId=${tip.tipId}" class="post-btn post-btn--ghost">취소</a>
				<button type="submit" class="post-btn post-btn--primary">수정하기</button>
			</div>
		</form>
		<div class="post-page-end"></div>
	</main>

	<jsp:include page="/common/footer.jsp" />
</body>
</html>
