<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
    import="java.util.List,java.util.ArrayList,java.text.SimpleDateFormat,dto.support.SupportInquiryDto" %>
<%!
    private String esc(Object obj) {
        if (obj == null) return "";
        return String.valueOf(obj).replace("&", "&amp;").replace("<", "&lt;")
                .replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    }
    private String catLabel(String c) {
        if ("ACCOUNT".equals(c)) return "계정";
        if ("ITINERARY".equals(c)) return "여행일정";
        if ("COMMUNITY".equals(c)) return "커뮤니티";
        if ("ERROR".equals(c)) return "오류";
        if ("ETC".equals(c)) return "기타";
        return "일반";
    }
    private String catStyle(String c) {
        if ("ACCOUNT".equals(c)) return "account";
        if ("ITINERARY".equals(c)) return "itinerary";
        if ("COMMUNITY".equals(c)) return "community";
        if ("ERROR".equals(c)) return "error";
        return "default";
    }
    private String statusName(String s) {
        if ("DONE".equals(s)) return "답변 완료";
        if ("ANSWERING".equals(s)) return "답변 중";
        return "접수 완료";
    }
    private String preview(String text) {
        if (text == null) return "";
        String shortText = text.trim();
        return shortText.length() > 220 ? shortText.substring(0, 220) + "…" : shortText;
    }
%>
<%
    request.setAttribute("activePage", "inquiries");
    String ctx = request.getContextPath();
    @SuppressWarnings("unchecked")
    List<SupportInquiryDto> inquiries = (List<SupportInquiryDto>) request.getAttribute("inquiries");
    if (inquiries == null) inquiries = new ArrayList<SupportInquiryDto>();
    String tab = (String)request.getAttribute("filterStatus");
    if (tab == null) tab = "RECEIVED";
    Integer received = (Integer)request.getAttribute("receivedCount");
    Integer answering = (Integer)request.getAttribute("answeringCount");
    Integer done = (Integer)request.getAttribute("doneCount");
    Integer total = (Integer)request.getAttribute("totalCount");
    if (received == null) received = 0;
    if (answering == null) answering = 0;
    if (done == null) done = 0;
    if (total == null) total = 0;
    SimpleDateFormat df = new SimpleDateFormat("yyyy.MM.dd HH:mm");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>문의 관리 | Planb</title>
    <jsp:include page="/common/headStyles.jsp" />
    <link rel="stylesheet" href="<%=ctx%>/view/assets/css/admin/adminInquiries.css?v=5">
</head>
<body class="site-shell">
<jsp:include page="/common/header.jsp" />
<main class="pi-page pi-inq-page">
    <section class="pi-head">
        <div>
            <span class="pi-eyebrow">ADMIN · INQUIRIES</span>
            <h1>문의 관리</h1>
            <p>접수된 회원 문의를 확인하고 답변을 등록합니다.<br class="pi-inq-desktop-break"> 처리 상태별로 문의를 분류해 확인할 수 있습니다.</p>
        </div>
        <div class="pi-head-summary">
            <span>답변 필요</span>
            <strong><%=received + answering%></strong>
        </div>
    </section>

    <section class="pi-summary-grid" aria-label="문의 상태 요약">
        <a href="<%=ctx%>/admin/support/inquiries?status=RECEIVED"
           class="pi-summary-card <%="RECEIVED".equals(tab) ? "selected" : ""%>">
            <span class="pi-summary-icon purple">
                <svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/></svg>
            </span>
            <div><span>접수 완료</span><strong><%=received%></strong></div>
        </a>
        <a href="<%=ctx%>/admin/support/inquiries?status=ANSWERING"
           class="pi-summary-card <%="ANSWERING".equals(tab) ? "selected" : ""%>">
            <span class="pi-summary-icon amber">
                <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M4 5h16v11H9l-5 4V5Z"/><path d="M8 10h8M8 13h5"/></svg>
            </span>
            <div><span>답변 중</span><strong><%=answering%></strong></div>
        </a>
        <a href="<%=ctx%>/admin/support/inquiries?status=DONE"
           class="pi-summary-card <%="DONE".equals(tab) ? "selected" : ""%>">
            <span class="pi-summary-icon green">
                <svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="12" r="9"/><path d="m8 12 3 3 5-6"/></svg>
            </span>
            <div><span>답변 완료</span><strong><%=done%></strong></div>
        </a>
        <a href="<%=ctx%>/admin/support/inquiries?status=ALL"
           class="pi-summary-card <%="ALL".equals(tab) ? "selected" : ""%>">
            <span class="pi-summary-icon gray">
                <svg viewBox="0 0 24 24" aria-hidden="true"><rect x="5" y="4" width="14" height="17" rx="2"/><path d="M9 9h6M9 13h6M9 17h4"/></svg>
            </span>
            <div><span>전체 문의</span><strong><%=total%></strong></div>
        </a>
    </section>

    <section class="pi-toolbar">
        <nav class="pi-tabs" aria-label="문의 상태 필터">
            <a href="<%=ctx%>/admin/support/inquiries?status=RECEIVED" class="<%="RECEIVED".equals(tab)?"active":""%>">접수 완료 <span><%=received%></span></a>
            <a href="<%=ctx%>/admin/support/inquiries?status=ANSWERING" class="<%="ANSWERING".equals(tab)?"active":""%>">답변 중 <span><%=answering%></span></a>
            <a href="<%=ctx%>/admin/support/inquiries?status=DONE" class="<%="DONE".equals(tab)?"active":""%>">답변 완료 <span><%=done%></span></a>
            <a href="<%=ctx%>/admin/support/inquiries?status=ALL" class="<%="ALL".equals(tab)?"active":""%>">전체 <span><%=total%></span></a>
        </nav>
        <div class="pi-toolbar-note">
            <svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="12" r="9"/><path d="M12 10v6M12 7h.01"/></svg>
            답변을 등록하면 문의 상태가 '답변 완료'로 바뀝니다.
        </div>
    </section>

    <section class="pi-list pi-inq-list" aria-label="문의 목록">
    <% if (inquiries.isEmpty()) { %>
        <div class="pi-empty">
            <span class="pi-empty-icon">
                <svg viewBox="0 0 24 24" aria-hidden="true"><rect x="4" y="5" width="16" height="14" rx="2"/><path d="m5 7 7 6 7-6"/></svg>
            </span>
            <strong>해당 상태의 문의가 없습니다.</strong>
            <p>선택한 상태의 문의가 없습니다. 다른 상태나 전체 목록을 확인해 주세요.</p>
            <% if (!"ALL".equals(tab)) { %>
            <a class="pi-inq-empty-link" href="<%=ctx%>/admin/support/inquiries?status=ALL">전체 문의 보기
                <svg viewBox="0 0 24 24" aria-hidden="true"><path d="m9 18 6-6-6-6"/></svg>
            </a>
            <% } %>
        </div>
    <% } else {
        for (SupportInquiryDto item : inquiries) {
            boolean completed = "DONE".equals(item.getStatus());
            String created = item.getCreatedAt() == null ? "-" : df.format(item.getCreatedAt());
    %>
        <article class="pi-card pi-inq-card">
            <div class="pi-type-panel pi-inq-type-panel <%=catStyle(item.getCategory())%>">
                <span class="pi-type-icon">
                    <svg viewBox="0 0 24 24" aria-hidden="true"><rect x="3" y="5" width="18" height="14" rx="2"/><path d="m4 7 8 6 8-6"/></svg>
                </span>
                <span class="pi-type-name"><%=esc(catLabel(item.getCategory()))%></span>
                <span class="pi-id">INQUIRY #<%=item.getInquiryId()%></span>
            </div>
            <div class="pi-body">
                <div class="pi-title-row">
                    <div class="pi-title-copy">
                        <div class="pi-meta-top">
                            <span class="pi-status pi-inq-status <%=completed ? "done" : ("ANSWERING".equals(item.getStatus()) ? "answering" : "received")%>"><%=statusName(item.getStatus())%></span>
                            <span class="pi-created"><%=esc(created)%></span>
                        </div>
                        <h2><%=esc(item.getTitle())%></h2>
                    </div>
                    <a class="pi-detail-link" href="<%=ctx%>/admin/support/inquiry?id=<%=item.getInquiryId()%>">
                        문의 상세
                        <svg viewBox="0 0 24 24" aria-hidden="true"><path d="m9 18 6-6-6-6"/></svg>
                    </a>
                </div>
                <div class="pi-info-grid">
                    <div><span>문의 유형</span><strong><%=esc(catLabel(item.getCategory()))%></strong></div>
                    <div><span>문의 회원</span><strong><%=item.getUserId() > 0 ? ("회원 #" + item.getUserId()) : "탈퇴·삭제된 회원"%></strong></div>
                    <div><span>회신 이메일</span><strong class="pi-inq-email"><%=esc(item.getContactEmail())%></strong></div>
                </div>
                <div class="pi-detail-box">
                    <span>문의 내용</span>
                    <p class="pi-inq-preview"><%=esc(preview(item.getContent()))%></p>
                </div>
                <div class="pi-footer">
                    <span class="pi-footer-note">
                        <svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="12" r="9"/><path d="M12 10v6M12 7h.01"/></svg>
                        <%=completed ? "등록된 관리자 답변을 확인할 수 있습니다." : "문의 상세에서 답변을 작성할 수 있습니다."%>
                    </span>
                    <div class="pi-actions">
                        <a class="<%=completed ? "pi-outline-action" : "pi-inq-primary-action"%>"
                           href="<%=ctx%>/admin/support/inquiry?id=<%=item.getInquiryId()%>"><%=completed ? "답변 확인" : "답변 작성"%></a>
                    </div>
                </div>
            </div>
        </article>
    <%  }
       } %>
    </section>
</main>
<jsp:include page="/common/footer.jsp" />
</body>
</html>
