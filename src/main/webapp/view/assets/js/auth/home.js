/* ========================================
   HOME - 헤더 높이를 CSS 변수로 전달
   각 구역이 (화면 높이 - 헤더 높이)로 꽉 차도록 사용
======================================== */
(function () {

    function setHeaderHeight() {
        const header = document.querySelector('.site-header');

        if (!header) {
            return;
        }

        document.documentElement.style.setProperty(
            '--header-height',
            header.getBoundingClientRect().height + 'px'
        );
    }

    setHeaderHeight();
    window.addEventListener('resize', setHeaderHeight);

})();


/* ========================================
   HOME - 메인 배너 배경 슬라이드
   - 진행바 애니메이션이 끝나면 다음 사진으로 전환
======================================== */
(function () {

    const hero = document.getElementById('homeArea1');

    if (!hero) {
        return;
    }

    const slides = Array.from(hero.querySelectorAll('.ph-hero-slide'));
    const bars = Array.from(hero.querySelectorAll('[data-hero-bars] button'));
    const placeEl = hero.querySelector('[data-hero-place]');
    const indexEl = hero.querySelector('[data-hero-index]');

    // 사진 한 장이 보이는 시간
    const INTERVAL = 6000;

    let current = 0;

    if (slides.length <= 1 || bars.length !== slides.length) {
        return;
    }

    hero.style.setProperty('--hero-interval', INTERVAL + 'ms');

    function setPlace(slide) {
        if (!placeEl) {
            return;
        }

        placeEl.classList.add('is-changing');

        setTimeout(function () {
            const country = document.createElement('em');
            country.textContent = slide.dataset.country;

            placeEl.textContent = slide.dataset.place + ', ';
            placeEl.appendChild(country);
            placeEl.classList.remove('is-changing');
        }, 350);
    }

    function show(index) {
        current = (index + slides.length) % slides.length;

        slides.forEach(function (slide, i) {
            slide.classList.toggle('is-active', i === current);
        });

        bars.forEach(function (bar, i) {
            bar.classList.remove('is-active');
            bar.classList.toggle('is-done', i < current);
        });

        // 같은 클래스를 다시 붙여도 진행바 애니메이션이 처음부터 시작되도록 리플로우
        void bars[current].offsetWidth;
        bars[current].classList.add('is-active');

        setPlace(slides[current]);

        if (indexEl) {
            indexEl.textContent = String(current + 1).padStart(2, '0');
        }
    }

    bars.forEach(function (bar, i) {
        bar.addEventListener('click', function () {
            show(i);
        });

        bar.addEventListener('animationend', function () {
            if (bar.classList.contains('is-active')) {
                show(current + 1);
            }
        });
    });

})();


/* ========================================
   HOME - 인기 여행일정 자동 슬라이드
   - 카드 묶음을 복제해서 끊김 없이 무한 반복
   - 마우스를 올리면 잠시 멈춤
======================================== */
(function () {

    const carousel = document.querySelector('[data-ph-carousel]');

    if (!carousel) {
        return;
    }

    const originalCards = Array.from(carousel.querySelectorAll('.ph-plan-card'));

    if (originalCards.length === 0) {
        return;
    }

    // 1초에 이동하는 거리(px)
    const SPEED = 38;

    function appendClones(cards) {
        cards.forEach(function (card) {
            const clone = card.cloneNode(true);
            clone.setAttribute('aria-hidden', 'true');
            clone.setAttribute('tabindex', '-1');
            carousel.appendChild(clone);
        });
    }

    // 일정 개수가 적어도 화면을 충분히 채우도록 반복
    let guard = 0;

    while (carousel.scrollWidth < window.innerWidth * 1.5 && guard < 20) {
        appendClones(originalCards);
        guard++;
    }

    // 무한 반복용으로 완성된 묶음을 한 번 더 복제
    const firstSet = Array.from(carousel.children);
    appendClones(firstSet);

    const loopWidth =
        carousel.children[firstSet.length].offsetLeft - firstSet[0].offsetLeft;

    let position = 0;
    let paused = false;
    let lastTime = null;

    carousel.addEventListener('mouseenter', function () { paused = true; });
    carousel.addEventListener('mouseleave', function () { paused = false; });

    function tick(time) {
        if (lastTime !== null && !paused) {
            // 탭 전환 등으로 시간이 크게 벌어져도 한 번에 튀지 않도록 제한
            const delta = Math.min(time - lastTime, 50);

            position += SPEED * delta / 1000;

            if (position >= loopWidth) {
                position -= loopWidth;
            }

            carousel.scrollLeft = position;
        }

        lastTime = time;
        requestAnimationFrame(tick);
    }

    requestAnimationFrame(tick);

})();


/* ========================================
   HOME - 여행꿀팁 / 여행메이트 게시글 로테이션
   - 페이지 수만큼 진행바를 만들고
     진행바가 다 차면 다음 페이지로 전환
   - 마우스를 올리면 진행바가 멈춤 (CSS)
======================================== */
document.querySelectorAll('[data-rotate-group]').forEach(function (group) {

    const pages = Array.from(group.querySelectorAll('.ph-rotate-page'));
    const progress = group.parentElement.querySelector('[data-rotate-progress]');

    // 페이지 전환 간격
    const INTERVAL = 4000;

    let current = 0;

    if (!progress || pages.length <= 1) {
        return;
    }

    progress.style.setProperty('--rotate-interval', INTERVAL + 'ms');

    const bars = pages.map(function (page, i) {
        const bar = document.createElement('button');
        bar.type = 'button';
        bar.className = 'ph-progress-bar';
        bar.setAttribute('aria-label', (i + 1) + '번째 묶음 보기');
        bar.appendChild(document.createElement('i'));

        bar.addEventListener('click', function () {
            show(i);
        });

        bar.addEventListener('animationend', function () {
            if (bar.classList.contains('is-active')) {
                show(current + 1);
            }
        });

        progress.appendChild(bar);
        return bar;
    });

    function show(index) {
        current = (index + pages.length) % pages.length;

        pages.forEach(function (page, i) {
            page.classList.toggle('is-active', i === current);
        });

        bars.forEach(function (bar) {
            bar.classList.remove('is-active');
        });

        void bars[current].offsetWidth;
        bars[current].classList.add('is-active');
    }

    show(0);
});


/* ========================================
   HOME - 섹션 단위 스크롤 + 우측 점 네비게이션

   - 휠 한 번(제스처 한 번)에 정확히 한 구역만 이동
   - 이동이 끝나도 휠 입력이 잠깐 멈출 때까지는 다음 이동을 막아서
     트랙패드 관성 / 연속 휠 때문에 두 구역씩 넘어가는 문제 방지
   - 마지막 구역 아래(푸터)는 일반 스크롤
   - 화면이 작아 구역 내용이 넘치면 일반 스크롤로 동작
======================================== */
(function () {

    const sections = Array.from(document.querySelectorAll('[data-ph-section]'));
    const dotsNav = document.querySelector('.ph-dots');
    const dots = Array.from(document.querySelectorAll('[data-dot]'));
    const header = document.querySelector('.site-header');

    if (sections.length === 0) {
        return;
    }

    document.documentElement.classList.add('ph-snap');

    // 구역 이동 시간
    const DURATION = 850;

    // 이 시간(ms) 동안 휠 입력이 없어야 다음 이동 허용
    const WHEEL_QUIET = 200;

    const last = sections.length - 1;

    let animating = false;
    let wheelLocked = false;
    let lastWheelAt = 0;
    let frameId = null;


    function headerHeight() {
        return header ? header.getBoundingClientRect().height : 0;
    }

    // 해당 구역 맨 위가 헤더 바로 아래에 오도록 하는 스크롤 위치
    function sectionTop(index) {
        if (index === 0) {
            return 0;
        }

        return Math.round(
            sections[index].getBoundingClientRect().top + window.scrollY - headerHeight()
        );
    }

    // 현재 화면에 걸쳐 있는 구역 번호
    function currentIndex() {
        const y = window.scrollY + 4;
        let index = 0;

        for (let i = 0; i < sections.length; i++) {
            if (sectionTop(i) <= y) {
                index = i;
            }
        }

        return index;
    }

    // 데스크톱이고 모든 구역이 한 화면 안에 들어올 때만 섹션 스크롤 사용
    function snapEnabled() {
        if (window.innerWidth <= 1024) {
            return false;
        }

        return sections.every(function (section) {
            return section.scrollHeight <= section.clientHeight + 2;
        });
    }

    function updateDots(index) {
        dots.forEach(function (dot, i) {
            dot.classList.toggle('is-active', i === index);
        });

        if (dotsNav) {
            dotsNav.classList.toggle(
                'is-dark',
                sections[index].dataset.theme === 'dark'
            );
        }
    }

    function easeInOutCubic(t) {
        return t < 0.5 ? 4 * t * t * t : 1 - Math.pow(-2 * t + 2, 3) / 2;
    }

    function releaseWheelWhenQuiet() {
        const wait = WHEEL_QUIET - (performance.now() - lastWheelAt);

        if (wait > 0) {
            setTimeout(releaseWheelWhenQuiet, wait);
        } else {
            wheelLocked = false;
        }
    }

    function goTo(index) {
        index = Math.max(0, Math.min(last, index));

        if (frameId !== null) {
            cancelAnimationFrame(frameId);
        }

        const startY = window.scrollY;
        const distance = sectionTop(index) - startY;
        const startTime = performance.now();

        animating = true;
        wheelLocked = true;
        updateDots(index);

        if (Math.abs(distance) < 2) {
            animating = false;
            releaseWheelWhenQuiet();
            return;
        }

        function step(now) {
            const progress = Math.min((now - startTime) / DURATION, 1);

            window.scrollTo(0, startY + distance * easeInOutCubic(progress));

            if (progress < 1) {
                frameId = requestAnimationFrame(step);
                return;
            }

            frameId = null;
            animating = false;
            releaseWheelWhenQuiet();
        }

        frameId = requestAnimationFrame(step);
    }

    // 방향(1: 아래, -1: 위)에 따라 이동할 구역 계산
    // null 이면 브라우저 기본 스크롤 사용
    function targetFor(direction) {
        const y = window.scrollY;
        const lastTop = sectionTop(last);
        const index = currentIndex();

        // 마지막 구역 이후(푸터 영역)
        if (y > lastTop + 4) {
            return direction > 0 ? null : last;
        }

        // 마지막 구역에서 아래로 → 푸터까지 일반 스크롤
        if (index === last && direction > 0) {
            return null;
        }

        // 구역 중간에 걸쳐 있다면 위로 갈 때는 현재 구역 맨 위로
        if (direction < 0 && y > sectionTop(index) + 4) {
            return index;
        }

        const target = index + direction;

        return target < 0 ? 0 : target;
    }

    window.addEventListener('wheel', function (event) {
        lastWheelAt = performance.now();

        if (event.ctrlKey || !snapEnabled() || event.deltaY === 0) {
            return;
        }

        const direction = event.deltaY > 0 ? 1 : -1;

        if (animating || wheelLocked) {
            event.preventDefault();
            return;
        }

        const target = targetFor(direction);

        if (target === null) {
            return;
        }

        event.preventDefault();
        goTo(target);

    }, { passive: false });


    // 키보드 (방향키 / PageUp / PageDown / Space)
    window.addEventListener('keydown', function (event) {
        const tag = (event.target.tagName || '').toLowerCase();

        if (tag === 'input' || tag === 'textarea' || tag === 'select' || event.target.isContentEditable) {
            return;
        }

        if (!snapEnabled()) {
            return;
        }

        let direction = 0;

        if (event.key === 'ArrowDown' || event.key === 'PageDown' || (event.key === ' ' && !event.shiftKey)) {
            direction = 1;
        } else if (event.key === 'ArrowUp' || event.key === 'PageUp' || (event.key === ' ' && event.shiftKey)) {
            direction = -1;
        }

        if (direction === 0) {
            return;
        }

        if (animating) {
            event.preventDefault();
            return;
        }

        const target = targetFor(direction);

        if (target === null) {
            return;
        }

        event.preventDefault();
        goTo(target);
    });


    // 점 클릭
    dots.forEach(function (dot) {
        dot.addEventListener('click', function () {
            goTo(Number(dot.dataset.dot));
        });
    });

    // 배너 하단 Scroll 버튼
    const scrollNext = document.querySelector('[data-scroll-next]');

    if (scrollNext) {
        scrollNext.addEventListener('click', function () {
            goTo(1);
        });
    }


    // 일반 스크롤(모바일, 푸터 등) 중에도 점 상태 맞추기
    window.addEventListener('scroll', function () {
        if (!animating) {
            updateDots(currentIndex());
        }
    }, { passive: true });


    // 창 크기가 바뀌면 현재 구역 위치로 다시 맞춤
    let resizeTimer = null;

    window.addEventListener('resize', function () {
        clearTimeout(resizeTimer);

        resizeTimer = setTimeout(function () {
            if (!snapEnabled() || animating) {
                return;
            }

            if (window.scrollY <= sectionTop(last) + 4) {
                window.scrollTo(0, sectionTop(currentIndex()));
            }
        }, 150);
    });


    // 새로고침 시 브라우저가 복원한 위치 기준으로 점 초기화
    window.addEventListener('load', function () {
        requestAnimationFrame(function () {
            updateDots(currentIndex());
        });
    });

})();
