# Motion graphics cho GymTalk — xu hướng 2025–2026 và chỗ đặt trong app

Ngày nghiên cứu: 2026-10-02. Thư viện và giấy phép chi tiết: `docs/research-motion-libraries.md`.

## 1. Hiện trạng

- Không có thư viện motion nào trong `pubspec.yaml` (không Rive/Lottie/flutter_animate); mọi chuyển động viết tay.
- Đã có: vòng Tập/Học/Nói tween 600 ms, toast XP, Celebration (pop + glow), karaoke tô chữ theo vị trí nhạc (`karaoke_lyrics.dart`, ShaderMask), ảnh bài tập lật khung.
- Còn tĩnh: tick nhiệm vụ, mở rương, số XP/số liệu không đếm lên, chuyển tab (IndexedStack), popup chỉ là bottom sheet mặc định, màn phát âm không có sóng âm, ngọn lửa chuỗi là icon tĩnh.
- Chỉ Celebration tôn trọng "giảm chuyển động".
- **Impeller đang tắt** (`android/app/src/main/AndroidManifest.xml`, `EnableImpeller=false`) vì từng nghi gây gạch chân vàng dưới chữ — triệu chứng đó là kiểu chữ dự phòng khi thiếu Material, đã sửa ở PR #95.

## 2. Xu hướng đang mạnh (xếp theo độ phổ biến)

| # | Xu hướng | Ví dụ / nguồn | Liên quan GymTalk |
|---|---|---|---|
| 1 | Chuyển động lò xo + biến hình (Material 3 Expressive, 05/2025): spring thay cho easing; scheme expressive (nảy) / standard; spatial vs effects | 9to5google 13/05/2025; token trong androidx `ExpressiveMotionTokens.kt` | Cao — Android-first, làm token chung được ngay (`SpringDescription.withDurationAndBounce`, Flutter 3.32+) |
| 2 | Liquid Glass (iOS 26, 06/2025): kính khúc xạ, co giãn theo ngón tay, tab bar co khi cuộn | WWDC25 session 219; HIG Motion 09/2025 | Trung bình — iOS là giai đoạn 2; Flutter chưa hỗ trợ chính thức |
| 3 | Nhân vật chạy state machine (Rive): nhép môi theo âm vị, trạng thái nghe/nghĩ/nói che độ trễ AI | Duolingo visemes (11/2022); Duolingo Lily video call (Rive, 03/2025) | Cao — avatar PT AI, linh vật phản ứng điểm phát âm |
| 4 | Ăn mừng dành cho cột mốc, không cho mọi thao tác | Duolingo streak milestone: +1.7% giữ chân ngày 7 (01/2022); Apple HIG Motion | Cao — rương, chuỗi, lên Rank |
| 5 | Số liệu chuyển động: vòng đóng, số "lăn" | Apple Activity, WHOOP pillars, SwiftUI numericText | Cao — màn Hôm nay. **Rủi ro iOS:** HIG cấm làm giao diện kiểu vòng giống Activity Rings, App Review 5.2.5 |
| 6 | Rung thiết kế cùng chuyển động | Apple HIG Playing haptics; Android haptics principles (09/2026): "không rung còn hơn rung rè" | Cao — xong hiệp, xong nhiệm vụ, điểm phát âm (không rung khi đang thu mic) |
| 7 | Điều hướng theo cử chỉ, chuyển cảnh liền mạch (predictive back, card → chi tiết) | Android 16; Flutter 3.38 bật predictive back mặc định | Trung bình |
| 8 | Lời bài hát động (kinetic lyrics) + dòng dịch | Apple Music Sing; iOS 26 dịch lời; Spotify dịch lời toàn cầu (TechCrunch 02/2026) | Cao — điểm khác biệt của app |
| 9 | Recap cá nhân hoá dựng từ dữ liệu | Spotify Wrapped 2025, LinkedIn Year in Review, Strava (đều làm bằng Rive) | Trung bình — "Tuần của bạn" ở Tiến độ |
| 10 | Vi tương tác nút (nén, nảy, phát sáng chỗ chạm) | M3 Expressive button groups; Liquid Glass | Trung bình–cao — nút chính |
| 11 | Nền shader / mesh gradient động | SwiftUI MeshGradient; nền lyric Apple Music | Trung bình — chỉ sau lyric/AI chat, có bản tĩnh |
| 12 | Tiến độ trên màn khoá / thông báo (Live Updates) | Android 16 ProgressStyle; app gym hiện đồng hồ nghỉ | Trung bình — cần code native |
| 13 | 3D thời gian thực | Huy chương 3D Apple Fitness; avatar AI | Thấp — đã có avatar Anam |

Chưa kiểm chứng được: case study motion của Speak/Busuu/Babbel/NTC; một số chi tiết Duolingo (rung, nút nổi, XP đếm lên) chỉ quan sát gián tiếp; trang WHOOP/LottieFiles trả 403.

## 3. Đặt motion vào đâu (theo đợt)

### Đợt 1 — chỉ Flutter có sẵn + `animations` ^2.2.0 (BSD-3), không native size

| Chỗ | Thêm gì |
|---|---|
| Toàn app | Token lò xo (expressive cho khoảnh khắc thưởng, standard cho UI thường, effects cho màu/độ mờ) trong `GtTokens`; một hàm `reduceMotion(context)` đọc cả cờ Android (`MediaQuery.disableAnimations`) lẫn iOS (`accessibilityFeatures.reduceMotion`) |
| Hôm nay | Vòng đóng bằng lò xo; % và XP đếm lên; vòng chạm 100% thì nháy sáng + rung nhẹ; tick nhiệm vụ vẽ dấu ✓ + gạch ngang chạy; rương rung khi sẵn sàng → mở nắp → Celebration |
| Celebration | Phân tầng: toast cho việc thường; toàn màn chỉ cho cột mốc (rương, chuỗi 7/30/100, lên Rank, qua Level Test, buổi tập đầu tiên) |
| Ôn thẻ | Lật 3D thật; chấm điểm thì thẻ trượt ra theo màu Quên/Khó/Nhớ |
| Phát âm, PT AI | Sóng âm theo mic (`speech_to_text`/`record` đã có luồng mức âm); điểm đếm lên + tô màu từng từ đúng/sai; PT AI có trạng thái nghe / đang nghĩ / đang nói |
| Buổi tập | Nút tick nảy + rung; chuyển bài kiểu shared-axis; vòng nghỉ chạy theo đồng hồ thật |
| Nghe nhạc | Dòng đang hát nổi lên (scale/opacity lò xo), dòng đã qua mờ dần, dòng dịch hiện mềm; nền đổi màu chậm theo bài (màu tính sẵn, không đọc pixel ảnh) |
| Điều hướng | Card → chi tiết "nở ra" (container transform); chuyển tab fade-through; Hero cho bìa bài hát / thẻ giáo án |

### Đợt 2 — `lottie` 3.6.x (MIT) + Noto Animated Emoji (CC BY 4.0, phải ghi công)

Lửa chuỗi ngày động (top bar + dải 7 ngày), pháo giấy/ngôi sao ở Celebration, vỗ tay/💯 khi phát âm tốt. Thêm mục ghi công animation vào màn Ghi công (hiện chỉ có bài hát) và một màn giấy phép mã nguồn mở (`showLicensePage`).

### Đợt 3 — `rive` 0.14.x (runtime MIT), cần người thiết kế + gói Rive Cadet (~9 $/tháng) trong lúc dựng

Linh vật/HLV có state machine (chờ, nghe, nghĩ, nói, cổ vũ) phản ứng theo điểm phát âm và đồng hồ nghỉ; thẻ "Tuần của bạn" kiểu Wrapped để chia sẻ. APK ước tăng ~4–5 MB (arm + arm64, cần đo).

### Không làm lúc này

Liquid Glass bằng shader (thử nghiệm, nặng GPU), 3D/Spline, nền shader khắp nơi, `flutter_animate` (không commit từ 11/2024), gói `confetti` (ngủ đông từ 09/2024), `animations` 3.x (chuyển sang `material_ui`, khác kiểu với `package:flutter/material.dart`).

## 4. Việc nền tảng trước khi thêm motion

1. **Bật lại Impeller và thử trên máy thật** — lý do tắt cũ đã được giải thích (PR #95); shader tùy biến qua `ImageFilter` chỉ chạy trên Impeller.
2. **Đổi kiểu vòng ở Hôm nay** (vòng tách rời hoặc cung phân đoạn) trước giai đoạn iOS — tránh HIG Activity Rings / App Review 5.2.5.
3. **Giảm chuyển động đúng chuẩn**: đọc cả cờ iOS; khi Android tắt animation, `AnimationController` mặc định chạy nhanh thay vì bỏ qua (flutter/flutter#164287) → đồng hồ nghỉ, karaoke chạy theo đồng hồ/vị trí nhạc; không nhấp nháy quá 3 lần/giây (WCAG 2.3.1).
4. **Tránh `toByteData` để lấy màu bìa**: lỗi treo trên chip MediaTek/Mali (flutter/flutter#193428, P1, 09/2026) → màu tính sẵn.
