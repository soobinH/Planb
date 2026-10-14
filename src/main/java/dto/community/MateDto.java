package dto.community;

import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;

public class MateDto {
	private Long mateId;				// 메이트 게시글 번호
	private Long userId;				// 작성 회원
	private String title;				// 제목
	private String content;				// 내용
	private String img;					// 대표 이미지
	private String visibility;			// 공개 설정 여부
	private int viewCount;				// 조회수
	private String status;				// 게시글 상태
	private Long deletedByUserId;		// 삭제 처리자
	private LocalDateTime deletedAt;	// 삭제 일시
	private LocalDateTime createdAt;	// 작성 일시
	private LocalDateTime updatedAt;	// 수정 일시
	private String country;				// 나라
	private int recruitCount;			// 모집 인원
	private String recruitStatus;		// 모집 상태
	private String nickname;
	private int likeCount;
	private int commentCount;
	private String profileImg; // 작성자 프로필 이미지
	
	public MateDto() {
		super();
		// TODO Auto-generated constructor stub
	}
	public MateDto(Long mateId, Long userId, String title, String content, String img, String visibility, int viewCount,
			String status, Long deletedByUserId, LocalDateTime deletedAt, LocalDateTime createdAt,
			LocalDateTime updatedAt, String country, int recruitCount, String recruitStatus, String nickname, 
			int likeCount, int commentCount, String profileImg) {
		super();
		this.mateId = mateId;
		this.userId = userId;
		this.title = title;
		this.content = content;
		this.img = img;
		this.visibility = visibility;
		this.viewCount = viewCount;
		this.status = status;
		this.deletedByUserId = deletedByUserId;
		this.deletedAt = deletedAt;
		this.createdAt = createdAt;
		this.updatedAt = updatedAt;
		this.country = country;
		this.recruitCount = recruitCount;
		this.recruitStatus = recruitStatus;
		this.nickname = nickname;
		this.likeCount = likeCount;
		this.commentCount = commentCount;
		this.profileImg = profileImg;
	}
	
	public String getTimeAgo() {
		if (createdAt == null) {
			return "";
		}

		long seconds = ChronoUnit.SECONDS.between(createdAt, LocalDateTime.now());

		if (seconds < 0) seconds = 0;
		if (seconds < 60) return seconds + "초 전";

		long minutes = seconds / 60;
		if (minutes < 60) return minutes + "분 전";

		long hours = minutes / 60;
		if (hours < 24) return hours + "시간 전";

		long days = hours / 24;
		if (days < 30) return days + "일 전";

		long months = days / 30;
		if (months < 12) return months + "개월 전";

		return (months / 12) + "년 전";
	}
	
	public String getFormattedCreatedAt() {
		if (createdAt == null) {
			return "";
		}

		return createdAt.format(java.time.format.DateTimeFormatter.ofPattern("yyyy.MM.dd"));
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
	public String getTitle() {
		return title;
	}
	public void setTitle(String title) {
		this.title = title;
	}
	public String getContent() {
		return content;
	}
	public void setContent(String content) {
		this.content = content;
	}
	public String getImg() {
		return img;
	}
	public void setImg(String img) {
		this.img = img;
	}
	public String getVisibility() {
		return visibility;
	}
	public void setVisibility(String visibility) {
		this.visibility = visibility;
	}
	public int getViewCount() {
		return viewCount;
	}
	public void setViewCount(int viewCount) {
		this.viewCount = viewCount;
	}
	public String getStatus() {
		return status;
	}
	public void setStatus(String status) {
		this.status = status;
	}
	public Long getDeletedByUserId() {
		return deletedByUserId;
	}
	public void setDeletedByUserId(Long deletedByUserId) {
		this.deletedByUserId = deletedByUserId;
	}
	public LocalDateTime getDeletedAt() {
		return deletedAt;
	}
	public void setDeletedAt(LocalDateTime deletedAt) {
		this.deletedAt = deletedAt;
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
	public String getCountry() {
		return country;
	}
	public void setCountry(String country) {
		this.country = country;
	}
	public int getRecruitCount() {
		return recruitCount;
	}
	public void setRecruitCount(int recruitCount) {
		this.recruitCount = recruitCount;
	}
	public String getRecruitStatus() {
		return recruitStatus;
	}
	public void setRecruitStatus(String recruitStatus) {
		this.recruitStatus = recruitStatus;
	}
	public String getNickname() {
		return nickname;
	}
	public void setNickname(String nickname) {
		this.nickname = nickname;
	}
	
	public int getLikeCount() {
		return likeCount;
	}
	public void setLikeCount(int likeCount) {
		this.likeCount = likeCount;
	}
	public int getCommentCount() {
		return commentCount;
	}
	public void setCommentCount(int commentCount) {
		this.commentCount = commentCount;
	}
	
	public String getProfileImg() {
	    return profileImg;
	}

	public void setProfileImg(String profileImg) {
	    this.profileImg = profileImg;
	}
	@Override
	public String toString() {
		return "MateDto [mateId=" + mateId + ", userId=" + userId + ", title=" + title + ", content=" + content
				+ ", img=" + img + ", visibility=" + visibility + ", viewCount=" + viewCount + ", status=" + status
				+ ", deletedByUserId=" + deletedByUserId + ", deletedAt=" + deletedAt + ", createdAt=" + createdAt
				+ ", updatedAt=" + updatedAt + ", country=" + country + ", recruitCount=" + recruitCount
				+ ", recruitStatus=" + recruitStatus + ", nickname=" + nickname + ", likeCount=" + likeCount
				+ ", commentCount=" + commentCount + ", profileImg=" + profileImg + "]";
	}
	
}
