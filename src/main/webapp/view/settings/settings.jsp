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
	href="<%=ctx%>/view/assets/css/setting/settings.css?v=2">
<script defer src="<%=ctx%>/view/assets/js/common/bioCounter.js"></script>

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
									<small id="profileImageStatus" class="settings-photo-status" aria-live="polite">사진을 고르면 바로 저장돼요.</small>

								</div>



								<!-- =============================
                                 파일 선택 버튼
                            ============================== -->

								<label class="settings-photo-label"> 프로필 사진 변경 <input
									type="file" id="profileImageInput"
									accept="image/jpeg,image/png,image/webp">

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

								<div class="settings-field"> <label for="postcode"
									class="settings-field-label"> 우편번호 </label>
									<div class="settings-postcode-row">
										<input type="text" id="postcode" name="postcode" maxlength="100"
											class="settings-address-input" value="<%=postcode%>"
											placeholder="주소 검색을 눌러주세요" readonly required>
										<button type="button" id="postcodeButton" class="settings-postcode-btn">주소 검색</button>
									</div>

								</div>



								<!-- =============================
                                 주소
                            ============================== -->

								<label class="settings-field full"> <span
									class="settings-field-label"> 주소 </span> <input type="text"
									id="address" name="address" maxlength="200" value="<%=address%>"
									class="settings-address-input" placeholder="주소 검색으로 입력돼요" readonly required>

								</label>



								<!-- =============================
                                 상세주소
                            ============================== -->

								<label class="settings-field full"> <span
									class="settings-field-label"> 상세주소 </span> <input type="text"
									id="addressDetail" name="addressDetail" maxlength="200" value="<%=addressDetail%>"
									placeholder="동, 호수 등 상세 주소">

								</label>



								<!-- =============================
                                 소개
                            ============================== -->

								<label class="settings-field full"> <span
									class="settings-field-label"> 소개 </span> <textarea name="bio"
										rows="2" maxlength="50" data-bio-input><%=bio%></textarea>
									<small class="bio-counter" data-bio-counter><%=bio.length()%> / 50</small>

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
     우편번호 찾기 (카카오 우편번호 서비스)
========================================================= -->

	<script src="//t1.kakaocdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>

	<script>
		document.addEventListener("DOMContentLoaded", function() {

			var postcodeButton = document.getElementById("postcodeButton");
			var postcodeInput = document.getElementById("postcode");
			var addressInput = document.getElementById("address");
			var addressDetailInput = document.getElementById("addressDetail");

			if (!postcodeButton || !postcodeInput || !addressInput) {
				return;
			}

			function openPostcode() {

				if (typeof daum === "undefined" || typeof daum.Postcode === "undefined") {
					alert("주소 검색 서비스를 불러오지 못했습니다.\n잠시 후 다시 시도해주세요.");
					return;
				}

				new daum.Postcode({
					oncomplete: function(data) {

						// 도로명 / 지번 중 사용자가 고른 주소
						var selectedAddress = data.userSelectedType === "R"
								? data.roadAddress
								: data.jibunAddress;

						// 도로명 주소면 건물명 / 법정동을 괄호로 붙임
						if (data.userSelectedType === "R") {
							var extra = [];

							if (data.bname && /[동|로|가]$/g.test(data.bname)) {
								extra.push(data.bname);
							}

							if (data.buildingName && data.apartment === "Y") {
								extra.push(data.buildingName);
							}

							if (extra.length > 0) {
								selectedAddress += " (" + extra.join(", ") + ")";
							}
						}

						postcodeInput.value = data.zonecode;
						addressInput.value = selectedAddress;

						// 주소가 바뀌면 상세주소는 새로 입력
						if (addressDetailInput) {
							addressDetailInput.value = "";
							addressDetailInput.focus();
						}
					}
				}).open();
			}

			postcodeButton.addEventListener("click", openPostcode);
			postcodeInput.addEventListener("click", openPostcode);
			addressInput.addEventListener("click", openPostcode);
		});
	</script>



	<!-- =========================================================
     프로필 사진 : 고르면 바로 저장
     - "변경사항 저장"을 누르지 않아도 /profile/image 로 즉시 업로드
     - 실패하면 기존 사진으로 되돌림
========================================================= -->

	<script>
		document.addEventListener("DOMContentLoaded", function() {

			var contextPath = "<%=ctx%>";
			var profileImageInput = document.getElementById("profileImageInput");
			var profilePreview = document.getElementById("profilePreview");
			var profileDefaultAvatar = document.getElementById("profileDefaultAvatar");
			var profileStatus = document.getElementById("profileImageStatus");
			var photoLabel = document.querySelector(".settings-photo-label");

			if (!profileImageInput || !profilePreview || !profileDefaultAvatar) {
				return;
			}

			// 저장에 실패하면 되돌릴 현재 사진
			var savedSrc = profilePreview.getAttribute("src");

			var allowedTypes = ["image/jpeg", "image/png", "image/webp"];
			var maxFileSize = 5 * 1024 * 1024;

			function setStatus(message, type) {
				if (!profileStatus) {
					return;
				}

				profileStatus.textContent = message || "";
				profileStatus.className = "settings-photo-status" + (type ? " is-" + type : "");
			}

			function showImage(src) {
				if (src) {
					profilePreview.src = src;
					profilePreview.style.display = "block";
					profileDefaultAvatar.style.display = "none";
				} else {
					profilePreview.removeAttribute("src");
					profilePreview.style.display = "none";
					profileDefaultAvatar.style.display = "block";
				}
			}

			// 헤더 등 화면에 떠 있는 내 프로필 사진도 같이 교체
			function updateOtherAvatars(oldSrc, newSrc) {
				if (!oldSrc) {
					return;
				}

				document.querySelectorAll("img").forEach(function(img) {
					if (img !== profilePreview && img.getAttribute("src") === oldSrc) {
						img.src = newSrc;
					}
				});
			}

			profileImageInput.addEventListener("change", function() {

				if (!this.files || this.files.length === 0) {
					return;
				}

				var file = this.files[0];

				// 다음에 같은 파일을 골라도 change 가 발생하도록 비움
				this.value = "";

				if (allowedTypes.indexOf(file.type) === -1) {
					setStatus("JPG, PNG, WEBP 이미지만 등록할 수 있어요.", "error");
					return;
				}

				if (file.size > maxFileSize) {
					setStatus("5MB 이하의 이미지만 등록할 수 있어요.", "error");
					return;
				}

				// 업로드 전 미리보기
				var reader = new FileReader();

				reader.onload = function(event) {
					showImage(event.target.result);
				};

				reader.readAsDataURL(file);

				var formData = new FormData();
				formData.append("profileImage", file);

				setStatus("사진을 저장하는 중이에요...", "loading");

				if (photoLabel) {
					photoLabel.classList.add("is-busy");
				}

				fetch(contextPath + "/profile/image", {
					method: "POST",
					body: formData,
					credentials: "same-origin"
				})
				.then(function(response) {
					return response.json().catch(function() {
						return { success: false };
					});
				})
				.then(function(result) {

					if (!result || !result.success) {
						throw new Error(result && result.message
								? result.message
								: "프로필 사진을 저장하지 못했어요.");
					}

					showImage(result.url);
					updateOtherAvatars(savedSrc, result.url);
					savedSrc = result.url;

					setStatus("프로필 사진이 저장됐어요.", "success");
				})
				.catch(function(error) {
					showImage(savedSrc);
					setStatus(error.message || "프로필 사진을 저장하지 못했어요.", "error");
				})
				.finally(function() {
					if (photoLabel) {
						photoLabel.classList.remove("is-busy");
					}
				});
			});
		});
	</script>


</body>

</html>