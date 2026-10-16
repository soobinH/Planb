package controller.travel;

import java.io.IOException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import dto.itinerary.ItineraryDto;
import dto.member.UserDto;
import service.itinerary.ItineraryService;
import service.itinerary.ItineraryServiceImpl;
import service.itinerary.ItineraryCardLocation;
import controller.itinerary.ItineraryRegionCatalog;

/**
 * Servlet implementation class ScheduleList
 */
@WebServlet({ "/schedules", "/schedules/load" })
public class ScheduleList extends HttpServlet {
	private static final long serialVersionUID = 1L;

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public ScheduleList() {
		super();
		// TODO Auto-generated constructor stub
	}

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		try {
			boolean loadRequest = "/schedules/load".equals(request.getServletPath());

			int offset = 0;

			if (loadRequest) {
				String offsetParam = request.getParameter("offset");

				if (offsetParam == null) {
					throw new IllegalArgumentException("조회 위치가 필요합니다.");
				}

				offset = Integer.parseInt(offsetParam);

				if (offset < 0) {
					throw new IllegalArgumentException("올바르지 않은 조회 위치입니다.");
				}
			}

			response.setContentType("text/html; charset=UTF-8");

			// 기존 세션만 가져오기
			HttpSession session = request.getSession(false);
			UserDto loginUser = null;
			if (session != null) {
				loginUser = (UserDto) session.getAttribute("user");
			}

			// 비로그인이면 null
			Long loginUserId = null;
			if (loginUser != null) {
				loginUserId = loginUser.getUserId();
			}

			// 검색어가 없으면 전체 공개 일정 조회
			String keyword = request.getParameter("keyword");

			if (keyword == null) {
				keyword = "";
			}

			keyword = keyword.trim();

			String country = request.getParameter("country");

			if (country == null) {
				country = "";
			}

			country = country.trim();

			String[] durations = request.getParameterValues("durations");
			String[] budgets = request.getParameterValues("budgets");
			String[] travelers = request.getParameterValues("travelers");

			String sort = request.getParameter("sort");

			if (!"views".equals(sort) && !"likes".equals(sort)) {
				sort = "latest";
			}

            // Card labels and the editor share the same CLDR Korean first-level names.
            try {
                ItineraryCardLocation.installKoreanAdmin1Catalog(
                        ItineraryRegionCatalog.get(getServletContext()));
            } catch (RuntimeException ex) {
                // Do not take the whole itinerary-list page offline if CLDR is unreachable.
                getServletContext().log("한글 1차 행정구역 목록 초기화 실패", ex);
            }

			ItineraryService service = new ItineraryServiceImpl();

			List<ItineraryDto> scheduleList = service.getScheduleList(loginUserId, keyword, country, durations, budgets,
					travelers, sort, offset);

			request.setAttribute("scheduleList", scheduleList);

			// 추가 조회는 카드 HTML만 반환
			if (loadRequest) {
				response.setHeader("Cache-Control", "no-store");

				request.getRequestDispatcher("/view/travel/scheduleCards.jsp").forward(request, response);

				return;
			}

			// 첫 화면에서만 전체 개수 조회
			long totalCount = service.countScheduleList(keyword, country, durations, budgets, travelers);

			request.setAttribute("totalCount", totalCount);

			// 조회 후에도 검색창에 입력한 검색어 유지
			request.setAttribute("keyword", keyword);
			request.setAttribute("country", country);
			request.setAttribute("sort", sort);

			// 화면 출력
			request.getRequestDispatcher("/view/travel/scheduleList.jsp").forward(request, response);

		} catch (IllegalArgumentException e) {
			response.sendError(HttpServletResponse.SC_BAD_REQUEST, e.getMessage());
		} catch (Exception e) {
			e.printStackTrace();
			response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
		}
	}
}
