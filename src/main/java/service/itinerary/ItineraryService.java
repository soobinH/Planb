package service.itinerary;

import java.util.List;
import java.util.Map;

import dto.itinerary.ItineraryCommentDto;
import dto.itinerary.ItineraryDto;

public interface ItineraryService {
	List<ItineraryDto> getScheduleList(Long loginUserId) throws Exception;

	List<ItineraryDto> getScheduleList(Long loginUserId, String keyword) throws Exception;

	List<ItineraryDto> getScheduleList(Long loginUserId, String keyword, String country) throws Exception;

	List<ItineraryDto> getScheduleList(Long loginUserId, String keyword, String country, String[] durations,
			String[] budgets, String[] travelers) throws Exception;

	List<ItineraryDto> getScheduleList(Long loginUserId, String keyword, String country, String[] durations,
			String[] budgets, String[] travelers, String sort) throws Exception;

	List<ItineraryDto> getScheduleList(Long loginUserId, String keyword, String country, String[] durations,
			String[] budgets, String[] travelers, String sort, int offset) throws Exception;

	long countScheduleList(String keyword, String country, String[] durations, String[] budgets, String[] travelers)
			throws Exception;
	
	// 통합검색용
	List<ItineraryDto> getSearchScheduleList(Long loginUserId, String keyword, int limit) throws Exception;

	ItineraryDto getScheduleDetail(Long itineraryId, Long loginUserId) throws Exception;

	// 좋아요 토글
	Map<String, Object> toggleLike(Long itineraryId, Long loginUserId) throws Exception;

	// 댓글
	List<ItineraryCommentDto> getItineraryComments(Long itineraryId, Long loginUserId) throws Exception;

	Map<String, Object> writeItineraryComment(Long itineraryId, Long loginUserId, String content) throws Exception;

	Map<String, Object> deleteItineraryComment(Long itineraryId, Long commentId, Long loginUserId) throws Exception;

	///////////////////////////////////////////////////////////////////////////////////

	Long writeItinerary(ItineraryDto itineraryDto) throws Exception;

	void modifyItinerary(ItineraryDto itineraryDto) throws Exception;

	ItineraryDto getItinerary(Long itineraryId) throws Exception;

	void deleteItinerary(Long itineraryId, Long userId) throws Exception;

	boolean toggleBookmark(Long itineraryId, Long loginUserId) throws Exception;
	
	

	Map<String, Object> updateItineraryComment(Long itineraryId, Long commentId, Long loginUserId, String content) throws Exception;

}
