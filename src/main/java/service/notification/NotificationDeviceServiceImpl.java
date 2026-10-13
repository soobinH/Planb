package service.notification;

import org.apache.ibatis.session.SqlSession;

import config.MybatisSqlSessionFactory;
import dao.notification.NotificationDeviceDao;
import dao.notification.NotificationDeviceDaoImpl;
import dto.notification.NotificationDeviceDto;

public class NotificationDeviceServiceImpl implements NotificationDeviceService {

	private final NotificationDeviceDao deviceDao = new NotificationDeviceDaoImpl();

	@Override
	public void registerDevice(Long userId, String installationId) throws Exception {

		NotificationDeviceDto device = makeDevice(userId, installationId);

		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession(false)) {

			try {
				deviceDao.saveNotificationDevice(sqlSession, device);
				sqlSession.commit();

			} catch (Exception e) {
				sqlSession.rollback();
				throw e;
			}
		}
	}

	@Override
	public void removeDevice(Long userId, String installationId) throws Exception {

		NotificationDeviceDto device = makeDevice(userId, installationId);

		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession(false)) {

			try {
				deviceDao.deleteNotificationDevice(sqlSession, device);
				sqlSession.commit();

			} catch (Exception e) {
				sqlSession.rollback();
				throw e;
			}
		}
	}

	private NotificationDeviceDto makeDevice(Long userId, String installationId) {

		if (userId == null || userId <= 0) {
			throw new SecurityException("로그인이 필요합니다.");
		}

		String normalizedId = installationId == null ? "" : installationId.trim();

		if (!normalizedId.matches("[A-Za-z0-9_-]{1,128}")) {
			throw new IllegalArgumentException("Firebase 등록번호가 올바르지 않습니다.");
		}

		NotificationDeviceDto device = new NotificationDeviceDto();

		device.setUserId(userId);
		device.setInstallationId(normalizedId);

		return device;
	}
}