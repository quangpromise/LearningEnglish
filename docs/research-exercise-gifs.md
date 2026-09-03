# Nghiên cứu nguồn ảnh động (GIF) minh hoạ bài tập (tính năng Fitness)

Thư viện 155 bài tập (`app/assets/fitness/exercises_seed.json`, port từ FitViet)
hiện chỉ có text hướng dẫn từng bước, chưa có ảnh động minh hoạ động tác.
FitViet gốc cũng chưa từng có GIF thật — chỉ có tên file placeholder trỏ tới
ảnh không tồn tại. Ràng buộc: app phát hành ngoài Google Play (sideload APK),
cần license cho phép **thương mại rõ ràng**, ưu tiên đóng gói sẵn trong app
(offline) hơn là gọi API runtime cần giữ key.

## Bảng so sánh

| Nguồn | Giá | License nội dung ảnh/GIF | Định dạng thật | Cần key/backend? | Khớp 155 bài? |
|---|---|---|---|---|---|
| **wger.de** (self-hosted OSS + API) | Miễn phí | App: AGPL 3+. Dữ liệu bài tập: CC-BY-SA (mỗi ảnh có tác giả/license riêng do cộng đồng đóng góp, phải tra từng ảnh) | Chủ yếu **ảnh tĩnh**, không phải GIF động; nhiều bài tập trong DB **không có ảnh** | Không bắt buộc — có thể tải qua API public rồi tự host | Cần ánh xạ thủ công theo tên tiếng Anh, tỉ lệ khớp không cao vì DB nhỏ và thiếu ảnh |
| **RepDB** (`RepDB/exercise-dataset` + repdb.co) | Free tier: 0đ (ảnh tĩnh + attribution) / Standard: $499 một lần (có animation) | Rõ ràng nhất: **ảnh AI-generated gốc do RepDB tự đặt làm** (không dính nguồn thứ 3), tier free cho thương mại kèm attribution bắt buộc, tier trả phí cho animation thương mại không cần attribution | Free: ảnh tĩnh WebP 1024×1024. Standard: **animation loop có nền trong suốt** | Không — tải file 1 lần, tự host/đóng gói trong app | 601 bài tập, tên `name_en` dạng slug (vd `bulgarian-split-squat`) — cần ánh xạ thủ công nhưng danh pháp tiếng Anh phổ biến nên tỉ lệ khớp khá cao |
| **exercisedb.io** (EDB Exercise Intelligence) | Starter $199 / Pro $599 — mua đứt 1 lần | "Platform-neutral commercial license", rõ ràng cho phép tự host, đóng gói trong app, không phụ thuộc dịch vụ lúc runtime | **GIF động thật** 180×180 đến 1080×1080 tuỳ gói | Không — tải file 1 lần | 1.394 bài tập, coverage rộng, nhiều khả năng khớp tên |
| **ExerciseDB (RapidAPI gốc / oss.exercisedb.dev / AGPL fork trên GitHub)** | "Miễn phí"/rẻ | **Rủi ro**: code server AGPL-3.0, nhưng **không tìm thấy tuyên bố license rõ ràng cho chính các file GIF/ảnh** — nguồn gốc GIF không được ghi nhận, nhiều bản fork/clone dùng lại cùng 1 bộ GIF không rõ ai là chủ sở hữu gốc | GIF động thật (5.000+ GIF) | Có, cần key cho bản RapidAPI gốc | Tên tiếng Anh phổ biến, dễ khớp — nhưng license mập mờ nên **không nên dùng** |
| **free-exercise-db** (`yuhonas/free-exercise-db`) | Miễn phí | Dữ liệu JSON: Unlicense (public domain, rõ ràng, an toàn). **Ảnh: không rõ nguồn, 2 issue GitHub hỏi về copyright ảnh (#2, #12, #13) đều KHÔNG được maintainer trả lời** | Chuỗi ảnh JPG tĩnh dạng sequence (không phải GIF động thật, phải tự ghép animation) | Không | Dữ liệu JSON dùng được (license rõ), nhưng ảnh có rủi ro license tương tự vụ Jamendo — **không dùng ảnh** |
| **MuscleWiki API** | Free: 500 call/tháng chỉ dùng trong Playground (không gọi được từ app thật). Trả phí từ $10-$199.99/tháng | Cho phép thương mại nhưng **cấm lưu trữ offline/đóng gói trong app**: video "chỉ được cache tạm thời", cấm tải về lưu CDN/app riêng; API key phải giấu sau backend riêng, không nhúng trong APK | Video demo thật | **Bắt buộc có backend riêng** để giấu key + đổi token ngắn hạn | Không phù hợp kiến trúc offline-first của app |

## Vì sao không dùng ExerciseDB (RapidAPI/AGPL fork) và ảnh của free-exercise-db

Cả hai đều có cùng một vấn đề: **không xác định được ai thực sự là chủ sở
hữu bản quyền gốc của các file GIF/ảnh**. Đây là mẫu rủi ro giống hệt vụ
Jamendo API đã gặp trong dự án này (ghi "miễn phí" nhưng điều khoản thực tế
không như quảng cáo) — chỉ khác là ở đây rủi ro nằm ở việc **hoàn toàn thiếu
tuyên bố license cho nội dung media**, không phải license hạn chế thương
mại. Nhiều app fitness indie đã dùng lại cùng bộ GIF này qua nhiều năm mà
không ai xác minh được nguồn gốc — không đủ an toàn để đưa vào app phát
hành thương mại.

## Vì sao không dùng MuscleWiki API

Điều khoản cấm rõ ràng việc lưu trữ/đóng gói media ngoài cache tạm thời của
trình phát — đi ngược triết lý offline-first của app này. Ngoài ra bắt buộc
phải có backend riêng để giấu API key (app hiện chưa có backend cho tính
năng Fitness), và free tier chỉ dùng được trong Playground, không gọi được
từ app thật.

## Vì sao wger không giải quyết được bài toán "ảnh động"

wger là nguồn mở, license dữ liệu an toàn (CC-BY-SA), nhưng **không hỗ trợ
GIF động** — chỉ có ảnh tĩnh, và nhiều bài tập trong DB thậm chí không có
ảnh nào. Phù hợp làm nguồn bổ sung ảnh tĩnh miễn phí cho một số bài tập cơ
bản, nhưng không thể là nguồn chính cho yêu cầu "ảnh động minh hoạ động tác".

## Khuyến nghị

Không có lựa chọn nào **vừa miễn phí, vừa có GIF động thật, vừa license rõ
ràng an toàn cho thương mại** — đây là trường hợp bắt buộc phải nêu rõ theo
quy ước dự án: chỉ đề xuất trả phí vì không có phương án miễn phí đủ tốt.

- **Ngắn hạn / chi phí 0đ**: giữ nguyên hướng dẫn text từng bước như hiện
  tại (đã đủ dùng cho Phase 1), bổ sung dần **ảnh tĩnh từ wger** (CC-BY-SA,
  cần ghi tác giả từng ảnh trong `ATTRIBUTION.md`/metadata tương tự quy ước
  nhạc) cho những bài tập trùng tên và có sẵn ảnh — không cố ép đủ 155 bài.
- **Khi có ngân sách nhỏ, muốn có GIF động thật cho toàn bộ 155 bài**:
  chọn **RepDB Standard ($499, mua 1 lần, không phí định kỳ)** làm ưu tiên
  số 1 — vì đây là nguồn duy nhất công bố rõ ràng ảnh là **tác phẩm gốc do
  họ đặt làm (AI-generated), không dính bản quyền bên thứ ba**, tránh hẳn
  rủi ro kiểu Jamendo/ExerciseDB. Phương án 2 là **exercisedb.io Starter
  ($199)** nếu ưu tiên phong cách ảnh thật hơn AI-art và cần coverage rộng
  hơn (1.394 bài so với 601 bài của RepDB).
- **Kiến trúc tích hợp**: dù chọn RepDB hay exercisedb.io, cả hai đều cho
  phép mua đứt và tự host — nên **tải về, ánh xạ thủ công theo `nameEn`
  trong `exercises_seed.json`, rồi đóng gói file GIF vào `app/assets/`**
  giống cách `exercises_seed.json` đang được đóng gói sẵn (không gọi API
  runtime) — nhất quán với triết lý offline-first của dự án và tránh phát
  sinh backend mới chỉ để phục vụ ảnh tĩnh.
- **Không dùng**: ExerciseDB (RapidAPI hay bản AGPL tự host), ảnh của
  free-exercise-db, MuscleWiki API — vì lý do license/kiến trúc nêu trên.
- Với cả 2 nguồn trả phí, việc khớp tên bài tập là **thủ công** (so khớp
  theo `nameEn`, chuẩn hoá chữ thường/bỏ dấu gạch ngang) — không có bài nào
  tự động khớp 100% vì bộ 155 bài đã được tuỳ biến/dịch riêng cho app này.
