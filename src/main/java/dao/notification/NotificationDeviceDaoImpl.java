package dao.notification;

import java.util.List;

import org.apache.ibatis.session.SqlSession;

import dto.notification.NotificationDeviceDto;

public class NotificationDeviceDaoImpl implements NotificationDeviceDao {

	private static final String NAMESPACE = "mapper.notification.notificationDevice.";

	@Override
	public int saveNotificationDevice(SqlSession sqlSession, NotificationDeviceDto device) throws Exception {

		return sqlSession.insert(NAMESPACE + "saveNotificationDevice", device);
	}

	@Override
	public List<NotificationDeviceDto> selectNotificationDevices(SqlSession sqlSession, Long userId) throws Exception {

		return sqlSession.selectList(NAMESPACE + "selectNotificationDevices", userId);
	}

	@Override
	public int deleteNotificationDevice(SqlSession sqlSession, NotificationDeviceDto device) throws Exception {

		return sqlSession.delete(NAMESPACE + "deleteNotificationDevice", device);
	}
}