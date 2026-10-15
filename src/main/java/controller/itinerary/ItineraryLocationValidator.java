package controller.itinerary;

import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

import javax.servlet.ServletContext;

import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;

import dto.itinerary.ItineraryDto;

/**
 * 서버와 클라이언트가 동일한 CLDR 한국어 지역명 카탈로그를 사용한다.
 * 신규 작성/수정에서 임의 국가 또는 존재하지 않는 1차 행정구역을 거부한다.
 * 데이터베이스 변경이나 유료 API 호출은 필요하지 않다.
 */
public final class ItineraryLocationValidator {
    private static final String CONTEXT_CACHE_KEY = ItineraryLocationValidator.class.getName() + ".countryRegions";

    private ItineraryLocationValidator() {}

    public static void validate(ItineraryDto itinerary, ServletContext context) {
        if (itinerary == null) {
            throw new IllegalArgumentException("일정 데이터가 없습니다.");
        }

        Map<String, Set<String>> catalog = getCatalog(context);
        String country = itinerary.getCountry() == null ? "" : itinerary.getCountry().trim();
        Set<String> validRegions = catalog.get(country);
        if (validRegions == null) {
            throw new IllegalArgumentException("국가 목록에 등록된 한국어 국가명을 선택해 주세요.");
        }

        // 지역은 선택 항목. 입력한 경우에만 반드시 실제 1차 행정구역이어야 한다.
        String city = itinerary.getCity() == null ? "" : itinerary.getCity().trim();
        if (!city.isEmpty() && !validRegions.contains(city)) {
            throw new IllegalArgumentException(
                    "'" + country + "'의 1차 행정구역 목록에서 지역을 선택해 주세요. "
                    + "직접 입력한 지역이나 이전 도시 단위 지역은 저장할 수 없습니다.");
        }
    }

    @SuppressWarnings("unchecked")
    private static Map<String, Set<String>> getCatalog(ServletContext context) {
        Object cached = context.getAttribute(CONTEXT_CACHE_KEY);
        if (cached != null) {
            return (Map<String, Set<String>>) cached;
        }

        synchronized (context) {
            cached = context.getAttribute(CONTEXT_CACHE_KEY);
            if (cached != null) {
                return (Map<String, Set<String>>) cached;
            }
            Map<String, Set<String>> loaded = readCatalog(context);
            context.setAttribute(CONTEXT_CACHE_KEY, loaded);
            return loaded;
        }
    }

    private static Map<String, Set<String>> readCatalog(ServletContext context) {
        JsonObject root = ItineraryRegionCatalog.get(context);
        JsonArray countries = root.getAsJsonArray("countries");
        if (countries == null) {
            throw new IllegalArgumentException("한국어 지역 목록 형식이 올바르지 않습니다.");
        }
        Map<String, Set<String>> result = new HashMap<String, Set<String>>();
        for (JsonElement countryEl : countries) {
            JsonObject country = countryEl.getAsJsonObject();
            String name = country.get("name").getAsString();
            Set<String> regions = new HashSet<String>();
            JsonArray regionList = country.getAsJsonArray("regions");
            if (regionList != null) {
                for (JsonElement regionEl : regionList) {
                    JsonObject region = regionEl.getAsJsonObject();
                    regions.add(region.get("name").getAsString());
                }
            }
            result.put(name, Collections.unmodifiableSet(regions));
        }
        return Collections.unmodifiableMap(result);
    }
}
