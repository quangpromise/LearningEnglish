# Nghiên cứu: Backend tài khoản, đăng nhập Google, điểm thưởng & phân quyền theo điểm

Yêu cầu: người dùng đăng ký/đăng nhập bằng **Google mail**, **admin tạo và gửi điểm thưởng** cho user, **phân quyền theo số điểm** (đủ điểm mới dùng được 1 số hạng mục/tính năng), và cần xác định backend + môi trường online dùng gì.

## Vì sao đây là 1 backend khác với AI Voice Chat
Tính năng AI Voice Chat (`backend/gemini-proxy` + `backend/fallback-pipeline`) chỉ lo phần hội thoại giọng nói — không có database, không có khái niệm tài khoản. Tài khoản/điểm thưởng/phân quyền cần **database quan hệ + hệ thống xác thực + logic nghiệp vụ (cấp điểm, tính hạng)** — đây là một backend riêng, gọi là **"Accounts & Rewards backend"**. Hai backend có thể (và nên) dùng chung 1 database ở bước sau để tính năng AI Voice Chat kiểm tra được "user này đủ điểm dùng tính năng chưa".

## So sánh phương án (nghiên cứu 2026)

| Phương án | Đăng nhập Google | Database | Chi phí free tier | Hạn chế |
|---|---|---|---|---|
| **Supabase** (khuyên dùng) | Auth có sẵn provider Google, chỉ cần đăng ký OAuth Client ID | **Postgres** (quan hệ, hợp với sổ điểm/giao dịch) | 50.000 MAU auth, 500MB DB, 500.000 lượt gọi Edge Function/tháng, **không cần thẻ tín dụng** | Project **tự tạm dừng (pause) sau 7 ngày không có hoạt động** trên free tier — cần ping định kỳ hoặc unpause thủ công trước khi demo |
| Firebase (Google) | Auth có sẵn provider Google (cùng hãng Google nên tích hợp mượt) | Firestore (NoSQL) — kém tự nhiên hơn cho sổ giao dịch điểm có ràng buộc số học | Auth free tới 50.000 MAU, Firestore 50k đọc/20k ghi/ngày | Từ 2/2026 **Cloud Storage bị bỏ khỏi gói free**; Cloud Functions (logic cấp điểm phía server) yêu cầu gói Blaze — **phải khai báo thẻ tín dụng** dù chưa vượt free quota |
| Tự viết backend (Node.js/NestJS + Postgres tự host) | Tự code OAuth Google (`passport-google-oauth20` hoặc xác thực ID token bằng `google-auth-library`) | Postgres tự host (VD trên Oracle Cloud Free VM) | Miễn phí nếu tự host, nhưng tốn công bảo trì | Phải tự lo bảo mật, backup, scale — nhiều việc hơn hẳn 2 phương án trên |

**Khuyến nghị: Supabase** — lý do quyết định: (1) Postgres quan hệ khớp tự nhiên với "sổ giao dịch điểm" (mỗi lần admin cấp điểm là 1 dòng transaction, cộng dồn ra số dư), (2) **Row Level Security (RLS)** của Postgres cho phép chặn ở tầng database — user thường **không thể tự sửa điểm của mình** dù có lấy được API key, chỉ vai trò `admin` mới ghi được vào bảng điểm, (3) không yêu cầu thẻ tín dụng để dùng free tier (khác Firebase Blaze).

## Kiến trúc đề xuất

```
Flutter app
   │  1. Đăng nhập Google (gói `google_sign_in`) → lấy ID token
   │  2. Gửi ID token cho Supabase Auth → Supabase tự tạo/xác thực tài khoản
   ▼
Supabase (1 project = Auth + Postgres + Edge Functions)
   ├── Bảng `profiles`      (user_id, email, display_name, role: 'user'|'admin')
   ├── Bảng `point_transactions` (id, user_id, amount, reason, granted_by_admin_id, created_at)
   ├── View/Function `user_points_balance(user_id)` → tổng điểm hiện có
   ├── Bảng `tiers`         (name, min_points, unlocked_features: jsonb)
   │        vd: Bronze (0đ): bài hát cơ bản · Silver (100đ): + Quiz nâng cao
   │            Gold (500đ): + AI Voice Chat
   ├── RLS policy: user chỉ SELECT được điểm/giao dịch của chính mình,
   │               chỉ role='admin' mới INSERT được vào point_transactions
   └── Edge Function `grant_points` — admin gọi để cấp điểm cho 1 user,
       tự kiểm tra caller có role admin không trước khi ghi vào DB
```

- **Trang quản trị (admin) để cấp điểm**: giai đoạn đầu dùng luôn **Supabase Studio** (giao diện quản lý bảng có sẵn, miễn phí, không cần code) để admin vào sửa/thêm dòng trong `point_transactions`. Khi cần giao diện đẹp/riêng cho admin, xây 1 trang web nhỏ (Flutter Web hoặc Next.js) gọi Edge Function `grant_points`, host miễn phí trên Cloudflare Pages/Vercel.
- **Kiểm tra quyền theo điểm trong app**: app đọc `user_points_balance` + so với bảng `tiers` để biết user đang ở hạng nào, từ đó ẩn/hiện tính năng — đồng thời **backend cũng phải tự kiểm tra lại** (không chỉ ẩn ở UI) mỗi khi user gọi 1 tính năng bị khoá theo điểm, để tránh user bypass bằng cách sửa code client.
- **AI Voice Chat** (`backend/gemini-proxy`) khi cần khoá theo điểm: gọi Supabase (dùng `service_role` key, chỉ ở phía server) để kiểm tra tier của user trước khi cho phép kết nối.

## Trả lời trực tiếp 2 câu hỏi

**"Backend dùng môi trường nào?"**
- Phần **tài khoản/điểm/phân quyền**: dùng **Supabase** — không phải tự quản lý server, môi trường là hạ tầng đám mây do Supabase vận hành (Postgres + Auth + Edge Functions), chỉ cần tạo project trên supabase.com.
- Phần **AI Voice Chat** (đã có kế hoạch trước): vẫn là Node.js (`gemini-proxy`) + Python (`fallback-pipeline`) tự host trên 1 VM.

**"Online sẽ dùng môi trường nào?"** (nơi host để chạy công khai)
- **Supabase project**: tự động online ngay khi tạo (không cần deploy gì thêm), free tier đủ cho giai đoạn đầu — chỉ cần lưu ý cơ chế tự pause sau 7 ngày không hoạt động (đặt 1 cron job gọi ping định kỳ, hoặc chấp nhận bấm "Resume" thủ công trước khi demo).
- **VM chạy `gemini-proxy` + `fallback-pipeline`**: **Oracle Cloud Always Free** (VM ARM, hiện còn 2 OCPU/12GB RAM miễn phí vĩnh viễn sau đợt cắt giảm giữa 2026) — cài Docker, dùng Caddy hoặc Cloudflare Tunnel để có HTTPS miễn phí mà không cần mở port thủ công.
- **Trang admin web (nếu xây riêng sau này)**: Cloudflare Pages hoặc Vercel free tier.

## Việc cần làm khi bắt đầu triển khai (chưa code trong lượt này)
1. Tạo project Supabase, bật provider Google trong Auth (cần tạo OAuth Client ID trên Google Cloud Console cho Android/iOS/Web).
2. Tạo schema: `profiles`, `point_transactions`, `tiers` + RLS policies.
3. Thêm `supabase_flutter` + `google_sign_in` vào `pubspec.yaml`, viết màn hình đăng nhập.
4. Viết Edge Function `grant_points`.
5. Nối logic kiểm tra tier vào các màn hình/tính năng cần khoá theo điểm.
