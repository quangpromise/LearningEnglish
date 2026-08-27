import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VoiceOption {
  const VoiceOption({required this.name, required this.locale});
  final String name;
  final String locale;

  @override
  bool operator ==(Object other) =>
      other is VoiceOption && other.name == name && other.locale == locale;

  @override
  int get hashCode => Object.hash(name, locale);
}

/// Service TTS dùng chung cho toàn app — đảm bảo mọi màn hình (luyện phát
/// âm, tra từ trong lyric...) phát cùng 1 giọng đọc mà người dùng đã chọn,
/// thay vì mỗi nơi tự tạo `FlutterTts()` riêng với giọng mặc định của máy.
class AppTts {
  AppTts._();
  static final AppTts instance = AppTts._();

  final FlutterTts _tts = FlutterTts();
  static const _prefNameKey = 'tts_voice_name';
  static const _prefLocaleKey = 'tts_voice_locale';

  VoiceOption? _selected;
  VoiceOption? get selected => _selected;

  /// Gọi 1 lần lúc khởi động app để áp lại giọng đã lưu từ lần trước.
  Future<void> restoreSavedVoice() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_prefNameKey);
    final locale = prefs.getString(_prefLocaleKey);
    if (name != null && locale != null) {
      _selected = VoiceOption(name: name, locale: locale);
      await _applySelected();
    }
  }

  /// Lấy danh sách giọng đọc tiếng Anh có sẵn trên máy (engine TTS gốc).
  Future<List<VoiceOption>> loadEnglishVoices() async {
    final raw = await _tts.getVoices;
    final result = <VoiceOption>[];
    final seen = <String>{};
    if (raw is List) {
      for (final entry in raw) {
        if (entry is Map) {
          final name = entry['name']?.toString() ?? '';
          final locale = entry['locale']?.toString() ?? '';
          if (name.isNotEmpty && locale.toLowerCase().startsWith('en')) {
            final key = '$name|$locale';
            if (seen.add(key)) {
              result.add(VoiceOption(name: name, locale: locale));
            }
          }
        }
      }
    }
    result.sort((a, b) => a.locale.compareTo(b.locale));
    return result;
  }

  Future<void> selectVoice(VoiceOption voice) async {
    _selected = voice;
    await _applySelected();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefNameKey, voice.name);
    await prefs.setString(_prefLocaleKey, voice.locale);
  }

  Future<void> _applySelected() async {
    final v = _selected;
    if (v != null) {
      await _tts.setVoice({'name': v.name, 'locale': v.locale});
    }
  }

  Future<void> speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }
}
