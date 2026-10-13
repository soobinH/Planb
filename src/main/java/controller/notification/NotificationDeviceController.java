package controller.notification;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import dto.member.UserDto;
import service.notification.NotificationDeviceService;
import service.notification.NotificationDeviceServiceImpl;
import util.JsonResponse;

/**
 * Servlet implementation class NotificationDeviceController
 */
@WebServlet({ "/notifications/device/register", "/notifications/device/remove" })
public class NotificationDeviceController extends HttpServlet {
	private static final long serialVersionUID = 1L;

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public NotificationDeviceController() {
		super();
		// TODO Auto-generated constructor stub
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		request.setCharacterEncoding("UTF-8");
		response.setHeader("Cache-Control", "no-store");

		HttpSession session = request.getSession(false);

		Object userObject = session == null ? null : session.getAttribute("user");

		if (!(userObject instanceof UserDto)) {
			JsonResponse.writeFailure(response, HttpServletResponse.SC_UNAUTHORIZED, "로그인이 필요합니다.");
			return;
		}

		UserDto loginUser = (UserDto) userObject;

		String path = request.getServletPath();
		String installationId = request.getParameter("installationId");

		NotificationDeviceService service = new NotificationDeviceServiceImpl();

		try {
			Long userId = Long.valueOf(loginUser.getUserId());

			if ("/notifications/device/register".equals(path)) {
				service.registerDevice(userId, installationId);

				// 로그아웃 시 연결을 해제하기 위해 세션에도 보관
				session.setAttribute("firebaseInstallationId", installationId.trim());

			} else if ("/notifications/device/remove".equals(path)) {
				service.removeDevice(userId, installationId);

				Object savedId = session.getAttribute("firebaseInstallationId");

				if (installationId.trim().equals(savedId)) {
					session.removeAttribute("firebaseInstallationId");
				}

			} else {
				JsonResponse.writeFailure(response, HttpServletResponse.SC_NOT_FOUND, "존재하지 않는 요청입니다.");
				return;
			}

			Map<String, Object> result = new HashMap<>();
			result.put("success", true);

			JsonResponse.writeJson(response, result);

		} catch (SecurityException e) {
			JsonResponse.writeFailure(response, HttpServletResponse.SC_UNAUTHORIZED, e.getMessage());

		} catch (IllegalArgumentException e) {
			JsonResponse.writeFailure(response, HttpServletResponse.SC_BAD_REQUEST, e.getMessage());

		} catch (Exception e) {
			getServletContext().log("Firebase 등록 정보 처리 실패", e);

			JsonResponse.writeFailure(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
					"실시간 알림 등록 정보를 저장하지 못했습니다.");
		}
	}

}
