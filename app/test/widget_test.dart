import 'package:flutter_test/flutter_test.dart';

import 'package:learn_english_music/main.dart';

void main() {
  testWidgets('App shows missing-config screen when Supabase env not set', (
    WidgetTester tester,
  ) async {
    // Trong test không truyền --dart-define nên Env.isConfigured = false,
    // app phải hiện màn hướng dẫn cấu hình thay vì crash.
    await tester.pumpWidget(const LearnEnglishMusicApp());
    await tester.pump();

    expect(find.textContaining('Thiếu cấu hình'), findsOneWidget);
  });
}
