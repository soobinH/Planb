<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>

<%
request.setAttribute("activePage", "auth");

String ctx = request.getContextPath();

String errorMessage =
        (String) request.getAttribute("errorMessage");
%>

<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>회원가입 · Planb</title>

<jsp:include page="/common/headStyles.jsp" />
<link rel="stylesheet" href="<%=ctx%>/view/assets/css/auth/signup.css">
</head>

<body class="site-shell">

	<jsp:include page="/common/header.jsp" />

	<main class="signup-main">
		<div class="signup-container">

			<div class="signup-header">
				<a class="site-brand auth-page-brand" href="<%=ctx%>/home"
					aria-label="Planb 홈"> <span class="tripily-mark"
					aria-hidden="true"> <svg width="17" height="17"
							viewBox="0 0 24 24" fill="none">

            <path
								d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7Z"
								fill="currentColor" />

            <circle cx="12" cy="9" r="2.6" fill="white" />

        </svg>

				</span> <span class="site-brand-copy"> <strong> Planb </strong>

				</span>

				</a>

				<h1>회원가입</h1>

				<p>Planb와 함께 특별한 여행을 시작하세요.</p>
			</div>


			<div class="signup-card">

				<form id="signupForm" action="<%=ctx%>/auth/signup" method="post"
					enctype="multipart/form-data" novalidate>


					<!-- ======================================= -->
					<!-- 기본 정보 -->
					<!-- ======================================= -->

					<section class="signup-section">

						<div class="section-title-area">
							<h2>기본 정보</h2>

							<span class="required-guide"> <span class="required">*</span>
								필수 입력
							</span>
						</div>


						<!-- 로그인 아이디 -->
						<div class="form-group">

							<label for="loginId"> 아이디 <span class="required">*</span>
							</label>

							<div class="postcode-row duplicate-row">

								<input type="text" id="loginId" name="loginId" maxlength="50"
									placeholder="로그인 아이디를 입력하세요" autocomplete="username" required>

								<button type="button" id="loginIdCheckButton"
									class="postcode-button duplicate-check-button">중복확인</button>

							</div>

							<p class="input-help">영문, 숫자, 밑줄(_)을 사용하여 4~20자로 입력해주세요.</p>

							<p class="field-error" data-error-for="loginId"></p>

							<p class="input-help duplicate-result" id="loginIdCheckMessage"></p>

						</div>


						<!-- 비밀번호 -->
						<div class="form-group">

							<label for="password"> 비밀번호 <span class="required">*</span>
							</label> <input type="password" id="password" name="password"
								maxlength="100" placeholder="8자 이상 입력하세요"
								autocomplete="new-password" required>

							<p class="input-help">영문과 숫자를 포함하여 8자 이상 입력해주세요.</p>

							<p class="field-error" data-error-for="password"></p>

						</div>


						<!-- 비밀번호 확인 -->
						<div class="form-group">

							<label for="passwordConfirm"> 비밀번호 확인 <span
								class="required">*</span>
							</label> <input type="password" id="passwordConfirm"
								name="passwordConfirm" maxlength="100"
								placeholder="비밀번호를 한 번 더 입력하세요" autocomplete="new-password"
								required>

							<p class="field-error" data-error-for="passwordConfirm"></p>

						</div>


						<div class="form-row">

							<!-- 이름 -->
							<div class="form-group">

								<label for="name"> 이름 <span class="required">*</span>
								</label> <input type="text" id="name" name="name" maxlength="50"
									placeholder="실명을 입력하세요" autocomplete="name" required>

								<p class="field-error" data-error-for="name"></p>

							</div>


							<!-- 닉네임 -->
							<div class="form-group">

								<label for="nickname"> 닉네임 <span class="required">*</span>
								</label>

								<div class="postcode-row duplicate-row">

									<input type="text" id="nickname" name="nickname" maxlength="50"
										placeholder="사용할 닉네임" required>

									<button type="button" id="nicknameCheckButton"
										class="postcode-button duplicate-check-button">중복확인</button>

								</div>

								<p class="field-error" data-error-for="nickname"></p>

								<p class="input-help duplicate-result" id="nicknameCheckMessage"></p>

							</div>

						</div>


						<!-- 이메일 -->
						<div class="form-group">

							<label for="email"> 이메일 <span class="required">*</span>
							</label>

							<div class="postcode-row duplicate-row">

								<input type="email" id="email" name="email" maxlength="100"
									placeholder="example@email.com" autocomplete="email" required>

								<button type="button" id="sendEmailCodeButton"
									class="postcode-button duplicate-check-button">인증번호 발송
								</button>

							</div>

							<p class="field-error" data-error-for="email"></p>

							<p class="input-help duplicate-result" id="emailSendMessage"></p>


							<!-- 이메일 인증번호 -->
							<div id="emailVerificationArea" class="email-verification-area"
								hidden>

								<div class="postcode-row duplicate-row"
									style="margin-top: 10px;">

									<input type="text" id="emailVerificationCode"
										name="emailVerificationCode" maxlength="6" inputmode="numeric"
										autocomplete="one-time-code" placeholder="6자리 인증번호">

									<button type="button" id="verifyEmailCodeButton"
										class="postcode-button duplicate-check-button">인증 확인
									</button>

								</div>

								<p class="input-help" id="emailVerificationMessage"></p>

							</div>

						</div>


						<!-- 전화번호 -->
						<div class="form-group">

							<label for="phone"> 전화번호 <span class="required">*</span>
							</label> <input type="tel" id="phone" name="phone" maxlength="13"
								placeholder="010-1234-5678" autocomplete="tel" required>

							<p class="field-error" data-error-for="phone"></p>

						</div>

					</section>


					<!-- ======================================= -->
					<!-- 주소 정보 -->
					<!-- ======================================= -->

					<section class="signup-section">

						<div class="section-title-area">
							<h2>주소 정보</h2>
						</div>


						<!-- 우편번호 -->
						<div class="form-group">

							<label for="postcode"> 우편번호 <span class="required">*</span>
							</label>

							<div class="postcode-row">

								<input type="text" id="postcode" name="postcode" maxlength="100"
									placeholder="우편번호" readonly required>

								<button type="button" id="postcodeButton"
									class="postcode-button">주소 검색</button>

							</div>

							<p class="field-error" data-error-for="postcode"></p>

						</div>


						<!-- 기본 주소 -->
						<div class="form-group">

							<label for="address"> 기본 주소 <span class="required">*</span>
							</label> <input type="text" id="address" name="address" maxlength="200"
								placeholder="도로명 주소" readonly required>

							<p class="field-error" data-error-for="address"></p>

						</div>


						<!-- 상세 주소 -->
						<div class="form-group">

							<label for="addressDetail"> 상세 주소 <span class="optional">선택</span>
							</label> <input type="text" id="addressDetail" name="addressDetail"
								maxlength="200" placeholder="동, 호수 등 상세 주소">

						</div>

					</section>


					<!-- ======================================= -->
					<!-- 추가 정보 -->
					<!-- ======================================= -->

					<section class="signup-section optional-section">

						<div class="section-title-area">
							<div>
								<h2>추가 정보</h2>

								<p class="section-description">선택사항이며 가입 후 마이페이지에서도 수정할 수
									있습니다.</p>
							</div>
						</div>


						<div class="form-row">

							<!-- 생년월일 -->
							<div class="form-group">

								<label for="birthDate"> 생년월일 <span class="optional">선택</span>
								</label> <input type="date" id="birthDate" name="birthDate">

							</div>


							<!-- 지역 -->
							<div class="form-group">

								<label for="region"> 지역 <span class="optional">선택</span>
								</label> <input type="text" id="region" name="region" maxlength="100"
									placeholder="예: 서울">

							</div>

						</div>


						<!-- 프로필 이미지 -->
						<div class="form-group">

							<label for="profileImage"> 프로필 이미지 <span class="optional">선택</span>
							</label>

							<div class="profile-upload">

								<div class="profile-preview" id="profilePreview">
									<span>사진</span>
								</div>

								<div class="profile-upload-info">

									<input type="file" id="profileImage" name="profileImage"
										accept="image/jpeg,image/png,image/webp">

									<p class="input-help">JPG, PNG, WEBP / 최대 5MB</p>

								</div>

							</div>

							<p class="field-error" data-error-for="profileImage"></p>

						</div>


						<!-- 자기소개 -->
						<div class="form-group">

							<label for="bio"> 소개글 <span class="optional">선택</span>
							</label>

							<textarea id="bio" name="bio" maxlength="300" rows="4"
								placeholder="간단한 자기소개를 입력해주세요."></textarea>

							<div class="textarea-bottom">
								<span></span> <span id="bioCounter"> 0 / 300 </span>
							</div>

						</div>

					</section>


					<!-- 서버 오류 -->
					<% if (errorMessage != null
                        && !errorMessage.trim().isEmpty()) { %>

					<div id="signupServerError" class="signup-error-box">
						<%=errorMessage%>
					</div>

					<% } %>


					<!-- 프론트 검증 오류 -->
					<div id="signupError" class="signup-error-box" hidden>입력 내용을
						다시 확인해주세요.</div>


					<!-- 회원가입 버튼 -->
					<button type="submit" id="signupSubmitButton" class="signup-submit">
						회원가입</button>

				</form>


				<p class="login-link">
					이미 계정이 있으신가요? <a href="<%=ctx%>/auth/login"> 로그인 </a>
				</p>

			</div>

		</div>
	</main>


	<jsp:include page="/common/footer.jsp" />


	<!-- 카카오 우편번호 서비스 -->
	<script
		src="//t1.kakaocdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>


	<!-- 회원가입 JS -->
	<script src="<%=ctx%>/view/assets/js/auth/signup.js"></script>


</body>
</html>
