package controller.itinerary;

import java.io.IOException;
import java.util.Collections;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import dto.itinerary.ItineraryDto;
import dto.member.UserDto;
import service.itinerary.ItineraryCartService;
import service.itinerary.ItineraryCartServiceImpl;

@WebServlet("/cart/load")
public class ItineraryCartLoad extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private final ItineraryCartService itineraryCartService;

    public ItineraryCartLoad() {
        itineraryCartService = new ItineraryCartServiceImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");
        response.setHeader("Cache-Control", "no-store");

        HttpSession session = request.getSession(false);
        UserDto loginUser = session == null ? null : (UserDto) session.getAttribute("user");

        if (loginUser == null || loginUser.getUserId() <= 0) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        int page = 2;
        int pageSize = 20;

        try {
            String pageParam = request.getParameter("page");
            if (pageParam != null && !pageParam.trim().isEmpty()) {
                page = Integer.parseInt(pageParam);
            }
            if (page < 1) {
                page = 1;
            }
        } catch (NumberFormatException e) {
            page = 2;
        }

        try {
            List<ItineraryDto> cartItineraries =
                    itineraryCartService.getCartItineraries(loginUser.getUserId(), page, pageSize);

            if (cartItineraries == null) {
                cartItineraries = Collections.emptyList();
            }

            request.setAttribute("cartItineraries", cartItineraries);
            request.setAttribute("page", page);
            request.setAttribute("pageSize", pageSize);

            request.getRequestDispatcher("/view/travel/cartCardList.jsp").forward(request, response);

        } catch (Exception e) {
            getServletContext().log("카트 추가 페이지 조회 중 오류 발생", e);
            throw new ServletException("카트를 추가로 불러오는 중 오류가 발생했습니다.", e);
        }
    }
}
