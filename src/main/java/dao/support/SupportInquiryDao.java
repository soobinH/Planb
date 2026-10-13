package dao.support;

import org.apache.ibatis.session.SqlSession;
import java.util.List;
import java.util.Map;

import dto.support.SupportInquiryDto;

public interface SupportInquiryDao {
	int insertInquiry(SqlSession sqlSession, SupportInquiryDto inquiry) throws Exception;
    List<SupportInquiryDto> selectAll(SqlSession session, Map<String,Object> params);
    SupportInquiryDto selectOne(SqlSession session, long inquiryId);
    int answerInquiry(SqlSession session, SupportInquiryDto inquiry);
    List<SupportInquiryDto> selectByUser(SqlSession session, long userId);
    SupportInquiryDto selectOneByUser(SqlSession session, Map<String,Object> params);
}
