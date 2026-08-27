import 'dart:convert';

import 'package:http/http.dart' as http;

/// Dịch Anh-Việt qua MyMemory Translation API — miễn phí, không cần key,
/// không giới hạn nghiêm ngặt cho nhu cầu tra từ đơn lẻ của app học ngôn ngữ
/// (xem docs/research-translation-tts.md). Trước đây dùng google_mlkit_
/// translation (dịch on-device) nhưng thư viện đó nhúng theo 1 file native
/// ~16MB (libtranslate_jni.so) vào APK — đổi sang gọi HTTP để giảm dung
/// lượng app, đánh đổi lấy việc luôn cần mạng khi dịch (chấp nhận được vì
/// tra từ điển/giọng đọc chất lượng cao cũng đã cần mạng).
class AppTranslator {
  AppTranslator._();
  static final AppTranslator instance = AppTranslator._();

  Future<String> translateToVietnamese(String text) async {
    final uri = Uri.parse(
      'https://api.mymemory.translated.net/get'
      '?q=${Uri.encodeComponent(text)}&langpair=en|vi',
    );
    final res = await http.get(uri).timeout(const Duration(seconds: 8));
    if (res.statusCode != 200) {
      throw Exception('MyMemory trả về lỗi HTTP ${res.statusCode}');
    }
    final data = jsonDecode(res.body);
    final translated = data['responseData']?['translatedText'] as String?;
    if (translated == null || translated.isEmpty) {
      throw Exception('MyMemory không trả về bản dịch');
    }
    return translated;
  }
}
