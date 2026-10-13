<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8" import="dto.member.UserDto"%>

<%
request.setAttribute("activePage", "profile");

/*
 * settingsSidebar.jsp에서 현재 메뉴를 활성화하기 위한 값
 */
request.setAttribute("settingsPage", "profile");

String ctx = request.getContextPath();

UserDto user = (UserDto) session.getAttribute("user");

if (user == null) {

	response.sendRedirect(ctx + "/auth/login");

	return;
}

/* =========================================================
   회원 정보
   ========================================================= */

String loginId = user.getLoginId() == null ? "" : user.getLoginId();

String nickname = user.getNickName() == null ? "" : user.getNickName();

String name = user.getName() == null ? "" : user.getName();

String email = user.getEmail() == null ? "" : user.getEmail();

String phone = user.getPhone() == null ? "" : user.getPhone();

String region = user.getRegion() == null ? "" : user.getRegion();

String postcode = user.getPostcode() == null ? "" : user.getPostcode();

String address = user.getAddress() == null ? "" : user.getAddress();

String addressDetail = user.getAddressDetail() == null ? "" : user.getAddressDetail();

String bio = user.getBio() == null ? "" : user.getBio();

String profileImg = user.getProfileImg() == null ? "" : user.getProfileImg();

String birthDate = user.getBirthDate() == null ? "" : user.getBirthDate().toString();

/* =========================================================
   프로필 이미지 URL 경로

   CommonFilter에서:
   profilePath = /profiles
   ========================================================= */

String profilePath = (String) application.getAttribute("profilePath");

if (profilePath == null || profilePath.trim().isEmpty()) {

	profilePath = "/profiles";
}
%>


<!DOCTYPE html>

<html lang="ko">

<head>

<meta charset="UTF-8">

<meta name="viewport" content="width=device-width, initial-scale=1">

<title>프로필 설정</title>


<!-- 공통 CSS -->
<jsp:include page="/common/headStyles.jsp" />


<!-- 설정 CSS -->
<link rel="stylesheet"
	href="<%=ctx%>/view/assets/css/setting/settings.css">

</head>



<body class="site-shell">


	<!-- =========================================================
     공통 Header
========================================================= -->

	<jsp:include page="/common/header.jsp" />



	<div class="settings-page">

		<div class="settings-shell">


			<!-- =================================================
             공통 설정 사이드바
        ================================================== -->

			<jsp:include page="/common/settingsSidebar.jsp" />



			<!-- =================================================
             메인 영역
        ================================================== -->

			<main class="settings-main">

				<div class="settings-content">


					<!-- =========================================
                     페이지 제목
                ========================================== -->

					<header class="settings-title">

						<span class="settings-eyebrow"> SETTINGS </span>

						<h1>프로필 설정</h1>

						<p>회원 기본 정보와 프로필 정보를 관리합니다.</p>

					</header>



					<!-- =========================================
                     프로필 수정 Form
                ========================================== -->

					<form id="profileEditForm" action="<%=ctx%>/profile/edit"
						method="post" enctype="multipart/form-data">



						<!-- =====================================
                         프로필 사진
                    ====================================== -->

						<section class="settings-panel settings-profile-panel">

							<div class="settings-profile-row">



								<!-- =============================
                                 프로필 이미지 미리보기
                            ============================== -->

								<div class="settings-avatar">


									<!--
                                    기존 이미지가 있든 없든
                                    img 태그는 항상 존재시킴.

                                    그래야 사진 선택 시
                                    바로 미리보기를 넣을 수 있음.
                                -->
									<img id="profilePreview" <%if (!profileImg.isEmpty()) {%>
										src="<%=ctx%><%=profilePath%>/<%=profileImg%>" <%}%>
										alt="<%=nickname%> 프로필 이미지"
										style="
                                        display:
                                        <%=profileImg.isEmpty() ? "none" : "block"%>;
                                    ">


									<!--
                                    프로필 이미지가 없을 때
                                    기본 아이콘
                                -->
									<svg id="profileDefaultAvatar" width="28" height="28"
										viewBox="0 0 24 24" fill="none" stroke="currentColor"
										stroke-width="1.6"
										style="
                                        display:
                                        <%=profileImg.isEmpty() ? "block" : "none"%>;
                                    ">

                                    <circle cx="12" cy="8" r="4" />

                                    <path
											d="M4 21c0-4.3 3.6-7 8-7s8 2.7 8 7" />

                                </svg>


								</div>



								<!-- =============================
                                 이름 / 닉네임
                            ============================== -->

								<div class="settings-profile-copy">

									<strong> <%=nickname%>
									</strong> <span> <%=name%>
									</span>

								</div>



								<!-- =============================
                                 파일 선택 버튼
                            ============================== -->

								<label class="settings-photo-label"> 프로필 사진 변경 <input
									type="file" id="profileImageInput" name="profileImage"
									accept="image/jpeg,image/png,image/webp,image/gif">

								</label>


							</div>

						</section>



						<!-- =====================================
                         회원 정보
                    ====================================== -->

						<section class="settings-panel settings-form-panel">

							<div class="settings-form settings-form-grid">



								<!-- =============================
                                 로그인 아이디
                            ============================== -->

								<label class="settings-field"> <span
									class="settings-field-label"> 로그인 아이디 </span> <input
									type="text" value="<%=loginId%>" readonly> <small>
										로그인 아이디는 이 화면에서 변경하지 않습니다. </small>

								</label>



								<!-- =============================
                                 이름
                            ============================== -->

								<label class="settings-field"> <span
									class="settings-field-label"> 이름 </span> <input type="text"
									name="name" maxlength="50" value="<%=name%>" required>

								</label>



								<!-- =============================
                                 닉네임
                            ============================== -->

								<label class="settings-field"> <span
									class="settings-field-label"> 닉네임 </span> <input type="text"
									name="nickname" maxlength="50" value="<%=nickname%>" required>

								</label>



								<!-- =============================
                                 생년월일
                            ============================== -->

								<label class="settings-field"> <span
									class="settings-field-label"> 생년월일 </span> <input type="date"
									name="birthDate" value="<%=birthDate%>">

								</label>



								<!-- =============================
                                 이메일
                            ============================== -->

								<label class="settings-field"> <span
									class="settings-field-label"> 이메일 </span> <input type="email"
									name="email" maxlength="100" value="<%=email%>" readonly>

								</label>



								<!-- =============================
                                 전화번호
                            ============================== -->

								<label class="settings-field"> <span
									class="settings-field-label"> 전화번호 </span> <input type="tel"
									id="phone" name="phone" maxlength="20" value="<%=phone%>"
									required>

								</label>



								<!-- =============================
                                 지역
                            ============================== -->

								<label class="settings-field"> <span
									class="settings-field-label"> 지역 </span> <input type="text"
									name="region" maxlength="100" value="<%=region%>">

								</label>



								<!-- =============================
                                 우편번호
                            ============================== -->

								<label class="settings-field"> <span
									class="settings-field-label"> 우편번호 </span> <input type="text"
									name="postcode" maxlength="100" value="<%=postcode%>" required>

								</label>



								<!-- =============================
                                 주소
                            ============================== -->

								<label class="settings-field full"> <span
									class="settings-field-label"> 주소 </span> <input type="text"
									name="address" maxlength="200" value="<%=address%>" required>

								</label>



								<!-- =============================
                                 상세주소
                            ============================== -->

								<label class="settings-field full"> <span
									class="settings-field-label"> 상세주소 </span> <input type="text"
									name="addressDetail" maxlength="200" value="<%=addressDetail%>">

								</label>



								<!-- =============================
                                 소개
                            ============================== -->

								<label class="settings-field full"> <span
									class="settings-field-label"> 소개 </span> <textarea name="bio"
										rows="4" maxlength="300"><%=bio%></textarea>

								</label>


							</div>

						</section>



						<!-- =====================================
                         저장 버튼
                    ====================================== -->

						<div class="settings-actions">

							<button class="settings-primary-btn" type="submit">변경사항
								저장</button>

						</div>


					</form>


				</div>

			</main>


		</div>

	</div>



	<!-- =========================================================
     Footer
========================================================= -->

	<jsp:include page="/common/footer.jsp" />



	<!-- =========================================================
     프로필 사진 즉시 미리보기
========================================================= -->

	<script>
		document
				.addEventListener(
						"DOMContentLoaded",
						function() {

							var profileImageInput = document
									.getElementById("profileImageInput");

							var profilePreview = document
									.getElementById("profilePreview");

							var profileDefaultAvatar = document
									.getElementById("profileDefaultAvatar");

							/*
							 * 요소를 찾지 못하면 종료
							 */
							if (!profileImageInput || !profilePreview
									|| !profileDefaultAvatar) {

								return;
							}

							/*
							 * 현재 프로필 이미지 저장
							 *
							 * 잘못된 이미지를 선택했을 때
							 * 기존 프로필 사진으로 복구하기 위해 사용.
							 */
							var originalSrc = profilePreview
									.getAttribute("src");

							var originalPreviewDisplay = profilePreview.style.display;

							var originalDefaultDisplay = profileDefaultAvatar.style.display;

							/* =====================================================
							   파일 선택
							====================================================== */

							profileImageInput
									.addEventListener(
											"change",
											function() {

												/*
												 * 파일 선택 취소
												 */
												if (!this.files
														|| this.files.length === 0) {

													restoreProfilePreview();

													return;
												}

												var file = this.files[0];

												/* =============================================
												   이미지 파일인지 검사
												============================================== */

												if (!file.type
														|| file.type
																.indexOf("image/") !== 0) {

													alert("이미지 파일만 선택할 수 있습니다.");

													this.value = "";

													restoreProfilePreview();

													return;
												}

												/* =============================================
												   서버 제한과 동일하게 5MB 검사
												============================================== */

												var maxFileSize = 5 * 1024 * 1024;

												if (file.size > maxFileSize) {

													alert("프로필 사진은 5MB 이하의 이미지만 업로드할 수 있습니다.");

													this.value = "";

													restoreProfilePreview();

													return;
												}

												/* =============================================
												   FileReader를 이용한 즉시 미리보기

												   아직 서버에 저장되는 것은 아님.
												   변경사항 저장 버튼을 눌러야
												   실제 DB/파일 저장이 이루어짐.
												============================================== */

												var reader = new FileReader();

												reader.onload = function(event) {

													profilePreview.src = event.target.result;

													profilePreview.style.display = "block";

													profileDefaultAvatar.style.display = "none";
												};

												reader.onerror = function() {

													alert("이미지를 불러오지 못했습니다.");

													profileImageInput.value = "";

													restoreProfilePreview();
												};

												reader.readAsDataURL(file);

											});

							/* =====================================================
							   기존 이미지로 복구
							====================================================== */

							function restoreProfilePreview() {

								if (originalSrc && originalSrc.trim() !== "") {

									profilePreview.src = originalSrc;

									profilePreview.style.display = originalPreviewDisplay
											|| "block";

									profileDefaultAvatar.style.display = "none";

								} else {

									profilePreview.removeAttribute("src");

									profilePreview.style.display = "none";

									profileDefaultAvatar.style.display = originalDefaultDisplay
											|| "block";
								}
							}

						});
	</script>


</body>

</html>