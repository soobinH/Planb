package dao.community;

import java.util.List;

import org.apache.ibatis.session.SqlSession;

import config.MybatisSqlSessionFactory;
import dto.community.TipCommentDto;

public class TipCommentDaoImpl implements TipCommentDao {

    // 댓글 작성
    @Override
    public int insertTipComment(TipCommentDto tipCommentDto) {
        try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {
            int result = sqlSession.insert("mapper.community.tipComment.insertTipComment", tipCommentDto);
            sqlSession.commit();
            return result;
        } catch (Exception e) {
            e.printStackTrace();
            throw e;
        }
    }

    // 댓글 1개 조회
    @Override
    public TipCommentDto selectTipComment(Long commentId) {
        try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {
            return sqlSession.selectOne("mapper.community.tipComment.selectTipComment", commentId);
        } catch (Exception e) {
            e.printStackTrace();
            throw e;
        }
    }

    // 댓글 목록 조회
    @Override
    public List<TipCommentDto> selectTipCommentList(long tipId) {
        try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {
            return sqlSession.selectList("mapper.community.tipComment.selectTipCommentList", tipId);
        } catch (Exception e) {
            e.printStackTrace();
            throw e;
        }
    }

    // 댓글 수정
    @Override
    public int updateTipComment(TipCommentDto tipCommentDto) {
        try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {
            int result = sqlSession.update("mapper.community.tipComment.updateTipComment", tipCommentDto);
            sqlSession.commit();
            return result;
        } catch (Exception e) {
            e.printStackTrace();
            throw e;
        }
    }

    // 댓글 삭제
    @Override
    public int deleteTipComment(TipCommentDto tipCommentDto) {
        try (SqlSession sqlSession = MybatisSqlSessionFactory.getSqlSessionFactory().openSession()) {
            int result = sqlSession.delete("mapper.community.tipComment.deleteTipComment", tipCommentDto);
            sqlSession.commit();
            return result;
        } catch (Exception e) {
            e.printStackTrace();
            throw e;
        }
    }
    
    @Override
    public int insertTipComment(SqlSession sqlSession, TipCommentDto tipCommentDto) {
        return sqlSession.insert("mapper.community.tipComment.insertTipComment", tipCommentDto);
    }
}