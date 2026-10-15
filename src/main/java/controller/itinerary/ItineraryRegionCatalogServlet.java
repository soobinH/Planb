package controller.itinerary;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.gson.Gson;

/** 서버에서 검증하는 목록과 화면의 목록이 언제나 동일하다. */
@WebServlet("/itinerary/regionCatalog")
public class ItineraryRegionCatalogServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");
        try {
            response.setHeader("Cache-Control", "private, max-age=3600");
            gson.toJson(ItineraryRegionCatalog.get(getServletContext()), response.getWriter());
        } catch (IllegalStateException ex) {
            getServletContext().log("한국어 1차 행정구역 초기화 실패", ex);
            response.resetBuffer();
            response.setStatus(HttpServletResponse.SC_SERVICE_UNAVAILABLE);
            response.setContentType("application/json; charset=UTF-8");
            response.getWriter().write("{\"error\":\"한글 지역 목록을 불러오지 못했습니다. 다시 시도해 주세요.\"}");
        }
    }
}
