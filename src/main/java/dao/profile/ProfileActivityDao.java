package dao.profile;

import java.util.List;
import java.util.Map;

import dto.profile.ProfileActivityDto;

public interface ProfileActivityDao {
	List<ProfileActivityDto> selectProfileActivities(long userId) throws Exception;

    List<ProfileActivityDto> selectProfileActivitiesPage(Map<String, Object> params) throws Exception;
    int countProfileActivities(long userId, String filter) throws Exception;
}
