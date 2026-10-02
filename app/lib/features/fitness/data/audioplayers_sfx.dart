import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:flutter/foundation.dart';

import 'rest_sounds.dart';

/// [SfxPlayer] bang `audioplayers` - KHONG dung just_audio: just_audio_background
/// chi cho 1 player trong ca app (xem pubspec.yaml).
class AudioplayersSfx implements SfxPlayer {
  final ap.AudioPlayer _player = ap.AudioPlayer();
  Future<void>? _ready;

  @override
  Future<void> load(String asset, {required bool duckOthers}) =>
      _ready ??= _load(asset, duckOthers: duckOthers);

  Future<void> _load(String asset, {required bool duckOthers}) async {
    // Giu file da nap sau khi keu xong (mac dinh la giai phong).
    await _player.setReleaseMode(ap.ReleaseMode.stop);
    // Android: kenh "thong bao su kien" - theo am luong thong bao, tu im khi
    // may de im lang / rung (rung van con). iOS: AVAudioSession dung chung ca
    // app (PT AI, trinh phat nhac) nen chua dat o day - giai doan 2.
    if (defaultTargetPlatform == TargetPlatform.android) {
      await _player.setAudioContext(
        ap.AudioContext(
          android: ap.AudioContextAndroid(
            contentType: ap.AndroidContentType.sonification,
            usageType: ap.AndroidUsageType.notificationEvent,
            audioFocus: duckOthers
                ? ap.AndroidAudioFocus.gainTransientMayDuck
                : ap.AndroidAudioFocus.none,
          ),
        ),
      );
    }
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
