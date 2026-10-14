package util.firebase;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.HashMap;
import java.util.Map;

import com.google.gson.Gson;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;

public final class FirebaseMessagingClient {

	private static final Gson GSON = new Gson();

	private static final HttpClient HTTP = HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(10)).build();

	private FirebaseMessagingClient() {
	}

	/*
	 * true: Firebase가 메시지 접수를 완료 false: 더 이상 등록되어 있지 않은 브라우저
	 */
	public static boolean sendRefresh(String installationId) throws Exception {

		if (installationId == null || installationId.trim().isEmpty()) {
			throw new IllegalArgumentException("Firebase 등록번호가 없습니다.");
		}

		String projectId = FirebaseAccessToken.getProjectId();

		URI endpoint = URI.create("https://fcm.googleapis.com/v1/projects/" + projectId + "/messages:send");

		Map<String, Object> data = new HashMap<>();
		data.put("type", "NOTIFICATIONS_UPDATED");

		Map<String, Object> headers = new HashMap<>();
		headers.put("TTL", "60");

		Map<String, Object> webpush = new HashMap<>();
		webpush.put("headers", headers);

		Map<String, Object> message = new HashMap<>();
		message.put("fid", installationId);
		message.put("data", data);
		message.put("webpush", webpush);

		Map<String, Object> body = new HashMap<>();
		body.put("message", message);

		String json = GSON.toJson(body);

		for (int attempt = 0; attempt < 2; attempt++) {
			HttpRequest request = HttpRequest.newBuilder().uri(endpoint).timeout(Duration.ofSeconds(20))
					.header("Authorization", "Bearer " + FirebaseAccessToken.getAccessToken())
					.header("Content-Type", "application/json; charset=UTF-8")
					.POST(HttpRequest.BodyPublishers.ofString(json, StandardCharsets.UTF_8)).build();

			HttpResponse<String> response;

			try {
				response = HTTP.send(request, HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));

			} catch (InterruptedException e) {
				Thread.currentThread().interrupt();
				throw e;
			}

			int status = response.statusCode();

			if (status >= 200 && status < 300) {
				return true;
			}

			String errorCode = getErrorCode(response.body());

			// 등록 해제된 브라우저만 DB 정리 대상으로 판단
			if ("UNREGISTERED".equals(errorCode)) {
				return false;
			}

			// 인증 오류는 토큰을 새로 발급받아 한 번만 재시도
			if (status == 401 && attempt == 0) {
				FirebaseAccessToken.invalidateToken();
				continue;
			}

			throw new IOException("Firebase 메시지 발송 실패: HTTP " + status + ", " + errorCode);
		}

		throw new IOException("Firebase 메시지 발송에 실패했습니다.");
	}

	private static String getErrorCode(String responseBody) {
		try {
			JsonObject result = GSON.fromJson(responseBody, JsonObject.class);

			if (result == null || !result.has("error")) {
				return "UNKNOWN";
			}

			JsonObject error = result.getAsJsonObject("error");

			if (error.has("details") && error.get("details").isJsonArray()) {

				for (JsonElement element : error.getAsJsonArray("details")) {
					if (!element.isJsonObject()) {
						continue;
					}

					JsonObject detail = element.getAsJsonObject();

					if (detail.has("@type") && "type.googleapis.com/google.firebase.fcm.v1.FcmError"
							.equals(detail.get("@type").getAsString()) && detail.has("errorCode")) {

						return detail.get("errorCode").getAsString();
					}
				}
			}

			if (error.has("status")) {
				return error.get("status").getAsString();
			}

		} catch (RuntimeException e) {
			// JSON이 아닌 오류 응답은 UNKNOWN으로 처리
		}

		return "UNKNOWN";
	}
}