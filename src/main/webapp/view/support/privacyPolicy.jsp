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


<title>개인정보처리방침</title>


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


						<span class="settings-eyebrow"> PRIVACY </span>


						<h1>개인정보처리방침</h1>


						<p>Planb가 이용자의 개인정보를 어떤 목적으로 처리하고 보호하는지 안내합니다.</p>


					</header>



					<a class="support-back" href="<%=ctx%>/support/support">

						‹ 고객지원 </a>



					<!-- =============================================
                     상단 요약
                ============================================== -->

					<section class="legal-summary">


						<div>


							<span class="legal-summary-label"> Planb Privacy Policy </span>


							<h2>개인정보 보호 안내</h2>


							<p>Planb는 서비스 제공에 필요한 개인정보만을 처리하고, 이용자의 개인정보를 안전하게 관리하기 위해
								노력합니다.</p>


						</div>


						<div class="legal-date">


							<span> 시행일 </span> <strong> 2026.10.07 </strong>


						</div>


					</section>



					<!-- =============================================
                     목차
                ============================================== -->

					<nav class="legal-index" aria-label="개인정보처리방침 목차">


						<a href="#privacy1"> 01 수집 항목 </a> <a href="#privacy2"> 02 이용
							목적 </a> <a href="#privacy3"> 03 보유 기간 </a> <a href="#privacy4">
							04 제공 </a> <a href="#privacy5"> 05 파기 </a> <a href="#privacy6">
							06 이용자 권리 </a> <a href="#privacy7"> 07 보호 조치 </a> <a href="#privacy8">
							08 문의 </a>


					</nav>



					<!-- =============================================
                     본문
                ============================================== -->

					<section class="legal-document">


						<!-- 1 -->

						<article class="legal-article" id="privacy1">


							<div class="legal-article-number">01</div>


							<div class="legal-article-content">


								<h2>처리하는 개인정보 항목</h2>


								<p>Planb는 서비스 제공을 위해 다음과 같은 개인정보를 처리할 수 있습니다.</p>



								<div class="privacy-table-wrap">


									<table class="privacy-table">


										<thead>


											<tr>

												<th>구분</th>

												<th>처리 항목</th>

											</tr>


										</thead>


										<tbody>


											<tr>

												<td>회원가입</td>

												<td>이름, 로그인 정보, 이메일, 전화번호, 비밀번호</td>

											</tr>


											<tr>

												<td>프로필</td>

												<td>닉네임, 프로필 이미지, 자기소개, 지역 등 회원이 선택하여 입력한 정보</td>

											</tr>


											<tr>

												<td>문의하기</td>

												<td>회원번호, 문의 유형, 제목, 문의 내용, 회신 이메일</td>

											</tr>


											<tr>

												<td>광고 문의</td>

												<td>업체명, 담당자명, 연락처, 이메일, 광고 내용, 광고 이미지 및 연결 주소</td>

											</tr>


											<tr>

												<td>서비스 이용</td>

												<td>회원이 작성한 여행 일정, 게시물, 좋아요, 북마크, 신고 등 서비스 이용 정보</td>

											</tr>


										</tbody>


									</table>


								</div>


								<div class="legal-notice">선택 항목은 해당 기능을 이용하는 경우에만 입력하거나
									처리됩니다.</div>


							</div>


						</article>



						<!-- 2 -->

						<article class="legal-article" id="privacy2">


							<div class="legal-article-number">02</div>


							<div class="legal-article-content">


								<h2>개인정보의 처리 목적</h2>


								<p>수집된 개인정보는 다음 목적의 범위에서 이용됩니다.</p>


								<ol>

									<li>회원 가입 및 본인 식별</li>

									<li>로그인 및 계정 관리</li>

									<li>프로필 및 개인화 기능 제공</li>

									<li>여행 일정 작성·저장·공유</li>

									<li>좋아요 및 북마크 기능 제공</li>

									<li>신고 처리 및 서비스 운영</li>

									<li>고객 문의에 대한 확인 및 회신</li>

									<li>광고 문의 접수 및 승인 처리</li>

									<li>서비스 안정성 유지 및 부정 이용 방지</li>

								</ol>


							</div>


						</article>



						<!-- 3 -->

						<article class="legal-article" id="privacy3">


							<div class="legal-article-number">03</div>


							<div class="legal-article-content">


								<h2>개인정보의 보유 및 이용기간</h2>


								<p>Planb는 개인정보의 처리 목적이 달성될 때까지 필요한 범위에서 개인정보를 보유합니다.</p>


								<div class="privacy-period-grid">


									<div>


										<span> 회원 정보 </span> <strong> 회원 탈퇴 시까지 </strong>


										<p>다만 관계 법령 또는 서비스 운영상 보존이 필요한 정보는 필요한 기간 동안 분리하여 보관할 수
											있습니다.</p>


									</div>



									<div>


										<span> 고객 문의 </span> <strong> 문의 처리 목적 달성 시까지 </strong>


										<p>문의 처리 기록은 서비스 운영 및 분쟁 대응을 위해 필요한 범위에서 보관될 수 있습니다.</p>


									</div>



									<div>


										<span> 광고 문의 </span> <strong> 광고 처리 종료 시까지 </strong>


										<p>승인, 거절, 게시 종료 등 광고 처리에 필요한 기간 동안 관련 정보를 보관합니다.</p>


									</div>


								</div>


							</div>


						</article>



						<!-- 4 -->

						<article class="legal-article" id="privacy4">


							<div class="legal-article-number">04</div>


							<div class="legal-article-content">


								<h2>개인정보의 제3자 제공</h2>


								<p>Planb는 원칙적으로 이용자의 개인정보를 서비스 제공 목적 외의 제3자에게 임의로 제공하지 않습니다.

								</p>


								<p>다만 이용자가 사전에 동의하거나 관계 법령에 따라 제공이 필요한 경우에는 예외로 할 수 있습니다.</p>


							</div>


						</article>



						<!-- 5 -->

						<article class="legal-article" id="privacy5">


							<div class="legal-article-number">05</div>


							<div class="legal-article-content">


								<h2>개인정보의 파기</h2>


								<p>개인정보의 처리 목적이 달성되고 더 이상 보관할 필요가 없는 경우 해당 개인정보는 지체 없이 삭제하거나
									안전한 방법으로 파기합니다.</p>


								<p>전자적 파일 형태의 정보는 복구하기 어려운 방식으로 삭제하고, 별도 문서 형태로 보관되는 정보가 있는
									경우 안전한 방법으로 폐기합니다.</p>


							</div>


						</article>



						<!-- 6 -->

						<article class="legal-article" id="privacy6">


							<div class="legal-article-number">06</div>


							<div class="legal-article-content">


								<h2>이용자의 권리</h2>


								<p>이용자는 서비스 내 설정 기능을 통해 자신의 개인정보를 조회하거나 수정할 수 있습니다.</p>


								<p>회원은 회원 탈퇴를 통해 개인정보 처리의 중단을 요청할 수 있으며, 공개 범위 설정을 통해 프로필 및
									활동 정보의 노출 범위를 조정할 수 있습니다.</p>


								<p>개인정보와 관련된 문의는 고객지원의 문의하기 기능을 통해 접수할 수 있습니다.</p>


							</div>


						</article>



						<!-- 7 -->

						<article class="legal-article" id="privacy7">


							<div class="legal-article-number">07</div>


							<div class="legal-article-content">


								<h2>개인정보 보호를 위한 조치</h2>


								<p>Planb는 개인정보의 분실, 유출, 변조 또는 훼손을 방지하기 위해 필요한 관리적·기술적 보호 조치를
									적용하도록 노력합니다.</p>


								<div class="privacy-security-grid">


									<div>

										<span> 01 </span> <strong> 비밀번호 보호 </strong>

										<p>회원 비밀번호는 평문으로 저장하지 않는 것을 원칙으로 합니다.</p>

									</div>



									<div>

										<span> 02 </span> <strong> 접근 권한 관리 </strong>

										<p>관리자 기능과 일반 회원 기능을 구분하여 운영합니다.</p>

									</div>



									<div>

										<span> 03 </span> <strong> 최소 정보 처리 </strong>

										<p>서비스 제공에 필요한 범위의 정보만 처리합니다.</p>

									</div>


								</div>


							</div>


						</article>



						<!-- 8 -->

						<article class="legal-article" id="privacy8">


							<div class="legal-article-number">08</div>


							<div class="legal-article-content">


								<h2>개인정보 관련 문의</h2>


								<p>개인정보 처리와 관련하여 문의사항이 있는 경우 Planb 고객지원의 문의하기 기능을 이용할 수
									있습니다.</p>


								<a class="legal-contact-button"
									href="<%=ctx%>/support/inquiry"> 문의하기 </a>


							</div>


						</article>



						<!-- 시행일 -->

						<article class="legal-article">


							<div class="legal-article-number">시행일</div>


							<div class="legal-article-content">


								<h2>방침 적용일</h2>


								<p>

									본 개인정보처리방침은 <strong>2026년 10월 7일</strong>부터 적용됩니다.

								</p>


							</div>


						</article>


					</section>



					<!-- =============================================
                     하단 링크
                ============================================== -->

					<section class="legal-footer-links">


						<div>

							<span> 서비스 이용 기준도 확인해보세요. </span> <strong> 이용약관 </strong>

						</div>


						<a href="<%=ctx%>/support/term"> 이용약관 보기 → </a>


					</section>


				</div>


			</main>


		</div>


	</div>


	<jsp:include page="/common/footer.jsp" />


</body>

</html>