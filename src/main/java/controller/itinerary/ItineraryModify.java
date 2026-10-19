package controller.itinerary;

import java.io.IOException;
import java.lang.reflect.Type;
import java.sql.Date;
import java.sql.Time;
import java.io.File;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonDeserializationContext;
import com.google.gson.JsonDeserializer;
import com.google.gson.JsonElement;
import com.google.gson.JsonParseException;

import dto.itinerary.ItineraryDto;
import dto.itinerary.ItineraryDayDto;
import dto.itinerary.ItineraryBlockDto;
import dto.member.UserDto;
import service.itinerary.ItineraryService;
import service.itinerary.ItineraryServiceImpl;

@WebServlet("/itinerary/modify")
@MultipartConfig(
        maxFileSize = 1024 * 1024 * 10,
        maxRequestSize = 1024 * 1024 * 100,
        fileSizeThreshold = 1024 * 1024
)
public class ItineraryModify extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private ItineraryService itineraryService;
    private Gson gson;

    public ItineraryModify() {
        itineraryService = new ItineraryServiceImpl();
        gson = createGson();
    }
    
	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		HttpSession session = request.getSession(false);

		/*
		 * 로그인 확인
		 */
		if (session == null || session.getAttribute("user") == null) {
			response.sendRedirect(request.getContextPath() + "/auth/login");
			return;
		}

		UserDto loginUser = (UserDto) session.getAttribute("user");

		try {

			/*
			 * 수정할 일정 번호
			 */
			String itineraryIdParam = request.getParameter("id");
			if (itineraryIdParam == null || itineraryIdParam.trim().isEmpty()) {
				response.sendError(HttpServletResponse.SC_BAD_REQUEST, "수정할 일정 번호가 없습니다.");
				return;
			}

			long itineraryId = Long.parseLong(itineraryIdParam);

			/*
			 * 기존 일정 조회
			 */
			ItineraryDto itinerary = itineraryService.getItinerary(itineraryId);

			if (itinerary == null) {
				response.sendError(HttpServletResponse.SC_NOT_FOUND, "일정을 찾을 수 없습니다.");
				return;
			}

			/*
			 * 본인 일정인지 확인
			 */
			if (itinerary.getUserId() == null || itinerary.getUserId().longValue() != loginUser.getUserId()) {
				response.sendError(HttpServletResponse.SC_FORBIDDEN, "수정 권한이 없습니다.");
				return;
			}

			/*
			 * 수정 화면에서 사용할 기존 일정 JSON
			 */
			String itineraryJson = gson.toJson(itinerary);
			request.setAttribute("editItineraryJson", itineraryJson);
			request.setAttribute("itinerary", itinerary);

			/*
			 * 수정 화면으로 이동
			 */
			request.getRequestDispatcher("/view/itinerary/planeditor.jsp").forward(request, response);

		} catch (NumberFormatException e) {
			response.sendError(HttpServletResponse.SC_BAD_REQUEST, "잘못된 일정 번호입니다.");

		} catch (Exception e) {
			e.printStackTrace();
			throw new ServletException("일정 수정 화면을 불러오는 중 오류가 발생했습니다.", e);
		}
	}

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("user") == null) {
            if (ItinerarySaveResponse.isAjax(request)) {
                ItinerarySaveResponse.failure(response, HttpServletResponse.SC_UNAUTHORIZED,
                        "로그인 세션이 만료되었습니다. 작성 내용은 유지됩니다. 다시 로그인해 주세요.");
            } else {
                response.sendRedirect(request.getContextPath() + "/auth/login");
            }
            return;
        }

        UserDto loginUser =
                (UserDto) session.getAttribute("user");

        List<File> uploadedFiles =
                new ArrayList<File>();

        try {

            String json =
                    request.getParameter("itineraryJson");

            if (json == null || json.trim().isEmpty()) {
                throw new IllegalArgumentException(
                        "수정할 일정 데이터가 없습니다."
                );
            }

            ItineraryDto itineraryDto =
                    gson.fromJson(
                            json,
                            ItineraryDto.class
                    );

            ItinerarySheetsSupport.normalize(itineraryDto);
            validateRequiredFields(itineraryDto);
            ItineraryLocationValidator.validate(itineraryDto, getServletContext());

            if (itineraryDto.getItineraryId() == null) {
                throw new IllegalArgumentException(
                        "수정할 일정 번호가 없습니다."
                );
            }

            /*
             * 수정 대상이 실제 로그인 사용자의 일정인지 확인한다.
             */
            ItineraryDto savedItinerary =
                    itineraryService.getItinerary(
                            itineraryDto.getItineraryId()
                    );

            if (savedItinerary == null) {
                throw new IllegalArgumentException(
                        "수정할 일정을 찾을 수 없습니다."
                );
            }

            if (savedItinerary.getUserId() == null
                    || savedItinerary.getUserId().longValue()
                    != loginUser.getUserId()) {

                response.sendError(
                        HttpServletResponse.SC_FORBIDDEN,
                        "수정 권한이 없습니다."
                );

                return;
            }

            /*
             * 클라이언트의 userId는 무시한다.
             */
            itineraryDto.setUserId(
                    loginUser.getUserId()
            );

            /*
             * 새로 선택한 사진만 실제 파일로 저장하고
             * ImageDto.imageUrl을 채운다.
             *
             * 기존 사진은 기존 imageUrl을 그대로 사용.
             */
            uploadedFiles =
                    ItineraryImageUploadUtil
                            .bindUploadedImages(
                                    request,
                                    itineraryDto
                            );

            String thumbnailImageKey =
                    request.getParameter(
                            "thumbnailImageKey"
                    );

            itineraryDto.setThumbnailImg(
                    ItineraryImageUploadUtil
                            .resolveThumbnailImageUrl(
                                    itineraryDto,
                                    thumbnailImageKey
                            )
            );


            itineraryService.modifyItinerary(
                    itineraryDto
            );

            /*
             * DB 수정 성공 후에만
             * 화면에서 제거된 기존 이미지의 실제 파일을 삭제한다.
             */
            ItineraryImageUploadUtil
                    .deleteRemovedImages(
                            savedItinerary,
                            itineraryDto
                    );

            /*
             * 기능명세서:
             * 수정 성공 -> 일정 상세페이지 이동
             */
            String detailUrl = request.getContextPath()
                    + "/schedules/detail?id=" + itineraryDto.getItineraryId();
            if (ItinerarySaveResponse.isAjax(request)) {
                ItinerarySaveResponse.success(response, detailUrl);
            } else {
                response.sendRedirect(detailUrl);
            }

        } catch (IllegalArgumentException e) {

            ItineraryImageUploadUtil
                    .deleteCreatedFiles(
                            uploadedFiles
                    );

            if (ItinerarySaveResponse.isAjax(request)) {
                ItinerarySaveResponse.failure(response, 422, e.getMessage());
                return;
            }

            request.setAttribute(
                    "err",
                    e.getMessage()
            );

            request.setAttribute(
                    "editItineraryJson",
                    request.getParameter("itineraryJson")
            );

            request.getRequestDispatcher(
                    "/view/itinerary/planeditor.jsp"
            ).forward(request, response);

        } catch (Exception e) {

            ItineraryImageUploadUtil
                    .deleteCreatedFiles(
                            uploadedFiles
                    );

            e.printStackTrace();
            if (ItinerarySaveResponse.isAjax(request)) {
                ItinerarySaveResponse.failure(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                        "일정 저장 중 서버 오류가 발생했습니다. 입력한 내용은 유지됩니다. 잠시 후 다시 시도해 주세요.");
                return;
            }

            throw new ServletException(
                    "일정 수정 중 오류가 발생했습니다.",
                    e
            );
        }
    }


    private void validateRequiredFields(
            ItineraryDto itineraryDto) {

        if (itineraryDto == null) {
            throw new IllegalArgumentException(
                    "일정 데이터가 없습니다."
            );
        }

        if (itineraryDto.getTitle() == null
                || itineraryDto.getTitle()
                        .trim().isEmpty()) {

            throw new IllegalArgumentException(
                    "여행 제목은 필수입니다."
            );
        }

        if (itineraryDto.getTitle().trim().length() > 30) {
            throw new IllegalArgumentException(
                    "여행 제목은 30자 이하로 입력해 주세요."
            );
        }

        if (itineraryDto.getSummary() != null
                && itineraryDto.getSummary().length() > 250) {
            throw new IllegalArgumentException(
                    "일정 소개는 250자 이하로 입력해 주세요."
            );
        }

        if (itineraryDto.getDays() != null) {
            for (ItineraryDayDto day : itineraryDto.getDays()) {
                if (day == null || day.getBlocks() == null) {
                    continue;
                }
                for (ItineraryBlockDto block : day.getBlocks()) {
                    if (block != null) {
                        String type = block.getBlockType();
                        if (!("ATTRACTION".equals(type)
                                || "MEAL".equals(type)
                                || "LODGING".equals(type)
                                || "TRANSPORT".equals(type))) {
                            throw new IllegalArgumentException(
                                    "지원하지 않는 일정 블록 타입입니다. 관광, 식사, 숙소, 교통만 사용할 수 있습니다."
                            );
                        }
                    }
                    if (block != null && block.getMemo() != null
                            && block.getMemo().length() > 200) {
                        throw new IllegalArgumentException(
                                "블록 메모는 200자 이하로 입력해 주세요."
                        );
                    }
                }
            }
        }

        if (itineraryDto.getCountry() == null
                || itineraryDto.getCountry()
                        .trim().isEmpty()) {

            throw new IllegalArgumentException(
                    "국가는 필수입니다."
            );
        }

        if (itineraryDto.getTravelerCount() != null
                && itineraryDto.getTravelerCount() < 1) {

            throw new IllegalArgumentException(
                    "여행 인원은 1명 이상이어야 합니다."
            );
        }

        if (itineraryDto.getStartDate() != null
                && itineraryDto.getEndDate() != null
                && itineraryDto.getEndDate()
                        .before(itineraryDto.getStartDate())) {

            throw new IllegalArgumentException(
                    "종료일은 시작일보다 빠를 수 없습니다."
            );
        }
    }


    private Gson createGson() {

        GsonBuilder builder =
                new GsonBuilder();

        builder.registerTypeAdapter(
                Date.class,
                new JsonDeserializer<Date>() {

                    @Override
                    public Date deserialize(
                            JsonElement json,
                            Type typeOfT,
                            JsonDeserializationContext context)
                            throws JsonParseException {

                        if (json == null
                                || json.isJsonNull()
                                || json.getAsString().trim().isEmpty()) {
                            return null;
                        }

                        return Date.valueOf(
                                json.getAsString()
                        );
                    }
                }
        );

        builder.registerTypeAdapter(
                Time.class,
                new JsonDeserializer<Time>() {

                    @Override
                    public Time deserialize(
                            JsonElement json,
                            Type typeOfT,
                            JsonDeserializationContext context)
                            throws JsonParseException {

                        if (json == null
                                || json.isJsonNull()
                                || json.getAsString().trim().isEmpty()) {
                            return null;
                        }

                        String value =
                                json.getAsString();

                        if (value.length() == 5) {
                            value += ":00";
                        }

                        return Time.valueOf(value);
                    }
                }
        );

        return builder.create();
    }

}
