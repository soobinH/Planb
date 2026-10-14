/* ========================================
   Planb 광고 상품 / 요금 계산 (광고 안내 · 광고 문의 공통)

   요금 기준
   - 계약 기간에 따라 하루 단가가 달라짐
       단기   : 30일 미만   (기준 기간보다 짧아 하루 단가가 가장 비쌈)
       1개월  : 30일 이상
       3개월  : 90일 이상
       6개월  : 180일 이상  (하루 단가가 가장 저렴)
   - 예상 금액 = 하루 단가 × 노출 일수
   - 단, 다음 기준 기간을 꽉 채워 계약하는 금액보다 비싸지면
     다음 기준 기간 금액을 상한으로 적용
     (예: 단기 27일 금액 > 1개월 30일 금액 → 1개월 30일 금액 적용)
======================================== */
(function (global) {

    /* 기준 기간 (짧은 순) */
    const TIERS = [
        { key: "SHORT", label: "단기", minDays: 1 },
        { key: "M1", label: "1개월", minDays: 30 },
        { key: "M3", label: "3개월", minDays: 90 },
        { key: "M6", label: "6개월", minDays: 180 }
    ];

    /*
     * 광고 위치별 정보
     * - width / height : 실제 화면에 표시되는 크기 (CSS px)
     * - image          : 권장 업로드 이미지 크기 (고해상도 화면 대비 2배)
     * - daily          : 기준 기간별 하루 단가 (원)
     */
    const POSITIONS = {
        TRIP_CARD: {
            name: "홈 슬라이딩 카드",
            area: "HOME",
            width: 290,
            height: 230,
            image: "580 × 460",
            ratio: "약 5 : 4",
            daily: { SHORT: 4000, M1: 3000, M3: 2500, M6: 2000 }
        },
        TIP_SIDE: {
            name: "여행 꿀팁 사이드",
            area: "TRAVEL TIP",
            width: 160,
            height: 600,
            image: "320 × 1200",
            ratio: "4 : 15",
            daily: { SHORT: 2600, M1: 2000, M3: 1700, M6: 1400 }
        },
        MATE_SIDE: {
            name: "여행 메이트 사이드",
            area: "TRAVEL MATE",
            width: 160,
            height: 600,
            image: "320 × 1200",
            ratio: "4 : 15",
            daily: { SHORT: 2000, M1: 1500, M3: 1300, M6: 1000 }
        },
        CART_SIDE: {
            name: "일정 카트 사이드",
            area: "SCHEDULE CART",
            width: 160,
            height: 600,
            image: "320 × 1200",
            ratio: "4 : 15",
            daily: { SHORT: 2400, M1: 1800, M3: 1500, M6: 1200 }
        }
    };

    function tierIndexFor(days) {
        let index = 0;

        TIERS.forEach(function (tier, i) {
            if (days >= tier.minDays) {
                index = i;
            }
        });

        return index;
    }

    /*
     * 예상 금액 계산
     * return null : 계산 불가 (위치 없음 / 기간 오류)
     */
    function estimate(position, days) {
        const info = POSITIONS[position];

        if (!info || !days || days < 1) {
            return null;
        }

        const index = tierIndexFor(days);
        const tier = TIERS[index];
        const dailyRate = info.daily[tier.key];

        let total = dailyRate * days;
        let capped = false;

        /* 다음 기준 기간을 꽉 채운 금액이 더 싸면 그 금액을 상한으로 */
        const next = TIERS[index + 1];

        if (next) {
            const nextTotal = info.daily[next.key] * next.minDays;

            if (nextTotal < total) {
                total = nextTotal;
                capped = true;
            }
        }

        return {
            days: days,
            tier: tier,
            dailyRate: dailyRate,
            total: total,
            capped: capped,
            next: next || null,
            nextDailyRate: next ? info.daily[next.key] : null,
            /* 이번 계약의 실제 하루 평균 금액 */
            averageDaily: Math.round(total / days)
        };
    }

    function won(value) {
        return Number(value).toLocaleString("ko-KR") + "원";
    }

    global.PlanbAdPricing = {
        TIERS: TIERS,
        POSITIONS: POSITIONS,
        estimate: estimate,
        won: won
    };

})(window);
