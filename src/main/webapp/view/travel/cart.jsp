<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%
if (request.getAttribute("cartItineraries") == null) {
    response.sendRedirect(request.getContextPath() + "/cart");
    return;
}
request.setAttribute("activePage", "travel");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>장바구니</title>

<jsp:include page="/common/headStyles.jsp" />

<style>
.cart-page {
    flex: 1;
    min-height: calc(100vh - 68px);
    background: #fbfbfe;
}

.cart-page-inner {
    width: 100%;
    max-width: 1180px;
    margin: 0 auto;
    padding: 32px 24px 56px;
}

.cart-heading {
    display: flex;
    align-items: flex-start;
    justify-content: space-between;
    gap: 18px;
    margin-bottom: 22px;
}

.cart-title {
    margin: 0 0 5px;
    color: #111827;
    font-size: 25px;
    font-weight: 900;
    line-height: 1.35;
}

.cart-description {
    margin: 0;
    color: #6b7280;
    font-size: 14px;
    line-height: 1.65;
}

.cart-heading-actions {
    display: flex;
    align-items: center;
    gap: 10px;
    flex-shrink: 0;
}

.cart-count {
    padding: 7px 12px;
    border-radius: 999px;
    background: #eef2ff;
    color: #6369d1;
    font-size: 13px;
    font-weight: 800;
    white-space: nowrap;
}

.cart-plan-link {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    min-height: 36px;
    padding: 0 14px;
    border-radius: 10px;
    background: #6369d1;
    color: #fff;
    font-size: 13px;
    font-weight: 800;
    text-decoration: none;
    box-shadow: 0 8px 20px rgba(99,105,209,.16);
}

.cart-plan-link:hover {
    background: #565dc5;
}

.cart-search-panel {
    margin-bottom: 18px;
    padding: 14px;
    border: 1px solid #e5e7eb;
    border-radius: 16px;
    background: #fff;
    box-shadow: 0 6px 18px rgba(17,24,39,.035);
}

.cart-search-box {
    display: flex;
    align-items: center;
    gap: 8px;
    min-height: 42px;
    padding: 0 12px;
    border: 1px solid #d9dbf6;
    border-radius: 12px;
    background: #f8f8fc;
}

.cart-search-box:focus-within {
    border-color: #6369d1;
    box-shadow: 0 0 0 3px rgba(99,105,209,.08);
}

.cart-search-icon {
    width: 18px;
    height: 18px;
    flex-shrink: 0;
    color: #6369d1;
}

.cart-search-input {
    flex: 1;
    min-width: 0;
    border: 0;
    outline: 0;
    background: transparent;
    color: #374151;
    font: inherit;
    font-size: 14px;
}

.cart-search-input::placeholder {
    color: #9ca3af;
}

.cart-search-clear {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 26px;
    height: 26px;
    padding: 0;
    border: 0;
    border-radius: 8px;
    background: transparent;
    color: #9ca3af;
    cursor: pointer;
}

.cart-search-clear:hover {
    background: #eef2ff;
    color: #6369d1;
}

.cart-search-clear[hidden] {
    display: none;
}

.cart-list {
    display: flex;
    flex-direction: column;
    gap: 14px;
}

.cart-itinerary-card {
    overflow: hidden;
    border: 1px solid #e5e7eb;
    border-radius: 18px;
    background: #fff;
    box-shadow: 0 8px 26px rgba(17,24,39,.045);
}

.cart-itinerary-card[hidden] {
    display: none;
}

.cart-itinerary-head {
    display: flex;
    align-items: stretch;
    border-bottom: 1px solid #eef0f5;
}

.cart-itinerary-toggle {
    display: flex;
    align-items: center;
    gap: 12px;
    flex: 1;
    min-width: 0;
    padding: 15px 16px;
    border: 0;
    background: #fff;
    text-align: left;
    cursor: pointer;
}

.cart-itinerary-toggle:hover {
    background: #fafaff;
}

.cart-itinerary-mark {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 42px;
    height: 42px;
    flex: 0 0 42px;
    overflow: hidden;
    border: 1px solid #e5e7eb;
    border-radius: 11px;
    background: #f3f4f6;
    color: #9ca3af;
    font-size: 10px;
    font-weight: 900;
}

.cart-itinerary-thumb {
    display: block;
    width: 100%;
    height: 100%;
    object-fit: cover;
}

.cart-itinerary-thumb-fallback {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 100%;
    height: 100%;
    background: #eef2ff;
    color: #6369d1;
}

.cart-itinerary-copy {
    flex: 1;
    min-width: 0;
}

.cart-itinerary-title-row {
    display: flex;
    align-items: center;
    gap: 8px;
    min-width: 0;
}

.cart-itinerary-title {
    margin: 0;
    min-width: 0;
    overflow: hidden;
    color: #1f2937;
    font-size: 15px;
    font-weight: 900;
    line-height: 1.4;
    text-overflow: ellipsis;
    white-space: nowrap;
}

.cart-itinerary-meta {
    display: flex;
    flex-wrap: wrap;
    gap: 5px 9px;
    margin-top: 4px;
    color: #9ca3af;
    font-size: 11px;
    line-height: 1.45;
}

.cart-itinerary-meta strong {
    color: #6b7280;
    font-weight: 700;
}

.cart-chevron {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 28px;
    height: 28px;
    flex-shrink: 0;
    border-radius: 8px;
    color: #9ca3af;
    transition: transform .18s ease, background .18s ease, color .18s ease;
}

[aria-expanded="false"] .cart-chevron {
    transform: rotate(-90deg);
}

.cart-delete-form {
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
}

.cart-head-actions {
    display: flex;
    align-items: center;
    gap: 7px;
    flex-shrink: 0;
    padding: 0 12px;
    border-left: 1px solid #eef0f5;
}

.cart-detail-link {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 5px;
    min-height: 32px;
    padding: 0 10px;
    border: 1px solid #d9dbf6;
    border-radius: 9px;
    background: #fff;
    color: #6369d1;
    font-size: 11px;
    font-weight: 800;
    line-height: 1;
    text-decoration: none;
    white-space: nowrap;
}

.cart-detail-link:hover {
    border-color: #b8bcf0;
    background: #f7f7ff;
}

.cart-head-delete {
    padding: 0;
}

.cart-delete-btn {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 34px;
    height: 34px;
    padding: 0;
    border: 1px solid transparent;
    border-radius: 9px;
    background: transparent;
    color: #9ca3af;
    cursor: pointer;
}

.cart-delete-btn:hover {
    border-color: #fecaca;
    background: #fff1f2;
    color: #dc2626;
}

.cart-itinerary-body {
    padding: 11px 12px 13px;
    background: #fcfcff;
}

.cart-itinerary-body[hidden] {
    display: none;
}

.cart-day {
    overflow: hidden;
    border: 1px solid #e8e9f1;
    border-radius: 13px;
    background: #fff;
}

.cart-day + .cart-day {
    margin-top: 8px;
}

.cart-day-head {
    display: flex;
    align-items: stretch;
}

.cart-day-toggle {
    display: flex;
    align-items: center;
    gap: 9px;
    flex: 1;
    min-width: 0;
    padding: 10px 11px;
    border: 0;
    background: #fff;
    text-align: left;
    cursor: pointer;
}

.cart-day-toggle:hover {
    background: #fafaff;
}

.cart-day-badge {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    min-width: 32px;
    height: 23px;
    padding: 0 7px;
    border-radius: 7px;
    background: #6369d1;
    color: #fff;
    font-size: 10px;
    font-weight: 900;
}

.cart-day-title {
    flex: 1;
    min-width: 0;
    overflow: hidden;
    color: #374151;
    font-size: 12px;
    font-weight: 800;
    text-overflow: ellipsis;
    white-space: nowrap;
}

.cart-day-date,
.cart-day-count {
    color: #9ca3af;
    font-size: 10px;
    white-space: nowrap;
}

.cart-day-delete {
    padding: 0 8px 0 2px;
}

.cart-day-delete .cart-delete-btn {
    width: 30px;
    height: 30px;
}

.cart-block-list {
    padding: 0 9px 9px 42px;
}

.cart-block-list[hidden] {
    display: none;
}

.cart-block-row {
    display: flex;
    align-items: center;
    gap: 9px;
    min-height: 42px;
    padding: 7px 8px;
    border: 1px solid #ececf2;
    border-radius: 10px;
    background: #fff;
}

.cart-block-row + .cart-block-row {
    margin-top: 6px;
}

.cart-block-type {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    min-width: 38px;
    height: 24px;
    padding: 0 7px;
    border-radius: 999px;
    font-size: 10px;
    font-weight: 900;
    white-space: nowrap;
}

.cart-block-type.attraction { background: #eef2ff; color: #6369d1; }
.cart-block-type.meal { background: #fff7ed; color: #f97316; }
.cart-block-type.lodging { background: #ecfdf5; color: #10b981; }
.cart-block-type.transport { background: #eff6ff; color: #3b82f6; }
.cart-block-type.activity { background: #fdf2f8; color: #ec4899; }
.cart-block-type.unknown { background: #f3f4f6; color: #6b7280; }

.cart-block-copy {
    flex: 1;
    min-width: 0;
}

.cart-block-name {
    overflow: hidden;
    color: #374151;
    font-size: 11px;
    font-weight: 800;
    line-height: 1.4;
    text-overflow: ellipsis;
    white-space: nowrap;
}

.cart-block-meta {
    display: flex;
    flex-wrap: wrap;
    gap: 3px 8px;
    margin-top: 2px;
    color: #9ca3af;
    font-size: 10px;
    line-height: 1.4;
}

.cart-block-delete .cart-delete-btn {
    width: 28px;
    height: 28px;
}

.cart-no-blocks {
    padding: 9px 10px;
    border-radius: 9px;
    background: #f9fafb;
    color: #9ca3af;
    font-size: 11px;
    text-align: center;
}

.cart-empty,
.cart-search-empty {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: 88px 16px;
    text-align: center;
}

.cart-search-empty[hidden] {
    display: none;
}

.cart-empty-icon {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 58px;
    height: 58px;
    margin-bottom: 14px;
    border-radius: 18px;
    background: #eef2ff;
    color: #6369d1;
}

.cart-empty-title {
    margin: 0 0 5px;
    color: #6b7280;
    font-size: 15px;
    font-weight: 800;
}

.cart-empty-description {
    margin: 0;
    color: #9ca3af;
    font-size: 13px;
    line-height: 1.6;
}

@media (max-width: 720px) {
    .cart-page-inner {
        padding: 24px 14px 44px;
    }

    .cart-heading {
        flex-direction: column;
        align-items: stretch;
    }

    .cart-heading-actions {
        justify-content: space-between;
    }

    .cart-itinerary-toggle {
        padding: 13px 11px;
    }

    .cart-head-actions {
        gap: 5px;
        padding: 0 7px;
    }

    .cart-detail-link {
        width: 32px;
        min-width: 32px;
        height: 32px;
        min-height: 32px;
        padding: 0;
        font-size: 0;
    }

    .cart-itinerary-mark {
        width: 36px;
        height: 36px;
        flex-basis: 36px;
    }

    .cart-day-date {
        display: none;
    }

    .cart-block-list {
        padding-left: 10px;
    }
}
</style>
</head>

<body class="site-shell">

<jsp:include page="/common/header.jsp" />

<main class="cart-page">
    <div class="cart-page-inner">

        <div class="cart-heading">
            <div>
                <h1 class="cart-title">일정 장바구니</h1>
                <p class="cart-description">
                    담아둔 일정·DAY·블록을 확인할 수 있습니다. 일정 만들기에서는 이 내용을 드래그해 가져올 수 있습니다.
                </p>
            </div>

            <div class="cart-heading-actions">
                <span class="cart-count" id="cartCountLabel">
                    총 <span id="cartTotalCount"><c:out value="${cartTotalCount}" /></span>개
                </span>
                <a class="cart-plan-link" href="${pageContext.request.contextPath}/writeplan">일정 만들기</a>
            </div>
        </div>

        <c:if test="${not empty cartItineraries}">
            <div class="cart-search-panel">
                <div class="cart-search-box">
                    <svg class="cart-search-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
                        <circle cx="10.5" cy="10.5" r="6.5" />
                        <path stroke-linecap="round" d="M16 16l5 5" />
                    </svg>

                    <input id="cartSearchInput" class="cart-search-input" type="search"
                           placeholder="일정·DAY·장소 이름으로 검색..." aria-label="장바구니 검색" autocomplete="off">

                    <button id="cartSearchClear" class="cart-search-clear" type="button" aria-label="검색어 지우기" hidden>
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
                            <path stroke-linecap="round" d="M6 6l12 12M18 6L6 18" />
                        </svg>
                    </button>
                </div>
            </div>
        </c:if>

        <c:choose>
            <c:when test="${empty cartItineraries}">
                <div class="cart-empty">
                    <div class="cart-empty-icon" aria-hidden="true">
                        <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13 5.4 5M7 13l-2.3 2.3c-.6.6-.2 1.7.7 1.7H17m0 0a2 2 0 100 4 2 2 0 000-4Zm-8 2a2 2 0 11-4 0 2 2 0 014 0Z" />
                        </svg>
                    </div>
                    <p class="cart-empty-title">장바구니가 비어있습니다.</p>
                    <p class="cart-empty-description">여행 일정 상세에서 일정 전체, DAY 또는 블록을 담아보세요.</p>
                </div>
            </c:when>

            <c:otherwise>
                <div id="cartList" class="cart-list">
                    <c:forEach var="itinerary" items="${cartItineraries}" varStatus="itineraryStatus">
                        <article class="cart-itinerary-card" data-cart-card>
                            <div class="cart-itinerary-head">
                                <button type="button" class="cart-itinerary-toggle" data-cart-toggle="itinerary"
                                        aria-expanded="true" aria-controls="cartItineraryBody${itineraryStatus.index}">
                                    <span class="cart-itinerary-mark">
                                        <c:choose>
                                            <c:when test="${fn:startsWith(itinerary.thumbnailImg, 'gplace:')}">
                                                <img class="cart-itinerary-thumb"
                                                     src="data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///ywAAAAAAQABAAACAUwAOw=="
                                                     data-google-place-id="${fn:substringAfter(itinerary.thumbnailImg, 'gplace:')}"
                                                     alt="" loading="lazy">
                                            </c:when>
                                            <c:when test="${fn:startsWith(itinerary.thumbnailImg, 'flag:')}">
                                                <img class="cart-itinerary-thumb"
                                                     src="data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///ywAAAAAAQABAAACAUwAOw=="
                                                     data-country-flag-code="${fn:substringAfter(itinerary.thumbnailImg, 'flag:')}"
                                                     alt="" loading="lazy">
                                            </c:when>
                                            <c:when test="${fn:startsWith(itinerary.thumbnailImg, 'http://') or fn:startsWith(itinerary.thumbnailImg, 'https://')}">
                                                <img class="cart-itinerary-thumb" src="${itinerary.thumbnailImg}" alt="" loading="lazy">
                                            </c:when>
                                            <c:when test="${not empty itinerary.thumbnailImg}">
                                                <img class="cart-itinerary-thumb"
                                                     src="${pageContext.request.contextPath}${itinerary.thumbnailImg}"
                                                     alt="" loading="lazy">
                                            </c:when>
                                            <c:when test="${not empty itinerary.country}">
                                                <span class="cart-itinerary-thumb-fallback">
                                                    <c:out value="${fn:substring(itinerary.country, 0, 1)}" />
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="cart-itinerary-thumb-fallback">TR</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </span>

                                    <span class="cart-itinerary-copy">
                                        <span class="cart-itinerary-title-row">
                                            <span class="cart-itinerary-title">
                                                <c:choose>
                                                    <c:when test="${not empty itinerary.title}"><c:out value="${itinerary.title}" /></c:when>
                                                    <c:otherwise>제목 없는 일정</c:otherwise>
                                                </c:choose>
                                            </span>
                                        </span>
                                        <span class="cart-itinerary-meta">
                                            <span>
                                                <strong><c:out value="${itinerary.country}" /></strong>
                                                <c:if test="${not empty itinerary.city}"> · <c:out value="${itinerary.city}" /></c:if>
                                            </span>
                                            <c:if test="${not empty itinerary.nickname}">
                                                <span>작성자 <strong><c:out value="${itinerary.nickname}" /></strong></span>
                                            </c:if>
                                            <span><strong>${fn:length(itinerary.days)}</strong> DAY</span>
                                            <span><strong><c:out value="${itinerary.travelerCount}" /></strong>명</span>
                                        </span>
                                    </span>

                                    <span class="cart-chevron" aria-hidden="true">⌄</span>
                                </button>

                                <div class="cart-head-actions">
                                    <a class="cart-detail-link"
                                       href="${pageContext.request.contextPath}/schedules/detail?id=${itinerary.itineraryId}"
                                       title="해당 일정 상세보기" aria-label="해당 일정 상세보기">
                                        상세보기
                                        <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
                                            <path stroke-linecap="round" stroke-linejoin="round" d="M7 17 17 7M9 7h8v8" />
                                        </svg>
                                    </a>

                                    <form class="cart-delete-form cart-head-delete" method="post"
                                          action="${pageContext.request.contextPath}/itinerary/cart/remove"
                                          data-remove-label="이 일정 묶음을 장바구니에서 삭제하시겠습니까?">
                                        <input type="hidden" name="itineraryId" value="${itinerary.itineraryId}">
                                        <input type="hidden" name="itemType" value="ITINERARY">
                                        <input type="hidden" name="targetId" value="${itinerary.itineraryId}">
                                        <button type="submit" class="cart-delete-btn" title="일정 전체 삭제" aria-label="일정 전체 삭제">
                                            <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" aria-hidden="true">
                                                <path stroke-linecap="round" stroke-linejoin="round" d="M4 7h16M10 11v6M14 11v6M6 7l1 13h10l1-13M9 7V4h6v3" />
                                            </svg>
                                        </button>
                                    </form>
                                </div>
                            </div>

                            <div class="cart-itinerary-body" id="cartItineraryBody${itineraryStatus.index}">
                                <c:forEach var="day" items="${itinerary.days}" varStatus="dayStatus">
                                    <section class="cart-day">
                                        <div class="cart-day-head">
                                            <button type="button" class="cart-day-toggle" data-cart-toggle="day"
                                                    aria-expanded="false"
                                                    aria-controls="cartDayBody${itineraryStatus.index}_${dayStatus.index}">
                                                <span class="cart-day-badge">D<c:out value="${empty day.dayOrder ? dayStatus.index + 1 : day.dayOrder}" /></span>
                                                <span class="cart-day-title">
                                                    <c:choose>
                                                        <c:when test="${not empty day.title}"><c:out value="${day.title}" /></c:when>
                                                        <c:otherwise>Day ${empty day.dayOrder ? dayStatus.index + 1 : day.dayOrder}</c:otherwise>
                                                    </c:choose>
                                                </span>
                                                <c:if test="${not empty day.dayDate}">
                                                    <span class="cart-day-date"><c:out value="${day.dayDate}" /></span>
                                                </c:if>
                                                <span class="cart-day-count">${fn:length(day.blocks)}개</span>
                                                <span class="cart-chevron" aria-hidden="true">⌄</span>
                                            </button>

                                            <form class="cart-delete-form cart-day-delete" method="post"
                                                  action="${pageContext.request.contextPath}/itinerary/cart/remove"
                                                  data-remove-label="이 DAY를 장바구니에서 삭제하시겠습니까?">
                                                <input type="hidden" name="itineraryId" value="${itinerary.itineraryId}">
                                                <input type="hidden" name="itemType" value="DAY">
                                                <input type="hidden" name="targetId" value="${day.dayId}">
                                                <button type="submit" class="cart-delete-btn" title="DAY 삭제" aria-label="DAY 삭제">
                                                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" aria-hidden="true">
                                                        <path stroke-linecap="round" stroke-linejoin="round" d="M4 7h16M10 11v6M14 11v6M6 7l1 13h10l1-13M9 7V4h6v3" />
                                                    </svg>
                                                </button>
                                            </form>
                                        </div>

                                        <div class="cart-block-list" id="cartDayBody${itineraryStatus.index}_${dayStatus.index}" hidden>
                                            <c:choose>
                                                <c:when test="${empty day.blocks}">
                                                    <div class="cart-no-blocks">담긴 일정 블록이 없습니다.</div>
                                                </c:when>
                                                <c:otherwise>
                                                    <c:forEach var="block" items="${day.blocks}">
                                                        <div class="cart-block-row">
                                                            <c:choose>
                                                                <c:when test="${block.blockType eq 'ATTRACTION'}"><span class="cart-block-type attraction">관광</span></c:when>
                                                                <c:when test="${block.blockType eq 'MEAL'}"><span class="cart-block-type meal">식사</span></c:when>
                                                                <c:when test="${block.blockType eq 'LODGING'}"><span class="cart-block-type lodging">숙박</span></c:when>
                                                                <c:when test="${block.blockType eq 'TRANSPORT'}"><span class="cart-block-type transport">교통</span></c:when>
                                                                <c:when test="${block.blockType eq 'ACTIVITY'}"><span class="cart-block-type activity">활동</span></c:when>
                                                                <c:otherwise><span class="cart-block-type unknown">일정</span></c:otherwise>
                                                            </c:choose>

                                                            <div class="cart-block-copy">
                                                                <div class="cart-block-name">
                                                                    <c:choose>
                                                                        <c:when test="${not empty block.title}"><c:out value="${block.title}" /></c:when>
                                                                        <c:when test="${not empty block.placeName}"><c:out value="${block.placeName}" /></c:when>
                                                                        <c:otherwise>새 일정</c:otherwise>
                                                                    </c:choose>
                                                                </div>
                                                                <div class="cart-block-meta">
                                                                    <c:if test="${not empty block.placeName}"><span><c:out value="${block.placeName}" /></span></c:if>
                                                                    <c:if test="${not empty block.startTime}">
                                                                        <span>
                                                                            <c:out value="${fn:substring(block.startTime, 0, 5)}" />
                                                                            <c:if test="${not empty block.endTime}">–<c:out value="${fn:substring(block.endTime, 0, 5)}" /></c:if>
                                                                        </span>
                                                                    </c:if>
                                                                    <c:if test="${not empty block.cost}">
                                                                        <span><c:out value="${block.cost}" />원<c:if test="${block.costType eq 'PER_PERSON'}">/인</c:if></span>
                                                                    </c:if>
                                                                </div>
                                                            </div>

                                                            <form class="cart-delete-form cart-block-delete" method="post"
                                                                  action="${pageContext.request.contextPath}/itinerary/cart/remove"
                                                                  data-remove-label="이 블록을 장바구니에서 삭제하시겠습니까?">
                                                                <input type="hidden" name="itineraryId" value="${itinerary.itineraryId}">
                                                                <input type="hidden" name="itemType" value="BLOCK">
                                                                <input type="hidden" name="targetId" value="${block.blockId}">
                                                                <button type="submit" class="cart-delete-btn" title="블록 삭제" aria-label="블록 삭제">
                                                                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" aria-hidden="true">
                                                                        <path stroke-linecap="round" stroke-linejoin="round" d="M4 7h16M10 11v6M14 11v6M6 7l1 13h10l1-13M9 7V4h6v3" />
                                                                    </svg>
                                                                </button>
                                                            </form>
                                                        </div>
                                                    </c:forEach>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </section>
                                </c:forEach>
                            </div>
                        </article>
                    </c:forEach>
                </div>

                <div id="cartSearchEmpty" class="cart-search-empty" hidden>
                    <div class="cart-empty-icon" aria-hidden="true">
                        <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9">
                            <circle cx="10.5" cy="10.5" r="6.5" />
                            <path stroke-linecap="round" d="M16 16l5 5" />
                        </svg>
                    </div>
                    <p class="cart-empty-title">검색 결과가 없습니다.</p>
                    <p class="cart-empty-description">다른 일정명, DAY명 또는 장소명으로 검색해보세요.</p>
                </div>
            </c:otherwise>
        </c:choose>

    </div>
</main>

<script src="${pageContext.request.contextPath}/view/assets/js/tripily.js"></script>
<script>
(function () {
    var searchInput = document.getElementById('cartSearchInput');
    var clearButton = document.getElementById('cartSearchClear');
    var searchEmpty = document.getElementById('cartSearchEmpty');
    var totalCount = document.getElementById('cartTotalCount');
    var cards = Array.prototype.slice.call(document.querySelectorAll('[data-cart-card]'));
    var baseCount = cards.length;

    function setExpanded(button, expanded) {
        var targetId = button.getAttribute('aria-controls');
        var target = targetId ? document.getElementById(targetId) : null;
        button.setAttribute('aria-expanded', expanded ? 'true' : 'false');
        if (target) target.hidden = !expanded;
    }

    document.addEventListener('click', function (event) {
        var toggle = event.target.closest('[data-cart-toggle]');
        if (!toggle) return;
        var expanded = toggle.getAttribute('aria-expanded') === 'true';
        setExpanded(toggle, !expanded);
    });

    function filterCards() {
        if (!searchInput) return;

        var query = searchInput.value.trim().toLowerCase();
        var visibleCount = 0;

        cards.forEach(function (card) {
            var matched = !query || card.textContent.toLowerCase().indexOf(query) !== -1;
            card.hidden = !matched;
            if (matched) visibleCount++;
        });

        if (clearButton) clearButton.hidden = query.length === 0;
        if (searchEmpty) searchEmpty.hidden = visibleCount !== 0 || query.length === 0;
        if (totalCount) totalCount.textContent = query ? visibleCount : baseCount;
    }

    if (searchInput) {
        searchInput.addEventListener('input', filterCards);
    }

    if (clearButton && searchInput) {
        clearButton.addEventListener('click', function () {
            searchInput.value = '';
            filterCards();
            searchInput.focus();
        });
    }

    document.addEventListener('submit', function (event) {
        var form = event.target.closest('.cart-delete-form');
        if (!form) return;

        var message = form.getAttribute('data-remove-label') || '장바구니에서 삭제하시겠습니까?';
        if (!window.confirm(message)) {
            event.preventDefault();
        }
    });
})();
</script>

</body>
</html>
