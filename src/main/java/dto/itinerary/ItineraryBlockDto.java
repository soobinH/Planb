package dto.itinerary;

import java.math.BigDecimal;
import java.sql.Time;
import java.util.List;

public class ItineraryBlockDto {

    private Long blockId;                  // 블록 고유번호
    private Long dayId;                    // DAY 고유번호

    private String googlePlaceId;          // Google Place ID
    private String placeName;              // 장소명
    private String placeAddress;           // 주소
    private Double placeLat;               // 위도
    private Double placeLng;               // 경도

    private Long sourceBlockId;            // 원본 블록 번호

    // MEAL / ATTRACTION / LODGING / TRANSPORT
    private String blockType;

    private Integer blockOrder;            // DAY 내부 블록 순서
    private String title;                  // 표시 제목
    private String memo;                   // 상세 메모
    private BigDecimal cost;               // 입력 비용
    private String costType;                // PER_PERSON / TOTAL

    private Time startTime;                // 시작 시간
    private Time endTime;                  // 종료 시간

    // BLOCK -> IMAGE 계층
    private List<ItineraryBlockImageDto> images;

    public ItineraryBlockDto() {
    }

    public Long getBlockId() {
        return blockId;
    }

    public void setBlockId(Long blockId) {
        this.blockId = blockId;
    }

    public Long getDayId() {
        return dayId;
    }

    public void setDayId(Long dayId) {
        this.dayId = dayId;
    }

    public String getGooglePlaceId() {
        return googlePlaceId;
    }

    public void setGooglePlaceId(String googlePlaceId) {
        this.googlePlaceId = googlePlaceId;
    }

    public String getPlaceName() {
        return placeName;
    }

    public void setPlaceName(String placeName) {
        this.placeName = placeName;
    }

    public String getPlaceAddress() {
        return placeAddress;
    }

    public void setPlaceAddress(String placeAddress) {
        this.placeAddress = placeAddress;
    }

    public Double getPlaceLat() {
        return placeLat;
    }

    public void setPlaceLat(Double placeLat) {
        this.placeLat = placeLat;
    }

    public Double getPlaceLng() {
        return placeLng;
    }

    public void setPlaceLng(Double placeLng) {
        this.placeLng = placeLng;
    }

    public Long getSourceBlockId() {
        return sourceBlockId;
    }

    public void setSourceBlockId(Long sourceBlockId) {
        this.sourceBlockId = sourceBlockId;
    }

    public String getBlockType() {
        return blockType;
    }

    public void setBlockType(String blockType) {
        this.blockType = blockType;
    }

    public Integer getBlockOrder() {
        return blockOrder;
    }

    public void setBlockOrder(Integer blockOrder) {
        this.blockOrder = blockOrder;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getMemo() {
        return memo;
    }

    public void setMemo(String memo) {
        this.memo = memo;
    }

    public BigDecimal getCost() {
        return cost;
    }

    public void setCost(BigDecimal cost) {
        this.cost = cost;
    }

    public String getCostType() {
        return costType;
    }

    public void setCostType(String costType) {
        this.costType = costType;
    }

    public Time getStartTime() {
        return startTime;
    }

    public void setStartTime(Time startTime) {
        this.startTime = startTime;
    }

    public Time getEndTime() {
        return endTime;
    }

    public void setEndTime(Time endTime) {
        this.endTime = endTime;
    }

    public List<ItineraryBlockImageDto> getImages() {
        return images;
    }

    public void setImages(List<ItineraryBlockImageDto> images) {
        this.images = images;
    }

    @Override
    public String toString() {
        return "ItineraryBlockDto [blockId=" + blockId
                + ", dayId=" + dayId
                + ", googlePlaceId=" + googlePlaceId
                + ", placeName=" + placeName
                + ", placeAddress=" + placeAddress
                + ", placeLat=" + placeLat
                + ", placeLng=" + placeLng
                + ", sourceBlockId=" + sourceBlockId
                + ", blockType=" + blockType
                + ", blockOrder=" + blockOrder
                + ", title=" + title
                + ", memo=" + memo
                + ", cost=" + cost
                + ", costType=" + costType
                + ", startTime=" + startTime
                + ", endTime=" + endTime
                + ", images=" + images + "]";
    }
}
