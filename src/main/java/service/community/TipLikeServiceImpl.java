package service.community;

import org.apache.ibatis.session.SqlSession;

import config.MybatisSqlSessionFactory;
import dao.community.TipDao;
import dao.community.TipDaoImpl;
import dao.community.TipLikeDao;
import dao.community.TipLikeDaoImpl;
import dao.notification.NotificationDao;
import dao.notification.NotificationDaoImpl;
import dto.community.TipDto;
import dto.community.TipLikeDto;
import dto.notification.NotificationDto;

public class TipLikeServiceImpl implements TipLikeService {

	private TipLikeDao tipLikeDao = new TipLikeDaoImpl();
	private TipDao tipDao = new TipDaoImpl();
	private NotificationDao notificationDao = new NotificationDaoImpl();

	// 좋아요 등록
	@Override
	public int insertTipLike(TipLikeDto tipLikeDto) {
		if (tipLikeDto == null) {
			throw new IllegalArgumentException("좋아요 정보가 없습니다.");
		}

		Long tipId = tipLikeDto.getTipId();
		Long userId = tipLikeDto.getUserId();

		if (userId == null || userId <= 0) {
			throw new SecurityException("로그인이 필요합니다.");
		}

		if (tipId == null || tipId <= 0) {
			throw new IllegalArgumentException("올바른 꿀팁 번호가 아닙니다.");
		}

		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession(false)) {

			try {
				TipDto tip = tipDao.selectTipForUpdate(sqlSession, tipId);

				if (tip == null || !"ACTIVE".equals(tip.getStatus())) {
					throw new IllegalArgumentException("게시글을 찾을 수 없습니다.");
				}

				boolean isOwner = userId.equals(tip.getUserId());

				if (!"PUBLIC".equals(tip.getVisibility()) && !isOwner) {
					throw new SecurityException("접근할 수 없는 게시글입니다.");
				}

				TipLikeDto existing = tipLikeDao.selectTipLike(sqlSession, tipLikeDto);

				if (existing != null) {
					sqlSession.commit();
					return 0;
				}

				int insertedRows = tipLikeDao.insertTipLike(sqlSession, tipLikeDto);

				if (insertedRows != 1) {
					throw new IllegalStateException("좋아요 등록에 실패했습니다.");
				}

				NotificationDto notification = new NotificationDto();

				notification.setRecipientUserId(tip.getUserId());
				notification.setSenderUserId(userId);
				notification.setNotificationType("TIP_LIKE");
				notification.setTargetType("TIP");
				notification.setTargetId(tipId);

				notificationDao.insertLikeNotification(sqlSession, notification);

				sqlSession.commit();
				return insertedRows;

			} catch (Exception e) {
				sqlSession.rollback();

				if (e instanceof RuntimeException) {
					throw (RuntimeException) e;
				}

				throw new IllegalStateException("좋아요 등록 중 오류가 발생했습니다.", e);
			}
		}
	}

	// 좋아요 여부 조회
	@Override
	public TipLikeDto selectTipLike(TipLikeDto tipLikeDto) {
		return tipLikeDao.selectTipLike(tipLikeDto);
	}

	// 좋아요 취소
	@Override
	public int deleteTipLike(TipLikeDto tipLikeDto) {
		if (tipLikeDto == null) {
			throw new IllegalArgumentException("좋아요 정보가 없습니다.");
		}

		Long tipId = tipLikeDto.getTipId();
		Long userId = tipLikeDto.getUserId();

		if (userId == null || userId <= 0) {
			throw new SecurityException("로그인이 필요합니다.");
		}

		if (tipId == null || tipId <= 0) {
			throw new IllegalArgumentException("올바른 꿀팁 번호가 아닙니다.");
		}

		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession(false)) {

			try {
				TipDto tip = tipDao.selectTipForUpdate(sqlSession, tipId);

				if (tip == null) {
					sqlSession.commit();
					return 0;
				}

				int deletedRows = tipLikeDao.deleteTipLike(sqlSession, tipLikeDto);

				sqlSession.commit();
				return deletedRows;

			} catch (RuntimeException e) {
				sqlSession.rollback();
				throw e;
			}
		}
	}

	@Override
	public int selectTipLikeCount(long tipId) {
		return tipLikeDao.selectTipLikeCount(tipId);
	}
}