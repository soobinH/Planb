package dto.advertisement;

import java.sql.Date;
import java.sql.Timestamp;

public class AdvertisementDto {
    private String siteName;
    public String getSiteName() { return siteName; }
    public void setSiteName(String value) { this.siteName = value; }
    private String headline;
    public String getHeadline() { return headline; }
    public void setHeadline(String value) { this.headline = value; }
    private String description;
    public String getDescription() { return description; }
    public void setDescription(String value) { this.description = value; }

	private long adId;				// 광고 신청 번호
	private long applicantUserId;	// 신청 회원 번호
	private String businessName;	// 업체명
	private String managerName;		// 담당자명
	private String contactPhone;	// 담당자 연락처
	private String contactEmail;	// 담당자 이메일
	private String adContent;		// 광고 내용
	private String imageUrl;
    private String imageUrlRight;
    public String getImageUrlRight() { return imageUrlRight; }
    public void setImageUrlRight(String imageUrlRight) { this.imageUrlRight = imageUrlRight; }		// 광고 이미지 경로
	private String linkUrl;			// 광고 연결 URL	
	private String adPosition;		// 광고 위치
	private Date startDate;			// 노출 시작일
	private Date endDate;			// 노출 종료일
	private String status;			// 처리/게시 상태
	private String rejectionReason;	// 거절 사유
	private long processedByuserId;	// 최근 처리 관리자
	private Timestamp approvedAt;	// 승인 일시
	private Timestamp processedAt;	// 최근 조치 일시
	private Timestamp deletedAt;	// 삭제/철회 일시
	private Timestamp createdAt;	// 광고 접수 일시
	private Timestamp updatedAt;	// 수정 일시
	public AdvertisementDto() {
		super();
		// TODO Auto-generated constructor stub
	}
	public AdvertisementDto(long adId, long applicantUserId, String businessName, String managerName,
			String contactPhone, String contactEmail, String adContent, String imageUrl, String linkUrl,
			String adPosition, Date startDate, Date endDate, String status, String rejectionReason,
			long processedByuserId, Timestamp approvedAt, Timestamp processedAt, Timestamp deletedAt,
			Timestamp createdAt, Timestamp updatedAt) {
		super();
		this.adId = adId;
		this.applicantUserId = applicantUserId;
		this.businessName = businessName;
		this.managerName = managerName;
		this.contactPhone = contactPhone;
		this.contactEmail = contactEmail;
		this.adContent = adContent;
		this.imageUrl = imageUrl;
		this.linkUrl = linkUrl;
		this.adPosition = adPosition;
		this.startDate = startDate;
		this.endDate = endDate;
		this.status = status;
		this.rejectionReason = rejectionReason;
		this.processedByuserId = processedByuserId;
		this.approvedAt = approvedAt;
		this.processedAt = processedAt;
		this.deletedAt = deletedAt;
		this.createdAt = createdAt;
		this.updatedAt = updatedAt;
	}
	public long getAdId() {
		return adId;
	}
	public void setAdId(long adId) {
		this.adId = adId;
	}
	public long getApplicantUserId() {
		return applicantUserId;
	}
	public void setApplicantUserId(long applicantUserId) {
		this.applicantUserId = applicantUserId;
	}
	public String getBusinessName() {
		return businessName;
	}
	public void setBusinessName(String businessName) {
		this.businessName = businessName;
	}
	public String getManagerName() {
		return managerName;
	}
	public void setManagerName(String managerName) {
		this.managerName = managerName;
	}
	public String getContactPhone() {
		return contactPhone;
	}
	public void setContactPhone(String contactPhone) {
		this.contactPhone = contactPhone;
	}
	public String getContactEmail() {
		return contactEmail;
	}
	public void setContactEmail(String contactEmail) {
		this.contactEmail = contactEmail;
	}
	public String getAdContent() {
		return adContent;
	}
	public void setAdContent(String adContent) {
		this.adContent = adContent;
	}
	public String getImageUrl() {
		return imageUrl;
	}
	public void setImageUrl(String imageUrl) {
		this.imageUrl = imageUrl;
	}
	public String getLinkUrl() {
		return linkUrl;
	}
	public void setLinkUrl(String linkUrl) {
		this.linkUrl = linkUrl;
	}
	public String getAdPosition() {
		return adPosition;
	}
	public void setAdPosition(String adPosition) {
		this.adPosition = adPosition;
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
	public String getStatus() {
		return status;
	}
	public void setStatus(String status) {
		this.status = status;
	}
	public String getRejectionReason() {
		return rejectionReason;
	}
	public void setRejectionReason(String rejectionReason) {
		this.rejectionReason = rejectionReason;
	}
	public long getProcessedByuserId() {
		return processedByuserId;
	}
	public void setProcessedByuserId(long processedByuserId) {
		this.processedByuserId = processedByuserId;
	}
	public Timestamp getApprovedAt() {
		return approvedAt;
	}
	public void setApprovedAt(Timestamp approvedAt) {
		this.approvedAt = approvedAt;
	}
	public Timestamp getProcessedAt() {
		return processedAt;
	}
	public void setProcessedAt(Timestamp processedAt) {
		this.processedAt = processedAt;
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
	@Override
	public String toString() {
		return "AdvertisementDto [adId=" + adId + ", applicantUserId=" + applicantUserId + ", businessName="
				+ businessName + ", managerName=" + managerName + ", contactPhone=" + contactPhone + ", contactEmail="
				+ contactEmail + ", adContent=" + adContent + ", imageUrl=" + imageUrl + ", linkUrl=" + linkUrl
				+ ", adPosition=" + adPosition + ", startDate=" + startDate + ", endDate=" + endDate + ", status="
				+ status + ", rejectionReason=" + rejectionReason + ", processedByuserId=" + processedByuserId
				+ ", approvedAt=" + approvedAt + ", processedAt=" + processedAt + ", deletedAt=" + deletedAt
				+ ", createdAt=" + createdAt + ", updatedAt=" + updatedAt + "]";
	}
	
	
}
