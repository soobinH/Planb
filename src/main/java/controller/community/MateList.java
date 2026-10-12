package controller.community;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import dto.community.MateDto;
import service.community.MateService;
import service.community.MateServiceImpl;

@WebServlet("/mates")
public class MateList extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private MateService mateService = new MateServiceImpl();

	public MateList() {
		super();
	}

	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String country = request.getParameter("country");
		String keyword = request.getParameter("keyword");
		String sort = request.getParameter("sort");

		if (country == null) country = "";
		if (keyword == null) keyword = "";
		if (sort == null || sort.trim().isEmpty()) sort = "latest";

		List<String> countryKeywords = new ArrayList<>();
		if (!country.trim().isEmpty()) countryKeywords = Arrays.asList(country);

		int page = 1;
		int pageSize = 12;

		try {
			String pageParam = request.getParameter("page");
			if (pageParam != null && !pageParam.trim().isEmpty()) page = Integer.parseInt(pageParam);
		} catch (NumberFormatException e) {
			page = 1;
		}

		if (page < 1) page = 1;

		int offset = (page - 1) * pageSize;

		List<MateDto> mateList = mateService.selectMateListByFilter(countryKeywords, keyword, sort, pageSize, offset);
		int totalCount = mateService.countMateListByFilter(countryKeywords, keyword);

		request.setAttribute("mateList", mateList);
		request.setAttribute("totalCount", totalCount);
		request.setAttribute("country", country);
		request.setAttribute("keyword", keyword);
		request.setAttribute("sort", sort);
		request.setAttribute("page", page);
		request.setAttribute("pageSize", pageSize);

		RequestDispatcher dispatcher = request.getRequestDispatcher("/view/mates/mateList.jsp");
		dispatcher.forward(request, response);
	}
}