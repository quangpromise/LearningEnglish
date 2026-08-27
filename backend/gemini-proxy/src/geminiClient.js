/**
 * Wrapper kết nối tới Google Gemini Live API.
 *
 * KHUNG CODE — chưa gọi API thật. Giao thức WebSocket chính thức của Gemini
 * Live thay đổi theo thời gian, xem tài liệu mới nhất trước khi hoàn thiện:
 * https://ai.google.dev/gemini-api/docs/live-api
 *
 * Mục tiêu của lớp này:
 *  - Mở 1 phiên (session) Gemini Live cho mỗi client Flutter kết nối tới.
 *  - Forward audio chunk từ client sang Gemini, forward audio phản hồi ngược lại.
 *  - Khi Gemini trả lỗi quota/429, gọi `onQuotaExceeded()` để gemini-proxy
 *    tự động chuyển sang fallback-pipeline (xem index.js).
 */
export class GeminiLiveSession {
  constructor({ apiKey, onAudioChunk, onQuotaExceeded, onError }) {
    this.apiKey = apiKey;
    this.onAudioChunk = onAudioChunk;
    this.onQuotaExceeded = onQuotaExceeded;
    this.onError = onError;
    this.connected = false;
  }

  async connect() {
    // TODO: thay bằng kết nối WebSocket/gRPC thật tới Gemini Live API,
    // dùng SDK chính thức (@google/genai) hoặc endpoint WebSocket trực tiếp.
    // Ví dụ khung tham khảo (KHÔNG chạy được, cần thay bằng API thật):
    //
    // import { GoogleGenAI } from '@google/genai';
    // const client = new GoogleGenAI({ apiKey: this.apiKey });
    // this.session = await client.live.connect({
    //   model: 'gemini-3.1-flash-live',
    //   callbacks: {
    //     onmessage: (msg) => this.onAudioChunk(msg.audio),
    //     onerror: (err) => this._handleError(err),
    //   },
    // });

    throw new Error(
      'GeminiLiveSession.connect() chưa được cài đặt thật — xem TODO trong geminiClient.js'
    );
  }

  sendAudioChunk(_chunk) {
    // TODO: this.session.sendRealtimeInput({ audio: chunk })
  }

  _handleError(err) {
    const isQuotaError = err?.status === 429 || /quota/i.test(err?.message ?? '');
    if (isQuotaError) {
      this.onQuotaExceeded?.(err);
    } else {
      this.onError?.(err);
    }
  }

  close() {
    this.connected = false;
    // TODO: this.session?.close()
  }
}
