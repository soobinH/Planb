<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>

<%
String ctx = request.getContextPath();

/*
 * 비밀번호 찾기 페이지를 새로 열었을 때
 * 이전 재설정 세션이 남아있다면 제거
 */
if ("GET".equalsIgnoreCase(request.getMethod())) {
	session.removeAttribute("passwordResetUserId");
}

String errorMessage = (String) request.getAttribute("errorMessage");

String loginId = request.getParameter("loginId") == null ? "" : request.getParameter("loginId");

String name = request.getParameter("name") == null ? "" : request.getParameter("name");

String email = request.getParameter("email") == null ? "" : request.getParameter("email");

String phone = request.getParameter("phone") == null ? "" : request.getParameter("phone");

/*
 * 오류로 다시 돌아온 경우에도 같은 이메일로 인증을 마쳤다면 인증 완료 상태 유지
 */
String findPwVerifiedEmail = (String) session.getAttribute("findPwVerifiedEmail");

boolean emailVerified = Boolean.TRUE.equals(session.getAttribute("findPwEmailVerified"))
		&& findPwVerifiedEmail != null && !email.isEmpty()
		&& findPwVerifiedEmail.equalsIgnoreCase(email.trim());
%>

<!DOCTYPE html>
<html lang="ko">

<head>

<meta charset="UTF-8">

<meta name="viewport" content="width=device-width, initial-scale=1">

<title>비밀번호 재설정</title>


<!-- 공통 스타일 -->
<jsp:include page="/common/headStyles.jsp" />


<style>

/* ============================================================
   FIND PASSWORD
   ============================================================ */
.find-password-page {
	min-height: calc(100vh - 80px);
	display: flex;
	align-items: center;
	justify-content: center;
	padding: 60px 20px;
	box-sizing: border-box;
	background: #fafafd;
}

.find-password-card {
	width: 100%;
	max-width: 430px;
	padding: 38px 36px 34px;
	border: 1px solid #e7e7ec;
	border-radius: 18px;
	background: #fff;
	box-sizing: border-box;
	box-shadow: 0 18px 50px rgba(30, 31, 50, 0.06);
}

/* ============================================================
   HEADER
   ============================================================ */
.find-password-header {
	margin-bottom: 28px;
}

.find-password-eyebrow {
	display: block;
	margin-bottom: 8px;
	color: #6369D1;
	font-size: 10px;
	font-weight: 800;
	letter-spacing: 0.13em;
}

.find-password-header h1 {
	margin: 0;
	color: #18181d;
	font-size: 26px;
	font-weight: 760;
	line-height: 1.25;
	letter-spacing: -0.04em;
}

.find-password-header p {
	margin: 10px 0 0;
	color: #898a93;
	font-size: 12px;
	line-height: 1.65;
}

/* ============================================================
   FORM
   ============================================================ */
.find-password-form {
	width: 100%;
}

.find-password-field {
	display: block;
	margin-bottom: 16px;
}

.find-password-field-label {
	display: block;
	margin-bottom: 7px;
	color: #3d3e45;
	font-size: 11.5px;
	font-weight: 700;
}

.find-password-field input {
	width: 100%;
	height: 45px;
	display: block;
	padding: 0 13px;
	border: 1px solid #dadbe1;
	border-radius: 10px;
	outline: none;
	background: #fff;
	color: #17171c;
	font: inherit;
	font-size: 12px;
	box-sizing: border-box;
	transition: border-color 0.15s ease, box-shadow 0.15s ease;
}

.find-password-field input::placeholder {
	color: #b0b1b8;
}

.find-password-field input:focus {
	border-color: #6369D1;
	box-shadow: 0 0 0 3px rgba(99, 105, 209, 0.09);
}

/* ============================================================
   EMAIL VERIFICATION
   ============================================================ */
.find-password-inline {
	display: flex;
	gap: 8px;
}

.find-password-inline input {
	flex: 1;
	min-width: 0;
}

.find-password-inline input[readonly] {
	background: #f6f6f9;
	color: #6b6c75;
}

.find-password-side-btn {
	flex: 0 0 auto;
	height: 45px;
	padding: 0 14px;
	border: 1px solid #6369D1;
	border-radius: 10px;
	background: #fff;
	color: #6369D1;
	font: inherit;
	font-size: 12px;
	font-weight: 700;
	white-space: nowrap;
	cursor: pointer;
	transition: background 0.15s ease, color 0.15s ease;
}

.find-password-side-btn:hover:not(:disabled) {
	background: #6369D1;
	color: #fff;
}

.find-password-side-btn:disabled {
	border-color: #dadbe1;
	color: #b0b1b8;
	cursor: default;
}

.find-password-field[hidden] {
	display: none;
}

.find-password-email-msg {
	min-height: 16px;
	margin: -8px 0 14px;
	color: #c73d49;
	font-size: 11px;
	line-height: 1.5;
}

.find-password-email-msg:empty {
	display: none;
}

.find-password-email-msg.success {
	color: #1f8a5b;
}

/* ============================================================
   ERROR
   ============================================================ */
.find-password-error {
	margin: 4px 0 17px;
	padding: 11px 13px;
	border: 1px solid #f1c9ce;
	border-radius: 9px;
	background: #fff5f6;
	color: #c73d49;
	font-size: 11px;
	line-height: 1.5;
}

/* ============================================================
   INFO
   ============================================================ */
.find-password-info {
	margin: 6px 0 20px;
	padding: 12px 13px;
	border: 1px solid #e7e7f4;
	border-radius: 10px;
	background: #fafaff;
	color: #777985;
	font-size: 10.5px;
	line-height: 1.65;
}

.find-password-info strong {
	color: #6369D1;
}

/* ============================================================
   BUTTON
   ============================================================ */
.find-password-submit {
	width: 100%;
	height: 44px;
	display: flex;
	align-items: center;
	justify-content: center;
	padding: 0;
	border: 1px solid #6369D1;
	border-radius: 10px;
	background: #6369D1;
	color: #fff;
	font: inherit;
	font-size: 12px;
	font-weight: 720;
	cursor: pointer;
	transition: background 0.15s ease, border-color 0.15s ease;
}

.find-password-submit:hover {
	border-color: #5056bb;
	background: #5056bb;
}

/* ============================================================
   BOTTOM
   ============================================================ */
.find-password-bottom {
	margin-top: 20px;
	padding-top: 18px;
	border-top: 1px solid #eeeeF2;
	text-align: center;
}

.find-password-bottom p {
	margin: 0;
	color: #93949c;
	font-size: 11px;
}

.find-password-bottom a {
	margin-left: 4px;
	color: #6369D1;
	font-weight: 700;
	text-decoration: none;
}

.find-password-bottom a:hover {
	text-decoration: underline;
}

/* ============================================================
   RESPONSIVE
   ============================================================ */
@media ( max-width : 520px) {
	.find-password-page {
		align-items: flex-start;
		padding: 30px 14px;
	}
	.find-password-card {
		padding: 30px 22px 28px;
		border-radius: 14px;
	}
	.find-password-header h1 {
		font-size: 23px;
	}
}
</style>

</head>


<body class="site-shell">


	<div class="find-password-page">


		<section class="find-password-card">


			<!-- =========================
             TITLE
        ========================== -->

			<header class="find-password-header">

				<span class="find-password-eyebrow"> PASSWORD RESET </span>


				<h1>비밀번호 재설정</h1>


				<p>
					가입할 때 입력한 회원정보를 입력해주세요.<br> 정보가 일치하면 새 비밀번호를 설정할 수 있습니다.
				</p>

			</header>



			<!-- =========================
             FORM
        ========================== -->

			<form class="find-password-form" id="findPwForm" action="<%=ctx%>/auth/findPassword"
				method="post">


				<!-- 아이디 -->
				<label class="find-password-field"> <span
					class="find-password-field-label"> 아이디 </span> <input type="text"
					name="loginId" value="<%=loginId%>" placeholder="아이디를 입력하세요"
					autocomplete="username" maxlength="50" required>

				</label>



				<!-- 이름 -->
				<label class="find-password-field"> <span
					class="find-password-field-label"> 이름 </span> <input type="text"
					name="name" value="<%=name%>" placeholder="이름을 입력하세요"
					autocomplete="name" maxlength="50" required>

				</label>



				<!-- 이메일 + 인증번호 발송 -->
				<div class="find-password-field">
					<label class="find-password-field-label" for="findPwEmail"> 이메일 </label>
					<div class="find-password-inline">
						<input type="email" id="findPwEmail" name="email" value="<%=email%>"
							placeholder="example@email.com" autocomplete="email"
							maxlength="100" required <%=emailVerified ? "readonly" : ""%>>
						<button type="button" class="find-password-side-btn" id="findPwSendBtn"
							<%=emailVerified ? "disabled" : ""%>>인증번호 발송</button>
					</div>
				</div>

				<!-- 인증번호 확인 -->
				<div class="find-password-field" id="findPwCodeField" <%=emailVerified ? "hidden" : ""%>>
					<label class="find-password-field-label" for="findPwCode"> 인증번호 </label>
					<div class="find-password-inline">
						<input type="text" id="findPwCode" inputmode="numeric"
							maxlength="6" placeholder="6자리 인증번호" autocomplete="one-time-code">
						<button type="button" class="find-password-side-btn" id="findPwVerifyBtn">확인</button>
					</div>
				</div>

				<p class="find-password-email-msg<%=emailVerified ? " success" : ""%>" id="findPwEmailMsg" aria-live="polite"><%=emailVerified ? "이메일 인증이 완료되었습니다." : ""%></p>



				<!-- 전화번호 -->
				<label class="find-password-field"> <span
					class="find-password-field-label"> 전화번호 </span> <input type="tel"
					id="phone" name="phone" value="<%=phone%>"
					placeholder="010-1234-5678" autocomplete="tel" maxlength="13"
					required>

				</label>



				<!-- =========================
                 ERROR MESSAGE
            ========================== -->

				<%
				if (errorMessage != null && !errorMessage.trim().isEmpty()) {
				%>

				<div class="find-password-error" role="alert">

					<%=errorMessage%>

				</div>

				<%
				}
				%>



				<!-- 안내 -->
				<div class="find-password-info">

					<strong> 확인해주세요. </strong> 이메일 인증을 마치고, 입력한 아이디, 이름, 이메일, 전화번호가 가입정보와 모두 일치해야 다음
					단계로 이동할 수 있습니다.

				</div>



				<!-- 다음 -->
				<button type="submit" class="find-password-submit">다음</button>


			</form>



			<!-- =========================
             LOGIN
        ========================== -->

			<div class="find-password-bottom">

				<p>

					비밀번호가 기억나셨나요? <a href="<%=ctx%>/auth/login"> 로그인 </a>

				</p>

			</div>


		</section>


	</div>
	<script>
		document.addEventListener("DOMContentLoaded",
				function() {
					var phone = document.getElementById("phone");
					if (!phone) {
						return;
					}

					function formatPhoneNumber(value) {
						/*
						 * 숫자가 아닌 문자는 전부 제거
						 */
						var numbers = value.replace(/[^0-9]/g, "");
						/*
						 * 휴대전화 최대 11자리
						 */
						if (numbers.length > 11) {
							numbers = numbers.substring(0, 11);
						}

						/*
						 * 010
						 */
						if (numbers.length <= 3) {
							return numbers;
						}

						/*
						 * 010-1234
						 */
						if (numbers.length <= 7) {
							return numbers.substring(0, 3) + "-"
									+ numbers.substring(3);
						}

						/*
						 * 010-1234-5678
						 */
						return numbers.substring(0, 3) + "-"
								+ numbers.substring(3, 7) + "-"
								+ numbers.substring(7, 11);
					}

					phone.addEventListener("input", function() {
						this.value = formatPhoneNumber(this.value);
					});

					/*
					 * 서버에서 기존 값이 다시 들어온 경우에도
					 * 자동으로 하이픈 적용
					 */
					phone.value = formatPhoneNumber(phone.value);

				});
	</script>

	<script>
		/* =========================================================
		   이메일 인증 (purpose=findPassword)
		   - 인증번호 발송 → 6자리 확인 → 인증 완료 후에만 다음 단계 진행
		========================================================= */
		document.addEventListener("DOMContentLoaded", function() {

			var ctx = "<%=ctx%>";
			var form = document.getElementById("findPwForm");
			var emailInput = document.getElementById("findPwEmail");
			var sendBtn = document.getElementById("findPwSendBtn");
			var codeField = document.getElementById("findPwCodeField");
			var codeInput = document.getElementById("findPwCode");
			var verifyBtn = document.getElementById("findPwVerifyBtn");
			var message = document.getElementById("findPwEmailMsg");

			if (!form || !emailInput || !sendBtn || !verifyBtn) {
				return;
			}

			var verified = emailInput.hasAttribute("readonly");

			function showMessage(text, success) {
				message.textContent = text;
				message.classList.toggle("success", !!success);
			}

			function post(url, data) {
				var body = new URLSearchParams(data);
				body.set("purpose", "findPassword");

				return fetch(ctx + url, {
					method: "POST",
					headers: { "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8" },
					body: body.toString()
				}).then(function(res) {
					return res.json();
				});
			}

			sendBtn.addEventListener("click", function() {

				var email = emailInput.value.trim();

				if (!email) {
					showMessage("이메일을 입력해주세요.");
					emailInput.focus();
					return;
				}

				sendBtn.disabled = true;
				sendBtn.textContent = "발송 중...";

				post("/auth/emailSend", { email: email })
					.then(function(result) {
						showMessage(result.message, result.success);

						if (result.success) {
							codeField.hidden = false;
							codeInput.value = "";
							codeInput.focus();
						}
					})
					.catch(function() {
						showMessage("인증번호 발송 중 오류가 발생했습니다.");
					})
					.finally(function() {
						sendBtn.disabled = false;
						sendBtn.textContent = "재발송";
					});
			});

			verifyBtn.addEventListener("click", function() {

				var code = codeInput.value.trim();

				if (!/^\d{6}$/.test(code)) {
					showMessage("6자리 인증번호를 입력해주세요.");
					codeInput.focus();
					return;
				}

				verifyBtn.disabled = true;

				post("/auth/emailVerify", { email: emailInput.value.trim(), code: code })
					.then(function(result) {
						showMessage(result.message, result.success);

						if (result.success) {
							verified = true;
							emailInput.readOnly = true;
							sendBtn.disabled = true;
							codeField.hidden = true;
						}
					})
					.catch(function() {
						showMessage("인증번호 확인 중 오류가 발생했습니다.");
					})
					.finally(function() {
						verifyBtn.disabled = false;
					});
			});

			codeInput.addEventListener("input", function() {
				this.value = this.value.replace(/[^0-9]/g, "").slice(0, 6);
			});

			codeInput.addEventListener("keydown", function(event) {
				if (event.key === "Enter") {
					event.preventDefault();
					verifyBtn.click();
				}
			});

			/* 인증을 마치지 않으면 다음 단계로 넘어가지 않음 */
			form.addEventListener("submit", function(event) {
				if (!verified) {
					event.preventDefault();
					showMessage("이메일 인증을 완료해주세요.");
					emailInput.focus();
				}
			});
		});
	</script>

</body>

</html>