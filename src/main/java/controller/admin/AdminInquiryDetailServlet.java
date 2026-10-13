package controller.admin;

import java.io.IOException;
import java.util.UUID;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import dto.member.UserDto;
import dto.support.SupportInquiryDto;
import service.support.*;

@WebServlet("/admin/support/inquiry")
public class AdminInquiryDetailServlet extends HttpServlet {
    private final SupportInquiryService service = new SupportInquiryServiceImpl();
    @Override protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        UserDto admin = InquiryAdminAccess.requireAdmin(request);
        if (admin == null) { response.sendError(403); return; }
        try {
            long id = Long.parseLong(request.getParameter("id"));
            SupportInquiryDto item = service.getInquiry(id);
            if (item == null) { response.sendError(404); return; }
            String csrf = UUID.randomUUID().toString();
            request.getSession().setAttribute("adminInquiryCsrf", csrf);
            request.setAttribute("csrf", csrf);
            request.setAttribute("inquiry", item);
            request.getRequestDispatcher("/view/admin/inquiryDetail.jsp").forward(request, response);
        } catch (NumberFormatException e) { response.sendError(400); }
        catch (Exception e) { throw new ServletException(e); }
    }
    @Override protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        UserDto admin = InquiryAdminAccess.requireAdmin(request);
        if (admin == null) { response.sendError(403); return; }
        HttpSession session = request.getSession(false);
        String actual = request.getParameter("csrf");
        String expected = session == null ? null : (String)session.getAttribute("adminInquiryCsrf");
        if (expected == null || !expected.equals(actual)) { response.sendError(403, "잘못된 요청입니다."); return; }
        session.removeAttribute("adminInquiryCsrf");
        try {
            long id = Long.parseLong(request.getParameter("id"));
            if (!service.answerInquiry(id, admin.getUserId(), request.getParameter("answer"))) {
                response.sendError(409, "존재하지 않거나 이미 답변된 문의입니다."); return;
            }
            response.sendRedirect(request.getContextPath() + "/admin/support/inquiry?id=" + id + "&saved=1");
        } catch (IllegalArgumentException e) { response.sendError(400, e.getMessage()); }
        catch (Exception e) { throw new ServletException(e); }
    }
}
