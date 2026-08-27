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
  static const googleWebClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');

  static bool get isConfigured => supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty && googleWebClientId.isNotEmpty;

  /// Commit SHA của bản build hiện tại, do CI truyền vào lúc build
  /// (--dart-define=BUILD_SHA=...). Rỗng khi build cục bộ không truyền vào —
  /// tính năng kiểm tra cập nhật sẽ tự bỏ qua trong trường hợp đó.
  static const buildSha = String.fromEnvironment('BUILD_SHA');
}
