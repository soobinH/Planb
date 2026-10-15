package service.community;

import java.util.List;

import dao.community.TipMediaDao;
import dao.community.TipMediaDaoImpl;
import dto.community.TipMediaDto;

public class TipMediaServiceImpl implements TipMediaService {

    private TipMediaDao tipMediaDao;

    public TipMediaServiceImpl() {
        tipMediaDao = new TipMediaDaoImpl();
    }

    @Override
    public int insertTipMedia(TipMediaDto tipMediaDto) {
        return tipMediaDao.insertTipMedia(tipMediaDto);
    }
    
    @Override
    public List<TipMediaDto> selectTipMediaList(long tipId) {
        return tipMediaDao.selectTipMediaList(tipId);
    }
    
    @Override
    public TipMediaDto selectTipMedia(Long mediaId) {
    	return tipMediaDao.selectTipMedia(mediaId);
    }
    
    @Override
    public int deleteTipMediaByTipId(long tipId) {
        return tipMediaDao.deleteTipMediaByTipId(tipId);
    }
    
    @Override
    public int deleteTipMedia(long mediaId, long tipId) {
        return tipMediaDao.deleteTipMedia(mediaId, tipId);
    }
    
    @Override
    public TipMediaDto selectFirstTipMedia(long tipId) {
        return tipMediaDao.selectFirstTipMedia(tipId);
    }

    @Override
    public int updateTipMediaSortOrder(long mediaId, long tipId, int sortOrder) {
        return tipMediaDao.updateTipMediaSortOrder(mediaId, tipId, sortOrder);
    }
}