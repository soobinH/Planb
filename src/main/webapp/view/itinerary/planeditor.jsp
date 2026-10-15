<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%
request.setAttribute("activePage", "planner");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>일정 수정</title>
<jsp:include page="/common/headStyles.jsp" />
<link rel="stylesheet" href="${pageContext.request.contextPath}/view/assets/css/itinerary/planner.css?v=1">
</head>
<body class="site-shell">
    <jsp:include page="/common/header.jsp" />
    <c:if test="${not empty err}">
        <div role="alert" aria-live="assertive"
             style="margin:12px auto;padding:12px 18px;max-width:980px;border:1px solid #FCA5A5;border-radius:10px;background:#FEF2F2;color:#B91C1C;font-size:14px;font-weight:600;">
            저장할 수 없습니다: <c:out value="${err}" />
        </div>
    </c:if>

    <main class="planner-page-shell flex flex-col">
        <div class="shrink-0 border-b border-gray-100" style="background: #F8F8FF">
            <div class="planner-top-grid grid min-w-0">
                <div class="planner-top-fields min-w-0 px-6 py-3 flex flex-col gap-3">
                    <div class="flex items-center gap-3 min-w-0">
                        <div class="h-[46px] flex-1 min-w-0 rounded-xl border bg-white flex items-center gap-3 px-4"
                            style="border-color: #E2E5EF">
                            <svg class="shrink-0" width="16" height="16" viewBox="0 0 24 24" fill="none"
                                stroke="#6369D1" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <path d="M12 20h9" />
                                <path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4Z" />
                            </svg>
                            <input
                                class="flex-1 min-w-0 font-semibold text-sm text-gray-800 outline-none bg-transparent placeholder-gray-400 border-none"
                                id="tripTitle" maxlength="30" placeholder="여행 제목을 입력하세요" style="font-size: 14px">
                            <span id="plannerTitleCount" class="shrink-0 text-[10px] font-semibold text-gray-400" aria-live="polite">0/30</span>
                        </div>
                        <div class="flex items-center gap-1.5 shrink-0 text-gray-500 text-sm px-2">
                            <svg class="text-gray-400" width="14" height="14" viewBox="0 0 24 24" fill="none"
                                stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <rect width="18" height="18" x="3" y="4" rx="2" />
                                <path d="M16 2v4M8 2v4M3 10h18" />
                            </svg>
                            <span id="plannerScheduleStats" aria-live="polite">1일 · 0개 일정</span>
                        </div>
                    </div>

                    <div class="planner-meta-grid grid gap-3 min-w-0">
                        <div id="plannerCountryField" class="relative overflow-visible min-w-0 h-[50px] rounded-xl border bg-white flex items-center gap-3 px-3.5"
                            style="border-color: #FCA5A5">
                            <div class="w-8 h-8 rounded-lg shrink-0 flex items-center justify-center"
                                style="background: #F0EFFF; color: #6369D1">
                                <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                    stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                    <circle cx="12" cy="12" r="10" />
                                    <path d="M2 12h20M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10Z" />
                                </svg>
                            </div>
                            <div class="min-w-0 flex-1 flex flex-col justify-center">
                                <span class="text-[10px] font-semibold text-gray-400 leading-none mb-1">국가</span>
                                <div id="plannerCountryCombo" class="w-full min-w-0">
                                    <div class="flex items-center gap-1.5 w-full min-w-0">
                                        <input class="outline-none text-sm text-gray-800 bg-transparent placeholder-gray-400 w-full min-w-0"
                                            id="plannerCountry" placeholder="국가 선택" value="" autocomplete="off">
                                        <button type="button" id="plannerCountryClear"
                                            class="hidden shrink-0 text-gray-300 hover:text-gray-500"
                                            aria-label="국가 입력 지우기">
                                            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                                stroke-width="2" stroke-linecap="round">
                                                <path d="M18 6 6 18M6 6l12 12"/>
                                            </svg>
                                        </button>
                                    </div>
                                    <div id="plannerCountryDropdown"
                                        class="hidden absolute top-full left-0 right-0 mt-1 bg-white border border-gray-200 rounded-xl shadow-xl z-50"
                                        style="max-height: 320px; overflow-y: auto; overflow-x: hidden;">
                                    </div>
                                </div>
                            </div>
                            <span id="plannerCountryStatus" class="text-[10px] font-semibold shrink-0 whitespace-nowrap"
                                style="color: #EF4444">필수</span>
                        </div>

                        <div class="relative overflow-visible min-w-0 h-[50px] rounded-xl border bg-white flex items-center gap-3 px-3.5"
                            style="border-color: #E2E5EF">
                            <div class="w-8 h-8 rounded-lg shrink-0 flex items-center justify-center"
                                style="background: #F0EFFF; color: #6369D1">
                                <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                    stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                    <path d="M20 10c0 5-8 12-8 12S4 15 4 10a8 8 0 1 1 16 0Z" />
                                    <circle cx="12" cy="10" r="2.5" />
                                </svg>
                            </div>
                            <div class="min-w-0 flex-1 flex flex-col justify-center">
                                <span class="text-[10px] font-semibold text-gray-400 leading-none mb-1">지역 (선택)</span>
                                <div id="plannerRegionCombo" class="w-full min-w-0">
                                    <div class="flex items-center gap-1.5 w-full min-w-0">
                                        <input class="outline-none text-sm text-gray-800 bg-transparent placeholder-gray-400 w-full min-w-0"
                                            id="plannerRegion" placeholder="국가 먼저 입력" value="" autocomplete="off" disabled>
                                        <button type="button" id="plannerRegionClear"
                                            class="hidden shrink-0 text-gray-300 hover:text-gray-500"
                                            aria-label="지역 입력 지우기">
                                            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                                stroke-width="2" stroke-linecap="round">
                                                <path d="M18 6 6 18M6 6l12 12"/>
                                            </svg>
                                        </button>
                                    </div>
                                    <div id="plannerRegionDropdown"
                                        class="hidden absolute top-full left-0 right-0 mt-1 bg-white border border-gray-200 rounded-xl shadow-xl z-50"
                                        style="max-height: 280px; overflow-y: auto; overflow-x: hidden;">
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="relative min-w-0 h-[50px] rounded-xl border bg-white flex items-center gap-3 px-3.5"
                            style="border-color: #E2E5EF">
                            <div class="w-8 h-8 rounded-lg shrink-0 flex items-center justify-center"
                                style="background: #F0EFFF; color: #6369D1">
                                <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                    stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                    <path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2" />
                                    <circle cx="9" cy="7" r="4" />
                                    <path d="M22 21v-2a4 4 0 0 0-3-3.87" />
                                    <path d="M16 3.13a4 4 0 0 1 0 7.75" />
                                </svg>
                            </div>
                            <div class="min-w-0 flex-1 flex flex-col justify-center">
                                <span class="text-[10px] font-semibold text-gray-400 leading-none mb-1">여행 인원</span>
                                <div class="flex items-center gap-1 min-w-0">
                                    <input
                                        id="plannerTravelerCount"
                                        type="number"
                                        min="1"
                                        max="99"
                                        step="1"
                                        value="1"
                                        inputmode="numeric"
                                        class="outline-none text-sm text-gray-800 bg-transparent w-full min-w-0 border-none"
                                        aria-label="여행 인원수">
                                    <span class="text-xs text-gray-500 shrink-0">명</span>
                                </div>
                            </div>
                        </div>

                        <div class="relative min-w-0 h-[50px] rounded-xl border bg-white flex items-center gap-3 px-3.5"
                            style="border-color: #E2E5EF">
                            <div class="w-8 h-8 rounded-lg shrink-0 flex items-center justify-center"
                                style="background: #F0EFFF; color: #6369D1">
                                <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                    stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                    <rect width="18" height="18" x="3" y="4" rx="2" />
                                    <path d="M16 2v4M8 2v4M3 10h18" />
                                </svg>
                            </div>
                            <div class="min-w-0 flex-1 flex flex-col justify-center">
                                <span class="text-[10px] font-semibold text-gray-400 leading-none mb-1">여행 기간</span>
                                <div class="planner-date-row min-w-0">
                                    <input id="plannerStartDate" type="date" class="text-xs text-gray-700 rounded-md px-1 py-0.5 outline-none cursor-pointer border-0 bg-transparent focus:bg-gray-50 min-w-0"
                                        style="color-scheme: light; width: 132px">
                                    <svg width="14" height="10" viewBox="0 0 14 10" fill="none" class="shrink-0 text-gray-400">
                                        <path d="M1 5h12M9 1l4 4-4 4" stroke="currentColor" stroke-width="1.5"
                                            stroke-linecap="round" stroke-linejoin="round" />
                                    </svg>
                                    <input id="plannerEndDate" type="date" class="text-xs text-gray-700 rounded-md px-1 py-0.5 outline-none cursor-pointer border-0 bg-transparent focus:bg-gray-50 min-w-0"
                                        style="color-scheme: light; width: 132px">
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="planner-top-actions border-l border-gray-100 px-6 py-3 flex flex-col items-end justify-center gap-3"
                    style="border-color: #E8E9F2">
                    <div class="flex items-center justify-end gap-2">
                        <button id="plannerSaveBtn" type="button" class="h-10 w-[200px] text-xs font-bold text-white rounded-xl hover:opacity-90 transition-all flex items-center justify-center gap-1.5 shadow-sm"
                            style="background: #6369D1">
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2Z" />
                                <polyline points="17 21 17 13 7 13 7 21" />
                                <polyline points="7 3 7 8 15 8" />
                            </svg>
                            <span id="plannerSaveLabel">저장하기</span>
                        </button>

                        <form id="plannerSubmitForm" method="post" enctype="multipart/form-data" class="hidden">
                            <input type="hidden" id="plannerItineraryJson" name="itineraryJson">
                            <input type="hidden" id="plannerThumbnailImageKey" name="thumbnailImageKey">
                        </form>
                    </div>

                    <button id="plannerVisibility"
                        type="button"
                        data-visibility="PUBLIC"
                        class="h-10 w-[200px] flex items-center justify-center gap-2 text-xs font-semibold rounded-full border bg-white transition-all"
                        style="border-color: #8B91FF; color: #555CD6">
                        <span class="w-1.5 h-1.5 rounded-full bg-emerald-400 shrink-0"></span>
                        공개 중
                        <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                            stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="m6 9 6 6 6-6" />
                        </svg>
                    </button>
                </div>
            </div>
        </div>

        <div class="planner-workspace flex flex-1 min-h-0">
            <div class="planner-left-shell relative flex shrink-0">
                <div id="plannerLeftPanel"
                    class="flex flex-col bg-gray-50 border-r border-gray-100 overflow-hidden transition-all duration-300 ease-in-out"
                    style="width: 340px">
                    <div class="w-[340px] flex flex-col h-full">
                        <div class="px-4 py-3 bg-white border-b border-gray-100 shrink-0">
                            <div class="flex items-center justify-between mb-2">
                                <h2 class="font-bold text-sm text-gray-800">📋 일정 가져오기</h2>
                                <span id="plannerPlanCount" class="text-[10px] text-gray-400">2개</span>
                            </div>
                            <div class="relative">
                                <svg class="absolute left-2.5 top-1/2 -translate-y-1/2 text-gray-400" width="13"
                                    height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                    stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                    <circle cx="11" cy="11" r="8" />
                                    <path d="m21 21-4.3-4.3" />
                                </svg>
                                <input id="plannerPlanSearch" type="text" placeholder="지역, 내용 검색..."
                                    class="w-full pl-8 pr-7 py-2 text-xs bg-gray-50 border border-gray-200 rounded-lg outline-none focus:border-purple-300 focus:bg-white transition-all">
                            </div>
                            <div class="mt-2 text-[10px] font-semibold" style="color:#6369D1">카드를 원하는 Day로 드래그해 가져올 수 있습니다.</div>
                            <div class="mt-2 flex gap-2 text-[10px] text-gray-400 flex-wrap">
                                <span>전체</span>
                                <span>·</span>
                                <span>D# = 1일</span>
                                <span>·</span>
                                <span>항목 = 단일</span>
                            </div>
                        </div>

                        <div id="plannerSavedPlansList" class="flex-1 overflow-y-auto p-3 flex flex-col gap-2"></div>
                    </div>
                </div>

                <button id="plannerPanelToggle" title="일정 가져오기 숨기기"
                    class="absolute right-0 top-1/2 -translate-y-1/2 translate-x-full z-20 flex flex-col items-center justify-center gap-1 shadow-md border border-gray-200 bg-white hover:bg-purple-50 transition-all"
                    style="width: 18px; height: 56px; border-radius: 0 8px 8px 0; border-left: none">
                    <svg id="plannerPanelToggleIcon" class="text-gray-400" width="13" height="13" viewBox="0 0 24 24"
                        fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"
                        stroke-linejoin="round">
                        <path d="m15 18-6-6 6-6" />
                    </svg>
                </button>
            </div>

            <div id="plannerCenterPanel" class="flex-1 flex flex-col min-w-0 bg-white">
                <div class="px-5 py-2.5 border-b border-gray-100 flex items-center shrink-0">
                    <div class="flex items-center gap-2 rounded-lg px-3 py-1.5 border"
                        style="background: #FFFBEB; border-color: #F5D98B">
                        <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#B8960C"
                            stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M20 7V5a2 2 0 0 0-2-2H5a3 3 0 0 0 0 6h15v12H5a3 3 0 0 1-3-3V6" />
                            <path d="M16 13h4" />
                        </svg>
                        <span class="text-xs font-semibold" style="color: #92720A">총 예상 예산</span>
                        <span id="plannerTotalBudget" class="text-sm font-black" style="color: #78590A">0원</span>
                        <span id="plannerTotalBudgetForeign" class="text-xs font-semibold text-gray-400">—</span>
                    </div>
                    <button id="plannerToggleAllDays" type="button" title="모두 닫기" class="ml-auto flex items-center justify-center text-gray-500 hover:text-gray-700 w-8 h-8 rounded-lg border border-gray-200 hover:border-gray-300 transition-all">⇅</button>
                </div>


                <!--
                    DAY 0개로 시작하더라도 새 블록을 생성할 수 있도록 DOM과 분리된 원본 템플릿을 유지한다.
                    화면에는 렌더링되지 않으며 일정 가져오기/직접 블록 추가가 이 템플릿을 복제한다.
                -->
                <template id="plannerBlockTemplate">
                    <div class="planner-block-card p-3" data-item-type="sightseeing">
                                                    <div class="planner-block-header flex items-center justify-between px-2 pb-3" draggable="true">
                                                        <div class="flex items-center gap-2">
                                                            <span class="planner-block-type-badge text-[10px] font-bold rounded-full px-2 py-1"
                                                                style="background: #FFF1E8; color: #F97316">관광</span>
                                                            <span class="planner-block-title-label font-bold text-sm text-gray-800">새 일정</span>
                                                        </div>
                                                        <div class="flex items-center gap-2 text-gray-400 text-xs">
                                                            <button type="button" class="planner-block-toggle hover:text-gray-600" data-block-toggle aria-expanded="true" title="블록 접기">˄</button>
                                                            <button type="button" class="planner-block-delete hover:text-red-500" title="일정 삭제" aria-label="일정 삭제">
                                                                <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                                                    <polyline points="3 6 5 6 21 6" />
                                                                    <path d="M19 6l-1 14H6L5 6m3 0V4h8v2M10 11v6M14 11v6" />
                                                                </svg>
                                                            </button>
                                                        </div>
                                                    </div>

                                                    <div class="planner-block-body" data-block-body>
                                                        <div class="planner-block-type-row">
                                                            <button type="button" data-item-type="sightseeing" class="planner-type-btn px-3 py-1 rounded-lg text-xs font-semibold" style="background:#FDF2F8;color:#EC4899">관광</button>
                                                            <button type="button" data-item-type="meal" class="planner-type-btn px-3 py-1 rounded-lg text-xs font-semibold" style="background:#FFF7ED;color:#F97316">식사</button>
                                                            <button type="button" data-item-type="accommodation" class="planner-type-btn px-3 py-1 rounded-lg text-xs font-semibold" style="background:#ECFDF5;color:#10B981">숙소</button>
                                                            <button type="button" data-item-type="transport" class="planner-type-btn px-3 py-1 rounded-lg text-xs font-semibold" style="background:#EFF6FF;color:#3B82F6">교통</button>
                                                        </div>

                                                        <div class="planner-block-grid">
                                                            <div class="planner-form-column">
                                                                <input class="planner-item-title planner-field rounded-lg border border-gray-200 px-3 text-sm font-semibold text-gray-800 outline-none" value="" placeholder="장소 / 일정 이름 *">

                                                                <div class="planner-time-grid planner-field">
                                                                    <div class="planner-time-box">
                                                                        <label>시작</label>
                                                                        <input class="planner-start-time" type="time" value="" readonly aria-label="시작 시간">
                                                                        <button type="button" class="planner-time-trigger" data-time-trigger aria-label="시작 시간 선택" title="시작 시간 선택">
                                                                            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                                                                                <circle cx="12" cy="12" r="9"></circle><path d="M12 7v5l3 2"></path>
                                                                            </svg>
                                                                        </button>
                                                                    </div>
                                                                    <div class="planner-time-box">
                                                                        <label>종료</label>
                                                                        <input class="planner-end-time" type="time" value="" readonly aria-label="종료 시간">
                                                                        <button type="button" class="planner-time-trigger" data-time-trigger aria-label="종료 시간 선택" title="종료 시간 선택">
                                                                            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                                                                                <circle cx="12" cy="12" r="9"></circle><path d="M12 7v5l3 2"></path>
                                                                            </svg>
                                                                        </button>
                                                                    </div>
                                                                </div>

                                                                <div class="planner-field planner-cost-field rounded-lg border border-gray-200 flex items-center px-3 bg-white">
                                                                    <button type="button" class="planner-cost-mode-btn" data-cost-type="PER_PERSON">1인당 요금</button>
                                                                    <input class="planner-item-cost w-24 min-w-0 outline-none bg-transparent text-sm font-semibold text-gray-800" value="" inputmode="numeric">
                                                                    <span class="planner-cost-unit text-xs font-semibold">원</span>
                                                                    <span class="planner-foreign-cost ml-auto text-xs font-semibold">—</span>
                                                                </div>

                                                                <div class="planner-field planner-place-field rounded-lg border border-gray-200 flex items-center gap-2 px-3 bg-white">
                                                                    <svg class="planner-place-pin-icon"
                                                                        width="14" height="14" viewBox="0 0 24 24"
                                                                        fill="none" stroke="#9CA3AF" stroke-width="2"
                                                                        stroke-linecap="round" stroke-linejoin="round">
                                                                        <path class="planner-place-pin-body"
                                                                            d="M20 10c0 5-8 12-8 12S4 15 4 10a8 8 0 1 1 16 0Z" />
                                                                        <circle class="planner-place-pin-dot"
                                                                            cx="12" cy="10" r="2.5" />
                                                                    </svg>

                                                                    <div class="planner-place-search-wrap">
                                                                        <input type="text"
                                                                            class="planner-place-search"
                                                                            value=""
                                                                            placeholder="구글 지도에서 장소 검색"
                                                                            autocomplete="off"
                                                                            data-google-place-id=""
                                                                            data-place-name=""
                                                                            data-place-address=""
                                                                            data-lat=""
                                                                            data-lng="">
                                                                        <div class="planner-place-results" role="listbox"></div>
                                                                    </div>
                                                                </div>

                                                                <div class="planner-memo-field rounded-lg border border-gray-200 bg-white">
                                                                    <textarea class="planner-item-note outline-none text-sm text-gray-700 placeholder-gray-400 bg-transparent" maxlength="200" placeholder="메모 (선택)"></textarea>
                                                                    <span class="planner-memo-count" aria-live="polite">0/200</span>
                                                                </div>
                                                            </div>

                                                            <div>
                                                                <div class="planner-photo-layout" data-photo-gallery>
                                                                <div class="planner-photo-preview">
                                                                    <img class="planner-photo-preview-img" alt="" style="display:none;">
                                                                    <div class="planner-photo-empty">
                                                                        <span>미리보기</span>
                                                                    </div>
                                                                </div>

                                                                <div class="planner-photo-thumbs">
                                                                    <button type="button" class="planner-photo-thumb is-empty" draggable="true"
                                                                        data-src="" data-index="0">
                                                                        <span class="planner-photo-plus">+</span>
                                                                        <span class="planner-photo-hover-label">이미지 등록하기</span>
                                                                        <span class="planner-photo-delete" role="button" tabindex="0" aria-label="이미지 삭제">
                                                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                                                                stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                                                                <polyline points="3 6 5 6 21 6"></polyline>
                                                                                <path d="M19 6l-1 14H6L5 6"></path>
                                                                                <path d="M10 11v6"></path>
                                                                                <path d="M14 11v6"></path>
                                                                                <path d="M9 6V4h6v2"></path>
                                                                            </svg>
                                                                        </span>
                                                                    </button>

                                                                    <button type="button" class="planner-photo-thumb is-empty" draggable="true"
                                                                        data-src="" data-index="1">
                                                                        <span class="planner-photo-plus">+</span>
                                                                        <span class="planner-photo-hover-label">이미지 등록하기</span>
                                                                        <span class="planner-photo-delete" role="button" tabindex="0" aria-label="이미지 삭제">
                                                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                                                                stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                                                                <polyline points="3 6 5 6 21 6"></polyline>
                                                                                <path d="M19 6l-1 14H6L5 6"></path>
                                                                                <path d="M10 11v6"></path>
                                                                                <path d="M14 11v6"></path>
                                                                                <path d="M9 6V4h6v2"></path>
                                                                            </svg>
                                                                        </span>
                                                                    </button>

                                                                    <button type="button" class="planner-photo-thumb is-empty" draggable="true"
                                                                        data-src="" data-index="2">
                                                                        <span class="planner-photo-plus">+</span>
                                                                        <span class="planner-photo-hover-label">이미지 등록하기</span>
                                                                        <span class="planner-photo-delete" role="button" tabindex="0" aria-label="이미지 삭제">
                                                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                                                                stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                                                                <polyline points="3 6 5 6 21 6"></polyline>
                                                                                <path d="M19 6l-1 14H6L5 6"></path>
                                                                                <path d="M10 11v6"></path>
                                                                                <path d="M14 11v6"></path>
                                                                                <path d="M9 6V4h6v2"></path>
                                                                            </svg>
                                                                        </span>
                                                                    </button>
                                                                </div>

                                                                <input type="file" class="planner-photo-file-input hidden" accept="image/*">
                                                            </div>
                                                                                                        <div class="planner-photo-guide">
                                                                <span>• 썸네일 3장까지 등록 가능</span>
                                                                <span>• 클릭해서 이미지 등록 / 변경</span>
                                                                <span>• 등록 후 왼쪽에서 크게 보기</span>
                                                                <span>• 드래그로 순서 변경</span>
                                                                <span>• 여행 대표 이미지는 저장 단계에서 선택</span>
                                                            </div>
                                                            </div>
                                                        </div>
                                                    </div>

                                                </div>
                </template>

                <div id="plannerDays" class="flex-1 overflow-y-auto px-5 py-4">
                        <button id="plannerAddDay" type="button"
                            class="w-full mt-4 flex items-center justify-center gap-2 py-2.5 rounded-xl border-2 border-dashed border-gray-200 text-xs font-semibold text-gray-400 hover:border-purple-300 hover:text-purple-400 transition-all">
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <path d="M12 5v14M5 12h14" />
                            </svg>
                            Day 1 추가
                        </button>
                    </div>
                </div>

            <div class="planner-map-panel w-[460px] shrink-0 border-l border-gray-100 flex flex-col bg-white">
                <div class="px-4 py-3 border-b border-gray-100 shrink-0">
                    <div class="flex items-center justify-between">
                        <div class="flex items-center gap-2">
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#6369D1"
                                stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <polygon points="3 6 9 3 15 6 21 3 21 18 15 21 9 18 3 21" />
                                <line x1="9" y1="3" x2="9" y2="18" />
                                <line x1="15" y1="6" x2="15" y2="21" />
                            </svg>
                            <h2 class="font-bold text-sm text-gray-800">경로 지도</h2>
                        </div>
                        <div class="relative"><button id="plannerMapFilterBtn" type="button" class="flex items-center gap-2 rounded-xl border px-3 py-1.5 text-xs font-bold shadow-sm hover:shadow-md transition-all"
                            style="border-color: #D1D2F9; color: #6369D1; background: #F5F5FF; min-width: 86px">
                            <span id="plannerMapFilterDot" class="w-2 h-2 rounded-full shrink-0" style="background: #6369D1"></span>
                            <span id="plannerMapFilterLabel" class="flex-1 text-left">전체</span>
                            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <path d="m6 9 6 6 6-6" />
                            </svg>
                        </button>
                            <div id="plannerMapFilterMenu" class="hidden absolute right-0 mt-1.5 w-44 rounded-xl border bg-white shadow-xl z-30 overflow-hidden" style="border-color:#D1D2F9">
                                <button type="button" data-map-day="all" class="w-full text-left px-3 py-2 text-xs font-bold hover:bg-purple-50" style="color:#6369D1">전체</button>
                                <button type="button" data-map-day="1" class="w-full text-left px-3 py-2 text-xs font-bold hover:bg-purple-50 text-gray-600">1일차</button>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="flex-1 flex flex-col min-h-0 relative">
                    <div id="plannerGoogleMap" class="flex-1 w-full" style="min-height: 360px; position:relative"></div>
                    <div id="plannerMapAllLegendOverlay" class="hidden absolute left-3 top-3 z-20 rounded-2xl px-3 py-2 text-xs text-white shadow-xl pointer-events-none"
                        style="background:rgba(17,24,39,.68); backdrop-filter:blur(6px); min-width:120px"></div>
                </div>
            </div>
        </div>
    </main>

    <jsp:include page="/common/footer.jsp" />

    <script>
        window.PLANNER_BOOTSTRAP = {
            contextPath: '${pageContext.request.contextPath}',
            importItineraries: ${empty importListJson ? '[]' : importListJson},
            editItinerary: ${empty editItineraryJson ? 'null' : editItineraryJson},
            editStartDate: '${empty editItinerary.startDate ? "" : editItinerary.startDate}',
            editEndDate: '${empty editItinerary.endDate ? "" : editItinerary.endDate}',
            exchangeRates: ${empty exchangeRatesJson ? '{}' : exchangeRatesJson}
        };
    </script>
    <script src="${pageContext.request.contextPath}/view/assets/js/itinerary/planeditor.js?v=20261015-iso-admin1"></script>
    <script async
        onerror="showPlannerMapFallback()" src="https://maps.googleapis.com/maps/api/js?key=AIzaSyB7ioaQS08aAzCl7gZPk6SyE1w7EeIrYhI&language=ko&libraries=places&v=weekly&loading=async&callback=initPlannerMap"></script>


    <div id="plannerPublishBackdrop" class="planner-publish-backdrop" aria-hidden="true">
        <div class="planner-publish-modal" role="dialog" aria-modal="true" aria-labelledby="plannerPublishTitle">

            <div class="planner-publish-head flex items-center justify-between px-6 py-5 border-b" style="border-color:#ECEEF5">
                <div>
                    <h3 id="plannerPublishTitle" class="text-lg font-black text-gray-900">여행 일정 미리보기</h3>
                    <p class="mt-1 text-xs text-gray-500">여행일정 목록에 표시될 카드입니다. 대표 사진과 일정 소개는 선택사항입니다.</p>
                </div>
                <button type="button" id="plannerPublishClose"
                    class="w-9 h-9 rounded-full hover:bg-gray-100 text-gray-500 text-xl">×</button>
            </div>

            <div class="planner-publish-body">
                <div class="planner-publish-grid">

                    <div class="planner-publish-column">
                        <p class="mb-2 text-xs font-bold text-gray-700">게시물 카드 미리보기</p>

                        <article class="planner-publish-card">
                            <button type="button" id="plannerPublishCover"
                                class="planner-publish-cover block w-full text-left">

                                <img id="plannerPublishCoverImg" alt="대표 이미지 미리보기">

                                <span class="planner-publish-cover-empty">
                                    <span class="text-2xl">＋</span>
                                    <span>배경 이미지 고르기</span>
                                </span>

                                <span class="planner-publish-cover-change">대표 이미지 변경하기</span>

                                <span id="plannerPublishCountryBadge"
                                    class="absolute top-2.5 left-2.5 text-[10px] font-bold px-2 py-0.5 rounded-full text-white"
                                    style="background:#6369D1"></span>

                                <span class="planner-publish-bookmark" aria-hidden="true">
                                    <svg width="13" height="13" viewBox="0 0 24 24"
                                        fill="none" stroke="#9CA3AF" stroke-width="2">
                                        <path stroke-linecap="round" stroke-linejoin="round"
                                            d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z"/>
                                    </svg>
                                </span>
                            </button>

                            <div class="planner-publish-card-body">
                                <h4 id="plannerPublishCardTitle"
                                    class="planner-publish-card-title"></h4>

                                <p id="plannerPublishCardSummary"
                                    class="planner-publish-card-summary">일정 소개를 입력해 주세요.</p>

                                <p id="plannerPublishCardDates"
                                    class="planner-publish-card-dates"></p>

                                <div class="planner-publish-card-stats" aria-label="미리보기 통계">
                                    <span>좋아요 0</span>
                                    <span>댓글 0</span>
                                    <span>조회 0</span>
                                </div>

                                <div class="planner-publish-card-footer">
                                    <span id="plannerPublishCardAuthor"
                                        class="planner-publish-card-author"><c:out value="${sessionScope.user.nickName}" default="작성자"/></span>

                                    <span id="plannerPublishCardCreated"
                                        class="planner-publish-card-created"></span>
                                </div>
                            </div>
                        </article>
                    </div>

                    <div id="plannerPublishControls" class="planner-publish-column planner-publish-controls">

                        <div class="mb-5">
                            <div class="flex items-center justify-between mb-2 gap-3">
                                <label class="text-xs font-bold text-gray-700">대표 이미지 <span id="plannerPublishPhotoRequirement" class="font-normal text-gray-400">(필수)</span></label>
                                <span id="plannerPublishPhotoHint" class="text-[10px] text-gray-400">등록 사진 우선 · 공개는 Google Places 사진, 비공개는 국기 사용</span>
                            </div>

                            <div id="plannerPublishPhotoList"
                                class="planner-publish-photo-list"></div>

                            <p id="plannerPublishPhotoEmpty"
                                class="hidden py-8 px-3 text-center text-xs text-gray-400 rounded-xl bg-gray-50">
                                대표 이미지 후보를 확인해 주세요.
                            </p>

                            <p id="plannerPublishPhotoError" class="planner-publish-error">
                                대표 이미지를 선택해야 저장할 수 있습니다.
                            </p>

                        </div>

                        <div id="plannerPublishSummarySection" style="display:block; visibility:visible;">
                            <div class="flex items-center justify-between mb-2">
                                <label for="plannerPublishSummary"
                                    class="text-xs font-bold text-gray-700">일정 소개 <span class="font-normal text-gray-400">(선택)</span></label>

                                <span id="plannerPublishSummaryCount"
                                    class="text-[10px] text-gray-400">0/250</span>
                            </div>

                            <textarea id="plannerPublishSummary"
                                maxlength="250"
                                class="planner-publish-summary"
                                placeholder="이 여행 일정의 특징이나 추천 포인트를 작성해 주세요."></textarea>

                            
                        </div>

                    </div>

                </div>
            </div>

            <div class="planner-publish-footer flex justify-end gap-2 px-6 py-4 border-t"
                style="border-color:#ECEEF5">
                <button type="button" id="plannerPublishCancel"
                    class="h-10 px-5 rounded-xl text-sm font-bold text-gray-600 bg-gray-100 hover:bg-gray-200">
                    취소
                </button>

                <button type="button" id="plannerPublishConfirm"
                    class="h-10 px-6 rounded-xl text-sm font-bold text-white hover:opacity-90"
                    style="background:#6369D1">
                    최종 저장
                </button>
            </div>

        </div>
    </div>

    <div id="plannerRequiredBackdrop" class="planner-required-backdrop" aria-hidden="true">
        <div class="planner-required-modal" role="dialog" aria-modal="true" aria-labelledby="plannerRequiredTitle">
            <div class="flex items-center gap-3">
                <div class="planner-required-icon">!</div>
                <div>
                    <h3 id="plannerRequiredTitle" class="text-base font-bold text-gray-800">필수 항목을 확인해 주세요</h3>
                    <p class="mt-1 text-xs text-gray-500">저장하기 전에 아래 항목을 입력하거나 수정해야 합니다.</p>
                </div>
            </div>
            <ul id="plannerRequiredList" class="planner-required-list"></ul>
            <button type="button" id="plannerRequiredClose"
                class="mt-5 w-full h-10 rounded-xl text-sm font-bold text-white"
                style="background:#6369D1">확인</button>
        </div>
    </div>

    <div id="plannerConfirmBackdrop" class="planner-confirm-backdrop" aria-hidden="true">
        <div class="planner-confirm-modal" role="dialog" aria-modal="true" aria-labelledby="plannerConfirmTitle">
            <div class="planner-confirm-content">
                <div class="planner-confirm-head">
                    <div class="planner-confirm-icon" aria-hidden="true">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
                            stroke-linecap="round" stroke-linejoin="round">
                            <polyline points="3 6 5 6 21 6"></polyline>
                            <path d="M19 6l-1 14H6L5 6"></path>
                            <path d="M8 6V4h8v2"></path>
                            <path d="M10 11v6M14 11v6"></path>
                        </svg>
                    </div>
                    <h3 id="plannerConfirmTitle" class="planner-confirm-title">삭제</h3>
                </div>
                <div class="planner-confirm-body">
                    <p id="plannerConfirmMessage" class="planner-confirm-message">삭제할까요?</p>
                    <div id="plannerConfirmList" class="planner-confirm-list"></div>
                    <p id="plannerConfirmWarning" class="planner-confirm-warning">삭제 후 되돌릴 수 없습니다.</p>
                </div>
            </div>
            <div class="planner-confirm-actions">
                <button type="button" id="plannerConfirmCancel" class="planner-confirm-btn planner-confirm-cancel">취소</button>
                <button type="button" id="plannerConfirmDelete" class="planner-confirm-btn planner-confirm-delete">삭제</button>
            </div>
        </div>
    </div>

</body>
</html>
