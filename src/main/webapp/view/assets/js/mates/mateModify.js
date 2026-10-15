// ========================================
// 여행 메이트 수정 페이지
//  - 내용 편집기 : community/postEditor.js (글 사이사이 사진, 기존 사진 유지 / 삭제)
//  - 제목 글자 수 / 모집 인원 − + 버튼
// ========================================
PostEditor.init({
	editor: "postEditor",
	fileInput: "postImages",
	contentInput: "postContent",
	error: "postContentError",
	addButton: "postImageButton",
	count: "postImageCount",
	source: "postContentSource",
	existing: "existingMediaData",
	deleted: "deletedMediaInputs"
});

PostEditor.bindCharCount();

PostEditor.bindStepper("recruitMinus", "recruitPlus", "recruitCount");
