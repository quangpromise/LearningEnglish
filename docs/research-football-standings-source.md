# Nghiên cứu nguồn BẢNG XẾP HẠNG bóng đá (miễn phí + dùng được thương mại)

> **Phạm vi hẹp của tài liệu này**: CHỈ tìm nguồn cho **bảng xếp hạng (standings)**
> mùa giải đang diễn ra (2026/27), để ghép chung với **API-Football bậc Free**
> (đã chốt dùng cho phần LIVE). Mọi tiêu chí khác (live, lineup, thống kê trận,
> logo) đã được phân tích ở `docs/research-football-api.md` — **không lặp lại ở
> đây**.
>
> Ngày nghiên cứu: **2026-09-20**.

## 0. Vì sao cần nguồn thứ hai

Đã test thật bằng key API-Football bậc Free trong ngày 2026-09-20:

- `/fixtures?live=all` chạy tốt, trả kèm mảng `events` (bàn thắng, thẻ, thay người).
- `/fixtures?date=` chỉ cho cửa sổ **±1 ngày** (hôm qua / hôm nay / ngày mai).
- **Mọi endpoint có tham số `season` đều bị chặn** với mùa hiện tại, lỗi nguyên văn:

  > `Free plans do not have access to this season, try from 2022 to 2024`

Hệ quả: `/standings` mùa 2026/27 **không dùng được**, và cũng **không thể tự tính
BXH** bằng cách kéo lịch sử trận từng ngày (ngày quá khứ cũng bị chặn ngoài cửa
sổ ±1 ngày). → Bắt buộc có nguồn thứ hai chỉ để lấy BXH.

---

## 1. Bảng so sánh nhanh

| Nguồn | Thương mại ở bậc FREE? | Cho lưu vào DB riêng? | Đủ 6 giải? | Mùa hiện tại 2026/27? | Tần suất cập nhật | Nghĩa vụ ghi công |
|---|---|---|---|---|---|---|
| **Highlightly** (`soccer.highlightly.net`) — **ĐỀ XUẤT** | **Có** — ToS cho phép tường minh; không phân biệt thương mại/phi thương mại | **Có** — "Distribution, transfer, and storage of the data … are allowed" | Có (950+ giải, gồm cả UCL) | **Chưa test được** (rủi ro chính, xem §2.4) | "up to an hour after a match … is finished" | **Không bắt buộc** |
| **openfootball / football.json** (GitHub) | **Có** — CC0 public domain, không ràng buộc gì | **Có** — CC0 | 5/6 giải quốc nội. **UCL 2026/27 KHÔNG có** (repo `champions-league` dừng ở 2025-26) | **Có**, đã xác minh file thật | **~1 lần/tuần** (commit "auto-update week N") → trễ 2–7 ngày | **Không bắt buộc** (CC0) |
| **Football-Data.co.uk** (CSV) | **Không rõ** — không có ToS/license, chỉ có "© Football-Data. All Rights Reserved." | Không rõ | 5/6 giải quốc nội, **không có UCL** | Có | 2 lần/tuần | Không rõ |
| **Wikipedia** (parse HTML/wikitext) | **Có** — CC BY-SA 4.0 cho phép thương mại | Có | Có (kể cả UCL) | Có, cập nhật gần như realtime | Theo cộng đồng, vài chục phút–vài giờ | **Bắt buộc**: ghi công + link license + **share-alike** (xem §5) |
| Wikidata (`P1350`, bảng xếp hạng) | Có (CC0) | Có | **Không** — không có BXH mùa hiện tại dạng có cấu trúc | — | — | — |
| football-data.org | **KHÔNG** (free = phi thương mại) — xác nhận lại 2026-09-20, điều khoản không đổi | — | — | — | — | — |
| TheSportsDB | **KHÔNG** (free cấm publish lên app store) — không đổi | — | — | — | — | — |
| SoccersAPI / apifootball.com | **KHÔNG** (cấm mọi mục đích thương mại) — không đổi | — | — | — | — | — |
| Sportmonks | Free chỉ Đan Mạch + Scotland — không đổi | — | — | — | — | — |

> **Không tìm được bằng chứng nào cho thấy 4 nguồn đã loại ở vòng trước đã đổi
> điều khoản.** Giữ nguyên quyết định loại.

---

## 2. Highlightly — ứng viên số 1

**Link**: https://highlightly.net/football-api/ · https://highlightly.net/terms/ ·
https://highlightly.net/documentation/football/

### 2.1 Điều khoản (trích nguyên văn)

Từ https://highlightly.net/terms/ :

> "Distribution, transfer, and storage of the data provided by the Service are
> allowed. You are free to use the data in your applications and products."

→ Đây là câu **quan trọng nhất**: cho phép **lưu trữ** (đúng kiến trúc Supabase
Postgres cache của ta) và **dùng trong sản phẩm** (không phân biệt thương mại
hay phi thương mại — khác hẳn football-data.org).

Các giới hạn (ta **không** vi phạm cái nào):

> "You may not resell, sublicense, or redistribute direct access to the API
> itself, or create a service that functions as a proxy or pass-through to the
> Highlightly API, without prior written permission."

> "You may not systematically extract or re-utilize the whole or a substantial
> part of the Company's database for the purpose of creating a competing
> service."

> "Using data obtained through the Service to operate, facilitate, or support any
> gambling, betting, wagering, lottery, or gaming operation." — **bị cấm**.

Về logo (giống mọi nhà cung cấp cấp 2, đã phân tích ở `research-football-api.md` §1):

> "For commercial use of visual content such as logos or images, it is your
> responsibility to verify that your use complies with applicable laws and to
> obtain any necessary permissions from the relevant organizations."

**Ghi công**: toàn bộ trang terms **không có** điều khoản bắt buộc attribution.

### 2.2 ⚠ Một câu mơ hồ PHẢI lưu ý

Ở mục 4.1 (Payment model) của terms có câu:

> "The 'free' or 'Basic' plan provides limited access and is not subject to the
> same terms as paid plans."

Câu này **không nói rõ điều khoản nào khác đi**. Đọc theo ngữ cảnh (nằm trong
mục *thanh toán*, ngay trước mục 4.2 về quota/rate limit), cách hiểu hợp lý nhất
là nó nói về **SLA / hoàn tiền / quota**, chứ không thu hồi quyền phân phối ở
mục 6.1. Nhưng đây **vẫn là rủi ro pháp lý chưa đóng**.

→ **Việc phải làm trước khi phát hành**: gửi email cho Highlightly hỏi đúng 1 câu:
*"Does the data distribution/storage right in §6.1 apply to the free Basic plan,
including use in a commercial application?"* — lưu lại email trả lời vào repo.
Nếu họ trả lời "không", phương án là nâng PRO **$9,49/tháng** (xem §6).

### 2.3 Cách lấy dữ liệu

```
GET https://soccer.highlightly.net/standings?leagueId=<id>&season=2026
Header: x-rapidapi-key: <API_KEY>   (hoặc header do dashboard cấp)
```

Response (rút gọn, theo tài liệu chính thức):

```json
{
  "league": { "id": 33973, "name": "Premier League", "season": 2026, "logo": "..." },
  "groups": [{
    "name": "Premier League",
    "standings": [{
      "position": 1,
      "points": 63,
      "team": { "id": 56950, "name": "Arsenal", "logo": "..." },
      "total": { "games": 17, "wins": 11, "draws": 4, "loses": 5,
                 "scoredGoals": 28, "receivedGoals": 27 },
      "home": { ... }, "away": { ... }
    }]
  }]
}
```

- **Đủ mọi cột đề bài yêu cầu**: `position`, `team.name`, `total.games`,
  `wins`, `draws`, `loses`, `scoredGoals`, `receivedGoals`, `points`.
  **Hiệu số phải tự tính** (`scoredGoals - receivedGoals`) — API không trả sẵn.
- **Không có phong độ 5 trận gần nhất** → nếu muốn, tự dựng từ bảng fixtures đã
  cache (API-Football live) hoặc từ openfootball.
- Cấu trúc `groups[]` xử lý được **vòng bảng / league phase của Champions League**.
- Tần suất làm mới của họ: *"up to an hour after a match for the associated
  league and season is finished"* → cập nhật 2 lần/ngày là thừa đủ.
- Quota BASIC: **100 request/ngày, không giới hạn rate**. Ta cần ~6–12/ngày → dư.

### 2.4 Rủi ro lớn nhất: bậc free có chặn mùa hiện tại không?

Tài liệu ghi: **"Some results might be hidden with FREE tier."** — câu này y hệt
kiểu mơ hồ đã khiến API-Football bậc Free vô dụng.

Tuy nhiên có 2 dấu hiệu tích cực:

1. Trang pricing liệt kê **cả 4 bậc dùng chung 950+ giải / 170+ quốc gia**, và
   ghi rõ tính năng "Standings" có ở **mọi bậc, kể cả BASIC**. Khác biệt được
   công bố giữa các bậc chỉ là: **số request/ngày**, **rate limit**, **odds
   endpoint** (chỉ trả phí) và **độ phủ video highlight** (free chỉ giải lớn).
2. **Không có** bất kỳ ghi chú nào về giới hạn **mùa giải** — trong khi
   API-Football nói thẳng "try from 2022 to 2024".

→ Nhưng vẫn **phải test thật**. Đây là việc đầu tiên khi triển khai:

```bash
# Đăng ký free tại https://highlightly.net → lấy key → chạy:
curl -H "x-rapidapi-key: $KEY" \
  "https://soccer.highlightly.net/leagues?limit=100&leagueName=Premier%20League"
# lấy leagueId, rồi:
curl -H "x-rapidapi-key: $KEY" \
  "https://soccer.highlightly.net/standings?leagueId=<id>&season=2026"
```

Nếu trả về BXH mùa 2026/27 → **xong, dùng Highlightly**. Nếu bị chặn mùa hiện
tại → rơi về §3 (openfootball) hoặc §6 (trả phí).

### 2.5 Độ tin cậy

- Công ty mới, không công bố độ trễ live, ít lịch sử vận hành (đã ghi nhận ở
  `research-football-api.md` §5). **Với riêng BXH thì rủi ro này thấp** — BXH là
  dữ liệu chậm, sai sót dễ phát hiện, và ta chỉ dùng nó như nguồn phụ.
- Nếu Highlightly chết, chuyển sang openfootball mất vài giờ code (cùng 1 bảng
  `standings` trong Postgres, chỉ đổi adapter).

---

## 3. openfootball / football.json — dự phòng miễn phí sạch 100% license

**Link**: https://github.com/openfootball · https://github.com/openfootball/football.json

### 3.1 License (không có gì để tranh cãi)

Toàn bộ repo dùng **CC0-1.0**:

> "The football.json schema, data and scripts are dedicated to the public domain.
> Use as you please with no restrictions whatsoever."

→ **Không ràng buộc thương mại, không bắt ghi công, cho lưu DB thoải mái.** Đây
là nguồn **sạch license nhất tuyệt đối** trong toàn bộ khảo sát — sạch hơn cả
mọi API trả phí.

### 3.2 Độ phủ mùa 2026/27 — đã xác minh thật (2026-09-20)

| Giải | Repo / đường dẫn | 2026/27 |
|---|---|---|
| Premier League | `openfootball/england` → `2026-27/1-premierleague.txt` | ✅ |
| La Liga | `openfootball/espana` → `2026-27/1-liga.txt` | ✅ |
| Serie A | `openfootball/italy` → `2026-27/1-seriea.txt` | ✅ |
| Bundesliga | `openfootball/deutschland` → `2026-27/1-bundesliga.txt` | ✅ |
| Ligue 1 | `openfootball/europe` → `france/2026-27_fr1.txt` | ✅ |
| **Champions League** | `openfootball/champions-league` | ❌ **chỉ tới 2025-26** |

→ **Thiếu UCL** (đề bài chấp nhận được, nhưng phải ghi nhận rõ).

Bản JSON tiện dùng hơn (khỏi parse Football.TXT):
`https://raw.githubusercontent.com/openfootball/football.json/master/2026-27/en.1.json`
(mã: `en.1`, `es.1`, `it.1`, `de.1`, `fr.1`).

Định dạng:

```json
{ "name": "English Premier League 2026/27",
  "matches": [
    { "round": "Matchday 1", "date": "2026-08-21", "time": "20:00",
      "team1": "Arsenal FC", "team2": "Coventry City FC",
      "score": { "ht": [2,0], "ft": [3,0] } }
  ] }
```

Trận chưa đá thì **không có trường `score`** → lọc rất dễ.

### 3.3 ⚠ Điểm yếu quyết định: cập nhật CHỈ 1 LẦN/TUẦN

Lịch sử commit thật của `england/2026-27/1-premierleague.txt`:

| Ngày commit | Message |
|---|---|
| 2026-09-18 | auto-update week 38 |
| 2026-09-08 | auto-update week 37 |
| 2026-09-01 | auto-update week 36 |
| 2026-08-25 | auto-update week 35 |
| 2026-08-23 | auto-update week 34 |

Kiểm tra nội dung file ngày 2026-09-20: **có tỉ số tới hết Matchday 4
(12–14/9)**, Matchday 5 (18–20/9) **chưa có tỉ số**.

→ **BXH tính từ openfootball sẽ trễ 2–7 ngày.** Repo `football.json` tự build
mỗi ngày 5h UTC nhưng **nguồn thượng nguồn vẫn chỉ đổi mỗi tuần**, nên build
hằng ngày không cứu được độ trễ.

Đây là lý do openfootball **không** được chọn làm nguồn chính: hiển thị một BXH
trễ cả tuần trong app là lỗi người dùng nhìn thấy ngay.

**Cách giảm thiểu nếu buộc phải dùng**: ghép openfootball (nền) + kết quả trận
lấy từ `/fixtures?live=all` và `/fixtures?date=` của API-Football (cửa sổ ±1
ngày, ta vẫn cache lại hằng ngày vào Postgres) → dần dần bảng fixtures nội bộ đủ
mọi trận trong mùa kể từ ngày bật hệ thống, dùng để **vá phần trễ** của
openfootball. Sau ~1 tuần chạy, ta tự có dữ liệu trận đầy đủ và không còn phụ
thuộc độ trễ upstream.

---

## 4. Football-Data.co.uk — LOẠI vì license mù mờ

**Link**: https://www.football-data.co.uk/ · https://www.football-data.co.uk/notes.txt

- Có CSV kết quả trận cho **England, Spain, Italy, Germany, France** (+20 nước
  khác), cập nhật 2 lần/tuần (thứ Sáu và thứ Ba). **Không có UCL.**
- Cột: `Div, Date, Time, HomeTeam, AwayTeam, FTHG, FTAG, FTR, HTHG, HTAG, HTR`
  + thống kê + odds. Đủ để tự tính BXH.
- **Vấn đề**: trang chủ chỉ ghi `"© Football-Data. Liability Disclaimer. All
  Rights Reserved."` Trang `disclaimer.php` chỉ nói về **trách nhiệm pháp lý khi
  cá cược**, hoàn toàn **không có** điều khoản về quyền sử dụng lại / thương mại /
  redistribution.
- "All Rights Reserved" + không có license = **mặc định là KHÔNG có quyền**.

→ **Loại.** Đây đúng kiểu bẫy "miễn phí tải về nhưng không cấp quyền" — trái với
quy tắc bắt buộc trong CLAUDE.md. Lợi thế duy nhất của nó (cập nhật 2 lần/tuần)
cũng không hơn openfootball là bao, trong khi openfootball có CC0 rõ ràng.

---

## 5. Wikipedia — dùng được thương mại nhưng share-alike là cái bẫy

**Link**: https://en.wikipedia.org/wiki/Wikipedia:Reusing_Wikipedia_content ·
https://creativecommons.org/licenses/by-sa/4.0/deed.en

Văn bản Wikipedia hiện dùng **CC BY-SA 4.0**, cho phép "adapt, remix, transform,
and build upon the material for any purpose, **even commercially**". Bài mùa
giải (vd `2026–27 Premier League`) có sẵn bảng xếp hạng đầy đủ, cập nhật nhanh
gần như realtime, và **có cả UCL**.

Nhưng có 2 vấn đề:

1. **Nghĩa vụ share-alike**: nếu coi bảng BXH là "tác phẩm" được CC BY-SA bảo
   hộ, thì sản phẩm phái sinh phải phát hành **dưới cùng giấy phép CC BY-SA**.
   Với một app đóng thì đây là nghĩa vụ rất khó chịu (dù thực tế chỉ ràng buộc
   phần nội dung đó, không phải toàn bộ code — nhưng ranh giới mù mờ).
   - Lập luận ngược: **dữ kiện (facts) không có bản quyền**. Điểm số, số bàn
     thắng, thứ hạng là facts thuần tuý. Nếu ta chỉ lấy **số liệu** rồi tự dựng
     lại bảng theo layout riêng (không copy văn bản, không copy chú thích), thì
     nhiều khả năng **không phát sinh nghĩa vụ CC BY-SA** nào cả. Tuy nhiên đây
     là **suy luận pháp lý, không phải điều khoản** — CLAUDE.md cấm suy diễn
     kiểu này khi có lựa chọn an toàn hơn.
2. **Độ bền kỹ thuật kém**: phải scrape HTML/wikitext. Template bảng BXH
   (`{{fb cl team}}`) đổi bất cứ lúc nào, và mỗi giải một kiểu. Bảo trì tốn kém,
   dễ vỡ im lặng (silent failure) — kiểu lỗi tệ nhất cho dữ liệu hiển thị.
   Nếu dùng, phải qua **MediaWiki API** (`action=parse&prop=wikitext`) chứ không
   scrape HTML render, và có **User-Agent định danh** theo policy của Wikimedia.

→ **Không đề xuất.** Chỉ giữ làm phương án cuối, và nếu dùng thì bắt buộc:
ghi ở màn About *"Standings data from Wikipedia, licensed under CC BY-SA 4.0"* +
link tới `https://creativecommons.org/licenses/by-sa/4.0/` + link bài gốc từng
giải, và nêu rõ đã có chỉnh sửa.

---

## 6. Nếu nguồn là dataset kết quả trận: thuật toán tự tính BXH

Áp dụng khi dùng openfootball (§3) hoặc dữ liệu fixtures tự cache.

### 6.1 Bước cơ bản (chung cho mọi giải)

Với mỗi đội, duyệt toàn bộ trận **đã có tỉ số** trong mùa:

```
played  += 1
gf      += bàn đội này ghi
ga      += bàn đội này thủng
if gf_match > ga_match: won += 1;   points += 3
elif ==:                drawn += 1; points += 1
else:                   lost += 1
gd = gf - ga
```

Phong độ 5 trận gần nhất: sắp trận đã đá theo `date` giảm dần, lấy 5 trận đầu,
map thành `W/D/L`.

**Lưu ý bắt buộc**:
- Chỉ tính trận có trường `score.ft` — bỏ qua trận chưa đá/hoãn.
- **Điểm trừ hành chính**: openfootball KHÔNG chứa thông tin đội bị trừ điểm
  (ví dụ vi phạm tài chính — đã từng xảy ra với Everton, Nottingham Forest,
  Juventus). Phải có bảng `manual_point_adjustments` trong Postgres để chỉnh tay,
  nếu không BXH sẽ **sai so với thực tế** dù thuật toán đúng.
- Chuẩn hoá tên đội: openfootball dùng tên dài ("Manchester United FC"),
  API-Football dùng tên khác ("Manchester United"). Phải có **bảng ánh xạ tên đội**
  giữa 2 nguồn, nếu không ghép dữ liệu sẽ tạo đội trùng lặp.

### 6.2 Quy tắc xếp hạng phụ (tie-break) — KHÁC NHAU TỪNG GIẢI

Đây là chỗ dễ làm sai nhất. **Không được dùng chung một hàm sort cho cả 6 giải.**

| Giải | Thứ tự tie-break sau khi bằng điểm |
|---|---|
| **Premier League** | 1. Hiệu số (GD) → 2. Bàn thắng ghi được → 3. *Nếu vẫn bằng: xếp đồng hạng*; chỉ khi liên quan vô địch / xuống hạng / suất cúp châu Âu mới đá play-off trên sân trung lập. **KHÔNG dùng đối đầu trực tiếp.** |
| **La Liga** | 1. **Đối đầu trực tiếp**: điểm trong các trận giữa các đội đang bằng điểm → 2. Hiệu số đối đầu trực tiếp → 3. Hiệu số toàn giải → 4. Bàn thắng ghi được toàn giải → 5. Điểm fair-play. *Lưu ý: đối đầu trực tiếp chỉ áp dụng khi cả 2 lượt đã đá xong.* |
| **Serie A** | 1. **Đối đầu trực tiếp** (mini-league giữa các đội bằng điểm: điểm → hiệu số trong mini-league) → 2. Hiệu số toàn giải → 3. Bàn thắng ghi được → 4. Bốc thăm. |
| **Bundesliga** | 1. Hiệu số toàn giải → 2. Bàn thắng ghi được → 3. Điểm đối đầu trực tiếp → 4. Hiệu số đối đầu trực tiếp → 5. Bàn thắng sân khách trong trận đối đầu → 6. Bàn thắng sân khách toàn giải → 7. Play-off. |
| **Ligue 1** | 1. Hiệu số toàn giải → 2. Bàn thắng ghi được toàn giải. (LFP dùng hiệu số toàn giải trước, **không** ưu tiên đối đầu trực tiếp.) |
| **UCL — league phase** (thể thức mới từ 2024/25, bảng duy nhất 36 đội) | 1. Hiệu số → 2. Bàn thắng ghi được → 3. Số trận thắng → 4. Điểm kỷ luật (thẻ) → 5. Hệ số CLB châu Âu. **Không dùng đối đầu trực tiếp** (vì mỗi đội đá 8 đối thủ khác nhau). |

**Hệ quả kỹ thuật**: 3 giải (La Liga, Serie A, Bundesliga) cần **tính mini-league
đối đầu trực tiếp** giữa nhóm đội bằng điểm → thuật toán phải:
1. Nhóm các đội có cùng điểm.
2. Với nhóm ≥2 đội, dựng bảng con chỉ từ các trận giữa chính các đội đó.
3. Sắp trong nhóm theo quy tắc riêng của giải, rồi ghép lại.

Nếu chỉ sort đơn giản `points DESC, gd DESC, gf DESC` thì **BXH La Liga và Serie A
sẽ sai** mỗi khi có 2 đội bằng điểm — tình huống xảy ra thường xuyên.

→ Đây là một **lý do kỹ thuật mạnh để ưu tiên nguồn có sẵn BXH (Highlightly)**
thay vì tự tính: nhà cung cấp đã xử lý đúng tie-break từng giải rồi.

---

## 7. So sánh chi phí (trường hợp phải trả tiền)

| Phương án | Giá | Được gì |
|---|---|---|
| Giữ API-Football Free (live) + **Highlightly BASIC** (BXH) | **$0** | Đúng mục tiêu. Rủi ro: chưa test mùa hiện tại + câu mơ hồ ở §2.2 |
| Giữ API-Football Free (live) + **openfootball** (BXH) | **$0** | License sạch tuyệt đối nhưng BXH trễ 2–7 ngày, thiếu UCL, phải tự code tie-break 6 kiểu |
| Giữ API-Football Free + **Highlightly PRO** | **$9,49/tháng** | 7.500 req/ngày, gỡ mọi giới hạn coverage, điều khoản paid-plan rõ ràng 100% |
| **Nâng API-Football lên Pro** (bỏ luôn nguồn thứ hai) | **$19/tháng** | 1 nguồn duy nhất cho cả live + BXH + lineup + statistics. Kiến trúc đơn giản nhất |

Nhận xét quan trọng: **Highlightly PRO $9,49/tháng rẻ hơn một nửa API-Football
Pro $19/tháng** (giá đã kiểm tra lại 2026-09-20 — rẻ hơn con số $19 ghi ở
`research-football-api.md`, họ đã giảm giá). Nếu có ngày phải trả tiền, đáng cân
nhắc lại **toàn bộ** bài toán: Highlightly PRO có đủ live scores + standings +
lineups + live events + match statistics + player data ở $9,49, tức có thể thay
API-Football Pro luôn và tiết kiệm 50%. Nhưng đó là quyết định của
`research-football-api.md`, không phải tài liệu này.

---

## 8. KẾT LUẬN THẲNG

**Có nguồn sạch license. Đề xuất: Highlightly bậc BASIC (miễn phí).**

Lý do, theo đúng thứ tự tiêu chí bắt buộc của đề bài:

1. **Thương mại ở bậc free: ĐƯỢC.** ToS nói tường minh "You are free to use the
   data in your applications and products", không hề phân biệt thương mại /
   phi thương mại. Đây là khác biệt cốt lõi so với football-data.org.
2. **Cho lưu DB riêng: ĐƯỢC, tường minh.** "storage of the data provided by the
   Service are allowed" — khớp chính xác kiến trúc Edge Function + Postgres.
3. **Đủ 6 giải, có `/standings` ở bậc BASIC**, cấu trúc `groups[]` xử lý được cả
   league phase của UCL.
4. **Không bắt buộc ghi công.** (Vẫn nên ghi "Standings data by Highlightly" ở
   màn About cho đẹp và để dễ giải trình, nhưng không phải nghĩa vụ.)
5. Quota 100 req/ngày ≫ nhu cầu ~6–12 req/ngày của ta.

**Hai việc phải làm trước khi tin tưởng hoàn toàn** (đừng bỏ qua — đây đúng là
chỗ API-Football đã làm ta mất công vòng trước):

- [ ] **Test thật** với key BASIC: `GET /standings?leagueId=<PL>&season=2026`.
      Xác nhận trả về BXH mùa 2026/27 chứ không bị chặn như API-Football.
- [ ] **Email hỏi Highlightly** làm rõ câu §2.2 ("free plan … not subject to the
      same terms"), lưu câu trả lời vào repo.

**Dự phòng nếu 1 trong 2 việc trên cho kết quả xấu**: **openfootball
(`football.json`, CC0)**. License sạch tuyệt đối, không thể bị thu hồi, nhưng
phải chấp nhận (a) BXH trễ 2–7 ngày — vá bằng fixtures tự cache từ
`/fixtures?date=` của API-Football, (b) **không có UCL**, (c) phải tự code
tie-break riêng cho từng giải theo §6.2.

**Không đề xuất**: Football-Data.co.uk (không có license = không có quyền),
Wikipedia (share-alike + scrape mong manh).

---

## 9. Chưa xác minh được — cần kiểm tra tay

- **Highlightly `/standings` với `season=2026` ở bậc BASIC** — chưa có key, chưa
  test. **Đây là giả định lớn nhất của cả tài liệu này.**
- `leagueId` thật của 6 giải trên Highlightly (phải gọi `/leagues` để lấy).
- Ý nghĩa chính xác của "Some results might be hidden with FREE tier" trong tài
  liệu Highlightly.
- Highlightly có trả phong độ 5 trận gần nhất không (tài liệu không nhắc).
- Trang `highlightly.net/football-api/coverage/` trả 404 — không có danh sách
  giải chính thức để đối chiếu.

## Nguồn tham khảo

- Highlightly — Football API: https://highlightly.net/football-api/
- Highlightly — Terms: https://highlightly.net/terms/
- Highlightly — Documentation (Football): https://highlightly.net/documentation/football/
- openfootball (tổ chức GitHub): https://github.com/openfootball
- openfootball/football.json (CC0, JSON): https://github.com/openfootball/football.json
- openfootball/england 2026-27: https://github.com/openfootball/england/tree/master/2026-27
- openfootball/champions-league (chỉ tới 2025-26): https://github.com/openfootball/champions-league
- Football-Data.co.uk: https://www.football-data.co.uk/ · notes: https://www.football-data.co.uk/notes.txt
- Wikipedia — Reusing Wikipedia content: https://en.wikipedia.org/wiki/Wikipedia:Reusing_Wikipedia_content
- CC BY-SA 4.0 deed: https://creativecommons.org/licenses/by-sa/4.0/deed.en
- Tài liệu liên quan trong dự án: `docs/research-football-api.md`
