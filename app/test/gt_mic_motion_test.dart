import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/core/theme/gt_haptics.dart';
import 'package:learn_english_music/core/widgets/gt_mic_ring.dart';
import 'package:learn_english_music/features/pronunciation/data/pronunciation_scoring.dart';
import 'package:learn_english_music/features/pronunciation/presentation/pronunciation_result_card.dart';

Widget _app(Widget child, {bool reduce = false}) => MaterialApp(
  home: Builder(
    builder: (context) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: reduce),
      child: Scaffold(
        body: Padding(padding: const EdgeInsets.all(24), child: child),
      ),
    ),
  ),
);

const _words = ['I', 'lift', 'heavy', 'weights', 'today'];

PronunciationScore _score(int score) => PronunciationScore(
  score: score,
  targetWords: _words,
  wordResults: const [true, true, false, true, true],
);

double _shown(WidgetTester tester, String word) => tester
    .widget<Opacity>(
      find.ancestor(of: find.text(word), matching: find.byType(Opacity)).first,
    )
    .opacity;

Iterable<GtMicRingPainter> _rings(WidgetTester tester) => tester
    .widgetList<CustomPaint>(find.byType(CustomPaint))
    .map((p) => p.painter)
    .whereType<GtMicRingPainter>();

void main() {
  late List<Object?> haptics;

  setUp(() {
    GtHaptics.resetForTest();
    haptics = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'HapticFeedback.vibrate') {
            haptics.add(call.arguments);
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  group('pronunciation result', () {
    testWidgets('words appear one by one, score counts up, 80+ buzzes once', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(PronunciationResultCard(result: _score(87))),
      );
      expect(_shown(tester, 'I'), 0);
      expect(find.text('0%'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 100));
      // Tu dau dang hien, tu cuoi chua toi luot.
      expect(_shown(tester, 'I'), greaterThan(0));
      expect(_shown(tester, 'today'), 0);
      await tester.pumpAndSettle();
      for (final w in _words) {
        expect(_shown(tester, w), 1, reason: w);
      }
      expect(find.text('87%'), findsOneWidget);
      expect(haptics, ['HapticFeedbackType.mediumImpact']);
    });

    testWidgets('a low score does not buzz', (tester) async {
      await tester.pumpWidget(
        _app(PronunciationResultCard(result: _score(60))),
      );
      await tester.pumpAndSettle();
      expect(find.text('60%'), findsOneWidget);
      expect(haptics, isEmpty);
    });

    testWidgets('no buzz while the mic is recording', (tester) async {
      final mic = Object();
      GtHaptics.micStarted(mic);
      addTearDown(() => GtHaptics.micStopped(mic));
      await tester.pumpWidget(
        _app(PronunciationResultCard(result: _score(95))),
      );
      await tester.pumpAndSettle();
      expect(haptics, isEmpty);
    });

    testWidgets('reduced motion: score and words are final at once', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(PronunciationResultCard(result: _score(87)), reduce: true),
      );
      for (final w in _words) {
        expect(_shown(tester, w), 1, reason: w);
      }
      expect(find.text('87%'), findsOneWidget);
      expect(tester.hasRunningAnimations, isFalse);
    });
  });

  group('mic ring', () {
    Widget ring(
      bool active,
      ValueNotifier<double> level, {
      bool reduce = false,
    }) => _app(
      Center(
        child: GtMicRing(
          active: active,
          level: level,
          color: Colors.pink,
          child: const SizedBox(width: 76, height: 76),
        ),
      ),
      reduce: reduce,
    );

    testWidgets('follows the voice level while recording', (tester) async {
      final level = ValueNotifier<double>(0);
      addTearDown(level.dispose);
      await tester.pumpWidget(ring(true, level));
      expect(_rings(tester).single.level, 0);
      level.value = 0.8;
      await tester.pumpAndSettle();
      expect(_rings(tester).single.level, closeTo(0.8, 1e-3));
    });

    testWidgets('stops when not recording', (tester) async {
      final level = ValueNotifier<double>(0.6);
      addTearDown(level.dispose);
      await tester.pumpWidget(ring(false, level));
      expect(_rings(tester), isEmpty);
      level.value = 1;
      await tester.pump();
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('reduced motion: only a colour ring, no pulsing', (
      tester,
    ) async {
      final level = ValueNotifier<double>(0.6);
      addTearDown(level.dispose);
      await tester.pumpWidget(ring(true, level, reduce: true));
      expect(_rings(tester), isEmpty);
      final border = tester.widget<DecoratedBox>(
        find.descendant(
          of: find.byType(GtMicRing),
          matching: find.byType(DecoratedBox),
        ),
      );
      expect((border.decoration as BoxDecoration).border, isNotNull);
      level.value = 1;
      await tester.pump();
      expect(tester.hasRunningAnimations, isFalse);
    });
  });
}
