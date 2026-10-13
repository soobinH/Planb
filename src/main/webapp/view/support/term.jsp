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

<title>이용약관</title>


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


				<div class="settings-content legal-page">


					<!-- =============================================
                     HEADER
                ============================================== -->

					<header class="settings-title">


						<span class="settings-eyebrow"> TERMS </span>


						<h1>이용약관</h1>


						<p>Planb 서비스 이용에 필요한 기본적인 권리와 의무를 안내합니다.</p>


					</header>



					<a class="support-back" href="<%=ctx%>/support/support">

						‹ 고객지원 </a>



					<!-- =============================================
                     상단 요약
                ============================================== -->

					<section class="legal-summary">


						<div>


							<span class="legal-summary-label"> Planb Terms of Service
							</span>


							<h2>Planb 이용약관</h2>


							<p>본 약관은 Planb가 제공하는 여행 일정 작성·공유 및 관련 서비스를 이용하는 과정에서 필요한 사항을
								정하기 위한 것입니다.</p>


						</div>



						<div class="legal-date">

							<span> 시행일 </span> <strong> 2026.10.07 </strong>

						</div>


					</section>



					<!-- =============================================
                     바로가기
                ============================================== -->

					<nav class="legal-index" aria-label="약관 목차">


						<a href="#article1"> 01 목적 </a> <a href="#article2"> 02 용어 </a> <a
							href="#article3"> 03 서비스 </a> <a href="#article4"> 04 회원가입 </a> <a
							href="#article5"> 05 이용자 의무 </a> <a href="#article6"> 06 게시물
						</a> <a href="#article7"> 07 이용 제한 </a> <a href="#article8"> 08 광고
						</a> <a href="#article9"> 09 탈퇴 </a> <a href="#article10"> 10 책임 </a>


					</nav>



					<!-- =============================================
                     약관 본문
                ============================================== -->

					<section class="legal-document">


						<!-- 제1조 -->

						<article class="legal-article" id="article1">


							<div class="legal-article-number">제1조</div>


							<div class="legal-article-content">


								<h2>목적</h2>


								<p>본 약관은 Planb가 제공하는 여행 일정 작성, 여행 일정 공유, 커뮤니티, 프로필 및 기타 관련
									서비스의 이용과 관련하여 서비스와 이용자 간의 권리, 의무 및 책임사항을 정하는 것을 목적으로 합니다.</p>


							</div>


						</article>



						<!-- 제2조 -->

						<article class="legal-article" id="article2">


							<div class="legal-article-number">제2조</div>


							<div class="legal-article-content">


								<h2>용어의 정의</h2>


								<p>이 약관에서 사용하는 주요 용어의 의미는 다음과 같습니다.</p>


								<div class="legal-definition">


									<div>

										<strong> 회원 </strong>

										<p>Planb에 회원가입하고 서비스를 이용하는 이용자</p>

									</div>


									<div>

										<strong> 여행 일정 </strong>

										<p>회원이 작성하거나 공유한 여행 계획 및 관련 정보</p>

									</div>


									<div>

										<strong> 게시물 </strong>

										<p>회원이 서비스에 등록한 일정, 글, 이미지, 댓글 등</p>

									</div>


									<div>

										<strong> 서비스 </strong>

										<p>Planb 웹사이트에서 제공하는 모든 기능 및 관련 서비스</p>

									</div>


								</div>


							</div>


						</article>



						<!-- 제3조 -->

						<article class="legal-article" id="article3">


							<div class="legal-article-number">제3조</div>


							<div class="legal-article-content">


								<h2>서비스의 제공</h2>


								<p>Planb는 회원에게 다음과 같은 서비스를 제공합니다.</p>


								<ol>

									<li>여행 일정 작성 및 저장</li>

									<li>다른 이용자의 여행 일정 조회 및 공유</li>

									<li>여행 일정 좋아요 및 북마크</li>

									<li>프로필 및 공개 범위 관리</li>

									<li>게시글 및 커뮤니티 기능</li>

									<li>신고 및 고객 문의 기능</li>

									<li>광고 및 제휴 관련 서비스</li>

									<li>그 밖에 Planb가 추가로 제공하는 서비스</li>

								</ol>


								<div class="legal-notice">서비스의 구체적인 내용은 운영상 필요에 따라 변경되거나
									일부 기능이 추가·중단될 수 있습니다.</div>


							</div>


						</article>



						<!-- 제4조 -->

						<article class="legal-article" id="article4">


							<div class="legal-article-number">제4조</div>


							<div class="legal-article-content">


								<h2>회원가입 및 계정 관리</h2>


								<p>회원은 서비스에서 요구하는 정보를 정확하게 입력하여 회원가입을 신청해야 합니다.</p>


								<p>회원은 자신의 계정 정보를 안전하게 관리해야 하며, 본인의 계정을 제3자가 부정하게 이용하지 않도록
									주의해야 합니다.</p>


								<p>회원정보에 변경사항이 발생한 경우 회원은 서비스 내 프로필 및 계정 설정 기능을 통해 정보를 수정할 수
									있습니다.</p>


							</div>


						</article>



						<!-- 제5조 -->

						<article class="legal-article" id="article5">


							<div class="legal-article-number">제5조</div>


							<div class="legal-article-content">


								<h2>회원의 의무</h2>


								<p>회원은 서비스를 이용하면서 다음 행위를 해서는 안 됩니다.</p>


								<ol>

									<li>다른 사람의 개인정보 또는 계정을 무단으로 사용하는 행위</li>

									<li>허위 또는 부정확한 정보를 등록하는 행위</li>

									<li>다른 이용자를 모욕하거나 괴롭히는 행위</li>

									<li>불법 또는 부적절한 콘텐츠를 등록하는 행위</li>

									<li>서비스의 정상적인 운영을 방해하는 행위</li>

									<li>타인의 저작권, 초상권, 개인정보 등 권리를 침해하는 행위</li>

									<li>광고성·스팸성 콘텐츠를 무단 게시하는 행위</li>

								</ol>


							</div>


						</article>



						<!-- 제6조 -->

						<article class="legal-article" id="article6">


							<div class="legal-article-number">제6조</div>


							<div class="legal-article-content">


								<h2>게시물 및 콘텐츠</h2>


								<p>회원이 작성한 여행 일정, 게시글, 이미지 등 콘텐츠에 대한 권리는 원칙적으로 해당 콘텐츠를 작성한
									회원에게 있습니다.</p>


								<p>회원은 다른 이용자가 서비스 내에서 게시물을 열람할 수 있도록 공개 범위를 설정할 수 있습니다.</p>


								<p>신고가 접수되거나 서비스 운영정책을 위반한 게시물은 관리자 검토 후 노출 제한 또는 삭제 등의 조치가
									이루어질 수 있습니다.</p>


							</div>


						</article>



						<!-- 제7조 -->

						<article class="legal-article" id="article7">


							<div class="legal-article-number">제7조</div>


							<div class="legal-article-content">


								<h2>서비스 이용 제한</h2>


								<p>Planb는 이용자가 본 약관이나 서비스 운영정책을 위반한 경우 필요한 범위에서 서비스 이용을 제한할
									수 있습니다.</p>


								<p>심각하거나 반복적인 위반 행위가 확인되는 경우 게시물 삭제, 계정 이용 제한 등의 조치가 이루어질 수
									있습니다.</p>


							</div>


						</article>



						<!-- 제8조 -->

						<article class="legal-article" id="article8">


							<div class="legal-article-number">제8조</div>


							<div class="legal-article-content">


								<h2>광고 및 제휴 서비스</h2>


								<p>Planb는 서비스 내 일부 영역에 광고 또는 제휴 콘텐츠를 제공할 수 있습니다.</p>


								<p>광고 신청자가 제출한 광고는 관리자 검토 및 승인 절차를 거친 후 지정된 기간 동안 노출될 수
									있습니다.</p>


								<p>법령 또는 서비스 정책에 위반되는 광고는 승인되지 않거나 게시 중에도 노출이 중단될 수 있습니다.</p>


							</div>


						</article>



						<!-- 제9조 -->

						<article class="legal-article" id="article9">


							<div class="legal-article-number">제9조</div>


							<div class="legal-article-content">


								<h2>회원 탈퇴</h2>


								<p>회원은 언제든지 서비스 내 회원 탈퇴 기능을 이용해 탈퇴를 요청할 수 있습니다.</p>


								<p>회원 탈퇴 후 회원 정보는 서비스 운영 및 관련 법령에서 요구하는 경우를 제외하고 처리 목적이 달성된
									범위에서 삭제 또는 비식별 처리됩니다.</p>


							</div>


						</article>



						<!-- 제10조 -->

						<article class="legal-article" id="article10">


							<div class="legal-article-number">제10조</div>


							<div class="legal-article-content">


								<h2>서비스 이용에 관한 책임</h2>


								<p>회원이 직접 작성한 여행 정보, 게시물 및 외부 링크의 정확성과 신뢰성에 대한 책임은 해당 정보를
									등록한 회원에게 있습니다.</p>


								<p>Planb는 천재지변, 시스템 장애, 통신 장애 등 합리적으로 통제하기 어려운 사유로 서비스 제공이
									일시적으로 중단될 수 있습니다.</p>


							</div>


						</article>



						<!-- 부칙 -->

						<article class="legal-article">


							<div class="legal-article-number">부칙</div>


							<div class="legal-article-content">


								<h2>시행일</h2>


								<p>

									본 약관은 <strong>2026년 10월 7일</strong>부터 적용됩니다.

								</p>


							</div>


						</article>


					</section>



					<!-- =============================================
                     하단 이동
                ============================================== -->

					<section class="legal-footer-links">


						<div>

							<span> 개인정보 처리 내용도 확인해보세요. </span> <strong> 개인정보처리방침 </strong>

						</div>


						<a href="<%=ctx%>/support/privacyPolicy"> 개인정보처리방침 보기
							→ </a>


					</section>


				</div>


			</main>


		</div>


	</div>


	<jsp:include page="/common/footer.jsp" />


</body>

</html>