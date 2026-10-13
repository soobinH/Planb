package controller.admin;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import dto.member.UserDto;
import dto.support.SupportInquiryDto;
import service.support.SupportInquiryService;
import service.support.SupportInquiryServiceImpl;

/** 관리자 문의 목록 및 상태별 통계를 제공한다. */
@WebServlet("/admin/support/inquiries")
public class AdminInquiryListServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final SupportInquiryService service = new SupportInquiryServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        UserDto admin = InquiryAdminAccess.requireAdmin(request);
        if (admin == null) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "관리자 권한이 필요합니다.");
            return;
        }

        String filter = request.getParameter("status");
        if (filter == null || filter.trim().isEmpty()) {
            filter = "RECEIVED"; // 신고 관리와 동일하게 미처리 목록부터 표시
        } else {
            filter = filter.trim().toUpperCase(java.util.Locale.ROOT);
        }
        if (!"ALL".equals(filter) && !"RECEIVED".equals(filter)
                && !"ANSWERING".equals(filter) && !"DONE".equals(filter)) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "잘못된 문의 상태입니다.");
            return;
        }

        try {
            // 목록/건수 계산을 하나의 조회 결과로 처리한다.
            List<SupportInquiryDto> all = service.getInquiries(null);
            List<SupportInquiryDto> shown = new ArrayList<SupportInquiryDto>();
            int received = 0;
            int answering = 0;
            int done = 0;
            for (SupportInquiryDto item : all) {
                String status = item.getStatus();
                if ("RECEIVED".equals(status)) received++;
                else if ("ANSWERING".equals(status)) answering++;
                else if ("DONE".equals(status)) done++;
                if ("ALL".equals(filter) || filter.equals(status)) {
                    shown.add(item);
                }
            }
            request.setAttribute("inquiries", shown);
            request.setAttribute("filterStatus", filter);
            request.setAttribute("receivedCount", received);
            request.setAttribute("answeringCount", answering);
            request.setAttribute("doneCount", done);
            request.setAttribute("totalCount", all.size());
            request.getRequestDispatcher("/view/admin/inquiryList.jsp")
                    .forward(request, response);
        } catch (Exception e) {
            getServletContext().log("관리자 문의 목록 조회 실패", e);
            throw new ServletException("문의 목록 조회 중 오류가 발생했습니다.", e);
        }
    }
}
