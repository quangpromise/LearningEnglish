# Hướng dẫn setup Supabase + Google Sign-In (làm 1 lần)

Đây là các bước **cần thao tác thủ công trên trình duyệt bằng tài khoản của bạn** — Claude Code không tự đăng ký tài khoản/tạo OAuth Client thay bạn được. Làm theo đúng thứ tự, xong bước nào báo lại giá trị (key/ID) để nối vào app.

## Bước 1 — Tạo project Supabase
1. Mở **[supabase.com/dashboard/sign-up](https://supabase.com/dashboard/sign-up)** → đăng ký (bấm **Continue with Google** cho nhanh, dùng luôn Google mail của bạn).
2. Sau khi vào dashboard, mở **[supabase.com/dashboard/new](https://supabase.com/dashboard/new)** → **New project**.
3. Đặt tên project (vd `learn-english-music`), chọn **Region: Southeast Asia (Singapore)**, đặt mật khẩu database (bấm **Generate a password** rồi lưu lại chỗ nào đó — không cần nhớ, chỉ cần lưu).
4. Bấm **Create new project**, đợi ~2 phút để khởi tạo xong.
5. Vào menu trái **Project Settings** (icon bánh răng) → **Data API** → lấy 2 giá trị, dán tạm vào notepad:
   - **Project URL** (dạng `https://xxxxxxxx.supabase.co`)
   - **anon public** key (chuỗi dài bắt đầu `eyJ...`) — trong mục **Project API keys**

## Bước 2 — Tạo Google OAuth Client ID
1. Mở **[console.cloud.google.com](https://console.cloud.google.com/)** → nếu chưa có project nào, tạo project mới (góc trên bên trái, chọn dropdown project → **New Project**).
2. Mở **[OAuth consent screen](https://console.cloud.google.com/auth/overview)** → bấm **Get started** → điền tên app (vd "Learn English Through Music"), email hỗ trợ (email của bạn) → chọn **External** → **Save**. Nếu được hỏi thêm scope/test user, thêm chính email Google của bạn vào **Test users** để đăng nhập thử được ngay (khi app chưa publish).
3. Mở **[Credentials](https://console.cloud.google.com/apis/credentials)** → **+ Create Credentials → OAuth client ID**:
   - **Loại 1 — Web application**: Application type chọn **Web application**, đặt tên (vd "Supabase Auth"). Ở **Authorized redirect URIs**, bấm **+ Add URI**, dán:
     `https://<project-ref>.supabase.co/auth/v1/callback`
     (thay `<project-ref>` bằng đoạn mã trong Project URL bạn lấy ở Bước 1 — vd URL là `https://abcdefgh.supabase.co` thì `<project-ref>` = `abcdefgh`).
     Bấm **Create** → 1 popup hiện ra **Client ID** và **Client secret** — copy cả 2, lưu tạm vào notepad.
   - **Loại 2 — Android** (để app Android đăng nhập được): bấm **+ Create Credentials → OAuth client ID** lần nữa, chọn **Android**. Cần điền:
     - **Package name**: `com.learnenglishmusic.learn_english_music`
     - **SHA-1 certificate fingerprint**: lấy bằng lệnh (chạy trong thư mục `app/`):
       ```bash
       cd app/android && ./gradlew signingReport
       ```
       Tìm dòng `SHA1:` trong phần `Variant: debug` của kết quả, copy dán vào.
     Bấm **Create** (client này không cần copy Client ID ra dùng — Google tự nhận diện qua package name + SHA-1 khi app chạy).

## Bước 3 — Bật đăng nhập Google trong Supabase
1. Quay lại Supabase Dashboard → menu trái **Authentication** → tab **Sign In / Providers** → tìm **Google** → bật toggle **Enable Sign in with Google**.
2. Dán **Client ID** và **Client Secret** (của OAuth Client loại **Web application** ở Bước 2) vào 2 ô tương ứng.
3. Bấm **Save**.

## Bước 4 — Chạy migration (tạo bảng profiles/point_transactions/tiers)
1. Trong Supabase Dashboard, menu trái → **SQL Editor** → **New query**.
2. Mở file [`supabase/migrations/0001_accounts_rewards.sql`](../supabase/migrations/0001_accounts_rewards.sql) trong repo, copy toàn bộ nội dung, dán vào ô query.
3. Bấm **Run** (hoặc Ctrl+Enter). Thấy "Success. No rows returned" là xong.

## Bước 5 — Deploy Edge Function `grant-points`
Cần cài Supabase CLI trước (Node.js đã có sẵn trên máy này):
```bash
npm install -g supabase
supabase login
```
Lệnh `login` sẽ mở trình duyệt để bạn xác nhận. Sau đó:
```bash
cd "D:\Projects\Learn Engligh"
supabase link --project-ref <project-ref>
supabase functions deploy grant-points
```
(`<project-ref>` giống Bước 2 — đoạn mã trong Project URL.)

## Bước 6 — Đưa các giá trị vào app
Báo tôi 3 giá trị đã lưu ở Bước 1 và Bước 2 (SUPABASE_URL, SUPABASE_ANON_KEY, GOOGLE_WEB_CLIENT_ID — là Client ID của client **Web application**) — tôi sẽ chạy giúp bạn:
```bash
flutter run \
  --dart-define=SUPABASE_URL=https://xxxxxxxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJ... \
  --dart-define=GOOGLE_WEB_CLIENT_ID=xxxxx.apps.googleusercontent.com
```

## Bước 7 — Cấp quyền admin cho tài khoản của bạn
Sau khi bạn đăng nhập lần đầu bằng Google trong app, 1 dòng sẽ tự xuất hiện trong bảng `profiles` (role mặc định là `user`). Vào Supabase Dashboard → menu trái **Table Editor** → chọn bảng **profiles** → tìm dòng có email của bạn → double-click ô `role` → sửa thành `admin` → Enter để lưu.

## Sau khi có key, báo lại cho tôi
Gửi 3 giá trị ở Bước 6 — tôi sẽ:
- Không commit key vào git (chỉ dùng khi chạy `flutter run`/build cục bộ, không lưu vào file trong repo).
- Chạy thử để xác nhận đăng nhập Google hoạt động.
- Test cấp điểm qua Edge Function `grant-points`.
