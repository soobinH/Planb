// ========================================
// 수정 페이지 - 내용 편집기 (글 사이사이에 사진 삽입)
//
// 저장 방식 (작성 페이지와 동일)
//  - 본문 텍스트 안에 사진 위치를 [[IMG:1]], [[IMG:2]] ... 로 표시해서
//    hidden input(name="content")에 담는다.
//  - [[IMG:n]] 은 "최종 사진 목록"의 n번째 사진이다.
//      · 남아있는 기존 사진 : 원래 순서대로 1, 2, ...
//      · 새로 추가한 사진   : 기존 사진 다음 번호부터 (글에 나온 순서대로)
//  - 새 사진 파일은 같은 순서로 input(name="images")에 담는다.
//  - 삭제한 기존 사진은 deletedMediaIds 로 전달한다.
// ========================================
document.addEventListener("DOMContentLoaded", function () {
 
	const tipImages = document.getElementById("tipImages");
	const tipEditor = document.getElementById("tipEditor");
	const tipContent = document.getElementById("tipContent");
	const tipContentError = document.getElementById("tipContentError");
	const tipImageButton = document.getElementById("tipImageButton");
	const tipImageCount = document.getElementById("tipImageCount");
	const contentSource = document.getElementById("tipContentSource");
	const existingData = document.getElementById("existingMediaData");
	const deletedMediaInputs = document.getElementById("deletedMediaInputs");
 
	if (!tipEditor || !tipImages || !tipContent) {
		return;
	}
 
	const tipEditorForm = tipEditor.closest("form");
 
	const MAX_IMAGES = 5;
 
	// 새로 추가한 사진 : figure id -> File
	const imageFileMap = new Map();
	let imageSeq = 0;
 
	// 편집기 안에서 마지막으로 커서가 있던 위치
	let savedRange = null;
 
	// 기존 사진 목록 (DB에 저장된 순서 그대로)
	const existingMedia = Array.from(
		existingData ? existingData.querySelectorAll("[data-media-id]") : []
	).map(function (element) {
		return {
			id: element.dataset.mediaId,
			url: element.dataset.url
		};
	});
 
	const existingOrder = existingMedia.map(function (media) {
		return media.id;
	});
 
	// 줄바꿈 시 <div> 로 줄을 구분
	document.execCommand("defaultParagraphSeparator", false, "div");
 
 
	// ========================================
	// 줄 / 사진 요소 생성
	// ========================================
	function createEmptyLine() {
 
		const line = document.createElement("div");
		line.appendChild(document.createElement("br"));
 
		return line;
	}
 
	function createTextLine(text) {
 
		const line = document.createElement("div");
 
		if (text === "") {
			line.appendChild(document.createElement("br"));
		} else {
			line.textContent = text;
		}
 
		return line;
	}
 
	function createRemoveButton() {
 
		const removeButton = document.createElement("button");
		removeButton.type = "button";
		removeButton.className = "tip-editor-image-remove";
		removeButton.setAttribute("aria-label", "사진 삭제");
		removeButton.textContent = "×";
 
		return removeButton;
	}
 
	// 기존(이미 저장된) 사진
	function createExistingFigure(media) {
 
		const figure = document.createElement("figure");
		figure.className = "tip-editor-image";
		figure.contentEditable = "false";
		figure.dataset.existingId = media.id;
 
		const img = document.createElement("img");
		img.src = media.url;
		img.alt = "등록된 이미지";
		img.draggable = false;
 
		figure.appendChild(img);
		figure.appendChild(createRemoveButton());
 
		return figure;
	}
 
	// 새로 추가한 사진
	function createNewFigure(file) {
 
		const id = "img" + (++imageSeq);
 
		imageFileMap.set(id, file);
 
		const figure = document.createElement("figure");
		figure.className = "tip-editor-image";
		figure.contentEditable = "false";
		figure.dataset.id = id;
 
		const img = document.createElement("img");
		img.src = URL.createObjectURL(file);
		img.alt = "첨부 이미지";
		img.draggable = false;
 
		figure.appendChild(img);
		figure.appendChild(createRemoveButton());
 
		return figure;
	}
 
 
	// ========================================
	// 기존 글 → 편집기 초기 내용 만들기
	//  - 본문의 [[IMG:n]] 위치에 n번째 기존 사진을 넣는다.
	//  - [[IMG:n]] 이 없는 예전 글은 사진을 글 맨 아래에 둔다.
	// ========================================
	function buildInitialEditor() {
 
		const text = (contentSource ? contentSource.value : "")
			.replace(/\r\n?/g, "\n");
 
		const pattern = /\[\[IMG:(\d+)\]\]/g;
 
		const parts = [];
		let last = 0;
		let match;
 
		while ((match = pattern.exec(text)) !== null) {
			parts.push({ type: "text", value: text.slice(last, match.index) });
			parts.push({ type: "img", number: parseInt(match[1], 10) });
			last = pattern.lastIndex;
		}
 
		parts.push({ type: "text", value: text.slice(last) });
 
		const usedIds = new Set();
 
		tipEditor.innerHTML = "";
 
		parts.forEach(function (part, index) {
 
			if (part.type === "img") {
 
				const media = existingMedia[part.number - 1];
 
				if (media && !usedIds.has(media.id)) {
					usedIds.add(media.id);
					tipEditor.appendChild(createExistingFigure(media));
				}
 
				return;
			}
 
			let value = part.value;
 
			// 사진 표시 앞뒤의 줄바꿈 하나는 저장할 때 붙은 것이므로 제거
			if (index > 0) {
				value = value.replace(/^\n/, "");
			}
 
			if (index < parts.length - 1) {
				value = value.replace(/\n$/, "");
			}
 
			if (value === "") {
				return;
			}
 
			value.split("\n").forEach(function (line) {
				tipEditor.appendChild(createTextLine(line));
			});
		});
 
		// 본문에 표시가 없는 기존 사진(예전 글 등)은 맨 아래에 이어서 배치
		existingMedia.forEach(function (media) {
 
			if (!usedIds.has(media.id)) {
				tipEditor.appendChild(createExistingFigure(media));
			}
		});
 
		if (tipEditor.childNodes.length === 0) {
			tipEditor.innerHTML = "<div><br></div>";
		}
	}
 
 
	// ========================================
	// 커서 위치 기억
	// ========================================
	document.addEventListener("selectionchange", function () {
 
		const selection = window.getSelection();
 
		if (selection.rangeCount > 0 && tipEditor.contains(selection.anchorNode)) {
			savedRange = selection.getRangeAt(0).cloneRange();
		}
	});
 
 
	// ========================================
	// 사진 추가 버튼 → 파일 선택창
	// ========================================
	tipImageButton.addEventListener("mousedown", function (event) {
		// 버튼을 눌러도 편집기의 커서가 사라지지 않도록
		event.preventDefault();
	});
 
	tipImageButton.addEventListener("click", function () {
		tipImages.click();
	});
 
	tipImages.addEventListener("change", function () {
 
		const files = Array.from(this.files);
 
		// 같은 파일을 다시 선택할 수 있도록 초기화
		this.value = "";
 
		insertImages(files);
	});
 
 
	// ========================================
	// 여러 장 삽입 (기존 + 새 사진 합쳐 최대 5장)
	// ========================================
	function countFigures() {
		return tipEditor.querySelectorAll("figure.tip-editor-image").length;
	}
 
	function insertImages(files) {
 
		for (const file of files) {
 
			// 이미지만 허용
			if (!file.type.startsWith("image/")) {
				continue;
			}
 
			if (countFigures() >= MAX_IMAGES) {
				alert("사진은 기존 사진과 새 사진을 합쳐 최대 5장까지 첨부할 수 있습니다.");
				break;
			}
 
			insertFigureAtCaret(createNewFigure(file));
		}
 
		updateEditorState();
	}
 
 
	// ========================================
	// 사진 삭제 (× 버튼)
	//  - 기존 사진 삭제 여부는 등록 시점에 화면에 남아있는지로 판단한다.
	// ========================================
	tipEditor.addEventListener("click", function (event) {
 
		const removeButton = event.target.closest(".tip-editor-image-remove");
 
		if (!removeButton) {
			return;
		}
 
		const figure = removeButton.closest("figure.tip-editor-image");
 
		if (!figure) {
			return;
		}
 
		// 새로 추가한 사진이면 파일 정보도 정리
		if (figure.dataset.id) {
 
			const img = figure.querySelector("img");
 
			if (img) {
				URL.revokeObjectURL(img.src);
			}
 
			imageFileMap.delete(figure.dataset.id);
		}
 
		figure.remove();
 
		// 편집기가 완전히 비면 기본 줄 하나 유지
		if (tipEditor.childNodes.length === 0) {
			tipEditor.innerHTML = "<div><br></div>";
		}
 
		updateEditorState();
	});
 
 
	// ========================================
	// 삽입할 위치(Range) 가져오기
	// ========================================
	function getInsertRange() {
 
		let range = savedRange;
 
		if (!range || !tipEditor.contains(range.startContainer)) {
 
			// 커서 기록이 없으면 맨 끝
			range = document.createRange();
			range.selectNodeContents(tipEditor);
			range.collapse(false);
		}
 
		// 글자를 드래그로 선택한 상태여도 지우지 않고 선택 끝에 삽입
		range = range.cloneRange();
		range.collapse(false);
 
		return range;
	}
 
 
	// ========================================
	// 커서 위치에 사진 삽입
	//  - 줄 중간이면 그 줄을 둘로 나눠서 사이에 사진을 넣는다.
	// ========================================
	function insertFigureAtCaret(figure) {
 
		const range = getInsertRange();
 
		let afterLine = null;
 
		if (range.startContainer === tipEditor) {
 
			// 줄(div) 사이에 커서가 있는 경우
			const ref = tipEditor.childNodes[range.startOffset] || null;
 
			tipEditor.insertBefore(figure, ref);
 
			if (figure.nextSibling && figure.nextSibling.nodeName === "DIV") {
				afterLine = figure.nextSibling;
			}
 
		} else {
 
			const container = range.startContainer;
			const offset = range.startOffset;
 
			// 편집기 바로 아래 줄(top) 찾기
			let top = container;
 
			while (top.parentNode !== tipEditor) {
				top = top.parentNode;
			}
 
			// 줄(div) 없이 글자만 있는 경우 div 로 감싸기
			if (top.nodeType === Node.TEXT_NODE) {
 
				const wrapper = document.createElement("div");
 
				tipEditor.insertBefore(wrapper, top);
				wrapper.appendChild(top);
 
				top = wrapper;
 
				range.setStart(container, offset);
				range.collapse(true);
			}
 
			// 커서 뒤쪽 내용을 새 줄로 분리
			const tail = document.createRange();
			tail.setStart(range.startContainer, range.startOffset);
			tail.setEnd(top, top.childNodes.length);
 
			afterLine = document.createElement("div");
			afterLine.appendChild(tail.extractContents());
 
			if (!afterLine.textContent && !afterLine.querySelector("br")) {
				afterLine.appendChild(document.createElement("br"));
			}
 
			top.after(figure);
			figure.after(afterLine);
 
			// 앞쪽 줄이 비었으면 제거
			if (!top.textContent.trim() && !top.querySelector("figure")) {
				top.remove();
			}
		}
 
		// 사진 아래에 항상 글을 이어서 쓸 수 있는 줄 확보
		if (!afterLine) {
 
			afterLine = createEmptyLine();
 
			figure.after(afterLine);
		}
 
		// 커서를 사진 다음 줄로 이동
		const caret = document.createRange();
		caret.setStart(afterLine, 0);
		caret.collapse(true);
 
		const selection = window.getSelection();
		selection.removeAllRanges();
		selection.addRange(caret);
 
		savedRange = caret.cloneRange();
	}
 
 
	// ========================================
	// 사진 위 / 아래에는 항상 글을 쓸 수 있는 줄이 있도록 보장
	// ========================================
	function ensureEditableLines() {
 
		tipEditor.querySelectorAll("figure.tip-editor-image").forEach(function (figure) {
 
			const prev = figure.previousElementSibling;
			const next = figure.nextElementSibling;
 
			if (!prev || prev.matches("figure.tip-editor-image")) {
				figure.before(createEmptyLine());
			}
 
			if (!next || next.matches("figure.tip-editor-image")) {
				figure.after(createEmptyLine());
			}
		});
	}
 
 
	// ========================================
	// 상태 갱신 (placeholder / 사진 개수 / 대표 이미지 표시)
	// ========================================
	function updateEditorState() {
 
		ensureEditableLines();
 
		const figures = Array.from(
			tipEditor.querySelectorAll("figure.tip-editor-image")
		);
 
		tipImageCount.textContent = figures.length + "/" + MAX_IMAGES;
 
		// 대표 이미지 : 남아있는 기존 사진 중 가장 앞 사진
		// (없으면 글에서 가장 먼저 나오는 새 사진)
		let representative = null;
 
		for (const id of existingOrder) {
 
			const found = tipEditor.querySelector(
				'figure[data-existing-id="' + id + '"]'
			);
 
			if (found) {
				representative = found;
				break;
			}
		}
 
		if (!representative && figures.length > 0) {
			representative = figures[0];
		}
 
		figures.forEach(function (figure) {
			figure.classList.toggle("is-representative", figure === representative);
		});
 
		tipEditor.classList.toggle(
			"is-empty",
			figures.length === 0 && tipEditor.textContent.trim() === ""
		);
	}
 
	tipEditor.addEventListener("input", function () {
		tipContentError.classList.add("hidden");
		updateEditorState();
	});
 
	// 키보드로 사진이 지워지는 경우 등도 반영
	new MutationObserver(updateEditorState).observe(tipEditor, {
		childList: true,
		subtree: true,
		characterData: true
	});
 
 
	// ========================================
	// 붙여넣기 : 서식 없이 글자만
	// ========================================
	tipEditor.addEventListener("paste", function (event) {
 
		event.preventDefault();
 
		const text = (event.clipboardData || window.clipboardData).getData("text/plain");
 
		document.execCommand("insertText", false, text);
	});
 
 
	// ========================================
	// 사진 파일을 글 안으로 드래그 앤 드롭
	// ========================================
	tipEditor.addEventListener("dragover", function (event) {
 
		if (event.dataTransfer && Array.from(event.dataTransfer.types).includes("Files")) {
			event.preventDefault();
		}
	});
 
	tipEditor.addEventListener("drop", function (event) {
 
		const files = Array.from(event.dataTransfer.files || [])
			.filter(function (file) {
				return file.type.startsWith("image/");
			});
 
		if (files.length === 0) {
			return;
		}
 
		event.preventDefault();
 
		// 놓은 위치로 커서 이동
		let dropRange = null;
 
		if (document.caretRangeFromPoint) {
			dropRange = document.caretRangeFromPoint(event.clientX, event.clientY);
		} else if (document.caretPositionFromPoint) {
			const position = document.caretPositionFromPoint(event.clientX, event.clientY);
 
			if (position) {
				dropRange = document.createRange();
				dropRange.setStart(position.offsetNode, position.offset);
				dropRange.collapse(true);
			}
		}
 
		if (dropRange && tipEditor.contains(dropRange.startContainer)) {
			savedRange = dropRange;
		}
 
		insertImages(files);
	});
 
 
	// ========================================
	// 편집기 내용 → { text, files, remainingIds }
	//  - 남아있는 기존 사진 : 원래 순서대로 1, 2, ...
	//  - 새 사진 : 기존 사진 다음 번호부터, 글에 나온 순서대로
	// ========================================
	function serializeEditor() {
 
		// 화면에 남아있는 기존 사진 (원래 순서)
		const remainingIds = existingOrder.filter(function (id) {
			return tipEditor.querySelector('figure[data-existing-id="' + id + '"]');
		});
 
		const result = {
			text: "",
			files: [],
			remainingIds: remainingIds
		};
 
		const seenExisting = new Set();
 
		function endLine() {
			if (result.text !== "" && !result.text.endsWith("\n")) {
				result.text += "\n";
			}
		}
 
		function walk(parent) {
 
			parent.childNodes.forEach(function (node) {
 
				if (node.nodeType === Node.TEXT_NODE) {
					result.text += node.nodeValue;
					return;
				}
 
				if (node.nodeType !== Node.ELEMENT_NODE) {
					return;
				}
 
				// 사진
				if (node.matches("figure.tip-editor-image")) {
 
					let number = 0;
 
					if (node.dataset.existingId) {
 
						// 기존 사진
						const id = node.dataset.existingId;
 
						if (seenExisting.has(id)) {
							return;
						}
 
						seenExisting.add(id);
						number = remainingIds.indexOf(id) + 1;
 
					} else {
 
						// 새 사진
						const file = imageFileMap.get(node.dataset.id);
 
						if (!file) {
							return;
						}
 
						result.files.push(file);
						number = remainingIds.length + result.files.length;
					}
 
					if (number > 0) {
						endLine();
						result.text += "[[IMG:" + number + "]]\n";
					}
 
					return;
				}
 
				// 줄바꿈
				if (node.tagName === "BR") {
					result.text += "\n";
					return;
				}
 
				// 줄(div, p)
				const isBlock = node.tagName === "DIV" || node.tagName === "P";
 
				if (isBlock) {
					endLine();
				}
 
				walk(node);
 
				if (isBlock) {
					endLine();
				}
			});
		}
 
		walk(tipEditor);
 
		// 줄 앞뒤 공백 정리 (&nbsp; 포함)
		result.text = result.text.replace(/\u00A0/g, " ").trim();
 
		return result;
	}
 
 
	// ========================================
	// 수정 시 : 편집기 내용을 hidden 값 / 파일 목록으로 변환
	// ========================================
	tipEditorForm.addEventListener("submit", function (event) {
 
		const result = serializeEditor();
 
		const plainText = result.text.replace(/\[\[IMG:\d+\]\]/g, "").trim();
 
		// 본문 글자는 필수
		if (plainText === "") {
 
			event.preventDefault();
 
			tipContentError.classList.remove("hidden");
			tipEditor.focus();
 
			return;
		}
 
		tipContent.value = result.text;
 
		// 화면에서 지운 기존 사진 → 서버로 삭제 요청
		if (deletedMediaInputs) {
 
			deletedMediaInputs.innerHTML = "";
 
			existingOrder.forEach(function (id) {
 
				if (result.remainingIds.includes(id)) {
					return;
				}
 
				const hiddenInput = document.createElement("input");
 
				hiddenInput.type = "hidden";
				hiddenInput.name = "deletedMediaIds";
				hiddenInput.value = id;
 
				deletedMediaInputs.appendChild(hiddenInput);
			});
		}
 
		// 새 사진은 글에 나온 순서대로 전송
		const dataTransfer = new DataTransfer();
 
		result.files.forEach(function (file) {
			dataTransfer.items.add(file);
		});
 
		tipImages.files = dataTransfer.files;
	});
 
 
	// ========================================
	// 시작
	// ========================================
	buildInitialEditor();
	updateEditorState();
});
 
// ========================================
// 수정 페이지 - 여행지 나라 / 도시
// ========================================
document.addEventListener("DOMContentLoaded", function () {
 
	const travelLocations = {
 
		"대한민국": [
			"서울",
			"부산",
			"제주",
			"경주",
			"강릉",
			"인천",
			"전주",
			"여수"
		],
 
		"일본": [
			"도쿄",
			"오사카",
			"교토",
			"후쿠오카",
			"삿포로",
			"오키나와",
			"나고야"
		],
 
		"중국": [
			"베이징",
			"상하이",
			"칭다오",
			"광저우"
		],
 
		"대만": [
			"타이베이",
			"타이중",
			"가오슝"
		],
 
		"태국": [
			"방콕",
			"치앙마이",
			"푸켓",
			"파타야"
		],
 
		"베트남": [
			"다낭",
			"하노이",
			"호치민",
			"나트랑"
		],
 
		"싱가포르": [
			"싱가포르"
		],
 
		"미국": [
			"뉴욕",
			"로스앤젤레스",
			"샌프란시스코",
			"라스베이거스",
			"하와이"
		],
 
		"캐나다": [
			"밴쿠버",
			"토론토",
			"몬트리올"
		],
 
		"프랑스": [
			"파리",
			"니스",
			"리옹",
			"마르세유"
		],
 
		"이탈리아": [
			"로마",
			"밀라노",
			"베네치아",
			"피렌체"
		],
 
		"스페인": [
			"바르셀로나",
			"마드리드",
			"세비야"
		],
 
		"영국": [
			"런던",
			"맨체스터",
			"에든버러"
		],
 
		"독일": [
			"베를린",
			"뮌헨",
			"프랑크푸르트"
		],
 
		"호주": [
			"시드니",
			"멜버른",
			"브리즈번",
			"골드코스트"
		]
	};
 
 
	const form =
		document.querySelector('form[action$="/tipModify"]');
 
	const countryInput =
		document.getElementById("countryInput");
 
	const countryValue =
		document.getElementById("country");
 
	const countrySuggestions =
		document.getElementById("countrySuggestions");
 
	const countryError =
		document.getElementById("countryError");
 
	const cityInput =
		document.getElementById("cityInput");
 
	const cityValue =
		document.getElementById("city");
 
	const citySuggestions =
		document.getElementById("citySuggestions");
 
	const cityError =
		document.getElementById("cityError");
 
 
	if (
		!form
		|| !countryInput
		|| !countryValue
		|| !cityInput
		|| !cityValue
	) {
		return;
	}
 
 
	// ========================================
	// 추천 태그 생성
	// ========================================
	function createSuggestionButton(text, clickHandler) {
 
		const button =
			document.createElement("button");
 
		button.type = "button";
		button.textContent = text;
 
		button.style.padding = "6px 12px";
		button.style.borderRadius = "9999px";
		button.style.border = "1px solid #D1D2F9";
		button.style.background = "#FAFAFF";
		button.style.color = "#6369D1";
		button.style.fontSize = "12px";
		button.style.fontWeight = "600";
		button.style.cursor = "pointer";
 
		button.addEventListener(
			"click",
			clickHandler
		);
 
		return button;
	}
 
 
	// ========================================
// 나라 추천
// ========================================
function renderCountrySuggestions() {
 
	const keyword =
		countryInput.value.trim();
 
	countrySuggestions.innerHTML = "";
 
	// 아무것도 입력하지 않았으면 태그 표시 안 함
	if (keyword === "") {
		return;
	}
 
	Object.keys(travelLocations).forEach(function (country) {
 
		if (!country.includes(keyword)) {
			return;
		}
 
		const button =
			createSuggestionButton(
				country,
				function () {
 
					countryInput.value =
						country;
 
					countryValue.value =
						country;
 
					countrySuggestions.innerHTML =
						"";
 
					clearCountryError();
 
					// 나라 선택 후 도시 다시 선택
					cityInput.disabled =
						false;
 
					cityInput.value =
						"";
 
					cityValue.value =
						"";
 
					citySuggestions.innerHTML =
						"";
 
					cityInput.focus();
				}
			);
 
		countrySuggestions.appendChild(
			button
		);
	});
}
 
// ========================================
// 나라 입력
// ========================================
countryInput.addEventListener("input", function () {
 
	// 직접 타이핑하기 시작하면 기존 선택값 해제
	countryValue.value = "";
 
	// 나라를 변경하는 중이므로 기존 도시도 해제
	cityInput.value = "";
	cityValue.value = "";
	cityInput.disabled = true;
 
	countrySuggestions.innerHTML = "";
	citySuggestions.innerHTML = "";
 
	clearCountryError();
	clearCityError();
 
	renderCountrySuggestions();
});
 
// ========================================
// 도시 검색
// ========================================
cityInput.addEventListener("input", function () {
 
	const keyword =
		this.value.trim();
 
	cityValue.value = "";
 
	citySuggestions.innerHTML = "";
 
	clearCityError();
 
	const selectedCountry =
			countryValue.value;
 
	if (
		selectedCountry === ""
		|| keyword === ""
	) {
		return;
	}
 
	const cities =
		travelLocations[selectedCountry] || [];
 
	const matchedCities =
		cities.filter(function (city) {
			return city.includes(keyword);
		});
 
	matchedCities.forEach(function (city) {
 
		const button =
			createSuggestionButton(
				city,
					function () {
 
					cityInput.value =
						city;
 
					cityValue.value =
						city;
 
					citySuggestions.innerHTML =
							"";
 
					clearCityError();
				}
			);
 
		citySuggestions.appendChild(
			button
		);
	});
});
 
 
	// ========================================
	// 오류 표시
	// ========================================
	function showCountryError() {
 
		countryInput.style.border =
			"1.5px solid #ef4444";
 
		countryError.classList.remove(
			"hidden"
		);
	}
 
 
	function clearCountryError() {
 
		countryInput.style.border =
			"1.5px solid #D1D2F9";
 
		countryError.classList.add(
			"hidden"
		);
	}
 
 
	function showCityError() {
 
		cityInput.style.border =
			"1.5px solid #ef4444";
 
		cityError.classList.remove(
			"hidden"
		);
	}
 
 
	function clearCityError() {
 
		cityInput.style.border =
			"1.5px solid #D1D2F9";
 
		cityError.classList.add(
			"hidden"
		);
	}
 
 
	// ========================================
	// 수정하기 전 최종 검사
	// ========================================
	form.addEventListener("submit", function (event) {
 
		if (countryValue.value.trim() === "") {
 
			event.preventDefault();
 
			showCountryError();
 
			countryInput.scrollIntoView({
				behavior: "smooth",
				block: "center"
			});
 
			setTimeout(function () {
				countryInput.focus();
			}, 300);
 
			return;
		}
 
 
		if (cityValue.value.trim() === "") {
 
			event.preventDefault();
 
			showCityError();
 
			cityInput.scrollIntoView({
				behavior: "smooth",
				block: "center"
			});
 
			setTimeout(function () {
				cityInput.focus();
			}, 300);
		}
	});
 
});
 
console.log("tipModify.js 로드됨");
 
document.addEventListener("DOMContentLoaded", function () {
 
	console.log("여행지 JS 시작");
 
	const countryInput =
		document.getElementById("countryInput");
 
	const countrySuggestions =
		document.getElementById("countrySuggestions");
 
	console.log("countryInput =", countryInput);
	console.log("countrySuggestions =", countrySuggestions);
 
});
 