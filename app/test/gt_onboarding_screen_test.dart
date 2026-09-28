import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/core/providers/app_providers.dart';
import 'package:learn_english_music/core/theme/gt_tokens.dart';
import 'package:learn_english_music/features/fitness/data/program_model.dart';
import 'package:learn_english_music/features/onboarding/presentation/gt_onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _program = Program(
  id: 1,
  titleVi: 'Tăng cơ toàn thân 8 tuần',
  titleEn: 'Full-body muscle, 8 weeks',
  level: 'beginner',
  equipment: 'gym',
  sessionsPerWeek: 4,
  durationWeeks: 8,
  tags: [],
  days: [],
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  String overflowReport(WidgetTester tester) {
    final error = tester.takeException();
    if (error == null) return '';
    final flexes = tester.allRenderObjects
        .whereType<RenderFlex>()
        .where((r) => r.toStringShort().contains('OVERFLOWING'))
        .map((r) => '${r.toStringShort()} size=${r.size} <- ${r.debugCreator}');
    return '$error\n${flexes.join('\n')}';
  }

  testWidgets('3 steps: goals, minutes with live plan, suggested program', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390 * 3, 787 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          programListProvider.overrideWith((ref) async => const [_program]),
        ],
        child: MaterialApp(
          theme: ThemeData(extensions: const [GtTokens.dark]),
          home: GtOnboardingScreen(userId: 'u1', onDone: () {}),
        ),
      ),
    );
    await tester.pump();
    expect(overflowReport(tester), isEmpty);
    expect(find.text('GYMTALK'), findsOneWidget);

    await tester.tap(find.text('Bắt đầu →'));
    await tester.pump();
    expect(find.text('BƯỚC 1 / 3'), findsOneWidget);
    expect(overflowReport(tester), isEmpty);
    await tester.tap(find.text('Giao tiếp'));
    await tester.pump();
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

    await tester.tap(find.text('Tiếp tục'));
    await tester.pump();
    expect(find.text('BƯỚC 2 / 3'), findsOneWidget);
    // Mac dinh 30 phut -> 4 buoi/tuan, 12 tu/ngay.
    expect(find.text('4 buổi/tuần'), findsOneWidget);
    // Muc tieu tu/ngay that cua vong Hoc (khong doi theo so phut).
    expect(find.text('10 từ/ngày'), findsOneWidget);
    await tester.tap(find.text('Hết mình'));
    await tester.pump();
    expect(find.text('5 buổi/tuần'), findsOneWidget);
    expect(find.text('10 từ/ngày + luyện nói'), findsOneWidget);
    expect(overflowReport(tester), isEmpty);

    await tester.tap(find.text('Tạo kế hoạch'));
    // Danh sach giao an tai bat dong bo lan dau duoc xem.
    await tester.pumpAndSettle();
    expect(find.text('BƯỚC 3 / 3'), findsOneWidget);
    expect(find.text('Tăng cơ toàn thân 8 tuần'), findsOneWidget);
    expect(find.text('4 buổi/tuần · 8 tuần'), findsOneWidget);
    expect(overflowReport(tester), isEmpty);
  });
}
