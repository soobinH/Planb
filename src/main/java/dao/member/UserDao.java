package dao.member;

import dto.member.UserDto;

public interface UserDao {
	void insertUser(UserDto userDto) throws Exception;
	UserDto selectUser(String id) throws Exception;
	void updateUser(UserDto userDto) throws Exception;
	int withdrawUser(long userId) throws Exception;
	String selectPasswordByUserId(long userId) throws Exception;
	Long findPasswordUser(String loginId, String name, String email, String phone) throws Exception;
	int resetPassword(Long userId, String password) throws Exception;
	int countLoginId(String loginId);
	int countNickname(String nickname);
	int countEmail(String email);
	UserDto findSocialUser(String provider,String providerUserId) throws Exception;
	int insertGoogleUser(UserDto user) throws Exception;
	UserDto selectUserById(long userId) throws Exception;
	int updateProfileVisibility(long userId, String profileVisibility) throws Exception;
	int updateShowLikedItinerary(long userId,boolean show) throws Exception;
	int updateShowBookmarkedItinerary(long userId, boolean show)throws Exception;
	int updateProfileImg(long userId, String profileImg) throws Exception;
}
