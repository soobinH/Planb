package dao.community;

import org.apache.ibatis.session.SqlSession;

import config.MybatisSqlSessionFactory;
import dto.community.MateLikeDto;

public class MateLikeDaoImpl implements MateLikeDao {

	@Override
	public int insertMateLike(MateLikeDto mateLikeDto) {
		SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession();

		try {
			int result = sqlSession.insert("mapper.community.mateLike.insertMateLike", mateLikeDto);

			if (result > 0) {
				sqlSession.commit();
			}

			return result;
		} finally {
			sqlSession.close();
		}
	}

	@Override
	public MateLikeDto selectMateLike(Long mateId, Long userId) {
		SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession();

		try {
			MateLikeDto mateLikeDto = new MateLikeDto();
			mateLikeDto.setMateId(mateId);
			mateLikeDto.setUserId(userId);

			return sqlSession.selectOne("mapper.community.mateLike.selectMateLike", mateLikeDto);
		} finally {
			sqlSession.close();
		}
	}

	@Override
	public int deleteMateLike(Long mateId, Long userId) {
		SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession();

		try {
			MateLikeDto mateLikeDto = new MateLikeDto();
			mateLikeDto.setMateId(mateId);
			mateLikeDto.setUserId(userId);

			int result = sqlSession.delete("mapper.community.mateLike.deleteMateLike", mateLikeDto);

			if (result > 0) {
				sqlSession.commit();
			}

			return result;
		} finally {
			sqlSession.close();
		}
	}

	@Override
	public int countMateLike(Long mateId) {
		SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession();

		try {
			return sqlSession.selectOne("mapper.community.mateLike.countMateLike", mateId);
		} finally {
			sqlSession.close();
		}
	}
	
	@Override
	public int insertMateLike(SqlSession sqlSession, MateLikeDto mateLikeDto) {
	    return sqlSession.insert("mapper.community.mateLike.insertMateLike", mateLikeDto);
	}

	@Override
	public MateLikeDto selectMateLike(SqlSession sqlSession, Long mateId, Long userId) {
	    MateLikeDto mateLikeDto = new MateLikeDto();
	    
	    mateLikeDto.setMateId(mateId);
	    mateLikeDto.setUserId(userId);
	    
	    return sqlSession.selectOne("mapper.community.mateLike.selectMateLike",mateLikeDto);
	}

	@Override
	public int deleteMateLike(SqlSession sqlSession, Long mateId, Long userId) {
	    MateLikeDto mateLikeDto = new MateLikeDto();
	    
	    mateLikeDto.setMateId(mateId);
	    mateLikeDto.setUserId(userId);

	    return sqlSession.delete("mapper.community.mateLike.deleteMateLike", mateLikeDto);
	}
}