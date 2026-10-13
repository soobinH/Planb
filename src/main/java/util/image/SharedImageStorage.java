package util.image;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.DirectoryStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.Locale;
import java.util.UUID;

import javax.servlet.http.Part;

/**
 * Planb 공용 사용자 업로드 이미지 저장소.
 *
 * 실제 파일은 Tomcat 배포 폴더가 아니라 공용 공유폴더 아래에 저장한다.
 * DB에는 운영체제 경로가 아니라 /uploads/{category}/{fileName} 형식의 웹 경로만 저장한다.
 */
public final class SharedImageStorage {

    public enum Category {
        ITINERARY("itinerary"),
        PROFILE("profile"),
        TIP("tip"),
        MATE("mate"),
        ADS("ads");

        private final String folderName;

        Category(String folderName) {
            this.folderName = folderName;
        }

        public String getFolderName() {
            return folderName;
        }

        public static Category fromFolderName(String folderName) {
            if (!hasText(folderName)) {
                return null;
            }

            for (Category category : values()) {
                if (category.folderName.equalsIgnoreCase(folderName.trim())) {
                    return category;
                }
            }

            return null;
        }
    }

    public static final String WEB_URL_ROOT = "/uploads";

    private static final String SYSTEM_PROPERTY = "planb.image.root";
    private static final String ENVIRONMENT_VARIABLE = "PLANB_IMAGE_ROOT";

    private static final String WINDOWS_DEFAULT_ROOT =
            "\\\\DESKTOP-SK3JQT0\\planb-data\\uploads";

    private static final String MAC_SHARE_NAME_PREFIX = "planb-data";
    private static final Path MAC_VOLUMES_ROOT = Paths.get("/Volumes");

    private static final String LINUX_DEFAULT_ROOT =
            "/mnt/planb-data/uploads";

    private SharedImageStorage() {
    }

    /**
     * 공유폴더의 uploads 루트 경로를 반환한다.
     *
     * 우선순위:
     * 1. -Dplanb.image.root=...
     * 2. PLANB_IMAGE_ROOT
     * 3. OS 기본값
     */
    public static Path getUploadsRootPath() {
        String configured = System.getProperty(SYSTEM_PROPERTY);

        if (!hasText(configured)) {
            configured = System.getenv(ENVIRONMENT_VARIABLE);
        }

        if (hasText(configured)) {
            return Paths.get(configured)
                    .toAbsolutePath()
                    .normalize();
        }

        return getDefaultRootByOs();
    }

    /**
     * 공유 uploads 루트가 실제로 접근 가능한지 확인한다.
     */
    public static Path ensureUploadsRootDirectory() throws IOException {
        Path root = getUploadsRootPath();
        Path parent = root.getParent();

        if (parent == null || !Files.exists(parent)) {
            throw new IOException(
                    "Planb 이미지 공유폴더에 연결되어 있지 않습니다: " + root
            );
        }

        Files.createDirectories(root);

        if (!Files.isDirectory(root)) {
            throw new IOException(
                    "Planb 이미지 저장 경로가 폴더가 아닙니다: " + root
            );
        }

        if (!Files.isWritable(root)) {
            throw new IOException(
                    "Planb 이미지 공유폴더에 쓰기 권한이 없습니다: " + root
            );
        }

        return root;
    }

    public static Path ensureCategoryDirectory(Category category)
            throws IOException {

        if (category == null) {
            throw new IllegalArgumentException("이미지 카테고리가 없습니다.");
        }

        Path directory = ensureUploadsRootDirectory()
                .resolve(category.getFolderName())
                .normalize();

        Path root = getUploadsRootPath();

        if (!directory.startsWith(root)) {
            throw new IllegalArgumentException("잘못된 이미지 저장 경로입니다.");
        }

        Files.createDirectories(directory);

        if (!Files.isDirectory(directory)) {
            throw new IOException(
                    "Planb 이미지 카테고리 경로가 폴더가 아닙니다: " + directory
            );
        }

        if (!Files.isWritable(directory)) {
            throw new IOException(
                    "Planb 이미지 카테고리 폴더에 쓰기 권한이 없습니다: " + directory
            );
        }

        return directory;
    }

    /**
     * 이미지 Part를 공용 공유폴더에 저장하고 DB에 넣을 웹 경로를 반환한다.
     */
    public static String saveImage(Part part, Category category)
            throws IOException {

        if (part == null || part.getSize() == 0) {
            throw new IllegalArgumentException("업로드할 이미지 파일이 없습니다.");
        }

        validateImagePart(part);

        String extension = extensionByContentType(part.getContentType());
        String fileName = UUID.randomUUID().toString() + extension;

        Path targetPath = ensureCategoryDirectory(category)
                .resolve(fileName)
                .normalize();

        try (InputStream input = part.getInputStream()) {
            Files.copy(
                    input,
                    targetPath,
                    StandardCopyOption.REPLACE_EXISTING
            );
        }

        return toWebUrl(category, fileName);
    }

    public static Path resolveFile(Category category, String fileName) {
        if (category == null) {
            throw new IllegalArgumentException("이미지 카테고리가 없습니다.");
        }

        validateFileName(fileName);

        Path root = getUploadsRootPath();
        Path categoryRoot = root.resolve(category.getFolderName()).normalize();
        Path target = categoryRoot.resolve(fileName).normalize();

        if (!target.startsWith(categoryRoot)) {
            throw new IllegalArgumentException("잘못된 이미지 경로입니다.");
        }

        return target;
    }

    /**
     * /uploads/{category}/{fileName} 형식의 DB 경로를 실제 공유폴더 Path로 변환한다.
     */
    public static Path resolveWebUrl(String imageUrl) {
        return resolveWebUrl(imageUrl, null);
    }

    /**
     * expectedCategory가 지정되면 다른 카테고리의 경로는 허용하지 않는다.
     */
    public static Path resolveWebUrl(
            String imageUrl,
            Category expectedCategory) {

        if (!hasText(imageUrl)) {
            return null;
        }

        String normalized = imageUrl.trim();

        if (!normalized.startsWith(WEB_URL_ROOT + "/")) {
            return null;
        }

        String relative = normalized.substring((WEB_URL_ROOT + "/").length());
        String[] parts = relative.split("/", 2);

        if (parts.length != 2) {
            return null;
        }

        Category category = Category.fromFolderName(parts[0]);

        if (category == null) {
            return null;
        }

        if (expectedCategory != null && category != expectedCategory) {
            return null;
        }

        return resolveFile(category, parts[1]);
    }

    public static String toWebUrl(Category category, String fileName) {
        if (category == null) {
            throw new IllegalArgumentException("이미지 카테고리가 없습니다.");
        }

        validateFileName(fileName);

        return WEB_URL_ROOT
                + "/"
                + category.getFolderName()
                + "/"
                + fileName;
    }

    public static boolean deleteByWebUrl(String imageUrl) throws IOException {
        Path target = resolveWebUrl(imageUrl);

        if (target == null) {
            return false;
        }

        return Files.deleteIfExists(target);
    }

    private static Path getDefaultRootByOs() {
        String osName = System.getProperty("os.name", "")
                .toLowerCase(Locale.ROOT);

        if (osName.contains("win")) {
            return Paths.get(WINDOWS_DEFAULT_ROOT)
                    .toAbsolutePath()
                    .normalize();
        }

        if (osName.contains("mac")) {
            return resolveMacUploadsRoot();
        }

        return Paths.get(LINUX_DEFAULT_ROOT)
                .toAbsolutePath()
                .normalize();
    }

    /**
     * Finder가 동일 공유폴더를 planb-data-1, planb-data-2처럼 마운트하는 경우까지 찾는다.
     */
    private static Path resolveMacUploadsRoot() {
        Path exactShare = MAC_VOLUMES_ROOT.resolve(MAC_SHARE_NAME_PREFIX);

        if (Files.isDirectory(exactShare)) {
            return exactShare.resolve("uploads")
                    .toAbsolutePath()
                    .normalize();
        }

        if (Files.isDirectory(MAC_VOLUMES_ROOT)) {
            try (DirectoryStream<Path> stream = Files.newDirectoryStream(MAC_VOLUMES_ROOT)) {
                for (Path candidate : stream) {
                    if (!Files.isDirectory(candidate)) {
                        continue;
                    }

                    String name = candidate.getFileName().toString();

                    if (name.toLowerCase(Locale.ROOT)
                            .startsWith(MAC_SHARE_NAME_PREFIX.toLowerCase(Locale.ROOT))) {

                        return candidate.resolve("uploads")
                                .toAbsolutePath()
                                .normalize();
                    }
                }
            } catch (IOException ignore) {
            }
        }

        return exactShare.resolve("uploads")
                .toAbsolutePath()
                .normalize();
    }

    private static void validateImagePart(Part part) {
        String contentType = part.getContentType();

        if (contentType == null) {
            throw new IllegalArgumentException("이미지 파일만 업로드할 수 있습니다.");
        }

        String normalized = contentType.toLowerCase(Locale.ROOT);

        if (!"image/jpeg".equals(normalized)
                && !"image/png".equals(normalized)
                && !"image/gif".equals(normalized)
                && !"image/webp".equals(normalized)) {

            throw new IllegalArgumentException(
                    "JPG, PNG, GIF, WEBP 이미지만 업로드할 수 있습니다."
            );
        }
    }

    private static String extensionByContentType(String contentType) {
        String normalized = contentType == null
                ? ""
                : contentType.toLowerCase(Locale.ROOT);

        if ("image/png".equals(normalized)) {
            return ".png";
        }

        if ("image/gif".equals(normalized)) {
            return ".gif";
        }

        if ("image/webp".equals(normalized)) {
            return ".webp";
        }

        return ".jpg";
    }

    private static void validateFileName(String fileName) {
        if (!hasText(fileName)) {
            throw new IllegalArgumentException("이미지 파일명이 없습니다.");
        }

        if (fileName.contains("/")
                || fileName.contains("\\")
                || fileName.contains("..")) {

            throw new IllegalArgumentException("잘못된 이미지 파일명입니다.");
        }
    }

    private static boolean hasText(String value) {
        return value != null && !value.trim().isEmpty();
    }
}
