package dao.support;

import org.apache.ibatis.session.SqlSession;
import java.util.List;
import java.util.Map;

import dto.support.SupportInquiryDto;

public class SupportInquiryDaoImpl implements SupportInquiryDao {

	@Override
	public int insertInquiry(SqlSession sqlSession, SupportInquiryDto inquiry) throws Exception {
		return sqlSession.insert("mapper.support.inquiry.insertInquiry", inquiry);
	}

    @Override
    public List<SupportInquiryDto> selectAll(SqlSession session, Map<String,Object> params) {
        return session.selectList("mapper.support.inquiry.selectAll", params);
    }

    @Override
    public SupportInquiryDto selectOne(SqlSession session, long inquiryId) {
        return session.selectOne("mapper.support.inquiry.selectOne", inquiryId);
    }

    @Override
    public int answerInquiry(SqlSession session, SupportInquiryDto inquiry) {
        return session.update("mapper.support.inquiry.answerInquiry", inquiry);
    }
    @Override
    public List<SupportInquiryDto> selectByUser(SqlSession session, long userId) {
        return session.selectList("mapper.support.inquiry.selectByUser", userId);
    }

    @Override
    public SupportInquiryDto selectOneByUser(SqlSession session, Map<String,Object> params) {
        return session.selectOne("mapper.support.inquiry.selectOneByUser", params);
    }
}
