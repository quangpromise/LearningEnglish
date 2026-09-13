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
const kUseAnamAvatar = true;

/// ID avatar da tao san tren Anam.ai (xem anam.ai/dashboard).
///
/// TAM THOI dung CHUNG 1 avatar cho ca 2 gioi (Anam.ai moi chi co 1 avatar
/// da tao) - [kAnamAvatarIdMale]/[kAnamAvatarIdFemale] ben duoi deu tro ve
/// gia tri nay cho toi khi co ID avatar Nam/Nu rieng that tren Anam.ai. Doi
/// giong Gemini Live luc do se KHONG lam avatar Anam doi gioi (van avatar
/// cu), chi Spatius (da co du 2 ID that, xem kSpatiusAvatarIdMale/Female)
/// moi doi gioi ngay duoc.
const kAnamAvatarId = '68b4b44d-874b-4343-a1c9-b97d3c4a4d6e';

/// TODO: thay bang ID avatar NAM rieng tren Anam.ai khi co.
const kAnamAvatarIdMale = kAnamAvatarId;

/// TODO: thay bang ID avatar NU rieng tren Anam.ai khi co (co the chinh la
/// [kAnamAvatarId] hien tai neu avatar dang dung la Nu).
const kAnamAvatarIdFemale = kAnamAvatarId;

/// Model render avatar - "cara-4" la model moi nhat Anam ho tro audio
/// passthrough luc viet code nay (2026-09), doi lai neu Anam doi ten model
/// hoac dashboard cua avatar tren bao model khac.
const kAnamAvatarModel = 'cara-4';

/// URL cua serverless function Vercel - repo rieng
/// github.com/quangpromise/anam-session-proxy (tach khoi repo app vi Vercel
/// can root repo chua dung vercel.json/api/, xem README trong repo do). Khi
/// khac rong, AiVoiceChatScreen se doi session token Anam qua day THAY VI
/// goi thang API key trong app (Env.anamApiKeyDirect) - day la cach dung
/// nen, vi ANAM_API_KEY that CHI nam tren Vercel, khong con bi nhung vao
/// APK nua.
///
/// Gia tri nay CUNG chinh la noi Anam tu dong xin token moi khi phien 3
/// phut (gioi han goi Free) bi dong dot ngot - xem
/// AnamLiveAvatar._onSessionExpired trong anam_live_avatar.dart.
const kAnamVercelProxyUrl = 'https://anam-session-proxy.vercel.app';

/// Bat/tat co che du phong (failover) sang Spatius AI (goi
/// spatius_avatarkit, render avatar NATIVE tren GPU may - khac Anam dung
/// WebView/WebRTC) khi Anam bi loi khong the phuc hoi (het quota
/// 30 phut/thang cua goi Free, hoac loi WebView khac). Xem
/// SpatiusLiveAvatar + AiVoiceChatScreen._onAnamUnrecoverable.
const kUseSpatiusFailover = true;

/// App ID cua du an tren Spatius Studio (app.spatius.ai) - can de goi
/// AvatarSDK.initialize. Khac voi API key (chi nam server-side), App ID
/// khong bi coi la bi mat nen dua thang vao app duoc.
const kSpatiusAppId = 'app_mtz9is0f_1ok6yyo';

/// ID avatar Nam/Nu da tao rieng tren Spatius Studio - KHONG dung chung ID
/// voi Anam ([kAnamAvatarId]) vi 2 nen tang co kho avatar rieng. Chon avatar
/// nao dua vao GeminiGender hien tai - xem
/// AiVoiceChatScreen._currentSpatiusAvatarId.
const kSpatiusAvatarIdFemale = 'd51ab422-3db7-47cc-afa8-7273b02bc70b';
const kSpatiusAvatarIdMale = '566981dd-1d95-4844-953e-d67e18b2fde8';

/// URL serverless function tu viet (repo rieng
/// github.com/quangpromise/spatius-session-proxy, xem README trong do) giu
/// SPATIUS_API_KEY that server-side va tra ve {"sessionToken": "..."} cho
/// SpatiusSessionApi.fetchSessionTokenFromProxy - xem api/session_token.py
/// trong repo do de biet endpoint that cua Spatius dang duoc goi.
const kSpatiusVercelProxyUrl =
    'https://spatius-session-proxy.vercel.app/api/session_token';
