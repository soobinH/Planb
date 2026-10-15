// ========================================
// 여행꿀팁 / 여행메이트 글쓰기·수정 공통 편집기
//
// 글 사이사이에 사진을 넣는 편집기
//
// 저장 방식
//  - 본문 텍스트 안에 사진 위치를 [[IMG:1]], [[IMG:2]] ... 로 표시해서
//    hidden input(content)에 담는다.
//  - [[IMG:n]] 은 "최종 사진 목록"의 n번째 사진이다.
//      · 남아있는 기존 사진 : 원래(DB) 순서대로 1, 2, ...
//      · 새로 추가한 사진   : 기존 사진 다음 번호부터 (글에 나온 순서대로)
//  - 새 사진 파일은 같은 순서로 input(images)에 담는다.
//  - 수정 화면에서 지운 기존 사진은 deletedMediaIds 로 전달한다.
//  - 서버는 저장 후 사진 순서를 글에 나온 순서대로 다시 정렬하므로
//    작성 / 수정 모두 "글 맨 위 사진 = 대표 이미지" 이다.
//
// 사용
//  PostEditor.init({
//      editor: "postEditor",            // contenteditable 영역
//      fileInput: "postImages",         // input[type=file][name=images]
//      contentInput: "postContent",     // hidden input[name=content]
//      error: "postContentError",       // 내용 미입력 안내
//      addButton: "postImageButton",    // 사진 추가 버튼
//      count: "postImageCount",         // "0/5"
//      source: "postContentSource",     // (수정) 기존 본문 textarea
//      existing: "existingMediaData",   // (수정) 기존 사진 목록
//      deleted: "deletedMediaInputs"    // (수정) 삭제 사진 hidden input 영역
//  });
// ========================================
(function (global) {

	var MAX_IMAGES = 5;

	var FIGURE = "figure.post-editor-image";

	function byId(id) {
		return id ? document.getElementById(id) : null;
	}

	function init(options) {

		var editor = byId(options.editor);
		var fileInput = byId(options.fileInput);
		var contentInput = byId(options.contentInput);
		var errorElement = byId(options.error);
		var addButton = byId(options.addButton);
		var countElement = byId(options.count);
		var contentSource = byId(options.source);
		var existingData = byId(options.existing);
		var deletedInputs = byId(options.deleted);

		if (!editor || !fileInput || !contentInput) {
			return;
		}

		var form = editor.closest("form");

		// 새로 추가한 사진 : figure id -> File
		var imageFileMap = new Map();
		var imageSeq = 0;

		// 편집기 안에서 마지막으로 커서가 있던 위치
		var savedRange = null;

		// 기존 사진 목록 (DB에 저장된 순서 그대로)
		var existingMedia = Array.from(
			existingData ? existingData.querySelectorAll("[data-media-id]") : []
		).map(function (element) {
			return {
				id: element.dataset.mediaId,
				url: element.dataset.url
			};
		});

		var existingOrder = existingMedia.map(function (media) {
			return media.id;
		});

		// 줄바꿈 시 <div> 로 줄을 구분
		document.execCommand("defaultParagraphSeparator", false, "div");

		// ========================================
		// 줄 / 사진 요소 생성
		// ========================================
		function createEmptyLine() {
			var line = document.createElement("div");
			line.appendChild(document.createElement("br"));
			return line;
		}

		function createTextLine(text) {
			var line = document.createElement("div");

			if (text === "") {
				line.appendChild(document.createElement("br"));
			} else {
				line.textContent = text;
			}

			return line;
		}

		function createFigure(src) {
			var figure = document.createElement("figure");
			figure.className = "post-editor-image";
			figure.contentEditable = "false";

			var img = document.createElement("img");
			img.src = src;
			img.alt = "첨부 이미지";
			img.draggable = false;

			var removeButton = document.createElement("button");
			removeButton.type = "button";
			removeButton.className = "post-editor-image-remove";
			removeButton.setAttribute("aria-label", "사진 삭제");
			removeButton.textContent = "×";

			figure.appendChild(img);
			figure.appendChild(removeButton);

			return figure;
		}

		// 기존(이미 저장된) 사진
		function createExistingFigure(media) {
			var figure = createFigure(media.url);
			figure.dataset.existingId = media.id;
			return figure;
		}

		// 새로 추가한 사진
		function createNewFigure(file) {
			var id = "img" + (++imageSeq);
			imageFileMap.set(id, file);

			var figure = createFigure(URL.createObjectURL(file));
			figure.dataset.id = id;
			return figure;
		}

		// ========================================
		// 기존 글 → 편집기 초기 내용
		//  - 본문의 [[IMG:n]] 위치에 n번째 기존 사진을 넣는다.
		//  - [[IMG:n]] 이 없는 예전 글은 사진을 글 맨 아래에 둔다.
		// ========================================
		function buildInitialEditor() {

			var text = (contentSource ? contentSource.value : "").replace(/\r\n?/g, "\n");

			editor.innerHTML = "";

			if (text.trim() === "" && existingMedia.length === 0) {
				editor.appendChild(createEmptyLine());
				return;
			}

			var pattern = /\[\[IMG:(\d+)\]\]/g;
			var parts = [];
			var last = 0;
			var match;

			while ((match = pattern.exec(text)) !== null) {
				parts.push({ type: "text", value: text.slice(last, match.index) });
				parts.push({ type: "img", number: parseInt(match[1], 10) });
				last = pattern.lastIndex;
			}

			parts.push({ type: "text", value: text.slice(last) });

			var usedIds = new Set();

			parts.forEach(function (part, index) {

				if (part.type === "img") {
					var media = existingMedia[part.number - 1];

					if (media && !usedIds.has(media.id)) {
						usedIds.add(media.id);
						editor.appendChild(createExistingFigure(media));
					}
					return;
				}

				var value = part.value;

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
					editor.appendChild(createTextLine(line));
				});
			});

			// 본문에 표시가 없는 기존 사진(예전 글 등)은 맨 아래에 이어서 배치
			existingMedia.forEach(function (media) {
				if (!usedIds.has(media.id)) {
					editor.appendChild(createExistingFigure(media));
				}
			});

			if (editor.childNodes.length === 0) {
				editor.appendChild(createEmptyLine());
			}
		}

		// ========================================
		// 커서 위치 기억
		// ========================================
		document.addEventListener("selectionchange", function () {
			var selection = window.getSelection();

			if (selection.rangeCount > 0 && editor.contains(selection.anchorNode)) {
				savedRange = selection.getRangeAt(0).cloneRange();
			}
		});

		// ========================================
		// 사진 추가 버튼 → 파일 선택창
		// ========================================
		if (addButton) {

			addButton.addEventListener("mousedown", function (event) {
				// 버튼을 눌러도 편집기의 커서가 사라지지 않도록
				event.preventDefault();
			});

			addButton.addEventListener("click", function () {
				fileInput.click();
			});
		}

		fileInput.addEventListener("change", function () {
			var files = Array.from(this.files);

			// 같은 파일을 다시 선택할 수 있도록 초기화
			this.value = "";

			insertImages(files);
		});

		// ========================================
		// 여러 장 삽입 (기존 + 새 사진 합쳐 최대 5장)
		// ========================================
		function countFigures() {
			return editor.querySelectorAll(FIGURE).length;
		}

		function insertImages(files) {

			for (var i = 0; i < files.length; i++) {

				var file = files[i];

				if (!file.type.startsWith("image/")) {
					continue;
				}

				if (countFigures() >= MAX_IMAGES) {
					alert("사진은 최대 " + MAX_IMAGES + "장까지 첨부할 수 있습니다.");
					break;
				}

				insertFigureAtCaret(createNewFigure(file));
			}

			updateEditorState();
		}

		// ========================================
		// 사진 삭제 (× 버튼)
		// ========================================
		editor.addEventListener("click", function (event) {

			var removeButton = event.target.closest(".post-editor-image-remove");

			if (!removeButton) {
				return;
			}

			var figure = removeButton.closest(FIGURE);

			if (!figure) {
				return;
			}

			// 새로 추가한 사진이면 파일 정보도 정리
			if (figure.dataset.id) {
				var img = figure.querySelector("img");

				if (img) {
					URL.revokeObjectURL(img.src);
				}

				imageFileMap.delete(figure.dataset.id);
			}

			figure.remove();

			if (editor.childNodes.length === 0) {
				editor.appendChild(createEmptyLine());
			}

			updateEditorState();
		});

		// ========================================
		// 삽입할 위치(Range)
		// ========================================
		function getInsertRange() {

			var range = savedRange;

			if (!range || !editor.contains(range.startContainer)) {
				// 커서 기록이 없으면 맨 끝
				range = document.createRange();
				range.selectNodeContents(editor);
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

			var range = getInsertRange();
			var afterLine = null;

			if (range.startContainer === editor) {

				// 줄(div) 사이에 커서가 있는 경우
				var ref = editor.childNodes[range.startOffset] || null;
				editor.insertBefore(figure, ref);

				if (figure.nextSibling && figure.nextSibling.nodeName === "DIV") {
					afterLine = figure.nextSibling;
				}

			} else {

				var container = range.startContainer;
				var offset = range.startOffset;

				// 편집기 바로 아래 줄(top) 찾기
				var top = container;

				while (top.parentNode !== editor) {
					top = top.parentNode;
				}

				// 줄(div) 없이 글자만 있는 경우 div 로 감싸기
				if (top.nodeType === Node.TEXT_NODE) {
					var wrapper = document.createElement("div");
					editor.insertBefore(wrapper, top);
					wrapper.appendChild(top);
					top = wrapper;

					range.setStart(container, offset);
					range.collapse(true);
				}

				// 커서 뒤쪽 내용을 새 줄로 분리
				var tail = document.createRange();
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
			var caret = document.createRange();
			caret.setStart(afterLine, 0);
			caret.collapse(true);

			var selection = window.getSelection();
			selection.removeAllRanges();
			selection.addRange(caret);

			savedRange = caret.cloneRange();
		}

		// ========================================
		// 사진 위 / 아래에는 항상 글을 쓸 수 있는 줄 보장
		// ========================================
		function ensureEditableLines() {

			editor.querySelectorAll(FIGURE).forEach(function (figure) {

				var prev = figure.previousElementSibling;
				var next = figure.nextElementSibling;

				if (!prev || prev.matches(FIGURE)) {
					figure.before(createEmptyLine());
				}

				if (!next || next.matches(FIGURE)) {
					figure.after(createEmptyLine());
				}
			});
		}

		// ========================================
		// 상태 갱신 (placeholder / 사진 개수 / 대표 이미지)
		//  - 대표 이미지 : 글에서 가장 먼저 나오는 사진 (작성 / 수정 동일)
		// ========================================
		var updating = false;

		function updateEditorState() {

			if (updating) {
				return;
			}

			updating = true;

			ensureEditableLines();

			var figures = Array.from(editor.querySelectorAll(FIGURE));

			if (countElement) {
				countElement.textContent = figures.length + "/" + MAX_IMAGES;
			}

			figures.forEach(function (figure, index) {
				figure.classList.toggle("is-representative", index === 0);
			});

			editor.classList.toggle(
				"is-empty",
				figures.length === 0 && editor.textContent.trim() === ""
			);

			updating = false;
		}

		editor.addEventListener("input", function () {
			if (errorElement) {
				errorElement.hidden = true;
			}
			updateEditorState();
		});

		// 키보드로 사진이 지워지는 경우 등도 반영
		new MutationObserver(updateEditorState).observe(editor, {
			childList: true,
			subtree: true,
			characterData: true
		});

		// ========================================
		// 붙여넣기 : 서식 없이 글자만
		// ========================================
		editor.addEventListener("paste", function (event) {
			event.preventDefault();

			var text = (event.clipboardData || window.clipboardData).getData("text/plain");

			document.execCommand("insertText", false, text);
		});

		// ========================================
		// 사진 파일을 글 안으로 드래그 앤 드롭
		// ========================================
		editor.addEventListener("dragover", function (event) {
			if (event.dataTransfer && Array.from(event.dataTransfer.types).includes("Files")) {
				event.preventDefault();
				editor.classList.add("is-dragover");
			}
		});

		editor.addEventListener("dragleave", function () {
			editor.classList.remove("is-dragover");
		});

		editor.addEventListener("drop", function (event) {

			editor.classList.remove("is-dragover");

			var files = Array.from(event.dataTransfer.files || []).filter(function (file) {
				return file.type.startsWith("image/");
			});

			if (files.length === 0) {
				return;
			}

			event.preventDefault();

			// 놓은 위치로 커서 이동
			var dropRange = null;

			if (document.caretRangeFromPoint) {
				dropRange = document.caretRangeFromPoint(event.clientX, event.clientY);
			} else if (document.caretPositionFromPoint) {
				var position = document.caretPositionFromPoint(event.clientX, event.clientY);

				if (position) {
					dropRange = document.createRange();
					dropRange.setStart(position.offsetNode, position.offset);
					dropRange.collapse(true);
				}
			}

			if (dropRange && editor.contains(dropRange.startContainer)) {
				savedRange = dropRange;
			}

			insertImages(files);
		});

		// ========================================
		// 편집기 내용 → { text, files, remainingIds }
		// ========================================
		function serializeEditor() {

			// 화면에 남아있는 기존 사진 (원래 순서)
			var remainingIds = existingOrder.filter(function (id) {
				return editor.querySelector('figure[data-existing-id="' + id + '"]');
			});

			var result = {
				text: "",
				files: [],
				remainingIds: remainingIds
			};

			var seenExisting = new Set();

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
					if (node.matches(FIGURE)) {

						var number = 0;

						if (node.dataset.existingId) {

							var id = node.dataset.existingId;

							if (seenExisting.has(id)) {
								return;
							}

							seenExisting.add(id);
							number = remainingIds.indexOf(id) + 1;

						} else {

							var file = imageFileMap.get(node.dataset.id);

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
					var isBlock = node.tagName === "DIV" || node.tagName === "P";

					if (isBlock) {
						endLine();
					}

					walk(node);

					if (isBlock) {
						endLine();
					}
				});
			}

			walk(editor);

			// 줄 앞뒤 공백 정리 (&nbsp; 포함)
			result.text = result.text.replace(/ /g, " ").trim();

			return result;
		}

		// ========================================
		// 등록 / 수정 시 : 편집기 내용을 hidden 값 / 파일 목록으로 변환
		// ========================================
		if (form) {

			form.addEventListener("submit", function (event) {

				var result = serializeEditor();
				var plainText = result.text.replace(/\[\[IMG:\d+\]\]/g, "").trim();

				// 본문 글자는 필수
				if (plainText === "") {
					event.preventDefault();

					if (errorElement) {
						errorElement.hidden = false;
					}

					editor.focus();
					return;
				}

				contentInput.value = result.text;

				// 화면에서 지운 기존 사진 → 서버로 삭제 요청
				if (deletedInputs) {

					deletedInputs.innerHTML = "";

					existingOrder.forEach(function (id) {

						if (result.remainingIds.indexOf(id) >= 0) {
							return;
						}

						var hiddenInput = document.createElement("input");
						hiddenInput.type = "hidden";
						hiddenInput.name = "deletedMediaIds";
						hiddenInput.value = id;

						deletedInputs.appendChild(hiddenInput);
					});
				}

				// 새 사진은 글에 나온 순서대로 전송
				var dataTransfer = new DataTransfer();

				result.files.forEach(function (file) {
					dataTransfer.items.add(file);
				});

				fileInput.files = dataTransfer.files;
			});
		}

		// ========================================
		// 시작
		// ========================================
		buildInitialEditor();
		updateEditorState();
	}

	// ========================================
	// 제목 글자 수 : [data-char-input] 옆의 [data-char-count]
	// ========================================
	function bindCharCount(root) {

		(root || document).querySelectorAll("[data-char-input]").forEach(function (input) {

			var wrap = input.closest(".post-field") || input.parentElement;
			var counter = wrap ? wrap.querySelector("[data-char-count]") : null;

			if (!counter) {
				return;
			}

			function update() {
				counter.textContent = input.value.length;
			}

			input.addEventListener("input", update);
			update();
		});
	}

	// ========================================
	// 숫자 − / + 버튼 (모집 인원)
	// ========================================
	function bindStepper(minusId, plusId, inputId) {

		var minus = byId(minusId);
		var plus = byId(plusId);
		var input = byId(inputId);

		if (!minus || !plus || !input) {
			return;
		}

		var min = Number(input.min) || 1;
		var max = Number(input.max) || 99;

		function set(value) {
			value = Math.max(min, Math.min(max, value));
			input.value = value;
			minus.disabled = value <= min;
			plus.disabled = value >= max;
		}

		minus.addEventListener("click", function () {
			set((Number(input.value) || min) - 1);
		});

		plus.addEventListener("click", function () {
			set((Number(input.value) || min) + 1);
		});

		set(Number(input.value) || min);
	}

	global.PostEditor = {
		init: init,
		bindCharCount: bindCharCount,
		bindStepper: bindStepper
	};

})(window);
