package dto.community;

import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;

public class MateCommentDto {
	private Long commentId;				// 댓글 번호
	private Long mateId;				// 메이트 게시글 번호
	private Long userId;				// 작성 회원
	private String content;				// 댓글 내용
	private String status;				// 댓글 상태
	private LocalDateTime createdAt;	// 작성 일시
	private LocalDateTime updatedAt;	// 수정 일시
	// TB_USER JOIN용
	private String nickname;
    private String profileImg;
    public String getProfileImg() { return profileImg; }
    public void setProfileImg(String profileImg) { this.profileImg = profileImg; }
	
	public MateCommentDto() {
		super();
		// TODO Auto-generated constructor stub
	}
	
	public MateCommentDto(Long commentId, Long mateId, Long userId, String content, String status,
			LocalDateTime createdAt, LocalDateTime updatedAt, String nickname) {
		super();
		this.commentId = commentId;
		this.mateId = mateId;
		this.userId = userId;
		this.content = content;
		this.status = status;
		this.createdAt = createdAt;
		this.updatedAt = updatedAt;
		this.nickname = nickname;
	}
	
	public String getTimeAgo() {
		if (createdAt == null) return "";

		long seconds = ChronoUnit.SECONDS.between(createdAt, LocalDateTime.now());

		if (seconds < 60) return Math.max(seconds, 0) + "초 전";

		long minutes = ChronoUnit.MINUTES.between(createdAt, LocalDateTime.now());

		if (minutes < 60) return minutes + "분 전";

		long hours = ChronoUnit.HOURS.between(createdAt, LocalDateTime.now());

		if (hours < 24) return hours + "시간 전";

		long days = ChronoUnit.DAYS.between(createdAt, LocalDateTime.now());

		return days + "일 전";
	}
	
	public boolean isEdited() {
		if (createdAt == null || updatedAt == null) return false;

		return updatedAt.isAfter(createdAt);
	}
	
	public Long getCommentId() {
		return commentId;
	}
	public void setCommentId(Long commentId) {
		this.commentId = commentId;
	}
	public Long getMateId() {
		return mateId;
	}
	public void setMateId(Long mateId) {
		this.mateId = mateId;
	}
	public Long getUserId() {
		return userId;
	}
	public void setUserId(Long userId) {
		this.userId = userId;
	}
	public String getContent() {
		return content;
	}
	public void setContent(String content) {
		this.content = content;
	}
	public String getStatus() {
		return status;
	}
	public void setStatus(String status) {
		this.status = status;
	}
	public LocalDateTime getCreatedAt() {
		return createdAt;
	}
	public void setCreatedAt(LocalDateTime createdAt) {
		this.createdAt = createdAt;
	}
	public LocalDateTime getUpdatedAt() {
		return updatedAt;
	}
	public void setUpdatedAt(LocalDateTime updatedAt) {
		this.updatedAt = updatedAt;
	}
	
	public String getNickname() {
		return nickname;
	}

	public void setNickname(String nickname) {
		this.nickname = nickname;
	}

	@Override
	public String toString() {
		return "MateCommentDto [commentId=" + commentId + ", mateId=" + mateId + ", userId=" + userId + ", content="
				+ content + ", status=" + status + ", createdAt=" + createdAt + ", updatedAt=" + updatedAt
				+ ", nickname=" + nickname + "]";
	}
	
}
