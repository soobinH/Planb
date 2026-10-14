package dao.itinerary;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.ibatis.session.SqlSession;

import dto.itinerary.ItineraryBlockCartDto;
import dto.itinerary.ItineraryCartDto;
import dto.itinerary.ItineraryDayCartDto;

public class ItineraryCartDaoImpl implements ItineraryCartDao {

	private static final String NAMESPACE = "mapper.itinerary.itineraryCart.";

	@Override
	public List<ItineraryCartDto> selectCartSnapshots(SqlSession sqlSession, Long userId) throws Exception {
		return sqlSession.selectList(NAMESPACE + "selectCartSnapshots", userId);
	}

	@Override
	public List<ItineraryCartDto> selectCartSnapshotsPaged(SqlSession sqlSession, Long userId, int offset, int pageSize)
			throws Exception {
		Map<String, Object> params = new HashMap<>();
		params.put("userId", userId);
		params.put("offset", offset);
		params.put("pageSize", pageSize);
		return sqlSession.selectList(NAMESPACE + "selectCartSnapshotsPaged", params);
	}

	@Override
	public List<ItineraryDayCartDto> selectDaySnapshots(SqlSession sqlSession, Long cartId) throws Exception {
		return sqlSession.selectList(NAMESPACE + "selectDaySnapshots", cartId);
	}

	@Override
	public List<ItineraryBlockCartDto> selectBlockSnapshots(SqlSession sqlSession, Long dayCartId) throws Exception {
		return sqlSession.selectList(NAMESPACE + "selectBlockSnapshots", dayCartId);
	}

	@Override
	public Long selectCartId(SqlSession sqlSession, Long userId, Long itineraryId) throws Exception {
		return sqlSession.selectOne(NAMESPACE + "selectCartId", pair("userId", userId, "itineraryId", itineraryId));
	}

	@Override
	public int insertCartSnapshot(SqlSession sqlSession, Long userId, Long itineraryId) throws Exception {
		return sqlSession.insert(NAMESPACE + "insertCartSnapshot", pair("userId", userId, "itineraryId", itineraryId));
	}

	@Override
	public Long selectDayCartId(SqlSession sqlSession, Long cartId, Long dayId) throws Exception {
		return sqlSession.selectOne(NAMESPACE + "selectDayCartId", pair("cartId", cartId, "dayId", dayId));
	}

	@Override
	public int insertDaySnapshot(SqlSession sqlSession, Long userId, Long cartId, Long dayId) throws Exception {
		Map<String, Object> params = new HashMap<>();
		params.put("userId", userId);
		params.put("cartId", cartId);
		params.put("dayId", dayId);
		return sqlSession.insert(NAMESPACE + "insertDaySnapshot", params);
	}

	@Override
	public Long selectBlockCartId(SqlSession sqlSession, Long dayCartId, Long blockId) throws Exception {
		return sqlSession.selectOne(NAMESPACE + "selectBlockCartId", pair("dayCartId", dayCartId, "blockId", blockId));
	}

	@Override
	public int insertBlockSnapshot(SqlSession sqlSession, Long userId, Long dayCartId, Long blockId) throws Exception {
		Map<String, Object> params = new HashMap<>();
		params.put("userId", userId);
		params.put("dayCartId", dayCartId);
		params.put("blockId", blockId);
		return sqlSession.insert(NAMESPACE + "insertBlockSnapshot", params);
	}

	@Override
	public int deleteItinerary(SqlSession sqlSession, Long userId, Long itineraryId) throws Exception {
		return sqlSession.delete(NAMESPACE + "deleteItinerary", pair("userId", userId, "itineraryId", itineraryId));
	}

	@Override
	public int deleteDay(SqlSession sqlSession, Long userId, Long dayId) throws Exception {
		return sqlSession.delete(NAMESPACE + "deleteDay", pair("userId", userId, "dayId", dayId));
	}

	@Override
	public int deleteBlock(SqlSession sqlSession, Long userId, Long blockId) throws Exception {
		return sqlSession.delete(NAMESPACE + "deleteBlock", pair("userId", userId, "blockId", blockId));
	}

	@Override
	public int selectCartCount(SqlSession sqlSession, Long userId) {
		return sqlSession.selectOne(NAMESPACE + "selectCartCount", userId);
	}

	@Override
	public int deleteEmptyDay(SqlSession sqlSession, Long userId, Long cartId, Long dayId) throws Exception {

		Map<String, Object> params = new HashMap<>();

		params.put("userId", userId);
		params.put("cartId", cartId);
		params.put("dayId", dayId);

		return sqlSession.delete(NAMESPACE + "deleteEmptyDay", params);
	}

	@Override
	public int deleteEmptyCart(SqlSession sqlSession, Long userId, Long cartId) throws Exception {

		return sqlSession.delete(NAMESPACE + "deleteEmptyCart", pair("userId", userId, "cartId", cartId));
	}

	private Map<String, Object> pair(String key1, Object value1, String key2, Object value2) {
		Map<String, Object> params = new HashMap<>();
		params.put(key1, value1);
		params.put(key2, value2);
		return params;
	}
}
