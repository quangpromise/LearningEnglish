import 'dart:async';

import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Nghe 1 lan (speech_to_text, en_US) va tra ve chuoi nhan dien duoc -
/// dung chung cho "Luyen noi ranh tay" va "Noi theo" trong trinh phat huong
/// dan bai tap. Tu dung khi im lang [pauseFor] hoac het [listenFor].
class SpeechListener {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool? _available;
  Completer<String>? _done;
  String _heard = '';

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

  void _finish() {
    final done = _done;
    if (done != null && !done.isCompleted) done.complete(_heard);
  }

  void _onError(SpeechRecognitionError error) => _finish();

  void _onStatus(String status) {
    if (status == stt.SpeechToText.doneStatus) _finish();
  }

  Future<String> listenOnce({
    Duration listenFor = const Duration(seconds: 8),
    Duration pauseFor = const Duration(seconds: 2),
  }) async {
    if (!await init()) return '';
    _heard = '';
    final done = Completer<String>();
    _done = done;
    try {
      await _speech.listen(
        onResult: (result) {
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
    return done.future.timeout(
      listenFor + const Duration(seconds: 2),
      onTimeout: () {
        _speech.stop();
        return _heard;
      },
    );
  }

  /// Dung nghe ngay (tra ket qua dang co cho lan listenOnce dang cho).
  void stop() {
    if (_speech.isListening) _speech.stop();
    _finish();
  }

  void dispose() {
    stop();
    _speech.cancel();
  }
}
