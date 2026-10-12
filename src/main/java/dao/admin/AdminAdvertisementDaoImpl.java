package dao.admin;

import java.sql.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.ibatis.session.SqlSession;


public class AdminAdvertisementDaoImpl implements AdminAdvertisementDao {
	private static final String NAMESPACE = "mapper.advertisement.admin.";

	
	@Override
	public List<Map<String, Object>> selectAllAds(SqlSession sqlSession) throws Exception {
		return sqlSession.selectList(NAMESPACE+"selectAllAds");
	}

	@Override
	public Map<String, Object> selectAdForUpdate(SqlSession sqlSession, long adId) throws Exception {
		return sqlSession.selectOne(NAMESPACE+"selectAdForUpdate", adId);
	}

	@Override
	public int approvedAd(SqlSession sqlSession, long adId, long adminUserId) throws Exception {
		Map<String, Object> param = new HashMap<>();
		param.put("adId", adId);
		param.put("adminUserId", adminUserId);
		return sqlSession.update(NAMESPACE+"approveAd", param);
	}

	@Override
	public int rejectAd(SqlSession sqlSession, long adId, long adminUserId, String reason) throws Exception {
		Map<String, Object> param = new HashMap<>();
		param.put("adId", adId);
		param.put("adminUserId", adminUserId);
		param.put("reason", reason);
		return sqlSession.update(NAMESPACE+"rejectAd", param);
	}

	@Override
	public int activateAd(SqlSession sqlSession, long adId, long adminUserId) throws Exception {
		Map<String, Object> param = new HashMap<>();
		param.put("adId", adId);
		param.put("adminUserId", adminUserId);
		return sqlSession.update(NAMESPACE+"activateAd", param);
	}

	@Override
	public int withdrawAd(SqlSession sqlSession, long adId, long adminUserId, String reason) throws Exception {
		Map<String, Object> param = new HashMap<>();
		param.put("adId", adId);
		param.put("adminUserId", adminUserId);
		param.put("reason", reason);
		return sqlSession.update(NAMESPACE+"withdrawAd", param);
	}

	@Override
	public int extendAd(SqlSession sqlSession, long adId, long adminUserId, Date newEndDate) throws Exception {
		Map<String, Object> param = new HashMap<>();
		param.put("adId", adId);
		param.put("adminUserId", adminUserId);
		param.put("newEndDate", newEndDate);
		return sqlSession.update(NAMESPACE + "extendAd", param);
	}

	@Override
	public int deleteAd(SqlSession sqlSession, long adId, long adminUserId) throws Exception {
		Map<String, Object> param = new HashMap<>();
		param.put("adId", adId);
		param.put("adminUserId", adminUserId);
		return sqlSession.update(NAMESPACE + "deleteAd", param);
	}

	@Override
	public int insertHistory(SqlSession sqlSession, long adId, long adminUserId, String actionType, String fromStatus,
			String toStatus, Date previousEndDate, Date newEndDate, String reason) throws Exception {
		Map<String, Object> param = new HashMap<>();
		param.put("adId", adId);
		param.put("adminUserId", adminUserId);
		param.put("actionType", actionType);
		param.put("fromStatus", fromStatus);
		param.put("previousEndDate", previousEndDate);
		param.put("newEndDate", newEndDate);
		param.put("reason", reason);
		return sqlSession.insert(NAMESPACE+"insertHistory", param); 
	}

}
