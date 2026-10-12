<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%
request.setAttribute("activePage", "profile");
request.setAttribute("settingsPage", "support");

String ctx = request.getContextPath();
%>

<!DOCTYPE html>
<html lang="ko">

<head>

<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">

<title>광고 안내 · Planb</title>

<jsp:include page="/common/headStyles.jsp" />

<link rel="stylesheet"
    href="<%=ctx%>/view/assets/css/setting/settings.css">

<link rel="stylesheet"
    href="<%=ctx%>/view/assets/css/support/support.css">

<!-- 반드시 support.css보다 뒤에 -->
<link rel="stylesheet"
    href="<%=ctx%>/view/assets/css/support/adGuide.css">

</head>


<body class="site-shell">

<jsp:include page="/common/header.jsp" />


<div class="settings-page">

    <div class="settings-shell">

        <jsp:include page="/common/settingsSidebar.jsp" />


        <main class="settings-main">

            <div class="settings-content ad-guide-compact">


                <!-- =====================================================
                     HEADER
                ====================================================== -->

                <div class="ad-guide-top">

                    <a class="ad-guide-back"
                        href="<%=ctx%>/support/support">

                        <span>←</span>
                        고객지원

                    </a>


                    <span class="ad-guide-badge">
                        ADVERTISEMENT
                    </span>

                </div>


                <header class="ad-guide-header">

                    <h1>광고 안내</h1>

                    <p>
                        Planb의 실제 콘텐츠 흐름에 맞춰
                        자연스럽게 노출되는 광고 상품을 안내합니다.
                    </p>

                </header>



                <!-- =====================================================
                     HERO
                ====================================================== -->

                <section class="ad-guide-intro-card">

                    <span class="ad-guide-kicker">
                        PLANB AD
                    </span>


                    <h2>
                        여행 콘텐츠 안에서<br>
                        자연스럽게 브랜드를 소개하세요.
                    </h2>


                    <p>
                        홈 메인 비주얼에는 광고를 넣지 않고,
                        여행 일정 카드 사이 또는 상세 콘텐츠 양쪽의
                        전용 광고 영역을 사용합니다.
                    </p>


                    <div class="ad-guide-actions">

                        <a class="ad-guide-primary"
                            href="#adPositions">
                            광고 위치 보기
                        </a>

                        <a class="ad-guide-secondary"
                            href="<%=ctx%>/support/adInquiry">
                            광고 문의하기
                        </a>

                    </div>


                    <div class="ad-guide-summary">

                        <div>

                            <span>HOME</span>
                            <strong>슬라이딩 카드</strong>
                            <b>600 × 400</b>

                        </div>


                        <div>

                            <span>TRAVEL TIP</span>
                            <strong>좌·우 사이드</strong>
                            <b>160 × 600</b>

                        </div>


                        <div>

                            <span>TRAVEL MATE</span>
                            <strong>좌·우 사이드</strong>
                            <b>160 × 600</b>

                        </div>

                    </div>

                </section>



                <div class="ad-guide-notice">

                    <span>i</span>

                    <p>
                        <strong>
                            홈 상단 메인 비주얼은 광고 영역이 아닙니다.
                        </strong>
                        홈 광고는 ‘지금 가장 인기 있는 여행일정’
                        슬라이딩 카드 안에 노출됩니다.
                    </p>

                </div>



                <!-- =====================================================
                     광고 위치
                ====================================================== -->

                <section class="ad-guide-section"
                    id="adPositions">

                    <div class="ad-guide-section-title">

                        <span>01</span>

                        <div>

                            <h2>광고 위치</h2>

                            <p>
                                실제 노출 위치와 이미지 권장 규격입니다.
                            </p>

                        </div>

                    </div>



                    <!-- HOME -->

                    <article class="ad-guide-card">

                        <div class="ad-guide-card-copy">

                            <div class="ad-guide-tags">

                                <span class="main">
                                    HOME
                                </span>

                                <span>
                                    TRIP_CARD
                                </span>

                            </div>


                            <h3>
                                홈 슬라이딩 카드 광고
                            </h3>


                            <p>
                                인기 여행일정 카드 사이에 일반 여행 카드와
                                같은 형태로 자연스럽게 노출됩니다.
                            </p>


                            <div class="ad-guide-specs">

                                <div>
                                    <span>권장 이미지</span>
                                    <strong>600 × 400 px</strong>
                                </div>

                                <div>
                                    <span>비율</span>
                                    <strong>3 : 2</strong>
                                </div>

                                <div>
                                    <span>노출</span>
                                    <strong>슬라이드</strong>
                                </div>

                            </div>


                            <ul>

                                <li>
                                    상단 메인 비주얼에는 광고가 들어가지 않습니다.
                                </li>

                                <li>
                                    광고 카드에는 AD 표시가 함께 노출됩니다.
                                </li>

                                <li>
                                    클릭 시 등록한 외부 URL로 이동할 수 있습니다.
                                </li>

                            </ul>


                            <a class="ad-guide-card-link"
                                href="<%=ctx%>/support/adInquiry?adPosition=TRIP_CARD">

                                홈 카드 광고 문의하기
                                <span>→</span>

                            </a>

                        </div>


                        <div class="ad-guide-preview">

                            <div class="ad-preview-window">

                                <div class="ad-preview-top">
                                    <strong>Planb</strong>
                                    <span>HOME</span>
                                </div>


                                <div class="ad-preview-main">
                                    <span>MAIN VISUAL</span>
                                    <b>광고 없음</b>
                                </div>


                                <div class="ad-preview-sub">
                                    인기 여행일정
                                </div>


                                <div class="ad-preview-cards">

                                    <div class="ad-preview-card">
                                        <i></i>
                                        <span>TRIP</span>
                                    </div>

                                    <div class="ad-preview-card ad">
                                        <i>
                                            <b>AD</b>
                                        </i>
                                        <span>SPONSORED</span>
                                    </div>

                                    <div class="ad-preview-card">
                                        <i></i>
                                        <span>TRIP</span>
                                    </div>

                                </div>

                            </div>

                        </div>

                    </article>



                    <!-- TIP -->

                    <article class="ad-guide-card">

                        <div class="ad-guide-card-copy">

                            <div class="ad-guide-tags">

                                <span class="main">
                                    TRAVEL TIP
                                </span>

                                <span>
                                    TIP_SIDE
                                </span>

                            </div>


                            <h3>
                                여행 꿀팁 사이드 광고
                            </h3>


                            <p>
                                여행 꿀팁 상세 콘텐츠를 가운데에 두고
                                좌측과 우측의 전용 사이드 영역에 노출됩니다.
                            </p>


                            <div class="ad-guide-specs">

                                <div>
                                    <span>이미지</span>
                                    <strong>160 × 600 px</strong>
                                </div>

                                <div>
                                    <span>위치</span>
                                    <strong>좌 · 우</strong>
                                </div>

                                <div>
                                    <span>화면</span>
                                    <strong>PC</strong>
                                </div>

                            </div>


                            <ul>

                                <li>
                                    콘텐츠 본문과 분리된 전용 광고 영역입니다.
                                </li>

                                <li>
                                    좌·우 각각 동일한 세로형 규격을 사용합니다.
                                </li>

                                <li>
                                    모바일에서는 사이드 광고가 노출되지 않습니다.
                                </li>

                            </ul>


                            <a class="ad-guide-card-link"
                                href="<%=ctx%>/support/adInquiry?adPosition=TIP_SIDE">

                                여행 꿀팁 광고 문의하기
                                <span>→</span>

                            </a>

                        </div>


                        <div class="ad-guide-preview">

                            <div class="ad-preview-window">

                                <div class="ad-preview-top">
                                    <strong>Planb</strong>
                                    <span>TRAVEL TIP</span>
                                </div>


                                <div class="ad-preview-side-layout">

                                    <div class="ad-preview-side-ad">
                                        <b>AD</b>
                                        <span>160 × 600</span>
                                    </div>


                                    <div class="ad-preview-content">

                                        <div class="ad-preview-image tip"></div>

                                        <i class="title"></i>
                                        <i></i>
                                        <i></i>
                                        <i class="short"></i>

                                    </div>


                                    <div class="ad-preview-side-ad">
                                        <b>AD</b>
                                        <span>160 × 600</span>
                                    </div>

                                </div>

                            </div>

                        </div>

                    </article>



                    <!-- MATE -->

                    <article class="ad-guide-card">

                        <div class="ad-guide-card-copy">

                            <div class="ad-guide-tags">

                                <span class="main">
                                    TRAVEL MATE
                                </span>

                                <span>
                                    MATE_SIDE
                                </span>

                            </div>


                            <h3>
                                여행 메이트 사이드 광고
                            </h3>


                            <p>
                                여행 메이트 상세 페이지에서도 게시글 본문
                                양쪽의 전용 광고 영역에 세로형으로 노출됩니다.
                            </p>


                            <div class="ad-guide-specs">

                                <div>
                                    <span>이미지</span>
                                    <strong>160 × 600 px</strong>
                                </div>

                                <div>
                                    <span>위치</span>
                                    <strong>좌 · 우</strong>
                                </div>

                                <div>
                                    <span>화면</span>
                                    <strong>PC</strong>
                                </div>

                            </div>


                            <ul>

                                <li>
                                    모집 게시글과 겹치지 않는 사이드 영역입니다.
                                </li>

                                <li>
                                    좌·우 각각 동일한 세로형 규격을 사용합니다.
                                </li>

                                <li>
                                    모바일에서는 사이드 광고가 노출되지 않습니다.
                                </li>

                            </ul>


                            <a class="ad-guide-card-link"
                                href="<%=ctx%>/support/adInquiry?adPosition=MATE_SIDE">

                                여행 메이트 광고 문의하기
                                <span>→</span>

                            </a>

                        </div>


                        <div class="ad-guide-preview">

                            <div class="ad-preview-window">

                                <div class="ad-preview-top">
                                    <strong>Planb</strong>
                                    <span>TRAVEL MATE</span>
                                </div>


                                <div class="ad-preview-side-layout">

                                    <div class="ad-preview-side-ad">
                                        <b>AD</b>
                                        <span>160 × 600</span>
                                    </div>


                                    <div class="ad-preview-content">

                                        <div class="ad-preview-image mate"></div>

                                        <i class="title"></i>
                                        <i></i>
                                        <i></i>
                                        <i class="short"></i>

                                    </div>


                                    <div class="ad-preview-side-ad">
                                        <b>AD</b>
                                        <span>160 × 600</span>
                                    </div>

                                </div>

                            </div>

                        </div>

                    </article>

                </section>



                <!-- =====================================================
                     가격
                ====================================================== -->

                <section class="ad-guide-section">

                    <div class="ad-guide-section-title">

                        <span>02</span>

                        <div>

                            <h2>광고 비용</h2>

                            <p>
                                홈 카드 광고 기준 가격입니다.
                            </p>

                        </div>

                    </div>


                    <div class="ad-guide-price">

                        <div class="head">
                            <span>광고 상품</span>
                            <span>7일</span>
                            <span>14일</span>
                            <span>30일</span>
                        </div>


                        <div>
                            <strong>
                                홈 슬라이딩 카드
                                <small>TRIP_CARD</small>
                            </strong>

                            <span>30,000원</span>

                            <span class="recommend">
                                50,000원
                            </span>

                            <span>90,000원</span>
                        </div>


                        <div>
                            <strong>
                                여행 꿀팁 사이드
                                <small>TIP_SIDE</small>
                            </strong>

                            <span class="consult">
                                문의 후 안내
                            </span>
                        </div>


                        <div>
                            <strong>
                                여행 메이트 사이드
                                <small>MATE_SIDE</small>
                            </strong>

                            <span class="consult">
                                문의 후 안내
                            </span>
                        </div>

                    </div>

                </section>



                <!-- =====================================================
                     PROCESS
                ====================================================== -->

                <section class="ad-guide-section">

                    <div class="ad-guide-section-title">

                        <span>03</span>

                        <div>

                            <h2>진행 절차</h2>

                            <p>
                                문의 접수부터 광고 게시까지의 과정입니다.
                            </p>

                        </div>

                    </div>


                    <div class="ad-guide-process">

                        <div>
                            <span>01</span>
                            <strong>문의 접수</strong>
                            <p>업체 정보와 광고 내용을 입력합니다.</p>
                        </div>

                        <div>
                            <span>02</span>
                            <strong>관리자 검토</strong>
                            <p>이미지, 링크와 노출 일정을 확인합니다.</p>
                        </div>

                        <div>
                            <span>03</span>
                            <strong>승인 안내</strong>
                            <p>광고 진행 가능 여부를 안내합니다.</p>
                        </div>

                        <div>
                            <span>04</span>
                            <strong>광고 게시</strong>
                            <p>승인된 기간에 광고를 노출합니다.</p>
                        </div>

                    </div>

                </section>



                <!-- =====================================================
                     READY
                ====================================================== -->

                <section class="ad-guide-section">

                    <div class="ad-guide-section-title">

                        <span>04</span>

                        <div>

                            <h2>문의 전 준비사항</h2>

                            <p>
                                아래 내용을 미리 준비해주세요.
                            </p>

                        </div>

                    </div>


                    <div class="ad-guide-ready">

                        <div>
                            <span>01</span>
                            <strong>업체 정보</strong>
                            <small>업체명 · 담당자명</small>
                        </div>

                        <div>
                            <span>02</span>
                            <strong>연락처</strong>
                            <small>전화번호 · 이메일</small>
                        </div>

                        <div>
                            <span>03</span>
                            <strong>광고 이미지</strong>
                            <small>위치별 권장 규격</small>
                        </div>

                        <div>
                            <span>04</span>
                            <strong>광고 내용</strong>
                            <small>상품 · 서비스 소개</small>
                        </div>

                        <div>
                            <span>05</span>
                            <strong>연결 주소</strong>
                            <small>광고 클릭 URL</small>
                        </div>

                        <div>
                            <span>06</span>
                            <strong>희망 기간</strong>
                            <small>시작일 · 종료일</small>
                        </div>

                    </div>

                </section>



                <!-- =====================================================
                     CTA
                ====================================================== -->

                <section class="ad-guide-cta">

                    <div>

                        <span>READY TO ADVERTISE?</span>

                        <h2>
                            광고 문의를 시작해보세요.
                        </h2>

                        <p>
                            원하는 광고 위치를 선택해 문의를 접수할 수 있습니다.
                        </p>

                    </div>


                    <a href="<%=ctx%>/support/adInquiry">
                        광고 문의하기 →
                    </a>

                </section>


            </div>

        </main>

    </div>

</div>


<jsp:include page="/common/footer.jsp" />

</body>
</html>
