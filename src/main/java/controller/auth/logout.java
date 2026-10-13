package controller.auth;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import dto.member.UserDto;
import service.notification.NotificationDeviceService;
import service.notification.NotificationDeviceServiceImpl;

/**
 * Servlet implementation class logout
 */
@WebServlet("/auth/logout")
public class logout extends HttpServlet {
	private static final long serialVersionUID = 1L;

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public logout() {
		super();
		// TODO Auto-generated constructor stub
	}

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		HttpSession session = request.getSession(false);

		if (session != null) {
			try {
				Object userObject = session.getAttribute("user");

				Object installationObject = session.getAttribute("firebaseInstallationId");

				if (userObject instanceof UserDto && installationObject instanceof String) {

					UserDto loginUser = (UserDto) userObject;

					String installationId = (String) installationObject;

					if (!installationId.trim().isEmpty()) {
						NotificationDeviceService service = new NotificationDeviceServiceImpl();

						service.removeDevice(Long.valueOf(loginUser.getUserId()), installationId);
					}
				}

			} catch (Exception e) {
				getServletContext().log("로그아웃 중 Firebase 등록 연결 해제 실패", e);

			} finally {
				// 연결 해제 중 오류가 발생해도 로그아웃은 실행
				session.invalidate();
			}
		}

		response.sendRedirect(request.getContextPath() + "/home");
	}

}
