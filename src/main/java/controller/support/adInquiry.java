package controller.support;

import java.io.IOException;
import java.io.InputStream;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;

import java.sql.Date;

import java.util.UUID;

import javax.servlet.ServletException;

import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;

import dto.advertisement.AdvertisementDto;
import dto.member.UserDto;

import service.advertisement.AdvertisementService;
import service.advertisement.AdvertisementServiceImpl;

@WebServlet("/support/adInquiry")

@MultipartConfig(fileSizeThreshold = 1024 * 1024, maxFileSize = 5 * 1024 * 1024, maxRequestSize = 7 * 1024 * 1024)

public class adInquiry extends HttpServlet {

	private static final long serialVersionUID = 1L;

	private final AdvertisementService service = new AdvertisementServiceImpl();

	public adInquiry() {

		super();
	}

	/*
	 * ========================================================= 광고 문의 페이지
	 * =========================================================
	 */

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		request.getRequestDispatcher("/view/support/adInquiry.jsp").forward(request, response);
	}

	/*
	 * ========================================================= 광고 문의 등록
	 * =========================================================
	 */

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		request.setCharacterEncoding("UTF-8");

		Path savedImagePath = null;

		/*
		 * 오류 발생 시 사용자가 입력한 값을 다시 JSP에 표시하기 위해 바깥에서 선언
		 */

		String businessName = null;

		String managerName = null;

		String phone = null;

		String email = null;

		String content = null;

		String linkUrl = null;

		String adPosition = null;

		String startDateValue = null;

		String endDateValue = null;

		try {

			/*
			 * ================================================= 로그인 사용자
			 *
			 * 광고 문의는 비회원도 가능 =================================================
			 */

			HttpSession session = request.getSession(false);

			UserDto user = session == null ? null : (UserDto) session.getAttribute("user");

			Long applicantUserId = user == null ? null : user.getUserId();

			/*
			 * ================================================= 입력값
			 * =================================================
			 */

			businessName = normalize(request.getParameter("businessName"));

			managerName = normalize(request.getParameter("managerName"));

			phone = normalize(request.getParameter("phone"));

			email = normalize(request.getParameter("email"));

			content = normalize(request.getParameter("content"));

			linkUrl = normalizeNullable(request.getParameter("linkUrl"));

			adPosition = normalize(request.getParameter("adPosition"));

			startDateValue = normalize(request.getParameter("startDate"));

			endDateValue = normalize(request.getParameter("endDate"));

			/*
			 * ================================================= 기본 입력값 검사
			 * =================================================
			 */

			validateRequired(businessName, "회사/브랜드명을 입력해주세요.");

			validateRequired(managerName, "담당자명을 입력해주세요.");

			validateRequired(phone, "전화번호를 입력해주세요.");

			validateRequired(email, "이메일을 입력해주세요.");

			validateRequired(content, "광고 및 문의 내용을 입력해주세요.");

			/*
			 * ================================================= 광고 위치 검사
			 *
			 * 현재 실제 사용하는 광고 상품은
			 *
			 * TRIP_CARD TIP_SIDE MATE_SIDE
			 *
			 * 3종 =================================================
			 */

			validateAdPosition(adPosition);

			/*
			 * ================================================= 날짜
			 * =================================================
			 */

			Date startDate = parseDate(startDateValue, "광고 시작일");

			Date endDate = parseDate(endDateValue, "광고 종료일");

			/*
			 * 종료일이 시작일보다 이전이면 안 됨
			 */

			if (endDate.before(startDate)) {

				throw new IllegalArgumentException("광고 종료일은 시작일 이후로 선택해주세요.");
			}

			/*
			 * ================================================= 이미지
			 * =================================================
			 */

			Part imagePart = request.getPart("image");

			if (imagePart == null || imagePart.getSize() <= 0) {

				throw new IllegalArgumentException("광고 이미지를 등록해주세요.");
			}

			/*
			 * 최대 5MB
			 */

			if (imagePart.getSize() > 5L * 1024L * 1024L) {

				throw new IllegalArgumentException("광고 이미지는 최대 5MB까지 등록할 수 있습니다.");
			}

			/*
			 * 이미지 형식
			 */

			String contentType = imagePart.getContentType();

			String extension;

			if ("image/jpeg".equalsIgnoreCase(contentType)) {

				extension = ".jpg";

			} else if ("image/png".equalsIgnoreCase(contentType)) {

				extension = ".png";

			} else if ("image/webp".equalsIgnoreCase(contentType)) {

				extension = ".webp";

			} else {

				throw new IllegalArgumentException("JPG, PNG, WEBP 이미지만 등록할 수 있습니다.");
			}

			/*
			 * ================================================= 저장 파일명
			 * =================================================
			 */

			String storedFileName = UUID.randomUUID().toString().replace("-", "") + extension;

			/*
			 * ================================================= 저장 경로
			 * =================================================
			 */

			String uploadRealPath = getServletContext().getRealPath("/uploads/ads");

			if (uploadRealPath == null) {

				throw new IllegalStateException("광고 이미지 저장 경로를 찾을 수 없습니다.");
			}

			Path uploadDirectory = Paths.get(uploadRealPath);

			Files.createDirectories(uploadDirectory);

			savedImagePath = uploadDirectory.resolve(storedFileName);

			/*
			 * 실제 파일 저장
			 */

			try (InputStream inputStream = imagePart.getInputStream()) {

				Files.copy(inputStream, savedImagePath, StandardCopyOption.REPLACE_EXISTING);
			}

			/*
			 * DB에는 실제 서버 경로가 아니라 웹 접근 URL 저장
			 */

			String imageUrl = "/uploads/ads/" + storedFileName;

			/*
			 * ================================================= DTO
			 * =================================================
			 */

			AdvertisementDto advertisement = new AdvertisementDto();

			advertisement.setApplicantUserId(applicantUserId);

			advertisement.setBusinessName(businessName);

			advertisement.setManagerName(managerName);

			advertisement.setContactPhone(phone);

			advertisement.setContactEmail(email);

			advertisement.setAdContent(content);

			advertisement.setImageUrl(imageUrl);

			advertisement.setLinkUrl(linkUrl);

			advertisement.setAdPosition(adPosition);

			advertisement.setStartDate(startDate);

			advertisement.setEndDate(endDate);

			/*
			 * ================================================= DB 등록
			 * =================================================
			 */

			long adId = service.submitAdvertisement(advertisement);

			System.out.println("광고 문의 접수 완료" + " / adId = " + adId + " / position = " + adPosition);

			/*
			 * ================================================= 성공
			 *
			 * JSP 직접 이동이 아니라 Servlet으로 다시 이동
			 * =================================================
			 */

			response.sendRedirect(request.getContextPath() + "/support/adInquiry" + "?success=1");

		} catch (IllegalArgumentException e) {

			/*
			 * DB 등록 전에 이미지를 저장했다면 실패 시 삭제
			 */

			deleteSavedFile(savedImagePath);

			/*
			 * 입력값 유지
			 */

			preserveFormValues(request, businessName, managerName, phone, email, content, linkUrl, adPosition,
					startDateValue, endDateValue);

			request.setAttribute("errorMessage", e.getMessage());

			request.getRequestDispatcher("/view/support/adInquiry.jsp").forward(request, response);

		} catch (IllegalStateException e) {

			deleteSavedFile(savedImagePath);

			preserveFormValues(request, businessName, managerName, phone, email, content, linkUrl, adPosition,
					startDateValue, endDateValue);

			getServletContext().log("광고 문의 처리 오류", e);

			request.setAttribute("errorMessage", "광고 문의 접수 중 오류가 발생했습니다.");

			request.getRequestDispatcher("/view/support/adInquiry.jsp").forward(request, response);

		} catch (Exception e) {

			deleteSavedFile(savedImagePath);

			preserveFormValues(request, businessName, managerName, phone, email, content, linkUrl, adPosition,
					startDateValue, endDateValue);

			getServletContext().log("광고 문의 처리 중 오류 발생", e);

			request.setAttribute("errorMessage", "광고 문의 접수 중 오류가 발생했습니다.");

			request.getRequestDispatcher("/view/support/adInquiry.jsp").forward(request, response);
		}
	}

	/*
	 * ========================================================= 광고 위치 검사
	 * =========================================================
	 */

	private void validateAdPosition(String adPosition) {

		if (adPosition == null || (!"TRIP_CARD".equals(adPosition) && !"TIP_SIDE".equals(adPosition)
				&& !"MATE_SIDE".equals(adPosition))) {

			throw new IllegalArgumentException("올바른 광고 영역을 선택해주세요.");
		}
	}

	/*
	 * ========================================================= 필수 입력값 검사
	 * =========================================================
	 */

	private void validateRequired(String value, String message) {

		if (value == null || value.trim().isEmpty()) {

			throw new IllegalArgumentException(message);
		}
	}

	/*
	 * ========================================================= 일반 문자열 정리
	 * =========================================================
	 */

	private String normalize(String value) {

		if (value == null) {
			return null;
		}

		return value.trim();
	}

	/*
	 * ========================================================= 빈 문자열은 NULL 처리
	 *
	 * linkUrl처럼 선택 입력값에 사용
	 * =========================================================
	 */

	private String normalizeNullable(String value) {

		if (value == null) {
			return null;
		}

		String normalized = value.trim();

		return normalized.isEmpty() ? null : normalized;
	}

	/*
	 * ========================================================= 오류 발생 시 입력값 유지
	 * =========================================================
	 */

	private void preserveFormValues(HttpServletRequest request, String businessName, String managerName, String phone,
			String email, String content, String linkUrl, String adPosition, String startDate, String endDate) {

		request.setAttribute("businessName", businessName);

		request.setAttribute("managerName", managerName);

		request.setAttribute("phone", phone);

		request.setAttribute("email", email);

		request.setAttribute("content", content);

		request.setAttribute("linkUrl", linkUrl);

		request.setAttribute("adPosition", adPosition);

		request.setAttribute("startDate", startDate);

		request.setAttribute("endDate", endDate);
	}

	/*
	 * ========================================================= 날짜 변환
	 * =========================================================
	 */

	private Date parseDate(String value, String fieldName) {

		if (value == null || value.trim().isEmpty()) {

			throw new IllegalArgumentException(fieldName + "을 선택해주세요.");
		}

		try {

			return Date.valueOf(value.trim());

		} catch (IllegalArgumentException e) {

			throw new IllegalArgumentException("올바른 " + fieldName + "을 선택해주세요.");
		}
	}

	/*
	 * ========================================================= 실패 시 저장한 이미지 삭제
	 * =========================================================
	 */

	private void deleteSavedFile(Path savedImagePath) {

		if (savedImagePath == null) {

			return;
		}

		try {

			Files.deleteIfExists(savedImagePath);

		} catch (IOException e) {

			getServletContext().log("광고 이미지 임시 파일 삭제 실패", e);
		}
	}
}