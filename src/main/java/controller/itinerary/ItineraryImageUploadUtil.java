package controller.itinerary;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.Part;

import dto.itinerary.ItineraryBlockDto;
import dto.itinerary.ItineraryBlockImageDto;
import dto.itinerary.ItineraryDayDto;
import dto.itinerary.ItineraryDto;
import util.image.SharedImageStorage;
import util.image.SharedImageStorage.Category;

public final class ItineraryImageUploadUtil {

    private ItineraryImageUploadUtil() {
    }


    /*
     * planner.jsp가 보내는 multipart 파일을 저장하고
     * 해당 ImageDto.imageUrl을 실제 저장 경로로 채운다.
     *
     * Part 이름 규칙:
     * blockImage_{dayIndex}_{blockIndex}_{imageOrder}
     *
     * 예:
     * blockImage_0_1_2
     * = 첫 번째 DAY / 두 번째 BLOCK / 2번 사진
     */
    public static List<File> bindUploadedImages(
            HttpServletRequest request,
            ItineraryDto itineraryDto
    ) throws Exception {

        List<File> createdFiles =
                new ArrayList<File>();

        if (itineraryDto == null
                || itineraryDto.getDays() == null) {

            return createdFiles;
        }

        List<ItineraryDayDto> days =
                itineraryDto.getDays();

        for (int dayIndex = 0;
                dayIndex < days.size();
                dayIndex++) {

            ItineraryDayDto day =
                    days.get(dayIndex);

            if (day == null
                    || day.getBlocks() == null) {
                continue;
            }

            List<ItineraryBlockDto> blocks =
                    day.getBlocks();

            for (int blockIndex = 0;
                    blockIndex < blocks.size();
                    blockIndex++) {

                ItineraryBlockDto block =
                        blocks.get(blockIndex);

                if (block == null
                        || block.getImages() == null) {
                    continue;
                }

                for (ItineraryBlockImageDto image
                        : block.getImages()) {

                    if (image == null) {
                        continue;
                    }

                    /*
                     * 기존 DB 이미지:
                     * imageUrl이 이미 있으므로 파일 재업로드 안 함.
                     */
                    if (hasText(image.getImageUrl())) {
                        continue;
                    }

                    Integer imageOrder =
                            image.getImageOrder();

                    if (imageOrder == null
                            || imageOrder < 1
                            || imageOrder > 3) {

                        throw new IllegalArgumentException(
                                "이미지 순서는 1~3만 가능합니다."
                        );
                    }

                    String partName =
                            "blockImage_"
                            + dayIndex + "_"
                            + blockIndex + "_"
                            + imageOrder;

                    Part part =
                            request.getPart(partName);

                    if (part == null
                            || part.getSize() == 0) {

                        throw new IllegalArgumentException(
                                "업로드할 이미지 파일을 찾을 수 없습니다: "
                                + partName
                        );
                    }

                    /*
                     * 실제 파일은 공용 공유폴더에 저장하고,
                     * DB에는 /uploads/itinerary/{파일명} 웹 경로만 저장한다.
                     */
                    String imageUrl =
                            SharedImageStorage.saveImage(
                                    part,
                                    Category.ITINERARY
                            );

                    Path targetPath =
                            SharedImageStorage.resolveWebUrl(
                                    imageUrl,
                                    Category.ITINERARY
                            );

                    if (targetPath != null) {
                        createdFiles.add(targetPath.toFile());
                    }

                    image.setImageUrl(imageUrl);
                }
            }
        }

        return createdFiles;
    }


    public static String resolveThumbnailImageUrl(
            ItineraryDto itineraryDto,
            String imageKey) {

        if (itineraryDto == null
                || imageKey == null
                || imageKey.trim().isEmpty()) {
            return null;
        }

        imageKey = imageKey.trim();

        /*
         * Google Places 사진은 URL/사진 자체를 DB에 캐시하지 않고
         * 저장 가능한 Place ID만 gplace:{placeId} 형태로 보관한다.
         *
         * 신규 선택: place:{dayIndex}:{blockIndex}
         * 기존 대표 이미지 유지: placeId:{placeId}
         */
        if (imageKey.startsWith("place:")) {
            String[] placeParts = imageKey.split(":");

            if (placeParts.length != 3) {
                throw new IllegalArgumentException(
                        "대표 장소 이미지 선택 정보가 올바르지 않습니다."
                );
            }

            int dayIndex;
            int blockIndex;

            try {
                dayIndex = Integer.parseInt(placeParts[1]);
                blockIndex = Integer.parseInt(placeParts[2]);
            } catch (NumberFormatException e) {
                throw new IllegalArgumentException(
                        "대표 장소 이미지 선택 정보가 올바르지 않습니다."
                );
            }

            ItineraryBlockDto block =
                    findBlock(itineraryDto, dayIndex, blockIndex);

            if (block == null
                    || !hasText(block.getGooglePlaceId())) {
                throw new IllegalArgumentException(
                        "대표 이미지로 선택한 장소를 찾을 수 없습니다."
                );
            }

            return "gplace:" + block.getGooglePlaceId().trim();
        }

        if (imageKey.startsWith("placeId:")) {
            String placeId =
                    imageKey.substring("placeId:".length()).trim();

            if (!hasText(placeId)
                    || !containsGooglePlaceId(itineraryDto, placeId)) {
                throw new IllegalArgumentException(
                        "기존 대표 장소 이미지를 찾을 수 없습니다."
                );
            }

            return "gplace:" + placeId;
        }

        String[] parts = imageKey.split(":");

        if (parts.length != 3) {
            throw new IllegalArgumentException(
                    "대표 이미지 선택 정보가 올바르지 않습니다."
            );
        }

        int dayIndex;
        int blockIndex;
        int imageOrder;

        try {
            dayIndex = Integer.parseInt(parts[0]);
            blockIndex = Integer.parseInt(parts[1]);
            imageOrder = Integer.parseInt(parts[2]);
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException(
                    "대표 이미지 선택 정보가 올바르지 않습니다."
            );
        }

        if (itineraryDto.getDays() == null
                || dayIndex < 0
                || dayIndex >= itineraryDto.getDays().size()) {
            throw new IllegalArgumentException(
                    "대표 이미지를 찾을 수 없습니다."
            );
        }

        ItineraryDayDto day =
                itineraryDto.getDays().get(dayIndex);

        if (day == null
                || day.getBlocks() == null
                || blockIndex < 0
                || blockIndex >= day.getBlocks().size()) {
            throw new IllegalArgumentException(
                    "대표 이미지를 찾을 수 없습니다."
            );
        }

        ItineraryBlockDto block =
                day.getBlocks().get(blockIndex);

        if (block == null
                || block.getImages() == null) {
            throw new IllegalArgumentException(
                    "대표 이미지를 찾을 수 없습니다."
            );
        }

        for (ItineraryBlockImageDto image
                : block.getImages()) {

            if (image != null
                    && image.getImageOrder() != null
                    && image.getImageOrder() == imageOrder
                    && hasText(image.getImageUrl())) {

                return image.getImageUrl();
            }
        }

        throw new IllegalArgumentException(
                "대표 이미지로 선택한 사진을 찾을 수 없습니다."
        );
    }


    private static ItineraryBlockDto findBlock(
            ItineraryDto itineraryDto,
            int dayIndex,
            int blockIndex) {

        if (itineraryDto == null
                || itineraryDto.getDays() == null
                || dayIndex < 0
                || dayIndex >= itineraryDto.getDays().size()) {
            return null;
        }

        ItineraryDayDto day =
                itineraryDto.getDays().get(dayIndex);

        if (day == null
                || day.getBlocks() == null
                || blockIndex < 0
                || blockIndex >= day.getBlocks().size()) {
            return null;
        }

        return day.getBlocks().get(blockIndex);
    }


    private static boolean containsGooglePlaceId(
            ItineraryDto itineraryDto,
            String placeId) {

        if (itineraryDto == null
                || itineraryDto.getDays() == null
                || !hasText(placeId)) {
            return false;
        }

        for (ItineraryDayDto day : itineraryDto.getDays()) {
            if (day == null || day.getBlocks() == null) {
                continue;
            }

            for (ItineraryBlockDto block : day.getBlocks()) {
                if (block != null
                        && hasText(block.getGooglePlaceId())
                        && placeId.equals(block.getGooglePlaceId().trim())) {
                    return true;
                }
            }
        }

        return false;
    }


    public static void deleteCreatedFiles(
            List<File> files) {

        if (files == null) {
            return;
        }

        for (File file : files) {

            if (file != null
                    && file.exists()) {

                try {
                    file.delete();
                } catch (Exception ignore) {
                }
            }
        }
    }


    /*
     * 일정 수정 성공 후,
     * 기존 DB에는 있었지만 현재 DTO에는 없는 이미지 파일을 삭제한다.
     */
    public static void deleteRemovedImages(
            ItineraryDto oldItinerary,
            ItineraryDto newItinerary) {

        if (oldItinerary == null) {
            return;
        }

        Set<String> oldUrls =
                collectImageUrls(oldItinerary);

        Set<String> newUrls =
                collectImageUrls(newItinerary);

        oldUrls.removeAll(newUrls);

        for (String imageUrl : oldUrls) {

            /*
             * 우리 일정 업로드 폴더 안의 파일만 삭제한다.
             */
            Path imagePath;

            try {
                imagePath =
                        SharedImageStorage
                            .resolveWebUrl(
                                    imageUrl,
                                    Category.ITINERARY
                            );
            } catch (IllegalArgumentException e) {
                continue;
            }

            if (imagePath == null) {
                continue;
            }

            try {
                Files.deleteIfExists(imagePath);
            } catch (Exception ignore) {
            }
        }
    }


    private static Set<String> collectImageUrls(
            ItineraryDto itineraryDto) {

        Set<String> result =
                new HashSet<String>();

        if (itineraryDto == null
                || itineraryDto.getDays() == null) {
            return result;
        }

        for (ItineraryDayDto day
                : itineraryDto.getDays()) {

            if (day == null
                    || day.getBlocks() == null) {
                continue;
            }

            for (ItineraryBlockDto block
                    : day.getBlocks()) {

                if (block == null
                        || block.getImages() == null) {
                    continue;
                }

                for (ItineraryBlockImageDto image
                        : block.getImages()) {

                    if (image != null
                            && hasText(
                                    image.getImageUrl()
                            )) {

                        result.add(
                                image.getImageUrl()
                        );
                    }
                }
            }
        }

        return result;
    }


    private static boolean hasText(
            String value) {

        return value != null
                && !value.trim().isEmpty();
    }
}
