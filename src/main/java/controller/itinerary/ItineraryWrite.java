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

@WebServlet("/itinerary/write")
@MultipartConfig(
        maxFileSize = 1024 * 1024 * 10,
        maxRequestSize = 1024 * 1024 * 100,
        fileSizeThreshold = 1024 * 1024
)
public class ItineraryWrite extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private ItineraryService itineraryService;
    private Gson gson;

    public ItineraryWrite() {
        itineraryService = new ItineraryServiceImpl();
        gson = createGson();
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(
                    request.getContextPath() + "/auth/login"
            );
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
                        "저장할 일정 데이터가 없습니다."
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

            /*
             * 클라이언트의 userId는 사용하지 않는다.
             * 로그인한 회원의 세션 값으로 강제한다.
             */
            itineraryDto.setUserId(
                    loginUser.getUserId()
            );

            /*
             * 신규 작성은 itineraryId를 무조건 null 처리한다.
             */
            itineraryDto.setItineraryId(null);

            /*
             * multipart 이미지 파일 저장
             * -> 각 ItineraryBlockImageDto.imageUrl 채움
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


            Long itineraryId =
                    itineraryService.writeItinerary(
                            itineraryDto
                    );

            /*
             * 기능명세서:
             * 저장 성공 -> 일정 상세페이지 이동
             *
             * 현재 Planb 프로젝트의 상세페이지 링크 규칙:
             * /view/travel/scheduleDetail.jsp?id=일정번호
             */
            response.sendRedirect(
                    request.getContextPath()
                    + "/schedules/detail?id="
                    + itineraryId
            );

        } catch (IllegalArgumentException e) {

            ItineraryImageUploadUtil
                    .deleteCreatedFiles(
                            uploadedFiles
                    );

            request.setAttribute(
                    "err",
                    e.getMessage()
            );

            request.getRequestDispatcher(
                    "/view/itinerary/planner.jsp"
            ).forward(request, response);

        } catch (Exception e) {

            ItineraryImageUploadUtil
                    .deleteCreatedFiles(
                            uploadedFiles
                    );

            e.printStackTrace();

            throw new ServletException(
                    "일정 저장 중 오류가 발생했습니다.",
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
