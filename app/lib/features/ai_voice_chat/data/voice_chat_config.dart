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
