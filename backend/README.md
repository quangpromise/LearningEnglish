# Backend — AI Voice Chat (Gemini Live + fallback tự host)

Xem bối cảnh & lý do kiến trúc trong [`docs/research-ai-voice.md`](../docs/research-ai-voice.md).

Đây là **khung code khởi tạo** (chưa chạy được ngay) — cần điền API key thật và cấu hình trước khi dùng.

## Kiến trúc

```
App Flutter (mic + loa)
      │  WebSocket: ws://<backend>/voice-chat
      ▼
gemini-proxy (Node.js)
      │
      ├─ Mặc định: forward audio sang Google Gemini Live API
      │              (API key đọc từ biến môi trường phía server)
      │
      └─ Khi Gemini trả lỗi quota/429: tự động gọi sang fallback-pipeline
                    (faster-whisper STT → Ollama LLM → Piper TTS)
```

## Thư mục

- **`gemini-proxy/`** — Node.js WebSocket server, là điểm kết nối duy nhất mà app Flutter gọi tới. Giữ API key Gemini phía server (không bao giờ nhúng vào app). Khi phát hiện lỗi quota/429 từ Gemini, tự chuyển tiếp sang `fallback-pipeline`.
- **`fallback-pipeline/`** — Dịch vụ Python chạy pipeline mã nguồn mở: `faster-whisper` (nhận diện giọng nói) → `Ollama` (LLM hội thoại, model gợi ý: Llama 3.3 8B hoặc Phi-4) → `Piper` (tổng hợp giọng nói). Chạy độc lập, `gemini-proxy` gọi sang qua HTTP/WebSocket nội bộ.

## Yêu cầu hạ tầng

- 1 server/VPS chạy được Node.js 20+ và Python 3.10+ (gợi ý: Oracle Cloud Free Tier có VM luôn miễn phí, đủ chạy `gemini-proxy` + pipeline fallback ở mức tải thấp).
- Cài Ollama (https://ollama.com) và pull sẵn 1 model nhỏ, vd `ollama pull llama3.2` hoặc `phi4`.
- Cài Piper (https://github.com/rhasspy/piper) kèm 1 giọng tiếng Anh (vd `en_US-lessac-medium`).
- `pip install faster-whisper` (tự tải model Whisper khi chạy lần đầu).

## Setup nhanh (khi triển khai thật)

```bash
cd gemini-proxy
npm install
cp .env.example .env   # điền GEMINI_API_KEY thật vào đây
npm start

# terminal khác
cd fallback-pipeline
pip install -r requirements.txt
python server.py
```

## Việc còn thiếu để chạy được thật (TODO)
- [ ] Tích hợp đúng giao thức WebSocket của Gemini Live API (SDK chính thức thay đổi thường xuyên — kiểm tra tài liệu mới nhất trước khi code phần forward audio thật).
- [ ] Logic phát hiện lỗi 429/quota cụ thể theo response thật của Gemini Live.
- [ ] Điền prompt hệ thống cho Ollama LLM (vai trò "bạn luyện nói tiếng Anh", góp ý phát âm/ngữ pháp tự nhiên).
- [ ] Bảo mật endpoint (xác thực người dùng trước khi cho kết nối WebSocket, giới hạn rate theo user).
