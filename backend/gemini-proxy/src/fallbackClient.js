import WebSocket from 'ws';

/**
 * Kết nối tới fallback-pipeline (Python: faster-whisper + Ollama + Piper)
 * khi Gemini Live hết quota. Giao thức nội bộ đơn giản: gửi/nhận audio
 * dạng binary WebSocket frame, cùng khuôn dạng với client Flutter, để
 * gemini-proxy chỉ cần forward 2 chiều mà không cần biết chi tiết bên trong.
 */
export function connectFallback(fallbackUrl, { onAudioChunk, onError }) {
  const ws = new WebSocket(fallbackUrl);

  ws.on('open', () => console.log('[fallback] Đã kết nối fallback-pipeline'));
  ws.on('message', (data) => onAudioChunk(data));
  ws.on('error', (err) => onError?.(err));
  ws.on('close', () => console.log('[fallback] Mất kết nối fallback-pipeline'));

  return ws;
}
