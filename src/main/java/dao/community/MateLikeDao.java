package dao.community;

import org.apache.ibatis.session.SqlSession;

import dto.community.MateLikeDto;

public interface MateLikeDao {

	int insertMateLike(MateLikeDto mateLikeDto);

	MateLikeDto selectMateLike(Long mateId, Long userId);

	int deleteMateLike(Long mateId, Long userId);

	int countMateLike(Long mateId);

	int insertMateLike(SqlSession sqlSession, MateLikeDto mateLikeDto);

	MateLikeDto selectMateLike(SqlSession sqlSession, Long mateId, Long userId);

	int deleteMateLike(SqlSession sqlSession, Long mateId, Long userId);
}