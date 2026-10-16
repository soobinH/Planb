package service.itinerary;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.ibatis.session.SqlSession;

import config.MybatisSqlSessionFactory;
import dao.itinerary.ItineraryBlockDao;
import dao.itinerary.ItineraryBlockDaoImpl;
import dao.itinerary.ItineraryBlockImageDao;
import dao.itinerary.ItineraryBlockImageDaoImpl;
import dao.itinerary.ItineraryBookmarkDao;
import dao.itinerary.ItineraryBookmarkDaoImpl;
import dao.itinerary.ItineraryCommentDao;
import dao.itinerary.ItineraryCommentDaoImpl;
import dao.itinerary.ItineraryDao;
import dao.itinerary.ItineraryDaoImpl;
import dao.itinerary.ItineraryDayDao;
import dao.itinerary.ItineraryDayDaoImpl;
import dao.itinerary.ItineraryLikeDao;
import dao.itinerary.ItineraryLikeDaoImpl;
import dao.notification.NotificationDao;
import dao.notification.NotificationDaoImpl;
import dto.itinerary.ItineraryBlockDto;
import dto.itinerary.ItineraryBlockImageDto;
import dto.itinerary.ItineraryBookmarkDto;
import dto.itinerary.ItineraryCommentDto;
import dto.itinerary.ItineraryDayDto;
import dto.itinerary.ItineraryDto;
import dto.itinerary.ItineraryLikeDto;
import dto.notification.NotificationDto;
import service.notification.NotificationPushService;
import service.notification.NotificationPushServiceImpl;

public class ItineraryServiceImpl implements ItineraryService {

	private ItineraryDao itineraryDao;

	private ItineraryDayDao itineraryDayDao;

	private ItineraryBlockDao itineraryBlockDao;

	private ItineraryBlockImageDao itineraryBlockImageDao;

	private ItineraryBookmarkDao itineraryBookmarkDao;

	private ItineraryLikeDao itineraryLikeDao;

	private ItineraryCommentDao itineraryCommentDao;

	private NotificationDao notificationDao;

	private final NotificationPushService notificationPushService = new NotificationPushServiceImpl();

	public ItineraryServiceImpl() {

		itineraryDao = new ItineraryDaoImpl();

		itineraryDayDao = new ItineraryDayDaoImpl();

		itineraryBlockDao = new ItineraryBlockDaoImpl();

		itineraryBlockImageDao = new ItineraryBlockImageDaoImpl();

		itineraryBookmarkDao = new ItineraryBookmarkDaoImpl();

		itineraryLikeDao = new ItineraryLikeDaoImpl();

		itineraryCommentDao = new ItineraryCommentDaoImpl();

		notificationDao = new NotificationDaoImpl();
	}

	@Override

	public List<ItineraryDto> getScheduleList(Long loginUserId) throws Exception {

		return getScheduleList(loginUserId, "", "");

	}

	@Override

	public List<ItineraryDto> getScheduleList(Long loginUserId, String keyword) throws Exception {

		return getScheduleList(loginUserId, keyword, "");

	}

	@Override

	public List<ItineraryDto> getScheduleList(Long loginUserId, String keyword, String country) throws Exception {

		return getScheduleList(loginUserId, keyword, country, null, null, null);

	}

	@Override

	public List<ItineraryDto> getScheduleList(Long loginUserId, String keyword, String country, String[] durations,

			String[] budgets, String[] travelers) throws Exception {

		return getScheduleList(loginUserId, keyword, country, durations, budgets, travelers, "latest");

	}

	@Override

	public List<ItineraryDto> getScheduleList(Long loginUserId, String keyword, String country, String[] durations,

			String[] budgets, String[] travelers, String sort) throws Exception {

		return getScheduleList(loginUserId, keyword, country, durations, budgets, travelers, sort, 0);

	}

	// 무한 스크롤

	@Override

	public List<ItineraryDto> getScheduleList(Long loginUserId, String keyword, String country, String[] durations,

			String[] budgets, String[] travelers, String sort, int offset) throws Exception {

		if (offset < 0) {

			throw new IllegalArgumentException("올바르지 않은 조회 위치입니다.");

		}

		if (!"views".equals(sort) && !"likes".equals(sort)) {

			sort = "latest";

		}

		Map<String, Object> params = new HashMap<>();

		params.put("loginUserId", loginUserId);

		params.put("keyword", keyword == null ? "" : keyword.trim());

		params.put("country", country == null ? "" : country.trim());

		params.put("durations", validateFilterValues(durations));

		params.put("budgets", validateFilterValues(budgets));

		params.put("travelers", validateFilterValues(travelers));

		params.put("sort", sort);

		params.put("limit", 12);

		params.put("offset", offset);

		return itineraryDao.selectScheduleList(params);

	}

	// 체크박스 값은 1~6만 허용

	private List<String> validateFilterValues(String[] values) {

		List<String> result = new java.util.ArrayList<>();

		if (values == null) {

			return result;

		}

		for (String value : values) {

			if (value == null || !value.matches("[1-6]")) {

				throw new IllegalArgumentException("올바르지 않은 검색 조건입니다.");

			}

			if (!result.contains(value)) {

				result.add(value);

			}

		}

		return result;

	}

	@Override

	public long countScheduleList(String keyword, String country, String[] durations, String[] budgets,

			String[] travelers) throws Exception {

		Map<String, Object> params = new HashMap<>();

		params.put("keyword", keyword == null ? "" : keyword.trim());

		params.put("country", country == null ? "" : country.trim());

		params.put("durations", validateFilterValues(durations));

		params.put("budgets", validateFilterValues(budgets));

		params.put("travelers", validateFilterValues(travelers));

		return itineraryDao.countScheduleList(params);

	}

	// 통합검색용
	@Override
	public List<ItineraryDto> getSearchScheduleList(Long loginUserId, String keyword, int limit) throws Exception {
		Map<String, Object> params = new HashMap<>();

		params.put("loginUserId", loginUserId);
		params.put("keyword", keyword == null ? "" : keyword.trim());
		params.put("country", "");
		params.put("durations", validateFilterValues(null));
		params.put("budgets", validateFilterValues(null));
		params.put("travelers", validateFilterValues(null));
		params.put("sort", "latest");
		params.put("limit", limit);
		params.put("offset", 0);

		return itineraryDao.selectScheduleList(params);
	}

	@Override

	public ItineraryDto getScheduleDetail(Long itineraryId, Long loginUserId) throws Exception {

		if (itineraryId == null || itineraryId <= 0) {

			throw new IllegalArgumentException("올바른 일정 번호가 아닙니다.");

		}

		ItineraryDto itinerary = getItinerary(itineraryId);

		if (itinerary == null) {

			return null;

		}

		boolean isOwner = loginUserId != null && loginUserId.equals(itinerary.getUserId());

		if (!"PUBLIC".equals(itinerary.getVisibility()) && !isOwner) {

			return null;

		}

		Map<String, Object> params = new HashMap<>();

		params.put("itineraryId", itineraryId);

		params.put("loginUserId", loginUserId);

		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession(false)) {

			try {

				int updatedRows = itineraryDao.increaseScheduleViewCount(sqlSession, params);

				if (updatedRows != 1) {

					sqlSession.rollback();

					return null;

				}

				ItineraryDto detailInfo = itineraryDao.selectScheduleDetailInfo(sqlSession, itineraryId);

				if (detailInfo == null) {

					sqlSession.rollback();

					return null;

				}

				itinerary.setNickname(detailInfo.getNickname());
				itinerary.setProfileImg(detailInfo.getProfileImg());
				itinerary.setViewCount(detailInfo.getViewCount());
				itinerary.setLikeCount(itineraryLikeDao.countItineraryLikes(sqlSession, itineraryId));
				itinerary.setCommentCount(itineraryCommentDao.countItineraryComments(sqlSession, itineraryId));

				// 로그인 회원이 좋아요를 눌렀는지 확인

				if (loginUserId != null && loginUserId > 0) {

					ItineraryLikeDto like = new ItineraryLikeDto();

					like.setItineraryId(itineraryId);

					like.setUserId(loginUserId);

					itinerary.setLiked(itineraryLikeDao.selectItineraryLike(sqlSession, like));

				} else {
					itinerary.setLiked(false);
				}

				// 로그인 회원의 북마크 여부

				itinerary.setBookmarked(false);

				if (loginUserId != null && loginUserId > 0 && !isOwner) {

					ItineraryBookmarkDto bookmark = new ItineraryBookmarkDto();

					bookmark.setItineraryId(itineraryId);

					bookmark.setUserId(loginUserId);

					itinerary.setBookmarked(itineraryBookmarkDao.selectItineraryBookmark(sqlSession, bookmark));

				}

				sqlSession.commit();

				return itinerary;

			} catch (Exception e) {

				sqlSession.rollback();

				throw e;

			}

		}

	}

	@Override

	public Map<String, Object> toggleLike(Long itineraryId, Long loginUserId) throws Exception {

		if (loginUserId == null || loginUserId <= 0) {

			throw new SecurityException("로그인 후 이용할 수 있습니다.");

		}

		if (itineraryId == null || itineraryId <= 0) {

			throw new IllegalArgumentException("올바른 일정 번호가 아닙니다.");

		}

		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession(false)) {

			try {

				// 일정의 작성자·상태·공개 여부를 조회하기 위해 bookmarktargetforupdate 함수 재사용.

				ItineraryDto itinerary = itineraryBookmarkDao.selectBookmarkTargetForUpdate(sqlSession, itineraryId);

				if (itinerary == null || !"ACTIVE".equals(itinerary.getStatus())) {

					throw new IllegalArgumentException("일정을 찾을 수 없습니다.");

				}

				boolean isOwner = loginUserId.equals(itinerary.getUserId());

				if (!"PUBLIC".equals(itinerary.getVisibility()) && !isOwner) {

					throw new SecurityException("접근할 수 없는 일정입니다.");

				}

				ItineraryLikeDto like = new ItineraryLikeDto();

				like.setItineraryId(itineraryId);

				like.setUserId(loginUserId);

				boolean alreadyLiked = itineraryLikeDao.selectItineraryLike(sqlSession, like);

				int affectedRows;

				if (alreadyLiked) {

					affectedRows = itineraryLikeDao.deleteItineraryLike(sqlSession, like);

				} else {

					affectedRows = itineraryLikeDao.insertItineraryLike(sqlSession, like);

				}

				if (affectedRows != 1) {

					throw new IllegalStateException("좋아요 처리에 실패했습니다.");

				}

				int notificationRows = 0;

				if (!alreadyLiked) {
					NotificationDto notification = new NotificationDto();

					notification.setRecipientUserId(itinerary.getUserId());
					notification.setSenderUserId(loginUserId);
					notification.setNotificationType("ITINERARY_LIKE");
					notification.setTargetType("ITINERARY");
					notification.setTargetId(itineraryId);

					notificationRows = notificationDao.insertLikeNotification(sqlSession, notification);
				}

				int likeCount = itineraryLikeDao.countItineraryLikes(sqlSession, itineraryId);

				Map<String, Object> result = new HashMap<>();

				result.put("liked", !alreadyLiked);

				result.put("likeCount", likeCount);

				sqlSession.commit();

				// DB에 새 알림이 저장됐을 때만 Firebase로 갱신 신호 발송
				if (notificationRows > 0) {
					System.out.println("[Firebase] 새 알림 저장됨, 발송 시작");
					System.out.println("[Firebase] 수신자 userId: " + itinerary.getUserId());
					notificationPushService.refreshUser(itinerary.getUserId());
				}

				return result;

			} catch (Exception e) {

				sqlSession.rollback();

				throw e;

			}

		}

	}

	private void checkCommentAccess(ItineraryDto itinerary, Long loginUserId) {

		if (itinerary == null || !"ACTIVE".equals(itinerary.getStatus())) {

			throw new IllegalArgumentException("일정을 찾을 수 없습니다.");

		}

		boolean isOwner = loginUserId != null && loginUserId.equals(itinerary.getUserId());

		if (!"PUBLIC".equals(itinerary.getVisibility()) && !isOwner) {

			throw new SecurityException("접근할 수 없는 일정입니다.");

		}

	}

	// 댓글 불러오기.

	@Override

	public List<ItineraryCommentDto> getItineraryComments(Long itineraryId, Long loginUserId) throws Exception {

		if (itineraryId == null || itineraryId <= 0) {

			throw new IllegalArgumentException("올바른 일정 번호가 아닙니다.");

		}

		ItineraryDto itinerary = getItinerary(itineraryId);

		checkCommentAccess(itinerary, loginUserId);

		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {

			return itineraryCommentDao.selectItineraryComments(sqlSession, itineraryId);

		}

	}

	// 댓글작성

	@Override

	public Map<String, Object> writeItineraryComment(Long itineraryId, Long loginUserId, String content)

			throws Exception {

		if (loginUserId == null || loginUserId <= 0) {

			throw new SecurityException("로그인 후 이용할 수 있습니다.");

		}

		if (itineraryId == null || itineraryId <= 0) {

			throw new IllegalArgumentException("올바른 일정 번호가 아닙니다.");

		}

		if (content == null || content.strip().isEmpty()) {

			throw new IllegalArgumentException("댓글 내용을 입력해주세요.");

		}

		// 저장할 내용 기준으로 길이 검사

		content = content.strip();

		if (content.codePointCount(0, content.length()) > 1000) {

			throw new IllegalArgumentException("댓글은 1,000자까지 입력할 수 있습니다.");

		}

		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession(false)) {

			try {

				// 기존 일정 조회·잠금 메서드 재사용

				ItineraryDto itinerary = itineraryBookmarkDao.selectBookmarkTargetForUpdate(sqlSession, itineraryId);

				checkCommentAccess(itinerary, loginUserId);

				ItineraryCommentDto comment = new ItineraryCommentDto();

				comment.setItineraryId(itineraryId);

				comment.setUserId(loginUserId);

				comment.setContent(content);

				int insertedRows = itineraryCommentDao.insertItineraryComment(sqlSession, comment);

				if (insertedRows != 1) {

					throw new IllegalStateException("댓글 등록에 실패했습니다.");

				}

				Long commentId = comment.getCommentId();

				if (commentId == null) {
					throw new IllegalStateException("댓글 번호를 가져오지 못했습니다.");
				}

				NotificationDto notification = new NotificationDto();

				notification.setRecipientUserId(itinerary.getUserId());
				notification.setSenderUserId(loginUserId);
				notification.setNotificationType("COMMENT");
				notification.setTargetType("ITINERARY");
				notification.setTargetId(itineraryId);
				notification.setSourceCommentId(commentId);

				int notificationRows = notificationDao.insertCommentNotification(sqlSession, notification);

				// 등록 후 최신 댓글 목록과 개수 조회

				List<ItineraryCommentDto> comments = itineraryCommentDao.selectItineraryComments(sqlSession,
						itineraryId);

				int commentCount = itineraryCommentDao.countItineraryComments(sqlSession, itineraryId);

				Map<String, Object> result = new HashMap<>();

				result.put("comments", comments);

				result.put("commentCount", commentCount);

				sqlSession.commit();

				// 새 알림이 저장됐을 때 일정 작성자에게 갱신 신호 발송
				if (notificationRows > 0) {
				    notificationPushService.refreshUser(itinerary.getUserId());
				}

				
				return result;

			} catch (Exception e) {

				sqlSession.rollback();

				throw e;

			}

		}

	}

	// 댓글 삭제

	@Override

	public Map<String, Object> deleteItineraryComment(Long itineraryId, Long commentId, Long loginUserId)

			throws Exception {

		if (loginUserId == null || loginUserId <= 0) {

			throw new SecurityException("로그인 후 이용할 수 있습니다.");

		}

		if (itineraryId == null || itineraryId <= 0) {

			throw new IllegalArgumentException("올바른 일정 번호가 아닙니다.");

		}

		if (commentId == null || commentId <= 0) {

			throw new IllegalArgumentException("올바른 댓글 번호가 아닙니다.");

		}

		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession(false)) {

			try {

				ItineraryDto itinerary = itineraryBookmarkDao.selectBookmarkTargetForUpdate(sqlSession, itineraryId);

				checkCommentAccess(itinerary, loginUserId);

				ItineraryCommentDto comment = new ItineraryCommentDto();

				comment.setItineraryId(itineraryId);

				comment.setCommentId(commentId);

				comment.setUserId(loginUserId);

				int updatedRows = itineraryCommentDao.softDeleteItineraryComment(sqlSession, comment);

				if (updatedRows != 1) {

					throw new IllegalArgumentException("삭제할 수 있는 댓글이 없습니다.");

				}

				List<ItineraryCommentDto> comments = itineraryCommentDao.selectItineraryComments(sqlSession,

						itineraryId);

				int commentCount = itineraryCommentDao.countItineraryComments(sqlSession, itineraryId);

				Map<String, Object> result = new HashMap<>();

				result.put("comments", comments);

				result.put("commentCount", commentCount);

				sqlSession.commit();

				return result;

			} catch (Exception e) {

				sqlSession.rollback();

				throw e;

			}

		}

	}

	@Override
	public Map<String, Object> updateItineraryComment(Long itineraryId, Long commentId, Long loginUserId,
			String content) throws Exception {

		if (loginUserId == null || loginUserId <= 0) {
			throw new SecurityException("로그인 후 이용할 수 있습니다.");
		}

		if (itineraryId == null || itineraryId <= 0) {
			throw new IllegalArgumentException("올바른 일정 번호가 아닙니다.");
		}

		if (commentId == null || commentId <= 0) {
			throw new IllegalArgumentException("올바른 댓글 번호가 아닙니다.");
		}

		if (content == null || content.strip().isEmpty()) {
			throw new IllegalArgumentException("댓글 내용을 입력해주세요.");
		}

		content = content.strip();

		if (content.codePointCount(0, content.length()) > 1000) {
			throw new IllegalArgumentException("댓글은 1,000자까지 입력할 수 있습니다.");
		}

		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession(false)) {

			try {
				ItineraryDto itinerary = itineraryBookmarkDao.selectBookmarkTargetForUpdate(sqlSession, itineraryId);

				// 일정 상태와 공개 여부·작성자 접근 검사
				checkCommentAccess(itinerary, loginUserId);

				ItineraryCommentDto comment = new ItineraryCommentDto();

				comment.setItineraryId(itineraryId);
				comment.setCommentId(commentId);
				comment.setUserId(loginUserId);
				comment.setContent(content);

				// SQL의 user_id 조건으로 본인 댓글만 수정
				int updatedRows = itineraryCommentDao.updateItineraryComment(sqlSession, comment);

				if (updatedRows != 1) {
					throw new IllegalArgumentException("수정할 수 있는 댓글이 없습니다.");
				}

				// 기존 등록·삭제 응답과 동일한 구조
				List<ItineraryCommentDto> comments = itineraryCommentDao.selectItineraryComments(sqlSession,
						itineraryId);

				int commentCount = itineraryCommentDao.countItineraryComments(sqlSession, itineraryId);

				Map<String, Object> result = new HashMap<>();

				result.put("comments", comments);
				result.put("commentCount", commentCount);

				sqlSession.commit();

				return result;

			} catch (Exception e) {
				sqlSession.rollback();
				throw e;
			}
		}
	}

	///////////////////////////////////////////////////////////////////////////////////////////////

	/*
	 * 
	 * 신규 일정 저장
	 *
	 * 
	 * 
	 * TB_ITINERARY ↓ itineraryId TB_ITINERARY_DAY ↓ dayId TB_ITINERARY_BLOCK ↓
	 * 
	 * blockId TB_ITINERARY_BLOCK_IMAGE
	 *
	 * 
	 * 
	 * 전체 과정을 하나의 SqlSession으로 처리한다.
	 * 
	 */

	@Override

	public Long writeItinerary(ItineraryDto itineraryDto) throws Exception {

		SqlSession sqlSession = null;

		try {

			sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession(false);

			prepareCalculatedFields(itineraryDto);

			itineraryDao.insertItinerary(sqlSession, itineraryDto);

			insertSheetChildren(sqlSession, itineraryDto);

			sqlSession.commit();

			return itineraryDto.getItineraryId();

		} catch (Exception e) {

			if (sqlSession != null) {

				sqlSession.rollback();

			}

			throw e;

		} finally {

			if (sqlSession != null) {

				sqlSession.close();

			}

		}

	}

	/*
	 * 
	 * 일정 수정
	 *
	 * 
	 * 
	 * 1. 일정 기본정보 UPDATE 2. 기존 DAY 삭제 - DB의 ON DELETE CASCADE에 의해 BLOCK / IMAGE도 함께
	 * 
	 * 삭제된다. 3. 현재 화면에 있는 DAY/BLOCK/IMAGE를 다시 INSERT
	 *
	 * 
	 * 
	 * 하나라도 실패하면 전체 rollback.
	 * 
	 */

	@Override

	public void modifyItinerary(ItineraryDto itineraryDto) throws Exception {

		SqlSession sqlSession = null;

		try {

			sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession(false);

			if (itineraryDto.getItineraryId() == null) {

				throw new IllegalArgumentException("수정할 itineraryId가 없습니다.");

			}

			prepareCalculatedFields(itineraryDto);

			/*
			 * 
			 * 수정은 기존 DAY/BLOCK을 삭제한 뒤 다시 INSERT하므로,
			 * 
			 * 현재 일정 내부 PK를 source_* 값으로 들고 있으면 삭제 직후 FK가 깨진다.
			 * 
			 * 현재 일정 자체를 원본으로 가리키는 값만 미리 제거하고,
			 * 
			 * 다른 일정에서 가져온 정상적인 원본 참조는 그대로 유지한다.
			 * 
			 */

			clearSourceIdsPointingToCurrentItinerary(sqlSession, itineraryDto);

			int updateCount = itineraryDao.updateItinerary(sqlSession, itineraryDto);

			if (updateCount == 0) {

				throw new Exception("수정할 일정을 찾을 수 없거나 수정 권한이 없습니다.");

			}

			/*
			 * 
			 * DAY 삭제 시 BLOCK, IMAGE는 FK CASCADE로 같이 삭제된다.
			 * 
			 */

			itineraryDayDao.deleteItineraryDaysByItineraryId(sqlSession, itineraryDto.getItineraryId());
			sqlSession.delete("mapper.itinerary.itinerarySheet.deleteSheets", itineraryDto.getItineraryId());

			insertSheetChildren(sqlSession, itineraryDto);

			sqlSession.commit();

		} catch (Exception e) {

			if (sqlSession != null) {

				sqlSession.rollback();

			}

			throw e;

		} finally {

			if (sqlSession != null) {

				sqlSession.close();

			}

		}

	}

	/*
	 * 
	 * 수정 시 삭제될 현재 일정의 PK를 source_*가 가리키지 않도록 정리한다.
	 * 
	 * 다른 일정에서 가져온 원본 참조는 유지한다.
	 * 
	 */

	private void clearSourceIdsPointingToCurrentItinerary(SqlSession sqlSession, ItineraryDto itineraryDto)
			throws Exception {

		Long itineraryId = itineraryDto.getItineraryId();

		if (itineraryId == null) {
			return;
		}

		if (itineraryId.equals(itineraryDto.getSourceItineraryId())) {
			itineraryDto.setSourceItineraryId(null);
		}

		Set<Long> currentDayIds = new HashSet<>();
		Set<Long> currentBlockIds = new HashSet<>();

		List<ItineraryDayDto> existingDays = itineraryDayDao.selectItineraryDays(sqlSession, itineraryId);

		if (existingDays != null) {
			for (ItineraryDayDto existingDay : existingDays) {
				if (existingDay.getDayId() == null) {
					continue;
				}

				currentDayIds.add(existingDay.getDayId());

				List<ItineraryBlockDto> existingBlocks = itineraryBlockDao.selectItineraryBlocks(sqlSession,
						existingDay.getDayId());

				if (existingBlocks == null) {
					continue;
				}

				for (ItineraryBlockDto existingBlock : existingBlocks) {
					if (existingBlock.getBlockId() != null) {
						currentBlockIds.add(existingBlock.getBlockId());
					}
				}
			}
		}

		List<ItineraryDayDto> incomingDays = itineraryDto.getDays();

		if (incomingDays == null) {
			return;
		}

		for (ItineraryDayDto day : incomingDays) {
			if (day.getSourceDayId() != null && currentDayIds.contains(day.getSourceDayId())) {
				day.setSourceDayId(null);
			}

			List<ItineraryBlockDto> blocks = day.getBlocks();

			if (blocks == null) {
				continue;
			}

			for (ItineraryBlockDto block : blocks) {
				if (block.getSourceBlockId() != null && currentBlockIds.contains(block.getSourceBlockId())) {
					block.setSourceBlockId(null);
				}
			}
		}
	}

	/*
	 * 
	 * 일정 수정 화면용 전체 계층 조회
	 *
	 * 
	 * 
	 * ItineraryDto └─ DayDto └─ BlockDto └─ BlockImageDto
	 * 
	 */

	@Override

	public ItineraryDto getItinerary(Long itineraryId) throws Exception {

		SqlSession sqlSession = null;

		try {

			sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession();

			ItineraryDto itinerary = itineraryDao.selectItinerary(sqlSession, itineraryId);

			if (itinerary == null) {

				return null;

			}

			List<ItineraryDayDto> days = itineraryDayDao.selectItineraryDays(sqlSession, itineraryId);

			for (ItineraryDayDto day : days) {

				List<ItineraryBlockDto> blocks = itineraryBlockDao.selectItineraryBlocks(sqlSession, day.getDayId());

				for (ItineraryBlockDto block : blocks) {

					List<ItineraryBlockImageDto> images = itineraryBlockImageDao.selectItineraryBlockImages(sqlSession,

							block.getBlockId());

					block.setImages(images);

				}

				day.setBlocks(blocks);

			}

            itinerary.setDays(days);
            List<dto.itinerary.ItinerarySheetDto> sheets = sqlSession.selectList(
                    "mapper.itinerary.itinerarySheet.selectSheets", itineraryId);
            // 기존 단일 국가 데이터도 화면에서 시트 하나로 보여 준다.
            if (sheets == null || sheets.isEmpty()) {
                dto.itinerary.ItinerarySheetDto legacy = new dto.itinerary.ItinerarySheetDto();
                legacy.setSheetOrder(1);
                legacy.setCountry(itinerary.getCountry());
                legacy.setCity(itinerary.getCity());
                legacy.setTravelerCount(itinerary.getTravelerCount());
                legacy.setStartDate(itinerary.getStartDate());
                legacy.setEndDate(itinerary.getEndDate());
                legacy.setTotalBudget(itinerary.getTotalBudget());
                legacy.setDays(days);
                sheets = new java.util.ArrayList<>();
                sheets.add(legacy);
            } else {
                for (dto.itinerary.ItinerarySheetDto sheet : sheets) {
                    List<ItineraryDayDto> matched = new java.util.ArrayList<>();
                    for (ItineraryDayDto day : days) {
                        if (sheet.getSheetId() != null && sheet.getSheetId().equals(day.getSheetId())) {
                            matched.add(day);
                        }
                    }
                    sheet.setDays(matched);
                }
            }
            itinerary.setSheets(sheets);
            return itinerary;

		} finally {

			if (sqlSession != null) {

				sqlSession.close();

			}

		}

	}

	/*
	 * 
	 * 일정 소프트 삭제
	 * 
	 */

	@Override
	public void deleteItinerary(Long itineraryId, Long userId) throws Exception {

		if (userId == null || userId <= 0) {
			throw new SecurityException("로그인 후 이용할 수 있습니다.");
		}

		if (itineraryId == null || itineraryId <= 0) {
			throw new IllegalArgumentException("올바른 일정 번호가 아닙니다.");
		}

		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession(false)) {

			try {
				ItineraryDto itinerary = itineraryDao.selectItinerary(sqlSession, itineraryId);

				if (itinerary == null) {
					throw new IllegalArgumentException("일정을 찾을 수 없습니다.");
				}

				if (!userId.equals(itinerary.getUserId())) {
					throw new SecurityException("본인이 작성한 일정만 삭제할 수 있습니다.");
				}

				int affectedRows = itineraryDao.deleteItinerary(sqlSession, itineraryId, userId);

				if (affectedRows != 1) {
					throw new IllegalArgumentException("이미 삭제됐거나 삭제할 수 없는 일정입니다.");
				}

				sqlSession.commit();

			} catch (Exception e) {
				sqlSession.rollback();
				throw e;
			}
		}
	}

	/*
	 * 
	 * DAY → BLOCK → IMAGE 저장
	 *
	 * 
	 * 
	 * INSERT 후 MyBatis useGeneratedKeys에 의해 dayId / blockId / imageId가 DTO에 자동으로
	 * 
	 * 들어온다.
	 * 
	 */

    private void insertSheetChildren(SqlSession sqlSession, ItineraryDto itineraryDto) throws Exception {
        List<dto.itinerary.ItinerarySheetDto> sheets = itineraryDto.getSheets();
        if (sheets == null || sheets.isEmpty()) {
            dto.itinerary.ItinerarySheetDto legacy = new dto.itinerary.ItinerarySheetDto();
            legacy.setSheetOrder(1);
            legacy.setCountry(itineraryDto.getCountry());
            legacy.setCity(itineraryDto.getCity());
            legacy.setTravelerCount(itineraryDto.getTravelerCount());
            legacy.setStartDate(itineraryDto.getStartDate());
            legacy.setEndDate(itineraryDto.getEndDate());
            legacy.setTotalBudget(itineraryDto.getTotalBudget());
            legacy.setDays(itineraryDto.getDays());
            sheets = java.util.Collections.singletonList(legacy);
        }
        int globalDayOrder = 0;
        for (int i = 0; i < sheets.size(); i++) {
            dto.itinerary.ItinerarySheetDto sheet = sheets.get(i);
            sheet.setSheetId(null); // client-provided IDs must not be trusted
            sheet.setItineraryId(itineraryDto.getItineraryId());
            sheet.setSheetOrder(i + 1);
            sqlSession.insert("mapper.itinerary.itinerarySheet.insertSheet", sheet);
            if (sheet.getDays() == null) continue;
            for (ItineraryDayDto day : sheet.getDays()) {
                day.setSheetId(sheet.getSheetId());
                day.setDayOrder(++globalDayOrder); // 기존 상세 페이지의 날짜 표시 순서 보존
            }
        }
        insertChildren(sqlSession, itineraryDto);
    }

	private void insertChildren(SqlSession sqlSession, ItineraryDto itineraryDto) throws Exception {

		List<ItineraryDayDto> days = itineraryDto.getDays();

		if (days == null) {

			return;

		}

		for (ItineraryDayDto day : days) {

			day.setItineraryId(itineraryDto.getItineraryId());

			/*
			 * 
			 * 수정 시 기존 ID가 프론트에서 들어올 수 있지만, 하위 데이터는 삭제 후 재INSERT하므로 신규 PK를 받는다.
			 * 
			 */

			day.setDayId(null);

			itineraryDayDao.insertItineraryDay(sqlSession, day);

			List<ItineraryBlockDto> blocks = day.getBlocks();

			if (blocks == null) {

				continue;

			}

			for (ItineraryBlockDto block : blocks) {

				block.setDayId(day.getDayId());

				block.setBlockId(null);

				itineraryBlockDao.insertItineraryBlock(sqlSession, block);

				List<ItineraryBlockImageDto> images = block.getImages();

				if (images == null) {

					continue;

				}

				for (ItineraryBlockImageDto image : images) {

					image.setBlockId(block.getBlockId());

					image.setImageId(null);

					itineraryBlockImageDao.insertItineraryBlockImage(sqlSession, image);

				}

			}

		}

	}

	/*
	 * 
	 * 클라이언트 값을 그대로 신뢰하지 않고 서버에서 계산할 값 정리.
	 *
	 * 
	 * 
	 * totalBudget: 모든 Block.cost의 합
	 *
	 * 
	 * 
	 * thumbnailImg: 저장 전 미리보기 모달에서 사용자가 고른 값을 유지한다.
	 * 
	 */

	private void prepareCalculatedFields(ItineraryDto itineraryDto) {
        // sheet별 여행 인원과 비용은 각 시트에 귀속된다.
        if (itineraryDto.getSheets() != null && !itineraryDto.getSheets().isEmpty()) {
            dto.itinerary.ItinerarySheetDto first = itineraryDto.getSheets().get(0);
            itineraryDto.setCountry(first.getCountry());
            itineraryDto.setCity(first.getCity());
            itineraryDto.setTravelerCount(first.getTravelerCount());
            java.sql.Date earliest = null, latest = null;
            java.math.BigDecimal groupBudget = java.math.BigDecimal.ZERO;
            for (dto.itinerary.ItinerarySheetDto sheet : itineraryDto.getSheets()) {
                int count = sheet.getTravelerCount() == null || sheet.getTravelerCount() < 1 ? 1 : sheet.getTravelerCount();
                sheet.setTravelerCount(count);
                java.math.BigDecimal budget = java.math.BigDecimal.ZERO;
                if (sheet.getStartDate() != null && (earliest == null || sheet.getStartDate().before(earliest))) earliest=sheet.getStartDate();
                if (sheet.getEndDate() != null && (latest == null || sheet.getEndDate().after(latest))) latest=sheet.getEndDate();
                if (sheet.getDays() != null) for (ItineraryDayDto day : sheet.getDays()) {
                    if (day.getBlocks() == null) continue;
                    for (ItineraryBlockDto block : day.getBlocks()) {
                        if (block.getCost() != null) budget=budget.add("PER_PERSON".equals(block.getCostType())
                                ? block.getCost().multiply(java.math.BigDecimal.valueOf(count)) : block.getCost());
                    }
                }
                sheet.setTotalBudget(budget);
                groupBudget=groupBudget.add(budget);
            }
            itineraryDto.setStartDate(earliest);
            itineraryDto.setEndDate(latest);
            itineraryDto.setTotalBudget(groupBudget);
            if (itineraryDto.getVisibility() == null || itineraryDto.getVisibility().trim().isEmpty()) itineraryDto.setVisibility("PRIVATE");
            return;
        }


		int travelerCount = itineraryDto.getTravelerCount() == null || itineraryDto.getTravelerCount() < 1 ? 1
				: itineraryDto.getTravelerCount();

		itineraryDto.setTravelerCount(travelerCount);

		BigDecimal totalBudget = BigDecimal.ZERO;

		List<ItineraryDayDto> days = itineraryDto.getDays();

		if (days != null) {

			for (ItineraryDayDto day : days) {

				List<ItineraryBlockDto> blocks = day.getBlocks();

				if (blocks == null) {

					continue;

				}

				for (ItineraryBlockDto block : blocks) {

					if (block.getCost() == null) {

						continue;

					}

					BigDecimal blockCost = block.getCost();

					if ("PER_PERSON".equals(block.getCostType())) {

						blockCost = blockCost.multiply(BigDecimal.valueOf(travelerCount));

					}

					totalBudget = totalBudget.add(blockCost);

				}

			}

		}

		itineraryDto.setTotalBudget(totalBudget);

		if (itineraryDto.getVisibility() == null || itineraryDto.getVisibility().trim().isEmpty()) {

			itineraryDto.setVisibility("PRIVATE");

		}

	}

	@Override

	public boolean toggleBookmark(Long itineraryId, Long loginUserId) throws Exception {

		// 로그인 여부는 Servlet에서도 확인할 예정

		if (loginUserId == null || loginUserId <= 0) {

			throw new SecurityException("로그인 후 이용할 수 있습니다.");

		}

		if (itineraryId == null || itineraryId <= 0) {

			throw new IllegalArgumentException("올바른 일정 번호가 아닙니다.");

		}

		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession(false)) {

			try {

				// 일정 조회 및 잠금

				ItineraryDto itinerary = itineraryBookmarkDao.selectBookmarkTargetForUpdate(sqlSession, itineraryId);

				if (itinerary == null || !"ACTIVE".equals(itinerary.getStatus())) {

					throw new IllegalArgumentException("일정을 찾을 수 없습니다.");

				}

				// 본인 일정 북마크 차단

				if (loginUserId.equals(itinerary.getUserId())) {

					throw new SecurityException("본인이 작성한 일정은 북마크할 수 없습니다.");

				}

				if (!"PUBLIC".equals(itinerary.getVisibility())) {

					throw new SecurityException("공개된 일정만 북마크할 수 있습니다.");

				}

				ItineraryBookmarkDto bookmark = new ItineraryBookmarkDto();

				bookmark.setItineraryId(itineraryId);

				bookmark.setUserId(loginUserId);

				// 현재 북마크 상태 확인

				boolean alreadyBookmarked = itineraryBookmarkDao.selectItineraryBookmark(sqlSession, bookmark);

				if (alreadyBookmarked) {

					itineraryBookmarkDao.deleteItineraryBookmark(sqlSession, bookmark);

				} else {

					itineraryBookmarkDao.insertItineraryBookmark(sqlSession, bookmark);

				}

				sqlSession.commit();

				// 처리 후 상태 반환

				return !alreadyBookmarked;

			} catch (Exception e) {

				sqlSession.rollback();

				throw e;

			}

		}

	}

}
