import { GoogleGenAI, Modality } from '@google/genai';

// Model + prompt he thong co the doi theo thoi gian - Gemini Live API thay
// doi ten model preview thuong xuyen, kiem tra tai lieu moi nhat truoc khi
// nang cap: https://ai.google.dev/gemini-api/docs/live-api
const MODEL = process.env.GEMINI_LIVE_MODEL || 'gemini-3.1-flash-live-preview';

const SYSTEM_PROMPT =
  'Ban la mot nguoi ban luyen noi tieng Anh than thien, kien nhan. Tro chuyen ' +
  'tu nhien bang tieng Anh voi nguoi dung (nguoi hoc tieng Anh trinh do trung ' +
  'binh). Neu nguoi dung dung sai ngu phap hoac dung tu chua chinh xac, nhe ' +
  'nhang chi ra cach noi dung hon NGAY TRONG luc tro chuyen (khong ngat mach ' +
  'hoi thoai qua nhieu), roi tiep tuc cau chuyen. Giu cau tra loi ngan gon, ' +
  'de hieu, phu hop de luyen nghe-noi.';

/**
 * Wrapper ket noi toi Google Gemini Live API qua SDK chinh thuc @google/genai.
 *
 * Moi client Flutter ket noi toi gemini-proxy se duoc gan 1 GeminiLiveSession
 * rieng. Audio chunk tu client duoc forward sang Gemini (dinh dang PCM 16-bit,
 * 16kHz, little-endian - client Flutter phai gui dung dinh dang nay), audio
 * phan hoi tu Gemini duoc forward nguoc lai qua onAudioChunk.
 */
export class GeminiLiveSession {
  constructor({ apiKey, onAudioChunk, onQuotaExceeded, onError }) {
    this.apiKey = apiKey;
    this.onAudioChunk = onAudioChunk;
    this.onQuotaExceeded = onQuotaExceeded;
    this.onError = onError;
    this.connected = false;
    this.session = null;
  }

  async connect() {
    const client = new GoogleGenAI({ apiKey: this.apiKey });
    this.session = await client.live.connect({
      model: MODEL,
      config: {
        responseModalities: [Modality.AUDIO],
        systemInstruction: SYSTEM_PROMPT,
      },
      callbacks: {
        onopen: () => {
          this.connected = true;
        },
        onmessage: (message) => this._handleMessage(message),
        onerror: (err) => this._handleError(err),
        onclose: (event) => {
          this.connected = false;
          // Mot so loi quota/rate-limit duoc Gemini tra ve qua ma dong ket
          // noi (close code/reason) thay vi onerror - kiem tra ca 2 noi.
          if (this._isQuotaIssue(event?.reason)) {
            this.onQuotaExceeded?.(new Error(event.reason));
          }
        },
      },
    });
  }

  _handleMessage(message) {
    const parts = message?.serverContent?.modelTurn?.parts;
    if (!parts) return;
    for (const part of parts) {
      if (part.inlineData?.data) {
        // Du lieu tra ve dang base64 - decode thanh Buffer nhi phan truoc
        // khi forward qua WebSocket cho client Flutter.
        this.onAudioChunk(Buffer.from(part.inlineData.data, 'base64'));
      }
    }
  }

  _isQuotaIssue(text) {
    return /quota|rate.?limit|429|resource_exhausted/i.test(text ?? '');
  }

  sendAudioChunk(chunk) {
    if (!this.session) return;
    this.session.sendRealtimeInput({
      audio: {
        data: Buffer.isBuffer(chunk) ? chunk.toString('base64') : chunk,
        mimeType: 'audio/pcm;rate=16000',
      },
    });
  }

  _handleError(err) {
    const isQuotaError =
      err?.status === 429 || this._isQuotaIssue(err?.message);
    if (isQuotaError) {
      this.onQuotaExceeded?.(err);
    } else {
      this.onError?.(err);
    }
  }

  close() {
    this.connected = false;
    this.session?.close();
    this.session = null;
  }
}
