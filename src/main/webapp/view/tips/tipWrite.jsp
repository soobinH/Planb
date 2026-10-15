<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%
request.setAttribute("activePage", "tips");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
	<meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
	<title>여행꿀팁 작성 · Tripily</title>
	<jsp:include page="/common/headStyles.jsp" />
	<link rel="stylesheet" href="${pageContext.request.contextPath}/view/assets/css/tips/tipWrite.css">
	<script defer src="${pageContext.request.contextPath}/view/assets/js/tips/tipWrite.js"></script>
</head>
<body class="site-shell"><jsp:include page="/common/header.jsp" />
	<div class="min-h-screen" style="background: #f5f5ff">
		<div class="relative" style="height: 220px">
			<img
				src="https://images.unsplash.com/photo-1488646953014-85cb44e25828?fit=crop&w=1600&q=80"
				alt="여행꿀팁 작성" class="absolute inset-0 w-full h-full object-cover"
				style="object-position: center 30%">
			<div class="absolute inset-0"
				style="background: linear-gradient(135deg, rgba(20, 12, 70, .80) 0%, rgba(99, 105, 209, .50) 55%, rgba(20, 12, 70, .40) 100%)"></div>
			<div
				class="absolute inset-0 flex flex-col items-center justify-center text-center px-4"
				style="padding-top: 64px">
				<span
					class="inline-flex items-center gap-1.5 text-[11px] font-bold tracking-widest uppercase px-3 py-1 rounded-full mb-3"
					style="background: #FFD447; color: #1a1a2e">✈ 여행꿀팁 작성</span>
				<h1 class="text-white font-bold leading-snug"
					style="font-family: Georgia, serif; font-size: clamp(1.4rem, 3vw, 2rem); font-style: italic; text-shadow: 0 2px 16px rgba(0, 0, 0, .4)">여행의
					모든 순간을 더 특별하게</h1>
				<p class="mt-2 text-sm" style="color: #D1D2F9">여행자들의 생생한 경험과 꿀팁을
					공유해보세요.</p>
			</div>
		</div>
		<div class="max-w-3xl mx-auto px-4 py-10">
			<form action="${pageContext.request.contextPath}/tipWrite" method="post" enctype="multipart/form-data"
				  class="bg-white rounded-2xl shadow-md overflow-hidden" style="border: 1.5px solid #D1D2F9">
				<div class="flex items-center justify-between px-8 py-5"
					style="background: linear-gradient(135deg, #6369D1 0%, #8b91e3 100%)">
					<div>
						<h2 class="text-lg font-bold text-white">여행꿀팁 작성하기</h2>
						<p class="text-sm mt-0.5" style="color: #D1D2F9">여러분의 소중한 경험이
							누군가에게 특별한 여행이 됩니다.</p>
					</div>
					<a href="${pageContext.request.contextPath}/tips"
						class="flex items-center gap-1.5 px-4 py-2 rounded-full text-sm font-semibold text-white"
						style="background: rgba(255, 255, 255, .15); border: 1px solid rgba(255, 255, 255, .3)">‹
						목록으로</a>
				</div>
				<div class="px-8 py-8 flex flex-col gap-8">
					<div>
						<label class="flex items-center gap-1.5 text-sm font-bold mb-2"
							style="color: #6369D1"><span
							class="w-5 h-5 rounded-full flex items-center justify-center text-white text-xs font-bold bg-[#6369D1]">1</span>제목
							<span class="text-red-500 text-xs">*</span></label>
						<div class="relative">
							<input type="text" name="title" maxlength="100" data-char-input
								class="jsp-focus w-full rounded-xl px-4 py-3 text-sm text-gray-800 outline-none"
								style="border: 1.5px solid #D1D2F9" placeholder="제목을 입력해주세요." required>
							<span class="absolute right-4 top-1/2 -translate-y-1/2 text-xs text-gray-300">
								<span data-char-count>0</span>/100
							</span>
						</div>
					</div>
					<!-- 여행지 -->
					<div>
						<label class="flex items-center gap-1.5 text-sm font-bold mb-2" style="color: #6369D1;">
							<span class="w-5 h-5 rounded-full flex items-center justify-center text-white text-xs font-bold bg-[#6369D1]">
								2
							</span>
							여행지
							<span class="text-red-500 text-xs">
								*
							</span>
						</label>
						<!-- 나라 / 도시 -->
						<div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
							<!-- 나라 -->
							<div>
								<label for="countryInput" class="block text-xs font-semibold text-gray-500 mb-2">
									나라
								</label>
								<input type="text" id="countryInput" autocomplete="off" placeholder="예: 일본, 홍콩, 베트남"
									class="jsp-focus w-full rounded-xl px-4 py-3 text-sm text-gray-800 outline-none"
									style="border: 1.5px solid #D1D2F9;">
								<input type="hidden" id="country" name="country">
								<!-- 나라 추천 -->
								<div id="countrySuggestions" lass="flex flex-wrap gap-2 mt-2"></div>
								<p id="countryError" class="hidden mt-2 text-xs" style="color: #ef4444;">
									나라를 입력한 후 아래 목록에서 나라를 선택해주세요.
								</p>
							</div>
							<!-- 도시 -->
							<div>
								<label for="cityInput" class="block text-xs font-semibold text-gray-500 mb-2">
									도시
								</label>
								<input type="text" id="cityInput" autocomplete="off" placeholder="예: 도쿄, 야우침몽구, 다낭" disabled
									class="jsp-focus w-full rounded-xl px-4 py-3 text-sm text-gray-800 outline-none 
									disabled:bg-gray-50 disabled:text-gray-400" style="border: 1.5px solid #D1D2F9;">
								<input type="hidden" id="city" name="city">
								<!-- 도시 추천 -->
								<div id="citySuggestions" class="flex flex-wrap gap-2 mt-2"></div>
								<p id="cityError" class="hidden mt-2 text-xs" style="color: #ef4444;">
									도시를 입력한 후 아래 목록에서 도시를 선택해주세요.
								</p>
							</div>
						</div>
						<p class="mt-3 text-xs text-gray-400">
							나라를 먼저 선택한 후 여행한 도시를 선택해주세요.
						</p>
					</div>
					<!-- 해시태그 -->
					<div>
						<label class="flex items-center gap-1.5 text-sm font-bold mb-2" style="color: #6369D1">
							<span class="w-5 h-5 rounded-full flex items-center justify-center text-white text-xs font-bold bg-[#6369D1]">
								3
							</span>
								해시태그
							<span class="text-xs font-normal text-gray-400">
								(선택)
							</span>
						</label>
						<input type="text" name="hashtag" class="jsp-focus w-full rounded-xl px-4 py-3 text-sm text-gray-800 outline-none"
							style="border: 1.5px solid #D1D2F9" placeholder="#교통 #맛집 #혼자여행">
						<p class="mt-2 text-xs text-gray-400">
							여행과 관련된 자유로운 키워드를 입력해주세요. 예: #교통 #맛집 #혼자여행
						</p>
					</div>

					<!-- [수정] 내용 + 사진 : 글 사이사이에 사진을 넣을 수 있는 편집기 -->
					<div>
						<label class="flex items-center gap-1.5 text-sm font-bold mb-3" style="color: #6369D1">
							<span class="w-5 h-5 rounded-full flex items-center justify-center text-white text-xs font-bold bg-[#6369D1]">
								4
							</span>내용
							<span class="text-red-500 text-xs">
								*
							</span>
						</label>
						<div class="tip-editor-wrap rounded-xl overflow-hidden" style="border: 1.5px solid #D1D2F9">
							<div class="flex flex-wrap items-center gap-1 px-3 py-2 border-b border-[#D1D2F9] bg-[#FAFAFF]">
								<button type="button" class="px-2 py-1 text-xs font-bold">↩</button>
								<button type="button" class="px-2 py-1 text-xs font-bold">↪</button>
								<button type="button" class="px-2 py-1 text-xs">본문 ▾</button>
								<button type="button" class="px-2 py-1 text-xs font-bold">B</button>
								<button type="button" class="px-2 py-1 text-xs italic">I</button>
								<button type="button" class="px-2 py-1 text-xs underline">U</button>
								<!-- 사진 추가 : 커서 위치에 삽입 -->
								<button type="button" id="tipImageButton" class="tip-editor-photo-btn">🖼 사진 추가</button>
								<span id="tipImageCount" class="tip-editor-count">0/5</span>
							</div>
							<div id="tipEditor"
								class="tip-editor is-empty"
								contenteditable="true"
								role="textbox"
								aria-multiline="true"
								aria-label="내용"
								data-placeholder="여행에서 직접 경험한 소중한 팁을 자세히 적어주세요."></div>
						</div>

						<!-- 편집기 내용은 전송 직전에 이 hidden 값(본문 + [[IMG:n]])으로 변환 -->
						<input type="hidden" name="content" id="tipContent">
						<!-- 사진 선택용 input : 전송 직전에 글에 나온 순서대로 파일이 채워짐 -->
						<input type="file" id="tipImages" name="images" multiple accept="image/*" class="hidden">

						<p id="tipContentError" class="hidden mt-2 text-xs" style="color: #ef4444;">
							내용을 입력해주세요.
						</p>
						<p class="mt-2 text-xs text-gray-400">
							사진을 넣을 위치에 커서를 두고 '사진 추가'를 누르거나, 사진을 글 안으로 끌어다 놓으세요.
							최대 5장 · JPG, PNG, GIF · 첫 번째 사진이 대표 이미지가 됩니다.
						</p>
					</div>

					<div class="flex justify-end gap-3 pt-2">
						<a href="${pageContext.request.contextPath}/tips" class="px-8 py-3 rounded-full text-sm font-semibold"
							style="border: 2px solid #D1D2F9; color: #6369D1">취소
						</a>
						<button
							class="px-8 py-3 rounded-full text-white text-sm font-bold shadow-md"
							style="background: linear-gradient(135deg, #6369D1 0%, #8b91e3 100%)">등록하기
						</button>
					</div>
				</div>
			</form>
		</div>
	</div>
	<jsp:include page="/common/footer.jsp" />
</body>
</html>
