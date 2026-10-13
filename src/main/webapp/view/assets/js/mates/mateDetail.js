document.addEventListener("DOMContentLoaded", function () {

	var mateLikeButton = document.getElementById("mateLikeButton");
	var mateLikeMateId = document.getElementById("mateLikeMateId");
	var mateLikeCount = document.getElementById("mateLikeCount");

	if (!mateLikeButton || !mateLikeMateId || !mateLikeCount) {
		return;
	}

	var mateLikeIcon = mateLikeButton.querySelector(".mate-like-icon");

	mateLikeButton.addEventListener("click", function () {

		mateLikeButton.disabled = true;

		fetch("/Planb/mateLike", {
			method: "POST",
			headers: {
				"Content-Type": "application/x-www-form-urlencoded; charset=UTF-8"
			},
			body: "mateId=" + encodeURIComponent(mateLikeMateId.value)
		})
		.then(function (response) {

			if (!response.ok) {
				throw new Error("HTTP 오류: " + response.status);
			}

			return response.json();
		})
		.then(function (data) {

			if (!data.success) {
				throw new Error("좋아요 처리 실패");
			}

			mateLikeCount.textContent = data.likeCount;

			if (data.liked) {
				mateLikeButton.classList.add("active");

				if (mateLikeIcon) {
					mateLikeIcon.setAttribute("fill", "currentColor");
				}
			} else {
				mateLikeButton.classList.remove("active");

				if (mateLikeIcon) {
					mateLikeIcon.setAttribute("fill", "none");
				}
			}

			mateLikeButton.disabled = false;
		})
		.catch(function (error) {

			console.error("Mate 좋아요 오류:", error);

			alert("좋아요 처리 중 오류가 발생했습니다.\n" + error.message);

			mateLikeButton.disabled = false;
		});

	});

});

// =========================
// 댓글 등록
// =========================

var mateCommentForm = document.getElementById("mateCommentForm");

if (mateCommentForm) {

	mateCommentForm.addEventListener("submit", function(e) {

		e.preventDefault();

		var commentInput = document.getElementById("mateCommentContent");
		var content = commentInput.value.trim();

		if (content === "") {
			alert("댓글을 입력해주세요.");
			commentInput.focus();
			return;
		}

		var submitButton = mateCommentForm.querySelector('button[type="submit"]');

		submitButton.disabled = true;

		var formData = new URLSearchParams(
			new FormData(mateCommentForm)
		);

		fetch(mateCommentForm.action, {
			method: "POST",
			headers: {
				"Content-Type": "application/x-www-form-urlencoded; charset=UTF-8"
			},
			body: formData.toString()
		})
		.then(function(response) {

			if (response.status === 401) {
				throw new Error("LOGIN_REQUIRED");
			}

			if (!response.ok) {
				throw new Error("COMMENT_WRITE_FAILED");
			}

			return response.json();
		})
		.then(function(data) {

			if (!data.success) {
				throw new Error("COMMENT_WRITE_FAILED");
			}

			window.location.reload();
		})
		.catch(function(error) {

			if (error.message === "LOGIN_REQUIRED") {
				alert("로그인이 필요합니다.");
				return;
			}

			console.error(error);
			alert("댓글 등록 중 오류가 발생했습니다.");
		})
		.then(function() {
			submitButton.disabled = false;
		});

	});

}

// =========================
// 댓글 수정 / 삭제
// =========================

var mateCommentList = document.getElementById("mateCommentList");

if (mateCommentList) {

	mateCommentList.addEventListener("click", function(e) {

		// =========================
		// 수정 시작
		// =========================

		var editButton = e.target.closest(".mate-comment-edit");

		if (editButton) {

			var commentItem = editButton.closest("[data-comment-id]");

			if (commentItem.classList.contains("editing")) {
				return;
			}

			var contentElement = commentItem.querySelector(".mate-comment-content");
			var currentContent = contentElement.textContent.trim();

			commentItem.classList.add("editing");

			// 기존 댓글 숨김
			contentElement.style.display = "none";

			// 기존 수정/삭제 버튼 숨김
			var originalEditButton = commentItem.querySelector(".mate-comment-edit");
			var originalDeleteButton = commentItem.querySelector(".mate-comment-delete");

			originalEditButton.style.display = "none";
			originalDeleteButton.style.display = "none";

			// 수정 영역 생성
			var editArea = document.createElement("div");

			editArea.className = "mate-comment-edit-area mt-2";

			editArea.innerHTML =
				'<div class="flex items-center gap-2">' +
					'<input type="text" ' +
						'class="mate-comment-edit-input ' +
						'jsp-focus flex-1 min-w-0 ' +
						'text-sm text-gray-700 outline-none ' +
						'border border-gray-200 rounded-xl ' +
						'px-3 py-2 transition-all">' +
					'<button type="button" ' +
						'class="mate-comment-save shrink-0 ' +
						'text-xs font-semibold">' +
						'저장' +
					'</button>' +
					'<button type="button" ' +
						'class="mate-comment-cancel shrink-0 ' +
						'text-xs text-gray-400">' +
						'취소' +
					'</button>' +
				'</div>';

			contentElement.after(editArea);

			var input = editArea.querySelector(".mate-comment-edit-input");
			var saveButton = editArea.querySelector(".mate-comment-save");
			var cancelButton = editArea.querySelector(".mate-comment-cancel");

			input.value = currentContent;
			input.focus();

			input.setSelectionRange(
				input.value.length,
				input.value.length
			);

			// =========================
			// 저장
			// =========================

			saveButton.addEventListener("click", function() {

				var newContent = input.value.trim();

				if (newContent === "") {
					alert("댓글 내용을 입력해주세요.");
					input.focus();
					return;
				}

				saveButton.disabled = true;

				var params = new URLSearchParams();

				params.append("commentId", commentItem.dataset.commentId);
				params.append("content", newContent);

				fetch(
					getContextPath() + "/mateCommentUpdate",
					{
						method: "POST",
						headers: {
							"Content-Type": "application/x-www-form-urlencoded; charset=UTF-8"
						},
						body: params.toString()
					}
				)
				.then(function(response) {

					if (response.status === 401) {
						throw new Error("LOGIN_REQUIRED");
					}

					if (response.status === 403) {
						throw new Error("FORBIDDEN");
					}

					if (!response.ok) {
						throw new Error("UPDATE_FAILED");
					}

					return response.json();
				})
				.then(function(data) {

					if (!data.success) {
						throw new Error("UPDATE_FAILED");
					}

					// 수정된 내용 화면에 바로 반영
					contentElement.textContent = newContent;

					// (수정됨) 표시
					var timeElement = commentItem.querySelector(".mate-comment-time");

					if (
						timeElement &&
						!timeElement.querySelector(".mate-comment-edited")
					) {
						var editedElement = document.createElement("span");

						editedElement.className = "mate-comment-edited ml-1";
						editedElement.textContent = "(수정됨)";

						timeElement.appendChild(editedElement);
					}

					closeMateCommentEdit(commentItem);
				})
				.catch(function(error) {

					saveButton.disabled = false;

					console.error(error);

					if (error.message === "LOGIN_REQUIRED") {
						alert("로그인이 필요합니다.");
						return;
					}

					if (error.message === "FORBIDDEN") {
						alert("본인이 작성한 댓글만 수정할 수 있습니다.");
						return;
					}

					alert("댓글 수정 중 오류가 발생했습니다.");
				});

			});

			// =========================
			// 취소
			// =========================

			cancelButton.addEventListener("click", function() {
				closeMateCommentEdit(commentItem);
			});

			// Enter 저장 / ESC 취소
			input.addEventListener("keydown", function(event) {

				if (event.key === "Enter") {
					event.preventDefault();
					saveButton.click();
				}

				if (event.key === "Escape") {
					event.preventDefault();
					cancelButton.click();
				}

			});

			return;
		}

		// =========================
		// 댓글 삭제
		// =========================

		var deleteButton = e.target.closest(".mate-comment-delete");

		if (deleteButton) {

			var commentItem = deleteButton.closest("[data-comment-id]");
			var commentId = commentItem.dataset.commentId;

			var confirmed = confirm("댓글을 삭제하시겠습니까?");

			if (!confirmed) {
				return;
			}

			var params = new URLSearchParams();

			params.append("commentId", commentId);

			fetch(
				getContextPath() + "/mateCommentDelete",
				{
					method: "POST",
					headers: {
						"Content-Type": "application/x-www-form-urlencoded; charset=UTF-8"
					},
					body: params.toString()
				}
			)
			.then(function(response) {

				if (response.status === 401) {
					throw new Error("LOGIN_REQUIRED");
				}

				if (response.status === 403) {
					throw new Error("FORBIDDEN");
				}

				if (!response.ok) {
					throw new Error("DELETE_FAILED");
				}

				return response.json();
			})
			.then(function(data) {

				if (!data.success) {
					throw new Error("DELETE_FAILED");
				}

				// 화면에서 바로 제거
				commentItem.remove();

				// 댓글 개수 변경
				updateMateCommentCount();
			})
			.catch(function(error) {

				console.error(error);

				if (error.message === "LOGIN_REQUIRED") {
					alert("로그인이 필요합니다.");
					return;
				}

				if (error.message === "FORBIDDEN") {
					alert("본인이 작성한 댓글만 삭제할 수 있습니다.");
					return;
				}

				alert("댓글 삭제 중 오류가 발생했습니다.");
			});
		}

	});

}


// =========================
// 댓글 수정 화면 닫기
// =========================

function closeMateCommentEdit(commentItem) {

	var contentElement = commentItem.querySelector(".mate-comment-content");
	var editArea = commentItem.querySelector(".mate-comment-edit-area");
	var editButton = commentItem.querySelector(".mate-comment-edit");
	var deleteButton = commentItem.querySelector(".mate-comment-delete");

	if (editArea) {
		editArea.remove();
	}

	if (contentElement) {
		contentElement.style.display = "";
	}

	if (editButton) {
		editButton.style.display = "";
	}

	if (deleteButton) {
		deleteButton.style.display = "";
	}

	commentItem.classList.remove("editing");
}


// =========================
// Context Path
// =========================

function getContextPath() {

	var path = window.location.pathname;
	var secondSlash = path.indexOf("/", 1);

	if (secondSlash === -1) {
		return "";
	}

	return path.substring(0, secondSlash);
}


// =========================
// 댓글 개수 화면 갱신
// =========================

function updateMateCommentCount() {

	var commentList = document.getElementById("mateCommentList");

	if (!commentList) {
		return;
	}

	var comments = commentList.querySelectorAll("[data-comment-id]");
	var count = comments.length;

	var countElements = document.querySelectorAll(".mate-comment-count");

	countElements.forEach(function(element) {
		element.textContent = count;
	});

	// 마지막 댓글까지 삭제한 경우
	if (count === 0) {
		commentList.innerHTML =
			'<div class="py-6 text-center text-sm text-gray-400">' +
				'아직 작성된 댓글이 없습니다.' +
			'</div>';
	}
}

// =========================
// 게시글 삭제
// =========================

var mateDeleteButton = document.getElementById("mateDeleteButton");

if (mateDeleteButton) {

	mateDeleteButton.addEventListener("click", function() {

		var confirmed = confirm("게시글을 삭제하시겠습니까?");

		if (!confirmed) {
			return;
		}

		var mateId = mateDeleteButton.dataset.mateId;

		var params = new URLSearchParams();

		params.append("mateId", mateId);

		mateDeleteButton.disabled = true;

		fetch(
			getContextPath() + "/mateDelete",
			{
				method: "POST",
				headers: {
					"Content-Type": "application/x-www-form-urlencoded; charset=UTF-8"
				},
				body: params.toString()
			}
		)
		.then(function(response) {

			if (response.status === 401) {
				throw new Error("LOGIN_REQUIRED");
			}

			if (response.status === 403) {
				throw new Error("FORBIDDEN");
			}

			if (response.status === 404) {
				throw new Error("NOT_FOUND");
			}

			if (!response.ok) {
				throw new Error("DELETE_FAILED");
			}

			return response.json();
		})
		.then(function(data) {

			if (!data.success) {
				throw new Error("DELETE_FAILED");
			}

			window.location.href = getContextPath() + "/mates";
		})
		.catch(function(error) {

			mateDeleteButton.disabled = false;

			console.error(error);

			if (error.message === "LOGIN_REQUIRED") {
				alert("로그인이 필요합니다.");
				return;
			}

			if (error.message === "FORBIDDEN") {
				alert("본인이 작성한 게시글만 삭제할 수 있습니다.");
				return;
			}

			if (error.message === "NOT_FOUND") {
				alert("존재하지 않는 게시글입니다.");
				return;
			}

			alert("게시글 삭제 중 오류가 발생했습니다.");
		});

	});

}

// =========================
// 모집 상태 변경
// =========================

var mateRecruitStatusButton =
	document.getElementById("mateRecruitStatusButton");

if (mateRecruitStatusButton) {

	mateRecruitStatusButton.addEventListener("click", function() {

		var currentStatus =
			mateRecruitStatusButton.dataset.recruitStatus;

		var confirmMessage;

		if (currentStatus === "OPEN") {
			confirmMessage = "모집을 완료하시겠습니까?";
		} else {
			confirmMessage = "다시 모집중으로 변경하시겠습니까?";
		}

		if (!confirm(confirmMessage)) {
			return;
		}

		var mateId =
			mateRecruitStatusButton.dataset.mateId;

		var params = new URLSearchParams();

		params.append("mateId", mateId);

		mateRecruitStatusButton.disabled = true;

		fetch(
			getContextPath() + "/mateRecruitStatus",
			{
				method: "POST",
				headers: {
					"Content-Type": "application/x-www-form-urlencoded; charset=UTF-8"
				},
				body: params.toString()
			}
		)
		.then(function(response) {

			if (response.status === 401) {
				throw new Error("LOGIN_REQUIRED");
			}

			if (response.status === 403) {
				throw new Error("FORBIDDEN");
			}

			if (response.status === 404) {
				throw new Error("NOT_FOUND");
			}

			if (!response.ok) {
				throw new Error("UPDATE_FAILED");
			}

			return response.json();
		})
		.then(function(data) {

			if (!data.success) {
				throw new Error("UPDATE_FAILED");
			}

			var newStatus = data.recruitStatus;

			mateRecruitStatusButton.dataset.recruitStatus =
				newStatus;

			if (newStatus === "OPEN") {

				mateRecruitStatusButton.textContent =
					"모집중";

				mateRecruitStatusButton.classList.remove(
					"closed"
				);

				mateRecruitStatusButton.classList.add(
					"open"
				);

			} else {

				mateRecruitStatusButton.textContent =
					"모집완료";

				mateRecruitStatusButton.classList.remove(
					"open"
				);

				mateRecruitStatusButton.classList.add(
					"closed"
				);
			}
		})
		.catch(function(error) {

			console.error(error);

			if (error.message === "LOGIN_REQUIRED") {
				alert("로그인이 필요합니다.");
				return;
			}

			if (error.message === "FORBIDDEN") {
				alert("본인이 작성한 게시글만 모집 상태를 변경할 수 있습니다.");
				return;
			}

			if (error.message === "NOT_FOUND") {
				alert("존재하지 않는 게시글입니다.");
				return;
			}

			alert("모집 상태 변경 중 오류가 발생했습니다.");

		})
		.finally(function() {

			mateRecruitStatusButton.disabled = false;

		});

	});

}

/* =========================================================
 * 여행 메이트 신고
 * ========================================================= */
(function () {

	const reportButton = document.getElementById("mateReportButton");
	const reportModal = document.getElementById("mateReportModal");
	const reportForm = document.getElementById("mateReportForm");
	const reportFormView = document.getElementById("mateReportFormView");
	const reportSuccessView = document.getElementById("mateReportSuccessView");
	const reportSubmit = document.getElementById("mateReportSubmit");
	const reportDetail = document.getElementById("mateReportDetail");
	const reportDetailCount = document.getElementById("mateReportDetailCount");
	const reportError = document.getElementById("mateReportError");
	const reportToast = document.getElementById("mateReportToast");
	const closeButtons = document.querySelectorAll("[data-mate-report-close]");

	if (!reportButton || !reportModal || !reportForm) {
		return;
	}

	let toastTimer = null;

	/* ================================
	 * 신고 버튼
	 * ================================ */
	reportButton.addEventListener("click", function () {

		const loggedIn = reportButton.dataset.loggedIn === "true";
		const isOwner = reportButton.dataset.isOwner === "true";
		const loginUrl = reportButton.dataset.loginUrl;

		if (!loggedIn) {
			window.location.href = loginUrl;
			return;
		}

		if (isOwner) {
			showReportToast();
			return;
		}

		resetReportModal();

		reportModal.showModal();
		document.body.style.overflow = "hidden";
	});

	/* ================================
	 * 신고 사유 선택
	 * ================================ */
	reportForm.addEventListener("change", function (event) {

		if (event.target.name !== "reasonId") {
			return;
		}

		reportSubmit.disabled = false;
		hideReportError();
	});

	/* ================================
	 * 상세 내용 글자 수
	 * ================================ */
	if (reportDetail) {
		reportDetail.addEventListener("input", function () {

			if (reportDetail.value.length > 300) {
				reportDetail.value = reportDetail.value.substring(0, 300);
			}

			reportDetailCount.textContent = reportDetail.value.length + " / 300";
		});
	}

	/* ================================
	 * 신고 전송
	 * ================================ */
	reportForm.addEventListener("submit", function (event) {
		event.preventDefault();

		const selectedReason = reportForm.querySelector('input[name="reasonId"]:checked');

		if (!selectedReason) {
			showReportError("신고 사유를 선택해주세요.");
			return;
		}

		reportSubmit.disabled = true;

		const originalText = reportSubmit.textContent;
		reportSubmit.textContent = "접수 중...";

		const formData = new URLSearchParams(new FormData(reportForm));

		fetch(reportForm.action, {
			method: "POST",
			headers: {
				"Content-Type": "application/x-www-form-urlencoded;charset=UTF-8"
			},
			body: formData.toString()
		})
			.then(function (response) {
				return response.json().then(function (data) {
					return {
						ok: response.ok,
						status: response.status,
						data: data
					};
				});
			})
			.then(function (result) {

				if (!result.ok || !result.data.success) {
					throw new Error(result.data.message || "신고 접수에 실패했습니다.");
				}

				reportFormView.hidden = true;
				reportSuccessView.hidden = false;

			})
			.catch(function (error) {
				showReportError(error.message || "신고 접수 중 오류가 발생했습니다.");
			})
			.finally(function () {
				reportSubmit.textContent = originalText;

				const selectedReasonAfterRequest = reportForm.querySelector('input[name="reasonId"]:checked');
				reportSubmit.disabled = !selectedReasonAfterRequest;
			});
	});

	/* ================================
	 * 닫기 버튼
	 * ================================ */
	closeButtons.forEach(function (button) {
		button.addEventListener("click", function () {
			closeReportModal();
		});
	});

	/* ================================
	 * ESC로 닫기
	 * ================================ */
	reportModal.addEventListener("cancel", function (event) {
		event.preventDefault();
		closeReportModal();
	});

	/* ================================
	 * 바깥 영역 클릭
	 * ================================ */
	reportModal.addEventListener("click", function (event) {

		if (event.target === reportModal) {
			closeReportModal();
		}
	});

	/* ================================
	 * 신고 모달 초기화
	 * ================================ */
	function resetReportModal() {

		reportForm.reset();

		reportFormView.hidden = false;
		reportSuccessView.hidden = true;

		reportSubmit.disabled = true;

		if (reportDetailCount) {
			reportDetailCount.textContent = "0 / 300";
		}

		hideReportError();
	}

	/* ================================
	 * 신고 모달 닫기
	 * ================================ */
	function closeReportModal() {

		if (reportModal.open) {
			reportModal.close();
		}

		document.body.style.overflow = "";

		resetReportModal();
	}

	/* ================================
	 * 에러 표시
	 * ================================ */
	function showReportError(message) {

		if (!reportError) {
			return;
		}

		reportError.textContent = message;
		reportError.hidden = false;
	}

	function hideReportError() {

		if (!reportError) {
			return;
		}

		reportError.textContent = "";
		reportError.hidden = true;
	}

	/* ================================
	 * 본인 게시글 신고 토스트
	 * ================================ */
	function showReportToast() {

		if (!reportToast) {
			return;
		}

		if (toastTimer) {
			clearTimeout(toastTimer);
		}

		reportToast.classList.add("show");

		toastTimer = setTimeout(function () {
			reportToast.classList.remove("show");
		}, 2500);
	}

})();