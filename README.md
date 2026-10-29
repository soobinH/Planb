# Planb — 여행 일정 공유 커뮤니티

여행 일정을 일차별로 만들고 공유하며, 꿀팁 게시판과 여행 메이트 모집으로 다른 여행자와 연결되는 웹 서비스입니다.
KOSTA 'AI를 활용하는 풀스택 개발자' 과정의 4인 팀 프로젝트로 만들었습니다.

| 항목 | 내용 |
| --- | --- |
| 기간 | 2026.09.28 – 2026.10.19 (약 3주) |
| 인원 | 5명 |
| 내 역할 | 회원·인증, 프로필·피드, 설정, 고객지원, 신고 기능의 **DB 쿼리(MyBatis)부터 서비스·서블릿·화면까지** |

<br>

## 기술 스택

| 구분 | 사용 기술 |
| --- | --- |
| Database | MariaDB (mariadb-java-client 3.1.1) |
| Persistence | MyBatis 3.4.6 (XML Mapper 33개) |
| Backend | Java, JSP/Servlet, JSTL |
| Server | Apache Tomcat |
| 외부 연동 | Google OAuth 로그인, JavaMail(이메일 인증), Firebase Cloud Messaging(알림) |
| Tools | Eclipse, Git/GitHub |

<br>

## 주요 기능

- **여행 일정**: 일차(Day)와 블록(장소) 단위로 일정 작성·수정, 시트 분리, 이미지 첨부, 공개 범위 설정
- **일정 담기**: 다른 사람의 일정이나 장소를 내 카트에 담아 새 일정에 활용
- **커뮤니티**: 여행 꿀팁, 여행 메이트 모집 게시판 (댓글, 좋아요, 미디어 첨부, 모집 상태)
- **회원**: 회원가입, 로그인, Google 로그인, 이메일 인증, 아이디 중복 확인, 비밀번호 찾기·변경, 회원 탈퇴
- **프로필**: 내 피드(작성·좋아요·북마크한 일정), 다른 사용자 프로필, 공개 범위 설정
- **알림·신고·광고**: 좋아요·댓글 알림과 알림 설정, 일정·게시글·사용자 신고와 관리자 처리, 광고 문의와 광고 게시
- **고객지원**: 1:1 문의, 광고 문의, FAQ, 약관·개인정보처리방침, 관리자 문의 관리

<br>

## 아키텍처

```
JSP (View)
  │  요청
  ▼
Servlet (controller/*)          ── 요청 파라미터 검증, 세션 확인, 화면 이동
  ▼
Service (service/*)             ── 비즈니스 로직
  ▼
DAO (dao/*)                     ── SqlSession으로 Mapper 호출
  ▼
MyBatis Mapper XML (mapper/*)   ── SQL
  ▼
MariaDB
```

```
src/main/java
├── controller   기능별 서블릿 (auth, itinerary, community, profile, settings, support, report, admin …)
├── service      서비스 인터페이스와 구현체
├── dao          DAO 인터페이스와 구현체
├── dto          테이블 단위 DTO
├── mapper       MyBatis XML Mapper (도메인별 폴더)
├── config       MyBatis SqlSessionFactory, 공통 필터, Firebase 초기화
└── resource     mybatis-config.xml, db.properties(커밋 제외)
src/main/webapp
├── view         기능별 JSP와 assets(css, js, images)
└── common       header, footer, 사이드바
```

<br>

## 데이터베이스 설계

Mapper에서 사용하는 테이블 29개를 도메인별로 나눴습니다. 모든 테이블은 `tb_` 접두사를 쓰고, MyBatis의 `mapUnderscoreToCamelCase`로 snake_case 컬럼을 DTO의 camelCase 필드에 매핑합니다.

| 도메인 | 테이블 |
| --- | --- |
| 회원 | `tb_user` |
| 여행 일정 | `tb_itinerary`, `tb_itinerary_sheet`, `tb_itinerary_day`, `tb_itinerary_block`, `tb_itinerary_block_image` |
| 일정 반응 | `tb_itinerary_like`, `tb_itinerary_bookmark`, `tb_itinerary_comment` |
| 일정 담기 | `tb_itinerary_cart`, `tb_itinerary_day_cart`, `tb_itinerary_block_cart` |
| 커뮤니티 | `tb_tip`, `tb_tip_comment`, `tb_tip_like`, `tb_tip_media`, `tb_mate`, `tb_mate_comment`, `tb_mate_like`, `tb_mate_media` |
| 알림 | `tb_notification`, `tb_notification_device` |
| 신고 | `tb_report`, `tb_report_reason` |
| 광고·관리 | `tb_advertisement`, `tb_advertisement_history`, `tb_admin_action_log` |
| 기타 | `tb_support_inquiry`, `tb_exchange_rate` |



<br>

## 내가 맡은 부분

회원·프로필 영역의 Mapper(`mapper/member/user.xml`, `mapper/profile/profileFeed.xml`)를 직접 작성했고, 이를 쓰는 DAO, Service, Servlet, JSP까지 연결했습니다.

**회원·인증**
- 회원가입(프로필 이미지, 주소 포함)과 `useGeneratedKeys`로 생성된 `user_id` 즉시 반환
- 로그인, Google 로그인과 추가 정보 입력, 이메일 인증, 아이디 중복 확인
- 비밀번호 찾기·재설정·변경, 회원 탈퇴

**프로필·피드**
- 내 피드: 작성한 일정, 좋아요한 일정, 북마크한 일정을 `LIMIT/OFFSET`으로 나눠 불러오기
- 다른 사용자 프로필: 상대가 설정한 공개 범위(프로필 비공개, 좋아요·북마크 목록 공개 여부)와 일정별 공개 범위(`visibility`)를 함께 적용해 볼 수 있는 일정만 조회
- 피드에서 내 일정 수정·삭제

**설정·고객지원·신고**
- 프로필 편집, 비밀번호 변경, 알림 설정(좋아요·댓글 알림 on/off), 개인정보 공개 설정
- 1:1 문의·광고 문의(이미지 업로드), FAQ, 약관, 관리자 문의 확인 페이지
- 사용자 프로필 신고, 관리자 신고 관리 페이지

<br>

## 고민한 점

### 회원 탈퇴: 삭제하지 않고 상태를 바꾸는 방식(Soft Delete)

탈퇴한 회원의 행을 `DELETE`하면 그 회원이 쓴 일정, 댓글, 좋아요가 외래키로 연결돼 있어 함께 지우거나 고아 데이터가 생깁니다.
그래서 행은 남기고 `status`를 `'WITHDRAWN'`으로 바꾸는 방식을 택했습니다.

이때 `login_id`, `nickname`, `email`은 중복을 허용하지 않는 값이라, 그대로 두면 같은 아이디·이메일로 재가입할 수 없습니다.
탈퇴 시 이 값들을 `withdrawn_{user_id}_{탈퇴시각}` 형태로 바꿔 제약은 지키면서 원래 값을 비웠고, 모든 회원 조회 쿼리에 `status = 'ACTIVE'` 조건을 넣어 탈퇴 회원이 로그인·검색되지 않게 했습니다.

```sql
UPDATE TB_USER
SET status   = 'WITHDRAWN',
    login_id = CONCAT('withdrawn_', user_id, '_', DATE_FORMAT(NOW(), '%Y%m%d%H%i%s')),
    nickname = CONCAT('탈퇴회원_', user_id, '_', DATE_FORMAT(NOW(), '%Y%m%d%H%i%s')),
    email    = CONCAT('withdrawn_', user_id, '_', DATE_FORMAT(NOW(), '%Y%m%d%H%i%s'), '@deleted.local'),
    updated_at = NOW()
WHERE user_id = #{value}
  AND status  = 'ACTIVE';
```

### 공개 범위가 두 겹인 피드 조회

다른 사람의 프로필에서는 '사용자가 프로필과 좋아요·북마크 목록을 공개했는가'와 '각 일정이 공개 일정인가'를 모두 만족해야 보여야 합니다.
사용자 단위 설정은 서블릿에서 먼저 확인해 아예 조회하지 않고, 일정 단위 공개 여부는 SQL의 `WHERE i.visibility = 'PUBLIC'`로 걸러 그 결과에 `LIMIT/OFFSET`을 적용했습니다. 이렇게 하면 '더 보기'를 눌렀을 때 페이지마다 보이는 개수가 일정하게 유지됩니다.

## 트러블슈팅

### Google 로그인 회원의 비밀번호가 없어 회원 정보 변경이 실패하던 문제

**문제**
처음에는 `tb_user.password`를 필수값(NOT NULL)으로 설계했습니다. 그런데 Google 로그인으로 가입한 회원은 비밀번호를 따로 입력하지 않아 저장할 값이 없었고, 이 회원들이 회원 정보나 비밀번호를 변경하려 하면 비밀번호 확인 단계에서 오류가 났습니다.

**원인**
'모든 회원은 비밀번호를 가진다'는 전제로 스키마를 만들었는데, 소셜 로그인 회원은 인증 수단이 비밀번호가 아니라 Google 계정이었습니다. 데이터 모델이 실제 회원 유형을 반영하지 못했습니다.

**해결**
1. `password` 컬럼을 nullable로 바꿔, 비밀번호가 없는 회원 유형을 스키마에서 허용했습니다.
2. 회원이 어떤 방식으로 가입했는지를 `provider`(`LOCAL` / `GOOGLE`) 컬럼으로 구분하고, Google 회원은 로그인 시 받은 고유 식별값(`provider_user_id`)으로 본인을 확인하도록 했습니다.
3. 백엔드에서 `provider`가 `LOCAL`이 아닌 회원은 비밀번호 변경 요청을 막고 "소셜 로그인 계정은 비밀번호를 변경할 수 없습니다"를 안내하도록 처리했습니다.

```java
// PasswordChange.java
if (user.getProvider() != null && !"LOCAL".equalsIgnoreCase(user.getProvider())) {
    throw new Exception("소셜 로그인 계정은 비밀번호를 변경할 수 없습니다.");
}
```

**배운 점**
NOT NULL 제약은 '이 값이 없는 데이터는 존재할 수 없다'는 선언입니다. 회원 유형이 늘어나면 그 선언이 여전히 맞는지 다시 확인해야 하고, 제약을 풀 때는 그 빈 값을 애플리케이션이 어떻게 다룰지까지 함께 정해야 한다는 것을 배웠습니다.

<br>

## 실행 방법

1. MariaDB에 `planb` 데이터베이스와 테이블을 생성합니다.
2. `src/main/java/resource/db.properties`를 만듭니다. (Git에 커밋하지 않습니다)
   ```properties
   driver=org.mariadb.jdbc.Driver
   url=jdbc:mariadb://localhost:3306/planb
   username=YOUR_USERNAME
   password=YOUR_PASSWORD
   ```
3. 메일 발송용 `mail.properties`, Firebase 서비스 계정 키를 준비합니다. (Git에 커밋하지 않습니다)
4. Eclipse에서 Dynamic Web Project로 가져와 Tomcat으로 실행합니다.

<br>

## 팀

| 이름 | GitHub |
| --- | --- |
| 황수빈 | [@soobinH](https://github.com/soobinH) |
| 임용택 | [@yoooong96](https://github.com/yoooong96) |
| 김상민 | [@pigsangmin](https://github.com/pigsangmin) |
| 강민구 | [@kangmingoo000805](https://github.com/kangmingoo000805) |
