package service.advertisement;

import java.net.URI;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import org.apache.ibatis.session.SqlSession;
import config.MybatisSqlSessionFactory;
import dto.advertisement.AdvertisementDto;

/** Public fields only; no applicant/contact data is exposed. */
public class AdvertisementDisplayService {
    public List<AdvertisementDto> load(String position, String contextPath) {
        if (!java.util.Arrays.asList("TRIP_CARD", "TIP_SIDE", "MATE_SIDE", "CART_SIDE").contains(position))
            throw new IllegalArgumentException("지원하지 않는 광고 위치입니다.");
        List<AdvertisementDto> result = new ArrayList<>();
        try (SqlSession session = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {
            List<AdvertisementDto> ads = session.selectList(
                    "mapper.advertisement.advertisement.selectDisplayAds", position);
            for (AdvertisementDto ad : ads) {
                if (!httpUrl(ad.getLinkUrl())) continue;
                String image = imageUrl(ad.getImageUrl(), contextPath);
                if (image == null) continue;
                ad.setImageUrl(image);
                String right = imageUrl(ad.getImageUrlRight(), contextPath);
                ad.setImageUrlRight(right == null ? image : right);
                // Legacy applications have no dedicated public copy: never expose inquiry text.
                if (blank(ad.getSiteName())) ad.setSiteName(ad.getBusinessName());
                if (blank(ad.getHeadline())) ad.setHeadline("여행 혜택을 확인해보세요");
                if (blank(ad.getDescription())) ad.setDescription("광고주 홈페이지에서 자세한 내용을 확인하세요.");
                result.add(ad);
            }
        }
        Collections.shuffle(result);
        return result;
    }
    static boolean blank(String value) { return value == null || value.trim().isEmpty(); }
    static boolean httpUrl(String value) {
        try {
            URI uri = new URI(value);
            return ("http".equalsIgnoreCase(uri.getScheme()) || "https".equalsIgnoreCase(uri.getScheme()))
                    && uri.getHost() != null;
        } catch (Exception e) { return false; }
    }
    static String imageUrl(String value, String contextPath) {
        if (blank(value)) return null;
        value = value.trim();
        if (httpUrl(value)) return value;
        if (!value.startsWith("/") || value.startsWith("//") || value.contains("\\")) return null;
        if (!contextPath.isEmpty() && value.startsWith(contextPath + "/")) return value;
        return contextPath + value;
    }
}
