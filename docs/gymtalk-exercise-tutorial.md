# GymTalk – Trình phát hướng dẫn bài tập (dựng trong app)

## Quyết định: dựng trong app thay vì file MP4
Nội dung hướng dẫn (2 ảnh tư thế, câu hướng dẫn Anh/Việt, giọng đọc) **đã có sẵn trong app**, nên trình phát ghép chúng lúc chạy thay vì phát file video render sẵn:

| | Trong app (đã chọn) | MP4 render bằng HyperFrames |
|---|---|---|
| Lưu trữ | Không cần host, chạy offline | ~300–650 MB cho 155 bài, cần CDN |
| Tương tác (Nói theo, 0.75×, bật/tắt dịch, sáng theo giọng đọc) | Chính xác vì app biết từng câu | Khó – chữ đã in cứng |
| Có ngay cho cả 155 bài | Có | Phải render + upload |

HyperFrames vẫn dùng cho **clip marketing/mạng xã hội** (xem `marketing/`).

## Màn chi tiết bài tập (`exercise_detail_screen.dart`)
- Giữ **ảnh 2 tư thế** (xem nhanh, không tốn data) + nút đỏ **Video hướng dẫn · EN** – chỉ chạy khi bấm.
- **Chương có thumbnail** (Tổng quan · Bước 1..n · Từ khoá) → mở thẳng đoạn đó.
- **Từ khoá của bài** chạm để nghe; nút **Tập bài này** mở buổi tập riêng chỉ gồm bài này.

## Trình phát (`exercise_tutorial_player.dart`)
- Dọc 9:16 toàn màn hình, thanh chương kiểu Stories (chạm để nhảy), chạm trái/phải = lùi/tới, giữa = tạm dừng/tiếp tục (tiến độ đứng yên khi dừng).
- **0.75×** (giọng máy), bật/tắt dịch VI; câu tiếng Anh **sáng dần theo giọng đọc** (ước lượng theo số ký tự – TTS không báo tiến độ từng từ), từ khoá gạch chân.
- **Nói theo** sau mỗi bước: bấm mic → nghe (`SpeechListener`) → chấm `scorePronunciation` → ghi thống kê (nguồn `exercise_tutorial`, cộng vòng Nói). Không nghe thấy gì → quay lại lời mời, không ghi 0 điểm. Bỏ qua/không tương tác 12 giây → sang bước sau.
- **Màn kết thúc**: số câu đạt, điểm TB, 3 từ khoá → **Thêm vào Ôn tập** (SRS), **Tập bài này ngay**, Xem lại.
- Mở bằng route `kPronunciationRouteName` → nút AI Voice Chat biết mic đang bận.

## Dữ liệu (`exercise_tutorial.dart`, có test)
- Tổng quan: "Today's exercise: the {nameEn}. It works your {3 nhóm cơ}."
- Mỗi bước: "Step one. {instructionsEn[i]}", bản dịch `instructions[i]`, chia cụm tại dấu câu.
- 3 từ khoá: từ bộ từ vựng gym, **ưu tiên từ xuất hiện trong câu hướng dẫn**, rồi cùng nhóm cơ, từ chưa thuộc trước; không lấy trùng tên bài.

## Giọng đọc Kokoro đóng gói sẵn
- `scripts/generate_tutorial_audio.py` tạo giọng **Kokoro-82M** (Apache-2.0, voice `am_michael`, tốc độ 0.95) cho **mọi câu cố định** trình phát đọc: tổng quan + từng bước của 155 bài, 68 từ vựng gym + 68 câu ví dụ, "Great job!" / "Nice try!" – hiện **724 câu, ~24 MB** (mp3 mono 40 kbps) trong `app/assets/tutorial_audio/<fnv1a32>.mp3` + `manifest.json`.
- App (`core/tts/tutorial_voice.dart`) băm câu cần đọc bằng cùng FNV-1a 32: có file → phát Kokoro (đúng tốc độ 0.75×/1×, thời lượng thật để chữ sáng khớp giọng); không có → AppTts như cũ. Nút loa ở thẻ Học khi nghỉ, 5 từ khởi động, Ôn tập, từ khoá cũng dùng giọng này.
- `test/tutorial_audio_manifest_test.dart` kiểm tra MỌI câu app sinh ra đều có file + mã băm Dart khớp Python → sửa nội dung bài tập/từ vựng mà quên chạy lại script là CI báo.
- Chạy lại sau khi sửa nội dung: `python scripts/generate_tutorial_audio.py` (chỉ tạo phần còn thiếu; cần `kokoro_onnx`, `soundfile`, ffmpeg và model trong `~/.cache/hyperframes/tts` – có sau khi chạy `npx hyperframes tts` 1 lần).
