import 'package:shared_preferences/shared_preferences.dart';

/// Luu kich co chu (dung chung cho moi sach) va trang dang doc CUA TUNG
/// cuon sach (rieng theo assetPath) tren may - de lan sau mo lai dung
/// vi tri va co chu da chinh.
class ReadingPrefs {
  ReadingPrefs._();

  static const double defaultFontScale = 1.0;
  static const double minFontScale = 0.8;
  static const double maxFontScale = 1.6;

  static const _fontScaleKey = 'reading_font_scale';

  static Future<double> loadFontScale() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_fontScaleKey) ?? defaultFontScale;
  }

  static Future<void> saveFontScale(double scale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontScaleKey, scale);
  }

  static String _progressKey(String assetPath) => 'reading_progress_$assetPath';

  /// Tra ve chi so DOAN VAN (khong phai trang) da doc gan nhat - on dinh
  /// hon so voi luu truc tiep so trang, vi so trang co the doi neu sau nay
  /// thay doi so doan van/trang.
  static Future<int> loadParagraphProgress(String assetPath) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_progressKey(assetPath)) ?? 0;
  }

  static Future<void> saveParagraphProgress(
    String assetPath,
    int paragraphIndex,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_progressKey(assetPath), paragraphIndex);
  }
}
