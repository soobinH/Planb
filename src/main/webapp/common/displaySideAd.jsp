<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:choose>
    <c:when test="${not empty displaySideAd}">
        <a class="display-side-ad-link" href="<c:out value='${displaySideAd.linkUrl}'/>"
           target="_blank" rel="noopener noreferrer sponsored" aria-label="광고주 홈페이지 새 창으로 보기">
            <img src="<c:out value='${param.side == "right" ? displaySideAd.imageUrlRight : displaySideAd.imageUrl}'/>"
                 alt="<c:out value='${displaySideAd.businessName}'/> 광고" width="160" height="600">
            <span class="display-side-ad-badge">AD</span>
        </a>
    </c:when>
    <c:otherwise><div class="display-ad-empty"><span>AD</span><p>광고 준비 중</p></div></c:otherwise>
</c:choose>
