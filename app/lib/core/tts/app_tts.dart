import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/ai_voice_chat/data/gemini_voices.dart';
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
class AppTts {
  AppTts._();
  static final AppTts instance = AppTts._();

  final FlutterTts _deviceTts = FlutterTts();
  final AudioPlayer _cloudPlayer = AudioPlayer();

  static const _prefCloudLocaleKey = 'tts_cloud_locale';
  static const _prefUseGeminiKey = 'tts_use_gemini';

  CloudVoice? _selectedCloud;
  CloudVoice? get selectedCloud => _selectedCloud;

  /// True neu nguoi dung chon dung giong Gemini (GeminiVoiceSelection) cho
  /// MOI tinh nang doc tu/cau trong app, khong chi rieng luc tro chuyen o AI
  /// Voice Chat. Loai tru lan nhau voi _selectedCloud - chon 1 trong 2, xem
  /// selectGeminiVoice()/selectCloudVoice().
  bool _useGemini = false;
  bool get useGemini => _useGemini;

  /// Gọi 1 lần lúc khởi động app để áp lại giọng đã lưu từ lần trước.
  Future<void> restoreSavedVoice() async {
    final prefs = await SharedPreferences.getInstance();
    final cloudLocale = prefs.getString(_prefCloudLocaleKey);
    if (cloudLocale != null) {
      final match = kCloudVoices.where((v) => v.locale == cloudLocale);
      if (match.isNotEmpty) _selectedCloud = match.first;
    }
    _useGemini = prefs.getBool(_prefUseGeminiKey) ?? false;
  }

  Future<void> selectCloudVoice(CloudVoice voice) async {
    _selectedCloud = voice;
    _useGemini = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefCloudLocaleKey, voice.locale);
    await prefs.setBool(_prefUseGeminiKey, false);
  }

  /// Chuyen sang dung giong Gemini (ten giong cu the lay tu
  /// GeminiVoiceSelection.instance, dung chung voi AI Voice Chat) cho moi
  /// tinh nang doc tu/cau trong app - xem AskUserQuestion da hoi nguoi dung
  /// truoc khi lam viec nay, vi day la thay doi kien truc lon (them 1 API
  /// TTS thu 3), khong phai fix loi don gian.
  Future<void> selectGeminiVoice() async {
    _useGemini = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefUseGeminiKey, true);
  }

  /// Loi that gan nhat tu _speakGemini (vd HTTP status + body tra ve) - luon
  /// bi nuot trong speak() (roi xuong giong khac de khong lam gian doan
  /// tinh nang dang dung), luu lai o day de noi can CHAN DOAN (vd sheet
  /// chon giong o man Ho so) co the doc va hien ra that su.
  String? lastGeminiError;

  Future<void> speak(String text) async {
    if (_useGemini) {
      try {
        await _speakGemini(text, GeminiVoiceSelection.instance.value);
        lastGeminiError = null;
        return;
      } catch (e) {
        // Loi mang/API Gemini TTS -> roi xuong VoiceRSS/giong may ben duoi -
        // nhung luu lai loi that de _previewGemini/UI chan doan doc duoc.
        lastGeminiError = '$e';
      }
    }
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

  /// Nhu speak() nhung CHI dung Gemini va KHONG nuot loi - dung rieng cho
  /// nut "nghe thu" luc chon giong o man Ho so, de nguoi dung (va bao cao
  /// loi) thay dung nguyen nhan that thay vi nghe giong khac ma khong biet
  /// vi sao Gemini that bai.
  Future<void> previewGeminiVoice(String voiceName, String text) =>
      _speakGemini(text, voiceName);

  /// Goi Gemini Text-to-Speech (generateContent 1 lan, KHAC voi Gemini Live
  /// dung o AI Voice Chat - Live chi noi duoc trong luc dang tro chuyen thoi
  /// gian thuc, khong co API "doc 1 cau bat ky" don gian) - xem
  /// https://ai.google.dev/gemini-api/docs/speech-generation. Tra ve PCM tho
  /// (24kHz, 16-bit, mono) can boc WAV truoc khi phat qua just_audio, giong
  /// het cach GeminiLiveDirectClient xu ly audio tra ve tu Gemini Live.
  Future<void> _speakGemini(String text, String voiceName) async {
    final apiKey = Env.geminiApiKeyDirect;
    if (apiKey.isEmpty) {
      throw Exception('Chưa cấu hình GEMINI_API_KEY_DIRECT.');
    }

    final dir = await getTemporaryDirectory();
    final cacheDir = Directory('${dir.path}/gemini_tts_cache');
    if (!await cacheDir.exists()) await cacheDir.create(recursive: true);
    final file = File('${cacheDir.path}/${voiceName}_${text.hashCode}.wav');

    if (!await file.exists()) {
      final res = await http
          .post(
            Uri.parse(
              'https://generativelanguage.googleapis.com/v1beta/interactions',
            ),
            headers: {
              'x-goog-api-key': apiKey,
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': 'gemini-3.1-flash-tts-preview',
              'input': text,
              'response_format': {'type': 'audio'},
              'generation_config': {
                'speech_config': [
                  {'voice': voiceName},
                ],
              },
            }),
          )
          .timeout(const Duration(seconds: 15));
      if (res.statusCode != 200) {
        throw Exception('Gemini TTS lỗi HTTP ${res.statusCode}: ${res.body}');
      }
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final audioData =
          (data['output_audio'] as Map<String, dynamic>?)?['data'] as String?;
      if (audioData == null) {
        throw Exception(
          'Gemini TTS không trả về audio - JSON nhận được: ${res.body}',
        );
      }
      final pcm = base64Decode(audioData);
      await file.writeAsBytes(_pcmToWav(pcm, sampleRate: 24000));
    }

    await _cloudPlayer.stop();
    await _cloudPlayer.setFilePath(file.path);
    await _cloudPlayer.play();
  }

  /// Boc PCM tho (16-bit, mono) thanh 1 file WAV hoan chinh - Gemini TTS
  /// (giong Gemini Live) tra ve audio dang nay, khong phai file nen san
  /// (mp3/wav) nhu VoiceRSS.
  Uint8List _pcmToWav(Uint8List pcm, {required int sampleRate}) {
    final byteRate = sampleRate * 2;
    final header = ByteData(44);
    void writeAscii(int offset, String s) {
      for (var i = 0; i < s.length; i++) {
        header.setUint8(offset + i, s.codeUnitAt(i));
      }
    }

    writeAscii(0, 'RIFF');
    header.setUint32(4, 36 + pcm.length, Endian.little);
    writeAscii(8, 'WAVE');
    writeAscii(12, 'fmt ');
    header.setUint32(16, 16, Endian.little);
    header.setUint16(20, 1, Endian.little);
    header.setUint16(22, 1, Endian.little);
    header.setUint32(24, sampleRate, Endian.little);
    header.setUint32(28, byteRate, Endian.little);
    header.setUint16(32, 2, Endian.little);
    header.setUint16(34, 16, Endian.little);
    writeAscii(36, 'data');
    header.setUint32(40, pcm.length, Endian.little);
    return Uint8List.fromList([...header.buffer.asUint8List(), ...pcm]);
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
