import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/core/theme/gt_haptics.dart';
import 'package:learn_english_music/features/speaking/data/speech_listener.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// speech_to_text gia: moi lan listen() "dang mo mic" toi khi test mo xong.
class _FakeSpeech implements stt.SpeechToText {
  final opening = <Completer<void>>[];
  void Function(String status)? status;
  var cancels = 0;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final name = invocation.memberName;
    if (name == #initialize) return Future<bool>.value(true);
    if (name == #listen) {
      final open = Completer<void>();
      opening.add(open);
      return open.future;
    }
    if (name == #cancel) cancels++;
    if (name == #stop || name == #cancel) return Future<void>.value();
    if (name == #isListening) return false;
    if (name == const Symbol('statusListener=')) {
      status = invocation.positionalArguments.single as void Function(String)?;
    }
    return null;
  }
}

void main() {
  setUp(GtHaptics.resetForTest);

  test(
    'the mic flag is up while listening, down when it ends (#123)',
    () async {
      final speech = _FakeSpeech();
      final listener = SpeechListener(speech: speech);
      final heard = listener.listenOnce();
      await pumpEventQueue();
      expect(GtHaptics.micActive, isTrue);
      speech.opening.single.complete();
      await pumpEventQueue();
      expect(GtHaptics.micActive, isTrue);
      speech.status!(stt.SpeechToText.doneStatus);
      expect(await heard, '');
      expect(GtHaptics.micActive, isFalse);
    },
  );

  test('a listen stopped while the mic opens leaves the next one alone '
      '(#123)', () async {
    final speech = _FakeSpeech();
    final listener = SpeechListener(speech: speech);
    final first = listener.listenOnce();
    await pumpEventQueue();
    listener.stop();
    expect(GtHaptics.micActive, isFalse);
    final second = listener.listenOnce();
    await pumpEventQueue();
    expect(GtHaptics.micActive, isTrue);
    // Lan dau mo mic xong muon: khong ha co, khong huy phien cua lan sau.
    speech.opening.first.complete();
    expect(await first, '');
    expect(speech.cancels, 0);
    expect(GtHaptics.micActive, isTrue);
    speech.opening.last.complete();
    await pumpEventQueue();
    speech.status!(stt.SpeechToText.doneStatus);
    expect(await second, '');
    expect(GtHaptics.micActive, isFalse);
  });

  test('a listen stopped while the mic opens is cancelled once open', () async {
    final speech = _FakeSpeech();
    final listener = SpeechListener(speech: speech);
    final heard = listener.listenOnce();
    await pumpEventQueue();
    listener.stop();
    speech.opening.single.complete();
    expect(await heard, '');
    expect(speech.cancels, 1);
    expect(GtHaptics.micActive, isFalse);
  });

  test(
    'a stopped listen that fails to open leaves the next one alone',
    () async {
      final speech = _FakeSpeech();
      final listener = SpeechListener(speech: speech);
      final first = listener.listenOnce();
      await pumpEventQueue();
      listener.stop();
      final second = listener.listenOnce();
      var secondDone = false;
      unawaited(second.then((_) => secondDone = true));
      await pumpEventQueue();
      speech.opening.first.completeError(Exception('busy'));
      expect(await first, '');
      speech.opening.last.complete();
      await pumpEventQueue();
      // Lan sau van dang nghe, khong bi ket thuc / huy nham.
      expect(secondDone, isFalse);
      expect(speech.cancels, 0);
      expect(GtHaptics.micActive, isTrue);
      speech.status!(stt.SpeechToText.doneStatus);
      expect(await second, '');
      expect(GtHaptics.micActive, isFalse);
    },
  );

  test('dispose puts the flag down (#123)', () async {
    final speech = _FakeSpeech();
    final listener = SpeechListener(speech: speech);
    unawaited(listener.listenOnce());
    await pumpEventQueue();
    expect(GtHaptics.micActive, isTrue);
    listener.dispose();
    expect(GtHaptics.micActive, isFalse);
  });
}
