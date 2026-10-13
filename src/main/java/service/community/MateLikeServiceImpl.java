package service.community;

import org.apache.ibatis.session.SqlSession;

import config.MybatisSqlSessionFactory;
import dao.community.MateDao;
import dao.community.MateDaoImpl;
import dao.community.MateLikeDao;
import dao.community.MateLikeDaoImpl;
import dao.notification.NotificationDao;
import dao.notification.NotificationDaoImpl;
import dto.community.MateDto;
import dto.community.MateLikeDto;
import dto.notification.NotificationDto;

public class MateLikeServiceImpl implements MateLikeService {

	private MateLikeDao mateLikeDao = new MateLikeDaoImpl();
	private MateDao mateDao = new MateDaoImpl();
	private NotificationDao notificationDao = new NotificationDaoImpl();

	@Override
	public boolean toggleMateLike(Long mateId, Long userId) {
	    if (userId == null || userId <= 0) {
	        throw new SecurityException("로그인이 필요합니다.");
	    }

	    if (mateId == null || mateId <= 0) {
	        throw new IllegalArgumentException("올바른 메이트 번호가 아닙니다.");
	    }

	    try (SqlSession sqlSession =
	            MybatisSqlSessionFactory.getSqlSessionFactory()
	                    .openSession(false)) {

	        try {
	            MateDto mate =
	                    mateDao.selectMateForUpdate(sqlSession, mateId);

	            if (mate == null || !"ACTIVE".equals(mate.getStatus())) {
	                throw new IllegalArgumentException("게시글을 찾을 수 없습니다.");
	            }

	            boolean isOwner = userId.equals(mate.getUserId());

	            if (!"PUBLIC".equals(mate.getVisibility()) && !isOwner) {
	                throw new SecurityException("접근할 수 없는 게시글입니다.");
	            }

	            MateLikeDto existing =
	                    mateLikeDao.selectMateLike(
	                            sqlSession, mateId, userId);

	            boolean alreadyLiked = existing != null;
	            int affectedRows;

	            if (alreadyLiked) {
	                affectedRows = mateLikeDao.deleteMateLike(
	                        sqlSession, mateId, userId);

	            } else {
	                MateLikeDto like = new MateLikeDto();

	                like.setMateId(mateId);
	                like.setUserId(userId);

	                affectedRows =
	                        mateLikeDao.insertMateLike(sqlSession, like);
	            }

	            if (affectedRows != 1) {
	                throw new IllegalStateException("좋아요 처리에 실패했습니다.");
	            }

	            // 좋아요가 추가된 경우에만 알림 생성
	            if (!alreadyLiked) {
	                NotificationDto notification = new NotificationDto();

	                notification.setRecipientUserId(mate.getUserId());
	                notification.setSenderUserId(userId);
	                notification.setNotificationType("MATE_LIKE");
	                notification.setTargetType("MATE");
	                notification.setTargetId(mateId);

	                notificationDao.insertLikeNotification(
	                        sqlSession, notification);
	            }

	            sqlSession.commit();

	            // 처리 후 좋아요 상태
	            return !alreadyLiked;

	        } catch (Exception e) {
	            sqlSession.rollback();

	            if (e instanceof RuntimeException) {
	                throw (RuntimeException) e;
	            }

	            throw new IllegalStateException(
	                    "좋아요 처리 중 오류가 발생했습니다.", e);
	        }
	    }
	}

	@Override
	public boolean isLiked(Long mateId, Long userId) {
		return mateLikeDao.selectMateLike(mateId, userId) != null;
	}

	@Override
	public int countMateLike(Long mateId) {
		return mateLikeDao.countMateLike(mateId);
	}
}