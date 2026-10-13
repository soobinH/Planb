package controller.notification;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import dto.member.UserDto;
import service.notification.NotificationService;
import service.notification.NotificationServiceImpl;
import util.JsonResponse;

/**
 * Servlet implementation class NotificationController
 */
@WebServlet(urlPatterns = { "/notifications", "/notifications/header", "/notifications/more", "/notifications/read",
		"/notifications/read-all" })
public class NotificationController extends HttpServlet {
	private static final long serialVersionUID = 1L;

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public NotificationController() {
		super();
		// TODO Auto-generated constructor stub
	}

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		response.setHeader("Cache-Control", "no-store");
		String path = request.getServletPath();
		UserDto loginUser = getLoginUser(request);

		// 전체 알림 페이지
		if ("/notifications".equals(path)) {
			if (loginUser == null) {
				response.sendRedirect(request.getContextPath() + "/auth/login");
				return;
			}

			try {
				NotificationService service = new NotificationServiceImpl();

				Map<String, Object> page = service.getUnreadNotificationPage(Long.valueOf(loginUser.getUserId()), null);

				request.setAttribute("notifications", page.get("notifications"));
				request.setAttribute("unreadCount", page.get("unreadCount"));
				request.setAttribute("hasMore", page.get("hasMore"));
				request.setAttribute("nextCursor", page.get("nextCursor"));

				request.getRequestDispatcher("/view/notification/notifications.jsp").forward(request, response);

			} catch (Exception e) {
				getServletContext().log("알림 목록 조회 중 오류 발생", e);
				if ("/notifications/more".equals(path)) {
					if (loginUser == null) {
						JsonResponse.writeFailure(response, HttpServletResponse.SC_UNAUTHORIZED, "로그인이 필요합니다.");
						return;
					}

					Long beforeNotificationId = parsePositiveLong(request.getParameter("beforeNotificationId"));

					if (beforeNotificationId == null) {
						JsonResponse.writeFailure(response, HttpServletResponse.SC_BAD_REQUEST,
								"더보기 기준 알림 번호가 올바르지 않습니다.");
						return;
					}

					try {
						NotificationService service = new NotificationServiceImpl();

						Map<String, Object> result = service
								.getUnreadNotificationPage(Long.valueOf(loginUser.getUserId()), beforeNotificationId);

						result.put("success", true);
						JsonResponse.writeJson(response, result);

					} catch (IllegalArgumentException e1) {
						JsonResponse.writeFailure(response, HttpServletResponse.SC_BAD_REQUEST, e1.getMessage());

					} catch (Exception e1) {
						getServletContext().log("추가 알림 조회 중 오류 발생", e1);

						JsonResponse.writeFailure(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
								"추가 알림을 불러오지 못했습니다.");
					}

					return;
				}
				response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
			}

			return;
		}

		// 헤더 드롭다운 데이터
		if ("/notifications/header".equals(path)) {
			if (loginUser == null) {
				JsonResponse.writeFailure(response, HttpServletResponse.SC_UNAUTHORIZED, "로그인이 필요합니다.");
				return;
			}

			try {
				NotificationService service = new NotificationServiceImpl();

				Map<String, Object> result = service.getHeaderNotifications(Long.valueOf(loginUser.getUserId()));

				result.put("success", true);
				JsonResponse.writeJson(response, result);

			} catch (Exception e) {
				getServletContext().log("헤더 알림 조회 중 오류 발생", e);
				JsonResponse.writeFailure(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "알림을 불러오지 못했습니다.");
			}

			return;
		}

		response.sendError(HttpServletResponse.SC_NOT_FOUND);
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		request.setCharacterEncoding("UTF-8");

		UserDto loginUser = getLoginUser(request);

		if (loginUser == null) {
			JsonResponse.writeFailure(response, HttpServletResponse.SC_UNAUTHORIZED, "로그인이 필요합니다.");
			return;
		}

		String path = request.getServletPath();
		NotificationService service = new NotificationServiceImpl();

		try {
			Long loginUserId = Long.valueOf(loginUser.getUserId());

			// 알림 하나 읽음 처리
			if ("/notifications/read".equals(path)) {
				Long notificationId = parsePositiveLong(request.getParameter("notificationId"));

				if (notificationId == null) {
					JsonResponse.writeFailure(response, HttpServletResponse.SC_BAD_REQUEST, "올바른 알림 번호가 아닙니다.");
					return;
				}

				boolean marked = service.markAsRead(notificationId, loginUserId);

				if (!marked) {
					JsonResponse.writeFailure(response, HttpServletResponse.SC_NOT_FOUND, "알림을 찾을 수 없습니다.");
					return;
				}

				// 읽음 처리 후 다음 미읽음 알림까지 다시 조회
				Map<String, Object> result = service.getHeaderNotifications(loginUserId);

				result.put("success", true);
				JsonResponse.writeJson(response, result);
				return;
			}

			// 읽지 않은 알림 전체 읽음 처리
			if ("/notifications/read-all".equals(path)) {
				int updatedCount = service.markAllAsRead(loginUserId);

				Map<String, Object> result = service.getUnreadNotificationPage(loginUserId, null);

				result.put("success", true);
				result.put("updatedCount", updatedCount);

				JsonResponse.writeJson(response, result);
				return;
			}

			response.sendError(HttpServletResponse.SC_NOT_FOUND);

		} catch (Exception e) {
			getServletContext().log("알림 읽음 처리 중 오류 발생", e);
			JsonResponse.writeFailure(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "알림 처리 중 오류가 발생했습니다.");
		}
	}

	private UserDto getLoginUser(HttpServletRequest request) {
		HttpSession session = request.getSession(false);

		if (session == null) {
			return null;
		}

		Object userObject = session.getAttribute("user");

		if (!(userObject instanceof UserDto)) {
			return null;
		}

		return (UserDto) userObject;
	}

	private Long parsePositiveLong(String value) {
		if (value == null || value.trim().isEmpty()) {
			return null;
		}

		try {
			long parsed = Long.parseLong(value.trim());
			return parsed > 0 ? Long.valueOf(parsed) : null;
		} catch (NumberFormatException e) {
			return null;
		}
	}
}
