package service.community;

import java.util.List;

import org.apache.ibatis.session.SqlSession;

import config.MybatisSqlSessionFactory;
import dao.community.MateCommentDao;
import dao.community.MateCommentDaoImpl;
import dao.community.MateDao;
import dao.community.MateDaoImpl;
import dao.notification.NotificationDao;
import dao.notification.NotificationDaoImpl;
import dto.community.MateCommentDto;
import dto.community.MateDto;
import dto.notification.NotificationDto;

public class MateCommentServiceImpl implements MateCommentService {

	private MateCommentDao mateCommentDao = new MateCommentDaoImpl();
	private MateDao mateDao = new MateDaoImpl();
	private NotificationDao notificationDao = new NotificationDaoImpl();

	@Override
	public int insertMateComment(MateCommentDto mateCommentDto) {
		if (mateCommentDto == null) {
			throw new IllegalArgumentException("댓글 정보가 없습니다.");
		}

		Long mateId = mateCommentDto.getMateId();
		Long userId = mateCommentDto.getUserId();
		String content = mateCommentDto.getContent();

		if (userId == null || userId <= 0) {
			throw new SecurityException("로그인이 필요합니다.");
		}

		if (mateId == null || mateId <= 0) {
			throw new IllegalArgumentException("올바른 메이트 번호가 아닙니다.");
		}

		if (content == null || content.strip().isEmpty()) {
			throw new IllegalArgumentException("댓글 내용을 입력해주세요.");
		}

		content = content.strip();

		if (content.codePointCount(0, content.length()) > 1000) {
			throw new IllegalArgumentException("댓글은 1,000자까지 입력할 수 있습니다.");
		}

		mateCommentDto.setContent(content);

		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession(false)) {

			try {
				MateDto mate = mateDao.selectMateForUpdate(sqlSession, mateId);

				if (mate == null || !"ACTIVE".equals(mate.getStatus())) {
					throw new IllegalArgumentException("게시글을 찾을 수 없습니다.");
				}

				boolean isOwner = userId.equals(mate.getUserId());

				if (!"PUBLIC".equals(mate.getVisibility()) && !isOwner) {
					throw new SecurityException("접근할 수 없는 게시글입니다.");
				}

				int insertedRows = mateCommentDao.insertMateComment(sqlSession, mateCommentDto);

				if (insertedRows != 1) {
					throw new IllegalStateException("댓글 등록에 실패했습니다.");
				}

				Long commentId = mateCommentDto.getCommentId();

				if (commentId == null || commentId <= 0) {
					throw new IllegalStateException("댓글 번호를 가져오지 못했습니다.");
				}

				NotificationDto notification = new NotificationDto();

				notification.setRecipientUserId(mate.getUserId());
				notification.setSenderUserId(userId);
				notification.setNotificationType("COMMENT");
				notification.setTargetType("MATE");
				notification.setTargetId(mateId);
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

	@Override
	public MateCommentDto selectMateComment(Long commentId) {
		return mateCommentDao.selectMateComment(commentId);
	}

	@Override
	public List<MateCommentDto> selectMateCommentList(Long mateId) {
		return mateCommentDao.selectMateCommentList(mateId);
	}

	@Override
	public int countMateComment(Long mateId) {
		return mateCommentDao.countMateComment(mateId);
	}

	@Override
	public int updateMateComment(MateCommentDto mateCommentDto) {
		return mateCommentDao.updateMateComment(mateCommentDto);
	}

	@Override
	public int deleteMateComment(MateCommentDto mateCommentDto) {
		return mateCommentDao.deleteMateComment(mateCommentDto);
	}
}