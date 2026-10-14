package dto.community;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;

public class TipDto {

	private Long tipId;				// 꿀팁 게시글 번호
	private Long userId;			// 작성 회원
	private String title;			// 제목
	private String content;			// 내용
	private String country;			// 여행 국가
	private String city;			// 여행 도시
	private String thumbnailImg;	// 대표 이미지
	private String visibility;		// 공개 설정 여부
	private int viewCount;			// 조회수
	private String status;			// 게시글 상태
	private Long deletedByUserId;	// 삭제 처리자
	private LocalDateTime deletedAt;// 삭제 일시
	private LocalDateTime createdAt;// 작성 일시
	private LocalDateTime updatedAt;// 수정 일시
	private String hashtag;			// 해시태그
	private String nickname;		// 작성자 닉네임
	private int likeCount;			// 좋아요 수
	private int commentCount;		// 댓글 수
	private String profileImg; 		// 작성자 프로필 이미지

	public TipDto() {
		super();
	}

	public TipDto(Long tipId, Long userId, String title, String content, String country, String city,
			String thumbnailImg, String visibility, int viewCount, String status, Long deletedByUserId,
			LocalDateTime deletedAt, LocalDateTime createdAt, LocalDateTime updatedAt, String hashtag,
			String nickname, int likeCount, int commentCount, String profileImg) {

		super();
		this.tipId = tipId;
		this.userId = userId;
		this.title = title;
		this.content = content;
		this.country = country;
		this.city = city;
		this.thumbnailImg = thumbnailImg;
		this.visibility = visibility;
		this.viewCount = viewCount;
		this.status = status;
		this.deletedByUserId = deletedByUserId;
		this.deletedAt = deletedAt;
		this.createdAt = createdAt;
		this.updatedAt = updatedAt;
		this.hashtag = hashtag;
		this.nickname = nickname;
		this.likeCount = likeCount;
		this.commentCount = commentCount;
		this.profileImg = profileImg;
	}

	public String getTimeAgo() {

		if (createdAt == null) {
			return "";
		}

		LocalDateTime now = LocalDateTime.now();

		long seconds = ChronoUnit.SECONDS.between(createdAt, now);

		if (seconds < 60) {
			return "방금 전";
		}

		long minutes = ChronoUnit.MINUTES.between(createdAt, now);

		if (minutes < 60) {
			return minutes + "분 전";
		}

		long hours = ChronoUnit.HOURS.between(createdAt, now);

		if (hours < 24) {
			return hours + "시간 전";
		}

		long days = ChronoUnit.DAYS.between(createdAt, now);

		if (days < 7) {
			return days + "일 전";
		}

		return createdAt.format(
			DateTimeFormatter.ofPattern("yyyy.MM.dd")
		);
	}

	public String[] getHashtagList() {

		if (hashtag == null || hashtag.trim().isEmpty()) {
			return new String[0];
		}

		return hashtag.trim().split("\\s+");
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

	public String getCountry() {
		return country;
	}

	public void setCountry(String country) {
		this.country = country;
	}

	public String getCity() {
		return city;
	}

	public void setCity(String city) {
		this.city = city;
	}

	public String getThumbnailImg() {
		return thumbnailImg;
	}

	public void setThumbnailImg(String thumbnailImg) {
		this.thumbnailImg = thumbnailImg;
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

	public String getHashtag() {
		return hashtag;
	}

	public void setHashtag(String hashtag) {
		this.hashtag = hashtag;
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
		return "TipDto [tipId=" + tipId + ", userId=" + userId + ", title=" + title + ", content=" + content
				+ ", country=" + country + ", city=" + city + ", thumbnailImg=" + thumbnailImg + ", visibility="
				+ visibility + ", viewCount=" + viewCount + ", status=" + status + ", deletedByUserId="
				+ deletedByUserId + ", deletedAt=" + deletedAt + ", createdAt=" + createdAt + ", updatedAt=" + updatedAt
				+ ", hashtag=" + hashtag + ", nickname=" + nickname + ", likeCount=" + likeCount + ", commentCount="
				+ commentCount + ", profileImg=" + profileImg + "]";
	}

}