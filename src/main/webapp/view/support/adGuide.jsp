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

<title>광고 안내</title>

<jsp:include page="/common/headStyles.jsp" />

<link rel="stylesheet"
    href="<%=ctx%>/view/assets/css/setting/settings.css">

<link rel="stylesheet"
    href="<%=ctx%>/view/assets/css/support/support.css">

<!-- 반드시 support.css보다 뒤에 -->
<link rel="stylesheet"
    href="<%=ctx%>/view/assets/css/support/adGuide.css?v=6">

<script defer src="<%=ctx%>/view/assets/js/support/adPricing.js?v=1"></script>
<script defer src="<%=ctx%>/view/assets/js/support/adGuide.js?v=4"></script>

</head>


<body class="site-shell">

<jsp:include page="/common/header.jsp" />


<div class="settings-page">

    <div class="settings-shell">

        <jsp:include page="/common/settingsSidebar.jsp" />

        <main class="settings-main">

            <div class="settings-content ag-page">

                <a class="ag-back" href="<%=ctx%>/support/support">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m15 18-6-6 6-6"/></svg>
                    고객지원
                </a>


                <!-- =====================================================
                     HEADER
                ====================================================== -->
                <header class="ag-header">

                    <span class="ag-eyebrow">광고 안내</span>

                    <h1>Planb에서 광고를 시작해보세요</h1>

                    <p>
                        여행 일정을 찾고, 계획하고, 함께 떠날 사람을 구하는 화면 곁에
                        브랜드가 자연스럽게 노출돼요.
                    </p>

                    <dl class="ag-facts">
                        <div>
                            <dt>광고 위치</dt>
                            <dd>4곳</dd>
                        </div>
                        <div>
                            <dt>최저 요금</dt>
                            <dd data-price-lowest>-</dd>
                        </div>
                        <div>
                            <dt>계약 기준</dt>
                            <dd>1 · 3 · 6개월</dd>
                        </div>
                    </dl>

                </header>


                <!-- =====================================================
                     광고 위치
                ====================================================== -->
                <section class="ag-section" id="agPositions">

                    <div class="ag-section-head">
                        <h2>광고 위치</h2>
                        <p>실제 화면에 표시되는 크기와 권장 이미지 규격이에요.</p>
                    </div>

                    <div class="ag-positions">

                        <!-- HOME -->
                        <article class="ag-pos pos-home">

                            <div class="ag-pos-preview" aria-hidden="true">
                                <div class="ag-wire ag-wire--cards">
                                    <i></i><i class="ad">AD</i><i></i><i></i>
                                </div>
                            </div>

                            <div class="ag-pos-body">

                                <div class="ag-pos-tag">
                                    <span>홈</span>
                                    <code>TRIP_CARD</code>
                                </div>

                                <h3>홈 슬라이딩 카드</h3>
                                <p>‘지금 가장 인기 있는 여행일정’ 카드 사이에 같은 모양의 카드로 흘러가며 노출돼요.</p>

                                <dl class="ag-pos-specs">
                                    <div><dt>표시 크기</dt><dd>290 × 230 px</dd></div>
                                    <div><dt>권장 이미지</dt><dd>580 × 460 px</dd></div>
                                    <div><dt>노출 화면</dt><dd>PC · 모바일</dd></div>
                                </dl>

                                <ul class="ag-pos-notes">
                                    <li>홈 상단 메인 비주얼에는 광고가 들어가지 않아요.</li>
                                    <li>화면 높이가 낮으면 세로가 줄어들 수 있어 핵심 내용은 가운데에 두세요.</li>
                                </ul>

                                <div class="ag-pos-foot">
                                    <span data-price-from="TRIP_CARD"></span>
                                    <a href="<%=ctx%>/support/adInquiry?adPosition=TRIP_CARD">문의하기<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m9 18 6-6-6-6"/></svg></a>
                                </div>

                            </div>

                        </article>


                        <!-- TIP -->
                        <article class="ag-pos pos-tip">

                            <div class="ag-pos-preview" aria-hidden="true">
                                <div class="ag-wire ag-wire--side">
                                    <i class="ad">AD</i>
                                    <span><u class="img"></u><u></u><u></u><u class="short"></u></span>
                                    <i class="ad">AD</i>
                                </div>
                            </div>

                            <div class="ag-pos-body">

                                <div class="ag-pos-tag">
                                    <span>여행 꿀팁</span>
                                    <code>TIP_SIDE</code>
                                </div>

                                <h3>여행 꿀팁 사이드</h3>
                                <p>여행 꿀팁 상세 본문을 가운데 두고 좌·우 전용 영역에 세로로 노출돼요.</p>

                                <dl class="ag-pos-specs">
                                    <div><dt>표시 크기</dt><dd>160 × 600 px</dd></div>
                                    <div><dt>권장 이미지</dt><dd>320 × 1200 px</dd></div>
                                    <div><dt>노출 화면</dt><dd>PC</dd></div>
                                </dl>

                                <ul class="ag-pos-notes">
                                    <li>본문과 분리된 전용 영역이라 콘텐츠를 가리지 않아요.</li>
                                    <li>좌·우 모두 같은 세로형 규격을 사용해요.</li>
                                </ul>

                                <div class="ag-pos-foot">
                                    <span data-price-from="TIP_SIDE"></span>
                                    <a href="<%=ctx%>/support/adInquiry?adPosition=TIP_SIDE">문의하기<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m9 18 6-6-6-6"/></svg></a>
                                </div>

                            </div>

                        </article>


                        <!-- MATE -->
                        <article class="ag-pos pos-mate">

                            <div class="ag-pos-preview" aria-hidden="true">
                                <div class="ag-wire ag-wire--side">
                                    <i class="ad">AD</i>
                                    <span><u class="img"></u><u></u><u></u><u class="short"></u></span>
                                    <i class="ad">AD</i>
                                </div>
                            </div>

                            <div class="ag-pos-body">

                                <div class="ag-pos-tag">
                                    <span>여행 메이트</span>
                                    <code>MATE_SIDE</code>
                                </div>

                                <h3>여행 메이트 사이드</h3>
                                <p>함께 떠날 사람을 찾는 모집글 상세의 좌·우 전용 영역에 세로로 노출돼요.</p>

                                <dl class="ag-pos-specs">
                                    <div><dt>표시 크기</dt><dd>160 × 600 px</dd></div>
                                    <div><dt>권장 이미지</dt><dd>320 × 1200 px</dd></div>
                                    <div><dt>노출 화면</dt><dd>PC</dd></div>
                                </dl>

                                <ul class="ag-pos-notes">
                                    <li>모집글 본문과 겹치지 않는 사이드 영역이에요.</li>
                                    <li>좌·우 모두 같은 세로형 규격을 사용해요.</li>
                                </ul>

                                <div class="ag-pos-foot">
                                    <span data-price-from="MATE_SIDE"></span>
                                    <a href="<%=ctx%>/support/adInquiry?adPosition=MATE_SIDE">문의하기<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m9 18 6-6-6-6"/></svg></a>
                                </div>

                            </div>

                        </article>


                        <!-- CART -->
                        <article class="ag-pos pos-cart">

                            <div class="ag-pos-preview" aria-hidden="true">
                                <div class="ag-wire ag-wire--side ag-wire--list">
                                    <i class="ad">AD</i>
                                    <span><u></u><u></u><u></u><u></u></span>
                                    <i class="ad">AD</i>
                                </div>
                            </div>

                            <div class="ag-pos-body">

                                <div class="ag-pos-tag">
                                    <span>일정 카트</span>
                                    <code>CART_SIDE</code>
                                </div>

                                <h3>일정 카트 사이드</h3>
                                <p>여행 일정을 담아두고 계획을 세우는 카트 화면의 좌·우 전용 영역에 노출돼요.</p>

                                <dl class="ag-pos-specs">
                                    <div><dt>표시 크기</dt><dd>160 × 600 px</dd></div>
                                    <div><dt>권장 이미지</dt><dd>320 × 1200 px</dd></div>
                                    <div><dt>노출 화면</dt><dd>PC</dd></div>
                                </dl>

                                <ul class="ag-pos-notes">
                                    <li>여행을 실제로 준비 중인 회원에게 노출돼요.</li>
                                    <li>다른 사이드 광고와 같은 세로형 규격을 사용해요.</li>
                                </ul>

                                <div class="ag-pos-foot">
                                    <span data-price-from="CART_SIDE"></span>
                                    <a href="<%=ctx%>/support/adInquiry?adPosition=CART_SIDE">문의하기<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m9 18 6-6-6-6"/></svg></a>
                                </div>

                            </div>

                        </article>

                    </div>

                </section>


                <!-- =====================================================
                     요금
                ====================================================== -->
                <section class="ag-section" id="agPrice">

                    <div class="ag-section-head">
                        <h2>요금</h2>
                        <p>오래 계약할수록 하루 금액이 낮아져요. 기간을 넣으면 예상 금액을 바로 확인할 수 있어요.</p>
                    </div>


                    <!-- 예상 금액 계산기 -->
                    <div class="ag-calc">

                        <div class="ag-calc-form">

                            <div class="ag-field">
                                <span class="ag-field-label">광고 위치</span>
                                <div class="ag-segment" id="calcPositions" role="radiogroup" aria-label="광고 위치"></div>
                            </div>

                            <div class="ag-field">
                                <label class="ag-field-label" for="calcDays">노출 기간</label>

                                <div class="ag-days">
                                    <button type="button" class="ag-step" data-step="-1" aria-label="하루 줄이기">−</button>
                                    <input type="number" id="calcDays" min="1" max="730" value="30" inputmode="numeric">
                                    <span>일</span>
                                    <button type="button" class="ag-step" data-step="1" aria-label="하루 늘리기">+</button>
                                </div>

                                <div class="ag-chips" role="group" aria-label="기준 기간 빠른 선택">
                                    <button type="button" data-calc-days="14">2주</button>
                                    <button type="button" data-calc-days="30">1개월</button>
                                    <button type="button" data-calc-days="90">3개월</button>
                                    <button type="button" data-calc-days="180">6개월</button>
                                </div>
                            </div>

                        </div>

                        <div class="ag-calc-result" aria-live="polite">

                            <span class="ag-calc-label">예상 광고비</span>
                            <strong id="calcTotal">-</strong>

                            <dl class="ag-calc-detail">
                                <div><dt>적용 요금</dt><dd id="calcTier">-</dd></div>
                                <div><dt>하루 금액</dt><dd id="calcDaily">-</dd></div>
                            </dl>

                            <p class="ag-calc-hint" id="calcHint"></p>

                            <a class="ag-btn" id="calcInquiry" href="<%=ctx%>/support/adInquiry">이 위치로 문의하기</a>

                        </div>

                    </div>


                    <!-- 기간별 요금표 : adPricing.js 데이터로 생성 -->
                    <div class="ag-table-wrap">
                        <table class="ag-table" id="adPriceTable">
                            <thead>
                                <tr>
                                    <th scope="col">광고 위치</th>
                                    <th scope="col">단기<small>30일 미만 · 하루</small></th>
                                    <th scope="col">1개월<small>30일</small></th>
                                    <th scope="col">3개월<small>90일</small></th>
                                    <th scope="col">6개월<small>180일</small></th>
                                </tr>
                            </thead>
                            <tbody></tbody>
                        </table>
                    </div>

                    <ul class="ag-notes">
                        <li>1·3·6개월 금액은 각각 30일·90일·180일 동안 노출했을 때의 전체 금액이에요.</li>
                        <li>기간 사이의 일수는 해당 기간의 하루 금액으로 계산해요. (예: 100일 → 3개월 하루 금액 × 100일)</li>
                        <li>다음 기준 기간 금액보다 비싸지면 다음 기준 기간 금액으로 계산돼요.</li>
                        <li>최종 금액은 관리자 검토 후 확정돼요.</li>
                    </ul>

                </section>


                <!-- =====================================================
                     진행 절차
                ====================================================== -->
                <section class="ag-section">

                    <div class="ag-section-head">
                        <h2>진행 절차</h2>
                        <p>문의 접수부터 광고 게시까지의 과정이에요.</p>
                    </div>

                    <ol class="ag-steps">
                        <li>
                            <b>1</b>
                            <strong>문의 접수</strong>
                            <span>업체 정보와 광고 위치, 기간, 이미지를 등록해요.</span>
                        </li>
                        <li>
                            <b>2</b>
                            <strong>관리자 검토</strong>
                            <span>이미지와 연결 링크, 노출 일정을 확인해요.</span>
                        </li>
                        <li>
                            <b>3</b>
                            <strong>승인 안내</strong>
                            <span>진행 가능 여부와 최종 금액을 이메일로 안내해요.</span>
                        </li>
                        <li>
                            <b>4</b>
                            <strong>광고 게시</strong>
                            <span>승인된 기간 동안 선택한 위치에 노출돼요.</span>
                        </li>
                    </ol>

                </section>


                <!-- =====================================================
                     준비사항
                ====================================================== -->
                <section class="ag-section">

                    <div class="ag-section-head">
                        <h2>문의 전 준비해주세요</h2>
                        <p>아래 내용을 미리 준비하면 검토가 더 빨라요.</p>
                    </div>

                    <ul class="ag-ready">
                        <li><strong>업체 정보</strong><span>회사·브랜드명, 담당자명</span></li>
                        <li><strong>연락처</strong><span>전화번호, 이메일</span></li>
                        <li><strong>광고 이미지</strong><span>위치별 권장 규격 · 최대 5MB</span></li>
                        <li><strong>광고 내용</strong><span>상품·서비스 소개</span></li>
                        <li><strong>연결 주소</strong><span>광고 클릭 시 이동할 URL</span></li>
                        <li><strong>희망 기간</strong><span>시작일과 종료일</span></li>
                    </ul>

                </section>


                <!-- =====================================================
                     CTA
                ====================================================== -->
                <section class="ag-cta">
                    <div>
                        <strong>준비가 되셨나요?</strong>
                        <span>위치와 기간을 선택해 광고 문의를 접수해보세요.</span>
                    </div>
                    <a class="ag-btn" href="<%=ctx%>/support/adInquiry">광고 문의하기</a>
                </section>

            </div>

        </main>

    </div>

</div>


<jsp:include page="/common/footer.jsp" />

</body>
</html>
