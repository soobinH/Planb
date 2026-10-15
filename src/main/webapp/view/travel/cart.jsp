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
<title>카트</title>

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
    padding: 64px 24px 56px;
}

.cart-heading {
    margin-bottom: 28px;
}

.cart-heading-main {
    width: 100%;
}

/* 타이틀과 카트 수/일정 만들기 버튼을 동일한 한 줄에 정렬 */
.cart-title-bar {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 18px;
    margin-top: 0;
}

/* 알림 페이지의 NOTIFICATIONS와 동일한 글자 크기/굵기/자간 */
.cart-eyebrow {
    display: block;
    margin: 0 0 12px;
    color: #6369d1;
    font-size: 11px;
    font-weight: 700;
    letter-spacing: 2px;
    line-height: 1.5;
}

.cart-title {
    margin: 0;
    color: #111827;
    font-size: 32px;
    font-weight: 750;
    line-height: 1.35;
    letter-spacing: -1.2px;
}

.cart-description {
    margin: 10px 0 0;
    color: #737687;
    font-size: 14px;
    line-height: 1.7;
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
    background: #ececff;
    color: #6666c8;
    border: 1px solid #dddfff;
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


.cart-infinite-scroll {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: 32px 0;
}

.cart-scroll-status {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 8px;
}

.cart-scroll-status[hidden],
.cart-scroll-sentinel[hidden] {
    display: none;
}

.cart-loading-spinner {
    width: 28px;
    height: 28px;
    border: 3px solid #e5e7eb;
    border-top-color: #6369d1;
    border-radius: 50%;
    animation: cart-spin .7s linear infinite;
}

@keyframes cart-spin {
    from { transform: rotate(0deg); }
    to { transform: rotate(360deg); }
}

.cart-scroll-title {
    margin: 0;
    color: #6b7280;
    font-size: 12px;
    font-weight: 600;
}

.cart-scroll-count {
    margin: 0;
    color: #9ca3af;
    font-size: 11px;
}

.cart-scroll-complete .cart-scroll-title {
    color: #6369d1;
    font-weight: 700;
}

.cart-scroll-sentinel {
    width: 100%;
    height: 1px;
}


/* ================================
   최상단 이동 버튼 - 여행꿀팁과 동일
================================ */

.cart-scroll-top-btn {
    position: fixed;

    right: clamp(16px, 2.5vw, 36px);
    bottom: clamp(20px, 3vw, 40px);

    width: clamp(44px, 4vw, 52px);
    height: clamp(44px, 4vw, 52px);

    display: flex;
    align-items: center;
    justify-content: center;

    border: 1px solid #e0e1ff;
    border-radius: 50%;

    background: #ffffff;
    color: #6369D1;

    box-shadow: 0 6px 20px rgba(99, 105, 209, 0.18);

    cursor: pointer;
    z-index: 100;

    opacity: 0;
    visibility: hidden;
    transform: translateY(10px);

    transition:
        opacity 0.25s ease,
        transform 0.25s ease,
        visibility 0.25s ease,
        background 0.2s ease;
}

.cart-scroll-top-btn svg {
    width: 22px;
    height: 22px;
}

.cart-scroll-top-btn.show {
    opacity: 1;
    visibility: visible;
    transform: translateY(0);
}

.cart-scroll-top-btn:hover {
    background: #f0f1ff;
    transform: translateY(-2px);
}

@media (max-width: 720px) {
    .cart-scroll-top-btn {
        right: 16px;
        bottom: 20px;
        width: 44px;
        height: 44px;
    }

    .cart-page-inner {
        padding: 64px 14px 44px;
    }

    .cart-title-bar {
        flex-wrap: wrap;
    }

    .cart-heading-actions {
        justify-content: flex-end;
        margin-left: auto;
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
            <div class="cart-heading-main">
                <p class="cart-eyebrow">CART</p>
                <div class="cart-title-bar">
                    <h1 class="cart-title">일정 카트</h1>
                    <div class="cart-heading-actions">
                        <span class="cart-count" id="cartCountLabel">
                            총 <span id="cartTotalCount"><c:out value="${cartTotalCount}" /></span>개
                        </span>
                        <a class="cart-plan-link" href="${pageContext.request.contextPath}/writeplan">일정 만들기</a>
                    </div>
                </div>
                <p class="cart-description">
                    담아둔 일정·DAY·블록을 확인할 수 있습니다.<br>일정 만들기에서는 이 내용을 드래그해 가져올 수 있습니다.
                </p>
            </div>
        </div>

        <div class="cart-search-panel">
                <div class="cart-search-box">
                    <svg class="cart-search-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
                        <circle cx="10.5" cy="10.5" r="6.5" />
                        <path stroke-linecap="round" d="M16 16l5 5" />
                    </svg>

                    <input id="cartSearchInput" class="cart-search-input" type="search"
                           placeholder="일정·DAY·장소 이름으로 검색..." aria-label="카트 검색" autocomplete="off">

                    <button id="cartSearchClear" class="cart-search-clear" type="button" aria-label="검색어 지우기" hidden>
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
                            <path stroke-linecap="round" d="M6 6l12 12M18 6L6 18" />
                        </svg>
                    </button>
                </div>
            </div>

        <c:choose>
            <c:when test="${empty cartItineraries}">
                <div class="cart-empty">
                    <div class="cart-empty-icon" aria-hidden="true">
                        <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13 5.4 5M7 13l-2.3 2.3c-.6.6-.2 1.7.7 1.7H17m0 0a2 2 0 100 4 2 2 0 000-4Zm-8 2a2 2 0 11-4 0 2 2 0 014 0Z" />
                        </svg>
                    </div>
                    <p class="cart-empty-title">카트가 비어있습니다.</p>
                    <p class="cart-empty-description">여행 일정 상세에서 일정 전체, DAY 또는 블록을 담아보세요.</p>
                </div>
            </c:when>

            <c:otherwise>
                <div id="cartList" class="cart-list">
                    <jsp:include page="/view/travel/cartCardList.jsp" />
                </div>

                <div id="cartInfiniteScroll" class="cart-infinite-scroll"
                     data-current-count="${fn:length(cartItineraries)}"
                     data-total-count="${cartTotalCount}"
                     data-current-page="${page}"
                     data-page-size="${pageSize}">

                    <div id="cartLoading" class="cart-scroll-status" hidden>
                        <div class="cart-loading-spinner"></div>
                        <p class="cart-scroll-title">카트를 불러오는 중...</p>
                        <p class="cart-scroll-count">
                            <span id="cartCurrentCount">${fn:length(cartItineraries)}</span>
                            / 총 <span id="cartScrollTotalCount">${cartTotalCount}</span>개
                        </p>
                    </div>

                    <div id="cartLoadComplete" class="cart-scroll-status cart-scroll-complete" hidden>
                        <p class="cart-scroll-title">모든 카트를 확인했습니다 ✓</p>
                        <p class="cart-scroll-count">
                            <span id="cartCompleteCount">${fn:length(cartItineraries)}</span>
                            / 총 ${cartTotalCount}개
                        </p>
                    </div>

                    <div id="cartScrollSentinel" class="cart-scroll-sentinel"></div>
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

<!-- 최상단 이동 버튼 - 여행꿀팁과 동일 -->
<button type="button" id="cartScrollTopBtn" class="cart-scroll-top-btn" aria-label="페이지 최상단으로 이동">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" aria-hidden="true">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.2" d="M12 19V5M5 12l7-7 7 7" />
    </svg>
</button>

<script src="${pageContext.request.contextPath}/view/assets/js/tripily.js"></script>
<script>
(function () {
    var searchInput = document.getElementById('cartSearchInput');
    var clearButton = document.getElementById('cartSearchClear');
    var searchEmpty = document.getElementById('cartSearchEmpty');
    var totalCountLabel = document.getElementById('cartTotalCount');
    var infiniteScroll = document.getElementById('cartInfiniteScroll');
    var cartList = document.getElementById('cartList');
    var sentinel = document.getElementById('cartScrollSentinel');
    var loading = document.getElementById('cartLoading');
    var loadComplete = document.getElementById('cartLoadComplete');

    var totalCartCount = infiniteScroll
        ? Number(infiniteScroll.dataset.totalCount || 0)
        : Number(totalCountLabel ? totalCountLabel.textContent : 0) || 0;

    function getCards() {
        return Array.prototype.slice.call(document.querySelectorAll('[data-cart-card]'));
    }

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

        getCards().forEach(function (card) {
            var matched = !query || card.textContent.toLowerCase().indexOf(query) !== -1;
            card.hidden = !matched;
            if (matched) visibleCount++;
        });

        if (clearButton) clearButton.hidden = query.length === 0;
        if (searchEmpty) searchEmpty.hidden = visibleCount !== 0 || query.length === 0;
        if (totalCountLabel) totalCountLabel.textContent = query ? visibleCount : totalCartCount;
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

        var message = form.getAttribute('data-remove-label') || '카트에서 삭제하시겠습니까?';
        if (!window.confirm(message)) {
            event.preventDefault();
        }
    });

    // 여행 꿀팁과 같은 방식의 무한 스크롤: 하단 30px, 로딩 대기 1초.
    if (infiniteScroll && cartList) {
        var currentPage = Number(infiniteScroll.dataset.currentPage || 1);
        var currentCount = Number(infiniteScroll.dataset.currentCount || 0);
        var totalCount = Number(infiniteScroll.dataset.totalCount || 0);
        var isLoading = false;

        function hideLoading() {
            if (loading) loading.hidden = true;
        }

        function showComplete() {
            if (sentinel) sentinel.hidden = true;

            var completeCount = document.getElementById('cartCompleteCount');
            if (completeCount) completeCount.textContent = currentCount;

            if (loadComplete) loadComplete.hidden = false;
        }

        function loadNextPage() {
            if (isLoading || currentCount >= totalCount) return;

            isLoading = true;

            if (loading) loading.hidden = false;

            var currentCountElement = document.getElementById('cartCurrentCount');
            if (currentCountElement) currentCountElement.textContent = currentCount;

            var nextPage = currentPage + 1;
            var params = new URLSearchParams(window.location.search);
            params.set('page', nextPage);

            var loadUrl = window.location.pathname + '/load?' + params.toString();

            fetch(loadUrl)
                .then(function (response) {
                    if (!response.ok) {
                        throw new Error('카트를 불러오지 못했습니다.');
                    }
                    return response.text();
                })
                .then(function (html) {
                    var temp = document.createElement('div');
                    temp.innerHTML = html.trim();
                    var newCards = Array.from(temp.children);

                    setTimeout(function () {
                        if (newCards.length === 0) {
                            currentCount = totalCount;
                            hideLoading();
                            showComplete();
                            isLoading = false;
                            return;
                        }

                        newCards.forEach(function (card) {
                            cartList.appendChild(card);
                        });

                        currentPage = nextPage;
                        currentCount = Math.min(currentCount + newCards.length, totalCount);

                        infiniteScroll.dataset.currentPage = currentPage;
                        infiniteScroll.dataset.currentCount = currentCount;

                        hideLoading();

                        if (searchInput && searchInput.value.trim()) {
                            filterCards();
                        }

                        if (currentCount >= totalCount) {
                            showComplete();
                        }

                        isLoading = false;
                    }, 1000);
                })
                .catch(function (error) {
                    console.error('카트 무한 스크롤 오류:', error);
                    hideLoading();
                    isLoading = false;
                });
        }

        window.addEventListener('scroll', function () {
            if (isLoading || currentCount >= totalCount) return;

            var scrollTop = window.pageYOffset || document.documentElement.scrollTop;
            var windowHeight = window.innerHeight;
            var documentHeight = document.documentElement.scrollHeight;

            if (scrollTop + windowHeight < documentHeight - 30) return;

            loadNextPage();
        });

        if (currentCount >= totalCount) {
            showComplete();
        }
    }

    // ================================
    // 최상단 이동 버튼 - 여행꿀팁과 동일
    // ================================
    var cartScrollTopBtn = document.getElementById('cartScrollTopBtn');

    if (cartScrollTopBtn) {
        window.addEventListener('scroll', function () {
            if (window.scrollY > 500) {
                cartScrollTopBtn.classList.add('show');
            } else {
                cartScrollTopBtn.classList.remove('show');
            }
        });

        cartScrollTopBtn.addEventListener('click', function () {
            window.scrollTo({
                top: 0,
                behavior: 'smooth'
            });
        });
    }

})();
</script>

</body>
</html>
