<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8" import="dto.member.UserDto"%>

<%
request.setAttribute("activePage", "profile");

request.setAttribute("settingsPage", "password");

String ctx = request.getContextPath();

UserDto user = (UserDto) session.getAttribute("user");

if (user == null) {

	response.sendRedirect(ctx + "/auth/login");

	return;
}

/* =========================================================
   결과 메시지
========================================================= */

String errorMessage = (String) request.getAttribute("errorMessage");

String success = request.getParameter("success");

boolean successResult = "true".equals(success);

boolean showResultModal = errorMessage != null || successResult;

/* =========================================================
   Google / 소셜 로그인 여부
========================================================= */

boolean socialUser = user.getProvider() != null && !"LOCAL".equalsIgnoreCase(user.getProvider());
%>


<!DOCTYPE html>

<html lang="ko">


<head>

<meta charset="UTF-8">

<meta name="viewport" content="width=device-width, initial-scale=1">


<title>비밀번호 변경</title>


<jsp:include page="/common/headStyles.jsp" />


<link rel="stylesheet"
	href="<%=ctx%>/view/assets/css/setting/settings.css">


<style>

/* =========================================================
   비밀번호 변경 결과 Modal
========================================================= */
.password-result-backdrop {
	position: fixed;
	inset: 0;
	z-index: 9999;
	display: none;
	align-items: center;
	justify-content: center;
	padding: 20px;
	background: rgba(18, 18, 25, 0.46);
	backdrop-filter: blur(4px);
}

.password-result-backdrop.show {
	display: flex;
}

.password-result-modal {
	width: min(390px, calc(100vw - 40px));
	padding: 28px;
	background: #ffffff;
	border-radius: 18px;
	box-shadow: 0 24px 80px rgba(25, 25, 40, 0.20);
	text-align: center;
}

.password-result-icon {
	width: 52px;
	height: 52px;
	margin: 0 auto 18px;
	display: flex;
	align-items: center;
	justify-content: center;
	border-radius: 50%;
	font-size: 23px;
	font-weight: 800;
}

.password-result-icon.error {
	background: #fff0f1;
	color: #e04d5a;
}

.password-result-icon.success {
	background: #eff0ff;
	color: #6369D1;
}

.password-result-modal h2 {
	margin: 0 0 10px;
	color: #25262d;
	font-size: 18px;
	font-weight: 750;
}

.password-result-modal p {
	margin: 0;
	color: #777982;
	font-size: 13px;
	line-height: 1.7;
}

.password-result-confirm {
	width: 100%;
	height: 45px;
	margin-top: 24px;
	border: 0;
	border-radius: 10px;
	background: #6369D1;
	color: #ffffff;
	font-size: 13px;
	font-weight: 700;
	cursor: pointer;
}

.password-result-confirm:hover {
	background: #555bc2;
}

/* =========================================================
   Google / Social 계정 안내
========================================================= */
.social-password-guide {
	padding: 26px;
	border: 1px solid #ececf2;
	border-radius: 14px;
	background: #fafaff;
}

.social-password-guide strong {
	display: block;
	margin-bottom: 10px;
	color: #30313a;
	font-size: 14px;
}

.social-password-guide p {
	margin: 0;
	color: #777984;
	font-size: 12px;
	line-height: 1.7;
}

.social-password-badge {
	display: inline-flex;
	align-items: center;
	justify-content: center;
	min-height: 26px;
	margin-bottom: 14px;
	padding: 0 10px;
	border-radius: 999px;
	background: #ffffff;
	border: 1px solid #e6e6ed;
	color: #555862;
	font-size: 11px;
	font-weight: 700;
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


					<!-- =========================================
                     제목
                ========================================== -->

					<header class="settings-title">

						<span class="settings-eyebrow"> SETTINGS </span>


						<h1>비밀번호 변경</h1>


						<p>안전한 계정 사용을 위해 새로운 비밀번호를 설정하세요.</p>

					</header>



					<%
					if (socialUser) {
					%>


					<!-- =====================================
                         Google / Social 로그인 회원
                    ====================================== -->

					<section class="settings-panel settings-form-panel">


						<div class="social-password-guide">


							<span class="social-password-badge"> <%=user.getProvider()%>
								로그인 계정

							</span> <strong> 소셜 로그인 계정은 여기에서 비밀번호를 변경할 수 없습니다. </strong>


							<p>

								현재 계정은
								<%=user.getProvider()%>
								계정으로 로그인하고 있습니다. <br> 비밀번호는 해당 소셜 서비스의 계정 설정에서 관리해주세요.

							</p>


						</div>


					</section>


					<%
					} else {
					%>


					<!-- =====================================
                         일반 회원 비밀번호 변경 Form
                    ====================================== -->

					<form id="passwordChangeForm"
						action="<%=ctx%>/settings/passwordChange" method="post">


						<section class="settings-panel settings-form-panel">


							<div class="settings-form">



								<!-- 현재 비밀번호 -->

								<label class="settings-field"> <span
									class="settings-field-label"> 현재 비밀번호 </span> <input
									type="password" id="currentPassword" name="currentPassword"
									autocomplete="current-password" placeholder="현재 비밀번호" required>


								</label>



								<!-- 새 비밀번호 -->

								<label class="settings-field"> <span
									class="settings-field-label"> 새 비밀번호 </span> <input
									type="password" id="newPassword" name="newPassword"
									autocomplete="new-password" placeholder="새 비밀번호" required>


									<small> 영문, 숫자, 특수문자를 포함해 8자 이상 입력해주세요. </small>


								</label>



								<!-- 새 비밀번호 확인 -->

								<label class="settings-field"> <span
									class="settings-field-label"> 새 비밀번호 확인 </span> <input
									type="password" id="confirmPassword" name="confirmPassword"
									autocomplete="new-password" placeholder="새 비밀번호 다시 입력" required>


								</label>


							</div>


						</section>



						<div class="settings-actions">


							<button class="settings-primary-btn" id="passwordChangeButton"
								type="submit">비밀번호 변경</button>


						</div>


					</form>


					<%
					}
					%>


				</div>

			</main>


		</div>

	</div>



	<jsp:include page="/common/footer.jsp" />



	<!-- =========================================================
     성공 / 실패 Modal
========================================================= -->

	<div
		class="password-result-backdrop<%=showResultModal ? " show" : ""%>"
		id="passwordResultModal"
		aria-hidden="<%=showResultModal ? "false" : "true"%>">


		<div class="password-result-modal" role="dialog" aria-modal="true">


			<%
			if (errorMessage != null) {
			%>


			<div class="password-result-icon error">!</div>


			<h2>비밀번호 변경 실패</h2>


			<p>

				<%=errorMessage%>

			</p>


			<%
			} else {
			%>


			<div class="password-result-icon success">✓</div>


			<h2>비밀번호 변경 완료</h2>


			<p>비밀번호가 정상적으로 변경되었습니다.</p>


			<%
			}
			%>


			<button type="button" class="password-result-confirm"
				id="closePasswordResultModal">확인</button>


		</div>


	</div>



	<script>
		document.addEventListener("DOMContentLoaded", function() {

			var modal = document.getElementById("passwordResultModal");

			var closeButton = document
					.getElementById("closePasswordResultModal");

			var form = document.getElementById("passwordChangeForm");

			var submitButton = document.getElementById("passwordChangeButton");

			/* =====================================================
			   결과 모달 닫기
			====================================================== */

			function closeModal() {

				if (!modal) {

					return;
				}

				modal.classList.remove("show");

				modal.setAttribute("aria-hidden", "true");
			}

			if (closeButton) {

				closeButton.addEventListener("click", function() {

					closeModal();

				});

			}

			if (modal) {

				modal.addEventListener("click", function(event) {

					if (event.target === modal) {

						closeModal();

					}

				});

			}

			document.addEventListener("keydown", function(event) {

				if (event.key === "Escape" && modal
						&& modal.classList.contains("show")) {

					closeModal();

				}

			});

			/* =====================================================
			   제출 중복 방지
			====================================================== */

			if (form) {

				form.addEventListener("submit", function() {

					if (submitButton) {

						submitButton.disabled = true;

						submitButton.textContent = "변경 중...";

					}

				});

			}

		});
	</script>


</body>

</html>