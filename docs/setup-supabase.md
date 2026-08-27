# Hướng dẫn setup Supabase + Google Sign-In (làm 1 lần)

Đây là các bước **cần thao tác thủ công trên trình duyệt bằng tài khoản của bạn** — Claude Code không tự đăng ký tài khoản/tạo OAuth Client thay bạn được. Làm theo đúng thứ tự, xong bước nào báo lại giá trị (key/ID) để nối vào app.

## Bước 1 — Tạo project Supabase
1. Vào https://supabase.com → **Sign up** (dùng luôn Google mail cho tiện) → **New project**.
2. Đặt tên project (vd `learn-english-music`), chọn region gần Việt Nam (Singapore), đặt mật khẩu database (lưu lại).
3. Đợi project khởi tạo xong (~2 phút).
4. Vào **Project Settings → Data API** (hoặc **API** tuỳ giao diện) → lấy 2 giá trị:
   - **Project URL** (dạng `https://xxxxxxxx.supabase.co`)
   - **anon public key** (chuỗi dài bắt đầu `eyJ...`)

## Bước 2 — Tạo Google OAuth Client ID
1. Vào https://console.cloud.google.com → tạo project mới (hoặc dùng project có sẵn).
2. Vào **APIs & Services → OAuth consent screen** → cấu hình cơ bản (tên app, email hỗ trợ) — chọn **External**, thêm email của bạn vào test users nếu app đang ở chế độ Testing.
3. Vào **APIs & Services → Credentials → Create Credentials → OAuth Client ID**:
   - Tạo 1 client loại **Web application** — đây là `GOOGLE_WEB_CLIENT_ID` dùng chung cho việc xác thực qua Supabase. Ở mục "Authorized redirect URIs", thêm:
     `https://<project-ref>.supabase.co/auth/v1/callback` (thay `<project-ref>` bằng ref project Supabase của bạn, xem trong Project URL ở Bước 1).
   - Tạo thêm 1 client loại **Android** (cần SHA-1 fingerprint — chạy `cd app/android && ./gradlew signingReport` để lấy, dùng debug SHA-1 để test trước) và package name `com.learnenglishmusic.learn_english_music`.
4. Copy **Client ID** của client loại **Web application** — đây là giá trị `GOOGLE_WEB_CLIENT_ID` sẽ dùng ở Bước 4.

## Bước 3 — Bật đăng nhập Google trong Supabase
1. Trong Supabase Dashboard → **Authentication → Providers → Google** → bật lên.
2. Điền **Client ID** và **Client Secret** của OAuth Client loại **Web application** (Client Secret lấy trong Google Cloud Console, cùng chỗ tạo Client ID).
3. Lưu lại.

## Bước 4 — Chạy migration (tạo bảng profiles/point_transactions/tiers)
Cách đơn giản nhất (không cần cài Supabase CLI): vào Supabase Dashboard → **SQL Editor** → New query → dán toàn bộ nội dung file [`supabase/migrations/0001_accounts_rewards.sql`](../supabase/migrations/0001_accounts_rewards.sql) → **Run**.

(Cách khác nếu đã cài Supabase CLI: `supabase link --project-ref <project-ref>` rồi `supabase db push`.)

## Bước 5 — Deploy Edge Function `grant-points`
Cần cài Supabase CLI (`npm install -g supabase`), sau đó:
```bash
supabase login
supabase link --project-ref <project-ref>
supabase functions deploy grant-points
```

## Bước 6 — Đưa các giá trị vào app
Chạy app kèm 3 giá trị lấy được ở trên:
```bash
flutter run \
  --dart-define=SUPABASE_URL=https://xxxxxxxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJ... \
  --dart-define=GOOGLE_WEB_CLIENT_ID=xxxxx.apps.googleusercontent.com
```
Khi build APK release cũng thêm y hệt 3 flag `--dart-define` này vào lệnh `flutter build apk --release`.

## Bước 7 — Cấp quyền admin cho tài khoản của bạn
Sau khi bạn đăng nhập lần đầu bằng Google trong app, 1 dòng sẽ tự xuất hiện trong bảng `profiles` (role mặc định là `user`). Vào Supabase Dashboard → **Table Editor → profiles** → tìm dòng của bạn → sửa cột `role` thành `admin`.

## Sau khi có key, báo lại cho tôi
Gửi 3 giá trị ở Bước 6 (SUPABASE_URL, SUPABASE_ANON_KEY, GOOGLE_WEB_CLIENT_ID) — tôi sẽ:
- Không commit key vào git (đưa vào file `.env`/script chạy cục bộ, đã có trong `.gitignore`).
- Chạy thử `flutter run` để xác nhận đăng nhập Google hoạt động.
- Test cấp điểm qua Edge Function `grant-points`.
