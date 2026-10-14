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
                    <svg class="feed-stat-icon" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M19 14c1.49-1.46 3-3.21 3-5.5A5.5 5.5 0 0 0 16.5 3c-1.76 0-3 .5-4.5 2-1.5-1.5-2.74-2-4.5-2A5.5 5.5 0 0 0 2 8.5c0 2.3 1.5 4.05 3 5.5l7 7Z"/></svg> <%=item.getLikeCount()%>
                </span>

                <span>
                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none"
                        stroke="currentColor" stroke-width="1.8" stroke-linecap="round"
                        stroke-linejoin="round" style="vertical-align:-3px;margin-right:3px"
                        aria-hidden="true"><path d="M6 4.5h12v16l-6-4-6 4z"/></svg> <%=item.getBookmarkCount()%>
                </span>

                <span>
                    <svg class="feed-stat-icon" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M7.9 20A9 9 0 1 0 4 16.1L2 22Z"/></svg> <%=item.getCommentCount()%>
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
