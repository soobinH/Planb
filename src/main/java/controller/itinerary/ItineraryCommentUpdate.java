package controller.itinerary;

import java.io.IOException;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import dto.member.UserDto;
import service.itinerary.ItineraryService;
import service.itinerary.ItineraryServiceImpl;
import util.JsonResponse;

/**
 * Servlet implementation class ItineraryCommentUpdate
 */
@WebServlet("/itinerary/comment/update")
public class ItineraryCommentUpdate extends HttpServlet {
	private static final long serialVersionUID = 1L;

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public ItineraryCommentUpdate() {
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

		UserDto loginUser = session == null ? null : (UserDto) session.getAttribute("user");

		if (loginUser == null || loginUser.getUserId() <= 0) {

			JsonResponse.writeFailure(response, HttpServletResponse.SC_UNAUTHORIZED, "로그인 후 이용할 수 있습니다.");

			return;
		}

		try {
			long itineraryId = readPositiveId(request.getParameter("itineraryId"), "일정 번호");

			long commentId = readPositiveId(request.getParameter("commentId"), "댓글 번호");

			String content = request.getParameter("content");

			ItineraryService service = new ItineraryServiceImpl();

			Map<String, Object> result = service.updateItineraryComment(itineraryId, commentId, loginUser.getUserId(),
					content);

			result.put("success", true);

			JsonResponse.writeJson(response, result);

		} catch (SecurityException e) {

			JsonResponse.writeFailure(response, HttpServletResponse.SC_FORBIDDEN, e.getMessage());

		} catch (IllegalArgumentException e) {

			JsonResponse.writeFailure(response, HttpServletResponse.SC_BAD_REQUEST, e.getMessage());

		} catch (Exception e) {

			getServletContext().log("댓글 수정 중 오류 발생", e);

			JsonResponse.writeFailure(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "댓글 수정 중 오류가 발생했습니다.");
		}
	}

	private long readPositiveId(String value, String name) {

		if (value == null || value.trim().isEmpty()) {
			throw new IllegalArgumentException(name + "를 확인해주세요.");
		}

		try {
			long id = Long.parseLong(value.trim());

			if (id <= 0) {
				throw new IllegalArgumentException(name + "는 양수여야 합니다.");
			}

			return id;

		} catch (NumberFormatException e) {
			throw new IllegalArgumentException("올바른 " + name + "가 아닙니다.");
		}
	}

}
