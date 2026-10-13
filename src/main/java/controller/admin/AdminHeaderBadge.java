package controller.admin;

import java.io.IOException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.ibatis.session.SqlSession;

import config.MybatisSqlSessionFactory;
import dto.member.UserDto;

/**
 * 관리자 헤더 - 신고 / 광고 / 신규 문의 알림 건수.
 *
 * 기존 신고·광고 Mapper ID는 그대로 사용한다.
 * 문의는 기존 supportInquiry.xml / DAO / Service를 수정할 필요가 없도록
 * SqlSession의 JDBC connection을 통해 TB_SUPPORT_INQUIRY를 직접 조회한다.
 *
 * 각 조회는 독립 실행되므로 하나가 실패해도 다른 결과를 받을 수 있다.
 */
@WebServlet("/admin/header-badges")
public class AdminHeaderBadge extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final String REPORT_STATEMENT =
            "mapper.itinerary.report.countPendingReports";

    private static final String AD_STATEMENT =
            "mapper.advertisement.admin.countPendingAds";

    private static final String INQUIRY_COUNT_SQL =
            "SELECT COUNT(*) FROM TB_SUPPORT_INQUIRY WHERE status = 'RECEIVED'";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Object sessionUser = session == null ? null : session.getAttribute("user");

        if (!(sessionUser instanceof UserDto)) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        UserDto user = (UserDto) sessionUser;
        if (!"ADMIN".equalsIgnoreCase(user.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");
        response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setHeader("X-Content-Type-Options", "nosniff");

        Long reports = countFromMapper(REPORT_STATEMENT, "신고");
        Long ads = countFromMapper(AD_STATEMENT, "광고");
        Long inquiries = countReceivedInquiries();

        // DB/Mapper 조회 실패 항목은 0으로 위장하지 않고 null로 전달한다.
        String json = "{"
                + "\"reportPendingCount\":" + toJsonNumber(reports) + ","
                + "\"adPendingCount\":" + toJsonNumber(ads) + ","
                + "\"receivedInquiryCount\":" + toJsonNumber(inquiries)
                + "}";

        response.getWriter().write(json);
    }

    private Long countFromMapper(String statementId, String label) {
        try (SqlSession sqlSession = MybatisSqlSessionFactory
                .getSqlSessionFactory().openSession()) {
            Number count = sqlSession.selectOne(statementId);
            return count == null ? 0L : count.longValue();
        } catch (Exception e) {
            getServletContext().log("관리자 헤더 " + label + " 건수 조회 실패: " + statementId, e);
            return null;
        }
    }

    private Long countReceivedInquiries() {
        try (SqlSession sqlSession = MybatisSqlSessionFactory
                .getSqlSessionFactory().openSession();
             PreparedStatement statement = sqlSession.getConnection()
                     .prepareStatement(INQUIRY_COUNT_SQL);
             ResultSet rs = statement.executeQuery()) {

            return rs.next() ? rs.getLong(1) : 0L;
        } catch (Exception e) {
            getServletContext().log("관리자 헤더 신규 문의 건수 조회 실패", e);
            return null;
        }
    }

    private String toJsonNumber(Long count) {
        return count == null ? "null" : Long.toString(count);
    }
}
