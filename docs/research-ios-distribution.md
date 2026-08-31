# Nghiên cứu: Phát hành iOS không qua App Store

## Bối cảnh
App hiện dùng các tính năng cần quyền hệ thống sâu: phát nhạc nền khi khoá máy (`just_audio`), ghi âm mic (luyện phát âm), và giờ có thêm push notification (chat qua Firebase). Bất kỳ phương án phân phối iOS nào cũng cần đáp ứng được các tính năng này — không chỉ đơn thuần "cài lên máy được".

## So sánh các phương án

| Phương án | Chi phí | Giới hạn thiết bị | Cần tài khoản Apple Developer? | Ghi chú |
|---|---|---|---|---|
| **Xcode sideload trực tiếp (free Apple ID)** | Miễn phí | Chỉ máy cắm cáp trực tiếp lúc build | Không cần (Apple ID thường) | App tự hết hạn sau **7 ngày**, phải build lại + cài lại bằng cáp mỗi lần. Chỉ hợp cho việc TỰ TEST trên máy của bạn, không dùng để phát hành cho người khác được. |
| **Ad Hoc distribution** | $99/năm (Apple Developer Program) | Tối đa **100 thiết bị** (đăng ký UDID trước) | Bắt buộc | Ký 1 năm không hết hạn hàng tuần như free ID. Cài qua link OTA (host file .ipa + .plist trên server riêng) — đúng mô hình "sideload ngoài App Store" hiện tại của Android. Đủ dùng nếu nhóm người dùng nhỏ (bạn bè, gia đình, nhóm beta ~100 người). |
| **TestFlight** | $99/năm | Tối đa **10.000 người test** | Bắt buộc | Vẫn phải qua 1 vòng review NHẸ của Apple (không phải full App Store review, thường vài giờ-1 ngày), build hết hạn sau 90 ngày phải upload lại. Không cần đăng ký UDID từng máy — người dùng tự cài app TestFlight rồi bấm link mời. Thực tế đây là con đường **dễ mở rộng nhất** trong các phương án hợp lệ, dù không phải "hoàn toàn không qua Apple". |
| **Apple Developer Enterprise Program** | $299/năm | Không giới hạn thiết bị | Bắt buộc, xét duyệt riêng | Theo điều khoản Apple **2026**: bắt buộc là pháp nhân có **từ 100 nhân viên trở lên**, chỉ dùng để phân phối app nội bộ cho chính nhân viên công ty đó. Dùng sai mục đích (phát hành ra công chúng) vi phạm điều khoản, Apple có thể **thu hồi cert** làm sập toàn bộ app đang cài trên máy người dùng ngay lập tức. **Không phù hợp** với dự án này (không phải doanh nghiệp 100+ nhân viên, mục tiêu là người dùng phổ thông). |
| **AltStore PAL / SideStore (chỉ EU)** | AltStore PAL: ~€1.85/năm. SideStore: miễn phí | Không giới hạn (SideStore cần "làm mới" định kỳ) | AltStore PAL: cần notarize qua Apple (có tài khoản Developer). SideStore: chỉ cần Apple ID thường | Đây là kênh mới mở từ **Digital Markets Act (DMA)** của EU (từ iOS 17.4). **CHỈ hoạt động khi Apple ID/thiết bị đặt vùng EU** — VPN không giả được, phải thực sự ở châu Âu. **Không dùng được cho người dùng ở Việt Nam** — loại khỏi lựa chọn cho đối tượng chính của app này. |
| **PWA (Progressive Web App qua Safari)** | Miễn phí hoàn toàn | Không giới hạn | Không cần | Cài qua Safari → "Thêm vào màn hình chính", không qua Apple duyệt gì cả. Nhưng: **không hỗ trợ phát nhạc nền khi khoá máy** (giới hạn cứng của Safari/iOS, không có background audio processing cho web app) — đây là tính năng LÕI của app này nên **loại trừ ngay**. Mic vẫn dùng được, push notification hoạt động từ iOS 16.4+ (ngoài EU). |

## Khuyến nghị

**Không có cách nào hoàn toàn miễn phí + không giới hạn + giữ được đầy đủ tính năng (nhạc nền, mic, push)** — đây là do chủ đích thiết kế của Apple, khác hẳn triết lý mở của Android.

Xếp hạng theo mức độ phù hợp với dự án:

1. **TestFlight ($99/năm)** — lựa chọn thực tế nhất nếu muốn mở rộng cho nhiều người (tới 10.000), giữ được đầy đủ tính năng native, không cần quản lý UDID từng máy thủ công. Đánh đổi: build hết hạn sau 90 ngày (phải up bản mới định kỳ), có 1 vòng review nhẹ của Apple (thường duyệt nhanh, không khắt khe như App Store chính thức).
2. **Ad Hoc ($99/năm, dùng chung Apple Developer Program với TestFlight)** — nếu nhóm dùng nhỏ (~dưới 100 máy, ví dụ gia đình/bạn bè/nhóm beta thân thiết), có thể tự host file .ipa giống hệt cách đang host APK Android hiện tại (GitHub Releases + link OTA). Không cần Apple review.
3. **Free Xcode sideload** — chỉ hữu ích cho chính bạn tự thử trên máy iPhone của mình trong lúc phát triển, không phải giải pháp phân phối.
4. **PWA** — loại bỏ vì mất tính năng phát nhạc nền, tính năng lõi của app.
5. **AltStore PAL/SideStore** — loại bỏ vì chỉ hoạt động ở EU, không phù hợp đối tượng người dùng Việt Nam.
6. **Enterprise Program** — loại bỏ, không đủ điều kiện pháp nhân (100+ nhân viên) và rủi ro bị Apple thu hồi cert nếu dùng sai mục đích.

**Kết luận thực tế**: iOS không có đường "sideload thật sự ngoài Apple" như Android khi ở ngoài EU — mọi phương án hợp lệ đều đi qua Apple Developer Program ($99/năm) ở mức độ nào đó. Nếu ngân sách cho phép, nên đăng ký **1 tài khoản Apple Developer Program ($99/năm)** và dùng **TestFlight** làm kênh phân phối chính cho giai đoạn beta — đúng với hướng "Giai đoạn 2+" đã ghi trong CLAUDE.md, chỉ khác là dùng TestFlight thay vì App Store chính thức cho tới khi sẵn sàng public.

## Có cách nào dùng tài khoản Apple ID MIỄN PHÍ không (không trả $99/năm)?

Có 1 con đường thật sự miễn phí, hoạt động ở mọi quốc gia (không bị giới hạn EU như AltStore PAL): **AltStore Classic + AltServer**.

**Cách hoạt động**: cài `AltServer` trên 1 máy Mac/Windows bất kỳ → cắm iPhone vào 1 lần → AltServer tự ký app bằng chính Apple ID thường (miễn phí) của bạn và cài `AltStore` lên máy → từ đó dùng AltStore để sideload file `.ipa` của app. Máy tính chạy AltServer cần **cùng mạng WiFi với iPhone định kỳ** (khoảng mỗi 7 ngày) để tự làm mới chữ ký trước khi hết hạn — nếu không làm mới kịp, app sẽ ngừng mở được cho tới lần làm mới tiếp theo. (AltStore Classic bản 2.3 beta tháng 5/2026 đang thử nghiệm làm mới ngay trên điện thoại không cần máy tính, nhưng hiện chỉ mở cho người ủng hộ Patreon, chưa phát hành công khai.)

**Đánh đổi quan trọng — Apple ID miễn phí ("Personal Team") KHÔNG cho phép bật các capability sau, dù build bằng cách nào**:
- ❌ **Push Notifications** — nghĩa là tính năng **chat báo tin nhắn qua Firebase vừa làm sẽ KHÔNG hoạt động được trên bản iOS này** nếu dùng tài khoản miễn phí. Đây là giới hạn cứng của Apple, không phải do cấu hình sai.
- ❌ iCloud, Sign in with Apple, App Groups, Apple Pay, Associated Domains.
- ⚠️ Một số Background Modes bị hạn chế — riêng mode `audio` (phát nhạc nền) nhìn chung vẫn dùng được vì đây chỉ là 1 giá trị khai báo trong Info.plist, không phải capability cần entitlement riêng như Push, nhưng cần kiểm chứng thực tế khi build thử.
- Giới hạn thêm: tối đa 3 app sideload cùng lúc bằng 1 Apple ID miễn phí (không phải vấn đề vì app này là app duy nhất), và **chỉ cài được cho chính Apple ID đó** — không chia sẻ file cho người khác cài tự do như Ad Hoc/TestFlight.

**Tóm lại**: dùng được miễn phí, nhưng phải **đánh đổi bỏ tính năng push chat trên bản iOS** (hoặc chấp nhận chat chỉ hoạt động khi app đang mở, giống trước khi làm Firebase) + phải định kỳ làm mới chữ ký mỗi tuần. Nếu về sau vẫn muốn giữ đầy đủ tính năng như bản Android hiện tại, sớm muộn vẫn cần nâng cấp lên Apple Developer Program ($99/năm).

## Phương án thay thế: build bản Web (thay vì app iOS native)

Flutter hỗ trợ sẵn target Web (`flutter build web`) — dùng LẠI TOÀN BỘ code hiện có, không cần viết lại. Vì dùng chung 1 backend Supabase, tài khoản/tiến trình học/điểm số... **tự động đồng bộ** với bản Android hiện tại — không cần đồng bộ thủ công gì thêm.

**Hosting**: miễn phí qua GitHub Pages hoặc Firebase Hosting, deploy tự động bằng GitHub Actions (cùng mô hình CI free đang dùng cho Android). Người dùng iPhone chỉ cần mở link bằng Safari, không cần cài gì, không dính bất kỳ giới hạn nào của Apple Developer Program.

**Nhưng có degradation thật sự với 3 tính năng đã build**, cần cân nhắc trước khi chọn hướng này:

| Tính năng | Trên Web | Ghi chú |
|---|---|---|
| Phát nhạc (`just_audio`) | Chạy được, nhưng **không có background audio thật sự trên Safari iOS** khi khoá máy/chuyển tab — nhạc dừng ngay. Trên Android Chrome thì ổn hơn (Chrome hỗ trợ phát nền qua Media Session API). | Đây là tính năng LÕI của app — mất trải nghiệm "nghe nhạc học tiếng Anh" trên iPhone qua web. |
| Ghi âm luyện phát âm (`speech_to_text`) | Có hỗ trợ web, nhưng dựa vào Web Speech API của trình duyệt — Safari hỗ trợ **không ổn định/kém hơn** Chrome. | Có thể lỗi hoặc kém chính xác hơn trên iPhone. |
| Đọc mẫu TTS (`flutter_tts`) | Hỗ trợ web đầy đủ. | Ổn. |
| Nhắc học "10 từ hôm nay" (`flutter_local_notifications`) | **Trình duyệt KHÔNG hỗ trợ thông báo hẹn giờ/lặp lại** (scheduled/repeating notification) — tính năng này sẽ **không hoạt động được** trên bản web dù bất kỳ trình duyệt nào. | Mất hẳn tính năng, không có cách thay thế tương đương trên web. |
| Push chat (Firebase) | FCM hỗ trợ web push tốt trên Chrome/Firefox/Edge. Trên Safari/iOS chỉ hoạt động nếu người dùng **"Thêm vào màn hình chính"** (biến thành PWA) — mở thẳng bằng Safari tab thường thì không nhận được push khi đã đóng tab. | Chấp nhận được nếu hướng dẫn người dùng thêm vào màn hình chính. |
| Đăng nhập Google (`google_sign_in`) | Dùng luồng khác trên web (`google_sign_in_web`, redirect OAuth) — có thể tái dùng Web OAuth Client đã tạo sẵn cho Supabase, nhưng cần code/test riêng, không tự động giống Android. | Cần code thêm, không phải "chạy thẳng không sửa gì". |

**Khuyến nghị**: bản Web là lựa chọn **miễn phí, nhanh nhất để có mặt trên iPhone**, phù hợp nếu chấp nhận **bỏ tính năng nhắc học hẹn giờ + giảm trải nghiệm nghe nhạc nền trên Safari**. Nếu 2 tính năng đó là cốt lõi không thể thiếu, nên ưu tiên hướng Apple Developer Program ($99/năm) ở trên để có app native đầy đủ tính năng. Có thể làm **cả hai song song**: build Web ngay bây giờ (miễn phí, nhanh) làm bản dùng tạm cho iPhone, và cân nhắc Apple Developer Program sau khi app ổn định hơn.

## Build iOS mà không cần máy Mac

Máy đang dùng để code là Windows — build app iOS (`.ipa`) bắt buộc phải chạy qua công cụ Apple (Xcode), vốn chỉ có trên macOS. Tin tốt: **không cần mua Mac**, có thể build hoàn toàn qua CI:

- **GitHub Actions với runner `macos-latest`** — repo này đang **public**, mà theo chính sách GitHub, **repo public được cấp runner GitHub-hosted (kể cả macOS) miễn phí, KHÔNG giới hạn số phút** (chỉ áp dụng multiplier 10x phút macOS cho hạn mức của repo **private**). Vì `LearningEnglish` đang public, build iOS qua GitHub Actions **không tốn thêm chi phí gì** ngoài $99/năm Apple Developer Program — chỉ cần thêm 1 workflow mới tương tự `build-apk.yml` hiện tại nhưng chạy trên `runs-on: macos-latest`, dùng `flutter build ipa`.
- **Thay thế**: Codemagic (có gói free tier riêng cho build Flutter, tự động quản lý cert/profile), hoặc thuê máy Mac cloud (MacStadium...) nếu cần truy cập Xcode trực tiếp — không cần thiết vì GitHub Actions miễn phí đã đủ dùng cho repo public này.

## Cấu hình iOS cần thêm cho đúng 3 tính năng "nhạy cảm" của app

Khi thật sự bắt tay code phần iOS (`flutter create` sẽ tự sinh thư mục `ios/`), cần bổ sung thủ công vào `ios/Runner/Info.plist` và `ios/Runner/Runner.entitlements`:

| Tính năng trong app | Cấu hình iOS cần thêm |
|---|---|
| Phát nhạc nền khi khoá máy (`just_audio`) | `Info.plist`: key `UIBackgroundModes` → mảng chứa `"audio"` (đây là 1 property của Info.plist, KHÔNG phải entitlement — để nhầm vào file `.entitlements` sẽ không có tác dụng). |
| Ghi âm mic (luyện phát âm) | `Info.plist`: key `NSMicrophoneUsageDescription` — chuỗi tiếng Việt giải thích lý do xin quyền (bắt buộc, Apple từ chối app thiếu key này ngay từ vòng review nhẹ của TestFlight). |
| Push notification chat (Firebase) | 1) Bật capability **Push Notifications** cho App ID trên Apple Developer portal. 2) Thêm `aps-environment` vào `Runner.entitlements` (`development` lúc test, `production` lúc build TestFlight/App Store). 3) **Riêng cho Firebase**: phải tạo **APNs Auth Key** (file `.p8`) trên Apple Developer portal rồi upload vào Firebase Console → Project Settings → Cloud Messaging — Android dùng `google-services.json` là đủ nhưng iOS cần thêm bước này vì FCM trên iOS chạy qua APNs của Apple, không gửi thẳng như Android. |

## Checklist thực tế để lên TestFlight

1. Đăng ký **Apple Developer Program** ($99/năm) tại [developer.apple.com/programs](https://developer.apple.com/programs/enroll/).
2. Trên Apple Developer portal: tạo **App ID** với bundle identifier khớp Android hiện tại (`com.learnenglishmusic.learn_english_music`) để dùng chung 1 Firebase project, bật capability **Push Notifications** + **Background Modes**.
3. Tạo **APNs Auth Key** (.p8) → upload vào Firebase Console cho project `learningenglish-ae40e` đã có sẵn.
4. Chạy `flutter create --platforms=ios .` trong `app/` để sinh thư mục `ios/` (project hiện chưa có), rồi thêm 3 cấu hình ở bảng trên.
5. Thêm workflow GitHub Actions mới (`build-ios.yml`, `runs-on: macos-latest`) — build `.ipa` bằng `flutter build ipa`, ký bằng certificate + provisioning profile lưu dạng secret (giống hệt cách đang làm với keystore Android), sau đó upload lên App Store Connect qua `xcrun altool` hoặc App Store Connect API key.
6. Trong App Store Connect: tạo app, bật TestFlight, mời người test qua email hoặc link công khai (tối đa 10.000 người).

## Sources
- [Sideload iOS apps using the third-party AltStore app — AppleInsider](https://appleinsider.com/inside/ios/tips/how-to-sideload-ios-apps-to-the-iphone-with-altstore)
- [How iOS sideloading actually works in 2025: dev certs, AltStore, and the EU exception — DEV Community](https://dev.to/1_king_0b1e1f8bfe6d1/how-ios-sideloading-actually-works-in-2025-dev-certs-altstore-and-the-eu-exception-1m2h)
- [SideStore vs AltStore in 2026: Which One Should You Use? — builds.io](https://builds.io/blog/technologies/ios-technologies/sidestore-vs-altstore/)
- [iOS Distribution Guide 2026: TestFlight, App Store & Enterprise — Foresight Mobile](https://foresightmobile.com/blog/ios-app-distribution-guide-2026)
- [Apple Developer Enterprise Program — Apple](https://developer.apple.com/programs/enterprise/)
- [iOS App Distribution: TestFlight, Ad Hoc, Enterprise & App Store — Appcircle](https://appcircle.io/guides/ios/ios-app-distribution)
- [Do Progressive Web Apps Work on iOS? The Complete Guide for 2026 — Mobiloud](https://www.mobiloud.com/blog/progressive-web-apps-ios)
- [PWA iOS Limitations and Safari Support [2026] — MagicBell](https://www.magicbell.com/blog/pwa-ios-limitations-safari-support-complete-guide)
- [How to Build an iOS App Without a Mac in 2026 (4 Real Options) — Code2Native](https://code2native.com/blog/build-ios-app-without-mac-2026)
- [Building a Flutter iOS app with Codemagic and GitHub Actions — Medium](https://medium.com/@pratheeshrussell/building-a-flutter-ios-app-with-codemagic-and-github-actions-9cd61321119b)
- [GitHub Actions Pricing 2026: $0.006/min, ARM, macOS 10x — cicdpipelinecost.com](https://cicdpipelinecost.com/github-actions-pricing)
- [Is GitHub Actions Free? Free Tier Limits Explained (2026) — CICDCalculator.com](https://cicdcalculator.com/github-actions-free-tier)
- [just_audio: Apple TestFlight rejected — missing NSMicrophoneUsageDescription — GitHub issue](https://github.com/ryanheise/just_audio/issues/1397)
- [Missing Push Notification Entitlement on iOS — FlutterFlow community](https://community.flutterflow.io/ask-the-community/post/missing-push-notification-entitlement-on-ios-app-store-with-supabase-mzLgRVcSlgU4v8Z)
- [AltStore launches on-device app sideloading without a computer or AltServer — AlternativeTo](https://alternativeto.net/news/2026/5/altstore-launches-on-device-app-sideloading-without-a-computer-or-altserver/)
- [AltStore vs SideStore vs LiveContainer - Which to Use in 2026 — builds.io](https://builds.io/blog/technologies/ios-technologies/altstore-vs-sidestore-vs-livecontainer/)
- [Signing With a Free Personal Team — zudo-tauri-wisdom](https://takazudomodular.com/pj/zudo-tauri/docs/mobile/ios-signing-free-team/)
- [Steps to Fix the Missing "Push Notifications" Capability — Awesome Enterprise Documentation](https://awxdocs.com/tutorials/steps-to-fix-the-missing-push-notifications-capability/)
- [How to Publish your Flutter Web Apps on GitHub Pages for Free — Code with Andrea](https://codewithandrea.com/articles/flutter-web-github-pages/)
- [flutter_local_notifications — pub.dev (web limitations)](https://pub.dev/packages/flutter_local_notifications)
- [Get started with Firebase Cloud Messaging in Web apps — Firebase docs](https://firebase.google.com/docs/cloud-messaging/web/get-started)
- [Sending to MacOS, iOS Safari using FCM JS SDK — Firebase Blog](https://firebase.blog/posts/2023/08/fcm-for-safari/)
