<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
    import="java.text.SimpleDateFormat,dto.support.SupportInquiryDto" %>
<%!
    private String esc(Object o) {
        if (o == null) return "";
        return String.valueOf(o).replace("&", "&amp;").replace("<", "&lt;")
                .replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    }
    private String catName(String c) {
        if ("ACCOUNT".equals(c)) return "계정";
        if ("ITINERARY".equals(c)) return "여행일정";
        if ("COMMUNITY".equals(c)) return "커뮤니티";
        if ("ERROR".equals(c)) return "오류";
        if ("ETC".equals(c)) return "기타";
        return "일반";
    }
    private String statusName(String s) {
        if ("DONE".equals(s)) return "답변 완료";
        if ("ANSWERING".equals(s)) return "답변 중";
        return "접수 완료";
    }
%>
<%
    request.setAttribute("activePage", "inquiries");
    String ctx = request.getContextPath();
    SupportInquiryDto item = (SupportInquiryDto)request.getAttribute("inquiry");
    if (item == null) {
        response.sendError(404, "문의가 없습니다.");
        return;
    }
    String csrf = (String)request.getAttribute("csrf");
    if (csrf == null) csrf = "";
    boolean done = "DONE".equals(item.getStatus());
    SimpleDateFormat fmt = new SimpleDateFormat("yyyy.MM.dd HH:mm");
    String created = item.getCreatedAt() == null ? "-" : fmt.format(item.getCreatedAt());
    String answered = item.getAnsweredAt() == null ? "-" : fmt.format(item.getAnsweredAt());
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>문의 상세</title>
    <jsp:include page="/common/headStyles.jsp" />
    <link rel="stylesheet" href="<%=ctx%>/view/assets/css/admin/adminInquiries.css?v=5">
</head>
<body class="site-shell">
<jsp:include page="/common/header.jsp" />
<main class="pi-page pi-inq-page pi-inq-detail-page">
    <div class="pi-inq-back-row">
        <a href="<%=ctx%>/admin/support/inquiries?status=<%=done ? "DONE" : "RECEIVED"%>">
            <svg viewBox="0 0 24 24" aria-hidden="true"><path d="m15 18-6-6 6-6"/></svg>
            문의 목록으로
        </a>
    </div>

    <section class="pi-head pi-inq-detail-heading">
        <div>
            <span class="pi-eyebrow">ADMIN · INQUIRY DETAIL</span>
            <h1>문의 상세</h1>
            <p>접수된 문의 내용을 확인하고 회원에게 전달할 답변을 등록합니다.</p>
        </div>
        <div class="pi-head-summary pi-inq-id-summary">
            <span>문의 번호</span>
            <strong>#<%=item.getInquiryId()%></strong>
        </div>
    </section>

    <% if ("1".equals(request.getParameter("saved"))) { %>
    <div class="pi-result success pi-inq-result">
        <span class="pi-result-icon"><svg viewBox="0 0 24 24"><path d="m5 12 4 4L19 6"/></svg></span>
        <div><strong>답변이 등록되었습니다.</strong><span>회원은 고객지원의 내 문의 내역에서 답변을 확인할 수 있습니다.</span></div>
    </div>
    <% } %>

    <article class="pi-card pi-inq-detail-card">
        <div class="pi-type-panel pi-inq-type-panel detail">
            <span class="pi-type-icon"><svg viewBox="0 0 24 24"><rect x="3" y="5" width="18" height="14" rx="2"/><path d="m4 7 8 6 8-6"/></svg></span>
            <span class="pi-type-name"><%=esc(catName(item.getCategory()))%></span>
            <span class="pi-id">INQUIRY #<%=item.getInquiryId()%></span>
        </div>
        <div class="pi-body">
            <div class="pi-title-row">
                <div class="pi-title-copy">
                    <div class="pi-meta-top">
                        <span class="pi-status pi-inq-status <%=done ? "done" : ("ANSWERING".equals(item.getStatus()) ? "answering" : "received")%>"><%=statusName(item.getStatus())%></span>
                        <span class="pi-created"><%=esc(created)%></span>
                    </div>
                    <h2><%=esc(item.getTitle())%></h2>
                </div>
            </div>
            <div class="pi-info-grid">
                <div><span>문의 유형</span><strong><%=esc(catName(item.getCategory()))%></strong></div>
                <div><span>문의 회원</span><strong><%=item.getUserId() > 0 ? ("회원 #" + item.getUserId()) : "탈퇴·삭제된 회원"%></strong></div>
                <div><span>회신 이메일</span><strong class="pi-inq-email"><%=esc(item.getContactEmail())%></strong></div>
            </div>
            <div class="pi-detail-box pi-inq-content-box">
                <span>문의 내용</span>
                <p><%=esc(item.getContent())%></p>
            </div>
        </div>
    </article>

    <section class="pi-inq-answer-card" aria-label="관리자 답변">
        <div class="pi-inq-answer-header">
            <div>
                <span class="pi-inq-section-eyebrow">ADMIN RESPONSE</span>
                <h2><%=done ? "등록된 답변" : "관리자 답변 작성"%></h2>
                <p><%=done ? "회원에게 전달된 답변 내용입니다." : "작성한 답변은 회원의 내 문의 내역에 표시됩니다."%></p>
            </div>
            <span class="pi-inq-answer-badge <%=done ? "is-complete" : ""%>"><%=done ? "답변 완료" : "답변 작성"%></span>
        </div>
        <% if (done) { %>
        <div class="pi-inq-answered-body"><%=esc(item.getAnswer())%></div>
        <div class="pi-inq-answered-meta">답변 일시 <strong><%=esc(answered)%></strong> <span class="pi-inq-inline-divider"></span> 답변 관리자 <strong><%=item.getAnsweredByUserId() > 0 ? ("#" + item.getAnsweredByUserId()) : "-"%></strong></div>
        <% } else { %>
        <form class="pi-inq-form" action="<%=ctx%>/admin/support/inquiry" method="post">
            <input type="hidden" name="id" value="<%=item.getInquiryId()%>">
            <input type="hidden" name="csrf" value="<%=esc(csrf)%>">
            <label for="answerText">답변 내용 <span class="pi-inq-required">*</span></label>
            <textarea id="answerText" name="answer" minlength="1" maxlength="3000" required placeholder="회원에게 전달할 답변을 입력해 주세요."></textarea>
            <div class="pi-inq-form-footer">
                <span class="pi-inq-form-hint">개인정보가 불필요하게 포함되지 않도록 확인해 주세요.</span>
                <div class="pi-inq-form-actions">
                    <a class="pi-inq-secondary" href="<%=ctx%>/admin/support/inquiries">목록으로</a>
                    <button type="submit" class="pi-inq-primary-action" onclick="return confirm('답변을 등록하시겠습니까? 등록 후에는 이 화면에서 수정할 수 없습니다.');">답변 등록</button>
                </div>
            </div>
        </form>
        <% } %>
    </section>
</main>
<jsp:include page="/common/footer.jsp" />
</body>
</html>
