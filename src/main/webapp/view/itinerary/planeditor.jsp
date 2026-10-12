<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
request.setAttribute("activePage", "planner");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>일정 만들기 | Tripily</title>
<jsp:include page="/common/headStyles.jsp" />
<style>
    .planner-photo-layout {
        display: grid;
        grid-template-columns: minmax(0, 1fr) 96px;
        gap: 12px;
        height: 310px;
        min-height: 310px;
    }

    .planner-photo-preview {
        position: relative;
        border: 2px solid #D7E600;
        border-radius: 12px;
        overflow: hidden;
        background: #E5E7EB;
        min-height: 310px;
    }

    .planner-photo-preview img {
        width: 100%;
        height: 100%;
        object-fit: cover;
        display: block;
    }

    .planner-photo-empty {
        position: absolute;
        inset: 0;
        display: flex;
        flex-direction: column;
        gap: 8px;
        align-items: center;
        justify-content: center;
        color: #9CA3AF;
        font-size: 12px;
        font-weight: 600;
        letter-spacing: -0.02em;
    }


    .planner-photo-thumbs {
        display: grid;
        grid-template-rows: repeat(3, 1fr);
        gap: 12px;
        min-height: 270px;
    }

    .planner-photo-thumb {
        position: relative;
        border: 2px solid #D1D5DB;
        border-radius: 12px;
        overflow: hidden;
        background: #E5E7EB;
        min-height: 82px;
        cursor: pointer;
        transition: transform .18s ease, box-shadow .18s ease, border-color .18s ease, background .18s ease;
    }

    .planner-photo-thumb:hover {
        transform: translateY(-1px);
        box-shadow: 0 8px 18px rgba(99, 105, 209, 0.14);
    }

    .planner-photo-thumb::after {
        content: "";
        position: absolute;
        inset: 0;
        background: rgba(17, 24, 39, 0.42);
        opacity: 0;
        transition: opacity .16s ease;
        z-index: 2;
        pointer-events: none;
    }

    .planner-photo-thumb:hover::after {
        opacity: 1;
    }

    .planner-photo-plus {
        position: absolute;
        left: 50%;
        top: 50%;
        transform: translate(-50%, -50%);
        color: #9CA3AF;
        font-size: 30px;
        font-weight: 300;
        line-height: 1;
        z-index: 1;
        pointer-events: none;
    }

    .planner-photo-thumb.has-image .planner-photo-plus {
        display: none;
    }

    .planner-photo-hover-label {
        position: absolute;
        left: 50%;
        top: 50%;
        transform: translate(-50%, -50%);
        color: #FFFFFF;
        font-size: 11px;
        font-weight: 700;
        white-space: nowrap;
        opacity: 0;
        transition: opacity .16s ease;
        z-index: 3;
        pointer-events: none;
    }

    .planner-photo-thumb:hover .planner-photo-hover-label {
        opacity: 1;
    }

    .planner-photo-delete {
        position: absolute;
        right: 6px;
        bottom: 6px;
        width: 24px;
        height: 24px;
        border-radius: 999px;
        background: rgba(255, 255, 255, 0.96);
        color: #6B7280;
        display: flex;
        align-items: center;
        justify-content: center;
        opacity: 0;
        visibility: hidden;
        transform: translateY(2px);
        transition: opacity .16s ease, transform .16s ease, background .16s ease, color .16s ease;
        z-index: 10;
        cursor: pointer;
        padding: 0;
        box-shadow: 0 1px 4px rgba(0,0,0,.18);
    }

    .planner-photo-thumb.has-image:hover .planner-photo-delete {
        opacity: 1;
        visibility: visible;
        transform: translateY(0);
    }

    .planner-photo-delete:hover {
        background: #FFFFFF;
        color: #DC2626;
    }

    .planner-photo-delete svg {
        width: 13px;
        height: 13px;
        pointer-events: none;
    }

    .planner-photo-thumb.dragging {
        opacity: 0.5;
        cursor: grabbing;
    }

    .planner-photo-thumb.drag-over {
        border-color: #6369D1;
        box-shadow: 0 0 0 3px rgba(99, 105, 209, 0.12);
    }

    .planner-photo-thumb.active {
        border-color: #6369D1;
        box-shadow: 0 0 0 3px rgba(99, 105, 209, 0.12);
    }

    .planner-photo-thumb img {
        position: absolute;
        inset: 0;
        width: 100%;
        height: 100%;
        object-fit: cover;
        display: block;
        z-index: 1;
    }

    .planner-photo-badge {
        position: absolute;
        right: 8px;
        top: 8px;
        padding: 2px 7px;
        border-radius: 999px;
        background: #EF4444;
        color: #fff;
        font-size: 10px;
        font-weight: 700;
        line-height: 1.2;
        z-index: 4;
    }

    .planner-photo-guide {
        margin-top: 10px;
        font-size: 11px;
        color: #6B7280;
        display: flex;
        gap: 10px;
        flex-wrap: wrap;
    }

    .planner-time-grid {
        display: grid;
        grid-template-columns: repeat(2, minmax(0, 1fr));
        gap: 10px;
    }

    .planner-time-box {
        height: 42px;
        border: 1px solid #E5E7EB;
        border-radius: 10px;
        background: #fff;
        display: flex;
        align-items: center;
        padding: 0 12px;
        gap: 8px;
    }

    .planner-time-box label {
        font-size: 11px;
        font-weight: 700;
        color: #6B7280;
        white-space: nowrap;
    }

    .planner-time-box input {
        flex: 1;
        min-width: 0;
        border: none;
        outline: none;
        background: transparent;
        font-size: 13px;
        color: #111827;
    }

    .planner-block-type-row {
        display: flex;
        flex-wrap: wrap;
        gap: 8px;
        margin-top: 12px;
        margin-bottom: 10px;
    }

    .planner-form-column {
        height: 310px;
        display: flex;
        flex-direction: column;
        gap: 10px;
    }

    .planner-field {
        height: 42px;
        min-height: 42px;
    }


    .planner-cost-field {
        width: min(100%, 340px);
        margin-right: auto;
        justify-content: flex-start;
        gap: 10px;
        position: relative;
        overflow: visible;
    }

    .planner-cost-field::after {
        content: '요금 기준은 버튼을 눌러 변경 가능.';
        position: absolute;
        left: calc(100% + 12px);
        top: 50%;
        transform: translateY(-50%);
        color: #9CA3AF;
        font-size: 11px;
        font-weight: 500;
        line-height: 1.3;
        white-space: nowrap;
        pointer-events: none;
    }

    @media (max-width: 1650px) {
        .planner-cost-field::after {
            content: '눌러서 요금 기준 변경';
        }
    }

    @media (max-width: 1400px) {
        .planner-cost-field::after {
            display: none;
        }
    }

    .planner-cost-mode-btn {
        flex: 0 0 auto;
        min-width: 88px;
        height: 30px;
        padding: 0 12px;
        border: none;
        border-radius: 10px;
        background: #6369D1;
        color: #FFFFFF;
        font-size: 12px;
        font-weight: 700;
        line-height: 1;
        cursor: pointer;
    }

    .planner-cost-mode-btn {
        transition: background-color .15s ease, box-shadow .15s ease, transform .15s ease;
    }

    .planner-cost-mode-btn:hover {
        background: #555AC4;
        box-shadow: 0 2px 8px rgba(99, 105, 209, .22);
    }

    .planner-day-header {
        transition: filter .15s ease, box-shadow .15s ease;
    }

    .planner-day-header:hover {
        filter: brightness(.92);
        box-shadow: 0 3px 10px rgba(79, 70, 229, .12);
    }

    .planner-item-cost {
        text-align: right;
    }

    .planner-cost-unit {
        color: #111827;
    }

    .planner-foreign-cost {
        color: #9CA3AF;
        white-space: nowrap;
    }

    .planner-memo-field {
        flex: 1 1 auto;
        min-height: 72px;
        display: flex;
        padding: 10px 12px;
    }

    .planner-memo-field textarea {
        width: 100%;
        height: 100%;
        min-height: 0;
        resize: vertical;
    }

    .planner-block-body.is-collapsed {
        display: none;
    }

    .planner-block-toggle {
        width: 26px;
        height: 26px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        border-radius: 7px;
    }

    .planner-block-grid {
        display: grid;
        grid-template-columns: minmax(0, 1.05fr) minmax(340px, .95fr);
        gap: 16px;
    }

    .planner-block-card {
        border: 2px solid #E5E7EB;
        border-radius: 16px;
        background: #fff;
        box-shadow: 0 8px 24px rgba(99, 105, 209, 0.08);
    }

    .planner-block-summary {
        border: 1px solid #E5E7EB;
        border-radius: 14px;
        background: #fff;
        padding: 14px 16px;
    }


    .planner-day-body.is-collapsed, .planner-block-body.is-collapsed { display:none; }
    .planner-type-btn { border:1px solid transparent; opacity:.62; transition:.15s ease; }
    .planner-type-btn.is-selected { opacity:1; box-shadow:0 0 0 2px rgba(99,105,209,.08); }
    .planner-saved-plan.is-hidden { display:none; }
    .planner-save-message { position:fixed; right:24px; bottom:24px; z-index:9999; background:#111827; color:#fff; padding:10px 14px; border-radius:10px; font-size:12px; font-weight:700; box-shadow:0 10px 30px rgba(0,0,0,.18); }

    @media (max-width: 1400px) {
        .planner-block-grid {
            grid-template-columns: 1fr;
        }

        .planner-photo-layout {
            grid-template-columns: minmax(0, 1fr) 88px;
        }
    }

    .planner-day-body {
        padding: 12px;
        border: 1px solid #E5E7EB;
        border-radius: 12px;
        background: #FFFFFF;
        overflow: hidden;
    }

    .planner-add-block-btn {
        width: calc(100% + 24px);
        min-height: 42px;
        margin: 0 -12px -12px;
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 6px;
        padding: 10px 12px;
        border: 0;
        border-top: 1px solid #E5E7EB;
        border-radius: 0 0 11px 11px;
        background: #FAFAFC;
        color: #6369D1;
        font-size: 12px;
        font-weight: 700;
        transition: background .16s ease, color .16s ease;
    }
    .planner-add-block-btn:hover { color:#555CD6; background:#F3F3FB; }
    .planner-day-body.is-drop-target { border-radius: 14px; outline: 2px dashed #8B91FF; outline-offset: 4px; background: #F8F8FF; }
    .planner-saved-plan-head[draggable="true"] { cursor: grab; }
    .planner-saved-plan-head[draggable="true"]:active { cursor: grabbing; }
    .planner-saved-day { border: 1px solid #E5E7EB; border-radius: 10px; margin: 6px 8px; background: #fff; }
    .planner-saved-item { border-color: #E5E7EB !important; background: #fff; }
    .planner-day-title { cursor: text; border-radius: 7px; padding: 2px 5px; margin-left: -5px; display:inline-flex; width:fit-content; max-width:100%; }
    .planner-day-title:hover { background: rgba(255,255,255,.14); }
    .planner-day-edit-icon { display:inline-flex; align-items:center; justify-content:center; width:18px; height:18px; margin-left:2px; transform:translateY(3px); border:0; border-radius:5px; background:transparent; color:rgba(255,255,255,.42); cursor:pointer; transition:color .15s ease, background .15s ease; vertical-align:middle; }
    .planner-day-edit-icon:hover { color:rgba(255,255,255,.9); background:rgba(255,255,255,.12); }
    .planner-day-edit-icon svg { width:11px; height:11px; pointer-events:none; }
    .planner-day-title-input { width: 120px; min-width: 72px; max-width: 420px; height: 28px; padding: 0 8px; border: 1px solid rgba(255,255,255,.55); border-radius: 7px; outline: none; background: rgba(255,255,255,.16); color: #fff; font-size: 14px; font-weight: 700; }
    .planner-block-card { transition: background .16s ease, border-color .16s ease, box-shadow .16s ease; }
    .planner-block-card:hover { background:#FAFAFD; }
    .planner-block-header { cursor:pointer; border-bottom:0 !important; transition: background .16s ease; border-radius:10px; }
    .planner-block-header:hover { background:rgba(99,105,209,.035); }
    .planner-block-header button { cursor:pointer; }
    .planner-date-row { width:100%; display:flex; align-items:center; justify-content:center; gap:10px; }
    .planner-date-row input[type="date"] { flex:1 1 0; width:auto !important; min-width:0; text-align:center; }
    .planner-date-row svg { flex:0 0 auto; }
    .planner-date-row input[type="date"]::-webkit-datetime-edit { text-align:center; width:100%; }
    #plannerCenterPanel { transition: opacity .18s ease, filter .18s ease; }
    #plannerCenterPanel.is-country-locked { opacity:.46; filter:grayscale(1) blur(.25px); pointer-events:none; user-select:none; }

    .planner-confirm-backdrop { position:fixed; inset:0; z-index:10000; display:none; align-items:center; justify-content:center; background:rgba(0,0,0,.40); padding:20px; }
    .planner-confirm-backdrop.is-open { display:flex; }
    .planner-confirm-modal { width:min(360px,100%); border:0; border-radius:16px; background:#fff; box-shadow:0 25px 50px -12px rgba(0,0,0,.28); padding:24px; display:flex; flex-direction:column; gap:16px; }
    .planner-confirm-content { display:flex; flex-direction:column; gap:8px; }
    .planner-confirm-head { display:flex; align-items:center; gap:8px; }
    .planner-confirm-icon { width:32px; height:32px; border-radius:999px; display:flex; align-items:center; justify-content:center; flex:0 0 auto; background:#FEE2E2; color:#EF4444; }
    .planner-confirm-icon svg { width:15px; height:15px; }
    .planner-confirm-title { margin:0; color:#1F2937; font-size:16px; font-weight:700; line-height:1.35; }
    .planner-confirm-body { display:flex; flex-direction:column; gap:8px; margin-top:4px; }
    .planner-confirm-message { margin:0; color:#4B5563; font-size:14px; line-height:1.55; }
    .planner-confirm-message strong { color:#1F2937; font-weight:600; }
    .planner-confirm-list { display:none; flex-direction:column; gap:4px; max-height:128px; overflow-y:auto; padding:10px 12px; border:1px solid #FEE2E2; border-radius:12px; background:#FEF2F2; }
    .planner-confirm-list.is-visible { display:flex; }
    .planner-confirm-list-item { display:flex; align-items:center; gap:8px; min-width:0; color:#374151; font-size:12px; line-height:1.4; }
    .planner-confirm-list-dot { width:7px; height:7px; border-radius:999px; flex:0 0 auto; background:#8B5CF6; }
    .planner-confirm-list-name { overflow:hidden; white-space:nowrap; text-overflow:ellipsis; }
    .planner-confirm-list-time { margin-left:auto; color:#9CA3AF; flex:0 0 auto; }
    .planner-confirm-warning { margin:0; color:#EF4444; font-size:12px; font-weight:600; }
    .planner-confirm-actions { display:flex; gap:8px; padding:0; }
    .planner-confirm-btn { flex:1 1 0; height:40px; border-radius:12px; font-size:14px; font-weight:600; border:1px solid #E5E7EB; transition:background .15s ease,border-color .15s ease; }
    .planner-confirm-cancel { background:#fff; color:#4B5563; }
    .planner-confirm-delete { border-color:#EF4444; background:#EF4444; color:#fff; font-weight:700; }
    .planner-confirm-cancel:hover { background:#F9FAFB; }
    .planner-confirm-delete:hover { background:#DC2626; border-color:#DC2626; }

    .planner-required-backdrop { position:fixed; inset:0; z-index:10020; display:none; align-items:center; justify-content:center; background:rgba(0,0,0,.40); padding:20px; }
    .planner-required-backdrop.is-open { display:flex; }
    .planner-required-modal { width:min(380px,100%); border-radius:16px; background:#fff; padding:24px; box-shadow:0 25px 50px -12px rgba(0,0,0,.28); }
    .planner-required-icon { width:34px; height:34px; border-radius:999px; display:flex; align-items:center; justify-content:center; background:#FEF2F2; color:#EF4444; font-weight:800; }
    .planner-required-list { margin:12px 0 0; padding-left:20px; color:#4B5563; font-size:13px; line-height:1.75; list-style:disc; }

    #plannerCountryDropdown button,
    #plannerRegionDropdown button { width:100%; min-height:40px; text-align:left; transition:background .15s ease; }
    #plannerCountryDropdown button:hover,
    #plannerRegionDropdown button:hover { background:#FAF5FF; }
    #plannerCountryDropdown::-webkit-scrollbar,
    #plannerRegionDropdown::-webkit-scrollbar { width:8px; }
    #plannerCountryDropdown::-webkit-scrollbar-track,
    #plannerRegionDropdown::-webkit-scrollbar-track { background:#F9FAFB; }
    #plannerCountryDropdown::-webkit-scrollbar-thumb,
    #plannerRegionDropdown::-webkit-scrollbar-thumb { background:#C7CBD4; border-radius:999px; }
    #plannerCountryDropdown,
    #plannerRegionDropdown { scrollbar-width:thin; scrollbar-color:#C7CBD4 #F9FAFB; }

    .planner-day-header[draggable="true"] { cursor:grab; }
    .planner-day-header[draggable="true"]:active { cursor:grabbing; }
    .planner-structure-grip {
        flex:0 0 auto;
        display:inline-flex;
        align-items:center;
        justify-content:center;
        width:16px;
        height:24px;
        font-size:15px;
        line-height:1;
        letter-spacing:-2px;
        opacity:.58;
        user-select:none;
        pointer-events:none;
    }
    .planner-day-header .planner-structure-grip { color:rgba(255,255,255,.92); }
    .planner-block-header .planner-structure-grip { color:#9CA3AF; }
    .planner-day-header:hover .planner-structure-grip,
    .planner-block-header:hover .planner-structure-grip { opacity:.95; }
    .planner-block-header[draggable="true"] { cursor:grab; }
    .planner-block-header[draggable="true"]:active { cursor:grabbing; }
    .planner-day.is-day-dragging { opacity:.48; }
    .planner-day.is-day-drag-over { outline:2px solid rgba(99,105,209,.35); outline-offset:3px; border-radius:14px; }


    /* 드래그 중에만 나타나는 구조 편집 모드 */
    #plannerDays.planner-structure-drag-mode {
        position: relative;
        padding-top: 12px;
        padding-bottom: 20px;
    }
    #plannerDays.planner-structure-drag-mode .planner-add-day-btn,
    #plannerDays.planner-structure-drag-mode #plannerAddDay { opacity:.28; pointer-events:none; }
    #plannerDays.planner-structure-drag-mode .planner-day {
        margin-bottom: 8px !important;
        transition: opacity .15s ease, transform .15s ease;
    }
    #plannerDays.planner-drag-day-mode .planner-day-body { display:none !important; }
    #plannerDays.planner-drag-day-mode .planner-day-header {
        min-height: 52px;
        box-shadow: 0 1px 0 rgba(17,24,39,.02);
    }
    /*
     * BLOCK 드래그 중에는 모든 DAY를 한꺼번에 펼치지 않는다.
     * 현재 마우스가 올라간 DAY만 본문을 열어 드롭 위치를 보여준다.
     * 기존 is-collapsed 상태 자체는 건드리지 않으므로 드래그 종료 후 원래 상태로 돌아간다.
     */
    #plannerDays.planner-drag-block-mode .planner-day-body,
    #plannerDays.planner-drag-block-mode .planner-day-body.is-collapsed {
        display:none !important;
    }
    #plannerDays.planner-drag-block-mode .planner-day.planner-block-drag-hover > .planner-day-body,
    #plannerDays.planner-drag-block-mode .planner-day.planner-block-drag-hover > .planner-day-body.is-collapsed {
        display:flex !important;
        gap:7px !important;
        min-height:58px;
        padding:10px;
        background:#FCFCFF;
    }
    #plannerDays.planner-drag-block-mode .planner-day.planner-block-drag-hover > .planner-day-header {
        box-shadow:0 0 0 2px rgba(99,105,209,.18);
    }
    #plannerDays.planner-drag-block-mode .planner-block-body { display:none !important; }
    #plannerDays.planner-drag-block-mode .planner-block-card {
        padding:7px 9px !important;
        margin:0 !important;
        border-color:#E6E7F2 !important;
        background:#fff;
        box-shadow:none !important;
    }
    #plannerDays.planner-drag-block-mode .planner-block-header {
        min-height:34px;
        padding:0 2px !important;
        border-radius:8px;
    }
    #plannerDays.planner-drag-block-mode .planner-add-block-btn,
    #plannerDays.planner-drag-block-mode .planner-empty-day-hint { display:none !important; }
    .planner-structure-source { opacity:.38 !important; }
    /* 가져온 DAY/일정이 기본 빈 D1을 대체하는 경우 드래그 미리보기에서도 D1을 숨긴다. */
    .planner-day.planner-import-replaced-starter { display:none !important; }

    .planner-drop-slot {
        position:relative;
        display:flex;
        align-items:center;
        justify-content:center;
        width:100%;
        min-height:18px;
        margin:4px 0;
        border:1px dashed transparent;
        border-radius:12px;
        color:#777CCF;
        transition:min-height .14s ease, background .14s ease, border-color .14s ease, margin .14s ease;
        overflow:hidden;
    }
    .planner-drop-slot::before {
        content:'';
        width:calc(100% - 24px);
        height:2px;
        border-radius:999px;
        background:#D8DAF7;
        transition:height .14s ease, background .14s ease;
    }
    .planner-drop-slot.is-active {
        min-height:72px;
        margin:8px 0;
        border-color:#8B91FF;
        background:rgba(99,105,209,.055);
        box-shadow:inset 0 0 0 1px rgba(99,105,209,.04);
    }
    .planner-drop-slot.is-active::before { display:none; }
    .planner-drop-slot.is-block-slot.is-active { min-height:56px; }
    .planner-drop-preview {
        display:none;
        width:calc(100% - 18px);
        padding:8px 10px;
        border:1px solid rgba(99,105,209,.34);
        border-radius:10px;
        background:rgba(255,255,255,.78);
        color:#4F56BE;
        box-shadow:0 8px 22px rgba(79,86,190,.10);
        pointer-events:none;
    }
    .planner-drop-slot.is-active .planner-drop-preview { display:block; }
    .planner-drop-preview-title {
        display:flex;
        align-items:center;
        gap:7px;
        min-width:0;
        font-size:12px;
        font-weight:800;
    }
    .planner-drop-preview-title span:last-child {
        overflow:hidden;
        text-overflow:ellipsis;
        white-space:nowrap;
    }
    .planner-drop-preview-days { display:flex; flex-direction:column; gap:5px; margin-top:6px; }
    .planner-drop-preview-day {
        display:flex;
        align-items:center;
        gap:7px;
        min-height:30px;
        padding:5px 8px;
        border:1px solid rgba(99,105,209,.22);
        border-radius:8px;
        background:rgba(248,248,255,.92);
        font-size:11px;
        font-weight:700;
    }
    .planner-drop-preview-day-badge {
        flex:0 0 auto;
        min-width:26px;
        padding:2px 5px;
        border-radius:6px;
        background:#6369D1;
        color:#fff;
        text-align:center;
        font-size:9px;
        font-weight:900;
    }
    .planner-drop-preview-block {
        display:flex;
        align-items:center;
        gap:8px;
        min-width:0;
    }
    .planner-drop-preview-type {
        flex:0 0 auto;
        padding:3px 7px;
        border-radius:999px;
        font-size:9px;
        font-weight:800;
    }
    .planner-drop-preview-name {
        min-width:0;
        overflow:hidden;
        text-overflow:ellipsis;
        white-space:nowrap;
        color:#374151;
        font-size:11px;
        font-weight:700;
    }
    .planner-drag-help {
        position:sticky;
        top:4px;
        z-index:12;
        display:flex;
        align-items:center;
        justify-content:center;
        gap:7px;
        width:max-content;
        max-width:calc(100% - 20px);
        margin:0 auto 10px;
        padding:7px 11px;
        border:1px solid #E0E1FA;
        border-radius:999px;
        background:rgba(255,255,255,.96);
        color:#6369D1;
        font-size:11px;
        font-weight:800;
        box-shadow:0 6px 18px rgba(99,105,209,.10);
        pointer-events:none;
    }




    /* 구조 드래그 v2: 원본은 자리에서 빠지고, 삽입 위치에 작성 폼 헤더와 동일한 미리보기만 표시 */
    .planner-structure-source {
        opacity:0 !important;
        height:0 !important;
        min-height:0 !important;
        max-height:0 !important;
        margin:0 !important;
        padding:0 !important;
        border-width:0 !important;
        overflow:hidden !important;
        pointer-events:none !important;
    }
    .planner-drop-slot { overflow:visible; }
    .planner-drop-preview {
        display:none;
        width:calc(100% - 10px);
        padding:0;
        border:0;
        border-radius:0;
        background:transparent;
        color:inherit;
        box-shadow:none;
        pointer-events:none;
    }
    .planner-drop-slot.is-active .planner-drop-preview { display:block; }
    .planner-drop-preview-stack { display:flex; flex-direction:column; gap:8px; width:100%; }
    .planner-drop-form-day { width:100%; opacity:.72; }
    .planner-drop-form-day .planner-day-header {
        width:100%;
        min-height:52px;
        box-shadow:0 8px 22px rgba(79,86,190,.12);
        pointer-events:none;
    }
    .planner-drop-form-block-card {
        width:100%;
        padding:10px 12px;
        border:1px solid #E6E7F2;
        border-radius:12px;
        background:rgba(255,255,255,.84);
        box-shadow:0 8px 22px rgba(17,24,39,.08);
        opacity:.74;
        pointer-events:none;
    }
    .planner-drop-form-block-card .planner-block-header {
        min-height:34px;
        padding:0 2px !important;
    }
    .planner-native-drag-ghost {
        position:fixed;
        left:-10000px;
        top:-10000px;
        z-index:-1;
        width:320px;
        max-width:320px;
        padding:4px;
        pointer-events:none;
    }

    .planner-publish-backdrop {
        position: fixed;
        inset: 0;
        z-index: 10050;
        display: none;
        align-items: center;
        justify-content: center;
        padding: 20px;
        background: rgba(17, 24, 39, .52);
        backdrop-filter: blur(3px);
    }
    .planner-publish-backdrop.is-open { display: flex; }

    .planner-publish-modal {
        width: min(1080px, calc(100vw - 32px));
        height: auto;
        max-height: calc(100vh - 40px);
        display: flex;
        flex-direction: column;
        overflow: hidden;
        border-radius: 22px;
        background: #fff;
        box-shadow: 0 24px 70px rgba(0,0,0,.24);
    }

    .planner-publish-head,
    .planner-publish-footer {
        flex: 0 0 auto;
        background: #fff;
    }

    .planner-publish-body {
        flex: 0 1 auto;
        min-height: 0;
        max-height: calc(100vh - 180px);
        overflow-y: auto;
        overflow-x: hidden;
        padding: 22px 24px;
    }

    .planner-publish-grid {
        width: 100%;
        min-width: 0;
        display: grid;
        grid-template-columns: minmax(420px, 460px) minmax(360px, 1fr);
        gap: 30px;
        align-items: start;
    }

    .planner-publish-column {
        min-width: 0;
        display: block;
        visibility: visible;
        opacity: 1;
    }

    .planner-publish-controls {
        display: block !important;
        min-width: 0;
        padding: 16px;
        border: 1px solid #ECEEF5;
        border-radius: 16px;
        background: #FAFBFF;
        transition: box-shadow .18s ease, border-color .18s ease;
    }

    .planner-publish-controls.is-emphasis {
        border-color: #6369D1;
        box-shadow: 0 0 0 4px rgba(99,105,209,.10);
    }

    /*
     * scheduleList.jsp의 실제 여행일정 카드 구조에 맞춘 미리보기 카드
     */
    .planner-publish-card {
        width: 100%;
        min-height: 520px;
        overflow: hidden;
        border: 1px solid #D1D2F9;
        border-radius: 16px;
        background: #fff;
        box-shadow: 0 2px 8px rgba(0,0,0,.07);
    }

    .planner-publish-cover {
        position: relative;
        width: 100%;
        aspect-ratio: 16 / 11;
        overflow: hidden;
        background: #F0F0FF;
        cursor: pointer;
    }

    .planner-publish-cover img {
        width: 100%;
        height: 100%;
        object-fit: cover;
        display: none;
        transition: transform .3s ease;
    }

    .planner-publish-cover.has-image img {
        display: block;
    }

    .planner-publish-cover.has-image:hover img {
        transform: scale(1.035);
    }

    .planner-publish-cover-empty {
        position: absolute;
        inset: 0;
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        gap: 8px;
        color: #6369D1;
        font-size: 12px;
        font-weight: 800;
    }

    .planner-publish-cover.has-image .planner-publish-cover-empty {
        display: none;
    }

    .planner-publish-cover-change {
        position: absolute;
        inset: 0;
        display: none;
        align-items: center;
        justify-content: center;
        background: rgba(17,24,39,.42);
        color: #fff;
        font-size: 12px;
        font-weight: 800;
    }

    .planner-publish-cover.has-image:hover .planner-publish-cover-change {
        display: flex;
    }

    .planner-publish-bookmark {
        position: absolute;
        top: 10px;
        right: 10px;
        z-index: 3;
        width: 28px;
        height: 28px;
        display: flex;
        align-items: center;
        justify-content: center;
        border-radius: 999px;
        background: rgba(255,255,255,.92);
        box-shadow: 0 1px 5px rgba(0,0,0,.10);
        pointer-events: none;
    }

    .planner-publish-card-body {
        padding: 14px;
    }

    .planner-publish-card-title {
        margin: 0 0 4px;
        color: #18181B;
        font-size: 14px;
        font-weight: 700;
        line-height: 1.45;
        display: -webkit-box;
        -webkit-box-orient: vertical;
        -webkit-line-clamp: 2;
        overflow: hidden;
    }

    .planner-publish-card-summary {
        margin: 0 0 10px;
        color: #6B7280;
        font-size: 12px;
        line-height: 1.6;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }

    .planner-publish-card-dates {
        margin: 0 0 8px;
        color: #9CA3AF;
        font-size: 11px;
    }

    .planner-publish-card-stats {
        display: flex;
        align-items: center;
        gap: 10px;
        margin-bottom: 12px;
        color: #9CA3AF;
        font-size: 11px;
    }

    .planner-publish-card-footer {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 12px;
        padding-top: 10px;
        border-top: 1px solid #D1D2F9;
    }

    .planner-publish-card-author {
        min-width: 0;
        color: #6B7280;
        font-size: 11px;
        font-weight: 600;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
    }

    .planner-publish-card-created {
        flex: 0 0 auto;
        color: #9CA3AF;
        font-size: 10px;
    }

    .planner-publish-photo-list {
        display: grid;
        grid-template-columns: repeat(3, minmax(0, 1fr));
        gap: 10px;
        max-height: 250px;
        overflow-y: auto;
        overflow-x: hidden;
        padding: 2px 4px 2px 2px;
    }

    .planner-publish-photo-option {
        position: relative;
        width: 100%;
        aspect-ratio: 4 / 3;
        padding: 0;
        overflow: hidden;
        border: 2px solid transparent;
        border-radius: 12px;
        background: #F3F4F6;
        cursor: pointer;
        box-sizing: border-box;
    }

    .planner-publish-photo-option img {
        width:100%;
        height:100%;
        object-fit:cover;
        display:block;
    }

    .planner-publish-photo-option.is-selected {
        border-color:#6369D1;
        box-shadow:0 0 0 2px rgba(99,105,209,.12);
    }

    .planner-publish-photo-option.is-selected::after {
        content: '선택';
        position: absolute;
        right: 6px;
        bottom: 6px;
        padding: 3px 7px;
        border-radius: 999px;
        background: #6369D1;
        color: #fff;
        font-size: 10px;
        font-weight: 800;
    }

    .planner-publish-summary {
        display: block !important;
        visibility: visible !important;
        opacity: 1 !important;
        width: 100%;
        max-width: 100%;
        min-width: 0;
        min-height: 140px;
        max-height: 230px;
        resize: vertical;
        box-sizing: border-box;
        border: 1px solid #D1D5DB;
        border-radius: 12px;
        padding: 12px 13px;
        outline: none;
        color: #374151;
        background: #fff;
        font-size: 13px;
        line-height: 1.6;
    }

    .planner-publish-summary:focus {
        border-color:#6369D1;
        box-shadow:0 0 0 3px rgba(99,105,209,.10);
    }

    .planner-publish-error {
        display: none;
        margin-top: 8px;
        color: #DC2626;
        font-size: 11px;
        font-weight: 700;
    }

    .planner-publish-error.is-visible {
        display:block;
    }

    @media (max-width: 800px) {
        .planner-publish-modal {
            height: auto;
            max-height: calc(100vh - 24px);
        }

        .planner-publish-grid {
            grid-template-columns: 1fr;
        }

        .planner-publish-card {
            max-width: 390px;
            margin: 0 auto;
        }
    }

    .planner-place-field {
        position: relative;
        overflow: visible;
    }

    .planner-place-search {
        width: 100%;
    }

    .planner-place-results {
        position: absolute;
        left: 0;
        right: 0;
        top: calc(100% + 6px);
        z-index: 120;
        display: none;
        max-height: 240px;
        overflow-y: auto;
        border: 1px solid #D1D5DB;
        border-radius: 12px;
        background: #fff;
        box-shadow: 0 12px 28px rgba(15, 23, 42, .14);
    }

    .planner-place-results.is-open {
        display: block;
    }

    .planner-place-result {
        width: 100%;
        display: block;
        padding: 10px 12px;
        border: 0;
        border-bottom: 1px solid #F1F5F9;
        background: #fff;
        text-align: left;
        cursor: pointer;
        color: #374151;
        font-size: 12px;
        line-height: 1.45;
    }

    .planner-place-result:last-child {
        border-bottom: 0;
    }

    .planner-place-result:hover,
    .planner-place-result:focus {
        outline: none;
        background: #F5F3FF;
        color: #4F46E5;
    }

    .planner-place-loading,
    .planner-place-empty,
    .planner-place-error {
        padding: 11px 12px;
        color: #9CA3AF;
        font-size: 11px;
    }

    .planner-place-error {
        color: #DC2626;
    }


    .planner-place-loading-text {
        color: #9CA3AF;
        font-size: 12px;
        white-space: nowrap;
    }


    .planner-place-pin-icon,
    .planner-place-pin-body,
    .planner-place-pin-dot {
        transition: fill .15s ease, stroke .15s ease;
    }


    .planner-place-search-wrap {
        position: relative;
        flex: 1 1 auto;
        min-width: 0;
    }

    .planner-place-search {
        width: 100%;
        min-width: 0;
        border: 0;
        outline: 0;
        background: transparent;
        color: #1F2937;
        font-size: 14px;
    }

    .planner-place-results {
        position: fixed;
        z-index: 20000;
        display: none;
        max-height: 300px;
        overflow-y: auto;
        border: 1px solid #D1D5DB;
        border-radius: 12px;
        background: #fff;
        box-shadow: 0 14px 32px rgba(15,23,42,.18);
    }

    .planner-place-results.is-open {
        display: block;
    }

    .planner-place-result {
        width: 100%;
        padding: 10px 12px;
        border: 0;
        border-bottom: 1px solid #F1F5F9;
        background: #fff;
        text-align: left;
        cursor: pointer;
    }

    .planner-place-result:last-child {
        border-bottom: 0;
    }

    .planner-place-result:hover,
    .planner-place-result:focus {
        outline: none;
        background: #F5F3FF;
    }

    .planner-place-result-name {
        display: block;
        color: #111827;
        font-size: 12px;
        font-weight: 700;
    }

    .planner-place-result-address {
        display: block;
        margin-top: 3px;
        color: #9CA3AF;
        font-size: 10px;
        line-height: 1.35;
    }

    .planner-place-result-message {
        padding: 11px 12px;
        color: #9CA3AF;
        font-size: 11px;
    }


    .planner-place-result-row {
        display: flex;
        align-items: flex-start;
        gap: 9px;
    }

    .planner-place-result-badge {
        flex: 0 0 auto;
        width: 22px;
        height: 22px;
        margin-top: 1px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        border-radius: 999px;
        background: #F59E0B;
        color: #fff;
        font-size: 10px;
        font-weight: 800;
    }

    .planner-place-result-copy {
        min-width: 0;
        flex: 1 1 auto;
    }

</style>
</head>
<body class="site-shell">
    <jsp:include page="/common/header.jsp" />

    <main class="flex flex-col" style="height: calc(100vh - 64px)">
        <div class="shrink-0 border-b border-gray-100" style="background: #F8F8FF">
            <div class="grid min-w-0" style="grid-template-columns: minmax(0, 1fr) 460px">
                <div class="min-w-0 px-6 py-3 flex flex-col gap-3">
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
                                id="tripTitle" placeholder="여행 제목을 입력하세요" style="font-size: 14px">
                        </div>
                        <div class="flex items-center gap-1.5 shrink-0 text-gray-500 text-sm px-2">
                            <svg class="text-gray-400" width="14" height="14" viewBox="0 0 24 24" fill="none"
                                stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <rect width="18" height="18" x="3" y="4" rx="2" />
                                <path d="M16 2v4M8 2v4M3 10h18" />
                            </svg>
                            <span>3일 · 13개 일정</span>
                        </div>
                    </div>

                    <div class="grid gap-3 min-w-0"
                        style="grid-template-columns: minmax(0, .72fr) minmax(0, .72fr) minmax(0, .42fr) minmax(380px, 1.55fr)">
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

                <div class="border-l border-gray-100 px-6 py-3 flex flex-col items-end justify-center gap-3"
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

        <div class="flex flex-1 min-h-0">
            <div class="relative flex shrink-0">
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

                <div id="plannerDays" class="flex-1 overflow-y-auto px-5 py-4">
                    <div class="planner-day mb-4" data-day-number="1">
                        <div class="planner-day-header flex items-center gap-3 rounded-xl px-4 py-3 cursor-pointer select-none transition-all group/hdr hover:brightness-[0.93]" draggable="true"
                            style="background: linear-gradient(135deg, #6369D1, #8B5CF6)">
                            <div class="planner-day-number-badge w-7 h-7 rounded-full flex items-center justify-center font-black text-[11px] text-white shrink-0"
                                style="background: rgba(255, 255, 255, .22)">D1</div>
                            <div class="flex-1 min-w-0">
                                <p class="planner-day-title font-bold text-sm truncate" style="color: #fff" title="클릭하여 제목 수정">Day 1</p>
                                <button type="button" class="planner-day-edit-icon" title="DAY 제목 수정" aria-label="DAY 제목 수정">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                        <path d="M12 20h9"/><path d="M16.5 3.5a2.1 2.1 0 0 1 3 3L7 19l-4 1 1-4Z"/>
                                    </svg>
                                </button>
                            </div>
                            <button type="button" class="planner-day-delete p-1 rounded transition-all hover:bg-white/20"
                                style="color: rgba(255,255,255,.6)" title="이 날 삭제">
                                <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                    stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                    <polyline points="3 6 5 6 21 6" />
                                    <path d="M19 6l-1 14H6L5 6m3 0V4h8v2M10 11v6M14 11v6" />
                                </svg>
                            </button>
                        </div>

                        <div class="planner-day-body mt-3 flex flex-col gap-3">
                            <div class="planner-block-card p-3" data-item-type="meal">
                                <div class="planner-block-header flex items-center justify-between px-2 pb-3" draggable="true">
                                    <div class="flex items-center gap-2">
                                        <span class="planner-block-type-badge text-[10px] font-bold rounded-full px-2 py-1"
                                            style="background: #FFF1E8; color: #F97316">식사</span>
                                        <span class="planner-block-title-label font-bold text-sm text-gray-800">츠키지 시장</span>
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
                                        <button type="button" data-item-type="sightseeing" class="planner-type-btn px-3 py-1 rounded-lg text-xs font-semibold" style="background:#EEF2FF;color:#6369D1">관광</button>
                                        <button type="button" data-item-type="meal" class="planner-type-btn px-3 py-1 rounded-lg text-xs font-semibold border" style="background:#FFF7ED;color:#F97316;border-color:#FDBA74">식사</button>
                                        <button type="button" data-item-type="accommodation" class="planner-type-btn px-3 py-1 rounded-lg text-xs font-semibold" style="background:#ECFDF5;color:#10B981">숙소</button>
                                        <button type="button" data-item-type="transport" class="planner-type-btn px-3 py-1 rounded-lg text-xs font-semibold" style="background:#EFF6FF;color:#3B82F6">교통</button>
                                        <button type="button" data-item-type="activity" class="planner-type-btn px-3 py-1 rounded-lg text-xs font-semibold" style="background:#FDF2F8;color:#EC4899">활동</button>
                                    </div>

                                    <div class="planner-block-grid">
                                        <div class="planner-form-column">
                                            <input class="planner-item-title planner-field rounded-lg border border-gray-200 px-3 text-sm font-semibold text-gray-800 outline-none" value="츠키지 시장" placeholder="장소 / 일정 이름 *">

                                            <div class="planner-time-grid planner-field">
                                                <div class="planner-time-box">
                                                    <label for="startTime1">시작</label>
                                                    <input id="startTime1" class="planner-start-time" type="time" value="07:30">
                                                </div>
                                                <div class="planner-time-box">
                                                    <label for="endTime1">종료</label>
                                                    <input id="endTime1" class="planner-end-time" type="time" value="09:00">
                                                </div>
                                            </div>

                                            <div class="planner-field planner-cost-field rounded-lg border border-gray-200 flex items-center px-3 bg-white">
                                                <button type="button" class="planner-cost-mode-btn" data-cost-type="PER_PERSON">1인당 요금</button>
                                                <input class="planner-item-cost w-24 min-w-0 outline-none bg-transparent text-sm font-semibold text-gray-800" value="15000" inputmode="numeric">
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
                                                <textarea class="planner-item-note outline-none text-sm text-gray-700 placeholder-gray-400 bg-transparent" placeholder="메모 (선택)">신선한 스시와 계란말이 추천</textarea>
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
                                            <span>• 1번 사진이 대표 이미지</span>
                                        </div>
                                        </div>
                                    </div>
                                </div>

                            </div>

                            <div class="planner-block-summary flex items-center gap-3" data-item-type="sightseeing" draggable="true">
                                <div class="w-8 h-8 rounded-lg flex items-center justify-center text-xs font-bold"
                                    style="background:#EEF2FF;color:#6369D1">관광</div>
                                <div class="flex-1 min-w-0">
                                    <p class="text-sm font-bold text-gray-800">센소지</p>
                                    <p class="text-xs text-gray-400">09:30 · 아사쿠사</p>
                                </div>
                                <div class="text-xs font-semibold text-indigo-400">관광</div>
                            </div>

                            <div class="planner-block-summary flex items-center gap-3" data-item-type="meal" draggable="true">
                                <div class="w-8 h-8 rounded-lg flex items-center justify-center text-xs font-bold"
                                    style="background:#FFF7ED;color:#F97316">식사</div>
                                <div class="flex-1 min-w-0">
                                    <p class="text-sm font-bold text-gray-800">아이사카 라멘 아사쿠사</p>
                                    <p class="text-xs text-gray-400">12:00 · 아사쿠사 · 15,000원</p>
                                </div>
                                <div class="text-xs font-semibold text-orange-400">식사</div>
                            </div>
                        </div>

                        <button id="plannerAddDay" type="button"
                            class="w-full mt-4 flex items-center justify-center gap-2 py-2.5 rounded-xl border-2 border-dashed border-gray-200 text-xs font-semibold text-gray-400 hover:border-purple-300 hover:text-purple-400 transition-all">
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <path d="M12 5v14M5 12h14" />
                            </svg>
                            Day 2 추가
                        </button>
                    </div>
                </div>
            </div>

            <div class="w-[460px] shrink-0 border-l border-gray-100 flex flex-col bg-white">
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
                    <div id="plannerMapAllLegendOverlay" class="hidden absolute right-3 top-3 z-20 rounded-2xl px-3 py-2 text-xs text-white shadow-xl pointer-events-none"
                        style="background:rgba(17,24,39,.68); backdrop-filter:blur(6px); min-width:120px"></div>
                </div>

                <div class="px-4 py-3 border-t border-gray-100 shrink-0">
                    <p class="text-[10px] text-gray-400 mb-2 font-medium">핀 범례</p>
                    <div class="flex flex-wrap gap-2">
                        <div class="flex items-center gap-1"><div class="w-4 h-4 rounded flex items-center justify-center" style="background:#6369D118"><span style="color:#6369D1;font-size:9px">●</span></div><span class="text-[10px] font-medium" style="color:#6369D1">관광</span></div>
                        <div class="flex items-center gap-1"><div class="w-4 h-4 rounded flex items-center justify-center" style="background:#F9731618"><span style="color:#F97316;font-size:9px">●</span></div><span class="text-[10px] font-medium" style="color:#F97316">식사</span></div>
                        <div class="flex items-center gap-1"><div class="w-4 h-4 rounded flex items-center justify-center" style="background:#10B98118"><span style="color:#10B981;font-size:9px">●</span></div><span class="text-[10px] font-medium" style="color:#10B981">숙박</span></div>
                        <div class="flex items-center gap-1"><div class="w-4 h-4 rounded flex items-center justify-center" style="background:#3B82F618"><span style="color:#3B82F6;font-size:9px">●</span></div><span class="text-[10px] font-medium" style="color:#3B82F6">교통</span></div>
                        <div class="flex items-center gap-1"><div class="w-4 h-4 rounded flex items-center justify-center" style="background:#EC489918"><span style="color:#EC4899;font-size:9px">●</span></div><span class="text-[10px] font-medium" style="color:#EC4899">활동</span></div>
                    </div>
                </div>
            </div>
        </div>
    </main>

    <jsp:include page="/common/footer.jsp" />

    <script>
        (function () {
            var DRAFT_KEY = 'tripily_planner_draft_edit_v4';
            var PLANNER_CONTEXT_PATH='${pageContext.request.contextPath}';
            var restoringDraft=false;
            var lastPlannerActivityAt=Date.now();
            var lastKeepAliveAt=Date.now();
            var keepAliveInFlight=false;
            var sessionExpiredHandling=false;
            var TYPE_CONFIG = {
                sightseeing:{label:'관광',color:'#6369D1',bg:'#EEF2FF'},
                meal:{label:'식사',color:'#F97316',bg:'#FFF7ED'},
                accommodation:{label:'숙소',color:'#10B981',bg:'#ECFDF5'},
                transport:{label:'교통',color:'#3B82F6',bg:'#EFF6FF'},
                activity:{label:'활동',color:'#EC4899',bg:'#FDF2F8'}
            };
            var map, mapMarkers=[], mapPolylines=[], mapSearchMarkers=[];
            var plannerPlaceDetailsCache={};
            var plannerMapInfoSeq=0;
            var plannerActiveMapDay='all';
            // DAY 동선 색상은 장소 유형(관광/식사/숙박/교통/활동) 핀 색상과 겹치지 않도록 별도 팔레트를 사용한다.
            var plannerDayLinePalette=['#111827','#92400E','#0E7490','#A16207','#991B1B','#475569','#4D7C0F','#713F12'];
            function getPlannerDayLineColor(dayNumber){
                var dayIndex=parseInt(dayNumber,10);
                if(!dayIndex||dayIndex<1){
                    dayIndex=1;
                }
                return plannerDayLinePalette[(dayIndex-1)%plannerDayLinePalette.length];
            }
            var plannerPlacesLibraryPromise=null;
            var dirty=false;

            function $(sel, root){ return (root||document).querySelector(sel); }
            function $$(sel, root){ return Array.prototype.slice.call((root||document).querySelectorAll(sel)); }
            var blockTemplate = $('.planner-block-card') ? $('.planner-block-card').cloneNode(true) : null;
            /*
             * ModifyPlanServlet에서 전달한 카트 조회 결과.
             *
             * List<ItineraryDto>
             *  └ days
             *      └ blocks
             */
            var IMPORT_ITINERARIES =
                ${empty importListJson ? '[]' : importListJson};

            var EDIT_ITINERARY =
                ${empty editItineraryJson ? 'null' : editItineraryJson};

            DRAFT_KEY += '_' + (EDIT_ITINERARY && EDIT_ITINERARY.itineraryId
                ? String(EDIT_ITINERARY.itineraryId)
                : 'unknown');

            function dbBlockTypeToPlanner(type){
                var map={
                    ATTRACTION:'sightseeing',
                    MEAL:'meal',
                    LODGING:'accommodation',
                    TRANSPORT:'transport',
                    ACTIVITY:'activity'
                };

                return map[type] || 'sightseeing';
            }

            function shortTime(value){
                if(!value) return '';
                value=String(value);
                return value.length>=5 ? value.substring(0,5) : value;
            }

            function calculateTripDays(startDate,endDate,fallback){
                if(startDate && endDate){
                    var s=new Date(startDate+'T00:00:00');
                    var e=new Date(endDate+'T00:00:00');

                    if(!isNaN(s.getTime()) && !isNaN(e.getTime())){
                        return Math.max(
                            1,
                            Math.round((e-s)/(1000*60*60*24))+1
                        );
                    }
                }

                return Math.max(1,fallback||1);
            }

            function normalizeImportItinerary(itinerary,index){
                itinerary=itinerary||{};

                var rawDays=Array.isArray(itinerary.days)
                    ? itinerary.days
                    : [];

                var tripDays=calculateTripDays(
                    itinerary.startDate,
                    itinerary.endDate,
                    rawDays.length
                );

                return {
                    id:'cart-itinerary-'+(itinerary.itineraryId||index),
                    sourceItineraryId:itinerary.sourceItineraryId||itinerary.itineraryId||null,
                    title:itinerary.title||'제목 없는 일정',
                    country:itinerary.country||'',
                    countryCode:'',
                    thumbnailImg:itinerary.thumbnailImg||'',
                    region:itinerary.city||'',
                    travelerCount:itinerary.travelerCount == null
                        ? 1
                        : Number(itinerary.travelerCount),
                    nights:Math.max(0,tripDays-1),
                    days:tripDays,
                    color:'#6369D1',

                    daySchedules:rawDays.map(function(day,dayIndex){
                        day=day||{};

                        var rawBlocks=Array.isArray(day.blocks)
                            ? day.blocks
                            : [];

                        return {
                            sourceDayId:day.sourceDayId||day.dayId||null,
                            dayNum:day.dayOrder||dayIndex+1,
                            theme:day.title||('Day '+(day.dayOrder||dayIndex+1)),

                            items:rawBlocks.map(function(block){
                                block=block||{};

                                return {
                                    sourceBlockId:block.sourceBlockId||block.blockId||null,
                                    type:dbBlockTypeToPlanner(block.blockType),
                                    name:block.title||'새 일정',
                                    time:shortTime(block.startTime),
                                    endTime:shortTime(block.endTime),
                                    location:block.placeName||block.placeAddress||'',
                                    googlePlaceId:block.googlePlaceId||'',
                                    placeName:block.placeName||'',
                                    placeAddress:block.placeAddress||'',
                                    placeLat:block.placeLat,
                                    placeLng:block.placeLng,
                                    cost:block.cost==null ? 0 : block.cost,
                                    costType:block.costType||'TOTAL',
                                    note:block.memo||''
                                };
                            })
                        };
                    })
                };
            }

            var SAVED_PLANS=IMPORT_ITINERARIES.map(
                normalizeImportItinerary
            );

            function money(v){ var n=parseInt(String(v||'').replace(/[^0-9]/g,''),10)||0; return n.toLocaleString('ko-KR')+'원'; }
            function escapeImportHtml(value){
                return String(value==null?'':value)
                    .replace(/&/g,'&amp;')
                    .replace(/</g,'&lt;')
                    .replace(/>/g,'&gt;')
                    .replace(/"/g,'&quot;')
                    .replace(/'/g,'&#39;');
            }
            function toast(msg){
                var old=$('.planner-save-message'); if(old) old.remove();
                var el=document.createElement('div'); el.className='planner-save-message'; el.textContent=msg; document.body.appendChild(el);
                setTimeout(function(){ el.remove(); },2200);
            }
            function handlePlannerSessionExpired(){
                if(sessionExpiredHandling) return;
                sessionExpiredHandling=true;
                Promise.resolve(saveDraftNow()).finally(function(){
                    dirty=false;
                    alert('로그인 세션이 만료되었습니다. 작성 내용은 브라우저에 임시저장했습니다. 다시 로그인한 뒤 일정 작성/수정 페이지로 돌아오면 복구됩니다.');
                    window.location.href=PLANNER_CONTEXT_PATH + '/auth/login';
                });
            }

            function keepPlannerSessionAlive(force){
                var now=Date.now();
                if(keepAliveInFlight) return Promise.resolve(true);
                if(!force && now-lastKeepAliveAt < 4*60*1000) return Promise.resolve(true);

                keepAliveInFlight=true;
                return fetch(PLANNER_CONTEXT_PATH + '/itinerary/session/keepalive',{
                    method:'POST',
                    credentials:'same-origin',
                    cache:'no-store',
                    headers:{'X-Requested-With':'XMLHttpRequest'}
                }).then(function(response){
                    if(response.status===401){
                        handlePlannerSessionExpired();
                        return false;
                    }
                    if(!response.ok){
                        throw new Error('keep-alive failed: '+response.status);
                    }
                    lastKeepAliveAt=Date.now();
                    return true;
                }).catch(function(error){
                    console.warn('세션 연장 요청에 실패했습니다.',error);
                    return false;
                }).finally(function(){
                    keepAliveInFlight=false;
                });
            }

            function markDirty(){
                if(restoringDraft) return;
                dirty=true;
                lastPlannerActivityAt=Date.now();
                // 임시저장은 세션 만료가 실제로 확인된 경우에만 수행한다.
                keepPlannerSessionAlive(false);
            }

            document.addEventListener('input',function(e){
                if(e.target.closest('#plannerCenterPanel') || e.target.closest('#plannerPublishBackdrop')){
                    markDirty();
                }
            },true);
            document.addEventListener('change',function(e){
                if(e.target.closest('#plannerCenterPanel') || e.target.closest('#plannerPublishBackdrop')){
                    markDirty();
                }
            },true);

            window.setInterval(function(){
                if(dirty && Date.now()-lastPlannerActivityAt < 5*60*1000){
                    keepPlannerSessionAlive(false);
                }
            },60*1000);

            window.addEventListener('beforeunload', function(e){
                if(!dirty) return;
                // 일반 페이지 이동/새로고침에서는 임시저장하지 않는다.
                // 저장하지 않은 변경사항이 있다는 경고만 표시한다.
                e.preventDefault();
                e.returnValue='';
            });

            var toggleBtn = $('#plannerPanelToggle'), panel = $('#plannerLeftPanel'), icon = $('#plannerPanelToggleIcon');
            if (toggleBtn && panel) toggleBtn.addEventListener('click', function () {
                var closed = panel.style.width === '0px'; panel.style.width = closed ? '340px' : '0px';
                toggleBtn.title = closed ? '일정 가져오기 숨기기' : '일정 가져오기 열기';
                if (icon) icon.innerHTML = closed ? '<path d="m15 18-6-6 6-6" />' : '<path d="m9 18 6-6-6-6" />';
            });

            var search=$('#plannerPlanSearch'), count=$('#plannerPlanCount');

            /*
             * 일정 가져오기 / 작성 중 DAY / 작성 중 BLOCK을 하나의 드래그 UX로 처리한다.
             * 드래그를 시작한 동안에만 #plannerDays를 구조 편집 모드로 바꾸고,
             * 넓은 drop slot + 반투명 미리보기를 표시한다.
             */
            var plannerStructureDrag=null;

            function plannerBlockPrefill(item){
                item=item||{};
                return {
                    sourceBlockId:item.sourceBlockId||null,
                    title:item.name||item.title||'',
                    type:item.type||'sightseeing',
                    startTime:item.time||item.startTime||'',
                    endTime:item.endTime||'',
                    cost:item.cost||'',
                    costType:item.costType||'TOTAL',
                    place:item.location||'',
                    googlePlaceId:item.googlePlaceId||'',
                    placeName:item.placeName||'',
                    placeAddress:item.placeAddress||'',
                    placeLat:item.placeLat,
                    placeLng:item.placeLng,
                    note:item.note||item.memo||''
                };
            }

            function createPlannerDayShell(title){
                var n=$$('.planner-day').length+1;
                var d=document.createElement('div');
                d.className='planner-day mb-4';
                d.dataset.dayNumber=String(n);
                d.dataset.dayOrder=String(n);
                d.innerHTML='<div class="planner-day-header flex items-center gap-3 rounded-xl px-4 py-3 cursor-pointer select-none transition-all" draggable="true" style="background:linear-gradient(135deg,#6369D1,#8B5CF6)"><div class="planner-day-number-badge w-7 h-7 rounded-full flex items-center justify-center font-black text-[11px] text-white shrink-0" style="background:rgba(255,255,255,.22)">D'+n+'</div><div class="flex-1 min-w-0"><p class="planner-day-title font-bold text-sm truncate" style="color:#fff" title="클릭하여 제목 수정">'+escapeImportHtml(title||('Day '+n))+'</p><button type="button" class="planner-day-edit-icon" title="DAY 제목 수정" aria-label="DAY 제목 수정"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 20h9"/><path d="M16.5 3.5a2.1 2.1 0 0 1 3 3L7 19l-4 1 1-4Z"/></svg></button></div><button type="button" class="planner-day-delete p-1 rounded" style="color:rgba(255,255,255,.6)" title="이 날 삭제"><svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14H6L5 6m3 0V4h8v2M10 11v6M14 11v6"/></svg></button></div><div class="planner-day-body mt-3 flex flex-col gap-3"></div>';
                return d;
            }

            function insertBlockAt(day,prefill,beforeNode){
                var body=$('.planner-day-body',day);
                if(!body) return null;
                body.classList.remove('is-collapsed');
                clearEmptyHint(body);
                var card=createBlock(prefill||{});
                if(!card) return null;
                var addBtn=$('.planner-add-block-btn',body);
                body.insertBefore(card,beforeNode && beforeNode.parentNode===body ? beforeNode : (addBtn||null));
                ensureDayControls(day);
                updateDayDeleteButtons();
                syncBudget();
                syncCountryEditLock();
                return card;
            }

            function insertImportedDayAt(beforeNode,dayData){
                dayData=dayData||{};
                var daysWrap=$('#plannerDays');
                var addDayBtn=$('#plannerAddDay');
                if(!daysWrap) return null;
                var d=createPlannerDayShell(dayData.theme||dayData.title||'Day');
                d.dataset.sourceDayId=dayData.sourceDayId||'';
                daysWrap.insertBefore(d,beforeNode && beforeNode.parentNode===daysWrap ? beforeNode : addDayBtn);
                setupDay(d);
                (dayData.items||dayData.blocks||[]).forEach(function(item){
                    insertBlockAt(d,plannerBlockPrefill(item),null);
                });
                ensureDayControls(d);
                return d;
            }

            function plannerDragModeFor(state){
                if(!state) return '';
                return (state.kind==='item' || state.kind==='internal-block') ? 'block' : 'day';
            }

            function plannerDayHeaderPreviewHtml(dayNumber,title,sourceElement){
                if(sourceElement){
                    var sourceHeader=$('.planner-day-header',sourceElement);
                    if(sourceHeader){
                        var dayClone=sourceHeader.cloneNode(true);
                        dayClone.removeAttribute('draggable');
                        dayClone.querySelectorAll('button').forEach(function(btn){btn.remove();});
                        return '<div class="planner-drop-form-day">'+dayClone.outerHTML+'</div>';
                    }
                }

                var number=(dayNumber==null || dayNumber==='') ? '' : String(dayNumber).replace(/^D/i,'');
                var badge=number ? ('D'+number) : 'DAY';
                return '<div class="planner-drop-form-day">'
                    +'<div class="planner-day-header flex items-center gap-3 rounded-xl px-4 py-3 select-none transition-all" style="background:linear-gradient(135deg,#6369D1,#8B5CF6)">'
                    +'<span class="planner-structure-grip" aria-hidden="true">⠿</span>'
                    +'<div class="planner-day-number-badge w-7 h-7 rounded-full flex items-center justify-center font-black text-[11px] text-white shrink-0" style="background:rgba(255,255,255,.22)">'+escapeImportHtml(badge)+'</div>'
                    +'<div class="flex-1 min-w-0"><p class="planner-day-title font-bold text-sm truncate" style="color:#fff">'+escapeImportHtml(title||'Day')+'</p></div>'
                    +'</div></div>';
            }

            function plannerBlockHeaderPreviewHtml(type,name,sourceElement){
                if(sourceElement){
                    var sourceHeader=$('.planner-block-header',sourceElement);
                    if(sourceHeader){
                        var blockClone=sourceHeader.cloneNode(true);
                        blockClone.removeAttribute('draggable');
                        blockClone.querySelectorAll('button').forEach(function(btn){btn.remove();});
                        return '<div class="planner-drop-form-block-card">'+blockClone.outerHTML+'</div>';
                    }
                }

                var cfg=TYPE_CONFIG[type]||TYPE_CONFIG.sightseeing;
                return '<div class="planner-drop-form-block-card">'
                    +'<div class="planner-block-header flex items-center justify-between px-2 pb-3">'
                    +'<div class="flex items-center gap-2">'
                    +'<span class="planner-structure-grip" aria-hidden="true">⠿</span>'
                    +'<span class="planner-block-type-badge text-[10px] font-bold rounded-full px-2 py-1" style="background:'+cfg.bg+';color:'+cfg.color+'">'+escapeImportHtml(cfg.label)+'</span>'
                    +'<span class="planner-block-title-label font-bold text-sm text-gray-800">'+escapeImportHtml(name||'일정 블록')+'</span>'
                    +'</div><div></div></div></div>';
            }

            function plannerDragPreviewHtml(state){
                if(!state) return '';
                var payload=state.payload||{};
                var html=[];

                if(state.kind==='plan'){
                    var schedules=(payload.plan && payload.plan.daySchedules)||[];
                    schedules.forEach(function(day,i){
                        html.push(plannerDayHeaderPreviewHtml(day.dayNum||day.dayNumber||(i+1),day.theme||day.title||('Day '+(i+1)),null));
                    });
                    return '<div class="planner-drop-preview-stack">'+html.join('')+'</div>';
                }

                if(state.kind==='day'){
                    var importedDay=payload.day||{};
                    return '<div class="planner-drop-preview-stack">'
                        +plannerDayHeaderPreviewHtml(importedDay.dayNum||importedDay.dayNumber||'',importedDay.theme||importedDay.title||'Day',null)
                        +'</div>';
                }

                if(state.kind==='internal-day'){
                    return '<div class="planner-drop-preview-stack">'
                        +plannerDayHeaderPreviewHtml('', '', state.element)
                        +'</div>';
                }

                var item=state.kind==='item' ? (payload.item||{}) : null;
                var card=state.element;
                var type=item ? item.type : (card ? card.dataset.itemType : 'sightseeing');
                var name=item ? (item.name||item.title||'일정 블록') : '';
                if(!name && card){
                    var label=$('.planner-block-title-label',card);
                    var input=$('.planner-item-title',card);
                    name=(label&&label.textContent.trim()) || (input&&input.value.trim()) || '일정 블록';
                }
                return '<div class="planner-drop-preview-stack">'
                    +plannerBlockHeaderPreviewHtml(type,name,state.kind==='internal-block'?card:null)
                    +'</div>';
            }

            var plannerNativeDragGhost=null;

            function clearPlannerNativeDragGhost(){
                if(plannerNativeDragGhost){
                    plannerNativeDragGhost.remove();
                    plannerNativeDragGhost=null;
                }
            }

            function setPlannerNativeDragImage(e,state){
                if(!e || !e.dataTransfer || typeof e.dataTransfer.setDragImage!=='function') return;
                clearPlannerNativeDragGhost();
                var ghost=document.createElement('div');
                ghost.className='planner-native-drag-ghost';
                ghost.innerHTML=plannerDragPreviewHtml(state);
                document.body.appendChild(ghost);
                plannerNativeDragGhost=ghost;
                var rect=ghost.getBoundingClientRect();
                e.dataTransfer.setDragImage(ghost,Math.min(150,Math.max(24,rect.width/2)),24);
            }

            var plannerBlockDragHoverDay=null;

            function setPlannerBlockDragHoverDay(day){
                if(plannerBlockDragHoverDay===day) return;
                $$('.planner-day.planner-block-drag-hover').forEach(function(node){
                    node.classList.remove('planner-block-drag-hover');
                });
                plannerBlockDragHoverDay=day||null;
                if(plannerBlockDragHoverDay){
                    plannerBlockDragHoverDay.classList.add('planner-block-drag-hover');
                }
            }

            function removePlannerDropSlots(){
                $$('.planner-drop-slot,.planner-drag-help').forEach(function(node){node.remove();});
                $$('.planner-day.planner-import-replaced-starter').forEach(function(day){
                    day.classList.remove('planner-import-replaced-starter');
                });
                setPlannerBlockDragHoverDay(null);
                var root=$('#plannerDays');
                if(root){
                    root.classList.remove('planner-structure-drag-mode','planner-drag-day-mode','planner-drag-block-mode');
                }
            }

            function activatePlannerDropSlot(slot){
                $$('.planner-drop-slot').forEach(function(s){
                    var active=s===slot;
                    s.classList.toggle('is-active',active);
                    s.style.minHeight='';
                    if(active){
                        var preview=$('.planner-drop-preview',s);
                        var base=s.classList.contains('is-block-slot') ? 56 : 72;
                        var needed=preview ? (preview.scrollHeight+16) : base;
                        s.style.minHeight=Math.max(base,needed)+'px';
                    }
                });
            }

            function makePlannerDropSlot(meta){
                var slot=document.createElement('div');
                slot.className='planner-drop-slot '+(meta.mode==='block'?'is-block-slot':'is-day-slot');
                slot._plannerDropMeta=meta;
                var preview=document.createElement('div');
                preview.className='planner-drop-preview';
                preview.innerHTML=plannerDragPreviewHtml(plannerStructureDrag);
                slot.appendChild(preview);

                slot.addEventListener('dragenter',function(e){
                    if(!plannerStructureDrag) return;
                    e.preventDefault();
                    e.stopPropagation();
                    activatePlannerDropSlot(slot);
                });
                slot.addEventListener('dragover',function(e){
                    if(!plannerStructureDrag) return;
                    e.preventDefault();
                    e.stopPropagation();
                    if(e.dataTransfer){
                        e.dataTransfer.dropEffect=plannerStructureDrag.source==='internal' ? 'move' : 'copy';
                    }
                    activatePlannerDropSlot(slot);
                });
                slot.addEventListener('drop',function(e){
                    if(!plannerStructureDrag) return;
                    e.preventDefault();
                    e.stopPropagation();

                    /*
                     * 반투명 미리보기가 실제로 보이는 슬롯만 유효한 삽입 위치다.
                     * 미리보기가 활성화되지 않은 슬롯이면 변경하지 않고 취소한다.
                     */
                    if(!slot.classList.contains('is-active')){
                        cancelPlannerStructureDrag();
                        return;
                    }

                    performPlannerStructureDrop(slot._plannerDropMeta);
                });
                return slot;
            }

            function buildPlannerDropSlots(){
                removePlannerDropSlots();
                if(!plannerStructureDrag) return;
                var root=$('#plannerDays');
                if(!root) return;
                var mode=plannerDragModeFor(plannerStructureDrag);
                root.classList.add('planner-structure-drag-mode',mode==='block'?'planner-drag-block-mode':'planner-drag-day-mode');

                var help=document.createElement('div');
                help.className='planner-drag-help';
                help.textContent=mode==='block' ? '원하는 DAY의 블록 사이에 놓으세요' : '원하는 DAY 사이에 놓으세요';
                root.insertBefore(help,root.firstChild);

                if(mode==='day'){
                    /*
                     * 새 일정의 기본 빈 D1만 있는 상태에서 왼쪽 DAY/일정 전체를 가져오면
                     * 실제 DROP 시 D1이 삭제되는 동작과 미리보기도 동일해야 한다.
                     * 따라서 드래그 중에도 기본 D1을 화면/슬롯 계산에서 제외한다.
                     */
                    var replacedStarterDay=null;
                    if(plannerStructureDrag.source==='import'
                            && (plannerStructureDrag.kind==='day' || plannerStructureDrag.kind==='plan')){
                        replacedStarterDay=getPlannerEmptyStarterDay();
                        if(replacedStarterDay){
                            replacedStarterDay.classList.add('planner-import-replaced-starter');
                        }
                    }

                    /* 이동 중인 DAY와 가져오기로 대체될 기본 빈 D1은 원래 자리에서 빠진 것으로 계산한다. */
                    var days=$$('.planner-day').filter(function(day){
                        if(plannerStructureDrag.kind==='internal-day' && day===plannerStructureDrag.element) return false;
                        if(replacedStarterDay && day===replacedStarterDay) return false;
                        return true;
                    });
                    var addDayBtn=$('#plannerAddDay');
                    for(var i=0;i<=days.length;i++){
                        var before=i<days.length ? days[i] : addDayBtn;
                        root.insertBefore(makePlannerDropSlot({mode:'day',beforeDay:before||null,index:i}),before||null);
                    }
                    return;
                }

                $$('.planner-day').forEach(function(day){
                    var body=$('.planner-day-body',day);
                    if(!body) return;
                    /* 이동 중인 BLOCK 역시 원래 자리에서 제외하고 슬롯을 계산한다. */
                    var blocks=$$('.planner-block-card',body).filter(function(block){
                        return !(plannerStructureDrag.kind==='internal-block' && block===plannerStructureDrag.element);
                    });
                    var addBtn=$('.planner-add-block-btn',body);
                    for(var i=0;i<=blocks.length;i++){
                        var before=i<blocks.length ? blocks[i] : addBtn;
                        body.insertBefore(makePlannerDropSlot({mode:'block',day:day,beforeBlock:before||null,index:i}),before||null);
                    }
                });

                /*
                 * 작성 중인 블록을 잡은 순간에는 마우스가 원본 DAY 위에 있으므로
                 * 그 DAY만 우선 펼친다. 왼쪽에서 가져오는 블록은 DAY 위에 진입할 때까지
                 * 모두 닫힌 상태를 유지한다.
                 */
                if(plannerStructureDrag.kind==='internal-block' && plannerStructureDrag.originDay){
                    setPlannerBlockDragHoverDay(plannerStructureDrag.originDay);
                }else{
                    setPlannerBlockDragHoverDay(null);
                }
            }


            var plannerStructureBuildFrame=0;

            function startPlannerStructureDrag(options){
                var nextState=options||null;
                if(!nextState) return;

                if(plannerStructureBuildFrame){
                    cancelAnimationFrame(plannerStructureBuildFrame);
                    plannerStructureBuildFrame=0;
                }

                plannerStructureDrag=nextState;

                /*
                 * 내부 DAY/BLOCK을 native dragstart 안에서 바로 재배치하면
                 * 드래그 원본이 들어 있는 DOM 자체가 변해서 Chrome에서 drag가
                 * 즉시 취소될 수 있다. 따라서 브라우저가 native drag를 시작한
                 * 다음 프레임에만 삽입 슬롯 UI를 만든다.
                 */
                if(nextState.source==='internal'){
                    plannerStructureBuildFrame=requestAnimationFrame(function(){
                        plannerStructureBuildFrame=0;
                        if(plannerStructureDrag!==nextState) return;
                        if(nextState.element){
                            nextState.element.classList.add('planner-structure-source');
                        }
                        buildPlannerDropSlots();
                    });
                    return;
                }

                if(nextState.element){
                    nextState.element.classList.add('planner-structure-source');
                }
                buildPlannerDropSlots();
            }

            function endPlannerStructureDrag(){
                if(plannerStructureBuildFrame){
                    cancelAnimationFrame(plannerStructureBuildFrame);
                    plannerStructureBuildFrame=0;
                }
                if(plannerStructureDrag && plannerStructureDrag.element){
                    plannerStructureDrag.element.classList.remove('planner-structure-source');
                }
                plannerStructureDrag=null;
                removePlannerDropSlots();
                clearPlannerNativeDragGhost();
            }


            /*
             * 구조 드래그 취소 공통 처리.
             * 유효한 삽입 위치가 아닌 곳에 놓은 경우에만 아무 변경 없이 취소한다.
             * 유효 여부는 화면의 반투명 삽입 미리보기 표시 여부와 정확히 일치한다.
             * 가져오기 중 숨겨 둔 기본 빈 D1 / 국가 잠금 상태도 원래대로 복구한다.
             */
            function cancelPlannerStructureDrag(){
                if(!plannerStructureDrag) return;

                var wasImport=plannerStructureDrag.source==='import';

                if(wasImport){
                    finishImportDrag();
                }else{
                    clearDayDragState();
                    endPlannerStructureDrag();
                    syncCountryEditLock();
                }
            }

            /*
             * 삽입 슬롯 자체의 drop은 슬롯 이벤트에서 먼저 처리되고 stopPropagation 된다.
             * 그 외 영역에 마우스를 놓은 경우에는 여기까지 올라오므로 단순 취소로 본다.
             */
            document.addEventListener('drop',function(e){
                if(!plannerStructureDrag) return;
                e.preventDefault();
                cancelPlannerStructureDrag();
            });

            /*
             * 작성/수정 중인 DAY와 BLOCK은 헤더 자체를 드래그 핸들로 사용한다.
             * 개별 카드 생성 시마다 dragstart를 다시 바인딩하지 않고 이벤트 위임으로
             * 처리해서 새로 추가된 DAY/BLOCK도 즉시 동일하게 동작한다.
             */
            function plannerInternalDragHeaderFromTarget(target){
                if(!target || !target.closest) return null;
                var header=target.closest('.planner-day-header,.planner-block-header');
                if(!header || !header.closest('#plannerDays')) return null;
                return header;
            }

            function plannerIsHeaderControlTarget(target,header){
                if(!target || !target.closest || !header) return false;
                var control=target.closest('button,input,textarea,select,a,[contenteditable="true"]');
                return !!(control && header.contains(control));
            }

            document.addEventListener('mousedown',function(e){
                var header=plannerInternalDragHeaderFromTarget(e.target);
                if(!header) return;

                /* 삭제/접기/제목수정 같은 실제 버튼 조작 중에는 드래그하지 않는다. */
                if(plannerIsHeaderControlTarget(e.target,header)){
                    header.setAttribute('draggable','false');
                    var restore=function(){
                        header.setAttribute('draggable','true');
                        document.removeEventListener('mouseup',restore,true);
                    };
                    document.addEventListener('mouseup',restore,true);
                    return;
                }

                /* 마우스를 누른 순간 확실히 draggable 상태로 만든다. */
                header.setAttribute('draggable','true');
            },true);

            /*
             * BLOCK 드래그 중 DAY 헤더/본문 위로 마우스가 들어가면 해당 DAY만 펼친다.
             * 다른 DAY로 이동하면 직전 DAY는 즉시 닫혀 한 번에 하나만 열린다.
             */
            document.addEventListener('dragover',function(e){
                if(!plannerStructureDrag) return;

                var target=e.target;
                var slot=target && target.closest ? target.closest('.planner-drop-slot') : null;
                if(slot && !slot.closest('#plannerDays')) slot=null;

                /*
                 * 마우스가 유효한 삽입 슬롯 밖으로 벗어나면 이전 슬롯의
                 * 미리보기를 즉시 끈다. 따라서 '미리보기가 보임 = 드롭 가능',
                 * '미리보기가 안 보임 = 드롭 시 취소'가 항상 성립한다.
                 */
                if(!slot){
                    activatePlannerDropSlot(null);
                }

                if(plannerDragModeFor(plannerStructureDrag)!=='block') return;

                var day=target && target.closest ? target.closest('.planner-day') : null;
                if(day && !day.closest('#plannerDays')) day=null;
                setPlannerBlockDragHoverDay(day);
            },true);

            document.addEventListener('dragstart',function(e){
                var header=plannerInternalDragHeaderFromTarget(e.target);
                if(!header) return;

                var day=header.closest('.planner-day');
                var block=header.closest('.planner-block-card');
                if(!day) return;

                /*
                 * dataTransfer를 먼저 채우고, DOM 변경은 startPlannerStructureDrag에서
                 * 다음 animation frame으로 미룬다.
                 */
                if(e.dataTransfer){
                    e.dataTransfer.effectAllowed='move';
                    e.dataTransfer.setData(
                        'text/plain',
                        block ? 'planner-block' : 'planner-day'
                    );
                }

                var internalDragState=block
                    ? {source:'internal',kind:'internal-block',element:block,originDay:day}
                    : {source:'internal',kind:'internal-day',element:day};

                /* native ghost도 중앙 작성 폼의 DAY/BLOCK 헤더 모양으로 통일한다. */
                setPlannerNativeDragImage(e,internalDragState);
                startPlannerStructureDrag(internalDragState);
            },true);

            document.addEventListener('dragend',function(){
                if(plannerStructureDrag && plannerStructureDrag.source==='internal'){
                    clearDayDragState();
                    endPlannerStructureDrag();
                }
            },true);

            /*
             * 새 일정의 기본 빈 D1만 남아 있는 상태에서 왼쪽의 DAY/일정 전체를
             * 가져오면, 빈 D1을 자리표시자로 남기지 않고 자동으로 제거한다.
             * 블록 1개를 가져오는 경우에는 그 블록을 담을 DAY가 필요하므로 제거하지 않는다.
             */
            function getPlannerEmptyStarterDay(){
                var days=$$('.planner-day');
                if(days.length!==1) return null;

                var day=days[0];
                var body=$('.planner-day-body',day);
                if(!body) return null;

                /* 이미 가져온 DAY는 내용이 비었더라도 사용자가 가진 DAY이므로 자동 삭제하지 않는다. */
                if(day.dataset.sourceDayId) return null;

                if($('.planner-block-card,.planner-block-summary',body)) return null;
                return day;
            }

            function removePlannerEmptyStarterDayBeforeImport(beforeNode){
                var emptyDay=getPlannerEmptyStarterDay();
                if(!emptyDay) return beforeNode;

                var wasBeforeTarget=(beforeNode===emptyDay);
                emptyDay.remove();

                /* 제거한 D1 자체가 삽입 기준점이었다면 맨 앞/유일 위치로 삽입되도록 null 처리 */
                return wasBeforeTarget ? null : beforeNode;
            }

            function performPlannerStructureDrop(meta){
                var state=plannerStructureDrag;
                if(!state || !meta) return;
                var changed=false;

                if(meta.mode==='day'){
                    var before=meta.beforeDay;
                    if(state.kind==='internal-day' && state.element){
                        var moving=state.element;
                        var root=$('#plannerDays');
                        var addBtn=$('#plannerAddDay');
                        if(before!==moving){
                            root.insertBefore(moving,before && before.parentNode===root ? before : addBtn);
                            changed=true;
                        }
                    }else if(state.kind==='day'){
                        applyImportHeaderDefaults(state.payload);

                        /* 기본으로 생성된 빈 D1뿐이면 가져온 DAY가 그 자리를 대신한다. */
                        before=removePlannerEmptyStarterDayBeforeImport(before);
                        insertImportedDayAt(before,state.payload.day||{});

                        toast('DAY 일정을 가져왔습니다.');
                        changed=true;
                    }else if(state.kind==='plan'){
                        applyImportHeaderDefaults(state.payload);
                        var schedules=(state.payload.plan && state.payload.plan.daySchedules)||[];

                        /* 일정 전체를 빈 새 일정에 가져오는 경우도 불필요한 기본 D1을 남기지 않는다. */
                        if(schedules.length>0){
                            before=removePlannerEmptyStarterDayBeforeImport(before);
                        }
                        schedules.forEach(function(dayData){ insertImportedDayAt(before,dayData); });
                        toast('일정 '+schedules.length+'개 DAY를 가져왔습니다.');
                        changed=schedules.length>0;
                    }
                }else if(meta.mode==='block'){
                    var targetDay=meta.day;
                    var beforeBlock=meta.beforeBlock;
                    if(state.kind==='internal-block' && state.element){
                        var card=state.element;
                        var oldDay=card.closest('.planner-day');
                        var body=$('.planner-day-body',targetDay);
                        if(beforeBlock!==card){
                            body.classList.remove('is-collapsed');
                            clearEmptyHint(body);
                            body.insertBefore(card,beforeBlock && beforeBlock.parentNode===body ? beforeBlock : $('.planner-add-block-btn',body));
                            ensureDayControls(targetDay);
                            if(oldDay && oldDay!==targetDay) ensureDayControls(oldDay);
                            changed=true;
                        }
                    }else if(state.kind==='item'){
                        applyImportHeaderDefaults(state.payload);
                        insertBlockAt(targetDay,plannerBlockPrefill(state.payload.item||{}),beforeBlock);
                        toast('일정 블록 1개를 가져왔습니다.');
                        changed=true;
                    }
                }

                endPlannerStructureDrag();
                finishImportDrag();
                if(changed){
                    $$('.planner-day').forEach(ensureDayControls);
                    renumberDays();
                    updateDayDeleteButtons();
                    syncBudget();
                    syncCountryEditLock();
                    markDirty();
                    if(typeof refreshMap==='function') refreshMap(plannerActiveMapDay||'all');
                }
            }

            function dragPayload(e, payload){
                e.dataTransfer.effectAllowed='copy';
                e.dataTransfer.setData('application/x-tripily-import', JSON.stringify(payload));
                e.dataTransfer.setData('text/plain', payload.kind);
                var importDragState={source:'import',kind:payload.kind,payload:payload};
                /* 왼쪽 일정 가져오기도 중앙 작성 폼의 헤더 모양을 drag ghost로 사용한다. */
                setPlannerNativeDragImage(e,importDragState);
                startPlannerStructureDrag(importDragState);

                /*
                 * 국가 미선택 상태에서도 '일정 가져오기'는 가능해야 하므로
                 * 가져오기 드래그 중에만 중앙 영역 잠금을 임시 해제한다.
                 */
                var center=$('#plannerCenterPanel');
                if(center){
                    center.dataset.importDragActive='1';
                    center.classList.remove('is-country-locked');
                    center.setAttribute('aria-disabled','false');
                }
            }

            function finishImportDrag(){
                endPlannerStructureDrag();
                var center=$('#plannerCenterPanel');

                if(center){
                    delete center.dataset.importDragActive;
                }

                syncCountryLock();
                syncCountryEditLock();
            }

            function importHeaderMeta(plan){
                return {
                    country:plan && plan.country ? plan.country : '',
                    region:plan && plan.region ? plan.region : '',
                    travelerCount:plan && plan.travelerCount
                        ? Number(plan.travelerCount)
                        : 1
                };
            }

            function plannerHasBlocks(){
                return $$('.planner-day .planner-block-card').length > 0;
            }

            /*
             * 가져오기 전에 아직 작성된 블록이 없고 국가도 비어 있으면
             * 원본 일정의 국가 / 지역 / 인원을 자동 입력한다.
             *
             * 제목과 여행기간은 의도적으로 건드리지 않는다.
             */
            function applyImportHeaderDefaults(payload){
                if(!payload || !payload.importMeta) return;
                if(plannerHasBlocks()) return;

                var country=$('#plannerCountry');
                var region=$('#plannerRegion');
                var traveler=$('#plannerTravelerCount');

                if(!country || normalizePlannerText(country.value)) return;

                var meta=payload.importMeta;

                if(meta.country){
                    country.value=meta.country;
                    refreshCountryStatus();
                    refreshRegionOptions(true);
                    centerMapOnPlannerCountry(meta.country);
                    syncForeignCosts();
                }

                if(region && meta.region){
                    /*
                     * 국가 선택 후 refreshRegionOptions()가 region을 활성화하므로
                     * 그 다음 실제 지역명을 넣는다.
                     */
                    region.value=meta.region;
                    updateRegionClear();
                }

                if(traveler){
                    var n=parseInt(meta.travelerCount,10);
                    if(!Number.isFinite(n) || n<1) n=1;
                    if(n>99) n=99;
                    traveler.value=String(n);
                }

                updateCountryClear();
                filterPlans();
                syncCountryLock();
                markDirty();
            }

            /*
             * DAY 아래에 블록이 하나라도 존재하면 국가 변경 금지.
             * 블록을 모두 삭제하면 다시 국가 수정 가능.
             */
            function syncCountryEditLock(){
                var input=$('#plannerCountry');
                var clearBtn=$('#plannerCountryClear');
                var dropdown=$('#plannerCountryDropdown');
                if(!input) return;

                var locked=plannerHasBlocks();

                input.disabled=locked;
                input.setAttribute('aria-disabled',locked ? 'true' : 'false');

                if(clearBtn){
                    clearBtn.disabled=locked;
                    if(locked){
                        clearBtn.classList.add('hidden');
                    }else{
                        updateCountryClear();
                    }
                }

                if(dropdown && locked){
                    dropdown.classList.add('hidden');
                }

                var field=$('#plannerCountryField');
                if(field){
                    field.style.backgroundColor=locked ? '#F8FAFC' : '';
                }
            }

            function plannerImportThumbnailHtml(plan){
                plan=plan||{};

                var raw=String(plan.thumbnailImg||'').trim();
                var countryMark=plan.countryCode
                    || (plan.country ? String(plan.country).substring(0,2) : '—');
                var fallback='<span class="absolute inset-0 flex items-center justify-center text-white text-[10px] font-black">'
                    +escapeImportHtml(countryMark)
                    +'</span>';

                if(!raw){
                    return '<div class="relative w-8 h-8 rounded-lg overflow-hidden shrink-0 flex items-center justify-center" style="background:'+escapeImportHtml(plan.color||'#6369D1')+'">'
                        +fallback
                        +'</div>';
                }

                var imgAttrs='';
                var src='';

                if(raw.indexOf('gplace:')===0){
                    var placeId=raw.substring('gplace:'.length).trim();
                    if(placeId){
                        src='data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///ywAAAAAAQABAAACAUwAOw==';
                        imgAttrs=' data-google-place-id="'+escapeImportHtml(placeId)+'"';
                    }
                }else if(raw.indexOf('flag:')===0){
                    var countryCode=raw.substring('flag:'.length).trim().toUpperCase();
                    if(/^[A-Z]{2}$/.test(countryCode)){
                        src='data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///ywAAAAAAQABAAACAUwAOw==';
                        imgAttrs=' data-country-flag-code="'+escapeImportHtml(countryCode)+'"';
                    }
                }else if(/^https?:\/\//i.test(raw)
                        || raw.indexOf('blob:')===0
                        || raw.indexOf('data:')===0){
                    src=raw;
                }else if(PLANNER_CONTEXT_PATH
                        && raw.indexOf(PLANNER_CONTEXT_PATH + '/')===0){
                    src=raw;
                }else if(raw.charAt(0)==='/'){
                    src=PLANNER_CONTEXT_PATH + raw;
                }else{
                    src=PLANNER_CONTEXT_PATH + '/' + raw;
                }

                if(!src){
                    return '<div class="relative w-8 h-8 rounded-lg overflow-hidden shrink-0 flex items-center justify-center" style="background:'+escapeImportHtml(plan.color||'#6369D1')+'">'
                        +fallback
                        +'</div>';
                }

                return '<div class="relative w-8 h-8 rounded-lg overflow-hidden shrink-0" style="background:'+escapeImportHtml(plan.color||'#6369D1')+'">'
                    +fallback
                    +'<img src="'+escapeImportHtml(src)+'" alt="" loading="lazy" class="absolute inset-0 w-full h-full object-cover"'+imgAttrs+' onerror="this.style.display=\'none\'">'
                    +'</div>';
            }

            function renderSavedPlans(){
                var list=$('#plannerSavedPlansList'); if(!list)return; list.innerHTML='';
                SAVED_PLANS.forEach(function(plan){
                    var card=document.createElement('div'); card.className='planner-saved-plan rounded-xl border border-gray-200 bg-white shadow-sm overflow-hidden';
                    card.dataset.country=plan.country||'';
                    card.dataset.search=(plan.title+' '+plan.country+' '+plan.region+' '+plan.daySchedules.map(function(d){return d.theme+' '+d.items.map(function(i){return i.name+' '+i.location}).join(' ')}).join(' ')).toLowerCase();
                    var head=document.createElement('div'); head.className='planner-saved-plan-head flex items-center gap-2.5 px-3 py-2.5 cursor-pointer hover:bg-gray-50 transition-colors select-none'; head.draggable=true;
                    head.innerHTML='<span class="text-gray-300 text-xs">⠿</span>'+plannerImportThumbnailHtml(plan)+'<div class="flex-1 min-w-0"><p class="text-xs font-bold text-gray-800 truncate">'+escapeImportHtml(plan.title)+'</p><p class="text-[10px] text-gray-400">'+escapeImportHtml(plan.country)+' · '+plan.nights+'박 '+plan.days+'일</p></div><span class="planner-plan-chevron text-gray-400 text-xs">⌄</span>';
                    var body=document.createElement('div'); body.className='planner-saved-plan-body hidden border-t border-gray-100';
                    plan.daySchedules.forEach(function(day){
                        var wrap=document.createElement('div'); wrap.className='border-b border-gray-50 last:border-0';
                        var row=document.createElement('div'); row.className='planner-saved-day flex items-center gap-2 px-3 py-2 cursor-pointer hover:bg-purple-50 select-none'; row.draggable=true;
                        row.innerHTML='<span class="text-gray-200 text-xs">⠿</span><span class="text-[10px] font-black text-white px-1.5 py-0.5 rounded" style="background:'+plan.color+'">D'+day.dayNum+'</span><span class="text-[11px] font-semibold text-gray-700 flex-1 truncate">'+escapeImportHtml(day.theme)+'</span><span class="text-[10px] text-gray-400">'+day.items.length+'개</span><span class="planner-day-chevron text-gray-400 text-xs">⌄</span>';
                        var items=document.createElement('div'); items.className='planner-saved-items hidden pl-6 pr-3 pb-2 flex flex-col gap-1';
                        day.items.forEach(function(item){
                            var cfg=TYPE_CONFIG[item.type]||TYPE_CONFIG.sightseeing; var ir=document.createElement('div'); ir.className='planner-saved-item flex items-center gap-2 px-2 py-1.5 rounded-lg cursor-grab hover:bg-gray-50 border select-none'; ir.draggable=true;
                            ir.innerHTML='<span class="text-gray-200 text-[10px]">⠿</span><span class="w-5 h-5 rounded flex items-center justify-center text-[9px] font-bold" style="background:'+cfg.bg+';color:'+cfg.color+'">'+cfg.label.substring(0,1)+'</span><span class="text-[11px] text-gray-700 flex-1 truncate font-medium">'+escapeImportHtml(item.name)+'</span><span class="text-[10px] text-gray-400">'+escapeImportHtml(item.time||'')+'</span>';
                            ir.addEventListener('dragstart',function(e){
                                e.stopPropagation();
                                dragPayload(e,{
                                    kind:'item',
                                    item:item,
                                    importMeta:importHeaderMeta(plan)
                                });
                            });
                            items.appendChild(ir);
                        });
                        row.addEventListener('click',function(){items.classList.toggle('hidden'); var c=$('.planner-day-chevron',row);if(c)c.textContent=items.classList.contains('hidden')?'⌄':'⌃';});
                        row.addEventListener('dragstart',function(e){
                            e.stopPropagation();
                            dragPayload(e,{
                                kind:'day',
                                day:day,
                                importMeta:importHeaderMeta(plan)
                            });
                        });
                        wrap.appendChild(row); wrap.appendChild(items); body.appendChild(wrap);
                    });
                    head.addEventListener('click',function(){body.classList.toggle('hidden'); var c=$('.planner-plan-chevron',head);if(c)c.textContent=body.classList.contains('hidden')?'⌄':'⌃';});
                    head.addEventListener('dragstart',function(e){
                        dragPayload(e,{
                            kind:'plan',
                            plan:plan,
                            importMeta:importHeaderMeta(plan)
                        });
                    });
                    card.appendChild(head); card.appendChild(body); list.appendChild(card);
                });
                if(SAVED_PLANS.length===0){
                    var empty=document.createElement('div');
                    empty.className='px-3 py-8 text-center text-xs text-gray-400';
                    empty.textContent='가져올 일정이 없습니다.';
                    list.appendChild(empty);
                }

                filterPlans();
            }
            function filterPlans(){
                var q=(search&&search.value||'').trim().toLowerCase();
                var countryInput=$('#plannerCountry');
                var matchedCountry=countryInput ? findPlannerCountry(countryInput.value) : null;
                var selectedCountry=matchedCountry ? matchedCountry.name : '';
                var visible=0;

                $$('.planner-saved-plan').forEach(function(card){
                    var searchOk=!q
                        || (card.dataset.search||card.textContent)
                            .toLowerCase()
                            .indexOf(q)>-1;

                    var countryOk=!selectedCountry
                        || (card.dataset.country||'')===selectedCountry;

                    var ok=searchOk && countryOk;

                    card.classList.toggle('is-hidden',!ok);

                    if(ok) visible++;
                });

                if(count) count.textContent=visible+'개';
            }
            if(search) search.addEventListener('input', filterPlans);
            renderSavedPlans();

            var startDate=$('#plannerStartDate'), endDate=$('#plannerEndDate');
            function syncDates(){
                if(!startDate || !endDate) return;
                // 어느 날짜를 먼저 골라도 선택 가능하게 하고, 서로의 선택 범위만 제한한다.
                endDate.min=startDate.value||'';
                startDate.max=endDate.value||'';
                endDate.removeAttribute('aria-disabled');
                endDate.style.opacity='1';
            }
            if(startDate){
                startDate.addEventListener('change',function(){
                    if(startDate.value && endDate && endDate.value && startDate.value>endDate.value){
                        startDate.value='';
                        if(typeof showToast==='function') showToast('시작 날짜는 종료 날짜보다 늦을 수 없습니다.');
                    }
                    syncDates();
                    markDirty();
                });
            }
            if(endDate){
                endDate.addEventListener('change',function(){
                    if(endDate.value && startDate && startDate.value && endDate.value<startDate.value){
                        endDate.value='';
                        if(typeof showToast==='function') showToast('종료 날짜는 시작 날짜보다 빠를 수 없습니다.');
                    }
                    syncDates();
                    markDirty();
                });
            }
            syncDates();

            var visibility=$('#plannerVisibility');

            function setPlannerVisibility(value,dirty){
                if(!visibility) return;

                var normalized=
                    value==='PRIVATE'
                        ? 'PRIVATE'
                        : 'PUBLIC';

                visibility.dataset.visibility=
                    normalized;

                var isPublic=
                    normalized==='PUBLIC';

                visibility.style.borderColor=
                    isPublic
                        ? '#8B91FF'
                        : '#CBD5E1';

                visibility.style.color=
                    isPublic
                        ? '#555CD6'
                        : '#6B7280';

                visibility.innerHTML=
                    isPublic
                    ? '<span class="w-1.5 h-1.5 rounded-full bg-emerald-400 shrink-0"></span>공개 중<svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="m6 9 6 6 6-6"/></svg>'
                    : '<span class="w-1.5 h-1.5 rounded-full bg-gray-400 shrink-0"></span>비공개<svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="m6 9 6 6 6-6"/></svg>';

                if(dirty!==false){
                    markDirty();
                }
            }

            if(visibility){
                visibility.addEventListener(
                    'click',
                    function(){
                        setPlannerVisibility(
                            visibility.dataset.visibility==='PUBLIC'
                                ? 'PRIVATE'
                                : 'PUBLIC',
                            true
                        );
                    }
                );
            }

            // 새 일정 작성 화면은 Day 1만 비어 있는 상태로 시작한다.
            $$('.planner-day').forEach(function(day){
                $$('.planner-block-card,.planner-block-summary',day).forEach(function(x){x.remove();});
            });

            function setupPhotoGallery(galleryEl) {
                if(!galleryEl || galleryEl.dataset.photoReady==='1') return;
                galleryEl.dataset.photoReady='1';

                var previewImg=$('.planner-photo-preview-img',galleryEl);
                var previewEmpty=$('.planner-photo-empty',galleryEl);
                var thumbs=$$('.planner-photo-thumb',galleryEl);
                var fileInput=$('.planner-photo-file-input',galleryEl);
                var dragIndex=null;
                var didDrag=false;

                if(!fileInput){
                    fileInput=document.createElement('input');
                    fileInput.type='file';
                    fileInput.accept='image/*';
                    fileInput.className='planner-photo-file-input hidden';
                    galleryEl.appendChild(fileInput);
                }

                function getSrc(t){
                    return String(t && t.dataset.src ? t.dataset.src : '').trim();
                }

                function updateThumbState(t){
                    var src=getSrc(t);
                    var img=$('img',t);
                    var label=$('.planner-photo-hover-label',t);

                    if(src){
                        t.classList.add('has-image');
                        t.classList.remove('is-empty');

                        if(!img){
                            img=document.createElement('img');
                            img.alt='블록 이미지';
                            t.insertBefore(img,t.firstChild);
                        }

                        img.src=plannerDraftDisplayImageUrl(src);

                        if(label) label.textContent='이미지 변경하기';
                    }else{
                        t.classList.remove('has-image');
                        t.classList.add('is-empty');

                        if(img) img.remove();

                        if(label) label.textContent='이미지 등록하기';
                    }
                }

                function renderBadge(){
                    thumbs.forEach(function(t,i){
                        t.dataset.index=i;

                        var badge=$('.planner-photo-badge',t);

                        // 현재 첫 번째 위치의 이미지가 항상 대표
                        if(i===0 && getSrc(t)){
                            if(!badge){
                                badge=document.createElement('span');
                                badge.className='planner-photo-badge';
                                badge.textContent='대표';
                                t.appendChild(badge);
                            }
                        }else if(badge){
                            badge.remove();
                        }

                        updateThumbState(t);
                    });
                }

                function active(t){
                    thumbs.forEach(function(x){
                        x.classList.toggle('active',x===t && !!getSrc(x));
                    });

                    var src=getSrc(t);

                    if(previewImg){
                        if(src){
                            previewImg.src=plannerDraftDisplayImageUrl(src);
                            previewImg.style.display='block';
                        }else{
                            previewImg.removeAttribute('src');
                            previewImg.style.display='none';
                        }
                    }

                    if(previewEmpty){
                        previewEmpty.style.display=src ? 'none' : 'flex';
                    }
                }

                function openPicker(t){
                    if(!t || !fileInput) return;

                    fileInput.dataset.targetIndex=t.dataset.index;
                    fileInput.value='';
                    fileInput.click();
                }

                function swap(a,b){
                    if(a==null || b==null || a===b) return;

                    var x=thumbs[a];
                    var y=thumbs[b];

                    if(!x || !y) return;

                    var xSrc=getSrc(x);
                    var ySrc=getSrc(y);
                    var xFile=x._plannerFile || null;
                    var yFile=y._plannerFile || null;

                    /*
                     * blob URL도 이미지 자체의 상태이므로
                     * src / File과 함께 반드시 자리 이동해야 한다.
                     *
                     * 기존에는 objectUrl이 원래 칸에 남아 있어서
                     * 이동 후 한 이미지를 삭제하면 다른 칸으로 이동한
                     * 이미지의 URL까지 revoke되는 문제가 있었다.
                     */
                    var xObjectUrl=x.dataset.objectUrl || '';
                    var yObjectUrl=y.dataset.objectUrl || '';

                    var activeThumb=$('.planner-photo-thumb.active',galleryEl);
                    var activeIndex=activeThumb ? Number(activeThumb.dataset.index) : null;

                    x.dataset.src=ySrc;
                    y.dataset.src=xSrc;

                    x._plannerFile=yFile;
                    y._plannerFile=xFile;

                    x.dataset.objectUrl=yObjectUrl;
                    y.dataset.objectUrl=xObjectUrl;

                    renderBadge();

                    if(activeIndex===a){
                        active(y);
                    }else if(activeIndex===b){
                        active(x);
                    }else{
                        var firstWithImage=thumbs.find(function(t){ return !!getSrc(t); });
                        active(firstWithImage || null);
                    }

                    markDirty();
                }

                function readThumbState(t){
                    return {
                        src:getSrc(t),
                        file:t._plannerFile || null,
                        objectUrl:t.dataset.objectUrl || ''
                    };
                }

                function writeThumbState(t,state){
                    state=state || {
                        src:'',
                        file:null,
                        objectUrl:''
                    };

                    t.dataset.src=state.src || '';
                    t.dataset.objectUrl=state.objectUrl || '';
                    t._plannerFile=state.file || null;
                }

                /*
                 * 사진 슬롯은 항상 왼쪽부터 연속해서 채운다.
                 *
                 * 예)
                 * [빈칸, 사진B, 사진C]
                 * → [사진B, 사진C, 빈칸]
                 */
                function compactThumbs(){
                    var states=[];

                    thumbs.forEach(function(t){
                        var state=readThumbState(t);

                        if(state.src){
                            states.push(state);
                        }
                    });

                    thumbs.forEach(function(t,index){
                        writeThumbState(
                            t,
                            states[index] || null
                        );
                    });

                    renderBadge();

                    var firstWithImage=thumbs.find(function(t){
                        return !!getSrc(t);
                    });

                    active(firstWithImage || null);
                }

                function firstEmptyThumb(){
                    return thumbs.find(function(t){
                        return !getSrc(t);
                    }) || null;
                }

                fileInput.addEventListener('change',function(){
                    var index=Number(fileInput.dataset.targetIndex);
                    var clickedTarget=thumbs[index];
                    var file=fileInput.files && fileInput.files[0];

                    if(!clickedTarget || !file) return;

                    if(file.type && file.type.indexOf('image/')!==0){
                        if(typeof toast==='function'){
                            toast('이미지 파일만 등록할 수 있습니다.');
                        }
                        return;
                    }

                    /*
                     * 이미 사진이 있는 슬롯을 눌렀다면 '변경'이므로
                     * 해당 위치의 사진을 그대로 교체한다.
                     *
                     * 빈 슬롯을 눌러 '등록'하는 경우에는 사용자가
                     * 2번/3번을 눌렀더라도 가장 앞의 빈 슬롯을 우선 사용한다.
                     */
                    var target=getSrc(clickedTarget)
                        ? clickedTarget
                        : firstEmptyThumb();

                    if(!target) return;

                    if(target.dataset.objectUrl){
                        try{
                            URL.revokeObjectURL(
                                target.dataset.objectUrl
                            );
                        }catch(e){}
                    }

                    var objectUrl=
                        URL.createObjectURL(file);

                    target.dataset.objectUrl=
                        objectUrl;

                    target.dataset.src=
                        objectUrl;

                    target._plannerFile=
                        file;

                    /*
                     * 기존 데이터에 빈 슬롯이 끼어 있는 경우까지
                     * 정리해서 1 → 2 → 3 순으로 붙여 둔다.
                     */
                    compactThumbs();
                    markDirty();
                });

                thumbs.forEach(function(t,i){
                    t.dataset.index=i;

                    t.addEventListener('mouseenter',function(){
                        if(getSrc(t)){
                            active(t);
                        }
                    });

                    var deleteBtn=$('.planner-photo-delete',t);

                    if(deleteBtn){
                        function removeThumbImage(e){
                            if(e){
                                e.preventDefault();
                                e.stopPropagation();
                            }

                            if(!getSrc(t)) return;

                            if(t.dataset.objectUrl){
                                try{
                                    URL.revokeObjectURL(t.dataset.objectUrl);
                                }catch(err){}
                            }

                            t.dataset.objectUrl='';
                            t.dataset.src='';
                            t._plannerFile=null;

                            /*
                             * 삭제 후에도 중간 빈칸이 남지 않도록
                             * 뒤쪽 사진을 앞으로 당긴다.
                             */
                            compactThumbs();
                            markDirty();
                        }

                        deleteBtn.addEventListener('click',removeThumbImage);
                        deleteBtn.addEventListener('keydown',function(e){
                            if(e.key==='Enter' || e.key===' '){
                                removeThumbImage(e);
                            }
                        });
                    }

                    t.addEventListener('click',function(e){
                        e.preventDefault();

                        if(didDrag){
                            didDrag=false;
                            return;
                        }

                        active(t);
                        openPicker(t);
                    });

                    t.addEventListener('dragstart',function(e){
                        dragIndex=Number(t.dataset.index);
                        didDrag=true;
                        t.classList.add('dragging');
                        e.dataTransfer.effectAllowed='move';
                    });

                    t.addEventListener('dragend',function(){
                        dragIndex=null;

                        thumbs.forEach(function(x){
                            x.classList.remove('dragging','drag-over');
                        });

                        setTimeout(function(){
                            didDrag=false;
                        },0);
                    });

                    t.addEventListener('dragover',function(e){
                        e.preventDefault();
                        t.classList.add('drag-over');
                    });

                    t.addEventListener('dragleave',function(){
                        t.classList.remove('drag-over');
                    });

                    t.addEventListener('drop',function(e){
                        e.preventDefault();
                        t.classList.remove('drag-over');
                        swap(dragIndex,Number(t.dataset.index));
                    });
                });

                compactThumbs();
            }
            $$('[data-photo-gallery]').forEach(setupPhotoGallery);

            function getPlannerCurrencyCode(){
                var input=$('#plannerCountry');
                if(!input) return '';

                var country=findPlannerCountry(input.value);
                return country && country.currency
                    ? country.currency
                    : '';
            }

            function formatPlannerForeignAmount(value){
                if(!isFinite(value)) return '—';

                return new Intl.NumberFormat(
                    'ko-KR',
                    {maximumFractionDigits:0}
                ).format(Math.ceil(value));
            }

            function getPlannerTravelerCount(){
                var traveler=$('#plannerTravelerCount');
                var count=traveler
                    ? parseInt(traveler.value,10)
                    : 1;

                if(!Number.isFinite(count) || count<1){
                    count=1;
                }

                return count;
            }

            function getPlannerCardCostType(card){
                if(!card) return 'PER_PERSON';
                return card.dataset.costType==='TOTAL'
                    ? 'TOTAL'
                    : 'PER_PERSON';
            }

            function getPlannerActualBlockCost(card){
                if(!card) return 0;

                var costInput=$('.planner-item-cost',card);
                var amount=costInput
                    ? (parseInt(String(costInput.value||'').replace(/[^0-9]/g,''),10)||0)
                    : 0;

                if(getPlannerCardCostType(card)==='PER_PERSON'){
                    amount*=getPlannerTravelerCount();
                }

                return amount;
            }

            function syncForeignCosts(){
                var currencyCode=getPlannerCurrencyCode();
                var rate=currencyCode
                    ? Number(PLANNER_EXCHANGE_RATES[currencyCode])
                    : NaN;

                $$('.planner-block-card').forEach(function(card){
                    var cost=$('.planner-item-cost',card);
                    var foreign=$('.planner-foreign-cost',card);

                    if(!foreign) return;

                    if(!currencyCode || !isFinite(rate)){
                        foreign.textContent='—';
                        return;
                    }

                    var krw=cost
                        ? (parseInt(cost.value.replace(/[^0-9]/g,''),10)||0)
                        : 0;

                    foreign.textContent=
                        formatPlannerForeignAmount(krw*rate)
                        +' '+getPlannerCurrencyLabel(currencyCode);
                });
            }

            function syncBudget(){
                var total=0;

                $$('.planner-block-card').forEach(function(card){
                    total+=getPlannerActualBlockCost(card);
                });

                var out=$('#plannerTotalBudget');
                if(out) out.textContent=money(total);

                var foreignTotal=$('#plannerTotalBudgetForeign');
                if(foreignTotal){
                    var currencyCode=getPlannerCurrencyCode();
                    var rate=currencyCode
                        ? Number(PLANNER_EXCHANGE_RATES[currencyCode])
                        : NaN;

                    foreignTotal.textContent=
                        currencyCode && isFinite(rate)
                            ? '≈ '
                                + formatPlannerForeignAmount(total*rate)
                                + ' '
                                + getPlannerCurrencyLabel(currencyCode)
                            : '—';
                }

                syncForeignCosts();
            }
            syncBudget();

            function clearEmptyHint(dayBody){
                $$('.planner-empty-day-hint', dayBody).forEach(function(x){ x.remove(); });
            }

            function makeEmptyHint(){
                var x=document.createElement('div');
                x.className='planner-empty-day-hint rounded-xl py-6 text-center text-xs text-gray-400';
                x.textContent='새 일정 블록을 추가하거나 왼쪽 일정을 끌어오세요.';
                return x;
            }




            function plannerDisplayImageUrl(rawUrl){
                var url=String(rawUrl || '').trim();

                if(!url){
                    return '';
                }

                if(/^https?:\/\//i.test(url)
                        || url.indexOf('blob:')===0
                        || url.indexOf('data:')===0){
                    return url;
                }

                if(PLANNER_CONTEXT_PATH
                        && url.indexOf(PLANNER_CONTEXT_PATH + '/')===0){
                    return url;
                }

                if(url.charAt(0)==='/'){
                    return PLANNER_CONTEXT_PATH + url;
                }

                return PLANNER_CONTEXT_PATH + '/' + url;
            }

            function applyPlannerExistingImages(card,images){
                if(!card || !Array.isArray(images) || !images.length){
                    return;
                }

                var gallery=$('[data-photo-gallery]',card);
                if(!gallery){
                    return;
                }

                var ordered=images.slice().sort(function(a,b){
                    return Number(a.imageOrder||0)-Number(b.imageOrder||0);
                }).slice(0,3);

                var thumbs=$$('.planner-photo-thumb',gallery);

                thumbs.forEach(function(thumb,index){
                    var image=ordered[index];
                    var src=image && image.imageUrl ? String(image.imageUrl) : '';

                    thumb.dataset.src=src;
                    thumb.dataset.objectUrl='';
                    thumb._plannerFile=null;
                    thumb.classList.toggle('has-image',!!src);
                    thumb.classList.toggle('is-empty',!src);

                    var oldImg=$('img',thumb);
                    if(src){
                        if(!oldImg){
                            oldImg=document.createElement('img');
                            oldImg.alt='블록 이미지';
                            thumb.insertBefore(oldImg,thumb.firstChild);
                        }
                        oldImg.src=plannerDisplayImageUrl(src);
                    }else if(oldImg){
                        oldImg.remove();
                    }

                    var label=$('.planner-photo-hover-label',thumb);
                    if(label){
                        label.textContent=src ? '이미지 변경하기' : '이미지 등록하기';
                    }

                    var badge=$('.planner-photo-badge',thumb);
                    if(index===0 && src){
                        if(!badge){
                            badge=document.createElement('span');
                            badge.className='planner-photo-badge';
                            badge.textContent='대표';
                            thumb.appendChild(badge);
                        }
                    }else if(badge){
                        badge.remove();
                    }
                });

                var first=ordered[0] && ordered[0].imageUrl
                    ? String(ordered[0].imageUrl)
                    : '';
                var previewImg=$('.planner-photo-preview-img',gallery);
                var previewEmpty=$('.planner-photo-empty',gallery);

                if(previewImg){
                    if(first){
                        previewImg.src=plannerDisplayImageUrl(first);
                        previewImg.style.display='block';
                    }else{
                        previewImg.removeAttribute('src');
                        previewImg.style.display='none';
                    }
                }
                if(previewEmpty){
                    previewEmpty.style.display=first ? 'none' : 'flex';
                }
            }

            function createBlock(prefill){
                prefill=prefill||{};
                var template=blockTemplate;
                if(!template) return null;
                var card=template.cloneNode(true);
                card.dataset.itemType=prefill.type||'sightseeing';
                card.dataset.sourceBlockId=prefill.sourceBlockId||'';
                card.querySelectorAll('[id]').forEach(function(el){ el.removeAttribute('id'); });
                card.querySelectorAll('label[for]').forEach(function(el){ el.removeAttribute('for'); });
                var title=$('.planner-item-title',card), label=$('.planner-block-title-label',card);
                var start=$('.planner-start-time',card), end=$('.planner-end-time',card), cost=$('.planner-item-cost',card), note=$('.planner-item-note',card);
                var place=$('.planner-place-search',card);
                if(title) title.value=prefill.title||'';
                if(label) label.textContent=prefill.title||'새 일정';
                if(start) start.value=prefill.startTime||'';
                if(end) end.value=prefill.endTime||'';
                if(cost) cost.value=prefill.cost||'';
                var costModeBtn=$('.planner-cost-mode-btn',card);
                var costType=prefill.costType || card.dataset.costType || 'PER_PERSON';
                card.dataset.costType=costType;
                if(costModeBtn){
                    costModeBtn.dataset.costType=costType;
                    costModeBtn.textContent=costType==='TOTAL' ? '전체 요금' : '1인당 요금';
                }
                if(place){
                    place.value=
                        prefill.placeName
                        || prefill.placeAddress
                        || prefill.place
                        || '';

                    place.dataset.googlePlaceId=
                        prefill.googlePlaceId || '';

                    place.dataset.placeName=
                        prefill.placeName || '';

                    place.dataset.placeAddress=
                        prefill.placeAddress || prefill.place || '';

                    place.dataset.lat=
                        prefill.placeLat!=null
                            ? String(prefill.placeLat)
                            : (prefill.lat!=null ? String(prefill.lat) : '');

                    place.dataset.lng=
                        prefill.placeLng!=null
                            ? String(prefill.placeLng)
                            : (prefill.lng!=null ? String(prefill.lng) : '');
                }
                if(note) note.value=prefill.note||'';
                var foreign=$('.planner-foreign-cost',card); if(foreign) foreign.textContent='—';
                var body=$('[data-block-body]',card); if(body) body.classList.remove('is-collapsed');
                var toggle=$('[data-block-toggle]',card); if(toggle){toggle.textContent='˄';toggle.setAttribute('aria-expanded','true');}
                var cfg=TYPE_CONFIG[card.dataset.itemType]||TYPE_CONFIG.sightseeing;
                var badge=$('.planner-block-type-badge',card); if(badge){badge.textContent=cfg.label;badge.style.background=cfg.bg;badge.style.color=cfg.color;}
                $$('.planner-type-btn',card).forEach(function(btn){btn.classList.toggle('is-selected',btn.dataset.itemType===card.dataset.itemType)});
                setupBlock(card);
                $$('[data-photo-gallery]',card).forEach(setupPhotoGallery);
                return card;
            }

            function addBlockToDay(day, prefill){
                var body=$('.planner-day-body',day); if(!body)return;
                clearEmptyHint(body);
                var card=createBlock(prefill); if(!card)return;
                var addBtn=$('.planner-add-block-btn',body);
                body.insertBefore(card,addBtn||null);
                if(body.classList.contains('is-collapsed')) body.classList.remove('is-collapsed');
                updateDayDeleteButtons();
                syncBudget();
                syncCountryEditLock();
                markDirty();
                var ti=$('.planner-item-title',card); if(ti && !prefill?.title) ti.focus();
                return card;
            }

            function ensureDayControls(day){
                var body=$('.planner-day-body',day); if(!body)return;
                if(!$('.planner-block-card,.planner-block-summary',body) && !$('.planner-empty-day-hint',body)) body.insertBefore(makeEmptyHint(),body.firstChild);
                if(!$('.planner-add-block-btn',body)){
                    var btn=document.createElement('button');
                    btn.type='button'; btn.className='planner-add-block-btn';
                    btn.innerHTML='<span style="font-size:16px;line-height:1">＋</span><span>일정 블록 추가</span>';
                    btn.addEventListener('click',function(){ addBlockToDay(day,{type:'sightseeing'}); });
                    body.appendChild(btn);
                }
                /*
                 * ensureDayControls()는 DAY 초기화 외에도 다시 호출될 수 있다.
                 * 이때 drop 리스너가 중복 등록되면 한 번 드롭했는데 같은 블록이
                 * 2번씩 추가될 수 있으므로 DAY body당 한 번만 등록한다.
                 */
                if(body.dataset.importDropReady!=='1'){
                    body.dataset.importDropReady='1';

                    body.addEventListener('dragover',function(e){
                        if(plannerStructureDrag) return;
                        if(!e.dataTransfer.types.includes('application/x-tripily-import')) return;
                        e.preventDefault();
                        e.dataTransfer.dropEffect='copy';
                        body.classList.add('is-drop-target');
                    });

                    body.addEventListener('dragleave',function(e){
                        if(!body.contains(e.relatedTarget)) body.classList.remove('is-drop-target');
                    });

                    body.addEventListener('drop',function(e){
                        if(plannerStructureDrag) return;
                        var raw=e.dataTransfer.getData('application/x-tripily-import');
                        if(!raw)return;

                        e.preventDefault();
                        e.stopImmediatePropagation();
                        body.classList.remove('is-drop-target');
                        try{
                        var d=JSON.parse(raw);

                        /*
                         * 첫 가져오기라면 원본 일정 기준으로
                         * 국가 / 지역 / 인원을 먼저 채운다.
                         */
                        applyImportHeaderDefaults(d);

                        var startIndex=$$('.planner-day').indexOf(day);
                        if(d.kind==='item'){
                            addBlockToDay(day,{sourceBlockId:d.item.sourceBlockId||null,title:d.item.name,type:d.item.type,startTime:d.item.time||'',endTime:d.item.endTime||'',cost:d.item.cost||'',costType:d.item.costType||'TOTAL',place:d.item.location||'',googlePlaceId:d.item.googlePlaceId||'',placeName:d.item.placeName||'',placeAddress:d.item.placeAddress||'',placeLat:d.item.placeLat,placeLng:d.item.placeLng,note:d.item.note||''});
                            toast('일정 블록 1개를 가져왔습니다.');
                        } else if(d.kind==='day'){
                            (d.day.items||[]).forEach(function(item){addBlockToDay(day,{sourceBlockId:item.sourceBlockId||null,title:item.name,type:item.type,startTime:item.time||'',endTime:item.endTime||'',cost:item.cost||'',costType:item.costType||'TOTAL',place:item.location||'',googlePlaceId:item.googlePlaceId||'',placeName:item.placeName||'',placeAddress:item.placeAddress||'',placeLat:item.placeLat,placeLng:item.placeLng,note:item.note||''});});
                            toast('D'+d.day.dayNum+' 일정을 가져왔습니다.');
                        } else if(d.kind==='plan'){
                            var schedules=d.plan.daySchedules||[];
                            var needed=Math.max(1,schedules.length);
                            while($$('.planner-day').length < startIndex + needed){ $('#plannerAddDay').click(); }
                            var targets=$$('.planner-day');
                            schedules.forEach(function(ds,di){(ds.items||[]).forEach(function(item){addBlockToDay(targets[startIndex+di],{sourceBlockId:item.sourceBlockId||null,title:item.name,type:item.type,startTime:item.time||'',endTime:item.endTime||'',cost:item.cost||'',costType:item.costType||'TOTAL',place:item.location||'',googlePlaceId:item.googlePlaceId||'',placeName:item.placeName||'',placeAddress:item.placeAddress||'',placeLat:item.placeLat,placeLng:item.placeLng,note:item.note||''});});});
                            toast('Day '+(startIndex+1)+'부터 '+needed+'개 Day를 가져왔습니다.');
                        }
                    }catch(err){
                        console.error(err);
                        }finally{
                            finishImportDrag();
                        }
                    });
                }

                updateDayDeleteButtons();
            }


            var plannerDeleteAction=null;
            function openDeleteModal(options,onDelete){
                setupDeleteModal();
                options=options||{};
                var backdrop=$('#plannerConfirmBackdrop');
                var titleEl=$('#plannerConfirmTitle');
                var msgEl=$('#plannerConfirmMessage');
                var warningEl=$('#plannerConfirmWarning');
                var listEl=$('#plannerConfirmList');
                if(!backdrop){
                    if(window.confirm(options.message||options.title||'삭제하시겠습니까?')) onDelete();
                    return;
                }

                plannerDeleteAction=onDelete;
                if(titleEl) titleEl.textContent=options.title||'삭제';

                if(msgEl){
                    msgEl.innerHTML='';
                    if(options.itemName){
                        var strong=document.createElement('strong');
                        strong.textContent='"'+options.itemName+'"';
                        msgEl.appendChild(strong);
                        msgEl.appendChild(document.createTextNode(' 일정을 삭제할까요?'));
                    }else{
                        msgEl.textContent=options.message||'삭제할까요?';
                    }
                }

                if(listEl){
                    listEl.innerHTML='';
                    var items=options.items||[];
                    listEl.classList.toggle('is-visible',items.length>0);
                    items.forEach(function(item){
                        var row=document.createElement('div');
                        row.className='planner-confirm-list-item';

                        var dot=document.createElement('span');
                        dot.className='planner-confirm-list-dot';

                        var name=document.createElement('span');
                        name.className='planner-confirm-list-name';
                        name.textContent=item.name||'제목 없음';

                        row.appendChild(dot);
                        row.appendChild(name);

                        if(item.time){
                            var time=document.createElement('span');
                            time.className='planner-confirm-list-time';
                            time.textContent=item.time;
                            row.appendChild(time);
                        }
                        listEl.appendChild(row);
                    });
                }

                if(warningEl) warningEl.textContent='삭제 후 되돌릴 수 없습니다.';

                backdrop.classList.add('is-open');
                backdrop.setAttribute('aria-hidden','false');
                var cancel=$('#plannerConfirmCancel');
                if(cancel) cancel.focus();
            }
            function closeDeleteModal(){
                var backdrop=$('#plannerConfirmBackdrop'); if(backdrop){backdrop.classList.remove('is-open');backdrop.setAttribute('aria-hidden','true');}
                plannerDeleteAction=null;
            }
            function setupDeleteModal(){
                var backdrop=$('#plannerConfirmBackdrop'), cancel=$('#plannerConfirmCancel'), ok=$('#plannerConfirmDelete');
                if(!backdrop || backdrop.dataset.bound==='1') return;
                backdrop.dataset.bound='1';
                if(cancel) cancel.addEventListener('click',function(e){ e.preventDefault(); e.stopPropagation(); closeDeleteModal(); });
                if(ok) ok.addEventListener('click',function(e){
                    e.preventDefault(); e.stopPropagation();
                    var fn=plannerDeleteAction;
                    closeDeleteModal();
                    if(fn) fn();
                });
                backdrop.addEventListener('click',function(e){ if(e.target===backdrop) closeDeleteModal(); });
                document.addEventListener('keydown',function(e){
                    if(e.key==='Escape' && backdrop.classList.contains('is-open')){
                        e.preventDefault();
                        closeDeleteModal();
                    }
                });
            }
            if(document.readyState==='loading') document.addEventListener('DOMContentLoaded',setupDeleteModal);
            else setupDeleteModal();


            function escapeHtml(value){
                return String(value == null ? '' : value)
                    .replace(/&/g,'&amp;')
                    .replace(/</g,'&lt;')
                    .replace(/>/g,'&gt;')
                    .replace(/"/g,'&quot;')
                    .replace(/'/g,'&#39;');
            }

            function getPlannerPlacesLibrary(){
                if(plannerPlacesLibraryPromise){
                    return plannerPlacesLibraryPromise;
                }

                if(!window.google
                        || !google.maps
                        || typeof google.maps.importLibrary!=='function'){

                    return Promise.reject(
                        new Error(
                            'Google Maps JavaScript API를 불러오지 못했습니다.'
                        )
                    );
                }

                plannerPlacesLibraryPromise=
                    google.maps.importLibrary('places');

                return plannerPlacesLibraryPromise;
            }

            function plannerSelectedPlacePoint(input){
                if(!input) return null;

                var latValue=input.dataset.lat;
                var lngValue=input.dataset.lng;

                /*
                 * Number('')는 0이 되므로,
                 * 빈 장소가 (0, 0)의 가짜 핀으로 생성되지 않게
                 * 숫자 변환 전에 빈 값부터 검사한다.
                 */
                if(latValue==null || lngValue==null
                        || String(latValue).trim()===''
                        || String(lngValue).trim()===''){
                    return null;
                }

                var lat=Number(latValue);
                var lng=Number(lngValue);

                if(!isFinite(lat) || !isFinite(lng)){
                    return null;
                }

                return {
                    googlePlaceId:
                        input.dataset.googlePlaceId || '',
                    name:
                        input.dataset.placeName
                        || input.value
                        || '장소',
                    address:
                        input.dataset.placeAddress || '',
                    lat:lat,
                    lng:lng
                };
            }

            function updatePlannerPlacePinState(card){
                if(!card) return;

                var hiddenInput=
                    $('.planner-place-search',card);

                var icon=
                    $('.planner-place-pin-icon',card);

                if(!hiddenInput || !icon){
                    return;
                }

                var selected=
                    !!plannerSelectedPlacePoint(hiddenInput);

                var body=
                    $('.planner-place-pin-body',icon);

                var dot=
                    $('.planner-place-pin-dot',icon);

                icon.setAttribute(
                    'stroke',
                    selected ? '#6369D1' : '#9CA3AF'
                );

                if(body){
                    body.setAttribute(
                        'fill',
                        selected ? '#6369D1' : 'none'
                    );
                }

                if(dot){
                    dot.setAttribute(
                        'fill',
                        selected ? '#FFFFFF' : 'none'
                    );

                    dot.setAttribute(
                        'stroke',
                        selected ? '#FFFFFF' : '#9CA3AF'
                    );
                }
            }

            function clearPlannerSelectedPlace(
                    input,
                    preserveText){

                if(!input) return;

                var currentText=
                    preserveText
                        ? input.value
                        : '';

                input.dataset.googlePlaceId='';
                input.dataset.placeName='';
                input.dataset.placeAddress='';
                input.dataset.lat='';
                input.dataset.lng='';

                input.value=currentText;

                var card=
                    input.closest('.planner-block-card');

                updatePlannerPlacePinState(card);
            }

            function clearPlannerMapSearchMarkers(){
                mapSearchMarkers.forEach(function(marker){
                    if(marker.__plannerSearchInfoWindow){
                        marker.__plannerSearchInfoWindow.close();
                    }
                    marker.setMap(null);
                });

                mapSearchMarkers=[];
            }

            function copyPlannerPlaceSelection(sourceInput,targetInput){
                if(!sourceInput || !targetInput){
                    return false;
                }

                var point=plannerSelectedPlacePoint(sourceInput);
                if(!point){
                    return false;
                }

                targetInput.value=
                    sourceInput.value
                    || point.name
                    || '';

                targetInput.dataset.googlePlaceId=
                    sourceInput.dataset.googlePlaceId || '';

                targetInput.dataset.placeName=
                    sourceInput.dataset.placeName
                    || point.name
                    || '';

                targetInput.dataset.placeAddress=
                    sourceInput.dataset.placeAddress
                    || point.address
                    || '';

                targetInput.dataset.lat=
                    sourceInput.dataset.lat
                    || String(point.lat);

                targetInput.dataset.lng=
                    sourceInput.dataset.lng
                    || String(point.lng);

                updatePlannerPlacePinState(
                    targetInput.closest('.planner-block-card')
                );

                return true;
            }

            function plannerPreviousAccommodationInput(card){
                if(!card){
                    return null;
                }

                var cards=$$('.planner-block-card');
                var currentIndex=cards.indexOf(card);

                if(currentIndex<0){
                    return null;
                }

                for(var i=currentIndex-1;i>=0;i--){
                    var previousCard=cards[i];

                    if(previousCard.dataset.itemType!=='accommodation'){
                        continue;
                    }

                    var previousInput=
                        $('.planner-place-search',previousCard);

                    if(plannerSelectedPlacePoint(previousInput)){
                        return previousInput;
                    }
                }

                return null;
            }

            function inheritPreviousAccommodationPlace(card){
                if(!card || card.dataset.itemType!=='accommodation'){
                    return false;
                }

                var currentInput=
                    $('.planner-place-search',card);

                var previousInput=
                    plannerPreviousAccommodationInput(card);

                if(!currentInput || !previousInput){
                    return false;
                }

                return copyPlannerPlaceSelection(
                    previousInput,
                    currentInput
                );
            }

            function plannerPreviousPlacePoint(card){
                if(!card) return null;

                var day=
                    card.closest('.planner-day');

                if(!day) return null;

                var cards=
                    $$('.planner-block-card',day);

                var index=
                    cards.indexOf(card);

                for(var i=index-1;i>=0;i--){
                    var input=
                        $('.planner-place-search',cards[i]);

                    var point=
                        plannerSelectedPlacePoint(input);

                    if(point){
                        return point;
                    }
                }

                return null;
            }

            function plannerSearchBiasPoint(card){
                var previous=
                    plannerPreviousPlacePoint(card);

                if(previous){
                    return {
                        lat:previous.lat,
                        lng:previous.lng
                    };
                }

                if(map && map.getCenter()){
                    var center=map.getCenter();

                    return {
                        lat:typeof center.lat==='function'
                            ? center.lat()
                            : center.lat,
                        lng:typeof center.lng==='function'
                            ? center.lng()
                            : center.lng
                    };
                }

                return null;
            }

            function showPlannerPlaceSearchResultsOnMap(
                    card,
                    places){

                clearPlannerMapSearchMarkers();

                if(!map || !Array.isArray(places)){
                    return;
                }

                var bounds=
                    new google.maps.LatLngBounds();

                var has=false;

                places.forEach(function(place,index){
                    if(!place || !place.location){
                        return;
                    }

                    var lat=
                        typeof place.location.lat==='function'
                            ? place.location.lat()
                            : place.location.lat;

                    var lng=
                        typeof place.location.lng==='function'
                            ? place.location.lng()
                            : place.location.lng;

                    if(!isFinite(Number(lat))
                            || !isFinite(Number(lng))){
                        return;
                    }

                    var marker=
                        new google.maps.Marker({
                            position:{
                                lat:Number(lat),
                                lng:Number(lng)
                            },
                            map:map,
                            title:
                                place.displayName
                                || place.formattedAddress
                                || '검색 결과',
                            label:{
                                text:String.fromCharCode(65+index),
                                color:'#FFFFFF',
                                fontWeight:'bold'
                            },
                            icon:{
                                path:
                                    google.maps.SymbolPath.CIRCLE,
                                scale:13,
                                fillColor:'#F59E0B',
                                fillOpacity:.95,
                                strokeColor:'#FFFFFF',
                                strokeWeight:2
                            },
                            zIndex:200+index
                        });

                    /*
                     * 지도 검색 결과 A~F 핀도 일정에 이미 지정된 핀과
                     * 동일한 상세정보 hover UI를 사용한다.
                     */
                    var searchPoint={
                        googlePlaceId:place.id || '',
                        name:place.displayName
                            || place.formattedAddress
                            || '검색 결과',
                        address:place.formattedAddress || '',
                        lat:Number(lat),
                        lng:Number(lng)
                    };
                    var searchInfoId=
                        'planner-search-map-info-'+(++plannerMapInfoSeq);
                    var searchInfoWindow=
                        new google.maps.InfoWindow({
                            content:plannerPlaceInfoHtml(
                                searchPoint,
                                null,
                                searchInfoId
                            ),
                            disableAutoPan:true
                        });
                    var searchInfoCloseTimer=null;
                    var searchMarkerHovered=false;
                    var searchInfoHovered=false;

                    marker.__plannerSearchInfoWindow=
                        searchInfoWindow;

                    function cancelSearchInfoClose(){
                        if(searchInfoCloseTimer){
                            clearTimeout(searchInfoCloseTimer);
                            searchInfoCloseTimer=null;
                        }
                    }

                    function scheduleSearchInfoClose(){
                        cancelSearchInfoClose();
                        searchInfoCloseTimer=setTimeout(function(){
                            if(!searchMarkerHovered
                                    && !searchInfoHovered){
                                searchInfoWindow.close();
                            }
                        },220);
                    }

                    searchInfoWindow.addListener(
                        'domready',
                        function(){
                            var infoRoot=
                                document.getElementById(
                                    searchInfoId
                                );

                            if(!infoRoot
                                    || infoRoot.dataset.hoverBound==='1'){
                                return;
                            }

                            infoRoot.dataset.hoverBound='1';
                            infoRoot.addEventListener(
                                'mouseenter',
                                function(){
                                    searchInfoHovered=true;
                                    cancelSearchInfoClose();
                                }
                            );
                            infoRoot.addEventListener(
                                'mouseleave',
                                function(){
                                    searchInfoHovered=false;
                                    scheduleSearchInfoClose();
                                }
                            );
                        }
                    );

                    searchInfoWindow.addListener(
                        'closeclick',
                        function(){
                            searchMarkerHovered=false;
                            searchInfoHovered=false;
                            cancelSearchInfoClose();
                        }
                    );

                    marker.addListener(
                        'mouseover',
                        function(){
                            searchMarkerHovered=true;
                            cancelSearchInfoClose();

                            searchInfoWindow.setContent(
                                plannerPlaceInfoHtml(
                                    searchPoint,
                                    null,
                                    searchInfoId
                                )
                            );
                            searchInfoWindow.open(map,marker);

                            fetchPlannerPlaceDetails(searchPoint)
                                .then(function(details){
                                    if(searchMarkerHovered
                                            || searchInfoHovered){
                                        searchInfoWindow.setContent(
                                            plannerPlaceInfoHtml(
                                                searchPoint,
                                                details,
                                                searchInfoId
                                            )
                                        );
                                    }
                                })
                                .catch(function(error){
                                    console.warn(
                                        '지도 검색 핀 상세정보 조회 실패:',
                                        error
                                    );
                                    if(searchMarkerHovered
                                            || searchInfoHovered){
                                        searchInfoWindow.setContent(
                                            plannerPlaceInfoHtml(
                                                searchPoint,
                                                false,
                                                searchInfoId
                                            )
                                        );
                                    }
                                });
                        }
                    );

                    marker.addListener(
                        'mouseout',
                        function(){
                            searchMarkerHovered=false;
                            scheduleSearchInfoClose();
                        }
                    );

                    marker.addListener(
                        'click',
                        function(){

                            var hiddenInput=
                                $('.planner-place-search',card);

                            applySelectedGooglePlace(
                                hiddenInput,
                                place
                            );
                        }
                    );

                    mapSearchMarkers.push(marker);

                    bounds.extend(
                        marker.getPosition()
                    );

                    has=true;
                });

                /*
                 * 검색 후보가 여러 개면 후보 전체가 보이도록,
                 * 하나면 해당 장소 근처로 확대한다.
                 */
                if(has){
                    if(mapSearchMarkers.length===1){
                        map.setCenter(
                            mapSearchMarkers[0].getPosition()
                        );
                        map.setZoom(15);
                    }else{
                        map.fitBounds(bounds);
                    }
                }
            }

            function searchPlannerPlaces(
                    card,
                    query,
                    requestState,
                    onResults){

                query=String(query || '').trim();

                if(query.length<2){
                    clearPlannerMapSearchMarkers();
                    return;
                }

                var requestId=
                    ++requestState.id;

                getPlannerPlacesLibrary()
                .then(function(placesLib){
                    if(!placesLib
                            || !placesLib.Place
                            || typeof placesLib.Place.searchByText!=='function'){

                        return null;
                    }

                    var biasPoint=
                        plannerSearchBiasPoint(card);

                    var request={
                        textQuery:query,
                        fields:[
                            'id',
                            'displayName',
                            'formattedAddress',
                            'location'
                        ],
                        language:'ko',
                        maxResultCount:6
                    };

                    if(biasPoint){
                        request.locationBias={
                            center:biasPoint,
                            radius:5000
                        };
                    }

                    return placesLib.Place
                        .searchByText(request);
                })
                .then(function(result){
                    if(!result
                            || requestId!==requestState.id){
                        return;
                    }

                    var places=result.places || [];

                    showPlannerPlaceSearchResultsOnMap(
                        card,
                        places
                    );

                    if(typeof onResults==='function'){
                        onResults(places);
                    }
                })
                .catch(function(error){
                    if(requestId!==requestState.id){
                        return;
                    }

                    console.error(
                        '지도 장소검색 결과 표시 실패:',
                        error
                    );

                    clearPlannerMapSearchMarkers();
                });
            }

            function applySelectedGooglePlace(
                    hiddenInput,
                    place){

                if(!hiddenInput || !place){
                    return;
                }

                if(!place.location){
                    if(typeof toast==='function'){
                        toast(
                            '선택한 장소의 위치 정보를 가져오지 못했습니다.'
                        );
                    }
                    return;
                }

                var lat=
                    typeof place.location.lat==='function'
                        ? place.location.lat()
                        : place.location.lat;

                var lng=
                    typeof place.location.lng==='function'
                        ? place.location.lng()
                        : place.location.lng;

                var placeName=
                    place.displayName
                    || place.formattedAddress
                    || '';

                hiddenInput.value=placeName;

                hiddenInput.dataset.googlePlaceId=
                    place.id || '';

                hiddenInput.dataset.placeName=
                    placeName;

                hiddenInput.dataset.placeAddress=
                    place.formattedAddress || '';

                hiddenInput.dataset.lat=
                    String(lat);

                hiddenInput.dataset.lng=
                    String(lng);

                var card=
                    hiddenInput.closest(
                        '.planner-block-card'
                    );

                if(card){
                    var title=
                        $('.planner-item-title',card);

                    var label=
                        $('.planner-block-title-label',card);

                    if(title && !title.value.trim()){
                        title.value=placeName;

                        if(label){
                            label.textContent=placeName;
                        }
                    }
                }

                clearPlannerMapSearchMarkers();
                updatePlannerPlacePinState(card);

                markDirty();

                if(typeof refreshMap==='function'){
                    refreshMap('all');
                }
            }

            function setupPlannerPlaceSearch(card){
                if(!card) return;

                var input=
                    $('.planner-place-search',card);

                var results=
                    $('.planner-place-results',card);

                if(!input
                        || !results
                        || input.dataset.placeBound==='1'){
                    return;
                }

                input.dataset.placeBound='1';

                /*
                 * 블록/Day의 overflow에 잘리지 않도록
                 * 검색결과 패널을 body 직속으로 이동한다.
                 */
                document.body.appendChild(results);

                results.dataset.ownerInputId=
                    input.dataset.placeSearchId
                    || ('placeSearch_'+Math.random().toString(36).slice(2));

                input.dataset.placeSearchId=
                    results.dataset.ownerInputId;

                var searchTimer=null;
                var requestState={
                    id:0
                };

                function positionResults(){
                    if(!input || !results) return;

                    var rect=input.getBoundingClientRect();

                    var viewportHeight=
                        window.innerHeight
                        || document.documentElement.clientHeight;

                    var viewportWidth=
                        window.innerWidth
                        || document.documentElement.clientWidth;

                    var gap=8;
                    var margin=12;

                    var desiredWidth=
                        Math.max(
                            280,
                            rect.width+42
                        );

                    /*
                     * 화면 오른쪽으로 넘어가지 않게 폭도 제한한다.
                     */
                    var left=
                        Math.max(
                            margin,
                            rect.left-34
                        );

                    if(left+desiredWidth>viewportWidth-margin){
                        desiredWidth=
                            Math.max(
                                240,
                                viewportWidth-left-margin
                            );
                    }

                    var spaceBelow=
                        viewportHeight
                        - rect.bottom
                        - margin;

                    var spaceAbove=
                        rect.top
                        - margin;

                    /*
                     * 최소 180px 정도의 공간이 아래에 없고
                     * 위쪽 공간이 더 넓다면 위로 펼친다.
                     */
                    var openUp=
                        spaceBelow<180
                        && spaceAbove>spaceBelow;

                    var availableHeight=
                        openUp
                            ? Math.max(
                                120,
                                spaceAbove-gap
                            )
                            : Math.max(
                                120,
                                spaceBelow-gap
                            );

                    var maxHeight=
                        Math.min(
                            300,
                            availableHeight
                        );

                    results.style.left=
                        left+'px';

                    results.style.width=
                        desiredWidth+'px';

                    results.style.maxHeight=
                        maxHeight+'px';

                    if(openUp){
                        /*
                         * 높이가 실제로 계산된 뒤 입력창 위에 붙인다.
                         */
                        results.style.top='auto';
                        results.style.bottom=
                            (viewportHeight-rect.top+gap)+'px';
                    }else{
                        results.style.bottom='auto';
                        results.style.top=
                            (rect.bottom+gap)+'px';
                    }
                }

                function closeResults(){
                    results.classList.remove('is-open');
                    results.innerHTML='';
                }

                function renderResults(places){
                    results.innerHTML='';

                    if(!Array.isArray(places)
                            || places.length===0){

                        results.innerHTML=
                            '<div class="planner-place-result-message">'
                            +'검색 결과가 없습니다.'
                            +'</div>';

                        positionResults();
                        results.classList.add('is-open');
                        return;
                    }

                    places.forEach(function(place,index){
                        var button=
                            document.createElement('button');

                        button.type='button';
                        button.className='planner-place-result';

                        var name=
                            place.displayName
                            || place.formattedAddress
                            || '장소';

                        var address=
                            place.formattedAddress || '';

                        var label=
                            String.fromCharCode(65+index);

                        button.innerHTML=
                            '<span class="planner-place-result-row">'
                            +'<span class="planner-place-result-badge">'
                            +label
                            +'</span>'
                            +'<span class="planner-place-result-copy">'
                            +'<span class="planner-place-result-name">'
                            +escapeHtml(name)
                            +'</span>'
                            +(address
                                ? '<span class="planner-place-result-address">'
                                    +escapeHtml(address)
                                    +'</span>'
                                : '')
                            +'</span>'
                            +'</span>';

                        button.addEventListener(
                            'mousedown',
                            function(event){
                                /*
                                 * input blur 전에 click이 처리되게 한다.
                                 */
                                event.preventDefault();
                            }
                        );

                        button.addEventListener(
                            'click',
                            function(){
                                applySelectedGooglePlace(
                                    input,
                                    place
                                );

                                closeResults();
                            }
                        );

                        results.appendChild(button);
                    });

                    positionResults();
                    results.classList.add('is-open');
                }

                function runSearch(){
                    var query=
                        input.value.trim();

                    if(query.length<2){
                        closeResults();
                        clearPlannerMapSearchMarkers();
                        return;
                    }

                    results.innerHTML=
                        '<div class="planner-place-result-message">'
                        +'장소 검색 중...'
                        +'</div>';

                    positionResults();
                    results.classList.add('is-open');

                    searchPlannerPlaces(
                        card,
                        query,
                        requestState,
                        renderResults
                    );
                }

                input.addEventListener(
                    'input',
                    function(){

                        var value=
                            input.value.trim();

                        var selectedName=
                            String(
                                input.dataset.placeName || ''
                            ).trim();

                        /*
                         * 확정 장소의 이름을 사용자가 수정하는 순간
                         * 장소 선택 상태만 해제한다.
                         * 검색어 자체는 그대로 유지한다.
                         */
                        if(selectedName
                                && value!==selectedName){

                            clearPlannerSelectedPlace(
                                input,
                                true
                            );

                            updatePlannerPlacePinState(
                                card
                            );

                            /*
                             * 확정 핀만 다시 그림.
                             * 이전 블록의 확정 핀은 그대로 유지된다.
                             */
                            refreshMap('all');
                        }

                        if(!value){
                            clearPlannerSelectedPlace(
                                input,
                                false
                            );

                            closeResults();
                            clearPlannerMapSearchMarkers();

                            refreshMap('all');
                            markDirty();
                            return;
                        }

                        if(!plannerSelectedPlacePoint(input)){
                            updatePlannerPlacePinState(
                                card
                            );
                        }

                        if(searchTimer){
                            window.clearTimeout(
                                searchTimer
                            );
                        }

                        searchTimer=
                            window.setTimeout(
                                runSearch,
                                320
                            );

                        markDirty();
                    }
                );

                input.addEventListener(
                    'focus',
                    function(){
                        if(input.value.trim().length>=2
                                && !plannerSelectedPlacePoint(input)){
                            runSearch();
                        }
                    }
                );

                input.addEventListener(
                    'keydown',
                    function(event){
                        if(event.key==='Escape'){
                            closeResults();
                            clearPlannerMapSearchMarkers();
                        }
                    }
                );

                /*
                 * 수정/가져오기 데이터로 이미 장소가 있으면
                 * 핀 아이콘을 바로 채운 상태로 표시한다.
                 */
                updatePlannerPlacePinState(card);

                window.addEventListener(
                    'resize',
                    function(){
                        if(results.classList.contains('is-open')){
                            positionResults();
                        }
                    }
                );

                window.addEventListener(
                    'scroll',
                    function(){
                        if(results.classList.contains('is-open')){
                            positionResults();
                        }
                    },
                    true
                );
            }

            function setupBlock(card){
                var body=$('[data-block-body]',card), toggle=$('[data-block-toggle]',card), del=$('.planner-block-delete',card), header=$('.planner-block-header',card), title=$('.planner-item-title',card), label=$('.planner-block-title-label',card), badge=$('.planner-block-type-badge',card);
                if(toggle&&body) toggle.addEventListener('click',function(){var c=body.classList.toggle('is-collapsed');toggle.textContent=c?'⌄':'˄';toggle.title=c?'블록 펼치기':'블록 접기';toggle.setAttribute('aria-expanded',c?'false':'true')});
                if(header&&body) header.addEventListener('click',function(e){ if(e.target.closest('button')) return; var c=body.classList.toggle('is-collapsed'); if(toggle){toggle.textContent=c?'⌄':'˄';toggle.title=c?'블록 펼치기':'블록 접기';toggle.setAttribute('aria-expanded',c?'false':'true');} });
                if(del) del.addEventListener('click',function(e){
                    e.stopPropagation();
                    var blockName=(label&&label.textContent?label.textContent.trim():'') || (title&&title.value?title.value.trim():'') || '제목 없음';
                    openDeleteModal({
                        title:'일정 삭제',
                        itemName:blockName
                    },function(){
                        card.remove();
                        updateDayDeleteButtons();
                        syncBudget();
                        markDirty();
                    });
                });
                if(title) title.addEventListener('input',function(){ if(label)label.textContent=title.value||'제목 없음';markDirty(); });
                $$('.planner-type-btn',card).forEach(function(btn){
                    if(btn.dataset.itemType===card.dataset.itemType) btn.classList.add('is-selected');
                    btn.addEventListener('click',function(){
                        var cfg=TYPE_CONFIG[btn.dataset.itemType];
                        card.dataset.itemType=btn.dataset.itemType;

                        $$('.planner-type-btn',card).forEach(function(x){
                            x.classList.toggle('is-selected',x===btn);
                        });

                        if(badge){
                            badge.textContent=cfg.label;
                            badge.style.background=cfg.bg;
                            badge.style.color=cfg.color;
                        }

                        /*
                         * 숙소 블록으로 변경했을 때 앞쪽 일정에 이미 선택된
                         * 숙소가 있으면 그 장소 snapshot을 그대로 이어받는다.
                         * 다른 숙소를 쓰려면 사용자가 장소검색에서 다시 선택하면 된다.
                         */
                        if(btn.dataset.itemType==='accommodation'){
                            inheritPreviousAccommodationPlace(card);
                        }

                        /*
                         * 이미 장소가 선택되어 지도에 핀이 있는 블록이라면
                         * 타입 변경 즉시 현재 지도 필터를 유지한 채 다시 그린다.
                         */
                        if(plannerSelectedPlacePoint($('.planner-place-search',card))){
                            refreshMap(plannerActiveMapDay);
                        }

                        markDirty();
                    });
                });
                var cost=$('.planner-item-cost',card);
                if(cost) cost.addEventListener('input',function(){
                    cost.value=cost.value.replace(/[^0-9]/g,'');
                    syncBudget();
                    markDirty();
                });

                var costModeBtn=$('.planner-cost-mode-btn',card);
                if(costModeBtn){
                    costModeBtn.addEventListener('click',function(){
                        var current=getPlannerCardCostType(card);
                        var next=current==='PER_PERSON' ? 'TOTAL' : 'PER_PERSON';
                        card.dataset.costType=next;
                        costModeBtn.dataset.costType=next;
                        costModeBtn.textContent=next==='TOTAL' ? '전체 요금' : '1인당 요금';
                        syncBudget();
                        markDirty();
                    });
                }

                $$('input,textarea',card).forEach(function(el){ if(el!==cost) el.addEventListener('input',markDirty); });

                /*
                 * 작성/수정 중인 블록도 왼쪽에서 가져오는 블록과 완전히 같은 드래그 UI를 쓴다.
                 * 별도 순서변경 버튼은 만들지 않고 기존 헤더 전체(버튼 제외)를 드래그 영역으로 사용한다.
                 */
                if(header && header.dataset.structureDragReady!=='1'){
                    header.dataset.structureDragReady='1';
                    header.setAttribute('draggable','true');
                    header.title='드래그하여 블록 순서 변경 / 다른 DAY로 이동';

                    var blockHeadLeft=header.firstElementChild;
                    if(blockHeadLeft && !$('.planner-structure-grip',blockHeadLeft)){
                        var blockGrip=document.createElement('span');
                        blockGrip.className='planner-structure-grip';
                        blockGrip.setAttribute('aria-hidden','true');
                        blockGrip.textContent='⠿';
                        blockHeadLeft.insertBefore(blockGrip,blockHeadLeft.firstChild);
                    }
                }

                setupPlannerPlaceSearch(card);
            }
            $$('.planner-block-card').forEach(setupBlock);

            function updateAddDayButton(){
                var btn=$('#plannerAddDay'); if(!btn)return;
                var next=$$('.planner-day').length+1;
                var label=$('.planner-add-day-label',btn);
                if(label) label.textContent='Day '+next+' 추가';
                else {
                    var nodes=Array.prototype.slice.call(btn.childNodes).filter(function(n){return n.nodeType===3 && n.textContent.trim()});
                    if(nodes.length) nodes[nodes.length-1].textContent=' Day '+next+' 추가';
                }
            }

            function updateDayDeleteButtons(){
                var days=$$('.planner-day');
                days.forEach(function(day){
                    var del=$('.planner-day-delete',day);
                    if(!del) return;
                    var blockCount=$$('.planner-block-card,.planner-block-summary',day).length;
                    var hidden=(days.length===1 && blockCount===0);
                    del.style.display=hidden?'none':'';
                    del.disabled=hidden;
                    del.style.pointerEvents=hidden?'none':'';
                    del.setAttribute('aria-hidden',hidden?'true':'false');
                });
            }

            function renumberDays(){
                $$('.planner-day').forEach(function(day,i){
                    var oldNo=Number(day.dataset.dayNumber||i+1);
                    var newNo=i+1;
                    day.dataset.dayNumber=String(newNo);
                    day.dataset.dayOrder=String(newNo);

                    /*
                     * DAY 헤더 앞에 드래그 그립(span)이 추가된 뒤에는
                     * ':first-child'가 번호 배지가 아니라 그립을 가리키게 된다.
                     * 번호 배지를 전용 클래스로 찾아 삭제/이동/가져오기 후에도
                     * D1, D2 ... 가 현재 화면 순서와 항상 일치하도록 갱신한다.
                     */
                    var badge=day.querySelector('.planner-day-number-badge');
                    if(!badge){
                        var header=day.querySelector('.planner-day-header');
                        if(header){
                            badge=Array.prototype.slice.call(header.children).find(function(child){
                                return child.tagName==='DIV' && child.classList.contains('w-7') && child.classList.contains('h-7');
                            })||null;
                            if(badge) badge.classList.add('planner-day-number-badge');
                        }
                    }
                    if(badge) badge.textContent='D'+newNo;

                    /* 사용자가 직접 바꾼 제목은 유지하고, 기본 Day N 제목만 함께 재번호화한다. */
                    var title=day.querySelector('.planner-day-title');
                    if(title && !title.querySelector('input')){
                        var titleText=(title.textContent||'').trim();
                        if(/^Day\s+\d+$/i.test(titleText)){
                            title.textContent='Day '+newNo;
                        }
                    }
                });
                updateAddDayButton(); rebuildMapFilter(); updateDayDeleteButtons();
            }

            function enableDayTitleEdit(day){
                var title=$('.planner-day-title',day);
                if(!title || title.dataset.editReady==='1') return;
                title.dataset.editReady='1';
                title.addEventListener('click',function(e){
                    e.stopPropagation();
                    if(title.querySelector('input')) return;
                    var before=(title.textContent||'').trim();
                    var input=document.createElement('input');
                    input.type='text'; input.className='planner-day-title-input'; input.value=before; input.maxLength=100;
                    var resizeTitleInput=function(){input.style.width=Math.min(420,Math.max(72,(input.value.length+1)*14))+'px';}; resizeTitleInput(); input.addEventListener('input',resizeTitleInput);
                    title.textContent=''; title.appendChild(input); input.focus(); input.select();
                    var finish=function(save){
                        if(!input.isConnected) return;
                        var value=save ? input.value.trim() : before;
                        title.textContent=value || before || ('Day '+day.dataset.dayNumber);
                        if(save && title.textContent!==before) markDirty();
                    };
                    input.addEventListener('click',function(ev){ev.stopPropagation();});
                    input.addEventListener('keydown',function(ev){
                        if(ev.key==='Enter'){ev.preventDefault(); finish(true);}
                        else if(ev.key==='Escape'){ev.preventDefault(); finish(false);}
                    });
                    input.addEventListener('blur',function(){finish(true);});
                });
                var editIcon=$('.planner-day-edit-icon',day);
                if(editIcon && editIcon.dataset.editReady!=='1'){
                    editIcon.dataset.editReady='1';
                    editIcon.addEventListener('click',function(e){
                        e.preventDefault(); e.stopPropagation();
                        title.click();
                    });
                }
            }

            function clearDayDragState(){
                $$('.planner-day').forEach(function(d){
                    d.classList.remove('is-day-dragging','is-day-drag-over','planner-structure-source');
                });
            }

            function setupDay(day){
                if(day.dataset.dayReady==='1') return; day.dataset.dayReady='1';
                var h=$('.planner-day-header',day), b=$('.planner-day-body',day), del=$('.planner-day-delete',day);
                if(h){
                    h.setAttribute('draggable','true');
                    h.title='드래그하여 DAY 순서 변경';

                    if(!$('.planner-structure-grip',h)){
                        var dayGrip=document.createElement('span');
                        dayGrip.className='planner-structure-grip';
                        dayGrip.setAttribute('aria-hidden','true');
                        dayGrip.textContent='⠿';
                        h.insertBefore(dayGrip,h.firstChild);
                    }

                }
                if(h&&b) h.addEventListener('click',function(e){ if(e.target.closest('.planner-day-delete') || e.target.closest('.planner-day-title') || e.target.closest('.planner-day-edit-icon'))return; b.classList.toggle('is-collapsed'); });
                enableDayTitleEdit(day);
                if(del) del.addEventListener('click',function(e){
                    e.stopPropagation();
                    var days=$$('.planner-day');
                    var currentBlockCount=$$('.planner-block-card,.planner-block-summary',day).length;
                    if(days.length===1 && currentBlockCount===0) return;
                    var dayNo=day.dataset.dayNumber||'';
                    var childItems=$$('.planner-block-card',day).map(function(card){
                        var nameEl=$('.planner-block-title-label',card);
                        var timeEl=$('.planner-item-start-time',card);
                        return {
                            name:(nameEl&&nameEl.textContent?nameEl.textContent.trim():'') || '제목 없음',
                            time:(timeEl&&timeEl.value?timeEl.value:'')
                        };
                    });
                    openDeleteModal({
                        title:'Day '+dayNo+' 삭제',
                        message:childItems.length>0
                            ? '하위 일정 '+childItems.length+'개도 함께 삭제됩니다.'
                            : (days.length<=1 ? '마지막 DAY의 일정 블록을 모두 삭제할까요?' : '이 날 블록을 삭제할까요?'),
                        items:childItems
                    }, function(){
                        if(days.length<=1){ $$('.planner-block-card,.planner-block-summary',day).forEach(function(x){x.remove()}); ensureDayControls(day); }
                        else day.remove();
                        renumberDays(); syncBudget(); markDirty();
                    });
                });
                ensureDayControls(day);
            }
            $$('.planner-day').forEach(setupDay);

            var addDay=$('#plannerAddDay');
            if(addDay){
                // Day 추가 버튼은 특정 Day 안이 아니라 전체 Day 목록의 맨 아래에 둔다.
                var daysWrap=$('#plannerDays'); daysWrap.appendChild(addDay);
                var label=document.createElement('span'); label.className='planner-add-day-label'; label.textContent='Day '+($$('.planner-day').length+1)+' 추가';
                Array.prototype.slice.call(addDay.childNodes).forEach(function(n){ if(n.nodeType===3 && n.textContent.trim()) n.remove(); });
                addDay.appendChild(label);
                addDay.addEventListener('click',function(){
                    var n=$$('.planner-day').length+1;
                    var d=createPlannerDayShell('Day '+n);
                    daysWrap.insertBefore(d,addDay); setupDay(d); renumberDays(); markDirty();
                    d.scrollIntoView({behavior:'smooth',block:'nearest'});
                });
            }
            renumberDays();


            var allBtn=$('#plannerToggleAllDays');
            if(allBtn) allBtn.addEventListener('click',function(){ var bodies=$$('.planner-day-body'), anyOpen=bodies.some(function(x){return !x.classList.contains('is-collapsed')}); bodies.forEach(function(x){x.classList.toggle('is-collapsed',anyOpen)}); allBtn.title=anyOpen?'모두 열기':'모두 닫기'; });

            function renderPlannerMapAllLegend(){
                var overlay=$('#plannerMapAllLegendOverlay');
                if(!overlay){
                    return;
                }

                if(plannerActiveMapDay!=='all'){
                    overlay.classList.add('hidden');
                    overlay.innerHTML='';
                    return;
                }

                var dayNumbers=$$('.planner-day').map(function(dayCard){
                    return String(dayCard.dataset.dayNumber||'');
                }).filter(function(dayNumber){
                    return !!dayNumber;
                });

                if(!dayNumbers.length){
                    overlay.classList.add('hidden');
                    overlay.innerHTML='';
                    return;
                }

                overlay.innerHTML=dayNumbers.map(function(dayNumber){
                    var lineColor=getPlannerDayLineColor(dayNumber);
                    return '<div class="flex items-center gap-2 py-1">'
                        +'<span class="font-bold text-white/90">'+dayNumber+'일차</span>'
                        +'<span class="inline-flex items-center ml-auto">'
                        +'<span style="width:24px;height:4px;border-radius:999px;background:'+lineColor+';display:inline-block"></span>'
                        +'</span>'
                        +'</div>';
                }).join('');

                overlay.classList.remove('hidden');
            }
            function updatePlannerMapFilterButton(){
                var label=$('#plannerMapFilterLabel');
                var dot=$('#plannerMapFilterDot');
                if(label){
                    label.textContent=plannerActiveMapDay==='all' ? '전체' : plannerActiveMapDay+'일차';
                }
                if(dot){
                    dot.style.background=plannerActiveMapDay==='all'
                        ? '#6B7280'
                        : getPlannerDayLineColor(plannerActiveMapDay);
                }
                renderPlannerMapAllLegend();
            }
            function rebuildMapFilter(){
                var menu=$('#plannerMapFilterMenu');
                if(!menu)return;
                menu.innerHTML='<button type="button" data-map-day="all" class="w-full text-left px-3 py-2 text-xs font-bold hover:bg-purple-50" style="color:#6369D1">전체</button>'
                    +$$('.planner-day').map(function(d){
                        var n=String(d.dataset.dayNumber||'');
                        var lineColor=getPlannerDayLineColor(n);
                        return '<button type="button" data-map-day="'+n+'" class="w-full flex flex-nowrap items-center justify-between gap-3 text-left px-3 py-2 text-xs font-bold hover:bg-purple-50 text-gray-700 whitespace-nowrap">'
                            +'<span>'+n+'일차</span>'
                            +'<span class="inline-flex items-center shrink-0">'
                            +'<span style="width:24px;height:4px;border-radius:999px;background:'+lineColor+';display:inline-block"></span>'
                            +'</span>'
                            +'</button>';
                    }).join('');
                bindMapOptions();
                updatePlannerMapFilterButton();
            }
            function bindMapOptions(){
                $$('#plannerMapFilterMenu [data-map-day]').forEach(function(b){
                    b.onclick=function(){
                        plannerActiveMapDay=b.dataset.mapDay || 'all';
                        updatePlannerMapFilterButton();
                        $('#plannerMapFilterMenu').classList.add('hidden');
                        refreshMap(plannerActiveMapDay);
                    };
                });
            }
            var mf=$('#plannerMapFilterBtn'); if(mf) mf.addEventListener('click',function(e){e.stopPropagation();$('#plannerMapFilterMenu').classList.toggle('hidden')}); document.addEventListener('click',function(e){var m=$('#plannerMapFilterMenu');if(m&&!e.target.closest('#plannerMapFilterBtn')&&!e.target.closest('#plannerMapFilterMenu'))m.classList.add('hidden')}); bindMapOptions(); updatePlannerMapFilterButton();

            /*
             * /modifyplan Servlet이 DB에서 넘긴 KRW 기준 환율.
             * 1 KRW = rates[통화코드] 형태입니다.
             */
            var PLANNER_EXCHANGE_RATES=
                ${empty exchangeRatesJson ? '{}' : exchangeRatesJson};

            /*
             * 환율 표시용 통화 한글명.
             * DB/API에서는 ISO 통화코드를 그대로 사용하고,
             * 화면에서만 한글 화폐단위로 변환한다.
             */
            var PLANNER_CURRENCY_LABELS={"AED":"디르함","AFN":"아프가니스탄 아프가니","ALL":"알바니아 레크","AMD":"아르메니아 드람","AOA":"앙골라 콴자","ARS":"아르헨티나 페소","AUD":"호주 달러","AWG":"아루바 플로린","AZN":"아제르바이잔 마나트","BAM":"보스니아-헤르체고비나 태환 마르크","BBD":"바베이도스 달러","BDT":"방글라데시 타카","BGN":"불가리아 레프","BHD":"바레인 디나르","BIF":"부룬디 프랑","BMD":"버뮤다 달러","BND":"부루나이 달러","BOB":"볼리비아 볼리비아노","BRL":"헤알","BSD":"바하마 달러","BWP":"보츠와나 풀라","BYN":"벨라루스 루블","BZD":"벨리즈 달러","CAD":"캐나다 달러","CDF":"콩고 프랑","CHF":"프랑","CLP":"칠레 페소","CNY":"위안","COP":"콜롬비아 페소","CRC":"코스타리카 콜론","CUP":"쿠바 페소","CVE":"카보베르데 에스쿠도","CZK":"체코 코루나","DJF":"지부티 프랑","DKK":"덴마크 크로네","DOP":"도미니카 페소","DZD":"알제리 디나르","EGP":"이집트 파운드","ERN":"에리트리아 나크파","ETB":"에티오피아 비르","EUR":"유로","FJD":"피지 달러","FKP":"포클랜드제도 파운드","GBP":"파운드","GEL":"조지아 라리","GHS":"가나 세디","GIP":"지브롤터 파운드","GMD":"감비아 달라시","GNF":"기니 프랑","GTQ":"과테말라 케트살","GYD":"가이아나 달러","HKD":"홍콩 달러","HNL":"온두라스 렘피라","HTG":"아이티 구르드","HUF":"헝가리 포린트","IDR":"루피아","ILS":"이스라엘 신권 세켈","INR":"루피","IQD":"이라크 디나르","IRR":"이란 리얄","ISK":"아이슬란드 크로나","JMD":"자메이카 달러","JOD":"요르단 디나르","JPY":"엔","KES":"케냐 실링","KGS":"키르기스스탄 솜","KHR":"캄보디아 리엘","KMF":"코모르 프랑","KPW":"조선 민주주의 인민 공화국 원","KRW":"원","KWD":"쿠웨이트 디나르","KYD":"케이맨 제도 달러","KZT":"카자흐스탄 텡게","LAK":"라오스 키프","LBP":"레바논 파운드","LKR":"스리랑카 루피","LRD":"라이베리아 달러","LYD":"리비아 디나르","MAD":"모로코 디르함","MDL":"몰도바 레이","MGA":"마다가스카르 아리아리","MKD":"마케도니아 디나르","MMK":"미얀마 키얏","MNT":"몽골 투그릭","MOP":"마카오 파타카","MRU":"모리타니 우기야","MUR":"모리셔스 루피","MVR":"몰디브 제도 루피아","MWK":"말라위 콰차","MXN":"멕시코 페소","MYR":"링깃","MZN":"모잠비크 메티칼","NGN":"나이지리아 나이라","NIO":"니카라과 코르도바","NOK":"노르웨이 크로네","NPR":"네팔 루피","NZD":"뉴질랜드 달러","OMR":"오만 리알","PAB":"파나마 발보아","PEN":"페루 솔","PGK":"파푸아뉴기니 키나","PHP":"페소","PKR":"파키스탄 루피","PLN":"폴란드 즈워티","PYG":"파라과이 과라니","QAR":"카타르 리얄","RON":"루마니아 레우","RSD":"세르비아 디나르","RUB":"루블","RWF":"르완다 프랑","SAR":"리얄","SBD":"솔로몬 제도 달러","SCR":"세이셸 루피","SDG":"수단 파운드","SEK":"스웨덴 크로나","SGD":"싱가포르 달러","SHP":"세인트헬레나 파운드","SLE":"시에라리온 리온","SOS":"소말리아 실링","SRD":"수리남 달러","SSP":"남수단 파운드","STN":"상투메 프린시페 도브라","SYP":"시리아 파운드","SZL":"스와질란드 릴랑게니","THB":"바트","TJS":"타지키스탄 소모니","TMT":"투르크메니스탄 마나트","TND":"튀니지 디나르","TOP":"통가 파앙가","TRY":"리라","TTD":"트리니다드 토바고 달러","TWD":"대만 달러","TZS":"탄자니아 실링","UAH":"우크라이나 그리브나","UGX":"우간다 실링","USD":"달러","UYU":"우루과이 페소","UZS":"우즈베키스탄 숨","VES":"베네수엘라 볼리바르","VND":"동","VUV":"바누아투 바투","WST":"서 사모아 탈라","XAF":"중앙아프리카 CFA 프랑","XCD":"동카리브 달러","XCG":"XCG","XOF":"서아프리카 CFA 프랑","XPF":"CFP 프랑","YER":"예멘 리알","ZAR":"랜드","ZMW":"잠비아 콰차"};

            function getPlannerCurrencyLabel(currencyCode){
                return PLANNER_CURRENCY_LABELS[currencyCode]
                    || currencyCode
                    || '';
            }

            /*
             * 국가 선택 시 지도 중심 이동용 좌표.
             * 별도 Geocoding/Routes API를 호출하지 않는다.
             */
            var PLANNER_COUNTRY_CENTERS={"AD":{"lat":42.5063,"lng":1.5218},"AE":{"lat":24.0,"lng":54.0},"AF":{"lat":33.0,"lng":65.0},"AG":{"lat":17.05,"lng":-61.8},"AI":{"lat":18.25,"lng":-63.16666666},"AL":{"lat":41.0,"lng":20.0},"AM":{"lat":40.0,"lng":45.0},"AO":{"lat":-12.5,"lng":18.5},"AQ":{"lat":-82.8628,"lng":135.0},"AR":{"lat":-34.0,"lng":-64.0},"AS":{"lat":-14.33333333,"lng":-170.0},"AT":{"lat":47.33333333,"lng":13.33333333},"AU":{"lat":-27.0,"lng":133.0},"AW":{"lat":12.5,"lng":-69.96666666},"AX":{"lat":60.1785,"lng":19.9156},"AZ":{"lat":40.5,"lng":47.5},"BA":{"lat":44.0,"lng":18.0},"BB":{"lat":13.16666666,"lng":-59.53333333},"BD":{"lat":24.0,"lng":90.0},"BE":{"lat":50.83333333,"lng":4.0},"BF":{"lat":13.0,"lng":-2.0},"BG":{"lat":43.0,"lng":25.0},"BH":{"lat":26.0,"lng":50.55},"BI":{"lat":-3.5,"lng":30.0},"BJ":{"lat":9.5,"lng":2.25},"BL":{"lat":17.9,"lng":-62.8333},"BM":{"lat":32.33333333,"lng":-64.75},"BN":{"lat":4.5353,"lng":114.7277},"BO":{"lat":-17.0,"lng":-65.0},"BQ":{"lat":12.1784,"lng":-68.2385},"BR":{"lat":-10.0,"lng":-55.0},"BS":{"lat":24.25,"lng":-76.0},"BT":{"lat":27.5,"lng":90.5},"BV":{"lat":-54.4232,"lng":3.4132},"BW":{"lat":-22.0,"lng":24.0},"BY":{"lat":53.0,"lng":28.0},"BZ":{"lat":17.25,"lng":-88.75},"CA":{"lat":60.0,"lng":-95.0},"CC":{"lat":-12.5,"lng":96.83333333},"CD":{"lat":-4.0383,"lng":21.7587},"CF":{"lat":7.0,"lng":21.0},"CG":{"lat":-1.0,"lng":15.0},"CH":{"lat":47.0,"lng":8.0},"CI":{"lat":8.0,"lng":-5.0},"CK":{"lat":-21.23333333,"lng":-159.76666666},"CL":{"lat":-30.0,"lng":-71.0},"CM":{"lat":6.0,"lng":12.0},"CN":{"lat":35.0,"lng":105.0},"CO":{"lat":4.0,"lng":-72.0},"CR":{"lat":10.0,"lng":-84.0},"CU":{"lat":21.5,"lng":-80.0},"CV":{"lat":16.0,"lng":-24.0},"CW":{"lat":12.1696,"lng":-68.99},"CX":{"lat":-10.5,"lng":105.66666666},"CY":{"lat":35.0,"lng":33.0},"CZ":{"lat":49.75,"lng":15.5},"DE":{"lat":51.0,"lng":9.0},"DJ":{"lat":11.5,"lng":43.0},"DK":{"lat":56.0,"lng":10.0},"DM":{"lat":15.41666666,"lng":-61.33333333},"DO":{"lat":19.0,"lng":-70.66666666},"DZ":{"lat":28.0,"lng":3.0},"EC":{"lat":-2.0,"lng":-77.5},"EE":{"lat":59.0,"lng":26.0},"EG":{"lat":27.0,"lng":30.0},"EH":{"lat":24.2155,"lng":-12.8858},"ER":{"lat":15.0,"lng":39.0},"ES":{"lat":40.0,"lng":-4.0},"ET":{"lat":8.0,"lng":38.0},"FI":{"lat":64.0,"lng":26.0},"FJ":{"lat":-18.0,"lng":175.0},"FK":{"lat":-51.7963,"lng":-59.5236},"FM":{"lat":6.91666666,"lng":158.25},"FO":{"lat":62.0,"lng":-7.0},"FR":{"lat":46.0,"lng":2.0},"GA":{"lat":-1.0,"lng":11.75},"GB":{"lat":54.0,"lng":-2.0},"GD":{"lat":12.11666666,"lng":-61.66666666},"GE":{"lat":42.0,"lng":43.5},"GF":{"lat":4.0,"lng":-53.0},"GG":{"lat":49.46666666,"lng":-2.58333333},"GH":{"lat":8.0,"lng":-2.0},"GI":{"lat":36.13333333,"lng":-5.35},"GL":{"lat":72.0,"lng":-40.0},"GM":{"lat":13.46666666,"lng":-16.56666666},"GN":{"lat":11.0,"lng":-10.0},"GP":{"lat":16.25,"lng":-61.583333},"GQ":{"lat":2.0,"lng":10.0},"GR":{"lat":39.0,"lng":22.0},"GS":{"lat":-54.5,"lng":-37.0},"GT":{"lat":15.5,"lng":-90.25},"GU":{"lat":13.46666666,"lng":144.78333333},"GW":{"lat":12.0,"lng":-15.0},"GY":{"lat":5.0,"lng":-59.0},"HK":{"lat":22.25,"lng":114.16666666},"HM":{"lat":-53.1,"lng":72.51666666},"HN":{"lat":15.0,"lng":-86.5},"HR":{"lat":45.16666666,"lng":15.5},"HT":{"lat":19.0,"lng":-72.41666666},"HU":{"lat":47.0,"lng":20.0},"ID":{"lat":-5.0,"lng":120.0},"IE":{"lat":53.0,"lng":-8.0},"IL":{"lat":31.5,"lng":34.75},"IM":{"lat":54.25,"lng":-4.5},"IN":{"lat":20.0,"lng":77.0},"IO":{"lat":-6.0,"lng":71.5},"IQ":{"lat":33.0,"lng":44.0},"IR":{"lat":32.0,"lng":53.0},"IS":{"lat":65.0,"lng":-18.0},"IT":{"lat":42.83333333,"lng":12.83333333},"JE":{"lat":49.25,"lng":-2.16666666},"JM":{"lat":18.25,"lng":-77.5},"JO":{"lat":31.0,"lng":36.0},"JP":{"lat":36.0,"lng":138.0},"KE":{"lat":1.0,"lng":38.0},"KG":{"lat":41.0,"lng":75.0},"KH":{"lat":13.0,"lng":105.0},"KI":{"lat":1.41666666,"lng":173.0},"KM":{"lat":-12.16666666,"lng":44.25},"KN":{"lat":17.33333333,"lng":-62.75},"KP":{"lat":40.0,"lng":127.0},"KR":{"lat":37.0,"lng":127.5},"KW":{"lat":29.5,"lng":45.75},"KY":{"lat":19.5,"lng":-80.5},"KZ":{"lat":48.0,"lng":68.0},"LA":{"lat":18.0,"lng":105.0},"LB":{"lat":33.83333333,"lng":35.83333333},"LC":{"lat":13.88333333,"lng":-60.96666666},"LI":{"lat":47.26666666,"lng":9.53333333},"LK":{"lat":7.0,"lng":81.0},"LR":{"lat":6.5,"lng":-9.5},"LS":{"lat":-29.5,"lng":28.5},"LT":{"lat":56.0,"lng":24.0},"LU":{"lat":49.75,"lng":6.16666666},"LV":{"lat":57.0,"lng":25.0},"LY":{"lat":25.0,"lng":17.0},"MA":{"lat":32.0,"lng":-5.0},"MC":{"lat":43.73333333,"lng":7.4},"MD":{"lat":47.0,"lng":29.0},"ME":{"lat":42.7087,"lng":19.3744},"MF":{"lat":18.0708,"lng":-63.0501},"MG":{"lat":-20.0,"lng":47.0},"MH":{"lat":9.0,"lng":168.0},"MK":{"lat":41.6086,"lng":21.7453},"ML":{"lat":17.0,"lng":-4.0},"MM":{"lat":21.9162,"lng":95.956},"MN":{"lat":46.0,"lng":105.0},"MO":{"lat":22.1987,"lng":113.5439},"MP":{"lat":15.2,"lng":145.75},"MQ":{"lat":14.666667,"lng":-61.0},"MR":{"lat":20.0,"lng":-12.0},"MS":{"lat":16.75,"lng":-62.2},"MT":{"lat":35.83333333,"lng":14.58333333},"MU":{"lat":-20.28333333,"lng":57.55},"MV":{"lat":3.25,"lng":73.0},"MW":{"lat":-13.5,"lng":34.0},"MX":{"lat":23.0,"lng":-102.0},"MY":{"lat":2.5,"lng":112.5},"MZ":{"lat":-18.25,"lng":35.0},"NA":{"lat":-22.0,"lng":17.0},"NC":{"lat":-21.5,"lng":165.5},"NE":{"lat":16.0,"lng":8.0},"NF":{"lat":-29.03333333,"lng":167.95},"NG":{"lat":10.0,"lng":8.0},"NI":{"lat":13.0,"lng":-85.0},"NL":{"lat":52.5,"lng":5.75},"NO":{"lat":62.0,"lng":10.0},"NP":{"lat":28.0,"lng":84.0},"NR":{"lat":-0.53333333,"lng":166.91666666},"NU":{"lat":-19.03333333,"lng":-169.86666666},"NZ":{"lat":-41.0,"lng":174.0},"OM":{"lat":21.0,"lng":57.0},"PA":{"lat":9.0,"lng":-80.0},"PE":{"lat":-10.0,"lng":-76.0},"PF":{"lat":-15.0,"lng":-140.0},"PG":{"lat":-6.0,"lng":147.0},"PH":{"lat":13.0,"lng":122.0},"PK":{"lat":30.0,"lng":70.0},"PL":{"lat":52.0,"lng":20.0},"PM":{"lat":46.83333333,"lng":-56.33333333},"PN":{"lat":-24.3768,"lng":-128.3242},"PR":{"lat":18.25,"lng":-66.5},"PS":{"lat":31.9522,"lng":35.2332},"PT":{"lat":39.5,"lng":-8.0},"PW":{"lat":7.5,"lng":134.5},"PY":{"lat":-23.0,"lng":-58.0},"QA":{"lat":25.5,"lng":51.25},"RE":{"lat":-21.15,"lng":55.5},"RO":{"lat":46.0,"lng":25.0},"RS":{"lat":44.1305021,"lng":16.4284181},"RU":{"lat":60.0,"lng":100.0},"RW":{"lat":-2.0,"lng":30.0},"SA":{"lat":25.0,"lng":45.0},"SB":{"lat":-8.0,"lng":159.0},"SC":{"lat":-4.58333333,"lng":55.66666666},"SD":{"lat":15.0,"lng":30.0},"SE":{"lat":62.0,"lng":15.0},"SG":{"lat":1.36666666,"lng":103.8},"SH":{"lat":-15.965,"lng":-5.7089},"SI":{"lat":46.11666666,"lng":14.81666666},"SJ":{"lat":78.0,"lng":20.0},"SK":{"lat":48.66666666,"lng":19.5},"SL":{"lat":8.5,"lng":-11.5},"SM":{"lat":43.76666666,"lng":12.41666666},"SN":{"lat":14.0,"lng":-14.0},"SO":{"lat":10.0,"lng":49.0},"SR":{"lat":4.0,"lng":-56.0},"SS":{"lat":7.0,"lng":30.0},"ST":{"lat":0.1864,"lng":6.6131},"SV":{"lat":13.83333333,"lng":-88.91666666},"SX":{"lat":18.0425,"lng":-63.0548},"SY":{"lat":35.0,"lng":38.0},"TD":{"lat":15.0,"lng":19.0},"TF":{"lat":-49.2804,"lng":69.3486},"TG":{"lat":8.0,"lng":1.16666666},"TH":{"lat":15.0,"lng":100.0},"TJ":{"lat":39.0,"lng":71.0},"TK":{"lat":-9.0,"lng":-172.0},"TL":{"lat":-8.8742,"lng":125.7275},"TM":{"lat":40.0,"lng":60.0},"TN":{"lat":34.0,"lng":9.0},"TO":{"lat":-20.0,"lng":-175.0},"TT":{"lat":11.0,"lng":-61.0},"TV":{"lat":-8.0,"lng":178.0},"TW":{"lat":23.5,"lng":121.0},"TZ":{"lat":-6.0,"lng":35.0},"UA":{"lat":49.0,"lng":32.0},"UG":{"lat":1.0,"lng":32.0},"UM":{"lat":19.2823,"lng":166.647},"US":{"lat":38.0,"lng":-97.0},"UY":{"lat":-33.0,"lng":-56.0},"UZ":{"lat":41.0,"lng":64.0},"VA":{"lat":41.9029,"lng":12.4534},"VC":{"lat":13.25,"lng":-61.2},"VE":{"lat":8.0,"lng":-66.0},"VG":{"lat":18.4207,"lng":-64.64},"VI":{"lat":18.3358,"lng":-64.8963},"VN":{"lat":16.16666666,"lng":107.83333333},"VU":{"lat":-16.0,"lng":167.0},"WF":{"lat":-13.3,"lng":-176.2},"WS":{"lat":-13.58333333,"lng":-172.33333333},"XK":{"lat":42.6026,"lng":20.903},"YE":{"lat":15.0,"lng":48.0},"YT":{"lat":-12.83333333,"lng":45.16666666},"ZA":{"lat":-29.0,"lng":24.0},"ZM":{"lat":-15.0,"lng":30.0},"ZW":{"lat":-20.0,"lng":30.0}};

            function centerMapOnPlannerCountry(countryValue){
                if(!map || !countryValue) return;

                var matched=findPlannerCountry(countryValue);
                if(!matched || !matched.code) return;

                var center=PLANNER_COUNTRY_CENTERS[matched.code];
                if(!center) return;

                map.setCenter(center);

                /*
                 * 대륙 크기의 국가와 소국가에 대해 너무 과도하게
                 * 확대/축소되지 않도록 간단히 줌만 구분한다.
                 */
                var wideCountries={
                    US:true, CA:true, RU:true, CN:true,
                    BR:true, AU:true, IN:true, AR:true,
                    KZ:true, DZ:true
                };

                var smallCountries={
                    SG:true, HK:true, MO:true, MC:true,
                    VA:true, SM:true, LI:true, LU:true,
                    MT:true, MV:true
                };

                if(wideCountries[matched.code]){
                    map.setZoom(4);
                }else if(smallCountries[matched.code]){
                    map.setZoom(8);
                }else{
                    map.setZoom(5);
                }
            }

            var PLANNER_COUNTRIES=[{"code":"GH","name":"가나","currency":"GHS"},{"code":"GA","name":"가봉","currency":"XAF"},{"code":"GY","name":"가이아나","currency":"GYD"},{"code":"GM","name":"감비아","currency":"GMD"},{"code":"GG","name":"건지","currency":"GBP"},{"code":"GP","name":"과들루프","currency":"EUR"},{"code":"GT","name":"과테말라","currency":"GTQ"},{"code":"GU","name":"괌","currency":"USD"},{"code":"GD","name":"그레나다","currency":"XCD"},{"code":"GR","name":"그리스","currency":"EUR"},{"code":"GL","name":"그린란드","currency":"DKK"},{"code":"GN","name":"기니","currency":"GNF"},{"code":"GW","name":"기니비사우","currency":"XOF"},{"code":"NA","name":"나미비아","currency":"ZAR"},{"code":"NR","name":"나우루","currency":"AUD"},{"code":"NG","name":"나이지리아","currency":"NGN"},{"code":"AQ","name":"남극 대륙","currency":"USD"},{"code":"SS","name":"남수단","currency":"SSP"},{"code":"ZA","name":"남아프리카","currency":"ZAR"},{"code":"NL","name":"네덜란드","currency":"EUR"},{"code":"BQ","name":"네덜란드령 카리브","currency":"USD"},{"code":"NP","name":"네팔","currency":"NPR"},{"code":"NO","name":"노르웨이","currency":"NOK"},{"code":"NF","name":"노퍽섬","currency":"AUD"},{"code":"NZ","name":"뉴질랜드","currency":"NZD"},{"code":"NC","name":"뉴칼레도니아","currency":"XPF"},{"code":"NU","name":"니우에","currency":"NZD"},{"code":"NE","name":"니제르","currency":"XOF"},{"code":"NI","name":"니카라과","currency":"NIO"},{"code":"TW","name":"대만","currency":"TWD"},{"code":"KR","name":"대한민국","currency":"KRW"},{"code":"DK","name":"덴마크","currency":"DKK"},{"code":"DM","name":"도미니카","currency":"XCD"},{"code":"DO","name":"도미니카 공화국","currency":"DOP"},{"code":"DE","name":"독일","currency":"EUR"},{"code":"TL","name":"동티모르","currency":"USD"},{"code":"LA","name":"라오스","currency":"LAK"},{"code":"LR","name":"라이베리아","currency":"LRD"},{"code":"LV","name":"라트비아","currency":"EUR"},{"code":"RU","name":"러시아","currency":"RUB"},{"code":"LB","name":"레바논","currency":"LBP"},{"code":"LS","name":"레소토","currency":"ZAR"},{"code":"RE","name":"레위니옹","currency":"EUR"},{"code":"RO","name":"루마니아","currency":"RON"},{"code":"LU","name":"룩셈부르크","currency":"EUR"},{"code":"RW","name":"르완다","currency":"RWF"},{"code":"LY","name":"리비아","currency":"LYD"},{"code":"LT","name":"리투아니아","currency":"EUR"},{"code":"LI","name":"리히텐슈타인","currency":"CHF"},{"code":"MG","name":"마다가스카르","currency":"MGA"},{"code":"MQ","name":"마르티니크","currency":"EUR"},{"code":"MH","name":"마셜 제도","currency":"USD"},{"code":"YT","name":"마요트","currency":"EUR"},{"code":"MO","name":"마카오(중국 특별행정구)","currency":"MOP"},{"code":"MW","name":"말라위","currency":"MWK"},{"code":"MY","name":"말레이시아","currency":"MYR"},{"code":"ML","name":"말리","currency":"XOF"},{"code":"IM","name":"맨섬","currency":"GBP"},{"code":"MX","name":"멕시코","currency":"MXN"},{"code":"MC","name":"모나코","currency":"EUR"},{"code":"MA","name":"모로코","currency":"MAD"},{"code":"MU","name":"모리셔스","currency":"MUR"},{"code":"MR","name":"모리타니","currency":"MRU"},{"code":"MZ","name":"모잠비크","currency":"MZN"},{"code":"ME","name":"몬테네그로","currency":"EUR"},{"code":"MS","name":"몬트세라트","currency":"XCD"},{"code":"MD","name":"몰도바","currency":"MDL"},{"code":"MV","name":"몰디브","currency":"MVR"},{"code":"MT","name":"몰타","currency":"EUR"},{"code":"MN","name":"몽골","currency":"MNT"},{"code":"US","name":"미국","currency":"USD"},{"code":"VI","name":"미국령 버진아일랜드","currency":"USD"},{"code":"UM","name":"미국령 해외 제도","currency":"USD"},{"code":"MM","name":"미얀마","currency":"MMK"},{"code":"FM","name":"미크로네시아","currency":"USD"},{"code":"VU","name":"바누아투","currency":"VUV"},{"code":"BH","name":"바레인","currency":"BHD"},{"code":"BB","name":"바베이도스","currency":"BBD"},{"code":"VA","name":"바티칸 시국","currency":"EUR"},{"code":"BS","name":"바하마","currency":"BSD"},{"code":"BD","name":"방글라데시","currency":"BDT"},{"code":"BM","name":"버뮤다","currency":"BMD"},{"code":"BJ","name":"베냉","currency":"XOF"},{"code":"VE","name":"베네수엘라","currency":"VES"},{"code":"VN","name":"베트남","currency":"VND"},{"code":"BE","name":"벨기에","currency":"EUR"},{"code":"BY","name":"벨라루스","currency":"BYN"},{"code":"BZ","name":"벨리즈","currency":"BZD"},{"code":"BA","name":"보스니아 헤르체고비나","currency":"BAM"},{"code":"BW","name":"보츠와나","currency":"BWP"},{"code":"BO","name":"볼리비아","currency":"BOB"},{"code":"BI","name":"부룬디","currency":"BIF"},{"code":"BF","name":"부르키나파소","currency":"XOF"},{"code":"BV","name":"부베섬","currency":"NOK"},{"code":"BT","name":"부탄","currency":"INR"},{"code":"MP","name":"북마리아나제도","currency":"USD"},{"code":"MK","name":"북마케도니아","currency":"MKD"},{"code":"KP","name":"북한","currency":"KPW"},{"code":"BG","name":"불가리아","currency":"BGN"},{"code":"BR","name":"브라질","currency":"BRL"},{"code":"BN","name":"브루나이","currency":"BND"},{"code":"WS","name":"사모아","currency":"WST"},{"code":"SA","name":"사우디아라비아","currency":"SAR"},{"code":"GS","name":"사우스조지아 사우스샌드위치 제도","currency":"GBP"},{"code":"SM","name":"산마리노","currency":"EUR"},{"code":"ST","name":"상투메 프린시페","currency":"STN"},{"code":"MF","name":"생마르탱","currency":"EUR"},{"code":"BL","name":"생바르텔레미","currency":"EUR"},{"code":"PM","name":"생피에르 미클롱","currency":"EUR"},{"code":"EH","name":"서사하라","currency":"MAD"},{"code":"SN","name":"세네갈","currency":"XOF"},{"code":"RS","name":"세르비아","currency":"RSD"},{"code":"SC","name":"세이셸","currency":"SCR"},{"code":"LC","name":"세인트루시아","currency":"XCD"},{"code":"VC","name":"세인트빈센트그레나딘","currency":"XCD"},{"code":"KN","name":"세인트키츠 네비스","currency":"XCD"},{"code":"SH","name":"세인트헬레나","currency":"SHP"},{"code":"SO","name":"소말리아","currency":"SOS"},{"code":"SB","name":"솔로몬 제도","currency":"SBD"},{"code":"SD","name":"수단","currency":"SDG"},{"code":"SR","name":"수리남","currency":"SRD"},{"code":"LK","name":"스리랑카","currency":"LKR"},{"code":"SJ","name":"스발바르제도-얀마웬섬","currency":"NOK"},{"code":"SE","name":"스웨덴","currency":"SEK"},{"code":"CH","name":"스위스","currency":"CHF"},{"code":"ES","name":"스페인","currency":"EUR"},{"code":"SK","name":"슬로바키아","currency":"EUR"},{"code":"SI","name":"슬로베니아","currency":"EUR"},{"code":"SY","name":"시리아","currency":"SYP"},{"code":"SL","name":"시에라리온","currency":"SLE"},{"code":"SX","name":"신트마르턴","currency":"XCG"},{"code":"SG","name":"싱가포르","currency":"SGD"},{"code":"AE","name":"아랍에미리트","currency":"AED"},{"code":"AW","name":"아루바","currency":"AWG"},{"code":"AM","name":"아르메니아","currency":"AMD"},{"code":"AR","name":"아르헨티나","currency":"ARS"},{"code":"AS","name":"아메리칸 사모아","currency":"USD"},{"code":"IS","name":"아이슬란드","currency":"ISK"},{"code":"HT","name":"아이티","currency":"HTG"},{"code":"IE","name":"아일랜드","currency":"EUR"},{"code":"AZ","name":"아제르바이잔","currency":"AZN"},{"code":"AF","name":"아프가니스탄","currency":"AFN"},{"code":"AD","name":"안도라","currency":"EUR"},{"code":"AL","name":"알바니아","currency":"ALL"},{"code":"DZ","name":"알제리","currency":"DZD"},{"code":"AO","name":"앙골라","currency":"AOA"},{"code":"AG","name":"앤티가 바부다","currency":"XCD"},{"code":"AI","name":"앵귈라","currency":"XCD"},{"code":"ER","name":"에리트리아","currency":"ERN"},{"code":"SZ","name":"에스와티니","currency":"SZL"},{"code":"EE","name":"에스토니아","currency":"EUR"},{"code":"EC","name":"에콰도르","currency":"USD"},{"code":"ET","name":"에티오피아","currency":"ETB"},{"code":"SV","name":"엘살바도르","currency":"USD"},{"code":"GB","name":"영국","currency":"GBP"},{"code":"VG","name":"영국령 버진아일랜드","currency":"USD"},{"code":"IO","name":"영국령 인도양 지역","currency":"USD"},{"code":"YE","name":"예멘","currency":"YER"},{"code":"OM","name":"오만","currency":"OMR"},{"code":"AU","name":"오스트레일리아","currency":"AUD"},{"code":"AT","name":"오스트리아","currency":"EUR"},{"code":"HN","name":"온두라스","currency":"HNL"},{"code":"AX","name":"올란드 제도","currency":"EUR"},{"code":"WF","name":"왈리스-푸투나 제도","currency":"XPF"},{"code":"JO","name":"요르단","currency":"JOD"},{"code":"UG","name":"우간다","currency":"UGX"},{"code":"UY","name":"우루과이","currency":"UYU"},{"code":"UZ","name":"우즈베키스탄","currency":"UZS"},{"code":"UA","name":"우크라이나","currency":"UAH"},{"code":"IQ","name":"이라크","currency":"IQD"},{"code":"IR","name":"이란","currency":"IRR"},{"code":"IL","name":"이스라엘","currency":"ILS"},{"code":"EG","name":"이집트","currency":"EGP"},{"code":"IT","name":"이탈리아","currency":"EUR"},{"code":"IN","name":"인도","currency":"INR"},{"code":"ID","name":"인도네시아","currency":"IDR"},{"code":"JP","name":"일본","currency":"JPY"},{"code":"JM","name":"자메이카","currency":"JMD"},{"code":"ZM","name":"잠비아","currency":"ZMW"},{"code":"JE","name":"저지","currency":"GBP"},{"code":"GQ","name":"적도 기니","currency":"XAF"},{"code":"GE","name":"조지아","currency":"GEL"},{"code":"CN","name":"중국","currency":"CNY"},{"code":"CF","name":"중앙 아프리카 공화국","currency":"XAF"},{"code":"DJ","name":"지부티","currency":"DJF"},{"code":"GI","name":"지브롤터","currency":"GIP"},{"code":"ZW","name":"짐바브웨","currency":"USD"},{"code":"TD","name":"차드","currency":"XAF"},{"code":"CZ","name":"체코","currency":"CZK"},{"code":"CL","name":"칠레","currency":"CLP"},{"code":"CM","name":"카메룬","currency":"XAF"},{"code":"CV","name":"카보베르데","currency":"CVE"},{"code":"KZ","name":"카자흐스탄","currency":"KZT"},{"code":"QA","name":"카타르","currency":"QAR"},{"code":"KH","name":"캄보디아","currency":"KHR"},{"code":"CA","name":"캐나다","currency":"CAD"},{"code":"KE","name":"케냐","currency":"KES"},{"code":"KY","name":"케이맨 제도","currency":"KYD"},{"code":"KM","name":"코모로","currency":"KMF"},{"code":"CR","name":"코스타리카","currency":"CRC"},{"code":"CC","name":"코코스 제도","currency":"AUD"},{"code":"CI","name":"코트디부아르","currency":"XOF"},{"code":"CO","name":"콜롬비아","currency":"COP"},{"code":"CG","name":"콩고-브라자빌","currency":"XAF"},{"code":"CD","name":"콩고-킨샤사","currency":"CDF"},{"code":"CU","name":"쿠바","currency":"CUP"},{"code":"KW","name":"쿠웨이트","currency":"KWD"},{"code":"CK","name":"쿡 제도","currency":"NZD"},{"code":"CW","name":"퀴라소","currency":"XCG"},{"code":"HR","name":"크로아티아","currency":"EUR"},{"code":"CX","name":"크리스마스섬","currency":"AUD"},{"code":"KG","name":"키르기스스탄","currency":"KGS"},{"code":"KI","name":"키리바시","currency":"AUD"},{"code":"CY","name":"키프로스","currency":"EUR"},{"code":"TJ","name":"타지키스탄","currency":"TJS"},{"code":"TZ","name":"탄자니아","currency":"TZS"},{"code":"TH","name":"태국","currency":"THB"},{"code":"TC","name":"터크스 케이커스 제도","currency":"USD"},{"code":"TG","name":"토고","currency":"XOF"},{"code":"TK","name":"토켈라우","currency":"NZD"},{"code":"TO","name":"통가","currency":"TOP"},{"code":"TM","name":"투르크메니스탄","currency":"TMT"},{"code":"TV","name":"투발루","currency":"AUD"},{"code":"TN","name":"튀니지","currency":"TND"},{"code":"TR","name":"튀르키예","currency":"TRY"},{"code":"TT","name":"트리니다드 토바고","currency":"TTD"},{"code":"PA","name":"파나마","currency":"PAB"},{"code":"PY","name":"파라과이","currency":"PYG"},{"code":"PK","name":"파키스탄","currency":"PKR"},{"code":"PG","name":"파푸아뉴기니","currency":"PGK"},{"code":"PW","name":"팔라우","currency":"USD"},{"code":"PS","name":"팔레스타인 지구","currency":"ILS"},{"code":"FO","name":"페로 제도","currency":"DKK"},{"code":"PE","name":"페루","currency":"PEN"},{"code":"PT","name":"포르투갈","currency":"EUR"},{"code":"FK","name":"포클랜드 제도","currency":"FKP"},{"code":"PL","name":"폴란드","currency":"PLN"},{"code":"PR","name":"푸에르토리코","currency":"USD"},{"code":"FR","name":"프랑스","currency":"EUR"},{"code":"GF","name":"프랑스령 기아나","currency":"EUR"},{"code":"TF","name":"프랑스령 남방 지역","currency":"EUR"},{"code":"PF","name":"프랑스령 폴리네시아","currency":"XPF"},{"code":"FJ","name":"피지","currency":"FJD"},{"code":"FI","name":"핀란드","currency":"EUR"},{"code":"PH","name":"필리핀","currency":"PHP"},{"code":"PN","name":"핏케언 제도","currency":"NZD"},{"code":"HM","name":"허드 맥도널드 제도","currency":"AUD"},{"code":"HU","name":"헝가리","currency":"HUF"},{"code":"HK","name":"홍콩(중국 특별행정구)","currency":"HKD"}];
            var PLANNER_REGION_MAP={"대한민국": ["서울", "부산", "인천", "대구", "대전", "광주", "울산", "경기", "강원", "충북", "충남", "전북", "전남", "경북", "경남", "제주"], "일본": ["도쿄", "오사카", "교토", "후쿠오카", "삿포로", "나고야", "오키나와", "나라", "고베", "요코하마"], "중국": ["베이징", "상하이", "광저우", "선전", "칭다오", "청두", "시안", "항저우"], "대만": ["타이베이", "가오슝", "타이중", "타이난", "화롄"], "태국": ["방콕", "치앙마이", "푸껫", "파타야", "끄라비"], "베트남": ["하노이", "호찌민", "다낭", "나트랑", "호이안", "푸꾸옥"], "미국": ["뉴욕", "로스앤젤레스", "샌프란시스코", "라스베이거스", "시애틀", "시카고", "보스턴", "하와이"], "프랑스": ["파리", "니스", "리옹", "마르세유", "보르도"], "이탈리아": ["로마", "밀라노", "피렌체", "베네치아", "나폴리"], "스페인": ["마드리드", "바르셀로나", "세비야", "발렌시아"], "영국": ["런던", "에든버러", "맨체스터", "리버풀"], "독일": ["베를린", "뮌헨", "프랑크푸르트", "함부르크"], "싱가포르": ["싱가포르"], "말레이시아": ["쿠알라룸푸르", "코타키나발루", "페낭", "말라카"], "인도네시아": ["발리", "자카르타", "욕야카르타", "롬복"], "필리핀": ["마닐라", "세부", "보라카이", "보홀"], "호주": ["시드니", "멜버른", "브리즈번", "골드코스트", "퍼스"], "캐나다": ["밴쿠버", "토론토", "몬트리올", "퀘벡"]};

            function normalizePlannerText(v){ return String(v||'').trim(); }
            function findPlannerCountry(name){
                var n=normalizePlannerText(name);

                if(!Array.isArray(PLANNER_COUNTRIES)){
                    return null;
                }

                return PLANNER_COUNTRIES.find(function(c){
                    return c.name===n;
                }) || null;
            }
            function refreshCountryStatus(){
                var input=$('#plannerCountry');
                var field=$('#plannerCountryField');
                var status=$('#plannerCountryStatus');
                if(!input || !field || !status) return false;

                var value=normalizePlannerText(input.value);
                var matched=findPlannerCountry(value);

                if(!value){
                    status.textContent='필수';
                    field.style.borderColor='#FCA5A5';
                }else if(!matched){
                    status.textContent='일치하는 국가가 없습니다';
                    field.style.borderColor='#FCA5A5';
                }else{
                    status.textContent='';
                    field.style.borderColor='#E2E5EF';
                }
                return !!matched;
            }
            function searchPlannerCountries(value){
                var q=normalizePlannerText(value);
                var qLower=q.toLowerCase();

                if(!q) return PLANNER_COUNTRIES;

                return PLANNER_COUNTRIES
                    .map(function(c){
                        var name=c.name||'';
                        var nameLower=name.toLowerCase();
                        var codeLower=(c.code||'').toLowerCase();
                        var rank=99;

                        if(nameLower===qLower || codeLower===qLower){
                            rank=0; // 완전 일치
                        }else if(nameLower.indexOf(qLower)===0 || codeLower.indexOf(qLower)===0){
                            rank=1; // 입력값으로 시작
                        }else if(nameLower.indexOf(qLower)!==-1 || codeLower.indexOf(qLower)!==-1){
                            rank=2; // 중간 포함
                        }

                        return { country:c, rank:rank };
                    })
                    .filter(function(item){ return item.rank<99; })
                    .sort(function(a,b){
                        if(a.rank!==b.rank) return a.rank-b.rank;

                        var aName=a.country.name||'';
                        var bName=b.country.name||'';

                        // 같은 우선순위에서는 짧고 직접적인 이름을 먼저
                        if(aName.length!==bName.length) return aName.length-bName.length;
                        return aName.localeCompare(bName,'ko');
                    })
                    .slice(0,8)
                    .map(function(item){ return item.country; });
            }
            function closePlannerDropdowns(exceptId){
                ['plannerCountryDropdown','plannerRegionDropdown'].forEach(function(id){
                    if(id===exceptId) return;
                    var el=document.getElementById(id);
                    if(el) el.classList.add('hidden');
                });
            }
            function renderCountryDropdown(){
                var input=$('#plannerCountry');
                var dropdown=$('#plannerCountryDropdown');
                if(!input || !dropdown) return;

                var suggestions=searchPlannerCountries(input.value);
                dropdown.innerHTML='';

                suggestions.forEach(function(c){
                    var btn=document.createElement('button');
                    btn.type='button';
                    btn.className='flex items-center gap-2 px-3 py-2.5 text-sm min-w-0 whitespace-nowrap';

                    var code=document.createElement('span');
                    code.className='text-[11px] font-semibold text-gray-500 w-6 shrink-0';
                    code.textContent=c.code;

                    var name=document.createElement('span');
                    name.className='font-medium text-gray-800 min-w-0 whitespace-nowrap';
                    name.textContent=c.name;

                    btn.appendChild(code);
                    btn.appendChild(name);

                    btn.addEventListener('mousedown',function(e){
                        e.preventDefault();
                        input.value=c.name;
                        dropdown.classList.add('hidden');
                        refreshCountryStatus();
                        refreshRegionOptions(true);
                        syncCountryLock();
                        updateCountryClear();
                        filterPlans();
                        centerMapOnPlannerCountry(c.name);
                        syncForeignCosts();
                        markDirty();
                    });

                    dropdown.appendChild(btn);
                });

                dropdown.classList.toggle('hidden',suggestions.length===0);
            }
            function updateCountryClear(){
                var input=$('#plannerCountry');
                var btn=$('#plannerCountryClear');
                if(btn) btn.classList.toggle('hidden',!(input && input.value));
            }
            function updateRegionClear(){
                var input=$('#plannerRegion');
                var btn=$('#plannerRegionClear');
                if(btn) btn.classList.toggle('hidden',!(input && input.value));
            }
            function refreshRegionOptions(clearValue){
                var country=$('#plannerCountry');
                var region=$('#plannerRegion');
                var dropdown=$('#plannerRegionDropdown');
                if(!country || !region || !dropdown) return;

                var matched=findPlannerCountry(country.value);
                dropdown.innerHTML='';

                if(clearValue) region.value='';

                if(!matched){
                    region.disabled=true;
                    region.placeholder='국가 먼저 입력';
                    region.value='';
                    dropdown.classList.add('hidden');
                    updateRegionClear();
                    return;
                }

                var options=PLANNER_REGION_MAP[matched.name]||[];
                region.disabled=options.length===0;
                region.placeholder=options.length ? '선택' : '지역 정보 없음';

                if(!options.length){
                    dropdown.classList.add('hidden');
                    updateRegionClear();
                    return;
                }

                renderRegionDropdown();
                dropdown.classList.add('hidden');
                updateRegionClear();
            }
            function renderRegionDropdown(){
                var country=$('#plannerCountry');
                var region=$('#plannerRegion');
                var dropdown=$('#plannerRegionDropdown');
                if(!country || !region || !dropdown) return;

                var matched=findPlannerCountry(country.value);
                var options=matched ? (PLANNER_REGION_MAP[matched.name]||[]) : [];
                var q=normalizePlannerText(region.value);
                var filtered=options.filter(function(r){ return !q || r.indexOf(q)!==-1; });

                dropdown.innerHTML='';
                filtered.forEach(function(r){
                    var btn=document.createElement('button');
                    btn.type='button';
                    btn.className='px-3 py-2 text-sm font-medium text-gray-800';
                    btn.textContent=r;
                    btn.addEventListener('mousedown',function(e){
                        e.preventDefault();
                        region.value=r;
                        dropdown.classList.add('hidden');
                        updateRegionClear();
                        markDirty();
                    });
                    dropdown.appendChild(btn);
                });
                dropdown.classList.toggle('hidden',filtered.length===0);
            }

            function showRequiredFieldsModal(items){
                var backdrop=$('#plannerRequiredBackdrop');
                var list=$('#plannerRequiredList');
                if(!backdrop || !list) return;
                list.innerHTML='';
                items.forEach(function(item){
                    var li=document.createElement('li');
                    li.textContent=item;
                    list.appendChild(li);
                });
                backdrop.classList.add('is-open');
                backdrop.setAttribute('aria-hidden','false');
                var close=$('#plannerRequiredClose');
                if(close) close.focus();
            }
            function closeRequiredFieldsModal(){
                var backdrop=$('#plannerRequiredBackdrop');
                if(!backdrop) return;
                backdrop.classList.remove('is-open');
                backdrop.setAttribute('aria-hidden','true');
            }
            function validatePlannerRequiredFields(){
                var missing=[];
                var title=$('#tripTitle');
                var country=$('#plannerCountry');

                if(!title || !normalizePlannerText(title.value)) missing.push('여행 제목');

                if(!country || !normalizePlannerText(country.value)){
                    missing.push('국가');
                    refreshCountryStatus();
                }else if(!findPlannerCountry(country.value)){
                    missing.push('일치하는 국가 선택');
                    refreshCountryStatus();
                }

                if(missing.length){
                    showRequiredFieldsModal(missing);
                    return false;
                }
                return true;
            }

            var plannerCountryInput=$('#plannerCountry');
            var plannerCountryClear=$('#plannerCountryClear');
            var plannerCountryDropdown=$('#plannerCountryDropdown');
            var plannerRegionInput=$('#plannerRegion');
            var plannerRegionClear=$('#plannerRegionClear');
            var plannerRegionDropdown=$('#plannerRegionDropdown');

            if(plannerCountryInput){
                plannerCountryInput.addEventListener('input',function(){
                    refreshCountryStatus();
                    refreshRegionOptions(true);
                    syncCountryLock();
                    updateCountryClear();
                    filterPlans();
                    closePlannerDropdowns('plannerCountryDropdown');
                    renderCountryDropdown();
                });
                plannerCountryInput.addEventListener('focus',function(){
                    closePlannerDropdowns('plannerCountryDropdown');
                    renderCountryDropdown();
                });
                plannerCountryInput.addEventListener('change',function(){
                    refreshCountryStatus();
                    refreshRegionOptions(false);
                    syncCountryLock();
                    updateCountryClear();
                    filterPlans();

                    if(findPlannerCountry(plannerCountryInput.value)){
                        centerMapOnPlannerCountry(
                            plannerCountryInput.value
                        );
                    }

                    syncForeignCosts();
                });
            }
            if(plannerCountryClear){
                plannerCountryClear.addEventListener('click',function(){
                    if(plannerCountryInput.disabled) return;
                    plannerCountryInput.value='';
                    refreshCountryStatus();
                    refreshRegionOptions(true);
                    syncCountryLock();
                    updateCountryClear();
                    filterPlans();
                    plannerCountryDropdown.classList.add('hidden');
                    plannerCountryInput.focus();
                    syncForeignCosts();
                    markDirty();
                });
            }
            if(plannerRegionInput){
                plannerRegionInput.addEventListener('input',function(){
                    updateRegionClear();
                    closePlannerDropdowns('plannerRegionDropdown');
                    renderRegionDropdown();
                });
                plannerRegionInput.addEventListener('focus',function(){
                    if(!plannerRegionInput.disabled){
                        closePlannerDropdowns('plannerRegionDropdown');
                        renderRegionDropdown();
                    }
                });
            }
            if(plannerRegionClear){
                plannerRegionClear.addEventListener('click',function(){
                    plannerRegionInput.value='';
                    updateRegionClear();
                    renderRegionDropdown();
                    plannerRegionInput.focus();
                    markDirty();
                });
            }

            document.addEventListener('mousedown',function(e){
                if(!e.target.closest('#plannerCountryCombo') && plannerCountryDropdown){
                    plannerCountryDropdown.classList.add('hidden');
                }
                if(!e.target.closest('#plannerRegionCombo') && plannerRegionDropdown){
                    plannerRegionDropdown.classList.add('hidden');
                }
            });

            var plannerItineraryId=EDIT_ITINERARY && EDIT_ITINERARY.itineraryId ? Number(EDIT_ITINERARY.itineraryId) : null;
            var plannerSaveLabel=$('#plannerSaveLabel');
            if(plannerSaveLabel) plannerSaveLabel.textContent='수정하기';

            function plannerDraftDisplayImageUrl(rawUrl){
                var url=String(rawUrl || '').trim();
                if(!url) return '';
                if(/^https?:\/\//i.test(url) || url.indexOf('blob:')===0 || url.indexOf('data:')===0){
                    return url;
                }
                var contextPath=(typeof PLANNER_CONTEXT_PATH!=='undefined') ? PLANNER_CONTEXT_PATH : '${pageContext.request.contextPath}';
                if(contextPath && url.indexOf(contextPath + '/')===0){
                    return url;
                }
                if(url.charAt(0)==='/'){
                    return contextPath + url;
                }
                return contextPath + '/' + url;
            }

            function collectDraftFiles(){
                var files=[];
                $$('.planner-day').forEach(function(day,dayIndex){
                    $$('.planner-block-card',day).forEach(function(card,blockIndex){
                        var gallery=$('[data-photo-gallery]',card);
                        if(!gallery) return;
                        $$('.planner-photo-thumb',gallery).forEach(function(thumb,imageIndex){
                            if(thumb._plannerFile){
                                files.push({
                                    dayIndex:dayIndex,
                                    blockIndex:blockIndex,
                                    imageIndex:imageIndex,
                                    file:thumb._plannerFile
                                });
                            }
                        });
                    });
                });
                return files;
            }

            function openPlannerDraftDb(){
                return new Promise(function(resolve,reject){
                    if(!window.indexedDB){
                        reject(new Error('IndexedDB unavailable'));
                        return;
                    }
                    var request=indexedDB.open('tripily_planner_drafts',1);
                    request.onupgradeneeded=function(){
                        var db=request.result;
                        if(!db.objectStoreNames.contains('draftFiles')){
                            db.createObjectStore('draftFiles',{keyPath:'id'});
                        }
                    };
                    request.onsuccess=function(){ resolve(request.result); };
                    request.onerror=function(){ reject(request.error || new Error('IndexedDB open failed')); };
                });
            }

            function savePlannerDraftFiles(files){
                return openPlannerDraftDb().then(function(db){
                    return new Promise(function(resolve,reject){
                        var tx=db.transaction('draftFiles','readwrite');
                        tx.objectStore('draftFiles').put({
                            id:DRAFT_KEY,
                            savedAt:new Date().toISOString(),
                            files:files || []
                        });
                        tx.oncomplete=function(){ db.close(); resolve(); };
                        tx.onerror=function(){ var err=tx.error; db.close(); reject(err); };
                        tx.onabort=function(){ var err=tx.error; db.close(); reject(err); };
                    });
                });
            }

            function loadPlannerDraftFiles(){
                return openPlannerDraftDb().then(function(db){
                    return new Promise(function(resolve,reject){
                        var tx=db.transaction('draftFiles','readonly');
                        var req=tx.objectStore('draftFiles').get(DRAFT_KEY);
                        req.onsuccess=function(){
                            var value=req.result;
                            resolve(value && Array.isArray(value.files) ? value.files : []);
                        };
                        req.onerror=function(){ reject(req.error); };
                        tx.oncomplete=function(){ db.close(); };
                        tx.onerror=function(){ db.close(); };
                    });
                }).catch(function(){ return []; });
            }

            function deletePlannerDraft(){
                try{ sessionStorage.removeItem(DRAFT_KEY); }catch(e){}
                return openPlannerDraftDb().then(function(db){
                    return new Promise(function(resolve){
                        var tx=db.transaction('draftFiles','readwrite');
                        tx.objectStore('draftFiles').delete(DRAFT_KEY);
                        tx.oncomplete=function(){ db.close(); resolve(); };
                        tx.onerror=function(){ db.close(); resolve(); };
                        tx.onabort=function(){ db.close(); resolve(); };
                    });
                }).catch(function(){});
            }

            function collectDraft(){
                return {
                    version:5,
                    reason:'session-expired',
                    mode:'edit',
                    itineraryId:(typeof plannerItineraryId!=='undefined' && plannerItineraryId) ? Number(plannerItineraryId) : null,
                    payload:collectPlannerPayload(),
                    savedAt:new Date().toISOString()
                };
            }

            function saveDraftToSessionStorage(){
                if(restoringDraft) return null;
                try{
                    var draft=collectDraft();
                    sessionStorage.setItem(DRAFT_KEY,JSON.stringify(draft));
                    return draft;
                }catch(e){
                    console.warn('일정 임시저장에 실패했습니다.',e);
                    return null;
                }
            }

            function saveDraftNow(){
                if(restoringDraft) return Promise.resolve();
                saveDraftToSessionStorage();
                return savePlannerDraftFiles(collectDraftFiles()).catch(function(e){
                    console.warn('일정 사진 임시저장에 실패했습니다.',e);
                });
            }

            function refreshPlannerDraftGallery(gallery){
                if(!gallery) return;
                var thumbs=$$('.planner-photo-thumb',gallery);
                thumbs.forEach(function(thumb,index){
                    var src=String(thumb.dataset.src || '').trim();
                    thumb.dataset.index=index;
                    thumb.classList.toggle('has-image',!!src);
                    thumb.classList.toggle('is-empty',!src);

                    var img=$('img',thumb);
                    if(src){
                        if(!img){
                            img=document.createElement('img');
                            img.alt='블록 이미지';
                            thumb.insertBefore(img,thumb.firstChild);
                        }
                        img.src=plannerDraftDisplayImageUrl(src);
                    }else if(img){
                        img.remove();
                    }

                    var label=$('.planner-photo-hover-label',thumb);
                    if(label) label.textContent=src ? '이미지 변경하기' : '이미지 등록하기';

                    var badge=$('.planner-photo-badge',thumb);
                    if(index===0 && src){
                        if(!badge){
                            badge=document.createElement('span');
                            badge.className='planner-photo-badge';
                            badge.textContent='대표';
                            thumb.appendChild(badge);
                        }
                    }else if(badge){
                        badge.remove();
                    }
                });

                var first=thumbs.find(function(t){ return !!String(t.dataset.src || '').trim(); });
                var firstSrc=first ? String(first.dataset.src || '').trim() : '';
                var previewImg=$('.planner-photo-preview-img',gallery);
                var previewEmpty=$('.planner-photo-empty',gallery);
                if(previewImg){
                    if(firstSrc){
                        previewImg.src=plannerDraftDisplayImageUrl(firstSrc);
                        previewImg.style.display='block';
                    }else{
                        previewImg.removeAttribute('src');
                        previewImg.style.display='none';
                    }
                }
                if(previewEmpty) previewEmpty.style.display=firstSrc ? 'none' : 'flex';
            }

            function applyPlannerDraftImages(card,images,fileRecords,dayIndex,blockIndex){
                var gallery=$('[data-photo-gallery]',card);
                if(!gallery) return;
                var thumbs=$$('.planner-photo-thumb',gallery);

                thumbs.forEach(function(thumb){
                    if(thumb.dataset.objectUrl){
                        try{ URL.revokeObjectURL(thumb.dataset.objectUrl); }catch(e){}
                    }
                    thumb.dataset.objectUrl='';
                    thumb.dataset.src='';
                    thumb._plannerFile=null;
                });

                (Array.isArray(images) ? images : []).forEach(function(image,index){
                    var slot=Math.max(0,Number(image.imageOrder || (index+1))-1);
                    var thumb=thumbs[slot];
                    if(thumb && image && image.imageUrl){
                        thumb.dataset.src=String(image.imageUrl);
                    }
                });

                (Array.isArray(fileRecords) ? fileRecords : []).forEach(function(record){
                    if(Number(record.dayIndex)!==dayIndex || Number(record.blockIndex)!==blockIndex || !record.file) return;
                    var thumb=thumbs[Number(record.imageIndex)];
                    if(!thumb) return;
                    var objectUrl=URL.createObjectURL(record.file);
                    thumb.dataset.src=objectUrl;
                    thumb.dataset.objectUrl=objectUrl;
                    thumb._plannerFile=record.file;
                });

                refreshPlannerDraftGallery(gallery);
            }

            function applyPlannerDraftPayload(payload,fileRecords){
                if(!payload) return;
                restoringDraft=true;
                try{
                    var tripTitle=$('#tripTitle');
                    var country=$('#plannerCountry');
                    var region=$('#plannerRegion');
                    var traveler=$('#plannerTravelerCount');
                    if(tripTitle) tripTitle.value=payload.title || '';
                    if(country) country.value=payload.country || '';
                    refreshCountryStatus();
                    refreshRegionOptions(false);
                    if(region) region.value=payload.city || '';
                    if(traveler) traveler.value=String(payload.travelerCount || 1);
                    if(startDate) startDate.value=payload.startDate || '';
                    if(endDate) endDate.value=payload.endDate || '';
                    setPlannerVisibility(payload.visibility || 'PUBLIC',false);
                    syncDates();

                    if(typeof plannerPublishState!=='undefined'){
                        plannerPublishState.summary=payload.summary || '';
                        plannerPublishState.thumbnailUrl=payload.thumbnailImg || '';
                        plannerPublishState.imageKey='';
                    }
                    var publishSummary=$('#plannerPublishSummary');
                    if(publishSummary){
                        publishSummary.value=payload.summary || '';
                        var summaryCount=$('#plannerPublishSummaryCount');
                        if(summaryCount) summaryCount.textContent=publishSummary.value.length+' / 500자';
                    }

                    var existingDays=$$('.planner-day');
                    var firstDay=existingDays[0];
                    existingDays.slice(1).forEach(function(day){ day.remove(); });
                    if(firstDay){
                        var firstBody=$('.planner-day-body',firstDay);
                        if(firstBody){
                            $$('.planner-block-card,.planner-block-summary,.planner-empty-day-hint',firstBody)
                                .forEach(function(node){ node.remove(); });
                        }
                    }

                    var days=Array.isArray(payload.days) ? payload.days.slice().sort(function(a,b){
                        return Number(a.dayOrder||0)-Number(b.dayOrder||0);
                    }) : [];
                    if(!days.length) days=[{dayOrder:1,title:'Day 1',blocks:[]}];

                    days.forEach(function(dayDto,index){
                        var day;
                        if(index===0){
                            day=firstDay;
                        }else{
                            var beforeCount=$$('.planner-day').length;
                            var addDayButton=$('#plannerAddDay');
                            if(addDayButton) addDayButton.click();
                            var dayList=$$('.planner-day');
                            day=dayList[beforeCount] || dayList[dayList.length-1];
                        }
                        if(!day) return;

                        day.dataset.dayNumber=String(index+1);
                        day.dataset.dayOrder=String(index+1);
                        var dayTitle=$('.planner-day-title',day);
                        if(dayTitle) dayTitle.textContent=dayDto.title || ('Day '+(index+1));

                        var body=$('.planner-day-body',day);
                        if(body){
                            $$('.planner-block-card,.planner-block-summary,.planner-empty-day-hint',body)
                                .forEach(function(node){ node.remove(); });
                        }

                        var blocks=Array.isArray(dayDto.blocks) ? dayDto.blocks.slice().sort(function(a,b){
                            return Number(a.blockOrder||0)-Number(b.blockOrder||0);
                        }) : [];

                        blocks.forEach(function(block,blockIndex){
                            var card=addBlockToDay(day,{
                                sourceBlockId:block.sourceBlockId || null,
                                type:dbBlockTypeToPlanner(block.blockType),
                                title:block.title || '',
                                startTime:shortTime(block.startTime),
                                endTime:shortTime(block.endTime),
                                cost:block.cost==null ? '' : block.cost,
                                costType:block.costType || 'PER_PERSON',
                                googlePlaceId:block.googlePlaceId || '',
                                placeName:block.placeName || '',
                                placeAddress:block.placeAddress || '',
                                placeLat:block.placeLat,
                                placeLng:block.placeLng,
                                note:block.memo || ''
                            });
                            if(card){
                                applyPlannerDraftImages(card,block.images || [],fileRecords,index,blockIndex);
                            }
                        });

                        ensureDayControls(day);
                    });

                    renumberDays();
                    syncBudget();
                    refreshCountryStatus();
                    refreshRegionOptions(false);
                    updateCountryClear();
                    updateRegionClear();
                    syncCountryLock();
                    syncCountryEditLock();
                    syncForeignCosts();
                    if(typeof refreshMap==='function') refreshMap('all');
                }finally{
                    restoringDraft=false;
                    dirty=true;
                }
            }

            function restoreDraft(){
                var raw=null;
                try{ raw=sessionStorage.getItem(DRAFT_KEY); }catch(e){}
                if(!raw) return Promise.resolve(false);

                var draft;
                try{
                    draft=JSON.parse(raw);
                }catch(e){
                    sessionStorage.removeItem(DRAFT_KEY);
                    return Promise.resolve(false);
                }

                if(!draft || !draft.payload) return Promise.resolve(false);
                if(draft.mode && draft.mode!=='edit') return Promise.resolve(false);

                // 예전 자동저장본이나 일반 페이지 이동 중 만들어진 임시저장본은 복구하지 않는다.
                if(draft.reason!=='session-expired'){
                    return deletePlannerDraft().then(function(){ return false; });
                }

                return loadPlannerDraftFiles().then(function(files){
                    applyPlannerDraftPayload(draft.payload,files);
                    toast('세션 만료 전에 임시저장된 작성 내용을 복구했습니다.');
                    // 세션 만료 복구본은 한 번만 사용한다.
                    return deletePlannerDraft().then(function(){ return true; });
                });
            }
            function plannerBlockTypeToDb(type){
                var map={
                    sightseeing:'ATTRACTION',
                    meal:'MEAL',
                    accommodation:'LODGING',
                    transport:'TRANSPORT',
                    activity:'ACTIVITY'
                };
                return map[type] || 'ATTRACTION';
            }

            function normalizePlannerTime(value){
                if(!value) return null;
                return value.length===5 ? value+':00' : value;
            }

            function collectPlannerImages(card){
                var gallery=$('[data-photo-gallery]',card);
                if(!gallery) return [];

                var images=[];

                $$('.planner-photo-thumb',gallery).forEach(function(thumb,index){
                    var src=thumb.dataset.src || '';

                    if(!src){
                        var img=$('img',thumb);
                        if(img) src=img.getAttribute('src') || '';
                    }

                    src=String(src || '').trim();

                    /*
                     * 새로 선택한 로컬 파일은 blob: URL이므로
                     * DB에 blob URL을 넣지 않는다.
                     *
                     * 대신 imageUrl=null 상태의 ImageDto를 JSON에 넣고,
                     * 실제 파일은 multipart Part로 별도 전송한다.
                     * 서버가 저장 후 imageUrl을 실제 경로로 채운다.
                     */
                    if(thumb._plannerFile){
                        images.push({
                            imageUrl:null,
                            imageOrder:index+1
                        });
                        return;
                    }

                    /*
                     * 수정 모드에서 기존 DB 이미지라면
                     * 기존 imageUrl을 그대로 유지한다.
                     */
                    if(src && src.indexOf('blob:')!==0){
                        images.push({
                            imageUrl:src,
                            imageOrder:index+1
                        });
                    }
                });

                return images;
            }

            function appendPlannerImageParts(form){
                /*
                 * 이전 저장 시 생성한 동적 file input 제거
                 */
                $$('.planner-upload-part',form).forEach(function(input){
                    input.remove();
                });

                $$('.planner-day').forEach(function(day,dayIndex){
                    $$('.planner-block-card',day).forEach(function(card,blockIndex){
                        var gallery=$('[data-photo-gallery]',card);
                        if(!gallery) return;

                        $$('.planner-photo-thumb',gallery).forEach(function(thumb,index){
                            var file=thumb._plannerFile;
                            if(!file) return;

                            var dt=new DataTransfer();
                            dt.items.add(file);

                            var input=document.createElement('input');
                            input.type='file';
                            input.name=
                                'blockImage_'
                                + dayIndex + '_'
                                + blockIndex + '_'
                                + (index+1);

                            input.className='planner-upload-part';
                            input.files=dt.files;
                            input.hidden=true;

                            form.appendChild(input);
                        });
                    });
                });
            }

            function collectPlannerPayload(){
                var days=[];

                $$('.planner-day').forEach(function(day,dayIndex){
                    var blocks=[];

                    $$('.planner-block-card',day).forEach(function(card,blockIndex){
                        var title=$('.planner-item-title',card);
                        var start=$('.planner-start-time',card);
                        var end=$('.planner-end-time',card);
                        var cost=$('.planner-item-cost',card);
                        var memo=$('.planner-item-note',card);
                        var placeInput=$('.planner-place-search',card);
                        var selectedPlace=plannerSelectedPlacePoint(placeInput);

                        blocks.push({
                            sourceBlockId:card.dataset.sourceBlockId
                                ? Number(card.dataset.sourceBlockId)
                                : null,
                            googlePlaceId:selectedPlace
                                ? selectedPlace.googlePlaceId
                                : null,
                            placeName:selectedPlace
                                ? selectedPlace.name
                                : null,
                            placeAddress:selectedPlace
                                ? selectedPlace.address
                                : null,
                            placeLat:selectedPlace
                                ? selectedPlace.lat
                                : null,
                            placeLng:selectedPlace
                                ? selectedPlace.lng
                                : null,
                            blockType:plannerBlockTypeToDb(card.dataset.itemType),
                            blockOrder:blockIndex+1,
                            costType:getPlannerCardCostType(card),
                            title:title ? title.value.trim() : '',
                            memo:memo ? memo.value.trim() : '',
                            cost:cost && cost.value ? Number(cost.value) : 0,
                            startTime:normalizePlannerTime(start ? start.value : ''),
                            endTime:normalizePlannerTime(end ? end.value : ''),
                            images:collectPlannerImages(card)
                        });
                    });

                    var dayTitle=$('.planner-day-title',day);

                    days.push({
                        sourceDayId:null,
                        dayOrder:dayIndex+1,
                        dayDate:null,
                        title:dayTitle ? dayTitle.textContent.trim() : ('Day '+(dayIndex+1)),
                        blocks:blocks
                    });
                });

                return {
                    itineraryId:plannerItineraryId ? Number(plannerItineraryId) : null,
                    sourceItineraryId:null,
                    title:$('#tripTitle') ? $('#tripTitle').value.trim() : '',
                    summary:plannerPublishState.summary || null,
                    continent:null,
                    country:$('#plannerCountry') ? $('#plannerCountry').value.trim() : '',
                    city:$('#plannerRegion') && $('#plannerRegion').value.trim()
                        ? $('#plannerRegion').value.trim()
                        : null,
                    travelerCount:$('#plannerTravelerCount')
                        ? Number($('#plannerTravelerCount').value || 1)
                        : 1,
                    startDate:startDate && startDate.value ? startDate.value : null,
                    endDate:endDate && endDate.value ? endDate.value : null,
                    visibility:visibility && visibility.dataset.visibility
                        ? visibility.dataset.visibility
                        : 'PUBLIC',
                    thumbnailImg:plannerPublishState.thumbnailUrl || null,
                    days:days
                };
            }

            var plannerPublishState={
                imageKey:'',
                thumbnailUrl:'',
                summary:EDIT_ITINERARY && EDIT_ITINERARY.summary
                    ? EDIT_ITINERARY.summary
                    : ''
            };

            function collectPublishPhotoCandidates(){
                var result=[];

                $$('.planner-day').forEach(function(day,dayIndex){
                    $$('.planner-block-card',day).forEach(function(card,blockIndex){
                        var gallery=$('[data-photo-gallery]',card);
                        if(!gallery) return;

                        $$('.planner-photo-thumb',gallery).forEach(function(thumb,index){
                            var src=String(thumb.dataset.src || '').trim();
                            if(!src){
                                var img=$('img',thumb);
                                if(img) src=String(img.getAttribute('src') || '').trim();
                            }
                            if(!src) return;

                            result.push({
                                key:dayIndex+':'+blockIndex+':'+(index+1),
                                src:src,
                                dayIndex:dayIndex,
                                blockIndex:blockIndex,
                                imageOrder:index+1
                            });
                        });
                    });
                });

                return result;
            }

            function formatPlannerCardDate(value){
                if(!value) return '';
                return String(value).replace(/-/g,'.');
            }

            function refreshPublishCard(){
                var title=$('#plannerPublishCardTitle');
                var badge=$('#plannerPublishCountryBadge');
                var dates=$('#plannerPublishCardDates');
                var summary=$('#plannerPublishCardSummary');
                var cover=$('#plannerPublishCover');
                var coverImg=$('#plannerPublishCoverImg');
                var created=$('#plannerPublishCardCreated');

                if(title) title.textContent=$('#tripTitle')?.value.trim() || '제목 없는 일정';

                var country=$('#plannerCountry')?.value.trim() || '';
                var city=$('#plannerRegion')?.value.trim() || '';
                if(badge) badge.textContent=[country,city].filter(Boolean).join(' · ');

                var s=startDate && startDate.value ? formatPlannerCardDate(startDate.value) : '';
                var e=endDate && endDate.value ? formatPlannerCardDate(endDate.value) : '';
                if(dates) dates.textContent=s && e ? s+' ~ '+e : (s || e || '');

                if(created){
                    var today=new Date();
                    var yyyy=today.getFullYear();
                    var mm=String(today.getMonth()+1).padStart(2,'0');
                    var dd=String(today.getDate()).padStart(2,'0');
                    created.textContent=yyyy+'.'+mm+'.'+dd;
                }

                if(summary){
                    summary.textContent=plannerPublishState.summary.trim()
                        ? plannerPublishState.summary.trim()
                        : '일정 소개를 입력해 주세요.';
                }

                if(cover && coverImg){
                    if(plannerPublishState.thumbnailUrl
                            && String(plannerPublishState.thumbnailUrl).indexOf('gplace:')!==0){
                        coverImg.src=plannerDisplayImageUrl(plannerPublishState.thumbnailUrl);
                        cover.classList.add('has-image');
                    }else{
                        coverImg.removeAttribute('src');
                        cover.classList.remove('has-image');
                    }
                }
            }

            function selectPublishImage(candidate){
                plannerPublishState.imageKey=candidate ? candidate.key : '';
                plannerPublishState.thumbnailUrl=candidate ? candidate.src : '';

                $$('.planner-publish-photo-option').forEach(function(btn){
                    btn.classList.toggle(
                        'is-selected',
                        !!candidate && btn.dataset.imageKey===candidate.key
                    );
                });

                var err=$('#plannerPublishPhotoError');
                if(err) err.classList.remove('is-visible');
                refreshPublishCard();
            }

            var plannerPublishPlacePhotoLoadToken=0;

            function plannerPrivateFlagCandidate(){
                var countryInput=$('#plannerCountry');
                var matched=findPlannerCountry(
                    countryInput ? countryInput.value : ''
                );

                if(!matched || !matched.code) return null;

                var code=String(matched.code).toUpperCase();

                return {
                    key:'flag:'+code,
                    src:'https://flagcdn.com/w640/'+code.toLowerCase()+'.png',
                    source:'flag',
                    countryCode:code,
                    countryName:matched.name || (countryInput ? countryInput.value.trim() : '')
                };
            }

            function isPlannerFlagThumbnailUrl(value){
                return /^https:\/\/flagcdn\.com\/w640\/[a-z]{2}\.png(?:[?#].*)?$/i.test(
                    String(value || '').trim()
                );
            }

            function syncPublishPhotoRequirement(isPublic){
                var requirement=$('#plannerPublishPhotoRequirement');
                var hint=$('#plannerPublishPhotoHint');

                if(requirement){
                    requirement.textContent=isPublic ? '(필수)' : '(자동)';
                }

                if(hint){
                    hint.textContent=isPublic
                        ? '업로드 사진 우선 · 없으면 일정 장소 사진'
                        : '비공개 일정은 선택한 국가의 국기를 자동 사용';
                }
            }

            function collectPublishPlacePhotoSources(){
                var result=[];
                var seen={};

                $$('.planner-day').forEach(function(day,dayIndex){
                    $$('.planner-block-card',day).forEach(function(card,blockIndex){
                        var input=$('.planner-place-search',card);
                        var point=plannerSelectedPlacePoint(input);
                        var placeId=point && point.googlePlaceId
                            ? String(point.googlePlaceId).trim()
                            : '';

                        if(!placeId || seen[placeId]) return;
                        seen[placeId]=true;

                        result.push({
                            key:'place:'+dayIndex+':'+blockIndex,
                            point:point,
                            placeId:placeId,
                            dayIndex:dayIndex,
                            blockIndex:blockIndex
                        });
                    });
                });

                return result;
            }

            function collectPublishPlacePhotoCandidates(){
                var sources=collectPublishPlacePhotoSources();
                if(!sources.length) return Promise.resolve([]);

                return Promise.all(sources.map(function(source){
                    return fetchPlannerPlaceDetails(source.point)
                        .then(function(details){
                            if(!details || !details.photos || !details.photos.length){
                                return null;
                            }

                            var photo=details.photos[0];
                            var src='';
                            try{
                                src=photo.getURI({
                                    maxWidth:960,
                                    maxHeight:720
                                }) || '';
                            }catch(e){
                                src='';
                            }

                            if(!src) return null;

                            return {
                                key:source.key,
                                src:src,
                                source:'place',
                                placeId:source.placeId,
                                placeName:details.displayName
                                    || source.point.name
                                    || '장소',
                                attributionNames:(photo.authorAttributions || []).map(function(attr){
                                    return attr && attr.displayName
                                        ? String(attr.displayName)
                                        : '사용자';
                                }),
                                dayIndex:source.dayIndex,
                                blockIndex:source.blockIndex
                            };
                        })
                        .catch(function(){
                            return null;
                        });
                })).then(function(items){
                    return items.filter(function(item){ return !!item; });
                });
            }

            function renderPublishPhotoCandidateButtons(candidates){
                var list=$('#plannerPublishPhotoList');
                if(!list) return;

                list.innerHTML='';

                candidates.forEach(function(candidate){
                    var btn=document.createElement('button');
                    btn.type='button';
                    btn.className='planner-publish-photo-option';
                    btn.dataset.imageKey=candidate.key;

                    if(candidate.source==='place'){
                        btn.dataset.placePhoto='1';
                        btn.title=(candidate.placeName || '장소')+' 장소 사진';
                    }else if(candidate.source==='flag'){
                        btn.dataset.countryFlag='1';
                        btn.title=(candidate.countryName || '선택 국가')+' 국기';
                    }

                    var img=document.createElement('img');
                    img.src=plannerDisplayImageUrl(candidate.src);
                    img.alt=candidate.source==='place'
                        ? (candidate.placeName || '장소')+' 사진'
                        : candidate.source==='flag'
                            ? (candidate.countryName || '선택 국가')+' 국기'
                            : '대표 이미지 후보';
                    btn.appendChild(img);

                    if(candidate.source==='place'){
                        var credit=document.createElement('span');
                        credit.style.position='absolute';
                        credit.style.left='5px';
                        credit.style.top='5px';
                        credit.style.maxWidth='88%';
                        credit.style.padding='2px 4px';
                        credit.style.borderRadius='4px';
                        credit.style.background='rgba(0,0,0,.52)';
                        credit.style.color='#fff';
                        credit.style.fontSize='8px';
                        credit.style.lineHeight='1.2';
                        credit.style.textAlign='left';
                        credit.style.pointerEvents='none';
                        credit.textContent='Google Maps'
                            +(candidate.attributionNames && candidate.attributionNames.length
                                ? ' · 사진: '+candidate.attributionNames.join(', ')
                                : '');
                        btn.appendChild(credit);
                    }

                    btn.addEventListener('click',function(){
                        selectPublishImage(candidate);
                    });

                    list.appendChild(btn);
                });
            }

            function applyPlannerPublishCandidateSelection(candidates){
                var existingToken=EDIT_ITINERARY && EDIT_ITINERARY.thumbnailImg
                    ? String(EDIT_ITINERARY.thumbnailImg)
                    : '';
                var existingPlaceId=existingToken.indexOf('gplace:')===0
                    ? existingToken.substring(7)
                    : '';
                var existingPlaceStillInPlan=existingPlaceId
                    ? collectPublishPlacePhotoSources().some(function(source){
                        return source.placeId===existingPlaceId;
                    })
                    : false;

                if(existingPlaceId
                        && !existingPlaceStillInPlan
                        && plannerPublishState.imageKey==='placeId:'+existingPlaceId){
                    plannerPublishState.imageKey='';
                    plannerPublishState.thumbnailUrl='';
                    refreshPublishCard();
                }

                /* 기존 로컬 업로드 대표 이미지 복원 */
                if(!plannerPublishState.imageKey && existingToken
                        && !existingPlaceId){
                    var existing=candidates.find(function(candidate){
                        return candidate.src===existingToken;
                    });
                    if(existing) selectPublishImage(existing);
                }

                /* 기존 장소 대표 이미지는 placeId 기준으로 새 사진 URI를 다시 받아 복원 */
                if(existingPlaceId){
                    var existingPlaceCandidate=candidates.find(function(candidate){
                        return candidate.source==='place'
                            && candidate.placeId===existingPlaceId;
                    });

                    if(existingPlaceCandidate
                            && (plannerPublishState.imageKey==='placeId:'+existingPlaceId
                                || !plannerPublishState.imageKey)){
                        selectPublishImage(existingPlaceCandidate);
                        return;
                    }
                }

                if(plannerPublishState.imageKey){
                    var selected=candidates.find(function(candidate){
                        return candidate.key===plannerPublishState.imageKey;
                    });

                    if(selected){
                        selectPublishImage(selected);
                    }else if(plannerPublishState.imageKey.indexOf('placeId:')!==0){
                        plannerPublishState.imageKey='';
                        plannerPublishState.thumbnailUrl='';
                        refreshPublishCard();
                    }
                }
            }

            function renderPublishPhotoCandidates(){
                var list=$('#plannerPublishPhotoList');
                var empty=$('#plannerPublishPhotoEmpty');
                if(!list) return;

                var loadToken=++plannerPublishPlacePhotoLoadToken;
                var isPublic=visibility
                    && visibility.dataset.visibility==='PUBLIC';

                syncPublishPhotoRequirement(isPublic);

                /*
                 * 비공개 일정은 업로드/장소 사진 선택과 무관하게
                 * 선택한 국가의 국기를 대표 이미지로 자동 지정한다.
                 */
                if(!isPublic){
                    var flagCandidate=plannerPrivateFlagCandidate();

                    if(flagCandidate){
                        renderPublishPhotoCandidateButtons([flagCandidate]);
                        list.classList.remove('hidden');
                        if(empty) empty.classList.add('hidden');
                        selectPublishImage(flagCandidate);
                    }else{
                        plannerPublishState.imageKey='';
                        plannerPublishState.thumbnailUrl='';
                        list.innerHTML='';
                        list.classList.add('hidden');
                        if(empty){
                            empty.textContent='국가를 선택하면 해당 국가의 국기가 대표 이미지로 자동 지정됩니다.';
                            empty.classList.remove('hidden');
                        }
                        refreshPublishCard();
                    }
                    return;
                }

                /*
                 * 비공개에서 공개로 바뀐 경우 국기는 공개 대표 이미지로
                 * 인정하지 않는다. 공개 일정은 사용자가 사진을 직접 골라야 한다.
                 */
                if((plannerPublishState.imageKey
                        && plannerPublishState.imageKey.indexOf('flag:')===0)
                        || isPlannerFlagThumbnailUrl(plannerPublishState.thumbnailUrl)){
                    plannerPublishState.imageKey='';
                    plannerPublishState.thumbnailUrl='';
                    refreshPublishCard();
                }

                var candidates=collectPublishPhotoCandidates();

                if(candidates.length){
                    renderPublishPhotoCandidateButtons(candidates);
                    if(empty) empty.classList.add('hidden');
                    list.classList.remove('hidden');
                    applyPlannerPublishCandidateSelection(candidates);
                    return;
                }

                list.innerHTML='';
                list.classList.add('hidden');

                if(empty){
                    empty.textContent='업로드한 사진이 없어 일정 장소의 사진을 불러오는 중입니다.';
                    empty.classList.remove('hidden');
                }

                collectPublishPlacePhotoCandidates().then(function(placeCandidates){
                    if(loadToken!==plannerPublishPlacePhotoLoadToken) return;

                    if(placeCandidates.length){
                        renderPublishPhotoCandidateButtons(placeCandidates);
                        list.classList.remove('hidden');
                        if(empty) empty.classList.add('hidden');
                        applyPlannerPublishCandidateSelection(placeCandidates);
                    }else{
                        list.classList.add('hidden');
                        if(empty){
                            empty.textContent='대표 이미지로 사용할 수 있는 업로드 사진 또는 장소 사진이 없습니다.';
                            empty.classList.remove('hidden');
                        }
                    }
                });
            }

            function openPublishPreviewModal(){
                var backdrop=$('#plannerPublishBackdrop');
                var summaryInput=$('#plannerPublishSummary');

                if(!backdrop) return;

                if(summaryInput){
                    summaryInput.value=plannerPublishState.summary || '';
                    var count=$('#plannerPublishSummaryCount');
                    if(count) count.textContent=summaryInput.value.length+' / 500자';
                }

                renderPublishPhotoCandidates();
                refreshPublishCard();

                var controls=$('#plannerPublishControls');
                if(controls){
                    controls.style.display='block';
                    controls.style.visibility='visible';
                    controls.style.opacity='1';
                }

                var summarySection=$('#plannerPublishSummarySection');
                if(summarySection){
                    summarySection.style.display='block';
                    summarySection.style.visibility='visible';
                }

                $('#plannerPublishPhotoError')?.classList.remove('is-visible');
                $('#plannerPublishSummaryError')?.classList.remove('is-visible');

                backdrop.classList.add('is-open');
                backdrop.setAttribute('aria-hidden','false');
                document.body.style.overflow='hidden';
            }

            function closePublishPreviewModal(){
                var backdrop=$('#plannerPublishBackdrop');
                if(!backdrop) return;
                backdrop.classList.remove('is-open');
                backdrop.setAttribute('aria-hidden','true');
                document.body.style.overflow='';
            }

            function submitPlannerAfterPreview(){
                var form=$('#plannerSubmitForm');
                var jsonInput=$('#plannerItineraryJson');
                var thumbInput=$('#plannerThumbnailImageKey');

                if(!form || !jsonInput || !thumbInput){
                    toast('저장 폼을 찾을 수 없습니다.');
                    return;
                }

                var payload=collectPlannerPayload();

                appendPlannerImageParts(form);

                thumbInput.value=plannerPublishState.imageKey;
                jsonInput.value=JSON.stringify(payload);

                form.action='${pageContext.request.contextPath}/itinerary/modify';

                keepPlannerSessionAlive(true).then(function(sessionOk){
                    if(!sessionOk || sessionExpiredHandling) return;
                    // 정상 저장에서는 임시저장본을 남기지 않는다.
                    return deletePlannerDraft().then(function(){
                        dirty=false;
                        form.submit();
                    });
                });
            }

            function setupPublishPreviewModal(){
                var plannerPublishSummary=$('#plannerPublishSummary');
                var plannerPublishCover=$('#plannerPublishCover');
                var plannerPublishClose=$('#plannerPublishClose');
                var plannerPublishCancel=$('#plannerPublishCancel');
                var plannerPublishBackdrop=$('#plannerPublishBackdrop');
                var plannerPublishConfirm=$('#plannerPublishConfirm');

                if(plannerPublishSummary && !plannerPublishSummary.dataset.bound){
                    plannerPublishSummary.dataset.bound='1';

                    plannerPublishSummary.addEventListener('input',function(){
                        plannerPublishState.summary=plannerPublishSummary.value;

                        var count=$('#plannerPublishSummaryCount');
                        if(count){
                            count.textContent=
                                plannerPublishSummary.value.length+' / 500자';
                        }

                        var summaryError=$('#plannerPublishSummaryError');
                        if(summaryError){
                            summaryError.classList.remove('is-visible');
                        }

                        refreshPublishCard();
                    });
                }

                if(plannerPublishCover && !plannerPublishCover.dataset.bound){
                    plannerPublishCover.dataset.bound='1';

                    plannerPublishCover.addEventListener('click',function(){
                        var controls=$('#plannerPublishControls');
                        var list=$('#plannerPublishPhotoList');
                        var first=$('.planner-publish-photo-option');
                        var empty=$('#plannerPublishPhotoEmpty');

                        if(controls){
                            controls.classList.add('is-emphasis');
                            controls.scrollIntoView({
                                behavior:'smooth',
                                block:'nearest'
                            });

                            window.setTimeout(function(){
                                controls.classList.remove('is-emphasis');
                            },900);
                        }

                        if(first){
                            first.focus();
                        }else if(empty){
                            empty.classList.remove('hidden');
                        }
                    });
                }

                if(plannerPublishClose && !plannerPublishClose.dataset.bound){
                    plannerPublishClose.dataset.bound='1';
                    plannerPublishClose.addEventListener(
                        'click',
                        closePublishPreviewModal
                    );
                }

                if(plannerPublishCancel && !plannerPublishCancel.dataset.bound){
                    plannerPublishCancel.dataset.bound='1';
                    plannerPublishCancel.addEventListener(
                        'click',
                        closePublishPreviewModal
                    );
                }

                if(plannerPublishBackdrop && !plannerPublishBackdrop.dataset.bound){
                    plannerPublishBackdrop.dataset.bound='1';

                    plannerPublishBackdrop.addEventListener('click',function(e){
                        if(e.target===e.currentTarget){
                            closePublishPreviewModal();
                        }
                    });
                }

                if(plannerPublishConfirm && !plannerPublishConfirm.dataset.bound){
                    plannerPublishConfirm.dataset.bound='1';

                    plannerPublishConfirm.addEventListener('click',function(){
                        var summaryInput=$('#plannerPublishSummary');
                        var isPublic=visibility
                            && visibility.dataset.visibility==='PUBLIC';
                        var photoError=$('#plannerPublishPhotoError');

                        /* 공개 일정은 대표 이미지를 반드시 직접 선택해야 한다. */
                        if(isPublic && (!plannerPublishState.imageKey
                                || plannerPublishState.imageKey.indexOf('flag:')===0)){
                            if(photoError){
                                photoError.textContent='공개 일정은 대표 이미지를 선택해야 저장할 수 있습니다.';
                                photoError.classList.add('is-visible');
                            }

                            var controls=$('#plannerPublishControls');
                            if(controls){
                                controls.scrollIntoView({
                                    behavior:'smooth',
                                    block:'nearest'
                                });
                            }
                            return;
                        }

                        plannerPublishState.summary=
                            summaryInput ? summaryInput.value : '';

                        closePublishPreviewModal();
                        submitPlannerAfterPreview();
                    });
                }
            }

            /*
             * 미리보기 모달 HTML은 현재 script 뒤쪽에 있으므로
             * DOM 생성 후 이벤트를 연결한다.
             */
            if(document.readyState==='loading'){
                document.addEventListener(
                    'DOMContentLoaded',
                    setupPublishPreviewModal
                );
            }else{
                setupPublishPreviewModal();
            }

            document.addEventListener('keydown',function(e){
                var backdrop=$('#plannerPublishBackdrop');
                if(e.key==='Escape' && backdrop && backdrop.classList.contains('is-open')){
                    closePublishPreviewModal();
                }
            });

            var save=$('#plannerSaveBtn');
            if(save) save.addEventListener('click',function(){
                if(!validatePlannerRequiredFields()) return;

                /*
                 * DOMContentLoaded 시점 차이와 관계없이
                 * 저장 버튼을 누르는 순간 한 번 더 이벤트 연결을 보장한다.
                 */
                setupPublishPreviewModal();
                openPublishPreviewModal();
            });
            ['#tripTitle','#plannerCountry','#plannerRegion','#plannerTravelerCount'].forEach(function(sel){var el=$(sel);if(el)el.addEventListener('input',markDirty)});
            var travelerCountInput=$('#plannerTravelerCount');
            if(travelerCountInput){
                travelerCountInput.addEventListener('change',function(){
                    var n=parseInt(travelerCountInput.value,10);
                    if(!Number.isFinite(n) || n<1) n=1;
                    if(n>99) n=99;
                    travelerCountInput.value=String(n);
                    syncBudget();
                    markDirty();
                });
            }

            function syncCountryLock(){
                var center=$('#plannerCenterPanel');
                if(!center) return;

                /*
                 * 수정 페이지는 이미 저장된 일정의 DTO를 불러오는 화면이다.
                 * 신규 작성용 '국가 선택 전 중앙 잠금'을 적용하지 않는다.
                 */
                if(EDIT_ITINERARY || plannerItineraryId){
                    center.classList.remove('is-country-locked');
                    center.setAttribute('aria-disabled','false');
                    return;
                }

                /*
                 * 일정 가져오기 드래그 중에는 국가가 비어 있어도
                 * DAY 영역이 dragover/drop 이벤트를 받을 수 있게 한다.
                 */
                if(center.dataset.importDragActive==='1'){
                    center.classList.remove('is-country-locked');
                    center.setAttribute('aria-disabled','false');
                    return;
                }

                var locked=!findPlannerCountry(
                    $('#plannerCountry')
                        ? $('#plannerCountry').value
                        : ''
                );

                center.classList.toggle(
                    'is-country-locked',
                    locked
                );

                center.setAttribute(
                    'aria-disabled',
                    locked ? 'true' : 'false'
                );
            }
            var countryInput=$('#plannerCountry');
            if(countryInput){
                countryInput.addEventListener('input',syncCountryLock);
                countryInput.addEventListener('change',syncCountryLock);
            }

            /*
             * 드래그를 중간에 취소한 경우에도
             * 원래 국가 잠금 상태로 복귀시킨다.
             */
            document.addEventListener('dragend',function(){
                finishImportDrag();
            });
            refreshCountryStatus();
            refreshRegionOptions(false);
            updateCountryClear();
            updateRegionClear();
            syncCountryLock();
            syncCountryEditLock();

            /*
             * 블록/DAY 삭제 경로가 여러 곳이라 DOM 변화를 기준으로
             * 국가 잠금 상태를 항상 다시 계산한다.
             */
            var plannerDaysRoot=$('#plannerDays');
            if(plannerDaysRoot && window.MutationObserver){
                new MutationObserver(function(){
                    syncCountryEditLock();
                }).observe(plannerDaysRoot,{
                    childList:true,
                    subtree:true
                });
            }

            if(typeof filterPlans==='function'){
                filterPlans();
            }

            function plannerMapQuery(){
                var region=$('#plannerRegion') ? $('#plannerRegion').value.trim() : '';
                var country=$('#plannerCountry') ? $('#plannerCountry').value.trim() : '';
                return [region,country].filter(Boolean).join(', ') || 'Seoul, Korea';
            }
            window.showPlannerMapFallback=function(force){
                var el=$('#plannerGoogleMap');
                if(!el || (el.dataset.fallback==='1' && !force)) return;
                el.dataset.fallback='1';
                var q=encodeURIComponent(plannerMapQuery());
                el.innerHTML='<iframe title="경로 지도" src="https://maps.google.com/maps?q='+q+'&z=11&output=embed" style="width:100%;height:100%;min-height:360px;border:0;display:block" loading="lazy" referrerpolicy="no-referrer-when-downgrade"></iframe>';
            };
            window.initPlannerMap=function(){
                var el=$('#plannerGoogleMap');
                if(!el||!window.google||!google.maps){ showPlannerMapFallback(); return; }
                try{
                    el.dataset.fallback='0';
                    el.innerHTML='';
                    map=new google.maps.Map(el,{center:{lat:37.5665,lng:126.9780},zoom:11,gestureHandling:'greedy',mapTypeControl:false,streetViewControl:false,fullscreenControl:false,styles:[{featureType:'poi',elementType:'labels',stylers:[{visibility:'off'}]},{featureType:'transit',elementType:'labels',stylers:[{visibility:'off'}]}]});

                    $$('.planner-block-card').forEach(function(card){
                        setupPlannerPlaceSearch(card);
                    });

                    refreshMap('all');

                    var initialCountry=$('#plannerCountry');
                    if(initialCountry && findPlannerCountry(initialCountry.value)){
                        centerMapOnPlannerCountry(initialCountry.value);
                    }
                }catch(e){ showPlannerMapFallback(); }
            };
            function plannerGoogleMapsDetailUrl(point){
                var placeId=point && point.googlePlaceId
                    ? String(point.googlePlaceId).trim()
                    : '';
                var query=point && point.name
                    ? String(point.name).trim()
                    : '';

                if(point && isFinite(Number(point.lat))
                        && isFinite(Number(point.lng))){
                    query=(query ? query+' ' : '')
                        +Number(point.lat)+','+Number(point.lng);
                }

                var url='https://www.google.com/maps/search/?api=1';
                if(query){
                    url+='&query='+encodeURIComponent(query);
                }
                if(placeId){
                    url+='&query_place_id='+encodeURIComponent(placeId);
                }
                return url;
            }

            function fetchPlannerPlaceDetails(point){
                var placeId=point && point.googlePlaceId
                    ? String(point.googlePlaceId).trim()
                    : '';

                if(!placeId){
                    return Promise.resolve(null);
                }

                if(plannerPlaceDetailsCache[placeId]){
                    return plannerPlaceDetailsCache[placeId];
                }

                plannerPlaceDetailsCache[placeId]=
                    getPlannerPlacesLibrary()
                    .then(function(placesLib){
                        if(!placesLib || !placesLib.Place){
                            return null;
                        }

                        var place=new placesLib.Place({id:placeId});
                        return place.fetchFields({
                            fields:[
                                'displayName',
                                'formattedAddress',
                                'rating',
                                'userRatingCount',
                                'photos',
                                'googleMapsURI'
                            ]
                        }).then(function(){
                            return place;
                        });
                    })
                    .catch(function(error){
                        delete plannerPlaceDetailsCache[placeId];
                        throw error;
                    });

                return plannerPlaceDetailsCache[placeId];
            }

            function plannerPlaceInfoHtml(point,details,infoId){
                var name=details && details.displayName
                    ? details.displayName
                    : point.name;
                var address=details && details.formattedAddress
                    ? details.formattedAddress
                    : point.address;
                var rating=details && typeof details.rating==='number'
                    ? details.rating
                    : null;
                var ratingCount=details
                    && typeof details.userRatingCount==='number'
                    ? details.userRatingCount
                    : null;
                var mapsUrl=details && details.googleMapsURI
                    ? details.googleMapsURI
                    : plannerGoogleMapsDetailUrl(point);

                var photoHtml='';
                if(details && details.photos && details.photos.length){
                    var photo=details.photos[0];
                    var photoUrl='';
                    try{
                        photoUrl=photo.getURI({
                            maxWidth:320,
                            maxHeight:180
                        });
                    }catch(e){}

                    if(photoUrl){
                        var attributionHtml='';
                        var attributions=photo.authorAttributions || [];
                        if(attributions.length){
                            attributionHtml='<div style="position:absolute;left:8px;bottom:6px;max-width:calc(100% - 16px);padding:2px 5px;border-radius:4px;background:rgba(17,24,39,.72);font-size:9px;line-height:1.3;color:#fff;white-space:nowrap;overflow:hidden;text-overflow:ellipsis">사진: ';
                            attributionHtml+=attributions.map(function(attr){
                                var attrName=attr && attr.displayName
                                    ? escapeHtml(attr.displayName)
                                    : 'Google Maps 사용자';
                                if(attr && attr.uri){
                                    return '<a href="'+escapeHtml(attr.uri)+'" target="_blank" rel="noopener noreferrer" style="color:#fff;text-decoration:underline">'+attrName+'</a>';
                                }
                                return attrName;
                            }).join(', ');
                            attributionHtml+='</div>';
                        }

                        photoHtml=
                            '<div style="position:relative;width:260px;height:130px;overflow:hidden;border-radius:9px 9px 0 0;background:#F3F4F6">'
                            +'<img src="'+escapeHtml(photoUrl)+'" alt="'+escapeHtml(name)+' 사진" style="width:100%;height:100%;display:block;object-fit:cover">'
                            +attributionHtml
                            +'</div>';
                    }
                }

                if(!photoHtml){
                    photoHtml=
                        '<div style="width:260px;height:78px;display:flex;align-items:center;justify-content:center;border-radius:9px 9px 0 0;background:#F3F4F6;color:#9CA3AF;font-size:11px">'
                        +(details===null && point.googlePlaceId
                            ? '장소 정보를 불러오는 중...'
                            : '등록된 사진이 없습니다.')
                        +'</div>';
                }

                var ratingHtml='';
                if(rating!=null){
                    ratingHtml=
                        '<div style="margin-top:8px;display:flex;align-items:center;gap:5px;font-size:12px;color:#374151">'
                        +'<span style="color:#F59E0B">★</span>'
                        +'<strong>'+escapeHtml(rating.toFixed(1))+'</strong>'
                        +(ratingCount!=null
                            ? '<span style="color:#6B7280">평가 '+escapeHtml(Number(ratingCount).toLocaleString())+'개</span>'
                            : '')
                        +'</div>';
                }else if(details){
                    ratingHtml=
                        '<div style="margin-top:8px;font-size:11px;color:#9CA3AF">평점 정보 없음</div>';
                }

                return '<div id="'+escapeHtml(infoId)+'" style="width:260px;font-family:Arial,\'Noto Sans KR\',sans-serif">'
                    +photoHtml
                    +'<div style="padding:11px 12px 12px">'
                    +'<div style="font-size:14px;line-height:1.35;font-weight:700;color:#111827">'+escapeHtml(name || '장소')+'</div>'
                    +(address
                        ? '<div style="margin-top:5px;font-size:11px;line-height:1.45;color:#6B7280">'+escapeHtml(address)+'</div>'
                        : '')
                    +ratingHtml
                    +'<a href="'+escapeHtml(mapsUrl)+'" target="_blank" rel="noopener noreferrer" style="display:inline-flex;margin-top:10px;align-items:center;font-size:12px;font-weight:700;color:#4F46E5;text-decoration:none">구글맵에서 자세히 보기 ↗</a>'
                    +'</div>'
                    +'</div>';
            }

            function plannerMapPoints(){
                var points=[];

                $$('.planner-day').forEach(function(dayEl,dayIndex){
                    var dayNumber=String(dayIndex+1);

                    $$('.planner-block-card',dayEl).forEach(
                        function(card,blockIndex){

                            var input=$('.planner-place-search',card);
                            var place=plannerSelectedPlacePoint(input);

                            if(!place){
                                return;
                            }

                            var title=$('.planner-item-title',card);
                            var cfg=TYPE_CONFIG[card.dataset.itemType]
                                || TYPE_CONFIG.sightseeing;

                            points.push({
                                day:dayNumber,
                                order:blockIndex+1,
                                sequence:blockIndex+1,
                                name:title && title.value.trim()
                                    ? title.value.trim()
                                    : place.name,
                                address:place.address,
                                googlePlaceId:place.googlePlaceId || '',
                                lat:place.lat,
                                lng:place.lng,
                                color:cfg.color
                            });
                        }
                    );
                });

                return points;
            }

            window.refreshMap=function(day){
                if(day==null || day===''){
                    day=plannerActiveMapDay;
                }else{
                    plannerActiveMapDay=String(day);
                }

                if(!map||!window.google||!google.maps){
                    showPlannerMapFallback();
                    return;
                }

                mapMarkers.forEach(function(marker){
                    marker.setMap(null);
                });
                mapMarkers=[];

                mapPolylines.forEach(function(line){
                    line.setMap(null);
                });
                mapPolylines=[];

                var allPoints=plannerMapPoints();

                var visiblePoints=allPoints.filter(function(point){
                    return day==='all'
                        || point.day===String(day);
                });

                var bounds=new google.maps.LatLngBounds();
                var has=false;

                visiblePoints.forEach(function(point,index){
                    var marker=new google.maps.Marker({
                        position:{
                            lat:point.lat,
                            lng:point.lng
                        },
                        map:map,
                        title:point.name,
                        label:{
                            text:String(point.sequence),
                            color:'#fff',
                            fontWeight:'bold'
                        },
                        icon:{
                            path:google.maps.SymbolPath.CIRCLE,
                            scale:14,
                            fillColor:point.color,
                            fillOpacity:1,
                            strokeColor:'#fff',
                            strokeWeight:2
                        }
                    });

                    var infoId='planner-map-info-'+(++plannerMapInfoSeq);
                    var infoWindow=new google.maps.InfoWindow({
                        content:plannerPlaceInfoHtml(point,null,infoId),
                        disableAutoPan:true
                    });
                    var infoCloseTimer=null;
                    var markerHovered=false;
                    var infoHovered=false;

                    function cancelInfoClose(){
                        if(infoCloseTimer){
                            clearTimeout(infoCloseTimer);
                            infoCloseTimer=null;
                        }
                    }

                    function scheduleInfoClose(){
                        cancelInfoClose();
                        infoCloseTimer=setTimeout(function(){
                            if(!markerHovered && !infoHovered){
                                infoWindow.close();
                            }
                        },220);
                    }

                    /*
                     * 정보창 안의 '구글맵에서 자세히 보기' 링크까지
                     * 마우스를 옮길 수 있도록 정보창 자체도 hover 영역으로 취급한다.
                     */
                    infoWindow.addListener('domready',function(){
                        var infoRoot=document.getElementById(infoId);
                        if(!infoRoot || infoRoot.dataset.hoverBound==='1'){
                            return;
                        }

                        infoRoot.dataset.hoverBound='1';
                        infoRoot.addEventListener('mouseenter',function(){
                            infoHovered=true;
                            cancelInfoClose();
                        });
                        infoRoot.addEventListener('mouseleave',function(){
                            infoHovered=false;
                            scheduleInfoClose();
                        });
                    });

                    infoWindow.addListener('closeclick',function(){
                        markerHovered=false;
                        infoHovered=false;
                        cancelInfoClose();
                    });

                    marker.addListener('mouseover',function(){
                        markerHovered=true;
                        cancelInfoClose();
                        infoWindow.setContent(
                            plannerPlaceInfoHtml(point,null,infoId)
                        );
                        infoWindow.open(map,marker);

                        fetchPlannerPlaceDetails(point)
                            .then(function(details){
                                if(markerHovered || infoHovered){
                                    infoWindow.setContent(
                                        plannerPlaceInfoHtml(
                                            point,
                                            details,
                                            infoId
                                        )
                                    );
                                }
                            })
                            .catch(function(error){
                                console.warn(
                                    '지도 핀 상세정보 조회 실패:',
                                    error
                                );
                                if(markerHovered || infoHovered){
                                    infoWindow.setContent(
                                        plannerPlaceInfoHtml(
                                            point,
                                            false,
                                            infoId
                                        )
                                    );
                                }
                            });
                    });

                    marker.addListener('mouseout',function(){
                        markerHovered=false;
                        scheduleInfoClose();
                    });

                    mapMarkers.push(marker);
                    bounds.extend(marker.getPosition());
                    has=true;
                });

                /*
                 * 실제 Routes API를 호출하지 않고,
                 * 같은 DAY의 장소들을 블록 순서대로 직선 연결한다.
                 */
                var dayGroups={};

                visiblePoints.forEach(function(point){
                    if(!dayGroups[point.day]){
                        dayGroups[point.day]=[];
                    }

                    dayGroups[point.day].push(point);
                });

                Object.keys(dayGroups).forEach(function(dayKey){
                    var group=dayGroups[dayKey]
                        .slice()
                        .sort(function(a,b){
                            return a.order-b.order;
                        });

                    if(group.length<2){
                        return;
                    }

                    var line=new google.maps.Polyline({
                        path:group.map(function(point){
                            return {
                                lat:point.lat,
                                lng:point.lng
                            };
                        }),
                        geodesic:true,
                        strokeColor:getPlannerDayLineColor(dayKey),
                        strokeOpacity:.82,
                        strokeWeight:4,
                        map:map
                    });

                    mapPolylines.push(line);
                });

                /*
                 * DAY 간 경계는 연결하지 않는다.
                 * 각 DAY의 동선은 해당 DAY 내부 장소끼리만 표시한다.
                 */

                renderPlannerMapAllLegend();

                if(has){
                    if(visiblePoints.length===1){
                        map.setCenter({
                            lat:visiblePoints[0].lat,
                            lng:visiblePoints[0].lng
                        });
                        map.setZoom(15);
                    }else{
                        map.fitBounds(bounds);
                    }
                }
            };

            ['#plannerCountry','#plannerRegion'].forEach(function(sel){
                var el=$(sel);
                if(el) el.addEventListener('change',function(){ if($('#plannerGoogleMap') && $('#plannerGoogleMap').dataset.fallback==='1') showPlannerMapFallback(true); });
            });
            function setupRequiredFieldsModal(){
                var plannerRequiredClose=$('#plannerRequiredClose');
                var plannerRequiredBackdrop=$('#plannerRequiredBackdrop');

                if(plannerRequiredClose && !plannerRequiredClose.dataset.bound){
                    plannerRequiredClose.dataset.bound='1';
                    plannerRequiredClose.addEventListener('click',function(e){
                        e.preventDefault();
                        closeRequiredFieldsModal();
                    });
                }

                if(plannerRequiredBackdrop && !plannerRequiredBackdrop.dataset.bound){
                    plannerRequiredBackdrop.dataset.bound='1';
                    plannerRequiredBackdrop.addEventListener('click',function(e){
                        if(e.target===plannerRequiredBackdrop){
                            closeRequiredFieldsModal();
                        }
                    });
                }
            }

            if(document.readyState==='loading'){
                document.addEventListener('DOMContentLoaded',setupRequiredFieldsModal);
            }else{
                setupRequiredFieldsModal();
            }

            document.addEventListener('keydown',function(e){
                var plannerRequiredBackdrop=$('#plannerRequiredBackdrop');

                if(e.key==='Escape'
                        && plannerRequiredBackdrop
                        && plannerRequiredBackdrop.classList.contains('is-open')){
                    closeRequiredFieldsModal();
                }
            });

            document.addEventListener('click',function(event){
                $$('.planner-place-results.is-open').forEach(function(results){
                    var ownerId=
                        results.dataset.ownerInputId;

                    var input=
                        ownerId
                            ? document.querySelector(
                                '.planner-place-search[data-place-search-id="'
                                +ownerId
                                +'"]'
                            )
                            : null;

                    var clickedInput=
                        input && input.contains(event.target);

                    var clickedResults=
                        results.contains(event.target);

                    if(!clickedInput && !clickedResults){
                        results.classList.remove('is-open');
                    }
                });
            });


            function initializePlanEditor(){
                if(!EDIT_ITINERARY || !plannerItineraryId){
                    return;
                }

                var centerPanel=$('#plannerCenterPanel');
                if(centerPanel){
                    centerPanel.classList.remove('is-country-locked');
                    centerPanel.setAttribute('aria-disabled','false');
                }

                var itinerary=EDIT_ITINERARY;
                var tripTitle=$('#tripTitle');
                var country=$('#plannerCountry');
                var region=$('#plannerRegion');
                var traveler=$('#plannerTravelerCount');

                if(tripTitle) tripTitle.value=itinerary.title || '';
                if(country) country.value=itinerary.country || '';

                refreshCountryStatus();
                refreshRegionOptions(false);

                if(region){
                    region.value=itinerary.city || '';
                }
                if(traveler){
                    traveler.value=String(itinerary.travelerCount || 1);
                }
                if(startDate){
                    startDate.value=itinerary.startDate || '';
                }
                if(endDate){
                    endDate.value=itinerary.endDate || '';
                }

                setPlannerVisibility(itinerary.visibility || 'PUBLIC',false);
                updateCountryClear();
                updateRegionClear();
                syncDates();

                var existingDays=$$('.planner-day');
                var firstDay=existingDays[0];
                existingDays.slice(1).forEach(function(day){ day.remove(); });

                if(firstDay){
                    var firstBody=$('.planner-day-body',firstDay);
                    if(firstBody){
                        $$('.planner-block-card,.planner-block-summary,.planner-empty-day-hint',firstBody)
                            .forEach(function(node){ node.remove(); });
                    }
                }

                var days=Array.isArray(itinerary.days)
                    ? itinerary.days.slice().sort(function(a,b){
                        return Number(a.dayOrder||0)-Number(b.dayOrder||0);
                    })
                    : [];

                if(!days.length){
                    days=[{dayOrder:1,title:'Day 1',blocks:[]}];
                }

                days.forEach(function(dayDto,index){
                    var day;

                    if(index===0){
                        day=firstDay;
                    }else{
                        var beforeCount=$$('.planner-day').length;
                        $('#plannerAddDay')?.click();
                        var dayList=$$('.planner-day');
                        day=dayList[beforeCount] || dayList[dayList.length-1];
                    }

                    if(!day){
                        return;
                    }

                    day.dataset.dayNumber=String(index+1);
                    day.dataset.dayOrder=String(index+1);

                    var dayTitle=$('.planner-day-title',day);
                    if(dayTitle){
                        dayTitle.textContent=dayDto.title || ('Day '+(index+1));
                    }

                    var body=$('.planner-day-body',day);
                    if(body){
                        $$('.planner-block-card,.planner-block-summary,.planner-empty-day-hint',body)
                            .forEach(function(node){ node.remove(); });
                    }

                    var blocks=Array.isArray(dayDto.blocks)
                        ? dayDto.blocks.slice().sort(function(a,b){
                            return Number(a.blockOrder||0)-Number(b.blockOrder||0);
                        })
                        : [];

                    blocks.forEach(function(block){
                        var card=addBlockToDay(day,{
                            sourceBlockId:block.sourceBlockId || null,
                            type:dbBlockTypeToPlanner(block.blockType),
                            title:block.title || '',
                            startTime:shortTime(block.startTime),
                            endTime:shortTime(block.endTime),
                            cost:block.cost==null ? '' : block.cost,
                            costType:block.costType || 'PER_PERSON',
                            googlePlaceId:block.googlePlaceId || '',
                            placeName:block.placeName || '',
                            placeAddress:block.placeAddress || '',
                            placeLat:block.placeLat,
                            placeLng:block.placeLng,
                            note:block.memo || ''
                        });

                        if(card){
                            applyPlannerExistingImages(card,block.images || []);
                        }
                    });

                    ensureDayControls(day);
                });

                plannerPublishState.summary=itinerary.summary || '';
                plannerPublishState.thumbnailUrl=itinerary.thumbnailImg || '';
                plannerPublishState.imageKey=(itinerary.thumbnailImg
                        && String(itinerary.thumbnailImg).indexOf('gplace:')===0)
                    ? 'placeId:'+String(itinerary.thumbnailImg).substring(7)
                    : '';

                renumberDays();
                syncBudget();
                refreshCountryStatus();
                updateCountryClear();
                updateRegionClear();

                /*
                 * 수정 화면은 페이지 최초 로드 시 빈 폼 상태에서 한 번 잠긴 뒤
                 * EDIT_ITINERARY의 국가값이 채워진다.
                 * 따라서 국가값 주입 후 중앙 잠금 상태를 반드시 다시 계산한다.
                 */
                syncCountryLock();
                syncCountryEditLock();

                refreshMap('all');
                dirty=false;
            }

            initializePlanEditor();
            restoreDraft().then(function(restored){
                if(restored && typeof refreshMap==='function'){
                    refreshMap('all');
                }
            });

            window.setTimeout(function(){ if(!map) showPlannerMapFallback(); },1800);
        })();
    </script>
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
                                <span id="plannerPublishPhotoHint" class="text-[10px] text-gray-400">업로드 사진 우선 · 없으면 일정 장소 사진</span>
                            </div>

                            <div id="plannerPublishPhotoList"
                                class="planner-publish-photo-list"></div>

                            <p id="plannerPublishPhotoEmpty"
                                class="hidden py-8 px-3 text-center text-xs text-gray-400 rounded-xl bg-gray-50">
                                대표 이미지 후보를 확인해 주세요.
                            </p>

                            <p id="plannerPublishPhotoError" class="planner-publish-error">
                                공개 일정은 대표 이미지를 선택해야 저장할 수 있습니다.
                            </p>

                        </div>

                        <div id="plannerPublishSummarySection" style="display:block; visibility:visible;">
                            <div class="flex items-center justify-between mb-2">
                                <label for="plannerPublishSummary"
                                    class="text-xs font-bold text-gray-700">일정 소개 <span class="font-normal text-gray-400">(선택)</span></label>

                                <span id="plannerPublishSummaryCount"
                                    class="text-[10px] text-gray-400">0자</span>
                            </div>

                            <textarea id="plannerPublishSummary"
                                maxlength="500"
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
