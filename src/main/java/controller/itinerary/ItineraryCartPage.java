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

@WebServlet("/cart")
public class ItineraryCartPage extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private final ItineraryCartService itineraryCartService;

    public ItineraryCartPage() {
        itineraryCartService = new ItineraryCartServiceImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Cache-Control", "no-store");

        HttpSession session = request.getSession(false);
        UserDto loginUser = session == null ? null : (UserDto) session.getAttribute("user");

        if (loginUser == null || loginUser.getUserId() <= 0) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return;
        }

        try {
            List<ItineraryDto> cartItineraries =
                    itineraryCartService.getCartItineraries(loginUser.getUserId());

            if (cartItineraries == null) {
                cartItineraries = Collections.emptyList();
            }

            request.setAttribute("cartItineraries", cartItineraries);
            request.setAttribute("cartTotalCount", cartItineraries.size());

            request.getRequestDispatcher("/view/travel/cart.jsp").forward(request, response);

        } catch (Exception e) {
            getServletContext().log("장바구니 페이지 조회 중 오류 발생", e);
            throw new ServletException("장바구니를 불러오는 중 오류가 발생했습니다.", e);
        }
    }
}
