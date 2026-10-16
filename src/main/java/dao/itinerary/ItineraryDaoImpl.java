package dao.itinerary;

import java.util.List;
import java.util.HashMap;
import java.util.Map;

import org.apache.ibatis.session.SqlSession;

import config.MybatisSqlSessionFactory;
import dto.itinerary.ItineraryDto;
import dto.itinerary.ItineraryCardGeoRow;

public class ItineraryDaoImpl implements ItineraryDao {
	// 26.10.01 추가.
	@Override
	public List<ItineraryDto> selectScheduleList(Map<String, Object> params) throws Exception {
		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {
			return sqlSession.selectList("mapper.itinerary.itinerary.selectScheduleList", params);
		}
	}

    @Override
    public List<ItineraryCardGeoRow> selectScheduleCardGeoRows(List<Long> ids) throws Exception {
        if (ids == null || ids.isEmpty()) return java.util.Collections.emptyList();
        try (SqlSession session = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {
            return session.selectList("mapper.itinerary.itinerary.selectScheduleCardGeoRows", ids);
        }
    }

	@Override
	public long countScheduleList(Map<String, Object> params) throws Exception {
		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {
			return sqlSession.selectOne("mapper.itinerary.itinerary.countScheduleList", params);
		}
	}

	@Override
	public ItineraryDto selectScheduleDetailInfo(SqlSession sqlSession, Long itineraryId) throws Exception {
		return sqlSession.selectOne("mapper.itinerary.itinerary.selectScheduleDetailInfo", itineraryId);
	}

	@Override
	public int increaseScheduleViewCount(SqlSession sqlSession, Map<String, Object> params) throws Exception {
		return sqlSession.update("mapper.itinerary.itinerary.increaseScheduleViewCount", params);
	}

	///////////////////////////////////////////////////////////////////////

	private static final String NAMESPACE = "mapper.itinerary.itinerary.";

	@Override
	public int insertItinerary(SqlSession sqlSession, ItineraryDto itineraryDto) throws Exception {
		return sqlSession.insert(NAMESPACE + "insertItinerary", itineraryDto);
	}

	@Override
	public ItineraryDto selectItinerary(SqlSession sqlSession, Long itineraryId) throws Exception {
		return sqlSession.selectOne(NAMESPACE + "selectItinerary", itineraryId);
	}

	@Override
	public int updateItinerary(SqlSession sqlSession, ItineraryDto itineraryDto) throws Exception {
		return sqlSession.update(NAMESPACE + "updateItinerary", itineraryDto);
	}

	@Override
	public int deleteItinerary(SqlSession sqlSession, Long itineraryId, Long userId) throws Exception {

		Map<String, Object> param = new HashMap<>();
		param.put("itineraryId", itineraryId);
		param.put("userId", userId);

		return sqlSession.update(NAMESPACE + "deleteItinerary", param);
	}
}
