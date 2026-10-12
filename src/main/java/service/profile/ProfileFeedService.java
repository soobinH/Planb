package service.profile;

import java.util.List;

import dto.profile.ProfileFeedDto;

public interface ProfileFeedService {

	/* 기존 전체 조회 */
	List<ProfileFeedDto> getMyItineraries(long userId) throws Exception;

	List<ProfileFeedDto> getBookmarkedItineraries(long userId) throws Exception;

	List<ProfileFeedDto> getLikedItineraries(long userId) throws Exception;

	List<ProfileFeedDto> getPublicItineraries(long userId) throws Exception;

	List<ProfileFeedDto> getPublicLikedItineraries(long userId) throws Exception;

	List<ProfileFeedDto> getPublicBookmarkedItineraries(long userId) throws Exception;

	/* 무한 스크롤 */
	List<ProfileFeedDto> getMyItinerariesPage(long userId, int offset, int limit) throws Exception;

	List<ProfileFeedDto> getBookmarkedItinerariesPage(long userId, int offset, int limit) throws Exception;

	List<ProfileFeedDto> getLikedItinerariesPage(long userId, int offset, int limit) throws Exception;

	List<ProfileFeedDto> getPublicItinerariesPage(long userId, int offset, int limit) throws Exception;

	List<ProfileFeedDto> getPublicLikedItinerariesPage(long userId, int offset, int limit) throws Exception;

	List<ProfileFeedDto> getPublicBookmarkedItinerariesPage(long userId, int offset, int limit) throws Exception;

	/* 통계 */
	int countMyItineraries(long userId) throws Exception;

	int countPublicItineraries(long userId) throws Exception;

	int getReceivedLikeCount(long userId) throws Exception;

	int getReceivedBookmarkCount(long userId) throws Exception;

	int getPublicReceivedLikeCount(long userId) throws Exception;

	int getPublicReceivedBookmarkCount(long userId) throws Exception;

	/* 일정 삭제 */
	void deleteItinerary(long itineraryId, long userId) throws Exception;
}
