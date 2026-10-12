package dao.profile;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.ibatis.session.SqlSession;

import config.MybatisSqlSessionFactory;
import dto.profile.ProfileFeedDto;

public class ProfileFeedDaoImpl implements ProfileFeedDao {

	private static final String NAMESPACE = "mapper.profile.profileFeed.";

	private Map<String, Object> pageParameter(long userId, int offset, int limit) {

		Map<String, Object> parameter = new HashMap<String, Object>();

		parameter.put("userId", userId);
		parameter.put("offset", offset);
		parameter.put("limit", limit);

		return parameter;
	}

	@Override
	public List<ProfileFeedDto> selectMyItineraries(long userId) throws Exception {

		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {

			return sqlSession.selectList(NAMESPACE + "selectMyItineraries", userId);
		}
	}

	@Override
	public List<ProfileFeedDto> selectBookmarkedItineraries(long userId) throws Exception {

		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {

			return sqlSession.selectList(NAMESPACE + "selectBookmarkedItineraries", userId);
		}
	}

	@Override
	public List<ProfileFeedDto> selectLikedItineraries(long userId) throws Exception {

		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {

			return sqlSession.selectList(NAMESPACE + "selectLikedItineraries", userId);
		}
	}

	@Override
	public List<ProfileFeedDto> selectPublicItineraries(long userId) throws Exception {

		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {

			return sqlSession.selectList(NAMESPACE + "selectPublicItineraries", userId);
		}
	}

	@Override
	public List<ProfileFeedDto> selectPublicLikedItineraries(long userId) throws Exception {

		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {

			return sqlSession.selectList(NAMESPACE + "selectPublicLikedItineraries", userId);
		}
	}

	@Override
	public List<ProfileFeedDto> selectPublicBookmarkedItineraries(long userId) throws Exception {

		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {

			return sqlSession.selectList(NAMESPACE + "selectPublicBookmarkedItineraries", userId);
		}
	}

	@Override
	public List<ProfileFeedDto> selectMyItinerariesPage(long userId, int offset, int limit) throws Exception {

		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {

			return sqlSession.selectList(NAMESPACE + "selectMyItinerariesPage", pageParameter(userId, offset, limit));
		}
	}

	@Override
	public List<ProfileFeedDto> selectBookmarkedItinerariesPage(long userId, int offset, int limit) throws Exception {

		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {

			return sqlSession.selectList(NAMESPACE + "selectBookmarkedItinerariesPage",
					pageParameter(userId, offset, limit));
		}
	}

	@Override
	public List<ProfileFeedDto> selectLikedItinerariesPage(long userId, int offset, int limit) throws Exception {

		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {

			return sqlSession.selectList(NAMESPACE + "selectLikedItinerariesPage",
					pageParameter(userId, offset, limit));
		}
	}

	@Override
	public List<ProfileFeedDto> selectPublicItinerariesPage(long userId, int offset, int limit) throws Exception {

		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {

			return sqlSession.selectList(NAMESPACE + "selectPublicItinerariesPage",
					pageParameter(userId, offset, limit));
		}
	}

	@Override
	public List<ProfileFeedDto> selectPublicLikedItinerariesPage(long userId, int offset, int limit) throws Exception {

		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {

			return sqlSession.selectList(NAMESPACE + "selectPublicLikedItinerariesPage",
					pageParameter(userId, offset, limit));
		}
	}

	@Override
	public List<ProfileFeedDto> selectPublicBookmarkedItinerariesPage(long userId, int offset, int limit)
			throws Exception {

		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {

			return sqlSession.selectList(NAMESPACE + "selectPublicBookmarkedItinerariesPage",
					pageParameter(userId, offset, limit));
		}
	}

	@Override
	public int countMyItineraries(long userId) throws Exception {

		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {

			Integer count = sqlSession.selectOne(NAMESPACE + "countMyItineraries", userId);

			return count == null ? 0 : count;
		}
	}

	@Override
	public int countPublicItineraries(long userId) throws Exception {

		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {

			Integer count = sqlSession.selectOne(NAMESPACE + "countPublicItineraries", userId);

			return count == null ? 0 : count;
		}
	}

	@Override
	public int selectReceivedLikeCount(long userId) throws Exception {

		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {

			Integer count = sqlSession.selectOne(NAMESPACE + "selectReceivedLikeCount", userId);

			return count == null ? 0 : count;
		}
	}

	@Override
	public int selectReceivedBookmarkCount(long userId) throws Exception {

		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {

			Integer count = sqlSession.selectOne(NAMESPACE + "selectReceivedBookmarkCount", userId);

			return count == null ? 0 : count;
		}
	}

	@Override
	public int selectPublicReceivedLikeCount(long userId) throws Exception {

		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {

			Integer count = sqlSession.selectOne(NAMESPACE + "selectPublicReceivedLikeCount", userId);

			return count == null ? 0 : count;
		}
	}

	@Override
	public int selectPublicReceivedBookmarkCount(long userId) throws Exception {

		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {

			Integer count = sqlSession.selectOne(NAMESPACE + "selectPublicReceivedBookmarkCount", userId);

			return count == null ? 0 : count;
		}
	}

	@Override
	public void deleteItinerary(long itineraryId, long userId) throws Exception {

		Map<String, Object> parameter = new HashMap<String, Object>();

		parameter.put("itineraryId", itineraryId);

		parameter.put("userId", userId);

		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession(false)) {

			try {

				int updated = sqlSession.update(NAMESPACE + "deleteItinerary", parameter);

				if (updated != 1) {

					throw new IllegalArgumentException("삭제할 일정을 찾을 수 없습니다.");
				}

				sqlSession.commit();

			} catch (Exception e) {

				sqlSession.rollback();

				throw e;
			}
		}
	}
}
