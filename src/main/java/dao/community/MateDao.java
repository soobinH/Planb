package dao.community;

import java.util.List;

import org.apache.ibatis.session.SqlSession;

import dto.community.MateDto;

public interface MateDao {

	int insertMate(MateDto mateDto);

	MateDto selectMate(Long mateId);

	int updateMate(MateDto mateDto);
	
	int updateMateImage(MateDto mateDto);

	int deleteMate(MateDto mateDto);

	// 여행메이트 전체 조회
	List<MateDto> selectMateList();

	// 검색 + 국가 + 정렬 + 페이지 처리
	List<MateDto> selectMateListByFilter(List<String> countryKeywords, String keyword, String sort, int pageSize, int offset);

	// 검색 + 국가 조건에 맞는 전체 게시글 수
	int countMateListByFilter(List<String> countryKeywords, String keyword);
	
	List<MateDto> selectMateWriteList(Long userId, int pageSize, int offset);

	int countMateWriteList(Long userId);
	
	int updateMateViewCount(Long mateId);
	
	int updateRecruitStatus(MateDto mateDto);
	
	// 같은 세션에 담기위해.
	MateDto selectMateForUpdate(SqlSession sqlSession, Long mateId);
}