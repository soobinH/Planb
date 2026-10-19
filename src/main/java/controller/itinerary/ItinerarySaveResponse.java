package controller.itinerary;

import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.Map;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import com.google.gson.Gson;

/** Multipart 일정 저장을 AJAX로 처리할 때 사용자 편집 화면을 보존하기 위한 응답. */
public final class ItinerarySaveResponse {
    private static final Gson GSON = new Gson();

    private ItinerarySaveResponse() {}

    public static boolean isAjax(HttpServletRequest request) {
        return "XMLHttpRequest".equalsIgnoreCase(request.getHeader("X-Requested-With"));
    }

    public static void success(HttpServletResponse response, String redirect) throws IOException {
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("ok", Boolean.TRUE);
        result.put("redirect", redirect);
        send(response, HttpServletResponse.SC_OK, result);
    }

    public static void failure(HttpServletResponse response, int status, String message) throws IOException {
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("ok", Boolean.FALSE);
        result.put("message", message == null || message.trim().isEmpty()
                ? "저장 요청을 처리하지 못했습니다." : message);
        send(response, status, result);
    }

    private static void send(HttpServletResponse response, int status, Map<String, Object> value)
            throws IOException {
        response.setStatus(status);
        response.setContentType("application/json;charset=UTF-8");
        response.setHeader("Cache-Control", "no-store");
        response.getWriter().write(GSON.toJson(value));
    }
}
