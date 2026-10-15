<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<c:forEach var="itinerary" items="${cartItineraries}" varStatus="itineraryStatus">
    <article class="cart-itinerary-card" data-cart-card>
        <div class="cart-itinerary-head">
            <button type="button" class="cart-itinerary-toggle" data-cart-toggle="itinerary"
                    aria-expanded="true" aria-controls="cartItineraryBody${itinerary.itineraryId}">
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
                      data-remove-label="이 일정 묶음을 카트에서 삭제하시겠습니까?">
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

        <div class="cart-itinerary-body" id="cartItineraryBody${itinerary.itineraryId}">
            <c:forEach var="day" items="${itinerary.days}" varStatus="dayStatus">
                <section class="cart-day">
                    <div class="cart-day-head">
                        <button type="button" class="cart-day-toggle" data-cart-toggle="day"
                                aria-expanded="false"
                                aria-controls="cartDayBody${itinerary.itineraryId}_${day.dayId}">
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
                              data-remove-label="이 DAY를 카트에서 삭제하시겠습니까?">
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

                    <div class="cart-block-list" id="cartDayBody${itinerary.itineraryId}_${day.dayId}" hidden>
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
                                            <c:when test="${block.blockType eq 'ACTIVITY'}"><span class="cart-block-type attraction">관광</span></c:when>
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
                                              data-remove-label="이 블록을 카트에서 삭제하시겠습니까?">
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
