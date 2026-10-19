package controller.support;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
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
import util.image.SharedImageStorage;
import util.image.SharedImageStorage.Category;

@WebServlet("/support/adInquiry")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize = 5 * 1024 * 1024,
        maxRequestSize = 12 * 1024 * 1024)
public class adInquiry extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final long MAX_IMAGE_SIZE = 5L * 1024L * 1024L;
    private final AdvertisementService service = new AdvertisementServiceImpl();

    public adInquiry() {
        super();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/view/support/adInquiry.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        for (String field : new String[]{"siteName", "headline", "description"}) {
            request.setAttribute(field, request.getParameter(field));
        }
        Path savedImagePath = null;
        Path savedImageRightPath = null;

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
            HttpSession session = request.getSession(false);
            UserDto user = session == null ? null : (UserDto) session.getAttribute("user");
            Long applicantUserId = user == null ? null : user.getUserId();

            businessName = normalize(request.getParameter("businessName"));
            managerName = normalize(request.getParameter("managerName"));
            phone = normalize(request.getParameter("phone"));
            email = normalize(request.getParameter("email"));
            content = normalize(request.getParameter("content"));
            linkUrl = normalizeNullable(request.getParameter("linkUrl"));
            adPosition = normalize(request.getParameter("adPosition"));
            startDateValue = normalize(request.getParameter("startDate"));
            endDateValue = normalize(request.getParameter("endDate"));

            validateRequired(businessName, "회사/브랜드명을 입력해주세요.");
            validateRequired(managerName, "담당자명을 입력해주세요.");
            validateRequired(phone, "전화번호를 입력해주세요.");
            validateRequired(email, "이메일을 입력해주세요.");
            validateRequired(content, "광고 및 문의 내용을 입력해주세요.");
            validateAdPosition(adPosition);

            Date startDate = parseDate(startDateValue, "광고 시작일");
            Date endDate = parseDate(endDateValue, "광고 종료일");
            if (endDate.before(startDate)) {
                throw new IllegalArgumentException("광고 종료일은 시작일 이후로 선택해주세요.");
            }

            Part imagePart = request.getPart("image");
            if (imagePart == null || imagePart.getSize() <= 0) {
                throw new IllegalArgumentException("광고 이미지를 등록해주세요.");
            }
            if (imagePart.getSize() > MAX_IMAGE_SIZE) {
                throw new IllegalArgumentException("광고 이미지는 최대 5MB까지 등록할 수 있습니다.");
            }

            boolean dualImages = "TIP_SIDE".equals(adPosition) || "MATE_SIDE".equals(adPosition) || "CART_SIDE".equals(adPosition);
            Part rightImagePart = dualImages ? request.getPart("imageRight") : null;
            String rightExtension = null;
            if (rightImagePart != null && rightImagePart.getSize() > 0) {
                if (rightImagePart.getSize() > MAX_IMAGE_SIZE) {
                    throw new IllegalArgumentException("오른쪽 광고 이미지는 최대 5MB까지 등록할 수 있습니다.");
                }
                rightExtension = getImageExtension(rightImagePart.getContentType());
            }

            String extension = getImageExtension(imagePart.getContentType());
            String storedFileName = "ad_" + UUID.randomUUID().toString().replace("-", "") + extension;

            /*
             * 회원가입 프로필 업로드와 동일한 공유 이미지 저장소 사용.
             */
            Category adCategory = Category.ADS;

            /*
             * 공유 저장소가 실제로 연결되어 있고 쓰기가 가능한지 확인한다.
             * 연결이 끊긴 경우 Tomcat 로컬 폴더에 대신 저장하지 않는다.
             */
            Path adDirectory = SharedImageStorage.ensureCategoryDirectory(adCategory);
            savedImagePath = SharedImageStorage.resolveFile(adCategory, storedFileName);
            if (!adDirectory.equals(savedImagePath.getParent())) {
                throw new IllegalStateException("광고 이미지 저장 경로가 올바르지 않습니다.");
            }

            try (InputStream inputStream = imagePart.getInputStream()) {
                Files.copy(inputStream, savedImagePath, StandardCopyOption.REPLACE_EXISTING);
            }

            /* DB에는 다른 이미지와 동일하게 공유 저장소의 웹 URL만 저장한다. */
            String imageUrl = SharedImageStorage.toWebUrl(adCategory, storedFileName);

            String imageUrlRight = dualImages ? imageUrl : null;
            if (rightExtension != null) {
                String rightFileName = "ad_" + UUID.randomUUID().toString().replace("-", "") + rightExtension;
                savedImageRightPath = SharedImageStorage.resolveFile(adCategory, rightFileName);
                if (!adDirectory.equals(savedImageRightPath.getParent())) {
                    throw new IllegalStateException("오른쪽 광고 이미지 저장 경로가 올바르지 않습니다.");
                }
                try (InputStream inputStream = rightImagePart.getInputStream()) {
                    Files.copy(inputStream, savedImageRightPath, StandardCopyOption.REPLACE_EXISTING);
                }
                imageUrlRight = SharedImageStorage.toWebUrl(adCategory, rightFileName);
            }

            AdvertisementDto advertisement = new AdvertisementDto();
            advertisement.setApplicantUserId(applicantUserId);
            advertisement.setSiteName(request.getParameter("siteName"));
            advertisement.setHeadline(request.getParameter("headline"));
            advertisement.setDescription(request.getParameter("description"));
            advertisement.setBusinessName(businessName);
            advertisement.setManagerName(managerName);
            advertisement.setContactPhone(phone);
            advertisement.setContactEmail(email);
            advertisement.setAdContent(content);
            advertisement.setImageUrl(imageUrl);
            advertisement.setImageUrlRight(imageUrlRight);
            advertisement.setLinkUrl(linkUrl);
            advertisement.setAdPosition(adPosition);
            advertisement.setStartDate(startDate);
            advertisement.setEndDate(endDate);

            long adId = service.submitAdvertisement(advertisement);
            getServletContext().log("광고 문의 접수 완료 / adId=" + adId
                    + " / image=" + savedImagePath.toAbsolutePath());

            response.sendRedirect(request.getContextPath() + "/support/adInquiry?success=1");

        } catch (IllegalArgumentException e) {
            deleteSavedFile(savedImagePath);
            deleteSavedFile(savedImageRightPath);
            preserveFormValues(request, businessName, managerName, phone, email,
                    content, linkUrl, adPosition, startDateValue, endDateValue);
            request.setAttribute("errorMessage", e.getMessage());
            request.getRequestDispatcher("/view/support/adInquiry.jsp").forward(request, response);

        } catch (IllegalStateException e) {
            deleteSavedFile(savedImagePath);
            deleteSavedFile(savedImageRightPath);
            preserveFormValues(request, businessName, managerName, phone, email,
                    content, linkUrl, adPosition, startDateValue, endDateValue);
            getServletContext().log("광고 문의 처리 오류", e);
            request.setAttribute("errorMessage", "광고 문의 접수 중 오류가 발생했습니다.");
            request.getRequestDispatcher("/view/support/adInquiry.jsp").forward(request, response);

        } catch (Exception e) {
            deleteSavedFile(savedImagePath);
            deleteSavedFile(savedImageRightPath);
            preserveFormValues(request, businessName, managerName, phone, email,
                    content, linkUrl, adPosition, startDateValue, endDateValue);
            getServletContext().log("광고 문의 처리 중 오류 발생", e);
            request.setAttribute("errorMessage", "광고 문의 접수 중 오류가 발생했습니다.");
            request.getRequestDispatcher("/view/support/adInquiry.jsp").forward(request, response);
        }
    }

    private String getImageExtension(String contentType) {
        if ("image/jpeg".equalsIgnoreCase(contentType)) {
            return ".jpg";
        }
        if ("image/png".equalsIgnoreCase(contentType)) {
            return ".png";
        }
        if ("image/webp".equalsIgnoreCase(contentType)) {
            return ".webp";
        }
        throw new IllegalArgumentException("JPG, PNG, WEBP 이미지만 등록할 수 있습니다.");
    }

    private void validateAdPosition(String adPosition) {
        if (adPosition == null || (!"TRIP_CARD".equals(adPosition)
                && !"TIP_SIDE".equals(adPosition)
                && !"MATE_SIDE".equals(adPosition)
                && !"CART_SIDE".equals(adPosition))) {
            throw new IllegalArgumentException("올바른 광고 영역을 선택해주세요.");
        }
    }

    private void validateRequired(String value, String message) {
        if (value == null || value.trim().isEmpty()) {
            throw new IllegalArgumentException(message);
        }
    }

    private String normalize(String value) {
        return value == null ? null : value.trim();
    }

    private String normalizeNullable(String value) {
        if (value == null) {
            return null;
        }
        String normalized = value.trim();
        return normalized.isEmpty() ? null : normalized;
    }

    private void preserveFormValues(HttpServletRequest request,
            String businessName, String managerName, String phone, String email,
            String content, String linkUrl, String adPosition,
            String startDate, String endDate) {
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

    private void deleteSavedFile(Path savedImagePath) {
        if (savedImagePath == null) {
            return;
        }
        try {
            Files.deleteIfExists(savedImagePath);
        } catch (IOException e) {
            getServletContext().log("광고 이미지 저장 실패 후 파일 삭제 실패", e);
        }
    }
}
