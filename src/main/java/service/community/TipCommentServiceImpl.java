package service.community;

import java.util.List;

import org.apache.ibatis.session.SqlSession;

import config.MybatisSqlSessionFactory;
import dao.community.TipCommentDao;
import dao.community.TipCommentDaoImpl;
import dao.community.TipDao;
import dao.community.TipDaoImpl;
import dao.notification.NotificationDao;
import dao.notification.NotificationDaoImpl;
import dto.community.TipCommentDto;
import dto.community.TipDto;
import dto.notification.NotificationDto;

public class TipCommentServiceImpl implements TipCommentService {

	private TipCommentDao tipCommentDao = new TipCommentDaoImpl();
	private TipDao tipDao = new TipDaoImpl();
	private NotificationDao notificationDao = new NotificationDaoImpl();

	// 댓글 작성
	@Override
	public int insertTipComment(TipCommentDto tipCommentDto) {
		if (tipCommentDto == null) {
			throw new IllegalArgumentException("댓글 정보가 없습니다.");
		}

		Long tipId = tipCommentDto.getTipId();
		Long userId = tipCommentDto.getUserId();
		String content = tipCommentDto.getContent();

		if (userId == null || userId <= 0) {
			throw new SecurityException("로그인이 필요합니다.");
		}

		if (tipId == null || tipId <= 0) {
			throw new IllegalArgumentException("올바른 꿀팁 번호가 아닙니다.");
		}

		if (content == null || content.strip().isEmpty()) {
			throw new IllegalArgumentException("댓글 내용을 입력해주세요.");
		}

		content = content.strip();

		if (content.codePointCount(0, content.length()) > 1000) {
			throw new IllegalArgumentException("댓글은 1,000자까지 입력할 수 있습니다.");
		}

		tipCommentDto.setContent(content);

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

				int insertedRows = tipCommentDao.insertTipComment(sqlSession, tipCommentDto);

				if (insertedRows != 1) {
					throw new IllegalStateException("댓글 등록에 실패했습니다.");
				}

				Long commentId = tipCommentDto.getCommentId();

				if (commentId == null || commentId <= 0) {
					throw new IllegalStateException("댓글 번호를 가져오지 못했습니다.");
				}

				NotificationDto notification = new NotificationDto();

				notification.setRecipientUserId(tip.getUserId());
				notification.setSenderUserId(userId);
				notification.setNotificationType("COMMENT");
				notification.setTargetType("TIP");
				notification.setTargetId(tipId);
				notification.setSourceCommentId(commentId);

				notificationDao.insertCommentNotification(sqlSession, notification);

				sqlSession.commit();
				return insertedRows;

			} catch (Exception e) {
				sqlSession.rollback();

				if (e instanceof RuntimeException) {
					throw (RuntimeException) e;
				}

				throw new IllegalStateException("댓글 등록 중 오류가 발생했습니다.", e);
			}
		}
	}

	// 댓글 1개 조회
	@Override
	public TipCommentDto selectTipComment(Long commentId) {
		return tipCommentDao.selectTipComment(commentId);
	}

	// 게시글 댓글 목록 조회
	@Override
	public List<TipCommentDto> selectTipCommentList(long tipId) {
		return tipCommentDao.selectTipCommentList(tipId);
	}

	// 본인 댓글 수정
	@Override
	public int updateTipComment(TipCommentDto tipCommentDto) {
		return tipCommentDao.updateTipComment(tipCommentDto);
	}

	// 본인 댓글 삭제
	@Override
	public int deleteTipComment(TipCommentDto tipCommentDto) {
		return tipCommentDao.deleteTipComment(tipCommentDto);
	}
}