<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="imageValue" value="${fn:trim(param.image)}"/>
<c:set var="imageSrc" value=""/>
<c:set var="contextPrefix" value="${pageContext.request.contextPath}/"/>
<c:choose>
    <c:when test="${fn:startsWith(imageValue, 'https://') or fn:startsWith(imageValue, 'http://')}"><c:set var="imageSrc" value="${imageValue}"/></c:when>
    <c:when test="${not empty imageValue and not fn:startsWith(imageValue, '//') and not fn:contains(imageValue, ':')}">
        <c:choose>
            <c:when test="${not empty pageContext.request.contextPath and fn:startsWith(imageValue, contextPrefix)}"><c:set var="imageSrc" value="${imageValue}"/></c:when>
            <c:when test="${fn:startsWith(imageValue, '/')}"><c:url var="imageSrc" value="${imageValue}"/></c:when>
            <c:otherwise><c:url var="imageSrc" value="${empty applicationScope.profilePath ? '/uploads/profile' : applicationScope.profilePath}/${imageValue}"/></c:otherwise>
        </c:choose>
    </c:when>
</c:choose>
<c:if test="${not empty imageSrc}"><img src="<c:out value='${imageSrc}'/>" alt="프로필 사진" class="w-full h-full object-cover" style="display:block;width:100%;height:100%;object-fit:cover;border-radius:inherit;" loading="lazy" onerror="this.style.display='none';this.nextElementSibling.style.display='flex';"/></c:if>
<span class="profile-image-default" style="display:${empty imageSrc ? 'flex' : 'none'};width:100%;height:100%;align-items:center;justify-content:center;border-radius:inherit;background:#D1D2F9;color:#5056BB;">
    <svg width="50%" height="50%" style="max-width:48px;max-height:48px;" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" aria-hidden="true"><circle cx="12" cy="8" r="4"/><path d="M4 21c0-4.3 3.6-7 8-7s8 2.7 8 7"/></svg>
</span>
