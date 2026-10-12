package service.advertisement;

import java.sql.Date;
import java.util.List;
import java.util.Map;

import dto.advertisement.AdvertisementDto;

public interface AdvertisementService {
	long submitAdvertisement(AdvertisementDto advertisement) throws Exception;
	
	List<Map<String, Object>> getAllAds() throws Exception;
	void approve(long adId, long adminUserId) throws Exception;
	void reject(long adId, long adminUserId, String reason) throws Exception;
	void activate(long adId,long adminUserId) throws Exception;
	void withdraw(long adId, long adminUserId, String reason) throws Exception;
	void extend(long adId,long adminUserId, Date newEndDate) throws Exception;
	void delete(long adId, long adminUserId) throws Exception;
}
