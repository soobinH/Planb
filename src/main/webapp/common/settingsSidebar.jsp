<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>

<%
String ctx = request.getContextPath();

String settingsPage =
    request.getAttribute("settingsPage") == null
        ? ""
        : String.valueOf(
            request.getAttribute("settingsPage")
        );
%>

<aside class="settings-sidebar">

	<div class="settings-sidebar-head">

		<a class="settings-back" href="<%=ctx%>/profile/myProfile"
			aria-label="내 프로필로 돌아가기"> <svg width="18" height="18"
				viewBox="0 0 24 24" fill="none" stroke="currentColor"
				stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">

                <path d="M15 18l-6-6 6-6" />

            </svg>

		</a>

		<div>

			<span> MY PAGE </span>

			<h2>설정</h2>

		</div>

	</div>


	<nav>

		<!-- =========================================
             프로필 설정
        ========================================== -->

		<a
			class="settings-nav-link <%= "profile".equals(settingsPage) ? "active" : "" %>"
			href="<%=ctx%>/profile/edit"> <span class="settings-nav-icon">

				<!-- 사용자 / 프로필 --> <svg viewBox="0 0 24 24" fill="none"
					stroke="currentColor" stroke-width="1.7" stroke-linecap="round"
					stroke-linejoin="round">

                    <circle cx="12" cy="8" r="4" />

                    <path d="M4 21c0-4.3 3.6-7 8-7s8 2.7 8 7" />

                </svg>

		</span> <span> 프로필 설정 </span>

		</a>


		<!-- =========================================
             비밀번호 변경
        ========================================== -->

		<a
			class="settings-nav-link <%= "password".equals(settingsPage) ? "active" : "" %>"
			href="<%=ctx%>/settings/passwordChange"> <span
			class="settings-nav-icon"> <!-- 자물쇠 --> <svg
					viewBox="0 0 24 24" fill="none" stroke="currentColor"
					stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round">

                    <rect x="5" y="10" width="14" height="10" rx="2" />

                    <path d="M8 10V7a4 4 0 0 1 8 0v3" />

                    <circle cx="12" cy="15" r="1" />

                </svg>

		</span> <span> 비밀번호 변경 </span>

		</a>


		<!-- =========================================
             알림 설정
        ========================================== -->

		<a
			class="settings-nav-link <%= "notification".equals(settingsPage) ? "active" : "" %>"
			href="<%=ctx%>/settings/notificationSettings"> <span
			class="settings-nav-icon"> <!-- 알림 벨 --> <svg
					viewBox="0 0 24 24" fill="none" stroke="currentColor"
					stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round">

                    <path
						d="M18 8a6 6 0 0 0-12 0c0 7-3 7-3 9h18c0-2-3-2-3-9" />

                    <path d="M10 21h4" />

                </svg>

		</span> <span> 알림 설정 </span>

		</a>


		<!-- =========================================
             내 활동 내역
        ========================================== -->

        <a class="settings-nav-link <%= "activity".equals(settingsPage) ? "active" : "" %>"
           href="<%=ctx%>/settings/myActivity">
            <span class="settings-nav-icon" aria-hidden="true">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"
                     stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round">
                    <rect x="4" y="4" width="16" height="16" rx="2" />
                    <path d="M8 9h8M8 13h8M8 17h5" />
                </svg>
            </span>
            <span>내 활동 내역</span>
        </a>


		<!-- =========================================
             개인정보 및 공개범위
        ========================================== -->

		<a
			class="settings-nav-link <%= "privacy".equals(settingsPage) ? "active" : "" %>"
			href="<%=ctx%>/settings/privacySettings"> <span
			class="settings-nav-icon"> <!-- 방패 / 개인정보 --> <svg
					viewBox="0 0 24 24" fill="none" stroke="currentColor"
					stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round">

                    <path
						d="M12 3l7 3v5c0 5-3 8-7 10-4-2-7-5-7-10V6l7-3z" />

                    <path d="M9.5 12l1.7 1.7L15 10" />

                </svg>

		</span> <span> 개인정보 및 공개범위 </span>

		</a>


		<!-- =========================================
             보안 및 로그인 활동
        ========================================== -->

		<a
			class="settings-nav-link <%= "security".equals(settingsPage) ? "active" : "" %>"
			href="<%=ctx%>/settings/securityActivity"> <span
			class="settings-nav-icon"> <!-- 보안 키 --> <svg
					viewBox="0 0 24 24" fill="none" stroke="currentColor"
					stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round">

                    <circle cx="8" cy="12" r="4" />

                    <path d="M12 12h9" />

                    <path d="M18 12v3" />

                    <path d="M21 12v2" />

                </svg>

		</span> <span> 보안 및 로그인 활동 </span>

		</a>


		<!-- =========================================
             고객지원
        ========================================== -->

		<a
			class="settings-nav-link <%= "support".equals(settingsPage) ? "active" : "" %>"
			href="<%=ctx%>/support/support"> <span class="settings-nav-icon">

				<!-- 헤드셋 --> <svg viewBox="0 0 24 24" fill="none"
					stroke="currentColor" stroke-width="1.7" stroke-linecap="round"
					stroke-linejoin="round">

                    <path d="M4 13a8 8 0 0 1 16 0" />

                    <path d="M4 13v5a2 2 0 0 0 2 2h2v-7H4z" />

                    <path d="M20 13v5a2 2 0 0 1-2 2h-2v-7h4z" />

                </svg>

		</span> <span> 고객지원 </span>

		</a>

	</nav>


	<div class="settings-sidebar-bottom">

		<!-- =========================================
             로그아웃
        ========================================== -->

		<a href="<%=ctx%>/auth/logout"> <span class="settings-nav-icon">

				<!-- 로그아웃 --> <svg viewBox="0 0 24 24" fill="none"
					stroke="currentColor" stroke-width="1.7" stroke-linecap="round"
					stroke-linejoin="round">

                    <path d="M10 17l5-5-5-5" />

                    <path d="M15 12H3" />

                    <path d="M14 4h5a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2h-5" />

                </svg>

		</span> <span> 로그아웃 </span>

		</a>


		<!-- =========================================
             회원 탈퇴
        ========================================== -->

		<a class="danger" href="<%=ctx%>/auth/withdraw"> <span
			class="settings-nav-icon"> <!-- 사용자 삭제 --> <svg
					viewBox="0 0 24 24" fill="none" stroke="currentColor"
					stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round">

                    <circle cx="9" cy="8" r="4" />

                    <path d="M2 21c0-4 3-6 7-6 1 0 2 .1 3 .4" />

                    <path d="M16 16l5 5" />

                    <path d="M21 16l-5 5" />

                </svg>

		</span> <span> 회원 탈퇴 </span>

		</a>

	</div>

</aside>