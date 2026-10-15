package service.community;

import java.util.List;

import dao.community.MateMediaDao;
import dao.community.MateMediaDaoImpl;
import dto.community.MateMediaDto;

public class MateMediaServiceImpl implements MateMediaService {

	private MateMediaDao mateMediaDao = new MateMediaDaoImpl();

	@Override
	public int insertMateMedia(MateMediaDto mateMediaDto) {
		return mateMediaDao.insertMateMedia(mateMediaDto);
	}

	@Override
	public List<MateMediaDto> selectMateMediaList(Long mateId) {
		return mateMediaDao.selectMateMediaList(mateId);
	}

	@Override
	public MateMediaDto selectMateMedia(Long mediaId) {
		return mateMediaDao.selectMateMedia(mediaId);
	}

	@Override
	public int deleteMateMedia(long mediaId, long mateId) {
		return mateMediaDao.deleteMateMedia(mediaId, mateId);
	}

	@Override
	public int deleteMateMediaByMateId(long mateId) {
		return mateMediaDao.deleteMateMediaByMateId(mateId);
	}

	@Override
	public MateMediaDto selectFirstMateMedia(long mateId) {
		return mateMediaDao.selectFirstMateMedia(mateId);
	}

	@Override
	public int updateMateMediaSortOrder(long mediaId, long mateId, int sortOrder) {
		return mateMediaDao.updateMateMediaSortOrder(mediaId, mateId, sortOrder);
	}
}