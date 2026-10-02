import 'dart:async';

import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../core/theme/gt_haptics.dart';

/// Nghe 1 lan (speech_to_text, en_US) va tra ve chuoi nhan dien duoc -
/// dung chung cho "Luyen noi ranh tay" va "Noi theo" trong trinh phat huong
/// dan bai tap. Tu dung khi im lang [pauseFor] hoac het [listenFor].
///
/// Moi lan [stop]/[dispose] tang [_generation]: 1 lan nghe dang cho (ke ca
/// dang doi xin quyen mic) se tu huy va tra ve rong thay vi bat mic muon /
/// hoan tat nham lan nghe sau.
///
/// Trong luc nghe bao phien mic cho [GtHaptics] (khong rung lot vao ban
/// ghi) - moi noi dung deu duoc phu (#123).
class SpeechListener {
  /// [speech]: ban gia cho test; mac dinh la speech_to_text that.
  SpeechListener({stt.SpeechToText? speech})
    : _speech = speech ?? stt.SpeechToText();

  final stt.SpeechToText _speech;
  bool? _available;
  Completer<String>? _done;
  String _heard = '';
  int _generation = 0;
  bool _disposed = false;

  /// Chuoi dang nhan dien (cap nhat trong luc nghe) - de UI hien truc tiep.
  void Function(String partial)? onPartial;

  /// Muc am (dB, thang do theo may) trong luc nghe - cho vong mic.
  void Function(double db)? onSoundLevel;

  bool get isListening => _speech.isListening;

  /// Xin quyen mic + khoi tao (goi 1 lan). false = may khong ho tro/tu choi.
  Future<bool> init() async {
    final cached = _available;
    if (cached != null) return cached;
    try {
      _available = await _speech.initialize(
        onError: _onError,
        onStatus: _onStatus,
      );
    } catch (_) {
      _available = false;
    }
    return _available!;
  }

  void _finish([String? value]) {
    final done = _done;
    _done = null;
    if (done != null && !done.isCompleted) done.complete(value ?? _heard);
  }

  void _onError(SpeechRecognitionError error) {
    _speech.cancel();
    _finish();
  }

  void _onStatus(String status) {
    if (status == stt.SpeechToText.doneStatus) _finish();
  }

  Future<String> listenOnce({
    Duration listenFor = const Duration(seconds: 8),
    Duration pauseFor = const Duration(seconds: 2),
  }) async {
    if (_disposed) return '';
    final generation = ++_generation;
    if (!await init() || generation != _generation) return '';
    _heard = '';
    final done = Completer<String>();
    _done = done;
    // speech_to_text la singleton: neu man khac khoi tao truoc, callback cua
    // init() o day khong duoc nhan -> gan lai moi lan nghe.
    _speech
      ..statusListener = _onStatus
      ..errorListener = _onError;
    GtHaptics.micStarted(this);
    try {
      return await _listen(generation, done, listenFor, pauseFor);
    } finally {
      // Lan nghe nay xong. Da co lan moi (stop() roi nghe tiep) thi lan moi
      // tu nha - stop()/dispose() cung nha.
      if (generation == _generation) GtHaptics.micStopped(this);
    }
  }

  Future<String> _listen(
    int generation,
    Completer<String> done,
    Duration listenFor,
    Duration pauseFor,
  ) async {
    try {
      await _speech.listen(
        onResult: (result) {
          if (generation != _generation) return;
          _heard = result.recognizedWords;
          onPartial?.call(_heard);
          if (result.finalResult) _finish();
        },
        onSoundLevelChange: (db) {
          if (generation == _generation) onSoundLevel?.call(db);
        },
        listenOptions: stt.SpeechListenOptions(
          localeId: 'en_US',
          listenFor: listenFor,
          pauseFor: pauseFor,
          listenMode: stt.ListenMode.dictation,
        ),
      );
    } catch (_) {
      // Lan nghe cu (da bi dung) mo mic loi: khong ket thuc nham lan moi.
      if (generation == _generation) _finish();
    }
    // Bi dung trong luc dang mo mic -> tat ngay, khong de mic bat. Da co lan
    // nghe moi (dung chung speech) thi de yen, khong huy phien cua no.
    if (generation != _generation) {
      if (_done == null) _speech.cancel();
      return '';
    }
    return done.future.timeout(
      listenFor + const Duration(seconds: 2),
      onTimeout: () {
        _speech.cancel();
        return _heard;
      },
    );
  }

  /// Dung nghe ngay: lan listenOnce dang cho tra ve phan da nghe duoc.
  void stop() {
    _generation++;
    GtHaptics.micStopped(this);
    _speech.stop();
    _finish();
  }

  void dispose() {
    _disposed = true;
    _generation++;
    GtHaptics.micStopped(this);
    _speech.cancel();
    _finish('');
  }
}
