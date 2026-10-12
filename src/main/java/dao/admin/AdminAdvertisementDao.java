package dao.admin;

import java.sql.Date;
import java.util.List;
import java.util.Map;

import org.apache.ibatis.session.SqlSession;

public interface AdminAdvertisementDao {
	/* 광고 전체 조회 */
	List<Map<String, Object>> selectAllAds(SqlSession sqlSession) throws Exception;

	/* 상태 변경 전 광고 조회 */
	Map<String, Object> selectAdForUpdate(SqlSession sqlSession, long adId) throws Exception;
	
	/* 광고 승인 */
	int approvedAd(SqlSession sqlSession, long adId, long adminUserId) throws Exception;

	/* 광고 거절 */
	int rejectAd(SqlSession sqlSession, long adId, long adminUserId, String reason) throws Exception;
	
	/* 광고 게시 시작 */
	int activateAd(SqlSession sqlSession, long adId, long adminUserId) throws Exception;
	
	/* 광고 게시 철회 */
	int withdrawAd(SqlSession sqlSession, long adId, long adminUserId, String reason) throws Exception;
	
	/* 광고 기간 연장 */
	int extendAd(SqlSession sqlSession, long adId, long adminUserId, Date newEndDate) throws Exception;
	
	/* 광고 삭제 처리 */
	int deleteAd(SqlSession sqlSession, long adId, long adminUserId)throws Exception;
	
	/* 광고 처리 이력 등록 */
	int insertHistory(SqlSession sqlSession, long adId, long adminUserId, String actionType, String fromStatus, String toStatus, Date previousEndDate, Date newEndDate, String reason) throws Exception;
	
	
}
