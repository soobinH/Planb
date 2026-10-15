package service.community;

import java.util.List;

import dto.community.TipMediaDto;

public interface TipMediaService {

    // 여행꿀팁 이미지 등록
    int insertTipMedia(TipMediaDto tipMediaDto);
    
    List<TipMediaDto> selectTipMediaList(long tipId);
    
    // 이미지 단건 조회
 	TipMediaDto selectTipMedia(Long mediaId);
    
    int deleteTipMediaByTipId(long tipId);
    
    int deleteTipMedia(long mediaId, long tipId);
    
    TipMediaDto selectFirstTipMedia(long tipId);

    // 사진 순서 변경
    int updateTipMediaSortOrder(long mediaId, long tipId, int sortOrder);
}