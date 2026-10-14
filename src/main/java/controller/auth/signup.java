package controller.auth;

import java.io.IOException;
import java.sql.Date;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;

import dto.member.UserDto;
import service.member.UserService;
import service.member.UserServiceImpl;

@WebServlet("/auth/signup")

@MultipartConfig(maxFileSize = 1024 * 1024 * 10, maxRequestSize = 1024 * 1024 * 10 * 5, fileSizeThreshold = 1024 * 1024)

public class signup extends HttpServlet {

	private static final long serialVersionUID = 1L;

	/* 소개글 최대 글자 수 */
	private static final int BIO_MAX_LENGTH = 50;

	private final UserService service = new UserServiceImpl();

	public signup() {
		super();
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		request.getRequestDispatcher("/view/auth/signup.jsp").forward(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		request.setCharacterEncoding("UTF-8");

		/*
		 * ===================================================== 1. 회원 정보
		 * =====================================================
		 */

		UserDto userDto = new UserDto();

		userDto.setLoginId(request.getParameter("loginId"));

		userDto.setPassword(request.getParameter("password"));

		String email = request.getParameter("email");

		userDto.setEmail(email);

		userDto.setName(request.getParameter("name"));

		userDto.setNickName(request.getParameter("nickname"));

		userDto.setPhone(request.getParameter("phone"));

		userDto.setPostcode(request.getParameter("postcode"));

		userDto.setAddress(request.getParameter("address"));

		userDto.setAddressDetail(request.getParameter("addressDetail"));

		userDto.setRegion(request.getParameter("region"));

		userDto.setBio(request.getParameter("bio"));

		/*
		 * ===================================================== 2. 생년월일
		 * =====================================================
		 */

		String birthDateStr = request.getParameter("birthDate");

		Date birthDate = null;

		if (birthDateStr != null && !birthDateStr.trim().isEmpty()) {

			birthDate = Date.valueOf(birthDateStr);
		}

		userDto.setBirthDate(birthDate);

		/*
		 * ===================================================== 3. 프로필 이미지 Part
		 * =====================================================
		 */

		Part profile = request.getPart("profileImage");

		/*
		 * 중요:
		 *
		 * getRealPath() 사용하지 않음.
		 *
		 * 실제 공유폴더 저장은 UserServiceImpl에서 SharedImageStorage를 통해 처리.
		 */

		try {

			/*
			 * ================================================= 4. 이메일 인증 확인
			 * =================================================
			 */

			HttpSession session = request.getSession(false);

			Boolean emailVerified = session == null ? null : (Boolean) session.getAttribute("emailVerified");

			String verifiedEmail = session == null ? null : (String) session.getAttribute("verifiedEmail");

			if (!Boolean.TRUE.equals(emailVerified) || verifiedEmail == null || email == null
					|| !verifiedEmail.equalsIgnoreCase(email.trim())) {

				request.setAttribute("errorMessage", "이메일 인증을 완료해주세요.");

				request.getRequestDispatcher("/view/auth/signup.jsp").forward(request, response);

				return;
			}

			String bio = userDto.getBio();

			if (bio != null && bio.trim().length() > BIO_MAX_LENGTH) {

				request.setAttribute("errorMessage", "소개글은 " + BIO_MAX_LENGTH + "자 이내로 입력해주세요.");

				request.getRequestDispatcher("/view/auth/signup.jsp").forward(request, response);

				return;
			}

			/*
			 * ================================================= 5. 회원가입
			 * 
			 * profile은 Service에서 공용 이미지 저장소에 저장
			 * =================================================
			 */

			service.signup(userDto, profile);

			/*
			 * ================================================= 6. 인증 임시 세션 제거
			 * =================================================
			 */

			session.removeAttribute("emailVerified");

			session.removeAttribute("verifiedEmail");

			/*
			 * ================================================= 7. 로그인 화면
			 * =================================================
			 */

			response.sendRedirect(request.getContextPath() + "/auth/login");

		} catch (Exception e) {

			e.printStackTrace();

			request.setAttribute("errorMessage", "회원가입 처리 중 오류가 발생했습니다.");

			request.getRequestDispatcher("/view/auth/signup.jsp").forward(request, response);
		}
	}
}