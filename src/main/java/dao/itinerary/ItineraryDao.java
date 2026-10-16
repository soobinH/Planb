package dao.itinerary;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.session.SqlSession;

import dto.itinerary.ItineraryDto;
import dto.itinerary.ItineraryCardGeoRow;

public interface ItineraryDao {

	// 공개 일정 목록 조회 26.10.01 추가
	List<ItineraryDto> selectScheduleList(Map<String, Object> params) throws Exception;

    List<ItineraryCardGeoRow> selectScheduleCardGeoRows(List<Long> ids) throws Exception;

	long countScheduleList(Map<String, Object> params) throws Exception;

	ItineraryDto selectScheduleDetailInfo(SqlSession sqlSession, Long itineraryId) throws Exception;

	int increaseScheduleViewCount(SqlSession sqlSession, Map<String, Object> params) throws Exception;

	/////////////////////////////////////////////////////////////////////////////////////////

	int insertItinerary(SqlSession sqlSession, ItineraryDto itineraryDto) throws Exception;

	ItineraryDto selectItinerary(SqlSession sqlSession, Long itineraryId) throws Exception;

	int updateItinerary(SqlSession sqlSession, ItineraryDto itineraryDto) throws Exception;

	int deleteItinerary(SqlSession sqlSession, Long itineraryId, Long userId) throws Exception;
}