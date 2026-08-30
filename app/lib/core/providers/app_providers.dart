import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/data/auth_repository.dart';
import '../../features/music_player/data/favorites_repository.dart';
import '../../features/profile/data/profile_repository.dart';
import '../../features/quiz/data/leaderboard_repository.dart';
import '../../features/rewards/data/rewards_repository.dart';
import '../../features/social/data/social_repository.dart';
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
/// autoDispose để không giữ dữ liệu của user cũ khi widget xem nó bị huỷ
/// (vd đăng xuất) - kết hợp với invalidate thủ công trong main.dart _AuthGate
/// khi đổi trạng thái đăng nhập (2 lớp bảo vệ chống lộ dữ liệu chéo user).
final myRewardsProvider = FutureProvider.autoDispose(
  (ref) => ref.watch(rewardsRepositoryProvider).fetchMyRewards(),
);

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(ref.watch(supabaseClientProvider)),
);

/// Hồ sơ (tên, avatar) của user hiện tại. Gọi `ref.invalidate(myProfileProvider)`
/// sau khi đổi avatar để làm mới lại UI. autoDispose - xem ghi chú ở
/// myRewardsProvider.
final myProfileProvider = FutureProvider.autoDispose(
  (ref) => ref.watch(profileRepositoryProvider).fetchMyProfile(),
);

final statsRepositoryProvider = Provider<StatsRepository>(
  (ref) => StatsRepository(ref.watch(supabaseClientProvider)),
);

/// Thống kê thật của user hiện tại (từ đã học, bài hoàn thành...). Gọi
/// `ref.invalidate(myStatsProvider)` sau khi ghi nhận hành động mới hoặc
/// reset để làm mới lại số liệu trên UI.
final myStatsProvider = FutureProvider.autoDispose(
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
final favoriteSongTitlesProvider = FutureProvider.autoDispose(
  (ref) => ref.watch(favoritesRepositoryProvider).fetchFavoriteTitles(),
);

final socialRepositoryProvider = Provider<SocialRepository>(
  (ref) => SocialRepository(ref.watch(supabaseClientProvider)),
);

/// Danh sách bạn bè (đã chấp nhận) kèm trạng thái online. Gọi
/// `ref.invalidate(myFriendsProvider)` sau khi kết bạn/hủy kết bạn.
final myFriendsProvider = FutureProvider.autoDispose(
  (ref) => ref.watch(socialRepositoryProvider).fetchFriends(),
);

/// Lời mời kết bạn đang chờ mình chấp nhận. Gọi
/// `ref.invalidate(myPendingRequestsProvider)` sau khi phản hồi lời mời.
final myPendingRequestsProvider = FutureProvider.autoDispose(
  (ref) => ref.watch(socialRepositoryProvider).fetchPendingRequests(),
);

/// Số tin nhắn chưa đọc gửi đến mình - realtime, dùng cho badge đỏ trên
/// nút tin nhắn ở Home (tương tự Facebook). Tự cập nhật khi có tin nhắn
/// mới hoặc khi mình mở 1 cuộc hội thoại (ChatScreen gọi
/// markConversationRead rồi số này tự giảm qua stream, không cần invalidate).
final unreadMessageCountProvider = StreamProvider.autoDispose(
  (ref) => ref.watch(socialRepositoryProvider).watchUnreadCount(),
);

/// Phat 1 su kien moi lan co tin nhan MOI (chua tung thay) gui den minh -
/// RootShell lang nghe cai nay de hien pop-up thong bao kieu Messenger
/// tren BAT KY man hinh nao, khong chi rieng man Tin nhan.
final newIncomingMessageProvider = StreamProvider.autoDispose(
  (ref) => ref.watch(socialRepositoryProvider).watchNewIncomingMessages(),
);

/// Toàn bộ provider gắn với user hiện tại - gọi invalidate hết mỗi khi
/// đăng nhập/đăng xuất (main.dart _AuthGate) để tránh hiện dữ liệu của
/// tài khoản trước đó khi đổi sang tài khoản khác trên cùng máy.
void invalidateUserScopedProviders(WidgetRef ref) {
  ref.invalidate(myProfileProvider);
  ref.invalidate(myStatsProvider);
  ref.invalidate(myRewardsProvider);
  ref.invalidate(myFriendsProvider);
  ref.invalidate(myPendingRequestsProvider);
  ref.invalidate(unreadMessageCountProvider);
  ref.invalidate(myConversationsProvider);
  ref.invalidate(favoriteSongTitlesProvider);
}

/// Nhip realtime tu bang messages (khong quan tam noi dung, chi de kich
/// hoat refetch) - moi khi co tin nhan moi/duoc danh dau da doc, dung de
/// lam moi myConversationsProvider ngay lap tuc thay vi phai roi man hinh
/// tin nhan roi quay lai moi thay cap nhat.
final _messagesRealtimePingProvider = StreamProvider.autoDispose<void>((ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client.auth.currentUser == null) return const Stream.empty();
  return client.from('messages').stream(primaryKey: ['id']).map((_) {});
});

/// Danh sach hoi thoai (man Tin nhan o Home) - ban be kem tin nhan gan
/// nhat + so chua doc. Gọi `ref.invalidate(myConversationsProvider)` sau
/// khi gui/nhan tin nếu cần làm mới ngay lập tức (thường tự làm mới qua
/// _messagesRealtimePingProvider ở trên).
final myConversationsProvider = FutureProvider.autoDispose((ref) {
  ref.watch(_messagesRealtimePingProvider);
  return ref.watch(socialRepositoryProvider).fetchConversations();
});

/// true khi tab Luyện phát âm (RootShell) đang là tab đang hiển thị - dùng
/// để ẩn nút nổi "AI Voice Chat" ở màn đó (tránh chồng lên nút mic).
final pronunciationTabActiveProvider = StateProvider<bool>((ref) => false);

/// true khi màn AiVoiceChatScreen đang mở - dùng để ẩn nút nổi ngay trên
/// chính màn hình đó (không cần nút mở lại tính năng đang mở sẵn).
final aiVoiceChatScreenActiveProvider = StateProvider<bool>((ref) => false);

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
