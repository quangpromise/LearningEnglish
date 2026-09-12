/// Đọc cấu hình từ --dart-define, KHÔNG hardcode key vào code.
///
/// Chạy app kèm giá trị thật:
/// ```
/// flutter run \
///   --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
///   --dart-define=SUPABASE_ANON_KEY=xxxxx \
///   --dart-define=GOOGLE_WEB_CLIENT_ID=xxxxx.apps.googleusercontent.com
/// ```
/// Xem hướng dẫn lấy các giá trị này trong docs/setup-supabase.md.
class Env {
  Env._();

  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// OAuth Client ID loại "Web application" tạo trên Google Cloud Console —
  /// dùng chung cho mọi nền tảng khi xác thực qua Supabase (serverClientId).
  static const googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
  );

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty &&
      supabaseAnonKey.isNotEmpty &&
      googleWebClientId.isNotEmpty;

  /// Commit SHA của bản build hiện tại, do CI truyền vào lúc build
  /// (--dart-define=BUILD_SHA=...). Rỗng khi build cục bộ không truyền vào —
  /// tính năng kiểm tra cập nhật sẽ tự bỏ qua trong trường hợp đó.
  static const buildSha = String.fromEnvironment('BUILD_SHA');

  /// TẠM THỜI: API key Gemini dùng cho GeminiLiveDirectClient (kết nối
  /// thẳng, bỏ qua backend/gemini-proxy) — xem
  /// ai_voice_chat/data/voice_chat_config.dart. Không hardcode giá trị thật
  /// vào đây, luôn truyền qua --dart-define=GEMINI_API_KEY_DIRECT=... (CI đã
  /// cấu hình sẵn secret GEMINI_API_KEY_DIRECT).
  static const geminiApiKeyDirect = String.fromEnvironment(
    'GEMINI_API_KEY_DIRECT',
  );

  /// API key GIPHY (mien phi, dang ky tai developers.giphy.com) - dung cho
  /// tinh nang sticker trong chat (xem sticker_repository.dart). Khong
  /// hardcode gia tri that vao day, luon truyen qua
  /// --dart-define=GIPHY_API_KEY=... (CI da cau hinh sẵn secret GIPHY_API_KEY).
  static const giphyApiKey = String.fromEnvironment('GIPHY_API_KEY');

  /// TAM THOI (cung tinh chat voi geminiApiKeyDirect o tren): API key that
  /// cua Anam.ai, dung de app tu goi thang REST API
  /// POST https://api.anam.ai/v1/auth/session-token va doi lay session token
  /// ngan han cho AnamLiveAvatar (xem
  /// ai_voice_chat/data/anam_session_api.dart). Khong hardcode gia tri that,
  /// luon truyen qua --dart-define=ANAM_API_KEY_DIRECT=...
  ///
  /// CANH BAO BAO MAT giong het geminiApiKeyDirect: key nay se bi nhung vao
  /// APK sau khi build, ai decompile APK deu lay duoc va dung duoc quota Anam
  /// cua ban. Chi dung tam trong luc phat trien/test - truoc khi phat APK
  /// that cho nguoi dung, PHAI chuyen viec tao session token sang 1 backend
  /// rieng (vd them 1 endpoint nho vao backend/gemini-proxy) de key that chi
  /// nam tren server, khong bao gio xuong may nguoi dung.
  static const anamApiKeyDirect = String.fromEnvironment('ANAM_API_KEY_DIRECT');
}
