package dao.community;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.ibatis.session.SqlSession;

import config.MybatisSqlSessionFactory;
import dto.community.MateMediaDto;

public class MateMediaDaoImpl implements MateMediaDao {

	@Override
	public int insertMateMedia(MateMediaDto mateMediaDto) {

		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {

			int result =
				sqlSession.insert(
					"mapper.community.mateMedia.insertMateMedia",
					mateMediaDto
				);

			if (result > 0) {
				sqlSession.commit();
			}

			return result;

		} catch (Exception e) {

			e.printStackTrace();
			throw e;
		}
	}

	@Override
	public MateMediaDto selectMateMedia(Long mediaId) {

		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {

			return sqlSession.selectOne(
				"mapper.community.mateMedia.selectMateMedia",
				mediaId
			);

		} catch (Exception e) {

			e.printStackTrace();
			throw e;
		}
	}

	@Override
	public int updateMateMedia(MateMediaDto mateMediaDto) {

		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {

			int result =
				sqlSession.update(
					"mapper.community.mateMedia.updateMateMedia",
					mateMediaDto
				);

			if (result > 0) {
				sqlSession.commit();
			}

			return result;

		} catch (Exception e) {

			e.printStackTrace();
			throw e;
		}
	}

	@Override
	public int deleteMateMedia(long mediaId, long mateId) {

		Map<String, Object> param =
			new HashMap<>();

		param.put("mediaId", mediaId);
		param.put("mateId", mateId);

		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {

			int result =
				sqlSession.delete(
					"mapper.community.mateMedia.deleteMateMedia",
					param
				);

			if (result > 0) {
				sqlSession.commit();
			}

			return result;

		} catch (Exception e) {

			e.printStackTrace();
			throw e;
		}
	}

	@Override
	public int deleteMateMediaByMateId(long mateId) {

		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {

			int result =
				sqlSession.delete(
					"mapper.community.mateMedia.deleteMateMediaByMateId",
					mateId
				);

			if (result > 0) {
				sqlSession.commit();
			}

			return result;

		} catch (Exception e) {

			e.printStackTrace();
			throw e;
		}
	}

	@Override
	public List<MateMediaDto> selectMateMediaList(Long mateId) {

		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {

			return sqlSession.selectList(
				"mapper.community.mateMedia.selectMateMediaList",
				mateId
			);

		} catch (Exception e) {

			e.printStackTrace();
			throw e;
		}
	}

	@Override
	public MateMediaDto selectFirstMateMedia(long mateId) {

		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {

			return sqlSession.selectOne(
				"mapper.community.mateMedia.selectFirstMateMedia",
				mateId
			);
		}
	}

	@Override
	public int updateMateMediaSortOrder(long mediaId, long mateId, int sortOrder) {

		Map<String, Object> param = new HashMap<>();

		param.put("mediaId", mediaId);
		param.put("mateId", mateId);
		param.put("sortOrder", sortOrder);

		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {

			int result = sqlSession.update("mapper.community.mateMedia.updateMateMediaSortOrder", param);

			sqlSession.commit();

			return result;
		}
	}
}