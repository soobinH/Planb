package dao.community;

import java.util.List;

import dto.community.MateMediaDto;

public interface MateMediaDao {

	int insertMateMedia(MateMediaDto mateMediaDto);

	// 이미지 단건 조회
	MateMediaDto selectMateMedia(Long mediaId);

	int updateMateMedia(MateMediaDto mateMediaDto);

	// 이미지 1개 삭제
	int deleteMateMedia(long mediaId, long mateId);

	// 게시글의 이미지 전체 삭제
	int deleteMateMediaByMateId(long mateId);

	// 게시글 이미지 목록 조회
	List<MateMediaDto> selectMateMediaList(Long mateId);

	// 첫 번째 이미지 조회
	MateMediaDto selectFirstMateMedia(long mateId);

	// 사진 순서 변경
	int updateMateMediaSortOrder(long mediaId, long mateId, int sortOrder);
}