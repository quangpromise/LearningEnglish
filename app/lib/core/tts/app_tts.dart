import 'dart:convert';
import 'dart:io';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env.dart';

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

/// Giọng đọc chất lượng cao (VoiceRSS, mã nguồn qua Edge Function `tts` để
/// giấu API key — xem docs/setup-voicerss-tts.md). `locale` là mã VoiceRSS
/// dùng cho tham số `hl`, vd 'en-us'.
class CloudVoice {
  const CloudVoice({required this.locale, required this.label});
  final String locale;
  final String label;

  @override
  bool operator ==(Object other) =>
      other is CloudVoice && other.locale == locale;

  @override
  int get hashCode => locale.hashCode;
}

const kCloudVoices = [
  CloudVoice(locale: 'en-us', label: 'Tiếng Anh (Mỹ)'),
  CloudVoice(locale: 'en-gb', label: 'Tiếng Anh (Anh)'),
  CloudVoice(locale: 'en-au', label: 'Tiếng Anh (Úc)'),
  CloudVoice(locale: 'en-in', label: 'Tiếng Anh (Ấn Độ)'),
  CloudVoice(locale: 'en-ca', label: 'Tiếng Anh (Canada)'),
];

enum _TtsMode { device, cloud }

/// Service TTS dùng chung cho toàn app — ưu tiên giọng chất lượng cao
/// (VoiceRSS qua Edge Function) nếu người dùng đã chọn và có mạng; tự động
/// rơi về giọng gốc máy (flutter_tts, offline) nếu lỗi mạng/hết quota.
class AppTts {
  AppTts._();
  static final AppTts instance = AppTts._();

  final FlutterTts _deviceTts = FlutterTts();
  final AudioPlayer _cloudPlayer = AudioPlayer();

  static const _prefModeKey = 'tts_mode';
  static const _prefNameKey = 'tts_voice_name';
  static const _prefLocaleKey = 'tts_voice_locale';
  static const _prefCloudLocaleKey = 'tts_cloud_locale';

  _TtsMode _mode = _TtsMode.device;
  VoiceOption? _selectedDevice;
  CloudVoice? _selectedCloud;

  VoiceOption? get selected => _selectedDevice;
  CloudVoice? get selectedCloud => _selectedCloud;
  bool get isCloudMode => _mode == _TtsMode.cloud;

  /// Gọi 1 lần lúc khởi động app để áp lại giọng đã lưu từ lần trước.
  Future<void> restoreSavedVoice() async {
    final prefs = await SharedPreferences.getInstance();
    final mode = prefs.getString(_prefModeKey);

    if (mode == 'cloud') {
      final cloudLocale = prefs.getString(_prefCloudLocaleKey);
      final match = kCloudVoices.where((v) => v.locale == cloudLocale);
      if (match.isNotEmpty) {
        _mode = _TtsMode.cloud;
        _selectedCloud = match.first;
        return;
      }
    }

    final name = prefs.getString(_prefNameKey);
    final locale = prefs.getString(_prefLocaleKey);
    if (name != null && locale != null) {
      _selectedDevice = VoiceOption(name: name, locale: locale);
      await _applySelectedDevice();
    }
  }

  /// Lấy danh sách giọng đọc tiếng Anh có sẵn trên máy (engine TTS gốc).
  Future<List<VoiceOption>> loadEnglishVoices() async {
    final raw = await _deviceTts.getVoices;
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
    _mode = _TtsMode.device;
    _selectedDevice = voice;
    await _applySelectedDevice();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefModeKey, 'device');
    await prefs.setString(_prefNameKey, voice.name);
    await prefs.setString(_prefLocaleKey, voice.locale);
  }

  Future<void> selectCloudVoice(CloudVoice voice) async {
    _mode = _TtsMode.cloud;
    _selectedCloud = voice;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefModeKey, 'cloud');
    await prefs.setString(_prefCloudLocaleKey, voice.locale);
  }

  Future<void> _applySelectedDevice() async {
    final v = _selectedDevice;
    if (v != null) {
      await _deviceTts.setVoice({'name': v.name, 'locale': v.locale});
    }
  }

  Future<void> speak(String text) async {
    if (_mode == _TtsMode.cloud && _selectedCloud != null) {
      try {
        await _speakCloud(text, _selectedCloud!);
        return;
      } catch (_) {
        // Không có mạng / hết quota VoiceRSS -> rơi về giọng máy bên dưới.
      }
    }
    await _deviceTts.stop();
    await _deviceTts.speak(text);
  }

  Future<void> _speakCloud(String text, CloudVoice voice) async {
    if (!Env.isConfigured) {
      throw Exception('Supabase chưa cấu hình — không gọi được giọng cloud.');
    }
    final dir = await getTemporaryDirectory();
    final cacheDir = Directory('${dir.path}/tts_cache');
    if (!await cacheDir.exists()) await cacheDir.create(recursive: true);
    final file = File('${cacheDir.path}/${voice.locale}_${text.hashCode}.mp3');

    if (!await file.exists()) {
      final res = await Supabase.instance.client.functions.invoke(
        'tts',
        body: {'text': text, 'locale': voice.locale},
      );
      final audioContent = (res.data as Map)['audioContent'] as String?;
      if (audioContent == null) {
        throw Exception('Edge Function tts không trả về audioContent.');
      }
      await file.writeAsBytes(base64Decode(audioContent));
    }

    await _cloudPlayer.stop();
    await _cloudPlayer.setFilePath(file.path);
    await _cloudPlayer.play();
  }
}
