package dao.itinerary;

import java.util.List;

import org.apache.ibatis.session.SqlSession;

import dto.itinerary.ItineraryBlockCartDto;
import dto.itinerary.ItineraryCartDto;
import dto.itinerary.ItineraryDayCartDto;

public interface ItineraryCartDao {

	List<ItineraryCartDto> selectCartSnapshots(SqlSession sqlSession, Long userId) throws Exception;

	List<ItineraryCartDto> selectCartSnapshotsPaged(SqlSession sqlSession, Long userId, int offset, int pageSize) throws Exception;

	List<ItineraryDayCartDto> selectDaySnapshots(SqlSession sqlSession, Long cartId) throws Exception;

	List<ItineraryBlockCartDto> selectBlockSnapshots(SqlSession sqlSession, Long dayCartId) throws Exception;

	Long selectCartId(SqlSession sqlSession, Long userId, Long itineraryId) throws Exception;

	int insertCartSnapshot(SqlSession sqlSession, Long userId, Long itineraryId) throws Exception;

	Long selectDayCartId(SqlSession sqlSession, Long cartId, Long dayId) throws Exception;

	int insertDaySnapshot(SqlSession sqlSession, Long userId, Long cartId, Long dayId) throws Exception;

	Long selectBlockCartId(SqlSession sqlSession, Long dayCartId, Long blockId) throws Exception;

	int insertBlockSnapshot(SqlSession sqlSession, Long userId, Long dayCartId, Long blockId) throws Exception;

	int deleteItinerary(SqlSession sqlSession, Long userId, Long itineraryId) throws Exception;

	int deleteDay(SqlSession sqlSession, Long userId, Long dayId) throws Exception;

	int deleteBlock(SqlSession sqlSession, Long userId, Long blockId) throws Exception;

	int selectCartCount(SqlSession sqlSession, Long userId);

	int deleteEmptyDay(SqlSession sqlSession, Long userId, Long cartId, Long dayId) throws Exception;

	int deleteEmptyCart(SqlSession sqlSession, Long userId, Long cartId) throws Exception;
}
