<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<%
request.setAttribute("activePage", "auth");

String ctx = request.getContextPath();

Boolean googleVerified = (Boolean) session.getAttribute("googleSignupVerified");

String googleEmail = (String) session.getAttribute("googleSignupEmail");

String googleName = (String) session.getAttribute("googleSignupName");

String googlePicture = (String) session.getAttribute("googleSignupPicture");

/*
 * Google 로그인을 정상적으로 거치지 않고
 * 직접 이 페이지에 접근한 경우
 */
if (!Boolean.TRUE.equals(googleVerified) || googleEmail == null) {

	response.sendRedirect(ctx + "/auth/login");

	return;
}

String errorMessage = (String) request.getAttribute("errorMessage");
%>


<!DOCTYPE html>
<html lang="ko">

<head>

<meta charset="UTF-8">

<meta name="viewport" content="width=device-width, initial-scale=1">

<title>회원정보 입력 · Planb</title>


<!-- 공통 스타일 -->
<jsp:include page="/common/headStyles.jsp" />


<!-- 기존 회원가입 CSS 그대로 사용 -->
<link rel="stylesheet" href="<%=ctx%>/view/assets/css/auth/signup.css">


<style>

/*
 * signup.css의 기존 UI를 그대로 쓰고
 * Google 계정 정보 표시 부분만 최소 추가
 */
.google-account-box {
	display: flex;
	align-items: center;
	gap: 14px;
	padding: 14px;
	margin-bottom: 20px;
	border: 1px solid #e7e7ec;
	border-radius: 10px;
	background: #fafaff;
}

.google-account-image {
	width: 46px;
	height: 46px;
	flex-shrink: 0;
	overflow: hidden;
	border: 1px solid #e4e4e9;
	border-radius: 50%;
	background: #f1f1f5;
}

.google-account-image img {
	width: 100%;
	height: 100%;
	object-fit: cover;
}

.google-account-placeholder {
	width: 100%;
	height: 100%;
	display: flex;
	align-items: center;
	justify-content: center;
	color: #999aa2;
	font-size: 10px;
}

.google-account-text {
	min-width: 0;
}

.google-account-name {
	margin: 0 0 4px;
	color: #2f3037;
	font-size: 13px;
	font-weight: 700;
}

.google-account-email {
	margin: 0;
	color: #8c8d95;
	font-size: 11px;
	overflow: hidden;
	text-overflow: ellipsis;
	white-space: nowrap;
}

.google-readonly {
	background: #f7f7f9 !important;
	color: #777982 !important;
	cursor: default;
}

.google-check-message {
	margin-top: 6px;
	font-size: 10.5px;
	min-height: 15px;
}

.google-check-message.success {
	color: #2f8f55;
}

.google-check-message.error {
	color: #c73d49;
}
</style>

</head>


<body class="site-shell">


	<jsp:include page="/common/header.jsp" />



	<main class="signup-main">


		<div class="signup-container">


			<!-- =====================================================
             상단
        ====================================================== -->

			<div class="signup-header">


				<a class="site-brand auth-page-brand" href="<%=ctx%>/home"
					aria-label="Planb 홈"> <span class="tripily-mark"
					aria-hidden="true"> <svg width="17" height="17"
							viewBox="0 0 24 24" fill="none">

            <path
								d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7Z"
								fill="currentColor" />

            <circle cx="12" cy="9" r="2.6" fill="white" />

        </svg>

				</span> <span class="site-brand-copy"> <strong> Planb </strong> <small>
							Travel Plan Share </small>

				</span>

				</a>


				<h1>추가정보 입력</h1>


				<p>Google 계정으로 가입하기 위해 필요한 정보를 입력해주세요.</p>


			</div>



			<!-- =====================================================
             카드
        ====================================================== -->

			<div class="signup-card">


				<form id="googleAdditionalForm"
					action="<%=ctx%>/auth/google/complete" method="post" novalidate>



					<!-- =================================================
                     Google 계정 정보
                ================================================== -->

					<section class="signup-section">


						<div class="section-title-area">


							<h2>Google 계정</h2>


						</div>



						<div class="google-account-box">


							<div class="google-account-image">


								<%
								if (googlePicture != null && !googlePicture.trim().isEmpty()) {
								%>


								<img src="<c:out value='${sessionScope.googleSignupPicture}' />"
									alt="Google 프로필 이미지">


								<%
								} else {
								%>


								<div class="google-account-placeholder">사진</div>


								<%
								}
								%>


							</div>



							<div class="google-account-text">


								<p class="google-account-name">

									<c:out value="${sessionScope.googleSignupName}"
										default="Google 사용자" />

								</p>


								<p class="google-account-email">

									<c:out value="${sessionScope.googleSignupEmail}" />

								</p>


							</div>


						</div>



						<!-- 이름 -->
						<div class="form-group">


							<label for="googleName"> 이름 </label> <input type="text"
								id="googleName" class="google-readonly"
								value="<c:out value='${sessionScope.googleSignupName}' />"
								readonly>


							<p class="input-help">Google 계정에서 가져온 이름입니다.</p>


						</div>



						<!-- 이메일 -->
						<div class="form-group">


							<label for="googleEmail"> 이메일 </label> <input type="email"
								id="googleEmail" class="google-readonly"
								value="<c:out value='${sessionScope.googleSignupEmail}' />"
								readonly>


							<p class="input-help">Google에서 인증된 이메일입니다.</p>


						</div>


					</section>



					<!-- =================================================
                     필수 정보
                ================================================== -->

					<section class="signup-section">


						<div class="section-title-area">


							<h2>기본 정보</h2>


							<span class="required-guide"> <span class="required">

									* </span> 필수 입력


							</span>


						</div>



						<!-- =================================================
                         닉네임
                    ================================================== -->

						<div class="form-group">


							<label for="nickname"> 닉네임 <span class="required">

									* </span>


							</label>



							<div class="postcode-row">


								<input type="text" id="nickname" name="nickname" maxlength="50"
									placeholder="사용할 닉네임" autocomplete="off" required>


								<button type="button" id="nicknameCheckButton"
									class="postcode-button">중복확인</button>


							</div>



							<p class="input-help">2자 이상 입력해주세요.</p>



							<p class="field-error" id="nicknameError"></p>



							<p class="google-check-message" id="nicknameMessage"></p>


						</div>



						<!-- =================================================
                         전화번호
                    ================================================== -->

						<div class="form-group">


							<label for="phone"> 전화번호 <span class="required"> *

							</span>


							</label> <input type="tel" id="phone" name="phone" maxlength="13"
								placeholder="010-1234-5678" autocomplete="tel"
								inputmode="numeric" required>


							<p class="input-help">숫자만 입력하면 하이픈(-)이 자동으로 입력됩니다.</p>


							<p class="field-error" id="phoneError"></p>


						</div>


					</section>



					<!-- =================================================
                     주소 정보
                ================================================== -->

					<section class="signup-section">


						<div class="section-title-area">


							<h2>주소 정보</h2>


						</div>



						<!-- =================================================
                         우편번호
                    ================================================== -->

						<div class="form-group">


							<label for="postcode"> 우편번호 <span class="required">

									* </span>


							</label>



							<div class="postcode-row">


								<input type="text" id="postcode" name="postcode" maxlength="100"
									placeholder="우편번호" readonly required>


								<button type="button" id="postcodeButton"
									class="postcode-button">주소 검색</button>


							</div>


							<p class="field-error" id="postcodeError"></p>


						</div>



						<!-- =================================================
                         기본 주소
                    ================================================== -->

						<div class="form-group">


							<label for="address"> 기본 주소 <span class="required">

									* </span>


							</label> <input type="text" id="address" name="address" maxlength="200"
								placeholder="주소 검색 시 자동으로 입력됩니다." readonly required>


							<p class="input-help">주소 검색에서 선택한 도로명 주소가 자동으로 입력됩니다.</p>


							<p class="field-error" id="addressError"></p>


						</div>



						<!-- =================================================
                         상세 주소
                    ================================================== -->

						<div class="form-group">


							<label for="addressDetail"> 상세 주소 <span class="optional">

									선택 </span>


							</label> <input type="text" id="addressDetail" name="addressDetail"
								maxlength="200" placeholder="동, 호수 등 상세 주소">


							<p class="input-help">필요한 경우 상세 주소를 직접 입력해주세요.</p>


						</div>


					</section>



					<!-- =================================================
                     서버 오류
                ================================================== -->

					<%
					if (errorMessage != null && !errorMessage.trim().isEmpty()) {
					%>


					<div class="signup-error-box">

						<%=errorMessage%>

					</div>


					<%
					}
					%>



					<!-- =================================================
                     클라이언트 오류
                ================================================== -->

					<div id="googleSignupError" class="signup-error-box" hidden>

						입력 내용을 다시 확인해주세요.</div>



					<!-- =================================================
                     가입 완료
                ================================================== -->

					<button type="submit" class="signup-submit">가입 완료</button>


				</form>


			</div>


		</div>


	</main>



	<jsp:include page="/common/footer.jsp" />



	<!-- ============================================================
     다음 우편번호 서비스
============================================================ -->

	<script
		src="https://t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js">
</script>

	<script>

document.addEventListener("DOMContentLoaded", function () {

    var form =
        document.getElementById("googleAdditionalForm");

    var nickname =
        document.getElementById("nickname");

    var nicknameCheckButton =
        document.getElementById("nicknameCheckButton");

    var nicknameError =
        document.getElementById("nicknameError");

    var nicknameMessage =
        document.getElementById("nicknameMessage");

    var phone =
        document.getElementById("phone");

    var phoneError =
        document.getElementById("phoneError");

    var postcode =
        document.getElementById("postcode");

    var postcodeError =
        document.getElementById("postcodeError");

    var address =
        document.getElementById("address");

    var addressError =
        document.getElementById("addressError");

    var addressDetail =
        document.getElementById("addressDetail");

    var postcodeButton =
        document.getElementById("postcodeButton");

    var googleSignupError =
        document.getElementById("googleSignupError");


    /*
     * form action:
     * /Planb/auth/google/complete
     *
     * 여기서 /Planb만 추출
     */
    var formAction =
        form.getAttribute("action") || "";

    var contextPath =
        formAction.replace(
            "/auth/google/complete",
            ""
        );


    var nicknameChecked =
        false;

    var checkedNickname =
        "";


    /* =========================================
       닉네임 입력 변경
       ========================================= */

    nickname.addEventListener(
        "input",
        function () {

            nicknameChecked = false;
            checkedNickname = "";

            nicknameError.textContent = "";
            nicknameMessage.textContent = "";

        }
    );


    /* =========================================
       닉네임 중복확인
       ========================================= */

    nicknameCheckButton.addEventListener(
        "click",
        function () {

            var value =
                nickname.value.trim();


            nicknameChecked = false;
            checkedNickname = "";

            nicknameError.textContent = "";
            nicknameMessage.textContent = "";


            if (value === "") {

                nicknameError.textContent =
                    "닉네임을 입력해주세요.";

                nickname.focus();

                return;
            }


            if (value.length < 2) {

                nicknameError.textContent =
                    "닉네임은 2자 이상 입력해주세요.";

                nickname.focus();

                return;
            }


            nicknameCheckButton.disabled =
                true;

            nicknameCheckButton.textContent =
                "확인 중...";


            var xhr =
                new XMLHttpRequest();


            var url =
                contextPath
                + "/auth/check-duplicate"
                + "?type=nickname"
                + "&value="
                + encodeURIComponent(value);


            xhr.open(
                "GET",
                url,
                true
            );


            xhr.onreadystatechange =
                function () {

                    if (
                        xhr.readyState !== 4
                    ) {

                        return;
                    }


                    nicknameCheckButton.disabled =
                        false;

                    nicknameCheckButton.textContent =
                        "중복확인";


                    if (
                        xhr.status !== 200
                    ) {

                        nicknameError.textContent =
                            "닉네임 중복확인 중 오류가 발생했습니다.";

                        return;
                    }


                    var data = null;


                    try {

                        data =
                            JSON.parse(
                                xhr.responseText
                            );

                    } catch (e) {

                        nicknameError.textContent =
                            "서버 응답을 확인할 수 없습니다.";

                        return;
                    }


                    if (
                        data.available === true
                    ) {

                        nicknameChecked =
                            true;

                        checkedNickname =
                            value;

                        nicknameMessage.textContent =
                            data.message
                            || "사용 가능한 닉네임입니다.";

                        nicknameMessage.style.color =
                            "#2f8f55";

                    } else {

                        nicknameChecked =
                            false;

                        checkedNickname =
                            "";

                        nicknameError.textContent =
                            data.message
                            || "이미 사용 중인 닉네임입니다.";

                    }

                };


            xhr.onerror =
                function () {

                    nicknameCheckButton.disabled =
                        false;

                    nicknameCheckButton.textContent =
                        "중복확인";

                    nicknameError.textContent =
                        "서버와 통신할 수 없습니다.";

                };


            xhr.send();

        }
    );


    /* =========================================
       전화번호 자동 하이픈
       ========================================= */

    phone.addEventListener(
        "input",
        function () {

            phoneError.textContent = "";


            var value =
                this.value.replace(
                    /[^0-9]/g,
                    ""
                );


            if (
                value.length > 11
            ) {

                value =
                    value.substring(
                        0,
                        11
                    );

            }


            if (
                value.length <= 3
            ) {

                this.value =
                    value;

            } else if (
                value.length <= 7
            ) {

                this.value =
                    value.substring(
                        0,
                        3
                    )
                    + "-"
                    + value.substring(
                        3
                    );

            } else {

                this.value =
                    value.substring(
                        0,
                        3
                    )
                    + "-"
                    + value.substring(
                        3,
                        7
                    )
                    + "-"
                    + value.substring(
                        7,
                        11
                    );

            }

        }
    );


    /* =========================================
       주소 검색
       ========================================= */

    postcodeButton.addEventListener(
        "click",
        function () {

            if (
                typeof daum === "undefined"
                || typeof daum.Postcode === "undefined"
            ) {

                alert(
                    "주소 검색 서비스를 불러오지 못했습니다."
                );

                return;
            }


            new daum.Postcode({

                oncomplete: function (data) {

                    var selectedAddress =
                        "";


                    /*
                     * 도로명주소가 있으면
                     * 도로명주소 우선 사용
                     */
                    if (
                        data.roadAddress
                        && data.roadAddress !== ""
                    ) {

                        selectedAddress =
                            data.roadAddress;

                    } else {

                        selectedAddress =
                            data.jibunAddress;

                    }


                    /*
                     * 우편번호 자동입력
                     */
                    postcode.value =
                        data.zonecode;


                    /*
                     * 기본주소 자동입력
                     */
                    address.value =
                        selectedAddress;


                    postcodeError.textContent =
                        "";

                    addressError.textContent =
                        "";


                    /*
                     * 상세주소는 사용자가 직접 입력
                     */
                    addressDetail.focus();

                }

            }).open();

        }
    );


    /* =========================================
       최종 가입 검증
       ========================================= */

    form.addEventListener(
        "submit",
        function (event) {

            var valid =
                true;


            nicknameError.textContent =
                "";

            phoneError.textContent =
                "";

            postcodeError.textContent =
                "";

            addressError.textContent =
                "";

            googleSignupError.hidden =
                true;


            /* 닉네임 */

            var nicknameValue =
                nickname.value.trim();


            if (
                nicknameValue === ""
            ) {

                nicknameError.textContent =
                    "닉네임을 입력해주세요.";

                valid =
                    false;

            } else if (
                nicknameValue.length < 2
            ) {

                nicknameError.textContent =
                    "닉네임은 2자 이상 입력해주세요.";

                valid =
                    false;

            } else if (
                nicknameChecked === false
                || checkedNickname
                    !== nicknameValue
            ) {

                nicknameError.textContent =
                    "닉네임 중복확인을 해주세요.";

                valid =
                    false;

            }


            /* 전화번호 */

            var phonePattern =
                /^01[016789]-[0-9]{3,4}-[0-9]{4}$/;


            if (
                phone.value.trim() === ""
            ) {

                phoneError.textContent =
                    "전화번호를 입력해주세요.";

                valid =
                    false;

            } else if (
                !phonePattern.test(
                    phone.value
                )
            ) {

                phoneError.textContent =
                    "올바른 전화번호를 입력해주세요.";

                valid =
                    false;

            }


            /* 주소 */

            if (
                postcode.value.trim() === ""
            ) {

                postcodeError.textContent =
                    "주소 검색을 진행해주세요.";

                valid =
                    false;

            }


            if (
                address.value.trim() === ""
            ) {

                addressError.textContent =
                    "주소를 입력해주세요.";

                valid =
                    false;

            }


            if (
                valid === false
            ) {

                event.preventDefault();

                googleSignupError.hidden =
                    false;

            }

        }
    );

});

</script>



</body>

</html>