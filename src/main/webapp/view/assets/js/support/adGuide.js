/* ========================================
   광고 안내 - 시작 요금 / 예상 금액 계산기 / 기간별 요금표
   (요금 데이터는 adPricing.js)
======================================== */
document.addEventListener("DOMContentLoaded", function () {

    const Pricing = window.PlanbAdPricing;

    if (!Pricing) {
        return;
    }

    const POSITION_CLASS = {
        TRIP_CARD: "pos-home",
        TIP_SIDE: "pos-tip",
        MATE_SIDE: "pos-mate",
        CART_SIDE: "pos-cart"
    };

    const keys = Object.keys(Pricing.POSITIONS);
    const lastTier = Pricing.TIERS[Pricing.TIERS.length - 1];


    /* =====================================================
       시작 요금 (6개월 하루 금액 기준)
    ====================================================== */
    document.querySelectorAll("[data-price-from]").forEach(function (el) {

        const info = Pricing.POSITIONS[el.dataset.priceFrom];

        if (info) {
            el.innerHTML = "";

            const label = document.createElement("small");
            const value = document.createElement("b");

            label.textContent = "하루";
            value.textContent = Pricing.won(info.daily[lastTier.key]) + "부터";

            el.appendChild(label);
            el.appendChild(value);
        }
    });

    const lowestEl = document.querySelector("[data-price-lowest]");

    if (lowestEl) {
        const lowest = Math.min.apply(null, keys.map(function (key) {
            return Pricing.POSITIONS[key].daily[lastTier.key];
        }));

        lowestEl.textContent = "하루 " + Pricing.won(lowest);
    }


    /* =====================================================
       기간별 요금표
       - 1·3·6개월 : 기준 기간 전체 금액 + 하루 금액
       - 단기      : 하루 금액
    ====================================================== */
    const tbody = document.querySelector("#adPriceTable tbody");

    if (tbody) {

        keys.forEach(function (key) {

            const info = Pricing.POSITIONS[key];
            const row = document.createElement("tr");

            row.className = POSITION_CLASS[key] || "";

            const head = document.createElement("th");
            head.scope = "row";
            head.textContent = info.name;
            row.appendChild(head);

            Pricing.TIERS.forEach(function (tier) {

                const cell = document.createElement("td");
                const main = document.createElement("strong");
                const sub = document.createElement("small");
                const daily = info.daily[tier.key];

                if (tier.key === "SHORT") {
                    main.textContent = Pricing.won(daily);
                    sub.textContent = "하루 금액";
                } else {
                    main.textContent = Pricing.won(daily * tier.minDays);
                    sub.textContent = "하루 " + Pricing.won(daily);
                }

                if (tier === lastTier) {
                    cell.className = "is-best";
                }

                cell.appendChild(main);
                cell.appendChild(sub);
                row.appendChild(cell);
            });

            tbody.appendChild(row);
        });
    }


    /* =====================================================
       예상 금액 계산기
    ====================================================== */
    const segment = document.getElementById("calcPositions");
    const daysInput = document.getElementById("calcDays");
    const totalText = document.getElementById("calcTotal");
    const tierText = document.getElementById("calcTier");
    const dailyText = document.getElementById("calcDaily");
    const hintText = document.getElementById("calcHint");
    const inquiryLink = document.getElementById("calcInquiry");
    const chips = document.querySelectorAll("[data-calc-days]");

    if (!segment || !daysInput) {
        return;
    }

    const inquiryBase = inquiryLink ? inquiryLink.getAttribute("href") : "";

    let selected = keys[0];

    keys.forEach(function (key) {

        const button = document.createElement("button");

        button.type = "button";
        button.className = POSITION_CLASS[key] || "";
        button.setAttribute("role", "radio");
        button.dataset.position = key;
        button.textContent = Pricing.POSITIONS[key].name.replace(" 사이드", "").replace(" 슬라이딩 카드", " 카드");

        button.addEventListener("click", function () {
            selected = key;
            update();
        });

        segment.appendChild(button);
    });

    function update() {

        segment.querySelectorAll("button").forEach(function (button) {
            const active = button.dataset.position === selected;

            button.classList.toggle("is-active", active);
            button.setAttribute("aria-checked", active ? "true" : "false");
        });

        const days = Math.floor(Number(daysInput.value));

        chips.forEach(function (chip) {
            chip.classList.toggle("is-active", Number(chip.dataset.calcDays) === days);
        });

        if (inquiryLink) {
            inquiryLink.href = inquiryBase + "?adPosition=" + selected;
        }

        const result = Pricing.estimate(selected, days);

        if (!result) {
            totalText.textContent = "-";
            tierText.textContent = "-";
            dailyText.textContent = "-";
            hintText.textContent = "노출 기간을 1일 이상 입력해주세요.";
            return;
        }

        totalText.textContent = Pricing.won(result.total);
        tierText.textContent = result.tier.label + " 요금";
        dailyText.textContent = Pricing.won(result.dailyRate);

        if (result.capped) {
            hintText.textContent =
                result.next.label + " 요금이 더 저렴해 이 금액으로 계산했어요. 같은 금액으로 "
                + result.next.minDays + "일까지 노출할 수 있어요.";
        } else if (result.next) {
            hintText.textContent =
                (result.next.minDays - result.days) + "일 더 계약하면 하루 "
                + Pricing.won(result.nextDailyRate) + "로 내려가요.";
        } else {
            hintText.textContent = "가장 저렴한 6개월 요금이 적용됐어요.";
        }
    }

    daysInput.addEventListener("input", update);

    document.querySelectorAll("[data-step]").forEach(function (button) {
        button.addEventListener("click", function () {
            const next = Math.max(1, Math.min(730, (Math.floor(Number(daysInput.value)) || 0) + Number(button.dataset.step)));

            daysInput.value = next;
            update();
        });
    });

    chips.forEach(function (chip) {
        chip.addEventListener("click", function () {
            daysInput.value = chip.dataset.calcDays;
            update();
        });
    });

    update();
});
