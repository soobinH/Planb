package dao.profile;

import java.util.List;

import dto.profile.ProfileFeedDto;

public interface ProfileFeedDao {

	/* 기존 전체 조회 */
	List<ProfileFeedDto> selectMyItineraries(long userId) throws Exception;

	List<ProfileFeedDto> selectBookmarkedItineraries(long userId) throws Exception;

	List<ProfileFeedDto> selectLikedItineraries(long userId) throws Exception;

	List<ProfileFeedDto> selectPublicItineraries(long userId) throws Exception;

	List<ProfileFeedDto> selectPublicLikedItineraries(long userId) throws Exception;

	List<ProfileFeedDto> selectPublicBookmarkedItineraries(long userId) throws Exception;

	/* 무한 스크롤 조회 */
	List<ProfileFeedDto> selectMyItinerariesPage(long userId, int offset, int limit) throws Exception;

	List<ProfileFeedDto> selectBookmarkedItinerariesPage(long userId, int offset, int limit) throws Exception;

	List<ProfileFeedDto> selectLikedItinerariesPage(long userId, int offset, int limit) throws Exception;

	List<ProfileFeedDto> selectPublicItinerariesPage(long userId, int offset, int limit) throws Exception;

	List<ProfileFeedDto> selectPublicLikedItinerariesPage(long userId, int offset, int limit) throws Exception;

	List<ProfileFeedDto> selectPublicBookmarkedItinerariesPage(long userId, int offset, int limit) throws Exception;

	/* 상단 통계 */
	int countMyItineraries(long userId) throws Exception;

	int countPublicItineraries(long userId) throws Exception;

	int selectReceivedLikeCount(long userId) throws Exception;

	int selectReceivedBookmarkCount(long userId) throws Exception;

	int selectPublicReceivedLikeCount(long userId) throws Exception;

	int selectPublicReceivedBookmarkCount(long userId) throws Exception;

	/* 일정 삭제 */
	void deleteItinerary(long itineraryId, long userId) throws Exception;
}
