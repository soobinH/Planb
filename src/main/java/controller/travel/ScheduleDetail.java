package controller.travel;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Set;
import java.util.Comparator;
import dto.itinerary.ItinerarySheetDto;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.google.gson.Gson;

import dto.itinerary.ItineraryBlockDto;
import dto.itinerary.ItineraryDayDto;
import dto.itinerary.ItineraryDto;
import dto.member.UserDto;
import service.itinerary.ItineraryService;
import service.itinerary.ItineraryServiceImpl;
import service.report.ReportService;
import service.report.ReportServiceImpl;

/**
 * Servlet implementation class ScheduleDetail
 */
@WebServlet("/schedules/detail")
public class ScheduleDetail extends HttpServlet {
	private static final long serialVersionUID = 1L;

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public ScheduleDetail() {
		super();
		// TODO Auto-generated constructor stub
	}

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		try {
			String id = request.getParameter("id");

			if (id == null || id.trim().isEmpty()) {
				throw new IllegalArgumentException("일정 번호가 필요합니다.");
			}

			Long itineraryId = Long.valueOf(id.trim());

			if (itineraryId <= 0) {
				throw new IllegalArgumentException("올바른 일정 번호가 아닙니다.");
			}

			HttpSession session = request.getSession(false);
			Long loginUserId = null;

			if (session != null) {
				UserDto user = (UserDto) session.getAttribute("user");

				if (user != null) {
					loginUserId = user.getUserId();
				}
			}

			ItineraryService service = new ItineraryServiceImpl();

			ItineraryDto itinerary = service.getScheduleDetail(itineraryId, loginUserId);

			if (itinerary == null) {
				response.sendError(HttpServletResponse.SC_NOT_FOUND, "일정을 찾을 수 없습니다.");
				return;
			}

            // 상세페이지에서 각 시트 순서대로 DAY를 일련번호로 정렬한다.
            // 기존 단일 국가 게시물도 서비스가 제공하는 레거시 시트 1개로 표시한다.
            List<ItinerarySheetDto> sheets = itinerary.getSheets() == null
                    ? new ArrayList<>() : new ArrayList<>(itinerary.getSheets());
            sheets.sort(Comparator.comparing(ItinerarySheetDto::getSheetOrder,
                    Comparator.nullsLast(Integer::compareTo)));
            if (sheets.isEmpty()) {
                ItinerarySheetDto legacy = new ItinerarySheetDto();
                legacy.setCountry(itinerary.getCountry());
                legacy.setDays(itinerary.getDays());
                sheets.add(legacy);
            }

            // 이전 버전의 일부 DAY에 sheet_id가 없는 경우 첫 시트에 포함한다.
            Set<Long> assignedDayIds = new HashSet<>();
            for (ItinerarySheetDto sheet : sheets) {
                if (sheet.getDays() != null) {
                    for (ItineraryDayDto day : sheet.getDays()) {
                        if (day.getDayId() != null) assignedDayIds.add(day.getDayId());
                    }
                }
            }
            if (itinerary.getDays() != null) {
                List<ItineraryDayDto> firstDays = sheets.get(0).getDays() == null
                        ? new ArrayList<>() : new ArrayList<>(sheets.get(0).getDays());
                for (ItineraryDayDto day : itinerary.getDays()) {
                    if (day.getDayId() != null && !assignedDayIds.contains(day.getDayId())) {
                        firstDays.add(day);
                    }
                }
                sheets.get(0).setDays(firstDays);
            }
            List<ItineraryDayDto> allDays = new ArrayList<>();
            List<Map<String, Object>> mapDays = new ArrayList<>();
            List<Map<String, Object>> sheetNavigation = new ArrayList<>();
            Map<Long, String> daySheetKeys = new HashMap<>();
            // 전체 보기에서 국가 시트의 시작 DAY 위에 표시할 구분 헤더 데이터.
            Map<Long, Map<String, Object>> daySheetDividers = new HashMap<>();
            int globalDay = 0;
            int sheetPosition = 0;
            for (ItinerarySheetDto sheet : sheets) {
                sheetPosition++;
                String sheetKey = sheet.getSheetId() == null ? "legacy-" + sheetPosition
                        : String.valueOf(sheet.getSheetId());
                String sheetLabel = sheet.getCountry() == null || sheet.getCountry().trim().isEmpty()
                        ? "plan" + (char)('A' + Math.min(25, sheetPosition)) : sheet.getCountry().trim();
                Map<String, Object> sheetMeta = new HashMap<>();
                sheetMeta.put("key", sheetKey);
                sheetMeta.put("label", sheetLabel);
                sheetMeta.put("index", sheetPosition);
                sheetNavigation.add(sheetMeta);
                List<ItineraryDayDto> sheetDays = sheet.getDays() == null
                        ? new ArrayList<>() : new ArrayList<>(sheet.getDays());
                sheetDays.sort(Comparator.comparing(ItineraryDayDto::getDayOrder,
                        Comparator.nullsLast(Integer::compareTo)));
                if (!sheetDays.isEmpty() && sheetDays.get(0).getDayId() != null) {
                    Map<String, Object> divider = new HashMap<>();
                    divider.put("sheetKey", sheetKey);
                    divider.put("label", sheetLabel);
                    divider.put("index", sheetPosition);
                    divider.put("startDay", globalDay + 1);
                    divider.put("endDay", globalDay + sheetDays.size());
                    divider.put("dayCount", sheetDays.size());
                    daySheetDividers.put(sheetDays.get(0).getDayId(), divider);
                }
                for (ItineraryDayDto day : sheetDays) {
                    allDays.add(day);
                    if (day.getDayId() != null) daySheetKeys.put(day.getDayId(), sheetKey);
                    globalDay++;
                    Map<String, Object> mapDay = new HashMap<>();
                    mapDay.put("dayNumber", globalDay);
                    mapDay.put("dayId", day.getDayId());
                    mapDay.put("title", day.getTitle());
                    mapDay.put("sheetKey", sheetKey);
                    mapDay.put("sheetLabel", sheetLabel);
                    mapDay.put("sheetIndex", sheetPosition);
                    List<Map<String, Object>> points = new ArrayList<>();
                    if (day.getBlocks() != null) {
                        int blockNumber = 0;
                        for (ItineraryBlockDto block : day.getBlocks()) {
                            blockNumber++;
                            if (block.getPlaceLat() == null || block.getPlaceLng() == null) continue;
                            Map<String, Object> point = new HashMap<>();
                            point.put("blockId", block.getBlockId());
                            point.put("sequence", blockNumber);
                            point.put("type", block.getBlockType());
                            point.put("googlePlaceId", block.getGooglePlaceId());
                            point.put("title", block.getTitle());
                            point.put("placeName", block.getPlaceName());
                            point.put("address", block.getPlaceAddress());
                            point.put("lat", block.getPlaceLat());
                            point.put("lng", block.getPlaceLng());
                            points.add(point);
                        }
                    }
                    mapDay.put("points", points);
                    mapDays.add(mapDay);
                }
            }
            itinerary.setDays(allDays);
            request.setAttribute("itinerary", itinerary);
            request.setAttribute("detailSheets", sheetNavigation);
            request.setAttribute("detailDaySheetKeys", daySheetKeys);
            request.setAttribute("detailDaySheetDividers", daySheetDividers);
            request.setAttribute("detailMapJson", new Gson().toJson(mapDays));

			request.setAttribute("comments", service.getItineraryComments(itineraryId, loginUserId));

			// 신고 팝업에 표시할 활성 신고 사유 조회
			ReportService reportService = new ReportServiceImpl();

			request.setAttribute("reportReasons", reportService.getContentReportReasons());

			request.getRequestDispatcher("/view/travel/scheduleDetail.jsp").forward(request, response);

		} catch (IllegalArgumentException e) {
			response.sendError(HttpServletResponse.SC_BAD_REQUEST, "올바른 일정 번호가 필요합니다.");

		} catch (Exception e) {
			e.printStackTrace();
			response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
		}
	}
}
