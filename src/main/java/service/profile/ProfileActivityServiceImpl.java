package service.profile;

import java.util.List;
import java.util.Map;
import java.util.HashMap;
import java.util.ArrayList;
import java.util.Base64;
import java.nio.charset.StandardCharsets;
import java.sql.Timestamp;

import dao.profile.ProfileActivityDao;
import dao.profile.ProfileActivityDaoImpl;
import dto.profile.ProfileActivityDto;

public class ProfileActivityServiceImpl implements ProfileActivityService {
	private ProfileActivityDao activityDao;

	public ProfileActivityServiceImpl() {

		activityDao = new ProfileActivityDaoImpl();
	}

	@Override
	public List<ProfileActivityDto> getProfileActivities(long userId) throws Exception {
		return activityDao.selectProfileActivities(userId);
	}


    @Override
    public Map<String, Object> getProfileActivityPage(long userId, String filter, String cursor) throws Exception {
        if (userId <= 0) throw new SecurityException("로그인 후 이용할 수 있습니다.");
        String selected = "POST".equals(filter) || "COMMENT".equals(filter) ? filter : "ALL";
        Map<String, Object> params = new HashMap<>();
        params.put("userId", userId);
        params.put("filter", selected);
        if (cursor != null && !cursor.isEmpty()) {
            try {
                String[] parts = new String(Base64.getUrlDecoder().decode(cursor), StandardCharsets.UTF_8).split("\\|", -1);
                if (parts.length != 3 || !parts[1].matches("TIP_POST|MATE_POST|TIP_COMMENT|MATE_COMMENT|ITINERARY_COMMENT")) {
                    throw new IllegalArgumentException();
                }
                long beforeId = Long.parseLong(parts[2]);
                if (beforeId <= 0) throw new IllegalArgumentException();
                params.put("beforeCreatedAt", Timestamp.valueOf(parts[0]));
                params.put("beforeType", parts[1]);
                params.put("beforeId", beforeId);
            } catch (IllegalArgumentException e) {
                throw new IllegalArgumentException("올바른 활동 목록 요청이 아닙니다.", e);
            }
        }
        List<ProfileActivityDto> rows = activityDao.selectProfileActivitiesPage(params);
        boolean hasMore = rows.size() > 10;
        List<ProfileActivityDto> activities = new ArrayList<>(rows.subList(0, Math.min(10, rows.size())));
        String nextCursor = "";
        if (hasMore) {
            ProfileActivityDto last = activities.get(activities.size() - 1);
            String key = last.getCreatedAt().toString() + "|" + last.getActivityType() + "|" + last.getActivityId();
            nextCursor = Base64.getUrlEncoder().withoutPadding().encodeToString(key.getBytes(StandardCharsets.UTF_8));
        }
        int postCount = activityDao.countProfileActivities(userId, "POST");
        int commentCount = activityDao.countProfileActivities(userId, "COMMENT");
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("activities", activities);
        result.put("hasMore", hasMore);
        result.put("nextCursor", nextCursor);
        result.put("postCount", postCount);
        result.put("commentCount", commentCount);
        result.put("totalCount", postCount + commentCount);
        result.put("filter", selected);
        return result;
    }
}
