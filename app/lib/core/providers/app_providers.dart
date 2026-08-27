import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/data/auth_repository.dart';
import '../../features/music_player/data/favorites_repository.dart';
import '../../features/profile/data/profile_repository.dart';
import '../../features/quiz/data/leaderboard_repository.dart';
import '../../features/rewards/data/rewards_repository.dart';
import '../../features/stats/data/stats_repository.dart';
import '../i18n/app_language.dart';

final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(supabaseClientProvider)),
);

final rewardsRepositoryProvider = Provider<RewardsRepository>(
  (ref) => RewardsRepository(ref.watch(supabaseClientProvider)),
);

/// Phát ra sự kiện mỗi khi trạng thái đăng nhập thay đổi (đăng nhập/đăng xuất).
final authStateProvider = StreamProvider<AuthState>(
  (ref) => ref.watch(authRepositoryProvider).authStateChanges,
);

/// true sau khi người dùng đã đặt xong mật khẩu mới từ link "quên mật khẩu"
/// - dùng để _AuthGate (main.dart) ngừng hiện ResetPasswordScreen dù event
/// AuthChangeEvent.passwordRecovery vẫn là giá trị cuối cùng của stream.
final passwordRecoveryHandledProvider = StateProvider<bool>((ref) => false);

/// Điểm thưởng & tier của user hiện tại. Gọi `ref.invalidate(myRewardsProvider)`
/// sau khi admin cấp điểm để làm mới lại số dư trên UI.
final myRewardsProvider = FutureProvider(
  (ref) => ref.watch(rewardsRepositoryProvider).fetchMyRewards(),
);

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(ref.watch(supabaseClientProvider)),
);

/// Hồ sơ (tên, avatar) của user hiện tại. Gọi `ref.invalidate(myProfileProvider)`
/// sau khi đổi avatar để làm mới lại UI.
final myProfileProvider = FutureProvider(
  (ref) => ref.watch(profileRepositoryProvider).fetchMyProfile(),
);

final statsRepositoryProvider = Provider<StatsRepository>(
  (ref) => StatsRepository(ref.watch(supabaseClientProvider)),
);

/// Thống kê thật của user hiện tại (từ đã học, bài hoàn thành...). Gọi
/// `ref.invalidate(myStatsProvider)` sau khi ghi nhận hành động mới hoặc
/// reset để làm mới lại số liệu trên UI.
final myStatsProvider = FutureProvider(
  (ref) => ref.watch(statsRepositoryProvider).fetchMyStats(),
);

final leaderboardRepositoryProvider = Provider<LeaderboardRepository>(
  (ref) => LeaderboardRepository(ref.watch(supabaseClientProvider)),
);

final favoritesRepositoryProvider = Provider<FavoritesRepository>(
  (ref) => FavoritesRepository(ref.watch(supabaseClientProvider)),
);

/// Tên các bài hát user đã đánh dấu yêu thích. Gọi
/// `ref.invalidate(favoriteSongTitlesProvider)` sau khi bật/tắt yêu thích.
final favoriteSongTitlesProvider = FutureProvider(
  (ref) => ref.watch(favoritesRepositoryProvider).fetchFavoriteTitles(),
);

const _appLanguagePrefKey = 'app_language';

/// Ngôn ngữ giao diện hiện tại - lưu lại trên máy (SharedPreferences), khôi
/// phục khi mở app lại. Đổi bằng `ref.read(appLanguageProvider.notifier)
/// .setLanguage(...)` (vd từ màn Hồ sơ).
class AppLanguageNotifier extends StateNotifier<AppLanguage> {
  AppLanguageNotifier() : super(AppLanguage.vi) {
    _restore();
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_appLanguagePrefKey);
    if (saved == AppLanguage.en.name) state = AppLanguage.en;
  }

  Future<void> setLanguage(AppLanguage lang) async {
    state = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_appLanguagePrefKey, lang.name);
  }
}

final appLanguageProvider =
    StateNotifierProvider<AppLanguageNotifier, AppLanguage>(
      (ref) => AppLanguageNotifier(),
    );

/// Version + build number thật đọc từ APK đã cài (hiện ở màn Hồ sơ) - đáng
/// tin cậy hơn tự đồng bộ tay theo pubspec.yaml.
final appVersionProvider = FutureProvider((ref) async {
  final info = await PackageInfo.fromPlatform();
  // Build --split-per-abi: Flutter tu cong them "1000 * ma ABI" vao build
  // number that trong pubspec.yaml (vd arm64-v8a co ma ABI = 2, build that
  // = 2 => versionCode thuc te tren may = 2002) de moi kien truc co
  // versionCode rieng cho Play Store - xem android/app/build.gradle.kts.
  // Neu hien thang so nay ra man hinh se gay hieu lam (giong nam thang/loi).
  // Lay phan du chia 1000 de ra lai dung build number that.
  final raw = int.tryParse(info.buildNumber);
  final build = raw != null ? (raw % 1000).toString() : info.buildNumber;
  return 'v${info.version} ($build)';
});
