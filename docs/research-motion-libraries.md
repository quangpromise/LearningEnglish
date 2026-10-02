# Nghiên cứu: thư viện & nguồn asset motion graphics cho GymTalk

> **Ngày kiểm tra: 2026-10-02.** Mọi URL trong tài liệu được kiểm ngày này, trừ khi có ghi chú khác.
> Bối cảnh: Flutter 3.47 / Dart 3.13, Riverpod. Phát hành APK sideload trước, iOS sau. App **dùng thương mại**.
> Nhu cầu: celebration, mascot/coach động, progress ring + number ticker, streak flame, page/shared-element
> transition, animated background, karaoke lyric highlight, mic/voice visualisation, haptics.

## 0. Kết luận nhanh

| | Lựa chọn | Lý do chính |
|---|---|---|
| **Áp dụng 1** | **Flutter built-ins + `animations` ^2.2.0 (ghim, CHƯA lên 3.x) + `HapticFeedback`** | License BSD-3, gói chính chủ. Không thêm file `.so` native nào. Chạy được cả trên Skia lẫn Impeller. App đã đi đúng hướng này (ring, karaoke, celebration). Phủ được transition, ring/ticker, karaoke, mic visualiser, spring và haptics. |
| **Áp dụng 2** | **`lottie` ^3.6.1** + asset **Noto Animated Emoji (CC BY 4.0)**, thêm LottieFiles free khi cần | License MIT, pure Dart (không thêm `.so`), ra bản đều trong năm 2026. Có sẵn emoji động (fire, party popper, glowing star, clapping hands...) cho celebration và streak, tải tự do không cần đăng nhập. |
| **Áp dụng 3** (khi có người dựng) | **`rive` ^0.14.11** cho mascot/coach | Runtime MIT, bảo trì rất tích cực. State machine là lựa chọn thực tế nhất để mascot phản ứng theo mic hay theo câu trả lời đúng/sai. Chi phí: phải trả **Rive Cadet $9/seat/tháng (trả theo năm)** trong những tháng dựng file để xuất `.riv` **không có splash**. APK ước tính nặng thêm khoảng 4–5 MB. |
| **Tránh** | `animations` 3.x, `liquid_glass_renderer`, xuất file Rive bằng plan Free (có splash), `dotlottie_flutter`/`thorvg` (còn non), `flutter_animate` làm phụ thuộc lõi (ngừng cập nhật từ 11/2024), asset IconScout/Lordicon/useAnimations | Xem §6.3 |

**Ba cảnh báo riêng cho repo này** (chi tiết ở §1):
- (a) Impeller đang bị **TẮT** trong `AndroidManifest.xml`.
- (b) Rive đã đổi luật export **2 lần**: ngày 20/10/2025 và tháng 9/2026.
- (c) App **chưa có màn "Giấy phép mã nguồn mở"**.

---

## 1. Những điểm trong repo ảnh hưởng tới lựa chọn

1. **Impeller đang TẮT trên Android.** Chỗ cấu hình: `app/android/app/src/main/AndroidManifest.xml` dòng 61–67 (`io.flutter.embedding.android.EnableImpeller = false`).
   - Lý do ghi trong comment: nghi Impeller gây ra "kẻ vàng dưới mọi dòng text".
   - Triệu chứng này khớp với *fallback text style* của Flutter: Text không có tổ tiên `Material`/`DefaultTextStyle` sẽ bị gạch chân đôi màu vàng.
   - Chính `app/lib/core/theme/app_theme.dart` (dòng 354–372) đã xử lý đúng nguyên nhân này: bọc `Material(type: transparency)` và `DefaultTextStyle.merge(decoration: none)`.

   Hệ quả với motion:
   - `ImageFilter` dùng custom shader (backdrop tuỳ biến, "kính lỏng"...) **chỉ chạy trên Impeller**. Trên Skia nó ném lỗi ([docs fragment shaders](https://docs.flutter.dev/ui/design/graphics/fragment-shaders)).
   - Việc opt-out Impeller **đã bị Flutter đánh dấu deprecated**. Cảnh báo in ra: *"These options are going to go away in an upcoming Flutter release"* ([flutter#177975](https://github.com/flutter/flutter/issues/177975), Flutter 3.35.7).
   - Một bài trên Medium/gitconnected khẳng định Flutter 3.44 đã bỏ Skia trên Android 10+. **Chưa xác nhận được** điều này: release notes 3.44 không có mục nào như vậy. Trang [docs Impeller](https://docs.flutter.dev/perf/impeller) vẫn ghi *"enabled by default on Android API 29+"* và vẫn hướng dẫn cách opt-out.
   - iOS (giai đoạn 2) **chỉ có Impeller** từ Flutter 3.29: *"Skia support has been removed from the iOS backend and the `FLTEnableImpeller` opt-out flag no longer works"* ([blog 3.29](https://flutter.dev/blog/whats-new-in-flutter-3-29), 12/02/2025).

   → Nên thử bật lại Impeller trên máy thật, kể cả máy GPU Adreno đời thấp, và làm việc này song song với phần motion. Cho tới khi bỏ hẳn opt-out, mọi animation phải test trên **cả hai** renderer.

2. **APK là bản universal arm + arm64** (`.github/workflows/build-apk.yml` dòng 138). Vì vậy mọi thư viện có file `.so` native đều bị tính dung lượng **2 lần**.

3. **App đã có nhiều motion tự viết bằng built-in:**
   - `core/widgets/gt_celebration.dart`: hiệu ứng pop + glow, kèm `HapticFeedback.heavyImpact`.
   - `GtRingsPainter` trong `gt_today_screen.dart`.
   - `ShaderMask` cho karaoke trong `karaoke_lyrics.dart`.
   - Waveform vẽ bằng `CustomPainter` trong `center_media_button.dart`.
   - Đã tôn trọng `MediaQuery.maybeDisableAnimationsOf`.

   → Built-ins đã đáp ứng phần lớn nhu cầu. Chỉ cần thêm thư viện cho phần **asset dựng sẵn** (Lottie) và **nhân vật tương tác** (Rive).

4. **Ghi công:** `features/attribution/data/attribution_data.dart` hiện khoá theo `songTitle`, tức chỉ dành cho nhạc. Asset CC BY (Noto emoji, file Rive Marketplace) cần một danh sách riêng (ví dụ `kAssetAttributions`), cộng thêm một mục trong `ATTRIBUTION.md`.

5. **Chưa có màn license mã nguồn mở:** không có `showLicensePage`/`LicensePage` nào trong `app/lib`.
   - Flutter tự đóng gói file NOTICES (license của mọi package) vào APK, nhưng người dùng không xem được.
   - MIT/BSD/Apache đều yêu cầu giữ notice khi phân phối.
   - → Nên thêm một mục "Giấy phép mã nguồn mở" gọi `showLicensePage()`. Việc này áp dụng cho mọi package chứ không riêng motion, và tốn rất ít công.

6. **Tài liệu cũ đã lỗi thời:** `docs/research-ai-avatar-lipsync.md` có hai chỗ sai so với hiện tại. Lượt này không sửa file đó.
   - Ghi "Lottie-Flutter: Apache 2.0/MIT tùy fork" → thực tế `lottie` là **MIT**.
   - Ghi "plan Free chỉ cho học/thử" → thực tế đã thay đổi, xem §3.

---

## 2. Bảng so sánh — runtime / package

| Package (bản mới nhất · ngày ra) | License | Thương mại? | Ghi công? | Bảo trì (10/2026) | Size / hiệu năng | Nguồn (kiểm 2026-10-02) |
|---|---|---|---|---|---|---|
| **`rive` 0.14.11** · 2026-08-03 (kèm `rive_native` 0.1.11 · 2026-08-03). Bản dev: `0.15.0-dev.3` / `rive_native 0.2.0-dev.3` · 2026-09-28 | MIT (© 2020 Rive; `rive_native` © 2024 Rive) | **Có** với runtime. Riêng file `.riv` còn tuỳ plan của editor (xem §3) | Không, chỉ cần giữ MIT notice | **Rất tích cực.** 12 bản 0.14.x kể từ 0.14.0 (17/11/2025). Publisher verified `rive.app` | C++ runtime + Rive Renderer qua FFI; chọn renderer `Factory.rive` hoặc `Factory.flutter`. **Chưa có số size chính thức cho Flutter.** Rive Android runtime (01/2026): arm64 2,40 MB tải / 7,03 MB cài, armv7 2,32 / 6,00 MB → APK arm+arm64 **ước +~4,7 MB tải** (phải đo). Lúc build sẽ tải binary từ `rive-flutter-artifacts.rive.app` | [pub rive](https://pub.dev/packages/rive), [versions](https://pub.dev/packages/rive/versions), [pub rive_native](https://pub.dev/packages/rive_native), [runtime sizes](https://rive.app/docs/runtimes/runtime-sizes) |
| **`lottie` 3.6.1** · 2026-09-18 | MIT. File LICENSE còn để nguyên placeholder `Copyright (c) [year] [fullname]`; package là *"unofficial conversion of the Lottie-android library"* (lottie-android dùng Apache-2.0) | **Có** | Không, chỉ cần giữ notice | **Tích cực.** 3.3.3 (04/2026) → 3.4.0 (06) → 3.5.x (07) → 3.6.1 (09). Publisher verified `xaha.dev`; 139 issue đang mở | Pure Dart, không có `.so`. Vẽ trên Canvas nên file phức tạp sẽ tốn CPU. `renderCache: raster` *"most efficient to render but will use the most memory"*, chỉ hợp với animation rất ngắn/nhỏ. `drawingCommands` lưu `Picture`, bớt việc cho CPU. Từ 3.5–3.6, tick được giới hạn theo frame rate của chính file. Đọc `.lottie` chỉ qua custom decoder | [pub lottie](https://pub.dev/packages/lottie), [changelog](https://pub.dev/packages/lottie/changelog), [RenderCache](https://pub.dev/documentation/lottie/latest/lottie/RenderCache-class.html), [repo](https://github.com/xvrh/lottie-flutter) |
| `dotlottie_flutter` 0.1.7 · 2026-08-17 (bản đầu 2025-11-21) | MIT, chính chủ `lottiefiles.com` | Có | Không | Mới, còn 0.x. 11 likes, ~15,8k downloads | Native (dotlottie-rs/ThorVG) nên thêm `.so`. Android phải khai báo thêm repo **jitpack**. Có state machine/theming của dotLottie. Cần Flutter ≥3.44 | [pub](https://pub.dev/packages/dotlottie_flutter), [repo](https://github.com/LottieFiles/dotlottie-flutter) |
| `thorvg` 1.1.0 · 2026-07-27 | MIT, `thorvg.org` | Có | Không | Gần như không ai dùng (54 downloads) | Native, chỉ Android/iOS, chỉ hỗ trợ Lottie | [pub](https://pub.dev/packages/thorvg) |
| `flutter_animate` 4.5.2 · 2024-11-25 | BSD-3-Clause, `gskinner.com` | Có | Không | **Đã ngừng hoạt động.** Commit cuối 25/11/2024; 34 issue mở, các issue năm 2026 không có phản hồi | Pure Dart, kèm `flutter_shaders` 0.1.3 (09/2024). File lõi `animate.dart` chỉ import `widgets.dart` | [pub](https://pub.dev/packages/flutter_animate), [commits](https://github.com/gskinner/flutter_animate/commits/main), [issues](https://github.com/gskinner/flutter_animate/issues) |
| **Flutter SDK built-ins**: implicit/explicit animation, `Hero`, `AnimatedSwitcher`, `TweenAnimationBuilder`, `CustomPainter`, `ShaderMask`, `SpringSimulation` + `SpringDescription.withDurationAndBounce` (có từ 3.32), `FragmentProgram` | BSD-3 (Flutter) | **Có** | Không (NOTICES được tự đóng gói) | Theo nhịp Flutter | Không thêm dung lượng nào. Shader thường (`Paint.shader`) chạy trên cả hai renderer. **`ImageFilter` dùng custom shader chỉ chạy trên Impeller.** Từ 3.44 bind được uniform theo tên | [docs animations](https://docs.flutter.dev/ui/animations), [fragment shaders](https://docs.flutter.dev/ui/design/graphics/fragment-shaders), [SpringDescription](https://api.flutter.dev/flutter/physics/SpringDescription-class.html) |
| **`animations` 2.2.0** · 2026-04-23 / 3.0.0 · 2026-08-19 | BSD-3 (© 2013 The Flutter Authors), `flutter.dev` | **Có** | Không | Chính chủ, tích cực | Pure Dart. Có container transform (`OpenContainer`), shared axis, fade through, fade. **Bản 3.0.0 "Migrates to material_ui"** (phụ thuộc `material_ui ^1.0.0`, cần Flutter ≥3.44) → **ghim ^2.2.0**, lý do ở §5.4 | [pub](https://pub.dev/packages/animations), [changelog](https://pub.dev/packages/animations/changelog) |
| `material_ui` 1.5.0 · 2026-09-28 (bản đầu 0.0.1 · 2026-02-18) | BSD-3 (© 2013 The Flutter Authors), `flutter.dev` | Có | Không | Chính chủ, phát hành độc lập với SDK (blog 3.47: có thể cập nhật hằng tuần) | 1.2.0 thêm `StyleVariant` (M3 / M3 Expressive); 1.5.0 thêm M3 Expressive cho `IconButton`. **Chưa có motion scheme/spring.** Muốn dùng phải migrate toàn app | [pub](https://pub.dev/packages/material_ui), [changelog](https://pub.dev/packages/material_ui/changelog) |
| `motor` 1.1.0 · 2025-12-02 | MIT, `whynotmake.it` (verified) | Có | Không | Repo vẫn có commit tới 23/07/2026 | Pure Dart. Có `SpringMotion`, `CupertinoMotion`, `MaterialSpringMotion` (token spring M3), `MotionBuilder` | [pub](https://pub.dev/packages/motor), [commits](https://github.com/whynotmake-it/rivership/commits/main/packages/motor) |
| `liquid_glass_renderer` 0.2.0-dev.4 · 2025-11-13 | MIT, `whynotmake.it` | Có | Không | Vẫn pre-release, khoảng 11 tháng chưa ra bản mới | README: *"still experimental and should not be blindly added to production apps"*, **"Skia is unsupported"**; chỉ chạy Android/iOS/macOS | [pub](https://pub.dev/packages/liquid_glass_renderer) |
| `confetti` 0.8.0 · 2024-09-28 | MIT. LICENSE ghi "© 2018 Felix Angelov", có vẻ copy từ mẫu | Có | Không | **Ít bảo trì.** Commit cuối 28/09/2024; 25 issue + 9 PR đang mở. Verified `funwith.app`, 1,64k likes | Pure Dart. README: *"Don't be greedy with the number of particles"* | [pub](https://pub.dev/packages/confetti), [commits](https://github.com/funwithflutter/flutter_confetti/commits/master) |
| `flutter_confetti` 0.9.2 · 2026-07-31 | MIT (© 2024 tao-zhi-1992), lấy cảm hứng từ canvas-confetti (ISC) | Có | Không | Tích cực, 1 issue mở. Uploader **chưa verified**; 158 likes | Pure Dart, gọi qua API `Confetti.launch()` | [pub](https://pub.dev/packages/flutter_confetti), [repo](https://github.com/tao-zhi-1992/flutter_confetti) |
| `newton_particles` 0.4.1 · 2026-03-22 | MIT, `7omtech.fr` | Có | Không | Tích cực | Phụ thuộc `chipmunk2d_physics_ffi` (native), quá nặng so với nhu cầu | [pub](https://pub.dev/packages/newton_particles) |
| `animated_flip_counter` 0.3.4 · 2024-04-02 | MIT (© 2021 h65wang) | Có | Không | Ít cập nhật | Widget nhỏ, tự viết bằng built-in cũng được | [pub](https://pub.dev/packages/animated_flip_counter) |
| **`HapticFeedback`** (built-in, thư viện `services`) | BSD-3 | **Có** | Không | Theo nhịp Flutter | Có thêm `successNotification` / `warningNotification` / `errorNotification`. Trên Android: `heavyImpact` dùng `CONTEXT_CLICK` (API 23+); `successNotification` dùng `CONFIRM` (API 30+), **dưới API 30 thì không rung**. Dùng `View.performHapticFeedback` nên **không cần quyền `VIBRATE`** | [HapticFeedback](https://api.flutter.dev/flutter/services/HapticFeedback-class.html), [successNotification](https://api.flutter.dev/flutter/services/HapticFeedback/successNotification.html), [Android haptics](https://developer.android.com/develop/ui/views/haptics/haptics-apis) |
| `vibration` 3.2.1 · 2026-09-02 | BSD-2-Clause (© 2018 Benjamin Dean) | Có | Không | Tích cực. Uploader chưa verified; 941 likes | **Bắt buộc** thêm `android.permission.VIBRATE`. Hỗ trợ pattern và amplitude 1–255 (Android 8+) | [pub](https://pub.dev/packages/vibration) |
| `gaimon` 1.5.0 · 2026-08-30 | MIT, `dimitridessus.fr` (verified) | Có | Không | Tích cực | Có sẵn preset haptic, hỗ trợ pattern AHAP (iPhone 8+; trên Android chuyển thành waveform) | [pub](https://pub.dev/packages/gaimon) |

---

## 3. Rive Editor — các plan và luật export (câu hỏi "Free có xuất `.riv` cho app thương mại được không?")

**Hiện trạng theo [rive.app/pricing](https://rive.app/pricing) (2026-10-02):**

| Plan | Giá | Export | Ghi chú |
|---|---|---|---|
| Free | $0 | *"Export .riv files with a splash screen"* | *"Build and ship with a Rive splash screen."* / *"Free exports play a Rive splash screen. Upgrade to remove it."* Giới hạn 3 collaborative files |
| **Cadet** | **$9/seat/tháng** | *"Export .riv files without the splash screen"*, không giới hạn số file | Tối đa 3 seat. Thông báo 10/2025 ghi $9 là giá **trả theo năm**; nguồn thứ cấp ([rivemasterclass](https://www.rivemasterclass.com/updates/export-now-requires-paid-plan)) ghi trả theo tháng là **$17** |
| Voyager | $32/seat/tháng | Như Cadet | Tối đa 25 seat |
| Enterprise | $120/seat/tháng | Như Cadet | Bắt buộc nếu doanh thu tổ chức > 10 triệu USD/năm (ToS) |

**Rive đã đổi luật 2 lần trong 2025–2026:**
1. **Trước 20/10/2025:** plan Free xuất được file runtime.
2. **06/10/2025 thông báo, 20/10/2025 có hiệu lực** ([Threads 06/10](https://www.threads.com/@rive.app/post/DPejYJNEmv7/cadet-unlimited-exports-premium-features-for-9mo-annual-exporting-files-to-use-i), [Threads 20/10](https://www.threads.com/@rive.app/post/DQCYKsKkW7A/the-editor-stays-free-for-everyone-to-explore-and-learn-fonts-and-audio-are-now-)):
   - Export chuyển sang plan trả phí; Cadet $9/tháng (trả theo năm).
   - *"Runtimes remain open-source under MIT"*.
   - *"No runtime fee. Your exports keep working forever."*
3. **Tháng 9/2026, cùng lúc ra Rive CLI technical preview:**
   - CEO Guido Rosso, khoảng 02/09/2026 ([X](https://x.com/guidorosso/status/2095174568189239611)): *"Free to create, free to export with a Rive splash screen, upgrade to remove the splash screen. No royalties either way, ever. The same model is coming to the editor soon after."*
   - Tài khoản Rive, khoảng 10/09/2026 ([X](https://x.com/rive_app/status/2098199130778857914)): *"Files published on the Free plan play a short Rive splash screen before your content… The editor is moving to the same model soon."*
   - Ghi chú: X chặn tải trực tiếp. Nội dung lấy từ snippet tìm kiếm; ngày suy ra từ ID bài viết.
   - Docs CLI ([getting started](https://rive.app/docs/cli/getting-started)): *"`--publish` may add a watermark… A clean `.riv` needs… that file in a workspace on the Cadet plan or higher."*

**Kết luận cho GymTalk:**
- Runtime miễn phí (MIT), không runtime fee, không royalty.
- Muốn ship mascot **không có splash** thì bắt buộc ≥ Cadet, nhưng chỉ cần trả trong những tháng dựng/xuất file, vì file đã xuất *"keep working forever"*.
- Splash của plan Free trước mỗi animation UI là không chấp nhận được → **coi như plan Free không dùng được cho production**.

**Điều khoản ToS cần nhớ** ([ToS](https://rive.app/docs/legal/terms-of-service), cập nhật lần cuối 20/05/2026):
- *"Creation of a Team requires you to purchase a subscription"*.
- Doanh thu > 10 triệu USD thì bắt buộc Enterprise.
- *"we will delete your profile and your User Content approximately 90 days after cancellation or termination"* → **phải lưu file nguồn `.rev` vào repo**.

Thêm một điểm từ docs CLI (không thuộc ToS): file có Rive Scripting chạy trên web phải `--publish` để được ký qua API của Rive — *"Unsigned scripts are rejected by the CDN and the web runtimes"*.

---

## 4. Bảng so sánh — nguồn asset animation

| Nguồn | License | Thương mại? | Ghi công? | Hạn chế chính / ghi chú | Nguồn (kiểm 2026-10-02) |
|---|---|---|---|---|---|
| **Noto Animated Emoji** (Google) | **CC BY 4.0**: *"The artwork is available under the CC BY 4.0 license."* | **Có** | **Bắt buộc** | Có Lottie JSON, đã kiểm có các mã: fire `1f525` (~65 KB, 60 fps, 1024², bodymovin 5.8.1), party popper `1f389`, glowing star `1f31f`, star `2b50`, clapping hands `1f44f`, star-struck `1f929`, hundred points `1f4af`. **Không có** trophy `1f3c6`. Tải trực tiếp từ `fonts.gstatic.com`, không cần tài khoản. Google chưa công bố mẫu ghi công ([google/fonts#7011](https://github.com/google/fonts/issues/7011) không có ai trả lời) → dùng mẫu TASL chuẩn của CC | [Google Developers Blog 13/09/2022](https://developers.googleblog.com/updates-to-emoji-new-characters-new-animation-new-color-customization-and-more/), [noto-emoji-animation](https://googlefonts.github.io/noto-emoji-animation/), [danh sách api.json](https://googlefonts.github.io/noto-emoji-animation/data/api.json), [ví dụ fire](https://fonts.gstatic.com/s/e/notoemoji/latest/1f525/lottie.json) |
| **LottieFiles – animation free/public** | **Lottie Simple License** (FL 9.13.21) | **Có**: *"Allowed in business projects, websites, and apps"* | **Không bắt buộc**, chỉ *"highly encouraged"*; gợi ý *"Animation by [Creator Name] from LottieFiles"* | Các điều cấm: *"compile or scrape animations to create a competing service"*, *"redistribute as standalone animation files"*, *"resell the original animation files"*. Khi phân phối thì file vẫn phải *"subject to the same terms"*; bản sửa đổi giữ cùng license. *"Always check the specific license on each animation page"*. **Workspace free chỉ tải được 5 animation public, không bao giờ reset** (bài cập nhật 04/09/2026) | [license](https://lottiefiles.com/page/license) (bị 403), [Licensing Basics 16/01/2026](https://help.lottiefiles.com/animation-licensing-basics-), [Attribution 19/01/2026](https://help.lottiefiles.com/hc/en-us/articles/900002475966-how-do-i-give-attribution-for-a-lottie-animation-i-ve-used), [giới hạn free](https://help.lottiefiles.com/hc/en-us/articles/16240626895385-File-Upload-and-Download-Limits-on-Free-Workspace) |
| LottieFiles – Premium | Premium license | Có | Không | *"reselling or redistributing the animations is not permitted"*. Phải có plan trả phí mới tải được; giá chưa xác minh (trang pricing bị 403) | [Premium Animations 19/01/2026](https://help.lottiefiles.com/hc/en-us/articles/24484503354137-Premium-Animations) |
| **Rive Community / Marketplace** | **CC BY 4.0**: *"Marketplace files are all shared under a CC BY license"*; ToS: *"…under the creative commons license described at …/by/4.0/"* | Có | **Bắt buộc** | Sau khi remix vào account, lúc export vẫn chịu luật plan (Free có splash). Người đăng có thể **không sở hữu toàn bộ nội dung** (fan art, logo thương hiệu); CC BY chỉ cấp phần họ thật sự sở hữu — cùng bài học với lyric trong CLAUDE.md | [Marketplace overview](https://rive.app/docs/community/marketplace-overview), [ToS 20/05/2026](https://rive.app/docs/legal/terms-of-service) |
| Kenney Particle Pack | **CC0** | Có | Không | 80 texture particle/VFX 512×512, dùng làm sprite cho confetti/sparkle (xem trang để biết danh sách file) | [kenney.nl/assets/particle-pack](https://kenney.nl/assets/particle-pack) |
| IconScout | **Chưa xác minh**: trang license trả 403, các nguồn thứ cấp mâu thuẫn nhau về việc asset free có bắt buộc ghi công hay không | ? | ? | Điều khoản theo từng item. `research-3d-icons.md` cũng đã loại nguồn này | [iconscout.com/licenses](https://iconscout.com/licenses) (bị 403) |
| Lordicon (free) | License free riêng của Lordicon | Có | **Bắt buộc** | Cấm dùng khi icon là *"the core of that product"*; cấm phân phối lại/bán lại; user free giới hạn 1 collection; không cho tải hàng loạt | [lordicon.com/docs/license/free](https://lordicon.com/docs/license/free) |
| useAnimations | LICENSE ghi *"Creative Commons (CC) Attribution (BY)"* kèm điều khoản riêng. **Không phải MIT** như vài blog ghi | Có | **Bắt buộc** (*"attribute or link to useanimations.com"*) | Cấm phân phối lại/bán lại | [LICENSE](https://github.com/useAnimations/react-useanimations) |
| Tự dựng (Rive Editor, hoặc thuê animator) | Thuộc sở hữu dự án | Có | Không | Rive phải ≥ Cadet để xuất không splash. Thuê ngoài thì hợp đồng phải ghi rõ chuyển quyền/cho phép dùng thương mại và **giao cả file `.rev`** | — |

---

## 5. Ghi chú chi tiết

### 5.1 Rive
- **Runtime hiện tại:**
  - Từ 0.14.0 (17/11/2025), toàn bộ runtime Dart được thay bằng C++ runtime qua `rive_native`: *"The majority of the new runtime code now lives in the rive_native package."*
  - Bản 0.13.x cuối cùng là 0.13.20 (02/12/2024).
- **Nhánh 0.15 sắp tới:**
  - Bản dev mới nhất là `0.15.0-dev.3` (28/09/2026). Migration guide mô tả 0.15: *"Data Binding binds when you create a controller, and the Rive Renderer uses deferred rendering on native platforms"*.
  - Docs ghi: *"expect changes before the stable release"* ([migration guide](https://rive.app/docs/runtimes/flutter/migration-guide)).
  - → Nên bắt đầu trên 0.14.x stable và lên kế hoạch migrate khi 0.15 ra bản stable.
- **Impeller:**
  - README/docs: *"there is a possibility of rendering and performance discrepencies when using the Rive Flutter runtime with platforms that use the Impeller renderer"*. Rive khuyên test lại bằng `--no-enable-impeller` ([docs Flutter runtime](https://rive.app/docs/runtimes/flutter/flutter)).
  - `Factory.rive` vẽ bằng Rive Renderer vào texture riêng (cần nó cho vector feathering). `Factory.flutter` vẽ thẳng vào canvas của Flutter.
  - Cả hai renderer đều chạy được khi app đang dùng Skia.
- **Build và CI:**
  - Native lib *"should be automatically downloaded during the build step"*, tải từ `https://rive-flutter-artifacts.rive.app/...`. Đã có báo cáo lỗi hash verification khi tải ([rive-flutter#589](https://github.com/rive-app/rive-flutter/issues/589), 12/2025, vẫn mở lúc kiểm).
  - → CI phụ thuộc thêm một CDN bên ngoài. Có thể tự build bằng `dart run rive_native:setup --build`.
- **Size:** Rive không công bố số riêng cho Flutter, nên phải đo bằng `flutter build apk --analyze-size --target-platform android-arm64`. File `.riv` cho mascot thường từ vài chục đến vài trăm KB (ước tính, cần đo).

### 5.2 Lottie & LottieFiles
- **`lottie` (xvrh):**
  - Pure Dart, *"supports the same feature set as Lottie Android"*.
  - Cảnh báo hiệu năng trên Impeller-Android:
    - [flutter#137423](https://github.com/flutter/flutter/issues/137423): nhiều ảnh Lottie đã cache chạy chậm trên Vulkan, đóng với lý do "not planned".
    - [flutter#176211](https://github.com/flutter/flutter/issues/176211): crash Vulkan trên GPU Adreno, đóng vì trùng #175562.
  - → Ưu tiên file **thuần vector** (không nhúng ảnh raster). Mỗi màn chỉ nên có ít instance. `RenderCache.raster` chỉ dùng cho animation nhỏ/ngắn.
- **dotLottie:**
  - `lottie` chỉ đọc được JSON bên trong file `.lottie` qua decoder tự viết.
  - Muốn dùng state machine/theming của dotLottie thì phải dùng `dotlottie_flutter` (còn non, xem §2).
- **Lottie Simple License:**
  - Trang gốc chặn fetch tự động (403). Nội dung đối chiếu từ snippet tìm kiếm của chính trang đó và từ Help Center của LottieFiles.
  - Nội dung cấp quyền: *"download, reproduce, modify, publish, distribute, publicly display, and publicly digitally perform … including for commercial purposes, provided that any … distribution of Files must contain (and be subject to) the same terms"*. Kèm hai giới hạn: không được áp điều khoản hay biện pháp kỹ thuật hạn chế thêm, và không được gom file để dựng dịch vụ cạnh tranh.
  - Cách hiểu cho app: **nhúng file vào UI = "use in your products"** → được phép. **Không** làm tính năng cho người dùng tải/xuất file animation gốc ("standalone"). Ghi tên file + license vào `ATTRIBUTION.md` để chứng minh nguồn, dù license không bắt buộc ghi công.

### 5.3 `flutter_animate`
- Cú pháp rất gọn: `.animate().fadeIn().slide()`.
- Nhưng **không có commit nào trong 22 tháng**, issue mới năm 2026 (ví dụ "Flutter Widget Preview does not work", 22/02/2026) không ai xử lý.
- Rủi ro thấp vì là pure Dart và file lõi chỉ import `widgets.dart`. Tuy vậy, nếu Flutter thay đổi API thì sẽ không có ai vá.
- → Không đưa vào làm nền tảng. Nếu nhóm thực sự muốn dùng thì chỉ dùng ở widget lá và sẵn sàng fork (license BSD-3 cho phép).

### 5.4 Built-ins, `animations`, Impeller/shader, spring, M3 Expressive
- **`animations` 3.x và `material_ui`:**
  - Flutter 3.44 đóng băng thư viện Material/Cupertino trong framework.
  - Flutter 3.47 ra `material_ui`/`cupertino_ui` 1.0; một bản stable tới sẽ deprecate `package:flutter/material.dart`.
  - Docs nói rõ: *"Types from `package:flutter/material.dart` and `package:material_ui` are **different types**"* ([breaking change](https://docs.flutter.dev/release/breaking-changes/material-ui-and-cupertino-ui)).
  - App hiện import `package:flutter/material.dart`. Nếu lên `animations` 3.0.0, các API dùng kiểu Material (ví dụ `SharedAxisPageTransitionsBuilder` đặt trong `PageTransitionsTheme`) có thể lệch kiểu.
  - → **Ghim `animations: ^2.2.0`.** Chỉ lên 3.x **cùng lúc** với việc migrate cả app (`dart fix --apply --code=migrate_design_widgets`).
- **Shader:**
  - *"Both the Skia and Impeller backends support writing custom shaders"*, nhưng *"The `ImageFilter` API for custom shaders is only supported by the Impeller backend"*.
  - Trên Skia, shader được biên dịch lúc chạy → cần precache `FragmentProgram` để tránh giật lần đầu.
  - Flutter 3.44 thêm bind uniform theo tên và cảnh báo khi shader không tương thích Skia. Flutter 3.47 bỏ nhu cầu tự lật toạ độ texture trên OpenGLES ([blog 3.44](https://flutter.dev/blog/whats-new-in-flutter-3-44), [blog 3.47](https://flutter.dev/blog/whats-new-in-flutter-3-47)).
- **Spring:**
  - `SpringDescription.withDurationAndBounce` (có từ Flutter 3.32, [PR #164411](https://github.com/flutter/flutter/pull/164411)) cho kết quả tương đương `spring(duration:bounce:)` của SwiftUI.
  - Kết hợp `AnimationController.animateWith(SpringSimulation(...))` là đủ cho nút bấm "nảy" hay card snap.
- **Material 3 Expressive:**
  - Flutter **chưa có motion M3E chính thức**. Umbrella issue [flutter#168813](https://github.com/flutter/flutter/issues/168813) ghi: *"All new work for Material 3 Expressive will happen in the new packages"*.
  - Tính tới `material_ui` 1.5.0, mới có `StyleVariant` và `IconButton` M3E, chưa có spring/motion scheme.
  - Các package cộng đồng kiểu `material_3_expressive` là không chính chủ → không dùng. Nếu cần token spring M3 thì `motor` (`MaterialSpringMotion`) là lựa chọn đáng tin nhất.

### 5.5 Confetti / particles
- `confetti` phổ biến nhất nhưng đã ngủ từ 09/2024. `flutter_confetti` còn được cập nhật (07/2026) nhưng uploader chưa verified. Cả hai đều pure Dart, MIT.
- Có hai lựa chọn rẻ hơn mà không phải thêm package:
  - Dùng Lottie party popper (`1f389`) của Noto.
  - Tự viết particle bằng `CustomPainter` + `AnimationController` (khoảng 100–150 dòng), dùng sprite CC0 của Kenney, tô theo màu token `gold`/accent của design system.

### 5.6 Haptics
- Built-in `HapticFeedback` đủ cho celebration, đúng/sai và chọn đáp án; app đã dùng `heavyImpact`. Có hai điểm cần xử lý:
  - `successNotification`/`warningNotification`/`errorNotification` **không rung dưới Android API 30** → cần fallback sang `heavyImpact`/`mediumImpact`.
  - Rung có thể bị tắt theo cài đặt "touch feedback" của hệ thống hoặc `View.hapticFeedbackEnabled`, đây là hành vi đúng.
- Chỉ cân nhắc `vibration` (thêm quyền `VIBRATE`) khi muốn **rung theo pattern/beat nhạc**.
- `gaimon` (AHAP) để dành cho giai đoạn iOS.

### 5.7 Lựa chọn mới 2025–2026
- **Có thật và còn bảo trì:**
  - `motor` (spring/motion thống nhất).
  - `dotlottie_flutter` (Lottie chính chủ, có state machine) — nên theo dõi tới khi lên 1.0.
  - `material_ui` (M3 Expressive sẽ đi vào đây).
- **Có thật nhưng không nên dùng:**
  - `liquid_glass_renderer`: experimental, chỉ chạy trên Impeller, mà app đang tắt Impeller.
  - `thorvg` Flutter: gần như không ai dùng.

---

## 6. Khuyến nghị

### 6.1 Ánh xạ nhu cầu → giải pháp

| Nhu cầu | Giải pháp | Ghi chú |
|---|---|---|
| Celebration (xong bài/lên level) | Giữ `gt_celebration.dart`, thêm Lottie Noto: party popper `1f389`, glowing star `1f31f`, hundred points `1f4af`. Thêm particle tự viết hoặc `flutter_confetti`, kèm `HapticFeedback.successNotification` (fallback `heavyImpact` khi < API 30) | Bộ Noto **không có** trophy. Tôn trọng `disableAnimations` như code hiện tại |
| Mascot/coach động | **Rive** state machine. Input gợi ý: `listening`/`talking`/`happy`/`sad`, và `mouthOpen` (number) lấy từ amplitude mic/TTS | Mua Cadet trong tháng dựng; backup `.rev` vào repo |
| Progress ring, number ticker | `TweenAnimationBuilder` + `CustomPainter` (đã có `GtRingsPainter`). Ticker dùng `TweenAnimationBuilder<int>` hoặc `AnimatedSwitcher`, kèm `FontFeature.tabularFigures()` nếu font hỗ trợ | Không cần package |
| Streak flame | Lottie fire `1f525` của Noto (CC BY 4.0, ~65 KB). Sau này nếu cần lửa theo thương hiệu, có input "cường độ" theo độ dài streak, thì làm bằng Rive | Ghi công Noto |
| Page/shared-element transition | `Hero` + `animations` ^2.2.0 (`OpenContainer`, `SharedAxisTransition`, `FadeThroughTransition`) | Ghim < 3.0.0 |
| Animated background | `FragmentProgram` qua `CustomPainter` (chạy cả Skia/Impeller) hoặc gradient chạy bằng `AnimationController`. **Tránh** `ImageFilter` dùng shader khi Impeller đang tắt | Dừng khi khuất màn hình (`TickerMode`); precache shader |
| Karaoke highlight | `ShaderMask` (đã có) với gradient stops chạy theo tiến độ từng từ; glow bằng `TextStyle.shadows` | Không cần package |
| Mic/voice visualisation | `record` → `AudioRecorder.onAmplitudeChanged(interval)` (dBFS) hoặc `speech_to_text` → `onSoundLevelChange`, vẽ bằng `CustomPainter` (bars/blob), hoặc đưa vào input của Rive | Cả hai package đã có trong `pubspec.yaml`. Giá trị Android của `onSoundLevelChange` chưa có tài liệu (theo docs) → cần chuẩn hoá |
| Spring/physics | `SpringDescription.withDurationAndBounce`; dùng `motor` nếu muốn token M3/Cupertino có sẵn | — |

### 6.2 Áp dụng (2–3 lựa chọn)
1. **Flutter built-ins + `animations` ^2.2.0 + `HapticFeedback`.**
   - Không có rủi ro license (BSD-3 chính chủ), không tốn MB.
   - Không phụ thuộc renderer, không phụ thuộc bên thứ ba bỏ dở.
   - Đúng phong cách code hiện có, dễ chia việc theo feature.
2. **`lottie` ^3.6.1 + Noto Animated Emoji (+ LottieFiles free có chọn lọc).**
   - Là cách rẻ nhất để có asset "đã đánh bóng".
   - Pure Dart, MIT, ra bản đều tay.
   - Noto tải tự do và rõ CC BY 4.0. LottieFiles không bắt buộc ghi công, nhưng workspace free chỉ tải được **5 file trọn đời** → chọn kỹ, hoặc trả phí 1 tháng khi cần tải nhiều.
3. **`rive` ^0.14.11 — chỉ cho mascot/coach, và chỉ khi có người dựng.**
   - Là lựa chọn duy nhất có state machine + data binding ổn định cho nhân vật phản ứng realtime. Khớp với hướng đã chọn trong `research-ai-avatar-lipsync.md`.
   - Đổi lại: khoảng +4–5 MB APK (cần đo), CI phụ thuộc CDN của Rive, và trả Cadet trong thời gian dựng.

### 6.3 Tránh
- **`animations` 3.x:** lệch kiểu với `package:flutter/material.dart` cho tới khi app migrate sang `material_ui`.
- **`liquid_glass_renderer`:** tác giả tự nhận experimental, không chạy trên Skia, pre-release đã ~11 tháng.
- **Xuất Rive bằng plan Free:** splash bắt buộc trước nội dung.
- **File Rive Marketplace / LottieFiles chưa kiểm tính nguyên gốc:** có nguy cơ fan art hoặc logo thương hiệu.
- **`dotlottie_flutter`, `thorvg`:** quá non (0.x, ít người dùng, thêm `.so` và jitpack). Xem lại khi `dotlottie_flutter` lên 1.0.
- **`flutter_animate` làm phụ thuộc lõi:** ngừng bảo trì từ 11/2024.
- **`confetti`:** ngủ từ 09/2024. Nếu cần package thì chọn `flutter_confetti`, ghim đúng version.
- **`newton_particles`:** kéo theo native physics FFI, quá mức cần thiết.
- **`vibration`/`gaimon` ở giai đoạn này:** built-in đã đủ, còn tránh được thêm quyền `VIBRATE`.
- **Asset IconScout** (không xác minh được), **Lordicon** (bắt buộc ghi công + hạn chế), **useAnimations** (CC BY + hạn chế).
- **Package M3 Expressive cộng đồng:** chờ `material_ui`.

### 6.4 Chi phí thực tế

| Hạng mục | Chi phí |
|---|---|
| Built-ins, `animations`, `lottie`, Noto, Kenney, `HapticFeedback` | $0 |
| LottieFiles | $0 nếu ≤ 5 file. Giá plan trả phí **chưa xác minh** được (pricing bị 403) |
| Rive | Runtime $0. Editor Cadet **$9/seat/tháng (trả năm, ~$108/năm)** hoặc ~$17 nếu trả theo tháng (nguồn thứ cấp). Chỉ cần 1 seat cho người dựng, trong những tháng dựng/xuất. Không runtime fee, không royalty |

---

## 7. Điểm mơ hồ / chưa xác minh — cần nhớ khi quyết định

1. **Rive Free:**
   - Trang pricing (02/10/2026) ghi Free *"Export .riv files with a splash screen"*.
   - Docs [Exporting for Runtime](https://rive.app/docs/editor/exporting/exporting-for-runtime) lại vẫn ghi *"Exporting for runtime is available on paid plans."*
   - Bài X ngày ~10/09/2026 nói editor *"moving to the same model soon"*.
   - → Hai nguồn **chính chủ không nhất quán**. Trong mọi trường hợp, plan Free đều không dùng được cho production.
2. **Giá Cadet trả theo tháng ($17)** chỉ thấy trong nguồn thứ cấp và thông báo năm 2025. Trang pricing hiện chỉ hiện "$9/seat/mo".
3. **Size `rive_native`:** chưa có số chính thức cho Flutter. Con số +~4,7 MB là ước tính từ runtime Android native của Rive.
4. **Trang Lottie Simple License** trả 403 với công cụ fetch. Nội dung lấy từ snippet tìm kiếm và Help Center chính chủ. Câu *"must contain (and be subject to) the same terms"* và câu cấm "standalone" có thể hiểu theo nhiều cách → không cho người dùng tải file gốc, và ghi rõ license trong `ATTRIBUTION.md`.
5. **License của `lottie`:**
   - File LICENSE là MIT nhưng copyright để trống (`[year] [fullname]`).
   - Package lại là bản port của lottie-android (Apache-2.0).
   - Rủi ro thấp vì cả hai đều permissive. Cách xử lý: có màn license (`showLicensePage`); có thể thêm notice Apache của lottie-android qua `LicenseRegistry.addLicense`.
6. **LICENSE của `confetti`** ghi tên "Felix Angelov", không phải tác giả package. Có vẻ là copy mẫu; vẫn là MIT.
7. **Impeller:**
   - Chưa xác nhận được việc "Skia bị bỏ trên Android 10+ từ 3.44" (chỉ có bài Medium nói vậy).
   - Chắc chắn: opt-out đã deprecated.
   - [flutter#192467](https://github.com/flutter/flutter/issues/192467) (3.47.2, 09/09/2026): `ImpellerBackend` bị bỏ qua ở bản release. Breaking change "Restrict Android engine flags in release mode" vẫn đang chờ (TBD).
8. **IconScout:** chưa xác minh được điều khoản (403, nguồn thứ cấp trái ngược nhau) → coi như **không dùng**.
9. **Asset CC BY** (Noto, Rive Marketplace): chỉ cấp quyền phần người đăng thật sự sở hữu. Noto do chính Google đăng nên rủi ro thấp; file Rive Marketplace phải kiểm từng file.

---

## 8. Checklist khi thực sự đưa vào code
- [ ] Mỗi package thêm vào `pubspec.yaml` có comment lý do (license / offline / miễn phí), theo quy ước của CLAUDE.md. Ghim `animations: ^2.2.0`.
- [ ] Mỗi asset bên thứ ba có bản ghi gồm: link trang gốc, license, ngày tải, tác giả. Lưu ảnh chụp trang license của file đó ở `docs/` để làm bằng chứng.
- [ ] Asset CC BY (Noto, Rive Marketplace): thêm vào `ATTRIBUTION.md` **và** màn ghi công trong app. Hiện `attribution_data.dart` chỉ khoá theo bài hát → cần tách danh sách cho asset.
- [ ] Thêm mục "Giấy phép mã nguồn mở" (`showLicensePage()`).
- [ ] Rive: lưu file nguồn `.rev` vào repo; ghi người dựng và plan đã dùng lúc xuất; đo APK bằng `flutter build apk --analyze-size --target-platform android-arm64`.
- [ ] Test mọi animation trên **Skia (hiện tại) và Impeller**, cả trên một máy Android đời thấp. Dừng animation khi khuất màn hình; tôn trọng `MediaQuery.disableAnimationsOf`.
- [ ] Haptics: có fallback cho API < 30 khi dùng `*Notification`.

---

## 9. Nguồn (đều kiểm ngày 2026-10-02)

**Rive**
- https://pub.dev/packages/rive · https://pub.dev/packages/rive/versions · https://pub.dev/packages/rive/changelog · https://pub.dev/packages/rive/license
- https://pub.dev/packages/rive_native · https://pub.dev/packages/rive_native/license
- https://rive.app/docs/runtimes/flutter/flutter · https://rive.app/docs/runtimes/flutter/migration-guide · https://raw.githubusercontent.com/rive-app/rive-flutter/master/README.md
- https://rive.app/docs/runtimes/runtime-sizes · https://github.com/rive-app/rive-flutter/issues/589
- https://rive.app/pricing · https://rive.app/docs/editor/exporting/exporting-for-runtime · https://rive.app/docs/cli/getting-started
- https://rive.app/docs/legal/terms-of-service · https://rive.app/docs/community/marketplace-overview
- https://www.threads.com/@rive.app/post/DPejYJNEmv7 · https://www.threads.com/@rive.app/post/DQCYKsKkW7A · https://www.rivemasterclass.com/updates/export-now-requires-paid-plan
- https://x.com/guidorosso/status/2095174568189239611 · https://x.com/rive_app/status/2098199130778857914 (X trả 402, nội dung lấy từ snippet tìm kiếm)

**Lottie / LottieFiles**
- https://pub.dev/packages/lottie · https://pub.dev/packages/lottie/changelog · https://pub.dev/packages/lottie/license · https://github.com/xvrh/lottie-flutter
- https://pub.dev/documentation/lottie/latest/lottie/RenderCache-class.html
- https://github.com/flutter/flutter/issues/137423 · https://github.com/flutter/flutter/issues/176211
- https://pub.dev/packages/dotlottie_flutter · https://github.com/LottieFiles/dotlottie-flutter · https://pub.dev/packages/thorvg
- https://lottiefiles.com/page/license (403) · https://help.lottiefiles.com/animation-licensing-basics-
- https://help.lottiefiles.com/hc/en-us/articles/900002475966-how-do-i-give-attribution-for-a-lottie-animation-i-ve-used
- https://help.lottiefiles.com/hc/en-us/articles/24484503354137-Premium-Animations
- https://help.lottiefiles.com/hc/en-us/articles/16240626895385-File-Upload-and-Download-Limits-on-Free-Workspace

**flutter_animate / Flutter / built-ins**
- https://pub.dev/packages/flutter_animate · https://github.com/gskinner/flutter_animate/commits/main · https://github.com/gskinner/flutter_animate/issues · https://pub.dev/packages/flutter_shaders
- https://docs.flutter.dev/ui/animations · https://docs.flutter.dev/ui/design/graphics/fragment-shaders · https://docs.flutter.dev/perf/impeller
- https://api.flutter.dev/flutter/physics/SpringDescription-class.html · https://github.com/flutter/flutter/pull/164411
- https://pub.dev/packages/animations · https://pub.dev/packages/animations/changelog · https://pub.dev/packages/material_ui · https://pub.dev/packages/material_ui/changelog
- https://docs.flutter.dev/release/breaking-changes/material-ui-and-cupertino-ui · https://docs.flutter.dev/release/breaking-changes · https://docs.flutter.dev/release/release-notes/release-notes-3.44.0
- https://flutter.dev/blog/whats-new-in-flutter-3-44 · https://flutter.dev/blog/whats-new-in-flutter-3-47 · https://flutter.dev/blog/whats-new-in-flutter-3-29
- https://github.com/flutter/flutter/issues/168813 · https://github.com/flutter/flutter/issues/177975 · https://github.com/flutter/flutter/issues/192467
- Chưa xác nhận: https://levelup.gitconnected.com/flutter-just-removed-skia-from-every-modern-android-device-impeller-vulkan-is-now-mandatory-b52de5038587

**Confetti / particles / counters / haptics / mới**
- https://pub.dev/packages/confetti · https://github.com/funwithflutter/flutter_confetti · https://pub.dev/packages/flutter_confetti · https://pub.dev/packages/newton_particles · https://pub.dev/packages/animated_flip_counter
- https://api.flutter.dev/flutter/services/HapticFeedback-class.html · https://api.flutter.dev/flutter/services/HapticFeedback/successNotification.html · https://api.flutter.dev/flutter/services/HapticFeedback/heavyImpact.html · https://developer.android.com/develop/ui/views/haptics/haptics-apis
- https://pub.dev/packages/vibration · https://pub.dev/packages/gaimon
- https://pub.dev/packages/motor · https://github.com/whynotmake-it/rivership/commits/main/packages/motor · https://pub.dev/packages/liquid_glass_renderer
- https://pub.dev/documentation/record/latest/record/AudioRecorder-class.html · https://pub.dev/documentation/speech_to_text/latest/speech_to_text/SpeechToText/listen.html

**Asset**
- https://developers.googleblog.com/updates-to-emoji-new-characters-new-animation-new-color-customization-and-more/ · https://googlefonts.github.io/noto-emoji-animation/ · https://googlefonts.github.io/noto-emoji-animation/data/api.json · https://fonts.gstatic.com/s/e/notoemoji/latest/1f525/lottie.json · https://github.com/google/fonts/issues/7011
- https://kenney.nl/assets/particle-pack · https://iconscout.com/licenses (403) · https://lordicon.com/docs/license/free · https://github.com/useAnimations/react-useanimations
