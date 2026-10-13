<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8" import="dto.member.UserDto"%>

<%
request.setAttribute(
    "activePage",
    "profile"
);

request.setAttribute(
    "settingsPage",
    "privacy"
);

String ctx =
        request.getContextPath();


/* =========================================
   로그인 사용자
========================================= */

UserDto user =
        (UserDto)
        session.getAttribute("user");


if (user == null) {

    response.sendRedirect(
        ctx + "/auth/login"
    );

    return;
}


/* =========================================
   현재 DB 설정값
========================================= */

String profileVisibility =
        user.getProfileVisibility();


if (profileVisibility == null
        || profileVisibility
            .trim()
            .isEmpty()) {

    profileVisibility =
            "PUBLIC";
}


boolean showBookmarkedItinerary = Boolean.TRUE.equals(user.getShowBookmarkedItinerary());


boolean showLikedItinerary =Boolean.TRUE.equals(user.getShowLikedItinerary());

%>


<!DOCTYPE html>

<html lang="ko">


<head>

<meta charset="UTF-8">

<meta name="viewport" content="width=device-width, initial-scale=1">


<title>개인정보 및 공개범위</title>


<jsp:include page="/common/headStyles.jsp" />


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


					<!-- =========================================
                     제목
                ========================================== -->

					<header class="settings-title">


						<span class="settings-eyebrow"> SETTINGS </span>


						<h1>개인정보 및 공개범위</h1>


						<p>프로필과 피드에 노출되는 정보를 항목별로 관리합니다.</p>


					</header>



					<!-- =========================================
                     프로필 공개범위
                ========================================== -->

					<section class="settings-panel">


						<div class="panel-head">


							<h3>프로필 공개범위</h3>


							<p>다른 사용자가 내 프로필을 볼 수 있는 범위를 선택합니다.</p>


						</div>



						<div class="visibility-options">


							<!-- 공개 -->

							<label class="visibility-option"> <input type="radio"
								id="profileVisibilityPublic" name="profileVisibility"
								value="PUBLIC"
								<%=
                                    "PUBLIC".equals(
                                        profileVisibility
                                    )
                                    ? "checked"
                                    : ""
                                %>>


								<span> <strong> 공개 </strong> <small> 다른 사용자가 내
										프로필과 공개 게시물을 볼 수 있습니다. </small>


							</span>


							</label>



							<!-- 비공개 -->

							<label class="visibility-option"> <input type="radio"
								id="profileVisibilityPrivate" name="profileVisibility"
								value="PRIVATE"
								<%=
                                    "PRIVATE".equals(
                                        profileVisibility
                                    )
                                    ? "checked"
                                    : ""
                                %>>


								<span> <strong> 비공개 </strong> <small> 내 프로필과 활동
										정보의 노출을 제한합니다. </small>


							</span>


							</label>


						</div>


					</section>



					<!-- =========================================
                     좋아요 / 북마크 공개
                ========================================== -->

					<section class="settings-panel settings-list-panel">


						<!-- =====================================
                         북마크
                    ====================================== -->

						<div class="toggle-row">


							<div class="toggle-copy">


								<strong> 북마크한 게시글 공개 </strong> <span> 내 프로필의 북마크한 게시글 탭을
									다른 사용자에게 공개합니다. </span>


							</div>



							<label class="switch"> <input type="checkbox"
								id="showBookmarkedItinerary"
								<%=
                                    showBookmarkedItinerary
                                    ? "checked"
                                    : ""
                                %>>


								<span class="slider"> </span>


							</label>


						</div>



						<!-- =====================================
                         좋아요
                    ====================================== -->

						<div class="toggle-row">


							<div class="toggle-copy">


								<strong> 좋아요한 게시글 공개 </strong> <span> 내 프로필의 좋아요한 게시글 탭을
									다른 사용자에게 공개합니다. </span>


							</div>



							<label class="switch"> <input type="checkbox"
								id="showLikedItinerary"
								<%=
                                    showLikedItinerary
                                    ? "checked"
                                    : ""
                                %>>


								<span class="slider"> </span>


							</label>


						</div>


					</section>


				</div>


			</main>


		</div>


	</div>



	<jsp:include page="/common/footer.jsp" />



	<script>

(function () {


    const ctx =
        "<%=ctx%>";



    /* =========================================
       공통 POST 함수
    ========================================= */

    function postSetting(
            url,
            parameterName,
            value) {


        const body =
            new URLSearchParams();


        body.append(
            parameterName,
            value
        );


        return fetch(
            ctx + url,

            {

                method:
                    "POST",

                headers: {

                    "Content-Type":
                        "application/x-www-form-urlencoded; charset=UTF-8"

                },

                body:
                    body.toString()

            }
        )

        .then(function (response) {


            return response
                .json()
                .then(function (data) {


                    return {

                        ok:
                            response.ok,

                        data:
                            data

                    };


                });

        })

        .then(function (result) {


            if (!result.ok
                    || !result.data.success) {


                throw new Error(

                    result.data.message
                    || "설정을 저장하지 못했습니다."

                );

            }


            return result.data;

        });

    }



    /* =========================================
       프로필 공개범위
    ========================================= */

    const profileRadios =
        document.querySelectorAll(
            'input[name="profileVisibility"]'
        );


    let previousProfileVisibility =
        "<%=profileVisibility%>";



    profileRadios.forEach(
        function (radio) {


            radio.addEventListener(
                "change",
                function () {


                    if (!this.checked) {
                        return;
                    }


                    const changedRadio =
                        this;


                    const newValue =
                        changedRadio.value;


                    /*
                     * 요청 중 중복 변경 방지
                     */
                    profileRadios.forEach(
                        function (item) {

                            item.disabled =
                                true;

                        }
                    );


                    postSetting(
                        "/settings/privacy/profile",
                        "profileVisibility",
                        newValue
                    )

                    .then(function () {


                        previousProfileVisibility =
                            newValue;


                        console.log(
                            "프로필 공개범위 저장 완료:",
                            newValue
                        );

                    })

                    .catch(function (error) {


                        console.error(
                            error
                        );


                        /*
                         * 저장 실패 시 이전 값으로 되돌림
                         */

                        profileRadios.forEach(
                            function (item) {


                                item.checked =
                                    item.value
                                    === previousProfileVisibility;


                            }
                        );


                        alert(
                            error.message
                        );

                    })

                    .finally(function () {


                        profileRadios.forEach(
                            function (item) {

                                item.disabled =
                                    false;

                            }
                        );


                    });

                }
            );

        }
    );



    /* =========================================
       북마크 공개
    ========================================= */

    const bookmarkToggle =
        document.getElementById(
            "showBookmarkedItinerary"
        );


    if (bookmarkToggle) {


        bookmarkToggle.addEventListener(
            "change",
            function () {


                const checkbox =
                    this;


                const newValue =
                    checkbox.checked;


                checkbox.disabled =
                    true;


                postSetting(
                    "/settings/privacy/bookmark",
                    "showBookmarkedItinerary",
                    newValue
                        ? "true"
                        : "false"
                )

                .then(function () {


                    console.log(
                        "북마크 공개 설정 저장:",
                        newValue
                    );

                })

                .catch(function (error) {


                    console.error(
                        error
                    );


                    /*
                     * 실패하면 이전 상태로 복구
                     */
                    checkbox.checked =
                        !newValue;


                    alert(
                        error.message
                    );

                })

                .finally(function () {


                    checkbox.disabled =
                        false;


                });

            }
        );

    }



    /* =========================================
       좋아요 공개
    ========================================= */

    const likedToggle =
        document.getElementById(
            "showLikedItinerary"
        );


    if (likedToggle) {


        likedToggle.addEventListener(
            "change",
            function () {


                const checkbox =
                    this;


                const newValue =
                    checkbox.checked;


                checkbox.disabled =
                    true;


                postSetting(
                    "/settings/privacy/like",
                    "showLikedItinerary",
                    newValue
                        ? "true"
                        : "false"
                )

                .then(function () {


                    console.log(
                        "좋아요 공개 설정 저장:",
                        newValue
                    );

                })

                .catch(function (error) {


                    console.error(
                        error
                    );


                    checkbox.checked =
                        !newValue;


                    alert(
                        error.message
                    );

                })

                .finally(function () {


                    checkbox.disabled =
                        false;


                });

            }
        );

    }


})();

</script>


</body>

</html>