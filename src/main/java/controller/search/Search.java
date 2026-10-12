package controller.search;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import dto.community.MateDto;
import dto.community.TipDto;
import dto.itinerary.ItineraryDto;
import dto.member.UserDto;
import service.community.MateService;
import service.community.MateServiceImpl;
import service.community.TipService;
import service.community.TipServiceImpl;
import service.itinerary.ItineraryService;
import service.itinerary.ItineraryServiceImpl;

@WebServlet("/search")
public class Search extends HttpServlet {

	private static final long serialVersionUID = 1L;

	private TipService tipService;
	private MateService mateService;
	private ItineraryService itineraryService;

	public Search() {
		super();
		tipService = new TipServiceImpl();
		mateService = new MateServiceImpl();
		itineraryService = new ItineraryServiceImpl();
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		request.setCharacterEncoding("UTF-8");

		String keyword = request.getParameter("q");

		if (keyword == null) {
			keyword = "";
		}

		keyword = keyword.trim();

		try {
			// =========================
			// 로그인 사용자 확인
			// =========================
			HttpSession session = request.getSession(false);

			UserDto loginUser = null;
			Long loginUserId = null;

			if (session != null) {
				loginUser = (UserDto) session.getAttribute("user");
			}

			if (loginUser != null) {
				loginUserId = loginUser.getUserId();
			}


			// =========================
			// 여행일정 검색
			// 최대 4개 조회
			// =========================
			List<ItineraryDto> scheduleList = itineraryService.getSearchScheduleList(
				loginUserId,
				keyword,
				4
			);

			long scheduleTotalCount = itineraryService.countScheduleList(
				keyword,
				"",
				null,
				null,
				null
			);


			// =========================
			// 여행꿀팁 검색
			// 최대 4개 조회
			// =========================
			List<TipDto> tipList = tipService.selectTipListByFilter(
				null,
				keyword,
				"latest",
				1,
				4
			);

			int tipTotalCount = tipService.countTipListByFilter(
				null,
				keyword
			);


			// =========================
			// 여행 메이트 검색
			// 최대 4개 조회
			// =========================
			List<String> countryKeywords = new ArrayList<>();

			List<MateDto> mateList = mateService.selectMateListByFilter(
				countryKeywords,
				keyword,
				"latest",
				4,
				0
			);

			int mateTotalCount = mateService.countMateListByFilter(
				countryKeywords,
				keyword
			);


			// =========================
			// 전체 검색 결과 개수
			// =========================
			long totalCount = scheduleTotalCount
				+ tipTotalCount
				+ mateTotalCount;


			// =========================
			// JSP 전달
			// =========================
			request.setAttribute("keyword", keyword);

			request.setAttribute("scheduleList", scheduleList);
			request.setAttribute("scheduleTotalCount", scheduleTotalCount);

			request.setAttribute("tipList", tipList);
			request.setAttribute("tipTotalCount", tipTotalCount);

			request.setAttribute("mateList", mateList);
			request.setAttribute("mateTotalCount", mateTotalCount);

			request.setAttribute("totalCount", totalCount);


			// =========================
			// 통합검색 결과 화면
			// =========================
			request.getRequestDispatcher("/view/search/searchResult.jsp").forward(request, response);

		} catch (Exception e) {
			e.printStackTrace();
			throw new ServletException(e);
		}
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		doGet(request, response);
	}
}