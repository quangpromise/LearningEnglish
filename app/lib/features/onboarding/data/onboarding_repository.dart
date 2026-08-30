import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cờ "đã xem hướng dẫn" lưu theo TỪNG userId (SharedPreferences, cùng
/// khuôn mẫu với DailyWordsRepository) - nếu nhiều tài khoản dùng chung 1
/// máy, mỗi tài khoản vẫn được xem hướng dẫn riêng đúng 1 lần.
class OnboardingRepository {
  OnboardingRepository._();

  static String _seenKey(String userId) => 'onboarding_seen_v1_$userId';

  static Future<bool> hasSeen(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_seenKey(userId)) ?? false;
  }

  static Future<void> markSeen(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_seenKey(userId), true);
  }
}

/// `ref.invalidate(onboardingSeenProvider(userId))` sau khi markSeen để
/// _AuthGate tự chuyển sang RootShell mà không cần setState thủ công.
final onboardingSeenProvider = FutureProvider.family<bool, String>((
  ref,
  userId,
) {
  return OnboardingRepository.hasSeen(userId);
});
