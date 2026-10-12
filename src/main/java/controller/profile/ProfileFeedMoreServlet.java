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
import dto.profile.ProfileFeedDto;
import service.member.UserService;
import service.member.UserServiceImpl;
import service.profile.ProfileFeedService;
import service.profile.ProfileFeedServiceImpl;

@WebServlet("/profile/feed/more")
public class ProfileFeedMoreServlet
        extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final int PAGE_SIZE = 9;

    private final ProfileFeedService profileFeedService =
            new ProfileFeedServiceImpl();

    private final UserService userService =
            new UserServiceImpl();


    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {


        request.setCharacterEncoding(
                "UTF-8"
        );

        response.setCharacterEncoding(
                "UTF-8"
        );

        response.setContentType(
                "text/html;charset=UTF-8"
        );

        response.setHeader(
                "Cache-Control",
                "no-store"
        );


        try {

            String scope =
                    normalize(
                            request.getParameter(
                                    "scope"
                            )
                    );


            String type =
                    normalize(
                            request.getParameter(
                                    "type"
                            )
                    );


            int offset =
                    parseOffset(
                            request.getParameter(
                                    "offset"
                            )
                    );


            List<ProfileFeedDto> page;


            /*
             * =================================================
             * 내 프로필
             * =================================================
             */
            if ("my".equals(scope)) {

                HttpSession session =
                        request.getSession(false);


                UserDto loginUser =
                        session == null
                        ? null
                        : (UserDto)
                            session.getAttribute(
                                    "user"
                            );


                if (loginUser == null) {

                    response.sendError(
                            HttpServletResponse
                                .SC_UNAUTHORIZED
                    );

                    return;
                }


                page =
                        loadMyFeed(
                                type,
                                loginUser.getUserId(),
                                offset,
                                PAGE_SIZE + 1
                        );


            /*
             * =================================================
             * 상대방 프로필
             * =================================================
             */
            } else if ("user".equals(scope)) {

                long targetUserId =
                        parseUserId(
                                request.getParameter(
                                        "userId"
                                )
                        );


                UserDto targetUser =
                        userService.getUserById(
                                targetUserId
                        );


                if (targetUser == null) {

                    response.sendError(
                            HttpServletResponse
                                .SC_NOT_FOUND
                    );

                    return;
                }


                /*
                 * 비공개 프로필은 URL 직접 호출로도
                 * 피드 데이터를 가져갈 수 없게 막는다.
                 */
                if (
                    "PRIVATE".equalsIgnoreCase(
                            targetUser
                                .getProfileVisibility()
                    )
                ) {

                    response.sendError(
                            HttpServletResponse
                                .SC_FORBIDDEN
                    );

                    return;
                }


                if (
                    "liked".equals(type)
                    &&
                    !Boolean.TRUE.equals(
                            targetUser
                                .getShowLikedItinerary()
                    )
                ) {

                    response.sendError(
                            HttpServletResponse
                                .SC_FORBIDDEN
                    );

                    return;
                }


                if (
                    "saved".equals(type)
                    &&
                    !Boolean.TRUE.equals(
                            targetUser
                                .getShowBookmarkedItinerary()
                    )
                ) {

                    response.sendError(
                            HttpServletResponse
                                .SC_FORBIDDEN
                    );

                    return;
                }


                page =
                        loadUserFeed(
                                type,
                                targetUserId,
                                offset,
                                PAGE_SIZE + 1
                        );


            } else {

                response.sendError(
                        HttpServletResponse
                            .SC_BAD_REQUEST
                );

                return;
            }


            if (page == null) {

                page =
                        new ArrayList<ProfileFeedDto>();
            }


            boolean hasMore =
                    page.size()
                    >
                    PAGE_SIZE;


            List<ProfileFeedDto> items;


            if (hasMore) {

                items =
                        new ArrayList<ProfileFeedDto>(
                                page.subList(
                                        0,
                                        PAGE_SIZE
                                )
                        );

            } else {

                items =
                        new ArrayList<ProfileFeedDto>(
                                page
                        );
            }


            /*
             * 다음 요청의 offset 계산용.
             */
            response.setHeader(
                    "X-Loaded-Count",
                    String.valueOf(
                            items.size()
                    )
            );


            response.setHeader(
                    "X-Has-More",
                    String.valueOf(
                            hasMore
                    )
            );


            request.setAttribute(
                    "feedItems",
                    items
            );

            request.setAttribute(
                    "feedScope",
                    scope
            );

            request.setAttribute(
                    "feedType",
                    type
            );


            request.getRequestDispatcher(
                    "/view/profile/profileFeedItems.jsp"
            ).forward(
                    request,
                    response
            );


        } catch (IllegalArgumentException e) {

            response.sendError(
                    HttpServletResponse
                        .SC_BAD_REQUEST,
                    e.getMessage()
            );


        } catch (Exception e) {

            e.printStackTrace();

            throw new ServletException(
                    "프로필 피드를 불러오는 중 오류가 발생했습니다.",
                    e
            );
        }
    }


    private List<ProfileFeedDto> loadMyFeed(
            String type,
            long userId,
            int offset,
            int limit
    ) throws Exception {


        if ("posts".equals(type)) {

            return profileFeedService
                    .getMyItinerariesPage(
                            userId,
                            offset,
                            limit
                    );
        }


        if ("saved".equals(type)) {

            return profileFeedService
                    .getBookmarkedItinerariesPage(
                            userId,
                            offset,
                            limit
                    );
        }


        if ("liked".equals(type)) {

            return profileFeedService
                    .getLikedItinerariesPage(
                            userId,
                            offset,
                            limit
                    );
        }


        throw new IllegalArgumentException(
                "잘못된 피드 종류입니다."
        );
    }


    private List<ProfileFeedDto> loadUserFeed(
            String type,
            long userId,
            int offset,
            int limit
    ) throws Exception {


        if ("posts".equals(type)) {

            return profileFeedService
                    .getPublicItinerariesPage(
                            userId,
                            offset,
                            limit
                    );
        }


        if ("saved".equals(type)) {

            return profileFeedService
                    .getPublicBookmarkedItinerariesPage(
                            userId,
                            offset,
                            limit
                    );
        }


        if ("liked".equals(type)) {

            return profileFeedService
                    .getPublicLikedItinerariesPage(
                            userId,
                            offset,
                            limit
                    );
        }


        throw new IllegalArgumentException(
                "잘못된 피드 종류입니다."
        );
    }


    private int parseOffset(
            String value
    ) {

        if (
            value == null
            ||
            value.trim().isEmpty()
        ) {

            return 0;
        }


        try {

            int offset =
                    Integer.parseInt(
                            value.trim()
                    );


            return Math.max(
                    offset,
                    0
            );


        } catch (NumberFormatException e) {

            return 0;
        }
    }


    private long parseUserId(
            String value
    ) {

        if (
            value == null
            ||
            value.trim().isEmpty()
        ) {

            throw new IllegalArgumentException(
                    "회원 번호가 없습니다."
            );
        }


        try {

            return Long.parseLong(
                    value.trim()
            );


        } catch (NumberFormatException e) {

            throw new IllegalArgumentException(
                    "잘못된 회원 번호입니다."
            );
        }
    }


    private String normalize(
            String value
    ) {

        return value == null
                ? ""
                : value.trim();
    }
}
