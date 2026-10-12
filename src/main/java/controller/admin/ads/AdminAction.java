package controller.admin.ads;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.Date;

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
 * Servlet implementation class AdminAction
 */
@WebServlet("/admin/ads/action")
public class AdminAction extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private final AdvertisementService service = new AdvertisementServiceImpl();
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public AdminAction() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		response.getWriter().append("Served at: ").append(request.getContextPath());
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		UserDto admin =
                requireAdmin(
                        request,
                        response
                );


        if (admin == null) {
            return;
        }


        String returnTab =
                normalizeTab(
                        request.getParameter(
                                "tab"
                        )
                );


        try {

            /*
             * 광고 번호
             */
            long adId =
                    parseAdId(
                            request.getParameter(
                                    "adId"
                            )
                    );


            /*
             * 처리 종류
             */
            String action =
                    request.getParameter(
                            "action"
                    );


            if (action == null) {

                throw new IllegalArgumentException(
                        "처리할 작업이 없습니다."
                );
            }


            switch (action) {


                /*
                 * 승인
                 */
                case "APPROVE":

                    service.approve(
                            adId,
                            admin.getUserId()
                    );

                    returnTab =
                            "PENDING_PUBLICATION";

                    break;


                /*
                 * 거절
                 */
                case "REJECT":

                    service.reject(
                            adId,
                            admin.getUserId(),
                            request.getParameter(
                                    "reason"
                            )
                    );

                    returnTab =
                            "CLOSED";

                    break;


                /*
                 * 게시 시작
                 */
                case "ACTIVATE":

                    service.activate(
                            adId,
                            admin.getUserId()
                    );

                    returnTab =
                            "ACTIVE";

                    break;


                /*
                 * 게시 철회
                 */
                case "WITHDRAW":

                    service.withdraw(
                            adId,
                            admin.getUserId(),
                            request.getParameter(
                                    "reason"
                            )
                    );

                    returnTab =
                            "CLOSED";

                    break;


                /*
                 * 기간 연장
                 */
                case "EXTEND":


                    String newEndDateValue =
                            request.getParameter(
                                    "newEndDate"
                            );


                    if (
                        newEndDateValue == null
                        ||
                        newEndDateValue
                            .trim()
                            .isEmpty()
                    ) {

                        throw new IllegalArgumentException(
                                "새 종료일을 입력해주세요."
                        );
                    }


                    Date newEndDate;


                    try {

                        newEndDate =
                                Date.valueOf(
                                        newEndDateValue
                                );

                    } catch (Exception e) {

                        throw new IllegalArgumentException(
                                "종료일 형식이 올바르지 않습니다."
                        );
                    }


                    service.extend(
                            adId,
                            admin.getUserId(),
                            newEndDate
                    );


                    returnTab =
                            "ACTIVE";

                    break;


                /*
                 * 광고 삭제
                 */
                case "DELETE":

                    service.delete(
                            adId,
                            admin.getUserId()
                    );


                    returnTab =
                            "CLOSED";

                    break;


                default:

                    throw new IllegalArgumentException(
                            "지원하지 않는 광고 처리입니다."
                    );
            }


            /*
             * 정상 처리
             */
            response.sendRedirect(
                    request.getContextPath()
                    + "/admin/ads"
                    + "?tab="
                    + encode(returnTab)
                    + "&result=success"
                    + "&action="
                    + encode(action)
            );


        } catch (Exception e) {

            e.printStackTrace();


            String message =
                    e.getMessage() == null
                    ? "광고 처리 중 오류가 발생했습니다."
                    : e.getMessage();


            /*
             * 오류 발생
             */
            response.sendRedirect(
                    request.getContextPath()
                    + "/admin/ads"
                    + "?tab="
                    + encode(returnTab)
                    + "&result=error"
                    + "&message="
                    + encode(message)
            );
        }
    }


    /*
     * =========================================================
     * 관리자 검사
     * =========================================================
     */

    private UserDto requireAdmin(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws IOException {


        HttpSession session =
                request.getSession(false);


        if (session == null) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/auth/login"
            );

            return null;
        }


        UserDto user =
                (UserDto)
                session.getAttribute(
                        "user"
                );


        if (user == null) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/auth/login"
            );

            return null;
        }


        if (
            user.getRole() == null
            ||
            !"ADMIN".equalsIgnoreCase(
                    user.getRole()
            )
        ) {

            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN
            );

            return null;
        }


        return user;
    }


    /*
     * 광고 ID 변환
     */
    private long parseAdId(
            String value
    ) {

        try {

            long adId =
                    Long.parseLong(
                            value
                    );


            if (adId <= 0) {

                throw new NumberFormatException();
            }


            return adId;

        } catch (Exception e) {

            throw new IllegalArgumentException(
                    "올바른 광고 번호가 아닙니다."
            );
        }
    }


    /*
     * 탭 검증
     */
    private String normalizeTab(
            String value
    ) {

        if (
            "PENDING_APPROVAL".equals(value)
            ||
            "PENDING_PUBLICATION".equals(value)
            ||
            "ACTIVE".equals(value)
            ||
            "CLOSED".equals(value)
            ||
            "ALL".equals(value)
        ) {

            return value;
        }


        return "PENDING_APPROVAL";
    }


    private String encode(
            String value
    ) {

        return URLEncoder.encode(
                value == null
                ? ""
                : value,
                StandardCharsets.UTF_8
        );
    }
}

