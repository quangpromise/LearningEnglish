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

const BASE_PROMPT =
  'Ban la mot nguoi ban luyen noi tieng Anh than thien, kien nhan. Tro chuyen ' +
  'tu nhien bang tieng Anh voi nguoi dung ({learner}). Neu nguoi dung dung sai ' +
  'ngu phap hoac dung tu chua chinh xac, nhe nhang chi ra cach noi dung hon ' +
  'NGAY TRONG luc tro chuyen (khong ngat mach hoi thoai qua nhieu), roi tiep ' +
  'tuc cau chuyen. Giu cau tra loi ngan gon, de hieu, phu hop de luyen nghe-noi.';

// Huong dan rieng theo cap hoc (query `level` tu app - xem
// app/lib/features/learning_path/data/learning_path_models.dart LearnerLevel
// va docs/research-level-based-content.md muc 6). Khong co/khong hop le ->
// dung cap trung cap nhu truoc.
const LEVEL_PROMPTS = {
  basic: {
    learner: 'nguoi moi bat dau, trinh do A1-A2',
    guide:
      'Noi CHAM, ro rang. Chi dung tu rat thong dung, cau toi da 8 tu. Hoi cau ' +
      'dang Co/Khong hoac chon 1 trong 2 (vd "Do you like tea or coffee?"). Moi ' +
      'luot chi sua 1 loi quan trong nhat. Neu nguoi hoc bi hoac noi tieng Viet, ' +
      'goi y tu tieng Anh tuong ung va dong vien.',
  },
  intermediate: {
    learner: 'nguoi hoc trinh do trung binh',
    guide:
      'Noi toc do tu nhien nhung ro, dung tu vung doi thuong, hoi cau mo ve ' +
      'cuoc song hang ngay.',
  },
  advanced: {
    learner: 'nguoi hoc nang cao B1-C1, dang di lam hoac luyen thi TOEIC/IELTS',
    guide:
      'Noi toc do ban ngu, dung thanh ngu va cum dong tu tu nhien. Khi phu hop, ' +
      'de xuat nhap vai tinh huong that (hop, phong van, trao doi email, cau hoi ' +
      'kieu IELTS Speaking Part 1-3). Ngoai sua loi, neu cau dung nhung chua tu ' +
      'nhien thi goi y cach noi tu nhien hon.',
  },
};

export function normalizeLevel(level) {
  return Object.hasOwn(LEVEL_PROMPTS, level) ? level : 'intermediate';
}

export function systemPromptFor(level) {
  const { learner, guide } = LEVEL_PROMPTS[normalizeLevel(level)];
  return `${BASE_PROMPT.replace('{learner}', learner)}\n\n${guide}`;
}

/**
 * Wrapper ket noi toi Google Gemini Live API qua SDK chinh thuc @google/genai.
 *
 * Moi client Flutter ket noi toi gemini-proxy se duoc gan 1 GeminiLiveSession
 * rieng. Audio chunk tu client duoc forward sang Gemini (dinh dang PCM 16-bit,
 * 16kHz, little-endian - client Flutter phai gui dung dinh dang nay), audio
 * phan hoi tu Gemini duoc forward nguoc lai qua onAudioChunk.
 */
export class GeminiLiveSession {
  constructor({ apiKey, level, onAudioChunk, onQuotaExceeded, onError }) {
    this.apiKey = apiKey;
    this.level = normalizeLevel(level);
    this.onAudioChunk = onAudioChunk;
    this.onQuotaExceeded = onQuotaExceeded;
    this.onError = onError;
    this.connected = false;
    this.session = null;
    this._turnAudioParts = [];
  }

  async connect() {
    const client = new GoogleGenAI({ apiKey: this.apiKey });
    this.session = await client.live.connect({
      model: MODEL,
      config: {
        responseModalities: [Modality.AUDIO],
        systemInstruction: systemPromptFor(this.level),
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
