package controller.itinerary;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import dto.member.UserDto;
import service.itinerary.ItineraryCartService;
import service.itinerary.ItineraryCartServiceImpl;

@WebServlet("/itinerary/cart/remove")
public class ItineraryCartRemove extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private final ItineraryCartService itineraryCartService;

    public ItineraryCartRemove() {
        itineraryCartService = new ItineraryCartServiceImpl();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        UserDto loginUser = session == null ? null : (UserDto) session.getAttribute("user");

        if (loginUser == null || loginUser.getUserId() <= 0) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return;
        }

        try {
            long itineraryId = readPositiveId(request.getParameter("itineraryId"), "일정 번호");
            long targetId = readPositiveId(request.getParameter("targetId"), "삭제 대상 번호");

            String itemType = request.getParameter("itemType");
            if (itemType == null || itemType.trim().isEmpty()) {
                throw new IllegalArgumentException("삭제 유형을 확인해주세요.");
            }

            itineraryCartService.removeFromCart(
                    loginUser.getUserId(), itineraryId, itemType.trim(), targetId);

            response.sendRedirect(request.getContextPath() + "/cart");

        } catch (IllegalArgumentException e) {
            getServletContext().log("장바구니 삭제 요청 오류: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/cart");
        } catch (Exception e) {
            getServletContext().log("장바구니 삭제 중 오류 발생", e);
            throw new ServletException("장바구니 항목 삭제 중 오류가 발생했습니다.", e);
        }
    }

    private long readPositiveId(String value, String name) {
        if (value == null || value.trim().isEmpty()) {
            throw new IllegalArgumentException(name + "를 확인해주세요.");
        }

        try {
            long id = Long.parseLong(value.trim());
            if (id <= 0) {
                throw new IllegalArgumentException(name + "는 양수여야 합니다.");
            }
            return id;
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("올바른 " + name + "가 아닙니다.");
        }
    }
}
