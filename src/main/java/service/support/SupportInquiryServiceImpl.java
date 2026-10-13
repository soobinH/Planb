package service.support;

import java.util.Arrays;
import java.util.Map;
import java.util.HashMap;
import java.util.List;
import java.util.HashSet;
import java.util.Set;

import org.apache.ibatis.session.SqlSession;

import config.MybatisSqlSessionFactory;
import dao.support.SupportInquiryDao;
import dao.support.SupportInquiryDaoImpl;
import dto.support.SupportInquiryDto;

public class SupportInquiryServiceImpl implements SupportInquiryService {

	private final SupportInquiryDao inquiryDao = new SupportInquiryDaoImpl();
	private static final Set<String> ALLOWED_CATEGORIES = new HashSet<>(
			Arrays.asList("ACCOUNT", "ITINERARY", "COMMUNITY", "ERROR", "ETC"));

	@Override
	public long submitInquiry(long userId, String category, String email, String title, String content)
			throws Exception {

		/*
		 * ===================================== 회원 검사
		 * ======================================
		 */

		if (userId <= 0) {

			throw new SecurityException("로그인이 필요합니다.");
		}

		/*
		 * ===================================== 문의 유형
		 * ======================================
		 */

		if (category == null) {

			throw new IllegalArgumentException("문의 유형을 선택해주세요.");
		}

		category = category.trim().toUpperCase();

		if (!ALLOWED_CATEGORIES.contains(category)) {

			throw new IllegalArgumentException("올바른 문의 유형이 아닙니다.");
		}

		/*
		 * ===================================== 이메일
		 * ======================================
		 */

		email = email == null ? "" : email.trim();

		if (email.isEmpty()) {

			throw new IllegalArgumentException("답변 받을 이메일을 입력해주세요.");
		}

		if (email.length() > 100) {

			throw new IllegalArgumentException("이메일은 100자 이하로 입력해주세요.");
		}

		if (!email.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")) {

			throw new IllegalArgumentException("올바른 이메일 형식이 아닙니다.");
		}

		/*
		 * ===================================== 제목
		 * ======================================
		 */

		title = title == null ? "" : title.trim();

		if (title.isEmpty()) {

			throw new IllegalArgumentException("문의 제목을 입력해주세요.");
		}

		if (title.length() > 60) {

			throw new IllegalArgumentException("문의 제목은 최대 60자까지 입력할 수 있습니다.");
		}

		/*
		 * ===================================== 내용
		 * ======================================
		 */

		content = content == null ? "" : content.trim();

		if (content.isEmpty()) {

			throw new IllegalArgumentException("문의 내용을 입력해주세요.");
		}

		if (content.length() > 3000) {

			throw new IllegalArgumentException("문의 내용은 최대 3000자까지 입력할 수 있습니다.");
		}

		/*
		 * ===================================== DTO
		 * ======================================
		 */

		SupportInquiryDto inquiry = new SupportInquiryDto();

		inquiry.setUserId(userId);

		inquiry.setCategory(category);

		inquiry.setContactEmail(email);

		inquiry.setTitle(title);

		inquiry.setContent(content);

		inquiry.setStatus("RECEIVED");

		/*
		 * ===================================== DB INSERT
		 * ======================================
		 */

		try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession(false)) {

			try {

				int result = inquiryDao.insertInquiry(sqlSession, inquiry);

				if (result != 1 || inquiry.getInquiryId() <= 0) {

					throw new IllegalStateException("문의 접수에 실패했습니다.");
				}

				sqlSession.commit();

				return inquiry.getInquiryId();

			} catch (Exception e) {

				sqlSession.rollback();

				throw e;
			}
		}
	}
    @Override
    public List<SupportInquiryDto> getInquiries(String status) throws Exception {
        if (status != null && !status.isEmpty()
                && !"RECEIVED".equals(status) && !"ANSWERING".equals(status) && !"DONE".equals(status)) {
            throw new IllegalArgumentException("잘못된 상태값입니다.");
        }
        Map<String,Object> params = new HashMap<>();
        params.put("status", status);
        try (SqlSession session = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {
            return inquiryDao.selectAll(session, params);
        }
    }

    @Override
    public SupportInquiryDto getInquiry(long inquiryId) throws Exception {
        if (inquiryId <= 0) throw new IllegalArgumentException("잘못된 문의 번호입니다.");
        try (SqlSession session = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {
            return inquiryDao.selectOne(session, inquiryId);
        }
    }

    @Override
    public boolean answerInquiry(long inquiryId, long adminUserId, String answer) throws Exception {
        if (inquiryId <= 0 || adminUserId <= 0) throw new IllegalArgumentException("잘못된 요청입니다.");
        answer = answer == null ? "" : answer.trim();
        if (answer.isEmpty() || answer.length() > 3000) {
            throw new IllegalArgumentException("답변은 1~3000자로 입력해주세요.");
        }
        SupportInquiryDto data = new SupportInquiryDto();
        data.setInquiryId(inquiryId);
        data.setAnsweredByUserId(adminUserId);
        data.setAnswer(answer);
        try (SqlSession session = MybatisSqlSessionFactory.getSqlSessionFactory().openSession(false)) {
            try {
                int changed = inquiryDao.answerInquiry(session, data);
                if (changed == 1) session.commit();
                else session.rollback();
                return changed == 1;
            } catch (Exception e) {
                session.rollback();
                throw e;
            }
        }
    }
    @Override
    public List<SupportInquiryDto> getMyInquiries(long userId) throws Exception {
        if (userId <= 0) throw new SecurityException("로그인이 필요합니다.");
        try (SqlSession session = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {
            return inquiryDao.selectByUser(session, userId);
        }
    }

    @Override
    public SupportInquiryDto getMyInquiry(long userId, long inquiryId) throws Exception {
        if (userId <= 0) throw new SecurityException("로그인이 필요합니다.");
        if (inquiryId <= 0) throw new IllegalArgumentException("잘못된 문의 번호입니다.");
        Map<String,Object> params = new HashMap<>();
        params.put("userId", userId);
        params.put("inquiryId", inquiryId);
        try (SqlSession session = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {
            return inquiryDao.selectOneByUser(session, params);
        }
    }
}
