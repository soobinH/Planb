package dao.notification;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.ibatis.session.SqlSession;

import dto.notification.NotificationDto;

public class NotificationDaoImpl implements NotificationDao {

	private static final String NAMESPACE = "mapper.notification.notification.";

	@Override
	public List<NotificationDto> selectRecentNotifications(SqlSession sqlSession, Long recipientUserId)
			throws Exception {

		return sqlSession.selectList(NAMESPACE + "selectRecentNotifications", recipientUserId);
	}

	@Override
	public List<NotificationDto> selectUnreadNotifications(SqlSession sqlSession, Long recipientUserId)
			throws Exception {

		return sqlSession.selectList(NAMESPACE + "selectUnreadNotifications", recipientUserId);
	}

	@Override
	public List<NotificationDto> selectNotificationPage(SqlSession sqlSession, Long recipientUserId, Long beforeNotificationId)
			throws Exception {
        return selectNotificationPage(sqlSession, recipientUserId, beforeNotificationId, "all");
    }

    @Override
    public List<NotificationDto> selectNotificationPage(SqlSession sqlSession, Long recipientUserId,
            Long beforeNotificationId, String readFilter) throws Exception {
        Map<String, Object> params = new HashMap<>();
        params.put("recipientUserId", recipientUserId);
        params.put("beforeNotificationId", beforeNotificationId);
        params.put("readFilter", readFilter);
		return sqlSession.selectList(NAMESPACE + "selectNotificationPage", params);
	}

	@Override
	public long countUnreadNotifications(SqlSession sqlSession, Long recipientUserId) throws Exception {

		return sqlSession.selectOne(NAMESPACE + "countUnreadNotifications", recipientUserId);
	}

	@Override
	public NotificationDto selectNotification(SqlSession sqlSession, Long notificationId, Long recipientUserId)
			throws Exception {

		return sqlSession.selectOne(NAMESPACE + "selectNotification",
				notificationParams(notificationId, recipientUserId));
	}

	@Override
	public int markNotificationRead(SqlSession sqlSession, Long notificationId, Long recipientUserId) throws Exception {

		return sqlSession.update(NAMESPACE + "markNotificationRead",
				notificationParams(notificationId, recipientUserId));
	}

	@Override
	public int markAllNotificationsRead(SqlSession sqlSession, Long recipientUserId) throws Exception {

		return sqlSession.update(NAMESPACE + "markAllNotificationsRead", recipientUserId);
	}

	@Override
	public int insertCommentNotification(SqlSession sqlSession, NotificationDto notification) throws Exception {

		return sqlSession.insert(NAMESPACE + "insertCommentNotification", notification);
	}

	@Override
	public int insertLikeNotification(SqlSession sqlSession, NotificationDto notification) throws Exception {

		return sqlSession.insert(NAMESPACE + "insertLikeNotification", notification);
	}

	@Override
	public int insertReportNotificationsForAdmins(SqlSession sqlSession, Long reportId, Long reporterUserId)
			throws Exception {

		Map<String, Object> params = new HashMap<>();
		params.put("reportId", reportId);
		params.put("reporterUserId", reporterUserId);

		return sqlSession.insert(NAMESPACE + "insertReportNotificationsForAdmins", params);
	}

	private Map<String, Object> notificationParams(Long notificationId, Long recipientUserId) {

		Map<String, Object> params = new HashMap<>();

		params.put("notificationId", notificationId);
		params.put("recipientUserId", recipientUserId);

		return params;
	}
}