/* ========================================
   HOME - 메인 배너 높이 자동 조절
   현재 화면의 헤더 높이를 자동으로 계산해서
   메인 배너가 화면 크기에 맞게 표시되도록 하는 기능
======================================== */

(function () {

    // 헤더의 실제 높이를 계산하는 함수
    function setHomeHeroHeight() {

        // 현재 페이지의 헤더 찾기
        const header = document.querySelector('.site-header');

        // 헤더를 찾지 못하면 실행 중지
        if (!header) {
            return;
        }

        // 현재 헤더의 실제 높이(px) 가져오기
        const headerHeight = header.getBoundingClientRect().height;

        // 계산한 헤더 높이를 CSS 변수로 전달
        // CSS에서 var(--header-height)로 사용할 수 있음
        document.documentElement.style.setProperty(
            '--header-height',
            headerHeight + 'px'
        );
    }

    // 페이지가 처음 열렸을 때 한 번 실행
    setHomeHeroHeight();

    // 브라우저 창 크기가 변경될 때마다 다시 계산
    window.addEventListener('resize', setHomeHeroHeight);

})();

/* ========================================
   HOME - 인기 여행일정 자동 슬라이드
======================================== */
(function () {

    const carousel =
        document.querySelector('[data-home-carousel]');

    if (!carousel) {
        return;
    }

    const originalCards =
        Array.from(carousel.children);

    if (originalCards.length === 0) {
        return;
    }

    /*
     * DB 일정 개수가 적어도
     * 화면 전체를 충분히 채우도록 반복 생성
     */
    const originalSet = originalCards.map(function (card) {
        return card.cloneNode(true);
    });

    while (
        carousel.scrollWidth <
        window.innerWidth * 2
    ) {
        originalSet.forEach(function (card) {
            carousel.appendChild(
                card.cloneNode(true)
            );
        });
    }

    /*
     * 무한 반복용으로
     * 완성된 카드 묶음을 한 번 더 복제
     */
    const firstSetCards =
        Array.from(carousel.children);

    const loopWidth =
        carousel.scrollWidth;

    firstSetCards.forEach(function (card) {
        carousel.appendChild(
            card.cloneNode(true)
        );
    });

    /*
     * 계속 오른쪽 방향으로 이동
     */
    function moveCarousel() {

        carousel.scrollLeft += 0.7;

        /*
         * 첫 번째 카드 묶음이 끝나면
         * 같은 위치의 두 번째 묶음으로 자연스럽게 연결
         */
        if (
            carousel.scrollLeft >= loopWidth
        ) {
            carousel.scrollLeft -= loopWidth;
        }

        requestAnimationFrame(
            moveCarousel
        );
    }

    requestAnimationFrame(
        moveCarousel
    );

})();

/* ========================================
   HOME - 여행일정 북마크 버튼
======================================== */
document
	.querySelectorAll('[data-bookmark]')
	.forEach(function (btn) {
		btn.addEventListener(
           'click',
			function (e) {
				// 카드 상세 페이지로
                // 이동하지 않도록 막음
                e.preventDefault();
                e.stopPropagation();
                // 저장 상태 표시
                btn.classList.toggle(
                    'saved'
            );
		}
	);
});


/* 여행꿀팁 + 여행메이트 게시글/진행바 로테이션 */
document.querySelectorAll('[data-rotate-group]').forEach(function (rotateGroup) {

    const pages = rotateGroup.querySelectorAll('.home-rotate-page');

    const progressWrap = rotateGroup.nextElementSibling;
    const bars = progressWrap.querySelectorAll('.home-progress-bar');

    let current = 0;

    // 진행바가 차는 시간
    const duration = 3000;

    // 게시글 전환 시간
    const fadeDuration = 150;


    function startProgress(index) {

        // 진행바 전부 초기화
        bars.forEach(function (bar) {
            bar.style.backgroundColor = '#e5e7eb';
            bar.innerHTML = '';
        });

        // 현재 진행바 채움 생성
        const fill = document.createElement('span');

        fill.style.position = 'absolute';
        fill.style.left = '0';
        fill.style.top = '0';
        fill.style.height = '100%';
        fill.style.width = '0%';
        fill.style.backgroundColor = '#FFD447';
        fill.style.borderRadius = '9999px';

        bars[index].appendChild(fill);

        // 0% → 100%
        requestAnimationFrame(function () {
            requestAnimationFrame(function () {

                fill.style.transition =
                    'width ' + duration + 'ms linear';

                fill.style.width = '100%';

            });
        });
    }


    function changePage() {

        const oldPage = pages[current];

        // 현재 게시글 살짝 사라짐
        oldPage.style.transition =
            'opacity ' + fadeDuration + 'ms ease';

        oldPage.style.opacity = '0';


        setTimeout(function () {

            oldPage.style.display = 'none';

            // 다음 페이지
            current = (current + 1) % pages.length;

            const newPage = pages[current];

            newPage.style.display = 'flex';
            newPage.style.opacity = '0';

            newPage.style.transition =
                'opacity ' + fadeDuration + 'ms ease';


            // 다음 게시글 살짝 나타남
            requestAnimationFrame(function () {
                requestAnimationFrame(function () {
                    newPage.style.opacity = '1';
                });
            });


            // 다음 진행바 시작
            startProgress(current);


            // 다시 3초 후 다음 페이지
            setTimeout(changePage, duration);

        }, fadeDuration);
    }


    // 처음 상태 설정
    pages.forEach(function (page, i) {

        if (i === 0) {

            page.style.display = 'flex';
            page.style.opacity = '1';

        } else {

            page.style.display = 'none';
            page.style.opacity = '0';

        }

    });


    // 첫 번째 진행바 시작
    startProgress(current);

    // 첫 번째 로테이션 시작
    setTimeout(changePage, duration);

});

/* =========================================================
   통합본(9) JSP 화면 상호작용
========================================================= */
(function () {
  function all(selector, root) { return Array.prototype.slice.call((root || document).querySelectorAll(selector)); }

  all('.continent-toggle').forEach(function (button) {
    button.addEventListener('click', function () {
      var panel = button.parentElement && button.parentElement.querySelector('.continent-panel');
      if (!panel) return;
      panel.classList.toggle('open');
      button.classList.toggle('open');
    });
  });

  var filterToggle = document.getElementById('scheduleFilterToggle');
  var filterPanel = document.getElementById('scheduleFilterPanel');
  var filterBar = document.getElementById('scheduleSearchBar');
  if (filterToggle && filterPanel) {
    filterToggle.addEventListener('click', function (event) {
      event.preventDefault();
      event.stopPropagation();
      filterPanel.classList.toggle('hidden');
      if (filterBar) filterBar.style.borderColor = filterPanel.classList.contains('hidden') ? '#D1D2F9' : '#6369D1';
    });
    filterPanel.addEventListener('click', function (event) { event.stopPropagation(); });
    document.addEventListener('click', function () {
      filterPanel.classList.add('hidden');
      if (filterBar) filterBar.style.borderColor = '#D1D2F9';
    });
  }

  all('[data-chip-group]').forEach(function (group) {
    all('button', group).forEach(function (button) {
      button.addEventListener('click', function () {
        all('button', group).forEach(function (item) {
          item.classList.remove('bg-[#6369D1]', 'border-[#6369D1]', 'text-white');
          if (!item.classList.contains('bg-white')) item.classList.add('bg-gray-100');
          item.classList.add('text-gray-500');
        });
        button.classList.remove('bg-gray-100', 'text-gray-500');
        button.classList.add('bg-[#6369D1]', 'border-[#6369D1]', 'text-white');
      });
    });
  });

  all('[data-tab-group]').forEach(function (group) {
    all('button', group).forEach(function (button) {
      button.addEventListener('click', function () {
        all('button', group).forEach(function (item) {
          item.classList.remove('text-[#6369D1]', 'border-b-2', 'border-[#6369D1]', 'font-black');
          item.classList.add('text-gray-400', 'font-bold');
        });
        button.classList.remove('text-gray-400', 'font-bold');
        button.classList.add('text-[#6369D1]', 'border-b-2', 'border-[#6369D1]', 'font-black');
      });
    });
  });

  all('[data-read-all]').forEach(function (button) {
    button.addEventListener('click', function () {
      all('.unread').forEach(function (item) { item.classList.remove('unread'); });
      if (window.tripilyToast) window.tripilyToast('모든 알림을 읽음 처리했습니다.');
    });
  });

  all('[data-char-input]').forEach(function (input) {
    function sync() {
      var counterId = input.getAttribute('data-char-input');
      var counter = counterId ? document.getElementById(counterId) : input.parentElement && input.parentElement.querySelector('[data-char-count]');
      if (counter) counter.textContent = String(input.value.length);
    }
    input.addEventListener('input', sync);
    sync();
  });
})();

/* ========================================
   HOME - 우측 점 네비게이션
======================================== */
(function () {

    /* ========================================
       점
    ======================================== */
    const dot1 = document.getElementById('homeScrollDot1');
    const dot2 = document.getElementById('homeScrollDot2');
    const dot3 = document.getElementById('homeScrollDot3');
    const dot4 = document.getElementById('homeScrollDot4');


    /* ========================================
       이동할 구역
    ======================================== */
    const area1 = document.getElementById('homeArea1');
    const area2 = document.getElementById('popularPlans');
    const area3 = document.getElementById('homeArea3');
    const area4 = document.getElementById('homeArea4');


    /* ========================================
       점 네비게이션
    ======================================== */
    const indicator =
        document.querySelector('.home-scroll-indicator');


    /* 필요한 요소가 없으면 종료 */
    if (
        !dot1 ||
        !dot2 ||
        !dot3 ||
        !dot4 ||
        !area1 ||
        !area2 ||
        !area3 ||
        !area4 ||
        !indicator
    ) {
        return;
    }


    /* ========================================
       현재 구역

       0 = 1번
       1 = 2번
       2 = 3번
       3 = 4번
    ======================================== */
    let currentSection = 0;

    /* 구역 이동 중인지 확인 */
    let isMoving = false;

    /* 현재 실행 중인 애니메이션 */
    let animationFrameId = null;


    /* ========================================
       활성화된 점 변경
    ======================================== */
    function setActiveDot(activeDot) {

        dot1.classList.remove('active');
        dot2.classList.remove('active');
        dot3.classList.remove('active');
        dot4.classList.remove('active');

        activeDot.classList.add('active');
    }


    /* ========================================
       부드러운 스크롤 이동
       - 처음부터 끝까지 일정한 속도
    ======================================== */
    function smoothScrollTo(targetY, duration, callback) {

        /* 기존 애니메이션이 있으면 취소 */
        if (animationFrameId !== null) {
            cancelAnimationFrame(animationFrameId);
        }

        const startY = window.scrollY;
        const distance = targetY - startY;
        const startTime = performance.now();


        function animation(currentTime) {

            const elapsed =
                currentTime - startTime;

            const progress =
                Math.min(elapsed / duration, 1);


            /* 일정한 속도로 이동 */
            window.scrollTo(
                0,
                startY + distance * progress
            );


            /* 아직 이동 중 */
            if (progress < 1) {

                animationFrameId =
                    requestAnimationFrame(animation);

            }

            /* 이동 완료 */
            else {

                animationFrameId = null;

                if (callback) {
                    callback();
                }
            }
        }


        animationFrameId =
            requestAnimationFrame(animation);
    }

    /* ========================================
	   각 구역의 실제 이동 위치 계산
	   - 화면 크기가 달라져도 실제 DOM 위치 기준
	======================================== */
	function getSectionPosition(sectionIndex) {
	
	    /* 1번 - 페이지 맨 위 */
	    if (sectionIndex === 0) {
	        return 0;
	    }
	
	
	    /* 2번 - 인기 여행일정 */
	    if (sectionIndex === 1) {

		    const targetPosition =
		        area2.getBoundingClientRect().top +
		        window.scrollY;
		
		    /*
		     * 화면 높이의 약 12%만큼 위쪽 여유 확보
		     * 모니터 높이에 따라 자동으로 달라짐
		     */
		    const offset =
		        window.innerHeight * 0.16;
		
		    return targetPosition - offset;
		}
	
	
	    /* 3번 - 일정 만들기 */
	    if (sectionIndex === 2) {
	
	        const targetPosition =
	            area3.getBoundingClientRect().top +
	            window.scrollY;
	
	        return targetPosition;
	    }
	
	
	    /* 4번 - 여행꿀팁 + 여행메이트 */
	    if (sectionIndex === 3) {
	
	        const targetPosition =
	            area4.getBoundingClientRect().top +
	            window.scrollY;
	
	        return targetPosition;
	    }
	
	
	    return 0;
	}


    /* ========================================
       해당 구역으로 이동
    ======================================== */
    function moveToSection(sectionIndex) {

        /* 범위 제한 : 0 ~ 3 */
        if (sectionIndex < 0 || sectionIndex > 3) {
            return;
        }


        /* 이미 이동 중이면 무시 */
        if (isMoving) {
            return;
        }


        /* 이동 시작 */
        isMoving = true;


        /*
         * 논리적인 현재 구역은
         * 휠 입력 즉시 다음 구역으로 변경
         */
        currentSection = sectionIndex;


        /* 이동할 위치 계산 */
        const targetY =
            getSectionPosition(sectionIndex);


        /* 화면 이동 */
        smoothScrollTo(
            targetY,
            10,
            function () {

                /*
                 * 화면 이동이 끝난 뒤
                 * 활성 점 변경
                 */
                if (sectionIndex === 0) {

                    setActiveDot(dot1);

                } else if (sectionIndex === 1) {

                    setActiveDot(dot2);

                } else if (sectionIndex === 2) {

                    setActiveDot(dot3);

                } else {

                    setActiveDot(dot4);
                }


                /* 이동 완료 */
                isMoving = false;
            }
        );
    }


    /* ========================================
       점 클릭
    ======================================== */

    /* 1번 */
    dot1.addEventListener('click', function () {

        if (
            currentSection === 0 &&
            window.scrollY === 0
        ) {
            return;
        }

        isMoving = false;

        moveToSection(0);
    });


    /* 2번 */
    dot2.addEventListener('click', function () {

        isMoving = false;

        moveToSection(1);
    });


    /* 3번 */
    dot3.addEventListener('click', function () {

        isMoving = false;

        moveToSection(2);
    });


    /* 4번 */
    dot4.addEventListener('click', function () {

        isMoving = false;

        moveToSection(3);
    });


    /* ========================================
       메인 배너 화살표 클릭
       - 2번 구역으로 이동
    ======================================== */
    const heroArrow =
        document.querySelector('[data-scroll-popular]');

    if (heroArrow) {

        heroArrow.addEventListener(
            'click',
            function () {

                dot2.click();
            }
        );
    }


    /* ========================================
       마우스 휠
       - 휠 입력 즉시 다음 구역으로 이동
    ======================================== */
    window.addEventListener(
        'wheel',
        function (event) {

            /* 브라우저 기본 스크롤 방지 */
            event.preventDefault();


            /* 이미 화면 이동 중이면 추가 입력 무시 */
            if (isMoving) {
                return;
            }


            /* 아래로 휠 */
            if (event.deltaY > 0) {

                if (currentSection < 3) {

                    moveToSection(
                        currentSection + 1
                    );
                }

                return;
            }


            /* 위로 휠 */
            if (event.deltaY < 0) {

                if (currentSection > 0) {

                    moveToSection(
                        currentSection - 1
                    );
                }
            }
        },
        {
            passive: false
        }
    );


    /* ========================================
       마우스를 움직이면 점 표시
    ======================================== */
    let hideTimer;

    document.addEventListener(
        'mousemove',
        function () {

            indicator.classList.add('visible');

            clearTimeout(hideTimer);

            hideTimer =
                setTimeout(function () {

                    indicator.classList.remove(
                        'visible'
                    );

                }, 1500);
        }
    );


    /* ========================================
       현재 스크롤 위치에 맞게 초기 구역 설정
    ======================================== */
    function initializeCurrentSection() {

        const scrollY =
            window.scrollY;


        /* 각 구역의 이동 위치 */
        const section1Position =
            getSectionPosition(0);

        const section2Position =
            getSectionPosition(1);

        const section3Position =
            getSectionPosition(2);

        const section4Position =
            getSectionPosition(3);


        /* 1번과 2번 사이 */
        const boundary1 =
            (section1Position + section2Position) / 2;


        /* 2번과 3번 사이 */
        const boundary2 =
            (section2Position + section3Position) / 2;


        /* 3번과 4번 사이 */
        const boundary3 =
            (section3Position + section4Position) / 2;


        /* ========================================
           1번 구역
        ======================================== */
        if (scrollY < boundary1) {

            currentSection = 0;

            setActiveDot(dot1);
        }


        /* ========================================
           2번 구역
        ======================================== */
        else if (scrollY < boundary2) {

            currentSection = 1;

            setActiveDot(dot2);
        }


        /* ========================================
           3번 구역
        ======================================== */
        else if (scrollY < boundary3) {

            currentSection = 2;

            setActiveDot(dot3);
        }


        /* ========================================
           4번 구역
        ======================================== */
        else {

            currentSection = 3;

            setActiveDot(dot4);
        }
    }


    /* ========================================
       페이지가 완전히 열린 후 현재 위치 확인
    ======================================== */
    window.addEventListener(
        'load',
        function () {

            /*
             * 브라우저가 새로고침 전 스크롤 위치를
             * 복원한 다음 확인
             */
            requestAnimationFrame(function () {

                initializeCurrentSection();

            });
        }
    );

})();