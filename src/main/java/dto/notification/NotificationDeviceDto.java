package dto.notification;

import java.sql.Timestamp;

public class NotificationDeviceDto {

    private String installationId;
    private Long userId;
    private Timestamp lastSeenAt;

    
    
    public NotificationDeviceDto() {
		super();
		// TODO Auto-generated constructor stub
	}

    
    
	public NotificationDeviceDto(String installationId, Long userId, Timestamp lastSeenAt) {
		super();
		this.installationId = installationId;
		this.userId = userId;
		this.lastSeenAt = lastSeenAt;
	}



	public String getInstallationId() {
        return installationId;
    }

    public void setInstallationId(String installationId) {
        this.installationId = installationId;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public Timestamp getLastSeenAt() {
        return lastSeenAt;
    }

    public void setLastSeenAt(Timestamp lastSeenAt) {
        this.lastSeenAt = lastSeenAt;
    }



	@Override
	public String toString() {
		return "NotificationDeviceDto [installationId=" + installationId + ", userId=" + userId + ", lastSeenAt="
				+ lastSeenAt + "]";
	}
    
}