package service.notification;

import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.apache.ibatis.session.SqlSession;

import config.MybatisSqlSessionFactory;
import dao.notification.NotificationDeviceDao;
import dao.notification.NotificationDeviceDaoImpl;
import dto.notification.NotificationDeviceDto;
import util.firebase.FirebaseMessagingClient;

public class NotificationPushServiceImpl implements NotificationPushService {

	private static final Logger LOGGER = Logger.getLogger(NotificationPushServiceImpl.class.getName());

	private final NotificationDeviceDao deviceDao = new NotificationDeviceDaoImpl();

	@Override
	public void refreshUser(Long userId) {
		if (userId == null || userId <= 0) {
			return;
		}

		List<NotificationDeviceDto> devices;

		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {

			devices = deviceDao.selectNotificationDevices(sqlSession, userId);

		} catch (Exception e) {
			LOGGER.log(Level.WARNING, "Firebase 수신 브라우저 조회 실패", e);
			return;
		}

		System.out.println(
		        "[Firebase] 수신 브라우저 수: " + devices.size());
		
		// DB 세션을 종료한 뒤 외부 API 호출
		for (NotificationDeviceDto device : devices) {
			try {
				boolean accepted = FirebaseMessagingClient.sendRefresh(device.getInstallationId());

				System.out.println(
				        "[Firebase] 메시지 접수 결과: " + accepted);
				
				if (!accepted) {
					removeUnregisteredDevice(device);
				}

			} catch (Exception e) {
				LOGGER.log(Level.WARNING, "Firebase 갱신 메시지 발송 실패", e);

				if (Thread.currentThread().isInterrupted()) {
					return;
				}
			}
		}
	}

	private void removeUnregisteredDevice(NotificationDeviceDto device) throws Exception {

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
}