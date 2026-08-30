# Tự động build & phát hành APK qua GitHub Actions

Mỗi lần push code vào `main` (thay đổi trong `app/`), GitHub Actions tự động:
1. Build APK release: 1 bản **universal** (gộp 2 kiến trúc ARM: `arm64-v8a` + `armeabi-v7a`) + 3 bản `--split-per-abi` nhỏ gọn hơn (đã bật R8 minify + shrink resources).
2. Cập nhật vào **1 GitHub Release cố định, tag `latest`** — link tải không bao giờ đổi, luôn là bản mới nhất.

## Link tải cố định — dùng file này khi chia sẻ cho người khác (bookmark lại, dùng mãi)
```
https://github.com/quangpromise/LearningEnglish/releases/download/latest/app-release.apk
```
File này là bản **universal**, cài được trên hầu như MỌI điện thoại Android thật bất kể kiến trúc chip — luôn dùng file này khi gửi link cho người dùng phổ thông, kể cả khi không biết máy họ dùng chip gì. Tính năng "Kiểm tra cập nhật" trong app cũng tự tải đúng file này (xem `update_checker.dart`).

### Vì sao trước đây bị lỗi "không tương thích"?
Trước đây chỉ phát hành 3 file `--split-per-abi` (`arm64-v8a`/`armeabi-v7a`/`x86_64`), mỗi file chỉ chứa thư viện native cho ĐÚNG 1 loại chip. Gửi nhầm file `arm64-v8a` (mặc định) cho máy dùng chip 32-bit đời cũ (`armeabi-v7a`) sẽ bị Android từ chối cài với lỗi không tương thích. Bản `app-release.apk` universal giải quyết dứt điểm vấn đề này bằng cách gộp `arm64-v8a` + `armeabi-v7a` vào 1 file, đổi lại dung lượng lớn hơn (~35-40MB thay vì ~20MB). **Cố tình bỏ `x86_64`** ra khỏi bản universal — kiến trúc này gần như chỉ tồn tại trên máy ảo/emulator chứ không có trên điện thoại thật nào, giữ nó trong bản universal chỉ tổ tốn thêm ~1/3 dung lượng vô ích (ai thực sự cần vẫn tải file `x86_64` riêng bên dưới).

### 3 file split-per-abi (tùy chọn, nhẹ hơn — chỉ dùng khi biết chắc kiến trúc máy)
```
https://github.com/quangpromise/LearningEnglish/releases/download/latest/app-arm64-v8a-release.apk   (hầu hết điện thoại từ ~2017 trở lại)
https://github.com/quangpromise/LearningEnglish/releases/download/latest/app-armeabi-v7a-release.apk (máy đời cũ, chip 32-bit)
https://github.com/quangpromise/LearningEnglish/releases/download/latest/app-x86_64-release.apk      (máy ảo/tablet Intel)
```

Cũng có thể vào thẳng trang **[Releases](https://github.com/quangpromise/LearningEnglish/releases/tag/latest)** để xem cả 4 file + thời điểm build gần nhất.

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
