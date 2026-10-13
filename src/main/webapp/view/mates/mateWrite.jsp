<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%
request.setAttribute("activePage", "mate");
%>

<!DOCTYPE html>
<html lang="ko">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">

	<title>여행 메이트 작성 · Tripily</title>

	<jsp:include page="/common/headStyles.jsp" />
	<link rel="stylesheet" href="${pageContext.request.contextPath}/view/assets/css/mates/mateWrite.css">
	<script defer src="${pageContext.request.contextPath}/view/assets/js/mates/mateWrite.js"></script>
</head>

<body class="site-shell">

	<jsp:include page="/common/header.jsp" />

	<div class="min-h-screen" style="background: #f5f5ff">

		<!-- 상단 배너 -->
		<div class="relative" style="height: 220px">

			<img
				src="https://images.unsplash.com/photo-1488646953014-85cb44e25828?fit=crop&w=1600&q=80"
				alt="여행 메이트 작성"
				class="absolute inset-0 w-full h-full object-cover"
				style="object-position: center 30%">

			<div
				class="absolute inset-0"
				style="background: linear-gradient(135deg, rgba(20, 12, 70, .80) 0%, rgba(99, 105, 209, .50) 55%, rgba(20, 12, 70, .40) 100%)">
			</div>

			<div
				class="absolute inset-0 flex flex-col items-center justify-center text-center px-4"
				style="padding-top: 64px">

				<span
					class="inline-flex items-center gap-1.5 text-[11px] font-bold tracking-widest uppercase px-3 py-1 rounded-full mb-3"
					style="background: #FFD447; color: #1a1a2e">
					✈ 여행 메이트 작성
				</span>

				<h1
					class="text-white font-bold leading-snug"
					style="font-family: Georgia, serif; font-size: clamp(1.4rem, 3vw, 2rem); font-style: italic; text-shadow: 0 2px 16px rgba(0, 0, 0, .4)">
					함께라서 더 특별한 여행
				</h1>

				<p class="mt-2 text-sm" style="color: #D1D2F9">
					같은 여행을 꿈꾸는 여행 메이트를 찾아보세요.
				</p>
			</div>
		</div>


		<!-- 작성 영역 -->
		<div class="w-full max-w-3xl mx-auto px-4 py-10">

			<form
				action="${pageContext.request.contextPath}/mateWrite"
				method="post"
				enctype="multipart/form-data"
				class="bg-white rounded-2xl shadow-md overflow-hidden"
				style="border: 1.5px solid #D1D2F9">

				<!-- 작성폼 상단 -->
				<div
					class="flex items-center justify-between gap-4 px-4 sm:px-8 py-5 flex-wrap"
					style="background: linear-gradient(135deg, #6369D1 0%, #8b91e3 100%)">

					<div>
						<h2 class="text-lg font-bold text-white">
							여행 메이트 모집하기
						</h2>

						<p class="text-sm mt-0.5" style="color: #D1D2F9">
							함께 여행할 메이트를 모집해보세요.
						</p>
					</div>

					<a
						href="${pageContext.request.contextPath}/mates"
						class="flex items-center gap-1.5 px-4 py-2 rounded-full text-sm font-semibold text-white"
						style="background: rgba(255, 255, 255, .15); border: 1px solid rgba(255, 255, 255, .3)">
						‹ 목록으로
					</a>
				</div>


				<!-- 입력폼 -->
				<div class="px-4 sm:px-8 py-8 flex flex-col gap-8">

					<!-- 1. 제목 -->
					<div>

						<label
							class="flex items-center gap-1.5 text-sm font-bold mb-2"
							style="color: #6369D1">

							<span
								class="w-5 h-5 rounded-full flex items-center justify-center text-white text-xs font-bold bg-[#6369D1]">
								1
							</span>

							제목

							<span class="text-red-500 text-xs">*</span>
						</label>

						<div class="relative">

							<input
								type="text"
								name="title"
								maxlength="200"
								data-char-input
								class="jsp-focus w-full rounded-xl px-4 py-3 pr-20 text-sm text-gray-800 outline-none"
								style="border: 1.5px solid #D1D2F9"
								placeholder="모집 제목을 입력해주세요."
								required>

							<span
								class="absolute right-4 top-1/2 -translate-y-1/2 text-xs text-gray-300">

								<span data-char-count>0</span>/200

							</span>
						</div>
					</div>


					<!-- 2. 여행지 -->
					<div>

						<label
							class="flex items-center gap-1.5 text-sm font-bold mb-2"
							style="color: #6369D1">

							<span
								class="w-5 h-5 rounded-full flex items-center justify-center text-white text-xs font-bold bg-[#6369D1]">
								2
							</span>

							여행지

							<span class="text-red-500 text-xs">*</span>
						</label>

						<input
							type="text"
							name="country"
							maxlength="100"
							class="jsp-focus w-full rounded-xl px-4 py-3 text-sm text-gray-800 outline-none"
							style="border: 1.5px solid #D1D2F9"
							placeholder="나라 (예: 일본)"
							required>

						<p class="mt-2 text-xs text-gray-400">
							함께 여행할 국가를 입력해주세요. 예: 일본, 프랑스, 대한민국
						</p>
					</div>


					<!-- 3. 모집 인원 -->
					<div>

						<label
							class="flex items-center gap-1.5 text-sm font-bold mb-3"
							style="color: #6369D1">

							<span
								class="w-5 h-5 rounded-full flex items-center justify-center text-white text-xs font-bold bg-[#6369D1]">
								3
							</span>

							모집 인원

							<span class="text-red-500 text-xs">*</span>
						</label>

						<div class="flex items-center gap-4">

							<button
								type="button"
								id="recruitMinus"
								class="w-10 h-10 rounded-full flex items-center justify-center text-xl text-gray-600 transition-colors"
								style="border: 1.5px solid #D1D2F9">
								−
							</button>

							<div class="flex items-center gap-2">

								<input
									type="number"
									id="recruitCount"
									name="recruitCount"
									value="1"
									min="1"
									max="99"
									readonly
									class="w-10 text-center text-lg font-bold text-gray-800 outline-none bg-transparent">

								<span class="text-sm text-gray-400">
									명
								</span>
							</div>

							<button
								type="button"
								id="recruitPlus"
								class="w-10 h-10 rounded-full flex items-center justify-center text-xl text-gray-600 transition-colors"
								style="border: 1.5px solid #D1D2F9">
								+
							</button>
						</div>
					</div>


					<!-- 4. 내용 -->
					<div>

						<label
							class="flex items-center gap-1.5 text-sm font-bold mb-3"
							style="color: #6369D1">

							<span
								class="w-5 h-5 rounded-full flex items-center justify-center text-white text-xs font-bold bg-[#6369D1]">
								4
							</span>

							내용

							<span class="text-red-500 text-xs">*</span>
						</label>

						<div
							class="rounded-xl overflow-hidden"
							style="border: 1.5px solid #D1D2F9">

							<!-- 에디터 메뉴 -->
							<div
								class="flex flex-wrap gap-1 px-3 py-2 border-b border-[#D1D2F9] bg-[#FAFAFF]">

								<button
									type="button"
									class="px-2 py-1 text-xs font-bold">
									↩
								</button>

								<button
									type="button"
									class="px-2 py-1 text-xs font-bold">
									↪
								</button>

								<button
									type="button"
									class="px-2 py-1 text-xs">
									본문 ▾
								</button>

								<button
									type="button"
									class="px-2 py-1 text-xs font-bold">
									B
								</button>

								<button
									type="button"
									class="px-2 py-1 text-xs italic">
									I
								</button>

								<button
									type="button"
									class="px-2 py-1 text-xs underline">
									U
								</button>

								<button
									type="button"
									class="px-2 py-1 text-xs">
									🖼
								</button>
							</div>

							<textarea
								name="content"
								class="w-full min-h-[260px] p-4 outline-none resize-y text-sm text-gray-700"
								placeholder="여행 일정, 원하는 메이트 스타일, 연락 방법 등을 자유롭게 작성해주세요."
								required></textarea>
						</div>
					</div>


					<!-- 사진 첨부 -->
					<div>

						<div class="flex items-center justify-between gap-3 mb-2">

							<label
								class="flex items-center gap-2 text-sm font-bold"
								style="color: #6369D1">
								📎 사진 첨부
							</label>

							<span class="text-xs text-gray-400">
								최대 5장
							</span>
						</div>

						<label
							class="rounded-xl py-12 px-4 flex flex-col items-center justify-center gap-3 cursor-pointer"
							style="border: 2px dashed #D1D2F9; background: #fafaff">

							<input
								type="file"
								id="mateImages"
								name="images"
								multiple
								accept="image/*"
								class="hidden">

							<div class="w-14 h-14 rounded-2xl flex items-center justify-center bg-[#D1D2F9]">

								<svg
									width="28"
									height="28"
									viewBox="0 0 24 24"
									fill="none"
									stroke="#6369D1"
									stroke-width="1.8">

									<rect
										x="3"
										y="3"
										width="18"
										height="18"
										rx="2" />

									<circle
										cx="8.5"
										cy="8.5"
										r="1.5" />

									<polyline
										points="21 15 16 10 5 21" />
								</svg>
							</div>

							<div class="text-center">

								<p class="text-sm font-semibold text-[#6369D1]">
									사진을 드래그하거나 클릭하여 업로드하세요.
								</p>

								<p class="text-xs text-gray-400 mt-0.5">
									JPG, PNG, GIF 파일 (최대 10MB)
								</p>
							</div>
						</label>


						<!-- 선택한 이미지 미리보기 -->
						<div
							id="mateImagePreview"
							style="
								display: grid;
								grid-template-columns: repeat(auto-fill, minmax(140px, 180px));
								gap: 12px;
								margin-top: 16px;
								width: 100%;
							">
						</div>
					</div>


					<!-- 하단 버튼 -->
					<div class="flex justify-end gap-3 pt-2 flex-wrap">

						<a
							href="${pageContext.request.contextPath}/mates"
							class="px-8 py-3 rounded-full text-sm font-semibold text-center"
							style="border: 2px solid #D1D2F9; color: #6369D1">
							취소
						</a>

						<button
							type="submit"
							class="px-8 py-3 rounded-full text-white text-sm font-bold shadow-md"
							style="background: linear-gradient(135deg, #6369D1 0%, #8b91e3 100%)">
							등록하기
						</button>
					</div>

				</div>
			</form>
		</div>
	</div>

	<jsp:include page="/common/footer.jsp" />

</body>
</html>