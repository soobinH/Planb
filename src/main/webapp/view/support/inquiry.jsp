<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8" import="dto.member.UserDto"%>

<%

request.setAttribute(
        "activePage",
        "profile"
);

request.setAttribute(
        "settingsPage",
        "support"
);


String ctx =
        request.getContextPath();


UserDto user =
        (UserDto)
        session.getAttribute(
                "user"
        );


if (user == null) {

    response.sendRedirect(
            ctx + "/auth/login"
    );

    return;
}


/* =====================================
   로그인 회원 이메일
====================================== */

String userEmail =
        user.getEmail() == null
        ? ""
        : user.getEmail();


/* =====================================
   오류 후 기존 입력값 유지
====================================== */

String category =
        request.getAttribute("category")
        == null
        ? "ACCOUNT"
        : String.valueOf(
            request.getAttribute("category")
        );


String email =
        request.getAttribute("email")
        == null
        ? userEmail
        : String.valueOf(
            request.getAttribute("email")
        );


String title =
        request.getAttribute("title")
        == null
        ? ""
        : String.valueOf(
            request.getAttribute("title")
        );


String content =
        request.getAttribute("content")
        == null
        ? ""
        : String.valueOf(
            request.getAttribute("content")
        );


String errorMessage =
        (String)
        request.getAttribute(
                "errorMessage"
        );


boolean success =
        "1".equals(
            request.getParameter(
                    "success"
            )
        );

%>


<!DOCTYPE html>

<html lang="ko">

<head>

<meta charset="UTF-8">

<meta name="viewport" content="width=device-width, initial-scale=1">

<title>문의하기</title>


<jsp:include page="/common/headStyles.jsp" />


<link rel="stylesheet"
	href="<%=ctx%>/view/assets/css/support/support.css">


<link rel="stylesheet"
	href="<%=ctx%>/view/assets/css/setting/settings.css">


</head>


<body class="site-shell">


	<jsp:include page="/common/header.jsp" />


	<div class="settings-page">

		<div class="settings-shell">


			<jsp:include page="/common/settingsSidebar.jsp" />


			<main class="settings-main">

				<div class="settings-content">


					<header class="settings-title">

						<span class="settings-eyebrow"> SETTINGS </span>

						<h1>문의하기</h1>

						<p>문의 내용을 남겨주시면 담당자가 확인 후 답변드립니다.</p>

					</header>



					<a class="support-back" href="<%=ctx%>/view/support/support.jsp">

						‹ 고객지원 </a>



					<% if (success) { %>

					<div
						style="margin-bottom: 18px; padding: 14px 16px; border-radius: 10px; background: #f1f8f4; color: #2f7a4c; font-size: 12px; line-height: 1.6;">

						문의가 정상적으로 접수되었습니다. 담당자가 확인 후 처리하겠습니다.</div>

					<% } %>



					<% if (errorMessage != null) { %>

					<div
						style="margin-bottom: 18px; padding: 14px 16px; border-radius: 10px; background: #fff2f3; color: #d6404d; font-size: 12px; line-height: 1.6;">

						<%=errorMessage%>

					</div>

					<% } %>



					<form action="<%=ctx%>/support/inquiry" method="post">


						<section class="settings-panel settings-form-panel">


							<div class="settings-form">


								<!-- =========================
                                 문의 유형
                            ========================== -->

								<label class="settings-field"> <span
									class="settings-field-label"> 문의 유형 </span> <select
									name="category" required>


										<option value="ACCOUNT"
											<%= "ACCOUNT".equals(category)
                                            ? "selected"
                                            : "" %>>

											계정/프로필</option>


										<option value="ITINERARY"
											<%= "ITINERARY".equals(category)
                                            ? "selected"
                                            : "" %>>

											여행 일정</option>


										<option value="COMMUNITY"
											<%= "COMMUNITY".equals(category)
                                            ? "selected"
                                            : "" %>>

											게시글/커뮤니티</option>


										<option value="ERROR"
											<%= "ERROR".equals(category)
                                            ? "selected"
                                            : "" %>>

											오류 신고</option>


										<option value="ETC"
											<%= "ETC".equals(category)
                                            ? "selected"
                                            : "" %>>

											기타</option>


								</select>

								</label>



								<!-- =========================
                                 이메일
                            ========================== -->

								<label class="settings-field"> <span
									class="settings-field-label"> 답변 받을 이메일 </span> <input
									type="email" name="email" maxlength="100" value="<%=email%>"
									required>


								</label>



								<!-- =========================
                                 제목
                            ========================== -->

								<label class="settings-field"> <span
									class="settings-field-label"> 문의 제목 </span> <input type="text"
									name="title" maxlength="60" value="<%=title%>"
									placeholder="문의 제목을 입력해주세요." required>


								</label>



								<!-- =========================
                                 문의 내용
                            ========================== -->

								<label class="settings-field"> <span
									class="settings-field-label"> 문의 내용 </span> <textarea
										name="content" rows="7" maxlength="3000"
										placeholder="문의 내용을 자세히 작성해주세요." required><%=content%></textarea>


									<small> 개인정보나 비밀번호 등 민감한 정보는 입력하지 마세요. </small>


								</label>


							</div>


						</section>



						<div class="settings-actions support-form-actions">


							<a class="btn-soft" href="<%=ctx%>/view/support/support.jsp">

								취소 </a>


							<button type="submit" class="btn-primary">문의 접수</button>


						</div>


					</form>


				</div>

			</main>

		</div>

	</div>


	<jsp:include page="/common/footer.jsp" />


</body>

</html>