package controller.support;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import dto.member.UserDto;
import service.support.SupportInquiryService;
import service.support.SupportInquiryServiceImpl;

/**
 * Servlet implementation class inquiry
 */
@WebServlet("/support/inquiry")
public class SupportInquiry extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private final SupportInquiryService service = new SupportInquiryServiceImpl();

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public SupportInquiry() {
		super();
		// TODO Auto-generated constructor stub
	}
	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		request.getRequestDispatcher("/view/support/inquiry.jsp").forward(request, response);
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		HttpSession session = request.getSession(false);

		UserDto user = session == null ? null : (UserDto) session.getAttribute("user");

		/*
		 * ===================================== 로그인 확인
		 * ======================================
		 */

		if (user == null) {

			response.sendRedirect(request.getContextPath() + "/auth/login");

			return;
		}

		String category = request.getParameter("category");

		String email = request.getParameter("email");

		String title = request.getParameter("title");

		String content = request.getParameter("content");

		try {

			service.submitInquiry(user.getUserId(), category, email, title, content);

			/*
			 * ================================= POST 성공 후 Redirect
			 * 
			 * 새로고침 시 중복 제출 방지 ==================================
			 */

			response.sendRedirect(request.getContextPath() + "/support/myInquiries?submitted=1");

		} catch (IllegalArgumentException e) {

			request.setAttribute("errorMessage", e.getMessage());

			request.setAttribute("category", category);

			request.setAttribute("email", email);

			request.setAttribute("title", title);

			request.setAttribute("content", content);

			request.getRequestDispatcher("/view/support/inquiry.jsp").forward(request, response);

		} catch (Exception e) {

			getServletContext().log("고객 문의 접수 중 오류 발생", e);

			request.setAttribute("errorMessage", "문의 접수 중 오류가 발생했습니다.");

			request.getRequestDispatcher("/view/support/inquiry.jsp").forward(request, response);
		}
	}

}
