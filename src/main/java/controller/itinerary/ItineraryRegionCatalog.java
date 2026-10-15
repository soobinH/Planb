package controller.itinerary;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.servlet.ServletContext;

import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

/**
 * 국가 이름은 기존 한국어 UI 이름으로 고정한다.
 * ISO 3166-2 (1차 행정구역) + Unicode CLDR의 ko 한글 이름을 일회 내려받아 캐싱한다.
 * Unicode CLDR: https://github.com/unicode-org/cldr/blob/b5a68e61ac365706856ea8796585783579c9a3ff/common/subdivisions/ko.xml
 * CLDR copyright (c) Unicode, Inc.; SPDX-License-Identifier: Unicode-3.0
 * 구글 API, 번역 API, DB 마이그레이션 없이 전체 한글 지역명 제공.
 */
public final class ItineraryRegionCatalog {
    private static final String DATA_PATH = "/view/assets/data/itinerary/admin1-regions.json";
    private static final String OVERRIDE_PATH = "/view/assets/data/itinerary/admin1-ko-overrides.json";
    private static final String CACHE_KEY = ItineraryRegionCatalog.class.getName() + ".koreanCatalog";
    private static final String[] CLDR_URLS = {
        "https://raw.githubusercontent.com/unicode-org/cldr/b5a68e61ac365706856ea8796585783579c9a3ff/common/subdivisions/ko.xml",
        "https://cdn.jsdelivr.net/gh/unicode-org/cldr@b5a68e61ac365706856ea8796585783579c9a3ff/common/subdivisions/ko.xml"
    };
    private static final Pattern SUBDIVISION = Pattern.compile(
            "<subdivision\\s+type=\"([^\"]+)\"[^>]*>([^<]*)</subdivision>");
    private static final Pattern HANGUL = Pattern.compile("[가-힣]");

    private ItineraryRegionCatalog() { }

    public static JsonObject get(ServletContext context) {
        synchronized (context) {
            JsonObject cached = (JsonObject) context.getAttribute(CACHE_KEY);
            if (cached != null) return cached;
            JsonObject loaded = createCatalog(context);
            context.setAttribute(CACHE_KEY, loaded);
            return loaded;
        }
    }

    private static JsonObject createCatalog(ServletContext context) {
        JsonObject catalog = loadJson(context, DATA_PATH);
        JsonObject overrides = loadJson(context, OVERRIDE_PATH);
        Map<String, String> translations = loadCldrKorean();
        JsonArray countries = catalog.getAsJsonArray("countries");
        int localized = 0;
        StringBuilder missing = new StringBuilder();
        for (JsonElement ce : countries) {
            JsonObject country = ce.getAsJsonObject();
            JsonArray regions = country.getAsJsonArray("regions");
            if (regions == null) continue;
            for (JsonElement re : regions) {
                JsonObject region = re.getAsJsonObject();
                String current = region.get("name").getAsString();
                if (HANGUL.matcher(current).find()) continue; // 기존 검수된 한국어 표기는 유지한다.
                String isoCode = region.get("code").getAsString().replace("-", "")
                        .toLowerCase(Locale.ROOT);
                String korean = overrides.has(isoCode) ? overrides.get(isoCode).getAsString()
                        : translations.get(isoCode);
                if (korean == null || !HANGUL.matcher(korean).find()) {
                    if (missing.length() > 0) missing.append(", ");
                    missing.append(isoCode);
                    continue;
                }
                region.addProperty("name", korean.trim());
                localized++;
            }
        }
        if (missing.length() > 0) {
            throw new IllegalStateException("한글 표기가 없는 1차 행정구역 코드: " + missing);
        }
        catalog.addProperty("source", "ISO 3166-2 / Unicode CLDR Korean subdivisions");
        catalog.addProperty("regionsPolicy", "한글 지역명만 노출. 원래 ISO 지역코드/영문명 보존.");
        context.log("ItineraryRegionCatalog: " + localized + "개 지역 한국어 표기 적용 완료");
        return catalog;
    }

    private static JsonObject loadJson(ServletContext context, String path) {
        try (InputStream input = context.getResourceAsStream(path)) {
            if (input == null) throw new IllegalStateException("지역 데이터 파일이 없습니다: " + path);
            return new JsonParser().parse(new InputStreamReader(input, StandardCharsets.UTF_8)).getAsJsonObject();
        } catch (IOException e) {
            throw new IllegalStateException("지역 데이터 파일 로드 실패: " + path, e);
        }
    }

    private static Map<String, String> loadCldrKorean() {
        IOException failure = null;
        for (String url : CLDR_URLS) {
            HttpURLConnection connection = null;
            try {
                connection = (HttpURLConnection) new URL(url).openConnection();
                connection.setConnectTimeout(6000);
                connection.setReadTimeout(10000);
                connection.setRequestProperty("User-Agent", "Planb-Region-Catalog/1.0");
                if (connection.getResponseCode() != HttpURLConnection.HTTP_OK) {
                    throw new IOException("CLDR HTTP " + connection.getResponseCode());
                }
                StringBuilder xml = new StringBuilder();
                try (BufferedReader reader = new BufferedReader(new InputStreamReader(
                        connection.getInputStream(), StandardCharsets.UTF_8))) {
                    char[] buf = new char[8192];
                    int n;
                    while ((n = reader.read(buf)) != -1) {
                        xml.append(buf, 0, n);
                        if (xml.length() > 2_000_000) throw new IOException("CLDR 파일 용량 초과");
                    }
                }
                Matcher matcher = SUBDIVISION.matcher(xml);
                Map<String, String> labels = new HashMap<String, String>();
                while (matcher.find()) {
                    String code = matcher.group(1).toLowerCase(Locale.ROOT);
                    String label = matcher.group(2).trim()
                        .replace("&amp;", "&")
                        .replace("&apos;", "'")
                        .replace("&quot;", "\"");
                    if (!HANGUL.matcher(label).find()) continue;
                    labels.put(code, label);
                }
                if (labels.size() < 3000) throw new IOException("CLDR 한국어 항목이 너무 적음: " + labels.size());
                return labels;
            } catch (IOException e) {
                failure = e;
            } finally {
                if (connection != null) connection.disconnect();
            }
        }
        throw new IllegalStateException("한글 지역명 초기화 실패: Unicode CLDR 파일에 접속할 수 없습니다."
            + " 서버 인터넷 연결을 확인하거나 다시 시도해 주세요.", failure);
    }
}
