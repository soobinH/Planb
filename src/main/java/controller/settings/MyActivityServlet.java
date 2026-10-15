package controller.settings;

import java.io.IOException;
import java.util.Map;
import java.util.HashMap;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import dto.member.UserDto;
import service.profile.ProfileActivityService;
import service.profile.ProfileActivityServiceImpl;

/** 로그인한 회원의 활동 목록: 처음 10건과 다음 10건 조회. */
@WebServlet({"/settings/myActivity", "/settings/myActivity/more"})
public class MyActivityServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final ProfileActivityService activityService = new ProfileActivityServiceImpl();
    private final Gson gson = new GsonBuilder().setDateFormat("yyyy-MM-dd HH:mm:ss.SSS").create();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        boolean more = request.getServletPath().endsWith("/more");
        response.setHeader("Cache-Control", "no-store");
        HttpSession session = request.getSession(false);
        UserDto loginUser = session == null ? null : (UserDto) session.getAttribute("user");
        if (loginUser == null) {
            if (more) writeError(response, 401, "로그인 후 이용할 수 있습니다.");
            else response.sendRedirect(request.getContextPath() + "/auth/login");
            return;
        }
        try {
            Map<String, Object> page = activityService.getProfileActivityPage(loginUser.getUserId(),
                    more ? request.getParameter("filter") : "ALL",
                    more ? request.getParameter("cursor") : null);
            if (more) {
                response.setContentType("application/json; charset=UTF-8");
                response.getWriter().write(gson.toJson(page));
                return;
            }
            for (Map.Entry<String, Object> entry : page.entrySet()) {
                request.setAttribute(entry.getKey(), entry.getValue());
            }
            request.setAttribute("activePage", "profile");
            request.setAttribute("settingsPage", "activity");
            request.getRequestDispatcher("/view/settings/myActivity.jsp").forward(request, response);
        } catch (Exception e) {
            getServletContext().log("내 활동 내역 조회 실패", e);
            if (more) writeError(response, e instanceof IllegalArgumentException ? 400 : 500,
                    "내 활동 내역을 불러오지 못했습니다.");
            else throw new ServletException("내 활동 내역을 불러오지 못했습니다.", e);
        }
    }

    private void writeError(HttpServletResponse response, int status, String message) throws IOException {
        response.setStatus(status);
        response.setContentType("application/json; charset=UTF-8");
        Map<String, Object> result = new HashMap<>();
        result.put("success", false);
        result.put("message", message);
        response.getWriter().write(gson.toJson(result));
    }
}
