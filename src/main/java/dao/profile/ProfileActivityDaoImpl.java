package dao.profile;

import java.util.List;
import java.util.Map;
import java.util.HashMap;

import org.apache.ibatis.session.SqlSession;

import config.MybatisSqlSessionFactory;
import dto.profile.ProfileActivityDto;

public class ProfileActivityDaoImpl implements ProfileActivityDao {

	@Override
	public List<ProfileActivityDto> selectProfileActivities(long userId) throws Exception {
		SqlSession session= null;
		
		try {
			session = MybatisSqlSessionFactory.getSqlSessionFactory().openSession();
			return session.selectList("mapper.profile.profileFeed.selectProfileActivities", userId);
		} finally {
			if(session != null) {
				session.close();
			}
		}
	}


    @Override
    public List<ProfileActivityDto> selectProfileActivitiesPage(Map<String, Object> params) throws Exception {
        try (SqlSession session = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {
            return session.selectList("mapper.profile.profileFeed.selectProfileActivitiesPage", params);
        }
    }

    @Override
    public int countProfileActivities(long userId, String filter) throws Exception {
        Map<String, Object> params = new HashMap<>();
        params.put("userId", userId);
        params.put("filter", filter);
        try (SqlSession session = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {
            return session.selectOne("mapper.profile.profileFeed.countProfileActivities", params);
        }
    }
}
