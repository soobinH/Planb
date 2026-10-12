<%@ page
    language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"
    import="java.util.List"
    import="dto.profile.ProfileFeedDto"
%>

<%!

private String escapeHtml(String value) {

    if (value == null) {
        return "";
    }

    return value
            .replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace("\"", "&quot;")
            .replace("'", "&#39;");
}

%>

<%

String ctx =
        request.getContextPath();


@SuppressWarnings("unchecked")
List<ProfileFeedDto> items =
        (List<ProfileFeedDto>)
        request.getAttribute(
                "feedItems"
        );


String scope =
        (String)
        request.getAttribute(
                "feedScope"
        );


String type =
        (String)
        request.getAttribute(
                "feedType"
        );


boolean ownerPost =
        "my".equals(scope)
        &&
        "posts".equals(type);


if (items != null) {

    for (ProfileFeedDto item : items) {

        String country =
                item.getCountry() == null
                ? ""
                : item.getCountry();


        String city =
                item.getCity() == null
                ? ""
                : item.getCity();


        String locationText =
                "";


        if (
            !country.isEmpty()
            &&
            !city.isEmpty()
        ) {

            locationText =
                    country
                    +
                    " · "
                    +
                    city;

        } else if (!country.isEmpty()) {

            locationText =
                    country;

        } else if (!city.isEmpty()) {

            locationText =
                    city;
        }


        String thumbnail =
                item.getThumbnailImg() == null
                ? ""
                : item.getThumbnailImg();


        String thumbnailUrl =
                "";


        if (
            thumbnail.startsWith("http://")
            ||
            thumbnail.startsWith("https://")
        ) {

            thumbnailUrl =
                    thumbnail;

        } else if (!thumbnail.isEmpty()) {

            thumbnailUrl =
                    ctx
                    +
                    (
                        thumbnail.startsWith("/")
                        ? thumbnail
                        : "/" + thumbnail
                    );
        }

%>

<div class="feed-admin-shell">

    <a
        class="feed-item"
        href="<%=ctx%>/schedules/detail?id=<%=item.getItineraryId()%>">

        <%
        if (!thumbnailUrl.isEmpty()) {
        %>

        <img
            src="<%=escapeHtml(thumbnailUrl)%>"
            alt="<%=escapeHtml(item.getTitle())%>"
            loading="lazy">

        <%
        } else {
        %>

        <span class="feed-fallback"></span>

        <%
        }
        %>


        <span class="feed-hover">

            <span class="feed-hover-copy">

                <strong>
                    <%=escapeHtml(item.getTitle())%>
                </strong>


                <%
                if (!locationText.isEmpty()) {
                %>

                <small>
                    <%=escapeHtml(locationText)%>
                </small>

                <%
                }
                %>


                <%
                if (
                    "my".equals(scope)
                    &&
                    "PRIVATE".equals(
                            item.getVisibility()
                    )
                ) {
                %>

                <small>
                    비공개
                </small>

                <%
                }
                %>

            </span>


            <span class="feed-hover-stats">

                <span>
                    ♥ <%=item.getLikeCount()%>
                </span>

                <span>
                    🔖 <%=item.getBookmarkCount()%>
                </span>

                <span>
                    💬 <%=item.getCommentCount()%>
                </span>

            </span>

        </span>

    </a>


    <%
    if (ownerPost) {
    %>

    <div class="feed-owner-actions">

        <button
            type="button"
            class="feed-owner-more"
            data-owner-more
            aria-label="게시글 메뉴">
            •••
        </button>


        <div
            class="feed-owner-menu"
            role="menu">

            <a
                href="<%=ctx%>/modifyplan?itineraryId=<%=item.getItineraryId()%>">
                수정
            </a>


            <button
                type="button"
                class="danger"
                data-delete-itinerary="<%=item.getItineraryId()%>">
                삭제
            </button>

        </div>

    </div>

    <%
    }
    %>

</div>

<%
    }
}
%>
