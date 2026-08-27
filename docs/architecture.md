# Kiến trúc app

## Nguyên tắc
- **Feature-first**: mỗi tính năng có thư mục riêng trong `app/lib/features/`, chứa `presentation/` (UI) và có thể thêm `data/`, `domain/` khi logic phức tạp hơn (xem `features/quiz/data/quiz_data.dart` làm ví dụ).
- **State management**: Riverpod (`flutter_riverpod`), `ProviderScope` bọc ở `main.dart`. Màn hình đơn giản dùng `StatefulWidget` cục bộ là đủ; chỉ tạo provider khi state cần chia sẻ giữa nhiều widget/màn hình.
- **Design system dùng chung**: `app/lib/core/theme/app_theme.dart` — định nghĩa màu, gradient, font (Space Grotesk/Manrope qua `google_fonts`), và các widget dùng chung (`GlowBox`, `PillButton`, `ScreenBackground`) đúng theo `.claude/skills/ui-design-system/SKILL.md`. Màn hình mới nên tái dùng các widget này thay vì tự viết style riêng.

## Điều hướng
`core/navigation/root_shell.dart` — bottom nav 4 tab chính (Home, Quiz, Luyện nói, Hồ sơ) dùng `IndexedStack` để giữ state khi chuyển tab. Các màn phụ (Player, WordPopup, Grammar, Quiz question/result/Leaderboard) điều hướng bằng `Navigator.push` thông thường từ màn cha liên quan.

## Trạng thái hiện tại (dữ liệu mẫu, chưa nối thật)
- `home_screen.dart`, `player_screen.dart`: dữ liệu bài hát/lyric là hằng số tĩnh (`kSongs`, `kLyrics`) — chưa phát nhạc thật, chưa đọc file `.lrc`.
- `word_popup_sheet.dart`: từ điển demo (`kMiniDictionary`) — chưa dùng `google_mlkit_translation`.
- `pronunciation_screen.dart`: **đã tích hợp thật** `speech_to_text` (ghi âm, nhận diện) và `flutter_tts` (nghe mẫu) — tính năng này hoạt động thật trên thiết bị có mic.
- `quiz/`: dữ liệu câu đố thật (`quiz_data.dart`, lấy từ kho đố vui tham khảo tại vn.elsaspeak.com/do-vui-tieng-anh), logic chấm điểm/chọn đáp án hoạt động thật, nhưng bảng xếp hạng (`leaderboard_screen.dart`) dùng danh sách người chơi giả lập tĩnh — trang gốc không có sẵn hệ thống điểm/xếp hạng, đây là phần app tự thiết kế thêm.
- `profile_screen.dart`: số liệu thống kê tĩnh, chưa lưu tiến độ thật.
- `ai_voice_chat/`: chỉ có màn hình placeholder, chưa nối backend (xem `docs/research-ai-voice.md`).

Xem `docs/roadmap.md` cho danh sách việc cần làm để thay dữ liệu mẫu bằng dữ liệu/tích hợp thật.
