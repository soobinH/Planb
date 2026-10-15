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

import dto.community.MateDto;
import dto.community.MateMediaDto;
import dto.member.UserDto;
import service.community.MateMediaService;
import service.community.MateMediaServiceImpl;
import service.community.MateService;
import service.community.MateServiceImpl;
import util.PostImageOrder;
import util.image.SharedImageStorage;

@WebServlet("/mateModify")
@MultipartConfig(
	fileSizeThreshold = 1024 * 1024,
	maxFileSize = 10 * 1024 * 1024,
	maxRequestSize = 50 * 1024 * 1024
)
public class MateModify extends HttpServlet {

	private static final long serialVersionUID = 1L;

	private MateService mateService;
	private MateMediaService mateMediaService;

	@Override
	public void init() throws ServletException {
		mateService = new MateServiceImpl();
		mateMediaService = new MateMediaServiceImpl();
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
		// 2. mateId 받기
		// ========================================
		String mateIdParam = request.getParameter("mateId");

		if (mateIdParam == null || mateIdParam.trim().isEmpty()) {
			response.sendRedirect(request.getContextPath() + "/mates");
			return;
		}

		try {

			long mateId = Long.parseLong(mateIdParam);

			// ========================================
			// 3. 게시글 조회
			// ========================================
			MateDto mate = mateService.selectMate(mateId);

			if (mate == null) {
				response.sendRedirect(request.getContextPath() + "/mates");
				return;
			}

			// ========================================
			// 4. 작성자 확인
			// ========================================
			if (mate.getUserId() != userId) {
				response.sendError(
					HttpServletResponse.SC_FORBIDDEN,
					"본인이 작성한 글만 수정할 수 있습니다."
				);
				return;
			}

			// ========================================
			// 5. 현재 등록된 이미지 전체 조회
			// ========================================
			List<MateMediaDto> mateMediaList =
				mateMediaService.selectMateMediaList(mateId);

			// ========================================
			// 6. 수정 JSP로 전달
			// ========================================
			request.setAttribute("mate", mate);
			request.setAttribute("mateMediaList", mateMediaList);

			request.getRequestDispatcher(
				"/view/mates/mateModify.jsp"
			).forward(request, response);

		} catch (NumberFormatException e) {

			response.sendRedirect(
				request.getContextPath() + "/mates"
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
			long mateId =
				Long.parseLong(request.getParameter("mateId"));

			String title =
				request.getParameter("title");

			String country =
				request.getParameter("country");

			String recruitCountParam =
				request.getParameter("recruitCount");

			String content =
				request.getParameter("content");

			String[] deletedMediaIds =
				request.getParameterValues("deletedMediaIds");

			// ========================================
			// 3. 기본 입력값 검사
			// ========================================
			if (
				title == null
				|| title.trim().isEmpty()
				|| country == null
				|| country.trim().isEmpty()
				|| recruitCountParam == null
				|| recruitCountParam.trim().isEmpty()
				|| content == null
				|| content.trim().isEmpty()
			) {

				response.sendRedirect(
					request.getContextPath()
						+ "/mateModify?mateId="
						+ mateId
				);

				return;
			}

			int recruitCount =
				Integer.parseInt(recruitCountParam);

			if (recruitCount < 1 || recruitCount > 99) {

				response.sendRedirect(
					request.getContextPath()
						+ "/mateModify?mateId="
						+ mateId
				);

				return;
			}

			// ========================================
			// 4. 기존 게시글 + 작성자 확인
			// ========================================
			MateDto oldMate =
				mateService.selectMate(mateId);

			if (oldMate == null) {

				response.sendRedirect(
					request.getContextPath() + "/mates"
				);

				return;
			}

			if (oldMate.getUserId() != user.getUserId()) {

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

					// 삭제할 이미지 정보 조회
					MateMediaDto deleteMedia =
						mateMediaService.selectMateMedia(
							mediaId
						);

					if (deleteMedia == null) {
						continue;
					}

					// 현재 게시글의 이미지인지 확인
					if (deleteMedia.getMateId() != mateId) {
						continue;
					}

					String deleteImageUrl =
						deleteMedia.getMediaUrl();

					// TB_MATE_MEDIA 삭제
					int deleteResult =
						mateMediaService.deleteMateMedia(
							mediaId,
							mateId
						);

					// DB 삭제 성공 시 실제 파일 삭제
					if (deleteResult > 0) {

						SharedImageStorage.deleteByWebUrl(
							deleteImageUrl
						);
					}
				}
			}

			// ========================================
			// 7. 삭제 처리 후 현재 이미지 다시 조회
			// ========================================
			List<MateMediaDto> existingMediaList =
				mateMediaService.selectMateMediaList(
					mateId
				);

			int existingImageCount = 0;
			int maxSortOrder = 0;

			for (MateMediaDto media : existingMediaList) {

				if ("IMAGE".equals(media.getMediaType())) {

					existingImageCount++;

					if (media.getSortOrder() > maxSortOrder) {
						maxSortOrder = media.getSortOrder();
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
					SharedImageStorage.saveImage(part,
						SharedImageStorage.Category.MATE
					);

				imageUrls.add(imageUrl);
			}

			// ========================================
			// 10. 게시글 기본 정보 수정
			// ========================================
			MateDto mate =
				new MateDto();

			mate.setMateId(mateId);
			mate.setUserId(user.getUserId());
			mate.setTitle(title.trim());
			mate.setCountry(country.trim());
			mate.setRecruitCount(recruitCount);
			/*
			 * 본문의 사진 표시를 "본문에 나온 순서"로 다시 번호 매김
			 * (작성 화면과 동일하게 글 맨 위 사진이 대표 이미지가 되도록)
			 */
			PostImageOrder.Result imageOrder =
				PostImageOrder.reorder(content.trim(), existingImageCount + imageUrls.size());

			mate.setContent(imageOrder.getContent());

			int result =
				mateService.updateMate(mate);

			if (result == 0) {

				response.sendError(
					HttpServletResponse.SC_FORBIDDEN,
					"수정할 수 없는 게시글입니다."
				);

				return;
			}

			// ========================================
			// 11. 새 이미지 DB 등록
			// ========================================
			int sortOrder =
				maxSortOrder + 1;

			for (String imageUrl : imageUrls) {

				MateMediaDto mediaDto =
					new MateMediaDto();

				mediaDto.setMateId(mateId);
				mediaDto.setMediaType("IMAGE");
				mediaDto.setMediaUrl(imageUrl);
				mediaDto.setSortOrder(sortOrder);

				mateMediaService.insertMateMedia(
					mediaDto
				);

				sortOrder++;
			}

			// ========================================
			// 사진 순서를 본문에 나온 순서대로 다시 정렬
			//  - 현재 목록 순서 : 남은 기존 사진 → 새 사진 (본문의 [[IMG:n]] 기준 순서)
			// ========================================
			List<MateMediaDto> orderedMediaList =
				mateMediaService.selectMateMediaList(mateId);

			int imageIndex = 0;

			for (MateMediaDto media : orderedMediaList) {

				if (!"IMAGE".equals(media.getMediaType())) {
					continue;
				}

				if (imageIndex >= existingImageCount + imageUrls.size()) {
					break;
				}

				mateMediaService.updateMateMediaSortOrder(
					media.getMediaId(),
					mateId,
					imageOrder.getNewOrder(imageIndex)
				);

				imageIndex++;
			}

			// ========================================
			// 12. 대표 이미지 다시 설정
			// ========================================
			MateMediaDto firstMedia =
				mateMediaService.selectFirstMateMedia(
					mateId
				);

			MateDto imageMate =
				new MateDto();

			imageMate.setMateId(mateId);
			imageMate.setUserId(user.getUserId());

			if (firstMedia != null) {

				imageMate.setImg(
					firstMedia.getMediaUrl()
				);

			} else {

				imageMate.setImg(null);
			}

			mateService.updateMateImage(
				imageMate
			);

			// ========================================
			// 13. 수정 완료 → 상세페이지
			// ========================================
			response.sendRedirect(
				request.getContextPath()
					+ "/mateDetail?mateId="
					+ mateId
			);

		} catch (NumberFormatException e) {

			response.sendRedirect(
				request.getContextPath()
					+ "/mates"
			);

		} catch (Exception e) {

			e.printStackTrace();
			throw new ServletException(e);
		}
	}
}