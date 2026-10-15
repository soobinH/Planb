<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<%
request.setAttribute("activePage", "mate");
%>

<!DOCTYPE html>
<html lang="ko">

<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">

	<title>내가 작성한 글 | Tripily</title>

	<jsp:include page="/common/headStyles.jsp" />

	<link
	rel="stylesheet"
	href="${pageContext.request.contextPath}/view/assets/css/mates/mateWriteList.css?v=20261014-2">

	<script
		defer
		src="${pageContext.request.contextPath}/view/assets/js/mates/mateWriteList.js">
	</script>
</head>

<body class="site-shell">

	<jsp:include page="/common/header.jsp" />


	<!-- ================================
	     상단 배너
	================================ -->
	<section class="mate-my-banner">

		<div class="mate-my-banner-inner">

			<div class="mate-my-banner-text">

				<p class="mate-my-breadcrumb">
					여행 메이트
					<span>›</span>
					내가 작성한 글
				</p>

				<h1>내가 작성한 글</h1>

				<p class="mate-my-description">
					총 <strong>${totalCount}</strong>개의 여행 메이트 모집글을 작성했습니다.
				</p>

			</div>


			<div class="mate-my-banner-actions">

				<!-- 여행 메이트 목록 -->
				<a
					href="${pageContext.request.contextPath}/mates"
					class="mate-list-btn">

					<svg
						viewBox="0 0 24 24"
						fill="none"
						stroke="currentColor">

						<path
							stroke-linecap="round"
							stroke-linejoin="round"
							stroke-width="2"
							d="M4 6h16M4 12h16M4 18h16" />
					</svg>

					여행 메이트 목록
				</a>


				<!-- 새 글 작성 -->
				<a
					href="${pageContext.request.contextPath}/mateWrite"
					class="mate-write-btn">

					<svg
						viewBox="0 0 24 24"
						fill="none"
						stroke="currentColor">

						<path
							stroke-linecap="round"
							stroke-linejoin="round"
							stroke-width="2"
							d="M12 4v16m8-8H4" />
					</svg>

					새 글 쓰기
				</a>

			</div>

		</div>

	</section>


	<!-- ================================
	     내가 작성한 글 목록
	================================ -->
	<main class="mate-my-main">

		<div class="mate-my-list">


			<!-- ================================
			     작성 글 없음
			================================ -->
			<c:if test="${empty mateList}">

				<div class="mate-my-empty">

					<div class="mate-my-empty-icon">
						✈️
					</div>

					<h2>
						아직 작성한 여행 메이트 모집글이 없습니다.
					</h2>

					<p>
						함께 여행할 메이트를 모집해보세요.
					</p>

					<a href="${pageContext.request.contextPath}/mateWrite">
						첫 여행 메이트 모집하기
					</a>

				</div>

			</c:if>


			<!-- ================================
			     작성 글 목록
			================================ -->
			<c:forEach var="mate" items="${mateList}">

				<article
					class="mate-my-card"
					onclick="location.href='${pageContext.request.contextPath}/mateDetail?mateId=${mate.mateId}'"
					style="cursor: pointer;">


					<div class="mate-my-card-content">


						<!-- 국가 / 모집 상태 -->
						<div class="mate-my-tags">

							<c:if test="${not empty mate.country}">
								<span>
									📍 ${mate.country}
								</span>
							</c:if>


							<c:choose>

								<c:when test="${mate.recruitStatus == 'OPEN'}">
									<span class="mate-recruit-open">
										모집중
									</span>
								</c:when>

								<c:otherwise>
									<span class="mate-recruit-closed">
										모집완료
									</span>
								</c:otherwise>

							</c:choose>

						</div>


						<!-- 제목 -->
						<h2 class="mate-my-title">
							${mate.title}
						</h2>
						<!-- 게시글 정보 -->
						<div class="mate-my-meta">
						
							<!-- 모집 인원 -->
							<span class="mate-my-recruit-count">
								👥 ${mate.recruitCount}명 모집
							</span>
						
							<!-- 좋아요 -->
							<span class="mate-my-meta-item">
						
								<svg
									viewBox="0 0 24 24"
									fill="none"
									stroke="currentColor"
									stroke-width="2">
						
									<path
										stroke-linecap="round"
										stroke-linejoin="round"
										d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78L12 21.23l8.84-8.84a5.5 5.5 0 0 0 0-7.78z" />
						
								</svg>
						
								${mate.likeCount}
						
							</span>
						
							<!-- 댓글 -->
							<span class="mate-my-meta-item">
						
								<svg
									viewBox="0 0 24 24"
									fill="none"
									stroke="currentColor"
									stroke-width="2">
						
									<path
										stroke-linecap="round"
										stroke-linejoin="round"
										d="M21 15a4 4 0 0 1-4 4H8l-5 3V7a4 4 0 0 1 4-4h10a4 4 0 0 1 4 4z" />
						
								</svg>
						
								${mate.commentCount}
						
							</span>
						
							<!-- 조회수 -->
							<span class="mate-my-meta-item">
						
								<svg
									viewBox="0 0 24 24"
									fill="none"
									stroke="currentColor"
									stroke-width="2">
						
									<path
										stroke-linecap="round"
										stroke-linejoin="round"
										d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7S2 12 2 12z" />
						
									<circle
										cx="12"
										cy="12"
										r="3" />
						
								</svg>
						
								${mate.viewCount}
						
							</span>
						
						</div>

					</div>


					<!-- ================================
					     수정 / 삭제 버튼
					================================ -->
					<div
						class="mate-my-card-actions"
						onclick="event.stopPropagation();">


						<a
							href="${pageContext.request.contextPath}/mateModify?mateId=${mate.mateId}"
							class="mate-edit-btn">

							<svg
								xmlns="http://www.w3.org/2000/svg"
								width="16"
								height="16"
								viewBox="0 0 24 24"
								fill="none"
								stroke="currentColor"
								stroke-width="2"
								stroke-linecap="round"
								stroke-linejoin="round">

								<path d="M12 20h9" />

								<path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4Z" />

							</svg>

							수정하기

						</a>


						<button
							type="button"
							class="mate-write-list-delete-btn"
							data-mate-id="${mate.mateId}">

							삭제

						</button>

					</div>

				</article>

			</c:forEach>


			<!-- ================================
			     페이지네이션
			================================ -->
			<c:if test="${totalPages > 0}">

				<nav
					class="mate-write-pagination"
					aria-label="페이지 이동">


					<!-- 이전 -->
					<c:choose>

						<c:when test="${page > 1}">

							<a
								href="${pageContext.request.contextPath}/mateWriteList?page=${page - 1}"
								class="mate-page-btn mate-page-arrow"
								aria-label="이전 페이지">

								‹

							</a>

						</c:when>

						<c:otherwise>

							<span class="mate-page-btn mate-page-arrow disabled">
								‹
							</span>

						</c:otherwise>

					</c:choose>


					<!-- 페이지 번호 -->
					<c:forEach
						var="pageNum"
						begin="1"
						end="${totalPages}">

						<c:choose>

							<c:when test="${pageNum == page}">

								<span class="mate-page-btn active">
									${pageNum}
								</span>

							</c:when>

							<c:otherwise>

								<a
									href="${pageContext.request.contextPath}/mateWriteList?page=${pageNum}"
									class="mate-page-btn">

									${pageNum}

								</a>

							</c:otherwise>

						</c:choose>

					</c:forEach>


					<!-- 다음 -->
					<c:choose>

						<c:when test="${page < totalPages}">

							<a
								href="${pageContext.request.contextPath}/mateWriteList?page=${page + 1}"
								class="mate-page-btn mate-page-arrow"
								aria-label="다음 페이지">

								›

							</a>

						</c:when>

						<c:otherwise>

							<span class="mate-page-btn mate-page-arrow disabled">
								›
							</span>

						</c:otherwise>

					</c:choose>

				</nav>

			</c:if>

		</div>

	</main>


	<jsp:include page="/common/footer.jsp" />

</body>
</html>