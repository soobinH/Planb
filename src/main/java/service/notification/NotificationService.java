package service.notification;

import java.util.List;
import java.util.Map;

public interface NotificationService {

	// 헤더 드롭다운: 최신 알림 3개와 읽지 않은 알림 수
	Map<String, Object> getHeaderNotifications(Long recipientUserId) throws Exception;

	// 알림 전체보기: 읽지 않은 알림만 조회
	List<Map<String, Object>> getUnreadNotifications(Long recipientUserId) throws Exception;

	// 알림 하나 읽음 처리
	boolean markAsRead(Long notificationId, Long recipientUserId) throws Exception;

	// 해당 회원의 읽지 않은 알림 전체 읽음 처리
	int markAllAsRead(Long recipientUserId) throws Exception;
}