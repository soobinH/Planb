package controller.settings;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.sql.Date;
import java.util.UUID;

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

import util.image.SharedImageStorage;
import util.image.SharedImageStorage.Category;

/**
 * 회원 프로필 수정
 */
@WebServlet("/profile/edit")

@MultipartConfig(maxFileSize = 5 * 1024 * 1024, maxRequestSize = 10 * 1024 * 1024, fileSizeThreshold = 1024 * 1024)

public class ProfileEdit extends HttpServlet {

	private static final long serialVersionUID = 1L;

	/* 소개글 최대 글자 수 */
	private static final int BIO_MAX_LENGTH = 50;

	private UserService service = new UserServiceImpl();

	public ProfileEdit() {
		super();
	}

	/*
	 * ========================================================= 프로필 설정 페이지 이동
	 * =========================================================
	 */

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		request.getRequestDispatcher("/view/settings/settings.jsp").forward(request, response);
	}

	/*
	 * ========================================================= 프로필 수정
	 * =========================================================
	 */

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		request.setCharacterEncoding("UTF-8");

		/*
		 * ===================================================== 1. 로그인 세션 확인
		 * =====================================================
		 */

		HttpSession session = request.getSession(false);

		if (session == null) {

			response.sendRedirect(request.getContextPath() + "/auth/login");

			return;
		}

		UserDto loginUser = (UserDto) session.getAttribute("user");

		if (loginUser == null) {

			response.sendRedirect(request.getContextPath() + "/auth/login");

			return;
		}

		/*
		 * ===================================================== 2. 입력값
		 * =====================================================
		 */

		String name = request.getParameter("name");

		String nickname = request.getParameter("nickname");

		String birthDate = request.getParameter("birthDate");

		String phone = request.getParameter("phone");

		String region = request.getParameter("region");

		String postcode = request.getParameter("postcode");

		String address = request.getParameter("address");

		String addressDetail = request.getParameter("addressDetail");

		String bio = request.getParameter("bio");

		/*
		 * DB UPDATE 실패 시 새로 저장한 이미지를 삭제하기 위한 변수
		 */
		Path newlySavedFile = null;

		try {

			/*
			 * ================================================= 3. 기본 Validation
			 * =================================================
			 */

			if (name == null || name.trim().isEmpty()) {

				throw new Exception("이름을 입력해주세요.");
			}

			if (nickname == null || nickname.trim().length() < 2) {

				throw new Exception("닉네임을 올바르게 입력해주세요.");
			}

			if (phone == null || !phone.matches("^01[016789]-\\d{3,4}-\\d{4}$")) {

				throw new Exception("전화번호를 올바르게 입력해주세요.");
			}

			if (postcode == null || postcode.trim().isEmpty() || address == null || address.trim().isEmpty()) {

				throw new Exception("주소를 입력해주세요.");
			}

			if (bio != null && bio.trim().length() > BIO_MAX_LENGTH) {

				throw new Exception("소개는 " + BIO_MAX_LENGTH + "자 이내로 입력해주세요.");
			}

			/*
			 * ================================================= 4. 닉네임 변경 시 중복확인
			 * =================================================
			 */

			String trimmedNickname = nickname.trim();

			if (loginUser.getNickName() == null || !trimmedNickname.equals(loginUser.getNickName())) {

				if (!service.isNicknameAvailable(trimmedNickname)) {

					throw new Exception("이미 사용 중인 닉네임입니다.");
				}
			}

			/*
			 * ================================================= 5. 수정할 UserDto
			 * =================================================
			 */

			UserDto updateUser = new UserDto();

			updateUser.setUserId(loginUser.getUserId());

			updateUser.setName(name.trim());

			updateUser.setNickName(trimmedNickname);

			updateUser.setPhone(phone.trim());

			updateUser.setRegion(emptyToNull(region));

			updateUser.setPostcode(emptyToNull(postcode));

			updateUser.setAddress(emptyToNull(address));

			updateUser.setAddressDetail(emptyToNull(addressDetail));

			updateUser.setBio(emptyToNull(bio));

			/*
			 * ================================================= 6. 생년월일
			 * =================================================
			 */

			if (birthDate != null && !birthDate.trim().isEmpty()) {

				updateUser.setBirthDate(Date.valueOf(birthDate.trim()));

			} else {

				updateUser.setBirthDate(null);
			}

			/*
			 * ================================================= 7. 프로필 이미지
			 * 
			 * 기본값: 기존 이미지 파일명 유지 =================================================
			 */

			String profileFileName = loginUser.getProfileImg();

			Part profileImage = request.getPart("profileImage");

			/*
			 * ================================================= 8. 새 이미지를 선택한 경우
			 * =================================================
			 */

			if (profileImage != null && profileImage.getSize() > 0) {

				/*
				 * --------------------------------------------- 이미지 크기
				 * ---------------------------------------------
				 */

				if (profileImage.getSize() > 5 * 1024 * 1024) {

					throw new Exception("프로필 이미지는 5MB 이하만 등록할 수 있습니다.");
				}

				/*
				 * --------------------------------------------- MIME 타입
				 * ---------------------------------------------
				 */

				String contentType = profileImage.getContentType();

				if (contentType == null) {

					throw new Exception("이미지 형식을 확인할 수 없습니다.");
				}

				/*
				 * --------------------------------------------- 확장자 결정
				 * ---------------------------------------------
				 */

				String extension = getImageExtension(contentType);

				/*
				 * --------------------------------------------- UUID 파일명 생성
				 * 
				 * 예: profile_a8f93....jpg ---------------------------------------------
				 */

				profileFileName = "profile_" + UUID.randomUUID().toString().replace("-", "") + extension;

				/*
				 * --------------------------------------------- 공유폴더의 profile 카테고리
				 * ---------------------------------------------
				 */

				Category profileCategory = Category.fromFolderName("profile");

				if (profileCategory == null) {

					throw new Exception("프로필 이미지 저장 카테고리를 찾을 수 없습니다.");
				}

				/*
				 * --------------------------------------------- 실제 공유폴더 파일 경로
				 * 
				 * 여기서 더 이상 getServletContext().getRealPath() 를 사용하지 않음.
				 * ---------------------------------------------
				 */

				Path savePath = SharedImageStorage.resolveFile(profileCategory, profileFileName);

				/*
				 * --------------------------------------------- 공유폴더 생성
				 * ---------------------------------------------
				 */

				Path parentDirectory = savePath.getParent();

				if (parentDirectory == null) {

					throw new Exception("프로필 이미지 저장 위치를 찾을 수 없습니다.");
				}

				Files.createDirectories(parentDirectory);

				/*
				 * --------------------------------------------- 실제 이미지 저장
				 * ---------------------------------------------
				 */

				try (InputStream input = profileImage.getInputStream()) {

					Files.copy(input, savePath, StandardCopyOption.REPLACE_EXISTING);
				}

				/*
				 * DB UPDATE 실패 시 새로 저장한 이미지 삭제용
				 */
				newlySavedFile = savePath;

				/*
				 * --------------------------------------------- 확인 로그
				 * ---------------------------------------------
				 */

				System.out.println("======================================");

				System.out.println("[프로필 이미지 수정]");

				System.out.println("fileName = " + profileFileName);

				System.out.println("shared savePath = " + savePath.toAbsolutePath());

				System.out.println("file exists = " + Files.exists(savePath));

				System.out.println("file size = " + Files.size(savePath));

				System.out.println("browser URL = " + request.getContextPath() + "/uploads/profile/" + profileFileName);

				System.out.println("======================================");
			}

			/*
			 * ================================================= 9. DTO에 프로필 이미지 설정
			 * 
			 * 새 사진 있음 → 새 profile_xxx.jpg
			 * 
			 * 새 사진 없음 → 기존 파일명 유지 =================================================
			 */

			updateUser.setProfileImg(profileFileName);

			/*
			 * ================================================= 10. DB UPDATE
			 * =================================================
			 */

			service.updateUser(updateUser);

			/*
			 * ================================================= 11. DB에서 수정된 회원정보 다시 조회
			 * 
			 * loginId가 아니라 userId로 다시 조회 =================================================
			 */

			UserDto refreshedUser = service.getUserById(loginUser.getUserId());

			if (refreshedUser == null) {

				throw new Exception("수정된 회원정보를 불러오지 못했습니다.");
			}

			/*
			 * ================================================= 12. 확인 로그
			 * =================================================
			 */

			System.out.println("수정 후 DB profileImg = " + refreshedUser.getProfileImg());

			System.out.println("수정 후 nickname = " + refreshedUser.getNickName());

			/*
			 * ================================================= 13. 세션 회원정보 최신화
			 * 
			 * 매우 중요
			 * 
			 * myProfile.jsp는 session의 user를 사용하므로 세션을 바꾸지 않으면 수정 전 정보가 계속 보임.
			 * =================================================
			 */

			session.setAttribute("user", refreshedUser);

			/*
			 * ================================================= 14. 수정 완료 → 내 프로필
			 * =================================================
			 */

			response.sendRedirect(request.getContextPath() + "/profile/myProfile" + "?updated=success");

		} catch (Exception e) {

			e.printStackTrace();

			/*
			 * ================================================= 새 이미지까지 저장했는데 DB UPDATE가
			 * 실패한 경우 새 파일 삭제 =================================================
			 */

			if (newlySavedFile != null) {

				try {

					Files.deleteIfExists(newlySavedFile);

				} catch (Exception deleteException) {

					deleteException.printStackTrace();
				}
			}

			request.setAttribute("errorMessage", e.getMessage());

			request.getRequestDispatcher("/profile/myProfile").forward(request, response);
		}
	}

	/*
	 * ========================================================= 빈 문자열 → null
	 * =========================================================
	 */

	private String emptyToNull(String value) {

		if (value == null) {

			return null;
		}

		value = value.trim();

		if (value.isEmpty()) {

			return null;
		}

		return value;
	}

	/*
	 * ========================================================= MIME 타입 → 확장자
	 * 
	 * 회원가입과 동일하게 JPG / PNG / WEBP만 허용
	 * =========================================================
	 */

	private String getImageExtension(String contentType) throws Exception {

		if ("image/jpeg".equalsIgnoreCase(contentType)) {

			return ".jpg";
		}

		if ("image/png".equalsIgnoreCase(contentType)) {

			return ".png";
		}

		if ("image/webp".equalsIgnoreCase(contentType)) {

			return ".webp";
		}

		throw new Exception("JPG, PNG, WEBP 이미지만 등록할 수 있습니다.");
	}
}