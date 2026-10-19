package service.advertisement;

import java.net.URI;
import java.sql.Date;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

import org.apache.ibatis.session.SqlSession;

import config.MybatisSqlSessionFactory;
import dao.admin.AdminAdvertisementDao;
import dao.admin.AdminAdvertisementDaoImpl;
import dao.advertisement.AdvertisementDao;
import dao.advertisement.AdvertisementDaoImpl;
import dto.advertisement.AdvertisementDto;

public class AdvertisementServiceImpl implements AdvertisementService {

	private final AdvertisementDao advertisementDao = new AdvertisementDaoImpl();
	private final AdminAdvertisementDao adminDao = new AdminAdvertisementDaoImpl();

	@Override
	public long submitAdvertisement(AdvertisementDto advertisement) throws Exception {

		if (advertisement == null) {
			throw new IllegalArgumentException("광고 신청 정보를 확인해주세요.");
		}

		/*
		 * ===================================================== 업체명
		 * ======================================================
		 */

		String businessName = normalize(advertisement.getBusinessName());

		if (businessName.isEmpty()) {
			throw new IllegalArgumentException("회사 또는 브랜드명을 입력해주세요.");
		}

		if (businessName.length() > 100) {
			throw new IllegalArgumentException("회사 또는 브랜드명은 100자 이하로 입력해주세요.");
		}

		/*
		 * ===================================================== 담당자명
		 * ======================================================
		 */

		String managerName = normalize(advertisement.getManagerName());

		if (managerName.isEmpty()) {
			throw new IllegalArgumentException("담당자명을 입력해주세요.");
		}

		if (managerName.length() > 100) {
			throw new IllegalArgumentException("담당자명은 100자 이하로 입력해주세요.");
		}

		/*
		 * ===================================================== 전화번호
		 * ======================================================
		 */

		String phone = normalize(advertisement.getContactPhone());

		if (phone.isEmpty()) {
			throw new IllegalArgumentException("연락처를 입력해주세요.");
		}

		if (phone.length() > 30) {
			throw new IllegalArgumentException("연락처를 확인해주세요.");
		}

		/*
		 * ===================================================== 이메일
		 * ======================================================
		 */

		String email = normalize(advertisement.getContactEmail());

		if (email.isEmpty()) {
			throw new IllegalArgumentException("이메일을 입력해주세요.");
		}

		if (email.length() > 150) {
			throw new IllegalArgumentException("이메일은 150자 이하로 입력해주세요.");
		}

		if (!email.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")) {
			throw new IllegalArgumentException("올바른 이메일 형식이 아닙니다.");
		}

		/*
		 * ===================================================== 광고 위치
		 * ======================================================
		 */

		/*
		 * ===================================================== 광고 위치
		 * ======================================================
		 */

		String adPosition = normalize(advertisement.getAdPosition());

		/*
		 * 현재 실제 광고 영역
		 *
		 * TRIP_CARD → 홈 인기 여행일정 슬라이딩 카드
		 *
		 * TIP_SIDE → 여행 꿀팁 상세 좌·우 사이드
		 *
		 * MATE_SIDE → 여행 메이트 상세 좌·우 사이드
		 *
		 * CART_SIDE → 일정 카트 좌·우 사이드
		 */
		if (!"TRIP_CARD".equals(adPosition) && !"TIP_SIDE".equals(adPosition) && !"MATE_SIDE".equals(adPosition)
				&& !"CART_SIDE".equals(adPosition)) {

			throw new IllegalArgumentException("올바른 광고 영역을 선택해주세요.");
		}

		/*
		 * ===================================================== 날짜
		 * ======================================================
		 */

		if (advertisement.getStartDate() == null || advertisement.getEndDate() == null) {
			throw new IllegalArgumentException("광고 기간을 선택해주세요.");
		}

		LocalDate startDate = advertisement.getStartDate().toLocalDate();

		LocalDate endDate = advertisement.getEndDate().toLocalDate();

		if (startDate.isBefore(LocalDate.now())) {
			throw new IllegalArgumentException("광고 시작일은 오늘 이후로 선택해주세요.");
		}

		if (endDate.isBefore(startDate)) {
			throw new IllegalArgumentException("광고 종료일은 시작일 이후여야 합니다.");
		}

		/*
		 * ===================================================== 광고 내용
		 * ======================================================
		 */

		String adContent = normalize(advertisement.getAdContent());

		if (adContent.isEmpty()) {
			throw new IllegalArgumentException("광고 내용을 입력해주세요.");
		}

		if (adContent.length() > 3000) {
			throw new IllegalArgumentException("광고 내용은 최대 3000자까지 입력할 수 있습니다.");
		}

		/*
		 * ===================================================== 이미지
		 * ======================================================
		 */

		String imageUrl = normalize(advertisement.getImageUrl());

		if (imageUrl.isEmpty()) {
			throw new IllegalArgumentException("광고 이미지를 등록해주세요.");
		}

		if (imageUrl.length() > 500) {
			throw new IllegalArgumentException("광고 이미지 경로가 너무 깁니다.");
		}

		/*
		 * ===================================================== 링크
		 * ======================================================
		 */

		String linkUrl = normalize(advertisement.getLinkUrl());

		if (linkUrl.isEmpty()) throw new IllegalArgumentException("광고 연결 주소를 입력해주세요.");
		if (!linkUrl.isEmpty()) {
			if (linkUrl.length() > 500) {
				throw new IllegalArgumentException("광고 연결 주소는 500자 이하로 입력해주세요.");
			}

			try {
				URI uri = new URI(linkUrl);
				String scheme = uri.getScheme();
				if (uri.getHost() == null || scheme == null || (!"http".equalsIgnoreCase(scheme) && !"https".equalsIgnoreCase(scheme))) {
					throw new IllegalArgumentException("광고 연결 주소는 http 또는 https 주소만 사용할 수 있습니다.");
				}

			} catch (IllegalArgumentException e) {
				throw e;

			} catch (Exception e) {
				throw new IllegalArgumentException("올바른 광고 연결 주소를 입력해주세요.");
			}
		}

		/*
		 * ===================================================== 정리된 값 다시 DTO에 저장
		 * ======================================================
		 */

        String siteName = normalize(advertisement.getSiteName());
        String headline = normalize(advertisement.getHeadline());
        String description = normalize(advertisement.getDescription());
        if ("TRIP_CARD".equals(adPosition)) {
            if (siteName.isEmpty() || headline.isEmpty() || description.isEmpty())
                throw new IllegalArgumentException("홈 광고의 홈페이지명, 제목, 소개 문구를 입력해주세요.");
            if (siteName.length() > 80 || headline.length() > 100 || description.length() > 300)
                throw new IllegalArgumentException("홈 광고 문구의 최대 길이를 확인해주세요.");
        } else { siteName = ""; headline = ""; description = ""; }
        advertisement.setSiteName(siteName.isEmpty() ? null : siteName);
        advertisement.setHeadline(headline.isEmpty() ? null : headline);
        advertisement.setDescription(description.isEmpty() ? null : description);

		advertisement.setBusinessName(businessName);
		advertisement.setManagerName(managerName);
		advertisement.setContactPhone(phone);
		advertisement.setContactEmail(email);
		advertisement.setAdContent(adContent);
		advertisement.setAdPosition(adPosition);
		advertisement.setImageUrl(imageUrl);
        String imageUrlRight = normalize(advertisement.getImageUrlRight());
        if (!"TIP_SIDE".equals(adPosition) && !"MATE_SIDE".equals(adPosition) && !"CART_SIDE".equals(adPosition)) imageUrlRight = "";
        if (imageUrlRight.length() > 500) throw new IllegalArgumentException("오른쪽 광고 이미지 경로가 너무 깁니다.");
        advertisement.setImageUrlRight(imageUrlRight.isEmpty() ? null : imageUrlRight);

		advertisement.setLinkUrl(linkUrl.isEmpty() ? null : linkUrl);

		/*
		 * 사용자가 상태를 결정하면 안 됨
		 */
		advertisement.setStatus("PENDING_APPROVAL");

		/*
		 * ===================================================== 광고 + 접수 이력을 하나의 트랜잭션으로
		 * 저장 ======================================================
		 */

		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession(false)) {
			try {
				int adResult = advertisementDao.insertAdvertisement(sqlSession, advertisement);
				if (adResult != 1 || advertisement.getAdId() <= 0) {
					throw new IllegalStateException("광고 문의 등록에 실패했습니다.");
				}
				int historyResult = advertisementDao.insertSubmittedHistory(sqlSession, advertisement.getAdId(),
						advertisement.getContactEmail());
				if (historyResult != 1) {
					throw new IllegalStateException("광고 접수 이력 저장에 실패했습니다.");
				}

				sqlSession.commit();

				return advertisement.getAdId();

			} catch (Exception e) {
				sqlSession.rollback();
				throw e;
			}
		}
	}

	private String normalize(String value) {
		return value == null ? "" : value.trim();
	}

	@Override
	public List<Map<String, Object>> getAllAds() throws Exception {

		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {
			return adminDao.selectAllAds(sqlSession);
		}
	}

	@Override
	public void approve(long adId, long adminUserId) throws Exception {
		validateIds(adId, adminUserId);

		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession(false)) {
			try {
				Map<String, Object> ad = requireAd(sqlSession, adId);
				String oldStatus = stringValue(ad.get("status"));

				if (!"PENDING_APPROVAL".equals(oldStatus)) {

					throw new IllegalStateException("승인 대기 상태의 광고만 승인할 수 있습니다.");
				}

				int updated = adminDao.approvedAd(sqlSession, adId, adminUserId);

				requireUpdated(updated);

				Date endDate = toSqlDate(ad.get("endDate"));

				adminDao.insertHistory(sqlSession, adId, adminUserId, "APPROVED", oldStatus, "PENDING_PUBLICATION",
						endDate, endDate, null);

				sqlSession.commit();

			} catch (Exception e) {

				sqlSession.rollback();

				throw e;
			}
		}
	}

	@Override
	public void reject(long adId, long adminUserId, String reason) throws Exception {
		validateIds(adId, adminUserId);

		String normalizedReason = normalizeRequiredReason(reason, "거절 사유를 입력해주세요.");

		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession(false)) {

			try {

				Map<String, Object> ad = requireAd(sqlSession, adId);

				String oldStatus = stringValue(ad.get("status"));

				if (!"PENDING_APPROVAL".equals(oldStatus)) {

					throw new IllegalStateException("승인 대기 상태의 광고만 거절할 수 있습니다.");
				}

				int updated = adminDao.rejectAd(sqlSession, adId, adminUserId, normalizedReason);

				requireUpdated(updated);

				Date endDate = toSqlDate(ad.get("endDate"));

				adminDao.insertHistory(sqlSession, adId, adminUserId, "REJECTED", oldStatus, "REJECTED", endDate,
						endDate, normalizedReason);

				sqlSession.commit();

			} catch (Exception e) {

				sqlSession.rollback();

				throw e;
			}
		}
	}

	@Override
	public void activate(long adId, long adminUserId) throws Exception {
		validateIds(adId, adminUserId);

		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession(false)) {

			try {

				Map<String, Object> ad = requireAd(sqlSession, adId);

				String oldStatus = stringValue(ad.get("status"));

				if (!"PENDING_PUBLICATION".equals(oldStatus)) {

					throw new IllegalStateException("게시 대기 상태의 광고만 게시할 수 있습니다.");
				}

				int updated = adminDao.activateAd(sqlSession, adId, adminUserId);

				requireUpdated(updated);

				Date endDate = toSqlDate(ad.get("endDate"));

				adminDao.insertHistory(sqlSession, adId, adminUserId, "ACTIVATED", oldStatus, "ACTIVE", endDate,
						endDate, null);

				sqlSession.commit();

			} catch (Exception e) {

				sqlSession.rollback();

				throw e;
			}
		}
	}

	@Override
	public void withdraw(long adId, long adminUserId, String reason) throws Exception {
		validateIds(adId, adminUserId);

		String normalizedReason = normalizeOptionalReason(reason);

		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession(false)) {

			try {

				Map<String, Object> ad = requireAd(sqlSession, adId);

				String oldStatus = stringValue(ad.get("status"));

				if (!"PENDING_PUBLICATION".equals(oldStatus) && !"ACTIVE".equals(oldStatus)) {

					throw new IllegalStateException("게시 대기 또는 게시 중인 광고만 철회할 수 있습니다.");
				}

				int updated = adminDao.withdrawAd(sqlSession, adId, adminUserId, normalizedReason);

				requireUpdated(updated);

				Date endDate = toSqlDate(ad.get("endDate"));

				adminDao.insertHistory(sqlSession, adId, adminUserId, "WITHDRAWN", oldStatus, "WITHDRAWN", endDate,
						endDate, normalizedReason);

				sqlSession.commit();

			} catch (Exception e) {

				sqlSession.rollback();

				throw e;
			}
		}
	}

	@Override
	public void extend(long adId, long adminUserId, Date newEndDate) throws Exception {
		validateIds(adId, adminUserId);

		if (newEndDate == null) {

			throw new IllegalArgumentException("새 종료일을 선택해주세요.");
		}

		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession(false)) {

			try {

				Map<String, Object> ad = requireAd(sqlSession, adId);

				String oldStatus = stringValue(ad.get("status"));

				if (!"ACTIVE".equals(oldStatus)) {

					throw new IllegalStateException("게시 중인 광고만 기간을 연장할 수 있습니다.");
				}

				Date oldEndDate = toSqlDate(ad.get("endDate"));

				if (oldEndDate != null && !newEndDate.after(oldEndDate)) {

					throw new IllegalArgumentException("새 종료일은 현재 종료일보다 이후여야 합니다.");
				}

				int updated = adminDao.extendAd(sqlSession, adId, adminUserId, newEndDate);

				requireUpdated(updated);

				adminDao.insertHistory(sqlSession, adId, adminUserId, "EXTENDED", oldStatus, "ACTIVE", oldEndDate,
						newEndDate, null);

				sqlSession.commit();

			} catch (Exception e) {

				sqlSession.rollback();

				throw e;
			}
		}
	}

	@Override
	public void delete(long adId, long adminUserId) throws Exception {
		validateIds(adId, adminUserId);

		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession(false)) {

			try {

				Map<String, Object> ad = requireAd(sqlSession, adId);

				String oldStatus = stringValue(ad.get("status"));

				if (!"ACTIVE".equals(oldStatus)) {

					throw new IllegalStateException("게시 중인 광고만 삭제할 수 있습니다.");
				}

				int updated = adminDao.deleteAd(sqlSession, adId, adminUserId);

				requireUpdated(updated);

				Date endDate = toSqlDate(ad.get("endDate"));

				adminDao.insertHistory(sqlSession, adId, adminUserId, "DELETED", oldStatus, "DELETED", endDate, endDate,
						null);

				sqlSession.commit();

			} catch (Exception e) {

				sqlSession.rollback();

				throw e;
			}
		}
	}

	private Map<String, Object> requireAd(SqlSession sqlSession, long adId) throws Exception {

		Map<String, Object> ad = adminDao.selectAdForUpdate(sqlSession, adId);

		if (ad == null) {

			throw new IllegalArgumentException("광고 정보를 찾을 수 없습니다.");
		}

		return ad;
	}

	/*
	 * ========================================================= ID 검사
	 * =========================================================
	 */

	private void validateIds(long adId, long adminUserId) {

		if (adId <= 0) {

			throw new IllegalArgumentException("올바른 광고 번호가 아닙니다.");
		}

		if (adminUserId <= 0) {

			throw new SecurityException("관리자 정보를 확인할 수 없습니다.");
		}
	}

	/*
	 * ========================================================= UPDATE 결과 검사
	 * =========================================================
	 */

	private void requireUpdated(int updated) {

		if (updated != 1) {

			throw new IllegalStateException("광고 상태 변경에 실패했습니다. 화면을 새로고침한 뒤 다시 시도해주세요.");
		}
	}

	/*
	 * ========================================================= 필수 사유
	 * =========================================================
	 */

	private String normalizeRequiredReason(String reason, String emptyMessage) {

		String value = normalizeOptionalReason(reason);

		if (value == null) {

			throw new IllegalArgumentException(emptyMessage);
		}

		return value;
	}

	/*
	 * ========================================================= 선택 사유
	 * =========================================================
	 */

	private String normalizeOptionalReason(String reason) {

		if (reason == null) {
			return null;
		}

		String value = reason.trim();

		if (value.isEmpty()) {
			return null;
		}

		if (value.codePointCount(0, value.length()) > 1000) {

			throw new IllegalArgumentException("사유는 최대 1000자까지 입력할 수 있습니다.");
		}

		return value;
	}

	private String stringValue(Object value) {

		return value == null ? "" : String.valueOf(value);
	}

	/*
	 * MyBatis Map의 Date를 java.sql.Date로 변환
	 */
	private Date toSqlDate(Object value) {

		if (value == null) {
			return null;
		}

		if (value instanceof Date) {

			return (Date) value;
		}

		if (value instanceof java.util.Date) {

			return new Date(((java.util.Date) value).getTime());
		}

		try {

			return Date.valueOf(String.valueOf(value).substring(0, 10));

		} catch (Exception e) {

			return null;
		}
	}
}
