/// URL WebSocket cua backend/gemini-proxy - PHAI thay bang dia chi that sau
/// khi da deploy backend (xem backend/README.md). Chua deploy o dau nen tam
/// de placeholder - tinh nang AI Voice Chat se bao loi ket noi cho toi khi
/// gia tri nay tro toi 1 server that dang chay gemini-proxy.
const kVoiceChatBackendUrl = 'wss://your-backend-host.example/voice-chat';

/// TAM THOI (theo yeu cau rieng): trong luc chua tao duoc VM Oracle Cloud do
/// het capacity, cho phep app ket noi THANG toi Gemini Live, bo qua
/// backend/gemini-proxy hoan toan. Key THAT khong hardcode o day - luon doc
/// tu --dart-define qua Env.geminiApiKeyDirect (xem core/config/env.dart) de
/// khong bao gio nam trong source code/git history.
///
/// CANH BAO BAO MAT: khi bat co nay va build APK phat cho nguoi khac, ai
/// decompile APK cung lay duoc key va dung duoc quota cua ban (du key khong
/// nam trong source code, no van bi nhung thang vao file APK sau khi build).
/// Doi lai `false` va dung [kVoiceChatBackendUrl] ngay khi co server that.
const kUseDirectGeminiConnection = true;

/// Bat/tat avatar sieu thuc Anam.ai (WebRTC, lipsync theo audio Gemini Live
/// tra ve) hien phia tren khung chat - xem AnamLiveAvatar +
/// GeminiLiveDirectClient.liveAudioChunks/turnAudioEnd. CHI hoat dong khi
/// [kUseDirectGeminiConnection] = true, vi VoiceChatClient (qua backend) chua
/// lam viec phat audio tung chunk truoc khi het luot noi.
const kUseAnamAvatar = false;

/// ID avatar da tao san tren Anam.ai (xem anam.ai/dashboard).
const kAnamAvatarId = '68b4b44d-874b-4343-a1c9-b97d3c4a4d6e';

/// Model render avatar - "cara-4" la model moi nhat Anam ho tro audio
/// passthrough luc viet code nay (2026-09), doi lai neu Anam doi ten model
/// hoac dashboard cua avatar tren bao model khac.
const kAnamAvatarModel = 'cara-4';
