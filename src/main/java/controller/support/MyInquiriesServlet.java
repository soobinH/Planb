package controller.support;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import dto.member.UserDto;
import dto.support.SupportInquiryDto;
import service.support.SupportInquiryService;
import service.support.SupportInquiryServiceImpl;

@WebServlet("/support/myInquiries")
public class MyInquiriesServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final SupportInquiryService service = new SupportInquiryServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        UserDto user = session == null ? null : (UserDto) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return;
        }
        try {
            long userId = user.getUserId(); // 요청 파라미터로 userId를 받지 않는다.
            List<SupportInquiryDto> items = service.getMyInquiries(userId);
            SupportInquiryDto selected = null;
            String idParam = request.getParameter("id");
            if (idParam != null && !idParam.trim().isEmpty()) {
                long inquiryId = Long.parseLong(idParam.trim());
                if (inquiryId <= 0) {
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST, "잘못된 문의 번호입니다.");
                    return;
                }
                selected = service.getMyInquiry(userId, inquiryId);
                if (selected == null) {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND, "문의 내역이 없습니다.");
                    return;
                }
            } else if (!items.isEmpty()) {
                selected = items.get(0);
            }
            request.setAttribute("myInquiries", items);
            request.setAttribute("selectedInquiry", selected);
            request.getRequestDispatcher("/view/support/myInquiries.jsp").forward(request, response);
        } catch (NumberFormatException ex) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "잘못된 문의 번호입니다.");
        } catch (Exception ex) {
            getServletContext().log("내 문의 내역 조회 오류", ex);
            throw new ServletException("내 문의 내역 조회 중 오류가 발생했습니다.", ex);
        }
    }
}
