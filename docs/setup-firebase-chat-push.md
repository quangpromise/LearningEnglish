# Hướng dẫn setup push notification cho tin nhắn chat (làm 1 lần)

Đây là các bước **cần thao tác thủ công trên trình duyệt bằng tài khoản của bạn** — Claude Code không tự tạo project Google/Firebase thay bạn được. Làm theo đúng thứ tự; cho tới khi hoàn tất, tính năng chat vẫn hoạt động bình thường qua Realtime lúc app đang mở, chỉ là **chưa** nhận được thông báo khi app đã đóng/khóa máy.

## Vì sao cần bước này?
`flutter_local_notifications` (dùng cho nhắc học từ vựng) chỉ đặt lịch **giờ đã biết trước** trên máy — không dùng được cho tin nhắn vì tin có thể đến **bất kỳ lúc nào**. Chỉ có cách server chủ động "đánh thức" máy qua dịch vụ push của hệ điều hành mới làm được — Firebase Cloud Messaging (FCM) là lựa chọn miễn phí, không giới hạn số lượng push, được Google duy trì chính thức.

## Bước 1 — Tạo Firebase project
1. Mở **[console.firebase.google.com](https://console.firebase.google.com/)** → **Add project** (dùng chung tài khoản Google với Supabase/OAuth cũng được, không bắt buộc).
2. Đặt tên project (vd `learn-english-music`) → có thể tắt Google Analytics (không cần cho tính năng này) → **Create project**.

## Bước 2 — Thêm app Android vào Firebase
1. Trong project vừa tạo, bấm icon **Android** để thêm app.
2. **Android package name**: điền chính xác `com.learnenglishmusic.learn_english_music`.
3. Bấm **Register app** → **Download google-services.json** → lưu lại file này.
4. Copy file vừa tải vào đúng đường dẫn **`app/android/app/google-services.json`** trong repo (ngang hàng với `build.gradle.kts`). File này an toàn để commit lên git (không phải bí mật — Google giới hạn quyền theo package name + chữ ký app, không phải theo việc giấu file này).
5. Báo lại cho Claude khi đã đặt file xong — Claude sẽ chạy build thử để xác nhận Gradle nhận được cấu hình.

## Bước 3 — Tạo Service Account key (để server gửi push được)
1. Trong Firebase Console → **Project settings** (icon bánh răng) → tab **Service accounts**.
2. Bấm **Generate new private key** → xác nhận → tải về 1 file `.json` (chứa `client_email`, `private_key`...).
3. **Giữ kín file này** — đây là bí mật thật sự, không commit lên git, không gửi qua chat công khai.
4. Cũng ở tab này, ghi lại **Project ID** (hiện ngay phía trên, dạng `learn-english-music-xxxxx`).

## Bước 4 — Thêm secret cho Supabase Edge Function
1. Cài Supabase CLI nếu chưa có (`npm install -g supabase` hoặc xem [hướng dẫn CLI](https://supabase.com/docs/guides/cli)), rồi đăng nhập + link project (`supabase login`, `supabase link --project-ref <project-ref>`).
2. Chạy các lệnh sau (thay giá trị thật vào), mở nội dung file service-account tải ở Bước 3 để dán nguyên văn:
   ```bash
   supabase secrets set FIREBASE_PROJECT_ID="learn-english-music-xxxxx"
   supabase secrets set FIREBASE_SERVICE_ACCOUNT_JSON="$(cat duong-dan-toi-file-service-account.json)"
   supabase secrets set CHAT_PUSH_WEBHOOK_SECRET="chuoi-bi-mat-tu-ban-chon-vd-mot-uuid-ngau-nhien"
   ```
3. Deploy Edge Function:
   ```bash
   supabase functions deploy send-chat-push --no-verify-jwt
   ```
   (`--no-verify-jwt` vì hàm này được gọi bởi trigger Postgres — không có JWT người dùng đính kèm, đã tự xác thực bằng header `x-webhook-secret` riêng thay thế.)

## Bước 5 — Chạy migration + tạo 2 secret trong Vault
1. Trong Supabase Dashboard → **SQL Editor** → **New query**, chạy nội dung file [`supabase/migrations/0014_chat_push_notifications.sql`](../supabase/migrations/0014_chat_push_notifications.sql).
2. Chạy tiếp 2 lệnh sau trong cùng SQL Editor (thay `<project-ref>` bằng project-ref Supabase của bạn, và dùng **đúng chuỗi bí mật đã đặt ở Bước 4** cho `send_chat_push_secret`):
   ```sql
   select vault.create_secret('https://<project-ref>.functions.supabase.co/send-chat-push', 'send_chat_push_url');
   select vault.create_secret('chuoi-bi-mat-tu-ban-chon-vd-mot-uuid-ngau-nhien', 'send_chat_push_secret');
   ```

## Bước 6 — Thêm secret cho GitHub Actions (để CI build được kèm cấu hình Firebase)
1. Chuyển file `google-services.json` (Bước 2) sang base64:
   ```bash
   base64 -w0 app/android/app/google-services.json
   ```
   (Windows PowerShell: `[Convert]::ToBase64String([IO.File]::ReadAllBytes("app/android/app/google-services.json"))`)
2. Vào **[Settings → Secrets and variables → Actions](https://github.com/quangpromise/LearningEnglish/settings/secrets/actions)** → **New repository secret** → tên `GOOGLE_SERVICES_JSON_BASE64`, giá trị là chuỗi base64 vừa tạo.

## Kiểm tra
Sau khi hoàn tất cả 6 bước, build APK mới (`build`), cài lên 2 máy khác nhau đã đăng nhập 2 tài khoản là bạn bè của nhau, tắt hẳn app ở 1 máy, gửi tin nhắn từ máy kia — máy đã tắt app phải nhận được thông báo hệ thống trong vài giây và bấm vào mở thẳng đoạn chat.
