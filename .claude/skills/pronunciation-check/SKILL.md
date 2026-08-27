---
name: pronunciation-check
description: Quy trình ghi âm mic, nhận diện giọng nói bằng speech_to_text, so khớp với câu gốc và chấm điểm phát âm trong app Learn English Through Music.
---

# Quy trình chấm điểm phát âm

Đã cài đặt thật trong [`app/lib/features/pronunciation/presentation/pronunciation_screen.dart`](../../../app/lib/features/pronunciation/presentation/pronunciation_screen.dart). Dùng skill này khi cần thêm màn luyện phát âm mới hoặc chỉnh thuật toán chấm điểm.

## Luồng xử lý
1. **Khởi tạo**: gọi `SpeechToText().initialize()` khi màn hình mở, kiểm tra thiết bị có hỗ trợ + đã cấp quyền `RECORD_AUDIO` (đã khai báo trong `AndroidManifest.xml`).
2. **Ghi âm**: người dùng chạm nút mic → gọi `speech.listen(listenOptions: SpeechListenOptions(localeId: 'en_US'))`, nhận kết quả liên tục qua `onResult`.
3. **Dừng & chấm điểm**: khi người dùng chạm dừng (hoặc speech tự kết thúc), chuẩn hoá cả câu mẫu và câu nhận diện được (`_normalize`: lowercase, bỏ ký tự đặc biệt, tách từ), so khớp **theo vị trí từng từ** (không phải chỉ đếm từ đúng ngẫu nhiên vị trí) để phát hiện đúng từ nào sai ở đúng chỗ nào.
4. **Hiển thị kết quả**: % số từ khớp đúng vị trí, kèm chip màu xanh (đúng)/đỏ (sai) cho từng từ trong câu mẫu.

## Giới hạn cần nói rõ với người dùng/PM
`speech_to_text` (ASR) được huấn luyện để đoán từ người dùng ĐỊNH nói, nên có thể "tự sửa" phát âm chưa chuẩn thành đúng từ trong văn bản kết quả — nghĩa là cách chấm này chính xác cho việc **có nói đúng từ/đúng thứ tự không**, nhưng KHÔNG chấm được lỗi phát âm ở mức âm vị (accent, ngữ điệu). Muốn chấm âm vị chính xác hơn, xem phương án Azure Pronunciation Assessment trong `docs/research-pronunciation.md`.

## Khi cần mở rộng
- Thêm ngôn ngữ/giọng khác: đổi `localeId`.
- Muốn giữ file ghi âm thô: thêm package `record`, ghi song song lúc `speech.listen`.
- Muốn chấm chi tiết hơn (âm vị): xem kiến trúc thay thế trong `docs/research-pronunciation.md` và `docs/research-ai-voice.md`.
