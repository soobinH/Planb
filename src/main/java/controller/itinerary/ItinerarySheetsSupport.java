package controller.itinerary;

import java.util.ArrayList;
import java.util.List;
import dto.itinerary.ItineraryDto;
import dto.itinerary.ItineraryDayDto;
import dto.itinerary.ItinerarySheetDto;

/** 여러 시트의 DAY를 사진 업로드와 기존 상세/카트 화면 호환용으로 평탄화한다. */
final class ItinerarySheetsSupport {
    private ItinerarySheetsSupport() {}
    static void normalize(ItineraryDto dto) {
        if (dto == null || dto.getSheets() == null || dto.getSheets().isEmpty()) return;
        if (dto.getSheets().size() > 99) throw new IllegalArgumentException("시트는 최대 99개까지 만들 수 있습니다.");
        List<ItineraryDayDto> all = new ArrayList<>();
        for (ItinerarySheetDto sheet : dto.getSheets()) {
            if (sheet == null) throw new IllegalArgumentException("올바르지 않은 시트입니다.");
            if (sheet.getDays() != null) all.addAll(sheet.getDays());
        }
        ItinerarySheetDto first = dto.getSheets().get(0);
        dto.setCountry(first.getCountry());
        dto.setCity(first.getCity());
        dto.setTravelerCount(first.getTravelerCount());
        dto.setDays(all);
    }
}
