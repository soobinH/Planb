package util;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * 게시글 본문의 사진 표시([[IMG:n]]) 순서 정리
 *
 * 수정 화면에서는 [[IMG:n]] 의 n 이 "최종 사진 목록"(남은 기존 사진 → 새 사진)의 순서다.
 * 저장 후에는 작성 화면과 똑같이 "본문에 나온 순서 = 사진 순서(sort_order)" 가 되도록
 * 본문 번호와 사진 순서를 함께 다시 매긴다.
 *  - 본문에 먼저 나온 사진부터 1, 2, 3 ...
 *  - 본문에 표시가 없는 사진은 그 뒤에 원래 순서대로
 *  → 첫 번째 사진(sort_order 1)이 대표 이미지가 된다.
 */
public final class PostImageOrder {

	private static final Pattern MARKER = Pattern.compile("\\[\\[IMG:(\\d+)\\]\\]");

	private PostImageOrder() {
	}

	public static final class Result {

		/** 번호를 다시 매긴 본문 */
		private final String content;

		/** newOrder[i] : 최종 사진 목록 i번째 사진의 새 순서 (1부터) */
		private final int[] newOrder;

		private Result(String content, int[] newOrder) {
			this.content = content;
			this.newOrder = newOrder;
		}

		public String getContent() {
			return content;
		}

		public int getNewOrder(int index) {
			return newOrder[index];
		}
	}

	/**
	 * @param content    수정 화면에서 넘어온 본문
	 * @param imageCount 최종 사진 수 (남은 기존 사진 + 새 사진)
	 */
	public static Result reorder(String content, int imageCount) {

		int[] newOrder = new int[imageCount];
		int next = 1;

		if (content == null) {
			content = "";
		}

		// 1. 본문에 나온 순서대로 새 번호 부여
		Matcher matcher = MARKER.matcher(content);

		while (matcher.find()) {

			int number = parseNumber(matcher.group(1));

			if (number >= 1 && number <= imageCount && newOrder[number - 1] == 0) {
				newOrder[number - 1] = next++;
			}
		}

		// 2. 본문에 표시가 없는 사진은 뒤에 원래 순서대로
		for (int i = 0; i < imageCount; i++) {

			if (newOrder[i] == 0) {
				newOrder[i] = next++;
			}
		}

		// 3. 본문의 번호를 새 번호로 교체 (범위를 벗어난 표시는 제거)
		matcher = MARKER.matcher(content);

		StringBuffer buffer = new StringBuffer();

		while (matcher.find()) {

			int number = parseNumber(matcher.group(1));

			String replacement = number >= 1 && number <= imageCount
					? "[[IMG:" + newOrder[number - 1] + "]]"
					: "";

			matcher.appendReplacement(buffer, Matcher.quoteReplacement(replacement));
		}

		matcher.appendTail(buffer);

		return new Result(buffer.toString(), newOrder);
	}

	private static int parseNumber(String value) {

		try {
			return Integer.parseInt(value);
		} catch (NumberFormatException e) {
			return 0;
		}
	}
}
