package service.notification;

public interface NotificationDeviceService {

	void registerDevice(Long userId, String installationId) throws Exception;

	void removeDevice(Long userId, String installationId) throws Exception;
}