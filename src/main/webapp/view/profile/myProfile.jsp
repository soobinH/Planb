<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8" import="dto.member.UserDto"
	import="dto.profile.ProfileFeedDto" import="java.util.List"%>

<%

request.setAttribute("activePage", "profile");

String ctx = request.getContextPath();

/* =========================

   로그인 사용자

========================= */

UserDto user = (UserDto) session.getAttribute("user");

/* 로그인하지 않은 상태에서 직접 접근한 경우 */

if (user == null) {

	response.sendRedirect(ctx + "/view/auth/login.jsp");

	return;

}

/* =========================

   회원 정보

========================= */

String loginId = user.getLoginId() == null ? "" : user.getLoginId();

String name = user.getName() == null ? "" : user.getName();

String nickname = user.getNickName() == null ? "" : user.getNickName();

String bio = user.getBio() == null ? "" : user.getBio();

String region = user.getRegion() == null ? "" : user.getRegion();

String profileImg = user.getProfileImg() == null ? "" : user.getProfileImg();

String phone = user.getPhone() == null ? "" : user.getPhone();

String postcode = user.getPostcode() == null ? "" : user.getPostcode();

String address = user.getAddress() == null ? "" : user.getAddress();

String addressDetail = user.getAddressDetail() == null ? "" : user.getAddressDetail();

String birthDate = user.getBirthDate() == null ? "" : user.getBirthDate().toString();

/* =========================

프로필 이미지 경로

SharedImageView:

/uploads/profile/*

========================= */

String profilePath = (String) application.getAttribute("profilePath");

if (profilePath == null || profilePath.trim().isEmpty()) {

	profilePath = "/uploads/profile";

}

/* =========================

내 여행 일정

========================= */

List<ProfileFeedDto> myItineraries = (List<ProfileFeedDto>) request.getAttribute("myItineraries");

if (myItineraries == null) {

	myItineraries = new java.util.ArrayList<ProfileFeedDto>();

}

List<ProfileFeedDto> bookmarkedItineraries = (List<ProfileFeedDto>) request.getAttribute("bookmarkedItineraries");

if (bookmarkedItineraries == null) {

	bookmarkedItineraries = new java.util.ArrayList<ProfileFeedDto>();

}

List<ProfileFeedDto> likedItineraries = (List<ProfileFeedDto>) request.getAttribute("likedItineraries");

if (likedItineraries == null) {

	likedItineraries = new java.util.ArrayList<ProfileFeedDto>();

}

Integer postCount = (Integer) request.getAttribute("postCount");

Integer likeCount = (Integer) request.getAttribute("likeCount");

Integer bookmarkCount = (Integer) request.getAttribute("bookmarkCount");

if (postCount == null) {

	postCount = 0;

}

if (likeCount == null) {

	likeCount = 0;

}

if (bookmarkCount == null) {

	bookmarkCount = 0;

}

Boolean myPostsHasMoreAttr =
        (Boolean) request.getAttribute("myPostsHasMore");

Boolean mySavedHasMoreAttr =
        (Boolean) request.getAttribute("mySavedHasMore");

Boolean myLikedHasMoreAttr =
        (Boolean) request.getAttribute("myLikedHasMore");

boolean myPostsHasMore =
        Boolean.TRUE.equals(myPostsHasMoreAttr);

boolean mySavedHasMore =
        Boolean.TRUE.equals(mySavedHasMoreAttr);

boolean myLikedHasMore =
        Boolean.TRUE.equals(myLikedHasMoreAttr);

%>

<!DOCTYPE html>

<html lang="ko">

<head>

<meta charset="UTF-8">

<meta name="viewport" content="width=device-width, initial-scale=1">

<title>내 프로필</title>

<!-- 공통 CSS -->

<jsp:include page="/common/headStyles.jsp" />

<!--

    실제 profile.css 위치 확인

    현재 기준:

    src/main/webapp/view/assets/css/profile.css

\-->

<link rel="stylesheet" href="<%=ctx%>/view/assets/css/auth/profile.css">


<style>
.profile-feed-sentinel {
	width: 100%;
	height: 1px;
}

.profile-feed-loading {
	width: 100%;
	padding: 22px 0 8px;
	text-align: center;
	font-size: 12px;
	font-weight: 700;
	color: #9ca3af;
}

.profile-feed-loading::before {
	content: "";
	display: inline-block;
	width: 14px;
	height: 14px;
	margin-right: 7px;
	border: 2px solid #e5e7eb;
	border-top-color: #6369D1;
	border-radius: 50%;
	vertical-align: -2px;
	animation: profile-feed-spin .7s linear infinite;
}

@
keyframes profile-feed-spin {to { transform:rotate(360deg);
	
}

}

/* 북마크는 컬러 이모지가 아닌 선형 SVG 아이콘으로 통일 */
.profile-tabs [data-profile-tab="saved"] {
	display: inline-flex;
	align-items: center;
	justify-content: center;
	gap: 7px;
}

.profile-bookmark-outline {
	display: inline-block;
	width: 17px;
	height: 17px;
	flex: 0 0 auto;
	vertical-align: -3px;
	color: inherit;
}

.feed-hover-stats .profile-bookmark-outline {
	width: 15px;
	height: 15px;
	vertical-align: -3px;
	margin-right: 3px;
}

/* ============================================================
   빈 피드: 3열 그리드의 전체 폭을 사용하고 안내 문구를 중앙에 배치
   (게시물 / 북마크 / 좋아요 공통)
   ============================================================ */
.profile-page .profile-content .feed-grid>.empty-state {
	grid-column: 1/-1 !important;
	justify-self: stretch;
	width: 100%;
	min-height: clamp(180px, 32vh, 320px);
	box-sizing: border-box;
	display: flex !important;
	align-items: center;
	justify-content: center;
	margin: 0 !important;
	padding: 32px 20px;
	text-align: center !important;
}

/* ============================================================
   프로필 편집: 팝업 오픈 시 배경 스크롤 잠금 + 뷰포트 안에 표시
   실제 크기 조정은 아래 fitProfileEditModal()에서 계산
   ============================================================ */
html.profile-modal-open, body.profile-modal-open {
	overflow: hidden !important;
	overscroll-behavior: none;
}

#profileEditModal.profile-edit-modal-backdrop {
	position: fixed !important;
	inset: 0 !important;
	box-sizing: border-box;
	padding: 0 !important;
	overflow: hidden !important;
	overscroll-behavior: contain;
}

#profileEditModal[aria-hidden="true"] {
	display: none !important;
}

#profileEditModal.show[aria-hidden="false"] {
	display: block !important;
}

#profileEditModal .profile-edit-modal {
	position: absolute !important;
	top: var(- -profile-edit-center-y, 50%) !important;
	left: var(- -profile-edit-center-x, 50%) !important;
	width: min(560px, calc(100vw - 24px)) !important;
	max-width: none !important;
	min-width: 0 !important;
	height: auto !important;
	max-height: none !important;
	margin: 0 !important;
	box-sizing: border-box;
	overflow: hidden !important;
	transform-origin: center center !important;
	transform: translate(-50%, -50%) scale(var(- -profile-edit-fit-scale, 1))
		!important;
}

#profileEditModal #profileEditModalForm, #profileEditModal .profile-edit-modal-body
	{
	min-height: 0;
	max-height: none !important;
	overflow: visible !important;
}

#profileEditModal .profile-edit-field, #profileEditModal .profile-edit-field input,
	#profileEditModal .profile-edit-field textarea {
	min-width: 0;
	box-sizing: border-box;
}

#profileEditModal .profile-edit-field textarea {
	resize: none;
}

/* 화면 세로 길이가 짧을 때 먼저 여백을 줄이고, 그래도 넘치면 자동 축소 */
@media ( max-height : 720px) {
	#profileEditModal .profile-edit-modal-header {
		padding-top: 13px !important;
		padding-bottom: 9px !important;
	}
	#profileEditModal .profile-edit-modal-body {
		padding-top: 10px !important;
		padding-bottom: 10px !important;
		gap: 10px !important;
	}
	#profileEditModal .profile-edit-modal-actions {
		padding-top: 10px !important;
		padding-bottom: 10px !important;
	}
	#profileEditModal .profile-edit-photo-row {
		gap: 12px !important;
		margin-bottom: 9px !important;
	}
	#profileEditModal .profile-edit-field {
		gap: 4px !important;
		margin-bottom: 8px !important;
	}
	#profileEditModal .profile-edit-field textarea {
		min-height: 64px !important;
		height: 64px !important;
	}
}

@media ( max-height : 520px) {
	#profileEditModal .profile-edit-modal-header, #profileEditModal .profile-edit-modal-actions
		{
		padding-top: 7px !important;
		padding-bottom: 7px !important;
	}
	#profileEditModal .profile-edit-modal-body {
		padding-top: 6px !important;
		padding-bottom: 6px !important;
		gap: 6px !important;
	}
	#profileEditModal .profile-edit-photo-row {
		margin-bottom: 4px !important;
	}
	#profileEditModal .profile-edit-field {
		margin-bottom: 4px !important;
	}
	#profileEditModal .profile-edit-field textarea {
		min-height: 52px !important;
		height: 52px !important;
	}
}

/* =========================================
   프로필 편집 팝업 중앙 정렬 수정
   ========================================= */

/* 팝업 배경: 화면 전체 + 중앙 정렬 */
#profileEditModal.show[aria-hidden="false"] {
    display: flex !important;
    align-items: center !important;
    justify-content: center !important;
}

/* 팝업 본체 */
#profileEditModal .profile-edit-modal {
    position: relative !important;

    top: auto !important;
    left: auto !important;
    right: auto !important;
    bottom: auto !important;

    margin: 0 !important;

    width: min(560px, calc(100vw - 24px)) !important;
    max-width: none !important;

    flex: 0 0 auto !important;

    /* 작은 화면에서 자동 축소 유지 */
    transform: scale(
        var(--profile-edit-fit-scale, 1)
    ) !important;

    transform-origin: center center !important;

    /* 상단 및 하단 둥근 모서리 유지 */
    border-radius: 18px !important;
    overflow: hidden !important;

    box-sizing: border-box !important;
}
</style>

</head>

<body class="site-shell">

	<!-- =========================

     공통 Header

========================= -->

	<jsp:include page="/common/header.jsp" />

	<div class="page profile-page">

		<!-- ==========================================

         프로필 상단

    =========================================== -->

		<section class="profile-hero">

			<div class="profile-hero-inner">

				<!-- =========================

                 프로필 이미지

            ========================== -->

				<div class="profile-avatar-wrap">

					<div class="avatar avatar-xl">

						<%

						if (!profileImg.isEmpty()) {

						%>

						<img src="<%=ctx%><%=profilePath%>/<%=profileImg%>"
							alt="<%=nickname%> 프로필 이미지"
							onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">

						<!-- 이미지 로딩 실패 시 기본 프로필 -->

						<span class="profile-default-avatar" style="display: none;">

							<svg width="48" height="48" viewBox="0 0 24 24" fill="none"
								stroke="currentColor" stroke-width="1.5">

                                <circle cx="12" cy="8" r="4" />

                                <path
									d="M4 21c0-4.3 3.6-7 8-7s8 2.7 8 7" />

                            </svg>

						</span>

						<%

						} else {

						%>

						<!-- 프로필 이미지 없는 경우 -->

						<span class="profile-default-avatar"> <svg width="48"
								height="48" viewBox="0 0 24 24" fill="none"
								stroke="currentColor" stroke-width="1.5">

                                <circle cx="12" cy="8" r="4" />

                                <path
									d="M4 21c0-4.3 3.6-7 8-7s8 2.7 8 7" />

                            </svg>

						</span>

						<%

						}

						%>

					</div>

				</div>

				<!-- =========================

                 회원 정보

            ========================== -->

				<div class="profile-copy">

					<div class="profile-topline">

						<div>

							<!-- 닉네임 -->

							<div class="profile-username-row">

								<h1>

									<%=nickname.isEmpty() ? loginId : nickname%>

								</h1>

							</div>

							<!-- 실명 -->

							<%

							if (!name.isEmpty()) {

							%>

							<p class="profile-name">

								<%=name%>

							</p>

							<%

							}

							%>

							<!-- 로그인 아이디 -->

							<%

							if (!loginId.isEmpty()) {

							%>

							<p class="profile-login-id">

								@<%=loginId%>

							</p>

							<%

							}

							%>

						</div>

						<!-- =========================

                         프로필 메뉴

                    ========================== -->

						<div class="profile-actions">

							<button type="button" class="btn-soft" id="openProfileEditModal">

								프로필 편집</button>

							<a class="icon-action" href="<%=ctx%>/profile/edit"
								aria-label="설정" title="설정"> ⚙ </a>

						</div>

					</div>

					<!-- =========================

                     통계

                ========================== -->

					<div class="profile-stats">

						<button type="button">

							<strong> <%=postCount%>

							</strong> <span> 게시물 </span>

						</button>

						<button type="button">

							<strong> <%=likeCount%>

							</strong> <span> 받은 좋아요 </span>

						</button>

						<button type="button">

							<strong> <%=bookmarkCount%>

							</strong> <span> 받은 북마크 </span>

						</button>

					</div>

					<!-- =========================

                     자기소개 / 지역

                ========================== -->

					<div class="profile-bio-block">

						<%-- <% if (!name.isEmpty()) { %>

                        <p>

                            <%=name%>

                        </p>

                    <% } %> --%>

						<%

						if (!bio.isEmpty()) {

						%>

						<p style="font-weight: 400;">

							<%=bio%>

						</p>

						<%

						} else {

						%>

						<p class="profile-empty-bio" style="font-weight: 400;">등록된

							소개글이 없습니다.</p>

						<%

						}

						%>

						<%

						if (!region.isEmpty()) {

						%>

						<span class="profile-location"> <%=region%>

						</span>

						<%

						}

						%>

					</div>

				</div>

			</div>

		</section>

		<!-- ==========================================

         프로필 탭

    =========================================== -->

		<div class="profile-tabs">

			<button type="button" class="active" data-profile-tab="posts">

				▦ <span> 게시물 </span>

			</button>

			<button type="button" data-profile-tab="saved">

				<svg class="profile-bookmark-outline" width="17" height="17"
					viewBox="0 0 24 24" fill="none" stroke="currentColor"
					stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"
					aria-hidden="true">
                    <path d="M6 4.5h12v16l-6-4-6 4z" />
                </svg>
				<span> 북마크한 게시글 </span>

			</button>

			<button type="button" data-profile-tab="liked">

				♡ <span> 좋아요한 게시글 </span>

			</button>

		</div>

		<!-- ==========================================

         프로필 컨텐츠

    =========================================== -->

		<main class="profile-content">

			<div data-profile-panel="posts">

				<div class="feed-grid" data-feed-grid="posts">

					<%

					if (!myItineraries.isEmpty()) {

						for (ProfileFeedDto item : myItineraries) {

							String country = item.getCountry() == null ? "" : item.getCountry();

							String city = item.getCity() == null ? "" : item.getCity();

							String locationText = "";

							if (!country.isEmpty() && !city.isEmpty()) {

						locationText = country + " · " + city;

							} else if (!country.isEmpty()) {

						locationText = country;

							} else if (!city.isEmpty()) {

						locationText = city;

							}

							String thumbnail = item.getThumbnailImg() == null ? "" : item.getThumbnailImg();

					%>

					<div class="feed-admin-shell">

						<a class="feed-item"
							href="<%=ctx%>/schedules/detail?id=<%=item.getItineraryId()%>">

							<%

							if (!thumbnail.isEmpty()) {

							%> <img src="<%=ctx%><%=thumbnail%>" alt="<%=item.getTitle()%>">

							<%

							} else {

							%> <span class="feed-fallback"></span> <%

 }

 %> <span class="feed-hover"> <span class="feed-hover-copy">

									<strong> <%=item.getTitle()%>

								</strong> <%

 if (!locationText.isEmpty()) {

 %> <small> <%=locationText%>

								</small> <%

 }

 %> <%

 if ("PRIVATE".equals(item.getVisibility())) {

 %> <small> 비공개 </small> <%

 }

 %>

							</span> <span class="feed-hover-stats"> <span> ♥ <%=item.getLikeCount()%>

								</span> <span> <svg class="profile-bookmark-outline" width="17"
											height="17" viewBox="0 0 24 24" fill="none"
											stroke="currentColor" stroke-width="1.8"
											stroke-linecap="round" stroke-linejoin="round"
											aria-hidden="true">
                    <path d="M6 4.5h12v16l-6-4-6 4z" />
                </svg> <%=item.getBookmarkCount()%>

								</span> <span> 💬 <%=item.getCommentCount()%>

								</span>

							</span>

						</span>

						</a>

						<!-- 본인 일정 수정 / 삭제 메뉴 -->

						<div class="feed-owner-actions">

							<button type="button" class="feed-owner-more" data-owner-more
								aria-label="게시글 메뉴">•••</button>

							<div class="feed-owner-menu" role="menu">

								<a
									href="<%=ctx%>/modifyplan?itineraryId=<%=item.getItineraryId()%>">

									수정 </a>

								<button type="button" class="danger"
									data-delete-itinerary="<%=item.getItineraryId()%>">삭제</button>

							</div>

						</div>

					</div>

					<%

					}

					} else {

					%>

					<div class="empty-state">아직 작성한 여행 일정이 없습니다.</div>

					<%

					}

					%>

				</div>

				<div class="profile-feed-sentinel" data-feed-sentinel
					data-scope="my" data-type="posts"
					data-offset="<%=myItineraries.size()%>"
					data-has-more="<%=myPostsHasMore%>"></div>

				<div class="profile-feed-loading" data-feed-loading="posts" hidden>

					불러오는 중...</div>

			</div>

			<!-- ======================================

		     북마크

		======================================= -->

			<div data-profile-panel="saved" class="jsp-hidden">

				<div class="feed-grid" data-feed-grid="saved">

					<%

					if (bookmarkedItineraries != null && !bookmarkedItineraries.isEmpty()) {

						for (ProfileFeedDto item : bookmarkedItineraries) {

							String country = item.getCountry() == null ? "" : item.getCountry();

							String city = item.getCity() == null ? "" : item.getCity();

							String locationText = "";

							if (!country.isEmpty() && !city.isEmpty()) {

						locationText = country + " · " + city;

							} else if (!country.isEmpty()) {

						locationText = country;

							} else if (!city.isEmpty()) {

						locationText = city;

							}

							String thumbnail = item.getThumbnailImg() == null ? "" : item.getThumbnailImg();

					%>

					<div class="feed-admin-shell">

						<a class="feed-item"
							href="<%=ctx%>/schedules/detail?id=<%=item.getItineraryId()%>">

							<%

							if (!thumbnail.isEmpty()) {

							%> <img src="<%=ctx%><%=thumbnail%>" alt="<%=item.getTitle()%>">

							<%

							} else {

							%> <span class="feed-fallback"></span> <%

 }

 %> <span class="feed-hover"> <span class="feed-hover-copy">

									<strong> <%=item.getTitle()%>

								</strong> <%

 if (!locationText.isEmpty()) {

 %> <small> <%=locationText%>

								</small> <%

 }

 %>

							</span> <span class="feed-hover-stats"> <span> ♥ <%=item.getLikeCount()%>

								</span> <span> <svg class="profile-bookmark-outline" width="17"
											height="17" viewBox="0 0 24 24" fill="none"
											stroke="currentColor" stroke-width="1.8"
											stroke-linecap="round" stroke-linejoin="round"
											aria-hidden="true">
                    <path d="M6 4.5h12v16l-6-4-6 4z" />
                </svg> <%=item.getBookmarkCount()%>

								</span> <span> 💬 <%=item.getCommentCount()%>

								</span>

							</span>

						</span>

						</a>

					</div>

					<%

					}

					} else {

					%>

					<div class="empty-state">아직 북마크한 여행 일정이 없습니다.</div>

					<%

					}

					%>

				</div>

				<div class="profile-feed-sentinel" data-feed-sentinel
					data-scope="my" data-type="saved"
					data-offset="<%=bookmarkedItineraries.size()%>"
					data-has-more="<%=mySavedHasMore%>"></div>

				<div class="profile-feed-loading" data-feed-loading="saved" hidden>

					불러오는 중...</div>

			</div>

			<!-- ======================================

		     좋아요

		======================================= -->

			<div data-profile-panel="liked" class="jsp-hidden">

				<div class="feed-grid" data-feed-grid="liked">

					<%

					if (likedItineraries != null && !likedItineraries.isEmpty()) {

						for (ProfileFeedDto item : likedItineraries) {

							String country = item.getCountry() == null ? "" : item.getCountry();

							String city = item.getCity() == null ? "" : item.getCity();

							String locationText = "";

							if (!country.isEmpty() && !city.isEmpty()) {

						locationText = country + " · " + city;

							} else if (!country.isEmpty()) {

						locationText = country;

							} else if (!city.isEmpty()) {

						locationText = city;

							}

							String thumbnail = item.getThumbnailImg() == null ? "" : item.getThumbnailImg();

					%>

					<div class="feed-admin-shell">

						<a class="feed-item"
							href="<%=ctx%>/schedules/detail?id=<%=item.getItineraryId()%>">

							<%

							if (!thumbnail.isEmpty()) {

							%> <img src="<%=ctx%><%=thumbnail%>" alt="<%=item.getTitle()%>">

							<%

							} else {

							%> <span class="feed-fallback"></span> <%

 }

 %> <span class="feed-hover"> <span class="feed-hover-copy">

									<strong> <%=item.getTitle()%>

								</strong> <%

 if (!locationText.isEmpty()) {

 %> <small> <%=locationText%>

								</small> <%

 }

 %>

							</span> <span class="feed-hover-stats"> <span> ♥ <%=item.getLikeCount()%>

								</span> <span> <svg class="profile-bookmark-outline" width="17"
											height="17" viewBox="0 0 24 24" fill="none"
											stroke="currentColor" stroke-width="1.8"
											stroke-linecap="round" stroke-linejoin="round"
											aria-hidden="true">
                    <path d="M6 4.5h12v16l-6-4-6 4z" />
                </svg> <%=item.getBookmarkCount()%>

								</span> <span> 💬 <%=item.getCommentCount()%>

								</span>

							</span>

						</span>

						</a>

					</div>

					<%

					}

					} else {

					%>

					<div class="empty-state">아직 좋아요한 여행 일정이 없습니다.</div>

					<%

					}

					%>

				</div>

				<div class="profile-feed-sentinel" data-feed-sentinel
					data-scope="my" data-type="liked"
					data-offset="<%=likedItineraries.size()%>"
					data-has-more="<%=myLikedHasMore%>"></div>

				<div class="profile-feed-loading" data-feed-loading="liked" hidden>

					불러오는 중...</div>

			</div>


		</main>

	</div>

	<!-- =========================================================

     프로필 편집 모달

========================================================= -->

	<div class="profile-edit-modal-backdrop" id="profileEditModal"
		aria-hidden="true">

		<div class="profile-edit-modal" role="dialog" aria-modal="true"
			aria-labelledby="profileEditModalTitle">

			<!-- 모달 헤더 -->

			<div class="profile-edit-modal-header">

				<div>

					<h2 id="profileEditModalTitle">프로필 편집</h2>

					<p>내 피드에 표시되는 정보를 수정합니다.</p>

				</div>

				<button type="button" class="profile-edit-modal-close"
					id="closeProfileEditModal" aria-label="닫기">×</button>

			</div>

			<form id="profileEditModalForm" action="<%=ctx%>/profile/edit"
				method="post" enctype="multipart/form-data">

				<!--

					ProfileEdit Servlet은 회원정보 전체를 UPDATE하므로

					모달에서 직접 수정하지 않는 값도 같이 전송합니다.

				-->

				<input type="hidden" name="birthDate" value="<%=birthDate%>">

				<input type="hidden" name="phone" value="<%=phone%>"> <input
					type="hidden" name="postcode" value="<%=postcode%>"> <input
					type="hidden" name="address" value="<%=address%>"> <input
					type="hidden" name="addressDetail" value="<%=addressDetail%>">

				<div class="profile-edit-modal-body">

					<!-- 프로필 이미지 -->

					<div class="profile-edit-photo-row">

						<div class="profile-edit-preview">

							<img id="profileEditPreviewImage"
								<%if (!profileImg.isEmpty()) {%>
								src="<%=ctx%><%=profilePath%>/<%=profileImg%>" <%}%>
								alt="<%=nickname%> 프로필 이미지"
								style="display:<%=profileImg.isEmpty() ? "none" : "block"%>;">

							<div class="profile-edit-preview-empty"
								id="profileEditPreviewEmpty"
								style="display:<%=profileImg.isEmpty() ? "flex" : "none"%>;">

								<svg width="34" height="34" viewBox="0 0 24 24" fill="none"
									stroke="currentColor" stroke-width="1.6">

									<circle cx="12" cy="8" r="4" />

									<path d="M4 21c0-4.3 3.6-7 8-7s8 2.7 8 7" />

								</svg>

							</div>

						</div>

						<div class="profile-edit-photo-copy">

							<strong><%=nickname%></strong> <span>프로필 사진을 변경할 수 있습니다.</span> <label
								class="profile-edit-photo-btn"> 사진 변경 <input type="file"
								name="profileImage" id="profileEditImageInput"
								accept="image/jpeg,image/png,image/webp,image/gif">

							</label>

						</div>

					</div>

					<!-- 닉네임 -->

					<label class="profile-edit-field"> <span>닉네임</span> <input
						type="text" name="nickname" value="<%=nickname%>" maxlength="50"
						required>

					</label>

					<!-- 이름 -->

					<label class="profile-edit-field"> <span>이름</span> <input
						type="text" name="name" value="<%=name%>" maxlength="50" required>

					</label>

					<!-- 소개 -->

					<label class="profile-edit-field"> <span>소개</span> <textarea
							name="bio" rows="4" maxlength="300"><%=bio%></textarea> <small>프로필에

							공개되는 소개글입니다.</small>

					</label>

					<!-- 지역 -->

					<label class="profile-edit-field"> <span>지역</span> <input
						type="text" name="region" value="<%=region%>" maxlength="100">

					</label>

				</div>

				<!-- 모달 하단 -->

				<div class="profile-edit-modal-actions">

					<button type="button" class="profile-edit-cancel-btn"
						id="cancelProfileEditModal">취소</button>

					<button type="submit" class="profile-edit-save-btn">저장</button>

				</div>

			</form>

		</div>

	</div>

	<!-- =========================

     Footer

========================= -->

	<jsp:include page="/common/footer.jsp" />

	<!-- ==========================================

     프로필 페이지 JS

=========================================== -->

	<script>

		document.addEventListener("DOMContentLoaded", function() {

			/* =========================

			   프로필 탭

			========================== */

			const tabs = document.querySelectorAll("[data-profile-tab]");

			const panels = document.querySelectorAll("[data-profile-panel]");

			tabs.forEach(function(tab) {

				tab.addEventListener("click", function() {

					const target = tab.dataset.profileTab;

					/* 모든 탭 비활성화 */

					tabs.forEach(function(item) {

						item.classList.remove("active");

					});

					/* 현재 탭 활성화 */

					tab.classList.add("active");

					/* 패널 전환 */

					panels.forEach(function(panel) {

						if (panel.dataset.profilePanel === target) {

							panel.classList.remove("jsp-hidden");

						} else {

							panel.classList.add("jsp-hidden");

						}

					});

				});

			});

			/* =========================

               게시물 메뉴
               무한스크롤로 추가된 카드에도 적용되도록 이벤트 위임 사용

            ========================== */

            document.addEventListener("click", function(event) {

                const button =
                    event.target.closest("[data-owner-more]");

                if (button) {

                    event.preventDefault();
                    event.stopPropagation();

                    const parent =
                        button.closest(".feed-owner-actions");

                    const menu =
                        parent
                        ? parent.querySelector(".feed-owner-menu")
                        : null;

                    document
                        .querySelectorAll(".feed-owner-menu")
                        .forEach(function(otherMenu) {

                            if (otherMenu !== menu) {

                                otherMenu.classList.remove("show");
                            }
                        });

                    if (menu) {

                        menu.classList.toggle("show");
                    }

                    return;
                }

                if (!event.target.closest(".feed-owner-menu")) {

                    document
                        .querySelectorAll(".feed-owner-menu")
                        .forEach(function(menu) {

                            menu.classList.remove("show");
                        });
                }
            });

            /* =========================================================

			   프로필 피드 무한스크롤

			========================================================= */

			const feedSentinels =

			    document.querySelectorAll(

			        "[data-feed-sentinel]"

			    );

			const feedObserver =

			    new IntersectionObserver(

			        function(entries) {

			            entries.forEach(

			                function(entry) {

			                    if (!entry.isIntersecting) {

			                        return;

			                    }

			                    const sentinel =

			                        entry.target;

			                    loadMoreProfileFeed(

			                        sentinel

			                    );

			                }

			            );

			        },

			        {

			            root:

			                null,

			            rootMargin:

			                "350px 0px",

			            threshold:

			                0

			        }

			    );

			feedSentinels.forEach(

			    function(sentinel) {

			        if (

			            sentinel.dataset.hasMore

			            ===

			            "true"

			        ) {

			            feedObserver.observe(

			                sentinel

			            );

			        }

			    }

			);

			/*

			 * =====================================================

			 * 다음 9개

			 * =====================================================

			 */

			async function loadMoreProfileFeed(

			        sentinel

			) {

			    /*

			     * 중복 요청 방지

			     */

			    if (

			        sentinel.dataset.loading

			        ===

			        "true"

			    ) {

			        return;

			    }

			    /*

			     * 더 이상 데이터 없음

			     */

			    if (

			        sentinel.dataset.hasMore

			        !==

			        "true"

			    ) {

			        feedObserver.unobserve(

			            sentinel

			        );

			        return;

			    }

			    sentinel.dataset.loading =

			        "true";

			    const type =

			        sentinel.dataset.type;

			    const scope =

			        sentinel.dataset.scope;

			    const offset =

			        Number(

			            sentinel.dataset.offset

			            ||

			            0

			        );

			    const panel =

			        sentinel.closest(

			            "[data-profile-panel]"

			        );

			    if (!panel) {

			        sentinel.dataset.loading =

			            "false";

			        return;

			    }

			    const grid =

			        panel.querySelector(

			            '[data-feed-grid="'

			            +

			            type

			            +

			            '"]'

			        );

			    if (!grid) {

			        sentinel.dataset.loading =

			            "false";

			        return;

			    }

			    const loading =

			        panel.querySelector(

			            '[data-feed-loading="'

			            +

			            type

			            +

			            '"]'

			        );

			    if (loading) {

			        loading.hidden =

			            false;

			    }

			    try {

			        const params =

			            new URLSearchParams();

			        params.set(

			            "scope",

			            scope

			        );

			        params.set(

			            "type",

			            type

			        );

			        params.set(

			            "offset",

			            String(

			                offset

			            )

			        );

			        /*

			         * 상대 프로필일 때만

			         */

			        if (

			            scope === "user"

			        ) {

			            params.set(

			                "userId",

			                sentinel.dataset.userId

			            );

			        }

			        const response =

			            await fetch(

			                "<%=ctx%>/profile/feed/more?"

			                +

			                params.toString(),

			                {

			                    method:

			                        "GET",

			                    headers: {

			                        "Accept":

			                            "text/html"

			                    },

			                    cache:

			                        "no-store"

			                }

			            );

			        if (!response.ok) {

			            throw new Error(

			                "프로필 피드를 불러오지 못했습니다."

			            );

			        }

			        const html =

			            await response.text();

			        const loadedCount =

			            Number(

			                response.headers.get(

			                    "X-Loaded-Count"

			                )

			                ||

			                0

			            );

			        const hasMore =

			            response.headers.get(

			                "X-Has-More"

			            )

			            ===

			            "true";

			        /*

			         * 새 카드 추가

			         */

			        if (

			            html.trim()

			                .length

			            >

			            0

			        ) {

			            grid.insertAdjacentHTML(

			                "beforeend",

			                html

			            );

			        }

			        /*

			         * 다음 offset

			         *

			         * 0 → 9 → 18 → 27 ...

			         */

			        sentinel.dataset.offset =

			            String(

			                offset

			                +

			                loadedCount

			            );

			        sentinel.dataset.hasMore =

			            String(

			                hasMore

			            );

			        /*

			         * 마지막 페이지

			         */

			        if (!hasMore) {

			            feedObserver.unobserve(

			                sentinel

			            );

			        }

			    } catch (error) {

			        console.error(

			            "[PROFILE INFINITE SCROLL]",

			            error

			        );

			    } finally {

			        sentinel.dataset.loading =

			            "false";

			        if (loading) {

			            loading.hidden =

			                true;

			        }

			    }

			}

		});

	</script>

	<script>

		document.addEventListener("DOMContentLoaded",function() {

							var modal = document.getElementById("profileEditModal");

							var openBtn = document.getElementById("openProfileEditModal");

							var closeBtn = document.getElementById("closeProfileEditModal");

							var cancelBtn = document.getElementById("cancelProfileEditModal");

							var imageInput = document.getElementById("profileEditImageInput");

							var preview = document.getElementById("profileEditPreviewImage");

							var empty = document.getElementById("profileEditPreviewEmpty");

							var form = document.getElementById("profileEditModalForm");

							if (!modal || !openBtn) {

								return;

							}

							var originalImageSrc = preview ? preview

									.getAttribute("src") : null;

							var originalPreviewDisplay = preview ? preview.style.display

									: "none";

							var originalEmptyDisplay = empty ? empty.style.display

									: "flex";

							var profileEditDialog = modal.querySelector(".profile-edit-modal");

							/* 실제 팝업 높이에 맞춰 비율을 조정하므로 별도 스크롤이 생기지 않음 */
							function fitProfileEditModal() {
								if (!profileEditDialog || !modal.classList.contains("show")) {
									return;
								}

								var viewport = window.visualViewport;
								var viewportWidth = viewport ? viewport.width : window.innerWidth;
								var viewportHeight = viewport ? viewport.height : window.innerHeight;

								/* 키보드가 올라오는 모바일에서도 보이는 영역의 중심에 배치 */
								var centerX = (viewport ? viewport.offsetLeft : 0) + viewportWidth / 2;
								var centerY = (viewport ? viewport.offsetTop : 0) + viewportHeight / 2;
								modal.style.setProperty("--profile-edit-center-x", centerX + "px");
								modal.style.setProperty("--profile-edit-center-y", centerY + "px");

								profileEditDialog.style.setProperty("--profile-edit-fit-scale", "1");
								var naturalWidth = Math.max(profileEditDialog.offsetWidth, profileEditDialog.scrollWidth);
								var naturalHeight = Math.max(profileEditDialog.offsetHeight, profileEditDialog.scrollHeight);

								var availableWidth = Math.max(1, viewportWidth - 24);
								var availableHeight = Math.max(1, viewportHeight - 24);
								var scale = Math.min(1, availableWidth / Math.max(1, naturalWidth),
										availableHeight / Math.max(1, naturalHeight));

								profileEditDialog.style.setProperty("--profile-edit-fit-scale", scale.toFixed(4));
							}

							function openProfileModal() {

								modal.classList.add("show");

								modal.setAttribute("aria-hidden", "false");

								document.body.classList.add("profile-modal-open");
								document.documentElement.classList.add("profile-modal-open");
								fitProfileEditModal();
								window.requestAnimationFrame(fitProfileEditModal);

							}

							function resetImagePreview() {

								if (imageInput) {

									imageInput.value = "";

								}

								if (!preview) {

									return;

								}

								if (originalImageSrc

										&& originalImageSrc.trim() !== "") {

									preview.src = originalImageSrc;

									preview.style.display = originalPreviewDisplay

											|| "block";

									if (empty) {

										empty.style.display = "none";

									}

								} else {

									preview.removeAttribute("src");

									preview.style.display = "none";

									if (empty) {

										empty.style.display = originalEmptyDisplay

												|| "flex";

									}

								}

							}

							function closeProfileModal() {

								modal.classList.remove("show");

								modal.setAttribute("aria-hidden", "true");

								document.body.classList.remove("profile-modal-open");
							document.documentElement.classList.remove("profile-modal-open");
							if (profileEditDialog) {
								profileEditDialog.style.removeProperty("--profile-edit-fit-scale");
							}

								if (form) {

									form.reset();

								}

								resetImagePreview();

							}

							window.addEventListener("resize", fitProfileEditModal);
							if (window.visualViewport) {
								window.visualViewport.addEventListener("resize", fitProfileEditModal);
								window.visualViewport.addEventListener("scroll", fitProfileEditModal);
							}

							openBtn.addEventListener("click", openProfileModal);

							if (closeBtn) {

								closeBtn.addEventListener("click",

										closeProfileModal);

							}

							if (cancelBtn) {

								cancelBtn.addEventListener("click",

										closeProfileModal);

							}

							modal.addEventListener("click", function(event) {

								if (event.target === modal) {

									closeProfileModal();

								}

							});

							document.addEventListener("keydown",

									function(event) {

										if (event.key === "Escape"

												&& modal.classList

														.contains("show")) {

											closeProfileModal();

										}

									});

							if (imageInput) {

								imageInput

										.addEventListener(

												"change",

												function() {

													if (!this.files

															|| this.files.length === 0) {

														resetImagePreview();

														return;

													}

													var file = this.files[0];

													if (!file.type

															|| file.type

																	.indexOf("image/") !== 0) {

														alert("이미지 파일만 선택할 수 있습니다.");

														this.value = "";

														resetImagePreview();

														return;

													}

													if (file.size > 5 * 1024 * 1024) {

														alert("프로필 이미지는 5MB 이하만 업로드할 수 있습니다.");

														this.value = "";

														resetImagePreview();

														return;

													}

													var reader = new FileReader();

													reader.onload = function(

															event) {

														preview.src = event.target.result;

														preview.style.display = "block";

														if (empty) {

															empty.style.display = "none";

														}

													};

													reader.onerror = function() {

														alert("이미지를 불러오지 못했습니다.");

														imageInput.value = "";

														resetImagePreview();

													};

													reader.readAsDataURL(file);

												});

							}

							if (form) {

								form

										.addEventListener(

												"submit",

												function() {

													var submitButton = form

															.querySelector(".profile-edit-save-btn");

													if (submitButton) {

														submitButton.disabled = true;

														submitButton.textContent = "저장 중...";

													}

												});

							}

						});

		document.addEventListener(

			    "click",

			    function(event) {

			        const deleteButton =

			            event.target.closest(

			                "[data-delete-itinerary]"

			            );

			        if (!deleteButton) {

			            return;

			        }

			        event.preventDefault();

			        event.stopPropagation();

			        const itineraryId =

			            deleteButton.getAttribute(

			                "data-delete-itinerary"

			            );

			        if (

			            !confirm(

			                "이 일정을 삭제하시겠습니까?"

			            )

			        ) {

			            return;

			        }

			        const form =

			            document.createElement(

			                "form"

			            );

			        form.method =

			            "post";

			        form.action = "<%=ctx%>/profile/itinerary/delete";

			const input = document.createElement("input");

			input.type = "hidden";

			input.name = "itineraryId";

			input.value = itineraryId;

			form.appendChild(input);

			document.body.appendChild(form);

			form.submit();

		});

	</script>


</body>

</html>