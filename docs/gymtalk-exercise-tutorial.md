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
