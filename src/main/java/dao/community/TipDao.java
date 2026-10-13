package dao.community;

import java.util.List;

import org.apache.ibatis.session.SqlSession;

import dto.community.TipDto;

public interface TipDao {

	// 여행꿀팁 작성
	int insertTip(TipDto tipDto);

	// 여행꿀팁 상세조회
	TipDto selectTip(Long tipId);
	
	TipDto selectTipDetail(long tipId);

	// 여행꿀팁 수정
	int updateTip(TipDto tipDto);

	// 여행꿀팁 삭제
	int deleteTip(TipDto tipDto);

	// 여행꿀팁 전체조회
	List<TipDto> selectTipList();

	// 해시태그 검색
	List<TipDto> searchTipByHashtag(String keyword);
	
	List<TipDto> selectTipListByFilter(List<String> countryKeywords, String keyword, String sort, int pageSize, int offset);
	
	int countTipListByFilter(List<String> countryKeywords, String keyword);
	
	List<TipDto> selectMyTipList(long userId);
	
	// 내가 작성한 글 페이지 조회
	List<TipDto> selectMyTipList(long userId, int offset, int pageSize);
	
	// 내가 작성한 여행꿀팁 전체 개수
	int countMyTipList(long userId);

	int updateTipThumbnail(TipDto tipDto);
	
	int updateTipViewCount(Long tipId);
	
	// 알림 관련 추가 
	TipDto selectTipForUpdate(SqlSession sqlSession, Long tipId);
}