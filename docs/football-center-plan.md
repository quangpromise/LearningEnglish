# Football Center — Kết quả inspect project & kế hoạch triển khai

> Trạng thái: **CHỜ DUYỆT — chưa code dòng nào.**
> Tài liệu này trả lời đúng mục 16 ("Trước khi code: phân tích project hiện tại")
> và mục 19 ("Deliverable") của yêu cầu.

---

## Phần A — INSPECT PROJECT (những gì đã có, sẽ tái sử dụng)

### A1. Kiến trúc & state management
- Flutter + **Riverpod**, **feature-first**: `app/lib/features/<tên>/{data,presentation}`.
- **KHÔNG có** lớp `domain/`, `services/`, `repositories/`, `widgets/` tách riêng —
  tất cả 25 feature hiện tại chỉ dùng đúng 2 thư mục `data/` (model + repository)
  và `presentation/` (screen + provider + widget riêng).
  → Module football sẽ theo **đúng** quy ước này, không dựng kiến trúc mới
  (yêu cầu cho phép điều chỉnh tên thư mục theo architecture hiện tại).

### A2. Navigation — điểm quan trọng nhất cần giữ nguyên
- App có **3 mini-app** (Học tiếng Anh / Fitness / Wealth), mỗi mini-app có
  1 màn Home *thật sự* với route **có tên** (`/`, `/fitness-home`, `/wealth-home`
  — xem `app/lib/core/navigation/nav_keys.dart`).
- **Mọi tính năng khác đều mở dạng POPUP** qua `openAppPopup()`
  (`showModalBottomSheet`, `heightFactor: 0.94`, bo góc trên 28) — route **không tên**.
  Đây là quy ước then chốt: `_goHome` của AssistiveTouch dùng `popUntil(name == homeRoute)`
  để đóng sạch mọi popup.
- **KHÔNG có bottom navigation** trong app → yêu cầu "không thêm bottom nav mới"
  được thoả mãn tự nhiên. Football Center = 1 popup như mọi tính năng khác.
- **AssistiveTouch**: `app/lib/core/navigation/assistive_fab_overlay.dart` —
  nút nổi dính cạnh phải, bung ra thành bánh xe cuộn dọc. Mỗi mục là bộ ba
  `(_RadialAction, IconData, labelKey)` trong `_kGridItems`. Hiện có 6 mục:
  Về trang chủ / Việc cần làm / Lập kế hoạch / AI Voice Chat / Máy tính / Tra từ điển.
  → Thêm mục thứ 7 = sửa đúng 4 chỗ, không đụng logic kéo-thả/hiển thị.

### A3. Auth & user
- **Supabase Auth** (email + Google Sign-In), bảng `public.profiles`,
  RLS `auth.uid() = user_id` ở mọi bảng theo-user.
- AssistiveTouch **tự ẩn khi chưa đăng nhập** → Football Center thừa hưởng,
  không cần tự kiểm tra đăng nhập ở tầng UI.

### A4. Database
- **Supabase Postgres**, migration đánh số tăng dần: `supabase/migrations/0001…0069`.
  → Migration mới bắt đầu từ **0070**.
- Có sẵn mẫu **cache dùng chung cho Edge Function**: bảng `wealth_edge_cache`
  (cache_key → data jsonb + updated_at), dùng bởi `stocks-intl`/`stocks-vn`
  với TTL + **stale-fallback** ("có giá hơi cũ còn hơn không có giá").

### A5. Backend đã có (không cần dựng Node.js server mới)
| Thành phần | Vai trò | Dùng lại cho football |
|---|---|---|
| Supabase **Edge Functions** (Deno) | 11 function đang chạy | Viết thêm function mới cùng kiểu |
| `stocks-intl` | Proxy API có key + cache TTL + stale-fallback | **Khuôn mẫu cho `football-api`** |
| `price-alert-check` | Cron 15′ → quét dữ liệu → **dedup bằng bảng state** → push FCM | **Khuôn mẫu cho live poller + notification engine** |
| `send-chat-push` | Ký JWT service-account → gọi FCM v1 | Dùng lại nguyên hàm |
| **GitHub Actions** `price-alert-check.yml` | `cron: */15 * * * *` gọi Edge Function kèm `x-webhook-secret` | Khuôn mẫu cho cron football |

→ **Yêu cầu "Backend chịu trách nhiệm lấy dữ liệu/cache/polling/push" đã có hạ tầng sẵn.**
Đề xuất **không dựng Node.js + PostgreSQL riêng** như sơ đồ trong ảnh: Supabase Edge
Functions + Postgres của project đã làm đúng vai trò đó, thêm 1 server nữa là thêm 1
thứ phải nuôi và phá nguyên tắc "giữ nguyên kiến trúc hiện tại".

### A6. Push notification — ĐÃ CÓ ĐẦY ĐỦ
- `firebase_core` + `firebase_messaging` đã nằm trong `pubspec.yaml`.
- Bảng `public.device_tokens` (fcm_token ↔ user_id) đã có từ migration 0014.
- `app/lib/core/notifications/chat_push.dart`: dùng **data-only message**, tự dựng
  thông báo bằng `flutter_local_notifications`; có **dispatcher theo `type`**
  (`chat` / `service_expiry` / `price_alert`), mỗi loại 1 **channel riêng**, và
  **background handler** chạy được khi app đã tắt hẳn.
  → Yêu cầu mục 7 ("dùng FCM nếu chưa có hệ thống tương đương") → **đã có**,
  chỉ cần thêm `type: 'football_*'` vào dispatcher + 1 channel mới.
- `daily_quiz_notifications.dart` + `timezone`: mẫu lịch thông báo on-device.

### A7. Đa ngôn ngữ (ràng buộc bắt buộc, ảnh thiết kế chưa tính tới)
- App **song ngữ Việt/Anh**, mọi chuỗi UI đi qua `ref.tr('key')` với
  `app/lib/core/i18n/app_strings.dart` (1.254 khoá). Vừa có commit dịch Fitness
  sang tiếng Anh, và lỗi "còn sót tiếng Việt" vừa phải sửa hôm nay.
  → **Mọi chuỗi của Football Center phải khai báo song ngữ ngay từ đầu.**
  Tên đội/giải lấy từ API (tiếng Anh) thì giữ nguyên, nhưng nhãn UI
  ("Bảng xếp hạng", "Đội hình", "Thống kê"…) phải có cả 2 bản.

### A8. Theme
- `app/lib/core/theme/app_theme.dart` + skill `ui-design-system`:
  nền `#0a0e1c→#0d1330`, glass card `rgba(255,255,255,.05)` viền `.09`, bo 20–24,
  accent xanh `#5b8cff` / tím `#9b6bff`, font Space Grotesk + Manrope.
- Mỗi mini-app đã có accent riêng qua `plannerAccentFor(section)`.
  → Football dùng **accent riêng (xanh điện + đỏ cho trạng thái LIVE)** nhưng
  **giữ nguyên** token nền/glass/bo góc/font ⇒ vừa "sport premium" vừa đồng bộ.

---

## Phần B — QUYẾT ĐỊNH KIẾN TRÚC (cần anh chốt trước khi code)

### B1. Nguồn dữ liệu — ĐÃ CHỐT: API-Football, bậc **Free 100 req/ngày**

Khảo sát đầy đủ 8 nguồn: `docs/research-football-api.md`. Chủ dự án chốt chạy
bậc **Free (100 request/ngày, 10 request/phút)**, nâng cấp sau nếu cần.
Toàn bộ thiết kế dưới đây được làm để **vừa khít 100 call/ngày** và để nâng cấp
chỉ là đổi hằng số trong bảng cấu hình, **không phải sửa code**.

#### Ba mẹo gộp call — nền tảng để 100 call/ngày là đủ

| Mẹo | Endpoint | Tiết kiệm |
|---|---|---|
| Lấy lịch theo NGÀY, không theo từng giải | `/fixtures?date=YYYY-MM-DD` | 1 call ra lịch của **mọi giải** trong ngày, thay vì 6 call |
| 1 call ra TẤT CẢ trận đang đá | `/fixtures?live=all` | 1 call cho toàn bộ trận live khắp thế giới, thay vì mỗi trận 1 call |
| 1 call ra TOÀN BỘ chi tiết 1 trận | `/fixtures?id={id}` | Trả kèm **events + lineups + statistics** trong cùng 1 response, thay vì 3 call riêng |

Mẹo thứ 3 là mấu chốt: mỗi nhịp poll trận yêu thích chỉ tốn **1 call** mà vẫn
có đủ tỉ số, người ghi bàn, thẻ, thay người, đội hình và thống kê.

#### Ngân sách 1 ngày CÓ trận của đội yêu thích

| Việc | Nhịp | Call/ngày |
|---|---|---|
| Đồng bộ lịch 3 ngày tới | 1 lần/ngày, 1 call/ngày-lịch | 3 |
| Bảng xếp hạng (cache 24h, chỉ giải người dùng mở) | tối đa 6 giải | 6 |
| Dò đội hình + theo dõi trận yêu thích (`/fixtures?id=`) | 5 phút/lần, từ 45′ trước bóng lăn | 9 |
| **Live trận yêu thích** (`/fixtures?id=`) | **3 phút/lần × 2,25 giờ** | **45** |
| Quét trận live các giải khác (`/fixtures?live=all`) | 15 phút/lần trong khung giờ có bóng | 20 |
| Dự phòng (retry, người dùng kéo làm mới) | — | ~15 |
| **Tổng** | | **~98** |

#### Điều PHẢI chấp nhận ở bậc Free — nói thẳng để không vỡ kỳ vọng

1. **Live "gần thật", trễ tối đa 3 phút** cho trận của đội yêu thích (bậc Pro cho
   phép 15–60 giây). Push bàn thắng vì vậy có thể đến chậm 1–3 phút so với TV.
2. **Mỗi ngày chỉ theo sát được 1 trận** của đội yêu thích. Nếu 2 đội yêu thích đá
   cùng lúc, backend tự **chia nhịp poll** (mỗi trận 6 phút/lần) thay vì bỏ trận nào.
3. **Các giải khác không có live chi tiết** — chỉ có tỉ số cập nhật 15 phút/lần,
   không có timeline/thống kê thời gian thực. Xem lại đầy đủ sau khi trận kết thúc.
4. **Thống kê + đội hình chỉ có cho trận đang theo dõi**, các trận khác lấy khi
   người dùng mở ra xem (tính vào phần dự phòng, có cache).
5. Hết quota trong ngày → backend **dừng gọi, dùng dữ liệu cache**, app hiện nhãn
   "cập nhật lúc HH:mm" chứ không báo lỗi và không hiện số liệu giả.

#### Cơ chế tự bảo vệ quota (bắt buộc có ngay từ Phase 1)

- Bảng `football_api_budget` đếm số call đã dùng trong ngày (reset theo giờ UTC
  của nhà cung cấp). Mọi call đi qua 1 hàm `spend()` — hết hạn mức thì **không gọi**.
- Ưu tiên theo thứ tự: trận đội yêu thích → lịch → BXH → giải khác. Khi quota
  còn ít, phần ưu tiên thấp bị cắt trước.
- Nhịp poll và hạn mức nằm trong **bảng cấu hình**, không hard-code: lên Pro chỉ
  cần đổi `daily_limit` 100 → 7.500 và nhịp live 180s → 30s.

#### ✅ ĐÃ TEST THẬT bằng key free (2026-09-20, hết 8/100 request)

Không còn phỏng đoán — đây là kết quả gọi thẳng API:

| Endpoint | Free tier | Ghi chú |
|---|---|---|
| `/fixtures?live=all` | ✅ **CHẠY** | 175 trận đang đá, **kèm luôn mảng `events`** (bàn thắng, thẻ, thay người). Có cả La Liga, Serie A, Bundesliga |
| `/fixtures?date=YYYY-MM-DD` | ⚠️ **CHỈ 3 NGÀY** | Cửa sổ cứng: **hôm qua → hôm nay → ngày mai**. Ngoài ra báo lỗi plan |
| `/fixtures?id={id}` | ✅ **CHẠY** | Chi tiết 1 trận |
| `/fixtures?date=…&league=39` | ❌ | Bắt buộc kèm `season` → rơi vào lỗi mùa giải bên dưới |
| `/fixtures?league=39&season=2026` | ❌ | *"Free plans do not have access to this season, try from 2022 to 2024"* |
| `/standings?league=39&season=2026` | ❌ | **Không có bảng xếp hạng mùa hiện tại** |

**Hai giới hạn quyết định phạm vi tính năng:**

1. **Mùa giải**: free chỉ cho 2022–2024. Mùa đang đá (2026/27) bị chặn ở **mọi
   endpoint có tham số `season`** → mất BXH, mất lịch theo vòng đấu, mất thống kê mùa.
2. **Ngày**: free chỉ cho **±1 ngày** quanh hôm nay → không lấy được lịch tương lai,
   không lấy được lịch sử. Đã thử backfill từng ngày để **tự tính BXH** —
   **không được**, ngày 22/08 đã bị chặn.

#### Làm được gì với bậc Free

| Tính năng | Free | Lý do |
|---|---|---|
| Live score 6 giải + timeline sự kiện | ✅ đầy đủ | `live=all` trả kèm `events` |
| Match Center 1 trận (sự kiện, thống kê, đội hình) | ✅ | `fixtures?id=` |
| Push bàn thắng / thẻ / thay người / bắt đầu / kết thúc | ✅ | Suy từ `events` |
| Lịch **hôm nay + ngày mai** | ✅ | `date=` |
| **Nhắc trước 1 ngày** | ✅ vừa đủ | Biết trước đúng 1 ngày — khít với yêu cầu |
| Kết quả **hôm qua** | ✅ | `date=` |
| Lịch thi đấu theo tháng / mùa | ❌ | Cửa sổ 3 ngày |
| **Bảng xếp hạng** | ❌ | `season` bị chặn, không tự tính được |
| Lịch sử đối đầu, thống kê mùa, vua phá lưới | ❌ | `season` bị chặn |

→ Bậc Free chạy được khoảng **60% tính năng** trong yêu cầu gốc: phần *live* thì
đầy đủ, phần *tra cứu* (BXH, lịch dài hạn, lịch sử) thì không.

#### ✅ NGUỒN THỨ HAI: Highlightly — đã TEST THẬT bằng key Basic (2026-09-20)

Lỗ hổng của API-Football Free được vá trọn bằng Highlightly (`sports.highlightly.net`,
bậc Basic **miễn phí**, 100 req/ngày, header `x-rapidapi-key`). Phản hồi của họ ghi
thẳng `"plan": {"tier":"BASIC","message":"All data available with current plan."}`
— **không chặn mùa giải**. Kết quả gọi thật:

| Endpoint | Kết quả test |
|---|---|
| `/football/leagues?leagueName=` | ✅ Premier League (England) = **id 33973**, có mùa 2019→2026 |
| `/football/standings?leagueId=&season=2026` | ✅ **20 đội, điểm thật** (Man City 12, Arsenal 12). Có `total`/`home`/`away` tách riêng: games, wins, draws, loses, scoredGoals, receivedGoals |
| `/football/matches?date=2026-09-06` (quá khứ) | ✅ có tỉ số chung cuộc |
| `/football/matches?date=2026-10-17` (tương lai 1 tháng) | ✅ 5 trận, trạng thái "Not started" |
| `/football/events/{matchId}` | ✅ Goal, VAR Goal Cancelled, kèm `assist` + `playerId` |
| `/football/statistics/{matchId}` | ✅ có cả **Expected Goals, Big Chances Created** — nhiều hơn API-Football |
| `/football/lineups/{matchId}` | có trong tài liệu (chưa test) |
| `?live=true` | ❌ không tồn tại — Highlightly **không có** endpoint "mọi trận đang đá" |

#### Phân vai hai nguồn — mỗi bên làm đúng việc nó mạnh

| Việc | Nguồn | Vì sao |
|---|---|---|
| **Live score + sự kiện realtime** | **API-Football** `live=all` | 1 call ra **mọi** trận đang đá kèm `events`. Highlightly không có endpoint này, muốn live phải gọi từng giải → tốn 6 call/nhịp |
| **Bảng xếp hạng** | **Highlightly** `/standings` | API-Football Free chặn mùa hiện tại |
| **Lịch thi đấu mọi ngày (quá khứ + tương lai)** | **Highlightly** `/matches` | API-Football Free kẹt trong cửa sổ ±1 ngày |
| Chi tiết trận, đội hình, thống kê | Cả hai | Ưu tiên Highlightly (có xG), API-Football dự phòng |

→ **Ghép 2 nguồn free = 200 request/ngày và phủ gần như 100% yêu cầu gốc, chi phí 0đ.**
Không còn tính năng nào phải cắt: bảng xếp hạng ✅, lịch theo tháng ✅, kết quả gần đây ✅,
live + push ✅.

#### Ngân sách gộp 2 nguồn (100 + 100 call/ngày)

**API-Football (100/ngày)** — chỉ lo live:

| Việc | Nhịp | Call/ngày |
|---|---|---|
| `live=all` khi có trận đang đá | 3 phút/lần | 60 (≈ 3 giờ phủ sóng, bao nhiêu trận cũng được) |
| `fixtures?id=` khi mở Match Center lúc trận đang đá | cache 60s | 20 |
| Dự phòng | — | 20 |

**Highlightly (100/ngày)** — lo tra cứu:

| Việc | Nhịp | Call/ngày |
|---|---|---|
| Bảng xếp hạng 6 giải | 2 lần/ngày | 12 |
| Lịch 6 giải (cửa sổ 30 ngày, cache dài) | 1 lần/ngày | 6 |
| `/events`, `/statistics`, `/lineups` khi mở Match Center | theo nhu cầu, cache | 60 |
| Dự phòng | — | 22 |

### B2. Luồng dữ liệu (app KHÔNG bao giờ gọi API-Football)

```
GitHub Actions cron ──► Edge Function "football-sync"  ──► API-Football
   (5–15 phút/lần)          (fixtures, standings, lineup)      │
                                      ▼                        │
Supabase Postgres  ◄───────────────────────────────────────────┘
 (football_* tables = nguồn sự thật + cache)
        ▲                                   │
        │                                   ▼
Flutter app ──► Edge Function "football"  (đọc Postgres, KHÔNG gọi API ngoài)
        ▲
        └──── FCM push ◄── Edge Function "football-live" (dedup + gửi thông báo)
```

- **Đọc**: app gọi 1 Edge Function `football` → đọc thẳng từ bảng Postgres đã
  đồng bộ → **không tốn quota, không có API key trong APK**.
- **Ghi/đồng bộ**: chỉ cron chạm vào API-Football.
- **Live**: khi có trận đang đá, `football-live` poll nhanh, ghi event mới, dedup,
  đẩy push. App đang mở thì nhận realtime qua **Supabase Realtime** trên bảng
  `football_match_events` (đã có sẵn trong supabase_flutter, không cần WebSocket riêng).

**Điểm cần xác minh khi code**: GitHub Actions cron tối thiểu 5 phút và hay trễ →
để live 60 giây, ưu tiên **pg_cron trong Supabase** (chạy theo phút, ngay trong DB).
Nếu bậc Supabase hiện tại không bật được pg_cron thì fallback: GH Actions 5′ +
một vòng lặp ngắn có kiểm soát bên trong Edge Function.

### B3. Schema (migration `0070_football.sql`)

| Bảng | Khoá | Ghi chú |
|---|---|---|
| `football_competitions` | `api_league_id` | 6 giải mở đầu, thêm giải = thêm dòng (kiến trúc mở) |
| `football_teams` | `api_team_id` | tên, logo url, quốc gia |
| `football_fixtures` | `api_fixture_id` | 2 đội, `kickoff_at timestamptz` (UTC), trạng thái, vòng, sân |
| `football_standings` | (league, season, team) | ST/T/H/B/BT/BB/HS/Đ + `form text` (5 trận) + `group_label` cho cúp |
| `football_lineups` | (fixture, team) | formation + JSON XI/dự bị/số áo/vị trí |
| `football_match_events` | (fixture, `event_key`) **unique** | loại, phút, cầu thủ, kiến tạo — `event_key` = hash để **chống trùng** |
| `football_match_stats` | (fixture, team) | JSON toàn bộ statistic API trả về |
| `football_favorite_teams` | (user_id, team) | RLS theo user, có `sort_order` |
| `football_notification_prefs` | user_id | 8 cờ bật/tắt từng loại thông báo |
| `football_push_state` | (fixture, event_key) | **dedup push** — 1 event chỉ push 1 lần |
| `football_api_budget` | ngày (UTC) | **đếm quota 100 call/ngày**, chặn gọi khi hết hạn mức |
| `football_config` | khoá | nhịp poll + hạn mức, đổi được mà không sửa code |

API-Football **không cấp id ổn định cho event** → `event_key` =
`sha1(fixture|elapsed|extra|type|detail|team|player)`, đúng yêu cầu mục 14.

### B4. Màn hình (10 màn, khớp ảnh thiết kế)
1. **Football Home** — hero giải nổi bật, Live đang đá, lưới 8 giải, BXH rút gọn, đội yêu thích
2. **Giải đấu** — danh sách giải (cờ + tên + quốc gia)
3. **Bảng xếp hạng** — chọn mùa, bảng đầy đủ + form 5 trận, hỗ trợ group/knockout
4. **Đội yêu thích** — tìm & chọn nhiều đội, có nút ⭐
5. **Lịch thi đấu đội yêu thích** — gom theo tháng, filter theo giải, chuông bật/tắt từng trận
6. **Trận trực tiếp** — tỉ số lớn + phút + timeline
7. **Match Center** — 5 tab: Tổng quan / Sự kiện / Thống kê / Đội hình / Cầu thủ
8. **Đội hình** — sơ đồ sân 4-3-3, XI + dự bị
9. **Chi tiết trận** — timeline dạng dòng thời gian
10. **Thông báo** — nhật ký thông báo + **cài đặt bật/tắt 8 loại**

Tất cả mở trong **1 popup duy nhất** (`FootballCenterScreen`), điều hướng nội bộ
bằng state như `VocabularyTopicsScreen` đang làm → nút back trong popup không pop
route thật, giữ nguyên quy ước điều hướng của app.

---

## Phần C — LỘ TRÌNH (mỗi phase là 1 lần duyệt)

| Phase | Nội dung | Kết quả kiểm chứng được |
|---|---|---|
| **0** | `docs/research-football-api.md`: chốt ToS, quota, mapping endpoint; mockup HTML 10 màn theo design system | Đọc/duyệt trước khi tốn dòng code nào |
| **1** | Xác minh key free thấy được mùa hiện tại → Migration `0070_football.sql` (gồm `football_api_budget`) + Edge Function `football-sync` + `football` (đọc) + cron | Gọi thử bằng curl, thấy dữ liệu thật trong Postgres, bộ đếm quota chạy đúng |
| **2** | Flutter: `features/football/data` (model + repository) + Home + Giải đấu + BXH + i18n | Mở được Football Center từ AssistiveTouch, thấy BXH thật |
| **3** | Đội yêu thích + lịch thi đấu đa giải + filter | Chọn MU → thấy cả trận Premier League lẫn Champions League |
| **4** | Match Center (5 tab) + Live + Supabase Realtime | Xem 1 trận đang đá, timeline tự cập nhật |
| **5** | `football-live` (dedup) + push 8 loại + nhắc trước 1 ngày + màn cài đặt thông báo | Nhận push thật khi app đóng |
| **6** | Xử lý biên (timeout, mất mạng, rate limit, hoãn/huỷ, chưa có lineup, timezone) + tài liệu bàn giao | Checklist mục 18 + 19 |

**Cam kết không phá vỡ cái cũ**: chỉ **thêm file mới**; 4 file hiện có bị **thêm dòng**
(không sửa logic): `assistive_fab_overlay.dart` (+1 mục menu), `app_strings.dart`
(+khoá i18n), `chat_push.dart` (+1 nhánh `type`), `pubspec.yaml` (nếu cần package mới).
Chạy `flutter analyze` + `dart format` + `flutter test` trước mỗi lần đẩy.

---

## Phần D — PHASE 1 ĐÃ XONG: hướng dẫn triển khai

### D1. File đã tạo (toàn bộ là file MỚI, không sửa code cũ)

| File | Vai trò |
|---|---|
| `supabase/migrations/0070_football.sql` | 14 bảng + RLS + 2 hàm quota + 2 hàm chuẩn hoá tên + Realtime |
| `supabase/functions/football-sync/index.ts` | Highlightly → lịch thi đấu + bảng xếp hạng + phong độ 5 trận |
| `supabase/functions/football-live/index.ts` | API-Football `live=all` → tỉ số + sự kiện + push (có chống trùng) |
| `.github/workflows/football-sync.yml` | Cron 3 giờ/lần |
| `.github/workflows/football-live.yml` | Cron 5 phút/lần, chỉ trong khung 11–23h UTC (18h–7h giờ VN) |

### D2. Thứ tự triển khai

```bash
# 1. Áp migration
supabase db push

# 2. Đặt secret (KHÔNG bao giờ nhúng khoá vào APK)
supabase secrets set HIGHLIGHTLY_KEY=...
supabase secrets set API_FOOTBALL_KEY=...
supabase secrets set FOOTBALL_WEBHOOK_SECRET=<chuỗi bí mật tự chọn>
# FIREBASE_SERVICE_ACCOUNT_JSON và FIREBASE_PROJECT_ID đã có sẵn từ send-chat-push

# 3. Deploy 2 Edge Function
supabase functions deploy football-sync --no-verify-jwt --use-api
supabase functions deploy football-live --no-verify-jwt --use-api

# 4. Chạy thử bằng tay (chưa cần đợi cron)
curl -sf -X POST "https://<project>.supabase.co/functions/v1/football-sync" \
  -H "x-webhook-secret: <FOOTBALL_WEBHOOK_SECRET>"
```

Lần chạy đầu trả về `{"fixtures":N,"standings":M,"budgetLeft":K}`. Kiểm tra bảng
`football_competitions` phải có đủ 6 dòng với `id` thật của Highlightly.

### D3. Secret cần thêm trong GitHub repo settings

| Tên | Giá trị |
|---|---|
| `FOOTBALL_SYNC_FUNCTION_URL` | `https://<project>.supabase.co/functions/v1/football-sync` |
| `FOOTBALL_LIVE_FUNCTION_URL` | `https://<project>.supabase.co/functions/v1/football-live` |
| `FOOTBALL_WEBHOOK_SECRET` | trùng với secret cùng tên bên Supabase |

### D4. Bốn quyết định thiết kế đáng chú ý

1. **App đọc thẳng Postgres, không qua Edge Function.** Bản kế hoạch đầu định
   viết thêm function `football` cho app gọi. Bỏ — các bảng `football_*` chỉ
   chứa dữ liệu đã đồng bộ, không dính khoá API nào, nên cho client đọc trực
   tiếp qua PostgREST + RLS vừa gọn vừa dùng được **Supabase Realtime** để màn
   Live tự cập nhật khi có bàn thắng (giống `todo_tasks`/`planner_tasks`).
   Edge Function chỉ còn đúng 1 việc: gọi API ngoài và ghi vào bảng.

2. **Ghép dữ liệu 2 nguồn bằng tên + giờ bóng lăn.** Id đội/trận của 2 nhà cung
   cấp không liên quan gì nhau. Khi API-Football báo 1 trận đang đá, worker tìm
   dòng fixture tương ứng bằng (giờ bóng lăn ±15 phút, tên 2 đội đã chuẩn hoá
   qua `football_name_key`), ghép xong thì ghi `api_football_fixture_id` để lần
   sau tra thẳng. Hàm chuẩn hoá có **2 bản** — SQL và TypeScript — phải sửa cùng
   lúc, đã ghi chú ở cả hai nơi.

3. **Quota là cổng chặn cứng, không phải lời khuyên.** Mọi lời gọi ra ngoài đều
   phải qua `football_spend()` — một câu `INSERT … ON CONFLICT … WHERE` nguyên
   tử, nên 2 worker chạy song song không thể cùng tiêu quá hạn mức. Hết quota
   thì worker dừng, app dùng dữ liệu cache.

4. **Không ghi "đã gửi push" trước khi gửi thành công.** Đây là bài học từ lỗi
   thật của `price-alert-check` ngày 2026-09-19 (giá BTC +5,9% mà không ai nhận
   được thông báo): nếu ghi state trước rồi FCM lỗi, sự kiện đó bị nuốt vĩnh
   viễn. Nay chỉ ghi `football_push_state` khi **ít nhất 1 token gửi thành công**.

### D5. Chưa làm (Phase 2 trở đi)

- Phía Flutter: `app/lib/features/football/` + mục AssistiveTouch + chuỗi i18n.
- Đội hình + thống kê chi tiết: gọi `/lineups/{id}`, `/statistics/{id}` của
  Highlightly khi người dùng mở Match Center (đã có bảng, chưa có worker).
- Nhắc trước 1 ngày (`fixture_reminder`) và thông báo đội hình
  (`lineup_available`): đã có cột bật/tắt, chưa có worker sinh thông báo.

---

## Phần E — PHASE 2: module Flutter

### E1. File đã tạo

| File | Vai trò |
|---|---|
| `app/lib/features/football/data/football_models.dart` | Competition, Team, Fixture, StandingRow, MatchEvent |
| `app/lib/features/football/data/football_repository.dart` | Đọc Supabase qua PostgREST |
| `app/lib/features/football/presentation/football_providers.dart` | Riverpod providers |
| `app/lib/features/football/presentation/football_widgets.dart` | TeamBadge, LivePill, FormStrip, EmptyState + màu riêng |
| `app/lib/features/football/presentation/football_center_screen.dart` | Popup gốc: Home + Giải đấu |
| `app/lib/features/football/presentation/football_standings_view.dart` | Bảng xếp hạng 10 cột + phong độ |

### E2. File cũ bị THÊM dòng (không sửa logic nào)

- `app/lib/core/i18n/app_strings.dart` — thêm 24 khoá song ngữ Việt/Anh.
- `app/lib/core/navigation/assistive_fab_overlay.dart` — thêm `openFootball` vào
  enum, 1 mục vào `_kGridItems`, 1 hàm `_openFootball()`, 1 nhánh `switch`,
  1 dòng `import`. Không đụng logic kéo-thả/hiển thị của nút nổi.

### E3. Bốn điểm thiết kế

1. **Cả luồng nằm trong 1 popup.** Home → Giải đấu → Bảng xếp hạng chuyển bằng
   state (`_FootballStep`), không mở thêm route/sheet nào. Đây là quy ước đã có
   của app, ghi rõ lý do ở `vocabulary_topics_screen.dart`: mở sheet chồng sheet
   sẽ làm mất gesture vuốt-xuống-để-đóng của chính popup gốc.

2. **Huy hiệu đội luôn có đường lui.** `TeamBadge` hotlink logo từ CDN nhà cung
   cấp; ảnh lỗi/đang tải/không có thì vẽ huy hiệu chữ viết tắt, màu băm từ tên
   đội nên mỗi đội luôn ra một màu cố định. Đây là ràng buộc **pháp lý** chứ
   không phải thẩm mỹ: logo CLB là nhãn hiệu, không nhà cung cấp nào cấp quyền.

3. **Không bao giờ hiện số liệu giả.** Mọi khối đều có 3 trạng thái loading /
   error / empty riêng. Hết quota → dòng "Cập nhật lúc HH:mm" ở chân màn Home
   cho biết dữ liệu cũ tới đâu, thay vì để người dùng tưởng app hỏng.

4. **Giờ luôn đổi sang múi giờ máy.** `kickoff_at` lưu UTC; model có
   `kickoffLocal`, và repository ép `.toUtc()` trước khi gửi mốc lọc lên server
   — quên chỗ này thì người ở GMT+7 sẽ mất các trận đầu/cuối ngày.

### E4. Chưa làm (Phase 3 trở đi)

- Màn Đội yêu thích + tìm đội + lịch thi đấu theo tháng (repository đã có sẵn
  `fixturesOfTeam`, `favoriteTeamIds`, `addFavorite`, `removeFavorite`).
- Match Center 5 tab + Realtime cho timeline.
- Worker lấy đội hình/thống kê; thông báo nhắc trước 1 ngày và đội hình ra sân.
- Nhánh `type: 'football_event'` trong `chat_push.dart` + channel thông báo riêng.

---

## Phần F — PHASE 3→6

### F1. Phase 3 — Đội yêu thích

| File | Vai trò |
|---|---|
| `football_favorites_view.dart` | Tìm + chọn nhiều đội, đánh dấu sao |
| `football_team_view.dart` | Trang 1 đội: lịch sắp tới + kết quả, lọc theo giải |

Hai quyết định:

- **Danh sách đội chỉ gồm đội đã xuất hiện trong lịch đã đồng bộ.** Cố ý: người
  dùng chỉ chọn được đội mà app thực sự có dữ liệu, thay vì chọn xong màn hình
  trống trơn.
- **Chip lọc giải dựng từ chính dữ liệu trả về** — chỉ hiện giải đội đó thực sự
  có trận, không liệt kê cứng 6 giải rồi để người dùng bấm vào cái rỗng.

### F2. Phase 4 — Match Center

`football_match_center_view.dart` với 4 tab (Tổng quan/Sự kiện gộp chung, Thống
kê, Đội hình).

- **Timeline tự cập nhật qua Supabase Realtime** — máy người dùng không gọi thêm
  request nào, đúng yêu cầu "không polling liên tục từ từng điện thoại".
- **Ghép 2 nguồn dữ liệu trong 1 màn**: bản tĩnh (có tên 2 đội nhờ join) + bản
  realtime (chỉ có tỉ số, vì `.stream()` không kéo theo join). Lấy tên từ bản
  tĩnh, tỉ số từ bản realtime.
- **Đội hình + thống kê lấy THEO NHU CẦU**, không đồng bộ sẵn: 50 trận cuối tuần
  × 2 endpoint = 100 request, đúng bằng hạn mức cả ngày. Chỉ khi người dùng mở
  tab mới gọi `football-match`, có cache 3 phút để nhiều người cùng mở 1 trận
  hot không làm nổ quota.
- Thống kê **chỉ hiện chỉ số có ở CẢ HAI đội** — so sánh một bên không có nghĩa.

### F3. Phase 5 — Thông báo

| Thành phần | Nội dung |
|---|---|
| `football-reminders` (Edge Function) | Nhắc trước 1 ngày + báo đội hình ra sân |
| `chat_push.dart` | Nhánh `football_event` + channel `football_v1` + màu theo loại sự kiện |
| `football_notification_link.dart` | Bấm thông báo → mở thẳng Match Center đúng trận |
| `football_notification_settings_view.dart` | Bật/tắt 9 loại, lưu theo tài khoản |

- **Cửa sổ nhắc trước rộng 4 tiếng** (22–26h trước bóng lăn) vì GitHub Actions
  cron hay trễ; hẹp hơn là trượt mất.
- **Dò đội hình chỉ trong 75 phút trước trận** và chỉ cho trận của đội yêu thích
  — ngoài cửa sổ đó không gọi API.
- Ba nơi định nghĩa giá trị mặc định của 9 loại thông báo (migration, Edge
  Function, model Dart) — đã ghi chú chéo ở cả ba, lệch một chỗ là người dùng
  nhận thông báo khác với cái họ thấy trên màn cài đặt.

### F4. Phase 6 — Xử lý biên

| Tình huống | Cách xử lý |
|---|---|
| Hết quota trong ngày | `football_spend()` chặn, worker dừng, app hiện "Cập nhật lúc HH:mm" |
| Mất mạng / timeout | Mọi khối có `error` state riêng, icon wifi-off, không hiện số giả |
| API chưa có đội hình | "Đội hình chưa được công bố" (yêu cầu mục 9) |
| Chưa có thống kê | Trạng thái rỗng riêng, không vẽ thanh 0-0 |
| Trận hoãn/huỷ | `FixtureState.postponed`, nhãn riêng thay cho giờ thi đấu |
| Timezone | Lưu UTC, hiển thị `.toLocal()`; riêng nội dung push in giờ VN vì server không biết múi giờ từng máy |
| FCM lỗi | Không ghi `football_push_state` → nhịp sau gửi lại |
| Logo lỗi/không có quyền | `TeamBadge` rơi về huy hiệu chữ viết tắt |
| `fixtureId` hỏng trong payload | Vẫn mở màn gốc thay vì không phản ứng gì |
