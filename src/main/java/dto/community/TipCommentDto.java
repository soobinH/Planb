package dto.community;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;

public class TipCommentDto {
	private Long commentId;			// 댓글 번호
	private Long tipId;				// 꿀팁 게시글 번호
	private Long userId;			// 작성 회원
	private String content;			// 댓글 내용
	private String status;			// 댓글 상태
	private LocalDateTime createdAt;// 작성 일시
	private LocalDateTime updatedAt;// 수정 일시
	private String nickname;
    private String profileImg;
    public String getProfileImg() { return profileImg; }
    public void setProfileImg(String profileImg) { this.profileImg = profileImg; }
	public TipCommentDto() {
		super();
		// TODO Auto-generated constructor stub
	}
	public TipCommentDto(Long commentId, Long tipId, Long userId, String content, String status,
			LocalDateTime createdAt, LocalDateTime updatedAt, String nickName) {
		super();
		this.commentId = commentId;
		this.tipId = tipId;
		this.userId = userId;
		this.content = content;
		this.status = status;
		this.createdAt = createdAt;
		this.updatedAt = updatedAt;
		this.nickname = nickName;
	}
	
	public String getTimeAgo() {
	    if (createdAt == null) {
	        return "";
	    }
	    LocalDateTime now = LocalDateTime.now();
	    long seconds = ChronoUnit.SECONDS.between(createdAt, now);
	    if (seconds < 0) {
	        seconds = 0;
	    }
	    if (seconds < 60) {
	        return seconds + "초 전";
	    }
	    long minutes = seconds / 60;
	    if (minutes < 60) {
	        return minutes + "분 전";
	    }
	    long hours = minutes / 60;
	    if (hours < 24) {
	        return hours + "시간 전";
	    }
	    long days = hours / 24;
	    if (days < 7) {
	        return days + "일 전";
	    }
	    return createdAt.format(DateTimeFormatter.ofPattern("yyyy.MM.dd") );
	}
	
	public boolean isEdited() {
	    if (createdAt == null || updatedAt == null) {
	        return false;
	    }
	    return updatedAt.isAfter(createdAt);
	}
	
	public Long getCommentId() {
		return commentId;
	}
	public void setCommentId(Long commentId) {
		this.commentId = commentId;
	}
	public Long getTipId() {
		return tipId;
	}
	public void setTipId(Long tipId) {
		this.tipId = tipId;
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
		return "TipCommentDto [commentId=" + commentId + ", tipId=" + tipId + ", userId=" + userId + ", content="
				+ content + ", status=" + status + ", createdAt=" + createdAt + ", updatedAt=" + updatedAt
				+ ", nickName=" + nickname + "]";
	}
}
