import 'dotenv/config';
import { WebSocketServer } from 'ws';

import { GeminiLiveSession } from './geminiClient.js';
import { connectFallback } from './fallbackClient.js';

const PORT = process.env.PORT || 8787;
const GEMINI_API_KEY = process.env.GEMINI_API_KEY;
const FALLBACK_PIPELINE_URL = process.env.FALLBACK_PIPELINE_URL || 'ws://localhost:8788';

if (!GEMINI_API_KEY) {
  console.warn('[gemini-proxy] CẢNH BÁO: chưa có GEMINI_API_KEY trong .env — mọi phiên sẽ fallback ngay lập tức.');
}

const wss = new WebSocketServer({ port: PORT });
console.log(`[gemini-proxy] Đang lắng nghe ws://localhost:${PORT}`);

wss.on('connection', (clientSocket) => {
  console.log('[gemini-proxy] Client Flutter kết nối');

  let usingFallback = false;
  let fallbackSocket = null;

  const switchToFallback = (reason) => {
    if (usingFallback) return;
    usingFallback = true;
    console.warn(`[gemini-proxy] Chuyển sang fallback-pipeline. Lý do: ${reason}`);
    fallbackSocket = connectFallback(FALLBACK_PIPELINE_URL, {
      onAudioChunk: (chunk) => clientSocket.send(chunk),
      onError: (err) => console.error('[fallback] Lỗi:', err.message),
    });
  };

  let geminiSession = null;
  if (GEMINI_API_KEY) {
    geminiSession = new GeminiLiveSession({
      apiKey: GEMINI_API_KEY,
      onAudioChunk: (chunk) => clientSocket.send(chunk),
      onQuotaExceeded: () => switchToFallback('Gemini Live báo lỗi quota/429'),
      onError: (err) => console.error('[gemini] Lỗi:', err.message),
    });
    geminiSession.connect().catch((err) => {
      console.error('[gemini] Không kết nối được:', err.message);
      switchToFallback('Không kết nối được Gemini Live');
    });
  } else {
    switchToFallback('Thiếu GEMINI_API_KEY');
  }

  clientSocket.on('message', (audioChunk) => {
    if (usingFallback) {
      fallbackSocket?.send(audioChunk);
    } else {
      geminiSession?.sendAudioChunk(audioChunk);
    }
  });

  clientSocket.on('close', () => {
    console.log('[gemini-proxy] Client Flutter ngắt kết nối');
    geminiSession?.close();
    fallbackSocket?.close();
  });
});
