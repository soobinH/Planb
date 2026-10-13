package dao.community;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.ibatis.session.SqlSession;

import config.MybatisSqlSessionFactory;
import dto.community.TipDto;

public class TipDaoImpl implements TipDao {

	@Override
	public int insertTip(TipDto tipDto) {
		try(SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {
			int result = sqlSession.insert("mapper.community.tip.insertTip", tipDto);
			sqlSession.commit();
			return result;
		} catch(Exception e) {
			e.printStackTrace();
			throw e;
		}
	}

	@Override
	public TipDto selectTip(Long tipId) {
		// TODO Auto-generated method stub
		return null;
	}
	
	@Override
	public TipDto selectTipDetail(long tipId) {
		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {
	        return sqlSession.selectOne("mapper.community.tip.selectTipDetail", tipId);
	    } catch (Exception e) {
	        e.printStackTrace();
	        throw e;
	    }
	}

	@Override
	public int updateTip(TipDto tipDto) {
		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {
	        int result = sqlSession.update("mapper.community.tip.updateTip", tipDto);
	        sqlSession.commit();
	        return result;
	    } catch (Exception e) {
	        e.printStackTrace();
	        throw e;
	    }
	}
	
	@Override
	public int updateTipThumbnail(TipDto tipDto) {
	    try (SqlSession session = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {
	        int result = session.update("mapper.community.tip.updateTipThumbnail", tipDto);
	        session.commit();
	        return result;
	    }
	}

	@Override
	public int deleteTip(TipDto tipDto) {
	    try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {
	        int result = sqlSession.update("mapper.community.tip.deleteTip",tipDto );
	        sqlSession.commit();
	        return result;
	    } catch (Exception e) {
	        e.printStackTrace();
	        throw e;
	    }
	}

	// 여행꿀팁 전체 조회
	@Override
	public List<TipDto> selectTipList() {
		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {
			return sqlSession.selectList("mapper.community.tip.selectTipList");
		} catch (Exception e) {
			e.printStackTrace();
			throw e;
		}
	}

	// 해시태그 검색
	@Override
	public List<TipDto> searchTipByHashtag(String keyword) {
		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {
			return sqlSession.selectList("mapper.community.tip.searchTipByHashtag", keyword);
		} catch (Exception e) {
			e.printStackTrace();
			throw e;
		}
	}

	@Override
	public List<TipDto> selectTipListByFilter(List<String> countryKeywords, String keyword, String sort, int pageSize, int offset) {
		Map<String, Object> param = new HashMap<>();
		param.put("countryKeywords", countryKeywords);
		param.put("keyword", keyword);
		param.put("sort", sort);
		
		// 무한 스크롤 페이지 처리
		param.put("pageSize", pageSize);
		param.put("offset", offset);
		
		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {
			return sqlSession.selectList("mapper.community.tip.selectTipListByFilter", param);
		} catch(Exception e) {
			e.printStackTrace();
			throw e;
		}
	}
	
	@Override
	public int countTipListByFilter(List<String> countryKeywords, String keyword) {
		Map<String, Object> param = new HashMap<>();

		param.put("countryKeywords", countryKeywords);
		param.put("keyword", keyword);

		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {
			return sqlSession.selectOne("mapper.community.tip.countTipListByFilter", param);
		} catch (Exception e) {
			e.printStackTrace();
			throw e;
		}
	}
	
	@Override
	public List<TipDto> selectMyTipList(long userId) {
		Map<String, Object> param = new HashMap<>();
		param.put("userId", userId);
		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {
			return sqlSession.selectList("mapper.community.tip.selectMyTipList", param);
		} catch (Exception e) {
			e.printStackTrace();
			throw e;
		}
	}

	@Override
	public List<TipDto> selectMyTipList(long userId, int offset, int pageSize) {
		Map<String, Object> param = new HashMap<>();

	    param.put("userId", userId);
	    param.put("offset", offset);
	    param.put("pageSize", pageSize);

	    try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {
	    	return sqlSession.selectList("mapper.community.tip.selectMyTipListPaging", param
	    	);
	    } catch (Exception e) {
	        e.printStackTrace();
	        throw e;
	    }
	}
	
	@Override
	public int countMyTipList(long userId) {
	    try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {
	        return sqlSession.selectOne("mapper.community.tip.countMyTipList", userId);
	    } catch (Exception e) {
	        e.printStackTrace();
	        throw e;
	    }
	}
	
	@Override
	public int updateTipViewCount(Long tipId) {

		SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession();

		try {

			int result = sqlSession.update(
				"mapper.community.tip.updateTipViewCount",
				tipId
			);

			if (result > 0) {
				sqlSession.commit();
			}

			return result;

		} finally {
			sqlSession.close();
		}
	}
	
	@Override
	public TipDto selectTipForUpdate(SqlSession sqlSession, Long tipId) {
	    return sqlSession.selectOne("mapper.community.tip.selectTipForUpdate",tipId);
	}
}