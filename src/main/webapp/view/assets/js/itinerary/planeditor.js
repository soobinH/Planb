(function () {
            var DRAFT_KEY = 'tripily_planner_draft_edit_v4';
            var PLANNER_BOOTSTRAP=window.PLANNER_BOOTSTRAP||{};
            var PLANNER_CONTEXT_PATH=PLANNER_BOOTSTRAP.contextPath||'';
            var restoringDraft=false;
            var lastPlannerActivityAt=Date.now();
            var lastKeepAliveAt=Date.now();
            var keepAliveInFlight=false;
            var sessionExpiredHandling=false;
            var TYPE_CONFIG = {
                sightseeing:{label:'관광',color:'#EC4899',bg:'#FDF2F8'},
                meal:{label:'식사',color:'#F97316',bg:'#FFF7ED'},
                accommodation:{label:'숙소',color:'#10B981',bg:'#ECFDF5'},
                transport:{label:'교통',color:'#3B82F6',bg:'#EFF6FF'}
            };
            var map, mapMarkers=[], mapPolylines=[], mapSearchMarkers=[];
            var plannerPlaceDetailsCache={};
            var plannerMapInfoSeq=0;
            var plannerActiveMapDay='all';
            // DAY별 색상은 해당 DAY의 일정 핀과 이동 동선에 공통으로 사용한다.
            var plannerDayLinePalette=['#7C3AED','#2563EB','#F97316','#10B981','#EC4899','#06B6D4','#EF4444','#6366F1','#14B8A6','#D97706','#8B5CF6','#0EA5E9'];
            function getPlannerDayLineColor(dayNumber){
                var dayIndex=parseInt(dayNumber,10);
                if(!dayIndex||dayIndex<1){
                    dayIndex=1;
                }
                return plannerDayLinePalette[(dayIndex-1)%plannerDayLinePalette.length];
            }
            var plannerPlacesLibraryPromise=null;
            // 첫 클릭 시 ISO 3166-2의 1차 행정구역만 표시한다 (동일 JSON을 서버가 검증).
            var plannerAdmin1Cache=Object.create(null);
            var plannerRegionSearchSeq=0;
            var dirty=false;

            function $(sel, root){ return (root||document).querySelector(sel); }
            function $$(sel, root){ return Array.prototype.slice.call((root||document).querySelectorAll(sel)); }
            var plannerBlockTemplateEl = $('#plannerBlockTemplate');
            var blockTemplate = plannerBlockTemplateEl
                && plannerBlockTemplateEl.content
                && plannerBlockTemplateEl.content.firstElementChild
                    ? plannerBlockTemplateEl.content.firstElementChild.cloneNode(true)
                    : ($('.planner-block-card') ? $('.planner-block-card').cloneNode(true) : null);
            /*
             * ModifyPlanServlet에서 전달한 카트 조회 결과.
             *
             * List<ItineraryDto>
             *  └ days
             *      └ blocks
             */
            var IMPORT_ITINERARIES=Array.isArray(PLANNER_BOOTSTRAP.importItineraries)
                ? PLANNER_BOOTSTRAP.importItineraries
                : [];

            var EDIT_ITINERARY=PLANNER_BOOTSTRAP.editItinerary || null;

            DRAFT_KEY += '_' + (EDIT_ITINERARY && EDIT_ITINERARY.itineraryId
                ? String(EDIT_ITINERARY.itineraryId)
                : 'unknown');

            function dbBlockTypeToPlanner(type){
                var map={
                    ATTRACTION:'sightseeing',
                    MEAL:'meal',
                    LODGING:'accommodation',
                    TRANSPORT:'transport',
                    // Legacy activity blocks are shown as attractions.
                    ACTIVITY:'sightseeing'
                };

                return map[type] || 'sightseeing';
            }

            function shortTime(value){
                if(!value) return '';
                value=String(value);
                return value.length>=5 ? value.substring(0,5) : value;
            }

            /*
             * 브라우저 기본 time picker 대신 프로젝트 공통 시간 선택창을 사용한다.
             * - 오전/오후는 항상 둘 중 하나가 선택된 상태를 유지한다.
             * - 시간(1~12), 분(00~59)은 실제 목록만 렌더링하므로 무한 반복되지 않는다.
             * - 시간/분을 더블클릭하면 해당 값으로 확정하고 선택창을 닫는다.
             */
            var plannerTimePickerState={
                input:null,
                period:'AM',
                hour:12,
                minute:0
            };
            var plannerTimePickerEl=null;

            function plannerPad2(value){
                return String(value).padStart(2,'0');
            }

            function plannerParseTimeValue(value){
                var match=String(value||'').match(/^(\d{1,2}):(\d{2})/);
                if(!match) return null;
                var h24=parseInt(match[1],10);
                var minute=parseInt(match[2],10);
                if(!isFinite(h24)||h24<0||h24>23||!isFinite(minute)||minute<0||minute>59) return null;
                return {
                    period:h24>=12 ? 'PM' : 'AM',
                    hour:(h24%12)||12,
                    minute:minute
                };
            }

            function plannerTimeDraftToValue(){
                var h12=parseInt(plannerTimePickerState.hour,10)||12;
                var h24=h12%12;
                if(plannerTimePickerState.period==='PM') h24+=12;
                return plannerPad2(h24)+':'+plannerPad2(plannerTimePickerState.minute);
            }

            function ensurePlannerTimePicker(){
                if(plannerTimePickerEl) return plannerTimePickerEl;

                var picker=document.createElement('div');
                picker.className='planner-time-picker';
                picker.setAttribute('role','dialog');
                picker.setAttribute('aria-label','시간 선택');
                picker.innerHTML=''
                    +'<div class="planner-time-picker-head"><span>오전/오후</span><span>시</span><span>분</span></div>'
                    +'<div class="planner-time-picker-columns">'
                    +'<div class="planner-time-picker-column" data-time-column="period"></div>'
                    +'<div class="planner-time-picker-column" data-time-column="hour"></div>'
                    +'<div class="planner-time-picker-column" data-time-column="minute"></div>'
                    +'</div>';

                var periodCol=picker.querySelector('[data-time-column="period"]');
                ['AM','PM'].forEach(function(period){
                    var btn=document.createElement('button');
                    btn.type='button';
                    btn.className='planner-time-option';
                    btn.dataset.timePart='period';
                    btn.dataset.timeValue=period;
                    btn.textContent=period==='AM' ? '오전' : '오후';
                    periodCol.appendChild(btn);
                });

                var hourCol=picker.querySelector('[data-time-column="hour"]');
                for(var hour=1;hour<=12;hour++){
                    var hourBtn=document.createElement('button');
                    hourBtn.type='button';
                    hourBtn.className='planner-time-option';
                    hourBtn.dataset.timePart='hour';
                    hourBtn.dataset.timeValue=String(hour);
                    hourBtn.textContent=String(hour);
                    hourCol.appendChild(hourBtn);
                }

                var minuteCol=picker.querySelector('[data-time-column="minute"]');
                for(var minute=0;minute<=59;minute++){
                    var minuteBtn=document.createElement('button');
                    minuteBtn.type='button';
                    minuteBtn.className='planner-time-option';
                    minuteBtn.dataset.timePart='minute';
                    minuteBtn.dataset.timeValue=String(minute);
                    minuteBtn.textContent=plannerPad2(minute);
                    minuteCol.appendChild(minuteBtn);
                }

                picker.addEventListener('click',function(e){
                    // 빈 공간을 눌러도 현재 선택값(특히 오전/오후)을 해제하지 않는다.
                    e.stopPropagation();
                    var option=e.target.closest('.planner-time-option');
                    if(!option) return;
                    plannerSelectTimeOption(option);
                });

                picker.addEventListener('dblclick',function(e){
                    e.stopPropagation();
                    var option=e.target.closest('.planner-time-option');
                    if(!option) return;
                    var part=option.dataset.timePart;
                    if(part!=='hour' && part!=='minute') return;
                    plannerSelectTimeOption(option);
                    closePlannerTimePicker();
                });

                document.body.appendChild(picker);
                plannerTimePickerEl=picker;
                return picker;
            }

            function plannerSelectTimeOption(option){
                var part=option.dataset.timePart;
                var raw=option.dataset.timeValue;
                if(part==='period'){
                    plannerTimePickerState.period=raw==='PM' ? 'PM' : 'AM';
                }else if(part==='hour'){
                    var hour=parseInt(raw,10);
                    if(hour>=1&&hour<=12) plannerTimePickerState.hour=hour;
                }else if(part==='minute'){
                    var minute=parseInt(raw,10);
                    if(minute>=0&&minute<=59) plannerTimePickerState.minute=minute;
                }else{
                    return;
                }

                renderPlannerTimePickerSelection();
                if(plannerTimePickerState.input){
                    var nextValue=plannerTimeDraftToValue();
                    if(plannerTimePickerState.input.value!==nextValue){
                        plannerTimePickerState.input.value=nextValue;
                        plannerTimePickerState.input.dispatchEvent(new Event('input',{bubbles:true}));
                        plannerTimePickerState.input.dispatchEvent(new Event('change',{bubbles:true}));
                    }
                }
            }

            function renderPlannerTimePickerSelection(){
                var picker=ensurePlannerTimePicker();
                picker.querySelectorAll('.planner-time-option').forEach(function(option){
                    var part=option.dataset.timePart;
                    var selected=false;
                    if(part==='period') selected=option.dataset.timeValue===plannerTimePickerState.period;
                    if(part==='hour') selected=Number(option.dataset.timeValue)===Number(plannerTimePickerState.hour);
                    if(part==='minute') selected=Number(option.dataset.timeValue)===Number(plannerTimePickerState.minute);
                    option.classList.toggle('is-selected',selected);
                });
            }

            function positionPlannerTimePicker(){
                var picker=ensurePlannerTimePicker();
                var input=plannerTimePickerState.input;
                if(!input||!picker.classList.contains('is-open')) return;
                var box=input.closest('.planner-time-box')||input;
                var rect=box.getBoundingClientRect();
                var pickerWidth=236;
                var left=Math.min(rect.left,window.innerWidth-pickerWidth-8);
                left=Math.max(8,left);
                var estimatedHeight=226;
                var top=rect.bottom+6;
                if(top+estimatedHeight>window.innerHeight-8){
                    top=Math.max(8,rect.top-estimatedHeight-6);
                }
                picker.style.left=Math.round(left)+'px';
                picker.style.top=Math.round(top)+'px';
            }

            function openPlannerTimePicker(input){
                if(!input) return;
                var picker=ensurePlannerTimePicker();
                if(plannerTimePickerState.input===input && picker.classList.contains('is-open')){
                    closePlannerTimePicker();
                    return;
                }

                var parsed=plannerParseTimeValue(input.value);
                if(!parsed){
                    var now=new Date();
                    parsed={
                        period:now.getHours()>=12 ? 'PM' : 'AM',
                        hour:(now.getHours()%12)||12,
                        minute:now.getMinutes()
                    };
                }

                plannerTimePickerState.input=input;
                plannerTimePickerState.period=parsed.period;
                plannerTimePickerState.hour=parsed.hour;
                plannerTimePickerState.minute=parsed.minute;
                renderPlannerTimePickerSelection();
                picker.classList.add('is-open');
                positionPlannerTimePicker();

                window.requestAnimationFrame(function(){
                    ['hour','minute'].forEach(function(part){
                        var selected=picker.querySelector('[data-time-part="'+part+'"].is-selected');
                        if(selected) selected.scrollIntoView({block:'center'});
                    });
                });
            }

            function closePlannerTimePicker(){
                if(plannerTimePickerEl) plannerTimePickerEl.classList.remove('is-open');
                plannerTimePickerState.input=null;
            }

            document.addEventListener('click',function(e){
                var trigger=e.target.closest('[data-time-trigger]');
                if(trigger){
                    e.preventDefault();
                    e.stopPropagation();
                    var box=trigger.closest('.planner-time-box');
                    openPlannerTimePicker(box ? box.querySelector('input[type="time"]') : null);
                    return;
                }

                var timeInput=e.target.closest('.planner-time-box input[type="time"]');
                if(timeInput){
                    e.preventDefault();
                    e.stopPropagation();
                    openPlannerTimePicker(timeInput);
                    return;
                }

                if(plannerTimePickerEl && !e.target.closest('.planner-time-picker')){
                    closePlannerTimePicker();
                }
            },true);

            document.addEventListener('keydown',function(e){
                if(e.key==='Escape' && plannerTimePickerEl && plannerTimePickerEl.classList.contains('is-open')){
                    closePlannerTimePicker();
                }
            });

            window.addEventListener('resize',positionPlannerTimePicker);

            function calculateTripDays(startDate,endDate,fallback){
                startDate=normalizePlannerDateValue(startDate);
                endDate=normalizePlannerDateValue(endDate);
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
                    type:TYPE_CONFIG[item.type] ? item.type : 'sightseeing',
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
                updatePlannerScheduleStats();
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
                help.textContent=mode==='block' ? '기존 DAY 안 또는 DAY 사이에 놓으면 새 DAY가 생성됩니다' : '원하는 DAY 사이에 놓으세요';
                root.insertBefore(help,root.firstChild);

                if(mode==='day'){
                    /* 이동 중인 DAY만 원래 자리에서 빠진 것으로 계산한다. */
                    var days=$$('.planner-day').filter(function(day){
                        return !(plannerStructureDrag.kind==='internal-day' && day===plannerStructureDrag.element);
                    });
                    var addDayBtn=$('#plannerAddDay');
                    for(var i=0;i<=days.length;i++){
                        var before=i<days.length ? days[i] : addDayBtn;
                        root.insertBefore(makePlannerDropSlot({mode:'day',beforeDay:before||null,index:i}),before||null);
                    }
                    return;
                }

                // 블록을 DAY 내부뿐 아니라 DAY 사이 / 빈 일정에도 놓을 수 있다.
                // 이 슬롯에 놓으면 DAY를 새로 만들어 블록을 첫 항목으로 배치한다.
                var visibleDays=$$('.planner-day');
                var newDayBefore=$('#plannerAddDay');
                for(var gapIndex=0;gapIndex<=visibleDays.length;gapIndex++){
                    var nextDay=gapIndex<visibleDays.length ? visibleDays[gapIndex] : newDayBefore;
                    root.insertBefore(makePlannerDropSlot({
                        mode:'new-day-for-block',
                        beforeDay:nextDay||null,
                        index:gapIndex
                    }),nextDay||null);
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
                stopPlannerDragAutoScroll();
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

                /*
                 * Chrome 계열은 native HTML5 drag 중 wheel 이벤트 자체를 전달하지 않는 경우가 있다.
                 * 따라서 현재 포인터가 DAY 목록 상/하단에 가까워지면 dragover 좌표를 기준으로
                 * #plannerDays를 자동 스크롤한다. 휠 이벤트가 전달되는 브라우저에서는 아래 wheel
                 * fallback도 그대로 동작한다.
                 */
                updatePlannerDragAutoScroll(e.clientX,e.clientY);

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


            var plannerDragAutoScrollFrame=0;
            var plannerDragAutoScrollSpeed=0;
            var plannerDragPointerX=0;
            var plannerDragPointerY=0;

            function stopPlannerDragAutoScroll(){
                plannerDragAutoScrollSpeed=0;
                if(plannerDragAutoScrollFrame){
                    cancelAnimationFrame(plannerDragAutoScrollFrame);
                    plannerDragAutoScrollFrame=0;
                }
            }

            function refreshPlannerDragTargetFromPoint(){
                if(!plannerStructureDrag) return;
                var hit=document.elementFromPoint(plannerDragPointerX,plannerDragPointerY);
                if(!hit || !hit.closest) return;

                var slot=hit.closest('.planner-drop-slot');
                if(slot && slot.closest('#plannerDays')){
                    activatePlannerDropSlot(slot);
                }else{
                    activatePlannerDropSlot(null);
                }

                if(plannerDragModeFor(plannerStructureDrag)==='block'){
                    var day=hit.closest('.planner-day');
                    if(day && !day.closest('#plannerDays')) day=null;
                    setPlannerBlockDragHoverDay(day);
                }
            }

            function runPlannerDragAutoScroll(){
                plannerDragAutoScrollFrame=0;
                if(!plannerStructureDrag || !plannerDragAutoScrollSpeed) return;

                var root=$('#plannerDays');
                if(!root) return;

                var before=root.scrollTop;
                root.scrollTop+=plannerDragAutoScrollSpeed;

                /*
                 * 포인터를 움직이지 않은 상태에서도 스크롤된 새 DAY/슬롯을
                 * 즉시 드롭 대상으로 다시 계산한다.
                 */
                if(root.scrollTop!==before){
                    refreshPlannerDragTargetFromPoint();
                }

                if(plannerStructureDrag && plannerDragAutoScrollSpeed){
                    plannerDragAutoScrollFrame=requestAnimationFrame(runPlannerDragAutoScroll);
                }
            }

            function updatePlannerDragAutoScroll(clientX,clientY){
                if(!plannerStructureDrag){
                    stopPlannerDragAutoScroll();
                    return;
                }

                var root=$('#plannerDays');
                if(!root){
                    stopPlannerDragAutoScroll();
                    return;
                }

                plannerDragPointerX=clientX||0;
                plannerDragPointerY=clientY||0;

                var rect=root.getBoundingClientRect();
                var insideX=plannerDragPointerX>=rect.left && plannerDragPointerX<=rect.right;
                var insideY=plannerDragPointerY>=rect.top-18 && plannerDragPointerY<=rect.bottom+18;
                if(!insideX || !insideY){
                    stopPlannerDragAutoScroll();
                    return;
                }

                var edge=Math.min(120,Math.max(72,rect.height*0.18));
                var topEdge=rect.top+edge;
                var bottomEdge=rect.bottom-edge;
                var maxSpeed=24;
                var speed=0;

                if(plannerDragPointerY<topEdge){
                    var topRatio=Math.min(1,Math.max(0,(topEdge-plannerDragPointerY)/edge));
                    speed=-Math.max(4,Math.round(maxSpeed*topRatio));
                }else if(plannerDragPointerY>bottomEdge){
                    var bottomRatio=Math.min(1,Math.max(0,(plannerDragPointerY-bottomEdge)/edge));
                    speed=Math.max(4,Math.round(maxSpeed*bottomRatio));
                }

                plannerDragAutoScrollSpeed=speed;
                if(!speed){
                    stopPlannerDragAutoScroll();
                    return;
                }

                if(!plannerDragAutoScrollFrame){
                    plannerDragAutoScrollFrame=requestAnimationFrame(runPlannerDragAutoScroll);
                }
            }

            /*
             * native drag 중에도 wheel 이벤트를 전달하는 브라우저에서는 휠을 직접 반영한다.
             * Chrome처럼 wheel 자체를 막는 경우에는 위의 dragover 기반 가장자리 자동스크롤이
             * 대신 작동하므로 긴 DAY 목록에서도 아래/위 DAY까지 이동할 수 있다.
             */
            document.addEventListener('wheel',function(e){
                if(!plannerStructureDrag) return;

                var root=$('#plannerDays');
                if(!root) return;

                var rect=root.getBoundingClientRect();
                var inside=(
                    e.clientX>=rect.left && e.clientX<=rect.right &&
                    e.clientY>=rect.top && e.clientY<=rect.bottom
                );
                if(!inside) return;

                var deltaY=e.deltaY||0;
                if(!deltaY) return;

                if(e.deltaMode===1){
                    deltaY*=32;
                }else if(e.deltaMode===2){
                    deltaY*=Math.max(1,root.clientHeight);
                }

                stopPlannerDragAutoScroll();
                var before=root.scrollTop;
                root.scrollTop+=deltaY;
                plannerDragPointerX=e.clientX;
                plannerDragPointerY=e.clientY;
                if(root.scrollTop!==before){
                    refreshPlannerDragTargetFromPoint();
                    e.preventDefault();
                    e.stopPropagation();
                }
            },{capture:true,passive:false});

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

                        insertImportedDayAt(before,state.payload.day||{});

                        toast('DAY 일정을 가져왔습니다.');
                        changed=true;
                    }else if(state.kind==='plan'){
                        applyImportHeaderDefaults(state.payload);
                        var schedules=(state.payload.plan && state.payload.plan.daySchedules)||[];

                        schedules.forEach(function(dayData){ insertImportedDayAt(before,dayData); });
                        toast('일정 '+schedules.length+'개 DAY를 가져왔습니다.');
                        changed=schedules.length>0;
                    }
                }else if(meta.mode==='new-day-for-block'){
                    var insertionBefore=meta.beforeDay;
                    var starterDay=getPlannerEmptyStarterDay();
                    if(starterDay){
                        if(insertionBefore===starterDay) insertionBefore=$('#plannerAddDay');
                        starterDay.remove();
                    }
                    var createdDay=insertImportedDayAt(insertionBefore,{
                        title:'새 DAY',items:[]
                    });
                    if(createdDay){
                        if(state.kind==='internal-block' && state.element){
                            var sourceDay=state.element.closest('.planner-day');
                            var targetBody=$('.planner-day-body',createdDay);
                            targetBody.insertBefore(state.element,$('.planner-add-block-btn',targetBody));
                            ensureDayControls(createdDay);
                            if(sourceDay) ensureDayControls(sourceDay);
                            changed=true;
                        }else if(state.kind==='item'){
                            applyImportHeaderDefaults(state.payload);
                            insertBlockAt(createdDay,plannerBlockPrefill(state.payload.item||{}),null);
                            toast('새 DAY를 만들고 일정 블록을 가져왔습니다.');
                            changed=true;
                        }else{
                            createdDay.remove();
                        }
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
                // 카트 가져오기는 국가 입력 이벤트를 발생시키지 않아 시트명이 갱신되지 않았음.
                // 시트 객체의 country를 즉시 동기화한다 (작성/수정 공통).
                syncPlannerActiveSheetCountry();
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
                var selectedCountry=matchedCountry ? matchedCountry.name
                    : normalizePlannerText(countryInput && countryInput.value);
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
                    : '<span class="w-1.5 h-1.5 rounded-full bg-red-500 shrink-0"></span>비공개<svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="m6 9 6 6 6-6"/></svg>';

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

            // 새 일정 작성 화면은 DAY 없이 시작한다. 사용자가 Day 추가 버튼을 눌러 직접 시작한다.

            // 공유폴더 서버(SharedImageStorage)가 허용하는 파일 형식과 정확히 일치시킨다.
            var PLANNER_IMAGE_MAX_BYTES=10*1024*1024;
            var PLANNER_REQUEST_MAX_BYTES=100*1024*1024;
            function validatePlannerImageFile(file){
                if(!file)return '이미지 파일을 선택해 주세요.';
                var mime=String(file.type||'').toLowerCase();
                var name=String(file.name||'').toLowerCase();
                var types={
                    'image/jpeg':/\.jpe?g$/,
                    'image/png':/\.png$/,
                    'image/gif':/\.gif$/,
                    'image/webp':/\.webp$/
                };
                if(!types[mime] || !types[mime].test(name)){
                    return 'JPG, PNG, GIF, WEBP 파일만 등록할 수 있습니다. 선택한 파일: '+(file.name||'이름 없음');
                }
                if(file.size>PLANNER_IMAGE_MAX_BYTES){
                    return '이미지는 파일당 10MB 이하만 업로드할 수 있습니다. 파일: '+file.name;
                }
                if(file.size===0)return '빈 이미지 파일은 업로드할 수 없습니다. 파일: '+file.name;
                return '';
            }
            function validatePlannerPendingUploads(){
                var total=0;
                for(var i=0;i<plannerSheets.length;i++){
                    var files=plannerSheets[i].files||[];
                    for(var j=0;j<files.length;j++){
                        var file=files[j]&&files[j].file;
                        if(!file)continue;
                        var problem=validatePlannerImageFile(file);
                        if(problem){
                            showRequiredFieldsModal([problem], '이미지 업로드 확인');
                            return false;
                        }
                        total+=file.size;
                    }
                }
                // multipart 경계/JSON 오버헤드를 남긴다 (서버 전체 요청 제한 100MB).
                if(total>PLANNER_REQUEST_MAX_BYTES-2*1024*1024){
                    showRequiredFieldsModal(['첨부 이미지 총 크기가 너무 큽니다. 사진 크기를 줄여 주세요.'], '이미지 업로드 확인');
                    return false;
                }
                return true;
            }

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
                    fileInput.accept='.jpg,.jpeg,.png,.gif,.webp,image/jpeg,image/png,image/gif,image/webp';
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

                    var uploadError=validatePlannerImageFile(file);
                    if(uploadError){
                        showRequiredFieldsModal([uploadError], '이미지 업로드 확인');
                        fileInput.value='';
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

                // 전체 예상 예산 = 화면에 열린 시트 + 저장된 다른 시트 예산.
                if(plannerSheets && plannerSheets.length){
                    var all=total;
                    plannerSheets.forEach(function(sheet,index){
                        if(index===plannerSheetIndex || !sheet.payload) return;
                        all+=plannerSheetAmount(sheet.payload);
                    });
                    var global=$('#plannerGlobalBudget');
                    if(global) global.textContent=money(all);
                }else{
                    var globalDefault=$('#plannerGlobalBudget');
                    if(globalDefault) globalDefault.textContent=money(total);
                }
                var countryName=$('#plannerCountry') ? $('#plannerCountry').value.trim() : '';
                var countryLabel=$('#plannerBudgetCountry');
                if(countryLabel) countryLabel.textContent=(countryName || '국가별')+' 예상 예산';
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
                card.dataset.itemType=TYPE_CONFIG[prefill.type] ? prefill.type : 'sightseeing';
                card.dataset.sourceBlockId=prefill.sourceBlockId||'';
                card.querySelectorAll('[id]').forEach(function(el){ el.removeAttribute('id'); });
                card.querySelectorAll('label[for]').forEach(function(el){ el.removeAttribute('for'); });
                var title=$('.planner-item-title',card), label=$('.planner-block-title-label',card);
                var start=$('.planner-start-time',card), end=$('.planner-end-time',card), cost=$('.planner-item-cost',card), note=$('.planner-item-note',card);
                var place=$('.planner-place-search',card);
                if(title) title.value=prefill.title||'';
                if(label) label.textContent=prefill.title||'새 일정';
                if(start) start.value=shortTime(prefill.startTime||'');
                if(end) end.value=shortTime(prefill.endTime||'');
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
                    place.dataset.placeCity=prefill.placeCity || '';

                    place.dataset.lat=
                        prefill.placeLat!=null
                            ? String(prefill.placeLat)
                            : (prefill.lat!=null ? String(prefill.lat) : '');

                    place.dataset.lng=
                        prefill.placeLng!=null
                            ? String(prefill.placeLng)
                            : (prefill.lng!=null ? String(prefill.lng) : '');
                }
                if(note){
                    note.value=prefill.note||'';
                    // 과거 저장본의 200자 초과 메모는 임의로 잘라내지 않는다.
                    // 저장할 때 초과 위치를 안내하여 직접 수정하도록 한다.
                    note.dataset.plannerLegacyOverLimit=note.value.length>200 ? '1' : '';
                }
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
                updatePlannerScheduleStats();
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
                    city:input.dataset.placeCity || '',
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
                input.dataset.placeCity='';
                input.dataset.lat='';
                input.dataset.lng='';

                input.value=currentText;

                var card=
                    input.closest('.planner-block-card');

                updatePlannerPlacePinState(card);
                schedulePlannerTripGeoStats();
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
                targetInput.dataset.placeCity=sourceInput.dataset.placeCity || point.city || '';

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

            // Google Places는 국가 코드만으로 텍스트 검색을 강제 제한하지 않으므로,
            // 장소의 실제 주소 구성요소(country.shortText)를 확인하여 다른 국가를 제외한다.
            function plannerSearchCountryCode(place){
                var components=place && place.addressComponents;
                if(!Array.isArray(components)) return '';
                for(var i=0;i<components.length;i++){
                    var part=components[i];
                    if(part && Array.isArray(part.types) && part.types.indexOf('country')!==-1){
                        return String(part.shortText||'').toUpperCase();
                    }
                }
                return '';
            }

            function searchPlannerPlaces(card,query,requestState,onResults){
                query=String(query||'').trim();
                if(query.length<2){
                    clearPlannerMapSearchMarkers();
                    return;
                }
                var selectedCountry=findPlannerCountry($('#plannerCountry') ? $('#plannerCountry').value : '');
                var requestId=++requestState.id;
                if(!selectedCountry){
                    clearPlannerMapSearchMarkers();
                    if(typeof onResults==='function') onResults([]);
                    return;
                }
                var expectedCode=String(selectedCountry.code||'').toUpperCase();
                getPlannerPlacesLibrary()
                .then(function(placesLib){
                    if(!placesLib || !placesLib.Place || typeof placesLib.Place.searchByText!=='function') return null;
                    // 지역 설정(region)은 검색 제한 옵션이 아니다. 국가명을 검색어에 포함시키고
                    // 실제 주소의 country 코드로 반드시 재검증한다.
                    var request={
                        textQuery:query+' '+selectedCountry.name,
                        fields:['id','displayName','formattedAddress','location','addressComponents'],
                        language:'ko',
                        region:expectedCode.toLowerCase(),
                        maxResultCount:20
                    };
                    return placesLib.Place.searchByText(request);
                })
                .then(function(result){
                    if(requestId!==requestState.id || !result) return;
                    // 시트를 바꾸거나 국가를 변경한 사이 도착한 이전 검색 결과는 표시하지 않는다.
                    var now=findPlannerCountry($('#plannerCountry') ? $('#plannerCountry').value : '');
                    if(!now || String(now.code||'').toUpperCase()!==expectedCode) return;
                    var places=(result.places||[]).filter(function(place){
                        return plannerSearchCountryCode(place)===expectedCode;
                    }).slice(0,6);
                    showPlannerPlaceSearchResultsOnMap(card,places);
                    if(typeof onResults==='function') onResults(places);
                })
                .catch(function(error){
                    if(requestId!==requestState.id)return;
                    console.error('지도 장소검색 결과 표시 실패:',error);
                    clearPlannerMapSearchMarkers();
                    if(typeof onResults==='function') onResults([]);
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
                hiddenInput.dataset.placeCity='';
                var selectedPlaceId=String(place.id||'');
                plannerFirstAdmin1Korean(place.addressComponents).then(function(region){
                    if(String(hiddenInput.dataset.googlePlaceId||'')!==selectedPlaceId)return;
                    hiddenInput.dataset.placeCity=region;
                    if(selectedPlaceId)plannerCityByPoint['place:'+selectedPlaceId]=region;
                    schedulePlannerTripGeoStats();
                    markDirty();
                });

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
                schedulePlannerTripGeoStats();
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
                var memoInput=$('.planner-item-note',card);
                var memoCounter=$('.planner-memo-count',card);
                if(memoInput && memoCounter){
                    var updateMemoCount=function(enforceLimit){
                        // 한글 IME 조합에서는 일시적으로 maxlength보다 한 글자
                        // 길어질 수 있으므로, 조합 완료 및 저장 시에도 보정한다.
                        if(enforceLimit && memoInput.value.length>200
                                && memoInput.dataset.plannerLegacyOverLimit!=='1'){
                            memoInput.value=memoInput.value.slice(0,200);
                        }
                        var length=memoInput.value.length;
                        if(length<=200){
                            memoInput.dataset.plannerLegacyOverLimit='';
                        }
                        memoCounter.textContent=length+'/200';
                        memoCounter.classList.toggle('is-over-limit',length>200);
                        memoInput.setAttribute('aria-invalid',length>200?'true':'false');
                        memoCounter.title=length>200
                            ? '메모가 200자를 초과했습니다. 저장하려면 200자 이하로 수정해 주세요.'
                            : '';
                    };
                    memoInput.maxLength=200;
                    memoInput.addEventListener('input',function(event){
                        updateMemoCount(!event.isComposing);
                        markDirty();
                    });
                    memoInput.addEventListener('compositionend',function(){
                        updateMemoCount(true);
                    });
                    memoInput.addEventListener('change',function(){
                        updateMemoCount(true);
                    });
                    memoInput.addEventListener('blur',function(){
                        updateMemoCount(true);
                    });
                    updateMemoCount(false);
                }
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
                        updatePlannerScheduleStats();
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
                $$('.planner-day').forEach(function(day){
                    var del=$('.planner-day-delete',day);
                    if(!del) return;
                    del.style.display='';
                    del.disabled=false;
                    del.style.pointerEvents='';
                    del.setAttribute('aria-hidden','false');
                });
            }

            /* 제목 오른쪽의 "N일 · N개 일정"을 현재 작성 중인 DAY/블록 수와 항상 동기화한다. */
            function updatePlannerScheduleStats(){
                var stats=$('#plannerScheduleStats');
                if(!stats) return;
                var dayCount=$$('.planner-day').length;
                var scheduleCount=$$('.planner-day .planner-block-card, .planner-day .planner-block-summary').length;
                stats.textContent=dayCount+'일 · '+scheduleCount+'개 일정';
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
                updateAddDayButton(); rebuildMapFilter(); updateDayDeleteButtons(); updatePlannerScheduleStats();
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
                            : '이 DAY를 삭제할까요?',
                        items:childItems
                    }, function(){
                        day.remove();
                        renumberDays();
                        syncBudget();
                        syncCountryEditLock();
                        refreshMap(plannerActiveMapDay);
                        markDirty();
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
            var PLANNER_EXCHANGE_RATES=PLANNER_BOOTSTRAP.exchangeRates || {};

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

            function normalizePlannerText(v){ return String(v||'').trim(); }

            function normalizePlannerDateValue(value){
                if(value==null || value==='') return '';

                var raw=String(value).trim();
                var iso=raw.match(/^(\d{4})-(\d{2})-(\d{2})/);
                if(iso){
                    return iso[1]+'-'+iso[2]+'-'+iso[3];
                }

                var parsed=new Date(raw);
                if(isNaN(parsed.getTime())) return '';

                var y=parsed.getFullYear();
                var m=String(parsed.getMonth()+1).padStart(2,'0');
                var d=String(parsed.getDate()).padStart(2,'0');
                return y+'-'+m+'-'+d;
            }

            function updatePlannerTitleCount(){
                var input=$('#tripTitle');
                var count=$('#plannerTitleCount');
                if(!input || !count) return;
                if(input.value.length>30){
                    input.value=input.value.slice(0,30);
                }
                count.textContent=input.value.length+'/30';
            }
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
                    status.dataset.countryStatus='required';
                    status.title='국가를 선택해 주세요.';
                    field.style.borderColor='#FCA5A5';
                }else if(!matched){
                    status.textContent='일치하는 국가가 없습니다';
                    status.dataset.countryStatus='invalid';
                    status.title='일치하는 국가가 없습니다';
                    field.style.borderColor='#FCA5A5';
                }else{
                    status.textContent='';
                    status.dataset.countryStatus='valid';
                    status.removeAttribute('title');
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
                        syncPlannerActiveSheetCountry();
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

            /**
             * ISO 3166-2 및 Unicode CLDR 한글 명칭을 서버에서 캐시한 목록.
             * 서버 저장 검증과 동일한 목록으로 임의 지역 입력을 막는다.
             * Google Places는 블록의 장소 검색에만 사용한다.
             */
            var plannerAdmin1CatalogPromise=null;
            function getPlannerRegionCatalog(){
                if(plannerAdmin1CatalogPromise) return plannerAdmin1CatalogPromise;
                var url=PLANNER_CONTEXT_PATH+'/itinerary/regionCatalog';
                plannerAdmin1CatalogPromise=fetch(url,{credentials:'same-origin'})
                    .then(function(response){
                        if(!response.ok) throw new Error('지역 목록 응답 '+response.status);
                        return response.json();
                    })
                    .then(function(data){
                        if(!data || !Array.isArray(data.countries)){
                            throw new Error('지역 목록 형식이 올바르지 않습니다.');
                        }
                        var result=Object.create(null);
                        data.countries.forEach(function(entry){
                            if(entry && entry.code && Array.isArray(entry.regions)){
                                result[String(entry.code).toUpperCase()]=entry.regions.map(function(region){
                                    return {code:region.code, name:region.name,
                                        nameEn:region.en||'',source:'admin1'};
                                });
                            }
                        });
                        return result;
                    })
                    .catch(function(error){
                        plannerAdmin1CatalogPromise=null; // 네트워크 일시 오류 시 재시도
                        throw error;
                    });
                return plannerAdmin1CatalogPromise;
            }
            function getPlannerAdmin1Regions(code){
                code=String(code||'').toUpperCase();
                if(Object.prototype.hasOwnProperty.call(plannerAdmin1Cache,code)){
                    return Promise.resolve(plannerAdmin1Cache[code]);
                }
                return getPlannerRegionCatalog().then(function(catalog){
                    var rows=(catalog[code]||[]).slice().sort(function(a,b){
                        return String(a.name||'').localeCompare(String(b.name||''),'ko-KR');
                    });
                    plannerAdmin1Cache[code]=rows;
                    return rows;
                });
            }
            function syncPlannerSavedRegion(matched,items){
                var region=$('#plannerRegion');
                var country=$('#plannerCountry');
                if(!region || !country || !matched) return;
                var current=findPlannerCountry(country.value);
                if(!current || current.code!==matched.code) return;
                // 기존 일정 불러오기: 정식 명칭과 일치하면 자동으로 선택된 항목으로 인식.
                var selected=items.find(function(item){return item.name===region.value.trim();});
                if(selected){
                    region.dataset.regionCode=selected.code;
                    region.dataset.regionCountry=matched.code;
                    region.setAttribute('aria-invalid','false');
                }else if(region.value.trim()){
                    region.dataset.regionCode='';
                    region.dataset.regionCountry='';
                }
            }
            function renderPlannerRegionButtons(items,matched){
                var region=$('#plannerRegion');
                var dropdown=$('#plannerRegionDropdown');
                if(!region || !dropdown) return;
                dropdown.innerHTML='';
                items.forEach(function(item){
                    var btn=document.createElement('button');
                    btn.type='button';
                    btn.className='flex flex-col items-start px-3 py-2.5 text-left min-w-0';
                    var label=document.createElement('span');
                    label.className='text-sm font-medium text-gray-800 w-full truncate';
                    label.textContent=item.name;
                    btn.appendChild(label);
                    btn.addEventListener('mousedown',function(event){
                        event.preventDefault();
                        region.value=item.name;
                        region.dataset.regionCode=item.code;
                        region.dataset.regionCountry=matched.code;
                        region.dataset.regionPlaceId='';
                        region.dataset.regionAddress='';
                        region.setAttribute('aria-invalid','false');
                        dropdown.classList.add('hidden');
                        updateRegionClear();
                        markDirty();
                    });
                    dropdown.appendChild(btn);
                });
                dropdown.classList.toggle('hidden',items.length===0);
            }
            function renderPlannerRegionMessage(message){
                var dropdown=$('#plannerRegionDropdown');
                if(!dropdown) return;
                dropdown.innerHTML='';
                var row=document.createElement('div');
                row.className='px-3 py-2.5 text-xs text-gray-500';
                row.textContent=message;
                dropdown.appendChild(row);
                dropdown.classList.remove('hidden');
            }
            function refreshRegionOptions(clearValue){
                var country=$('#plannerCountry');
                var region=$('#plannerRegion');
                var dropdown=$('#plannerRegionDropdown');
                if(!country || !region || !dropdown) return;
                var matched=findPlannerCountry(country.value);
                dropdown.innerHTML='';
                plannerRegionSearchSeq++;
                if(clearValue){
                    region.value='';
                    region.dataset.regionCode='';
                    region.dataset.regionCountry='';
                    region.dataset.regionPlaceId='';
                    region.dataset.regionAddress='';
                }
                if(!matched){
                    region.disabled=true;
                    region.placeholder='국가 먼저 선택';
                    region.value='';
                    region.dataset.regionCode='';
                    region.dataset.regionCountry='';
                    dropdown.classList.add('hidden');
                    updateRegionClear();
                    return;
                }
                region.disabled=false;
                region.placeholder='1차 행정구역 선택 또는 검색';
                // 기존 일정 및 초안 불러오기도 검증할 수 있도록 미리 로딩한다.
                getPlannerAdmin1Regions(matched.code).then(function(items){
                    syncPlannerSavedRegion(matched,items);
                }).catch(function(){});
                dropdown.classList.add('hidden');
                updateRegionClear();
            }
            function renderRegionDropdown(){
                var country=$('#plannerCountry');
                var region=$('#plannerRegion');
                var dropdown=$('#plannerRegionDropdown');
                if(!country || !region || !dropdown || region.disabled) return;
                var matched=findPlannerCountry(country.value);
                if(!matched){
                    dropdown.classList.add('hidden');
                    return;
                }
                var query=normalizePlannerText(region.value).toLocaleLowerCase();
                var seq=++plannerRegionSearchSeq;
                renderPlannerRegionMessage('1차 행정구역 목록을 불러오는 중입니다.');
                getPlannerAdmin1Regions(matched.code).then(function(items){
                    if(seq!==plannerRegionSearchSeq) return;
                    var current=findPlannerCountry(country.value);
                    if(!current || current.code!==matched.code) return;
                    if(normalizePlannerText(region.value).toLocaleLowerCase()!==query) return;
                    var matches=items.filter(function(item){
                        if(!query) return true;
                        return item.name.toLocaleLowerCase().indexOf(query)!==-1
                            || item.nameEn.toLocaleLowerCase().indexOf(query)!==-1
                            || item.code.toLocaleLowerCase().indexOf(query)!==-1;
                    });
                    if(matches.length){
                        renderPlannerRegionButtons(matches,matched);
                    }else{
                        renderPlannerRegionMessage(items.length
                            ? '일치하는 1차 행정구역이 없습니다. 목록에서 선택해 주세요.'
                            : '해당 국가의 등록된 1차 행정구역이 없습니다. 지역은 비워둘 수 있습니다.');
                    }
                }).catch(function(){
                    if(seq===plannerRegionSearchSeq){
                        renderPlannerRegionMessage('지역 목록을 불러오지 못했습니다. 다시 클릭해 주세요.');
                    }
                });
            }

            function validatePlannerMemoLengths(){
                var problem=null;
                $$('.planner-day').some(function(day,dayIndex){
                    return $$('.planner-block-card',day).some(function(card,blockIndex){
                        var input=$('.planner-item-note',card);
                        if(!input) return false;

                        // 저장 버튼을 조합 중 바로 눌러도 201자가 넘어가지 않게 한다.
                        // 단, 기존에 저장되어 있던 200자 초과 메모는
                        // 사용자의 동의 없이 잘라내지 않는다.
                        if(input.value.length>200
                                && input.dataset.plannerLegacyOverLimit!=='1'){
                            input.value=input.value.slice(0,200);
                        }
                        var count=$('.planner-memo-count',card);
                        var length=input.value.length;
                        if(length<=200){
                            input.dataset.plannerLegacyOverLimit='';
                        }
                        if(count){
                            count.textContent=length+'/200';
                            count.classList.toggle('is-over-limit',length>200);
                        }
                        input.setAttribute('aria-invalid',length>200?'true':'false');
                        if(length<=200) return false;
                        problem={day:day,card:card,dayIndex:dayIndex,
                            blockIndex:blockIndex,length:length};
                        return true;
                    });
                });
                if(!problem) return true;

                // 초과된 블록이 접혀 있어도 사용자가 바로 찾을 수 있게 펼친다.
                var dayBody=$('.planner-day-body',problem.day);
                var blockBody=$('[data-block-body]',problem.card);
                if(dayBody) dayBody.classList.remove('is-collapsed');
                if(blockBody) blockBody.classList.remove('is-collapsed');
                problem.card.scrollIntoView({behavior:'smooth',block:'center'});
                var titleInput=$('.planner-item-title',problem.card);
                var blockName=titleInput && titleInput.value.trim()
                    ? ' ('+titleInput.value.trim()+')' : '';
                showRequiredFieldsModal([
                    'Day '+(problem.dayIndex+1)+'의 '+(problem.blockIndex+1)
                    +'번째 블록'+blockName+' 메모가 '+problem.length
                    +'자입니다. 200자 이하로 수정한 뒤 저장해 주세요.'
                ], '블록 메모 글자 수 초과');
                return false;
            }

            function showRequiredFieldsModal(items,headingText){
                var backdrop=$('#plannerRequiredBackdrop');
                var list=$('#plannerRequiredList');
                if(!backdrop || !list) return;
                var heading=$('#plannerRequiredTitle');
                if(heading) heading.textContent=headingText||'필수 항목을 확인해 주세요';
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
            function validatePlannerRequiredFields(skipTitle){
                var missing=[];
                var title=$('#tripTitle');
                var country=$('#plannerCountry');

                if(!skipTitle && (!title || !normalizePlannerText(title.value))) missing.push('여행 제목');

                if(!country || !normalizePlannerText(country.value)){
                    missing.push('국가');
                    refreshCountryStatus();
                }else if(!findPlannerCountry(country.value)){
                    missing.push('일치하는 국가 선택');
                    refreshCountryStatus();
                }

                var regionInput=$('#plannerRegion');
                var validCountry=country ? findPlannerCountry(country.value) : null;
                if(regionInput && regionInput.type!=='hidden' && regionInput.value.trim()){
                    // 복원된 일정과 초안은 원본 목록과 일치하면 syncPlannerSavedRegion이 갱신한다.
                    var items=validCountry && plannerAdmin1Cache[validCountry.code];
                    if(items && items.length){syncPlannerSavedRegion(validCountry,items);}
                    if(!validCountry || regionInput.dataset.regionCountry!==validCountry.code
                            || !regionInput.dataset.regionCode){
                        regionInput.setAttribute('aria-invalid','true');
                        missing.push('지역은 검색 결과의 1차 행정구역을 직접 선택해 주세요. (임의 입력 불가)');
                    }
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
                    syncPlannerActiveSheetCountry();
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
                    plannerRegionInput.dataset.regionPlaceId='';
                    plannerRegionInput.dataset.regionAddress='';
                    plannerRegionInput.dataset.regionCode='';
                    plannerRegionInput.dataset.regionCountry='';
                    plannerRegionInput.setAttribute('aria-invalid','false');
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
                    plannerRegionInput.dataset.regionPlaceId='';
                    plannerRegionInput.dataset.regionAddress='';
                    plannerRegionInput.dataset.regionCode='';
                    plannerRegionInput.dataset.regionCountry='';
                    plannerRegionInput.setAttribute('aria-invalid','false');
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
                var contextPath=(typeof PLANNER_CONTEXT_PATH!=='undefined') ? PLANNER_CONTEXT_PATH : '';
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
                    sheets:plannerSheets && plannerSheets.length ? collectAllPlannerSheets().map(function(payload,i){
                        return {payload:payload,placeholder:plannerSheets[i].placeholder,first:plannerSheets[i].first};
                    }) : null,
                    currentSheetIndex:plannerSheetIndex||0,
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
                var sheetsFiles=[];
                if(plannerSheets&&plannerSheets.length){
                    capturePlannerSheet();
                    plannerSheets.forEach(function(sheet,index){
                        (sheet.files||[]).forEach(function(rec){
                            sheetsFiles.push({sheetIndex:index,dayIndex:rec.dayIndex,
                                blockIndex:rec.blockIndex,imageIndex:rec.imageIndex,file:rec.file});
                        });
                    });
                }else sheetsFiles=collectDraftFiles();
                return savePlannerDraftFiles(sheetsFiles).catch(function(e){
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
                    if(tripTitle){
                        tripTitle.value=payload.title || '';
                        updatePlannerTitleCount();
                    }
                    if(country) country.value=payload.country || '';
                    refreshCountryStatus();
                    refreshRegionOptions(false);
                    if(region) region.value=payload.city || '';
                    if(traveler) traveler.value=String(payload.travelerCount || 1);
                    if(startDate) startDate.value=normalizePlannerDateValue(payload.startDate);
                    if(endDate) endDate.value=normalizePlannerDateValue(payload.endDate);
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
                        if(summaryCount) summaryCount.textContent=publishSummary.value.length+'/250';
                    }

                    $$('.planner-day').forEach(function(day){ day.remove(); });

                    var days=Array.isArray(payload.days) ? payload.days.slice().sort(function(a,b){
                        return Number(a.dayOrder||0)-Number(b.dayOrder||0);
                    }) : [];

                    days.forEach(function(dayDto,index){
                        var daysWrap=$('#plannerDays');
                        var addDayButton=$('#plannerAddDay');
                        if(!daysWrap) return;
                        var day=createPlannerDayShell(dayDto.title || ('Day '+(index+1)));
                        daysWrap.insertBefore(day,addDayButton||null);
                        setupDay(day);

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
                                placeCity:block.placeCity || '',
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
                    if(Array.isArray(draft.sheets) && draft.sheets.length && plannerSheets){
                        plannerSheets=draft.sheets.map(function(item,index){
                            return {payload:item.payload,first:!!item.first,
                                placeholder:item.placeholder||plannerPlaceholderAt(index),
                                files:files.filter(function(rec){return Number(rec.sheetIndex)===index;})};
                        });

                        plannerSheetIndex=0;
                        applyPlannerDraftPayload(plannerSheets[0].payload,plannerSheets[0].files);
                        var targetIndex=Math.max(0,Math.min(plannerSheets.length-1,Number(draft.currentSheetIndex)||0));
                        if(targetIndex!==0)switchPlannerSheet(targetIndex);
                        renderPlannerSheets();syncBudget();
                    }else{
                        applyPlannerDraftPayload(draft.payload,files);
                    }
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
                    transport:'TRANSPORT'
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
                            placeCity:selectedPlace
                                ? (plannerSavedAdmin1Korean(selectedPlace.city || plannerCityByPoint[plannerCityPointId(selectedPlace)] || '', (findPlannerCountry($('#plannerCountry') ? $('#plannerCountry').value : '') || {}).code) || null)
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
                    city:$('#plannerRegion') && $('#plannerRegion').type!=='hidden' && $('#plannerRegion').value.trim()
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

                // 다른 시트에 등록된 사진도 대표 이미지 후보에 포함한다.
                // 활성 시트의 로컬 사진은 위 루프에서 가져오므로 중복하지 않는다.
                if(plannerSheets && plannerSheets.length>1){
                    plannerSheets.forEach(function(sheet,sheetIndex){
                        if(sheetIndex===plannerSheetIndex)return;
                        (sheet.payload && sheet.payload.days || []).forEach(function(day,dayIndex){
                            (day.blocks||[]).forEach(function(block,blockIndex){
                                (block.images||[]).forEach(function(photo,photoIndex){
                                    var order=Number(photo.imageOrder||photoIndex+1);
                                    var fileRec=(sheet.files||[]).find(function(rec){
                                        return Number(rec.dayIndex)===dayIndex&&Number(rec.blockIndex)===blockIndex&&Number(rec.imageIndex)===order-1;
                                    });
                                    var src='';
                                    if(fileRec&&fileRec.file){
                                        if(!fileRec.previewUrl)fileRec.previewUrl=URL.createObjectURL(fileRec.file);
                                        src=fileRec.previewUrl;
                                    }else if(photo.imageUrl){
                                        src=plannerDraftDisplayImageUrl(photo.imageUrl);
                                    }
                                    if(src)result.push({
                                        key:'sheetphoto:'+sheetIndex+':'+dayIndex+':'+blockIndex+':'+order,
                                        src:src,dayIndex:dayIndex,blockIndex:blockIndex,imageOrder:order
                                    });
                                });
                            });
                        });
                    });
                }
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

                if(title) title.textContent=$('#tripTitle')?.value.trim() || '여행 제목을 입력하세요.';

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
                // Google 장소 ID 없이 저장된 좌표 핀을 텍스트 검색으로 찾은 경우,
                // 사용자가 사진을 선택할 때만 해당 블록에 확인된 Place ID를 반영한다.
                // 그래야 서버의 gplace: 참조 검증과 실제 블록 데이터가 일치한다.
                if(candidate && candidate.source==='place' && candidate.placeId
                        && Number.isInteger(candidate.dayIndex)
                        && Number.isInteger(candidate.blockIndex)){
                    var photoDay=$$('.planner-day')[candidate.dayIndex];
                    var photoBlock=photoDay && $$('.planner-block-card',photoDay)[candidate.blockIndex];
                    var photoPlaceInput=photoBlock && $('.planner-place-search',photoBlock);
                    if(photoPlaceInput && !String(photoPlaceInput.dataset.googlePlaceId||'').trim()){
                        photoPlaceInput.dataset.googlePlaceId=String(candidate.placeId);
                        markDirty();
                    }
                }
                if(candidate && candidate.source==='place' && candidate.placeId
                        && String(candidate.key||'').indexOf('sheetplace:')===0){
                    var indexes=String(candidate.key).split(':');
                    var targetSheet=plannerSheets[Number(indexes[1])];
                    var targetDay=targetSheet&&targetSheet.payload&&targetSheet.payload.days[Number(indexes[2])];
                    var targetBlock=targetDay&&targetDay.blocks[Number(indexes[3])];
                    if(targetBlock)targetBlock.googlePlaceId=String(candidate.placeId);
                }
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
            var plannerPublishActiveCandidates=[];

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

            function syncPublishPhotoRequirement(isPublic, hasRegisteredPhotos){
                var requirement=$('#plannerPublishPhotoRequirement');
                var hint=$('#plannerPublishPhotoHint');

                if(requirement){
                    requirement.textContent=(!isPublic && !hasRegisteredPhotos)
                        ? '(자동 선택)' : '(필수)';
                }

                if(hint){
                    hint.textContent=hasRegisteredPhotos
                        ? '등록한 사진 중에서 대표 이미지를 선택해 주세요.'
                        : isPublic
                            ? '등록 사진이 없어 Google Places 장소 사진에서 선택합니다. (국기 사용 불가)'
                            : '등록 사진이 없어 선택한 국가의 국기가 자동 지정됩니다.';
                }
            }

            function collectPublishPlacePhotoSources(){
                var result=[];
                var seen={};

                $$('.planner-day').forEach(function(day,dayIndex){
                    $$('.planner-block-card',day).forEach(function(card,blockIndex){
                        var input=$('.planner-place-search',card);
                        var point=plannerSelectedPlacePoint(input);
                        if(!point) return;
                        var placeId=String(point.googlePlaceId||'').trim();
                        // 지도에 찍힌 핀이 좌표/이름만 가지고 있어도 사진 검색 대상에 포함한다.
                        var identity=placeId || ('geo:'+point.lat+','+point.lng+':'+point.name);
                        if(seen[identity]) return;
                        seen[identity]=true;
                        result.push({
                            key:'place:'+dayIndex+':'+blockIndex,
                            point:point,
                            placeId:placeId,
                            dayIndex:dayIndex,
                            blockIndex:blockIndex
                        });
                    });
                });
                if(plannerSheets && plannerSheets.length>1){
                    plannerSheets.forEach(function(sheet,sheetIndex){
                        if(sheetIndex===plannerSheetIndex)return;
                        (sheet.payload && sheet.payload.days || []).forEach(function(day,dayIndex){
                            (day.blocks||[]).forEach(function(block,blockIndex){
                                if(!isFinite(Number(block.placeLat)) || !isFinite(Number(block.placeLng))
                                        || !String(block.placeName||'').trim())return;
                                var point={lat:Number(block.placeLat),lng:Number(block.placeLng),
                                    name:block.placeName,address:block.placeAddress||'',googlePlaceId:block.googlePlaceId||''};
                                var placeId=String(point.googlePlaceId||'').trim();
                                var identity=placeId || ('geo:'+point.lat+','+point.lng+':'+point.name);
                                if(seen[identity])return;
                                seen[identity]=true;
                                result.push({key:'sheetplace:'+sheetIndex+':'+dayIndex+':'+blockIndex,
                                    point:point,placeId:placeId,dayIndex:dayIndex,blockIndex:blockIndex,
                                    sheetIndex:sheetIndex});
                            });
                        });
                    });
                }
                return result;
            }

            function resolvePlannerPlacePhotoDetails(source){
                if(source.placeId){
                    return fetchPlannerPlaceDetails(source.point).catch(function(){ return null; });
                }
                var point=source.point;
                var query=String(point.name||'').trim();
                if(!query) return Promise.resolve(null);
                return getPlannerPlacesLibrary().then(function(lib){
                    if(!lib || !lib.Place || typeof lib.Place.searchByText!=='function') return null;
                    var request={
                        textQuery:query+(point.address ? ' '+point.address : ''),
                        fields:['id','displayName','location','photos'],
                        maxResultCount:5,
                        language:'ko'
                    };
                    return lib.Place.searchByText(request).then(function(response){
                        var places=response && response.places || [];
                        // 이름 검색 결과가 다른 국가/도시일 수 있으므로 핀과 가까운 결과만 인정한다.
                        for(var i=0;i<places.length;i++){
                            var place=places[i];
                            if(!place || !place.id || !place.photos || !place.photos.length || !place.location) continue;
                            var lat=typeof place.location.lat==='function' ? place.location.lat() : place.location.lat;
                            var lng=typeof place.location.lng==='function' ? place.location.lng() : place.location.lng;
                            if(!isFinite(Number(lat)) || !isFinite(Number(lng))) continue;
                            var latDelta=(Number(lat)-Number(point.lat))*111000;
                            var lngDelta=(Number(lng)-Number(point.lng))*111000*Math.cos(Number(point.lat)*Math.PI/180);
                            if(Math.sqrt(latDelta*latDelta+lngDelta*lngDelta)<=3000) return place;
                        }
                        return null;
                    });
                }).catch(function(){ return null; });
            }

            function collectPublishPlacePhotoCandidates(){
                var sources=collectPublishPlacePhotoSources();
                if(!sources.length) return Promise.resolve([]);
                return Promise.all(sources.map(function(source){
                    return resolvePlannerPlacePhotoDetails(source).then(function(details){
                        if(!details || !details.photos || !details.photos.length || !details.id) return null;
                        var photo=details.photos[0];
                        var src='';
                        try{src=photo.getURI({maxWidth:960,maxHeight:720}) || '';}
                        catch(e){src='';}
                        if(!src) return null;
                        return {
                            key:source.key,
                            src:src,
                            source:'place',
                            placeId:String(details.id),
                            placeName:details.displayName || source.point.name || '장소',
                            attributionNames:(photo.authorAttributions||[]).map(function(attr){
                                return attr && attr.displayName ? String(attr.displayName) : '사용자';
                            }),
                            dayIndex:source.dayIndex,
                            blockIndex:source.blockIndex
                        };
                    }).catch(function(){return null;});
                })).then(function(items){
                    return items.filter(function(item){return !!item;});
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

            // 저장된 기존 대표 이미지는 수정 모달의 첫 후보 조회에서만 복원한다.
            // 사진 삭제/공개 전환 후에는 사용자가 새로운 후보를 선택해야 한다.
            var plannerSavedThumbnailRestoreConsumed=false;

            function applyPlannerPublishCandidateSelection(candidates){
                var selected=candidates.find(function(candidate){
                    return candidate.key===plannerPublishState.imageKey;
                });

                // 기존 Google Places 사진의 gplace: 토큰을 후보의 현재 key로 연결한다.
                if(!selected && plannerPublishState.imageKey.indexOf('placeId:')===0){
                    var currentPlaceId=plannerPublishState.imageKey.substring(8);
                    selected=candidates.find(function(candidate){
                        return candidate.source==='place' && candidate.placeId===currentPlaceId;
                    });
                }

                if(!selected && !plannerSavedThumbnailRestoreConsumed
                        && !plannerPublishState.imageKey){
                    var savedThumbnail=EDIT_ITINERARY && EDIT_ITINERARY.thumbnailImg
                        ? String(EDIT_ITINERARY.thumbnailImg) : '';
                    selected=candidates.find(function(candidate){
                        return candidate.src===savedThumbnail
                            || candidate.key===savedThumbnail
                            || (candidate.source==='place'
                                && savedThumbnail==='gplace:'+candidate.placeId);
                    });
                }
                plannerSavedThumbnailRestoreConsumed=true;

                if(selected){
                    selectPublishImage(selected);
                }else{
                    selectPublishImage(null);
                }
            }

            function renderPublishPhotoCandidates(preloadedPlaceCandidates){
                var list=$('#plannerPublishPhotoList');
                var empty=$('#plannerPublishPhotoEmpty');
                if(!list) return;

                var loadToken=++plannerPublishPlacePhotoLoadToken;
                var isPublic=visibility
                    && visibility.dataset.visibility==='PUBLIC';
                var registered=collectPublishPhotoCandidates();
                var hasRegisteredPhotos=registered.length>0;
                syncPublishPhotoRequirement(isPublic,hasRegisteredPhotos);

                function showCandidates(candidates){
                    plannerPublishActiveCandidates=candidates.slice();
                    renderPublishPhotoCandidateButtons(candidates);
                    list.classList.toggle('hidden',candidates.length===0);
                    if(empty) empty.classList.toggle('hidden',candidates.length>0);
                }

                if(hasRegisteredPhotos){
                    // 공개/비공개 모두 직접 등록한 사진이 있으면 그 사진만 보여 준다.
                    // 국기 및 Google Places 사진을 섞지 않는다.
                    showCandidates(registered);
                    applyPlannerPublishCandidateSelection(registered);
                    return;
                }

                if(!isPublic){
                    // 등록 사진이 없는 비공개 일정: 국기를 보여 주고 자동 선택한다.
                    var flagCandidate=plannerPrivateFlagCandidate();
                    showCandidates(flagCandidate ? [flagCandidate] : []);
                    if(flagCandidate){
                        selectPublishImage(flagCandidate);
                    }else{
                        selectPublishImage(null);
                        if(empty){
                            empty.textContent='국가를 선택하면 해당 국가의 국기가 자동 지정됩니다.';
                        }
                    }
                    plannerSavedThumbnailRestoreConsumed=true;
                    return;
                }

                // 공개 일정 + 등록 사진 없음: Google Places 사진만 허용한다.
                // 이전 선택(국기 또는 삭제한 사진)은 즉시 해제하되,
                // 수정 화면에서 유효한 기존 gplace 토큰은 로드 뒤 다시 검증한다.
                showCandidates([]);
                if(plannerPublishState.imageKey.indexOf('placeId:')!==0){
                    selectPublishImage(null);
                }
                if(empty){
                    empty.textContent='등록된 사진이 없어 Google Places 장소 사진을 불러오는 중입니다.';
                    empty.classList.remove('hidden');
                }

                // 저장 전 검사에서 확보한 후보를 재사용해 API를 중복 호출하지 않는다.
                function applyPlaceCandidates(placeCandidates){
                    if(loadToken!==plannerPublishPlacePhotoLoadToken) return;
                    showCandidates(placeCandidates);
                    applyPlannerPublishCandidateSelection(placeCandidates);
                    if(!placeCandidates.length && empty){
                        empty.textContent='등록 사진이나 사진을 제공하는 Google Places 장소가 없어 대표 이미지를 선택할 수 없습니다.';
                    }
                }
                if(Array.isArray(preloadedPlaceCandidates)){
                    applyPlaceCandidates(preloadedPlaceCandidates);
                    return;
                }
                collectPublishPlacePhotoCandidates().then(applyPlaceCandidates).catch(function(){
                    if(loadToken!==plannerPublishPlacePhotoLoadToken) return;
                    showCandidates([]);
                    selectPublishImage(null);
                    if(empty){
                        empty.textContent='Google Places 사진을 불러오지 못했습니다. 장소를 확인하거나 사진을 직접 등록해 주세요.';
                    }
                });
            }

            function openPublishPreviewModal(preloadedPlaceCandidates){
                var backdrop=$('#plannerPublishBackdrop');
                var summaryInput=$('#plannerPublishSummary');

                if(!backdrop) return;

                if(summaryInput){
                    summaryInput.value=plannerPublishState.summary || '';
                    var count=$('#plannerPublishSummaryCount');
                    if(count) count.textContent=summaryInput.value.length+'/250';
                }

                renderPublishPhotoCandidates(preloadedPlaceCandidates);
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

                $('#plannerPublishTitleError')?.classList.remove('is-visible');
                $('.planner-publish-title-field')?.classList.remove('has-error');
                $('#tripTitle')?.removeAttribute('aria-invalid');
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

            // 실패한 요청도 편집 상태와 선택한 브라우저 File 객체를 유지하도록 비동기 저장한다.
            var plannerSaveInProgress=false;
            function submitPlannerAfterPreview(){
                if(plannerSaveInProgress)return;
                var form=$('#plannerSubmitForm');
                var jsonInput=$('#plannerItineraryJson');
                var thumbInput=$('#plannerThumbnailImageKey');
                if(!form || !jsonInput || !thumbInput){
                    toast('저장 폼을 찾을 수 없습니다.');
                    return;
                }
                if(!validatePlannerMemoLengths())return;
                var payload=collectFullPlannerPayload();
                if(!validatePlannerPendingUploads())return;

                appendAllPlannerSheetImageParts(form,payload.sheets);
                thumbInput.value=activeSheetThumbnailKey(plannerPublishState.imageKey);
                jsonInput.value=JSON.stringify(payload);
                form.action=PLANNER_CONTEXT_PATH+'/itinerary/modify';

                plannerSaveInProgress=true;
                var confirmButton=$('#plannerPublishConfirm');
                if(confirmButton)confirmButton.disabled=true;
                keepPlannerSessionAlive(true).then(function(sessionOk){
                    if(!sessionOk || sessionExpiredHandling){
                        throw new Error('로그인 상태를 확인할 수 없습니다. 다시 로그인한 뒤 저장해 주세요. 작성 내용은 유지됩니다.');
                    }
                    return fetch(form.action,{
                        method:'POST',
                        credentials:'same-origin',
                        headers:{'X-Requested-With':'XMLHttpRequest','Accept':'application/json'},
                        body:new FormData(form)
                    });
                }).then(function(response){
                    return response.text().then(function(raw){
                        var result={};
                        try{result=JSON.parse(raw);}catch(e){}
                        if(!response.ok || result.ok!==true || !result.redirect){
                            throw new Error(result.message||'저장에 실패했습니다. 입력 내용을 유지했으니 다시 시도해 주세요.');
                        }
                        return result.redirect;
                    });
                }).then(function(redirect){
                    // 저장이 실제 성공한 경우에만 초안을 삭제한다.
                    return deletePlannerDraft().catch(function(){return null;}).then(function(){
                        dirty=false;
                        window.location.assign(redirect);
                    });
                }).catch(function(error){
                    // 폼을 재로드하지 않는다: 모든 시트, 블록, 사진 File 객체가 그대로 남는다.
                    showRequiredFieldsModal([error && error.message ? error.message : '저장 중 오류가 발생했습니다.'], '저장하지 못했습니다');
                }).finally(function(){
                    plannerSaveInProgress=false;
                    if(confirmButton)confirmButton.disabled=false;
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
                                plannerPublishSummary.value.length+'/250';
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
                        var titleInput=$('#tripTitle');
                        if(!titleInput || !normalizePlannerText(titleInput.value)){
                            var titleError=$('#plannerPublishTitleError');
                            var titleField=$('.planner-publish-title-field');
                            if(titleError) titleError.classList.add('is-visible');
                            if(titleField) titleField.classList.add('has-error');
                            if(titleInput){
                                titleInput.setAttribute('aria-invalid','true');
                                titleInput.focus();
                                titleInput.scrollIntoView({behavior:'smooth',block:'nearest'});
                            }
                            return;
                        }
                        var summaryInput=$('#plannerPublishSummary');
                        var isPublic=visibility
                            && visibility.dataset.visibility==='PUBLIC';
                        var photoError=$('#plannerPublishPhotoError');

                        // 저장 시점에도 현재 후보와 선택한 이미지 키가 일치해야 한다.
                        // 등록 사진이 있으면 그 사진만, 없으면 비공개 국기/공개 장소 사진이다.
                        var registered=collectPublishPhotoCandidates();
                        var selectedKey=plannerPublishState.imageKey || '';
                        var flagCandidate=plannerPrivateFlagCandidate();
                        var validSelection=false;

                        if(registered.length){
                            validSelection=registered.some(function(candidate){
                                return candidate.key===selectedKey;
                            });
                        }else if(!isPublic){
                            validSelection=!!flagCandidate
                                && selectedKey===flagCandidate.key;
                        }else{
                            var availablePlaces=collectPublishPlacePhotoSources();
                            validSelection=plannerPublishActiveCandidates.some(function(candidate){
                                return candidate.source==='place'
                                    && candidate.key===selectedKey
                                    && availablePlaces.some(function(place){
                                        return place.key===candidate.key
                                            && place.placeId===candidate.placeId;
                                    });
                            });
                        }

                        if(!validSelection){
                            if(photoError){
                                photoError.textContent='대표 이미지를 선택해야 저장할 수 있습니다.';
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

            // 공개 일정은 모달에 제목/소개를 입력하기 전에 대표 이미지 후보를 검사한다.
            // 직접 등록한 사진이 없으면 핀이 지정된 장소에서 Google 사진을 실제로 조회한다.
            var plannerPhotoPrecheckInProgress=false;
            function showPlannerPublicPhotoRequiredModal(hasPlaces){
                showRequiredFieldsModal([
                    hasPlaces
                        ? '지도에 지정한 장소에서 대표 사진을 가져올 수 없습니다. 사진을 직접 등록하거나 사진을 제공하는 장소를 선택해 주세요.'
                        : '등록된 사진과 지도에 지정한 장소가 없습니다. 블록에 사진을 등록하거나 사진이 있는 장소를 선택해 주세요.'
                ], '공개 일정에는 대표 사진이 필요합니다');
            }

            var save=$('#plannerSaveBtn');
            if(save) save.addEventListener('click',function(){
                if(plannerPhotoPrecheckInProgress) return;
                if(!validatePlannerRequiredFields(true)) return;
                if(!validatePlannerMemoLengths()) return;
                setupPublishPreviewModal();

                var isPublic=visibility && visibility.dataset.visibility==='PUBLIC';
                if(!isPublic || collectPublishPhotoCandidates().length){
                    openPublishPreviewModal();
                    return;
                }

                var photoSources=collectPublishPlacePhotoSources();
                if(!photoSources.length){
                    showPlannerPublicPhotoRequiredModal(false);
                    return;
                }

                // 장소 핀만으로 사진 확보가 보장되는 것은 아니므로 API 결과를 확인한다.
                plannerPhotoPrecheckInProgress=true;
                save.disabled=true;
                save.setAttribute('aria-busy','true');
                var saveLabel=$('#plannerSaveLabel');
                var originalSaveLabel=saveLabel ? saveLabel.textContent : '';
                if(saveLabel) saveLabel.textContent='사진 확인 중...';

                collectPublishPlacePhotoCandidates().then(function(candidates){
                    // 조회 중에 공개 상태/사진/장소가 변경되면 현재 입력을 기준으로 재판단한다.
                    if(visibility && visibility.dataset.visibility!=='PUBLIC'){
                        openPublishPreviewModal();
                        return;
                    }
                    if(collectPublishPhotoCandidates().length){
                        openPublishPreviewModal();
                        return;
                    }
                    var currentSources=collectPublishPlacePhotoSources();
                    var sourceKeys=photoSources.map(function(source){return source.key+':'+source.placeId;}).join('|');
                    var currentKeys=currentSources.map(function(source){return source.key+':'+source.placeId;}).join('|');
                    if(currentKeys!==sourceKeys){
                        showRequiredFieldsModal(['장소가 변경되었습니다. 저장하기를 다시 눌러 사진을 확인해 주세요.'], '대표 사진을 다시 확인해 주세요');
                        return;
                    }
                    if(!candidates || !candidates.length){
                        showPlannerPublicPhotoRequiredModal(currentSources.length>0);
                        return;
                    }
                    // 확인된 사진을 미리보기 모달에 전달하여 같은 API를 다시 호출하지 않는다.
                    openPublishPreviewModal(candidates);
                }).catch(function(){
                    showPlannerPublicPhotoRequiredModal(true);
                }).finally(function(){
                    plannerPhotoPrecheckInProgress=false;
                    save.disabled=false;
                    save.removeAttribute('aria-busy');
                    if(saveLabel) saveLabel.textContent=originalSaveLabel;
                });
            });
            var plannerTitleInput=$('#tripTitle');
            if(plannerTitleInput){
                plannerTitleInput.addEventListener('input',function(){
                    updatePlannerTitleCount();
                    refreshPublishCard();
                    var error=$('#plannerPublishTitleError');
                    var field=$('.planner-publish-title-field');
                    if(error) error.classList.remove('is-visible');
                    if(field) field.classList.remove('has-error');
                    plannerTitleInput.removeAttribute('aria-invalid');
                });
                updatePlannerTitleCount();
            }
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
                var days=$('#plannerDays');
                if(!center) return;

                // 빈 국가의 DAY 편집 영역만 잠근다. 예산/시트 탭/시트 추가는 활성 상태를 유지한다.
                var locked=center.dataset.importDragActive!=='1'
                    && !findPlannerCountry($('#plannerCountry') ? $('#plannerCountry').value : '');
                center.classList.toggle('is-country-locked',locked);
                center.removeAttribute('aria-disabled');
                if(days)days.setAttribute('aria-disabled',locked?'true':'false');
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
                    plannerCityRetryAfter={};
                    schedulePlannerTripGeoStats();

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
                                color:getPlannerDayLineColor(dayNumber)
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
                            // 일반적인 지도 핀 형태. DAY 색상으로 핀/동선을 통일한다.
                            path:'M0,-18 C-10,-18 -18,-10 -18,0 C-18,12 0,30 0,30 C0,30 18,12 18,0 C18,-10 10,-18 0,-18 Z',
                            scale:.78,
                            fillColor:point.color,
                            fillOpacity:1,
                            strokeColor:'#fff',
                            strokeWeight:2,
                            anchor:new google.maps.Point(0,30),
                            labelOrigin:new google.maps.Point(0,-1)
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
                        strokeWeight:5,
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


            // === 3차 국가별 여행 시트 ===
            // 현재 시트는 기존 planner DOM을 재사용하고, 비활성 시트는 payload와 File을 보관한다.
            var plannerSheets=[];
            var plannerSheetIndex=0;

            // 각 시트의 선택 국가와 각 블록에 등록된 지도 핀을 기준으로 한 여행 규모입니다.
            // 국가는 ISO 3166 국가 코드, 대륙은 정적 분류, 도시는 Google Places 주소 구성요소를 사용합니다.
            var PLANNER_CONTINENT_BY_ISO={"GH":"아프리카","GA":"아프리카","GY":"남아메리카","GM":"아프리카","GG":"유럽","GP":"북아메리카","GT":"북아메리카","GU":"오세아니아","GD":"북아메리카","GR":"유럽","GL":"북아메리카","GN":"아프리카","GW":"아프리카","NA":"아프리카","NR":"오세아니아","NG":"아프리카","AQ":"남극","SS":"아프리카","ZA":"아프리카","NL":"유럽","BQ":"북아메리카","NP":"아시아","NO":"유럽","NF":"오세아니아","NZ":"오세아니아","NC":"오세아니아","NU":"오세아니아","NE":"아프리카","NI":"북아메리카","TW":"아시아","KR":"아시아","DK":"유럽","DM":"북아메리카","DO":"북아메리카","DE":"유럽","TL":"아시아","LA":"아시아","LR":"아프리카","LV":"유럽","RU":"유럽","LB":"아시아","LS":"아프리카","RE":"아프리카","RO":"유럽","LU":"유럽","RW":"아프리카","LY":"아프리카","LT":"유럽","LI":"유럽","MG":"아프리카","MQ":"북아메리카","MH":"오세아니아","YT":"아프리카","MO":"아시아","MW":"아프리카","MY":"아시아","ML":"아프리카","IM":"유럽","MX":"북아메리카","MC":"유럽","MA":"아프리카","MU":"아프리카","MR":"아프리카","MZ":"아프리카","ME":"유럽","MS":"북아메리카","MD":"유럽","MV":"아시아","MT":"유럽","MN":"아시아","US":"북아메리카","VI":"북아메리카","UM":"오세아니아","MM":"아시아","FM":"오세아니아","VU":"오세아니아","BH":"아시아","BB":"북아메리카","VA":"유럽","BS":"북아메리카","BD":"아시아","BM":"북아메리카","BJ":"아프리카","VE":"남아메리카","VN":"아시아","BE":"유럽","BY":"유럽","BZ":"북아메리카","BA":"유럽","BW":"아프리카","BO":"남아메리카","BI":"아프리카","BF":"아프리카","BV":"남극","BT":"아시아","MP":"오세아니아","MK":"유럽","KP":"아시아","BG":"유럽","BR":"남아메리카","BN":"아시아","WS":"오세아니아","SA":"아시아","GS":"남아메리카","SM":"유럽","ST":"아프리카","MF":"북아메리카","BL":"북아메리카","PM":"북아메리카","EH":"아프리카","SN":"아프리카","RS":"유럽","SC":"아프리카","LC":"북아메리카","VC":"북아메리카","KN":"북아메리카","SH":"아프리카","SO":"아프리카","SB":"오세아니아","SD":"아프리카","SR":"남아메리카","LK":"아시아","SJ":"유럽","SE":"유럽","CH":"유럽","ES":"유럽","SK":"유럽","SI":"유럽","SY":"아시아","SL":"아프리카","SX":"북아메리카","SG":"아시아","AE":"아시아","AW":"북아메리카","AM":"아시아","AR":"남아메리카","AS":"오세아니아","IS":"유럽","HT":"북아메리카","IE":"유럽","AZ":"아시아","AF":"아시아","AD":"유럽","AL":"유럽","DZ":"아프리카","AO":"아프리카","AG":"북아메리카","AI":"북아메리카","ER":"아프리카","SZ":"아프리카","EE":"유럽","EC":"남아메리카","ET":"아프리카","SV":"북아메리카","GB":"유럽","VG":"북아메리카","IO":"아프리카","YE":"아시아","OM":"아시아","AU":"오세아니아","AT":"유럽","HN":"북아메리카","AX":"유럽","WF":"오세아니아","JO":"아시아","UG":"아프리카","UY":"남아메리카","UZ":"아시아","UA":"유럽","IQ":"아시아","IR":"아시아","IL":"아시아","EG":"아프리카","IT":"유럽","IN":"아시아","ID":"아시아","JP":"아시아","JM":"북아메리카","ZM":"아프리카","JE":"유럽","GQ":"아프리카","GE":"아시아","CN":"아시아","CF":"아프리카","DJ":"아프리카","GI":"유럽","ZW":"아프리카","TD":"아프리카","CZ":"유럽","CL":"남아메리카","CM":"아프리카","CV":"아프리카","KZ":"아시아","QA":"아시아","KH":"아시아","CA":"북아메리카","KE":"아프리카","KY":"북아메리카","KM":"아프리카","CR":"북아메리카","CC":"오세아니아","CI":"아프리카","CO":"남아메리카","CG":"아프리카","CD":"아프리카","CU":"북아메리카","KW":"아시아","CK":"오세아니아","CW":"북아메리카","HR":"유럽","CX":"오세아니아","KG":"아시아","KI":"오세아니아","CY":"유럽","TJ":"아시아","TZ":"아프리카","TH":"아시아","TC":"북아메리카","TG":"아프리카","TK":"오세아니아","TO":"오세아니아","TM":"아시아","TV":"오세아니아","TN":"아프리카","TR":"아시아","TT":"북아메리카","PA":"북아메리카","PY":"남아메리카","PK":"아시아","PG":"오세아니아","PW":"오세아니아","PS":"아시아","FO":"유럽","PE":"남아메리카","PT":"유럽","FK":"남아메리카","PL":"유럽","PR":"북아메리카","FR":"유럽","GF":"남아메리카","TF":"남극","PF":"오세아니아","FJ":"오세아니아","FI":"유럽","PH":"아시아","PN":"오세아니아","HM":"남극","HU":"유럽","HK":"아시아"};
            var plannerCityByPoint={};
            var plannerCityLookups={};
            var plannerCityRetryAfter={};
            var plannerCityLookupQueue=[];
            var plannerCityLookupActive=0;
            var plannerTripGeoRefreshTimer=null;
            function pumpPlannerCityLookupQueue(){
                while(plannerCityLookupActive<4 && plannerCityLookupQueue.length){
                    var job=plannerCityLookupQueue.shift();
                    plannerCityLookupActive++;
                    job().finally(function(){
                        plannerCityLookupActive--;
                        pumpPlannerCityLookupQueue();
                    });
                }
            }

            // Google Places locality는 나라에 따라 도시가 아닌 '구/자치구'일 수 있습니다.
            // 도시 판정은 country + 1/2차 행정구역 + locality를 함께 보고 결정합니다.
            // 알려진 한글 도시명만 치환하며 미확인 지명은 임의 번역하지 않습니다.
            function plannerCityKey(value){
                return String(value||'').normalize('NFKC').trim().toLowerCase()
                    .replace(/[\s._'’.-]/g,'').replace(/(?:metropolis|prefecture|city|ward|district|gu|ku|区|구)$/u,'');
            }
            var PLANNER_CITY_KO_BY_COUNTRY={"JP":{"tokyo":"도쿄","osaka":"오사카","kyoto":"교토","sapporo":"삿포로","nagoya":"나고야","yokohama":"요코하마","kobe":"고베","nara":"나라","fukuoka":"후쿠오카","hiroshima":"히로시마","sendai":"센다이","nagasaki":"나가사키","naha":"나하","kanazawa":"가나자와","chiba":"지바","hachioji":"하치오지","kawasaki":"가와사키","saitama":"사이타마","kumamoto":"구마모토","hakodate":"하코다테","okinawa":"오키나와"},"US":{"newyork":"뉴욕","losangeles":"로스앤젤레스","sanfrancisco":"샌프란시스코","chicago":"시카고","washington":"워싱턴","washingtondc":"워싱턴","seattle":"시애틀","boston":"보스턴","lasvegas":"라스베이거스","honolulu":"호놀룰루","miami":"마이애미","orlando":"올랜도","sandiego":"샌디에이고","philadelphia":"필라델피아","atlanta":"애틀랜타","houston":"휴스턴","dallas":"댈러스","brooklyn":"뉴욕","queens":"뉴욕","manhattan":"뉴욕","thebronx":"뉴욕","bronx":"뉴욕","statenisland":"뉴욕"},"FR":{"paris":"파리","lyon":"리옹","marseille":"마르세유","nice":"니스","bordeaux":"보르도","toulouse":"툴루즈","strasbourg":"스트라스부르","lille":"릴"},"GB":{"london":"런던","greaterlondon":"런던","edinburgh":"에든버러","manchester":"맨체스터","birmingham":"버밍엄","liverpool":"리버풀","bristol":"브리스톨","oxford":"옥스퍼드","cambridge":"케임브리지","glasgow":"글래스고"},"IT":{"rome":"로마","roma":"로마","milan":"밀라노","milano":"밀라노","venice":"베네치아","venezia":"베네치아","florence":"피렌체","firenze":"피렌체","naples":"나폴리","napoli":"나폴리","turin":"토리노","torino":"토리노","bologna":"볼로냐","pisa":"피사"},"DE":{"berlin":"베를린","munich":"뮌헨","münchen":"뮌헨","frankfurt":"프랑크푸르트","hamburg":"함부르크","cologne":"쾰른","köln":"쾰른","düsseldorf":"뒤셀도르프","dresden":"드레스덴"},"ES":{"madrid":"마드리드","barcelona":"바르셀로나","seville":"세비야","sevilla":"세비야","valencia":"발렌시아","granada":"그라나다","malaga":"말라가","málaga":"말라가"},"PT":{"lisbon":"리스본","lisboa":"리스본","porto":"포르투"},"AT":{"vienna":"빈","wien":"빈","salzburg":"잘츠부르크"},"CH":{"zurich":"취리히","zürich":"취리히","geneva":"제네바","genève":"제네바","bern":"베른","lucerne":"루체른","luzern":"루체른"},"NL":{"amsterdam":"암스테르담","rotterdam":"로테르담","thehague":"헤이그","denhaag":"헤이그"},"BE":{"brussels":"브뤼셀","bruxelles":"브뤼셀","antwerp":"안트베르펜","antwerpen":"안트베르펜"},"CZ":{"prague":"프라하","praha":"프라하"},"HU":{"budapest":"부다페스트"},"GR":{"athens":"아테네","athina":"아테네","thessaloniki":"테살로니키"},"TR":{"istanbul":"이스탄불","i̇stanbul":"이스탄불","ankara":"앙카라","izmir":"이즈미르","i̇zmir":"이즈미르","antalya":"안탈리아","bursa":"부르사"},"KR":{"seoul":"서울","busan":"부산","incheon":"인천","dae":"대구","daejeon":"대전","gwangju":"광주","ulsan":"울산","jeju":"제주","seogwipo":"서귀포","suwon":"수원"},"CN":{"beijing":"베이징","peking":"베이징","shanghai":"상하이","chongqing":"충칭","tianjin":"톈진","guangzhou":"광저우","shenzhen":"선전","chengdu":"청두","hangzhou":"항저우","nanjing":"난징","xian":"시안","wuhan":"우한","suzhou":"쑤저우"},"TW":{"taipei":"타이베이","newtaipei":"신베이","taichung":"타이중","kaohsiung":"가오슝","tainan":"타이난","hsinchu":"신주"},"HK":{"hongkong":"홍콩","kowloon":"홍콩","hongkongisland":"홍콩"},"SG":{"singapore":"싱가포르"},"TH":{"bangkok":"방콕","krungthepmahanakhon":"방콕","chiangmai":"치앙마이","phuket":"푸껫","pattaya":"파타야","krabi":"끄라비"},"VN":{"hanoi":"하노이","hochiminh":"호찌민","danang":"다낭","nhatrang":"냐짱","hue":"후에","hộian":"호이안","hoian":"호이안"},"ID":{"jakarta":"자카르타","bali":"발리","denpasar":"덴파사르","surabaya":"수라바야","bandung":"반둥","yogyakarta":"욕야카르타"},"MY":{"kualalumpur":"쿠알라룸푸르","georgetown":"조지타운","penang":"페낭","johorbahru":"조호르바루","malacca":"믈라카","melaka":"믈라카"},"PH":{"manila":"마닐라","quezon":"케손시티","cebu":"세부","davao":"다바오","makati":"마카티"},"IN":{"delhi":"델리","newdelhi":"뉴델리","mumbai":"뭄바이","bengaluru":"벵갈루루","bangalore":"벵갈루루","chennai":"첸나이","kolkata":"콜카타","jaipur":"자이푸르","agra":"아그라","varanasi":"바라나시"},"AE":{"dubai":"두바이","abudhabi":"아부다비","sharjah":"샤르자"},"IL":{"jerusalem":"예루살렘","telaviv":"텔아비브"},"SA":{"riyadh":"리야드","jeddah":"제다","mecca":"메카","makkah":"메카"},"EG":{"cairo":"카이로","giza":"기자","luxor":"룩소르","alexandria":"알렉산드리아"},"AU":{"sydney":"시드니","melbourne":"멜버른","brisbane":"브리즈번","perth":"퍼스","adelaide":"애들레이드","canberra":"캔버라","goldcoast":"골드코스트"},"NZ":{"auckland":"오클랜드","wellington":"웰링턴","christchurch":"크라이스트처치","queenstown":"퀸스타운"},"CA":{"toronto":"토론토","vancouver":"밴쿠버","montreal":"몬트리올","montréal":"몬트리올","ottawa":"오타와","calgary":"캘거리","quebec":"퀘벡"},"MX":{"mexico":"멕시코시티","ciudaddeméxico":"멕시코시티","cancun":"칸쿤","cancún":"칸쿤","guadalajara":"과달라하라","monterrey":"몬테레이"},"BR":{"riodejaneiro":"리우데자네이루","sãopaulo":"상파울루","saopaulo":"상파울루","brasília":"브라질리아","brasilia":"브라질리아","salvador":"사우바도르"},"AR":{"buenosaires":"부에노스아이레스","córdoba":"코르도바","cordoba":"코르도바"},"PE":{"lima":"리마","cusco":"쿠스코","cuzco":"쿠스코"},"CL":{"santiago":"산티아고","valparaíso":"발파라이소"},"ZA":{"capetown":"케이프타운","johannesburg":"요하네스버그","durban":"더반","pretoria":"프리토리아"},"MA":{"marrakesh":"마라케시","marrakech":"마라케시","casablanca":"카사블랑카","rabat":"라바트","fez":"페스","fès":"페스"},"KE":{"nairobi":"나이로비","mombasa":"몸바사"}};
            var PLANNER_METRO_CITY_RULES=[{"code":"JP","names":["Tokyo","Tokyo Metropolis","東京都","도쿄도","도쿄"],"city":"도쿄","mode":"tokyo"},{"code":"KR","names":["Seoul","서울특별시","서울"],"city":"서울","mode":"district"},{"code":"KR","names":["Busan","부산광역시","부산"],"city":"부산","mode":"district"},{"code":"KR","names":["Incheon","인천광역시","인천"],"city":"인천","mode":"district"},{"code":"KR","names":["Daegu","대구광역시","대구"],"city":"대구","mode":"district"},{"code":"KR","names":["Daejeon","대전광역시","대전"],"city":"대전","mode":"district"},{"code":"KR","names":["Gwangju","광주광역시","광주"],"city":"광주","mode":"district"},{"code":"KR","names":["Ulsan","울산광역시","울산"],"city":"울산","mode":"district"},{"code":"GB","names":["Greater London","London","런던"],"city":"런던","mode":"london"},{"code":"FR","names":["Paris","파리"],"city":"파리","mode":"paris"},{"code":"US","names":["New York City","NYC","뉴욕"],"city":"뉴욕","mode":"nyc"},{"code":"CN","names":["Beijing","北京市","베이징"],"city":"베이징","mode":"district"},{"code":"CN","names":["Shanghai","上海市","상하이"],"city":"상하이","mode":"district"},{"code":"CN","names":["Chongqing","重庆市","충칭"],"city":"충칭","mode":"district"},{"code":"CN","names":["Tianjin","天津市","톈진"],"city":"톈진","mode":"district"},{"code":"TW","names":["Taipei City","Taipei","臺北市","台北市","타이베이"],"city":"타이베이","mode":"district"},{"code":"TW","names":["New Taipei City","新北市","신베이"],"city":"신베이","mode":"district"},{"code":"TW","names":["Kaohsiung City","高雄市","가오슝"],"city":"가오슝","mode":"district"},{"code":"TH","names":["Bangkok","Krung Thep Maha Nakhon","กรุงเทพมหานคร","방콕"],"city":"방콕","mode":"bangkok"},{"code":"TR","names":["Istanbul","İstanbul","이스탄불"],"city":"이스탄불","mode":"district"},{"code":"MX","names":["Mexico City","Ciudad de México","CDMX","멕시코시티"],"city":"멕시코시티","mode":"district"},{"code":"IN","names":["Delhi","National Capital Territory of Delhi","델리"],"city":"델리","mode":"district"},{"code":"ID","names":["Jakarta","DKI Jakarta","자카르타"],"city":"자카르타","mode":"district"},{"code":"SG","names":["Singapore","싱가포르"],"city":"싱가포르","mode":"always"},{"code":"HK","names":["Hong Kong","홍콩"],"city":"홍콩","mode":"always"}];
            var PLANNER_TOKYO_WARDS=new Set('adachi arakawa bunkyo chiyoda chuo edogawa itabashi katsushika kita koto meguro minato nakano nerima ota setagaya shibuya shinagawa shinjuku suginami sumida taito toshima 아다치 아라카와 분쿄 지요다 주오 에도가와 이타바시 가쓰시카 기타 고토 메구로 미나토 나카노 네리마 오타 세타가야 시부야 시나가와 신주쿠 스기나미 스미다 다이토 도시마 足立 荒川 文京 千代田 中央 江戸川 板橋 葛飾 北 江東 目黒 港 中野 練馬 大田 世田谷 渋谷 品川 新宿 杉並 墨田 台東 豊島'.split(' '));
            var PLANNER_NYC_BOROUGHS=new Set(['brooklyn','queens','bronx','thebronx','manhattan','statenisland']);
            function plannerMetroCity(code,region1,region2,locality){
                code=String(code||'').toUpperCase();
                var cityKey=plannerCityKey(locality);
                for(var i=0;i<PLANNER_METRO_CITY_RULES.length;i++){
                    var rule=PLANNER_METRO_CITY_RULES[i];
                    if(rule.code!==code)continue;
                    var inRegion=rule.names.some(function(name){
                        var key=plannerCityKey(name);
                        return key===plannerCityKey(region1) || key===plannerCityKey(region2);
                    });
                    if(rule.mode==='always')return rule.city;
                    if(!inRegion)continue;
                    if(rule.mode==='tokyo'){
                        if(PLANNER_TOKYO_WARDS.has(cityKey))return rule.city;
                    }else if(rule.mode==='nyc'){
                        if(PLANNER_NYC_BOROUGHS.has(cityKey))return rule.city;
                    }else if(rule.mode==='paris'){
                        if(/(?:arrondissement|아롱디스망|구$)/i.test(locality||''))return rule.city;
                    }else if(rule.mode==='london'){
                        // Greater London 내의 구는 여행 도시명을 런던으로 통일합니다.
                        return rule.city;
                    }else if(rule.mode==='bangkok'){
                        return rule.city;
                    }else if(rule.mode==='district'){
                        // 특별시/직할시 내부의 작은 행정 단위는 광역 도시로 합칩니다.
                        return rule.city;
                    }
                }
                return '';
            }
            function plannerCanonicalCity(name,countryCode,region1,region2,address){
                var raw=String(name||'').trim();
                var code=String(countryCode||'').toUpperCase();
                var metro=plannerMetroCity(code,region1,region2,raw);
                if(metro)return metro;
                if(!raw)return '';
                // 예전 데이터에는 광역행정구역이 없으므로 저장된 장소 주소를 사용합니다.
                var addr=String(address||'').toLowerCase();
                var key=plannerCityKey(raw);
                if(code==='JP' && PLANNER_TOKYO_WARDS.has(key)
                    && (/tokyo|도쿄|東京都|東京/.test(addr)
                        || key==='minato' && /minato\s+city/i.test(raw)))return '도쿄';
                if(code==='US' && PLANNER_NYC_BOROUGHS.has(key))return '뉴욕';
                if(code==='GB' && /london|런던/.test(addr))return '런던';
                if(code==='FR' && /paris|파리/.test(addr)
                    && /arrondissement|아롱디스망/.test(raw.toLowerCase()))return '파리';
                // 광역시의 '구/자치구'가 도시로 오인되면 주소의 실제 상위 도시를 사용합니다.
                if(/(?:district|ward|구|区|-gu|\s+gu)$/iu.test(raw)){
                    for(var i=0;i<PLANNER_METRO_CITY_RULES.length;i++){
                        var rule=PLANNER_METRO_CITY_RULES[i];
                        if(code!==rule.code || rule.mode==='tokyo' || rule.mode==='nyc')continue;
                        if(rule.names.some(function(name){
                            return name.length>2 && addr.includes(name.toLowerCase());
                        }))return rule.city;
                    }
                }
                var aliases=PLANNER_CITY_KO_BY_COUNTRY[code]||{};
                return aliases[key]||raw;
            }
            function plannerAddressPart(parts,type){
                return parts.find(function(part){
                    return part && Array.isArray(part.types) && part.types.indexOf(type)!==-1;
                });
            }
            // 여행 카드의 지역 단위는 도시(locality)가 아니라 국가의 1차 행정구역이다.
            // 기존 지역 선택 API(ISO 3166-2 + CLDR ko + 수동 보정)와 동일한 한국어 정규명을 사용한다.
            function plannerAdmin1Key(value){
                return String(value||'').normalize('NFKD').replace(/[\u0300-\u036f]/g,'')
                    .toLocaleLowerCase('en').replace(/[^a-z0-9\uac00-\ud7a3\u3040-\u30ff\u4e00-\u9fff]/g,'');
            }
            function plannerAdmin1Display(name,code){
                var text=String(name||'').trim();
                // 카드에서는 Tokyo-to/도쿄도를 일반 여행지 명칭 '도쿄'로 표시한다.
                // 다른 국가의 행정구역 명칭은 표준 CLDR 한글 표기를 유지한다.
                if(code==='JP')return text==='홋카이도' ? text : text.replace(/(?:도|부|현)$/,'');
                if(code==='KR')return text.replace(/(?:특별자치시|특별시|광역시|특별자치도)$/,'');
                return text;
            }
            function plannerMatchAdmin1(rows,code,longName,shortName){
                if(!rows || !rows.length)return '';
                var longKey=plannerAdmin1Key(longName).replace(/(?:prefecture|province|state|region|metropolis)$/,'');
                var shortKey=plannerAdmin1Key(shortName);
                for(var i=0;i<rows.length;i++){
                    var row=rows[i];
                    var aliases=[row.code, row.nameEn, row.name, plannerAdmin1Display(row.name,code)];
                    if(row.code)aliases.push(String(row.code).split('-').slice(1).join('-'));
                    if(row.nameEn)aliases.push(String(row.nameEn).replace(/(?:\s+prefecture|\s+province|\s+state|\s+region|\s+metropolis)$/i,''));
                    if(code==='KR' && row.nameEn)aliases.push(String(row.nameEn).replace(/-(?:teukbyeoljachido|teukbyeoljachisi|teukbyeolsi|gwangyeoksi|do)$/i,''));
                    if(code==='JP' && row.nameEn){
                        if(/도$/.test(row.name)&&row.name!=='홋카이도')aliases.push(row.nameEn+'-to');
                        if(/부$/.test(row.name))aliases.push(row.nameEn+'-fu');
                        if(/현$/.test(row.name))aliases.push(row.nameEn+'-ken');
                    }
                    if(row.nameEn)aliases.push(String(row.nameEn).replace(/(?:\s+metropolitan\s+city|\s+city)$/i,''));
                    if(aliases.some(function(alias){var key=plannerAdmin1Key(alias);return key && (key===longKey||key===shortKey);})){
                        return /[가-힣]/.test(row.name||'') ? plannerAdmin1Display(row.name,code) : '';
                    }
                }
                return '';
            }
            function plannerSavedAdmin1Korean(name,code){
                var rows=plannerAdmin1Cache[String(code||'').toUpperCase()]||[];
                return plannerMatchAdmin1(rows,String(code||'').toUpperCase(),name,name);
            }
            function plannerFirstAdmin1Korean(parts){
                if(!Array.isArray(parts))return Promise.resolve('');
                var country=plannerAddressPart(parts,'country');
                var area=plannerAddressPart(parts,'administrative_area_level_1');
                var code=String(country&&(country.shortText||country.short_name)||'').toUpperCase();
                if(!code || !area)return Promise.resolve('');
                var longName=area.longText||area.long_name||'';
                var shortName=area.shortText||area.short_name||'';
                return getPlannerAdmin1Regions(code).then(function(rows){
                    var value=plannerMatchAdmin1(rows,code,longName,shortName);
                    if(!value && /[가-힣]/.test(longName)){
                        // Google이 한글로 응답했더라도 검증된 ISO 목록에 없는 이름은
                        // 임의의 행정구역으로 인정하지 않는다.
                        console.warn('[Triply] 1차 행정구역 대조 실패',code,longName,shortName);
                    }
                    if(!value && !/[가-힣]/.test(longName)){
                        console.warn('[Triply] 한글 1차 행정구역 미확인',code,longName,shortName);
                    }
                    return value;
                }).catch(function(error){
                    console.warn('[Triply] 한글 행정구역 목록 조회 실패',error);
                    return '';
                });
            }

            function plannerCityFromAddressParts(parts){
                if(!Array.isArray(parts))return '';
                function partName(part){return String(part && (part.longText||part.long_name||part.shortText||part.short_name)||'').trim();}
                var country=plannerAddressPart(parts,'country');
                var code=String(country&&(country.shortText||country.short_name)||'').toUpperCase();
                var region1=partName(plannerAddressPart(parts,'administrative_area_level_1'));
                var region2=partName(plannerAddressPart(parts,'administrative_area_level_2'));
                var locality=partName(plannerAddressPart(parts,'locality'));
                var town=partName(plannerAddressPart(parts,'postal_town'));
                // postal_town은 우편 주소상의 도시가 될 수 있으며 London 등에서 locality보다 정확합니다.
                var main=(code==='GB' && town) ? town : (locality || town);
                // 일본의 보통 '시(市)' 아래 구가 locality로 반환되는 경우:
                // Osaka/Naniwa Ward -> Osaka, Kyoto/Nakagyo Ward -> Kyoto.
                if(code==='JP' && main && /(?:ward|区|구|[- ]ku)$/iu.test(main) && region2){
                    var parentCity=region2.replace(/(?:city|市|[- ]shi)$/iu,'').trim();
                    if(parentCity)return plannerCanonicalCity(parentCity,code,region1,region2);
                }
                var metro=plannerMetroCity(code,region1,region2,main);
                if(metro)return metro;
                if(main)return plannerCanonicalCity(main,code,region1,region2);
                // locality 미제공 국가도 시/군 단위 행정명까지 순차 확인합니다.
                var fallback=partName(plannerAddressPart(parts,'administrative_area_level_3'))
                    || region2 || partName(plannerAddressPart(parts,'sublocality_level_1'));
                if(fallback)return plannerCanonicalCity(fallback,code,region1,region2);
                // 국가 자체가 도시(싱가포르/홍콩)인 경우에만 국가명으로 정규화합니다.
                return plannerMetroCity(code,region1,region2,'');
            }

            function plannerCityPointId(point){
                if(!point)return '';
                var placeId=String(point.googlePlaceId||'').trim();
                if(placeId)return 'place:'+placeId;
                var lat=Number(point.placeLat!=null?point.placeLat:point.lat);
                var lng=Number(point.placeLng!=null?point.placeLng:point.lng);
                if(!isFinite(lat)||!isFinite(lng))return '';
                return 'geo:'+lat.toFixed(6)+','+lng.toFixed(6);
            }

            // Google API가 응답하기 전에는 미확인 도시를 임의로 세지 않습니다.
            function resolvePlannerPinCity(point){
                var id=plannerCityPointId(point);
                if(!id || Object.prototype.hasOwnProperty.call(plannerCityByPoint,id)
                        || plannerCityLookups[id]
                        || Date.now()<(plannerCityRetryAfter[id]||0))return;
                var placeId=String(point.googlePlaceId||'').trim();
                // 중복 요청을 막고, API 호출은 동시 최대 4개로 제한합니다.
                plannerCityLookups[id]=true;
                plannerCityLookupQueue.push(function(){
                    var pending;
                    if(placeId){
                        pending=getPlannerPlacesLibrary().then(function(placesLib){
                            var place=new placesLib.Place({id:placeId});
                            return place.fetchFields({fields:['addressComponents']}).then(function(){
                                return plannerFirstAdmin1Korean(place.addressComponents);
                            });
                        });
                    }else if(window.google && google.maps && google.maps.Geocoder){
                        var geocoder=new google.maps.Geocoder();
                        pending=geocoder.geocode({location:{
                            lat:Number(point.placeLat!=null?point.placeLat:point.lat),
                            lng:Number(point.placeLng!=null?point.placeLng:point.lng)
                        }}).then(function(reply){
                            var results=reply&&reply.results||[];
                            // 역지오코딩 결과에는 건물/거리부터 국가까지 다양한 단계가 있다.
                            // 동일한 위치의 1차 행정구역을 첫 번째 확인된 응답에서 사용한다.
                            var first=results.find(function(item){
                                return Array.isArray(item.address_components)
                                    && !!plannerAddressPart(item.address_components,'administrative_area_level_1');
                            });
                            return first ? plannerFirstAdmin1Korean(first.address_components) : '';
                        });
                    }else pending=Promise.reject(new Error('Google Maps API not ready'));
                    return pending.then(function(city){
                        plannerCityByPoint[id]=String(city||'').trim();
                        delete plannerCityRetryAfter[id];
                    }).catch(function(){
                        // API 오류 후 1분간 재시도를 제한해 무한 요청을 방지합니다.
                        plannerCityRetryAfter[id]=Date.now()+60000;
                    }).finally(function(){
                        delete plannerCityLookups[id];
                        schedulePlannerTripGeoStats();
                    });
                });
                pumpPlannerCityLookupQueue();
            }

            function updatePlannerTripGeoStats(){
                var continentEl=$('#plannerTripContinentCount');
                var countryEl=$('#plannerTripCountryCount');
                var cityEl=$('#plannerTripCityCount');
                if(!continentEl || !countryEl || !cityEl || !plannerSheets || !plannerSheets.length)return;
                var countries=new Set(),continents=new Set(),cities=new Set();
                var waiting=false;
                // 대한민국만 방문하는 국내 일정에서는 한국을 방문국으로 유지한다.
                // 다른 나라가 있을 때만 첫/마지막 한국 시트를 출발·귀국 기록으로 제외.
                var hasForeignDestination=plannerSheets.some(function(sheet,index){
                    var payload=index===plannerSheetIndex?collectPlannerPayload():sheet.payload;
                    var matched=findPlannerCountry(payload&&payload.country||'');
                    return matched && matched.code && matched.code!=='KR';
                });
                plannerSheets.forEach(function(sheet,index){
                    var payload=index===plannerSheetIndex?collectPlannerPayload():sheet.payload;
                    if(!payload)return;
                    var country=findPlannerCountry(payload.country||'');
                    var code=country?String(country.code||'').toUpperCase():'';
                    // 출국/귀국을 위한 맨 앞·맨 뒤 대한민국 시트는 여행 지역에서 제외.
                    // 중간에 배치된 대한민국 시트는 실제 방문지로 집계한다.
                    if(hasForeignDestination && code==='KR' && (index===0 || index===plannerSheets.length-1))return;
                    if(code){
                        countries.add(code);
                        if(PLANNER_CONTINENT_BY_ISO[code])continents.add(PLANNER_CONTINENT_BY_ISO[code]);
                    }
                    (payload.days||[]).forEach(function(day){
                        (day.blocks||[]).forEach(function(block){
                            var id=plannerCityPointId(block);
                            if(!id || !code)return;
                            var city=plannerSavedAdmin1Korean(plannerCityByPoint[id]||block.placeCity||'',code);
                            if(city){
                                plannerCityByPoint[id]=city;
                                cities.add(code+':'+city.normalize('NFKC').toLocaleLowerCase());
                            }else if(!Object.prototype.hasOwnProperty.call(plannerCityByPoint,id)){
                                if(Date.now()>=(plannerCityRetryAfter[id]||0))waiting=true;
                                resolvePlannerPinCity(block);
                            }
                        });
                    });
                });
                continentEl.textContent=continents.size+'개 대륙';
                countryEl.textContent=countries.size+'개 국가';
                cityEl.textContent=cities.size+'개 도시';
                cityEl.title=waiting?'지도에 등록된 핀의 도시 정보를 확인하는 중입니다.':'지도에 등록된 핀 기준 · 중복 도시 제외';
            }

            function schedulePlannerTripGeoStats(){
                if(plannerTripGeoRefreshTimer!==null)clearTimeout(plannerTripGeoRefreshTimer);
                plannerTripGeoRefreshTimer=setTimeout(function(){
                    plannerTripGeoRefreshTimer=null;
                    updatePlannerTripGeoStats();
                },50);
            }

            // 블록 추가/삭제, 국가 변경, 시트 이동 후에도 현재 통계가 갱신되도록 합니다.
            var plannerGeoStatsObserver=null;
            function initPlannerGeoStats(){
                getPlannerRegionCatalog().then(function(){
                    schedulePlannerTripGeoStats();
                }).catch(function(){ /* 다음 장소 선택 및 재조회 시 다시 시도 */ });
                var root=$('#plannerDays');
                if(root && window.MutationObserver){
                    plannerGeoStatsObserver=new MutationObserver(schedulePlannerTripGeoStats);
                    plannerGeoStatsObserver.observe(root,{childList:true,subtree:true});
                }
                document.addEventListener('change',function(event){
                    if(event.target && event.target.closest && event.target.closest('#plannerCenterPanel')){
                        schedulePlannerTripGeoStats();
                    }
                });
                schedulePlannerTripGeoStats();
            }

            // 비어 있는 시트의 임시 명칭: B..Z, BB..BZ, CB..CZ ...
            // A 및 AA/BA/CA처럼 A로 끝나는 명칭은 사용하지 않는다.
            // 국가를 지정한 시트는 임시 명칭을 점유하지 않아 재사용할 수 있다.
            var PLANNER_SHEET_LIMIT=99;

            function plannerPlaceholderAt(index){
                if(index<0 || index>=PLANNER_SHEET_LIMIT) return null;
                if(index<25) return 'plan'+String.fromCharCode(66+index);
                var remaining=index-25;
                return 'plan'+String.fromCharCode(66+Math.floor(remaining/25))
                    +String.fromCharCode(66+(remaining%25));
            }

            function plannerSheetHasCountry(sheet){
                return !!(sheet && sheet.payload && String(sheet.payload.country||'').trim());
            }

            function reconcilePlannerSheetPlaceholders(){
                var used=new Set();
                // 이미 사용 중인 빈 시트의 이름은 그대로 유지한다.
                // 이전 버전의 '국가 선택' 등 잘못된 이름/중복 이름만 교체한다.
                plannerSheets.forEach(function(sheet){
                    if(plannerSheetHasCountry(sheet)) return;
                    var placeholder=sheet.placeholder;
                    var valid=false;
                    for(var i=0;i<PLANNER_SHEET_LIMIT;i++){
                        if(plannerPlaceholderAt(i)===placeholder){valid=true;break;}
                    }
                    if(!valid || used.has(placeholder)){
                        for(var j=0;j<PLANNER_SHEET_LIMIT;j++){
                            var candidate=plannerPlaceholderAt(j);
                            if(!used.has(candidate)){
                                placeholder=candidate;
                                break;
                            }
                        }
                    }
                    sheet.placeholder=placeholder;
                    used.add(placeholder);
                });
            }

            function nextPlannerSheetPlaceholder(){
                reconcilePlannerSheetPlaceholders();
                var used=new Set();
                plannerSheets.forEach(function(sheet){
                    if(!plannerSheetHasCountry(sheet)) used.add(sheet.placeholder);
                });
                for(var i=0;i<PLANNER_SHEET_LIMIT;i++){
                    var candidate=plannerPlaceholderAt(i);
                    if(!used.has(candidate)) return candidate;
                }
                return null;
            }
            var plannerSheetSwitching=false;
            var plannerSheetDragged=-1;

            function plannerSheetAmount(payload){
                var total=0;
                var travelers=Math.max(1,Number(payload && payload.travelerCount)||1);
                (payload && payload.days || []).forEach(function(day){
                    (day.blocks || []).forEach(function(block){
                        var amount=Math.max(0,Number(block.cost)||0);
                        total+=block.costType==='PER_PERSON' ? amount*travelers : amount;
                    });
                });
                return total;
            }

            function capturePlannerSheet(){
                if(!plannerSheets.length || plannerSheetSwitching) return;
                var sheet=plannerSheets[plannerSheetIndex];
                sheet.payload=collectPlannerPayload();
                sheet.files=collectDraftFiles(); // 브라우저 File 객체를 보존한다.
            }

            function plannerSheetName(sheet,index){
                var country=sheet && sheet.payload && sheet.payload.country;
                return country && String(country).trim() ? String(country).trim()
                    : (sheet.placeholder||'planB');
            }

            // 국가 자동완성은 input/change 이벤트를 발생시키지 않고 값을 대입하므로
            // 선택 즉시 활성 시트의 명칭과 국가 데이터를 동기화한다.
            function syncPlannerActiveSheetCountry(){
                if(!plannerSheets.length || plannerSheetSwitching) return;
                var input=$('#plannerCountry');
                if(!input)return;
                plannerSheets[plannerSheetIndex].payload.country=input.value;
                renderPlannerSheets();
                schedulePlannerTripGeoStats();
            }

            function updatePlannerSheetArrows(){
                var scroller=$('#plannerSheetScroller');
                var prev=$('#plannerSheetPrev'),next=$('#plannerSheetNext');
                if(!scroller)return;
                var max=Math.max(0,scroller.scrollWidth-scroller.clientWidth);
                if(prev)prev.disabled=scroller.scrollLeft<=1;
                if(next)next.disabled=scroller.scrollLeft>=max-1;
            }

            // 3개 시트를 한 번에 더 보여주고, 각 시트의 실제 좌우 끝에 정렬한다.
            // 마지막에는 + 버튼까지 완전히 보이도록 스크롤 끝으로 이동한다.
            function scrollPlannerSheets(direction){
                var scroller=$('#plannerSheetScroller');
                if(!scroller)return;
                var rect=scroller.getBoundingClientRect();
                var left=scroller.scrollLeft, right=left+scroller.clientWidth;
                var buttons=$$('.planner-sheet-tab',scroller);
                var positions=buttons.map(function(button){
                    var b=button.getBoundingClientRect();
                    return {start:b.left-rect.left+left,end:b.right-rect.left+left};
                });
                var max=Math.max(0,scroller.scrollWidth-scroller.clientWidth);
                var target=left;
                if(direction>0){
                    var first=positions.findIndex(function(p){return p.end>right+1;});
                    if(first===-1){target=max;}
                    else{
                        var last=Math.min(positions.length-1,first+2);
                        target=last===positions.length-1?max:positions[last].end-scroller.clientWidth;
                    }
                }else{
                    var before=-1;
                    for(var i=positions.length-1;i>=0;i--){
                        if(positions[i].start<left-1){before=i;break;}
                    }
                    target=before<0?0:positions[Math.max(0,before-2)].start;
                }
                scroller.scrollTo({left:Math.max(0,Math.min(max,target)),behavior:'smooth'});
            }

            function revealPlannerSheet(index,includeAdd){
                var scroller=$('#plannerSheetScroller');
                if(!scroller)return;
                var button=$$('.planner-sheet-tab',scroller)[index];
                if(!button)return;
                var rect=scroller.getBoundingClientRect();
                var current=scroller.scrollLeft;
                var box=button.getBoundingClientRect();
                var start=box.left-rect.left+current;
                var end=box.right-rect.left+current;
                var target=current;
                if(includeAdd){target=scroller.scrollWidth-scroller.clientWidth;}
                else if(start<current){target=start;}
                else if(end>current+scroller.clientWidth){target=end-scroller.clientWidth;}
                if(target!==current)scroller.scrollTo({left:Math.max(0,target),behavior:'smooth'});
            }

            function renderPlannerSheets(){
                var tabs=$('#plannerSheetTabs');if(!tabs)return;
                reconcilePlannerSheetPlaceholders();
                tabs.innerHTML='';
                plannerSheets.forEach(function(sheet,index){
                    var itemWrap=document.createElement('div');
                    itemWrap.className='planner-sheet-item';
                    var button=document.createElement('button');
                    button.type='button';button.className='planner-sheet-tab';
                    button.draggable=true;button.dataset.sheetIndex=String(index);
                    button.setAttribute('role','tab');
                    button.setAttribute('aria-selected',index===plannerSheetIndex?'true':'false');
                    button.setAttribute('aria-label',plannerSheetName(sheet,index)+' 시트');
                    var label=document.createElement('span');
                    label.className='planner-sheet-tab-label';
                    label.textContent=plannerSheetName(sheet,index);
                    button.appendChild(label);
                    itemWrap.appendChild(button);
                    if(plannerSheets.length){
                        var remove=document.createElement('button');
                        remove.type='button';
                        remove.className='planner-sheet-remove';
                        remove.setAttribute('aria-label',plannerSheetName(sheet,index)+' 시트 삭제');
                        remove.title='시트 삭제';
                        remove.textContent='×';
                        remove.draggable=false;
                        remove.addEventListener('click',function(event){
                            event.preventDefault();event.stopPropagation();deletePlannerSheet(index);
                        });
                        remove.addEventListener('mousedown',function(event){event.stopPropagation();});
                        itemWrap.appendChild(remove);
                    }
                    button.addEventListener('click',function(){switchPlannerSheet(index);});
                    button.addEventListener('dragstart',function(e){
                        plannerSheetDragged=index;
                        if(e.dataTransfer){e.dataTransfer.effectAllowed='move';e.dataTransfer.setData('text/plain','sheet-'+index);}
                        e.stopPropagation();
                    });
                    button.addEventListener('dragover',function(e){e.preventDefault();button.classList.add('is-drag-over');e.stopPropagation();});
                    button.addEventListener('dragleave',function(){button.classList.remove('is-drag-over');});
                    button.addEventListener('drop',function(e){
                        e.preventDefault();e.stopPropagation();button.classList.remove('is-drag-over');
                        if(plannerSheetDragged<0 || plannerSheetDragged===index)return;
                        capturePlannerSheet();
                        var activeItem=plannerSheets[plannerSheetIndex];
                        var item=plannerSheets.splice(plannerSheetDragged,1)[0];
                        plannerSheets.splice(index,0,item);
                        plannerSheetIndex=plannerSheets.indexOf(activeItem);
                        plannerSheetDragged=-1;renderPlannerSheets();
                        revealPlannerSheet(plannerSheetIndex,false);
                        syncBudget();markDirty();
                    });
                    button.addEventListener('dragend',function(){plannerSheetDragged=-1;button.classList.remove('is-drag-over');});
                    tabs.appendChild(itemWrap);
                });
                updatePlannerSheetArrows();
            }

            function sheetDateAfter(value){
                if(!value || !/^\d{4}-\d{2}-\d{2}$/.test(value)) return '';
                var date=new Date(value+'T12:00:00Z');
                if(!isFinite(date.getTime())) return '';
                date.setUTCDate(date.getUTCDate()+1);
                return date.toISOString().slice(0,10);
            }

            function switchPlannerSheet(index){
                if(index<0||index>=plannerSheets.length||plannerSheetSwitching)return;
                if(index===plannerSheetIndex){renderPlannerSheets();return;}
                capturePlannerSheet();
                var active=plannerSheets[plannerSheetIndex].payload||{};
                var shared={title:$('#tripTitle')?$('#tripTitle').value:'',
                    summary:plannerPublishState.summary,visibility:visibility.dataset.visibility};
                plannerSheetIndex=index;
                plannerSheetSwitching=true;
                try{
                    var target=plannerSheets[index];
                    var p=Object.assign({},target.payload||{},shared);
                    applyPlannerDraftPayload(p,target.files||[]);
                    plannerPublishState.summary=shared.summary;
                    if($('#plannerPublishSummary'))$('#plannerPublishSummary').value=shared.summary||'';
                    if($('#tripTitle'))$('#tripTitle').value=shared.title;
                    updatePlannerTitleCount();
                    setPlannerVisibility(shared.visibility,false);
                    target.payload=p;
                }finally{plannerSheetSwitching=false;}
                renderPlannerSheets();
                revealPlannerSheet(index,false);
                schedulePlannerTripGeoStats();
                syncCountryLock();
                syncBudget();
                if(typeof filterPlans==='function')filterPlans();
                if(typeof centerMapOnPlannerCountry==='function' && $('#plannerCountry') && $('#plannerCountry').value){
                    centerMapOnPlannerCountry($('#plannerCountry').value);
                }
                markDirty();
            }

            function deletePlannerSheet(index){
                if(index<0||index>=plannerSheets.length)return;
                capturePlannerSheet();
                var sheet=plannerSheets[index];
                var days=(sheet.payload&&sheet.payload.days)||[];
                var blocks=days.reduce(function(sum,day){return sum+(day.blocks||[]).length;},0);
                var label=plannerSheetName(sheet,index);
                var message='“'+label+'” 시트를 삭제하시겠습니까?';
                if(days.length || blocks || (sheet.files||[]).length){
                    message+=' 이 시트의 DAY '+days.length+'개, 일정 '+blocks+'개와 사진도 함께 삭제됩니다.';
                }
                if(plannerSheets.length===1){
                    message+=' 삭제 후에는 제목과 소개 등 작성 내용이 초기화된 빈 planB 시트가 생성됩니다.';
                }
                openDeleteModal({title:'시트 삭제',message:message},function(){
                    var oldActive=plannerSheets[plannerSheetIndex];
                    plannerSheets.splice(index,1);
                    var deletedLastSheet=plannerSheets.length===0;
                    if(deletedLastSheet){
                        // 마지막 1개를 지웠다면 신규 작성 페이지의 완전한 빈 상태로 다시 시작합니다.
                        // 기존 itinerary는 서버에 '최종 저장'하기 전까지 삭제되지 않습니다.
                        plannerSheetIndex=0;
                        var emptyPayload={title:'',summary:'',visibility:'PUBLIC',country:'',city:null,
                            travelerCount:1,startDate:null,endDate:null,days:[],thumbnailImg:null};
                        plannerSheets=[{placeholder:'planB',first:true,payload:emptyPayload,files:[]}];
                    }
                    // 제거된 시트의 사진을 대표 이미지로 참조하는 일이 없도록 다시 선택하게 합니다.
                    plannerPublishState.imageKey='';
                    plannerPublishState.thumbnailUrl='';
                    if(typeof plannerPublishPlacePhotoLoadToken!=='undefined')plannerPublishPlacePhotoLoadToken++;
                    (sheet.files||[]).forEach(function(record){
                        if(record.previewUrl && /^blob:/.test(record.previewUrl)){
                            try{URL.revokeObjectURL(record.previewUrl);}catch(e){}
                        }
                    });
                    if(deletedLastSheet){
                        plannerSheetSwitching=true;
                        try{
                            applyPlannerDraftPayload(plannerSheets[0].payload,[]);
                        }finally{plannerSheetSwitching=false;}
                        // 나라와 핀이 없는 처음 화면의 지도 위치를 복원합니다.
                        if(map && typeof map.setCenter==='function'){
                            map.setCenter({lat:37.5665,lng:126.9780});
                            if(typeof map.setZoom==='function')map.setZoom(11);
                        }
                        if(typeof filterPlans==='function')filterPlans();
                    }else if(oldActive===sheet){
                        plannerSheetIndex=Math.min(index,plannerSheets.length-1);
                        var next=plannerSheets[plannerSheetIndex];
                        var shared={title:$('#tripTitle')?$('#tripTitle').value:'',
                            summary:plannerPublishState.summary,
                            visibility:visibility.dataset.visibility};
                        plannerSheetSwitching=true;
                        try{
                            applyPlannerDraftPayload(Object.assign({},next.payload||{},shared),next.files||[]);
                            next.payload=Object.assign({},next.payload,shared);
                        }finally{plannerSheetSwitching=false;}
                        syncCountryLock();
                        if(typeof filterPlans==='function')filterPlans();
                        if(typeof centerMapOnPlannerCountry==='function' && $('#plannerCountry') && $('#plannerCountry').value){
                            centerMapOnPlannerCountry($('#plannerCountry').value);
                        }
                    }else{
                        plannerSheetIndex=plannerSheets.indexOf(oldActive);
                    }
                    renderPlannerSheets();
                    revealPlannerSheet(plannerSheetIndex,false);
                    syncBudget();
                    schedulePlannerTripGeoStats();
                    markDirty();
                });
            }

            function addPlannerSheet(){
                if(plannerSheets.length>=PLANNER_SHEET_LIMIT){
                    showRequiredFieldsModal(['시트는 최대 99개까지 만들 수 있습니다.'],'시트 추가 불가');return;
                }
                capturePlannerSheet();
                var previous=plannerSheets[plannerSheetIndex].payload||{};
                var start=sheetDateAfter(previous.endDate);
                var placeholder=nextPlannerSheetPlaceholder();
                var payload={title:previous.title||'',summary:plannerPublishState.summary||'',
                    visibility:visibility.dataset.visibility,country:'',city:null,
                    travelerCount:Math.max(1,Number(previous.travelerCount)||1),
                    startDate:start||null,endDate:null,days:[]};
                plannerSheets.push({placeholder:placeholder,payload:payload,files:[],first:false});
                switchPlannerSheet(plannerSheets.length-1);
                revealPlannerSheet(plannerSheetIndex,true);
                schedulePlannerTripGeoStats();
            }

            function collectAllPlannerSheets(){
                capturePlannerSheet();
                var title=$('#tripTitle')?$('#tripTitle').value.trim():'';
                var visibilityValue=visibility.dataset.visibility||'PUBLIC';
                var summary=plannerPublishState.summary||'';
                return plannerSheets.map(function(sheet,i){
                    var p=Object.assign({},sheet.payload||{});
                    p.title=title;p.summary=summary;p.visibility=visibilityValue;
                    p.sheetOrder=i+1;
                    // '지역' 입력 UI가 제거된 동안 과거 시트의 숨은 city 값을 보내지 않는다.
                    if($('#plannerRegion') && $('#plannerRegion').type==='hidden')p.city=null;
                    return p;
                });
            }

            function validateAllPlannerSheets(){
                capturePlannerSheet();
                for(var i=0;i<plannerSheets.length;i++){
                    var p=plannerSheets[i].payload||{};
                    if(!p.country || !findPlannerCountry(p.country)){
                        switchPlannerSheet(i);
                        showRequiredFieldsModal([(i+1)+'번째 시트의 국가를 선택해 주세요.'],'국가 선택 필요');
                        return false;
                    }
                    if(p.startDate && p.endDate && p.startDate>p.endDate){
                        switchPlannerSheet(i);
                        showRequiredFieldsModal([(i+1)+'번째 시트의 종료일을 확인해 주세요.'],'여행 기간 확인');
                        return false;
                    }
                    for(var d=0;d<(p.days||[]).length;d++){
                        var day=p.days[d];
                        for(var b=0;b<(day.blocks||[]).length;b++){
                            if((day.blocks[b].memo||'').length>200){
                                switchPlannerSheet(i);
                                showRequiredFieldsModal([(i+1)+'번째 시트에 200자를 초과한 블록 메모가 있습니다.']);return false;
                            }
                        }
                    }
                }
                return true;
            }

            function appendAllPlannerSheetImageParts(form,sheets){
                $$('.planner-upload-part',form).forEach(function(el){el.remove();});
                var globalDay=0;
                sheets.forEach(function(sheet,index){
                    var files=plannerSheets[index].files||[];
                    files.forEach(function(record){
                        if(!record.file)return;
                        var dt=new DataTransfer();dt.items.add(record.file);
                        var input=document.createElement('input');input.type='file';input.hidden=true;
                        input.className='planner-upload-part';
                        input.name='blockImage_'+(globalDay+Number(record.dayIndex))+'_'+Number(record.blockIndex)+'_'+(Number(record.imageIndex)+1);
                        input.files=dt.files;form.appendChild(input);
                    });
                    globalDay+=(sheet.days||[]).length;
                });
            }

            function collectFullPlannerPayload(){
                var sheets=collectAllPlannerSheets();
                var p=Object.assign({},sheets[0]||{});
                // 한 게시물의 정체성(공개 여부, 제목, 소개)은 공통이고
                // 국가, 인원, 기간, DAY는 각 시트에 귀속된다.
                p.sheets=sheets.map(function(sheet,i){
                    return {sheetOrder:i+1,country:sheet.country||'',city:sheet.city||null,
                        travelerCount:sheet.travelerCount||1,startDate:sheet.startDate||null,
                        endDate:sheet.endDate||null,days:sheet.days||[]};
                });
                p.days=[];
                p.sheets.forEach(function(sheet){
                    sheet.days.forEach(function(day){
                        p.days.push(day);
                        day.dayOrder=p.days.length;
                    });
                });
                // Root는 기존 상세/카트 화면에 대한 호환 필드로 첫 시트 정보를 보존한다.
                p.country=sheets[0].country;p.city=sheets[0].city;
                p.startDate=sheets[0].startDate;p.endDate=sheets[0].endDate;
                return p;
            }

            function activeSheetThumbnailKey(key){
                var offset=0;
                for(var i=0;i<plannerSheetIndex;i++) offset+=(plannerSheets[i].payload.days||[]).length;
                var parts=String(key||'').split(':');
                if(parts[0]==='sheetphoto' && parts.length===5){
                    var prior=0;for(var j=0;j<Number(parts[1]);j++)prior+=(plannerSheets[j].payload.days||[]).length;
                    return (prior+Number(parts[2]))+':'+parts[3]+':'+parts[4];
                }
                if(parts[0]==='sheetplace' && parts.length===4){
                    var priorPlace=0;for(var k=0;k<Number(parts[1]);k++)priorPlace+=(plannerSheets[k].payload.days||[]).length;
                    return 'place:'+(priorPlace+Number(parts[2]))+':'+parts[3];
                }
                if(parts.length===3 && parts[0]==='place')return 'place:'+(offset+Number(parts[1]))+':'+parts[2];
                if(parts.length===3 && /^\d+$/.test(parts[0]))return (offset+Number(parts[0]))+':'+parts[1]+':'+parts[2];
                return key;
            }

            function initPlannerSheets(){
                var base=collectPlannerPayload();
                var existing=(typeof EDIT_ITINERARY!=='undefined' && EDIT_ITINERARY && Array.isArray(EDIT_ITINERARY.sheets))
                    ? EDIT_ITINERARY.sheets : null;
                if(existing && existing.length){
                    var general=Object.assign({},base);
                    plannerSheets=existing.map(function(sheet,i){
                        return {placeholder:plannerPlaceholderAt(i),first:i===0,
                            payload:Object.assign({},general,sheet,{days:sheet.days||[]}),files:[]};
                    });

                    plannerSheetIndex=0;
                    // 수정 화면 최초 로드에서는 첫 시트가 initializePlanEditor로 이미 렌더링되어 있지만
                    // 다른 시트의 데이터를 기준으로 첫 시트를 다시 정렬한다.
                    plannerSheetSwitching=true;
                    try{applyPlannerDraftPayload(plannerSheets[0].payload,[]);}finally{plannerSheetSwitching=false;}
                }else{
                    plannerSheets=[{placeholder:'planB',first:true,payload:base,files:[]}];
                }
                renderPlannerSheets();syncBudget();
                initPlannerGeoStats();
                var add=$('#plannerSheetAdd'),prev=$('#plannerSheetPrev'),next=$('#plannerSheetNext');
                var scroller=$('#plannerSheetScroller');
                if(add)add.addEventListener('click',function(event){addPlannerSheet();if(event.detail>0)add.blur();});
                if(prev)prev.addEventListener('click',function(){scrollPlannerSheets(-1);});
                if(next)next.addEventListener('click',function(){scrollPlannerSheets(1);});
                if(scroller)scroller.addEventListener('scroll',updatePlannerSheetArrows,{passive:true});
                if($('#plannerCountry')){
                    $('#plannerCountry').addEventListener('input',function(){
                        syncPlannerActiveSheetCountry();syncBudget();
                    });
                    $('#plannerCountry').addEventListener('change',syncPlannerActiveSheetCountry);
                }
                if(window.ResizeObserver && scroller){
                    new ResizeObserver(updatePlannerSheetArrows).observe(scroller);
                    new ResizeObserver(updatePlannerSheetArrows).observe($('#plannerSheetTabs'));
                }
            }

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

                if(tripTitle){
                    tripTitle.value=itinerary.title || '';
                    updatePlannerTitleCount();
                }
                if(country) country.value=itinerary.country || '';

                refreshCountryStatus();
                refreshRegionOptions(false);

                if(region){
                    region.value=itinerary.city || '';
                }
                if(traveler){
                    traveler.value=String(itinerary.travelerCount || 1);
                }
                /*
                 * 수정 화면의 기존 여행기간은 서버 DTO의 java.sql.Date.toString()
                 * (yyyy-MM-dd) 값을 우선 사용한다.
                 * Gson의 Date 문자열 포맷/브라우저 로케일 차이 때문에
                 * 기존 날짜가 빈 값으로 보이던 문제를 방지한다.
                 */
                if(startDate){
                    startDate.value=normalizePlannerDateValue(
                        PLANNER_BOOTSTRAP.editStartDate || itinerary.startDate
                    );
                }
                if(endDate){
                    endDate.value=normalizePlannerDateValue(
                        PLANNER_BOOTSTRAP.editEndDate || itinerary.endDate
                    );
                }

                setPlannerVisibility(itinerary.visibility || 'PUBLIC',false);
                updateCountryClear();
                updateRegionClear();
                syncDates();

                $$('.planner-day').forEach(function(day){ day.remove(); });

                var days=Array.isArray(itinerary.days)
                    ? itinerary.days.slice().sort(function(a,b){
                        return Number(a.dayOrder||0)-Number(b.dayOrder||0);
                    })
                    : [];

                days.forEach(function(dayDto,index){
                    var daysWrap=$('#plannerDays');
                    var addDayButton=$('#plannerAddDay');
                    if(!daysWrap){
                        return;
                    }
                    var day=createPlannerDayShell(dayDto.title || ('Day '+(index+1)));
                    daysWrap.insertBefore(day,addDayButton||null);
                    setupDay(day);

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
                filterPlans(); // 수정 대상 국가가 채워진 후 같은 국가만 표시한다.

                refreshMap('all');
                dirty=false;
            }

            initializePlanEditor();
            initPlannerSheets();
            restoreDraft().then(function(restored){
                filterPlans();
                if(restored && typeof refreshMap==='function'){
                    refreshMap('all');
                }
            });

            window.setTimeout(function(){ if(!map) showPlannerMapFallback(); },1800);
        })();
