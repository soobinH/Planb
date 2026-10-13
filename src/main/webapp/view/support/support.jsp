<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
request.setAttribute("activePage", "profile");
request.setAttribute("settingsPage", "support");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>고객지원</title>
<jsp:include page="/common/headStyles.jsp" />
<link rel="stylesheet" href="${pageContext.request.contextPath}/view/assets/css/support/support.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/view/assets/css/setting/settings.css">
</head>
<body class="site-shell">
<jsp:include page="/common/header.jsp" />
<div class="settings-page">
  <div class="settings-shell">
    <jsp:include page="/common/settingsSidebar.jsp" />
    <main class="settings-main">
      <div class="settings-content">
        <header class="settings-title">
          <span class="settings-eyebrow">SETTINGS</span>
          <h1>고객지원</h1>
          <p>Planb 이용 중 필요한 도움을 빠르게 찾아보세요.</p>
        </header>
        <section class="support-entry-grid">
          <a class="support-entry-card" href="${pageContext.request.contextPath}/support/faq">
            <span class="support-entry-icon">▧</span><span><strong>자주 묻는 질문</strong><small>계정, 프로필, 게시글 관련 안내를 확인합니다.</small></span><span>›</span>
          </a>
          <a class="support-entry-card" href="${pageContext.request.contextPath}/support/inquiry">
            <span class="support-entry-icon">◯</span><span><strong>문의하기</strong><small>문의 유형과 내용을 작성해 접수하는 화면입니다.</small></span><span>›</span>
          </a>
          <a class="support-entry-card" href="${pageContext.request.contextPath}/support/myInquiries">
            <span class="support-entry-icon">▤</span><span><strong>내 문의 내역</strong><small>접수한 문의의 진행 상태와 관리자 답변을 확인합니다.</small></span><span>›</span>
          </a>
        </section>
        <section class="settings-panel support-links support-legal-links">
          <a href="${pageContext.request.contextPath}/support/adGuide"><span>📣 광고 문의하기</span><span>›</span></a>
          <a href="${pageContext.request.contextPath}/view/support/term.jsp"><span>이용약관</span><span>›</span></a>
          <a href="${pageContext.request.contextPath}/view/support/privacyPolicy.jsp"><span>개인정보처리방침</span><span>›</span></a>
        </section>
      </div>
    </main>
  </div>
</div>
<jsp:include page="/common/footer.jsp" />
</body>
</html>
