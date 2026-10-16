<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="imageValue" value="${fn:trim(param.image)}"/>
<c:set var="imageSrc" value=""/>
<c:choose>
    <c:when test="${fn:startsWith(imageValue, 'https://') or fn:startsWith(imageValue, 'http://')}"><c:set var="imageSrc" value="${imageValue}"/></c:when>
    <c:when test="${not empty imageValue and not fn:startsWith(imageValue, '//') and not fn:contains(imageValue, ':')}">
        <c:choose>
            <c:when test="${fn:startsWith(imageValue, '/')}"><c:url var="imageSrc" value="${imageValue}"/></c:when>
            <c:otherwise><c:url var="imageSrc" value="/uploads/profile/${imageValue}"/></c:otherwise>
        </c:choose>
    </c:when>
</c:choose>
<c:if test="${not empty imageSrc}"><img src="<c:out value='${imageSrc}'/>" alt="프로필 사진" class="w-full h-full object-cover" loading="lazy" onerror="this.style.display='none';this.nextElementSibling.style.display='flex';"/></c:if>
<span class="w-full h-full items-center justify-center" style="display:${empty imageSrc ? 'flex' : 'none'}"><c:out value="${empty param.nickname ? 'U' : fn:substring(param.nickname, 0, 1)}"/></span>
