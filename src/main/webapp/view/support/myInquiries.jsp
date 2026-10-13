<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
    import="java.util.List,java.util.ArrayList,java.text.SimpleDateFormat,dto.support.SupportInquiryDto" %>
<%!
    private String esc(Object o) {
        if (o == null) return "";
        return String.valueOf(o).replace("&", "&amp;").replace("<", "&lt;")
                .replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    }
    private String categoryName(String c) {
        if ("ACCOUNT".equals(c)) return "계정";
        if ("ITINERARY".equals(c)) return "여행 일정";
        if ("COMMUNITY".equals(c)) return "커뮤니티";
        if ("ERROR".equals(c)) return "오류";
        if ("ETC".equals(c)) return "기타";
        return "일반";
    }
    private String stateName(String s) {
        if ("DONE".equals(s)) return "답변 완료";
        if ("ANSWERING".equals(s)) return "답변 중";
        return "접수 완료";
    }
%>
<%
    request.setAttribute("activePage", "profile");
    request.setAttribute("settingsPage", "support");
    String ctx = request.getContextPath();
    @SuppressWarnings("unchecked")
    List<SupportInquiryDto> inquiries = (List<SupportInquiryDto>) request.getAttribute("myInquiries");
    if (inquiries == null) inquiries = new ArrayList<SupportInquiryDto>();
    SupportInquiryDto selected = (SupportInquiryDto) request.getAttribute("selectedInquiry");
    int waitingCount = 0;
    int doneCount = 0;
    for (SupportInquiryDto i : inquiries) {
        if ("DONE".equals(i.getStatus())) doneCount++;
        else waitingCount++;
    }
    SimpleDateFormat df = new SimpleDateFormat("yyyy.MM.dd HH:mm");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>내 문의 내역 · Planb</title>
    <jsp:include page="/common/headStyles.jsp" />
    <link rel="stylesheet" href="<%=ctx%>/view/assets/css/support/support.css">
    <link rel="stylesheet" href="<%=ctx%>/view/assets/css/setting/settings.css">
    <link rel="stylesheet" href="<%=ctx%>/view/assets/css/support/myInquiries.css?v=2">
</head>
<body class="site-shell">
<jsp:include page="/common/header.jsp" />
<div class="settings-page">
    <div class="settings-shell">
        <jsp:include page="/common/settingsSidebar.jsp" />
        <main class="settings-main">
            <div class="settings-content my-inquiry-page">
                <header class="settings-title">
                    <span class="settings-eyebrow">SUPPORT · MY INQUIRIES</span>
                    <h1>내 문의 내역</h1>
                    <p>접수한 문의의 처리 상태와 관리자 답변을 확인할 수 있어요.</p>
                </header>

                <section class="my-inquiry-overview" aria-label="문의 요약">
                    <div class="my-inquiry-overview-item">
                        <span>전체 문의</span>
                        <strong><%=inquiries.size()%><small>건</small></strong>
                    </div>
                    <div class="my-inquiry-overview-item">
                        <span>답변 대기</span>
                        <strong><%=waitingCount%><small>건</small></strong>
                    </div>
                    <div class="my-inquiry-overview-item">
                        <span>답변 완료</span>
                        <strong><%=doneCount%><small>건</small></strong>
                    </div>
                </section>

                <section class="my-inquiry-list-section" aria-label="내 문의 목록">
                    <div class="my-inquiry-list-head">
                        <div>
                            <h2>문의 내역 <span><%=inquiries.size()%></span></h2>
                            <p>문의 제목을 선택하면 상세 내용을 볼 수 있어요.</p>
                        </div>
                        <a href="<%=ctx%>/support/inquiry" class="my-inquiry-new-btn">
                            <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 5v14M5 12h14"/></svg>
                            새 문의하기
                        </a>
                    </div>

                    <% if (inquiries.isEmpty()) { %>
                        <div class="my-inquiry-empty">
                            <span class="my-inquiry-empty-icon">
                                <svg viewBox="0 0 24 24" aria-hidden="true"><rect x="3" y="5" width="18" height="14" rx="2"/><path d="m4 7 8 6 8-6"/></svg>
                            </span>
                            <strong>아직 등록한 문의가 없어요.</strong>
                            <p>궁금한 점이나 도움이 필요한 내용이 있다면 문의해 주세요.</p>
                            <a href="<%=ctx%>/support/inquiry">문의 작성하기</a>
                        </div>
                    <% } else { %>
                        <div class="my-inquiry-table" role="list">
                            <div class="my-inquiry-table-head" aria-hidden="true">
                                <span>유형</span><span>문의 제목</span><span>접수일</span><span>처리 상태</span><span></span>
                            </div>
                            <% for (SupportInquiryDto i : inquiries) {
                                boolean active = selected != null && selected.getInquiryId() == i.getInquiryId();
                                boolean finished = "DONE".equals(i.getStatus());
                                String stamp = i.getCreatedAt() == null ? "-" : df.format(i.getCreatedAt());
                            %>
                            <a role="listitem" href="<%=ctx%>/support/myInquiries?id=<%=i.getInquiryId()%>#inquiry-detail"
                               class="my-inquiry-table-row <%=active ? "is-selected" : ""%>"
                               <%=active ? "aria-current=\"true\"" : ""%>>
                                <span class="my-inquiry-category"><%=esc(categoryName(i.getCategory()))%></span>
                                <strong class="my-inquiry-row-title"><%=esc(i.getTitle())%></strong>
                                <time class="my-inquiry-row-date"><%=esc(stamp)%></time>
                                <span class="my-inquiry-state <%=finished ? "is-done" : ("ANSWERING".equals(i.getStatus()) ? "is-answering" : "")%>"><%=stateName(i.getStatus())%></span>
                                <svg class="my-inquiry-row-chevron" viewBox="0 0 24 24" aria-hidden="true"><path d="m9 18 6-6-6-6"/></svg>
                            </a>
                            <% } %>
                        </div>
                    <% } %>
                </section>

                <% if (selected != null) {
                    boolean answered = "DONE".equals(selected.getStatus()) &&
                            selected.getAnswer() != null && !selected.getAnswer().trim().isEmpty();
                    String receivedAt = selected.getCreatedAt() == null ? "-" : df.format(selected.getCreatedAt());
                    String replyAt = selected.getAnsweredAt() == null ? "-" : df.format(selected.getAnsweredAt());
                %>
                <section class="my-inquiry-detail" id="inquiry-detail" aria-label="문의 상세 및 답변">
                    <div class="my-inquiry-detail-topline">
                        <span class="my-inquiry-detail-eyebrow">INQUIRY #<%=selected.getInquiryId()%></span>
                        <span class="my-inquiry-state <%= "DONE".equals(selected.getStatus()) ? "is-done" : ("ANSWERING".equals(selected.getStatus()) ? "is-answering" : "")%>"><%=stateName(selected.getStatus())%></span>
                    </div>
                    <h2><%=esc(selected.getTitle())%></h2>
                    <div class="my-inquiry-detail-meta">
                        <span><%=esc(categoryName(selected.getCategory()))%></span>
                        <span class="my-inquiry-dot">·</span>
                        <time><%=esc(receivedAt)%></time>
                    </div>
                    <div class="my-inquiry-message">
                        <div class="my-inquiry-message-label">
                            <span class="my-inquiry-message-icon"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M8 10h8M8 14h6"/><path d="M5 4h14v16H5z"/></svg></span>
                            <strong>문의 내용</strong>
                        </div>
                        <div class="my-inquiry-message-body"><%=esc(selected.getContent())%></div>
                    </div>
                    <div class="my-inquiry-reply <%=answered ? "is-answered" : "is-waiting"%>">
                        <div class="my-inquiry-message-label">
                            <span class="my-inquiry-message-icon"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M20 11a7 7 0 0 1-7 7H7l-4 3V8a7 7 0 0 1 7-7h3a7 7 0 0 1 7 7z"/><path d="M8 9h8M8 13h5"/></svg></span>
                            <strong>관리자 답변</strong>
                            <% if (answered) { %><span class="my-inquiry-reply-date"><%=esc(replyAt)%></span><% } %>
                        </div>
                        <% if (answered) { %>
                            <div class="my-inquiry-message-body"><%=esc(selected.getAnswer())%></div>
                        <% } else { %>
                            <div class="my-inquiry-awaiting">
                                <strong><%= "ANSWERING".equals(selected.getStatus()) ? "답변을 작성하고 있어요." : "답변을 기다리고 있어요."%></strong>
                                <p>관리자가 답변을 등록하면 이곳에서 바로 확인할 수 있습니다.</p>
                            </div>
                        <% } %>
                    </div>
                    <div class="my-inquiry-detail-bottom">
                        <a href="<%=ctx%>/support/inquiry" class="my-inquiry-bottom-link">다른 문의 작성하기
                            <svg viewBox="0 0 24 24" aria-hidden="true"><path d="m9 18 6-6-6-6"/></svg>
                        </a>
                    </div>
                </section>
                <% } %>
            </div>
        </main>
    </div>
</div>
<jsp:include page="/common/footer.jsp" />
</body>
</html>
