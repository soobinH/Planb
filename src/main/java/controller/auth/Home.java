package controller.auth;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import dto.community.MateDto;
import dto.community.TipDto;
import service.community.MateService;
import service.community.MateServiceImpl;
import service.community.TipService;
import service.community.TipServiceImpl;

import dto.itinerary.ItineraryDto;
import service.itinerary.ItineraryService;
import service.itinerary.ItineraryServiceImpl;

@WebServlet("/home")
public class Home extends HttpServlet {

	private static final long serialVersionUID = 1L;

	private TipService tipService;
	private MateService mateService;
	private ItineraryService itineraryService;

	public Home() {
		super();
		tipService = new TipServiceImpl();
		mateService = new MateServiceImpl();
		itineraryService = new ItineraryServiceImpl();
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		try {
			List<ItineraryDto> itineraryList = itineraryService.getScheduleList(null, "", "", null, null, null, "likes",0);
			
			// 여행꿀팁 최신 게시글 3개
			List<TipDto> tipList = tipService.selectTipListByFilter(null, "", "latest", 1, 9);

			// 여행메이트 최신 게시글 3개
			List<String> countryKeywords = new ArrayList<>();
			List<MateDto> mateList = mateService.selectMateListByFilter(countryKeywords, "", "latest", 9, 0);

			request.setAttribute("itineraryList", itineraryList);
			request.setAttribute("tipList", tipList);
			request.setAttribute("mateList", mateList);
			
			System.out.println("HOME itineraryList = " + itineraryList);

			request.getRequestDispatcher("/view/home/home.jsp").forward(request, response);

		} catch (Exception e) {
			e.printStackTrace();
			throw new ServletException(e);
		}
	}
}