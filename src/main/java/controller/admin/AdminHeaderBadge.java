package controller.admin;

import java.io.IOException;

import org.apache.ibatis.session.SqlSession;

import config.MybatisSqlSessionFactory;
import dto.member.UserDto;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/admin/header-badges")
public class AdminHeaderBadge extends HttpServlet {

	private static final long serialVersionUID = 1L;

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		/*
		 * ========================================= 관리자 확인
		 * =========================================
		 */

		HttpSession session = request.getSession(false);

		if (session == null) {

			response.sendError(HttpServletResponse.SC_UNAUTHORIZED);

			return;
		}

		UserDto user = (UserDto) session.getAttribute("user");

		if (user == null || user.getRole() == null || !"ADMIN".equalsIgnoreCase(user.getRole())) {

			response.sendError(HttpServletResponse.SC_FORBIDDEN);

			return;
		}

		/*
		 * ========================================= DB 조회
		 * =========================================
		 */

		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {

			Integer reportPendingCount = sqlSession.selectOne("mapper.itinerary.report.countPendingReports");

			Integer adPendingCount = sqlSession.selectOne("mapper.advertisement.admin.countPendingAds");

			if (reportPendingCount == null) {

				reportPendingCount = 0;
			}

			if (adPendingCount == null) {

				adPendingCount = 0;
			}

			/*
			 * ========================================= JSON 응답
			 * =========================================
			 */

			response.setCharacterEncoding("UTF-8");

			response.setContentType("application/json;charset=UTF-8");

			response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate");

			String json = "{" + "\"reportPendingCount\":" + reportPendingCount + "," + "\"adPendingCount\":"
					+ adPendingCount + "}";

			response.getWriter().write(json);

		} catch (Exception e) {

			e.printStackTrace();

			response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
		}
	}
}