package dao.notification;

import java.util.List;

import org.apache.ibatis.session.SqlSession;

import dto.notification.NotificationDto;

public interface NotificationDao {

	List<NotificationDto> selectRecentNotifications(SqlSession sqlSession, Long recipientUserId) throws Exception;

	List<NotificationDto> selectUnreadNotifications(SqlSession sqlSession, Long recipientUserId) throws Exception;

	List<NotificationDto> selectNotificationPage(SqlSession sqlSession, Long recipientUserId) throws Exception;

	long countUnreadNotifications(SqlSession sqlSession, Long recipientUserId) throws Exception;

	NotificationDto selectNotification(SqlSession sqlSession, Long notificationId, Long recipientUserId)
			throws Exception;

	int markNotificationRead(SqlSession sqlSession, Long notificationId, Long recipientUserId) throws Exception;

	int markAllNotificationsRead(SqlSession sqlSession, Long recipientUserId) throws Exception;

	int insertCommentNotification(SqlSession sqlSession, NotificationDto notification) throws Exception;

	int insertLikeNotification(SqlSession sqlSession, NotificationDto notification) throws Exception;

	int insertReportNotificationsForAdmins(SqlSession sqlSession, Long reportId, Long reporterUserId) throws Exception;
}