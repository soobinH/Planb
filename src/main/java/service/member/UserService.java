package service.member;

import javax.servlet.http.Part;

import dto.member.UserDto;

public interface UserService {
	void signup(UserDto user, Part profile) throws Exception;
	UserDto login(String id, String password) throws Exception;
	boolean checkUserId(String id) throws Exception;
	boolean withdraw(long userId, String password) throws Exception;
	void withdraw(long userId) throws Exception;
	Long findPasswordUser(String loginId, String name, String email, String phone) throws Exception;
	void resetPassword(long userId, String password) throws Exception;
	void changePassword(long userId, String currentPassword, String newPassword) throws Exception;

	/* 비밀번호 변경 1단계 : 현재 비밀번호 확인 */
	boolean checkPassword(long userId, String password) throws Exception;

	/* 비밀번호 변경 2단계 : 현재 비밀번호 확인을 마친 뒤 새 비밀번호로 변경 */
	void updatePassword(long userId, String newPassword) throws Exception;
	boolean isLoginIdAvailable(String loginId);
	boolean isNicknameAvailable(String nickname);
	boolean isEmailAvailable(String email);
	UserDto findSocialUser(String provider, String providerUserId) throws Exception;
	void signupGoogle(UserDto user) throws Exception;
	void updateUser(UserDto user) throws Exception;
	UserDto selectUser(String loginId) throws Exception;
	UserDto getUserById(long userId) throws Exception;
	void updateProfileVisibility(long userId, String profileVisibility) throws Exception;
	void updateShowLikedItinerary(long userId, boolean show) throws Exception;
	void updateShowBookmarkedItinerary(long userId, boolean show) throws Exception;
}
