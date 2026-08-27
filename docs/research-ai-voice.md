# Nghiên cứu: AI trò chuyện bằng giọng nói + sửa lỗi phát âm

Mục tiêu: một "bạn luyện nói" AI trò chuyện tự nhiên bằng giọng nói với người dùng, chỉ ra khi phát âm/ngữ pháp chưa đúng, ưu tiên miễn phí. Kết luận: dùng **Google Gemini Live API làm chính**, tự động **fallback sang pipeline mã nguồn mở tự host** khi hết quota miễn phí — không phụ thuộc hoàn toàn vào 1 nhà cung cấp.

## Bảng so sánh (nghiên cứu 2026)

| Giải pháp | Chi phí | Chất lượng hội thoại tự nhiên | Ghi chú |
|---|---|---|---|
| **Google Gemini Live API** (AI Studio) | Free tier cho prototype/rate giới hạn; vượt free tier: $3/1M token audio input, $12/1M token audio output | Cao — speech-to-speech độ trễ thấp, hỗ trợ ngắt lời tự nhiên (model Gemini 3.1 Flash Live) | Free tier không cam kết SLA cho production nhiều người dùng đồng thời — cần theo dõi lỗi quota (HTTP 429) để tự chuyển sang fallback |
| **OpenAI Realtime API** | Không có free tier thật sự (chỉ $5 credit dùng thử ban đầu); production ~$0.05/phút với model gpt-realtime-2.1 | Cao nhất theo đánh giá thị trường hiện tại | **Loại khỏi lựa chọn** — không đáp ứng yêu cầu miễn phí của dự án |
| **Azure AI Speech — Pronunciation Assessment** | Free tier F0: 5 giờ audio/tháng (dùng chung quota Speech-to-Text) | Không phải hội thoại — là engine **chấm điểm phát âm theo văn bản tham chiếu cố định** (accuracy/fluency/completeness/prosody ở mức âm vị) | Không dùng để "trò chuyện tự do"; phù hợp cho tính năng Pronunciation Practice (luyện theo câu lyric cụ thể) đã có trong roadmap |
| **Tự host: faster-whisper (STT) + Ollama LLM (Llama 3.3 8B / Phi-4) + Piper (TTS)** | Miễn phí vĩnh viễn về phía API — chỉ tốn chi phí hạ tầng server chạy pipeline | Trung bình-khá, phụ thuộc cấu hình server, thấp hơn Gemini Live | 100% mã nguồn mở, chạy được trên 1 VPS riêng (vd Oracle Cloud Free Tier có VM luôn miễn phí) |

## Giới hạn kỹ thuật quan trọng

Cả Gemini Live lẫn Whisper đều dùng ASR (nhận diện giọng nói) được huấn luyện để **đoán ra từ người dùng ĐỊNH nói**, kể cả khi phát âm chưa chuẩn hoặc có giọng nước ngoài — nghĩa là ASR thường tự "sửa" âm thanh nghe được thành đúng từ trong đầu ra văn bản. Do đó, hội thoại tự do (không có câu mẫu cố định trước) **khó phát hiện chính xác lỗi phát âm ở mức âm vị**. AI hội thoại (Gemini Live hoặc LLM tự host) chỉ góp ý phát âm ở mức tương đối — dựa vào ngữ cảnh, từ bị nghe nhầm lặp lại nhiều lần, hoặc lỗi ngữ pháp/từ vựng rõ ràng — chứ không thay thế được engine chấm điểm âm vị chuyên dụng như Azure Pronunciation Assessment (vốn cần biết trước câu mục tiêu để so khớp).

**Vì vậy tách rõ 2 tính năng khác mục đích:**
- **AI Voice Chat** (tính năng mới) — trò chuyện tự do, tự nhiên bằng giọng nói; AI góp ý phát âm/ngữ pháp/từ vựng ở mức tương đối trong lúc chat.
- **Pronunciation Practice** (đã có trong roadmap giai đoạn 2, xem `docs/roadmap.md`) — luyện theo câu cụ thể trong lyric bằng `speech_to_text`; có thể nâng cấp dùng Azure Pronunciation Assessment (free 5h/tháng) khi cần điểm chính xác từng âm.

## Kiến trúc đề xuất

```
App Flutter (mic + loa)
      │  audio stream (WebSocket)
      ▼
Backend proxy nhỏ (tự host, vd Oracle Cloud Free Tier VM)
      │
      ├─ Mặc định: forward sang Google Gemini Live API
      │              (API key giữ phía server, KHÔNG nhúng trong app)
      │
      └─ Khi Gemini trả lỗi quota/429 (hoặc rate-limit nội bộ theo user):
                    tự động fallback sang pipeline tự host:
                    faster-whisper (STT) → Ollama LLM (hội thoại + góp ý) → Piper (TTS)
                    trả audio phản hồi ngược lại app qua cùng WebSocket
```

Lý do bắt buộc phải có backend (không gọi Gemini Live thẳng từ Flutter app): API key Gemini nhúng trong client APK có thể bị trích xuất/lạm dụng khi APK phát tán qua sideload — đây là yêu cầu bảo mật, không phải tùy chọn.

Xem khung code khởi tạo tại [`backend/`](../backend/README.md).

## Nguồn tham khảo
- Gemini Live API overview — ai.google.dev/gemini-api/docs/live-api
- Azure AI Speech Pronunciation Assessment — learn.microsoft.com (Azure AI services)
- OpenAI Realtime API pricing 2026 — nhiều nguồn tổng hợp giá gpt-realtime-2.1
- Local AI voice stack (Whisper + Ollama + Piper) — các hướng dẫn self-host 2026
