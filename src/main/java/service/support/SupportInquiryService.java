package service.support;

import java.util.List;
import dto.support.SupportInquiryDto;

public interface SupportInquiryService {
	long submitInquiry(long userId, String category, String email, String title, String content) throws Exception;
    List<SupportInquiryDto> getInquiries(String status) throws Exception;
    SupportInquiryDto getInquiry(long inquiryId) throws Exception;
    boolean answerInquiry(long inquiryId, long adminUserId, String answer) throws Exception;
    List<SupportInquiryDto> getMyInquiries(long userId) throws Exception;
    SupportInquiryDto getMyInquiry(long userId, long inquiryId) throws Exception;
}
