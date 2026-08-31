# Tự động build & phát hành bản Web qua GitHub Actions + Pages

Khác với APK (build thủ công có chủ đích, dùng tag `[build]`), bản Web
**tự động deploy lại mỗi lần push code vào `main`** (thay đổi trong `app/`)
— không cần chờ đồng ý, vì đây chỉ là ghi đè 1 trang web tĩnh, miễn phí,
không phát sinh file tải về mới cho người dùng như APK.

## Link truy cập
```
https://quangpromise.github.io/LearningEnglish/
```

## Setup 1 lần (cần bạn thao tác trên GitHub — chỉ làm đúng 1 lần)
1. Vào **[Settings → Pages](https://github.com/quangpromise/LearningEnglish/settings/pages)** của repo.
2. Ở mục **Build and deployment → Source**, chọn **GitHub Actions** (không chọn "Deploy from a branch").
3. Không cần làm gì thêm — workflow [`build-web.yml`](../.github/workflows/build-web.yml) tự chạy từ lần push kế tiếp, dùng lại đúng 3 secret (`SUPABASE_URL`, `SUPABASE_ANON_KEY`, `GOOGLE_WEB_CLIENT_ID`) đã tạo sẵn cho bản Android.

## Những gì KHÔNG hoạt động trên bản Web (đã biết trước, chấp nhận đánh đổi)
Xem đầy đủ trong [`docs/research-ios-distribution.md`](research-ios-distribution.md) mục "Phương án thay thế: build bản Web":
- Phát nhạc nền khi khoá máy/chuyển tab — hạn chế của Safari iOS, Chrome Android thì ổn hơn.
- Nhắc học "10 từ hôm nay" theo giờ — trình duyệt không hỗ trợ thông báo hẹn giờ/lặp lại.
- Push chat (Firebase) — chỉ hoạt động trên Safari nếu người dùng "Thêm vào màn hình chính".
- "Kiểm tra cập nhật APK" tự tắt trên Web (không có ý nghĩa trong trình duyệt).

## Vì sao dùng GitHub Pages thay vì Firebase Hosting?
Cùng hệ sinh thái với repo (không cần thêm tài khoản/CLI mới), miễn phí không giới hạn cho repo public, deploy qua Actions y hệt pattern đã quen với `build-apk.yml`.
