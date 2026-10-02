import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:flutter/foundation.dart';

import 'rest_sounds.dart';

/// [SfxPlayer] bang `audioplayers` - KHONG dung just_audio: just_audio_background
/// chi cho 1 player trong ca app (xem pubspec.yaml).
class AudioplayersSfx implements SfxPlayer {
  /// Chi Android (giai doan 1). iOS: plugin dat AVAudioSession `.playback`
  /// khong tron ngay luc khoi tao - am se bo qua nut im lang va dung nhac
  /// cua app khac; can chien luoc session chung ca app (giai doan 2).
  static bool get supported => defaultTargetPlatform == TargetPlatform.android;

  final ap.AudioPlayer _player = ap.AudioPlayer();
  Future<void>? _ready;

  @override
  Future<void> load(String asset) => _ready ??= _load(asset);

  Future<void> _load(String asset) async {
    // Giu file da nap sau khi keu xong (mac dinh la giai phong).
    await _player.setReleaseMode(ap.ReleaseMode.stop);
    // Kenh "thong bao su kien": theo am luong thong bao, tu im khi may de im
    // lang / rung (rung van con). KHONG xin audio focus - tron chung voi am
    // khac: chuong ma xin focus thi giong HLV (cung app, xin focus day du) cat
    // ngang no, va Android 15+ tu choi focus khi app khong o tren cung.
    await _player.setAudioContext(
      ap.AudioContext(
        android: const ap.AudioContextAndroid(
          contentType: ap.AndroidContentType.sonification,
          usageType: ap.AndroidUsageType.notificationEvent,
          audioFocus: ap.AndroidAudioFocus.none,
        ),
      ),
    );
    await _player.setSource(ap.AssetSource(asset));
  }

  @override
  Future<void> replay() async {
    await _ready;
    await _player.stop();
    await _player.resume();
  }

  @override
  Future<void> dispose() => _player.dispose();
}
