/* ========================================
   소개글(bio) 글자 수 표시
   - textarea[data-bio-input] 와 같은 label 안의 [data-bio-counter]에 "n / 최대" 표시
   - 최대 글자 수를 넘기면 .is-over 로 빨간색 표시
======================================== */
(function () {

    document.querySelectorAll('[data-bio-input]').forEach(function (input) {

        const wrap = input.closest('label') || input.parentElement;
        const counter = wrap ? wrap.querySelector('[data-bio-counter]') : null;
        const max = Number(input.getAttribute('maxlength')) || 50;

        if (!counter) {
            return;
        }

        function update() {
            const length = input.value.length;

            counter.textContent = length + ' / ' + max;
            counter.classList.toggle('is-over', length > max);
        }

        input.addEventListener('input', update);
        update();
    });

})();
