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
  // Nhom haptics dung test() thuong nhung can binding (kenh nen tang gia).
  TestWidgetsFlutterBinding.ensureInitialized();

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

    testWidgets('never shows a number past the target', (tester) async {
      await tester.pumpWidget(
        _app(const GtCountUp(value: 1000, style: _style)),
      );
      for (var i = 0; i < 40; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        final shown = int.parse(tester.widget<Text>(find.byType(Text)).data!);
        expect(shown, lessThanOrEqualTo(1000), reason: 'frame $i');
      }
      await tester.pumpAndSettle();
      expect(find.text('1000'), findsOneWidget);
    });

    testWidgets('screen readers get the final value, not each step', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(GtCountUp(value: 55, format: (v) => '+$v XP', style: _style)),
      );
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('+55 XP'), findsNothing);
      expect(find.bySemanticsLabel('+55 XP'), findsWidgets);
      await tester.pumpAndSettle();
      semantics.dispose();
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
      await GtHaptics.play(GtHapticEvent.cardGraded);
      await GtHaptics.play(GtHapticEvent.setTicked);
      await GtHaptics.play(GtHapticEvent.questCompleted);
      await GtHaptics.play(GtHapticEvent.chestOpened);
      expect(calls.map((c) => c.arguments), [
        'HapticFeedbackType.selectionClick',
        'HapticFeedbackType.lightImpact',
        'HapticFeedbackType.mediumImpact',
        'HapticFeedbackType.heavyImpact',
      ]);
    });

    test('one turn buzzes once, at the strongest level', () async {
      await Future.wait([
        GtHaptics.play(GtHapticEvent.questCompleted),
        GtHaptics.play(GtHapticEvent.ringCompleted),
        GtHaptics.play(GtHapticEvent.setTicked),
      ]);
      expect(calls.map((c) => c.arguments), [
        'HapticFeedbackType.mediumImpact',
      ]);
      await Future.wait([
        GtHaptics.play(GtHapticEvent.questCompleted),
        GtHaptics.play(GtHapticEvent.chestOpened),
      ]);
      expect(calls.map((c) => c.arguments), [
        'HapticFeedbackType.mediumImpact',
        'HapticFeedbackType.heavyImpact',
      ]);
    });

    test('within the refractory window only a stronger buzz plays', () async {
      var at = DateTime(2026, 10, 2, 9);
      GtHaptics.now = () => at;
      await GtHaptics.play(GtHapticEvent.questCompleted);
      at = at.add(const Duration(milliseconds: 214));
      await GtHaptics.play(GtHapticEvent.ringCompleted);
      await GtHaptics.play(GtHapticEvent.setTicked);
      await GtHaptics.play(GtHapticEvent.chestOpened);
      at = at.add(GtHaptics.refractory);
      await GtHaptics.play(GtHapticEvent.questCompleted);
      expect(calls.map((c) => c.arguments), [
        'HapticFeedbackType.mediumImpact',
        'HapticFeedbackType.heavyImpact',
        'HapticFeedbackType.mediumImpact',
      ]);
    });

    test('stays silent while any mic session is open', () async {
      final pronunciation = Object();
      final trainer = Object();
      GtHaptics.micStarted(pronunciation);
      // "Dang nghe" ban lai khi tu khoi dong lai: khong lam lech.
      GtHaptics.micStarted(pronunciation);
      GtHaptics.micStarted(trainer);
      await GtHaptics.play(GtHapticEvent.questCompleted);
      GtHaptics.micStopped(pronunciation);
      await GtHaptics.play(GtHapticEvent.questCompleted);
      expect(calls, isEmpty);
      GtHaptics.micStopped(trainer);
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

    testWidgets('celebration counts XP up, then the glow keeps going', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          GtCelebration(
            xp: 100,
            title: 'Done',
            subtitle: 'Sub',
            ctaLabel: 'OK',
            onClose: () {},
          ),
        ),
      );
      expect(find.text('+0 XP'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 700));
      expect(find.text('+100 XP'), findsOneWidget);
      // Huy hieu bat len xong -> vong toa sang lap lai.
      expect(tester.hasRunningAnimations, isTrue);
    });
  });

  group('rank-up card in a celebration (#121)', () {
    late List<String> buzzes;

    setUp(() {
      GtHaptics.resetForTest();
      buzzes = [];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            if (call.method == 'HapticFeedback.vibrate') {
              buzzes.add('${call.arguments}');
            }
            return null;
          });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    GtCelebration celebration() => GtCelebration(
      xp: 40,
      title: 'Lên B1!',
      subtitle: '18/20',
      ctaLabel: 'OK',
      onClose: () {},
      rankUp: const GtRankUp(
        fromTier: 2,
        toTier: 3,
        title: 'Lên GymTalk Rank!',
        detail: 'Bậc 3: Athlete · B1',
      ),
    );

    double opacityOf(WidgetTester tester, String text) => tester
        .widget<Opacity>(
          find
              .ancestor(of: find.text(text), matching: find.byType(Opacity))
              .first,
        )
        .opacity;

    testWidgets('one Celebration: the card slides in, the tier flips once', (
      tester,
    ) async {
      await tester.pumpWidget(_app(celebration()));
      expect(find.text('Lên GymTalk Rank!'), findsOneWidget);
      expect(find.text('Bậc 3: Athlete · B1'), findsOneWidget);
      // The da vao, bac van la bac cu.
      await tester.pump(const Duration(milliseconds: 900));
      expect(opacityOf(tester, '2'), 1);
      expect(opacityOf(tester, '3'), 0);
      expect(buzzes, isEmpty);
      // Doi bac: 1 nhip rung nhe, bac moi hien han.
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 700));
      expect(opacityOf(tester, '3'), 1);
      expect(opacityOf(tester, '2'), 0);
      expect(buzzes, ['HapticFeedbackType.lightImpact']);
      await tester.pump(const Duration(seconds: 1));
      expect(buzzes, hasLength(1));
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('reduced motion: the new tier at once, no extra tick', (
      tester,
    ) async {
      await tester.pumpWidget(_app(celebration(), disableAnimations: true));
      await tester.pump();
      expect(find.text('3'), findsOneWidget);
      expect(find.text('2'), findsNothing);
      await tester.pump(const Duration(seconds: 2));
      expect(buzzes, isEmpty);
      expect(tester.hasRunningAnimations, isFalse);
    });
  });
}
