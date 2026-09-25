import 'dart:async';

import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Nghe 1 lan (speech_to_text, en_US) va tra ve chuoi nhan dien duoc -
/// dung chung cho "Luyen noi ranh tay" va "Noi theo" trong trinh phat huong
/// dan bai tap. Tu dung khi im lang [pauseFor] hoac het [listenFor].
///
/// Moi lan [stop]/[dispose] tang [_generation]: 1 lan nghe dang cho (ke ca
/// dang doi xin quyen mic) se tu huy va tra ve rong thay vi bat mic muon /
/// hoan tat nham lan nghe sau.
class SpeechListener {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool? _available;
  Completer<String>? _done;
  String _heard = '';
  int _generation = 0;
  bool _disposed = false;

  /// Chuoi dang nhan dien (cap nhat trong luc nghe) - de UI hien truc tiep.
  void Function(String partial)? onPartial;

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
    try {
      await _speech.listen(
        onResult: (result) {
          if (generation != _generation) return;
          _heard = result.recognizedWords;
          onPartial?.call(_heard);
          if (result.finalResult) _finish();
        },
        listenOptions: stt.SpeechListenOptions(
          localeId: 'en_US',
          listenFor: listenFor,
          pauseFor: pauseFor,
          listenMode: stt.ListenMode.dictation,
        ),
      );
    } catch (_) {
      _finish();
    }
    // Bi dung trong luc dang mo mic -> tat ngay, khong de mic bat.
    if (generation != _generation) {
      _speech.cancel();
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
    _speech.stop();
    _finish();
  }

  void dispose() {
    _disposed = true;
    _generation++;
    _speech.cancel();
    _finish('');
  }
}
