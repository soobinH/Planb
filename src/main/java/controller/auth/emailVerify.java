package controller.auth;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import dto.member.UserDto;

/**
 * 이메일 인증번호 확인
 */
@WebServlet("/auth/emailVerify")
public class emailVerify extends HttpServlet {

	private static final long serialVersionUID = 1L;

	public emailVerify() {

		super();

	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		request.setCharacterEncoding("UTF-8");

		response.setContentType("application/json; charset=UTF-8");

		String email = request.getParameter("email");

		String inputCode = request.getParameter("code");

		String purpose = request.getParameter("purpose");

		boolean withdrawMode = "withdraw".equals(purpose);

		boolean findPasswordMode = "findPassword".equals(purpose);

		/*
		 * ===================================================== 입력값 확인
		 * ======================================================
		 */

		if (email == null || email.trim().isEmpty() || inputCode == null || inputCode.trim().isEmpty()) {

			sendJson(response, false, "이메일과 인증번호를 확인해주세요.");

			return;
		}

		email = email.trim().toLowerCase();

		inputCode = inputCode.trim();

		HttpSession session = request.getSession(false);

		if (session == null) {

			sendJson(response, false, "인증정보가 없습니다. 인증번호를 다시 발급해주세요.");

			return;
		}

		/*
		 * ===================================================== 회원 탈퇴의 경우 현재 로그인 회원 확인
		 * ======================================================
		 */

		if (withdrawMode) {

			UserDto user = (UserDto) session.getAttribute("user");

			if (user == null) {

				sendJson(response, false, "로그인이 필요합니다.");

				return;
			}

			String userEmail = user.getEmail();

			if (userEmail == null || !userEmail.trim().equalsIgnoreCase(email)) {

				sendJson(response, false, "현재 로그인한 계정의 이메일과 일치하지 않습니다.");

				return;
			}
		}

		/*
		 * ===================================================== 인증 데이터 KEY 선택
		 * ======================================================
		 */

		String emailKey;

		String codeKey;

		String expiresKey;

		String failCountKey;

		if (withdrawMode) {

			emailKey = "withdrawEmailVerificationEmail";

			codeKey = "withdrawEmailVerificationCode";

			expiresKey = "withdrawEmailVerificationExpiresAt";

			failCountKey = "withdrawEmailVerificationFailCount";

		} else if (findPasswordMode) {

			emailKey = "findPwEmailVerificationEmail";

			codeKey = "findPwEmailVerificationCode";

			expiresKey = "findPwEmailVerificationExpiresAt";

			failCountKey = "findPwEmailVerificationFailCount";

		} else {

			emailKey = "emailVerificationEmail";

			codeKey = "emailVerificationCode";

			expiresKey = "emailVerificationExpiresAt";

			failCountKey = "emailVerificationFailCount";
		}

		String savedEmail = (String) session.getAttribute(emailKey);

		String savedCode = (String) session.getAttribute(codeKey);

		Long expiresAt = (Long) session.getAttribute(expiresKey);

		Integer failCount = (Integer) session.getAttribute(failCountKey);

		if (failCount == null) {

			failCount = 0;
		}

		/*
		 * ===================================================== 5회 실패 제한
		 * ======================================================
		 */

		if (failCount >= 5) {

			clearVerification(session, withdrawMode, findPasswordMode);

			sendJson(response, false, "인증번호 입력 횟수를 초과했습니다. 인증번호를 다시 발급해주세요.");

			return;
		}

		/*
		 * ===================================================== 인증 데이터 확인
		 * ======================================================
		 */

		if (savedEmail == null || savedCode == null || expiresAt == null) {

			sendJson(response, false, "인증번호를 먼저 발급해주세요.");

			return;
		}

		/*
		 * ===================================================== 발급 이메일과 일치 여부
		 * ======================================================
		 */

		if (!savedEmail.equalsIgnoreCase(email)) {

			sendJson(response, false, "인증번호를 발급받은 이메일과 일치하지 않습니다.");

			return;
		}

		/*
		 * ===================================================== 만료 확인
		 * ======================================================
		 */

		if (System.currentTimeMillis() > expiresAt) {

			clearVerification(session, withdrawMode, findPasswordMode);

			sendJson(response, false, "인증번호가 만료되었습니다. 다시 발급해주세요.");

			return;
		}

		/*
		 * ===================================================== 인증번호 불일치
		 * ======================================================
		 */

		if (!savedCode.equals(inputCode)) {

			failCount++;

			session.setAttribute(failCountKey, failCount);

			sendJson(response, false, "인증번호가 일치하지 않습니다.");

			return;
		}

		/*
		 * ===================================================== 인증 성공
		 * ======================================================
		 */

		if (withdrawMode) {

			/*
			 * 회원 탈퇴 전용 인증 완료
			 */
			session.setAttribute("withdrawEmailVerified", Boolean.TRUE);

			session.setAttribute("withdrawVerifiedEmail", email);

		} else if (findPasswordMode) {

			/*
			 * 비밀번호 찾기 전용 인증 완료
			 */
			session.setAttribute("findPwEmailVerified", Boolean.TRUE);

			session.setAttribute("findPwVerifiedEmail", email);

		} else {

			/*
			 * 회원가입용 기존 인증 완료
			 */
			session.setAttribute("emailVerified", Boolean.TRUE);

			session.setAttribute("verifiedEmail", email);
		}

		/*
		 * ===================================================== 사용한 인증번호 제거
		 * ======================================================
		 */

		session.removeAttribute(codeKey);

		session.removeAttribute(expiresKey);

		session.removeAttribute(failCountKey);

		sendJson(response, true, "이메일 인증이 완료되었습니다.");
	}

	private void clearVerification(HttpSession session, boolean withdrawMode, boolean findPasswordMode) {

		if (withdrawMode) {

			session.removeAttribute("withdrawEmailVerificationCode");

			session.removeAttribute("withdrawEmailVerificationExpiresAt");

			session.removeAttribute("withdrawEmailVerificationFailCount");

			session.setAttribute("withdrawEmailVerified", false);

			session.removeAttribute("withdrawVerifiedEmail");

		} else if (findPasswordMode) {

			session.removeAttribute("findPwEmailVerificationCode");

			session.removeAttribute("findPwEmailVerificationExpiresAt");

			session.removeAttribute("findPwEmailVerificationFailCount");

			session.setAttribute("findPwEmailVerified", false);

			session.removeAttribute("findPwVerifiedEmail");

		} else {

			session.removeAttribute("emailVerificationCode");

			session.removeAttribute("emailVerificationExpiresAt");

			session.removeAttribute("emailVerificationFailCount");

			session.setAttribute("emailVerified", false);

			session.removeAttribute("verifiedEmail");
		}
	}

	private void sendJson(HttpServletResponse response, boolean success, String message) throws IOException {

		response.getWriter().print(

				"{" + "\"success\":" + success + "," + "\"message\":\"" + message + "\"" + "}"

		);
	}
}