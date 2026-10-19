<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>

<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%
request.setAttribute("activePage", "home");
%>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Planb</title>
<jsp:include page="/common/headStyles.jsp" />
<link rel="stylesheet" href="${ctx}/view/assets/css/auth/home.css?v=20261019-ads">
<script defer src="${ctx}/view/assets/js/auth/home.js?v=4"></script>
</head>
<body class="site-shell ph-page">
	<jsp:include page="/common/header.jsp" />

	<!-- ========================================
	     HOME - 섹션 네비게이션 (우측 점)
	========================================= -->
	<nav class="ph-dots" aria-label="홈 구역 이동">
		<button type="button" class="ph-dot is-active" data-dot="0" aria-label="메인"><span>Main</span></button>
		<button type="button" class="ph-dot" data-dot="1" aria-label="인기 여행일정"><span>Popular</span></button>
		<button type="button" class="ph-dot" data-dot="2" aria-label="일정 만들기"><span>Create</span></button>
		<button type="button" class="ph-dot" data-dot="3" aria-label="여행꿀팁 · 여행 메이트"><span>Community</span></button>
	</nav>

	<main class="ph-main">

		<!-- ========================================
		     HOME - 1번 구역 : 메인 배너 (배경 슬라이드)
		========================================= -->
		<section id="homeArea1" class="ph-section ph-hero" data-ph-section data-theme="dark">

			<div class="ph-hero-slides" aria-hidden="true">
				<div class="ph-hero-slide is-active" data-place="Santorini" data-country="Greece"
					style="background-image: url('https://images.unsplash.com/photo-1570077188670-e3a8d69ac5ff?auto=format&fit=crop&w=2000&q=80')"></div>
				<div class="ph-hero-slide" data-place="Kyoto" data-country="Japan"
					style="background-image: url('https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?auto=format&fit=crop&w=2000&q=80')"></div>
				<div class="ph-hero-slide" data-place="Paris" data-country="France"
					style="background-image: url('https://images.unsplash.com/photo-1502602898657-3e91760cbb34?auto=format&fit=crop&w=2000&q=80')"></div>
				<div class="ph-hero-slide" data-place="Bali" data-country="Indonesia"
					style="background-image: url('https://images.unsplash.com/photo-1537996194471-e657df975ab4?auto=format&fit=crop&w=2000&q=80')"></div>
				<div class="ph-hero-slide" data-place="Swiss Alps" data-country="Switzerland"
					style="background-image: url('https://images.unsplash.com/photo-1506905925346-21bda4d32df4?auto=format&fit=crop&w=2000&q=80')"></div>
			</div>
			<div class="ph-hero-overlay" aria-hidden="true"></div>

			<div class="ph-hero-inner">
				<div class="ph-hero-content">
					<span class="ph-hero-badge"><i></i>Planb</span>

					<h1 class="ph-hero-title">
						누군가의 여행이<br>
						당신의 <em>다음 여행</em>이 됩니다
					</h1>

					<p class="ph-hero-description">
						실제로 다녀온 여행자들의 일정과 꿀팁, 함께 떠날 메이트까지.<br>
						Planb에서 다음 여행을 가볍게 시작해보세요.
					</p>

					<form action="${ctx}/search" method="get" class="ph-hero-search" role="search">
						<svg class="ph-hero-search-icon" width="20" height="20" viewBox="0 0 24 24" fill="none"
							stroke="currentColor" stroke-width="2.2" aria-hidden="true">
							<circle cx="11" cy="11" r="8" />
							<path d="m21 21-4.35-4.35" />
						</svg>
						<input type="text" name="q" placeholder="여행지, 일정, 꿀팁 등 무엇이든 검색해보세요"
							aria-label="전체 검색" autocomplete="off">
						<button type="submit" class="ph-hero-search-btn">검색</button>
					</form>

					<div class="ph-hero-tags">
						<span>인기 검색</span>
						<a href="${ctx}/search?q=오사카">#오사카</a>
						<a href="${ctx}/search?q=파리">#파리</a>
						<a href="${ctx}/search?q=다낭">#다낭</a>
						<a href="${ctx}/search?q=제주">#제주</a>
					</div>
				</div>

				<div class="ph-hero-bottom">
					<div class="ph-hero-place">
						<span class="ph-hero-place-label">Now viewing</span>
						<strong class="ph-hero-place-name" data-hero-place>Santorini, <em>Greece</em></strong>
					</div>

					<button type="button" class="ph-hero-scroll" data-scroll-next aria-label="아래로 스크롤">
						<span>Scroll</span>
						<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
							<path d="M12 5v14M5 12l7 7 7-7" />
						</svg>
					</button>

					<div class="ph-hero-controls">
						<span class="ph-hero-count"><b data-hero-index>01</b> / 05</span>
						<div class="ph-hero-bars" data-hero-bars>
							<button type="button" class="is-active" aria-label="1번 사진"><i></i></button>
							<button type="button" aria-label="2번 사진"><i></i></button>
							<button type="button" aria-label="3번 사진"><i></i></button>
							<button type="button" aria-label="4번 사진"><i></i></button>
							<button type="button" aria-label="5번 사진"><i></i></button>
						</div>
					</div>
				</div>
			</div>
		</section>

		<!-- ========================================
		     HOME - 2번 구역 : 인기 여행일정
		========================================= -->
		<section id="popularPlans" class="ph-section ph-popular" data-ph-section>
			<div class="ph-container ph-section-head">
				<div>
					<p class="ph-eyebrow"><b>01</b> Popular Travel Plans</p>
					<h2 class="ph-heading">지금 가장 인기 있는 여행일정</h2>
				</div>
				<div class="ph-section-head-side">
					<p>전 세계 여행자들이 사랑하는 특별한 일정을 만나보세요.</p>
					<a href="${ctx}/schedules" class="ph-more-link">
						전체 일정 보기
						<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M5 12h14M12 5l7 7-7 7" /></svg>
					</a>
				</div>
			</div>

			<div class="ph-popular-carousel" data-ph-carousel>
				<c:forEach var="itinerary" items="${itineraryList}" varStatus="status">
					<a href="${ctx}/schedules/detail?id=${itinerary.itineraryId}" class="ph-plan-card">
						<div class="ph-plan-card-image">
							<c:choose>
								<c:when test="${not empty itinerary.thumbnailImg}">
									<img src="${ctx}${itinerary.thumbnailImg}" alt="<c:out value='${itinerary.title}' />" loading="lazy">
								</c:when>
								<c:otherwise>
									<div class="ph-plan-card-noimg">이미지 없음</div>
								</c:otherwise>
							</c:choose>

							<span class="ph-plan-card-location">
								<svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z" /><circle cx="12" cy="10" r="3" /></svg>
								<c:out value="${not empty itinerary.city ? itinerary.city : itinerary.country}" />
							</span>
							<span class="ph-plan-card-duration"><c:out value="${itinerary.durationText}" /></span>
						</div>

						<div class="ph-plan-card-body">
							<h3><c:out value="${itinerary.title}" /></h3>
							<p><c:out value="${itinerary.summary}" /></p>

							<div class="ph-plan-card-foot">
								<div class="ph-plan-card-author">
									<span class="ph-avatar"><jsp:include page="/common/profileImage.jsp"><jsp:param name="image" value="${itinerary.profileImg}"/></jsp:include></span>
									<span><c:out value="${itinerary.nickname}" /></span>
								</div>

								<div class="ph-plan-card-stats">
									<span title="댓글">
										<svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 11.5a8.38 8.38 0 0 1-.9 3.8 8.5 8.5 0 0 1-7.6 4.7 8.38 8.38 0 0 1-3.8-.9L3 21l1.9-5.7a8.38 8.38 0 0 1-.9-3.8 8.5 8.5 0 0 1 4.7-7.6 8.38 8.38 0 0 1 3.8-.9h.5a8.48 8.48 0 0 1 8 8v.5z" /></svg>
										<fmt:formatNumber value="${itinerary.commentCount}" />
									</span>
									<span title="조회">
										<svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" /><path d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" /></svg>
										<fmt:formatNumber value="${itinerary.viewCount}" />
									</span>
								</div>
							</div>
						</div>
					</a>

					<!-- 홈 인기 여행일정 사이 광고 -->
					                    <c:if test="${not empty displayHomeAds and status.count mod homeAdInterval == 0}">
                        <c:set var="displayHomeAd" value="${displayHomeAds[((status.count / homeAdInterval) - 1) mod fn:length(displayHomeAds)]}" />
                        <a href="<c:out value='${displayHomeAd.linkUrl}'/>" target="_blank" rel="noopener noreferrer sponsored" class="ph-plan-card ph-plan-card--ad">
                            <div class="ph-plan-card-image">
                                <img src="<c:out value='${displayHomeAd.imageUrl}'/>" alt="<c:out value='${displayHomeAd.headline}'/>" loading="lazy">
                                <span class="ph-plan-card-ad-badge">AD</span>
                            </div>
                            <div class="ph-plan-card-body">
                                <span class="ph-plan-card-brand"><c:out value="${displayHomeAd.siteName}"/></span>
                                <h3><c:out value="${displayHomeAd.headline}"/></h3>
                                <p><c:out value="${displayHomeAd.description}"/></p>
                                <div class="ph-plan-card-foot"><span class="ph-plan-card-ad-link">광고 보기 →</span></div>
                            </div>
                        </a>
                    </c:if>
				</c:forEach>

				<c:if test="${empty itineraryList}">
					<div class="ph-empty">아직 등록된 여행일정이 없습니다.</div>
				</c:if>
			</div>
		</section>

		<!-- ========================================
		     HOME - 3번 구역 : 여행일정 만들기 CTA
		========================================= -->
		<section id="homeArea3" class="ph-section ph-create" data-ph-section data-theme="dark">
			<div class="ph-container ph-create-inner">
				<div class="ph-create-text">
					<p class="ph-eyebrow ph-eyebrow--light"><b>02</b> Create Your Journey</p>
					<h2 class="ph-create-title">
						마음에 드는 여행을 발견하셨나요?<br>
						이제 <em>나만의 여행</em>을 만들어보세요.
					</h2>
					<p class="ph-create-description">
						가고 싶은 장소와 일정을 자유롭게 담아<br>
						나만의 특별한 여행 계획을 완성해보세요.
					</p>

					<ul class="ph-create-steps">
						<li><b>1</b><div><strong>장소 담기</strong><span>가고 싶은 곳을 검색해 추가</span></div></li>
						<li><b>2</b><div><strong>일정 짜기</strong><span>날짜별로 동선을 정리</span></div></li>
						<li><b>3</b><div><strong>공유하기</strong><span>다른 여행자와 함께 나누기</span></div></li>
					</ul>

					<a href="${ctx}${not empty sessionScope.user ? '/writeplan' : '/auth/login'}" class="ph-create-button">
						일정 만들기 <span aria-hidden="true">→</span>
					</a>
				</div>

				<div class="ph-create-visual" aria-hidden="true">
					<div class="ph-create-photo ph-create-photo--main"
						style="background-image: url('https://images.unsplash.com/photo-1488646953014-85cb44e25828?auto=format&fit=crop&w=1200&q=80')"></div>
					<div class="ph-create-photo ph-create-photo--sub"
						style="background-image: url('https://images.unsplash.com/photo-1533105079780-92b9be482077?auto=format&fit=crop&w=800&q=80')"></div>

					<div class="ph-create-ticket">
						<span class="ph-create-ticket-label">DAY 1 · Santorini</span>
						<div class="ph-create-ticket-route">
							<span>ATH</span>
							<i></i>
							<span class="ph-create-ticket-plane">✈</span>
							<i></i>
							<span>JTR</span>
						</div>
						<ul>
							<li><b>09:00</b> 피라 마을 산책</li>
							<li><b>13:00</b> 아무디 베이 점심</li>
							<li><b>19:30</b> 이아 선셋 감상</li>
						</ul>
					</div>
				</div>
			</div>
		</section>

		<!-- ========================================
		     HOME - 4번 구역 : 여행꿀팁 / 여행 메이트
		========================================= -->
		<section id="homeArea4" class="ph-section ph-community" data-ph-section>
			<div class="ph-container">
				<div class="ph-section-head ph-section-head--center">
					<p class="ph-eyebrow"><b>03</b> Community</p>
					<h2 class="ph-heading">여행자들이 나누는 이야기</h2>
				</div>

				<div class="ph-community-grid">

					<!-- 여행 꿀팁 -->
					<div class="ph-board">
						<div class="ph-board-head">
							<div>
								<span class="ph-board-kicker">Travel Tips</span>
								<h3>여행꿀팁</h3>
								<p>여행 고수들의 노하우</p>
							</div>
							<a href="${ctx}/tips" class="ph-board-more" aria-label="여행꿀팁 더보기">
								더보기
								<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M5 12h14M12 5l7 7-7 7" /></svg>
							</a>
						</div>

						<c:choose>
							<c:when test="${not empty tipList}">
								<div class="ph-board-pages" data-rotate-group>
									<c:forEach var="page" begin="0" end="2">
										<c:if test="${fn:length(tipList) > page * 3}">
											<div class="ph-rotate-page${page == 0 ? ' is-active' : ''}">
												<c:forEach var="tip" items="${tipList}" begin="${page * 3}" end="${page * 3 + 2}">
													<a href="${ctx}/tipDetail?tipId=${tip.tipId}" class="ph-board-item">
														<div class="ph-board-thumb">
															<c:choose>
																<c:when test="${not empty tip.thumbnailImg}">
																	<img src="${ctx}${tip.thumbnailImg}" alt="<c:out value='${tip.title}' />" loading="lazy">
																</c:when>
																<c:otherwise>
																	<img src="${ctx}/view/assets/images/default/tip-default.svg" alt="여행꿀팁 기본 이미지" loading="lazy">
																</c:otherwise>
															</c:choose>
														</div>
														<div class="ph-board-info">
															<c:if test="${not empty tip.country}">
																<span class="ph-chip"><c:out value="${tip.country}" /></span>
															</c:if>
															<h4><c:out value="${tip.title}" /></h4>
															<div class="ph-board-author">
																<c:set var="boardProfileImg" value="${tip.profileImg}" />
																<c:set var="boardNickname" value="${tip.nickname}" />
																<%@ include file="/view/home/homeBoardAvatar.jspf" %>
																<span class="ph-board-name"><c:out value="${tip.nickname}" default="알 수 없음" /></span>
															</div>
														</div>
														<svg class="ph-board-arrow" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><path d="M9 6l6 6-6 6" /></svg>
													</a>
												</c:forEach>
											</div>
										</c:if>
									</c:forEach>
								</div>
								<div class="ph-progress" data-rotate-progress></div>
							</c:when>
							<c:otherwise>
								<div class="ph-empty">등록된 여행꿀팁이 없습니다.</div>
							</c:otherwise>
						</c:choose>
					</div>

					<!-- 여행 메이트 -->
					<div class="ph-board">
						<div class="ph-board-head">
							<div>
								<span class="ph-board-kicker">Travel Mate</span>
								<h3>여행 메이트</h3>
								<p>함께 여행할 동반자</p>
							</div>
							<a href="${ctx}/mates" class="ph-board-more" aria-label="여행 메이트 더보기">
								더보기
								<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M5 12h14M12 5l7 7-7 7" /></svg>
							</a>
						</div>

						<c:choose>
							<c:when test="${not empty mateList}">
								<div class="ph-board-pages" data-rotate-group>
									<c:forEach var="page" begin="0" end="2">
										<c:if test="${fn:length(mateList) > page * 3}">
											<div class="ph-rotate-page${page == 0 ? ' is-active' : ''}">
												<c:forEach var="mate" items="${mateList}" begin="${page * 3}" end="${page * 3 + 2}">
													<a href="${ctx}/mateDetail?mateId=${mate.mateId}" class="ph-board-item">
														<div class="ph-board-thumb">
															<c:choose>
																<c:when test="${not empty mate.img}">
																	<img src="${ctx}${mate.img}" alt="<c:out value='${mate.title}' />" loading="lazy">
																</c:when>
																<c:otherwise>
																	<img src="${ctx}/view/assets/images/default/mate-default.svg" alt="여행 메이트 기본 이미지" loading="lazy">
																</c:otherwise>
															</c:choose>
														</div>
														<div class="ph-board-info">
															<div class="ph-board-meta">
																<span class="ph-chip"><c:out value="${mate.country}" /></span>
																<c:if test="${mate.recruitStatus eq 'OPEN'}">
																	<span class="ph-chip ph-chip--open"><c:out value="${mate.recruitCount}" />명 모집</span>
																</c:if>
																<c:if test="${mate.recruitStatus eq 'CLOSED'}">
																	<span class="ph-chip ph-chip--closed">모집완료</span>
																</c:if>
															</div>
															<h4><c:out value="${mate.title}" /></h4>
															<div class="ph-board-author">
																<c:set var="boardProfileImg" value="${mate.profileImg}" />
																<c:set var="boardNickname" value="${mate.nickname}" />
																<%@ include file="/view/home/homeBoardAvatar.jspf" %>
																<span class="ph-board-name"><c:out value="${mate.nickname}" default="알 수 없음" /></span>
															</div>
														</div>
														<svg class="ph-board-arrow" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><path d="M9 6l6 6-6 6" /></svg>
													</a>
												</c:forEach>
											</div>
										</c:if>
									</c:forEach>
								</div>
								<div class="ph-progress" data-rotate-progress></div>
							</c:when>
							<c:otherwise>
								<div class="ph-empty">등록된 여행 메이트가 없습니다.</div>
							</c:otherwise>
						</c:choose>
					</div>

				</div>
			</div>
		</section>
	</main>

	<jsp:include page="/common/footer.jsp" />
</body>
</html>
