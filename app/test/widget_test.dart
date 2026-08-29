import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:learn_english_music/main.dart';

void main() {
  testWidgets('App shows missing-config screen when Supabase env not set', (
    WidgetTester tester,
  ) async {
    // Trong test không truyền --dart-define nên Env.isConfigured = false,
    // app phải hiện màn hướng dẫn cấu hình thay vì crash. Bọc ProviderScope
    // giống main() thật - bắt buộc từ khi MaterialApp.builder luôn gắn
    // AiFabOverlay (dùng Riverpod) trên MỌI màn hình, kể cả màn lỗi cấu hình.
    await tester.pumpWidget(const ProviderScope(child: LearnEnglishMusicApp()));
    await tester.pump();

    expect(find.textContaining('Thiếu cấu hình'), findsOneWidget);
  });
}
