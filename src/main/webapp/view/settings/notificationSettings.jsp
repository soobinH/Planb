<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8" import="dto.member.UserDto"%>

<%

request.setAttribute(
        "activePage",
        "profile"
);

request.setAttribute(
        "settingsPage",
        "notification"
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
            ctx + "/view/auth/login.jsp"
    );

    return;
}


/* =========================================================
   Servlet에서 조회한 현재 DB 설정
========================================================= */

Boolean notifyLikeAttr =
        (Boolean)
        request.getAttribute(
                "notifyLike"
        );


Boolean notifyCommentAttr =
        (Boolean)
        request.getAttribute(
                "notifyComment"
        );


boolean notifyLike =
        notifyLikeAttr == null
        ? true
        : notifyLikeAttr;


boolean notifyComment =
        notifyCommentAttr == null
        ? true
        : notifyCommentAttr;

%>


<!DOCTYPE html>

<html lang="ko">

<head>

<meta charset="UTF-8">

<meta name="viewport" content="width=device-width, initial-scale=1">


<title>알림 설정</title>


<jsp:include page="/common/headStyles.jsp" />


<link rel="stylesheet"
	href="<%=ctx%>/view/assets/css/setting/settings.css">


<style>

/* =========================================================
   알림 설정
========================================================= */
.notification-info {
	margin-bottom: 16px;
	padding: 14px 16px;
	border: 1px solid #e7e7ef;
	border-radius: 11px;
	background: #fafaff;
	color: #7b7c86;
	font-size: 10.5px;
	line-height: 1.65;
}

/* 알림 행 */
.notification-row-content {
	min-width: 0;
	display: flex;
	align-items: center;
	gap: 13px;
}

.notification-icon {
	width: 38px;
	height: 38px;
	flex: 0 0 38px;
	display: flex;
	align-items: center;
	justify-content: center;
	border-radius: 10px;
	background: #f0f0ff;
	color: #6369D1;
	font-size: 17px;
	font-weight: 700;
}

.notification-row-content
.toggle-copy {
	min-width: 0;
}

/* =========================================================
   저장 상태
========================================================= */
.notification-status {
	min-height: 21px;
	margin-top: 12px;
	color: #999aa3;
	font-size: 10px;
	line-height: 1.5;
	transition: color .15s ease;
}

.notification-status.saving {
	color: #6369D1;
}

.notification-status.success {
	color: #318354;
}

.notification-status.error {
	color: #d6404d;
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


					<!-- =================================================
                     TITLE
                ================================================== -->

					<header class="settings-title">


						<span class="settings-eyebrow"> SETTINGS </span>


						<h1>알림 설정</h1>


						<p>필요한 활동 알림만 선택해서 받을 수 있습니다.</p>


					</header>



					<!-- =================================================
                     INFO
                ================================================== -->

					<div class="notification-info">토글을 변경하면 별도의 저장 버튼 없이 즉시 알림
						설정에 반영됩니다.</div>



					<!-- =================================================
                     LIST
                ================================================== -->

					<section
						class="settings-panel
                           settings-list-panel">


						<!-- =============================================
                         좋아요
                    ============================================== -->

						<div class="toggle-row">


							<div class="notification-row-content">


								<div class="notification-icon">♡</div>


								<div class="toggle-copy">


									<strong> 좋아요 알림 </strong> <span> 내 여행 일정이나 게시물에 좋아요가
										등록되면 알려드립니다. </span>


								</div>


							</div>



							<label class="switch"> <input type="checkbox"
								id="notifyLike"
								<%=notifyLike
                                    ? "checked"
                                    : ""%>>


								<span class="slider"> </span>


							</label>


						</div>



						<!-- =============================================
                         댓글
                    ============================================== -->

						<div class="toggle-row">


							<div class="notification-row-content">


								<div class="notification-icon">◯</div>


								<div class="toggle-copy">


									<strong> 댓글 알림 </strong> <span> 내 여행 일정이나 게시물에 새 댓글이
										등록되면 알려드립니다. </span>


								</div>


							</div>



							<label class="switch"> <input type="checkbox"
								id="notifyComment"
								<%=notifyComment
                                    ? "checked"
                                    : ""%>>


								<span class="slider"> </span>


							</label>


						</div>


					</section>



					<!-- =================================================
                     저장 상태
                ================================================== -->

					<div id="notificationStatus" class="notification-status"></div>


				</div>


			</main>


		</div>


	</div>



	<jsp:include page="/common/footer.jsp" />



	<script>

document.addEventListener(
    "DOMContentLoaded",
    function () {


        const ctx =
            "<%=ctx%>";


        const notifyLike =
            document.getElementById(
                "notifyLike"
            );


        const notifyComment =
            document.getElementById(
                "notifyComment"
            );


        const status =
            document.getElementById(
                "notificationStatus"
            );


        let statusTimer = null;



        /* =====================================================
           상태 메시지
        ====================================================== */

        function showStatus(
            message,
            type
        ) {


            if (statusTimer) {

                clearTimeout(
                    statusTimer
                );

            }


            status.className =
                "notification-status "
                + type;


            status.textContent =
                message;


            /*
             * 성공 메시지는 잠시 후 삭제
             */
            if (
                type === "success"
            ) {


                statusTimer =
                    setTimeout(
                        function () {


                            status.textContent =
                                "";


                            status.className =
                                "notification-status";


                        },
                        1800
                    );

            }

        }



        /* =====================================================
           서버 저장
        ====================================================== */

        async function saveNotification(
            type,
            checkbox
        ) {


            /*
             * 바뀌기 전 상태
             *
             * change 이벤트가 발생한 시점에는 이미
             * checkbox.checked가 변경된 상태이므로
             * 반대값이 이전 상태
             */

            const previousValue =
                !checkbox.checked;


            const enabled =
                checkbox.checked;


            /*
             * 저장 중 중복 조작 방지
             */

            checkbox.disabled =
                true;


            showStatus(
                "설정을 저장하고 있습니다.",
                "saving"
            );



            try {


                const body =
                    new URLSearchParams();


                body.append(
                    "type",
                    type
                );


                body.append(
                    "enabled",
                    enabled
                        ? "1"
                        : "0"
                );



                const response =
                    await fetch(
                        ctx
                        + "/settings/notificationSettings",
                        {

                            method:
                                "POST",

                            headers: {

                                "Content-Type":
                                    "application/x-www-form-urlencoded; charset=UTF-8",

                                "X-Requested-With":
                                    "XMLHttpRequest"

                            },

                            body:
                                body.toString()

                        }
                    );



                if (!response.ok) {

                    throw new Error(
                        "HTTP "
                        + response.status
                    );

                }



                const result =
                    await response.json();



                if (!result.success) {

                    throw new Error(
                        result.message
                        || "저장 실패"
                    );

                }



                showStatus(
                    "알림 설정이 저장되었습니다.",
                    "success"
                );



            } catch (error) {


                /*
                 * DB 저장 실패하면
                 * 화면 토글을 원래 상태로 복구
                 */

                checkbox.checked =
                    previousValue;


                showStatus(
                    "알림 설정 저장에 실패했습니다.",
                    "error"
                );


                console.error(
                    error
                );



            } finally {


                checkbox.disabled =
                    false;

            }

        }



        /* =====================================================
           LIKE
        ====================================================== */

        notifyLike.addEventListener(
            "change",
            function () {


                saveNotification(
                    "LIKE",
                    notifyLike
                );

            }
        );



        /* =====================================================
           COMMENT
        ====================================================== */

        notifyComment.addEventListener(
            "change",
            function () {


                saveNotification(
                    "COMMENT",
                    notifyComment
                );

            }
        );


    }
);

</script>


</body>

</html>