package dto.itinerary;

import java.math.BigDecimal;
import java.sql.Date;
import java.util.List;

/** 국가별 시트. 한 여행 게시물(itinerary)에 여러 시트가 소속된다. */
public class ItinerarySheetDto {
    private Long sheetId;
    private Long itineraryId;
    private Integer sheetOrder;
    private String country;
    private String city;
    private Integer travelerCount;
    private Date startDate;
    private Date endDate;
    private BigDecimal totalBudget;
    private List<ItineraryDayDto> days;
    public Long getSheetId() { return sheetId; }
    public void setSheetId(Long v) { sheetId=v; }
    public Long getItineraryId() { return itineraryId; }
    public void setItineraryId(Long v) { itineraryId=v; }
    public Integer getSheetOrder() { return sheetOrder; }
    public void setSheetOrder(Integer v) { sheetOrder=v; }
    public String getCountry() { return country; }
    public void setCountry(String v) { country=v; }
    public String getCity() { return city; }
    public void setCity(String v) { city=v; }
    public Integer getTravelerCount() { return travelerCount; }
    public void setTravelerCount(Integer v) { travelerCount=v; }
    public Date getStartDate() { return startDate; }
    public void setStartDate(Date v) { startDate=v; }
    public Date getEndDate() { return endDate; }
    public void setEndDate(Date v) { endDate=v; }
    public BigDecimal getTotalBudget() { return totalBudget; }
    public void setTotalBudget(BigDecimal v) { totalBudget=v; }
    public List<ItineraryDayDto> getDays() { return days; }
    public void setDays(List<ItineraryDayDto> v) { days=v; }
}
