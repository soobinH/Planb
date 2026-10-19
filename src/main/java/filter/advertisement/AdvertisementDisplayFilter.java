package filter.advertisement;

import java.io.IOException;
import java.util.List;
import java.util.concurrent.ThreadLocalRandom;
import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.*;
import dto.advertisement.AdvertisementDto;
import service.advertisement.AdvertisementDisplayService;

@WebFilter(urlPatterns = {"/home", "/tipDetail", "/mateDetail", "/cart",
    "/view/home/home.jsp", "/view/tips/tipDetail.jsp", "/view/mates/mateDetail.jsp", "/view/travel/cart.jsp"})
public class AdvertisementDisplayFilter implements Filter {
    @Override public void init(FilterConfig config) { }
    @Override public void destroy() { }
    @Override public void doFilter(ServletRequest input, ServletResponse output, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest request = (HttpServletRequest) input;
        String path = request.getServletPath();
        String position = path.contains("tipDetail") ? "TIP_SIDE" : path.contains("mateDetail") ? "MATE_SIDE"
                : path.contains("cart") ? "CART_SIDE" : "TRIP_CARD";
        ((HttpServletResponse) output).setHeader("Cache-Control", "no-store");
        try {
            List<AdvertisementDto> ads = new AdvertisementDisplayService().load(position, request.getContextPath());
            // Avoid showing the same first advertisement on consecutive refreshes when alternatives exist.
            if (!ads.isEmpty()) {
                HttpSession session = request.getSession();
                synchronized (session) {
                    Object previous = session.getAttribute("displayAdPrevious:" + position);
                    if (ads.size() > 1 && Long.valueOf(ads.get(0).getAdId()).equals(previous))
                        java.util.Collections.swap(ads, 0, 1);
                    session.setAttribute("displayAdPrevious:" + position, ads.get(0).getAdId());
                }
                if ("TRIP_CARD".equals(position)) {
                    request.setAttribute("displayHomeAds", ads);
                    request.setAttribute("homeAdInterval", ThreadLocalRandom.current().nextInt(3, 6));
                } else request.setAttribute("displaySideAd", ads.get(0));
            }
        } catch (Exception e) {
            request.getServletContext().log("광고 조회 실패: 본문은 정상 표시합니다.", e);
        }
        chain.doFilter(input, output);
    }
}
