package dao.community;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.ibatis.session.SqlSession;

import config.MybatisSqlSessionFactory;
import dto.community.TipMediaDto;


public class TipMediaDaoImpl implements TipMediaDao {

	@Override
	public int insertTipMedia(TipMediaDto tipMediaDto) {
	    try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {
	        int result = sqlSession.insert("mapper.community.tipMedia.insertTipMedia", tipMediaDto);
	        sqlSession.commit();
	        return result;
	    } catch (Exception e) {
	        e.printStackTrace();
	        throw e;
	    }
	}

	@Override
	public TipMediaDto selectTipMedia(Long mediaId) {
		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {
			return sqlSession.selectOne("mapper.community.tipMedia.selectTipMedia", mediaId);
		} catch (Exception e) {
			e.printStackTrace();
			throw e;
		}
	}

	@Override
	public int updateTipMedia(TipMediaDto tipMediaDto) {
		// TODO Auto-generated method stub
		return 0;
	}

	@Override
	public int deleteTipMedia(long mediaId, long tipId) {
	    Map<String, Object> param = new HashMap<>();

	    param.put("mediaId", mediaId);
	    param.put("tipId", tipId);

	    try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {
	        int result = sqlSession.delete("mapper.community.tipMedia.deleteTipMedia",param);
	        sqlSession.commit();
	        return result;
	    }
	}

	@Override
	public List<TipMediaDto> selectTipMediaList(long tipId) {
	    try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {
	        return sqlSession.selectList("mapper.community.tipMedia.selectTipMediaList",  tipId);
	    } catch (Exception e) {
	        e.printStackTrace();
	        throw e;
	    }
	}
	
	@Override
	public int deleteTipMediaByTipId(long tipId) {
	    try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {
	        int result = sqlSession.delete("mapper.community.tipMedia.deleteTipMediaByTipId", tipId);
	        sqlSession.commit();
	        return result;
	    } catch (Exception e) {
	        e.printStackTrace();
	        throw e;
	    }
	}
	
	@Override
	public TipMediaDto selectFirstTipMedia(long tipId) {
	    try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {
	        return sqlSession.selectOne("mapper.community.tipMedia.selectFirstTipMedia", tipId);
	    }
	}

	@Override
	public int updateTipMediaSortOrder(long mediaId, long tipId, int sortOrder) {
	    Map<String, Object> param = new HashMap<>();
	    param.put("mediaId", mediaId);
	    param.put("tipId", tipId);
	    param.put("sortOrder", sortOrder);
	    try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {
	        int result = sqlSession.update("mapper.community.tipMedia.updateTipMediaSortOrder", param);
	        sqlSession.commit();
	        return result;
	    }
	}
}
