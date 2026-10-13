<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8" import="dto.member.UserDto"%>

<%
request.setAttribute("activePage", "profile");

request.setAttribute("settingsPage", "withdraw");

String ctx = request.getContextPath();

UserDto user = (UserDto) session.getAttribute("user");

if (user == null) {

	response.sendRedirect(ctx + "/auth/login");

	return;
}

String loginId = user.getLoginId() == null ? "" : user.getLoginId();

String email = user.getEmail() == null ? "" : user.getEmail();

String errorMessage = (String) request.getAttribute("errorMessage");
%>

<!DOCTYPE html>

<html lang="ko">

<head>

<meta charset="UTF-8">

<meta name="viewport" content="width=device-width, initial-scale=1">

<title>회원 탈퇴</title>

<jsp:include page="/common/headStyles.jsp" />

<link rel="stylesheet"
	href="<%=ctx%>/view/assets/css/setting/settings.css">


<style>
.withdraw-warning {
	padding: 14px 16px;
	margin-bottom: 18px;
	border: 1px solid #f2c5ca;
	border-radius: 12px;
	background: #fff7f8;
	color: #9f3440;
	font-size: 11.5px;
	line-height: 1.7;
}

.withdraw-account-info {
	padding: 13px 15px;
	margin-bottom: 18px;
	border-radius: 10px;
	background: #f7f7fb;
	color: #666873;
	font-size: 11.5px;
	line-height: 1.7;
}

.withdraw-account-info strong {
	color: #35363d;
}

.withdraw-email-row {
	display: grid;
	grid-template-columns: minmax(0, 1fr) auto;
	align-items: center;
	gap: 8px;
}

.withdraw-email-row input {
	width: 100%;
}

.withdraw-verify-btn {
	min-width: 105px;
	height: 40px;
	padding: 0 14px;
	border: 1px solid #6369D1;
	border-radius: 10px;
	background: #ffffff;
	color: #6369D1;
	font-size: 11.5px;
	font-weight: 700;
	cursor: pointer;
}

.withdraw-verify-btn:hover {
	background: #f6f6ff;
}

.withdraw-verify-btn:disabled {
	opacity: 0.55;
	cursor: not-allowed;
}

.withdraw-verification-area {
	margin-top: 15px;
}

.withdraw-verification-area[hidden] {
	display: none;
}

.withdraw-message {
	min-height: 18px;
	margin-top: 7px;
	font-size: 11px;
	line-height: 1.5;
}

.withdraw-message.success {
	color: #2f8f55;
}

.withdraw-message.error {
	color: #d6404d;
}

.withdraw-error-box {
	margin-bottom: 16px;
	padding: 11px 13px;
	border-radius: 9px;
	background: #fff2f3;
	color: #d6404d;
	font-size: 11px;
	line-height: 1.55;
}

.withdraw-agree {
	display: flex;
	align-items: flex-start;
	gap: 8px;
	margin: 5px 0 18px;
	color: #62636b;
	font-size: 11.5px;
	line-height: 1.5;
	cursor: pointer;
}

.withdraw-agree input {
	margin-top: 2px;
	accent-color: #6369D1;
}

.withdraw-danger-button {
	min-width: 116px;
	height: 40px;
	display: inline-flex;
	align-items: center;
	justify-content: center;
	padding: 0 15px;
	border: 1px solid #E5484D;
	border-radius: 10px;
	background: #E5484D;
	color: #ffffff;
	font: inherit;
	font-size: 12px;
	font-weight: 700;
	cursor: pointer;
}

.withdraw-danger-button:disabled {
	opacity: 0.45;
	cursor: not-allowed;
}
</style>

</head>


<body class="site-shell">


	<jsp:include page="/common/header.jsp" />


	<div class="settings-page">

		<div class="settings-shell">


			<jsp:include page="/common/settingsSidebar.jsp" />


			<main class="settings-main">

				<div class="settings-content">


					<header class="settings-title">

						<span class="settings-eyebrow"> ACCOUNT </span>

						<h1>회원 탈퇴</h1>

						<p>탈퇴 전 아래 내용을 확인해주세요.</p>

					</header>


					<form id="withdrawForm" action="<%=ctx%>/auth/withdraw"
						method="post">


						<section class="settings-panel settings-form-panel">


							<div class="settings-form compact">


								<div class="withdraw-warning">계정을 탈퇴하면 작성한 일정, 게시글, 좋아요 및
									북마크 등 계정에 연결된 데이터가 더 이상 정상적으로 이용되지 않을 수 있습니다.</div>


								<div class="withdraw-account-info">

									현재 로그인 계정 <br> <strong> <%=loginId%>
									</strong> · <strong> <%=email%>
									</strong>

								</div>


								<div class="settings-field">

									<span class="settings-field-label"> 이메일 본인 인증 </span>


									<div class="withdraw-email-row">


										<input type="email" id="withdrawEmail" value="<%=email%>"
											readonly>


										<button type="button" class="withdraw-verify-btn"
											id="sendWithdrawEmailCode">인증번호 전송</button>


									</div>


									<small> 회원 정보에 등록된 이메일로 인증번호를 전송합니다. </small>


									<div class="withdraw-message" id="withdrawEmailSendMessage">
									</div>

								</div>


								<div class="withdraw-verification-area"
									id="withdrawVerificationArea" hidden>


									<div class="settings-field">

										<span class="settings-field-label"> 인증번호 </span>


										<div class="withdraw-email-row">


											<input type="text" id="withdrawVerificationCode"
												maxlength="6" inputmode="numeric"
												autocomplete="one-time-code" placeholder="6자리 인증번호">


											<button type="button" class="withdraw-verify-btn"
												id="verifyWithdrawEmailCode">인증 확인</button>


										</div>


										<div class="withdraw-message" id="withdrawVerificationMessage">
										</div>


									</div>

								</div>


								<%
								if (errorMessage != null && !errorMessage.trim().isEmpty()) {
								%>

								<div class="withdraw-error-box">

									<%=errorMessage%>

								</div>

								<%
								}
								%>


								<label class="withdraw-agree"> <input type="checkbox"
									id="withdrawAgree" name="withdrawAgree" value="Y"> <span>

										위 내용을 확인했으며 회원 탈퇴에 동의합니다. </span>


								</label>


							</div>


						</section>


						<div class="settings-actions" style="gap: 8px;">


							<a class="settings-soft-btn"
								href="<%=ctx%>/profile/myProfile"
								style="min-width: 104px; text-decoration: none;"> 취소 </a>


							<button type="submit" id="withdrawSubmitButton"
								class="withdraw-danger-button" disabled>회원 탈퇴</button>


						</div>


					</form>


				</div>

			</main>


		</div>

	</div>


	<jsp:include page="/common/footer.jsp" />



	<script>
document.addEventListener(
    "DOMContentLoaded",
    function () {

        	var contextPath = "<%=ctx%>";

			var email = document.getElementById("withdrawEmail");

			var sendButton = document.getElementById("sendWithdrawEmailCode");

			var verificationArea = document
					.getElementById("withdrawVerificationArea");

			var verificationCode = document
					.getElementById("withdrawVerificationCode");

			var verifyButton = document
					.getElementById("verifyWithdrawEmailCode");

			var sendMessage = document
					.getElementById("withdrawEmailSendMessage");

			var verifyMessage = document
					.getElementById("withdrawVerificationMessage");

			var agree = document.getElementById("withdrawAgree");

			var submitButton = document.getElementById("withdrawSubmitButton");

			var form = document.getElementById("withdrawForm");

			var emailVerified = false;

			function setMessage(element, message, success) {

				if (!element) {
					return;
				}

				element.textContent = message || "";

				element.className = "withdraw-message";

				if (!message) {
					return;
				}

				if (success) {

					element.classList.add("success");

				} else {

					element.classList.add("error");
				}
			}

			function requestJson(url, body, callback) {

				var xhr = new XMLHttpRequest();

				xhr.open("POST", url, true);

				xhr.setRequestHeader("Accept", "application/json");

				xhr.setRequestHeader("Content-Type",
						"application/x-www-form-urlencoded; charset=UTF-8");

				xhr.onreadystatechange = function() {

					if (xhr.readyState !== 4) {

						return;
					}

					var data = null;

					try {

						data = JSON.parse(xhr.responseText);

					} catch (e) {

						callback(new Error("서버 응답을 처리할 수 없습니다."), null);

						return;
					}

					if (xhr.status >= 200 && xhr.status < 300) {

						callback(null, data);

					} else {

						callback(new Error("요청 처리 중 오류가 발생했습니다."), data);
					}
				};

				xhr.onerror = function() {

					callback(new Error("서버와 통신할 수 없습니다."), null);
				};

				xhr.send(body);
			}

			function updateSubmitButton() {

				submitButton.disabled = !emailVerified || !agree.checked;
			}

			sendButton.addEventListener("click", function() {

				var emailValue = email.value.trim();

				emailVerified = false;

				updateSubmitButton();

				setMessage(sendMessage, "", false);

				setMessage(verifyMessage, "", false);

				if (!emailValue) {

					setMessage(sendMessage, "등록된 이메일을 찾을 수 없습니다.", false);

					return;
				}

				sendButton.disabled = true;

				sendButton.textContent = "발송 중...";

				requestJson(

				contextPath + "/auth/emailSend",

						"email=" + encodeURIComponent(emailValue)
								+ "&purpose=withdraw",

						function(error, data) {

							sendButton.disabled = false;

							sendButton.textContent = "인증번호 전송";

							if (error) {

								setMessage(sendMessage, error.message, false);

								return;
							}

							if (!data || data.success !== true) {

								setMessage(sendMessage,

								data && data.message ? data.message
										: "인증번호 발송에 실패했습니다.",

								false);

								return;
							}

							verificationArea.hidden = false;

							verificationCode.value = "";

							verificationCode.readOnly = false;

							verifyButton.disabled = false;

							verifyButton.textContent = "인증 확인";

							setMessage(sendMessage,

							data.message || "인증번호를 발송했습니다.",

							true);

							verificationCode.focus();
						});
			});

			verifyButton.addEventListener("click", function() {

				var emailValue = email.value.trim();

				var code = verificationCode.value.trim();

				if (code.length !== 6) {

					setMessage(verifyMessage, "6자리 인증번호를 입력해주세요.", false);

					return;
				}

				verifyButton.disabled = true;

				verifyButton.textContent = "확인 중...";

				requestJson(

				contextPath + "/auth/emailVerify",

				"email=" + encodeURIComponent(emailValue) + "&code="
						+ encodeURIComponent(code) + "&purpose=withdraw",

				function(error, data) {

					verifyButton.disabled = false;

					verifyButton.textContent = "인증 확인";

					if (error) {

						setMessage(verifyMessage, error.message, false);

						return;
					}

					if (!data || data.success !== true) {

						setMessage(verifyMessage,

						data && data.message ? data.message
								: "인증번호가 올바르지 않습니다.",

						false);

						return;
					}

					emailVerified = true;

					setMessage(verifyMessage, "이메일 인증이 완료되었습니다.", true);

					verificationCode.readOnly = true;

					verifyButton.disabled = true;

					verifyButton.textContent = "인증완료";

					sendButton.disabled = true;

					sendButton.textContent = "인증완료";

					updateSubmitButton();
				});
			});

			agree.addEventListener("change", function() {

				updateSubmitButton();
			});

			form.addEventListener("submit", function(event) {

				if (!emailVerified) {

					event.preventDefault();

					alert("이메일 인증을 완료해주세요.");

					return;
				}

				if (!agree.checked) {

					event.preventDefault();

					alert("회원 탈퇴에 동의해주세요.");

					return;
				}

				if (!window.confirm("정말 회원 탈퇴를 진행하시겠습니까?")) {

					event.preventDefault();

					return;
				}

				submitButton.disabled = true;

				submitButton.textContent = "탈퇴 처리 중...";
			});

			updateSubmitButton();

		});
	</script>


</body>

</html>