package controller.settings;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
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
 * 프로필 사진 즉시 저장
 *
 * 설정 > 프로필 설정에서 사진을 고르면 "변경사항 저장"을 누르지 않아도
 * 바로 공유폴더에 저장하고 DB / 세션의 profile_img 를 바꿈.
 *
 * 응답(JSON) : {"success":true,"url":"/Planb/uploads/profile/profile_xxx.jpg"}
 *             {"success":false,"message":"..."}
 */
@WebServlet("/profile/image")
@MultipartConfig(maxFileSize = 5 * 1024 * 1024, maxRequestSize = 6 * 1024 * 1024, fileSizeThreshold = 1024 * 1024)
public class ProfileImageUpload extends HttpServlet {

	private static final long serialVersionUID = 1L;

	private static final long MAX_FILE_SIZE = 5 * 1024 * 1024;

	private UserService service = new UserServiceImpl();

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		request.setCharacterEncoding("UTF-8");
		response.setContentType("application/json; charset=UTF-8");

		HttpSession session = request.getSession(false);
		UserDto loginUser = session == null ? null : (UserDto) session.getAttribute("user");

		if (loginUser == null) {
			response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
			writeError(response, "로그인이 필요합니다.");
			return;
		}

		Path savedFile = null;

		try {
			Part profileImage;

			try {
				profileImage = request.getPart("profileImage");
			} catch (IllegalStateException e) {
				throw new Exception("프로필 사진은 5MB 이하의 이미지만 업로드할 수 있습니다.");
			}

			if (profileImage == null || profileImage.getSize() == 0) {
				throw new Exception("사진을 선택해주세요.");
			}

			if (profileImage.getSize() > MAX_FILE_SIZE) {
				throw new Exception("프로필 사진은 5MB 이하의 이미지만 업로드할 수 있습니다.");
			}

			String extension = getImageExtension(profileImage.getContentType());
			String fileName = "profile_" + UUID.randomUUID().toString().replace("-", "") + extension;

			Category profileCategory = Category.fromFolderName("profile");

			if (profileCategory == null) {
				throw new Exception("프로필 이미지 저장 카테고리를 찾을 수 없습니다.");
			}

			Path savePath = SharedImageStorage.resolveFile(profileCategory, fileName);
			Files.createDirectories(savePath.getParent());

			try (InputStream input = profileImage.getInputStream()) {
				Files.copy(input, savePath, StandardCopyOption.REPLACE_EXISTING);
			}

			savedFile = savePath;

			// DB 저장 후 세션도 최신 정보로 교체
			service.updateProfileImg(loginUser.getUserId(), fileName);

			UserDto refreshedUser = service.getUserById(loginUser.getUserId());
			session.setAttribute("user", refreshedUser != null ? refreshedUser : loginUser);

			if (refreshedUser == null) {
				loginUser.setProfileImg(fileName);
			}

			String url = request.getContextPath() + "/uploads/profile/" + fileName;

			response.getWriter().write("{\"success\":true,\"url\":\"" + escapeJson(url) + "\"}");

		} catch (Exception e) {
			e.printStackTrace();

			if (savedFile != null) {
				try {
					Files.deleteIfExists(savedFile);
				} catch (Exception deleteException) {
					deleteException.printStackTrace();
				}
			}

			response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
			writeError(response, e.getMessage());
		}
	}

	/* 회원가입 / 프로필 수정과 동일하게 JPG / PNG / WEBP만 허용 */
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

	private void writeError(HttpServletResponse response, String message) throws IOException {
		String text = message == null ? "프로필 사진을 저장하지 못했습니다." : message;
		response.getWriter().write("{\"success\":false,\"message\":\"" + escapeJson(text) + "\"}");
	}

	private String escapeJson(String value) {
		return value.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", " ").replace("\r", " ");
	}
}
