package dto.itinerary;

import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Timestamp;
import java.util.List;

public class ItineraryDto {
	private Long itineraryId;              // 일정 고유번호
	private Long userId;                   // 작성 회원
	private String title;                  // 여행 제목
    private String summary;                // 일정 소개
    private String continent;              // 대륙
    private String country;                // 나라
    private String city;                   // 도시 (선택)

    private Integer travelerCount;         // 여행 인원수, DB DEFAULT 1
    
    private Date startDate;                // 시작일 (선택)
    private Date endDate;                  // 종료일 (선택)
	
    private BigDecimal totalBudget;        // 총 예산
    private String visibility;             // PUBLIC / PRIVATE
    private String thumbnailImg;           // 대표 이미지
    
    private Integer viewCount;             // 조회수
    private Long sourceItineraryId;        // 원본 일정 번호
    private String status;                 // ACTIVE / DELETED
    
    private Long deletedByUserId;          // 삭제 처리자
    private Timestamp deletedAt;           // 삭제 일시
    private Timestamp createdAt;           // 작성 일시
    private Timestamp updatedAt;           // 수정 일시
    
    private String nickname;
	private String profileImg;
	private int likeCount;
	private int commentCount;

    // 일정 -> DAY 계층
    private List<ItineraryDayDto> days;
    private Integer dayCount;             // 목록 조회에서 집계한 실제 DAY 개수
    
    private boolean liked;		// 화면에 띄울 좋아요. 화면 전달값이라 DB에 추가필요없음.
    
	public ItineraryDto() {
		super();
		// TODO Auto-generated constructor stub
	}
	
	public ItineraryDto(long itineraryId, long userId, String title, String summary, String continent, String country,
			String city, Date startDate, Date endDate, BigDecimal totalBudget, String visibility, String thumbnailImg,
			int viewCount, long sourceItineraryId, String status, long deletedByUserId, Timestamp deletedAt,
			Timestamp createdAt, Timestamp updatedAt) {
		super();
		this.itineraryId = itineraryId;
		this.userId = userId;
		this.title = title;
		this.summary = summary;
		this.continent = continent;
		this.country = country;
		this.city = city;
		this.startDate = startDate;
		this.endDate = endDate;
		this.totalBudget = totalBudget;
		this.visibility = visibility;
		this.thumbnailImg = thumbnailImg;
		this.viewCount = viewCount;
		this.sourceItineraryId = sourceItineraryId;
		this.status = status;
		this.deletedByUserId = deletedByUserId;
		this.deletedAt = deletedAt;
		this.createdAt = createdAt;
		this.updatedAt = updatedAt;
	}
	
	public Long getItineraryId() {
        return itineraryId;
    }

    public void setItineraryId(Long itineraryId) {
        this.itineraryId = itineraryId;
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

    public String getSummary() {
        return summary;
    }

    public void setSummary(String summary) {
        this.summary = summary;
    }

    public String getContinent() {
        return continent;
    }

    public void setContinent(String continent) {
        this.continent = continent;
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

    public Integer getTravelerCount() {
        return travelerCount;
    }

    public void setTravelerCount(Integer travelerCount) {
        this.travelerCount = travelerCount;
    }

    public Date getStartDate() {
        return startDate;
    }

    public void setStartDate(Date startDate) {
        this.startDate = startDate;
    }

    public Date getEndDate() {
        return endDate;
    }

    public void setEndDate(Date endDate) {
        this.endDate = endDate;
    }

    public BigDecimal getTotalBudget() {
        return totalBudget;
    }

    public void setTotalBudget(BigDecimal totalBudget) {
        this.totalBudget = totalBudget;
    }

    public String getVisibility() {
        return visibility;
    }

    public void setVisibility(String visibility) {
        this.visibility = visibility;
    }

    public String getThumbnailImg() {
        return thumbnailImg;
    }

    public void setThumbnailImg(String thumbnailImg) {
        this.thumbnailImg = thumbnailImg;
    }

    public Integer getViewCount() {
        return viewCount;
    }

    public void setViewCount(Integer viewCount) {
        this.viewCount = viewCount;
    }

    public Long getSourceItineraryId() {
        return sourceItineraryId;
    }

    public void setSourceItineraryId(Long sourceItineraryId) {
        this.sourceItineraryId = sourceItineraryId;
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

    public Timestamp getDeletedAt() {
        return deletedAt;
    }

    public void setDeletedAt(Timestamp deletedAt) {
        this.deletedAt = deletedAt;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }

    public List<ItineraryDayDto> getDays() {
        return days;
    }

    public void setDays(List<ItineraryDayDto> days) {
        this.days = days;
    }
	
    public boolean isLiked() {
        return liked;
    }

    public void setLiked(boolean liked) {
        this.liked = liked;
    }

    public String getProfileImg() {
        return profileImg;
    }

    public void setProfileImg(String profileImg) {
        this.profileImg = profileImg;
    }
    
	@Override
    public String toString() {
        return "ItineraryDto [itineraryId=" + itineraryId
                + ", userId=" + userId
                + ", title=" + title
                + ", summary=" + summary
                + ", continent=" + continent
                + ", country=" + country
                + ", city=" + city
                + ", travelerCount=" + travelerCount
                + ", startDate=" + startDate
                + ", endDate=" + endDate
                + ", totalBudget=" + totalBudget
                + ", visibility=" + visibility
                + ", thumbnailImg=" + thumbnailImg
                + ", viewCount=" + viewCount
                + ", sourceItineraryId=" + sourceItineraryId
                + ", status=" + status
                + ", deletedByUserId=" + deletedByUserId
                + ", deletedAt=" + deletedAt
                + ", createdAt=" + createdAt
                + ", updatedAt=" + updatedAt
                + ", days=" + days + "]";
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
	
	//로그인한 회원의 게시글일 때는 전체 일정 조회에서 북마크 토글 아이콘을 숨김. 26.10.01 추가.
	private boolean bookmarked;

	public boolean isBookmarked() {
	    return bookmarked;
	}

	public void setBookmarked(boolean bookmarked) {
	    this.bookmarked = bookmarked;
	}
	

    public Integer getDayCount() {
        return dayCount;
    }

    public void setDayCount(Integer dayCount) {
        this.dayCount = dayCount;
    }

    // 카드의 기간은 여행 날짜가 아닌 등록된 DAY 개수로 표시한다.
    public String getDayDurationText() {
        int count = dayCount != null ? dayCount : (days != null ? days.size() : 0);
        if (count <= 0) {
            return "기간 미정";
        }
        if (count == 1) {
            return "당일치기";
        }
        return (count - 1) + "박" + count + "일";
    }

	public String getDurationText() {
	    if (startDate == null || endDate == null) {
	        return "기간 미정";
	    }

	    long nights = java.time.temporal.ChronoUnit.DAYS.between(
	        startDate.toLocalDate(),
	        endDate.toLocalDate()
	    );

	    if (nights < 0) {
	        return "기간 확인 필요";
	    }

	    return nights + "박 " + (nights + 1) + "일";
	}
}
