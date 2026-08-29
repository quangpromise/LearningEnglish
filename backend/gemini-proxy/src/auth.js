import jwt from 'jsonwebtoken';

/**
 * Xac thuc nguoi dung truoc khi cho phep mo ket noi WebSocket toi voice-chat -
 * tranh nguoi la goi thang endpoint nay de "muon" quota Gemini/server cua
 * minh ma khong qua app that. App Flutter da dang nhap Supabase san, nen
 * tai dung luon JWT (access token) Supabase da cap cho nguoi dung, gui kem
 * theo query string khi mo WebSocket: ws://host/voice-chat?token=<jwt>.
 *
 * SUPABASE_JWT_SECRET lay tu Supabase Dashboard > Project Settings > API >
 * JWT Secret (KHONG phai anon key hay service_role key).
 */
export function verifySupabaseToken(token, jwtSecret) {
  if (!token || !jwtSecret) return null;
  try {
    const payload = jwt.verify(token, jwtSecret, { algorithms: ['HS256'] });
    // Supabase dat id nguoi dung o claim "sub".
    return payload?.sub ?? null;
  } catch {
    return null;
  }
}

/**
 * Gioi han so tin nhan audio/giay moi nguoi dung, tranh 1 tai khoan gui lien
 * tuc lam can quota Gemini/server dung chung cho ca nhom ban. Dung sliding
 * window don gian trong bo nho - du cho quy mo 1 nhom nho, khong can Redis.
 */
export class RateLimiter {
  constructor({ maxPerWindow = 120, windowMs = 60_000 } = {}) {
    this.maxPerWindow = maxPerWindow;
    this.windowMs = windowMs;
    this.hits = new Map(); // userId -> [timestamps]
  }

  allow(userId) {
    const now = Date.now();
    const timestamps = (this.hits.get(userId) ?? []).filter(
      (t) => now - t < this.windowMs
    );
    if (timestamps.length >= this.maxPerWindow) {
      this.hits.set(userId, timestamps);
      return false;
    }
    timestamps.push(now);
    this.hits.set(userId, timestamps);
    return true;
  }
}
