package controller.profile;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import dto.member.UserDto;
import dto.profile.ProfileFeedDto;

import service.member.UserService;
import service.member.UserServiceImpl;

import service.profile.ProfileFeedService;
import service.profile.ProfileFeedServiceImpl;

@WebServlet("/profile/userProfile")
public class userProfile extends HttpServlet {

	private static final long serialVersionUID = 1L;

	/*
	 * ========================================================= Service
	 * =========================================================
	 */

	private UserService userService = new UserServiceImpl();

	private ProfileFeedService profileFeedService = new ProfileFeedServiceImpl();

	/*
	 * ========================================================= 생성자
	 * =========================================================
	 */

	public userProfile() {

		super();
	}

	/*
	 * ========================================================= GET
	 *
	 * 예: /profile/userProfile?userId=3
	 * =========================================================
	 */

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		try {

			/*
			 * ================================================= 1. 조회할 회원 번호
			 * =================================================
			 */

			String userIdParam = request.getParameter("userId");

			if (userIdParam == null || userIdParam.trim().isEmpty()) {

				response.sendError(HttpServletResponse.SC_BAD_REQUEST, "회원 번호가 없습니다.");

				return;
			}

			/*
			 * ================================================= 2. String -> long
			 * =================================================
			 */

			long targetUserId = Long.parseLong(userIdParam);

			/*
			 * ================================================= 3. 상대방 회원정보 조회
			 * =================================================
			 */

			UserDto targetUser = userService.getUserById(targetUserId);

			if (targetUser == null) {

				response.sendError(HttpServletResponse.SC_NOT_FOUND, "존재하지 않는 회원입니다.");

				return;
			}

			/*
			 * ================================================= 4. 프로필 비공개 여부
			 * =================================================
			 *
			 * profile_visibility
			 *
			 * PUBLIC PRIVATE
			 */

			boolean privateProfile = "PRIVATE".equalsIgnoreCase(targetUser.getProfileVisibility());

			/*
			 * ================================================= 5. 상대방 회원정보는 항상 JSP에 전달
			 * =================================================
			 *
			 * 비공개 계정이어도
			 *
			 * 프로필 이미지 닉네임 로그인 아이디 신고 버튼
			 *
			 * 정도는 표시하기 위해 필요
			 */

			request.setAttribute("targetUser", targetUser);

			request.setAttribute("privateProfile", privateProfile);

			/*
			 * ================================================= 6. 비공개 프로필
			 * =================================================
			 *
			 * 중요한 부분:
			 *
			 * 비공개라면 일정/좋아요/북마크를 DB에서 아예 조회하지 않는다.
			 */

			if (privateProfile) {

				request.setAttribute("itineraries", new ArrayList<ProfileFeedDto>());

				request.setAttribute("likedItineraries", new ArrayList<ProfileFeedDto>());

				request.setAttribute("bookmarkedItineraries", new ArrayList<ProfileFeedDto>());

				/*
				 * 프로필 자체가 비공개이면 좋아요/북마크 개별 공개설정보다 비공개 설정이 우선한다.
				 */

				request.setAttribute("showLikedItinerary", false);

				request.setAttribute("showBookmarkedItinerary", false);

				/*
				 * 통계도 노출하지 않는다.
				 */

				request.setAttribute("postCount", 0);

				request.setAttribute("likeCount", 0);

				request.setAttribute("bookmarkCount", 0);

				/*
				 * JSP 이동 후 종료
				 */

				request.getRequestDispatcher("/view/profile/userProfile.jsp").forward(request, response);

				return;
			}

			/*
			 * ================================================= 여기부터는 PUBLIC 프로필만 실행
			 * =================================================
			 */

			/*
			 * ================================================= 7. 상대방이 작성한 PUBLIC 일정
			 * =================================================
			 */

			List<ProfileFeedDto> itineraries = profileFeedService.getPublicItineraries(targetUserId);

			if (itineraries == null) {

				itineraries = new ArrayList<ProfileFeedDto>();
			}

			/*
			 * ================================================= 8. 좋아요 / 북마크 공개 설정
			 * =================================================
			 *
			 * Boolean이 null일 수도 있으므로 Boolean.TRUE.equals() 사용
			 */

			boolean showLikedItinerary = Boolean.TRUE.equals(targetUser.getShowLikedItinerary());

			boolean showBookmarkedItinerary = Boolean.TRUE.equals(targetUser.getShowBookmarkedItinerary());

			/*
			 * ================================================= 9. 좋아요한 PUBLIC 일정
			 * =================================================
			 */

			List<ProfileFeedDto> likedItineraries = new ArrayList<ProfileFeedDto>();

			if (showLikedItinerary) {

				likedItineraries = profileFeedService.getPublicLikedItineraries(targetUserId);

				if (likedItineraries == null) {

					likedItineraries = new ArrayList<ProfileFeedDto>();
				}
			}

			/*
			 * ================================================= 10. 북마크한 PUBLIC 일정
			 * =================================================
			 */

			List<ProfileFeedDto> bookmarkedItineraries = new ArrayList<ProfileFeedDto>();

			if (showBookmarkedItinerary) {

				bookmarkedItineraries = profileFeedService.getPublicBookmarkedItineraries(targetUserId);

				if (bookmarkedItineraries == null) {

					bookmarkedItineraries = new ArrayList<ProfileFeedDto>();
				}
			}

			/*
			 * ================================================= 11. 게시물 수
			 * =================================================
			 */

			int postCount = itineraries.size();

			/*
			 * ================================================= 12. 받은 좋아요 총합
			 *
			 * 본인이 본인 일정에 누른 좋아요는 제외 =================================================
			 */

			int likeCount = profileFeedService.getReceivedLikeCount(targetUserId);

			/*
			 * ================================================= 13. 받은 북마크 총합
			 *
			 * 본인이 본인 일정에 누른 북마크는 제외 =================================================
			 */

			int bookmarkCount = profileFeedService.getReceivedBookmarkCount(targetUserId);

			/*
			 * ================================================= 14. JSP에 데이터 전달
			 * =================================================
			 */

			request.setAttribute("itineraries", itineraries);

			request.setAttribute("likedItineraries", likedItineraries);

			request.setAttribute("bookmarkedItineraries", bookmarkedItineraries);

			request.setAttribute("showLikedItinerary", showLikedItinerary);

			request.setAttribute("showBookmarkedItinerary", showBookmarkedItinerary);

			request.setAttribute("postCount", postCount);

			request.setAttribute("likeCount", likeCount);

			request.setAttribute("bookmarkCount", bookmarkCount);

			/*
			 * ================================================= 15. JSP 이동
			 * =================================================
			 */

			request.getRequestDispatcher("/view/profile/userProfile.jsp").forward(request, response);

			/*
			 * ===================================================== userId=abc
			 * =====================================================
			 */

		} catch (NumberFormatException e) {

			response.sendError(HttpServletResponse.SC_BAD_REQUEST, "잘못된 회원 번호입니다.");

			/*
			 * ===================================================== DB / Service 오류
			 * =====================================================
			 */

		} catch (Exception e) {

			e.printStackTrace();

			throw new ServletException("사용자 프로필 조회 중 오류가 발생했습니다.", e);
		}
	}
}