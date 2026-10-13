package dao.community;

import org.apache.ibatis.session.SqlSession;

import dto.community.TipLikeDto;

public interface TipLikeDao {

	int insertTipLike(TipLikeDto tipLikeDto);

	TipLikeDto selectTipLike(TipLikeDto tipLikeDto);

	int deleteTipLike(TipLikeDto tipLikeDto);
	
	int selectTipLikeCount(long tipId);
	
	// 알림 관련 추가.
	int insertTipLike(SqlSession sqlSession, TipLikeDto tipLikeDto);

	TipLikeDto selectTipLike(SqlSession sqlSession, TipLikeDto tipLikeDto);
	
	int deleteTipLike(SqlSession sqlSession, TipLikeDto tipLikeDto);
}