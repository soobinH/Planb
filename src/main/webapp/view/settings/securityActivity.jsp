<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"
    import="dto.member.UserDto" %>

<%
request.setAttribute("activePage", "profile");
request.setAttribute("settingsPage", "security");

String ctx = request.getContextPath();

UserDto user =
        (UserDto) session.getAttribute("user");

if (user == null) {
    response.sendRedirect(ctx + "/auth/login");
    return;
}

String loginId =
        user.getLoginId() == null
            ? ""
            : user.getLoginId();
%>

<!DOCTYPE html>
<html lang="ko">

<head>

<meta charset="UTF-8">

<meta name="viewport"
      content="width=device-width, initial-scale=1">

<title>보안 및 로그인 활동</title>

<jsp:include page="/common/headStyles.jsp" />

<link
    rel="stylesheet"
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

                    <span class="settings-eyebrow">
                        SETTINGS
                    </span>

                    <h1>
                        보안 및 로그인 활동
                    </h1>

                    <p>
                        현재 로그인한 계정과
                        계정 보안 정보를 확인합니다.
                    </p>

                </header>


                <section class="settings-panel settings-list-panel">


                    <div class="security-summary">

                        <span class="security-icon">
                            ✓
                        </span>


                        <div class="security-copy">

                            <strong>
                                현재 로그인 계정
                            </strong>

                            <small>
                                <%=loginId%> 계정으로 로그인되어 있습니다.
                            </small>

                        </div>


                        <span class="security-badge">
                            현재 세션
                        </span>

                    </div>


                    <div class="security-summary">

                        <span class="security-icon">
                            ⌁
                        </span>


                        <div class="security-copy">

                            <strong>
                                비밀번호 관리
                            </strong>

                            <small>
                                주기적으로 비밀번호를 변경해
                                계정을 안전하게 보호하세요.
                            </small>

                        </div>


                        <a
                            class="settings-soft-btn"
                            href="<%=ctx%>/settings/passwordChange"
                            style="text-decoration:none;">

                            변경

                        </a>

                    </div>


                </section>


            


            </div>

        </main>


    </div>

</div>


<jsp:include page="/common/footer.jsp" />

</body>
</html>
