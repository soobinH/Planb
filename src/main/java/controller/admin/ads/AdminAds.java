package controller.admin.ads;

import java.io.IOException;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import dto.member.UserDto;
import service.advertisement.AdvertisementService;
import service.advertisement.AdvertisementServiceImpl;

/**
 * Servlet implementation class AdminAds
 */
@WebServlet("/admin/ads")
public class AdminAds extends HttpServlet {
	private static final long serialVersionUID = 1L;
	
	private final AdvertisementService service = new AdvertisementServiceImpl();
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public AdminAds() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		UserDto admin = requireAdmin(request, response);
		if(admin == null) return;
		try {
			List<Map<String, Object>> ads = service.getAllAds();
			request.setAttribute("ads", ads);
			request.getRequestDispatcher("/view/admin/ads/adminAds.jsp").forward(request, response);
		} catch(Exception e) {
			e.printStackTrace();
			throw new ServletException("광고 목록을 불러오는 중 오류가 발생했습니다.", e);
		}
	
	}
	
	private UserDto requireAdmin(HttpServletRequest request, HttpServletResponse response) throws IOException {
		HttpSession session = request.getSession(false);
		if(session == null) {
			response.sendRedirect(request.getContextPath()+"/auth/login");
			return null;
		}
		
		UserDto user = (UserDto)session.getAttribute("user");
		if(user == null) {
			response.sendRedirect(request.getContextPath()+"/auth/login");
			return null;
		}
		
		if(user.getRole() == null || !"ADMIN".equalsIgnoreCase(user.getRole())){
			response.sendError(HttpServletResponse.SC_FORBIDDEN);
			return null;
		}
		
		return user;
	}

}
