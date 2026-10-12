package dao.itinerary;

import java.util.List;

import org.apache.ibatis.session.SqlSession;

import dto.itinerary.ItineraryCommentDto;

public interface ItineraryCommentDao {

	int countItineraryComments(SqlSession sqlSession, Long itineraryId) throws Exception;

	List<ItineraryCommentDto> selectItineraryComments(SqlSession sqlSession, Long itineraryId) throws Exception;

	int insertItineraryComment(SqlSession sqlSession, ItineraryCommentDto comment) throws Exception;

	int softDeleteItineraryComment(SqlSession sqlSession, ItineraryCommentDto comment) throws Exception;

	int updateItineraryComment(SqlSession sqlSession, ItineraryCommentDto comment) throws Exception;
}