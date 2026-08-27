# Hướng dẫn lấy VoiceRSS API key (làm 1 lần)

Nhà cung cấp giọng đọc chất lượng cao hiện tại của app — chọn thay Google
Cloud TTS vì **không cần gắn thẻ thanh toán**, chỉ cần đăng ký email.

Giới hạn: **350 lượt gọi/ngày miễn phí, dùng chung cho TẤT CẢ user của app**
(không phải 350/ngày cho mỗi người) — xem [voicerss.org/api](https://www.voicerss.org/api/)
để biết chi tiết. Nếu app có nhiều người dùng đồng thời, hạn mức này có thể
hết nhanh — khi đó Edge Function sẽ trả lỗi và app tự động rơi về giọng máy
(offline), không crash. Cân nhắc nâng cấp gói trả phí VoiceRSS hoặc quay lại
Google Cloud TTS (xem `docs/setup-google-tts.md`) nếu lượng dùng tăng.

## Bước 1 — Đăng ký lấy API key
1. Mở **[voicerss.org/registration.aspx](https://www.voicerss.org/registration.aspx)**.
2. Điền email, đặt mật khẩu → đăng ký.
3. Xác nhận email nếu được yêu cầu → đăng nhập vào **[voicerss.org/Home/ApiKey.aspx](https://www.voicerss.org/Home/ApiKey.aspx)** (hoặc mục **API Key** sau khi đăng nhập) để lấy API key — copy lại, lưu tạm.

## Bước 2 — Thêm secret vào Supabase
1. Mở **[supabase.com/dashboard/project/pbvxnzsquqycweyjjnis/settings/functions](https://supabase.com/dashboard/project/pbvxnzsquqycweyjjnis/settings/functions)**.
2. Tìm mục **Edge Function Secrets** → **Add new secret**.
3. Name: `VOICERSS_API_KEY`, Value: dán API key ở Bước 1 → **Save**.

## Bước 3 — Deploy Edge Function `tts`
Cần Supabase CLI (nếu chưa cài):
```bash
npm install -g supabase
supabase login
cd "D:\Projects\Learn Engligh"
supabase link --project-ref pbvxnzsquqycweyjjnis
supabase functions deploy tts
```

## Báo lại khi xong
Báo tôi khi hoàn thành Bước 1–3 (không cần gửi API key — chỉ cần nằm trong
Supabase secret) để tôi xác nhận giọng "Chất lượng cao" trong app hoạt động.
