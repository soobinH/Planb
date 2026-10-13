package controller.report;

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
import service.report.ReportService;
import service.report.ReportServiceImpl;
import util.JsonResponse;

@WebServlet("/mate/report")
public class MateReport extends HttpServlet {
	private static final long serialVersionUID = 1L;

	public MateReport() {
		super();
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		request.setCharacterEncoding("UTF-8");

		HttpSession session = request.getSession(false);
		UserDto loginUser = session == null ? null : (UserDto) session.getAttribute("user");

		if (loginUser == null || loginUser.getUserId() <= 0) {
			JsonResponse.writeFailure(response, HttpServletResponse.SC_UNAUTHORIZED, "로그인 후 이용할 수 있습니다.");
			return;
		}

		try {
			long mateId = readPositiveId(request.getParameter("mateId"), "여행메이트 번호");
			long reasonValue = readPositiveId(request.getParameter("reasonId"), "신고 사유");

			if (reasonValue > Short.MAX_VALUE) {
				throw new IllegalArgumentException("올바른 신고 사유가 아닙니다.");
			}

			int reasonId = (int) reasonValue;
			String detail = request.getParameter("detail");

			ReportService service = new ReportServiceImpl();

			long reportId = service.submitMateReport(mateId, loginUser.getUserId(), reasonId, detail);

			Map<String, Object> result = new HashMap<>();

			result.put("success", true);
			result.put("reportId", reportId);
			result.put("message", "신고가 접수되었습니다.");

			JsonResponse.writeJson(response, result);

		} catch (SecurityException e) {
			JsonResponse.writeFailure(response, HttpServletResponse.SC_FORBIDDEN, e.getMessage());

		} catch (IllegalArgumentException e) {
			JsonResponse.writeFailure(response, HttpServletResponse.SC_BAD_REQUEST, e.getMessage());

		} catch (Exception e) {
			getServletContext().log("여행메이트 신고 접수 중 오류 발생", e);
			JsonResponse.writeFailure(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "신고 접수 중 오류가 발생했습니다.");
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