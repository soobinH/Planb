<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>

<%
String ctx = request.getContextPath();

/* ============================================================
   비밀번호 재설정 대상 확인

   FindPasswordServlet에서:
   session.setAttribute("passwordResetUserId", userId);
   로 저장한 값
   ============================================================ */

Object resetUserIdObj = session.getAttribute("passwordResetUserId");

/*
 * 회원정보 확인 단계를 거치지 않고
 * resetPassword.jsp에 직접 접근한 경우
 */
if (resetUserIdObj == null) {

	response.sendRedirect(ctx + "/auth/findPassword");

	return;
}

/* 서버에서 전달된 오류 메시지 */
String errorMessage = (String) request.getAttribute("errorMessage");
%>


<!DOCTYPE html>

<html lang="ko">


<head>

<meta charset="UTF-8">

<meta name="viewport" content="width=device-width, initial-scale=1">

<title>새 비밀번호 설정</title>


<!-- 공통 CSS -->
<jsp:include page="/common/headStyles.jsp" />


<style>

/* ============================================================
   RESET PASSWORD PAGE
   ============================================================ */
.reset-password-page {
	min-height: calc(100vh - 80px);
	display: flex;
	align-items: center;
	justify-content: center;
	padding: 60px 20px;
	box-sizing: border-box;
	background: #fafafd;
}

/* ============================================================
   CARD
   ============================================================ */
.reset-password-card {
	width: 100%;
	max-width: 430px;
	padding: 38px 36px 34px;
	border: 1px solid #e7e7ec;
	border-radius: 18px;
	background: #ffffff;
	box-sizing: border-box;
	box-shadow: 0 18px 50px rgba(30, 31, 50, 0.06);
}

/* ============================================================
   HEADER
   ============================================================ */
.reset-password-header {
	margin-bottom: 28px;
}

.reset-password-eyebrow {
	display: block;
	margin-bottom: 8px;
	color: #6369D1;
	font-size: 10px;
	font-weight: 800;
	letter-spacing: 0.13em;
}

.reset-password-header h1 {
	margin: 0;
	color: #18181d;
	font-size: 26px;
	font-weight: 760;
	line-height: 1.25;
	letter-spacing: -0.04em;
}

.reset-password-header p {
	margin: 10px 0 0;
	color: #898a93;
	font-size: 12px;
	line-height: 1.65;
}

/* ============================================================
   FORM
   ============================================================ */
.reset-password-form {
	width: 100%;
}

.reset-password-field {
	display: block;
	margin-bottom: 16px;
}

.reset-password-field-label {
	display: block;
	margin-bottom: 7px;
	color: #3d3e45;
	font-size: 11.5px;
	font-weight: 700;
}

.reset-password-input-wrap {
	position: relative;
	width: 100%;
}

.reset-password-field input {
	width: 100%;
	height: 45px;
	display: block;
	padding: 0 44px 0 13px;
	border: 1px solid #dadbe1;
	border-radius: 10px;
	outline: none;
	background: #ffffff;
	color: #17171c;
	font: inherit;
	font-size: 12px;
	box-sizing: border-box;
	transition: border-color 0.15s ease, box-shadow 0.15s ease;
}

.reset-password-field input::placeholder {
	color: #b0b1b8;
}

.reset-password-field input:focus {
	border-color: #6369D1;
	box-shadow: 0 0 0 3px rgba(99, 105, 209, 0.09);
}

/* 비밀번호 보기 버튼 */
.password-toggle {
	position: absolute;
	top: 50%;
	right: 8px;
	width: 31px;
	height: 31px;
	display: flex;
	align-items: center;
	justify-content: center;
	padding: 0;
	border: 0;
	border-radius: 8px;
	background: transparent;
	color: #8f9098;
	font-size: 13px;
	cursor: pointer;
	transform: translateY(-50%);
}

.password-toggle:hover {
	background: #f4f4f7;
	color: #55565e;
}

/* 설명 */
.reset-password-field small {
	display: block;
	margin-top: 6px;
	color: #999aa2;
	font-size: 10px;
	line-height: 1.55;
}

/* ============================================================
   PASSWORD CONDITION
   ============================================================ */
.password-guide {
	margin: 3px 0 18px;
	padding: 12px 13px;
	border: 1px solid #e7e7f4;
	border-radius: 10px;
	background: #fafaff;
}

.password-guide-title {
	margin-bottom: 7px;
	color: #575962;
	font-size: 10.5px;
	font-weight: 700;
}

.password-guide ul {
	margin: 0;
	padding-left: 16px;
	color: #93949c;
	font-size: 10px;
	line-height: 1.7;
}

.password-guide li.valid {
	color: #4a8f63;
}

/* ============================================================
   CLIENT ERROR
   ============================================================ */
.reset-password-client-error {
	display: none;
	margin: 0 0 16px;
	padding: 11px 13px;
	border: 1px solid #f1c9ce;
	border-radius: 9px;
	background: #fff5f6;
	color: #c73d49;
	font-size: 11px;
	line-height: 1.5;
}

.reset-password-client-error.show {
	display: block;
}

/* ============================================================
   SERVER ERROR
   ============================================================ */
.reset-password-error {
	margin: 0 0 16px;
	padding: 11px 13px;
	border: 1px solid #f1c9ce;
	border-radius: 9px;
	background: #fff5f6;
	color: #c73d49;
	font-size: 11px;
	line-height: 1.5;
}

/* ============================================================
   SUBMIT BUTTON
   ============================================================ */
.reset-password-submit {
	width: 100%;
	height: 44px;
	display: flex;
	align-items: center;
	justify-content: center;
	padding: 0;
	border: 1px solid #6369D1;
	border-radius: 10px;
	background: #6369D1;
	color: #ffffff;
	font: inherit;
	font-size: 12px;
	font-weight: 720;
	cursor: pointer;
	transition: background 0.15s ease, border-color 0.15s ease, opacity
		0.15s ease;
}

.reset-password-submit:hover {
	border-color: #5056bb;
	background: #5056bb;
}

.reset-password-submit:disabled {
	opacity: 0.55;
	cursor: default;
}

/* ============================================================
   BOTTOM
   ============================================================ */
.reset-password-bottom {
	margin-top: 20px;
	padding-top: 18px;
	border-top: 1px solid #eeeef2;
	text-align: center;
}

.reset-password-bottom a {
	color: #6369D1;
	font-size: 11px;
	font-weight: 700;
	text-decoration: none;
}

.reset-password-bottom a:hover {
	text-decoration: underline;
}

/* ============================================================
   RESPONSIVE
   ============================================================ */
@media ( max-width : 520px) {
	.reset-password-page {
		align-items: flex-start;
		padding: 30px 14px;
	}
	.reset-password-card {
		padding: 30px 22px 28px;
		border-radius: 14px;
	}
	.reset-password-header h1 {
		font-size: 23px;
	}
}
</style>


</head>



<body class="site-shell">


	<div class="reset-password-page">


		<section class="reset-password-card">


			<!-- ====================================================
             HEADER
        ===================================================== -->

			<header class="reset-password-header">


				<span class="reset-password-eyebrow"> PASSWORD RESET </span>


				<h1>새 비밀번호 설정</h1>


				<p>

					새로운 비밀번호를 입력해주세요.<br> 변경이 완료되면 새 비밀번호로 로그인할 수 있습니다.

				</p>


			</header>



			<!-- ====================================================
             FORM
        ===================================================== -->

			<form id="resetPasswordForm" class="reset-password-form"
				action="<%=ctx%>/auth/resetPassword" method="post">


				<!-- =================================================
                 새 비밀번호
            ================================================== -->

				<label class="reset-password-field"> <span
					class="reset-password-field-label"> 새 비밀번호 </span>


					<div class="reset-password-input-wrap">


						<input type="password" id="password" name="password"
							placeholder="새 비밀번호를 입력하세요" autocomplete="new-password"
							minlength="8" maxlength="100" required>


						<button type="button" class="password-toggle"
							data-password-target="password" aria-label="비밀번호 보기">보기

						</button>


					</div> <small> 8자 이상 입력해주세요. </small>


				</label>



				<!-- =================================================
                 새 비밀번호 확인
            ================================================== -->

				<label class="reset-password-field"> <span
					class="reset-password-field-label"> 새 비밀번호 확인 </span>


					<div class="reset-password-input-wrap">


						<input type="password" id="passwordConfirm" name="passwordConfirm"
							placeholder="새 비밀번호를 다시 입력하세요" autocomplete="new-password"
							minlength="8" maxlength="100" required>


						<button type="button" class="password-toggle"
							data-password-target="passwordConfirm" aria-label="비밀번호 확인 보기">

							보기</button>


					</div> <small id="passwordMatchMessage"> 동일한 비밀번호를 한 번 더 입력해주세요.

				</small>


				</label>



				<!-- =================================================
                 PASSWORD GUIDE
            ================================================== -->

				<div class="password-guide">


					<div class="password-guide-title">비밀번호 조건</div>


					<ul>

						<li id="passwordLengthCondition">8자 이상</li>

						<li id="passwordLetterCondition">영문 포함</li>

						<li id="passwordNumberCondition">숫자 포함</li>

					</ul>


				</div>



				<!-- =================================================
                 CLIENT ERROR
            ================================================== -->

				<div id="clientErrorMessage" class="reset-password-client-error"
					role="alert"></div>



				<!-- =================================================
                 SERVER ERROR
            ================================================== -->

				<%
				if (errorMessage != null && !errorMessage.trim().isEmpty()) {
				%>


				<div class="reset-password-error" role="alert">

					<%=errorMessage%>

				</div>


				<%
				}
				%>



				<!-- =================================================
                 SUBMIT
            ================================================== -->

				<button type="submit" class="reset-password-submit">비밀번호 변경

				</button>


			</form>



			<!-- ====================================================
             BOTTOM
        ===================================================== -->

			<div class="reset-password-bottom">


				<a href="<%=ctx%>/view/auth/login.jsp"> 로그인 화면으로 돌아가기 </a>


			</div>


		</section>


	</div>



	<script>
		/*
		 * Eclipse의 오래된 JavaScript Validator에서도
		 * 오류가 적도록 arrow function,
		 * optional chaining 등을 사용하지 않음
		 */

		document.addEventListener("DOMContentLoaded", function() {

			var form = document.getElementById("resetPasswordForm");

			var password = document.getElementById("password");

			var passwordConfirm = document.getElementById("passwordConfirm");

			var clientError = document.getElementById("clientErrorMessage");

			var matchMessage = document.getElementById("passwordMatchMessage");

			var lengthCondition = document
					.getElementById("passwordLengthCondition");

			var letterCondition = document
					.getElementById("passwordLetterCondition");

			var numberCondition = document
					.getElementById("passwordNumberCondition");

			/* =====================================================
			   비밀번호 조건 확인
			====================================================== */

			function checkPasswordCondition() {

				var value = password.value;

				var lengthValid = value.length >= 8;

				var letterValid = /[A-Za-z]/.test(value);

				var numberValid = /[0-9]/.test(value);

				if (lengthValid) {

					lengthCondition.classList.add("valid");

				} else {

					lengthCondition.classList.remove("valid");

				}

				if (letterValid) {

					letterCondition.classList.add("valid");

				} else {

					letterCondition.classList.remove("valid");

				}

				if (numberValid) {

					numberCondition.classList.add("valid");

				} else {

					numberCondition.classList.remove("valid");

				}

				return (lengthValid && letterValid && numberValid);

			}

			/* =====================================================
			   비밀번호 일치 확인
			====================================================== */

			function checkPasswordMatch() {

				if (passwordConfirm.value === "") {

					matchMessage.innerText = "동일한 비밀번호를 한 번 더 입력해주세요.";

					matchMessage.style.color = "#999aa2";

					return false;

				}

				if (password.value === passwordConfirm.value) {

					matchMessage.innerText = "비밀번호가 일치합니다.";

					matchMessage.style.color = "#4a8f63";

					return true;

				}

				matchMessage.innerText = "비밀번호가 일치하지 않습니다.";

				matchMessage.style.color = "#c73d49";

				return false;

			}

			/* =====================================================
			   입력 이벤트
			====================================================== */

			password.addEventListener("input", function() {

				checkPasswordCondition();

				checkPasswordMatch();

			});

			passwordConfirm.addEventListener("input", function() {

				checkPasswordMatch();

			});

			/* =====================================================
			   비밀번호 보기
			====================================================== */

			var toggleButtons = document
					.querySelectorAll("[data-password-target]");

			var i;

			for (i = 0; i < toggleButtons.length; i++) {

				toggleButtons[i].addEventListener("click", function() {

					var targetId = this.getAttribute("data-password-target");

					var targetInput = document.getElementById(targetId);

					if (!targetInput) {

						return;

					}

					if (targetInput.type === "password") {

						targetInput.type = "text";

						this.innerText = "숨김";

					} else {

						targetInput.type = "password";

						this.innerText = "보기";

					}

				});

			}

			/* =====================================================
			   FORM SUBMIT
			====================================================== */

			form.addEventListener("submit", function(event) {

				clientError.classList.remove("show");

				clientError.innerText = "";

				var conditionValid = checkPasswordCondition();

				var matchValid = checkPasswordMatch();

				if (!conditionValid) {

					event.preventDefault();

					clientError.innerText = "비밀번호는 8자 이상이며 영문과 숫자를 포함해야 합니다.";

					clientError.classList.add("show");

					password.focus();

					return;

				}

				if (!matchValid) {

					event.preventDefault();

					clientError.innerText = "새 비밀번호와 비밀번호 확인이 일치하지 않습니다.";

					clientError.classList.add("show");

					passwordConfirm.focus();

					return;

				}

			});

		});
	</script>


</body>

</html>