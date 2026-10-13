package service.report;

import java.util.List;

import dto.report.ReportDto;
import dto.report.ReportReasonDto;

public interface ReportService {

	List<ReportReasonDto> getContentReportReasons() throws Exception;
	long submitItineraryReport(Long itineraryId, Long loginUserId, Integer reasonId, String detail) throws Exception;
	void reportUser(long reporterUserId, long targetUserId, String reasonCode, String detail) throws Exception;
	List<ReportDto> getAllReports() throws Exception;
	void rejectReport(long reportId, long adminUserId) throws Exception;
	void deleteReportedContent(long reportId, long adminUserId) throws Exception;
	void suspendReportedUser(long reportId, long adminUserId) throws Exception;
	long submitTipReport(Long tipId, Long loginUserId, Integer reasonId, String detail) throws Exception;
}