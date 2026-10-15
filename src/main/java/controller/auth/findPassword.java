package controller.auth;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import service.member.UserService;
import service.member.UserServiceImpl;

/**
 * Servlet implementation class findPassword
 */
@WebServlet("/auth/findPassword")
public class findPassword extends HttpServlet {
	private static final long serialVersionUID = 1L;

	private UserService service = new UserServiceImpl();

	public findPassword() {
		super();
		// TODO Auto-generated constructor stub
	}
	
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		request.getRequestDispatcher("/view/auth/findPassword.jsp").forward(request, response);
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		String loginId = request.getParameter("loginId");
		String name = request.getParameter("name");
		String email = request.getParameter("email");
		String phone = request.getParameter("phone");

		try {

			HttpSession session = request.getSession();

			/*
			 * 이메일 인증 확인
			 * 비밀번호 찾기 화면에서 인증을 마친 이메일과 입력한 이메일이 같아야 진행
			 */
			Boolean emailVerified = (Boolean) session.getAttribute("findPwEmailVerified");

			String verifiedEmail = (String) session.getAttribute("findPwVerifiedEmail");

			if (!Boolean.TRUE.equals(emailVerified) || verifiedEmail == null || email == null
					|| !verifiedEmail.equalsIgnoreCase(email.trim())) {

				throw new Exception("이메일 인증을 완료해주세요.");
			}

			Long userId = service.findPasswordUser(loginId, name, email, phone);

			/*
			 * 사용한 이메일 인증 정보 제거
			 */
			session.removeAttribute("findPwEmailVerified");

			session.removeAttribute("findPwVerifiedEmail");

			session.removeAttribute("findPwEmailVerificationEmail");

			session.removeAttribute("findPwEmailVerificationSentAt");

			/*
			 * URL이나 hidden input에 userId를 넣지 않고 세션에 저장
			 */
			session.setAttribute("passwordResetUserId", userId);

			response.sendRedirect(request.getContextPath() + "/view/auth/resetPassword.jsp");

		} catch (Exception e) {

			request.setAttribute("errorMessage", e.getMessage());

			request.getRequestDispatcher("/view/auth/findPassword.jsp").forward(request, response);

		}

	}

}
