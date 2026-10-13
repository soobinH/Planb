package controller.image;

import java.io.IOException;
import java.io.OutputStream;
import java.nio.file.Files;
import java.nio.file.Path;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import util.image.SharedImageStorage;
import util.image.SharedImageStorage.Category;

/**
 * DB의 /uploads/{category}/{fileName} 경로를 공용 공유폴더 이미지로 연결한다.
 */
@WebServlet(urlPatterns = {
        "/uploads/itinerary/*",
        "/uploads/profile/*",
        "/uploads/tip/*",
        "/uploads/mate/*",
        "/uploads/ads/*"
})
public class SharedImageView extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Category category = resolveCategory(request.getServletPath());
        String pathInfo = request.getPathInfo();

        if (category == null || pathInfo == null || pathInfo.length() <= 1) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String fileName = pathInfo.substring(1);
        Path imagePath;

        try {
            imagePath = SharedImageStorage.resolveFile(category, fileName);
        } catch (IllegalArgumentException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        if (!Files.exists(imagePath) || !Files.isRegularFile(imagePath)) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String contentType = getServletContext().getMimeType(
                imagePath.getFileName().toString());

        if (contentType == null) {
            contentType = Files.probeContentType(imagePath);
        }

        if (contentType == null || !contentType.startsWith("image/")) {
            response.sendError(HttpServletResponse.SC_UNSUPPORTED_MEDIA_TYPE);
            return;
        }

        response.setContentType(contentType);
        response.setContentLengthLong(Files.size(imagePath));
        response.setHeader("Cache-Control", "public, max-age=604800");
        response.setHeader("X-Content-Type-Options", "nosniff");

        try (OutputStream output = response.getOutputStream()) {
            Files.copy(imagePath, output);
        }
    }

    private Category resolveCategory(String servletPath) {
        if (servletPath == null) {
            return null;
        }

        String prefix = SharedImageStorage.WEB_URL_ROOT + "/";
        if (!servletPath.startsWith(prefix)) {
            return null;
        }

        String folderName = servletPath.substring(prefix.length());
        return Category.fromFolderName(folderName);
    }
}
