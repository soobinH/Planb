package service.member;

import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.util.UUID;

import javax.servlet.http.Part;

import dao.member.UserDao;
import dao.member.UserDaoImpl;
import dto.member.UserDto;
import util.image.SharedImageStorage;
import util.image.SharedImageStorage.Category;

public class UserServiceImpl implements UserService {
	private UserDao userDao;

	public UserServiceImpl() {
		userDao = new UserDaoImpl();
	}

	@Override
	public void signup(UserDto user, Part profile) throws Exception {

		String savedFileName = null;

		try {

			/* 프로필 이미지가 있으면 공유폴더에 저장 */
			if (profile != null && profile.getSize() > 0) {

				savedFileName = saveProfileImage(profile);

				/* DB에는 파일명만 저장 */
				user.setProfileImg(savedFileName);
			}

			/* 회원 DB 저장 */
			userDao.insertUser(user);

		} catch (Exception e) {

			/*
			 * 이미지는 저장됐는데 회원가입 DB 저장이 실패한 경우 이미지 삭제
			 */
			if (savedFileName != null) {

				try {

					Category profileCategory = Category.fromFolderName("profile");

					if (profileCategory != null) {

						Path savedPath = SharedImageStorage.resolveFile(profileCategory, savedFileName);

						Files.deleteIfExists(savedPath);
					}

				} catch (Exception deleteException) {

					deleteException.printStackTrace();
				}
			}

			throw e;
		}
	}


	private String saveProfileImage(Part profile) throws Exception {

		if (profile == null || profile.getSize() <= 0) {

			return null;
		}

		/*
		 * ===================================================== 1. 용량 검사
		 * =====================================================
		 */

		if (profile.getSize() > 5 * 1024 * 1024) {

			throw new Exception("프로필 이미지는 5MB 이하만 등록할 수 있습니다.");
		}

		/*
		 * ===================================================== 2. MIME 타입 검사
		 * =====================================================
		 */

		String contentType = profile.getContentType();

		if (contentType == null) {

			throw new Exception("이미지 형식을 확인할 수 없습니다.");
		}

		contentType = contentType.toLowerCase();

		String extension;

		switch (contentType) {

		case "image/jpeg":
			extension = ".jpg";
			break;

		case "image/png":
			extension = ".png";
			break;

		case "image/webp":
			extension = ".webp";
			break;

		default:
			throw new Exception("JPG, PNG, WEBP 이미지만 등록할 수 있습니다.");
		}

		/*
		 * ===================================================== 3. 랜덤 파일명
		 * =====================================================
		 */

		String fileName = "profile_" + UUID.randomUUID().toString().replace("-", "") + extension;

		/*
		 * ===================================================== 4. profile 카테고리
		 * =====================================================
		 */

		Category profileCategory = Category.fromFolderName("profile");

		if (profileCategory == null) {

			throw new Exception("프로필 이미지 저장 카테고리를 찾을 수 없습니다.");
		}

		/*
		 * ===================================================== 5. 공유 저장소의 실제 파일 위치
		 * =====================================================
		 */

		Path savePath = SharedImageStorage.resolveFile(profileCategory, fileName);

		/*
		 * ===================================================== 6. 폴더 생성
		 * =====================================================
		 */

		Path parent = savePath.getParent();

		if (parent == null) {

			throw new Exception("프로필 이미지 저장 위치를 찾을 수 없습니다.");
		}

		Files.createDirectories(parent);

		/*
		 * ===================================================== 7. 파일 저장
		 * =====================================================
		 */

		try (java.io.InputStream input = profile.getInputStream()) {

			Files.copy(input, savePath, StandardCopyOption.REPLACE_EXISTING);
		}

		System.out.println("프로필 이미지 공유폴더 저장: " + savePath.toAbsolutePath());

		/*
		 * DB에는 파일명만 반환
		 */
		return fileName;
	}

	@Override
	public UserDto login(String id, String password) throws Exception {
		UserDto user = userDao.selectUser(id);
		if (user == null)
			throw new Exception("아이디 오류입니다.");
		if (!user.getPassword().equals(password))
			throw new Exception("비밀번호 오류입니다.");
		user.setPassword("");
		return user;
	}

	@Override
	public boolean checkUserId(String id) throws Exception {
		// TODO Auto-generated method stub
		return false;
	}

	@Override
	public boolean withdraw(long userId, String password) throws Exception {
		String dbPassword = userDao.selectPasswordByUserId(userId);

		if (dbPassword == null) {
			throw new Exception("회원정보를 찾을 수 없습니다.");
		}

		if (!dbPassword.equals(password)) {
			throw new Exception("비밀번호가 일치하지 않습니다.");
		}

		int result = userDao.withdrawUser(userId);

		if (result == 0) {
			throw new Exception("회원 탈퇴 처리에 실패했습니다.");
		}

		return true;
	}

	@Override
	public Long findPasswordUser(String loginId, String name, String email, String phone) throws Exception {
		Long userId = userDao.findPasswordUser(loginId, name, email, phone);
		if (userId == null) {
			throw new Exception("일치하는 회원 정보가 없습니다.");
		}

		return userId;

	}

	@Override
	public void resetPassword(long userId, String password) throws Exception {
		int result = userDao.resetPassword(userId, password);
		if (result == 0) {
			throw new Exception("비밀번호 변경에 실패했습니다.");
		}
	}

	@Override
	public boolean isLoginIdAvailable(String loginId) {
		// TODO Auto-generated method stub
		return userDao.countLoginId(loginId) == 0;
	}

	@Override
	public boolean isNicknameAvailable(String nickname) {
		// TODO Auto-generated method stub
		return userDao.countNickname(nickname) == 0;
	}

	@Override
	public boolean isEmailAvailable(String email) {
		// TODO Auto-generated method stub
		return userDao.countEmail(email) == 0;
	}

	@Override
	public UserDto findSocialUser(String provider, String providerUserId) throws Exception {
		return userDao.findSocialUser(provider, providerUserId);
	}

	@Override
	public void signupGoogle(UserDto user) throws Exception {
		userDao.insertGoogleUser(user);

	}

	@Override
	public void updateUser(UserDto user) throws Exception {
		userDao.updateUser(user);

	}

	@Override
	public UserDto selectUser(String loginId) throws Exception {
		return userDao.selectUser(loginId);
	}

	@Override
	public void changePassword(long userId, String currentPassword, String newPassword) throws Exception {

		String savedPassword = userDao.selectPasswordByUserId(userId);

		if (savedPassword == null) {

			throw new Exception("비밀번호 정보를 찾을 수 없습니다.");

		}

		if (!savedPassword.equals(currentPassword)) {

			throw new Exception("현재 비밀번호가 올바르지 않습니다.");

		}

		if (savedPassword.equals(newPassword)) {

			throw new Exception("새 비밀번호는 현재 비밀번호와 다르게 설정해주세요.");

		}

		int result = userDao.resetPassword(userId, newPassword);

		if (result <= 0) {

			throw new Exception("비밀번호 변경에 실패했습니다.");

		}

	}

	@Override
	public boolean checkPassword(long userId, String password) throws Exception {

		String savedPassword = userDao.selectPasswordByUserId(userId);

		if (savedPassword == null) {

			throw new Exception("비밀번호 정보를 찾을 수 없습니다.");
		}

		return savedPassword.equals(password);
	}

	@Override
	public void updatePassword(long userId, String newPassword) throws Exception {

		if (checkPassword(userId, newPassword)) {

			throw new Exception("새 비밀번호는 현재 비밀번호와 다르게 설정해주세요.");
		}

		int result = userDao.resetPassword(userId, newPassword);

		if (result <= 0) {

			throw new Exception("비밀번호 변경에 실패했습니다.");
		}
	}

	@Override
	public void withdraw(long userId) throws Exception {
		int result = userDao.withdrawUser(userId);

		if (result <= 0) {

			throw new Exception("회원 탈퇴 처리에 실패했습니다.");
		}
	}

	@Override
	public UserDto getUserById(long userId) throws Exception {
		return userDao.selectUserById(userId);
	}

	@Override
	public void updateProfileVisibility(long userId, String profileVisibility) throws Exception {
		if (!"PUBLIC".equals(profileVisibility) && !"PRIVATE".equals(profileVisibility)) {
			throw new IllegalArgumentException("잘못된 공개 범위입니다.");
		}

		userDao.updateProfileVisibility(userId, profileVisibility);

	}

	@Override
	public void updateShowLikedItinerary(long userId, boolean show) throws Exception {
		userDao.updateShowLikedItinerary(userId, show);

	}

	@Override
	public void updateShowBookmarkedItinerary(long userId, boolean show) throws Exception {
		userDao.updateShowBookmarkedItinerary(userId, show);
	}

	@Override
	public void updateProfileImg(long userId, String profileImg) throws Exception {
		if (userDao.updateProfileImg(userId, profileImg) == 0) {
			throw new Exception("프로필 사진을 저장하지 못했습니다.");
		}
	}

}
