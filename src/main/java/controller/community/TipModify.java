package controller.community;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;

import dto.community.TipDto;
import dto.community.TipMediaDto;
import dto.member.UserDto;
import service.community.TipMediaService;
import service.community.TipMediaServiceImpl;
import service.community.TipService;
import service.community.TipServiceImpl;
import util.PostImageOrder;
import util.image.SharedImageStorage;

@WebServlet("/tipModify")
@MultipartConfig(
	fileSizeThreshold = 1024 * 1024,
	maxFileSize = 10 * 1024 * 1024,
	maxRequestSize = 50 * 1024 * 1024
)
public class TipModify extends HttpServlet {

	private static final long serialVersionUID = 1L;

	private TipService tipService;
	private TipMediaService tipMediaService;

	@Override
	public void init() throws ServletException {
		tipService = new TipServiceImpl();
		tipMediaService = new TipMediaServiceImpl();
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

		request.setCharacterEncoding("UTF-8");

		// ========================================
		// 1. 로그인 확인
		// ========================================
		HttpSession session = request.getSession(false);

		if (session == null || session.getAttribute("user") == null) {
			response.sendRedirect(request.getContextPath() + "/auth/login");
			return;
		}

		UserDto user = (UserDto) session.getAttribute("user");
		long userId = user.getUserId();

		// ========================================
		// 2. tipId 받기
		// ========================================
		String tipIdParam = request.getParameter("tipId");

		if (tipIdParam == null || tipIdParam.trim().isEmpty()) {
			response.sendRedirect(request.getContextPath() + "/tipWriteList");
			return;
		}

		try {

			long tipId = Long.parseLong(tipIdParam);

			// ========================================
			// 3. 게시글 조회
			// ========================================
			TipDto tip = tipService.selectTipDetail(tipId);

			if (tip == null) {
				response.sendRedirect(request.getContextPath() + "/tipWriteList");
				return;
			}

			// ========================================
			// 4. 본인이 작성한 글인지 확인
			// ========================================
			if (tip.getUserId() != userId) {
				response.sendError(
					HttpServletResponse.SC_FORBIDDEN,
					"본인이 작성한 글만 수정할 수 있습니다."
				);
				return;
			}

			// ========================================
			// 5. 현재 등록된 이미지 전체 조회
			// ========================================
			List<TipMediaDto> tipMediaList =
				tipMediaService.selectTipMediaList(tipId);

			// ========================================
			// 6. 수정 JSP로 전달
			// ========================================
			request.setAttribute("tip", tip);
			request.setAttribute("tipMediaList", tipMediaList);

			request.getRequestDispatcher(
				"/view/tips/tipModify.jsp"
			).forward(request, response);

		} catch (NumberFormatException e) {

			response.sendRedirect(
				request.getContextPath() + "/tipWriteList"
			);

		} catch (Exception e) {

			e.printStackTrace();
			throw new ServletException(e);
		}
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

		request.setCharacterEncoding("UTF-8");

		// ========================================
		// 1. 로그인 확인
		// ========================================
		HttpSession session = request.getSession(false);

		if (session == null || session.getAttribute("user") == null) {
			response.sendRedirect(request.getContextPath() + "/auth/login");
			return;
		}

		UserDto user = (UserDto) session.getAttribute("user");

		try {

			// ========================================
			// 2. 수정 값 받기
			// ========================================
			long tipId = Long.parseLong(request.getParameter("tipId"));

			String title = request.getParameter("title");
			String country = request.getParameter("country");
			String city = request.getParameter("city");
			String hashtag = request.getParameter("hashtag");
			String content = request.getParameter("content");
			String[] deletedMediaIds = request.getParameterValues("deletedMediaIds");

			// ========================================
			// 3. 기본 입력값 검사
			// ========================================
			if (title == null || title.trim().isEmpty() || country == null || country.trim().isEmpty()
				|| city == null || city.trim().isEmpty() || content == null || content.trim().isEmpty()) {
				response.sendRedirect(request.getContextPath() + "/tipModify?tipId=" + tipId);
				return;
			}

			// ========================================
			// 4. 기존 게시글 + 작성자 확인
			// ========================================
			TipDto oldTip =
				tipService.selectTipDetail(tipId);

			if (oldTip == null) {

				response.sendRedirect(
					request.getContextPath() + "/tipWriteList"
				);

				return;
			}

			if (oldTip.getUserId() != user.getUserId()) {

				response.sendError(
					HttpServletResponse.SC_FORBIDDEN,
					"본인이 작성한 글만 수정할 수 있습니다."
				);

				return;
			}

			// ========================================
			// 5. 새 이미지 파일 확인
			// ========================================
			List<Part> newImageParts =
				new ArrayList<>();

			for (Part part : request.getParts()) {

				if (!"images".equals(part.getName())) {
					continue;
				}

				if (part.getSize() == 0) {
					continue;
				}

				String originalName =
					part.getSubmittedFileName();

				if (
					originalName == null
					|| originalName.trim().isEmpty()
				) {
					continue;
				}

				String contentType =
					part.getContentType();

				if (
					contentType == null
					|| !contentType.startsWith("image/")
				) {
					continue;
				}

				newImageParts.add(part);
			}

			// ========================================
			// 6. 사용자가 X 누른 기존 이미지 삭제
			// ========================================
			if (deletedMediaIds != null) {

				for (String mediaIdValue : deletedMediaIds) {

					if (
						mediaIdValue == null
						|| mediaIdValue.trim().isEmpty()
					) {
						continue;
					}

					long mediaId =
						Long.parseLong(mediaIdValue);

					// 삭제하기 전에 이미지 정보 조회
					TipMediaDto deleteMedia =
						tipMediaService.selectTipMedia(mediaId);

					if (deleteMedia == null) {
						continue;
					}

					// 현재 게시글의 이미지인지 확인
					if (deleteMedia.getTipId() != tipId) {
						continue;
					}

					String deleteImageUrl =
						deleteMedia.getMediaUrl();

					// DB 이미지 정보 삭제
					int deleteResult =
						tipMediaService.deleteTipMedia(
							mediaId,
							tipId
						);

					// DB 삭제 성공 후 실제 이미지 파일 삭제
					if (deleteResult > 0) {

						SharedImageStorage.deleteByWebUrl(
							deleteImageUrl
						);
					}
				}
			}

			// ========================================
			// 7. 삭제 후 남은 기존 이미지 조회
			// ========================================
			List<TipMediaDto> remainingMediaList =
				tipMediaService.selectTipMediaList(tipId);

			int existingImageCount = 0;
			int maxSortOrder = 0;

			for (TipMediaDto media : remainingMediaList) {

				if ("IMAGE".equals(media.getMediaType())) {

					existingImageCount++;

					if (media.getSortOrder() > maxSortOrder) {
						maxSortOrder =
							media.getSortOrder();
					}
				}
			}

			// ========================================
			// 8. 기존 + 신규 이미지 최대 5장 검사
			// ========================================
			if (
				existingImageCount
				+ newImageParts.size()
				> 5
			) {

				response.sendError(
					HttpServletResponse.SC_BAD_REQUEST,
					"사진은 기존 사진과 새 사진을 합쳐 최대 5장까지 등록할 수 있습니다."
				);

				return;
			}

			// ========================================
			// 9. 새 이미지 공유폴더에 저장
			// ========================================
			List<String> imageUrls =
				new ArrayList<>();

			for (Part part : newImageParts) {

				String imageUrl =
					SharedImageStorage.saveImage(
						part,
						SharedImageStorage.Category.TIP
					);

				imageUrls.add(imageUrl);
			}

			// ========================================
			// 10. 제목 / 여행지 / 내용 / 해시태그 수정
			// ========================================
			TipDto tip = new TipDto();

			tip.setTipId(tipId);
			tip.setUserId(user.getUserId());
			tip.setTitle(title.trim());
			tip.setCountry(country.trim());
			tip.setCity(city.trim());
			tip.setHashtag(hashtag == null ? null : hashtag.trim());
			/*
			 * 본문의 사진 표시를 "본문에 나온 순서"로 다시 번호 매김
			 * (작성 화면과 동일하게 글 맨 위 사진이 대표 이미지가 되도록)
			 */
			PostImageOrder.Result imageOrder =
				PostImageOrder.reorder(content.trim(), existingImageCount + imageUrls.size());

			tip.setContent(imageOrder.getContent());

			int result = tipService.updateTip(tip);

			if (result == 0) {
				response.sendError(HttpServletResponse.SC_FORBIDDEN,"수정할 수 없는 게시글입니다.");
				return;
			}

			// ========================================
			// 11. 새 이미지 DB 등록
			// ========================================
			int sortOrder =
				maxSortOrder + 1;

			for (String imageUrl : imageUrls) {

				TipMediaDto mediaDto =
					new TipMediaDto();

				mediaDto.setTipId(tipId);
				mediaDto.setMediaType("IMAGE");
				mediaDto.setMediaUrl(imageUrl);
				mediaDto.setSortOrder(sortOrder);

				tipMediaService.insertTipMedia(
					mediaDto
				);

				sortOrder++;
			}

			// ========================================
			// 11-1. 사진 순서를 본문에 나온 순서대로 다시 정렬
			//  - 현재 목록 순서 : 남은 기존 사진 → 새 사진 (본문의 [[IMG:n]] 기준 순서)
			// ========================================
			List<TipMediaDto> orderedMediaList =
				tipMediaService.selectTipMediaList(tipId);

			int imageIndex = 0;

			for (TipMediaDto media : orderedMediaList) {

				if (!"IMAGE".equals(media.getMediaType())) {
					continue;
				}

				if (imageIndex >= existingImageCount + imageUrls.size()) {
					break;
				}

				tipMediaService.updateTipMediaSortOrder(
					media.getMediaId(),
					tipId,
					imageOrder.getNewOrder(imageIndex)
				);

				imageIndex++;
			}

			// ========================================
			// 12. 최종 대표 이미지 다시 설정
			// ========================================
			TipMediaDto firstMedia =
				tipMediaService.selectFirstTipMedia(
					tipId
				);

			TipDto thumbnailTip =
				new TipDto();

			thumbnailTip.setTipId(tipId);
			thumbnailTip.setUserId(user.getUserId());

			if (firstMedia != null) {

				thumbnailTip.setThumbnailImg(
					firstMedia.getMediaUrl()
				);

			} else {

				thumbnailTip.setThumbnailImg(null);
			}

			tipService.updateTipThumbnail(
				thumbnailTip
			);

			// ========================================
			// 13. 수정 완료 → 상세페이지
			// ========================================
			response.sendRedirect(
				request.getContextPath()
					+ "/tipDetail?tipId="
					+ tipId
			);

		} catch (NumberFormatException e) {

			response.sendRedirect(
				request.getContextPath()
					+ "/tipWriteList"
			);

		} catch (Exception e) {

			e.printStackTrace();
			throw new ServletException(e);
		}
	}
}