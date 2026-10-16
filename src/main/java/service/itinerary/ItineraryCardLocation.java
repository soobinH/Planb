package service.itinerary;

import java.text.Normalizer;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;

import dto.itinerary.ItineraryDto;
import dto.itinerary.ItineraryCardGeoRow;
import com.google.gson.JsonObject;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;

/**
 * 카드에서 방문한 지역을 요약한다. 시트 국가 순서와 Google 장소 핀의 도시명만 사용한다.
 * 국가/대륙 사전은 현재 planner.js의 ISO 국가 목록과 대륙 구분을 기준으로 생성했다.
 */
public final class ItineraryCardLocation {
    private static final Map<String, String> CONTINENTS = new HashMap<>();
    static {
        CONTINENTS.put("가나", "아프리카");
        CONTINENTS.put("가봉", "아프리카");
        CONTINENTS.put("가이아나", "남아메리카");
        CONTINENTS.put("감비아", "아프리카");
        CONTINENTS.put("건지", "유럽");
        CONTINENTS.put("과들루프", "북아메리카");
        CONTINENTS.put("과테말라", "북아메리카");
        CONTINENTS.put("괌", "오세아니아");
        CONTINENTS.put("그레나다", "북아메리카");
        CONTINENTS.put("그리스", "유럽");
        CONTINENTS.put("그린란드", "북아메리카");
        CONTINENTS.put("기니", "아프리카");
        CONTINENTS.put("기니비사우", "아프리카");
        CONTINENTS.put("나미비아", "아프리카");
        CONTINENTS.put("나우루", "오세아니아");
        CONTINENTS.put("나이지리아", "아프리카");
        CONTINENTS.put("남극 대륙", "남극");
        CONTINENTS.put("남수단", "아프리카");
        CONTINENTS.put("남아프리카", "아프리카");
        CONTINENTS.put("네덜란드", "유럽");
        CONTINENTS.put("네덜란드령 카리브", "북아메리카");
        CONTINENTS.put("네팔", "아시아");
        CONTINENTS.put("노르웨이", "유럽");
        CONTINENTS.put("노퍽섬", "오세아니아");
        CONTINENTS.put("뉴질랜드", "오세아니아");
        CONTINENTS.put("뉴칼레도니아", "오세아니아");
        CONTINENTS.put("니우에", "오세아니아");
        CONTINENTS.put("니제르", "아프리카");
        CONTINENTS.put("니카라과", "북아메리카");
        CONTINENTS.put("대만", "아시아");
        CONTINENTS.put("대한민국", "아시아");
        CONTINENTS.put("덴마크", "유럽");
        CONTINENTS.put("도미니카", "북아메리카");
        CONTINENTS.put("도미니카 공화국", "북아메리카");
        CONTINENTS.put("독일", "유럽");
        CONTINENTS.put("동티모르", "아시아");
        CONTINENTS.put("라오스", "아시아");
        CONTINENTS.put("라이베리아", "아프리카");
        CONTINENTS.put("라트비아", "유럽");
        CONTINENTS.put("러시아", "유럽");
        CONTINENTS.put("레바논", "아시아");
        CONTINENTS.put("레소토", "아프리카");
        CONTINENTS.put("레위니옹", "아프리카");
        CONTINENTS.put("루마니아", "유럽");
        CONTINENTS.put("룩셈부르크", "유럽");
        CONTINENTS.put("르완다", "아프리카");
        CONTINENTS.put("리비아", "아프리카");
        CONTINENTS.put("리투아니아", "유럽");
        CONTINENTS.put("리히텐슈타인", "유럽");
        CONTINENTS.put("마다가스카르", "아프리카");
        CONTINENTS.put("마르티니크", "북아메리카");
        CONTINENTS.put("마셜 제도", "오세아니아");
        CONTINENTS.put("마요트", "아프리카");
        CONTINENTS.put("마카오(중국 특별행정구)", "아시아");
        CONTINENTS.put("말라위", "아프리카");
        CONTINENTS.put("말레이시아", "아시아");
        CONTINENTS.put("말리", "아프리카");
        CONTINENTS.put("맨섬", "유럽");
        CONTINENTS.put("멕시코", "북아메리카");
        CONTINENTS.put("모나코", "유럽");
        CONTINENTS.put("모로코", "아프리카");
        CONTINENTS.put("모리셔스", "아프리카");
        CONTINENTS.put("모리타니", "아프리카");
        CONTINENTS.put("모잠비크", "아프리카");
        CONTINENTS.put("몬테네그로", "유럽");
        CONTINENTS.put("몬트세라트", "북아메리카");
        CONTINENTS.put("몰도바", "유럽");
        CONTINENTS.put("몰디브", "아시아");
        CONTINENTS.put("몰타", "유럽");
        CONTINENTS.put("몽골", "아시아");
        CONTINENTS.put("미국", "북아메리카");
        CONTINENTS.put("미국령 버진아일랜드", "북아메리카");
        CONTINENTS.put("미국령 해외 제도", "오세아니아");
        CONTINENTS.put("미얀마", "아시아");
        CONTINENTS.put("미크로네시아", "오세아니아");
        CONTINENTS.put("바누아투", "오세아니아");
        CONTINENTS.put("바레인", "아시아");
        CONTINENTS.put("바베이도스", "북아메리카");
        CONTINENTS.put("바티칸 시국", "유럽");
        CONTINENTS.put("바하마", "북아메리카");
        CONTINENTS.put("방글라데시", "아시아");
        CONTINENTS.put("버뮤다", "북아메리카");
        CONTINENTS.put("베냉", "아프리카");
        CONTINENTS.put("베네수엘라", "남아메리카");
        CONTINENTS.put("베트남", "아시아");
        CONTINENTS.put("벨기에", "유럽");
        CONTINENTS.put("벨라루스", "유럽");
        CONTINENTS.put("벨리즈", "북아메리카");
        CONTINENTS.put("보스니아 헤르체고비나", "유럽");
        CONTINENTS.put("보츠와나", "아프리카");
        CONTINENTS.put("볼리비아", "남아메리카");
        CONTINENTS.put("부룬디", "아프리카");
        CONTINENTS.put("부르키나파소", "아프리카");
        CONTINENTS.put("부베섬", "남극");
        CONTINENTS.put("부탄", "아시아");
        CONTINENTS.put("북마리아나제도", "오세아니아");
        CONTINENTS.put("북마케도니아", "유럽");
        CONTINENTS.put("북한", "아시아");
        CONTINENTS.put("불가리아", "유럽");
        CONTINENTS.put("브라질", "남아메리카");
        CONTINENTS.put("브루나이", "아시아");
        CONTINENTS.put("사모아", "오세아니아");
        CONTINENTS.put("사우디아라비아", "아시아");
        CONTINENTS.put("사우스조지아 사우스샌드위치 제도", "남아메리카");
        CONTINENTS.put("산마리노", "유럽");
        CONTINENTS.put("상투메 프린시페", "아프리카");
        CONTINENTS.put("생마르탱", "북아메리카");
        CONTINENTS.put("생바르텔레미", "북아메리카");
        CONTINENTS.put("생피에르 미클롱", "북아메리카");
        CONTINENTS.put("서사하라", "아프리카");
        CONTINENTS.put("세네갈", "아프리카");
        CONTINENTS.put("세르비아", "유럽");
        CONTINENTS.put("세이셸", "아프리카");
        CONTINENTS.put("세인트루시아", "북아메리카");
        CONTINENTS.put("세인트빈센트그레나딘", "북아메리카");
        CONTINENTS.put("세인트키츠 네비스", "북아메리카");
        CONTINENTS.put("세인트헬레나", "아프리카");
        CONTINENTS.put("소말리아", "아프리카");
        CONTINENTS.put("솔로몬 제도", "오세아니아");
        CONTINENTS.put("수단", "아프리카");
        CONTINENTS.put("수리남", "남아메리카");
        CONTINENTS.put("스리랑카", "아시아");
        CONTINENTS.put("스발바르제도-얀마웬섬", "유럽");
        CONTINENTS.put("스웨덴", "유럽");
        CONTINENTS.put("스위스", "유럽");
        CONTINENTS.put("스페인", "유럽");
        CONTINENTS.put("슬로바키아", "유럽");
        CONTINENTS.put("슬로베니아", "유럽");
        CONTINENTS.put("시리아", "아시아");
        CONTINENTS.put("시에라리온", "아프리카");
        CONTINENTS.put("신트마르턴", "북아메리카");
        CONTINENTS.put("싱가포르", "아시아");
        CONTINENTS.put("아랍에미리트", "아시아");
        CONTINENTS.put("아루바", "북아메리카");
        CONTINENTS.put("아르메니아", "아시아");
        CONTINENTS.put("아르헨티나", "남아메리카");
        CONTINENTS.put("아메리칸 사모아", "오세아니아");
        CONTINENTS.put("아이슬란드", "유럽");
        CONTINENTS.put("아이티", "북아메리카");
        CONTINENTS.put("아일랜드", "유럽");
        CONTINENTS.put("아제르바이잔", "아시아");
        CONTINENTS.put("아프가니스탄", "아시아");
        CONTINENTS.put("안도라", "유럽");
        CONTINENTS.put("알바니아", "유럽");
        CONTINENTS.put("알제리", "아프리카");
        CONTINENTS.put("앙골라", "아프리카");
        CONTINENTS.put("앤티가 바부다", "북아메리카");
        CONTINENTS.put("앵귈라", "북아메리카");
        CONTINENTS.put("에리트리아", "아프리카");
        CONTINENTS.put("에스와티니", "아프리카");
        CONTINENTS.put("에스토니아", "유럽");
        CONTINENTS.put("에콰도르", "남아메리카");
        CONTINENTS.put("에티오피아", "아프리카");
        CONTINENTS.put("엘살바도르", "북아메리카");
        CONTINENTS.put("영국", "유럽");
        CONTINENTS.put("영국령 버진아일랜드", "북아메리카");
        CONTINENTS.put("영국령 인도양 지역", "아프리카");
        CONTINENTS.put("예멘", "아시아");
        CONTINENTS.put("오만", "아시아");
        CONTINENTS.put("오스트레일리아", "오세아니아");
        CONTINENTS.put("오스트리아", "유럽");
        CONTINENTS.put("온두라스", "북아메리카");
        CONTINENTS.put("올란드 제도", "유럽");
        CONTINENTS.put("왈리스-푸투나 제도", "오세아니아");
        CONTINENTS.put("요르단", "아시아");
        CONTINENTS.put("우간다", "아프리카");
        CONTINENTS.put("우루과이", "남아메리카");
        CONTINENTS.put("우즈베키스탄", "아시아");
        CONTINENTS.put("우크라이나", "유럽");
        CONTINENTS.put("이라크", "아시아");
        CONTINENTS.put("이란", "아시아");
        CONTINENTS.put("이스라엘", "아시아");
        CONTINENTS.put("이집트", "아프리카");
        CONTINENTS.put("이탈리아", "유럽");
        CONTINENTS.put("인도", "아시아");
        CONTINENTS.put("인도네시아", "아시아");
        CONTINENTS.put("일본", "아시아");
        CONTINENTS.put("자메이카", "북아메리카");
        CONTINENTS.put("잠비아", "아프리카");
        CONTINENTS.put("저지", "유럽");
        CONTINENTS.put("적도 기니", "아프리카");
        CONTINENTS.put("조지아", "아시아");
        CONTINENTS.put("중국", "아시아");
        CONTINENTS.put("중앙 아프리카 공화국", "아프리카");
        CONTINENTS.put("지부티", "아프리카");
        CONTINENTS.put("지브롤터", "유럽");
        CONTINENTS.put("짐바브웨", "아프리카");
        CONTINENTS.put("차드", "아프리카");
        CONTINENTS.put("체코", "유럽");
        CONTINENTS.put("칠레", "남아메리카");
        CONTINENTS.put("카메룬", "아프리카");
        CONTINENTS.put("카보베르데", "아프리카");
        CONTINENTS.put("카자흐스탄", "아시아");
        CONTINENTS.put("카타르", "아시아");
        CONTINENTS.put("캄보디아", "아시아");
        CONTINENTS.put("캐나다", "북아메리카");
        CONTINENTS.put("케냐", "아프리카");
        CONTINENTS.put("케이맨 제도", "북아메리카");
        CONTINENTS.put("코모로", "아프리카");
        CONTINENTS.put("코스타리카", "북아메리카");
        CONTINENTS.put("코코스 제도", "오세아니아");
        CONTINENTS.put("코트디부아르", "아프리카");
        CONTINENTS.put("콜롬비아", "남아메리카");
        CONTINENTS.put("콩고-브라자빌", "아프리카");
        CONTINENTS.put("콩고-킨샤사", "아프리카");
        CONTINENTS.put("쿠바", "북아메리카");
        CONTINENTS.put("쿠웨이트", "아시아");
        CONTINENTS.put("쿡 제도", "오세아니아");
        CONTINENTS.put("퀴라소", "북아메리카");
        CONTINENTS.put("크로아티아", "유럽");
        CONTINENTS.put("크리스마스섬", "오세아니아");
        CONTINENTS.put("키르기스스탄", "아시아");
        CONTINENTS.put("키리바시", "오세아니아");
        CONTINENTS.put("키프로스", "유럽");
        CONTINENTS.put("타지키스탄", "아시아");
        CONTINENTS.put("탄자니아", "아프리카");
        CONTINENTS.put("태국", "아시아");
        CONTINENTS.put("터크스 케이커스 제도", "북아메리카");
        CONTINENTS.put("터키", "아시아");
        CONTINENTS.put("토고", "아프리카");
        CONTINENTS.put("토켈라우", "오세아니아");
        CONTINENTS.put("통가", "오세아니아");
        CONTINENTS.put("투르크메니스탄", "아시아");
        CONTINENTS.put("투발루", "오세아니아");
        CONTINENTS.put("튀니지", "아프리카");
        CONTINENTS.put("튀르키예", "아시아");
        CONTINENTS.put("트리니다드 토바고", "북아메리카");
        CONTINENTS.put("파나마", "북아메리카");
        CONTINENTS.put("파라과이", "남아메리카");
        CONTINENTS.put("파키스탄", "아시아");
        CONTINENTS.put("파푸아뉴기니", "오세아니아");
        CONTINENTS.put("팔라우", "오세아니아");
        CONTINENTS.put("팔레스타인 지구", "아시아");
        CONTINENTS.put("페로 제도", "유럽");
        CONTINENTS.put("페루", "남아메리카");
        CONTINENTS.put("포르투갈", "유럽");
        CONTINENTS.put("포클랜드 제도", "남아메리카");
        CONTINENTS.put("폴란드", "유럽");
        CONTINENTS.put("푸에르토리코", "북아메리카");
        CONTINENTS.put("프랑스", "유럽");
        CONTINENTS.put("프랑스령 기아나", "남아메리카");
        CONTINENTS.put("프랑스령 남방 지역", "남극");
        CONTINENTS.put("프랑스령 폴리네시아", "오세아니아");
        CONTINENTS.put("피지", "오세아니아");
        CONTINENTS.put("핀란드", "유럽");
        CONTINENTS.put("필리핀", "아시아");
        CONTINENTS.put("핏케언 제도", "오세아니아");
        CONTINENTS.put("한국", "아시아");
        CONTINENTS.put("한국(대한민국)", "아시아");
        CONTINENTS.put("허드 맥도널드 제도", "남극");
        CONTINENTS.put("헝가리", "유럽");
        CONTINENTS.put("홍콩(중국 특별행정구)", "아시아");
    }

    /** The country/subdivision data installed here is the same localized catalog the editor uses. */
    private static volatile Map<String, List<Admin1Region>> koreanAdmin1ByCountry = java.util.Collections.emptyMap();

    private static final class Admin1Region {
        final String display;
        final String[] aliases;
        Admin1Region(String display, String[] aliases) {
            this.display = display;
            this.aliases = aliases;
        }
    }

    /** Called once per webapp lifetime by the schedule-list servlet; safe to repeat. */
    public static synchronized void installKoreanAdmin1Catalog(JsonObject catalog) {
        if (!koreanAdmin1ByCountry.isEmpty()) return;
        if (catalog == null || catalog.getAsJsonArray("countries") == null) return;
        Map<String, List<Admin1Region>> out = new HashMap<>();
        for (JsonElement countryElement : catalog.getAsJsonArray("countries")) {
            JsonObject country = countryElement.getAsJsonObject();
            if (!country.has("code") || !country.has("regions")) continue;
            String code = country.get("code").getAsString().toUpperCase(Locale.ROOT);
            JsonArray regions = country.getAsJsonArray("regions");
            List<Admin1Region> names = new ArrayList<>();
            for (JsonElement item : regions) {
                JsonObject region = item.getAsJsonObject();
                if (!region.has("name") || !region.has("code")) continue;
                String ko = region.get("name").getAsString();
                if (!ko.matches(".*[가-힣].*")) continue;
                String iso = region.get("code").getAsString();
                String english = region.has("en") ? region.get("en").getAsString() : "";
                String shown = displayAdmin1(ko, code);
                names.add(new Admin1Region(shown, new String[]{
                    regionKey(iso), regionKey(iso.substring(iso.indexOf('-') + 1)),
                    regionKey(english), regionKey(ko), regionKey(shown),
                    regionKey("KR".equals(code) ? english.replaceAll("(?i)-(teukbyeoljachido|teukbyeoljachisi|teukbyeolsi|gwangyeoksi|do)$", "") : english)
                }));
            }
            out.put(code, java.util.Collections.unmodifiableList(names));
        }
        koreanAdmin1ByCountry = java.util.Collections.unmodifiableMap(out);
    }

    private static String displayAdmin1(String name, String code) {
        if ("JP".equals(code)) return "홋카이도".equals(name) ? name : name.replaceAll("(도|부|현)$", "");
        if ("KR".equals(code)) return name.replaceAll("(특별자치시|특별시|광역시|특별자치도)$", "");
        return name;
    }

    private static String regionKey(String raw) {
        String normalized = Normalizer.normalize(raw == null ? "" : raw, Normalizer.Form.NFKD)
                .replaceAll("\\p{M}", "").toLowerCase(Locale.ROOT);
        return normalized.replaceAll("[^\\p{L}\\p{N}]", "");
    }

    private static String resolvedKoreanAdmin1(String country, String previousValue, String address) {
        String code = COUNTRY_CODES.get(country);
        List<Admin1Region> regions = koreanAdmin1ByCountry.get(code);
        if (regions == null || regions.isEmpty()) return "";
        String previousKey = regionKey(previousValue);
        if (!previousKey.isEmpty()) {
            for (Admin1Region entry : regions) {
                for (String key : entry.aliases) {
                    if (!key.isEmpty() && previousKey.equals(key)) return entry.display;
                }
            }
        }
        // Migration support: historic place_city stored 'Minato City' etc. Read admin1
        // from the Google formatted address instead of interpreting the locality as a city.
        String addressKey = regionKey(address);
        if (addressKey.isEmpty()) return "";
        int longest = 0;
        String answer = "";
        for (Admin1Region entry : regions) {
            for (int i : new int[]{2,3,4,5}) { // English/Korean full names; not ISO short code
                String alias = entry.aliases[i];
                if (alias.length() < 4 || !addressKey.contains(alias)) continue;
                if (alias.length() > longest) {
                    longest = alias.length();
                    answer = entry.display;
                }
            }
        }
        return answer;
    }

    private ItineraryCardLocation() { }

    private static String normalized(String name) {
        return name == null ? "" : Normalizer.normalize(name.trim(), Normalizer.Form.NFKC)
                .toLowerCase(Locale.ROOT);
    }

    private static boolean isKorea(String name) {
        return "대한민국".equals(name) || "한국".equals(name) || "한국(대한민국)".equals(name);
    }

    private static final Map<String, String> COUNTRY_CODES = new HashMap<>();
    private static final Map<String, Map<String, String>> CITY_ALIASES = new HashMap<>();
    static {
        COUNTRY_CODES.put("가나", "GH");
        COUNTRY_CODES.put("가봉", "GA");
        COUNTRY_CODES.put("가이아나", "GY");
        COUNTRY_CODES.put("감비아", "GM");
        COUNTRY_CODES.put("건지", "GG");
        COUNTRY_CODES.put("과들루프", "GP");
        COUNTRY_CODES.put("과테말라", "GT");
        COUNTRY_CODES.put("괌", "GU");
        COUNTRY_CODES.put("그레나다", "GD");
        COUNTRY_CODES.put("그리스", "GR");
        COUNTRY_CODES.put("그린란드", "GL");
        COUNTRY_CODES.put("기니", "GN");
        COUNTRY_CODES.put("기니비사우", "GW");
        COUNTRY_CODES.put("나미비아", "NA");
        COUNTRY_CODES.put("나우루", "NR");
        COUNTRY_CODES.put("나이지리아", "NG");
        COUNTRY_CODES.put("남극 대륙", "AQ");
        COUNTRY_CODES.put("남수단", "SS");
        COUNTRY_CODES.put("남아프리카", "ZA");
        COUNTRY_CODES.put("네덜란드", "NL");
        COUNTRY_CODES.put("네덜란드령 카리브", "BQ");
        COUNTRY_CODES.put("네팔", "NP");
        COUNTRY_CODES.put("노르웨이", "NO");
        COUNTRY_CODES.put("노퍽섬", "NF");
        COUNTRY_CODES.put("뉴질랜드", "NZ");
        COUNTRY_CODES.put("뉴칼레도니아", "NC");
        COUNTRY_CODES.put("니우에", "NU");
        COUNTRY_CODES.put("니제르", "NE");
        COUNTRY_CODES.put("니카라과", "NI");
        COUNTRY_CODES.put("대만", "TW");
        COUNTRY_CODES.put("대한민국", "KR");
        COUNTRY_CODES.put("덴마크", "DK");
        COUNTRY_CODES.put("도미니카", "DM");
        COUNTRY_CODES.put("도미니카 공화국", "DO");
        COUNTRY_CODES.put("독일", "DE");
        COUNTRY_CODES.put("동티모르", "TL");
        COUNTRY_CODES.put("라오스", "LA");
        COUNTRY_CODES.put("라이베리아", "LR");
        COUNTRY_CODES.put("라트비아", "LV");
        COUNTRY_CODES.put("러시아", "RU");
        COUNTRY_CODES.put("레바논", "LB");
        COUNTRY_CODES.put("레소토", "LS");
        COUNTRY_CODES.put("레위니옹", "RE");
        COUNTRY_CODES.put("루마니아", "RO");
        COUNTRY_CODES.put("룩셈부르크", "LU");
        COUNTRY_CODES.put("르완다", "RW");
        COUNTRY_CODES.put("리비아", "LY");
        COUNTRY_CODES.put("리투아니아", "LT");
        COUNTRY_CODES.put("리히텐슈타인", "LI");
        COUNTRY_CODES.put("마다가스카르", "MG");
        COUNTRY_CODES.put("마르티니크", "MQ");
        COUNTRY_CODES.put("마셜 제도", "MH");
        COUNTRY_CODES.put("마요트", "YT");
        COUNTRY_CODES.put("마카오", "MO");
        COUNTRY_CODES.put("마카오(중국 특별행정구)", "MO");
        COUNTRY_CODES.put("말라위", "MW");
        COUNTRY_CODES.put("말레이시아", "MY");
        COUNTRY_CODES.put("말리", "ML");
        COUNTRY_CODES.put("맨섬", "IM");
        COUNTRY_CODES.put("멕시코", "MX");
        COUNTRY_CODES.put("모나코", "MC");
        COUNTRY_CODES.put("모로코", "MA");
        COUNTRY_CODES.put("모리셔스", "MU");
        COUNTRY_CODES.put("모리타니", "MR");
        COUNTRY_CODES.put("모잠비크", "MZ");
        COUNTRY_CODES.put("몬테네그로", "ME");
        COUNTRY_CODES.put("몬트세라트", "MS");
        COUNTRY_CODES.put("몰도바", "MD");
        COUNTRY_CODES.put("몰디브", "MV");
        COUNTRY_CODES.put("몰타", "MT");
        COUNTRY_CODES.put("몽골", "MN");
        COUNTRY_CODES.put("미국", "US");
        COUNTRY_CODES.put("미국령 버진아일랜드", "VI");
        COUNTRY_CODES.put("미국령 해외 제도", "UM");
        COUNTRY_CODES.put("미얀마", "MM");
        COUNTRY_CODES.put("미크로네시아", "FM");
        COUNTRY_CODES.put("바누아투", "VU");
        COUNTRY_CODES.put("바레인", "BH");
        COUNTRY_CODES.put("바베이도스", "BB");
        COUNTRY_CODES.put("바티칸 시국", "VA");
        COUNTRY_CODES.put("바하마", "BS");
        COUNTRY_CODES.put("방글라데시", "BD");
        COUNTRY_CODES.put("버뮤다", "BM");
        COUNTRY_CODES.put("베냉", "BJ");
        COUNTRY_CODES.put("베네수엘라", "VE");
        COUNTRY_CODES.put("베트남", "VN");
        COUNTRY_CODES.put("벨기에", "BE");
        COUNTRY_CODES.put("벨라루스", "BY");
        COUNTRY_CODES.put("벨리즈", "BZ");
        COUNTRY_CODES.put("보스니아 헤르체고비나", "BA");
        COUNTRY_CODES.put("보츠와나", "BW");
        COUNTRY_CODES.put("볼리비아", "BO");
        COUNTRY_CODES.put("부룬디", "BI");
        COUNTRY_CODES.put("부르키나파소", "BF");
        COUNTRY_CODES.put("부베섬", "BV");
        COUNTRY_CODES.put("부탄", "BT");
        COUNTRY_CODES.put("북마리아나제도", "MP");
        COUNTRY_CODES.put("북마케도니아", "MK");
        COUNTRY_CODES.put("북한", "KP");
        COUNTRY_CODES.put("불가리아", "BG");
        COUNTRY_CODES.put("브라질", "BR");
        COUNTRY_CODES.put("브루나이", "BN");
        COUNTRY_CODES.put("사모아", "WS");
        COUNTRY_CODES.put("사우디아라비아", "SA");
        COUNTRY_CODES.put("사우스조지아 사우스샌드위치 제도", "GS");
        COUNTRY_CODES.put("산마리노", "SM");
        COUNTRY_CODES.put("상투메 프린시페", "ST");
        COUNTRY_CODES.put("생마르탱", "MF");
        COUNTRY_CODES.put("생바르텔레미", "BL");
        COUNTRY_CODES.put("생피에르 미클롱", "PM");
        COUNTRY_CODES.put("서사하라", "EH");
        COUNTRY_CODES.put("세네갈", "SN");
        COUNTRY_CODES.put("세르비아", "RS");
        COUNTRY_CODES.put("세이셸", "SC");
        COUNTRY_CODES.put("세인트루시아", "LC");
        COUNTRY_CODES.put("세인트빈센트그레나딘", "VC");
        COUNTRY_CODES.put("세인트키츠 네비스", "KN");
        COUNTRY_CODES.put("세인트헬레나", "SH");
        COUNTRY_CODES.put("소말리아", "SO");
        COUNTRY_CODES.put("솔로몬 제도", "SB");
        COUNTRY_CODES.put("수단", "SD");
        COUNTRY_CODES.put("수리남", "SR");
        COUNTRY_CODES.put("스리랑카", "LK");
        COUNTRY_CODES.put("스발바르제도-얀마웬섬", "SJ");
        COUNTRY_CODES.put("스웨덴", "SE");
        COUNTRY_CODES.put("스위스", "CH");
        COUNTRY_CODES.put("스페인", "ES");
        COUNTRY_CODES.put("슬로바키아", "SK");
        COUNTRY_CODES.put("슬로베니아", "SI");
        COUNTRY_CODES.put("시리아", "SY");
        COUNTRY_CODES.put("시에라리온", "SL");
        COUNTRY_CODES.put("신트마르턴", "SX");
        COUNTRY_CODES.put("싱가포르", "SG");
        COUNTRY_CODES.put("아랍에미리트", "AE");
        COUNTRY_CODES.put("아루바", "AW");
        COUNTRY_CODES.put("아르메니아", "AM");
        COUNTRY_CODES.put("아르헨티나", "AR");
        COUNTRY_CODES.put("아메리칸 사모아", "AS");
        COUNTRY_CODES.put("아이슬란드", "IS");
        COUNTRY_CODES.put("아이티", "HT");
        COUNTRY_CODES.put("아일랜드", "IE");
        COUNTRY_CODES.put("아제르바이잔", "AZ");
        COUNTRY_CODES.put("아프가니스탄", "AF");
        COUNTRY_CODES.put("안도라", "AD");
        COUNTRY_CODES.put("알바니아", "AL");
        COUNTRY_CODES.put("알제리", "DZ");
        COUNTRY_CODES.put("앙골라", "AO");
        COUNTRY_CODES.put("앤티가 바부다", "AG");
        COUNTRY_CODES.put("앵귈라", "AI");
        COUNTRY_CODES.put("에리트리아", "ER");
        COUNTRY_CODES.put("에스와티니", "SZ");
        COUNTRY_CODES.put("에스토니아", "EE");
        COUNTRY_CODES.put("에콰도르", "EC");
        COUNTRY_CODES.put("에티오피아", "ET");
        COUNTRY_CODES.put("엘살바도르", "SV");
        COUNTRY_CODES.put("영국", "GB");
        COUNTRY_CODES.put("영국령 버진아일랜드", "VG");
        COUNTRY_CODES.put("영국령 인도양 지역", "IO");
        COUNTRY_CODES.put("예멘", "YE");
        COUNTRY_CODES.put("오만", "OM");
        COUNTRY_CODES.put("오스트레일리아", "AU");
        COUNTRY_CODES.put("오스트리아", "AT");
        COUNTRY_CODES.put("온두라스", "HN");
        COUNTRY_CODES.put("올란드 제도", "AX");
        COUNTRY_CODES.put("왈리스-푸투나 제도", "WF");
        COUNTRY_CODES.put("요르단", "JO");
        COUNTRY_CODES.put("우간다", "UG");
        COUNTRY_CODES.put("우루과이", "UY");
        COUNTRY_CODES.put("우즈베키스탄", "UZ");
        COUNTRY_CODES.put("우크라이나", "UA");
        COUNTRY_CODES.put("이라크", "IQ");
        COUNTRY_CODES.put("이란", "IR");
        COUNTRY_CODES.put("이스라엘", "IL");
        COUNTRY_CODES.put("이집트", "EG");
        COUNTRY_CODES.put("이탈리아", "IT");
        COUNTRY_CODES.put("인도", "IN");
        COUNTRY_CODES.put("인도네시아", "ID");
        COUNTRY_CODES.put("일본", "JP");
        COUNTRY_CODES.put("자메이카", "JM");
        COUNTRY_CODES.put("잠비아", "ZM");
        COUNTRY_CODES.put("저지", "JE");
        COUNTRY_CODES.put("적도 기니", "GQ");
        COUNTRY_CODES.put("조지아", "GE");
        COUNTRY_CODES.put("중국", "CN");
        COUNTRY_CODES.put("중앙 아프리카 공화국", "CF");
        COUNTRY_CODES.put("지부티", "DJ");
        COUNTRY_CODES.put("지브롤터", "GI");
        COUNTRY_CODES.put("짐바브웨", "ZW");
        COUNTRY_CODES.put("차드", "TD");
        COUNTRY_CODES.put("체코", "CZ");
        COUNTRY_CODES.put("칠레", "CL");
        COUNTRY_CODES.put("카메룬", "CM");
        COUNTRY_CODES.put("카보베르데", "CV");
        COUNTRY_CODES.put("카자흐스탄", "KZ");
        COUNTRY_CODES.put("카타르", "QA");
        COUNTRY_CODES.put("캄보디아", "KH");
        COUNTRY_CODES.put("캐나다", "CA");
        COUNTRY_CODES.put("케냐", "KE");
        COUNTRY_CODES.put("케이맨 제도", "KY");
        COUNTRY_CODES.put("코모로", "KM");
        COUNTRY_CODES.put("코스타리카", "CR");
        COUNTRY_CODES.put("코코스 제도", "CC");
        COUNTRY_CODES.put("코트디부아르", "CI");
        COUNTRY_CODES.put("콜롬비아", "CO");
        COUNTRY_CODES.put("콩고-브라자빌", "CG");
        COUNTRY_CODES.put("콩고-킨샤사", "CD");
        COUNTRY_CODES.put("쿠바", "CU");
        COUNTRY_CODES.put("쿠웨이트", "KW");
        COUNTRY_CODES.put("쿡 제도", "CK");
        COUNTRY_CODES.put("퀴라소", "CW");
        COUNTRY_CODES.put("크로아티아", "HR");
        COUNTRY_CODES.put("크리스마스섬", "CX");
        COUNTRY_CODES.put("키르기스스탄", "KG");
        COUNTRY_CODES.put("키리바시", "KI");
        COUNTRY_CODES.put("키프로스", "CY");
        COUNTRY_CODES.put("타지키스탄", "TJ");
        COUNTRY_CODES.put("탄자니아", "TZ");
        COUNTRY_CODES.put("태국", "TH");
        COUNTRY_CODES.put("터크스 케이커스 제도", "TC");
        COUNTRY_CODES.put("터키", "TR");
        COUNTRY_CODES.put("토고", "TG");
        COUNTRY_CODES.put("토켈라우", "TK");
        COUNTRY_CODES.put("통가", "TO");
        COUNTRY_CODES.put("투르크메니스탄", "TM");
        COUNTRY_CODES.put("투발루", "TV");
        COUNTRY_CODES.put("튀니지", "TN");
        COUNTRY_CODES.put("튀르키예", "TR");
        COUNTRY_CODES.put("트리니다드 토바고", "TT");
        COUNTRY_CODES.put("파나마", "PA");
        COUNTRY_CODES.put("파라과이", "PY");
        COUNTRY_CODES.put("파키스탄", "PK");
        COUNTRY_CODES.put("파푸아뉴기니", "PG");
        COUNTRY_CODES.put("팔라우", "PW");
        COUNTRY_CODES.put("팔레스타인 지구", "PS");
        COUNTRY_CODES.put("페로 제도", "FO");
        COUNTRY_CODES.put("페루", "PE");
        COUNTRY_CODES.put("포르투갈", "PT");
        COUNTRY_CODES.put("포클랜드 제도", "FK");
        COUNTRY_CODES.put("폴란드", "PL");
        COUNTRY_CODES.put("푸에르토리코", "PR");
        COUNTRY_CODES.put("프랑스", "FR");
        COUNTRY_CODES.put("프랑스령 기아나", "GF");
        COUNTRY_CODES.put("프랑스령 남방 지역", "TF");
        COUNTRY_CODES.put("프랑스령 폴리네시아", "PF");
        COUNTRY_CODES.put("피지", "FJ");
        COUNTRY_CODES.put("핀란드", "FI");
        COUNTRY_CODES.put("필리핀", "PH");
        COUNTRY_CODES.put("핏케언 제도", "PN");
        COUNTRY_CODES.put("한국", "KR");
        COUNTRY_CODES.put("한국(대한민국)", "KR");
        COUNTRY_CODES.put("허드 맥도널드 제도", "HM");
        COUNTRY_CODES.put("헝가리", "HU");
        COUNTRY_CODES.put("홍콩", "HK");
        COUNTRY_CODES.put("홍콩(중국 특별행정구)", "HK");
        CITY_ALIASES.computeIfAbsent("AE", ignored -> new HashMap<>()).put("abudhabi", "아부다비");
        CITY_ALIASES.computeIfAbsent("AE", ignored -> new HashMap<>()).put("dubai", "두바이");
        CITY_ALIASES.computeIfAbsent("AE", ignored -> new HashMap<>()).put("sharjah", "샤르자");
        CITY_ALIASES.computeIfAbsent("AR", ignored -> new HashMap<>()).put("buenosaires", "부에노스아이레스");
        CITY_ALIASES.computeIfAbsent("AR", ignored -> new HashMap<>()).put("cordoba", "코르도바");
        CITY_ALIASES.computeIfAbsent("AR", ignored -> new HashMap<>()).put("córdoba", "코르도바");
        CITY_ALIASES.computeIfAbsent("AT", ignored -> new HashMap<>()).put("salzburg", "잘츠부르크");
        CITY_ALIASES.computeIfAbsent("AT", ignored -> new HashMap<>()).put("vienna", "빈");
        CITY_ALIASES.computeIfAbsent("AT", ignored -> new HashMap<>()).put("wien", "빈");
        CITY_ALIASES.computeIfAbsent("AU", ignored -> new HashMap<>()).put("adelaide", "애들레이드");
        CITY_ALIASES.computeIfAbsent("AU", ignored -> new HashMap<>()).put("brisbane", "브리즈번");
        CITY_ALIASES.computeIfAbsent("AU", ignored -> new HashMap<>()).put("canberra", "캔버라");
        CITY_ALIASES.computeIfAbsent("AU", ignored -> new HashMap<>()).put("goldcoast", "골드코스트");
        CITY_ALIASES.computeIfAbsent("AU", ignored -> new HashMap<>()).put("melbourne", "멜버른");
        CITY_ALIASES.computeIfAbsent("AU", ignored -> new HashMap<>()).put("perth", "퍼스");
        CITY_ALIASES.computeIfAbsent("AU", ignored -> new HashMap<>()).put("sydney", "시드니");
        CITY_ALIASES.computeIfAbsent("BE", ignored -> new HashMap<>()).put("antwerp", "안트베르펜");
        CITY_ALIASES.computeIfAbsent("BE", ignored -> new HashMap<>()).put("antwerpen", "안트베르펜");
        CITY_ALIASES.computeIfAbsent("BE", ignored -> new HashMap<>()).put("brussels", "브뤼셀");
        CITY_ALIASES.computeIfAbsent("BE", ignored -> new HashMap<>()).put("bruxelles", "브뤼셀");
        CITY_ALIASES.computeIfAbsent("BR", ignored -> new HashMap<>()).put("brasilia", "브라질리아");
        CITY_ALIASES.computeIfAbsent("BR", ignored -> new HashMap<>()).put("brasília", "브라질리아");
        CITY_ALIASES.computeIfAbsent("BR", ignored -> new HashMap<>()).put("riodejaneiro", "리우데자네이루");
        CITY_ALIASES.computeIfAbsent("BR", ignored -> new HashMap<>()).put("salvador", "사우바도르");
        CITY_ALIASES.computeIfAbsent("BR", ignored -> new HashMap<>()).put("saopaulo", "상파울루");
        CITY_ALIASES.computeIfAbsent("BR", ignored -> new HashMap<>()).put("sãopaulo", "상파울루");
        CITY_ALIASES.computeIfAbsent("CA", ignored -> new HashMap<>()).put("calgary", "캘거리");
        CITY_ALIASES.computeIfAbsent("CA", ignored -> new HashMap<>()).put("montreal", "몬트리올");
        CITY_ALIASES.computeIfAbsent("CA", ignored -> new HashMap<>()).put("montréal", "몬트리올");
        CITY_ALIASES.computeIfAbsent("CA", ignored -> new HashMap<>()).put("ottawa", "오타와");
        CITY_ALIASES.computeIfAbsent("CA", ignored -> new HashMap<>()).put("quebec", "퀘벡");
        CITY_ALIASES.computeIfAbsent("CA", ignored -> new HashMap<>()).put("toronto", "토론토");
        CITY_ALIASES.computeIfAbsent("CA", ignored -> new HashMap<>()).put("vancouver", "밴쿠버");
        CITY_ALIASES.computeIfAbsent("CH", ignored -> new HashMap<>()).put("bern", "베른");
        CITY_ALIASES.computeIfAbsent("CH", ignored -> new HashMap<>()).put("geneva", "제네바");
        CITY_ALIASES.computeIfAbsent("CH", ignored -> new HashMap<>()).put("genève", "제네바");
        CITY_ALIASES.computeIfAbsent("CH", ignored -> new HashMap<>()).put("lucerne", "루체른");
        CITY_ALIASES.computeIfAbsent("CH", ignored -> new HashMap<>()).put("luzern", "루체른");
        CITY_ALIASES.computeIfAbsent("CH", ignored -> new HashMap<>()).put("zurich", "취리히");
        CITY_ALIASES.computeIfAbsent("CH", ignored -> new HashMap<>()).put("zürich", "취리히");
        CITY_ALIASES.computeIfAbsent("CL", ignored -> new HashMap<>()).put("santiago", "산티아고");
        CITY_ALIASES.computeIfAbsent("CL", ignored -> new HashMap<>()).put("valparaíso", "발파라이소");
        CITY_ALIASES.computeIfAbsent("CN", ignored -> new HashMap<>()).put("beijing", "베이징");
        CITY_ALIASES.computeIfAbsent("CN", ignored -> new HashMap<>()).put("chengdu", "청두");
        CITY_ALIASES.computeIfAbsent("CN", ignored -> new HashMap<>()).put("chongqing", "충칭");
        CITY_ALIASES.computeIfAbsent("CN", ignored -> new HashMap<>()).put("guangzhou", "광저우");
        CITY_ALIASES.computeIfAbsent("CN", ignored -> new HashMap<>()).put("hangzhou", "항저우");
        CITY_ALIASES.computeIfAbsent("CN", ignored -> new HashMap<>()).put("nanjing", "난징");
        CITY_ALIASES.computeIfAbsent("CN", ignored -> new HashMap<>()).put("peking", "베이징");
        CITY_ALIASES.computeIfAbsent("CN", ignored -> new HashMap<>()).put("shanghai", "상하이");
        CITY_ALIASES.computeIfAbsent("CN", ignored -> new HashMap<>()).put("shenzhen", "선전");
        CITY_ALIASES.computeIfAbsent("CN", ignored -> new HashMap<>()).put("suzhou", "쑤저우");
        CITY_ALIASES.computeIfAbsent("CN", ignored -> new HashMap<>()).put("tianjin", "톈진");
        CITY_ALIASES.computeIfAbsent("CN", ignored -> new HashMap<>()).put("wuhan", "우한");
        CITY_ALIASES.computeIfAbsent("CN", ignored -> new HashMap<>()).put("xian", "시안");
        CITY_ALIASES.computeIfAbsent("CN", ignored -> new HashMap<>()).put("xian", "시안");
        CITY_ALIASES.computeIfAbsent("CZ", ignored -> new HashMap<>()).put("prague", "프라하");
        CITY_ALIASES.computeIfAbsent("CZ", ignored -> new HashMap<>()).put("praha", "프라하");
        CITY_ALIASES.computeIfAbsent("DE", ignored -> new HashMap<>()).put("berlin", "베를린");
        CITY_ALIASES.computeIfAbsent("DE", ignored -> new HashMap<>()).put("cologne", "쾰른");
        CITY_ALIASES.computeIfAbsent("DE", ignored -> new HashMap<>()).put("dresden", "드레스덴");
        CITY_ALIASES.computeIfAbsent("DE", ignored -> new HashMap<>()).put("düsseldorf", "뒤셀도르프");
        CITY_ALIASES.computeIfAbsent("DE", ignored -> new HashMap<>()).put("frankfurt", "프랑크푸르트");
        CITY_ALIASES.computeIfAbsent("DE", ignored -> new HashMap<>()).put("hamburg", "함부르크");
        CITY_ALIASES.computeIfAbsent("DE", ignored -> new HashMap<>()).put("köln", "쾰른");
        CITY_ALIASES.computeIfAbsent("DE", ignored -> new HashMap<>()).put("munich", "뮌헨");
        CITY_ALIASES.computeIfAbsent("DE", ignored -> new HashMap<>()).put("münchen", "뮌헨");
        CITY_ALIASES.computeIfAbsent("EG", ignored -> new HashMap<>()).put("alexandria", "알렉산드리아");
        CITY_ALIASES.computeIfAbsent("EG", ignored -> new HashMap<>()).put("cairo", "카이로");
        CITY_ALIASES.computeIfAbsent("EG", ignored -> new HashMap<>()).put("giza", "기자");
        CITY_ALIASES.computeIfAbsent("EG", ignored -> new HashMap<>()).put("luxor", "룩소르");
        CITY_ALIASES.computeIfAbsent("ES", ignored -> new HashMap<>()).put("barcelona", "바르셀로나");
        CITY_ALIASES.computeIfAbsent("ES", ignored -> new HashMap<>()).put("granada", "그라나다");
        CITY_ALIASES.computeIfAbsent("ES", ignored -> new HashMap<>()).put("madrid", "마드리드");
        CITY_ALIASES.computeIfAbsent("ES", ignored -> new HashMap<>()).put("malaga", "말라가");
        CITY_ALIASES.computeIfAbsent("ES", ignored -> new HashMap<>()).put("málaga", "말라가");
        CITY_ALIASES.computeIfAbsent("ES", ignored -> new HashMap<>()).put("sevilla", "세비야");
        CITY_ALIASES.computeIfAbsent("ES", ignored -> new HashMap<>()).put("seville", "세비야");
        CITY_ALIASES.computeIfAbsent("ES", ignored -> new HashMap<>()).put("valencia", "발렌시아");
        CITY_ALIASES.computeIfAbsent("FR", ignored -> new HashMap<>()).put("bordeaux", "보르도");
        CITY_ALIASES.computeIfAbsent("FR", ignored -> new HashMap<>()).put("lille", "릴");
        CITY_ALIASES.computeIfAbsent("FR", ignored -> new HashMap<>()).put("lyon", "리옹");
        CITY_ALIASES.computeIfAbsent("FR", ignored -> new HashMap<>()).put("marseille", "마르세유");
        CITY_ALIASES.computeIfAbsent("FR", ignored -> new HashMap<>()).put("nice", "니스");
        CITY_ALIASES.computeIfAbsent("FR", ignored -> new HashMap<>()).put("paris", "파리");
        CITY_ALIASES.computeIfAbsent("FR", ignored -> new HashMap<>()).put("strasbourg", "스트라스부르");
        CITY_ALIASES.computeIfAbsent("FR", ignored -> new HashMap<>()).put("toulouse", "툴루즈");
        CITY_ALIASES.computeIfAbsent("GB", ignored -> new HashMap<>()).put("birmingham", "버밍엄");
        CITY_ALIASES.computeIfAbsent("GB", ignored -> new HashMap<>()).put("bristol", "브리스톨");
        CITY_ALIASES.computeIfAbsent("GB", ignored -> new HashMap<>()).put("cambridge", "케임브리지");
        CITY_ALIASES.computeIfAbsent("GB", ignored -> new HashMap<>()).put("edinburgh", "에든버러");
        CITY_ALIASES.computeIfAbsent("GB", ignored -> new HashMap<>()).put("glasgow", "글래스고");
        CITY_ALIASES.computeIfAbsent("GB", ignored -> new HashMap<>()).put("greaterlondon", "런던");
        CITY_ALIASES.computeIfAbsent("GB", ignored -> new HashMap<>()).put("liverpool", "리버풀");
        CITY_ALIASES.computeIfAbsent("GB", ignored -> new HashMap<>()).put("london", "런던");
        CITY_ALIASES.computeIfAbsent("GB", ignored -> new HashMap<>()).put("manchester", "맨체스터");
        CITY_ALIASES.computeIfAbsent("GB", ignored -> new HashMap<>()).put("oxford", "옥스퍼드");
        CITY_ALIASES.computeIfAbsent("GR", ignored -> new HashMap<>()).put("athens", "아테네");
        CITY_ALIASES.computeIfAbsent("GR", ignored -> new HashMap<>()).put("athina", "아테네");
        CITY_ALIASES.computeIfAbsent("GR", ignored -> new HashMap<>()).put("thessaloniki", "테살로니키");
        CITY_ALIASES.computeIfAbsent("HK", ignored -> new HashMap<>()).put("hongkong", "홍콩");
        CITY_ALIASES.computeIfAbsent("HK", ignored -> new HashMap<>()).put("hongkongisland", "홍콩");
        CITY_ALIASES.computeIfAbsent("HK", ignored -> new HashMap<>()).put("kowloon", "홍콩");
        CITY_ALIASES.computeIfAbsent("HU", ignored -> new HashMap<>()).put("budapest", "부다페스트");
        CITY_ALIASES.computeIfAbsent("ID", ignored -> new HashMap<>()).put("bali", "발리");
        CITY_ALIASES.computeIfAbsent("ID", ignored -> new HashMap<>()).put("bandung", "반둥");
        CITY_ALIASES.computeIfAbsent("ID", ignored -> new HashMap<>()).put("denpasar", "덴파사르");
        CITY_ALIASES.computeIfAbsent("ID", ignored -> new HashMap<>()).put("jakarta", "자카르타");
        CITY_ALIASES.computeIfAbsent("ID", ignored -> new HashMap<>()).put("surabaya", "수라바야");
        CITY_ALIASES.computeIfAbsent("ID", ignored -> new HashMap<>()).put("yogyakarta", "욕야카르타");
        CITY_ALIASES.computeIfAbsent("IL", ignored -> new HashMap<>()).put("jerusalem", "예루살렘");
        CITY_ALIASES.computeIfAbsent("IL", ignored -> new HashMap<>()).put("telaviv", "텔아비브");
        CITY_ALIASES.computeIfAbsent("IN", ignored -> new HashMap<>()).put("agra", "아그라");
        CITY_ALIASES.computeIfAbsent("IN", ignored -> new HashMap<>()).put("bangalore", "벵갈루루");
        CITY_ALIASES.computeIfAbsent("IN", ignored -> new HashMap<>()).put("bengaluru", "벵갈루루");
        CITY_ALIASES.computeIfAbsent("IN", ignored -> new HashMap<>()).put("chennai", "첸나이");
        CITY_ALIASES.computeIfAbsent("IN", ignored -> new HashMap<>()).put("delhi", "델리");
        CITY_ALIASES.computeIfAbsent("IN", ignored -> new HashMap<>()).put("jaipur", "자이푸르");
        CITY_ALIASES.computeIfAbsent("IN", ignored -> new HashMap<>()).put("kolkata", "콜카타");
        CITY_ALIASES.computeIfAbsent("IN", ignored -> new HashMap<>()).put("mumbai", "뭄바이");
        CITY_ALIASES.computeIfAbsent("IN", ignored -> new HashMap<>()).put("newdelhi", "뉴델리");
        CITY_ALIASES.computeIfAbsent("IN", ignored -> new HashMap<>()).put("varanasi", "바라나시");
        CITY_ALIASES.computeIfAbsent("IT", ignored -> new HashMap<>()).put("bologna", "볼로냐");
        CITY_ALIASES.computeIfAbsent("IT", ignored -> new HashMap<>()).put("firenze", "피렌체");
        CITY_ALIASES.computeIfAbsent("IT", ignored -> new HashMap<>()).put("florence", "피렌체");
        CITY_ALIASES.computeIfAbsent("IT", ignored -> new HashMap<>()).put("milan", "밀라노");
        CITY_ALIASES.computeIfAbsent("IT", ignored -> new HashMap<>()).put("milano", "밀라노");
        CITY_ALIASES.computeIfAbsent("IT", ignored -> new HashMap<>()).put("naples", "나폴리");
        CITY_ALIASES.computeIfAbsent("IT", ignored -> new HashMap<>()).put("napoli", "나폴리");
        CITY_ALIASES.computeIfAbsent("IT", ignored -> new HashMap<>()).put("pisa", "피사");
        CITY_ALIASES.computeIfAbsent("IT", ignored -> new HashMap<>()).put("roma", "로마");
        CITY_ALIASES.computeIfAbsent("IT", ignored -> new HashMap<>()).put("rome", "로마");
        CITY_ALIASES.computeIfAbsent("IT", ignored -> new HashMap<>()).put("torino", "토리노");
        CITY_ALIASES.computeIfAbsent("IT", ignored -> new HashMap<>()).put("turin", "토리노");
        CITY_ALIASES.computeIfAbsent("IT", ignored -> new HashMap<>()).put("venezia", "베네치아");
        CITY_ALIASES.computeIfAbsent("IT", ignored -> new HashMap<>()).put("venice", "베네치아");
        CITY_ALIASES.computeIfAbsent("JP", ignored -> new HashMap<>()).put("chiba", "지바");
        CITY_ALIASES.computeIfAbsent("JP", ignored -> new HashMap<>()).put("fukuoka", "후쿠오카");
        CITY_ALIASES.computeIfAbsent("JP", ignored -> new HashMap<>()).put("hachioji", "하치오지");
        CITY_ALIASES.computeIfAbsent("JP", ignored -> new HashMap<>()).put("hakodate", "하코다테");
        CITY_ALIASES.computeIfAbsent("JP", ignored -> new HashMap<>()).put("hiroshima", "히로시마");
        CITY_ALIASES.computeIfAbsent("JP", ignored -> new HashMap<>()).put("kanazawa", "가나자와");
        CITY_ALIASES.computeIfAbsent("JP", ignored -> new HashMap<>()).put("kawasaki", "가와사키");
        CITY_ALIASES.computeIfAbsent("JP", ignored -> new HashMap<>()).put("kobe", "고베");
        CITY_ALIASES.computeIfAbsent("JP", ignored -> new HashMap<>()).put("kumamoto", "구마모토");
        CITY_ALIASES.computeIfAbsent("JP", ignored -> new HashMap<>()).put("kyoto", "교토");
        CITY_ALIASES.computeIfAbsent("JP", ignored -> new HashMap<>()).put("nagasaki", "나가사키");
        CITY_ALIASES.computeIfAbsent("JP", ignored -> new HashMap<>()).put("nagoya", "나고야");
        CITY_ALIASES.computeIfAbsent("JP", ignored -> new HashMap<>()).put("naha", "나하");
        CITY_ALIASES.computeIfAbsent("JP", ignored -> new HashMap<>()).put("nara", "나라");
        CITY_ALIASES.computeIfAbsent("JP", ignored -> new HashMap<>()).put("okinawa", "오키나와");
        CITY_ALIASES.computeIfAbsent("JP", ignored -> new HashMap<>()).put("osaka", "오사카");
        CITY_ALIASES.computeIfAbsent("JP", ignored -> new HashMap<>()).put("saitama", "사이타마");
        CITY_ALIASES.computeIfAbsent("JP", ignored -> new HashMap<>()).put("sapporo", "삿포로");
        CITY_ALIASES.computeIfAbsent("JP", ignored -> new HashMap<>()).put("sendai", "센다이");
        CITY_ALIASES.computeIfAbsent("JP", ignored -> new HashMap<>()).put("tokyo", "도쿄");
        CITY_ALIASES.computeIfAbsent("JP", ignored -> new HashMap<>()).put("tokyo", "도쿄");
        CITY_ALIASES.computeIfAbsent("JP", ignored -> new HashMap<>()).put("yokohama", "요코하마");
        CITY_ALIASES.computeIfAbsent("KE", ignored -> new HashMap<>()).put("mombasa", "몸바사");
        CITY_ALIASES.computeIfAbsent("KE", ignored -> new HashMap<>()).put("nairobi", "나이로비");
        CITY_ALIASES.computeIfAbsent("KR", ignored -> new HashMap<>()).put("busan", "부산");
        CITY_ALIASES.computeIfAbsent("KR", ignored -> new HashMap<>()).put("dae", "대구");
        CITY_ALIASES.computeIfAbsent("KR", ignored -> new HashMap<>()).put("daejeon", "대전");
        CITY_ALIASES.computeIfAbsent("KR", ignored -> new HashMap<>()).put("gwangju", "광주");
        CITY_ALIASES.computeIfAbsent("KR", ignored -> new HashMap<>()).put("incheon", "인천");
        CITY_ALIASES.computeIfAbsent("KR", ignored -> new HashMap<>()).put("jeju", "제주");
        CITY_ALIASES.computeIfAbsent("KR", ignored -> new HashMap<>()).put("jeju", "제주");
        CITY_ALIASES.computeIfAbsent("KR", ignored -> new HashMap<>()).put("seogwipo", "서귀포");
        CITY_ALIASES.computeIfAbsent("KR", ignored -> new HashMap<>()).put("seoul", "서울");
        CITY_ALIASES.computeIfAbsent("KR", ignored -> new HashMap<>()).put("suwon", "수원");
        CITY_ALIASES.computeIfAbsent("KR", ignored -> new HashMap<>()).put("ulsan", "울산");
        CITY_ALIASES.computeIfAbsent("MA", ignored -> new HashMap<>()).put("casablanca", "카사블랑카");
        CITY_ALIASES.computeIfAbsent("MA", ignored -> new HashMap<>()).put("fez", "페스");
        CITY_ALIASES.computeIfAbsent("MA", ignored -> new HashMap<>()).put("fès", "페스");
        CITY_ALIASES.computeIfAbsent("MA", ignored -> new HashMap<>()).put("marrakech", "마라케시");
        CITY_ALIASES.computeIfAbsent("MA", ignored -> new HashMap<>()).put("marrakesh", "마라케시");
        CITY_ALIASES.computeIfAbsent("MA", ignored -> new HashMap<>()).put("rabat", "라바트");
        CITY_ALIASES.computeIfAbsent("MX", ignored -> new HashMap<>()).put("cancun", "칸쿤");
        CITY_ALIASES.computeIfAbsent("MX", ignored -> new HashMap<>()).put("cancún", "칸쿤");
        CITY_ALIASES.computeIfAbsent("MX", ignored -> new HashMap<>()).put("ciudaddeméxico", "멕시코시티");
        CITY_ALIASES.computeIfAbsent("MX", ignored -> new HashMap<>()).put("guadalajara", "과달라하라");
        CITY_ALIASES.computeIfAbsent("MX", ignored -> new HashMap<>()).put("mexico", "멕시코시티");
        CITY_ALIASES.computeIfAbsent("MX", ignored -> new HashMap<>()).put("monterrey", "몬테레이");
        CITY_ALIASES.computeIfAbsent("MY", ignored -> new HashMap<>()).put("georgetown", "조지타운");
        CITY_ALIASES.computeIfAbsent("MY", ignored -> new HashMap<>()).put("johorbahru", "조호르바루");
        CITY_ALIASES.computeIfAbsent("MY", ignored -> new HashMap<>()).put("kualalumpur", "쿠알라룸푸르");
        CITY_ALIASES.computeIfAbsent("MY", ignored -> new HashMap<>()).put("malacca", "믈라카");
        CITY_ALIASES.computeIfAbsent("MY", ignored -> new HashMap<>()).put("melaka", "믈라카");
        CITY_ALIASES.computeIfAbsent("MY", ignored -> new HashMap<>()).put("penang", "페낭");
        CITY_ALIASES.computeIfAbsent("NL", ignored -> new HashMap<>()).put("amsterdam", "암스테르담");
        CITY_ALIASES.computeIfAbsent("NL", ignored -> new HashMap<>()).put("denhaag", "헤이그");
        CITY_ALIASES.computeIfAbsent("NL", ignored -> new HashMap<>()).put("rotterdam", "로테르담");
        CITY_ALIASES.computeIfAbsent("NL", ignored -> new HashMap<>()).put("thehague", "헤이그");
        CITY_ALIASES.computeIfAbsent("NZ", ignored -> new HashMap<>()).put("auckland", "오클랜드");
        CITY_ALIASES.computeIfAbsent("NZ", ignored -> new HashMap<>()).put("christchurch", "크라이스트처치");
        CITY_ALIASES.computeIfAbsent("NZ", ignored -> new HashMap<>()).put("queenstown", "퀸스타운");
        CITY_ALIASES.computeIfAbsent("NZ", ignored -> new HashMap<>()).put("wellington", "웰링턴");
        CITY_ALIASES.computeIfAbsent("PE", ignored -> new HashMap<>()).put("cusco", "쿠스코");
        CITY_ALIASES.computeIfAbsent("PE", ignored -> new HashMap<>()).put("cuzco", "쿠스코");
        CITY_ALIASES.computeIfAbsent("PE", ignored -> new HashMap<>()).put("lima", "리마");
        CITY_ALIASES.computeIfAbsent("PH", ignored -> new HashMap<>()).put("cebu", "세부");
        CITY_ALIASES.computeIfAbsent("PH", ignored -> new HashMap<>()).put("cebu", "세부");
        CITY_ALIASES.computeIfAbsent("PH", ignored -> new HashMap<>()).put("davao", "다바오");
        CITY_ALIASES.computeIfAbsent("PH", ignored -> new HashMap<>()).put("makati", "마카티");
        CITY_ALIASES.computeIfAbsent("PH", ignored -> new HashMap<>()).put("manila", "마닐라");
        CITY_ALIASES.computeIfAbsent("PH", ignored -> new HashMap<>()).put("quezon", "케손시티");
        CITY_ALIASES.computeIfAbsent("PT", ignored -> new HashMap<>()).put("lisboa", "리스본");
        CITY_ALIASES.computeIfAbsent("PT", ignored -> new HashMap<>()).put("lisbon", "리스본");
        CITY_ALIASES.computeIfAbsent("PT", ignored -> new HashMap<>()).put("porto", "포르투");
        CITY_ALIASES.computeIfAbsent("SA", ignored -> new HashMap<>()).put("jeddah", "제다");
        CITY_ALIASES.computeIfAbsent("SA", ignored -> new HashMap<>()).put("makkah", "메카");
        CITY_ALIASES.computeIfAbsent("SA", ignored -> new HashMap<>()).put("mecca", "메카");
        CITY_ALIASES.computeIfAbsent("SA", ignored -> new HashMap<>()).put("riyadh", "리야드");
        CITY_ALIASES.computeIfAbsent("SG", ignored -> new HashMap<>()).put("singapore", "싱가포르");
        CITY_ALIASES.computeIfAbsent("TH", ignored -> new HashMap<>()).put("bangkok", "방콕");
        CITY_ALIASES.computeIfAbsent("TH", ignored -> new HashMap<>()).put("chiangmai", "치앙마이");
        CITY_ALIASES.computeIfAbsent("TH", ignored -> new HashMap<>()).put("chiangmai", "치앙마이");
        CITY_ALIASES.computeIfAbsent("TH", ignored -> new HashMap<>()).put("krabi", "끄라비");
        CITY_ALIASES.computeIfAbsent("TH", ignored -> new HashMap<>()).put("krungthepmahanakhon", "방콕");
        CITY_ALIASES.computeIfAbsent("TH", ignored -> new HashMap<>()).put("pattaya", "파타야");
        CITY_ALIASES.computeIfAbsent("TH", ignored -> new HashMap<>()).put("phuket", "푸껫");
        CITY_ALIASES.computeIfAbsent("TR", ignored -> new HashMap<>()).put("ankara", "앙카라");
        CITY_ALIASES.computeIfAbsent("TR", ignored -> new HashMap<>()).put("antalya", "안탈리아");
        CITY_ALIASES.computeIfAbsent("TR", ignored -> new HashMap<>()).put("bursa", "부르사");
        CITY_ALIASES.computeIfAbsent("TR", ignored -> new HashMap<>()).put("istanbul", "이스탄불");
        CITY_ALIASES.computeIfAbsent("TR", ignored -> new HashMap<>()).put("izmir", "이즈미르");
        CITY_ALIASES.computeIfAbsent("TR", ignored -> new HashMap<>()).put("i̇stanbul", "이스탄불");
        CITY_ALIASES.computeIfAbsent("TR", ignored -> new HashMap<>()).put("i̇zmir", "이즈미르");
        CITY_ALIASES.computeIfAbsent("TW", ignored -> new HashMap<>()).put("hsinchu", "신주");
        CITY_ALIASES.computeIfAbsent("TW", ignored -> new HashMap<>()).put("kaohsiung", "가오슝");
        CITY_ALIASES.computeIfAbsent("TW", ignored -> new HashMap<>()).put("newtaipei", "신베이");
        CITY_ALIASES.computeIfAbsent("TW", ignored -> new HashMap<>()).put("newtaipei", "신베이");
        CITY_ALIASES.computeIfAbsent("TW", ignored -> new HashMap<>()).put("taichung", "타이중");
        CITY_ALIASES.computeIfAbsent("TW", ignored -> new HashMap<>()).put("tainan", "타이난");
        CITY_ALIASES.computeIfAbsent("TW", ignored -> new HashMap<>()).put("taipei", "타이베이");
        CITY_ALIASES.computeIfAbsent("TW", ignored -> new HashMap<>()).put("taipei", "타이베이");
        CITY_ALIASES.computeIfAbsent("US", ignored -> new HashMap<>()).put("atlanta", "애틀랜타");
        CITY_ALIASES.computeIfAbsent("US", ignored -> new HashMap<>()).put("boston", "보스턴");
        CITY_ALIASES.computeIfAbsent("US", ignored -> new HashMap<>()).put("bronx", "뉴욕");
        CITY_ALIASES.computeIfAbsent("US", ignored -> new HashMap<>()).put("brooklyn", "뉴욕");
        CITY_ALIASES.computeIfAbsent("US", ignored -> new HashMap<>()).put("chicago", "시카고");
        CITY_ALIASES.computeIfAbsent("US", ignored -> new HashMap<>()).put("dallas", "댈러스");
        CITY_ALIASES.computeIfAbsent("US", ignored -> new HashMap<>()).put("honolulu", "호놀룰루");
        CITY_ALIASES.computeIfAbsent("US", ignored -> new HashMap<>()).put("houston", "휴스턴");
        CITY_ALIASES.computeIfAbsent("US", ignored -> new HashMap<>()).put("lasvegas", "라스베이거스");
        CITY_ALIASES.computeIfAbsent("US", ignored -> new HashMap<>()).put("losangeles", "로스앤젤레스");
        CITY_ALIASES.computeIfAbsent("US", ignored -> new HashMap<>()).put("manhattan", "뉴욕");
        CITY_ALIASES.computeIfAbsent("US", ignored -> new HashMap<>()).put("miami", "마이애미");
        CITY_ALIASES.computeIfAbsent("US", ignored -> new HashMap<>()).put("newyork", "뉴욕");
        CITY_ALIASES.computeIfAbsent("US", ignored -> new HashMap<>()).put("newyork", "뉴욕");
        CITY_ALIASES.computeIfAbsent("US", ignored -> new HashMap<>()).put("orlando", "올랜도");
        CITY_ALIASES.computeIfAbsent("US", ignored -> new HashMap<>()).put("philadelphia", "필라델피아");
        CITY_ALIASES.computeIfAbsent("US", ignored -> new HashMap<>()).put("queens", "뉴욕");
        CITY_ALIASES.computeIfAbsent("US", ignored -> new HashMap<>()).put("sandiego", "샌디에이고");
        CITY_ALIASES.computeIfAbsent("US", ignored -> new HashMap<>()).put("sanfrancisco", "샌프란시스코");
        CITY_ALIASES.computeIfAbsent("US", ignored -> new HashMap<>()).put("seattle", "시애틀");
        CITY_ALIASES.computeIfAbsent("US", ignored -> new HashMap<>()).put("statenisland", "뉴욕");
        CITY_ALIASES.computeIfAbsent("US", ignored -> new HashMap<>()).put("thebronx", "뉴욕");
        CITY_ALIASES.computeIfAbsent("US", ignored -> new HashMap<>()).put("washington", "워싱턴");
        CITY_ALIASES.computeIfAbsent("US", ignored -> new HashMap<>()).put("washingtondc", "워싱턴");
        CITY_ALIASES.computeIfAbsent("VN", ignored -> new HashMap<>()).put("danang", "다낭");
        CITY_ALIASES.computeIfAbsent("VN", ignored -> new HashMap<>()).put("danang", "다낭");
        CITY_ALIASES.computeIfAbsent("VN", ignored -> new HashMap<>()).put("hanoi", "하노이");
        CITY_ALIASES.computeIfAbsent("VN", ignored -> new HashMap<>()).put("hanoi", "하노이");
        CITY_ALIASES.computeIfAbsent("VN", ignored -> new HashMap<>()).put("hochiminh", "호찌민");
        CITY_ALIASES.computeIfAbsent("VN", ignored -> new HashMap<>()).put("hochiminh", "호찌민");
        CITY_ALIASES.computeIfAbsent("VN", ignored -> new HashMap<>()).put("hoian", "호이안");
        CITY_ALIASES.computeIfAbsent("VN", ignored -> new HashMap<>()).put("hue", "후에");
        CITY_ALIASES.computeIfAbsent("VN", ignored -> new HashMap<>()).put("hộian", "호이안");
        CITY_ALIASES.computeIfAbsent("VN", ignored -> new HashMap<>()).put("nhatrang", "냐짱");
        CITY_ALIASES.computeIfAbsent("ZA", ignored -> new HashMap<>()).put("capetown", "케이프타운");
        CITY_ALIASES.computeIfAbsent("ZA", ignored -> new HashMap<>()).put("durban", "더반");
        CITY_ALIASES.computeIfAbsent("ZA", ignored -> new HashMap<>()).put("johannesburg", "요하네스버그");
        CITY_ALIASES.computeIfAbsent("ZA", ignored -> new HashMap<>()).put("pretoria", "프리토리아");
    }

    private static String cityKey(String value) {
        return normalized(value).replaceAll("[\\s._'’.-]", "")
                .replaceAll("(?i)(metropolis|prefecture|city|ward|district|gu|ku|区|구)$", "");
    }
    // 기존 DB의 place_city, place_address를 함께 사용해 도시 내 구를 대표 도시로 통합합니다.
    // 다른 도시/국가의 같은 구 이름까지 합치는 것을 막기 위해 주소의 광역도시도 확인합니다.
    private static String normalizeCity(String country, String city, String address) {
        String raw = city == null ? "" : city.trim();
        if (raw.isEmpty()) return "";
        String code = COUNTRY_CODES.get(country);
        if (code == null) return raw;
        String key = cityKey(raw);
        String addr = normalized(address);
        if ("JP".equals(code)) {
            Set<String> tokyoWards = new LinkedHashSet<>(java.util.Arrays.asList(
                    "adachi", "arakawa", "bunkyo", "chiyoda", "chuo", "edogawa", "itabashi",
                    "katsushika", "kita", "koto", "meguro", "minato", "nakano", "nerima",
                    "ota", "setagaya", "shibuya", "shinagawa", "shinjuku", "suginami",
                    "sumida", "taito", "toshima", "미나토", "시부야", "신주쿠", "스미다", "港"));
            if (tokyoWards.contains(key) && (addr.contains("tokyo") || addr.contains("도쿄")
                    || addr.contains("東京都") || addr.contains("東京")
                    || key.equals("minato") && raw.toLowerCase(Locale.ROOT).contains("city")
                            && addr.isEmpty())) return "도쿄";
        }
        if ("JP".equals(code) && raw.matches("(?iu).*?(?:ward|区|[- ]ku)$")) {
            // 도쿄 외에도 오사카·교토 등 대도시의 '구'를 독립 도시로 세지 않는다.
            String[][] majorCityNames = {
                {"osaka", "오사카"}, {"kyoto", "교토"},
                {"yokohama", "요코하마"}, {"nagoya", "나고야"},
                {"sapporo", "삿포로"}, {"kobe", "고베"},
                {"fukuoka", "후쿠오카"}, {"hiroshima", "히로시마"},
                {"sendai", "센다이"}, {"tokyo", "도쿄"}
            };
            for (String[] major : majorCityNames) {
                if (addr.contains(major[0]) || addr.contains(major[1])) return major[1];
            }
        }
        if ("US".equals(code) && (key.equals("brooklyn") || key.equals("queens")
                || key.equals("bronx") || key.equals("thebronx")
                || key.equals("manhattan") || key.equals("statenisland"))) return "뉴욕";
        // 주소에 확인되는 광역 도시를 쓰고, 단독 구 이름으로는 도시를 추정하지 않습니다.
        if ("GB".equals(code) && (addr.contains("london") || addr.contains("런던")))
            return "런던";
        if ("FR".equals(code) && (addr.contains("paris") || addr.contains("파리"))
                && (key.contains("arrondissement") || key.matches("[0-9]+e?r?"))) return "파리";
        if (raw.matches("(?iu).*?(?:district|ward|구|区|[- ]gu)$")) {
            String[][] metroAddresses = {
                {"KR", "seoul", "서울"}, {"KR", "busan", "부산"},
                {"KR", "incheon", "인천"}, {"KR", "daegu", "대구"},
                {"KR", "daejeon", "대전"}, {"KR", "gwangju", "광주"},
                {"KR", "ulsan", "울산"}, {"CN", "beijing", "베이징"},
                {"CN", "shanghai", "상하이"}, {"CN", "tianjin", "톈진"},
                {"CN", "chongqing", "충칭"}, {"TW", "taipei", "타이베이"},
                {"TH", "bangkok", "방콕"}, {"TR", "istanbul", "이스탄불"},
                {"MX", "mexico city", "멕시코시티"}
            };
            for (String[] metro : metroAddresses) {
                if (code.equals(metro[0]) && (addr.contains(metro[1])
                        || addr.contains(metro[2]))) return metro[2];
            }
        }
        Map<String, String> aliases = CITY_ALIASES.get(code);
        return aliases == null ? raw : aliases.getOrDefault(key, raw);
    }

    public static String label(ItineraryDto schedule, List<ItineraryCardGeoRow> rows) {
        // DB 이관 전 단일 국가 일정은 기존 국가를 그대로 표시한다.
        if (rows == null || rows.isEmpty()) {
            return schedule.getCountry() == null || schedule.getCountry().trim().isEmpty()
                    ? "여행 지역 미지정" : schedule.getCountry().trim();
        }
        // SQL의 LEFT JOIN으로 여러 블록이 있더라도 각 시트별로 모은다.
        Map<Integer, SheetCities> sheets = new LinkedHashMap<>();
        for (ItineraryCardGeoRow row : rows) {
            if (row.getSheetOrder() == null) continue;
            SheetCities item = sheets.get(row.getSheetOrder());
            if (item == null) {
                item = new SheetCities(row.getCountry());
                sheets.put(row.getSheetOrder(), item);
            }
            if ((row.getPlaceCity() != null && !row.getPlaceCity().trim().isEmpty())
                    || (row.getPlaceAddress() != null && !row.getPlaceAddress().trim().isEmpty())) {
                String city = resolvedKoreanAdmin1(item.country, row.getPlaceCity(), row.getPlaceAddress());
                if (city.isEmpty() && koreanAdmin1ByCountry.isEmpty()) {
                    // Failed offline startup: conservative legacy Korean-only rendering.
                    city = normalizeCity(item.country, row.getPlaceCity(), row.getPlaceAddress());
                    if (!city.matches(".*[가-힣].*")) city = "";
                }
                if (!city.isEmpty()) item.cities.putIfAbsent(normalized(city), city);
            }
        }
        List<SheetCities> ordered = new ArrayList<>(sheets.values());
        if (ordered.isEmpty()) return "여행 지역 미지정";

        // 출국/귀국 기록을 위한 경계 한국 시트 제외. 한국 국내 일정만 있으면 유지한다.
        boolean hasForeignDestination = false;
        for (SheetCities item : ordered) {
            if (!item.country.isEmpty() && !isKorea(item.country)) {
                hasForeignDestination = true;
                break;
            }
        }
        if (hasForeignDestination) {
            if (!ordered.isEmpty() && isKorea(ordered.get(0).country)) ordered.remove(0);
            if (!ordered.isEmpty() && isKorea(ordered.get(ordered.size()-1).country)) {
                ordered.remove(ordered.size()-1);
            }
        }

        Map<String, String> countries = new LinkedHashMap<>();
        Set<String> continents = new LinkedHashSet<>();
        Set<String> cityKeys = new LinkedHashSet<>();
        String oneCity = null;
        for (SheetCities item : ordered) {
            if (item.country.isEmpty()) continue;
            String countryKey = normalized(item.country);
            countries.putIfAbsent(countryKey, item.country);
            String continent = CONTINENTS.get(item.country);
            if (continent != null) continents.add(continent);
            for (Map.Entry<String,String> city : item.cities.entrySet()) {
                if (cityKeys.add(countryKey + ":" + city.getKey())) oneCity = city.getValue();
            }
        }
        if (countries.isEmpty()) return "여행 지역 미지정";
        if (continents.size() > 1) return continents.size() + "개 대륙";
        String onlyCountry = countries.values().iterator().next();
        String continent = continents.isEmpty() ? null : continents.iterator().next();
        if (countries.size() > 1) {
            return continent == null ? countries.size() + "개 국가" : continent;
        }
        if (cityKeys.size() == 1) return onlyCountry + " · " + oneCity;
        if (cityKeys.size() > 1 && continent != null) return continent + " · " + onlyCountry;
        return onlyCountry;
    }

    private static final class SheetCities {
        final String country;
        final Map<String, String> cities = new LinkedHashMap<>();
        SheetCities(String country) { this.country = country == null ? "" : country.trim(); }
    }
}
