package dto.itinerary;

/** 일정 목록에서 1개 국가 시트와 해당 시트의 장소 핀 도시를 집계하기 위한 조회 결과. */
public class ItineraryCardGeoRow {
    private Long itineraryId;
    private Integer sheetOrder;
    private String country;
    private String placeCity;
    private String placeAddress;
    public Long getItineraryId() { return itineraryId; }
    public void setItineraryId(Long value) { itineraryId = value; }
    public Integer getSheetOrder() { return sheetOrder; }
    public void setSheetOrder(Integer value) { sheetOrder = value; }
    public String getCountry() { return country; }
    public void setCountry(String value) { country = value; }
    public String getPlaceAddress() { return placeAddress; }
    public void setPlaceAddress(String value) { placeAddress = value; }
    public String getPlaceCity() { return placeCity; }
    public void setPlaceCity(String value) { placeCity = value; }
}
