<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<%
request.setAttribute("activePage", "auth");
%>


<!DOCTYPE html>
<html lang="ko">

<head>

<meta charset="UTF-8">

<meta name="viewport" content="width=device-width, initial-scale=1">

<title>로그인 · Planb</title>


<jsp:include page="/common/headStyles.jsp" />


<link rel="stylesheet"
	href="${pageContext.request.contextPath}/view/assets/css/auth/login.css">


<!-- Google 로그인 버튼 스타일 -->
<style>
.google-login-button {
	width: 100%;
	height: 46px;
	display: flex;
	align-items: center;
	justify-content: center;
	gap: 10px;
	margin-bottom: 20px;
	box-sizing: border-box;
	padding: 0 16px;
	border: 1px solid #dadce0;
	border-radius: 10px;
	background: #ffffff;
	color: #3c4043;
	font-size: 13px;
	font-weight: 600;
	text-decoration: none;
	cursor: pointer;
	transition: background 0.15s ease, border-color 0.15s ease, box-shadow
		0.15s ease;
}

.google-login-button:hover {
	background: #f8f9fa;
	border-color: #c7c9cc;
	box-shadow: 0 1px 3px rgba(60, 64, 67, 0.12);
}

.google-login-button:active {
	background: #f1f3f4;
}

.google-login-icon {
	width: 18px;
	height: 18px;
	flex-shrink: 0;
}

.google-login-text {
	line-height: 1;
}
</style>

</head>


<body class="site-shell">


	<jsp:include page="/common/header.jsp" />


	<main class="login-main">


		<div class="login-container">


			<!-- =====================================================
             상단
        ====================================================== -->

			<div class="login-header">


				<a class="site-brand auth-page-brand"
					href="${pageContext.request.contextPath}/home" aria-label="Planb 홈">

					<span class="tripily-mark" aria-hidden="true"> <svg
							width="17" height="17" viewBox="0 0 24 24" fill="none">

            <path
								d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7Z"
								fill="currentColor" />

            <circle cx="12" cy="9" r="2.6" fill="white" />

        </svg>

				</span> <span class="site-brand-copy"> <strong> Planb </strong>

				</span>

				</a>



				<h1>로그인</h1>


				<p>여행 일정을 공유하고 메이트를 찾아보세요.</p>


			</div>



			<!-- =====================================================
             로그인 카드
        ====================================================== -->

			<div class="login-card">


				<!-- =================================================
                 일반 로그인
            ================================================== -->

				<form id="loginForm"
					action="${pageContext.request.contextPath}/auth/login"
					method="post" novalidate>



					<!-- 아이디 -->
					<div class="form-group">


						<label for="loginId"> 아이디 </label> <input type="text" id="loginId"
							name="loginId" value="<c:out value='${param.loginId}' />"
							maxlength="50" placeholder="아이디를 입력하세요" autocomplete="username"
							required>


						<p class="field-error" data-error-for="loginId"></p>


					</div>



					<!-- 비밀번호 -->
					<div class="form-group">


						<label for="password"> 비밀번호 </label>


						<div class="password-wrap">


							<input type="password" id="password" name="password"
								placeholder="비밀번호를 입력하세요" autocomplete="current-password"
								required>


							<button type="button" id="passwordToggle" class="password-toggle"
								aria-label="비밀번호 보기">보기</button>


						</div>


						<p class="field-error" data-error-for="password"></p>


					</div>



					<!-- =================================================
                     아이디 기억 + 비밀번호 찾기
                ================================================== -->

					<div class="login-options">


						<label class="remember-login"> <input type="checkbox"
							name="rememberLogin" id="rememberLogin"> <span>
								아이디 저장 </span>


						</label> <a href="${pageContext.request.contextPath}/auth/findPassword"
							class="find-password"> 비밀번호 찾기 </a>


					</div>



					<!-- =================================================
                     전체 에러
                ================================================== -->

					<div id="loginError" class="login-error-box" hidden>아이디와
						비밀번호를 확인해주세요.</div>



					<!-- =================================================
                     로그인 버튼
                ================================================== -->

					<button type="submit" class="login-submit">로그인</button>


				</form>



				<!-- =====================================================
                 구분선
            ====================================================== -->

				<div class="login-divider">


					<div></div>


					<span> 또는 </span>


					<div></div>


				</div>



				<!-- =====================================================
                 Google 로그인
            ====================================================== -->

				<a href="${pageContext.request.contextPath}/auth/google"
					class="google-login-button"> <!-- Google Logo --> <svg
						class="google-login-icon" viewBox="0 0 18 18"
						xmlns="http://www.w3.org/2000/svg" aria-hidden="true">


                    <path fill="#4285F4"
							d="M17.64 9.205c0-.638-.057-1.252-.164-1.841H9v3.482h4.844a4.14 4.14 0 0 1-1.797 2.715v2.258h2.909c1.702-1.567 2.684-3.874 2.684-6.614z" />


                    <path fill="#34A853"
							d="M9 18c2.43 0 4.468-.806 5.956-2.181l-2.909-2.258c-.806.54-1.836.859-3.047.859-2.344 0-4.328-1.585-5.037-3.714H.956v2.332A9 9 0 0 0 9 18z" />


                    <path fill="#FBBC05"
							d="M3.963 10.706A5.41 5.41 0 0 1 3.682 9c0-.592.102-1.168.281-1.706V4.962H.956A9 9 0 0 0 0 9c0 1.452.347 2.827.956 4.038l3.007-2.332z" />


                    <path fill="#EA4335"
							d="M9 3.58c1.321 0 2.507.454 3.441 1.346l2.581-2.581C13.464.892 11.426 0 9 0A9 9 0 0 0 .956 4.962l3.007 2.332C4.672 5.165 6.656 3.58 9 3.58z" />


                </svg> <span class="google-login-text"> Google로 로그인 </span>


				</a>



				<!-- =====================================================
                 회원가입
            ====================================================== -->

				<p class="signup-link">


					아직 회원이 아니신가요? <a
						href="${pageContext.request.contextPath}/auth/signup"> 회원가입 </a>


				</p>


			</div>



			<!-- =====================================================
             하단 약관
        ====================================================== -->

			<p class="login-policy">


				로그인 시 <a href="#"> 이용약관 </a> 및 <a href="#"> 개인정보처리방침 </a> 에 동의하는 것으로
				간주합니다.


			</p>


		</div>



		<!-- =========================================================
         로그인 실패 Modal
    ========================================================== -->

		<c:if test="${not empty err}">


			<dialog id="loginErrorModal" class="login-modal">


			<div class="login-modal-box">


				<p class="login-modal-title">로그인 실패</p>


				<p class="login-modal-message">

					<c:out value="${err}" />

				</p>


				<form method="dialog">


					<button type="submit" class="login-modal-btn" autofocus>

						확인</button>


				</form>


			</div>


			</dialog>


		</c:if>


	</main>



	<jsp:include page="/common/footer.jsp" />



	<script
		src="${pageContext.request.contextPath}/view/assets/js/auth/login.js">
		
	</script>


</body>

</html>