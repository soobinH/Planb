package controller.profile;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import dto.member.UserDto;
import dto.profile.ProfileActivityDto;
import dto.profile.ProfileFeedDto;
import service.profile.ProfileActivityService;
import service.profile.ProfileActivityServiceImpl;
import service.profile.ProfileFeedService;
import service.profile.ProfileFeedServiceImpl;

@WebServlet("/profile/myProfile")
public class myProfile extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final int PAGE_SIZE = 9;

    private final ProfileActivityService activityService =
            new ProfileActivityServiceImpl();

    private final ProfileFeedService profileFeedService =
            new ProfileFeedServiceImpl();


    public myProfile() {

        super();
    }


    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {


        HttpSession session =
                request.getSession(false);


        if (session == null) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/view/auth/login.jsp"
            );

            return;
        }


        UserDto user =
                (UserDto)
                session.getAttribute(
                        "user"
                );


        if (user == null) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/view/auth/login.jsp"
            );

            return;
        }


        long userId =
                user.getUserId();


        try {

            /*
             * 처음 화면에서는 10개를 조회한다.
             *
             * 1~9개  : 화면에 그대로 표시 / 다음 페이지 없음
             * 10개   : 화면에는 9개만 표시 / 다음 페이지 있음
             */
            List<ProfileFeedDto> myPage =
                    profileFeedService
                        .getMyItinerariesPage(
                                userId,
                                0,
                                PAGE_SIZE + 1
                        );


            List<ProfileFeedDto> bookmarkedPage =
                    profileFeedService
                        .getBookmarkedItinerariesPage(
                                userId,
                                0,
                                PAGE_SIZE + 1
                        );


            List<ProfileFeedDto> likedPage =
                    profileFeedService
                        .getLikedItinerariesPage(
                                userId,
                                0,
                                PAGE_SIZE + 1
                        );


            boolean myPostsHasMore =
                    hasMore(
                            myPage
                    );


            boolean mySavedHasMore =
                    hasMore(
                            bookmarkedPage
                    );


            boolean myLikedHasMore =
                    hasMore(
                            likedPage
                    );


            List<ProfileFeedDto> myItineraries =
                    firstPage(
                            myPage
                    );


            List<ProfileFeedDto> bookmarkedItineraries =
                    firstPage(
                            bookmarkedPage
                    );


            List<ProfileFeedDto> likedItineraries =
                    firstPage(
                            likedPage
                    );


            List<ProfileActivityDto> activities =
                    activityService
                        .getProfileActivities(
                                userId
                        );


            if (activities == null) {

                activities =
                        new ArrayList<ProfileActivityDto>();
            }


            /*
             * 상단 통계는 현재 9개 목록 크기로 계산하면 안 된다.
             * 별도 COUNT 쿼리로 전체 건수를 계산한다.
             */
            int postCount =
                    profileFeedService
                        .countMyItineraries(
                                userId
                        );


            int likeCount =
                    profileFeedService
                        .getReceivedLikeCount(
                                userId
                        );


            int bookmarkCount =
                    profileFeedService
                        .getReceivedBookmarkCount(
                                userId
                        );


            request.setAttribute(
                    "postCount",
                    postCount
            );


            request.setAttribute(
                    "likeCount",
                    likeCount
            );


            request.setAttribute(
                    "bookmarkCount",
                    bookmarkCount
            );


            request.setAttribute(
                    "myItineraries",
                    myItineraries
            );


            request.setAttribute(
                    "bookmarkedItineraries",
                    bookmarkedItineraries
            );


            request.setAttribute(
                    "likedItineraries",
                    likedItineraries
            );


            request.setAttribute(
                    "activities",
                    activities
            );


            request.setAttribute(
                    "myPostsHasMore",
                    myPostsHasMore
            );


            request.setAttribute(
                    "mySavedHasMore",
                    mySavedHasMore
            );


            request.setAttribute(
                    "myLikedHasMore",
                    myLikedHasMore
            );


            request.getRequestDispatcher(
                    "/view/profile/myProfile.jsp"
            ).forward(
                    request,
                    response
            );


        } catch (Exception e) {

            e.printStackTrace();

            throw new ServletException(
                    "내 프로필 조회 중 오류가 발생했습니다.",
                    e
            );
        }
    }


    private boolean hasMore(
            List<ProfileFeedDto> items
    ) {

        return items != null
                &&
                items.size() > PAGE_SIZE;
    }


    private List<ProfileFeedDto> firstPage(
            List<ProfileFeedDto> items
    ) {

        if (
            items == null
            ||
            items.isEmpty()
        ) {

            return new ArrayList<ProfileFeedDto>();
        }


        int end =
                Math.min(
                        PAGE_SIZE,
                        items.size()
                );


        return new ArrayList<ProfileFeedDto>(
                items.subList(
                        0,
                        end
                )
        );
    }
}
