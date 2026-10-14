package service.notification;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.ibatis.session.SqlSession;

import config.MybatisSqlSessionFactory;
import dao.notification.NotificationDao;
import dao.notification.NotificationDaoImpl;
import dto.notification.NotificationDto;

public class NotificationServiceImpl implements NotificationService {

	private final NotificationDao notificationDao = new NotificationDaoImpl();

	@Override
	public Map<String, Object> getHeaderNotifications(Long recipientUserId) throws Exception {

		validateUserId(recipientUserId);

		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {

			List<NotificationDto> notifications = notificationDao.selectRecentNotifications(sqlSession,
					recipientUserId);

			long unreadCount = notificationDao.countUnreadNotifications(sqlSession, recipientUserId);

			List<Map<String, Object>> recentNotifications = toResponseList(notifications);

			Map<String, Object> result = new HashMap<>();
			result.put("recentNotifications", recentNotifications);
			result.put("unreadCount", unreadCount);

			return result;
		}
	}

	@Override
	public List<Map<String, Object>> getUnreadNotifications(Long recipientUserId) throws Exception {

		validateUserId(recipientUserId);

		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {

			List<NotificationDto> notifications = notificationDao.selectUnreadNotifications(sqlSession,
					recipientUserId);

			return toResponseList(notifications);
		}
	}

	@Override
	public Map<String, Object> getNotificationPage(Long recipientUserId) throws Exception {
		validateUserId(recipientUserId);
		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {
			List<NotificationDto> notifications =
					notificationDao.selectNotificationPage(sqlSession, recipientUserId);
			Map<String, Object> result = new HashMap<>();
			result.put("notifications", toResponseList(notifications));
			result.put("unreadCount", notificationDao.countUnreadNotifications(sqlSession, recipientUserId));
			return result;
		}
	}

	@Override
	public boolean markAsRead(Long notificationId, Long recipientUserId) throws Exception {

		validateUserId(recipientUserId);

		if (notificationId == null || notificationId <= 0) {
			throw new IllegalArgumentException("올바르지 않은 알림 번호입니다.");
		}

		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession(false)) {

			try {
				// 요청한 알림이 이 회원의 알림인지 먼저 확인
				NotificationDto notification = notificationDao.selectNotification(sqlSession, notificationId,
						recipientUserId);

				if (notification == null) {
					sqlSession.rollback();
					return false;
				}

				// 이미 읽은 알림이면 성공으로 처리
				if (notification.isRead()) {
					sqlSession.commit();
					return true;
				}

				notificationDao.markNotificationRead(sqlSession, notificationId, recipientUserId);

				sqlSession.commit();
				return true;

			} catch (Exception e) {
				sqlSession.rollback();
				throw e;
			}
		}
	}

	@Override
	public int markAllAsRead(Long recipientUserId) throws Exception {

		validateUserId(recipientUserId);

		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession(false)) {

			try {
				int updatedCount = notificationDao.markAllNotificationsRead(sqlSession, recipientUserId);

				sqlSession.commit();
				return updatedCount;

			} catch (Exception e) {
				sqlSession.rollback();
				throw e;
			}
		}
	}

	private List<Map<String, Object>> toResponseList(List<NotificationDto> notifications) {

		List<Map<String, Object>> result = new ArrayList<>();

		for (NotificationDto notification : notifications) {
			Map<String, Object> item = new HashMap<>();

			item.put("notificationId", notification.getNotificationId());
			item.put("notificationType", notification.getNotificationType());
			item.put("targetType", notification.getTargetType());
			item.put("targetId", notification.getTargetId());
			item.put("message", notification.getMessage());
			item.put("label", notification.getLabel());
			item.put("read", notification.isRead());
			item.put("createdAt", notification.getCreatedAt());
			item.put("targetUrl", makeTargetUrl(notification));

			result.add(item);
		}

		return result;
	}

	private String makeTargetUrl(NotificationDto notification) {
		String targetType = notification.getTargetType();
		Long targetId = notification.getTargetId();

		if (targetType == null || targetId == null) {
			return "#";
		}

		switch (targetType) {
		case "ITINERARY":
			return "/schedules/detail?id=" + targetId;

		case "TIP":
			return "/tipDetail?tipId=" + targetId;

		case "MATE":
			return "/mateDetail?mateId=" + targetId;

		case "REPORT":
			return "/admin/reports";

		default:
			return "#";
		}
	}

	private void validateUserId(Long userId) {
		if (userId == null || userId <= 0) {
			throw new SecurityException("로그인이 필요한 기능입니다.");
		}
	}
}