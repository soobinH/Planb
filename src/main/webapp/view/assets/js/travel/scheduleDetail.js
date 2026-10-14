(function() {

	const button =
		document.getElementById("scheduleLikeButton");

	const count =
		document.getElementById("scheduleLikeCount");

	if (!button || !count) {
		return;
	}

	button.addEventListener("click", async function(event) {

		event.preventDefault();

		if (button.dataset.loggedIn !== "true") {
			window.location.href = button.dataset.loginUrl;
			return;
		}

		if (button.disabled) {
			return;
		}

		button.disabled = true;
		button.setAttribute("aria-busy", "true");

		try {
			const params = new URLSearchParams();

			params.set(
				"itineraryId",
				button.dataset.itineraryId
			);

			const response = await fetch(
				button.dataset.likeUrl,
				{
					method: "POST",
					credentials: "same-origin",
					headers: {
						"Content-Type":
							"application/x-www-form-urlencoded;charset=UTF-8",
						"Accept": "application/json"
					},
					body: params.toString()
				}
			);

			const result = await response.json();

			if (!response.ok || result.success !== true) {
				throw new Error(
					result.message || "좋아요 처리에 실패했습니다."
				);
			}

			if (typeof result.liked !== "boolean"
				|| !Number.isInteger(result.likeCount)
				|| result.likeCount < 0) {

				throw new Error("서버 응답을 확인해주세요.");
			}

			// 서버에서 처리한 결과로 화면 갱신
			button.setAttribute(
				"aria-pressed",
				String(result.liked)
			);

			button.setAttribute(
				"aria-label",
				button.title = result.liked ? "좋아요 취소" : "좋아요"
			);

			button.style.color =
				result.liked ? "#ef4444" : "#64748b";

			const icon = button.querySelector("svg");

			if (icon) {
				icon.setAttribute(
					"fill",
					result.liked ? "currentColor" : "none"
				);
			}

			count.textContent =
				result.likeCount.toLocaleString("ko-KR");

		} catch (error) {
			console.error(error);

			window.tripilyToast(
				error.message || "좋아요 처리 중 오류가 발생했습니다."
			);

		} finally {
			button.disabled = false;
			button.removeAttribute("aria-busy");
		}
	});

})();

(function() {

	const button =
		document.getElementById("scheduleBookmarkButton");

	if (!button) {
		return;
	}

	button.addEventListener("click", async function(event) {

		event.preventDefault();

		if (button.dataset.loggedIn !== "true") {
			window.location.href = button.dataset.loginUrl;
			return;
		}

		if (button.disabled) {
			return;
		}

		button.disabled = true;
		button.setAttribute("aria-busy", "true");

		try {
			const params = new URLSearchParams();

			params.set(
				"itineraryId",
				button.dataset.itineraryId
			);

			const response = await fetch(
				button.dataset.bookmarkUrl,
				{
					method: "POST",
					credentials: "same-origin",
					headers: {
						"Content-Type":
							"application/x-www-form-urlencoded;charset=UTF-8",
						"Accept": "application/json"
					},
					body: params.toString()
				}
			);

			const result = await response.json();

			if (!response.ok || result.success !== true) {
				throw new Error(
					result.message || "북마크 처리에 실패했습니다."
				);
			}

			if (typeof result.bookmarked !== "boolean") {
				throw new Error("서버 응답을 확인해주세요.");
			}

			button.setAttribute(
				"aria-pressed",
				String(result.bookmarked)
			);

			const label =
				result.bookmarked ? "북마크 해제" : "북마크 추가";

			button.setAttribute("aria-label", label);
			button.title = label;

			const icon = button.querySelector("svg");

			if (icon) {
				icon.setAttribute(
					"fill",
					result.bookmarked ? "#6369D1" : "none"
				);
			}

			window.tripilyToast(
				result.bookmarked
					? "일정을 북마크했어요."
					: "북마크를 해제했어요."
			);

		} catch (error) {
			console.error(error);

			window.tripilyToast(
				error.message || "북마크 처리 중 오류가 발생했습니다."
			);

		} finally {
			button.disabled = false;
			button.removeAttribute("aria-busy");
		}
	});

})();

(function() {

	const tabs =
		document.querySelectorAll("[data-detail-tab]");

	const schedulePanel =
		document.getElementById("detailSchedulePanel");

	const commentPanel =
		document.getElementById("detailCommentPanel");

	if (!tabs.length || !schedulePanel || !commentPanel) {
		return;
	}

	function selectTab(selected) {

		schedulePanel.classList.toggle(
			"hidden",
			selected !== "schedule"
		);

		commentPanel.classList.toggle(
			"hidden",
			selected !== "comments"
		);

		tabs.forEach(function(tab) {

			const active =
				tab.dataset.detailTab === selected;

			tab.setAttribute(
				"aria-selected",
				String(active)
			);

			tab.style.color =
				active ? "#6369D1" : "#94a3b8";

			const line =
				tab.querySelector("[data-detail-tab-line]");

			if (line) {
				line.classList.toggle("hidden", !active);
			}
		});
	}

	tabs.forEach(function(tab) {
		tab.addEventListener("click", function() {
			selectTab(tab.dataset.detailTab);
		});
	});

	selectTab("schedule");

})();

/* 댓글 작성·삭제 */
(function() {

	const panel = document.getElementById("detailCommentPanel");
	const input = document.getElementById("scheduleCommentContent");
	const submit = document.getElementById("scheduleCommentSubmit");
	const length = document.getElementById("scheduleCommentLength");
	const list = document.getElementById("scheduleCommentList");
	const count = document.getElementById("scheduleCommentCount");

	if (!panel || !input || !submit || !length || !list || !count) {
		return;
	}

	// 작성과 삭제 요청이 동시에 진행되지 않도록 관리
	let processing = false;
	let editingArticle = null;

	function updateLength() {
		// 서버의 codePointCount와 동일하게 글자 수 계산
		const size = Array.from(input.value).length;

		length.textContent = size.toLocaleString("ko-KR");
		length.style.color = size > 1000 ? "#ef4444" : "";
	}

	input.addEventListener("input", updateLength);
	updateLength();

	function checkLogin() {
		if (panel.dataset.loggedIn === "true") {
			return true;
		}

		window.location.href = panel.dataset.loginUrl;
		return false;
	}

	function setProcessing(value) {
		processing = value;

		const editing = editingArticle !== null;

		submit.disabled = value || editing;
		input.readOnly = value || editing;

		submit.style.opacity = submit.disabled ? "0.6" : "";
		submit.setAttribute("aria-busy", String(value));

		list.querySelectorAll("[data-comment-edit], [data-comment-delete]").forEach(function(button) {
			button.disabled = value || editing;
		});

		list.querySelectorAll("[data-comment-save], [data-comment-cancel]").forEach(function(button) {
			button.disabled = value;
		});

		const textarea = list.querySelector("[data-comment-edit-input]");

		if (textarea) {
			textarea.readOnly = value;
		}
	}

	async function requestComment(url, params) {
		const response = await fetch(url, {
			method: "POST",
			credentials: "same-origin",
			headers: {
				"Content-Type":
					"application/x-www-form-urlencoded;charset=UTF-8",
				"Accept": "application/json"
			},
			body: params.toString()
		});

		const result = await response.json();

		if (!response.ok || result.success !== true) {
			throw new Error(
				result.message || "댓글 처리에 실패했습니다."
			);
		}

		if (!Array.isArray(result.comments)
			|| !Number.isInteger(result.commentCount)
			|| result.commentCount < 0) {
			throw new Error("댓글 처리 응답을 확인해주세요.");
		}

		return result;
	}

	// 문자열을 HTML로 해석하지 않고 텍스트로 표시
	function createElement(tag, className, text) {
		const element = document.createElement(tag);

		element.className = className;

		if (text !== undefined && text !== null) {
			element.textContent = String(text);
		}

		return element;
	}

	function getProfileUrl(path) {
		if (!path) {
			return null;
		}

		const value = String(path).trim();

		if (/^https?:\/\//i.test(value)) {
			return value;
		}

		// 외부 URL처럼 해석되는 경로나 다른 프로토콜은 제외
		if (value.startsWith("//")
			|| /^[a-z][a-z0-9+.-]*:/i.test(value)) {
			return null;
		}

		if (value.startsWith("/")) {
			return panel.dataset.contextPath + value;
		}

		return panel.dataset.contextPath
			+ "/uploads/profile/" + encodeURIComponent(value);
	}

	function createProfile(comment) {
		const profile = createElement(
			"div",
			"w-10 h-10 rounded-full overflow-hidden shrink-0 "
			+ "flex items-center justify-center"
		);

		profile.style.background = "#F0F0FF";
		profile.style.color = "#6369D1";

		// 고정된 아이콘이며 댓글 내용은 넣지 않음
		function showDefaultProfile() {
			profile.innerHTML =
				'<svg width="22" height="22" viewBox="0 0 24 24"'
				+ ' fill="none" stroke="currentColor" stroke-width="2"'
				+ ' aria-hidden="true">'
				+ '<circle cx="12" cy="8" r="4"/>'
				+ '<path d="M4 21v-2a8 8 0 0 1 16 0v2"/>'
				+ '</svg>';
		}

		const url = getProfileUrl(comment.profileImg);

		if (url) {
			const image = createElement(
				"img",
				"w-full h-full object-cover"
			);

			image.alt = "작성자 프로필";
			image.addEventListener("error", showDefaultProfile, {
				once: true
			});
			image.src = url;

			profile.appendChild(image);
		} else {
			showDefaultProfile();
		}

		return profile;
	}

	function parseCommentDate(value) {
		if (!value) {
			return null;
		}

		if (typeof value === "number") {
			const date = new Date(value);
			return Number.isNaN(date.getTime()) ? null : date;
		}

		let text = String(value).trim();

		// yyyy.MM.dd 또는 yyyy-MM-dd 형식 처리
		text = text.replace(/^(\d{4})\.(\d{2})\.(\d{2})/, "$1-$2-$3");

		text = text.replace(/^(\d{4}-\d{2}-\d{2}) /, "$1T");

		const date = new Date(text);

		return Number.isNaN(date.getTime()) ? null : date;
	}

	function formatCommentDate(value) {
		const date = parseCommentDate(value);

		if (!date) {
			return value || "";
		}

		function pad(number) {
			return String(number).padStart(2, "0");
		}

		return date.getFullYear()
			+ "." + pad(date.getMonth() + 1)
			+ "." + pad(date.getDate())
			+ " " + pad(date.getHours())
			+ ":" + pad(date.getMinutes());
	}

	function renderComments(comments) {
		const fragment = document.createDocumentFragment();

		if (comments.length === 0) {
			fragment.appendChild(
				createElement(
					"p",
					"py-5 text-center text-[12px] text-gray-400",
					"아직 댓글이 없습니다."
				)
			);
		}

		comments.forEach(function(comment) {
			const article = createElement(
				"article",
				"flex items-start gap-3"
			);

			article.setAttribute("data-comment-item", "");
			article.dataset.commentId = String(comment.commentId);
			article.appendChild(createProfile(comment));

			const body = createElement("div", "flex-1 min-w-0");

			const header = createElement(
				"div",
				"flex items-center gap-2 flex-wrap"
			);

			header.appendChild(
				createElement(
					"span",
					"font-bold text-[13px] text-gray-900",
					comment.nickname || ""
				)
			);

			header.appendChild(
				createElement(
					"span",
					"text-[11px] text-gray-400",
					formatCommentDate(comment.createdAt)
				)
			);

			const created = parseCommentDate(comment.createdAt);
			const updated = parseCommentDate(comment.updatedAt);

			if (created && updated
				&& updated.getTime() > created.getTime()) {

				const edited = createElement(
					"span",
					"text-[10px] text-gray-400",
					"수정됨"
				);

				edited.setAttribute("data-comment-edited", "");
				header.appendChild(edited);
			}

			if (panel.dataset.loggedIn === "true"
				&& String(comment.userId)
				=== panel.dataset.loginUserId) {

				const actions = createElement(
					"div",
					"ml-auto flex items-center gap-2"
				);

				actions.setAttribute("data-comment-actions", "");

				const editButton = createElement(
					"button",
					"text-[11px] text-gray-400 hover:text-[#6369D1]",
					"수정"
				);

				editButton.type = "button";
				editButton.setAttribute("data-comment-edit", "");
				editButton.dataset.commentId = String(comment.commentId);

				const deleteButton = createElement(
					"button",
					"text-[11px] text-gray-400 hover:text-red-500",
					"삭제"
				);

				deleteButton.type = "button";
				deleteButton.setAttribute("data-comment-delete", "");
				deleteButton.dataset.commentId = String(comment.commentId);

				actions.appendChild(editButton);
				actions.appendChild(deleteButton);

				header.appendChild(actions);
			}

			const content = createElement(
				"p",
				"mt-1 text-[13px] text-gray-600",
				comment.content || ""
			);

			content.setAttribute("data-comment-content", "");
			content.style.whiteSpace = "pre-wrap";
			content.style.overflowWrap = "anywhere";

			body.appendChild(header);
			body.appendChild(content);
			article.appendChild(body);
			fragment.appendChild(article);
		});

		list.replaceChildren(fragment);
	}

	function updateComments(result) {
		editingArticle = null;

		renderComments(result.comments);

		count.textContent =
			result.commentCount.toLocaleString("ko-KR");
	}

	submit.addEventListener("click", async function() {
		if (!checkLogin() || processing || editingArticle) {
			return;
		}

		const content = input.value.trim();

		if (!content) {
			window.tripilyToast("댓글 내용을 입력해주세요.");
			input.focus();
			return;
		}

		if (Array.from(content).length > 1000) {
			window.tripilyToast("댓글은 최대 1,000자까지 입력할 수 있습니다.");
			input.focus();
			return;
		}

		setProcessing(true);

		try {
			const params = new URLSearchParams();

			params.set("itineraryId", panel.dataset.itineraryId);
			params.set("content", content);

			const result = await requestComment(
				panel.dataset.writeUrl,
				params
			);

			updateComments(result);

			input.value = "";
			updateLength();

			window.tripilyToast("댓글을 등록했어요.");

		} catch (error) {
			console.error(error);
			window.tripilyToast(
				error.message || "댓글 등록 중 오류가 발생했습니다."
			);

		} finally {
			setProcessing(false);
		}
	});

	// 새로 추가된 댓글의 삭제 버튼에도 동작하도록 이벤트 위임
	list.addEventListener("click", async function(event) {
		const button = event.target.closest("[data-comment-delete]");

		if (!button || !list.contains(button)) {
			return;
		}

		if (!checkLogin() || processing || editingArticle) {
			return;
		}

		if (!window.confirm("댓글을 삭제할까요?")) {
			return;
		}

		setProcessing(true);

		try {
			const params = new URLSearchParams();

			params.set("itineraryId", panel.dataset.itineraryId);
			params.set("commentId", button.dataset.commentId);

			const result = await requestComment(
				panel.dataset.deleteUrl,
				params
			);

			updateComments(result);

			window.tripilyToast("댓글을 삭제했어요.");

		} catch (error) {
			console.error(error);
			window.tripilyToast(
				error.message || "댓글 삭제 중 오류가 발생했습니다."
			);

		} finally {
			setProcessing(false);
		}
	});

	function closeCommentEditor(article) {
		const editor = article.querySelector("[data-comment-editor]");
		const content = article.querySelector("[data-comment-content]");
		const actions = article.querySelector("[data-comment-actions]");

		if (editor) {
			editor.remove();
		}

		if (content) {
			content.hidden = false;
		}

		if (actions) {
			actions.hidden = false;
			actions.style.display = "";
		}

		editingArticle = null;
		setProcessing(false);
	}

	function openCommentEditor(article) {
		const content = article.querySelector("[data-comment-content]");
		const actions = article.querySelector("[data-comment-actions]");

		if (!content || !actions) {
			return;
		}

		editingArticle = article;

		const editor = createElement(
			"div",
			"mt-2 rounded-xl border p-3"
		);

		editor.setAttribute("data-comment-editor", "");
		editor.style.borderColor = "#D1D2F9";
		editor.style.background = "#fafafa";

		const textarea = createElement(
			"textarea",
			"w-full bg-transparent text-[13px] outline-none resize-y"
		);

		textarea.setAttribute("data-comment-edit-input", "");
		textarea.setAttribute("aria-label", "댓글 수정 내용");
		textarea.style.minHeight = "90px";
		textarea.value = content.textContent;

		const footer = createElement(
			"div",
			"flex items-center justify-between gap-2 mt-2"
		);

		const lengthText = createElement(
			"span",
			"text-[11px] text-gray-400"
		);

		function updateEditLength() {
			const size = Array.from(textarea.value).length;

			lengthText.textContent =
				size.toLocaleString("ko-KR") + " / 1,000";

			lengthText.style.color = size > 1000 ? "#ef4444" : "";
		}

		textarea.addEventListener("input", updateEditLength);
		updateEditLength();

		const controls = createElement(
			"div",
			"flex items-center gap-2"
		);

		const cancel = createElement(
			"button",
			"px-3 py-1.5 rounded-lg text-[12px] text-gray-500",
			"취소"
		);

		cancel.type = "button";
		cancel.setAttribute("data-comment-cancel", "");

		const save = createElement(
			"button",
			"px-3 py-1.5 rounded-lg text-[12px] font-semibold text-white",
			"저장"
		);

		save.type = "button";
		save.style.background = "#6369D1";
		save.setAttribute("data-comment-save", "");

		controls.appendChild(cancel);
		controls.appendChild(save);

		footer.appendChild(lengthText);
		footer.appendChild(controls);

		editor.appendChild(textarea);
		editor.appendChild(footer);

		content.hidden = true;
		actions.hidden = true;
		actions.style.display = "none";

		content.after(editor);

		setProcessing(false);
		textarea.focus();
	}

	list.addEventListener("click", async function(event) {
		const button = event.target.closest(
			"[data-comment-edit], "
			+ "[data-comment-save], "
			+ "[data-comment-cancel]"
		);

		if (!button || !list.contains(button)) {
			return;
		}

		event.preventDefault();

		if (!checkLogin() || processing) {
			return;
		}

		const article = button.closest("[data-comment-item]");

		if (!article) {
			return;
		}

		if (button.hasAttribute("data-comment-edit")) {
			if (!editingArticle) {
				openCommentEditor(article);
			}

			return;
		}

		if (button.hasAttribute("data-comment-cancel")) {
			closeCommentEditor(article);
			return;
		}

		const textarea = article.querySelector(
			"[data-comment-edit-input]"
		);

		if (!textarea) {
			return;
		}

		const content = textarea.value.trim();

		if (!content) {
			window.tripilyToast("댓글 내용을 입력해주세요.");
			textarea.focus();
			return;
		}

		if (Array.from(content).length > 1000) {
			window.tripilyToast("댓글은 1,000자까지 입력할 수 있습니다.");
			textarea.focus();
			return;
		}

		const original = article.querySelector(
			"[data-comment-content]"
		);

		// 내용이 같으면 UPDATE 없이 수정창만 닫기
		if (original && content === original.textContent.trim()) {
			closeCommentEditor(article);
			return;
		}

		setProcessing(true);

		try {
			const params = new URLSearchParams();

			params.set("itineraryId", panel.dataset.itineraryId);
			params.set("commentId", article.dataset.commentId);
			params.set("content", content);

			const result = await requestComment(
				panel.dataset.updateUrl,
				params
			);

			updateComments(result);

			window.tripilyToast("댓글을 수정했어요.");

		} catch (error) {
			console.error(error);

			window.tripilyToast(
				error.message || "댓글 수정 중 오류가 발생했습니다."
			);

		} finally {
			setProcessing(false);
		}
	});

})();

/* 일정 신고 팝업 */
(function() {

	const openButton =
		document.getElementById("scheduleReportButton");

	const modal =
		document.getElementById("scheduleReportModal");

	const form =
		document.getElementById("scheduleReportForm");

	const detail =
		document.getElementById("scheduleReportDetail");

	const length =
		document.getElementById("scheduleReportLength");

	const submit =
		document.getElementById("scheduleReportSubmit");

	const errorText =
		document.getElementById("scheduleReportError");

	const success =
		document.getElementById("scheduleReportSuccess");

	if (!openButton || !modal || !form || !detail
		|| !length || !submit || !errorText || !success) {
		return;
	}

	const closeButtons =
		modal.querySelectorAll("[data-report-close]");

	let processing = false;
	let previousBodyOverflow = "";

	function showError(message) {
		errorText.textContent = message;
		errorText.hidden = !message;
	}

	function updateFormState() {
		const size = Array.from(detail.value).length;

		const selected =
			form.querySelector('input[name="reasonId"]:checked');

		length.textContent = size.toLocaleString("ko-KR");
		length.style.color = size > 300 ? "#ef4444" : "";

		submit.disabled =
			processing || !selected || size > 300;
	}

	function setProcessing(value) {
		processing = value;

		form.querySelectorAll("input, textarea")
			.forEach(function(element) {
				element.disabled = value;
			});

		closeButtons.forEach(function(button) {
			button.disabled = value;
		});

		submit.textContent = value ? "접수 중..." : "신고하기";
		form.setAttribute("aria-busy", String(value));

		updateFormState();
	}

	openButton.addEventListener("click", function(event) {
		event.preventDefault();

		if (openButton.dataset.loggedIn !== "true") {
			window.location.href = openButton.dataset.loginUrl;
			return;
		}

		if (openButton.dataset.isOwner === "true") {
			window.tripilyToast(
				"본인이 작성한 일정은 신고할 수 없습니다."
			);
			return;
		}

		if (modal.open) {
			return;
		}

		form.reset();
		form.hidden = false;
		success.hidden = true;

		showError("");
		setProcessing(false);

		previousBodyOverflow = document.body.style.overflow;

		modal.showModal();
		document.body.style.overflow = "hidden";
	});

	function closeModal() {
		if (!processing && modal.open) {
			modal.close();
		}
	}

	closeButtons.forEach(function(button) {
		button.addEventListener("click", closeModal);
	});

	// Escape 키로 닫기, 제출 중에는 닫기 차단
	modal.addEventListener("cancel", function(event) {
		if (processing) {
			event.preventDefault();
		}
	});

	modal.addEventListener("close", function() {
		document.body.style.overflow = previousBodyOverflow;
		openButton.focus();
	});

	form.addEventListener("change", function() {
		showError("");
		updateFormState();
	});

	detail.addEventListener("input", function() {
		showError("");
		updateFormState();
	});

	form.addEventListener("submit", async function(event) {
		event.preventDefault();

		if (processing) {
			return;
		}

		const selected =
			form.querySelector('input[name="reasonId"]:checked');

		if (!selected) {
			showError("신고 사유를 선택해주세요.");
			return;
		}

		if (Array.from(detail.value).length > 300) {
			showError("상세 내용은 최대 300자까지 입력할 수 있습니다.");
			detail.focus();
			return;
		}

		// 입력을 비활성화하기 전에 요청 데이터 구성
		const params = new URLSearchParams();

		params.set(
			"itineraryId",
			form.elements.namedItem("itineraryId").value
		);

		params.set("reasonId", selected.value);
		params.set("detail", detail.value.trim());

		showError("");
		setProcessing(true);

		try {
			const response = await fetch(form.action, {
				method: "POST",
				credentials: "same-origin",
				headers: {
					"Content-Type":
						"application/x-www-form-urlencoded;charset=UTF-8",
					"Accept": "application/json"
				},
				body: params.toString()
			});

			const result = await response.json();

			if (!response.ok || result.success !== true) {
				throw new Error(
					result.message || "신고 접수에 실패했습니다."
				);
			}

			// DB 저장 성공 후 완료 화면 표시
			form.hidden = true;
			success.hidden = false;

			success.querySelector("button").focus();

		} catch (error) {
			console.error(error);

			showError(
				error.message || "신고 접수 중 오류가 발생했습니다."
			);

		} finally {
			setProcessing(false);

			if (!success.hidden) {
				success.querySelector("button").focus();
			}
		}
	});

	updateFormState();

})();

/* 일정 링크 공유 */
(function() {

	const button =
		document.getElementById("scheduleShareButton");

	if (!button) {
		return;
	}

	button.addEventListener("click", async function() {

		if (button.disabled) {
			return;
		}

		const url = new URL(
			button.dataset.shareUrl,
			window.location.origin
		).href;

		button.disabled = true;

		try {
			if (!navigator.clipboard || !window.isSecureContext) {
				throw new Error("클립보드 사용 불가");
			}

			await navigator.clipboard.writeText(url);

			window.tripilyToast("링크를 복사했어요.");

		} catch (error) {
			// 자동 복사가 제한된 환경에서는 직접 복사 안내
			window.prompt(
				"아래 링크를 복사해서 공유해주세요.",
				url
			);

		} finally {
			button.disabled = false;
		}
	});

})();

/* 전체 일정·DAY·BLOCK 담기 */
(function() {

	const root = document.getElementById("scheduleDetail");

	if (!root) {
		return;
	}

	const buttons = Array.from(
		root.querySelectorAll("[data-cart-add]")
	);

	if (buttons.length === 0) {
		return;
	}

	const loggedIn = root.dataset.loggedIn === "true";

	let processing = false;
	let stateReady = !loggedIn;

	function updateDisabled() {
		buttons.forEach(function(button) {
			button.disabled = processing || !stateReady;
		});
	}

	function applyState(result) {

		const validStates = ["NONE", "PARTIAL", "FULL"];

		if (!validStates.includes(result.itineraryState)
			|| !result.dayStates
			|| !result.blockStates) {

			throw new Error("장바구니 상태 응답을 확인해주세요.");
		}

		// 모든 상태를 먼저 검사한 뒤 화면에 반영
		const states = buttons.map(function(button) {

			const type = button.dataset.cartAdd;
			const targetId = button.dataset.targetId;

			let state;

			if (type === "ITINERARY") {
				state = result.itineraryState;
			} else if (type === "DAY") {
				state = result.dayStates[targetId];
			} else if (type === "BLOCK") {
				state = result.blockStates[targetId];
			}

			if (!validStates.includes(state)) {
				throw new Error(
					"담기 대상의 상태를 확인해주세요."
				);
			}

			return state;
		});

		buttons.forEach(function(button, index) {

			const state = states[index];
			const whole = button.dataset.cartAdd === "ITINERARY";
			const label = button.querySelector("[data-cart-label]");

			button.dataset.cartState = state;

			button.setAttribute(
				"aria-pressed",
				state === "FULL"
					? "true"
					: state === "PARTIAL" ? "mixed" : "false"
			);

			let text;
			let description;

			if (state === "FULL") {

				text = whole
					? "전체 담김 · 해제"
					: "담김 · 해제";

				description =
					"전체 담긴 상태입니다. 누르면 장바구니에서 뺍니다.";

			} else if (state === "PARTIAL") {

				text = "일부 담김 · 나머지 담기";

				description =
					"일부 담긴 상태입니다. 누르면 빠진 항목을 담습니다.";

			} else {

				text = whole ? "전체 일정 담기" : "담기";

				description =
					"안 담긴 상태입니다. 누르면 장바구니에 담습니다.";
			}

			if (label) {
				label.textContent = text;
			}

			button.title = description;
			button.setAttribute("aria-label", text);
		});
	}

	async function readResponse(response) {

		const result = await response.json();

		if (!response.ok || result.success !== true) {
			throw new Error(
				result.message || "장바구니 처리에 실패했습니다."
			);
		}

		return result;
	}

	async function loadInitialState() {

		updateDisabled();

		try {
			const url = new URL(
				root.dataset.cartStateUrl,
				window.location.origin
			);

			url.searchParams.set(
				"itineraryId",
				root.dataset.itineraryId
			);

			const response = await fetch(url, {
				method: "GET",
				credentials: "same-origin",
				cache: "no-store",
				headers: {
					"Accept": "application/json"
				}
			});

			const result = await readResponse(response);

			applyState(result);

			stateReady = true;

		} catch (error) {
			console.error(error);

			window.tripilyToast(
				error.message + " 화면을 새로고침해주세요."
			);

		} finally {
			updateDisabled();
		}
	}

	root.addEventListener("click", async function(event) {

		const button = event.target.closest("[data-cart-add]");

		if (!button || !root.contains(button)) {
			return;
		}

		event.preventDefault();

		if (!loggedIn) {
			window.location.href = root.dataset.loginUrl;
			return;
		}

		if (processing || !stateReady) {
			return;
		}

		processing = true;
		updateDisabled();

		button.setAttribute("aria-busy", "true");

		try {
			const params = new URLSearchParams();

			params.set("itineraryId", root.dataset.itineraryId);
			params.set("itemType", button.dataset.cartAdd);
			params.set("targetId", button.dataset.targetId);

			const response = await fetch(root.dataset.cartUrl, {
				method: "POST",
				credentials: "same-origin",
				headers: {
					"Content-Type":
						"application/x-www-form-urlencoded;charset=UTF-8",
					"Accept": "application/json"
				},
				body: params.toString()
			});

			const result = await readResponse(response);

			// 관련 전체 일정·DAY·BLOCK 버튼을 함께 갱신
			applyState(result);

			window.tripilyToast(result.message);

			// 헤더 장바구니 배지도 다시 조회
			window.dispatchEvent(
				new CustomEvent("itinerary-cart-updated", {
					detail: result
				})
			);

		} catch (error) {
			console.error(error);

			// 요청이 실제 반영됐을 수도 있으므로
			// 상태 확인 없이 다시 토글하는 것을 방지
			stateReady = false;

			window.tripilyToast(
				error.message + " 화면을 새로고침해주세요."
			);

		} finally {
			processing = false;
			button.removeAttribute("aria-busy");
			updateDisabled();
		}
	});

	if (loggedIn) {
		loadInitialState();
	}

})();

(function() {

	const button =
		document.getElementById("scheduleDeleteButton");

	if (!button) {
		return;
	}

	button.addEventListener("click", async function() {

		if (button.disabled) {
			return;
		}

		if (!window.confirm("이 일정을 삭제하시겠습니까?")) {
			return;
		}

		button.disabled = true;
		button.setAttribute("aria-busy", "true");

		let deleted = false;

		try {
			const params = new URLSearchParams();

			params.set(
				"itineraryId",
				button.dataset.itineraryId
			);

			const response = await fetch(
				button.dataset.deleteUrl,
				{
					method: "POST",
					credentials: "same-origin",
					headers: {
						"Content-Type":
							"application/x-www-form-urlencoded;charset=UTF-8",
						"Accept": "application/json"
					},
					body: params.toString()
				}
			);

			const result = await response.json();

			if (!response.ok || result.success !== true) {
				throw new Error(
					result.message || "일정 삭제에 실패했습니다."
				);
			}

			deleted = true;

			window.location.replace(button.dataset.listUrl);

		} catch (error) {
			console.error(error);

			window.tripilyToast(
				error.message || "일정 삭제 중 오류가 발생했습니다."
			);

		} finally {
			if (!deleted) {
				button.disabled = false;
			}

			button.removeAttribute("aria-busy");
		}
	});

})();

/* 일정표의 DAY별 접기·펼치기. 지도와 담기 상태에는 영향 없음. */
(function () {
    const panel = document.getElementById("detailSchedulePanel");
    if (!panel) return;
    panel.addEventListener("click", function (event) {
        const toggle = event.target.closest("[data-detail-day-toggle]");
        if (!toggle || !panel.contains(toggle)) return;
        const body = document.getElementById(toggle.getAttribute("aria-controls"));
        if (!body) return;
        const expanded = toggle.getAttribute("aria-expanded") === "true";
        toggle.setAttribute("aria-expanded", String(!expanded));
        body.hidden = expanded;
    });
})();
