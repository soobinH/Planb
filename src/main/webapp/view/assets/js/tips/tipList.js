document.querySelectorAll("[data-continent-toggle]").forEach(button => {
 
	button.addEventListener("click", function() {
 
		const continent = this.dataset.continentToggle;
 
		const panel = document.querySelector(
			`[data-continent-panel="${continent}"]`
		);
 
		if (panel) {
			panel.classList.toggle("hidden");
 
			if (panel.classList.contains("hidden")) {
				panel.style.display = "none";
			} else {
				panel.style.display = "block";
			}
		}
 
		const chevron = this.querySelector(".continent-chevron");
 
		if (chevron) {
			chevron.classList.toggle("rotate-180");
		}
	});
});
 
// 현재 선택된 나라가 속한 대륙 토글 유지
const countryContinentMap = {
 
	// 아시아
	"대한민국": "asia",
	"일본": "asia",
	"중국": "asia",
	"대만": "asia",
	"홍콩": "asia",
	"태국": "asia",
	"베트남": "asia",
	"필리핀": "asia",
	"싱가포르": "asia",
	"말레이시아": "asia",
	"인도네시아": "asia",
 
	// 유럽
	"그리스": "europe",
	"독일": "europe",
	"스페인": "europe",
	"영국": "europe",
	"이탈리아": "europe",
	"포르투갈": "europe",
	"프랑스": "europe",
 
	// 북아메리카
	"멕시코": "north-america",
	"미국": "north-america",
	"캐나다": "north-america",
 
	// 남아메리카
	"브라질": "south-america",
	"아르헨티나": "south-america",
	"칠레": "south-america",
	"페루": "south-america",
 
	// 아프리카
	"남아프리카": "africa",
	"모로코": "africa",
	"이집트": "africa",
	"케냐": "africa",
 
	// 오세아니아
	"뉴질랜드": "oceania",
	"피지": "oceania",
	"호주": "oceania",
 
	// 중동
	"UAE": "middle-east",
	"터키": "middle-east",
	"이스라엘": "middle-east"
};
 
if (window.selectedCountry) {
 
	const continent = countryContinentMap[window.selectedCountry];
 
	if (continent) {
 
		const panel = document.querySelector(
			`[data-continent-panel="${continent}"]`
		);
 
		const button = document.querySelector(
			`[data-continent-toggle="${continent}"]`
		);
 
		if (panel) {
			panel.classList.remove("hidden");
			panel.style.display = "block";
		}
 
		if (button) {
			const chevron = button.querySelector(".continent-chevron");
 
			if (chevron) {
				chevron.classList.add("rotate-180");
			}
		}
	}
}
 
// ================================
// 카드 미리보기에서 사진 위치 표시([[IMG:n]]) 제거
//  - 글 작성 시 사진 위치가 본문에 [[IMG:1]] 형태로 저장되므로
//    목록 카드의 미리보기 문구에서는 보이지 않게 정리한다.
// ================================
 
function cleanTipPreview(root) {
 
	root.querySelectorAll("p.line-clamp-2").forEach(function (preview) {
 
		const original = preview.textContent;
 
		if (!/\[\[IMG:\d+\]\]/.test(original)) {
			return;
		}
 
		preview.textContent = original
			.replace(/\[\[IMG:\d+\]\]/g, " ")
			.replace(/\s+/g, " ")
			.trim();
	});
}
 
// 처음 화면에 그려진 카드
cleanTipPreview(document);
 
// ================================
// 여행 꿀팁 무한 스크롤
// ================================
 
const infiniteScroll = document.getElementById("tipInfiniteScroll");
const cardGrid = document.querySelector("[data-card-grid]");
const sentinel = document.getElementById("tipScrollSentinel");
const loading = document.getElementById("tipLoading");
const loadComplete = document.getElementById("tipLoadComplete");
 
if (infiniteScroll && cardGrid) {
 
    let currentPage = Number(infiniteScroll.dataset.currentPage);
    let currentCount = Number(infiniteScroll.dataset.currentCount);
    const totalCount = Number(infiniteScroll.dataset.totalCount);
 
    let isLoading = false;
    const loadingStartTime = Date.now();
 
    window.addEventListener("scroll", function () {
 
        if (isLoading) {
            return;
        }
 
        if (currentCount >= totalCount) {
            return;
        }
 
        // 현재 스크롤 위치
        const scrollTop =
            window.pageYOffset ||
            document.documentElement.scrollTop;
 
        // 현재 브라우저 화면 높이
        const windowHeight = window.innerHeight;
 
        // 전체 문서 높이
        const documentHeight =
            document.documentElement.scrollHeight;
 
        /*
         * 실제 페이지 맨 아래 근처까지 내려왔을 때만
         * 다음 페이지를 불러온다.
         */
        if (scrollTop + windowHeight < documentHeight - 30) {
            return;
        }
 
        loadNextPage();
 
    });
 
 
    function loadNextPage() {
 
	    if (isLoading || currentCount >= totalCount) {
	        return;
	    }
	
	    isLoading = true;
	
	    // 로딩 표시
	    if (loading) {
	        loading.classList.remove("hidden");
	        loading.classList.add("flex");
	    }
	
	    // 로딩 시작 시점의 현재 개수 표시
	    const currentCountElement =
	        document.getElementById("tipCurrentCount");
	
	    if (currentCountElement) {
	        currentCountElement.textContent = currentCount;
	    }
	
	    const nextPage = currentPage + 1;
	
	    const params =
	        new URLSearchParams(window.location.search);
	
	    params.set("page", nextPage);
	
	    const loadUrl =
	        window.location.pathname
	        + "/load?"
	        + params.toString();
	
	    fetch(loadUrl)
	
	        .then(function (response) {
	
	            if (!response.ok) {
	                throw new Error(
	                    "여행 꿀팁을 불러오지 못했습니다."
	                );
	            }
	
	            return response.text();
	        })
	
	        .then(function (html) {
	
	            const temp =
	                document.createElement("div");
	
	            temp.innerHTML = html.trim();
	
	            const newCards =
	                Array.from(temp.children);
	
	            /*
	             * 테스트용:
	             * 로딩 화면을 5초 보여준 뒤
	             * 실제 카드를 추가한다.
	             */
	            setTimeout(function () {
	
	                // 더 이상 가져올 게시글이 없는 경우
	                if (newCards.length === 0) {
	
	                    currentCount = totalCount;
	
	                    hideLoading();
	                    showComplete();
	
	                    isLoading = false;
	
	                    return;
	                }
	
	                // 여기서 실제 카드가 추가됨
	                newCards.forEach(function (card) {
 
	                    // 미리보기 문구의 [[IMG:n]] 표시 제거
	                    cleanTipPreview(card);
 
	                    cardGrid.appendChild(card);
	                });
	
	                currentPage = nextPage;
	
	                currentCount = Math.min(
	                    currentCount + newCards.length,
	                    totalCount
	                );
	
	                infiniteScroll.dataset.currentPage =
	                    currentPage;
	
	                infiniteScroll.dataset.currentCount =
	                    currentCount;
	
	                // 카드 추가가 끝난 후 로딩 숨김
	                hideLoading();
	
	                // 마지막 페이지라면 그때 완료 문구 표시
	                if (currentCount >= totalCount) {
	                    showComplete();
	                }
	
	                isLoading = false;
	
	            }, 1000);
	        })
	
	        .catch(function (error) {
	
	            console.error(
	                "무한 스크롤 오류:",
	                error
	            );
	
	            hideLoading();
	
	            isLoading = false;
	        });
	}
	function hideLoading() {
 
	    if (loading) {
	        loading.classList.add("hidden");
	        loading.classList.remove("flex");
	    }
	}
 
 
    function showComplete() {
 
        if (sentinel) {
            sentinel.classList.add("hidden");
        }
 
        const completeCount =
            document.getElementById("tipCompleteCount");
 
        if (completeCount) {
            completeCount.textContent = currentCount;
        }
 
        if (loadComplete) {
 
            loadComplete.classList.remove("hidden");
            loadComplete.classList.add("flex");
        }
    }
}
 
// ================================
// 최상단 이동 버튼
// ================================
 
const tipScrollTopBtn =
	document.getElementById("tipScrollTopBtn");
 
if (tipScrollTopBtn) {
 
	window.addEventListener("scroll", function () {
 
		// 500px 이상 내려가면 버튼 표시
		if (window.scrollY > 500) {
			tipScrollTopBtn.classList.add("show");
		} else {
			tipScrollTopBtn.classList.remove("show");
		}
	});
 
	tipScrollTopBtn.addEventListener("click", function () {
 
		window.scrollTo({
			top: 0,
			behavior: "smooth"
		});
	});
}
 
// =========================
// 뒤로가기로 목록 복원 시 새로고침
// =========================
 
window.addEventListener("pageshow", function(event) {
 
	var navigationEntries = performance.getEntriesByType("navigation");
 
	if (
		event.persisted ||
		(
			navigationEntries.length > 0 &&
			navigationEntries[0].type === "back_forward"
		)
	) {
		window.location.reload();
	}
 
});