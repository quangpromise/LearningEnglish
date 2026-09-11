import { GoogleGenAI, Modality } from '@google/genai';

// Model + prompt he thong co the doi theo thoi gian - Gemini Live API thay
// doi ten model preview thuong xuyen, kiem tra tai lieu moi nhat truoc khi
// nang cap: https://ai.google.dev/gemini-api/docs/live-api
const MODEL = process.env.GEMINI_LIVE_MODEL || 'gemini-3.1-flash-live-preview';

// Gemini Live tra am thanh dang PCM 16-bit, mono, 24kHz (khong co header).
const OUTPUT_SAMPLE_RATE = 24000;

/**
 * Boc du lieu PCM tho thanh 1 file WAV hoan chinh (them header 44 byte) -
 * de client Flutter (va ca fallback-pipeline dung Piper, von da tra ve WAV
 * san) nhan duoc CUNG 1 dinh dang moi luot noi, khong can biet dang dung
 * Gemini hay fallback.
 */
function pcmToWav(pcmBuffer, sampleRate = OUTPUT_SAMPLE_RATE) {
  const header = Buffer.alloc(44);
  const byteRate = sampleRate * 2; // 16-bit mono
  header.write('RIFF', 0, 'ascii');
  header.writeUInt32LE(36 + pcmBuffer.length, 4);
  header.write('WAVE', 8, 'ascii');
  header.write('fmt ', 12, 'ascii');
  header.writeUInt32LE(16, 16); // fmt chunk size
  header.writeUInt16LE(1, 20); // PCM format
  header.writeUInt16LE(1, 22); // mono
  header.writeUInt32LE(sampleRate, 24);
  header.writeUInt32LE(byteRate, 28);
  header.writeUInt16LE(2, 32); // block align (16-bit mono)
  header.writeUInt16LE(16, 34); // bits per sample
  header.write('data', 36, 'ascii');
  header.writeUInt32LE(pcmBuffer.length, 40);
  return Buffer.concat([header, pcmBuffer]);
}

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
    this._turnAudioParts = [];
    // Rieng quota cua Google Search grounding (5.000 luot mien phi/thang)
    // co the het truoc quota audio chinh - khi do chi tat tool search va
    // ket noi lai, KHONG fallback toan bo sang pipeline tu host.
    this._searchEnabled = true;
  }

  async connect() {
    const client = new GoogleGenAI({ apiKey: this.apiKey });
    this.session = await client.live.connect({
      model: MODEL,
      config: {
        responseModalities: [Modality.AUDIO],
        systemInstruction: SYSTEM_PROMPT,
        // Cho phep Gemini tu tim kiem Google khi can du lieu thoi gian thuc
        // (gia crypto, gia dat, tin tuc...) - Gemini 3.x: 5.000 luot mien
        // phi/thang, sau do $14/1.000 luot ground. Xem docs/research-ai-voice.md.
        ...(this._searchEnabled ? { tools: [{ googleSearch: {} }] } : {}),
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
          this._handleQuotaText(event?.reason);
        },
      },
    });
  }

  _handleQuotaText(text) {
    if (!text) return;
    if (this._searchEnabled && this._isSearchQuotaIssue(text)) {
      this._disableSearchAndReconnect();
    } else if (this._isQuotaIssue(text)) {
      this.onQuotaExceeded?.(new Error(text));
    }
  }

  _isSearchQuotaIssue(text) {
    return this._isQuotaIssue(text) && /search|ground/i.test(text ?? '');
  }

  _disableSearchAndReconnect() {
    console.warn(
      '[gemini] Het quota Google Search grounding — tat tinh nang tim kiem, ' +
        'tiep tuc hoi thoai binh thuong (khong fallback).'
    );
    this._searchEnabled = false;
    this.session?.close();
    this.session = null;
    this.connect().catch((err) => {
      console.error('[gemini] Khong ket noi lai duoc sau khi tat search:', err.message);
      this.onError?.(err);
    });
  }

  _handleMessage(message) {
    const parts = message?.serverContent?.modelTurn?.parts;
    if (parts) {
      for (const part of parts) {
        if (part.inlineData?.data) {
          this._turnAudioParts.push(Buffer.from(part.inlineData.data, 'base64'));
        }
      }
    }
    // Gom het audio cua 1 luot noi (turn) roi moi gui 1 lan duoi dang WAV
    // hoan chinh - client chi can phat file, khong phai tu ghep chunk PCM
    // tho lai voi nhau.
    if (message?.serverContent?.turnComplete && this._turnAudioParts.length) {
      const wav = pcmToWav(Buffer.concat(this._turnAudioParts));
      this._turnAudioParts = [];
      this.onAudioChunk(wav);
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
    const text = err?.message ?? '';
    const isQuotaError = err?.status === 429 || this._isQuotaIssue(text);
    if (this._searchEnabled && isQuotaError && this._isSearchQuotaIssue(text)) {
      this._disableSearchAndReconnect();
    } else if (isQuotaError) {
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
