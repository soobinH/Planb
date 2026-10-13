
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>탈퇴한 회원 | PLANB</title>

<style>
.withdrawn-page {
	min-height: calc(100vh - 80px);
	display: flex;
	align-items: center;
	justify-content: center;
	background: #fff;
	font-family: Pretendard, Arial, sans-serif;
}

.withdrawn-content {
	text-align: center;
	padding: 60px 24px;
}

.withdrawn-icon {
	width: 80px;
	height: 80px;
	margin: 0 auto 24px;
	border-radius: 50%;
	background: #f4f4f6;
	display: flex;
	align-items: center;
	justify-content: center;
	color: #999;
}

.withdrawn-title {
	font-size: 22px;
	font-weight: 600;
	color: #222;
	margin: 0 0 12px;
}

.withdrawn-description {
	font-size: 14px;
	color: #888;
	line-height: 1.8;
	margin: 0 0 32px;
}

.withdrawn-back {
	height: 44px;
	padding: 0 28px;
	background: #6369D1;
	color: #fff;
	border: none;
	border-radius: 6px;
	font-size: 14px;
	font-weight: 500;
	cursor: pointer;
}

.withdrawn-back:hover {
	background: #5157bd;
}
</style>
</head>

<body>

	<%-- 기존 프로젝트의 공통 헤더를 여기에 포함 --%>

	<main class="withdrawn-page">
		<div class="withdrawn-content">

			<div class="withdrawn-icon">
				<svg width="40" height="40" viewBox="0 0 24 24" fill="none"
					stroke="currentColor" stroke-width="1.5">
                    <circle cx="12" cy="12" r="10" />
                    <circle cx="9" cy="10" r="1" fill="currentColor" />
                    <circle cx="15" cy="10" r="1" fill="currentColor" />
                    <path d="M8 16 Q12 12 16 16" />
                </svg>
			</div>

			<h2 class="withdrawn-title">탈퇴한 회원입니다.</h2>

			<p class="withdrawn-description">
				해당 회원은 서비스를 탈퇴하여<br> 더 이상 프로필을 확인할 수 없습니다.
			</p>

			<button class="withdrawn-back" type="button"
				onclick="window.location.href='${pageContext.request.contextPath}/'">
				홈으로 돌아가기</button>

		</div>
	</main>

</body>
</html>
