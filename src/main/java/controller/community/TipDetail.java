package controller.community;

import java.io.IOException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import dto.community.TipCommentDto;
import dto.community.TipDto;
import dto.community.TipLikeDto;
import dto.community.TipMediaDto;
import dto.member.UserDto;
import service.community.TipCommentService;
import service.community.TipCommentServiceImpl;
import service.community.TipLikeService;
import service.community.TipLikeServiceImpl;
import service.community.TipMediaService;
import service.community.TipMediaServiceImpl;
import service.community.TipService;
import service.community.TipServiceImpl;
import service.report.ReportService;
import service.report.ReportServiceImpl;

@WebServlet("/tipDetail")
public class TipDetail extends HttpServlet {

    private static final long serialVersionUID = 1L;

    public TipDetail() {
        super();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 1. 목록에서 넘어온 tipId 받기
        String tipIdParam = request.getParameter("tipId");
        if (tipIdParam == null || tipIdParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/tips");
            return;
        }

        try {
            long tipId = Long.parseLong(tipIdParam);
            TipService tipService = new TipServiceImpl();
            
            // 조회수 증가
            tipService.updateTipViewCount(tipId);

	        // 게시글 조회
	        TipDto tip = tipService.selectTipDetail(tipId);

	        if (tip == null) {
	            response.sendRedirect(request.getContextPath() + "/tips");
	            return;
	        }
         	// 게시글 이미지 목록 조회
         	TipMediaService tipMediaService = new TipMediaServiceImpl();
         	List<TipMediaDto> tipMediaList = tipMediaService.selectTipMediaList(tipId);
         	
         	// 댓글 목록 조회
         	TipCommentService tipCommentService =  new TipCommentServiceImpl();

         	List<TipCommentDto> tipCommentList = tipCommentService.selectTipCommentList(tipId);
         	
         	// 좋아요 Service
         	TipLikeService tipLikeService = new TipLikeServiceImpl();

         	// 좋아요 개수
         	int likeCount = tipLikeService.selectTipLikeCount(tipId);

         	tip.setLikeCount(likeCount);

         	// 현재 로그인 사용자의 좋아요 여부
         	boolean liked = false;

         	HttpSession session = request.getSession(false);

         	if (session != null && session.getAttribute("user") != null) {

         	    UserDto user = (UserDto) session.getAttribute("user");

         	    TipLikeDto tipLikeDto = new TipLikeDto();

         	    tipLikeDto.setTipId(tipId);
         	    tipLikeDto.setUserId(user.getUserId());

         	    TipLikeDto existingLike = tipLikeService.selectTipLike(tipLikeDto);

         	    liked = existingLike != null;
         	}

         	// JSP 전달
         	request.setAttribute("tip", tip);
         	request.setAttribute("tipMediaList", tipMediaList);
         	request.setAttribute("liked", liked);
         	request.setAttribute("tipCommentList", tipCommentList);
         	
         	// 신고 팝업에 표시할 활성 신고 사유 조회
         	ReportService reportService = new ReportServiceImpl();

         	request.setAttribute("reportReasons", reportService.getContentReportReasons());
         	
            // 5. 상세 JSP 이동
            request.getRequestDispatcher("/view/tips/tipDetail.jsp").forward(request, response);
        } catch (NumberFormatException e) {
        	response.sendRedirect(request.getContextPath() + "/tips");
        } catch (Exception e) {
        	e.printStackTrace();
        	response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        } 
    }
}