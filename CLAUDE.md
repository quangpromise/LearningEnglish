# Learn English Through Music — CLAUDE.md

## Mục tiêu dự án
App học tiếng Anh bằng âm nhạc: người dùng nghe bài hát, xem lyric song ngữ (Anh/Việt) đồng bộ theo thời gian, chạm vào từ để xem nghĩa và nghe phát âm mẫu, luyện phát âm bằng mic và được chấm điểm, xem giải thích ngữ pháp cho các câu khó trong lời bài hát.

## Nền tảng & lộ trình phát hành
- **Giai đoạn 1**: Android — build APK ký sẵn (`flutter build apk --release`), phân phối bằng sideload (host file trên GitHub Releases/Cloudflare R2/S3, KHÔNG qua Google Play).
- **Giai đoạn 2+**: Mở rộng sang iOS/App Store khi có tài khoản Apple Developer. Vì dùng Flutter (1 codebase), phần lớn logic tái sử dụng được, chỉ cần cấu hình ký (`Info.plist`, provisioning) và tuân thủ App Store Review Guidelines (đặc biệt là quyền truy cập mic).

## Stack kỹ thuật
- **Framework**: Flutter (Dart) — chọn vì build APK sideload dễ dàng, không ràng buộc Google Play, và cùng codebase mở rộng iOS sau này.
- **State management**: Riverpod — mỗi feature tự quản state riêng, thuận tiện khi nhiều người code song song (xem "Cộng tác nhiều người" bên dưới).
- **Phát nhạc & đồng bộ lyric**: `just_audio` (hoặc tương đương) + parser file `.lrc` (lyric có timestamp).
- **Dịch (song ngữ Anh-Việt)**: `google_mlkit_translation` — dịch on-device, offline, miễn phí, không giới hạn số lượt gọi. Lưu ý: dịch giữa các ngôn ngữ không phải tiếng Anh sẽ đi qua trung gian English nên chất lượng thấp hơn — nhưng cặp Anh↔Việt là dịch trực tiếp nên ổn.
- **Phát âm mẫu (TTS)**: `flutter_tts` làm mặc định (dùng engine TTS gốc máy, offline, miễn phí). Có thể nâng cấp sang Google Cloud TTS (free tier: 4 triệu ký tự standard/tháng, 1 triệu ký tự WaveNet/tháng) khi cần giọng bản địa tự nhiên hơn (Anh-Anh, Anh-Úc...).
- **Ghi âm & chấm phát âm**: `speech_to_text` (dùng SFSpeechRecognizer/Android SpeechRecognizer, on-device, offline, miễn phí) để nhận diện giọng nói người dùng, so khớp với transcript câu gốc và tính điểm tương đồng. Gói `record`/`flutter_sound` dùng nếu cần lưu file ghi âm thô.
- **Kiểm tra ngữ pháp**: LanguageTool (mã nguồn mở, LGPL 2.1+) — dùng API công cộng hoặc tự host server riêng để chấm lỗi ngữ pháp trong lyric/câu luyện tập.

## Nguồn nhạc — QUAN TRỌNG về bản quyền
**Không dùng Jamendo API** để lấy nhạc trong bản phát hành thương mại — API của Jamendo chỉ miễn phí cho mục đích **phi thương mại**; dùng thương mại bắt buộc phải liên hệ mua license riêng (dù bản thân track có gắn nhãn CC).

Chiến lược đúng: **tự lưu trữ (self-host)** một bộ nhạc đã chọn lọc thủ công, chỉ lấy các track có giấy phép cho phép thương mại rõ ràng, rồi host file audio + lyric trên server/CDN riêng (không gọi API bị giới hạn):
- ~~**Pixabay Music**~~ — **KHÔNG dùng cho app này.** Pixabay Content License cấm phân phối content "trên cơ sở standalone" (giữ nguyên dạng gốc, không thêm công sức sáng tạo lên chính file đó) — mà app này stream nguyên file mp3 cho người dùng nghe. Xem phân tích đầy đủ trong `docs/research-music-libraries.md` §6.
- **Incompetech (Kevin MacLeod)** — CC-BY, dùng thương mại được nếu ghi công tác giả.
- **Free Music Archive / ccMixter** — không có API public, phải tự host file; chỉ chọn track gắn nhãn **CC0 hoặc CC-BY** (loại bỏ mọi track CC-BY-NC vì cấm thương mại).

Quy tắc bắt buộc:
- **Kiểm tra giấy phép có bao trùm cả LỜI bài hát không, không chỉ bản thu.** Một bài hát có 2 bản quyền riêng: bản thu (sound recording) và tác phẩm gốc gồm giai điệu + lời (composition). Giấy phép CC chỉ bao trùm phần người đăng thực sự sở hữu — nếu 1 người remix đăng bản thu của họ dưới CC-BY nhưng lời do người khác viết thì ta KHÔNG có quyền với phần lời, mà lời chính là thứ app này dùng nhiều nhất. → Ưu tiên singer-songwriter tự viết + tự thu + tự sở hữu toàn bộ, phát hành dưới CC 4.0.
- Mỗi track thêm vào app phải có ghi chú nguồn + loại giấy phép trong `docs/research-music-libraries.md` hoặc file metadata đi kèm.
- Track CC-BY phải có file `ATTRIBUTION.md` liệt kê tên tác giả/link gốc theo đúng yêu cầu giấy phép.
- Ưu tiên bài indie/acoustic có lời rõ ràng, dễ nghe, phù hợp học tiếng Anh — không cần bài nổi tiếng.

## Cấu trúc thư mục
```
D:\Projects\Learn Engligh\
├── CLAUDE.md                          # File này
├── docs/                              # Tài liệu nghiên cứu & kiến trúc
├── .claude/
│   ├── agents/                        # Agent chuyên biệt (xem bên dưới)
│   └── skills/                        # Skill quy trình cụ thể (xem bên dưới)
├── backend/                            # Proxy Gemini Live + pipeline fallback tự host cho AI Voice Chat
└── app/                                # Flutter project (Android + iOS)
    └── lib/
        ├── features/
        │   ├── music_player/          # Phát nhạc, đồng bộ lyric
        │   ├── translation/           # Dịch từ/câu on-device
        │   ├── pronunciation/         # Ghi âm mic, chấm điểm phát âm
        │   ├── grammar/                # Giải thích ngữ pháp
        │   ├── quiz/                   # Đố vui tiếng Anh + bảng xếp hạng
        │   └── ai_voice_chat/          # Trò chuyện AI bằng giọng nói (xem docs/research-ai-voice.md)
        └── core/                       # Config, DI, theme, routing
```

## Agents (`.claude/agents/`)
- **grammar-researcher** — nhận câu/đoạn lyric, giải thích cấu trúc ngữ pháp, tạo bài tập liên quan, dùng LanguageTool để kiểm tra lỗi.
- **pronunciation-researcher** — tra cứu IPA chuẩn (Anh-Anh/Anh-Mỹ), trọng âm, quy tắc nối âm, ví dụ minh họa cho từ/câu trong bài hát.
- **library-researcher** — khi cần thêm tính năng mới (nguồn nhạc, ngôn ngữ mới...), tìm & so sánh thư viện phù hợp, ưu tiên miễn phí/mã nguồn mở, **luôn kiểm tra kỹ điều khoản license cho mục đích thương mại** trước khi đề xuất.

## Skills (`.claude/skills/`)
- **grammar-check** — quy trình gọi LanguageTool chấm lỗi ngữ pháp câu trong lyric/luyện tập.
- **pronunciation-check** — quy trình bật mic → ghi âm → chạy `speech_to_text` → so khớp transcript với câu gốc → tính điểm tương đồng → phản hồi từ phát âm sai.
- **lyric-sync** — parse file `.lrc`, đồng bộ với vị trí phát nhạc để highlight từ đang hát.
- **apk-release** — quy trình build & ký APK release, checklist trước phát hành, hướng dẫn host & hướng dẫn người dùng cài từ nguồn ngoài Play.

## Quy ước
- Cấu trúc code theo feature-first (mỗi tính năng 1 thư mục trong `lib/features/`).
- Mọi package mới thêm vào `pubspec.yaml` phải ghi lý do chọn (miễn phí, license, offline/online) vào `docs/`.
- Không thêm bất kỳ nguồn nhạc/dữ liệu nào chưa xác minh rõ giấy phép thương mại.

## Cộng tác nhiều người
Dự án được thiết kế để nhiều người cùng code song song, hạn chế đụng conflict:
- **Kiến trúc feature-first**: mỗi người/nhóm nhận trọn 1 thư mục trong `app/lib/features/` (music_player, translation, pronunciation, grammar) để làm việc độc lập; ít khi phải sửa chung 1 file.
- **State management: Riverpod** — mỗi feature tự quản provider/state riêng trong thư mục của mình, tránh 1 file state dùng chung mà nhiều người cùng sửa.
- **Git flow**: `main` (luôn build được, dùng để build APK release) ← `develop` (nhánh tích hợp) ← `feature/*`, `fix/*`, `docs/*` branches. Không push thẳng vào `main`/`develop`, luôn qua Pull Request.
- **CODEOWNERS** (`/CODEOWNERS`): map từng module tới người/nhóm chịu trách nhiệm review — cập nhật username thật khi có thành viên mới join.
- **CI** (`.github/workflows/ci.yml`): tự động chạy `flutter analyze`, `dart format --set-exit-if-changed`, `flutter test` trên mọi PR vào `main`/`develop`.
- **Templates**: `.github/PULL_REQUEST_TEMPLATE.md` và `.github/ISSUE_TEMPLATE/` chuẩn hoá cách báo bug/đề xuất tính năng/PR, có mục nhắc kiểm tra license khi thêm nhạc/thư viện mới.
- **Chi tiết quy trình** (setup môi trường, branch naming, commit convention, coding style): xem [CONTRIBUTING.md](CONTRIBUTING.md).
- **Thành viên mới dùng Claude Code**: xem [docs/team-onboarding.md](docs/team-onboarding.md) — hướng dẫn clone repo, mở bằng Claude Code, bật MCP GitHub, cài môi trường Flutter, nhận việc.
