package controller.admin;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import dto.member.UserDto;

/** 세션의 관리자 역할 확인 (실제 UserDto.getRole() 사용). */
final class InquiryAdminAccess {
    private InquiryAdminAccess() {}

    static UserDto requireAdmin(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return null;
        Object principal = session.getAttribute("user");
        if (!(principal instanceof UserDto)) return null;
        UserDto user = (UserDto) principal;
        return "ADMIN".equalsIgnoreCase(user.getRole()) ? user : null;
    }
}
