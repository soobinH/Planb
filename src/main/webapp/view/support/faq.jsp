<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>

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

%>

<!DOCTYPE html>

<html lang="ko">

<head>

<meta charset="UTF-8">

<meta name="viewport" content="width=device-width, initial-scale=1">


<title>자주 묻는 질문</title>


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


				<div class="settings-content faq-page">


					<!-- =================================================
                     TITLE
                ================================================== -->

					<header class="settings-title">


						<span class="settings-eyebrow"> SUPPORT </span>


						<h1>자주 묻는 질문</h1>


						<p>Planb 이용 중 궁금한 내용을 빠르게 확인해보세요.</p>


					</header>



					<a class="support-back" href="<%=ctx%>/view/support/support.jsp">

						‹ 고객지원 </a>



					<!-- =================================================
                     SEARCH
                ================================================== -->

					<section class="faq-search-box">


						<div class="faq-search-icon">

							<svg width="18" height="18" viewBox="0 0 24 24" fill="none"
								stroke="currentColor" stroke-width="1.8">

                            <circle cx="11" cy="11" r="7">
                            </circle>

                            <path d="m20 20-3.5-3.5">
                            </path>

                        </svg>

						</div>


						<input type="text" id="faqSearch" placeholder="궁금한 내용을 검색해주세요."
							autocomplete="off">


						<button type="button" id="faqSearchClear" class="faq-search-clear"
							aria-label="검색어 지우기">×</button>


					</section>



					<!-- =================================================
                     CATEGORY
                ================================================== -->

					<div class="faq-category-list" id="faqCategoryList">


						<button type="button" class="faq-category active"
							data-category="ALL">전체</button>


						<button type="button" class="faq-category" data-category="ACCOUNT">

							계정 / 프로필</button>


						<button type="button" class="faq-category"
							data-category="ITINERARY">여행 일정</button>


						<button type="button" class="faq-category"
							data-category="COMMUNITY">게시글 / 커뮤니티</button>


						<button type="button" class="faq-category" data-category="PRIVACY">

							개인정보 / 공개범위</button>


						<button type="button" class="faq-category" data-category="ETC">

							기타</button>


					</div>



					<!-- =================================================
                     FAQ LIST
                ================================================== -->

					<section class="settings-panel faq-list" id="faqList">


						<!-- 계정 / 프로필 -->

						<article class="faq-item" data-category="ACCOUNT"
							data-keywords="회원정보 프로필 수정 닉네임 이미지 자기소개">


							<button type="button">


								<span> 회원정보는 어디에서 수정할 수 있나요? </span> <span class="faq-symbol">

									+ </span>


							</button>


							<p>

								마이페이지의 <strong>프로필 편집</strong> 메뉴에서 닉네임, 프로필 이미지, 자기소개 등 프로필 정보를
								수정할 수 있습니다.

							</p>


						</article>



						<article class="faq-item" data-category="ACCOUNT"
							data-keywords="비밀번호 변경 패스워드 계정">


							<button type="button">


								<span> 비밀번호를 변경하고 싶어요. </span> <span class="faq-symbol">

									+ </span>


							</button>


							<p>

								마이페이지 설정의 <strong>비밀번호 변경</strong> 메뉴에서 현재 비밀번호를 확인한 뒤 새로운 비밀번호로
								변경할 수 있습니다.

							</p>


						</article>



						<article class="faq-item" data-category="ACCOUNT"
							data-keywords="회원탈퇴 탈퇴 삭제 계정삭제">


							<button type="button">


								<span> 회원 탈퇴는 어떻게 하나요? </span> <span class="faq-symbol">

									+ </span>


							</button>


							<p>

								마이페이지 설정의 <strong>회원 탈퇴</strong> 메뉴에서 비밀번호를 확인한 후 탈퇴를 진행할 수
								있습니다.

							</p>


						</article>



						<!-- 여행 일정 -->

						<article class="faq-item" data-category="ITINERARY"
							data-keywords="여행 일정 작성 만들기 여행계획 장소 식당">


							<button type="button">


								<span> 여행 일정은 어떻게 작성하나요? </span> <span class="faq-symbol">

									+ </span>


							</button>


							<p>여행 일정 작성 화면에서 여행 기간을 선택하고, 방문할 장소와 식당 등을 추가하여 나만의 여행 일정을
								만들 수 있습니다.</p>


						</article>



						<article class="faq-item" data-category="ITINERARY"
							data-keywords="작성 일정 확인 내일정 프로필 게시글">


							<button type="button">


								<span> 내가 작성한 여행 일정은 어디에서 확인할 수 있나요? </span> <span
									class="faq-symbol"> + </span>


							</button>


							<p>내 프로필에서 내가 작성한 여행 일정 및 게시글을 확인할 수 있습니다. 게시글을 선택하면 해당 여행
								일정의 상세 화면으로 이동합니다.</p>


						</article>



						<article class="faq-item" data-category="ITINERARY"
							data-keywords="일정 수정 삭제 편집">


							<button type="button">


								<span> 작성한 여행 일정을 수정하거나 삭제할 수 있나요? </span> <span
									class="faq-symbol"> + </span>


							</button>


							<p>본인이 작성한 여행 일정은 내 프로필에서 해당 게시글을 선택한 후 제공되는 수정 또는 삭제 기능을 통해
								관리할 수 있습니다.</p>


						</article>



						<!-- 게시글 / 커뮤니티 -->

						<article class="faq-item" data-category="COMMUNITY"
							data-keywords="다른 사람 일정 조회 공개 프로필">


							<button type="button">


								<span> 다른 사용자의 여행 일정도 볼 수 있나요? </span> <span class="faq-symbol">

									+ </span>


							</button>


							<p>다른 사용자가 공개한 여행 일정은 프로필이나 여행 일정 조회 화면을 통해 확인할 수 있습니다.</p>


						</article>



						<article class="faq-item" data-category="COMMUNITY"
							data-keywords="좋아요 북마크 저장">


							<button type="button">


								<span> 좋아요와 북마크는 어떻게 사용하나요? </span> <span class="faq-symbol">

									+ </span>


							</button>


							<p>마음에 드는 여행 일정에는 좋아요를 누를 수 있고, 나중에 다시 확인하고 싶은 일정은 북마크하여 저장할
								수 있습니다.</p>


						</article>



						<article class="faq-item" data-category="COMMUNITY"
							data-keywords="신고 게시글 사용자 부적절 신고하기">


							<button type="button">


								<span> 부적절한 사용자나 게시물을 발견했어요. </span> <span class="faq-symbol">

									+ </span>


							</button>


							<p>사용자 프로필 또는 게시물에 있는 신고 기능을 이용하여 신고할 수 있습니다. 접수된 신고는 관리자가
								검토한 후 필요한 조치를 진행합니다.</p>


						</article>



						<!-- 개인정보 -->

						<article class="faq-item" data-category="PRIVACY"
							data-keywords="좋아요 공개 비공개 북마크 개인정보 공개범위">


							<button type="button">


								<span> 좋아요나 북마크 목록을 다른 사람에게 숨길 수 있나요? </span> <span
									class="faq-symbol"> + </span>


							</button>


							<p>마이페이지의 개인정보 및 공개범위 설정에서 좋아요한 일정과 북마크한 일정의 공개 여부를 각각 설정할 수
								있습니다.</p>


						</article>



						<article class="faq-item" data-category="PRIVACY"
							data-keywords="개인정보 처리방침 개인정보수집 개인정보보호">


							<button type="button">


								<span> Planb는 어떤 개인정보를 처리하나요? </span> <span class="faq-symbol">

									+ </span>


							</button>


							<p>

								회원가입 및 서비스 제공에 필요한 이름, 이메일, 전화번호 등과 서비스 이용 과정에서 생성되는 정보를 처리할 수
								있습니다. 자세한 내용은 <a href="<%=ctx%>/view/support/privacyPolicy.jsp">

									개인정보처리방침 </a> 에서 확인할 수 있습니다.

							</p>


						</article>



						<!-- 기타 -->

						<article class="faq-item" data-category="ETC"
							data-keywords="문의 오류 문제 고객지원 문의하기">


							<button type="button">


								<span> 서비스 이용 중 문제가 발생했어요. </span> <span class="faq-symbol">

									+ </span>


							</button>


							<p>FAQ에서 해결되지 않는 문제는 고객지원의 문의하기 메뉴에서 문의 유형과 내용을 작성하여 접수해주세요.

							</p>


						</article>



						<article class="faq-item" data-category="ETC"
							data-keywords="광고 광고문의 광고신청 배너 여행카드">


							<button type="button">


								<span> Planb에 광고를 등록하고 싶어요. </span> <span class="faq-symbol">

									+ </span>


							</button>


							<p>고객지원의 광고 문의하기 메뉴에서 광고 영역과 예상 가격을 확인한 뒤 광고 신청서를 작성할 수 있습니다.
								접수된 광고는 관리자 검토 후 승인 여부가 결정됩니다.</p>


						</article>


					</section>



					<!-- =================================================
                     EMPTY
                ================================================== -->

					<div class="faq-empty" id="faqEmpty">


						<div class="faq-empty-icon">?</div>


						<strong> 검색 결과가 없습니다. </strong>


						<p>다른 검색어를 입력하거나 카테고리를 변경해보세요.</p>


					</div>



					<!-- =================================================
                     문의하기 CTA
                ================================================== -->

					<section class="faq-help">


						<div class="faq-help-copy">


							<span> 원하는 답변을 찾지 못하셨나요? </span> <strong> 직접 문의해 주세요. </strong>


							<p>문의 내용을 남겨주시면 확인 후 안내드리겠습니다.</p>


						</div>


						<a class="faq-help-button" href="<%=ctx%>/support/inquiry">

							문의하기 <span> → </span>

						</a>


					</section>


				</div>


			</main>


		</div>


	</div>


	<jsp:include page="/common/footer.jsp" />



	<script>

document.addEventListener(
    "DOMContentLoaded",
    function () {


        const faqItems =
            Array.from(
                document.querySelectorAll(
                    ".faq-item"
                )
            );


        const categoryButtons =
            Array.from(
                document.querySelectorAll(
                    ".faq-category"
                )
            );


        const searchInput =
            document.getElementById(
                "faqSearch"
            );


        const clearButton =
            document.getElementById(
                "faqSearchClear"
            );


        const emptyState =
            document.getElementById(
                "faqEmpty"
            );


        let currentCategory =
            "ALL";



        /* =====================================================
           FAQ OPEN / CLOSE
        ====================================================== */

        faqItems.forEach(
            function (item) {


                const button =
                    item.querySelector(
                        "button"
                    );


                const symbol =
                    item.querySelector(
                        ".faq-symbol"
                    );


                button.addEventListener(
                    "click",
                    function () {


                        const isOpen =
                            item.classList.contains(
                                "open"
                            );


                        /*
                         * 다른 FAQ 닫기
                         */
                        faqItems.forEach(
                            function (otherItem) {


                                otherItem.classList.remove(
                                    "open"
                                );


                                const otherSymbol =
                                    otherItem.querySelector(
                                        ".faq-symbol"
                                    );


                                if (otherSymbol) {

                                    otherSymbol.textContent =
                                        "+";

                                }

                            }
                        );


                        /*
                         * 현재 항목 열기
                         */
                        if (!isOpen) {


                            item.classList.add(
                                "open"
                            );


                            symbol.textContent =
                                "−";

                        }


                    }
                );

            }
        );



        /* =====================================================
           FILTER
        ====================================================== */

        function filterFaq() {


            const keyword =
                searchInput.value
                    .trim()
                    .toLowerCase();


            let visibleCount = 0;


            faqItems.forEach(
                function (item) {


                    const itemCategory =
                        item.dataset.category;


                    const question =
                        item.querySelector(
                            "button span:first-child"
                        )
                        .textContent
                        .toLowerCase();


                    const answer =
                        item.querySelector(
                            "p"
                        )
                        .textContent
                        .toLowerCase();


                    const keywords =
                        (
                            item.dataset.keywords
                            || ""
                        )
                        .toLowerCase();



                    const categoryMatch =
                        currentCategory === "ALL"
                        ||
                        currentCategory
                        === itemCategory;


                    const keywordMatch =
                        keyword === ""
                        ||
                        question.includes(
                            keyword
                        )
                        ||
                        answer.includes(
                            keyword
                        )
                        ||
                        keywords.includes(
                            keyword
                        );


                    const visible =
                        categoryMatch
                        && keywordMatch;


                    item.style.display =
                        visible
                        ? ""
                        : "none";


                    if (visible) {

                        visibleCount++;

                    }


                }
            );


            emptyState.style.display =
                visibleCount === 0
                ? "flex"
                : "none";


            clearButton.classList.toggle(
                "visible",
                searchInput.value.length > 0
            );

        }



        /* =====================================================
           CATEGORY
        ====================================================== */

        categoryButtons.forEach(
            function (button) {


                button.addEventListener(
                    "click",
                    function () {


                        currentCategory =
                            button.dataset.category;


                        categoryButtons.forEach(
                            function (other) {

                                other.classList.remove(
                                    "active"
                                );

                            }
                        );


                        button.classList.add(
                            "active"
                        );


                        /*
                         * 카테고리 변경 시
                         * 열려 있던 FAQ 닫기
                         */
                        faqItems.forEach(
                            function (item) {


                                item.classList.remove(
                                    "open"
                                );


                                const symbol =
                                    item.querySelector(
                                        ".faq-symbol"
                                    );


                                if (symbol) {

                                    symbol.textContent =
                                        "+";

                                }

                            }
                        );


                        filterFaq();

                    }
                );

            }
        );



        /* =====================================================
           SEARCH
        ====================================================== */

        searchInput.addEventListener(
            "input",
            filterFaq
        );



        clearButton.addEventListener(
            "click",
            function () {


                searchInput.value =
                    "";


                searchInput.focus();


                filterFaq();

            }
        );



        /* 초기 상태 */

        filterFaq();

    }
);

</script>


</body>

</html>