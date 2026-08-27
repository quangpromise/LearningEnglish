# Nghiên cứu: ghi âm & chấm điểm phát âm

| Giải pháp | Chi phí | Offline? | Độ chi tiết | Ghi chú |
|---|---|---|---|---|
| **speech_to_text** (đang dùng, feature Pronunciation Practice) | Miễn phí | ✅ On-device (SFSpeechRecognizer/Android SpeechRecognizer) | So khớp văn bản (word-match), chưa phân tích âm vị | Đã tích hợp trong `app/lib/features/pronunciation/` — ghi âm, nhận diện, so khớp câu mẫu, tính % đúng theo từ |
| Azure AI Speech — Pronunciation Assessment | Free tier F0: 5 giờ audio/tháng | ❌ Cần mạng | Chấm điểm accuracy/fluency/completeness/prosody ở **mức âm vị** | Cần biết trước câu mục tiêu để so khớp — phù hợp nâng cấp cho Pronunciation Practice khi cần độ chính xác cao hơn |
| Tự host Whisper (STT thay thế) | Miễn phí (chỉ tốn hạ tầng server) | Tuỳ triển khai | Tương đương speech_to_text về độ chi tiết | Không giải quyết được vấn đề chấm âm vị — xem thêm `docs/research-ai-voice.md` |

## Giới hạn quan trọng
ASR nói chung (kể cả `speech_to_text`, Whisper, Gemini Live) được huấn luyện để **đoán từ người dùng định nói**, nên khó phát hiện chính xác lỗi phát âm ở mức âm vị khi không có câu tham chiếu cố định. Xem phân tích đầy đủ và kiến trúc AI Voice Chat liên quan tại [`docs/research-ai-voice.md`](research-ai-voice.md).

## Quyết định
- **MVP**: dùng `speech_to_text` so khớp văn bản (đã code trong `pronunciation_screen.dart`) — đơn giản, miễn phí, offline, đủ dùng cho phản hồi cơ bản.
- **Nâng cấp sau** (nếu cần chính xác hơn): tích hợp Azure Pronunciation Assessment cho các câu luyện tập có văn bản cố định (không dùng cho hội thoại tự do).
