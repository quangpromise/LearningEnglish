---
name: apk-release
description: Build & ký file APK Android release cho app Learn English Through Music, kèm checklist trước phát hành và hướng dẫn host + cài đặt cho người dùng ngoài Google Play (sideload).
---

# Quy trình build & phát hành APK (sideload)

## 0. GitHub Actions build & phát hành — CHỈ khi người dùng đồng ý
Push vào `main` vẫn luôn chạy CI (analyze/format/test) như bình thường, nhưng
job "Build & Publish APK" (`.github/workflows/build-apk.yml`) có điều kiện
`if:` chỉ chạy khi: (a) người dùng tự bấm "Run workflow" (workflow_dispatch)
trên GitHub, HOẶC (b) commit message chứa `[build]`. **Claude chỉ được thêm
`[build]` vào commit message khi người dùng đã yêu cầu rõ ràng build/phát
hành bản mới** — không tự ý build sau mỗi lần sửa code, kể cả khi đã fix
xong 1 bug, trừ khi người dùng nói build/release/tải bản mới. Xem chi tiết
& link tải tại [`docs/ci-apk-distribution.md`](../../../docs/ci-apk-distribution.md).
Chỉ dùng các bước build thủ công dưới đây khi cần build ngay trên máy
(debug nhanh, không đợi CI) hoặc khi CI gặp sự cố.

## 1. Build APK debug để test nhanh (không cần keystore)
```bash
cd app
flutter build apk --debug
```
File ra tại `app/build/app/outputs/flutter-apk/app-debug.apk`.

> Lưu ý môi trường Windows nhiều ổ đĩa: nếu project nằm ở ổ khác với `PUB_CACHE`/Gradle cache (vd project ở D:, cache ở C:), Kotlin incremental compiler có thể lỗi "different roots". Đã tắt sẵn bằng `kotlin.incremental=false` trong `app/android/gradle.properties` — giữ nguyên dòng này nếu build lại từ máy khác gặp lỗi tương tự.

## 2. Tạo keystore ký release (chỉ làm 1 lần, giữ file này an toàn — mất là không update được app cũ)
```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```
Lưu file `.jks` **ngoài git** (đã có trong `.gitignore`: `*.jks`, `key.properties`). Tạo `app/android/key.properties`:
```
storePassword=<mật khẩu keystore>
keyPassword=<mật khẩu key>
keyAlias=upload
storeFile=<đường dẫn tuyệt đối tới file .jks>
```

## 3. Build APK release đã ký
```bash
cd app
flutter build apk --release
```
File ra tại `app/build/app/outputs/flutter-apk/app-release.apk`.

## 4. Checklist trước khi phát hành
- [ ] Test cài & chạy trên **thiết bị Android thật** (không chỉ emulator) — đặc biệt màn Luyện phát âm (cần quyền mic thật).
- [ ] Tăng `version`/`build number` trong `app/pubspec.yaml` (`version: x.y.z+build`).
- [ ] `flutter analyze` và `flutter test` sạch lỗi.
- [ ] Nhạc dùng trong bản build đã xác minh license theo `docs/research-music-libraries.md` (không còn dữ liệu mẫu/demo).
- [ ] Ghi chú thay đổi (changelog) cho bản phát hành.
- [ ] **Dung lượng APK**: mỗi khi thêm package mới, kiểm tra tác động dung
      lượng TRƯỚC khi merge — tải APK CI mới nhất, `unzip -l app-*.apk` xem
      thư mục `lib/<abi>/` có file `.so` nào bất thường lớn không (case thật
      đã gặp: `google_mlkit_translation` nhúng 1 file `libtranslate_jni.so`
      ~16MB, chiếm 44% APK). CI đã có bước tự cảnh báo khi APK > 22MB và
      **chặn build** khi > 30MB (xem `.github/workflows/build-apk.yml`) — nếu
      build bị chặn vì lý do chính đáng (tính năng thật sự cần), tăng
      ngưỡng `MAX_MB` trong workflow kèm ghi chú lý do, đừng lặng lẽ bỏ qua.

## 5. Host & hướng dẫn người dùng cài (sideload, không qua Google Play)
1. Tạo GitHub Release mới trong repo, đính kèm file `app-release.apk`:
   ```bash
   gh release create v1.0.0 app/build/app/outputs/flutter-apk/app-release.apk --title "v1.0.0" --notes "..."
   ```
2. Gửi link tải trực tiếp (`https://github.com/<owner>/<repo>/releases/download/v1.0.0/app-release.apk`) cho người dùng.
3. Hướng dẫn người dùng cài:
   - Mở link bằng trình duyệt trên điện thoại Android, tải file APK.
   - Khi cài, Android sẽ cảnh báo "Cài đặt ứng dụng ngoài Play Store bị chặn" → vào **Cài đặt → Bảo mật (hoặc Ứng dụng) → Cho phép cài từ nguồn này** cho trình duyệt/trình quản lý file đang dùng để mở file APK.
   - Mở lại file APK vừa tải, bấm **Cài đặt**.

## 6. Khi scale lên nhiều bản/nhiều người dùng
Cân nhắc chuyển sang host trên Cloudflare R2/S3 thay vì GitHub Releases nếu cần CDN nhanh hơn hoặc file lớn hơn giới hạn 2GB/asset của GitHub (thực tế APK nhỏ hơn nhiều nên GitHub Releases đủ dùng lâu dài).
