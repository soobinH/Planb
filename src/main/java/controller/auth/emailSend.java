package controller.auth;

import java.io.IOException;
import java.security.SecureRandom;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import dto.member.UserDto;
import service.email.EmailService;
import service.member.UserService;
import service.member.UserServiceImpl;

/**
 * 이메일 인증번호 발송
 *
 * 회원가입: /auth/emailSend
 *
 * 회원탈퇴: /auth/emailSend purpose=withdraw
 *
 * 비밀번호 찾기: /auth/emailSend purpose=findPassword
 */
@WebServlet("/auth/emailSend")
public class emailSend extends HttpServlet {

	private static final long serialVersionUID = 1L;

	private UserService userService = new UserServiceImpl();

	private EmailService emailService = new EmailService();

	private SecureRandom random = new SecureRandom();

	public emailSend() {

		super();

	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		request.setCharacterEncoding("UTF-8");

		response.setContentType("application/json; charset=UTF-8");

		String email = request.getParameter("email");

		String purpose = request.getParameter("purpose");

		boolean withdrawMode = "withdraw".equals(purpose);

		boolean findPasswordMode = "findPassword".equals(purpose);

		/*
		 * ===================================================== 이메일 입력 확인
		 * ======================================================
		 */

		if (email == null || email.trim().isEmpty()) {

			sendJson(response, false, "이메일을 입력해주세요.");

			return;
		}

		email = email.trim().toLowerCase();

		/*
		 * ===================================================== 이메일 형식 확인
		 * ======================================================
		 */

		if (!email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$")) {

			sendJson(response, false, "올바른 이메일 형식이 아닙니다.");

			return;
		}

		try {

			HttpSession session;

			/*
			 * ================================================= 회원 탈퇴 인증
			 * ==================================================
			 */

			if (withdrawMode) {

				session = request.getSession(false);

				if (session == null) {

					sendJson(response, false, "로그인이 필요합니다.");

					return;
				}

				UserDto user = (UserDto) session.getAttribute("user");

				if (user == null) {

					sendJson(response, false, "로그인이 필요합니다.");

					return;
				}

				String userEmail = user.getEmail();

				if (userEmail == null || userEmail.trim().isEmpty()) {

					sendJson(response, false, "회원 이메일 정보를 확인할 수 없습니다.");

					return;
				}

				/*
				 * 로그인한 회원의 이메일과 인증 요청 이메일 비교
				 */
				if (!userEmail.trim().equalsIgnoreCase(email)) {

					sendJson(response, false, "현재 로그인한 계정의 이메일과 일치하지 않습니다.");

					return;
				}

			} else if (findPasswordMode) {

				/*
				 * ============================================= 비밀번호 찾기 인증
				 *
				 * 가입된 이메일로만 인증번호 전송
				 * ==============================================
				 */

				if (userService.isEmailAvailable(email)) {

					sendJson(response, false, "가입된 이메일이 아닙니다.");

					return;
				}

				session = request.getSession();

			} else {

				/*
				 * ============================================= 회원가입 인증
				 * 
				 * 회원가입에서는 이미 사용 중인 이메일이면 인증번호 전송 불가
				 * ==============================================
				 */

				if (!userService.isEmailAvailable(email)) {

					sendJson(response, false, "이미 가입된 이메일입니다.");

					return;
				}

				session = request.getSession();
			}

			long now = System.currentTimeMillis();

			/*
			 * ================================================= 탈퇴 / 회원가입 세션 KEY 분리
			 * ==================================================
			 */

			String sentAtKey;

			String emailKey;

			String codeKey;

			String expiresKey;

			String failCountKey;

			if (withdrawMode) {

				sentAtKey = "withdrawEmailVerificationSentAt";

				emailKey = "withdrawEmailVerificationEmail";

				codeKey = "withdrawEmailVerificationCode";

				expiresKey = "withdrawEmailVerificationExpiresAt";

				failCountKey = "withdrawEmailVerificationFailCount";

			} else if (findPasswordMode) {

				sentAtKey = "findPwEmailVerificationSentAt";

				emailKey = "findPwEmailVerificationEmail";

				codeKey = "findPwEmailVerificationCode";

				expiresKey = "findPwEmailVerificationExpiresAt";

				failCountKey = "findPwEmailVerificationFailCount";

			} else {

				sentAtKey = "emailVerificationSentAt";

				emailKey = "emailVerificationEmail";

				codeKey = "emailVerificationCode";

				expiresKey = "emailVerificationExpiresAt";

				failCountKey = "emailVerificationFailCount";
			}

			/*
			 * ================================================= 연속 전송 방지
			 * ==================================================
			 */

			Long lastSentAt = (Long) session.getAttribute(sentAtKey);

			if (lastSentAt != null && now - lastSentAt < 60000) {

				sendJson(response, false, "인증번호는 1분 후 다시 요청할 수 있습니다.");

				return;
			}

			/*
			 * ================================================= 인증번호 생성
			 * ==================================================
			 */

			String code = String.format("%06d", random.nextInt(1000000));

			/*
			 * ================================================= 이메일 전송
			 * ==================================================
			 */

			emailService.sendVerificationCode(email, code);

			/*
			 * ================================================= 인증정보 세션 저장
			 * ==================================================
			 */

			session.setAttribute(emailKey, email);

			session.setAttribute(codeKey, code);

			/*
			 * 인증번호 유효시간 5분
			 */
			session.setAttribute(expiresKey, now + (5 * 60 * 1000));

			session.setAttribute(sentAtKey, now);

			session.setAttribute(failCountKey, 0);

			/*
			 * ================================================= 인증 완료 상태 초기화
			 * ==================================================
			 */

			if (withdrawMode) {

				session.setAttribute("withdrawEmailVerified", false);

				session.removeAttribute("withdrawVerifiedEmail");

			} else if (findPasswordMode) {

				session.setAttribute("findPwEmailVerified", false);

				session.removeAttribute("findPwVerifiedEmail");

			} else {

				session.setAttribute("emailVerified", false);

				session.removeAttribute("verifiedEmail");
			}

			sendJson(response, true, "인증번호를 발송했습니다. 이메일을 확인해주세요.");

		} catch (Exception e) {

			e.printStackTrace();

			response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);

			sendJson(response, false, "인증번호 발송 중 오류가 발생했습니다.");
		}
	}

	private void sendJson(HttpServletResponse response, boolean success, String message) throws IOException {

		response.getWriter().print(

				"{" + "\"success\":" + success + "," + "\"message\":\"" + message + "\"" + "}"

		);
	}
}