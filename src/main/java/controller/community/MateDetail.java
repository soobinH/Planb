package controller.community;

import java.io.IOException;
import java.util.List;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import dto.community.MateCommentDto;
import dto.community.MateDto;
import dto.community.MateMediaDto;
import dto.member.UserDto;
import service.community.MateCommentService;
import service.community.MateCommentServiceImpl;
import service.community.MateLikeService;
import service.community.MateLikeServiceImpl;
import service.community.MateMediaService;
import service.community.MateMediaServiceImpl;
import service.community.MateService;
import service.community.MateServiceImpl;

import service.report.ReportService;
import service.report.ReportServiceImpl;

@WebServlet("/mateDetail")
public class MateDetail extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private MateService mateService = new MateServiceImpl();
	private MateMediaService mateMediaService = new MateMediaServiceImpl();
	private MateLikeService mateLikeService = new MateLikeServiceImpl();
	private MateCommentService mateCommentService = new MateCommentServiceImpl();
	private ReportService reportService = new ReportServiceImpl();

	public MateDetail() {
		super();
	}

	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String mateIdParam = request.getParameter("mateId");

		if (mateIdParam == null || mateIdParam.trim().isEmpty()) {
			response.sendRedirect(request.getContextPath() + "/mates");
			return;
		}

		try {
			Long mateId = Long.parseLong(mateIdParam);

			// 조회수 증가
			mateService.updateMateViewCount(mateId);

			// 상세 게시글 조회
			MateDto mate = mateService.selectMate(mateId);
			
			
			List<MateMediaDto> mateMediaList = mateMediaService.selectMateMediaList(mateId);
			
			int mateLikeCount = mateLikeService.countMateLike(mateId);
			
			List<MateCommentDto> mateCommentList = mateCommentService.selectMateCommentList(mateId);
			int mateCommentCount = mateCommentService.countMateComment(mateId);

			boolean liked = false;

			HttpSession session = request.getSession(false);

			if (session != null && session.getAttribute("user") != null) {
				UserDto user = (UserDto) session.getAttribute("user");
				liked = mateLikeService.isLiked(mateId, user.getUserId());
			}

			if (mate == null) {
				response.sendRedirect(request.getContextPath() + "/mates");
				return;
			}

			request.setAttribute("mate", mate);
			request.setAttribute("mateMediaList", mateMediaList);
			request.setAttribute("mateLikeCount", mateLikeCount);
			request.setAttribute("liked", liked);
			request.setAttribute("mateCommentList", mateCommentList);
			request.setAttribute("mateCommentCount", mateCommentCount);
			
			// 신고 팝업에 표시할 활성 신고 사유 조회
			ReportService reportService = new ReportServiceImpl();

			request.setAttribute("reportReasons", reportService.getContentReportReasons());

			RequestDispatcher dispatcher = request.getRequestDispatcher("/view/mates/mateDetail.jsp");
			dispatcher.forward(request, response);

		} catch (NumberFormatException e) {
			response.sendRedirect(request.getContextPath() + "/mates");
		} catch (Exception e) {
			e.printStackTrace();
			response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
		}
	}
}