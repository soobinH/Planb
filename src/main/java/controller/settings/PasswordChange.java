package controller.settings;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import dto.member.UserDto;
import service.member.UserService;
import service.member.UserServiceImpl;

/*
 * 비밀번호 변경 (2단계)
 *
 * 1단계 (step=verify) : 현재 비밀번호 확인
 *   - 확인되면 세션에 확인 시각을 저장하고 2단계 화면으로 이동
 *
 * 2단계 (step=change) : 새 비밀번호 설정
 *   - 1단계 확인 후 VERIFY_VALID_MILLIS 이내에만 변경 가능
 */
@WebServlet("/settings/passwordChange")
public class PasswordChange extends HttpServlet {

	private static final long serialVersionUID = 1L;

	/* 현재 비밀번호 확인 결과를 저장하는 세션 키 */
	private static final String VERIFIED_AT = "passwordVerifiedAt";

	/* 현재 비밀번호 확인 후 변경 가능한 시간 (10분) */
	private static final long VERIFY_VALID_MILLIS = 10 * 60 * 1000L;

	private static final String VIEW = "/view/settings/passwordChange.jsp";

	private UserService service = new UserServiceImpl();

	public PasswordChange() {

		super();

	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);

		/*
		 * 2단계 화면은 현재 비밀번호 확인을 마친 경우에만 보여줌
		 * 그 외(처음 진입, 시간 만료, 변경 완료 후)는 항상 1단계부터
		 */
		if ("change".equals(request.getParameter("step")) && isVerified(session)) {

			request.setAttribute("passwordStep", "change");

		} else {

			if (session != null) {
				session.removeAttribute(VERIFIED_AT);
			}

			request.setAttribute("passwordStep", "verify");
		}

		request.getRequestDispatcher(VIEW).forward(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		request.setCharacterEncoding("UTF-8");

		/*
		 * ===================================================== 로그인 확인
		 * ======================================================
		 */
		HttpSession session = request.getSession(false);

		if (session == null) {

			response.sendRedirect(request.getContextPath() + "/auth/login");

			return;
		}

		UserDto user = (UserDto) session.getAttribute("user");

		if (user == null) {

			response.sendRedirect(request.getContextPath() + "/auth/login");

			return;
		}

		boolean changeStep = "change".equals(request.getParameter("step"));

		try {

			/*
			 * ================================================= Google / Social 로그인 회원 차단
			 * ==================================================
			 */
			if (user.getProvider() != null && !"LOCAL".equalsIgnoreCase(user.getProvider())) {

				throw new Exception("소셜 로그인 계정은 비밀번호를 변경할 수 없습니다.");
			}

			if (changeStep) {

				changePassword(request, session, user);

				/* 변경 완료 → 확인 기록 삭제 후 1단계 화면에서 완료 안내 */
				session.removeAttribute(VERIFIED_AT);

				response.sendRedirect(request.getContextPath() + "/settings/passwordChange?success=true");

			} else {

				verifyCurrentPassword(request, session, user);

				response.sendRedirect(request.getContextPath() + "/settings/passwordChange?step=change");
			}

		} catch (Exception e) {

			e.printStackTrace();

			/*
			 * ================================================= 실패 메시지
			 *
			 * JSP에서 이 값이 있으면 자동으로 실패 모달이 열림
			 * ==================================================
			 */
			request.setAttribute("errorMessage", e.getMessage());

			request.setAttribute("errorTitle", changeStep ? "비밀번호 변경 실패" : "비밀번호 확인 실패");

			/* 2단계에서 실패했더라도 확인 시간이 남아 있으면 2단계 화면 유지 */
			request.setAttribute("passwordStep", changeStep && isVerified(session) ? "change" : "verify");

			request.getRequestDispatcher(VIEW).forward(request, response);
		}
	}

	/*
	 * ===================================================== 1단계 : 현재 비밀번호 확인
	 * ======================================================
	 */
	private void verifyCurrentPassword(HttpServletRequest request, HttpSession session, UserDto user)
			throws Exception {

		session.removeAttribute(VERIFIED_AT);

		String currentPassword = request.getParameter("currentPassword");

		if (currentPassword == null || currentPassword.isEmpty()) {

			throw new Exception("현재 비밀번호를 입력해주세요.");
		}

		if (!service.checkPassword(user.getUserId(), currentPassword)) {

			throw new Exception("현재 비밀번호가 올바르지 않습니다.");
		}

		session.setAttribute(VERIFIED_AT, System.currentTimeMillis());
	}

	/*
	 * ===================================================== 2단계 : 새 비밀번호 변경
	 * ======================================================
	 */
	private void changePassword(HttpServletRequest request, HttpSession session, UserDto user) throws Exception {

		if (!isVerified(session)) {

			throw new Exception("현재 비밀번호 확인 시간이 만료되었습니다. 다시 확인해주세요.");
		}

		String newPassword = request.getParameter("newPassword");

		String confirmPassword = request.getParameter("confirmPassword");

		if (newPassword == null || newPassword.isEmpty()) {

			throw new Exception("새 비밀번호를 입력해주세요.");
		}

		if (confirmPassword == null || confirmPassword.isEmpty()) {

			throw new Exception("새 비밀번호 확인을 입력해주세요.");
		}

		if (!newPassword.equals(confirmPassword)) {

			throw new Exception("새 비밀번호와 비밀번호 확인이 일치하지 않습니다.");
		}

		/*
		 * 비밀번호 규칙 : 영문 + 숫자 혼용 8자 이상 (특수문자는 선택)
		 */
		String passwordPattern = "^(?=.*[A-Za-z])" + "(?=.*\\d)" + ".{8,}$";

		if (!newPassword.matches(passwordPattern)) {

			throw new Exception("비밀번호는 영문과 숫자를 포함하여 8자 이상 입력해주세요.");
		}

		/* 현재 비밀번호와 같은지 확인 후 변경 */
		service.updatePassword(user.getUserId(), newPassword);
	}

	/* 현재 비밀번호 확인 후 유효 시간이 남아 있는지 */
	private boolean isVerified(HttpSession session) {

		if (session == null) {
			return false;
		}

		Object verifiedAt = session.getAttribute(VERIFIED_AT);

		return verifiedAt instanceof Long
				&& System.currentTimeMillis() - (Long) verifiedAt < VERIFY_VALID_MILLIS;
	}
}
