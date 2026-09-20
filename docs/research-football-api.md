# Nghiên cứu API dữ liệu bóng đá (tính năng Football Center)

Football Center cần: lịch thi đấu, BXH đầy đủ (ST/T/H/B/BT/BB/HS/Đ + phong độ 5
trận, hỗ trợ bảng & knockout của Champions League), kết quả, **live** (tỉ số +
phút + sự kiện: bàn thắng/kiến tạo/thẻ/thay người/penalty/VAR), thống kê trận
(possession, shots, SOT, corners, fouls, offsides, passes, pass accuracy,
saves), đội hình (formation, XI, dự bị, vị trí, số áo) và logo đội/giải, cho 6
giải: Premier League, La Liga, Serie A, Bundesliga, Ligue 1, UEFA Champions
League (mở rộng Europa/Conference sau).

Kiến trúc đã chốt: **app không gọi API trực tiếp**. Supabase Edge Function
(Deno) giữ key, poll → cache vào Postgres → client chỉ đọc bảng đã đồng bộ +
nhận push. Quota là của backend, dùng chung cho toàn bộ người dùng (không nhân
theo user). Vì vậy hai tiêu chí quan trọng nhất khi chọn nguồn là:

1. **Có được phép lưu dữ liệu vào database riêng không** (rất nhiều API thể
   thao cấm cache lâu dài — đây là điểm dễ vi phạm nhất với kiến trúc này).
2. **Bậc free có được dùng thương mại không** (bài học Jamendo: "miễn phí"
   thường chỉ có nghĩa là "miễn phí cho phi thương mại").

## Bảng tổng hợp so sánh

| Nguồn | Free tier | Thương mại ở bậc free? | Cho lưu vào DB riêng? | Bậc cần cho kịch bản của ta | Giá | Đủ 6 giải? | Live | Lineup + Stats |
|---|---|---|---|---|---|---|---|---|
| **API-Football / API-Sports** (đề xuất chính) | 100 req/ngày, 10 req/phút, giới hạn mùa giải | Không cấm tường minh, nhưng quota 100/ngày vô dụng cho production | **Có** — ToS cho "distribution, transfer and storage of the data"; chính họ hướng dẫn cache | **Pro** | **$19/tháng** (7.500 req/ngày, 300 req/phút) | Có, mọi bậc trả phí mở toàn bộ 1.200+ giải | Cập nhật **15 giây** | Có: `/fixtures/lineups`, `/fixtures/statistics`, `/fixtures/events` |
| **football-data.org** (đề xuất dự phòng) | 12 giải (đủ 6 giải ta cần), 10 req/phút | **KHÔNG** — free tier chỉ cho phi thương mại | Không có điều khoản cấm; bắt buộc **ghi công** "Data provided by football-data.org" | Free + Deep Data (€29) + Statistics add-on (€15) | **~€44/tháng** (30 req/phút) | Có ở ngay gói free 12 giải | Free: **delayed**; có live từ gói €12 | Lineup/sự kiện = add-on Deep Data; thống kê = add-on riêng |
| **Sportmonks** | Chỉ 2 giải (Đan Mạch + Scotland) | Không áp dụng (free tier không có 6 giải ta cần) | **Có, tường minh nhất trong nhóm** — cho lưu/phân phối trong sản phẩm của mình | Growth (Starter 5 giải không đủ 6) | **€99/tháng** (3.000 call/giờ) | Starter €29 chỉ 5 giải → phải lên Growth €99/30 giải | Latency < 15 giây | Có, mô hình dữ liệu sâu nhất |
| **TheSportsDB** | Test key, 30 req/phút, endpoint hạn chế | **KHÔNG** — cấm publish lên app store nếu không trả phí | Cho "scrape, copy and modify" nội dung trả về qua endpoint chính thức | Premium | **$9/tháng** (rẻ nhất) | Có metadata + artwork, nhưng dữ liệu cộng đồng | Livescore refresh **~2 phút** (chậm) | Yếu/không ổn định cho thống kê chi tiết |
| **SoccersAPI** | 3 giải, 100 req/giờ | **KHÔNG** | ToS cấm "reproduce, display, publicly perform, distribute... for any public or commercial purpose" | — | $39–$279/tháng | — | — | **LOẠI** vì điều khoản |
| **Highlightly** | 100 req/ngày | Cho phép ("free to use the data in your applications and products") | **Có** — "Distribution, transfer, and storage of the data provided by the Service are allowed" | Pro | $19/tháng (cùng khung giá API-Football) | 950+ giải | Không công bố độ trễ | Có lineups + statistics + predictions + highlights video | 
| **apifootball.com** (khác API-Football!) | Có | **KHÔNG** — ToS ghi rõ "solely provided for personal, non-commercial use" | — | — | — | — | — | **LOẠI** vì điều khoản |
| Sportradar / SportsDataIO | Trial | — | Hợp đồng riêng | Enterprise | **$500+/tháng** | Có, chính thống (đối tác UEFA) | Realtime push | Đầy đủ | **LOẠI** vì giá |

> **Cảnh báo dễ nhầm**: `api-football.com` (của API-Sports, Pháp) và
> `apifootball.com` là **hai dịch vụ khác nhau**. Cái thứ hai có ToS cấm
> thương mại rõ ràng. Đừng nhầm khi đăng ký.

---

## 1. API-Football / API-Sports (`api-sports.io`) — ĐỀ XUẤT CHÍNH

**Link**: https://www.api-football.com/pricing · https://api-sports.io/terms ·
https://api-sports.io/documentation/football/v3

### Thương mại & redistribution

ToS của API-Sports **không cấm dùng thương mại**, nhưng có một đoạn quan trọng
phải hiểu đúng (trích ý từ trang `api-sports.io/terms`, xem mục "Chưa xác minh
được" bên dưới):

> API-SPORTS **không cấp bất kỳ quyền thương mại nào đối với bản thân các giải
> đấu** ("does not grant any commercial rights on competitions"). Việc dùng dữ
> liệu cho nền tảng cá cược, phát sóng truyền hình, fantasy sports, hoặc phân
> phối đại chúng (mass media) **có thể cần giấy phép bổ sung từ chủ sở hữu
> quyền**. Người dùng có trách nhiệm tự xác minh và xin các giấy phép cần
> thiết.

Nghĩa là: họ bán cho ta **quyền truy cập dữ liệu**, không bán **quyền khai thác
giải đấu**. Với một app học tiếng Anh hiển thị tỉ số/BXH cho người dùng cuối,
đây là mức rủi ro thấp (dữ liệu tỉ số/lịch thi đấu là facts, không có bản quyền
ở hầu hết các nước; rủi ro thật chỉ phát sinh nếu làm cá cược hoặc phát sóng).
Đây cũng là điều khoản **giống hệt** với mọi nhà cung cấp cấp 2 khác trong bảng
— không có nguồn giá rẻ nào cấp quyền giải đấu cả.

Về **lưu trữ**: đây là điểm mạnh nhất của API-Football với kiến trúc của ta.
Điều khoản cho phép "distribution, transfer and storage of the data provided by
the Service", chỉ cấm **bán lại** (re-selling) sản phẩm dữ liệu khi chưa xin
phép. Chính tài liệu hướng dẫn của họ khuyến nghị: gọi một lô nhỏ các endpoint
tham chiếu (leagues, teams, venues) rồi **lưu vào database/cache riêng**, sau đó
chỉ còn gọi live → đúng y kiến trúc Edge Function + Postgres của dự án.

**Không có yêu cầu ghi công (attribution) bắt buộc.**

### Logo / hình ảnh — điểm license riêng, PHẢI đọc kỹ

API trả về URL ảnh trên CDN của họ (`media.api-sports.io/football/teams/<id>.png`,
`.../leagues/<id>.png`). Nhưng điều khoản nói rõ:

> Toàn bộ logo/hình ảnh/video thuộc bản quyền của chủ sở hữu hợp pháp; API chỉ
> cung cấp **nguồn** (sources). Để hiển thị các nội dung này trong app/website,
> bạn phải tự đảm bảo việc sử dụng tuân thủ khung pháp lý và **tự lo phần chứng
> minh quyền sở hữu trí tuệ**.

→ **API-Football KHÔNG cấp quyền dùng logo CLB.** Logo Manchester United,
Real Madrid, logo Premier League/UEFA là **nhãn hiệu đã đăng ký** của các CLB
và ban tổ chức, không nhà cung cấp API nào (kể cả Sportradar) bán lại được
quyền đó.

Khuyến nghị thực tế cho Football Center:
- **Hotlink** từ CDN của nhà cung cấp, không tự host lại logo (tự host = tự tạo
  bản sao, khó biện minh hơn; hotlink giữ nguyên trạng "chỉ hiển thị nguồn do
  nhà cung cấp trỏ tới").
- Dùng logo **chỉ với mục đích định danh** (nominative fair use): nhận diện đội
  nào đá với đội nào — không dùng làm logo app, banner quảng cáo, merchandising,
  hay bất cứ thứ gì gợi ý được CLB/giải đấu bảo trợ.
- Có sẵn **fallback không-logo**: khi không tải được ảnh hoặc khi phải gỡ theo
  yêu cầu, hiển thị viết tắt tên đội trong ô màu (ví dụ "MUN", "RMA") — thiết kế
  UI phải chịu được trường hợp này ngay từ đầu, đừng để vỡ bố cục.
- Ghi nguồn logo/dữ liệu ở màn About như dự án vẫn làm với `ATTRIBUTION.md`.

### Giá & quota

| Bậc | Giá | Req/ngày | Req/phút | Ghi chú |
|---|---|---|---|---|
| Free | $0 | **100** | **10** | Giới hạn mùa giải (không có đầy đủ mùa hiện tại) |
| **Pro** | **$19/tháng** | **7.500** | **300** | Mở toàn bộ giải + toàn bộ endpoint |
| Ultra | $29/tháng | 75.000 | 450 (chưa xác minh) | |
| Mega | $39/tháng | 150.000 | 900 | |

Mọi bậc trả phí đều mở **toàn bộ** endpoint và toàn bộ 1.200+ giải — không có
tính năng nào bị khoá sau paywall riêng (khác hẳn football-data.org và
Sportmonks vốn bán lineup/statistics/giải theo gói). Hết quota thì API trả lỗi
chứ **không tính phí vượt** (prepaid, không auto-renew).

### Độ phủ & dữ liệu

- Đủ 6 giải + Europa/Conference/World Cup ở mọi bậc trả phí.
- `/fixtures` và `/fixtures/events` **cập nhật mỗi 15 giây** — đủ nhanh cho
  live polling 60 giây của ta.
- `/fixtures?live=all` trả **toàn bộ trận đang đá trên mọi giải trong 1 lần
  gọi** — đây là chi tiết quyết định toàn bộ bài toán quota (xem §6).
- `/fixtures/lineups` (formation, XI, dự bị, vị trí, số áo),
  `/fixtures/statistics` (possession, shots, SOT, corners, fouls, offsides,
  passes, pass accuracy, saves), `/fixtures/events` (bàn thắng + người ghi bàn
  + kiến tạo, thẻ, thay người, penalty, VAR), `/standings` (BXH, hỗ trợ cấu
  trúc group của Champions League), `/fixtures/headtohead`.
- Điểm yếu đã được nhiều bài so sánh ghi nhận: **chất lượng dữ liệu không đều ở
  các giải ngoài top 5 châu Âu**. Với phạm vi 6 giải của ta thì không phải vấn
  đề.

### Rủi ro

- Là nhà cung cấp cấp 2 (không có hợp đồng chính thức với UEFA/các giải) → nếu
  có tranh chấp quyền dữ liệu ở thượng nguồn, dịch vụ có thể gián đoạn.
- Trang web chặn bot khá gắt (Cloudflare) — không ảnh hưởng API nhưng gây khó
  khi đọc ToS tự động (xem mục cuối).

---

## 2. football-data.org — ĐỀ XUẤT DỰ PHÒNG

**Link**: https://www.football-data.org/pricing ·
https://docs.football-data.org/general/v4/policies.html

### Thương mại & attribution

Điểm chí tử: **bậc free chỉ cho phép dùng phi thương mại**. Đây đúng là kiểu
bẫy Jamendo mà CLAUDE.md cảnh báo. Muốn dùng thương mại → bắt buộc trả phí.

Attribution **bắt buộc ở mọi bậc**:

> "Data provided by football-data.org" — phải đặt ở một khu vực nhìn thấy được
> của app/website (footer, About us hoặc vị trí tương đương).

Không tìm thấy điều khoản cấm cache/lưu trữ vào DB riêng.

### Giá & quota

| Bậc | Giá | Req/phút | Số giải | Nội dung |
|---|---|---|---|---|
| Free | €0 | 10 | 12 (có đủ 6 giải ta cần) | Tỉ số **delayed**, fixtures, BXH. **Phi thương mại** |
| Free + Livescores | €12/tháng | 20 | 12 | Thêm live score |
| Free + Deep Data | €29/tháng | 30 | 12 | Live + **Line-ups & Subs, Goal scorers, Bookings/Cards, Squads** |
| Standard | €49/tháng | 60 | 30 | |
| Advanced | €99/tháng | 100 | 50 | |
| Pro | €199/tháng | 120 | 100 | |
| Add-on Statistics | **+€15/tháng** | — | — | Corners, free-kicks, goal-kicks, offsides, fouls, possession, saves, throw-ins, shots on/off, cards |
| Add-on Odds | +€15/tháng | — | — | Không cần cho dự án |

Lưu ý: giới hạn là **req/phút**, không có trần theo ngày công bố — ngược hẳn
với API-Football. Điều này lại hợp với mô hình backend poll đều đặn của ta.

**Để đủ tính năng ta cần**: Free + Deep Data (€29) + Statistics add-on (€15) =
**€44/tháng ≈ $48**, tức **đắt hơn 2,5 lần** API-Football Pro mà lại ít dữ liệu
hơn (không có thay người chi tiết/VAR ở mức tương đương, không có số áo/vị trí
chi tiết như `/fixtures/lineups`).

### Ưu điểm để làm dự phòng

- Vận hành ổn định từ 2013, tác giả cam kết giữ 12 giải cơ bản miễn phí vĩnh
  viễn → nguồn **đối chiếu/kiểm tra chéo** rất tốt.
- 12 giải free trùng khớp gần như hoàn hảo với 6 giải của ta + Eredivisie,
  Primeira Liga, Championship, Brazil Serie A, World Cup, Euro.
- Mô hình dữ liệu sạch, tài liệu rõ.

**Cách dùng đúng trong dự án**: để ở chế độ chờ (đã viết adapter, chưa bật).
Nếu API-Football hỏng/tăng giá/ngừng, bật lên ở gói €29+€15. **Không** dùng bậc
free của football-data.org trong bản phát hành vì app có yếu tố thương mại.

---

## 3. Sportmonks — điều khoản tốt nhất, giá không hợp

**Link**: https://www.sportmonks.com/terms-of-service/ ·
https://www.sportmonks.com/football-api/plans-pricing/

Điều khoản rõ ràng và thân thiện nhất trong toàn bộ khảo sát:

> "If you use our data to create something based on our data and start earning
> money from your creation, everything is fine."
>
> "Reselling Sportmonks' data without approval is not allowed. This means that
> you cannot directly sell the data we provide."

Cho phép tường minh: lưu vào database riêng, hiển thị cho người dùng cuối trong
giao diện của mình, trên bất kỳ stack nào gọi được HTTP. Chỉ cấm **bán lại dữ
liệu như dữ liệu** và **redistribute dạng feed** (feed cần duyệt bằng văn bản).
Họ cũng nói rõ không nhận dữ liệu gì về end-user của ta (tốt cho quyền riêng
tư).

Về logo — cùng kết luận như API-Football, nhưng viết thẳng thắn hơn:

> "All logos and profile photos are copyrighted by their legal owner. To display
> these types of content in your app or website, you have to arrange proof of
> intellectual property yourself."
>
> "Clearly attribute the logos and photos to their respective owners. Include
> appropriate credits or acknowledgements within your app."

**Vì sao không chọn**: free tier chỉ có Danish Superliga + Scottish Premiership
(vô dụng với ta). Starter €29 chỉ **5 giải** — ta cần 6 (5 giải quốc nội + UCL)
→ phải lên **Growth €99/tháng** (30 giải). Gấp 5 lần API-Football Pro cho cùng
một nhu cầu. Rate limit thì rất thoáng: **3.000 call/giờ per entity**.

(Ghi chú mâu thuẫn chưa gỡ được: một trang marketing của Sportmonks nói "plans
scale by request volume and data depth, not by competition", trong khi trang
giá lại liệt kê số giải theo gói. Nếu có lúc nào cần cân nhắc lại Sportmonks,
phải hỏi sales xác nhận UCL có nằm trong Starter €29 không — nếu có thì
Sportmonks đáng chọn hơn hẳn nhờ điều khoản.)

---

## 4. TheSportsDB — rẻ nhất, nhưng không đủ sâu cho live

**Link**: https://www.thesportsdb.com/pricing ·
https://www.thesportsdb.com/docs_terms_of_use.php

- **$9/tháng** (qua Patreon) — rẻ nhất tuyệt đối, mở V2 API + livescore.
- **Bậc free KHÔNG dùng được cho app này**: ToS ghi rõ *"You cannot publish apps
  to an appstore unless you are a paid subscriber."* Dù ta sideload APK (không
  qua Play) thì tinh thần điều khoản vẫn là phân phối công khai = phải trả phí.
- Cho phép rộng rãi việc lưu trữ/xử lý: *"You can scrape, copy and modify any
  content returned from the API, as long as you use the official end points."*
- Bắt buộc ghi công + link về website.
- **Artwork là thế mạnh**: logo/badge/ảnh sân vận động do cộng đồng tạo, nhiều
  mục có trường `strCreativeCommons` cho biết giấy phép. Đây là nguồn ảnh **an
  toàn pháp lý hơn** logo chính chủ — nhưng chú ý: mục nào `strCreativeCommons`
  là "Unknown" hoặc trống thì **không được dùng công khai**. Logo có nhãn hiệu
  thì tuyệt đối không được sửa đổi.
- **Điểm chết**: livescore chỉ refresh **~2 phút**, và dữ liệu do cộng đồng
  đóng góp nên độ chính xác/đầy đủ của thống kê trận và đội hình không đủ tin
  cậy cho production.

**Cách dùng đúng**: không làm nguồn chính, nhưng **rất đáng cân nhắc làm nguồn
ảnh/metadata bổ sung** (badge CC, ảnh sân, mô tả CLB) cho phần trang trí UI của
Football Center, với $9/tháng.

---

## 5. Các nguồn đã loại

| Nguồn | Lý do loại |
|---|---|
| **SoccersAPI** | ToS cấm thẳng: *"You may not sell or modify the Material or reproduce, display, publicly perform, distribute, or otherwise use the Material in any way for any public or commercial purpose"* và *"all data obtained through the service remains the intellectual property of SoccersAPI"*, kèm quyền đơn phương huỷ dịch vụ nếu *"Client resells or redistributes our data without our consent"*. Với một app hiển thị dữ liệu cho người dùng cuối, điều khoản này **mâu thuẫn trực tiếp** với mục đích sử dụng. Giá cũng cao ($39–$279). |
| **apifootball.com** | *"solely provided for personal, non-commercial use"*. Loại. |
| **Sportradar** | Nguồn chính thống nhất (đối tác UEFA), realtime push, nhưng mô hình B2B hợp đồng, $500+/tháng. Ngoài tầm. |
| **SportsDataIO** | $99–$149/tháng cho Discovery Lab, bóng đá là mảng phụ (UCL chỉ có trong trial), bậc thấp là dữ liệu trễ đến hôm sau. |
| **Highlightly** | Điều khoản **tốt** (*"Distribution, transfer, and storage of the data provided by the Service are allowed. You are free to use the data in your applications and products."*, không bắt attribution, giá $19/$29/$39 trùng khung API-Football). Chỉ cấm làm proxy/pass-through bán lại API và trích xuất DB để làm dịch vụ cạnh tranh — ta không vi phạm. **Không loại hẳn**, nhưng là công ty mới, không công bố độ trễ live, ít lịch sử vận hành hơn API-Football → xếp sau. Nếu API-Football có sự cố, đây là ứng viên thay thế thứ hai sau football-data.org. |
| **FotMob / SofaScore / LiveScore (API nội bộ)** | Không có ToS cho phép, phải reverse-engineer. Rủi ro pháp lý + kỹ thuật cao, đúng như bài học `vnstock`/Simplize ở `docs/research-wealth-stock-apis.md`. Không dùng. |
| **OpenLigaDB / openfootball** | Miễn phí thật, open data, nhưng chỉ mạnh ở Bundesliga / dữ liệu tĩnh, không có live + thống kê trận. Không đáp ứng yêu cầu. |

---

## 6. Tính toán quota cho kịch bản thực tế

**Kịch bản đề bài**: 6 giải; cuối tuần 8–10 trận/ngày; live polling 60 giây/trận
trong 2 giờ; dò lineup 5 phút/lần trong 60 phút trước trận; đồng bộ fixtures
1 lần/ngày; BXH 2 lần/ngày.

### Cách tính ngây thơ (1 call/trận/lần poll)

| Tác vụ | Phép tính | Call/ngày |
|---|---|---|
| Live score + sự kiện | 10 trận × 120 lần (2h, mỗi 60s) | **1.200** |
| Thống kê trận (5 phút/lần) | 10 trận × 24 lần | 240 |
| Lineup (5 phút/lần, 60 phút trước trận) | 10 trận × 12 lần | 120 |
| Fixtures | 6 giải × 1 | 6 |
| BXH | 6 giải × 2 | 12 |
| **Tổng** | | **≈ 1.578 call/ngày** |

### Cách tính tối ưu (dùng `/fixtures?live=all`)

API-Football có `/fixtures?live=all` trả **toàn bộ trận đang đá trên mọi giải
trong MỘT lần gọi**. Trận đấu cuối tuần trải ra khoảng 8 giờ/ngày (từ trận sớm
Ngoại hạng tới trận muộn La Liga), nên chỉ cần poll 1 lần/phút liên tục trong
cửa sổ đó:

| Tác vụ | Phép tính | Call/ngày |
|---|---|---|
| Live (gộp mọi trận) | 8 giờ × 60 | **480** |
| Thống kê trận (per-fixture, 5 phút/lần) | 10 trận × 24 | 240 |
| Lineup (per-fixture) | 10 trận × 12 | 120 |
| Fixtures | 6 | 6 |
| BXH | 12 | 12 |
| **Tổng** | | **≈ 858 call/ngày** (tính dư retry: ~1.000) |

**Đỉnh theo phút**: khung giờ đông nhất có ~5 trận song song → 1 call
`live=all` + 5 call statistics (rải đều trong 5 phút → ~1/phút) ≈ **2–6
call/phút**. Rất thấp. Nếu poll per-fixture kiểu ngây thơ thì đỉnh là
~10–11 call/phút — **vừa đúng vượt trần 10/phút của bậc free** cả ở
API-Football lẫn football-data.org. Đây là lý do `live=all` không chỉ tiết kiệm
quota ngày mà còn cứu cả giới hạn phút.

### Bậc cần thiết cho từng nguồn

| Nguồn | Bậc tối thiểu chạy được kịch bản | Giá | Headroom |
|---|---|---|---|
| **API-Football** | **Pro** (7.500/ngày, 300/phút) | **$19/tháng** | ~7,5× quota ngày, ~50× quota phút — thoải mái để sau này thêm Europa/Conference League |
| football-data.org | Free + Deep Data (€29) + Statistics (€15), 30 req/phút | ~€44/tháng | 30/phút = 43.200/ngày lý thuyết, không có trần ngày → rất thoáng |
| Sportmonks | Growth (30 giải), 3.000 call/giờ | €99/tháng | Thoáng nhưng quá đắt |
| TheSportsDB | Premium, 100 req/phút | $9/tháng | Đủ quota nhưng live 2 phút → không đạt yêu cầu tính năng |
| Highlightly | Pro | $19/tháng | Tương đương API-Football |

### Bậc free chạy được tới đâu?

- **API-Football Free (100/ngày, 10/phút)**: sau khi trừ fixtures (6) + BXH (12)
  còn **~80 call/ngày** cho live. Tức chỉ đủ `live=all` mỗi **6 phút** trong 8
  giờ, **không có** lineup, **không có** thống kê trận. Thêm nữa bậc free bị
  **giới hạn mùa giải** (không có đầy đủ mùa hiện tại) → coi như **không dùng
  được** cho Football Center, chỉ dùng để thử nghiệm lúc dev.
- **football-data.org Free (10/phút, 12 giải)**: về mặt kỹ thuật đủ chạy
  fixtures + BXH + live-delayed cho cả 6 giải (10/phút = 14.400/ngày). Nhưng
  (a) **cấm thương mại**, (b) không có lineup/thống kê, (c) tỉ số bị delay →
  **không dùng được** cho bản phát hành.
- **Sportmonks Free**: không có 6 giải ta cần. Vô nghĩa.
- **TheSportsDB Free**: cấm publish app. Vô nghĩa.

**Kết luận về quota**: không có bậc free nào của bất kỳ nguồn nào chạy được
Football Center ở mức tính năng đề ra. Đây là trường hợp mà CLAUDE.md cho phép
đề xuất dịch vụ trả phí — và **$19/tháng là mức thấp nhất khả thi**.

### Mẹo giảm quota thêm (áp dụng ở Edge Function)

- Chỉ chạy vòng poll live khi thực sự có trận đang đá (đọc từ bảng fixtures đã
  cache), không poll 24/7 → ngày thường (không có trận) tốn < 20 call.
- Giãn `live=all` ra 90–120 giây ở các trận không có gì xảy ra, siết về 30 giây
  trong 10 phút cuối trận (khi khả năng có bàn/thẻ cao nhất).
- `/fixtures/statistics` chỉ gọi ở phút ~45, ~70 và sau trận thay vì 5 phút/lần
  → giảm 240 → 30 call/ngày.
- `/fixtures/lineups` chỉ gọi khi API báo trạng thái đã công bố (thường ~60 phút
  trước giờ bóng lăn), backoff tăng dần thay vì cố định 5 phút.
- Cache tham chiếu (leagues, teams, venues, logo URL) **một lần mỗi mùa** —
  chính nhà cung cấp khuyến nghị cách này.

---

## 7. Kết luận & khuyến nghị

**Nguồn chính: API-Football (API-Sports) — gói Pro $19/tháng.**

Lý do:
1. **Rẻ nhất trong nhóm đáp ứng đủ tính năng** — $19 so với €44 (football-data)
   và €99 (Sportmonks) cho cùng nhu cầu.
2. **Không bán tính năng theo gói**: mọi bậc trả phí mở toàn bộ endpoint và
   toàn bộ giải. Thêm Europa/Conference League về sau **không tốn thêm tiền** —
   đúng yêu cầu "kiến trúc mở" của đề bài.
3. **Điều khoản cho phép lưu dữ liệu vào DB riêng** — tương thích trực tiếp với
   kiến trúc Edge Function + Postgres cache; chính họ hướng dẫn làm vậy.
4. **`live=all` gộp mọi trận trong 1 call** — giảm quota live gần 3 lần và giữ
   đỉnh req/phút ở mức rất thấp.
5. Live 15 giây, có đủ `/fixtures/events` (bàn/kiến tạo/thẻ/thay người/penalty/
   VAR), `/fixtures/lineups` (formation/XI/dự bị/vị trí/số áo),
   `/fixtures/statistics` (đủ bộ chỉ số đề bài yêu cầu), `/standings` (hỗ trợ
   group của UCL).
6. Hết quota thì lỗi chứ không bị tính tiền vượt — an toàn cho ngân sách.

**Nguồn dự phòng: football-data.org — Free + Deep Data (€29) + Statistics (€15).**

Lý do: vận hành ổn định từ 2013, 12 giải free bao phủ đúng 6 giải ta cần (dùng
làm nguồn **đối chiếu chéo** khi nghi ngờ dữ liệu sai — ở bậc free, chỉ cho mục
đích kiểm thử nội bộ, KHÔNG hiển thị ra bản phát hành), mô hình dữ liệu sạch,
giới hạn theo phút chứ không theo ngày. Khi cần bật thật thì nâng lên gói trả
phí và thêm dòng ghi công.

Ứng viên thay thế thứ hai nếu cần: **Highlightly** ($19/tháng, điều khoản
lưu trữ rõ ràng, không bắt attribution) — nhưng công ty mới, chưa có lịch sử
vận hành dài.

### Rủi ro phải chấp nhận & cách giảm thiểu

| Rủi ro | Mức độ | Giảm thiểu |
|---|---|---|
| **Logo CLB/giải là nhãn hiệu** — không API nào cấp quyền | Trung bình | Hotlink CDN nhà cung cấp (không tự host), chỉ dùng để định danh, có fallback viết tắt tên đội, ghi nguồn ở About, gỡ ngay nếu có yêu cầu |
| API-Football là nhà cung cấp cấp 2, không có hợp đồng với UEFA | Trung bình | Viết lớp `FootballDataSource` trừu tượng trong Edge Function, adapter riêng cho từng nguồn → đổi nhà cung cấp không phải viết lại feature |
| Phụ thuộc 1 nguồn duy nhất, hỏng là chết tính năng | Cao | Client **luôn đọc từ Postgres cache**, không gọi API → nguồn hỏng thì app vẫn hiển thị dữ liệu gần nhất + banner "đang cập nhật", không vỡ màn hình |
| Đổi giá / đổi điều khoản | Thấp–TB | Kiểm tra lại file này mỗi 6 tháng; prepaid theo tháng, không khoá hợp đồng dài |
| Vượt quota ngoài dự kiến (vòng knockout UCL, nhiều trận trùng giờ) | Thấp | Đếm request trong Postgres, có circuit breaker tự giãn nhịp poll khi chạm 80% quota ngày |

### Việc phải làm khi triển khai

1. Đăng ký tài khoản tại `api-football.com`, mua gói Pro, lấy key.
2. `supabase secrets set API_FOOTBALL_KEY=<key> --project-ref pbvxnzsquqycweyjjnis`
   (Edge Function đọc qua `Deno.env.get("API_FOOTBALL_KEY")` — **thiếu bước này
   là toàn bộ Football Center trả 500**, đúng lỗi đã từng gặp với
   `TWELVE_DATA_API_KEY`).
3. Header xác thực: `x-apisports-key` khi gọi thẳng `https://v3.football.api-sports.io`
   (nếu mua qua RapidAPI thì header khác — **mua thẳng, đừng qua RapidAPI**).
4. Thêm mục ghi nguồn dữ liệu + logo vào màn About / `ATTRIBUTION.md`.

---

## 8. Chưa xác minh được từ nguồn gốc — cần kiểm tra lại thủ công

Ghi rõ để người sau không tưởng nhầm là đã xác thực:

- **`api-sports.io/terms` và `api-football.com/pricing` đều trả HTTP 403** khi
  đọc tự động (Cloudflare bot protection). Toàn bộ nội dung điều khoản
  API-Sports trong file này lấy **gián tiếp** qua trích dẫn của kết quả tìm
  kiếm và các bài so sánh bên thứ ba, **chưa đọc được nguyên văn từ trang gốc**.
  → **Trước khi trả tiền, phải mở trình duyệt đọc tay `api-sports.io/terms`**,
  xác nhận ba điểm: (a) cho phép lưu dữ liệu vào DB riêng, (b) không cấm thương
  mại, (c) điều khoản về hình ảnh/logo.
- Giới hạn **req/phút của gói Ultra ($29)** chưa xác minh được (chỉ chắc chắn
  Free = 10/phút, Pro = 300/phút, Mega = 900/phút).
- Free tier API-Football bị "giới hạn mùa giải" — có nguồn nói chỉ truy cập
  được các mùa cũ (2021–2023), **chưa xác nhận chính xác phạm vi**.
- Sportmonks: mâu thuẫn giữa trang giá (gói theo số giải) và trang marketing
  ("không tính phí theo giải") — cần hỏi sales nếu có ngày cân nhắc lại.
- Độ trễ live của Highlightly: không công bố ở đâu.

## Nguồn tham khảo

- API-Football — pricing: https://www.api-football.com/pricing
- API-Sports — terms of service: https://api-sports.io/terms (403 khi đọc tự động)
- API-Sports — tài liệu Football v3: https://api-sports.io/documentation/football/v3
- football-data.org — pricing: https://www.football-data.org/pricing
- football-data.org — API policies: https://docs.football-data.org/general/v4/policies.html
- football-data.org — FAQ (attribution): https://www.football-data.org/documentation/faq
- Sportmonks — terms of service: https://www.sportmonks.com/terms-of-service/
- Sportmonks — pricing: https://www.sportmonks.com/football-api/plans-pricing/
- TheSportsDB — terms of use: https://www.thesportsdb.com/docs_terms_of_use.php
- TheSportsDB — pricing: https://www.thesportsdb.com/pricing
- SoccersAPI — terms: https://soccersapi.com/page/terms
- SoccersAPI — pricing: https://soccersapi.com/pricing
- Highlightly — terms: https://highlightly.net/terms/
- Highlightly — so sánh các Football API 2026: https://highlightly.net/blogs/best-football-apis-in-2026
- apifootball.com — terms of use (khác API-Football): https://apifootball.com/terms_of_use/
- TheStatsAPI — so sánh Football API 2026: https://www.thestatsapi.com/blog/best-football-api
- DEV — khảo sát API bóng đá công khai 2026: https://dev.to/leomarsh886/a-survey-of-public-apis-for-building-a-football-live-score-site-in-2026-part-3-football-data-api-16hi
