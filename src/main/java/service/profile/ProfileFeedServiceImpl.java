package service.profile;

import java.util.List;

import dao.profile.ProfileFeedDao;
import dao.profile.ProfileFeedDaoImpl;
import dto.profile.ProfileFeedDto;

public class ProfileFeedServiceImpl implements ProfileFeedService {

	private final ProfileFeedDao profileFeedDao;

	public ProfileFeedServiceImpl() {

		profileFeedDao = new ProfileFeedDaoImpl();
	}

	@Override
	public List<ProfileFeedDto> getMyItineraries(long userId) throws Exception {

		return profileFeedDao.selectMyItineraries(userId);
	}

	@Override
	public List<ProfileFeedDto> getBookmarkedItineraries(long userId) throws Exception {

		return profileFeedDao.selectBookmarkedItineraries(userId);
	}

	@Override
	public List<ProfileFeedDto> getLikedItineraries(long userId) throws Exception {

		return profileFeedDao.selectLikedItineraries(userId);
	}

	@Override
	public List<ProfileFeedDto> getPublicItineraries(long userId) throws Exception {

		return profileFeedDao.selectPublicItineraries(userId);
	}

	@Override
	public List<ProfileFeedDto> getPublicLikedItineraries(long userId) throws Exception {

		return profileFeedDao.selectPublicLikedItineraries(userId);
	}

	@Override
	public List<ProfileFeedDto> getPublicBookmarkedItineraries(long userId) throws Exception {

		return profileFeedDao.selectPublicBookmarkedItineraries(userId);
	}

	@Override
	public List<ProfileFeedDto> getMyItinerariesPage(long userId, int offset, int limit) throws Exception {

		return profileFeedDao.selectMyItinerariesPage(userId, offset, limit);
	}

	@Override
	public List<ProfileFeedDto> getBookmarkedItinerariesPage(long userId, int offset, int limit) throws Exception {

		return profileFeedDao.selectBookmarkedItinerariesPage(userId, offset, limit);
	}

	@Override
	public List<ProfileFeedDto> getLikedItinerariesPage(long userId, int offset, int limit) throws Exception {

		return profileFeedDao.selectLikedItinerariesPage(userId, offset, limit);
	}

	@Override
	public List<ProfileFeedDto> getPublicItinerariesPage(long userId, int offset, int limit) throws Exception {

		return profileFeedDao.selectPublicItinerariesPage(userId, offset, limit);
	}

	@Override
	public List<ProfileFeedDto> getPublicLikedItinerariesPage(long userId, int offset, int limit) throws Exception {

		return profileFeedDao.selectPublicLikedItinerariesPage(userId, offset, limit);
	}

	@Override
	public List<ProfileFeedDto> getPublicBookmarkedItinerariesPage(long userId, int offset, int limit)
			throws Exception {

		return profileFeedDao.selectPublicBookmarkedItinerariesPage(userId, offset, limit);
	}

	@Override
	public int countMyItineraries(long userId) throws Exception {

		return profileFeedDao.countMyItineraries(userId);
	}

	@Override
	public int countPublicItineraries(long userId) throws Exception {

		return profileFeedDao.countPublicItineraries(userId);
	}

	@Override
	public int getReceivedLikeCount(long userId) throws Exception {

		return profileFeedDao.selectReceivedLikeCount(userId);
	}

	@Override
	public int getReceivedBookmarkCount(long userId) throws Exception {

		return profileFeedDao.selectReceivedBookmarkCount(userId);
	}

	@Override
	public int getPublicReceivedLikeCount(long userId) throws Exception {

		return profileFeedDao.selectPublicReceivedLikeCount(userId);
	}

	@Override
	public int getPublicReceivedBookmarkCount(long userId) throws Exception {

		return profileFeedDao.selectPublicReceivedBookmarkCount(userId);
	}

	@Override
	public void deleteItinerary(long itineraryId, long userId) throws Exception {

		profileFeedDao.deleteItinerary(itineraryId, userId);
	}
}
