package service.profile;

import java.util.List;
import java.util.Map;

import dto.profile.ProfileActivityDto;

public interface ProfileActivityService {
	List<ProfileActivityDto> getProfileActivities(long userId) throws Exception;

    Map<String, Object> getProfileActivityPage(long userId, String filter, String cursor) throws Exception;
}
