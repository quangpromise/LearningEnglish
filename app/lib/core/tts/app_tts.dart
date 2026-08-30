import 'dart:convert';
import 'dart:io';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env.dart';

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

/// Service TTS dùng chung cho toàn app — phát bằng giọng chất lượng cao
/// (VoiceRSS qua Edge Function) nếu người dùng đã chọn và có mạng; tự động
/// rơi về giọng mặc định của máy (flutter_tts, offline) nếu chưa chọn giọng
/// cloud, mất mạng, hoặc hết quota — để tính năng luyện phát âm vẫn dùng
/// được khi không có Internet, không bắt buộc phải cấu hình gì.
///
/// KHONG dung Gemini TTS o day - da thu tich hop lam giong dung chung cho ca
/// app nhung go bo lai theo yeu cau, chi giu VoiceRSS/giong may. Giong
/// Gemini (GeminiVoiceSelection) CHI con dung rieng cho AI Voice Chat trong
/// luc dang tro chuyen truc tiep voi Gemini Live, khong lien quan gi den
/// service nay nua.
class AppTts {
  AppTts._();
  static final AppTts instance = AppTts._();

  final FlutterTts _deviceTts = FlutterTts();
  final AudioPlayer _cloudPlayer = AudioPlayer();

  static const _prefCloudLocaleKey = 'tts_cloud_locale';

  CloudVoice? _selectedCloud;
  CloudVoice? get selectedCloud => _selectedCloud;

  bool _awaitCompletionConfigured = false;

  /// Gọi 1 lần lúc khởi động app để áp lại giọng đã lưu từ lần trước.
  Future<void> restoreSavedVoice() async {
    final prefs = await SharedPreferences.getInstance();
    final cloudLocale = prefs.getString(_prefCloudLocaleKey);
    if (cloudLocale != null) {
      final match = kCloudVoices.where((v) => v.locale == cloudLocale);
      if (match.isNotEmpty) _selectedCloud = match.first;
    }
  }

  Future<void> selectCloudVoice(CloudVoice voice) async {
    _selectedCloud = voice;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefCloudLocaleKey, voice.locale);
  }

  Future<void> speak(String text) async {
    if (_selectedCloud != null) {
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

  /// Doc 1 doan text va CHO den khi doc xong (hoac bi stop()) moi hoan tat -
  /// dung cho tinh nang doc sach thanh tieng theo tung cau (Reading), de
  /// biet chinh xac luc nao chuyen sang cau tiep theo thay vi doan mo dai
  /// (moi cau dai ngan khac nhau).
  Future<void> speakAndWait(String text) async {
    if (_selectedCloud != null) {
      try {
        await _speakCloud(text, _selectedCloud!);
        await _cloudPlayer.playerStateStream.firstWhere(
          (s) =>
              s.processingState == ProcessingState.completed ||
              s.processingState == ProcessingState.idle,
        );
        return;
      } catch (_) {
        // Không có mạng / hết quota VoiceRSS -> rơi về giọng máy bên dưới.
      }
    }
    if (!_awaitCompletionConfigured) {
      await _deviceTts.awaitSpeakCompletion(true);
      _awaitCompletionConfigured = true;
    }
    await _deviceTts.stop();
    await _deviceTts.speak(text);
  }

  /// Dung ngay lap tuc ca 2 nguon phat (may/cloud) - lam pending
  /// speakAndWait() hoan tat som (khong loi) de vong lap doc tuan tu o
  /// Reading dung lai dung luc thay vi cho het cau dang doc.
  Future<void> stopSpeaking() async {
    await _deviceTts.stop();
    await _cloudPlayer.stop();
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
