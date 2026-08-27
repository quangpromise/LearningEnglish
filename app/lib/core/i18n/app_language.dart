/// Ngôn ngữ GIAO DIỆN (UI) của app — KHÔNG liên quan đến bảng từ vựng học
/// (luôn là Anh→Việt, vì đó là nội dung học, không phải chrome của app).
enum AppLanguage {
  vi('🇻🇳', 'Tiếng Việt'),
  en('🇺🇸', 'English');

  const AppLanguage(this.flag, this.label);
  final String flag;
  final String label;
}
