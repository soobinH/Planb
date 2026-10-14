<%@ page language="java" contentType="text/html; charset=UTF-8"

	pageEncoding="UTF-8" import="dto.member.UserDto"

	import="dto.profile.ProfileFeedDto" import="java.util.List"

	import="java.util.ArrayList"%>

<%

request.setAttribute("activePage", "profile");

String ctx = request.getContextPath();

/* =========================================================

   1. 조회 대상 사용자

========================================================= */

UserDto targetUser = (UserDto) request.getAttribute("targetUser");

/*

 * Servlet을 거치지 않고

 * JSP로 직접 접근한 경우

 */

if (targetUser == null) {

	response.sendRedirect(ctx + "/schedules");

	return;

}

long targetUserId = targetUser.getUserId();

/* =========================================================

   2. 회원 정보

========================================================= */

String loginId = targetUser.getLoginId() == null ? "" : targetUser.getLoginId();

String nickname = targetUser.getNickName() == null ? "" : targetUser.getNickName();

String name = targetUser.getName() == null ? "" : targetUser.getName();

String bio = targetUser.getBio() == null ? "" : targetUser.getBio();

String region = targetUser.getRegion() == null ? "" : targetUser.getRegion();

String profileImg = targetUser.getProfileImg() == null ? "" : targetUser.getProfileImg();

/* 화면 표시 이름 */

String displayName = nickname.isEmpty() ? loginId : nickname;

/* =========================================================

   3. 프로필 이미지 경로

========================================================= */

String profilePath = (String) application.getAttribute("profilePath");

if (profilePath == null || profilePath.trim().isEmpty()) {

	profilePath = "/uploads/profile";

}

/* =========================================================

   4. 상대방이 작성한 공개 일정

========================================================= */

List<ProfileFeedDto> itineraries = (List<ProfileFeedDto>) request.getAttribute("itineraries");

if (itineraries == null) {

	itineraries = new ArrayList<ProfileFeedDto>();

}

/* =========================================================

   5. 상대방이 북마크한 공개 일정

========================================================= */

List<ProfileFeedDto> bookmarkedItineraries = (List<ProfileFeedDto>) request.getAttribute("bookmarkedItineraries");

if (bookmarkedItineraries == null) {

	bookmarkedItineraries = new ArrayList<ProfileFeedDto>();

}

/* =========================================================

   6. 상대방이 좋아요한 공개 일정

========================================================= */

List<ProfileFeedDto> likedItineraries = (List<ProfileFeedDto>) request.getAttribute("likedItineraries");

if (likedItineraries == null) {

	likedItineraries = new ArrayList<ProfileFeedDto>();

}

/* =========================================================

   7. 공개 설정

========================================================= */

Boolean showLikedAttr = (Boolean) request.getAttribute("showLikedItinerary");

Boolean showBookmarkedAttr = (Boolean) request.getAttribute("showBookmarkedItinerary");

boolean showLikedItinerary = Boolean.TRUE.equals(showLikedAttr);

boolean showBookmarkedItinerary = Boolean.TRUE.equals(showBookmarkedAttr);

Boolean privateProfileAttr = (Boolean) request.getAttribute("privateProfile");

boolean privateProfile = Boolean.TRUE.equals(privateProfileAttr);

/* =========================================================

   8. 프로필 상단 통계

========================================================= */

Integer postCount = (Integer) request.getAttribute("postCount");

Integer likeCount = (Integer) request.getAttribute("likeCount");

Integer bookmarkCount = (Integer) request.getAttribute("bookmarkCount");

if (postCount == null) {

	postCount = itineraries.size();

}

if (likeCount == null) {

	likeCount = 0;

}

if (bookmarkCount == null) {

	bookmarkCount = 0;

}

Boolean userPostsHasMoreAttr =
        (Boolean) request.getAttribute("userPostsHasMore");

Boolean userSavedHasMoreAttr =
        (Boolean) request.getAttribute("userSavedHasMore");

Boolean userLikedHasMoreAttr =
        (Boolean) request.getAttribute("userLikedHasMore");

boolean userPostsHasMore =
        Boolean.TRUE.equals(userPostsHasMoreAttr);

boolean userSavedHasMore =
        Boolean.TRUE.equals(userSavedHasMoreAttr);

boolean userLikedHasMore =
        Boolean.TRUE.equals(userLikedHasMoreAttr);

%>

<!DOCTYPE html>

<html lang="ko">

<head>

<meta charset="UTF-8">

<meta name="viewport" content="width=device-width, initial-scale=1">

<title><%=displayName%> · Planb</title>

<!-- 공통 CSS -->

<jsp:include page="/common/headStyles.jsp" />

<!-- 프로필 CSS -->

<link rel="stylesheet"

	href="<%=ctx%>/view/assets/css/auth/userProfile.css">
<link rel="stylesheet" href="<%=ctx%>/view/assets/css/auth/profileFeed.css?v=2">


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

@keyframes profile-feed-spin {
    to {
        transform: rotate(360deg);
    }
}
</style>

</head>

<body class="site-shell">

	<!-- =========================================================

     공통 Header

========================================================= -->

	<jsp:include page="/common/header.jsp" />

	<!-- =========================================================

     프로필 페이지

========================================================= -->

	<div class="page profile-page">

		<!-- ==========================================

         뒤로 가기

    =========================================== -->

		<button type="button" class="back-link" id="profileBackButton">

			<svg width="16" height="16" viewBox="0 0 24 24" fill="none"

				stroke="currentColor" stroke-width="1.7" stroke-linecap="round"

				stroke-linejoin="round" aria-hidden="true">

            <path d="m15 18-6-6 6-6" />

        </svg>

			뒤로 가기

		</button>

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

							alt="<%=displayName%> 프로필 이미지"

							onerror="

                            this.style.display='none';

                            this.nextElementSibling.style.display='flex';

                        ">

						<!-- 이미지 로딩 실패 시 -->

						<span class="profile-default-avatar" style="display: none;">

							<svg width="48" height="48" viewBox="0 0 24 24" fill="none"

								stroke="currentColor" stroke-width="1.5">

                            <circle cx="12" cy="8" r="4" />

                            <path d="M4 21c0-4.3 3.6-7 8-7s8 2.7 8 7" />

                        </svg>

						</span>

						<%

						} else {

						%>

						<!-- 프로필 이미지가 없는 경우 -->

						<span class="profile-default-avatar"> <svg width="48"

								height="48" viewBox="0 0 24 24" fill="none"

								stroke="currentColor" stroke-width="1.5">

                            <circle cx="12" cy="8" r="4" />

                            <path d="M4 21c0-4.3 3.6-7 8-7s8 2.7 8 7" />

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

									<%=displayName%>

								</h1>

								<% if (privateProfile) { %>
								<span class="profile-private-badge"><svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="5" y="10" width="14" height="10" rx="2"/><path d="M8 10V7a4 4 0 0 1 8 0v3"/></svg> 비공개 계정</span>
								<% } %>

							</div>

							<!-- 실명 -->

							<%

							if (!privateProfile && !name.isEmpty()) {

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

                         신고 버튼

                    ========================== -->

						<div class="profile-actions profile-actions--report">

							<button type="button" class="profile-report-btn"

								id="openReportModal">

								<svg width="14" height="14" viewBox="0 0 24 24" fill="none"

									stroke="currentColor" stroke-width="1.7" stroke-linecap="round"

									stroke-linejoin="round" aria-hidden="true">

                                <path d="M5 21V4" />

                                <path d="M5 4h10.5l-1.5 3 1.5 3H5" />

                            </svg>

								<span> 신고 </span>

							</button>

						</div>

					</div>

					<%

					if (!privateProfile) {

					%>

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

					<%

					}

					%>

				</div>

			</div>

		</section>

		<%

		if (privateProfile) {

		%>

		<!-- ==========================================
		     비공개 계정: 피드 대신 잠금 영역
		=========================================== -->
		<div class="profile-tabs profile-tabs--locked" aria-hidden="true">
			<span class="active"><svg class="profile-tab-icon" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="3.5" y="3.5" width="7" height="7" rx="1.5"/><rect x="13.5" y="3.5" width="7" height="7" rx="1.5"/><rect x="3.5" y="13.5" width="7" height="7" rx="1.5"/><rect x="13.5" y="13.5" width="7" height="7" rx="1.5"/></svg> <span> 게시물 </span></span>
		</div>

		<section class="profile-locked">
			<div class="profile-locked-card">
				<div class="profile-locked-icon"><svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="5" y="10" width="14" height="10" rx="2"/><path d="M8 10V7a4 4 0 0 1 8 0v3"/></svg></div>
				<h2>비공개 계정입니다</h2>
				<p>이 사용자는 피드를 비공개로 설정했어요.<br>여행 일정과 활동 내역은 볼 수 없습니다.</p>
			</div>
		</section>

		<%

		} else {

		%>

		<!-- ==========================================

         프로필 탭

    =========================================== -->

		<div class="profile-tabs">

			<!-- 게시물 -->

			<button type="button" class="active" data-profile-tab="posts">

				<svg class="profile-tab-icon" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="3.5" y="3.5" width="7" height="7" rx="1.5"/><rect x="13.5" y="3.5" width="7" height="7" rx="1.5"/><rect x="3.5" y="13.5" width="7" height="7" rx="1.5"/><rect x="13.5" y="13.5" width="7" height="7" rx="1.5"/></svg> <span> 게시물 </span>

			</button>

			<!-- 북마크 공개 설정 ON -->

			<%

			if (showBookmarkedItinerary) {

			%>

			<button type="button" data-profile-tab="saved">

				<svg class="profile-tab-icon" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M6 4.5h12v16l-6-4-6 4z"/></svg> <span> 북마크한 게시글 </span>

			</button>

			<%

			}

			%>

			<!-- 좋아요 공개 설정 ON -->

			<%

			if (showLikedItinerary) {

			%>

			<button type="button" data-profile-tab="liked">

				<svg class="profile-tab-icon" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M19 14c1.49-1.46 3-3.21 3-5.5A5.5 5.5 0 0 0 16.5 3c-1.76 0-3 .5-4.5 2-1.5-1.5-2.74-2-4.5-2A5.5 5.5 0 0 0 2 8.5c0 2.3 1.5 4.05 3 5.5l7 7Z"/></svg> <span> 좋아요한 게시글 </span>

			</button>

			<%

			}

			%>

		</div>

		<!-- ==========================================

         프로필 컨텐츠

    =========================================== -->

		<main class="profile-content">

			<!-- ======================================

             게시물

        ======================================= -->

			<div data-profile-panel="posts">

				<div class="feed-grid" data-feed-grid="posts">

					<%

					if (!itineraries.isEmpty()) {

						for (ProfileFeedDto item : itineraries) {

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

							%> <img src="<%=ctx%><%=thumbnail%>" alt="<%=item.getTitle()%>"

							loading="lazy"> <%

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

							</span> <span class="feed-hover-stats"> <span> <svg class="feed-stat-icon" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M19 14c1.49-1.46 3-3.21 3-5.5A5.5 5.5 0 0 0 16.5 3c-1.76 0-3 .5-4.5 2-1.5-1.5-2.74-2-4.5-2A5.5 5.5 0 0 0 2 8.5c0 2.3 1.5 4.05 3 5.5l7 7Z"/></svg> <%=item.getLikeCount()%>

								</span> <span> <svg class="feed-stat-icon" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M6 4.5h12v16l-6-4-6 4z"/></svg> <%=item.getBookmarkCount()%>

								</span> <span> <svg class="feed-stat-icon" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M7.9 20A9 9 0 1 0 4 16.1L2 22Z"/></svg> <%=item.getCommentCount()%>

								</span>

							</span>

						</span>

						</a>

					</div>

					<%

					}

					} else {

					%>

					<div class="empty-state">공개된 여행 일정이 없습니다.</div>

					<%

					}

					%>


				</div>

				<div class="profile-feed-sentinel"
					data-feed-sentinel
					data-scope="user"
					data-type="posts"
					data-user-id="<%=targetUserId%>"
					data-offset="<%=itineraries.size()%>"
					data-has-more="<%=userPostsHasMore%>"></div>

				<div class="profile-feed-loading"
					data-feed-loading="posts"
					hidden>
					불러오는 중...
				</div>

			</div>

			<!-- ======================================

             북마크

        ======================================= -->

			<%

			if (showBookmarkedItinerary) {

			%>

			<div data-profile-panel="saved" class="jsp-hidden">

				<div class="feed-grid" data-feed-grid="saved">

					<%

					if (!bookmarkedItineraries.isEmpty()) {

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

							%> <img src="<%=ctx%><%=thumbnail%>" alt="<%=item.getTitle()%>"

							loading="lazy"> <%

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

							</span> <span class="feed-hover-stats"> <span> <svg class="feed-stat-icon" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M19 14c1.49-1.46 3-3.21 3-5.5A5.5 5.5 0 0 0 16.5 3c-1.76 0-3 .5-4.5 2-1.5-1.5-2.74-2-4.5-2A5.5 5.5 0 0 0 2 8.5c0 2.3 1.5 4.05 3 5.5l7 7Z"/></svg> <%=item.getLikeCount()%>

								</span> <span> <svg class="feed-stat-icon" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M6 4.5h12v16l-6-4-6 4z"/></svg> <%=item.getBookmarkCount()%>

								</span> <span> <svg class="feed-stat-icon" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M7.9 20A9 9 0 1 0 4 16.1L2 22Z"/></svg> <%=item.getCommentCount()%>

								</span>

							</span>

						</span>

						</a>

					</div>

					<%

					}

					} else {

					%>

					<div class="empty-state">공개된 북마크 일정이 없습니다.</div>

					<%

					}

					%>


				</div>

				<div class="profile-feed-sentinel"
					data-feed-sentinel
					data-scope="user"
					data-type="saved"
					data-user-id="<%=targetUserId%>"
					data-offset="<%=bookmarkedItineraries.size()%>"
					data-has-more="<%=userSavedHasMore%>"></div>

				<div class="profile-feed-loading"
					data-feed-loading="saved"
					hidden>
					불러오는 중...
				</div>

			</div>

			<%

			}

			%>

			<!-- ======================================

             좋아요

        ======================================= -->

			<%

			if (showLikedItinerary) {

			%>

			<div data-profile-panel="liked" class="jsp-hidden">

				<div class="feed-grid" data-feed-grid="liked">

					<%

					if (!likedItineraries.isEmpty()) {

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

							%> <img src="<%=ctx%><%=thumbnail%>" alt="<%=item.getTitle()%>"

							loading="lazy"> <%

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

							</span> <span class="feed-hover-stats"> <span> <svg class="feed-stat-icon" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M19 14c1.49-1.46 3-3.21 3-5.5A5.5 5.5 0 0 0 16.5 3c-1.76 0-3 .5-4.5 2-1.5-1.5-2.74-2-4.5-2A5.5 5.5 0 0 0 2 8.5c0 2.3 1.5 4.05 3 5.5l7 7Z"/></svg> <%=item.getLikeCount()%>

								</span> <span> <svg class="feed-stat-icon" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M6 4.5h12v16l-6-4-6 4z"/></svg> <%=item.getBookmarkCount()%>

								</span> <span> <svg class="feed-stat-icon" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M7.9 20A9 9 0 1 0 4 16.1L2 22Z"/></svg> <%=item.getCommentCount()%>

								</span>

							</span>

						</span>

						</a>

					</div>

					<%

					}

					} else {

					%>

					<div class="empty-state">공개된 좋아요 일정이 없습니다.</div>

					<%

					}

					%>


				</div>

				<div class="profile-feed-sentinel"
					data-feed-sentinel
					data-scope="user"
					data-type="liked"
					data-user-id="<%=targetUserId%>"
					data-offset="<%=likedItineraries.size()%>"
					data-has-more="<%=userLikedHasMore%>"></div>

				<div class="profile-feed-loading"
					data-feed-loading="liked"
					hidden>
					불러오는 중...
				</div>

			</div>

			<%

			}

			%>

		</main>

		<%

		}

		%>

	</div>

	<!-- =========================================================

     신고 모달

========================================================= -->

	<div class="jsp-modal report-backdrop" id="reportModal">

		<div class="report-modal" role="dialog" aria-modal="true"

			aria-labelledby="profileReportTitle">

			<form id="profileReportForm">

				<!-- 신고 대상 -->

				<input type="hidden" name="targetType" value="USER"> <input

					type="hidden" name="targetId" value="<%=targetUserId%>">

				<!-- =========================

                 모달 헤더

            ========================== -->

				<div class="report-modal-header">

					<div>

						<h3 id="profileReportTitle">신고하기</h3>

						<p>

							<strong> <%=displayName%>

							</strong> 님의 프로필에서 문제가 되는 항목을 선택해 주세요.

						</p>

					</div>

					<button type="button" class="report-close-btn"

						id="closeReportModal" aria-label="신고 창 닫기">

						<svg width="19" height="19" viewBox="0 0 24 24" fill="none"

							stroke="currentColor" stroke-width="1.7" stroke-linecap="round"

							stroke-linejoin="round">

                        <path d="M18 6 6 18M6 6l12 12" />

                    </svg>

					</button>

				</div>

				<!-- =========================

                 신고 내용

            ========================== -->

				<div class="report-modal-body">

					<fieldset class="report-reason-group">

						<legend>

							신고 사유를 선택해 주세요 <span> * </span>

						</legend>

						<label class="report-radio-row"> <input type="radio"

							name="profileReportReason" value="NICKNAME" required> <span

							class="report-radio-ui" aria-hidden="true"> </span> <span>

								닉네임 또는 아이디가 부적절해요 </span>

						</label> <label class="report-radio-row"> <input type="radio"

							name="profileReportReason" value="PROFILE_IMAGE"> <span

							class="report-radio-ui" aria-hidden="true"> </span> <span>

								프로필 사진이 부적절해요 </span>

						</label> <label class="report-radio-row"> <input type="radio"

							name="profileReportReason" value="CONTENT"> <span

							class="report-radio-ui" aria-hidden="true"> </span> <span>

								게시글 또는 게시물 내용이 부적절해요 </span>

						</label> <label class="report-radio-row"> <input type="radio"

							name="profileReportReason" value="SPAM"> <span

							class="report-radio-ui" aria-hidden="true"> </span> <span>

								스팸 또는 광고 계정이에요 </span>

						</label> <label class="report-radio-row"> <input type="radio"

							name="profileReportReason" value="IMPERSONATION"> <span

							class="report-radio-ui" aria-hidden="true"> </span> <span>

								다른 사람을 사칭하고 있어요 </span>

						</label> <label class="report-radio-row"> <input type="radio"

							name="profileReportReason" value="PRIVACY"> <span

							class="report-radio-ui" aria-hidden="true"> </span> <span>

								개인정보 노출 또는 도용이 의심돼요 </span>

						</label> <label class="report-radio-row"> <input type="radio"

							name="profileReportReason" value="ETC"> <span

							class="report-radio-ui" aria-hidden="true"> </span> <span>

								기타 </span>

						</label>

					</fieldset>

					<!-- 상세 내용 -->

					<label class="report-detail-label" for="profileReportDetail">

						상세 내용 <span> (선택) </span>

					</label>

					<textarea id="profileReportDetail" name="detail" maxlength="300"

						placeholder="신고 사유에 대해 자세히 설명해 주세요."></textarea>

					<div class="report-char-count" id="profileReportCharCount">

						0/300</div>

				</div>

				<!-- =========================

                 모달 하단 버튼

            ========================== -->

				<div class="report-modal-footer">

					<button type="button" class="report-cancel-btn"

						id="cancelReportModal">취소</button>

					<button type="submit" class="report-submit-btn">신고하기</button>

				</div>

			</form>

		</div>

	</div>

	<!-- =========================================================

     Footer

========================================================= -->

	<jsp:include page="/common/footer.jsp" />

	<!-- =========================================================

     JS

========================================================= -->

	<script>

document.addEventListener(

    "DOMContentLoaded",

    function() {

        const ctx = "<%=ctx%>";

        /* =====================================

           뒤로 가기

        ====================================== */

        const backButton =

            document.getElementById(

                "profileBackButton"

            );

        if (backButton) {

            backButton.addEventListener(

                "click",

                function() {

                    if (window.history.length > 1) {

                        window.history.back();

                    } else {

                        window.location.href =

                            ctx + "/schedules";

                    }

                }

            );

        }

        /* =====================================

           프로필 탭

        ====================================== */

        const tabs =

            document.querySelectorAll(

                "[data-profile-tab]"

            );

        const panels =

            document.querySelectorAll(

                "[data-profile-panel]"

            );

        tabs.forEach(

            function(tab) {

                tab.addEventListener(

                    "click",

                    function() {

                        const target =

                            tab.dataset.profileTab;

                        /*

                         * 모든 탭 비활성화

                         */

                        tabs.forEach(

                            function(item) {

                                item.classList.remove(

                                    "active"

                                );

                            }

                        );

                        /*

                         * 선택한 탭 활성화

                         */

                        tab.classList.add(

                            "active"

                        );

                        /*

                         * 패널 전환

                         */

                        panels.forEach(

                            function(panel) {

                                if (

                                    panel.dataset.profilePanel

                                    === target

                                ) {

                                    panel.classList.remove(

                                        "jsp-hidden"

                                    );

                                } else {

                                    panel.classList.add(

                                        "jsp-hidden"

                                    );

                                }

                            }

                        );

                    }

                );

            }

        );

        /* =====================================

           신고 모달

        ====================================== */

        const reportModal =

            document.getElementById(

                "reportModal"

            );

        const openReportModal =

            document.getElementById(

                "openReportModal"

            );

        const closeReportModal =

            document.getElementById(

                "closeReportModal"

            );

        const cancelReportModal =

            document.getElementById(

                "cancelReportModal"

            );

        function openModal() {

            if (!reportModal) {

                return;

            }

            reportModal.classList.add(

                "open"

            );

            document.body.style.overflow =

                "hidden";

        }

        function closeModal() {

            if (!reportModal) {

                return;

            }

            reportModal.classList.remove(

                "open"

            );

            document.body.style.overflow =

                "";

        }

        if (openReportModal) {

            openReportModal.addEventListener(

                "click",

                openModal

            );

        }

        if (closeReportModal) {

            closeReportModal.addEventListener(

                "click",

                closeModal

            );

        }

        if (cancelReportModal) {

            cancelReportModal.addEventListener(

                "click",

                closeModal

            );

        }

        /*

         * 모달 바깥 클릭

         */

        if (reportModal) {

            reportModal.addEventListener(

                "click",

                function(event) {

                    if (

                        event.target

                        === reportModal

                    ) {

                        closeModal();

                    }

                }

            );

        }

        /*

         * ESC 키

         */

        document.addEventListener(

            "keydown",

            function(event) {

                if (

                    event.key === "Escape"

                    && reportModal

                    && reportModal.classList.contains(

                        "open"

                    )

                ) {

                    closeModal();

                }

            }

        );

        /* =====================================

           신고 상세내용 글자 수

        ====================================== */

        const detail =

            document.getElementById(

                "profileReportDetail"

            );

        const charCount =

            document.getElementById(

                "profileReportCharCount"

            );

        if (detail && charCount) {

            detail.addEventListener(

                "input",

                function() {

                    charCount.textContent =

                        detail.value.length

                        + "/300";

                }

            );

        }

        /* =====================================

           신고 Form

        ====================================== */

        const reportForm =

            document.getElementById(

                "profileReportForm"

            );

        if (reportForm) {

            reportForm.addEventListener(

                "submit",

                function(event) {

                    event.preventDefault();

                    /* =================================

                       신고 사유

                    ================================== */

                    const checked =

                        reportForm.querySelector(

                            'input[name="profileReportReason"]:checked'

                        );

                    if (!checked) {

                        alert(

                            "신고 사유를 선택해 주세요."

                        );

                        return;

                    }

                    /* =================================

                       전송 데이터

                       FormData 사용하지 않음.

                       Servlet의 request.getParameter()

                       로 바로 받을 수 있도록

                       x-www-form-urlencoded 방식 사용

                    ================================== */

                    const params =

                        new URLSearchParams();

                    /*

                     * 신고 대상 종류

                     */

                    params.set(

                        "targetType",

                        "USER"

                    );

                    /*

                     * 현재 보고 있는 사용자 번호

                     *

                     * 예:

                     * userProfile?userId=17

                     *

                     * targetId = 17

                     */

                    params.set(

                        "targetId",

                        "<%=targetUserId%>"

                    );

                    /*

                     * 신고 사유 코드

                     *

                     * NICKNAME

                     * PROFILE_IMAGE

                     * CONTENT

                     * SPAM

                     * IMPERSONATION

                     * PRIVACY

                     * ETC

                     */

                    params.set(

                        "profileReportReason",

                        checked.value

                    );

                    /*

                     * 상세 내용

                     */

                    params.set(

                        "detail",

                        detail

                            ? detail.value.trim()

                            : ""

                    );

                    /* =================================

                       전송값 확인

                    ================================== */

                    console.log(

                        "신고 대상 유형:",

                        params.get(

                            "targetType"

                        )

                    );

                    console.log(

                        "신고 대상 ID:",

                        params.get(

                            "targetId"

                        )

                    );

                    console.log(

                        "신고 사유:",

                        params.get(

                            "profileReportReason"

                        )

                    );

                    console.log(

                        "상세 내용:",

                        params.get(

                            "detail"

                        )

                    );

                    /* =================================

                       신고 요청

                    ================================== */

                    fetch(

                        ctx + "/report/user",

                        {

                            method:

                                "POST",

                            headers: {

                                "Content-Type":

                                    "application/x-www-form-urlencoded; charset=UTF-8"

                            },

                            body:

                                params.toString()

                        }

                    )

                    /* =================================

                       서버 응답

                    ================================== */

                    .then(

                        function(response) {

                            return response

                                .text()

                                .then(

                                    function(text) {

                                        console.log(

                                            "신고 응답 status:",

                                            response.status

                                        );

                                        console.log(

                                            "신고 응답 body:",

                                            text

                                        );

                                        let data;

                                        try {

                                            data =

                                                JSON.parse(

                                                    text

                                                );

                                        } catch (e) {

                                            console.error(

                                                "JSON이 아닌 응답:",

                                                text

                                            );

                                            throw new Error(

                                                "서버가 JSON 대신 오류 페이지를 반환했습니다."

                                            );

                                        }

                                        return {

                                            ok:

                                                response.ok,

                                            status:

                                                response.status,

                                            data:

                                                data

                                        };

                                    }

                                );

                        }

                    )

                    /* =================================

                       결과 처리

                    ================================== */

                    .then(

                        function(result) {

                            /*

                             * =========================

                             * 신고 성공

                             * =========================

                             */

                            if (

                                result.ok

                                && result.data.success

                            ) {

                                alert(

                                    result.data.message

                                    || "신고가 접수되었습니다."

                                );

                                /*

                                 * 신고 폼 초기화

                                 */

                                reportForm.reset();

                                /*

                                 * 글자수 초기화

                                 */

                                if (charCount) {

                                    charCount.textContent =

                                        "0/300";

                                }

                                /*

                                 * 신고 모달 닫기

                                 */

                                closeModal();

                                return;

                            }

                            /*

                             * =========================

                             * 로그인 필요

                             * =========================

                             */

                            if (

                                result.status === 401

                            ) {

                                alert(

                                    result.data.message

                                    || "로그인이 필요합니다."

                                );

                                return;

                            }

                            /*

                             * =========================

                             * 잘못된 요청

                             * =========================

                             */

                            if (

                                result.status === 400

                            ) {

                                alert(

                                    result.data.message

                                    || "신고 정보를 확인해 주세요."

                                );

                                return;

                            }

                            /*

                             * =========================

                             * 중복 신고

                             * =========================

                             */

                            if (

                                result.status === 409

                            ) {

                                alert(

                                    result.data.message

                                    || "이미 신고한 계정입니다."

                                );

                                closeModal();

                                return;

                            }

                            /*

                             * =========================

                             * 서버 오류

                             * =========================

                             */

                            if (

                                result.status === 500

                            ) {

                                alert(

                                    result.data.message

                                    || "신고 처리 중 서버 오류가 발생했습니다."

                                );

                                return;

                            }

                            /*

                             * =========================

                             * 기타 오류

                             * =========================

                             */

                            alert(

                                result.data.message

                                || "신고 처리에 실패했습니다."

                            );

                        }

                    )

                    /* =================================

                       네트워크 / JS 오류

                    ================================== */

                    .catch(

                        function(error) {

                            console.error(

                                "신고 요청 오류:",

                                error

                            );

                            alert(

                                error.message

                                || "신고 처리 중 오류가 발생했습니다."

                            );

                        }

                    );

                }

            );

        }

    }

);

</script>


<script>
document.addEventListener("DOMContentLoaded", function() {

    const feedSentinels =
        document.querySelectorAll("[data-feed-sentinel]");

    const feedObserver =
        new IntersectionObserver(
            function(entries) {

                entries.forEach(function(entry) {

                    if (!entry.isIntersecting) {
                        return;
                    }

                    loadMoreProfileFeed(entry.target);
                });
            },
            {
                root: null,
                rootMargin: "350px 0px",
                threshold: 0
            }
        );

    feedSentinels.forEach(function(sentinel) {

        if (sentinel.dataset.hasMore === "true") {

            feedObserver.observe(sentinel);
        }
    });

    async function loadMoreProfileFeed(sentinel) {

        if (sentinel.dataset.loading === "true") {
            return;
        }

        if (sentinel.dataset.hasMore !== "true") {

            feedObserver.unobserve(sentinel);
            return;
        }

        sentinel.dataset.loading = "true";

        const type =
            sentinel.dataset.type;

        const offset =
            Number(
                sentinel.dataset.offset
                ||
                0
            );

        const panel =
            sentinel.closest("[data-profile-panel]");

        if (!panel) {

            sentinel.dataset.loading = "false";
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

        const loading =
            panel.querySelector(
                '[data-feed-loading="'
                +
                type
                +
                '"]'
            );

        if (!grid) {

            sentinel.dataset.loading = "false";
            return;
        }

        if (loading) {

            loading.hidden = false;
        }

        try {

            const params =
                new URLSearchParams();

            params.set("scope", "user");
            params.set("type", type);
            params.set(
                "userId",
                sentinel.dataset.userId
            );
            params.set(
                "offset",
                String(offset)
            );

            const response =
                await fetch(
                    "<%=ctx%>/profile/feed/more?"
                    +
                    params.toString(),
                    {
                        method: "GET",
                        headers: {
                            "Accept": "text/html"
                        },
                        cache: "no-store"
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

            if (html.trim().length > 0) {

                grid.insertAdjacentHTML(
                    "beforeend",
                    html
                );
            }

            sentinel.dataset.offset =
                String(
                    offset
                    +
                    loadedCount
                );

            sentinel.dataset.hasMore =
                String(hasMore);

            if (!hasMore) {

                feedObserver.unobserve(
                    sentinel
                );
            }

        } catch (error) {

            console.error(
                "[USER PROFILE INFINITE SCROLL]",
                error
            );

        } finally {

            sentinel.dataset.loading =
                "false";

            if (loading) {

                loading.hidden = true;
            }
        }
    }
});
</script>

</body>

</html>