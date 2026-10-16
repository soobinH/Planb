package dto.itinerary;

import java.sql.Date;
import java.sql.Timestamp;
import java.util.List;

public class ItineraryDayDto {

    private Long dayId;                    // DAY 고유번호
    private Long sheetId;                 // 국가별 시트 (신규 다국가 구성)
    public Long getSheetId() { return sheetId; }
    public void setSheetId(Long v) { sheetId=v; }
    private Long itineraryId;              // 일정 고유번호
    private Long sourceDayId;              // 원본 DAY 번호

    // 프론트에서 현재 DAY 배치 순서대로 결정해서 전달
    private Integer dayOrder;

    private Date dayDate;                  // 여행 날짜 (선택)
    private String title;                  // DAY 제목
    private Timestamp createdAt;           // 생성 일시

    // DAY -> BLOCK 계층
    private List<ItineraryBlockDto> blocks;

    public ItineraryDayDto() {
    }

    public Long getDayId() {
        return dayId;
    }

    public void setDayId(Long dayId) {
        this.dayId = dayId;
    }

    public Long getItineraryId() {
        return itineraryId;
    }

    public void setItineraryId(Long itineraryId) {
        this.itineraryId = itineraryId;
    }

    public Long getSourceDayId() {
        return sourceDayId;
    }

    public void setSourceDayId(Long sourceDayId) {
        this.sourceDayId = sourceDayId;
    }

    public Integer getDayOrder() {
        return dayOrder;
    }

    public void setDayOrder(Integer dayOrder) {
        this.dayOrder = dayOrder;
    }

    public Date getDayDate() {
        return dayDate;
    }

    public void setDayDate(Date dayDate) {
        this.dayDate = dayDate;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public List<ItineraryBlockDto> getBlocks() {
        return blocks;
    }

    public void setBlocks(List<ItineraryBlockDto> blocks) {
        this.blocks = blocks;
    }

    @Override
    public String toString() {
        return "ItineraryDayDto [dayId=" + dayId
                + ", itineraryId=" + itineraryId
                + ", sourceDayId=" + sourceDayId
                + ", dayOrder=" + dayOrder
                + ", dayDate=" + dayDate
                + ", title=" + title
                + ", createdAt=" + createdAt
                + ", blocks=" + blocks + "]";
    }
}
