package dao.community;

import java.util.List;

import dto.community.TipMediaDto;

public interface TipMediaDao {

	int insertTipMedia(TipMediaDto tipMediaDto);

	TipMediaDto selectTipMedia(Long mediaId);

	int updateTipMedia(TipMediaDto tipMediaDto);

	int deleteTipMedia(long mediaId, long tipId);
	
	List<TipMediaDto> selectTipMediaList(long tipId);
	
	int deleteTipMediaByTipId(long tipId);
	
	TipMediaDto selectFirstTipMedia(long tipId);

	// 사진 순서 변경
	int updateTipMediaSortOrder(long mediaId, long tipId, int sortOrder);
}