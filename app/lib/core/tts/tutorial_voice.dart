import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:flutter/services.dart';

import 'app_tts.dart';

/// Ma bam FNV-1a 32-bit (UTF-8) cua 1 cau -> ten file audio Kokoro dong goi
/// san (`assets/tutorial_audio/<ma>.mp3`). PHAI khop fnv1a32() trong
/// scripts/generate_tutorial_audio.py.
String tutorialAudioKey(String text) {
  var hash = 0x811C9DC5;
  for (final byte in utf8.encode(text)) {
    hash ^= byte;
    hash = (hash * 0x01000193) & 0xFFFFFFFF;
  }
  return hash.toRadixString(16).padLeft(8, '0');
}

/// Giong doc tu nhien (Kokoro-82M, render san bang
/// scripts/generate_tutorial_audio.py) cho cac cau CO DINH cua app: huong
/// dan bai tap, tu vung gym, cau phan hoi. Cau nao chua co file -> tu quay
/// ve AppTts (giong may/VoiceRSS) nen khong bao gio cam.
class TutorialVoice {
  TutorialVoice();

  /// Dung chung cho cac nut loa don le (the tu, on tap...).
  static final TutorialVoice shared = TutorialVoice();

  static const _prefix = 'assets/tutorial_audio/';
  static Future<Set<String>>? _available;

  static Future<Set<String>> _loadAvailable() async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      return manifest
          .listAssets()
          .where((a) => a.startsWith(_prefix) && a.endsWith('.mp3'))
          .map((a) => a.substring(_prefix.length, a.length - 4))
          .toSet();
    } catch (_) {
      return const {};
    }
  }

  final ap.AudioPlayer _player = ap.AudioPlayer();
  Completer<void>? _pending;
  int _generation = 0;

  /// Toc do phat file Kokoro (0.75 cho nguoi moi hoc).
  double rate = 1;

  Future<bool> hasAudio(String text) async =>
      (await (_available ??= _loadAvailable())).contains(
        tutorialAudioKey(text),
      );

  /// Doc [text] va CHO doc xong (hoac bi [stop]). [onStart] duoc goi dung
  /// luc bat dau phat, kem thoi luong THAT cua file (da tinh toc do) - null
  /// khi phai dung giong may (khong biet truoc thoi luong).
  Future<void> speakAndWait(
    String text, {
    void Function(Duration? duration)? onStart,
  }) async {
    final generation = ++_generation;
    // Cau truoc (neu dang phat) ket thuc ngay - player.stop() khong ban
    // onPlayerComplete nen neu khong lan goi cu se treo mai.
    final previous = _pending;
    _pending = null;
    if (previous != null && !previous.isCompleted) previous.complete();
    final available = await (_available ??= _loadAvailable());
    if (generation != _generation) return;
    final key = tutorialAudioKey(text);
    if (!available.contains(key)) {
      onStart?.call(null);
      await AppTts.instance.speakAndWait(text);
      return;
    }
    final done = Completer<void>();
    _pending = done;
    final sub = _player.onPlayerComplete.listen((_) {
      if (!done.isCompleted) done.complete();
    });
    try {
      await AppTts.instance.ensureMusicSession();
      await _player.stop();
      await _player.setSource(ap.AssetSource('tutorial_audio/$key.mp3'));
      await _player.setPlaybackRate(rate);
      final duration = await _player.getDuration();
      if (generation != _generation) return;
      await _player.resume();
      onStart?.call(duration == null ? null : duration * (1 / rate));
      await done.future;
    } catch (_) {
      if (generation != _generation || done.isCompleted) return;
      // Loi phat file -> van doc duoc bang giong may.
      onStart?.call(null);
      await AppTts.instance.speakAndWait(text);
    } finally {
      await sub.cancel();
      if (identical(_pending, done)) _pending = null;
    }
  }

  /// Doc khong cho (nut loa).
  void speak(String text) => unawaited(speakAndWait(text));

  /// Dung ca file Kokoro lan giong may - lan speakAndWait dang cho hoan tat.
  Future<void> stop() async {
    _generation++;
    final pending = _pending;
    _pending = null;
    if (pending != null && !pending.isCompleted) pending.complete();
    try {
      await _player.stop();
    } catch (_) {}
    await AppTts.instance.stopSpeaking();
  }

  Future<void> dispose() async {
    await stop();
    await _player.dispose();
  }
}
