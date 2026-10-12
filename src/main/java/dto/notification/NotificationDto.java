package dto.notification;

import java.sql.Timestamp;

public class NotificationDto {

	private Long notificationId;
	private Long recipientUserId;
	private Long senderUserId;

	private String notificationType;
	private String targetType;
	private Long targetId;
	private Long sourceCommentId;

	private boolean read;
	private Timestamp readAt;
	private Timestamp createdAt;

	// TB_USER JOIN으로 가져오는 화면 표시용 값
	private String senderNickname;

	public Long getNotificationId() {
		return notificationId;
	}

	public void setNotificationId(Long notificationId) {
		this.notificationId = notificationId;
	}

	public Long getRecipientUserId() {
		return recipientUserId;
	}

	public void setRecipientUserId(Long recipientUserId) {
		this.recipientUserId = recipientUserId;
	}

	public Long getSenderUserId() {
		return senderUserId;
	}

	public void setSenderUserId(Long senderUserId) {
		this.senderUserId = senderUserId;
	}

	public String getNotificationType() {
		return notificationType;
	}

	public void setNotificationType(String notificationType) {
		this.notificationType = notificationType;
	}

	public String getTargetType() {
		return targetType;
	}

	public void setTargetType(String targetType) {
		this.targetType = targetType;
	}

	public Long getTargetId() {
		return targetId;
	}

	public void setTargetId(Long targetId) {
		this.targetId = targetId;
	}

	public Long getSourceCommentId() {
		return sourceCommentId;
	}

	public void setSourceCommentId(Long sourceCommentId) {
		this.sourceCommentId = sourceCommentId;
	}

	public boolean isRead() {
		return read;
	}

	public void setRead(boolean read) {
		this.read = read;
	}

	public Timestamp getReadAt() {
		return readAt;
	}

	public void setReadAt(Timestamp readAt) {
		this.readAt = readAt;
	}

	public Timestamp getCreatedAt() {
		return createdAt;
	}

	public void setCreatedAt(Timestamp createdAt) {
		this.createdAt = createdAt;
	}

	public String getSenderNickname() {
		return senderNickname;
	}

	public void setSenderNickname(String senderNickname) {
		this.senderNickname = senderNickname;
	}

	@Override
	public String toString() {
		return "NotificationDto [notificationId=" + notificationId + ", recipientUserId=" + recipientUserId
				+ ", senderUserId=" + senderUserId + ", notificationType=" + notificationType + ", targetType="
				+ targetType + ", targetId=" + targetId + ", sourceCommentId=" + sourceCommentId + ", read=" + read
				+ ", readAt=" + readAt + ", createdAt=" + createdAt + ", senderNickname=" + senderNickname + "]";
	}

	// 화면에 표시할 알림 제목
	public String getLabel() {

		if ("REPORT_RECEIVED".equals(notificationType)) {
			return "신고 접수";
		}

		if ("COMMENT".equals(notificationType)) {
			return "새 댓글";
		}

		if ("ITINERARY_LIKE".equals(notificationType) || "TIP_LIKE".equals(notificationType)
				|| "MATE_LIKE".equals(notificationType)) {
			return "새 좋아요";
		}

		return "알림";
	}

	// 최신 닉네임과 유형으로 문구 생성
	public String getMessage() {

		String nickname = senderNickname == null || senderNickname.isBlank() ? "탈퇴한 회원" : senderNickname;

		if ("REPORT_RECEIVED".equals(notificationType)) {
			return nickname + "님이 신고를 접수했습니다.";
		}

		String target;

		if ("ITINERARY".equals(targetType)) {
			target = "여행 일정";
		} else if ("TIP".equals(targetType)) {
			target = "여행 꿀팁";
		} else if ("MATE".equals(targetType)) {
			target = "메이트 게시글";
		} else {
			target = "게시글";
		}

		if ("COMMENT".equals(notificationType)) {
			return nickname + "님이 내 " + target + "에 댓글을 남겼습니다.";
		}

		if ("ITINERARY_LIKE".equals(notificationType) || "TIP_LIKE".equals(notificationType)
				|| "MATE_LIKE".equals(notificationType)) {
			return nickname + "님이 내 " + target + "에 좋아요를 눌렀습니다.";
		}

		return "새 알림이 있습니다.";
	}
}