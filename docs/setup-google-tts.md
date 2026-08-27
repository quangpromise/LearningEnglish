> **Trạng thái: KHÔNG dùng hiện tại.** Yêu cầu gắn thẻ thanh toán Google Cloud
> không thực hiện được — dự án đang dùng **VoiceRSS** thay thế, xem
> [`docs/setup-voicerss-tts.md`](setup-voicerss-tts.md). Giữ lại file này để
> tham khảo nếu sau muốn quay lại Google Cloud TTS (chất lượng cao hơn).

# Hướng dẫn lấy Google Cloud Text-to-Speech API key (làm 1 lần)

Nâng cấp giọng đọc từ TTS mặc định của máy (thường khó nghe, robot) lên giọng
**Neural2/WaveNet** tự nhiên như người thật, miễn phí trong hạn mức 1 triệu
ký tự WaveNet + 4 triệu ký tự standard/tháng.

**Lưu ý quan trọng**: Google **bắt buộc gắn thẻ thanh toán** vào project để
bật API này, kể cả khi chỉ dùng trong hạn mức miễn phí — đây là yêu cầu của
Google, không có cách nào bỏ qua. Bạn sẽ không bị trừ tiền nếu dùng trong hạn
mức free tier hàng tháng.

## Bước 1 — Tạo/chọn Google Cloud project
1. Mở **[console.cloud.google.com](https://console.cloud.google.com/)**.
2. Nếu đã có project (vd project bạn từng tạo cho Google Sign-In OAuth), dùng
   lại project đó luôn cho gọn — không cần tạo mới. Nếu chưa có, bấm dropdown
   project ở góc trên trái → **New Project** → đặt tên (vd `learn-english-music`).

## Bước 2 — Gắn thẻ thanh toán (Billing)
1. Mở **[console.cloud.google.com/billing](https://console.cloud.google.com/billing)**.
2. Nếu chưa có billing account nào, bấm **Add billing account**, điền thông
   tin thẻ (Visa/Mastercard đều được).
3. Đảm bảo project ở Bước 1 đã được **link** với billing account này (nếu
   Google hỏi lúc tạo project, chọn luôn; nếu không, vào **Billing → Link a
   billing account** và chọn project).

## Bước 3 — Bật Cloud Text-to-Speech API
1. Mở **[console.cloud.google.com/apis/library/texttospeech.googleapis.com](https://console.cloud.google.com/apis/library/texttospeech.googleapis.com)**.
2. Đảm bảo đúng project đang chọn ở góc trên (giống Bước 1).
3. Bấm **Enable**.

## Bước 4 — Tạo API key
1. Mở **[console.cloud.google.com/apis/credentials](https://console.cloud.google.com/apis/credentials)**.
2. Bấm **+ Create Credentials → API key**. Một popup hiện ra API key vừa tạo
   — copy lại, lưu tạm vào notepad.
3. **Quan trọng — giới hạn key để tránh bị lạm dụng**: bấm **Edit API key**
   (hoặc bấm vào tên key vừa tạo trong danh sách) →
   - Mục **API restrictions** → chọn **Restrict key** → tick vào
     **Cloud Text-to-Speech API** → **Save**.
   - (Không cần giới hạn theo IP vì Supabase Edge Function chạy IP động.)

## Bước 5 — Đưa API key vào Supabase (secret, không đưa vào app)
1. Mở **[supabase.com/dashboard/project/pbvxnzsquqycweyjjnis/settings/functions](https://supabase.com/dashboard/project/pbvxnzsquqycweyjjnis/settings/functions)**.
2. Tìm mục **Edge Function Secrets** (hoặc **Manage secrets**) → **Add new
   secret**.
3. Tên (Name): `GOOGLE_TTS_API_KEY`
   Giá trị (Value): dán API key từ Bước 4.
4. Bấm **Save**.

## Bước 6 — Deploy Edge Function `tts`
Cần Supabase CLI (nếu chưa cài từ lần deploy `grant-points` trước thì cài lại):
```bash
npm install -g supabase
supabase login
cd "D:\Projects\Learn Engligh"
supabase link --project-ref pbvxnzsquqycweyjjnis
supabase functions deploy tts
```

## Báo lại khi xong
Báo tôi khi đã hoàn thành Bước 1–6 (không cần gửi API key cho tôi — key chỉ
cần nằm trong Supabase secret là đủ, tôi không cần biết giá trị) để tôi test
thử gọi function và xác nhận giọng đọc mới hoạt động.
