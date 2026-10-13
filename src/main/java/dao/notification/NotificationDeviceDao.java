package dao.notification;

import java.util.List;

import org.apache.ibatis.session.SqlSession;

import dto.notification.NotificationDeviceDto;

public interface NotificationDeviceDao {

	int saveNotificationDevice(SqlSession sqlSession, NotificationDeviceDto device) throws Exception;

	List<NotificationDeviceDto> selectNotificationDevices(SqlSession sqlSession, Long userId) throws Exception;

	int deleteNotificationDevice(SqlSession sqlSession, NotificationDeviceDto device) throws Exception;
}