package dao.itinerary;

import java.util.List;

import org.apache.ibatis.session.SqlSession;

import dto.itinerary.ItineraryCommentDto;

public class ItineraryCommentDaoImpl implements ItineraryCommentDao {

	@Override
	public int countItineraryComments(SqlSession sqlSession, Long itineraryId) throws Exception {

		return sqlSession.selectOne("mapper.itinerary.itineraryComment.countItineraryComments", itineraryId);
	}

	@Override
	public List<ItineraryCommentDto> selectItineraryComments(SqlSession sqlSession, Long itineraryId) throws Exception {

		return sqlSession.selectList("mapper.itinerary.itineraryComment.selectItineraryComments", itineraryId);
	}

	@Override
	public int insertItineraryComment(SqlSession sqlSession, ItineraryCommentDto comment) throws Exception {

		return sqlSession.insert("mapper.itinerary.itineraryComment.insertItineraryComment", comment);
	}

	@Override
	public int softDeleteItineraryComment(SqlSession sqlSession, ItineraryCommentDto comment) throws Exception {

		return sqlSession.update("mapper.itinerary.itineraryComment.softDeleteItineraryComment", comment);
	}

	@Override
	public int updateItineraryComment(SqlSession sqlSession, ItineraryCommentDto comment) throws Exception {

		return sqlSession.update("mapper.itinerary.itineraryComment.updateItineraryComment", comment);
	}
}