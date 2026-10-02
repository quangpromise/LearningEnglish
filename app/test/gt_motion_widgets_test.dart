import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/core/theme/gt_haptics.dart';
import 'package:learn_english_music/core/theme/gt_motion.dart';
import 'package:learn_english_music/core/theme/gt_tokens.dart';
import 'package:learn_english_music/core/widgets/gt_celebration.dart';
import 'package:learn_english_music/core/widgets/gt_count_up.dart';

Widget _app(Widget child, {bool disableAnimations = false}) => MaterialApp(
  theme: ThemeData(extensions: const [GtTokens.dark]),
  home: Builder(
    builder: (context) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(disableAnimations: disableAnimations),
      child: Scaffold(body: Center(child: child)),
    ),
  ),
);

const _style = TextStyle(fontSize: 20);

void main() {
  group('reduced motion flag', () {
    testWidgets('reads Android "remove animations" via MediaQuery', (
      tester,
    ) async {
      late bool reduce;
      await tester.pumpWidget(
        _app(
          disableAnimations: true,
          Builder(
            builder: (context) {
              reduce = gtReduceMotion(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(reduce, isTrue);
    });

    testWidgets('reads the iOS reduce-motion flag separately', (tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(reduceMotion: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      late bool reduce;
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (context) {
              reduce = gtReduceMotion(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(reduce, isTrue);
    });

    testWidgets('motion spec: instant for spatial motion when reduced', (
      tester,
    ) async {
      late Duration spatial;
      late Duration fade;
      await tester.pumpWidget(
        _app(
          disableAnimations: true,
          Builder(
            builder: (context) {
              spatial = gtMotion(context, GtMotionKind.expressive).duration;
              fade = gtMotion(context, GtMotionKind.effects).duration;
              return const SizedBox();
            },
          ),
        ),
      );
      expect(spatial, Duration.zero);
      expect(fade.inMilliseconds, inInclusiveRange(1, 150));
    });
  });

  group('count up', () {
    testWidgets('counts from 0 and lands on the value', (tester) async {
      await tester.pumpWidget(
        _app(GtCountUp(value: 120, format: (v) => '+$v XP', style: _style)),
      );
      expect(find.text('+0 XP'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('+120 XP'), findsOneWidget);
    });

    testWidgets('reduced motion shows the final value immediately', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          disableAnimations: true,
          GtCountUp(value: 120, format: (v) => '+$v XP', style: _style),
        ),
      );
      expect(find.text('+120 XP'), findsOneWidget);
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('a new value counts from the number on screen', (tester) async {
      await tester.pumpWidget(_app(const GtCountUp(value: 10, style: _style)));
      await tester.pumpAndSettle();
      await tester.pumpWidget(_app(const GtCountUp(value: 30, style: _style)));
      await tester.pump(const Duration(milliseconds: 16));
      final shown = int.parse((tester.widget<Text>(find.byType(Text)).data)!);
      expect(shown, inInclusiveRange(10, 30));
      await tester.pumpAndSettle();
      expect(find.text('30'), findsOneWidget);
    });
  });

  group('haptics', () {
    late List<MethodCall> calls;

    setUp(() {
      GtHaptics.resetForTest();
      calls = [];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            if (call.method == 'HapticFeedback.vibrate') calls.add(call);
            return null;
          });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    test('each event maps to the agreed level', () {
      expect(gtHapticLevel(GtHapticEvent.cardGraded), GtHapticLevel.selection);
      expect(gtHapticLevel(GtHapticEvent.setTicked), GtHapticLevel.light);
      for (final e in [
        GtHapticEvent.questCompleted,
        GtHapticEvent.ringCompleted,
        GtHapticEvent.pronunciationGood,
      ]) {
        expect(gtHapticLevel(e), GtHapticLevel.medium, reason: '$e');
      }
      expect(gtHapticLevel(GtHapticEvent.chestOpened), GtHapticLevel.heavy);
      expect(gtHapticLevel(GtHapticEvent.celebration), GtHapticLevel.heavy);
    });

    test('plays the platform haptic for the level', () async {
      await GtHaptics.play(GtHapticEvent.setTicked);
      await GtHaptics.play(GtHapticEvent.chestOpened);
      expect(calls.map((c) => c.arguments), [
        'HapticFeedbackType.lightImpact',
        'HapticFeedbackType.heavyImpact',
      ]);
    });

    test('stays silent while the mic is recording', () async {
      GtHaptics.micStarted();
      await GtHaptics.play(GtHapticEvent.questCompleted);
      expect(calls, isEmpty);
      GtHaptics.micStopped();
      await GtHaptics.play(GtHapticEvent.questCompleted);
      expect(calls, hasLength(1));
    });
  });

  group('XP toast and celebration', () {
    testWidgets('toast stays readable when Android removes animations', (
      tester,
    ) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await tester.pumpWidget(_app(const SizedBox(), disableAnimations: true));
      final overlay = tester.state<OverlayState>(find.byType(Overlay).first);
      showXpToast(40, overlay: overlay);
      await tester.pump();
      // So hien ngay (giam chuyen dong) va toast KHONG bi rut con ~90ms.
      expect(find.text('+40 XP'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 1000));
      expect(find.text('+40 XP'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pump();
      expect(find.text('+40 XP'), findsNothing);
    });

    testWidgets('celebration with reduced motion: no pop, no glow loop', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          disableAnimations: true,
          GtCelebration(
            xp: 100,
            title: 'Done',
            subtitle: 'Sub',
            ctaLabel: 'OK',
            onClose: () {},
          ),
        ),
      );
      await tester.pump();
      expect(find.text('+100 XP'), findsOneWidget);
      expect(tester.hasRunningAnimations, isFalse);
    });
  });
}
