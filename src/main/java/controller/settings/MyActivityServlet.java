package controller.settings;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import dto.member.UserDto;
import dto.profile.ProfileActivityDto;
import service.profile.ProfileActivityService;
import service.profile.ProfileActivityServiceImpl;

/** 회원 본인 활동 내역 조회 (게시글/댓글). */
@WebServlet("/settings/myActivity")
public class MyActivityServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private final ProfileActivityService activityService = new ProfileActivityServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        UserDto loginUser = session == null ? null : (UserDto) session.getAttribute("user");
        if (loginUser == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return;
        }

        try {
            // URL의 userId가 아닌 로그인 세션의 userId만 사용한다.
            List<ProfileActivityDto> activities =
                    activityService.getProfileActivities(loginUser.getUserId());
            if (activities == null) {
                activities = new ArrayList<ProfileActivityDto>();
            }

            request.setAttribute("activities", activities);
            request.setAttribute("activePage", "profile");
            request.setAttribute("settingsPage", "activity");
            request.getRequestDispatcher("/view/settings/myActivity.jsp")
                    .forward(request, response);
        } catch (Exception e) {
            getServletContext().log("내 활동 내역 조회 실패", e);
            throw new ServletException("내 활동 내역을 불러오지 못했습니다.", e);
        }
    }
}
