import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/features/ai_voice_chat/presentation/pt_voice_indicators.dart';

Widget _app(Widget child, {bool reduce = false}) => MaterialApp(
  home: Builder(
    builder: (context) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: reduce),
      child: Scaffold(body: Center(child: child)),
    ),
  ),
);

double _barHeight(WidgetTester tester, int i) =>
    tester.getSize(find.byKey(ValueKey('gt-voice-bar-$i'))).height;

void main() {
  group('thinking dots', () {
    testWidgets('breathe while thinking, stop when removed', (tester) async {
      await tester.pumpWidget(_app(const GtThinkingDots(color: Colors.blue)));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.hasRunningAnimations, isTrue);
      // Het nghi (hoac roi man): cham bi go -> khong con hoat anh nao.
      await tester.pumpWidget(_app(const SizedBox()));
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('reduced motion: the dots stay still', (tester) async {
      await tester.pumpWidget(
        _app(const GtThinkingDots(color: Colors.blue), reduce: true),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.hasRunningAnimations, isFalse);
    });
  });

  group('voice bars', () {
    testWidgets('follow the coach voice level', (tester) async {
      final level = ValueNotifier<double>(0);
      addTearDown(level.dispose);
      await tester.pumpWidget(
        _app(GtVoiceBars(level: level, color: Colors.teal)),
      );
      expect(_barHeight(tester, 2), 4);
      level.value = 1;
      await tester.pumpAndSettle();
      expect(_barHeight(tester, 2), 22);
      // Thanh giua cao nhat.
      expect(_barHeight(tester, 0), lessThan(_barHeight(tester, 2)));
      level.value = 0;
      await tester.pumpAndSettle();
      expect(_barHeight(tester, 2), 4);
    });

    testWidgets('reduced motion: bars stay still', (tester) async {
      final level = ValueNotifier<double>(0);
      addTearDown(level.dispose);
      await tester.pumpWidget(
        _app(GtVoiceBars(level: level, color: Colors.teal), reduce: true),
      );
      final before = _barHeight(tester, 2);
      level.value = 1;
      await tester.pump();
      expect(_barHeight(tester, 2), before);
      expect(tester.hasRunningAnimations, isFalse);
    });
  });
}
