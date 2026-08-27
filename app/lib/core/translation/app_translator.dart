import 'package:google_mlkit_translation/google_mlkit_translation.dart';

/// Dịch Anh-Việt on-device qua ML Kit — tải model 1 lần khi có mạng, sau đó
/// dùng offline không giới hạn số lượt (xem docs/research-translation-tts.md).
/// Dùng chung 1 instance cho cả app để không tải/khởi tạo lại translator mỗi
/// lần mở popup từ.
class AppTranslator {
  AppTranslator._();
  static final AppTranslator instance = AppTranslator._();

  final _modelManager = OnDeviceTranslatorModelManager();
  final _translator = OnDeviceTranslator(
    sourceLanguage: TranslateLanguage.english,
    targetLanguage: TranslateLanguage.vietnamese,
  );

  bool _modelReady = false;

  Future<void> _ensureModelDownloaded() async {
    if (_modelReady) return;
    final downloaded = await _modelManager.isModelDownloaded(
      TranslateLanguage.vietnamese.bcpCode,
    );
    if (!downloaded) {
      await _modelManager.downloadModel(TranslateLanguage.vietnamese.bcpCode);
    }
    _modelReady = true;
  }

  /// Trả về bản dịch tiếng Việt, hoặc ném lỗi nếu không có mạng lần tải đầu.
  Future<String> translateToVietnamese(String text) async {
    await _ensureModelDownloaded();
    return _translator.translateText(text);
  }
}
