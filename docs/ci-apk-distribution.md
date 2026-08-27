# Tự động build & phát hành APK qua GitHub Actions

Mỗi lần push code vào `main` (thay đổi trong `app/`), GitHub Actions tự động:
1. Build APK release (`--split-per-abi`, đã bật R8 minify + shrink resources).
2. Cập nhật vào **1 GitHub Release cố định, tag `latest`** — link tải không bao giờ đổi, luôn là bản mới nhất.

## Link tải cố định (bookmark lại, dùng mãi)
```
https://github.com/quangpromise/LearningEnglish/releases/download/latest/app-arm64-v8a-release.apk
```
(dùng file `arm64-v8a` cho hầu hết điện thoại; `armeabi-v7a`/`x86_64` chỉ dùng cho máy đời cũ/máy ảo — đổi tên file trong URL nếu cần)

Cũng có thể vào thẳng trang **[Releases](https://github.com/quangpromise/LearningEnglish/releases/tag/latest)** để xem cả 3 file + thời điểm build gần nhất.

## Setup 1 lần (cần bạn thao tác — chứa key nên phải thêm dạng "Secret")
1. Vào **[Settings → Secrets and variables → Actions](https://github.com/quangpromise/LearningEnglish/settings/secrets/actions)** của repo.
2. Bấm **New repository secret**, thêm lần lượt 3 secret:
   - `SUPABASE_URL` = `https://pbvxnzsquqycweyjjnis.supabase.co`
   - `SUPABASE_ANON_KEY` = (giá trị anon key đã lấy ở `docs/setup-supabase.md`)
   - `GOOGLE_WEB_CLIENT_ID` = (Client ID loại Web application)

Không cần làm gì thêm — workflow tại [`.github/workflows/build-apk.yml`](../.github/workflows/build-apk.yml) tự chạy từ lần push kế tiếp.

## Build thủ công (không cần đợi push code)
Vào tab **[Actions](https://github.com/quangpromise/LearningEnglish/actions/workflows/build-apk.yml)** → chọn workflow **"Build & Publish APK"** → **Run workflow** → chọn nhánh `main` → **Run workflow**. Sau ~5-8 phút, link tải ở trên sẽ có bản mới.

## Vì sao build trên GitHub thay vì trên máy?
Máy chạy Claude Code hiện khá ít RAM trống, từng bị crash (Out of Memory) khi build release cục bộ. Server của GitHub Actions có RAM/CPU dư dả và không ảnh hưởng tới máy cá nhân — build ổn định hơn, đồng thời có sẵn link online để test nhanh trên điện thoại mà không cần copy file qua USB/Zalo mỗi lần.
