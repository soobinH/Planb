<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="dto.member.UserDto"%>

<%!
private String escapeHtml(String value) {

    if (value == null) {
        return "";
    }

    return value
            .replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace("\"", "&quot;")
            .replace("'", "&#39;");
}
%>

<%

request.setAttribute("activePage", "profile");
request.setAttribute("settingsPage", "support");

String ctx =
        request.getContextPath();


/* =========================================================
   로그인 회원
   광고 문의는 비회원도 가능
========================================================= */

UserDto user =
        (UserDto)
        session.getAttribute("user");


String defaultManagerName = "";
String defaultEmail = "";


if (user != null) {

    defaultManagerName =
            user.getName() == null
            ? ""
            : user.getName();

    defaultEmail =
            user.getEmail() == null
            ? ""
            : user.getEmail();
}


/* =========================================================
   광고 안내에서 넘어온 위치
========================================================= */

String selectedAdPosition =
        request.getParameter("adPosition");


Object preservedAdPosition =
        request.getAttribute("adPosition");


if (preservedAdPosition != null) {

    selectedAdPosition =
            String.valueOf(
                    preservedAdPosition
            );
}


/*
 * 현재 실제 광고 상품 3종만 허용
 */
if (
    !"TRIP_CARD".equals(selectedAdPosition)
    &&
    !"TIP_SIDE".equals(selectedAdPosition)
    &&
    !"MATE_SIDE".equals(selectedAdPosition)
) {

    selectedAdPosition = "";
}


/* =========================================================
   처리 결과
========================================================= */

boolean success =
        "1".equals(
                request.getParameter("success")
        );


String errorMessage =
        (String)
        request.getAttribute("errorMessage");


/* =========================================================
   오류 발생 후 입력값 유지
========================================================= */

String formBusinessName =
        request.getAttribute("businessName") == null
        ? ""
        : String.valueOf(
                request.getAttribute("businessName")
        );


String formManagerName =
        request.getAttribute("managerName") == null
        ? defaultManagerName
        : String.valueOf(
                request.getAttribute("managerName")
        );


String formPhone =
        request.getAttribute("phone") == null
        ? ""
        : String.valueOf(
                request.getAttribute("phone")
        );


String formEmail =
        request.getAttribute("email") == null
        ? defaultEmail
        : String.valueOf(
                request.getAttribute("email")
        );


String formLinkUrl =
        request.getAttribute("linkUrl") == null
        ? ""
        : String.valueOf(
                request.getAttribute("linkUrl")
        );


String formContent =
        request.getAttribute("content") == null
        ? ""
        : String.valueOf(
                request.getAttribute("content")
        );


String formStartDate =
        request.getAttribute("startDate") == null
        ? ""
        : String.valueOf(
                request.getAttribute("startDate")
        );


String formEndDate =
        request.getAttribute("endDate") == null
        ? ""
        : String.valueOf(
                request.getAttribute("endDate")
        );

%>

<!DOCTYPE html>

<html lang="ko">

<head>

<meta charset="UTF-8">

<meta name="viewport"
    content="width=device-width, initial-scale=1">

<title>광고 문의하기</title>

<jsp:include page="/common/headStyles.jsp" />


<link rel="stylesheet"
    href="<%=ctx%>/view/assets/css/setting/settings.css">


<link rel="stylesheet"
    href="<%=ctx%>/view/assets/css/support/support.css">


<!-- 반드시 support.css보다 뒤에 -->
<link rel="stylesheet"
    href="<%=ctx%>/view/assets/css/support/adInquiry.css">

</head>


<body class="site-shell">

<jsp:include page="/common/header.jsp" />


<div class="settings-page">

    <div class="settings-shell">

        <jsp:include page="/common/settingsSidebar.jsp" />


        <main class="settings-main">

            <div class="settings-content ad-inquiry-compact">


                <!-- =================================================
                     TOP
                ================================================== -->

                <div class="ad-inquiry-top">

                    <a
                        href="<%=ctx%>/view/support/adGuide.jsp">

                        <span>←</span>
                        광고 안내

                    </a>


                    <span>
                        AD INQUIRY
                    </span>

                </div>



                <header class="ad-inquiry-header">

                    <h1>
                        광고 문의하기
                    </h1>

                    <p>
                        광고 위치와 기간, 이미지를 등록하면
                        담당자가 내용을 검토한 뒤 안내드립니다.
                    </p>

                </header>



                <!-- =================================================
                     성공 / 오류
                ================================================== -->

                <% if (success) { %>

                <div class="ad-inquiry-message success">

                    <strong>
                        광고 문의가 접수되었습니다.
                    </strong>

                    <span>
                        담당자가 내용을 검토한 후 입력한 이메일로 안내드립니다.
                    </span>

                </div>

                <% } %>


                <%
                if (
                    errorMessage != null
                    &&
                    !errorMessage.trim().isEmpty()
                ) {
                %>

                <div class="ad-inquiry-message error">

                    <strong>
                        문의를 접수하지 못했습니다.
                    </strong>

                    <span>
                        <%=escapeHtml(errorMessage)%>
                    </span>

                    <small>
                        광고 이미지는 보안상 다시 선택해야 합니다.
                    </small>

                </div>

                <%
                }
                %>



                <!-- =================================================
                     상품 요약
                ================================================== -->

                <section class="ad-inquiry-guide">

                    <div class="ad-inquiry-guide-title">

                        <div>

                            <span>
                                PLACEMENT GUIDE
                            </span>

                            <strong>
                                현재 신청 가능한 광고 영역
                            </strong>

                        </div>


                        <a
                            href="<%=ctx%>/view/support/adGuide.jsp">
                            자세히 보기 →
                        </a>

                    </div>


                    <div class="ad-inquiry-guide-grid">

                        <div>
                            <span>HOME</span>
                            <strong>슬라이딩 카드</strong>
                            <b>600 × 400</b>
                        </div>

                        <div>
                            <span>TIP</span>
                            <strong>좌·우 사이드</strong>
                            <b>160 × 600</b>
                        </div>

                        <div>
                            <span>MATE</span>
                            <strong>좌·우 사이드</strong>
                            <b>160 × 600</b>
                        </div>

                    </div>

                </section>



                <!-- =================================================
                     FORM
                ================================================== -->

                <form
                    id="adInquiryForm"
                    action="<%=ctx%>/support/adInquiry"
                    method="post"
                    enctype="multipart/form-data">


                    <!-- =================================================
                         01 업체 정보
                    ================================================== -->

                    <section class="ad-inquiry-panel">

                        <div class="ad-inquiry-panel-head">

                            <span>01</span>

                            <div>

                                <h2>
                                    업체 및 담당자 정보
                                </h2>

                                <p>
                                    문의 답변을 받을 기본 정보를 입력해주세요.
                                </p>

                            </div>

                        </div>


                        <div class="ad-inquiry-form-grid two">


                            <div class="ad-inquiry-field">

                                <label for="businessName">
                                    회사/브랜드명
                                </label>

                                <input
                                    type="text"
                                    id="businessName"
                                    name="businessName"
                                    maxlength="100"
                                    value="<%=escapeHtml(formBusinessName)%>"
                                    placeholder="회사 또는 브랜드명"
                                    required>

                            </div>


                            <div class="ad-inquiry-field">

                                <label for="managerName">
                                    담당자명
                                </label>

                                <input
                                    type="text"
                                    id="managerName"
                                    name="managerName"
                                    maxlength="100"
                                    value="<%=escapeHtml(formManagerName)%>"
                                    placeholder="담당자 이름"
                                    required>

                            </div>


                            <div class="ad-inquiry-field">

                                <label for="email">
                                    연락 이메일
                                </label>

                                <input
                                    type="email"
                                    id="email"
                                    name="email"
                                    maxlength="150"
                                    value="<%=escapeHtml(formEmail)%>"
                                    placeholder="example@company.com"
                                    required>

                                <small>
                                    광고 검토 및 승인 결과를 받을 이메일입니다.
                                </small>

                            </div>


                            <div class="ad-inquiry-field">

                                <label for="phone">
                                    전화번호
                                </label>

                                <input
                                    type="tel"
                                    id="phone"
                                    name="phone"
                                    maxlength="13"
                                    inputmode="numeric"
                                    autocomplete="tel"
                                    value="<%=escapeHtml(formPhone)%>"
                                    placeholder="010-1234-5678"
                                    required>

                                <small>
                                    숫자만 입력해도 하이픈이 자동 입력됩니다.
                                </small>

                            </div>

                        </div>

                    </section>



                    <!-- =================================================
                         02 광고 위치
                    ================================================== -->

                    <section class="ad-inquiry-panel">

                        <div class="ad-inquiry-panel-head">

                            <span>02</span>

                            <div>

                                <h2>
                                    광고 위치 선택
                                </h2>

                                <p>
                                    광고를 노출할 페이지 영역을 선택해주세요.
                                </p>

                            </div>

                        </div>


                        <div class="ad-inquiry-position-grid">


                            <!-- HOME -->

                            <label class="ad-inquiry-position-card">

                                <input
                                    type="radio"
                                    name="adPosition"
                                    value="TRIP_CARD"
                                    <%=
                                        "TRIP_CARD".equals(
                                                selectedAdPosition
                                        )
                                        ? "checked"
                                        : ""
                                    %>
                                    required>


                                <span class="ad-inquiry-position-top">

                                    <b>HOME</b>
                                    <em>TRIP_CARD</em>

                                </span>


                                <strong>
                                    홈 슬라이딩 카드
                                </strong>


                                <small>
                                    인기 여행일정 카드 사이에 노출
                                </small>


                                <span class="ad-inquiry-position-size">
                                    600 × 400 px
                                </span>

                            </label>



                            <!-- TIP -->

                            <label class="ad-inquiry-position-card">

                                <input
                                    type="radio"
                                    name="adPosition"
                                    value="TIP_SIDE"
                                    <%=
                                        "TIP_SIDE".equals(
                                                selectedAdPosition
                                        )
                                        ? "checked"
                                        : ""
                                    %>
                                    required>


                                <span class="ad-inquiry-position-top">

                                    <b>TRAVEL TIP</b>
                                    <em>TIP_SIDE</em>

                                </span>


                                <strong>
                                    여행 꿀팁 사이드
                                </strong>


                                <small>
                                    상세 페이지 좌·우에 노출
                                </small>


                                <span class="ad-inquiry-position-size">
                                    160 × 600 px
                                </span>

                            </label>



                            <!-- MATE -->

                            <label class="ad-inquiry-position-card">

                                <input
                                    type="radio"
                                    name="adPosition"
                                    value="MATE_SIDE"
                                    <%=
                                        "MATE_SIDE".equals(
                                                selectedAdPosition
                                        )
                                        ? "checked"
                                        : ""
                                    %>
                                    required>


                                <span class="ad-inquiry-position-top">

                                    <b>TRAVEL MATE</b>
                                    <em>MATE_SIDE</em>

                                </span>


                                <strong>
                                    여행 메이트 사이드
                                </strong>


                                <small>
                                    상세 페이지 좌·우에 노출
                                </small>


                                <span class="ad-inquiry-position-size">
                                    160 × 600 px
                                </span>

                            </label>

                        </div>

                    </section>



                    <!-- =================================================
                         03 일정 / 예상 비용
                    ================================================== -->

                    <section class="ad-inquiry-panel">

                        <div class="ad-inquiry-panel-head">

                            <span>03</span>

                            <div>

                                <h2>
                                    희망 노출 일정
                                </h2>

                                <p>
                                    광고를 노출하고 싶은 기간을 선택해주세요.
                                </p>

                            </div>

                        </div>


                        <div class="ad-inquiry-date-grid">

                            <div class="ad-inquiry-field">

                                <label for="adStartDate">
                                    시작일
                                </label>

                                <input
                                    type="date"
                                    id="adStartDate"
                                    name="startDate"
                                    value="<%=escapeHtml(formStartDate)%>"
                                    required>

                            </div>


                            <div class="ad-inquiry-field">

                                <label for="adEndDate">
                                    종료일
                                </label>

                                <input
                                    type="date"
                                    id="adEndDate"
                                    name="endDate"
                                    value="<%=escapeHtml(formEndDate)%>"
                                    required>

                            </div>

                        </div>


                        <div class="ad-inquiry-price">

                            <div>

                                <span>
                                    선택 광고
                                </span>

                                <strong id="pricePosition">
                                    -
                                </strong>

                            </div>


                            <div>

                                <span>
                                    광고 기간
                                </span>

                                <strong id="priceDuration">
                                    -
                                </strong>

                            </div>


                            <div class="total">

                                <span>
                                    예상 광고비
                                </span>

                                <strong id="priceTotal">
                                    광고 위치와 기간을 선택해주세요.
                                </strong>

                            </div>

                        </div>


                        <p class="ad-inquiry-help">
                            홈 카드 광고는 7일·14일·30일 기준 요금이 표시되며,
                            사이드 광고는 관리자 검토 후 비용을 안내합니다.
                        </p>

                    </section>



                    <!-- =================================================
                         04 광고 소재
                    ================================================== -->

                    <section class="ad-inquiry-panel">

                        <div class="ad-inquiry-panel-head">

                            <span>04</span>

                            <div>

                                <h2>
                                    광고 소재
                                </h2>

                                <p>
                                    광고 이미지와 클릭 시 이동할 주소를 등록해주세요.
                                </p>

                            </div>

                        </div>


                        <div class="ad-inquiry-field">

                            <label for="linkUrl">

                                광고 연결 URL

                                <span>
                                    선택
                                </span>

                            </label>

                            <input
                                type="url"
                                id="linkUrl"
                                name="linkUrl"
                                maxlength="500"
                                value="<%=escapeHtml(formLinkUrl)%>"
                                placeholder="https://example.com">

                            <small>
                                사용자가 광고를 클릭했을 때 이동할 웹사이트 주소입니다.
                            </small>

                        </div>



                        <div class="ad-inquiry-image-box">

                            <div>

                                <div
                                    class="ad-inquiry-image-preview"
                                    id="adImagePreview">

                                    <span>
                                        IMAGE
                                    </span>

                                </div>

                            </div>


                            <div class="ad-inquiry-image-info">

                                <div class="ad-inquiry-image-guide">

                                    <span>
                                        권장 이미지
                                    </span>

                                    <strong id="imageGuideSize">
                                        광고 위치를 먼저 선택해주세요.
                                    </strong>

                                    <small id="imageGuideText">
                                        선택한 광고 영역에 맞는 이미지 규격을 안내합니다.
                                    </small>

                                </div>


                                <input
                                    type="file"
                                    id="adImage"
                                    name="image"
                                    accept="image/jpeg,image/png,image/webp"
                                    required>


                                <p>
                                    JPG, PNG, WEBP / 최대 5MB
                                </p>


                                <%
                                if (errorMessage != null) {
                                %>

                                <p class="error">
                                    오류 후에는 광고 이미지를 다시 선택해야 합니다.
                                </p>

                                <%
                                }
                                %>

                            </div>

                        </div>

                    </section>



                    <!-- =================================================
                         05 문의 내용
                    ================================================== -->

                    <section class="ad-inquiry-panel">

                        <div class="ad-inquiry-panel-head">

                            <span>05</span>

                            <div>

                                <h2>
                                    광고 및 문의 내용
                                </h2>

                                <p>
                                    광고하려는 상품 또는 서비스와 요청사항을 작성해주세요.
                                </p>

                            </div>

                        </div>


                        <div class="ad-inquiry-field">

                            <label for="content">
                                문의 내용
                            </label>

                            <textarea
                                id="content"
                                name="content"
                                maxlength="3000"
                                rows="7"
                                placeholder="광고 목적, 상품 또는 서비스 설명, 요청사항 등을 작성해주세요."
                                required><%=escapeHtml(formContent)%></textarea>

                            <small>
                                광고 목적과 필요한 요청사항을 구체적으로 작성하면
                                검토가 더 빠르게 진행됩니다.
                            </small>

                        </div>

                    </section>



                    <!-- =================================================
                         ACTION
                    ================================================== -->

                    <div class="ad-inquiry-actions">

                        <a
                            href="<%=ctx%>/view/support/adGuide.jsp"
                            class="ad-inquiry-cancel">

                            취소

                        </a>


                        <button
                            type="submit"
                            id="adSubmitButton"
                            class="ad-inquiry-submit">

                            광고 문의 접수

                        </button>

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

        const form =
            document.getElementById(
                "adInquiryForm"
            );

        const submitButton =
            document.getElementById(
                "adSubmitButton"
            );

        const phoneInput =
            document.getElementById(
                "phone"
            );

        const startDate =
            document.getElementById(
                "adStartDate"
            );

        const endDate =
            document.getElementById(
                "adEndDate"
            );

        const imageInput =
            document.getElementById(
                "adImage"
            );

        const imagePreview =
            document.getElementById(
                "adImagePreview"
            );

        const positionInputs =
            document.querySelectorAll(
                'input[name="adPosition"]'
            );

        const positionCards =
            document.querySelectorAll(
                ".ad-inquiry-position-card"
            );

        const pricePosition =
            document.getElementById(
                "pricePosition"
            );

        const priceDuration =
            document.getElementById(
                "priceDuration"
            );

        const priceTotal =
            document.getElementById(
                "priceTotal"
            );

        const imageGuideSize =
            document.getElementById(
                "imageGuideSize"
            );

        const imageGuideText =
            document.getElementById(
                "imageGuideText"
            );


        /* =====================================================
           광고 상품 정보
        ====================================================== */

        const POSITION_INFO = {

            TRIP_CARD: {
                name: "홈 슬라이딩 카드",
                size: "600 × 400 px",
                imageText: "3:2 비율의 가로형 이미지를 권장합니다.",
                previewType: "card"
            },

            TIP_SIDE: {
                name: "여행 꿀팁 사이드",
                size: "160 × 600 px",
                imageText: "여행 꿀팁 상세 좌·우에 들어가는 세로형 이미지입니다.",
                previewType: "side"
            },

            MATE_SIDE: {
                name: "여행 메이트 사이드",
                size: "160 × 600 px",
                imageText: "여행 메이트 상세 좌·우에 들어가는 세로형 이미지입니다.",
                previewType: "side"
            }

        };


        const PRICE_TABLE = {

            TRIP_CARD: {
                7: 30000,
                14: 50000,
                30: 90000
            }

        };


        /* =====================================================
           전화번호
        ====================================================== */

        function formatPhoneNumber(value) {

            let number =
                value.replace(
                    /[^0-9]/g,
                    ""
                );

            number =
                number.substring(
                    0,
                    11
                );


            if (
                number.startsWith("02")
            ) {

                if (number.length <= 2) {
                    return number;
                }

                if (number.length <= 5) {

                    return number.replace(
                        /(\d{2})(\d+)/,
                        "$1-$2"
                    );
                }

                if (number.length <= 9) {

                    return number.replace(
                        /(\d{2})(\d{3})(\d+)/,
                        "$1-$2-$3"
                    );
                }

                return number.replace(
                    /(\d{2})(\d{4})(\d{4})/,
                    "$1-$2-$3"
                );
            }


            if (number.length <= 3) {
                return number;
            }

            if (number.length <= 7) {

                return number.replace(
                    /(\d{3})(\d+)/,
                    "$1-$2"
                );
            }

            if (number.length <= 10) {

                return number.replace(
                    /(\d{3})(\d{3})(\d{4})/,
                    "$1-$2-$3"
                );
            }

            return number.replace(
                /(\d{3})(\d{4})(\d{4})/,
                "$1-$2-$3"
            );
        }


        phoneInput.addEventListener(
            "input",
            function () {

                this.value =
                    formatPhoneNumber(
                        this.value
                    );
            }
        );


        phoneInput.value =
            formatPhoneNumber(
                phoneInput.value
            );


        /* =====================================================
           오늘 날짜
        ====================================================== */

        const today =
            new Date();

        const yyyy =
            today.getFullYear();

        const mm =
            String(
                today.getMonth() + 1
            ).padStart(
                2,
                "0"
            );

        const dd =
            String(
                today.getDate()
            ).padStart(
                2,
                "0"
            );

        const todayValue =
            yyyy
            + "-"
            + mm
            + "-"
            + dd;


        startDate.min =
            todayValue;


        if (startDate.value) {

            endDate.min =
                startDate.value;

        } else {

            endDate.min =
                todayValue;
        }


        /* =====================================================
           위치
        ====================================================== */

        function getSelectedPosition() {

            const selected =
                document.querySelector(
                    'input[name="adPosition"]:checked'
                );

            return selected
                ? selected.value
                : null;
        }


        function updatePositionUI() {

            const position =
                getSelectedPosition();


            positionCards.forEach(
                function (card) {

                    const radio =
                        card.querySelector(
                            'input[type="radio"]'
                        );

                    card.classList.toggle(
                        "selected",
                        !!radio && radio.checked
                    );
                }
            );


            if (
                position
                &&
                POSITION_INFO[position]
            ) {

                const info =
                    POSITION_INFO[position];

                imageGuideSize.textContent =
                    info.size;

                imageGuideText.textContent =
                    info.imageText;

                imagePreview.classList.toggle(
                    "side",
                    info.previewType === "side"
                );

            } else {

                imageGuideSize.textContent =
                    "광고 위치를 먼저 선택해주세요.";

                imageGuideText.textContent =
                    "선택한 광고 영역에 맞는 이미지 규격을 안내합니다.";

                imagePreview.classList.remove(
                    "side"
                );
            }
        }


        positionInputs.forEach(
            function (input) {

                input.addEventListener(
                    "change",
                    function () {

                        updatePositionUI();
                        updatePrice();
                    }
                );
            }
        );


        /* =====================================================
           날짜
        ====================================================== */

        startDate.addEventListener(
            "change",
            function () {

                if (startDate.value) {

                    endDate.min =
                        startDate.value;
                }


                if (
                    endDate.value
                    &&
                    endDate.value
                    <
                    startDate.value
                ) {

                    endDate.value =
                        "";
                }


                updatePrice();
            }
        );


        endDate.addEventListener(
            "change",
            updatePrice
        );


        function calculateDays() {

            if (
                !startDate.value
                ||
                !endDate.value
            ) {

                return null;
            }


            const start =
                new Date(
                    startDate.value
                    + "T00:00:00"
                );

            const end =
                new Date(
                    endDate.value
                    + "T00:00:00"
                );


            if (end < start) {
                return -1;
            }


            const diff =
                end.getTime()
                -
                start.getTime();


            return Math.floor(
                diff / 86400000
            ) + 1;
        }


        /* =====================================================
           가격
        ====================================================== */

        function updatePrice() {

            const position =
                getSelectedPosition();

            const days =
                calculateDays();


            pricePosition.textContent =
                position
                && POSITION_INFO[position]
                ? POSITION_INFO[position].name
                : "-";


            if (days === null) {

                priceDuration.textContent =
                    "-";

            } else if (days <= 0) {

                priceDuration.textContent =
                    "날짜를 확인해주세요.";

            } else {

                priceDuration.textContent =
                    days.toLocaleString()
                    + "일";
            }


            if (!position) {

                priceTotal.textContent =
                    "광고 위치를 선택해주세요.";

                return;
            }


            if (days === null) {

                priceTotal.textContent =
                    "광고 기간을 선택해주세요.";

                return;
            }


            if (days <= 0) {

                priceTotal.textContent =
                    "종료일을 확인해주세요.";

                return;
            }


            /*
             * TIP/MATE 사이드는 별도 견적
             */
            if (
                position === "TIP_SIDE"
                ||
                position === "MATE_SIDE"
            ) {

                priceTotal.textContent =
                    "관리자 검토 후 별도 안내";

                return;
            }


            const price =
                PRICE_TABLE[position]
                &&
                PRICE_TABLE[position][days];


            if (price) {

                priceTotal.textContent =
                    price.toLocaleString()
                    + "원";

            } else {

                priceTotal.textContent =
                    "기간별 별도 안내";
            }
        }


        /* =====================================================
           이미지
        ====================================================== */

        imageInput.addEventListener(
            "change",
            function () {

                const file =
                    imageInput.files[0];


                if (!file) {

                    imagePreview.innerHTML =
                        "<span>IMAGE</span>";

                    return;
                }


                if (
                    file.size
                    >
                    5 * 1024 * 1024
                ) {

                    alert(
                        "광고 이미지는 최대 5MB까지 등록할 수 있습니다."
                    );

                    imageInput.value =
                        "";

                    imagePreview.innerHTML =
                        "<span>IMAGE</span>";

                    return;
                }


                const allowedTypes = [
                    "image/jpeg",
                    "image/png",
                    "image/webp"
                ];


                if (
                    !allowedTypes.includes(
                        file.type
                    )
                ) {

                    alert(
                        "JPG, PNG, WEBP 이미지만 등록할 수 있습니다."
                    );

                    imageInput.value =
                        "";

                    imagePreview.innerHTML =
                        "<span>IMAGE</span>";

                    return;
                }


                const reader =
                    new FileReader();


                reader.onload =
                    function (event) {

                        const image =
                            document.createElement(
                                "img"
                            );

                        image.src =
                            event.target.result;

                        image.alt =
                            "광고 이미지 미리보기";

                        imagePreview.innerHTML =
                            "";

                        imagePreview.appendChild(
                            image
                        );
                    };


                reader.readAsDataURL(
                    file
                );
            }
        );


        /* =====================================================
           제출
        ====================================================== */

        form.addEventListener(
            "submit",
            function (event) {

                const selectedPosition =
                    getSelectedPosition();


                if (!selectedPosition) {

                    event.preventDefault();

                    alert(
                        "광고 희망 영역을 선택해주세요."
                    );

                    return;
                }


                if (!startDate.value) {

                    event.preventDefault();

                    alert(
                        "광고 시작일을 선택해주세요."
                    );

                    startDate.focus();

                    return;
                }


                if (!endDate.value) {

                    event.preventDefault();

                    alert(
                        "광고 종료일을 선택해주세요."
                    );

                    endDate.focus();

                    return;
                }


                if (
                    endDate.value
                    <
                    startDate.value
                ) {

                    event.preventDefault();

                    alert(
                        "광고 종료일은 시작일 이후로 선택해주세요."
                    );

                    endDate.focus();

                    return;
                }


                if (
                    !imageInput.files
                    ||
                    !imageInput.files[0]
                ) {

                    event.preventDefault();

                    alert(
                        "광고 이미지를 등록해주세요."
                    );

                    return;
                }


                submitButton.disabled =
                    true;

                submitButton.textContent =
                    "접수 중...";
            }
        );


        /* =====================================================
           초기 표시
        ====================================================== */

        updatePositionUI();
        updatePrice();

    }
);

</script>


</body>
</html>
