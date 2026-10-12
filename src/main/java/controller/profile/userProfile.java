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

	private static final int PAGE_SIZE = 9;

	private final UserService userService = new UserServiceImpl();

	private final ProfileFeedService profileFeedService = new ProfileFeedServiceImpl();

	public userProfile() {

		super();
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		try {

			String userIdParam = request.getParameter("userId");

			if (userIdParam == null || userIdParam.trim().isEmpty()) {

				response.sendError(HttpServletResponse.SC_BAD_REQUEST, "회원 번호가 없습니다.");

				return;
			}

			long targetUserId = Long.parseLong(userIdParam);

			UserDto targetUser = userService.getUserById(targetUserId);

			if (targetUser == null) {

				response.sendError(HttpServletResponse.SC_NOT_FOUND, "존재하지 않는 회원입니다.");

				return;
			}

			boolean privateProfile = "PRIVATE".equalsIgnoreCase(targetUser.getProfileVisibility());

			request.setAttribute("targetUser", targetUser);

			request.setAttribute("privateProfile", privateProfile);

			/*
			 * 비공개 프로필은 피드 데이터를 조회하지 않는다.
			 */
			if (privateProfile) {

				request.setAttribute("itineraries", new ArrayList<ProfileFeedDto>());

				request.setAttribute("likedItineraries", new ArrayList<ProfileFeedDto>());

				request.setAttribute("bookmarkedItineraries", new ArrayList<ProfileFeedDto>());

				request.setAttribute("showLikedItinerary", false);

				request.setAttribute("showBookmarkedItinerary", false);

				request.setAttribute("postCount", 0);

				request.setAttribute("likeCount", 0);

				request.setAttribute("bookmarkCount", 0);

				request.setAttribute("userPostsHasMore", false);

				request.setAttribute("userSavedHasMore", false);

				request.setAttribute("userLikedHasMore", false);

				request.getRequestDispatcher("/view/profile/userProfile.jsp").forward(request, response);

				return;
			}

			/*
			 * PUBLIC 프로필의 작성 일정. 다음 페이지 존재 여부를 확인하기 위해 10개 조회.
			 */
			List<ProfileFeedDto> itineraryPage = profileFeedService.getPublicItinerariesPage(targetUserId, 0,
					PAGE_SIZE + 1);

			boolean userPostsHasMore = hasMore(itineraryPage);

			List<ProfileFeedDto> itineraries = firstPage(itineraryPage);

			boolean showLikedItinerary = Boolean.TRUE.equals(targetUser.getShowLikedItinerary());

			boolean showBookmarkedItinerary = Boolean.TRUE.equals(targetUser.getShowBookmarkedItinerary());

			List<ProfileFeedDto> likedItineraries = new ArrayList<ProfileFeedDto>();

			List<ProfileFeedDto> bookmarkedItineraries = new ArrayList<ProfileFeedDto>();

			boolean userLikedHasMore = false;

			boolean userSavedHasMore = false;

			if (showLikedItinerary) {

				List<ProfileFeedDto> likedPage = profileFeedService.getPublicLikedItinerariesPage(targetUserId, 0,
						PAGE_SIZE + 1);

				userLikedHasMore = hasMore(likedPage);

				likedItineraries = firstPage(likedPage);
			}

			if (showBookmarkedItinerary) {

				List<ProfileFeedDto> savedPage = profileFeedService.getPublicBookmarkedItinerariesPage(targetUserId, 0,
						PAGE_SIZE + 1);

				userSavedHasMore = hasMore(savedPage);

				bookmarkedItineraries = firstPage(savedPage);
			}

			/*
			 * 상단 통계는 현재 화면에 로딩된 9개가 아니라 전체 공개 일정 기준으로 계산한다.
			 *
			 * 본인이 본인 글에 누른 좋아요/북마크는 제외한다.
			 */
			int postCount = profileFeedService.countPublicItineraries(targetUserId);

			int likeCount = profileFeedService.getPublicReceivedLikeCount(targetUserId);

			int bookmarkCount = profileFeedService.getPublicReceivedBookmarkCount(targetUserId);

			request.setAttribute("itineraries", itineraries);

			request.setAttribute("likedItineraries", likedItineraries);

			request.setAttribute("bookmarkedItineraries", bookmarkedItineraries);

			request.setAttribute("showLikedItinerary", showLikedItinerary);

			request.setAttribute("showBookmarkedItinerary", showBookmarkedItinerary);

			request.setAttribute("postCount", postCount);

			request.setAttribute("likeCount", likeCount);

			request.setAttribute("bookmarkCount", bookmarkCount);

			request.setAttribute("userPostsHasMore", userPostsHasMore);

			request.setAttribute("userSavedHasMore", userSavedHasMore);

			request.setAttribute("userLikedHasMore", userLikedHasMore);

			request.getRequestDispatcher("/view/profile/userProfile.jsp").forward(request, response);

		} catch (NumberFormatException e) {

			response.sendError(HttpServletResponse.SC_BAD_REQUEST, "잘못된 회원 번호입니다.");

		} catch (Exception e) {

			e.printStackTrace();

			throw new ServletException("사용자 프로필 조회 중 오류가 발생했습니다.", e);
		}
	}

	private boolean hasMore(List<ProfileFeedDto> items) {

		return items != null && items.size() > PAGE_SIZE;
	}

	private List<ProfileFeedDto> firstPage(List<ProfileFeedDto> items) {

		if (items == null || items.isEmpty()) {

			return new ArrayList<ProfileFeedDto>();
		}

		int end = Math.min(PAGE_SIZE, items.size());

		return new ArrayList<ProfileFeedDto>(items.subList(0, end));
	}
}
