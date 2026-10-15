package dao.member;

import java.util.HashMap;
import java.util.Map;

import org.apache.ibatis.session.SqlSession;

import config.MybatisSqlSessionFactory;
import dto.member.UserDto;

public class UserDaoImpl implements UserDao {

	/*
	 * ========================================================= 일반 회원가입
	 * =========================================================
	 */

	@Override
	public void insertUser(UserDto userDto) throws Exception {

		SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession();

		try {

			sqlSession.insert("mapper.member.user.insertUser", userDto);

			sqlSession.commit();

		} catch (Exception e) {

			sqlSession.rollback();

			e.printStackTrace();

			throw e;

		} finally {

			sqlSession.close();

		}

	}

	/*
	 * ========================================================= 로그인 회원 조회
	 * =========================================================
	 */

	@Override
	public UserDto selectUser(String id) throws Exception {

		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {

			return sqlSession.selectOne("mapper.member.user.selectUser", id);

		} catch (Exception e) {

			e.printStackTrace();

			throw e;

		}

	}

	/*
	 * ========================================================= 회원 정보 수정
	 * =========================================================
	 */

	@Override
	public void updateUser(UserDto userDto) throws Exception {

		SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession();

		try {

			int result = sqlSession.update("mapper.member.user.updateUser", userDto);

			if (result > 0) {

				sqlSession.commit();

			} else {

				sqlSession.rollback();

			}

		} catch (Exception e) {

			sqlSession.rollback();

			e.printStackTrace();

			throw e;

		} finally {

			sqlSession.close();

		}

	}

	/*
	 * ========================================================= 회원 탈퇴
	 * =========================================================
	 */

	@Override
	public int withdrawUser(long userId) throws Exception {

		SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession();

		try {

			int result = sqlSession.update("mapper.member.user.withdrawUser", userId);

			if (result > 0) {

				sqlSession.commit();

			} else {

				sqlSession.rollback();

			}

			return result;

		} catch (Exception e) {

			sqlSession.rollback();

			e.printStackTrace();

			throw e;

		} finally {

			sqlSession.close();

		}

	}

	/*
	 * ========================================================= 현재 비밀번호 조회
	 * =========================================================
	 */

	@Override
	public String selectPasswordByUserId(long userId) throws Exception {

		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {

			return sqlSession.selectOne("mapper.member.user.selectPasswordByUserId", userId);

		} catch (Exception e) {

			e.printStackTrace();

			throw e;

		}

	}

	/*
	 * ========================================================= 비밀번호 찾기 회원 조회
	 * =========================================================
	 */

	@Override
	public Long findPasswordUser(String loginId, String name, String email, String phone) throws Exception {

		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {

			Map<String, Object> param = new HashMap<String, Object>();

			param.put("loginId", loginId);

			param.put("name", name);

			param.put("email", email);

			param.put("phone", phone);

			return sqlSession.selectOne("mapper.member.user.findPasswordUser", param);

		} catch (Exception e) {

			e.printStackTrace();

			throw e;

		}

	}

	/*
	 * ========================================================= 비밀번호 재설정
	 * =========================================================
	 */

	@Override
	public int resetPassword(Long userId, String password) throws Exception {

		SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession();

		try {

			Map<String, Object> param = new HashMap<String, Object>();

			param.put("userId", userId);

			param.put("password", password);

			int result = sqlSession.update("mapper.member.user.resetPassword", param);

			if (result > 0) {

				sqlSession.commit();

			} else {

				sqlSession.rollback();

			}

			return result;

		} catch (Exception e) {

			sqlSession.rollback();

			e.printStackTrace();

			throw e;

		} finally {

			sqlSession.close();

		}

	}

	/*
	 * ========================================================= 아이디 중복 확인
	 * =========================================================
	 */

	@Override
	public int countLoginId(String loginId) {

		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {

			return sqlSession.selectOne("mapper.member.user.countLoginId", loginId);

		}

	}

	/*
	 * ========================================================= 닉네임 중복 확인
	 * =========================================================
	 */

	@Override
	public int countNickname(String nickname) {

		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {

			return sqlSession.selectOne("mapper.member.user.countNickname", nickname);

		}

	}

	/*
	 * ========================================================= 이메일 중복 확인
	 * =========================================================
	 */

	@Override
	public int countEmail(String email) {

		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {

			return sqlSession.selectOne("mapper.member.user.countEmail", email);

		}

	}

	/*
	 * ========================================================= 소셜 로그인 회원 조회 Google
	 * 로그인 시 사용 =========================================================
	 */

	@Override
	public UserDto findSocialUser(String provider, String providerUserId) throws Exception {

		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {

			Map<String, Object> param = new HashMap<String, Object>();

			param.put("provider", provider);

			param.put("providerUserId", providerUserId);

			return sqlSession.selectOne("mapper.member.user.findSocialUser", param);

		} catch (Exception e) {

			e.printStackTrace();

			throw e;

		}

	}

	/*
	 * ========================================================= Google 신규 회원가입
	 * =========================================================
	 */

	@Override
	public int insertGoogleUser(UserDto user) throws Exception {

		SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession();

		try {

			int result = sqlSession.insert("mapper.member.user.insertGoogleUser", user);

			/*
			 * 반드시 commit 필요
			 *
			 * 기존 코드에서는 이 부분이 없어서 INSERT 후 findSocialUser()에서 신규 회원을 조회하지 못했음
			 */
			if (result > 0) {

				sqlSession.commit();

			} else {

				sqlSession.rollback();

			}

			return result;

		} catch (Exception e) {

			sqlSession.rollback();

			e.printStackTrace();

			throw e;

		} finally {

			sqlSession.close();

		}

	}

	@Override
	public UserDto selectUserById(long userId) throws Exception {
		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {

			return sqlSession.selectOne("mapper.member.user.selectUserById", userId);

		} catch (Exception e) {

			e.printStackTrace();

			throw e;
		}
	}

	@Override
	public int updateProfileVisibility(long userId, String profileVisibility) throws Exception {
		try(SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {
			Map<String, Object> param = new HashMap<String, Object>();
			param.put("userId", userId);
			param.put("profileVisibility", profileVisibility);
			int result = sqlSession.update("mapper.member.user.updateProfileVisibility", param);
			sqlSession.commit();
			return result;
		}
	}

	@Override
	public int updateShowLikedItinerary(long userId, boolean show) throws Exception {
		try(SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {
			Map<String, Object> param = new HashMap<String, Object>();
			param.put("userId", userId);
			param.put("show", show ? 1: 0);
			int result = sqlSession.update("mapper.member.user.updateShowLikedItinerary", param);
			sqlSession.commit();
			return result;
		}
	}

	@Override
	public int updateShowBookmarkedItinerary(long userId, boolean show) throws Exception {
		try(SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {
			Map<String, Object> param = new HashMap<String, Object>();
			param.put("userId", userId);
			param.put("show", show ? 1:0);
			int result = sqlSession.update("mapper.member.user.updateShowBookmarkedItinerary", param);
			sqlSession.commit();
			return result;
		}
	}

	@Override
	public int updateProfileImg(long userId, String profileImg) throws Exception {
		try(SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {
			Map<String, Object> param = new HashMap<String, Object>();
			param.put("userId", userId);
			param.put("profileImg", profileImg);
			int result = sqlSession.update("mapper.member.user.updateProfileImg", param);
			sqlSession.commit();
			return result;
		}
	}

}