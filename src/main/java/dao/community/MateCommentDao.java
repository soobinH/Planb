package dao.community;

import java.util.List;

import org.apache.ibatis.session.SqlSession;

import dto.community.MateCommentDto;

public interface MateCommentDao {

	int insertMateComment(MateCommentDto mateCommentDto);

	MateCommentDto selectMateComment(Long commentId);

	List<MateCommentDto> selectMateCommentList(Long mateId);

	int countMateComment(Long mateId);

	int updateMateComment(MateCommentDto mateCommentDto);

	int deleteMateComment(MateCommentDto mateCommentDto);
	
	int insertMateComment(SqlSession sqlSession, MateCommentDto mateCommentDto);
}