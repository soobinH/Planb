package util.firebase;

import java.io.IOException;
import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.security.KeyFactory;
import java.security.PrivateKey;
import java.security.Signature;
import java.security.spec.PKCS8EncodedKeySpec;
import java.time.Duration;
import java.time.Instant;
import java.util.Base64;
import java.util.HashMap;
import java.util.Map;

import com.google.gson.Gson;
import com.google.gson.JsonObject;

public final class FirebaseAccessToken {

	private static final String TOKEN_URL = "https://oauth2.googleapis.com/token";

	private static final String SCOPE = "https://www.googleapis.com/auth/firebase.messaging";

	private static final Gson GSON = new Gson();

	private static final HttpClient HTTP = HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(10)).build();

	private static Credentials credentials;
	private static String cachedToken;
	private static long expiresAt;

	private FirebaseAccessToken() {
	}

	public static synchronized String getAccessToken() throws Exception {
		long now = Instant.now().getEpochSecond();

		// 만료 60초 전부터 새 토큰 발급
		if (cachedToken != null && now < expiresAt - 60) {
			return cachedToken;
		}

		Credentials account = getCredentials();

		Map<String, Object> header = new HashMap<>();
		header.put("alg", "RS256");
		header.put("typ", "JWT");

		Map<String, Object> claims = new HashMap<>();
		claims.put("iss", account.clientEmail);
		claims.put("scope", SCOPE);
		claims.put("aud", TOKEN_URL);
		claims.put("iat", now);
		claims.put("exp", now + 3600);

		String unsignedJwt = encode(GSON.toJson(header).getBytes(StandardCharsets.UTF_8)) + "."
				+ encode(GSON.toJson(claims).getBytes(StandardCharsets.UTF_8));

		Signature signer = Signature.getInstance("SHA256withRSA");
		signer.initSign(account.privateKey);
		signer.update(unsignedJwt.getBytes(StandardCharsets.UTF_8));

		String jwt = unsignedJwt + "." + encode(signer.sign());

		String body = "grant_type="
				+ URLEncoder.encode("urn:ietf:params:oauth:grant-type:jwt-bearer", StandardCharsets.UTF_8)
				+ "&assertion=" + URLEncoder.encode(jwt, StandardCharsets.UTF_8);

		HttpRequest request = HttpRequest.newBuilder().uri(URI.create(TOKEN_URL)).timeout(Duration.ofSeconds(20))
				.header("Content-Type", "application/x-www-form-urlencoded")
				.POST(HttpRequest.BodyPublishers.ofString(body, StandardCharsets.UTF_8)).build();

		HttpResponse<String> response;

		try {
			response = HTTP.send(request, HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));

		} catch (InterruptedException e) {
			Thread.currentThread().interrupt();
			throw e;
		}

		if (response.statusCode() != 200) {
			throw new IOException("Firebase 인증 토큰 발급 실패: HTTP " + response.statusCode());
		}

		JsonObject result = GSON.fromJson(response.body(), JsonObject.class);

		String accessToken = requiredString(result, "access_token");

		if (!result.has("expires_in")) {
			throw new IOException("인증 응답에 만료 시간이 없습니다.");
		}

		long expiresIn = result.get("expires_in").getAsLong();

		if (expiresIn <= 0) {
			throw new IOException("인증 토큰 만료 시간이 올바르지 않습니다.");
		}

		cachedToken = accessToken;
		expiresAt = Instant.now().getEpochSecond() + expiresIn;

		return cachedToken;
	}

	public static synchronized String getProjectId() throws Exception {
		return getCredentials().projectId;
	}

	private static Credentials getCredentials() throws Exception {
		if (credentials != null) {
			return credentials;
		}

		String filePath = System.getenv("GOOGLE_APPLICATION_CREDENTIALS");

		if (filePath == null || filePath.trim().isEmpty()) {
			throw new IllegalStateException("GOOGLE_APPLICATION_CREDENTIALS 환경변수가 없습니다.");
		}

		Path path = Path.of(filePath);

		if (!Files.isRegularFile(path)) {
			throw new IOException("Firebase 인증 파일을 찾을 수 없습니다.");
		}

		String json = Files.readString(path, StandardCharsets.UTF_8);
		JsonObject account = GSON.fromJson(json, JsonObject.class);

		if (!"service_account".equals(requiredString(account, "type"))) {
			throw new IllegalArgumentException("서비스 계정 인증 파일이 아닙니다.");
		}

		String projectId = requiredString(account, "project_id");

		if (!"planb-7d7d5".equals(projectId)) {
			throw new IllegalArgumentException("Firebase 인증 파일의 프로젝트가 Planb와 다릅니다.");
		}

		String clientEmail = requiredString(account, "client_email");
		String pem = requiredString(account, "private_key");

		String keyText = pem.replace("-----BEGIN PRIVATE KEY-----", "").replace("-----END PRIVATE KEY-----", "")
				.replaceAll("\\s", "");

		byte[] keyBytes = Base64.getDecoder().decode(keyText);

		PrivateKey privateKey = KeyFactory.getInstance("RSA").generatePrivate(new PKCS8EncodedKeySpec(keyBytes));

		credentials = new Credentials(projectId, clientEmail, privateKey);

		return credentials;
	}

	private static String requiredString(JsonObject object, String name) {

		if (object == null || !object.has(name) || object.get(name).isJsonNull()) {

			throw new IllegalArgumentException("Firebase 인증 정보에 " + name + " 값이 없습니다.");
		}

		String value = object.get(name).getAsString();

		if (value.trim().isEmpty()) {
			throw new IllegalArgumentException("Firebase 인증 정보의 " + name + " 값이 비어 있습니다.");
		}

		return value;
	}

	private static String encode(byte[] bytes) {
		return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
	}

	private static final class Credentials {
		private final String projectId;
		private final String clientEmail;
		private final PrivateKey privateKey;

		private Credentials(String projectId, String clientEmail, PrivateKey privateKey) {

			this.projectId = projectId;
			this.clientEmail = clientEmail;
			this.privateKey = privateKey;
		}
	}
}