# Gọi thoại/video (Agora RTC)

## Kiến trúc

- **Media (âm thanh/hình ảnh)**: truyền trực tiếp qua hạ tầng Agora (SDK
  `agora_rtc_engine`), KHÔNG qua Supabase — Supabase chỉ dùng để báo hiệu.
- **Báo hiệu**: bảng `public.calls` (xem `supabase/migrations/0020_calls.sql`)
  — 1 dòng/1 cuộc gọi, trạng thái `ringing` → `accepted`/`declined`/`ended`,
  đồng bộ realtime giữa 2 máy qua Supabase Realtime (`.stream()`).
- **Token RTC**: bắt buộc phải sinh ở server vì cần *App Certificate* (bí
  mật tuyệt đối, không được nhúng vào app) — xem Edge Function
  `supabase/functions/agora-token/index.ts`. Function này CÓ xác thực JWT
  bình thường (khác `send-chat-push` là webhook nội bộ), người dùng đã đăng
  nhập mới gọi được.
- **uid Agora**: Agora cần 1 số nguyên 32-bit cho mỗi người trong kênh — lấy
  từ 8 ký tự hex đầu của user id (UUID) để luôn ổn định cho cùng 1 người
  (xem `CallRepository.uidFor`).
- **Báo thức khi app đã tắt hẳn**: giống hệt cơ chế push tin nhắn chat —
  trigger `on_new_call_send_push` (migration `0021_call_push_notifications.sql`)
  gọi Edge Function `notify-incoming-call` gửi FCM data message tới máy
  người nhận. App tự dựng 1 thông báo `fullScreenIntent` (kênh
  `incoming_call_v1`, xem `chat_push.dart`) — Android sẽ tự bật màn hình
  `IncomingCallScreen` lên ngay cả khi máy đang khóa, giống 1 cuộc gọi điện
  thoại thật. Bấm "Từ chối" xử lý ngầm (cập nhật Supabase) không mở app;
  bấm "Trả lời"/chạm vào nội dung thông báo mở app rồi tự vào thẳng màn
  hình xác nhận cuộc gọi (`ChatPush.checkPendingCallLaunch`, xử lý cả
  trường hợp app khởi động lại từ đầu do đã bị tắt hẳn).

## Cấu hình cần thiết

1. Tài khoản Agora miễn phí tại https://console.agora.io/ (gói free ~10.000
   phút/tháng) — tạo project với **Authentication mechanism: Secured mode
   (APP ID + Token)**.
2. Lấy **App ID** và **App Certificate** (bật "Enable Certificate" nếu chưa
   có) từ project đó.
3. Đặt secret cho Supabase Edge Function (App Certificate PHẢI ở đây, không
   được để nơi khác):
   ```
   supabase secrets set AGORA_APP_ID=... AGORA_APP_CERTIFICATE=...
   ```
4. Đặt secret GitHub Actions `AGORA_APP_ID` (App ID không bí mật nhưng vẫn
   cần build vào app qua `--dart-define=AGORA_APP_ID=...`, xem
   `.github/workflows/build-apk.yml`/`build-web.yml`).

## Secret Vault bổ sung (cho push cuộc gọi)

Giống `send_chat_push_url`/`send_chat_push_secret` nhưng riêng cho cuộc gọi
(đã tạo sẵn qua SQL editor lúc build tính năng này):
```sql
select vault.create_secret('https://<project-ref>.supabase.co/functions/v1/notify-incoming-call', 'send_call_push_url');
select vault.create_secret('<chuoi bi mat tu chon>', 'send_call_push_secret');
```
Và secret `CALL_PUSH_WEBHOOK_SECRET` cho Edge Function (phải khớp với
`send_call_push_secret` ở trên):
```
supabase secrets set CALL_PUSH_WEBHOOK_SECRET=...
```
(`FIREBASE_SERVICE_ACCOUNT_JSON`/`FIREBASE_PROJECT_ID` dùng chung với
`send-chat-push`, không cần tạo lại.)

## Giới hạn đã biết (chưa làm trong lần đầu)

- **Android 14+ có thể yêu cầu cấp lại quyền full-screen intent thủ công**
  trong Settings nếu bị hệ thống thu hồi — hiếm khi xảy ra với app mới cài
  nhưng là hành vi chuẩn của Android, không phải lỗi.
- Chưa có lịch sử cuộc gọi (danh sách cuộc gọi nhỡ/đã gọi) trong UI — bảng
  `calls` đã lưu đủ dữ liệu để làm tính năng này sau.
- Thông báo cuộc gọi chỉ rung/kêu 1 lần khi đến (không đổ chuông liên tục
  như điện thoại thật) — Android không hỗ trợ lặp âm thanh thông báo theo
  cách flutter_local_notifications cho phép mà không cần thêm 1 foreground
  service riêng.
