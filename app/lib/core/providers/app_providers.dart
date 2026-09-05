import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/data/auth_repository.dart';
import '../../features/crypto/data/crypto_currency.dart';
import '../../features/crypto/presentation/crypto_providers.dart';
import '../../features/wealth/data/asset_watchlist_repository.dart';
import '../../features/wealth/data/used_bank_repository.dart';
import '../../features/fitness/data/community_post_model.dart';
import '../../features/fitness/data/community_repository.dart';
import '../../features/fitness/data/exercise_model.dart';
import '../../features/fitness/data/exercise_repository.dart';
import '../../features/fitness/data/meal_model.dart';
import '../../features/fitness/data/nutrition_repository.dart';
import '../../features/fitness/data/program_model.dart';
import '../../features/fitness/data/program_repository.dart';
import '../../features/fitness/data/workout_repository.dart';
import '../../features/music_player/data/favorites_repository.dart';
import '../../features/profile/data/profile_repository.dart';
import '../../features/quiz/data/leaderboard_repository.dart';
import '../../features/rewards/data/rewards_repository.dart';
import '../../features/social/data/social_repository.dart';
import '../../features/stats/data/stats_repository.dart';
import '../../features/story/data/lesson_progress_repository.dart';
import '../../features/wealth/data/exchange_rate_repository.dart';
import '../../features/wealth/data/stocks_intl_repository.dart';
import '../../features/wealth/data/stocks_vn_repository.dart';
import '../../features/wealth/data/vn_bank_model.dart';
import '../../features/wealth/data/vn_bank_repository.dart';
import '../../features/wealth/data/wealth_balance_entry_model.dart';
import '../../features/wealth/data/wealth_balance_entry_repository.dart';
import '../../features/wealth/data/wealth_debt_model.dart';
import '../../features/wealth/data/wealth_debt_payment_model.dart';
import '../../features/wealth/data/wealth_debt_payment_repository.dart';
import '../../features/wealth/data/wealth_debt_person_model.dart';
import '../../features/wealth/data/wealth_debt_person_repository.dart';
import '../../features/wealth/data/wealth_debt_repository.dart';
import '../../features/wealth/data/recurring_service_model.dart';
import '../../features/wealth/data/recurring_service_repository.dart';
import '../../features/wealth/data/wealth_holding_model.dart';
import '../../features/wealth/data/wealth_holding_repository.dart';
import '../../features/wealth/data/wealth_investment_transaction_repository.dart';
import '../../features/wealth/data/wealth_transaction_model.dart';
import '../../features/wealth/data/wealth_transaction_repository.dart';
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

/// Rieng bieu do "Hoat dong tuan nay" khi man Ho so duoc mo tu Fitness -
/// tach khoi [myStatsProvider] (nguon 'english') de khong tron thoi gian
/// dung 2 khu vuc lai voi nhau.
final fitnessWeeklyActivityProvider = FutureProvider.autoDispose(
  (ref) =>
      ref.watch(statsRepositoryProvider).fetchWeeklyActivity(source: 'fitness'),
);

final lessonProgressRepositoryProvider = Provider<LessonProgressRepository>(
  (ref) => LessonProgressRepository(ref.watch(supabaseClientProvider)),
);

/// Đã hoàn thành 1 bài học (vd micro-story) chưa - key theo `lessonId`. Gọi
/// `ref.invalidate(lessonCompletedProvider(lessonId))` sau khi đánh dấu hoàn
/// thành để cập nhật badge trên UI ngay.
final lessonCompletedProvider = FutureProvider.autoDispose.family<bool, String>(
  (ref, lessonId) =>
      ref.watch(lessonProgressRepositoryProvider).isCompleted(lessonId),
);

final leaderboardRepositoryProvider = Provider<LeaderboardRepository>(
  (ref) => LeaderboardRepository(ref.watch(supabaseClientProvider)),
);

final favoritesRepositoryProvider = Provider<FavoritesRepository>(
  (ref) => FavoritesRepository(ref.watch(supabaseClientProvider)),
);

/// Quan ly danh sach ten bai hat yeu thich - dung StateNotifier (khong phai
/// FutureProvider thuan) de ho tro CAP NHAT UI NGAY LAP TUC (optimistic) khi
/// bat/tat yeu thich, thay vi phai cho invalidate() goi lai fetchFavoriteTitles()
/// tu server (co do tre, tung khien nguoi dung phai roi man hinh/quay lai moi
/// thay tick cap nhat). Goi `ref.read(favoriteSongTitlesProvider.notifier)
/// .toggle(title)` de bat/tat 1 bai - KHONG con dung ref.invalidate() nua.
class FavoriteSongsNotifier extends StateNotifier<AsyncValue<Set<String>>> {
  FavoriteSongsNotifier(this._repo) : super(const AsyncValue.loading()) {
    _load();
  }
  final FavoritesRepository _repo;

  Future<void> _load() async {
    try {
      state = AsyncValue.data(await _repo.fetchFavoriteTitles());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggle(String title) async {
    final current = state.valueOrNull ?? <String>{};
    final wasFavorite = current.contains(title);
    // Cap nhat UI truoc (khong cho ghi server) - moi noi dang watch provider
    // nay (danh sach bai hat, popup theo trinh do, man phat nhac) deu thay
    // tick doi NGAY LAP TUC.
    final optimistic = {...current};
    if (wasFavorite) {
      optimistic.remove(title);
    } else {
      optimistic.add(title);
    }
    state = AsyncValue.data(optimistic);
    try {
      if (wasFavorite) {
        await _repo.removeFavorite(title);
      } else {
        await _repo.addFavorite(title);
      }
    } catch (_) {
      // Ghi server that bai - khoi phuc lai trang thai cu de khong hien sai.
      state = AsyncValue.data(current);
    }
  }
}

final favoriteSongTitlesProvider =
    StateNotifierProvider.autoDispose<
      FavoriteSongsNotifier,
      AsyncValue<Set<String>>
    >((ref) => FavoriteSongsNotifier(ref.watch(favoritesRepositoryProvider)));

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

/// So loi moi ket ban dang cho - realtime, dung cho cham do tren nut "Ban
/// be" (Profile va man Tin nhan) - tu giam khi chap nhan/tu choi vi cham
/// invalidate() thu cong ngay sau do (xem friends_screen.dart), tu tang khi
/// co loi moi moi qua Realtime khong can invalidate.
final pendingRequestCountProvider = StreamProvider.autoDispose(
  (ref) => ref.watch(socialRepositoryProvider).watchPendingRequestCount(),
);

/// Toan bo tin nhan gui DEN MINH, cap nhat Realtime - dung CUNG 1 cau truc
/// truy van don gian voi watchUnreadCount(). _AuthGate (main.dart) tu so
/// sanh previous/next CUA RIVERPOD de tim id tin nhan MOI.
///
/// KHONG duoc autoDispose (khac unreadMessageCountProvider o tren) - da xac
/// nhan bang debug log thuc te: vi la autoDispose va _AuthGate build lai
/// (vd sau khi mo/dong 1 popup app khac), provider bi huy va tao lai, khien
/// Riverpod luon dua "previous = null" vao callback ref.listen moi lan co
/// tin nhan den - logic so sanh previous/next luon bi chan o buoc "previous
/// == null -> return" nen banner KHONG BAO GIO hien duoc, du provider van
/// nhan du lieu dung. Giu provider nay song SUOT vong doi app (giong 1
/// singleton) de "previous" duoc bao toan giua cac lan co tin nhan moi;
/// invalidate() thu cong khi doi tai khoan (xem invalidateUserScopedProviders).
final incomingMessagesProvider = StreamProvider(
  (ref) => ref.watch(socialRepositoryProvider).watchIncomingMessages(),
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
  ref.invalidate(pendingRequestCountProvider);
  ref.invalidate(incomingMessagesProvider);
  ref.invalidate(myConversationsProvider);
  ref.invalidate(favoriteSongTitlesProvider);
  ref.invalidate(favoriteExerciseIdsProvider);
  ref.invalidate(activeProgramIdProvider);
  ref.invalidate(todayMealsProvider);
  ref.invalidate(wealthTransactionsProvider);
  ref.invalidate(wealthHoldingsProvider);
  ref.invalidate(walletBalanceEntriesProvider);
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

// --- Fitness (Phase 1: Thu vien bai tap - port tu FitViet) ---

final exerciseRepositoryProvider = Provider<ExerciseRepository>(
  (ref) => ExerciseRepository(ref.watch(supabaseClientProvider)),
);

/// Toan bo 155 bai tap - noi dung TINH dong goi san trong app (giong
/// songs_data.dart cua nhac), khong doi trong luc dung app nen FutureProvider
/// thuan la du, khong can autoDispose (giu song suot doi app, repository tu
/// cache lai sau lan doc dau).
final exerciseListProvider = FutureProvider<List<Exercise>>(
  (ref) => ref.watch(exerciseRepositoryProvider).getAllExercises(),
);

/// Danh sach id bai tap yeu thich cua user hien tai - StateNotifier (khong
/// phai FutureProvider+invalidate) de ho tro cap nhat UI NGAY LAP TUC khi
/// bam yeu thich, giong het mau cua [FavoriteSongsNotifier] o tren (da tung
/// sua loi "phai roi man hinh/quay lai moi thay tick doi" tu chinh mau nay).
class FavoriteExerciseIdsNotifier extends StateNotifier<AsyncValue<Set<int>>> {
  FavoriteExerciseIdsNotifier(this._repo, this._userId)
    : super(const AsyncValue.loading()) {
    _load();
  }
  final ExerciseRepository _repo;
  final String? _userId;

  Future<void> _load() async {
    final userId = _userId;
    if (userId == null) {
      state = const AsyncValue.data({});
      return;
    }
    try {
      state = AsyncValue.data(await _repo.getFavoriteIds(userId));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggle(int exerciseId) async {
    final userId = _userId;
    if (userId == null) return;
    final current = state.valueOrNull ?? <int>{};
    final wasFavorite = current.contains(exerciseId);
    final optimistic = {...current};
    if (wasFavorite) {
      optimistic.remove(exerciseId);
    } else {
      optimistic.add(exerciseId);
    }
    state = AsyncValue.data(optimistic);
    try {
      if (wasFavorite) {
        await _repo.removeFavorite(userId, exerciseId);
      } else {
        await _repo.addFavorite(userId, exerciseId);
      }
    } catch (_) {
      state = AsyncValue.data(current);
    }
  }
}

final favoriteExerciseIdsProvider =
    StateNotifierProvider.autoDispose<
      FavoriteExerciseIdsNotifier,
      AsyncValue<Set<int>>
    >(
      (ref) => FavoriteExerciseIdsNotifier(
        ref.watch(exerciseRepositoryProvider),
        ref.watch(supabaseClientProvider).auth.currentUser?.id,
      ),
    );

// --- Fitness (Phase 2: Giao an + Tap luyen - port tu FitViet, xem
// docs/research-exercise-gifs.md ve nguon anh minh hoa da dung o Phase 1) ---

final programRepositoryProvider = Provider<ProgramRepository>(
  (ref) => ProgramRepository(),
);

/// Toan bo chuong trinh tap - noi dung TINH dong goi san (giong
/// exerciseListProvider), khong can autoDispose.
final programListProvider = FutureProvider<List<Program>>(
  (ref) => ref.watch(programRepositoryProvider).getAllPrograms(),
);

final workoutRepositoryProvider = Provider<WorkoutRepository>(
  (ref) => WorkoutRepository(ref.watch(supabaseClientProvider)),
);

/// Id chuong trinh dang theo cua user hien tai - null neu chua chon giao an
/// nao. Invalidate thu cong sau khi goi setActiveProgramId() (xem
/// program_detail_screen.dart), giong cach favoriteExerciseIdsProvider lam
/// sau khi toggle yeu thich.
final activeProgramIdProvider = FutureProvider.autoDispose<int?>((ref) {
  final userId = ref.watch(supabaseClientProvider).auth.currentUser?.id;
  if (userId == null) return Future.value(null);
  return ref.watch(workoutRepositoryProvider).getActiveProgramId(userId);
});

/// So lieu Trang chu Fitness (Phase 4) - autoDispose, tu lam moi moi lan
/// man Fitness Home duoc mo lai (khong can giu song vinh vien).
final fitnessDashboardStatsProvider =
    FutureProvider.autoDispose<FitnessDashboardStats>((ref) {
      final userId = ref.watch(supabaseClientProvider).auth.currentUser?.id;
      if (userId == null) {
        return Future.value(
          const FitnessDashboardStats(
            streakDays: 0,
            sessionsThisWeek: 0,
            totalVolumeThisWeekKg: 0,
            dailyVolumeLast7: [0, 0, 0, 0, 0, 0, 0],
          ),
        );
      }
      return ref.watch(workoutRepositoryProvider).getDashboardStats(userId);
    });

// --- Fitness (Phase 3: Dinh duong - port tu FitViet) ---

final nutritionRepositoryProvider = Provider<NutritionRepository>(
  (ref) => NutritionRepository(ref.watch(supabaseClientProvider)),
);

/// Bua an DA LOG cua user hien tai trong ngay hom nay - autoDispose (khong
/// giu song vinh vien nhu incomingMessagesProvider) vi "hom nay" tu doi khi
/// qua nua dem, dung invalidate lai moi khi man Dinh duong duoc mo lai la
/// du (khac truong hop can theo doi lien tuc xuyen suot vong doi app).
final todayMealsProvider = FutureProvider.autoDispose<List<Meal>>((ref) {
  final userId = ref.watch(supabaseClientProvider).auth.currentUser?.id;
  if (userId == null) return Future.value(const []);
  return ref
      .watch(nutritionRepositoryProvider)
      .getMealsForDate(userId, DateTime.now());
});

// --- Fitness (Phase 6: Cong dong - port tu FitViet, xem giai thich kien
// truc trong supabase/migrations/0031_fitness_community.sql) ---

final communityRepositoryProvider = Provider<CommunityRepository>(
  (ref) => CommunityRepository(ref.watch(supabaseClientProvider)),
);

final fitnessCommunityFeedProvider =
    FutureProvider.autoDispose<List<CommunityPost>>((ref) {
      final userId = ref.watch(supabaseClientProvider).auth.currentUser?.id;
      return ref.watch(communityRepositoryProvider).getFeed(userId);
    });

// --- Wealth Management (features/wealth/) - Phase 1: Chi tieu/Thu nhap +
// Dau tu (crypto giu nguyen o CryptoScreen, co phieu quoc te qua Twelve
// Data). Xem docs/research-wealth-stock-apis.md va
// .claude/skills/wealth-data-sync/SKILL.md.

/// "App" nao dang mo trong so 3 khu vuc cua ung dung.
enum AppSection { learnEnglish, fitness, wealth }

/// Nguon SU THAT DUY NHAT cho "app dang mo" - THAY THE hoan toan cach cu
/// (2 `StateProvider<bool>` rieng le, bat/tat qua initState/dispose cua
/// FitnessShell/WealthShell). Cach cu bi loi "lan dau dung, lan sau loan"
/// vi phu thuoc dung thu tu dispose(man cu)/initState(man moi) qua
/// addPostFrameCallback - neu nguoi dung bam chuyen doi nhanh hoac dieu
/// huong khong theo dung 1 duong (vd nhan nut back he thong giua chung),
/// 2 co co the lech pha nhau (ca 2 cung true, hoac ca 2 cung false).
/// Gio CHI set truc tiep, dong bo, ngay tai noi bam chon trong
/// app_switcher_sheet.dart - khong con phu thuoc lifecycle cua widget nao.
final currentAppSectionProvider = StateProvider<AppSection>(
  (ref) => AppSection.learnEnglish,
);

/// Ghi nho "dang o Fitness/Wealth luc bam Sign out" de KHOI PHUC dung app do
/// ngay sau khi dang nhap lai - thay vi luon quay ve Hoc Tieng Anh. Sign out
/// (profile_screen.dart) doc currentAppSectionProvider ngay TRUOC khi goi
/// signOut() roi luu vao day; main.dart doc lai va push dung Shell tuong
/// ung khi bat su kien AuthChangeEvent.signedIn, sau do tu xoa (set null) de
/// khong anh huong cac lan dang nhap binh thuong khac.
final pendingRestoreAppSectionProvider = StateProvider<AppSection?>(
  (ref) => null,
);

/// Anh nen "xung quanh" theo dung "app" dang mo (Hoc Tieng Anh/Fitness/
/// Wealth) - [ScreenBackground] tu doc provider nay lam mac dinh khi khong
/// truyen `backgroundImage` rieng, nen MOI man hinh dung ScreenBackground
/// trong 1 khu vuc se tu dong co dung anh nen ma khong can sua tung file.
final currentAppBackgroundProvider = Provider<String?>((ref) {
  return switch (ref.watch(currentAppSectionProvider)) {
    AppSection.fitness => 'assets/fitness/fitness_background.jpg',
    AppSection.wealth => 'assets/wealth/wealth_background.jpg',
    AppSection.learnEnglish => 'assets/home/home_background.jpg',
  };
});

final wealthTransactionRepositoryProvider =
    Provider<WealthTransactionRepository>(
      (ref) => WealthTransactionRepository(ref.watch(supabaseClientProvider)),
    );

final wealthHoldingRepositoryProvider = Provider<WealthHoldingRepository>(
  (ref) => WealthHoldingRepository(ref.watch(supabaseClientProvider)),
);

final wealthInvestmentTransactionRepositoryProvider =
    Provider<WealthInvestmentTransactionRepository>(
      (ref) => WealthInvestmentTransactionRepository(
        ref.watch(supabaseClientProvider),
      ),
    );

final stocksIntlRepositoryProvider = Provider<StocksIntlRepository>(
  (ref) => StocksIntlRepository(ref.watch(supabaseClientProvider)),
);

/// Toan bo giao dich chi tieu/thu nhap cua user hien tai. Khac
/// [favoriteExerciseIdsProvider] (khong can cap nhat lac quan tuc thi vi
/// khong co thao tac "bam 1 phat doi trang thai" nhu yeu thich) -
/// FutureProvider don gian + invalidate sau moi lan them/xoa la du.
final wealthTransactionsProvider =
    FutureProvider.autoDispose<List<WealthTransaction>>((ref) {
      final userId = ref.watch(supabaseClientProvider).auth.currentUser?.id;
      if (userId == null) return Future.value(<WealthTransaction>[]);
      return ref.watch(wealthTransactionRepositoryProvider).fetchAll(userId);
    });

/// Danh sach holding theo 1 asset_type cu the ('stock_intl'/'gold'/'silver'/
/// 'copper'/'real_estate') - family de moi loai tai san dau tu trong Vi tu
/// quan ly danh sach rieng, khong lan sang nhau.
final wealthHoldingsProvider = FutureProvider.autoDispose
    .family<List<WealthHolding>, String>((ref, assetType) {
      final userId = ref.watch(supabaseClientProvider).auth.currentUser?.id;
      if (userId == null) return Future.value(<WealthHolding>[]);
      return ref
          .watch(wealthHoldingRepositoryProvider)
          .fetchAll(userId, assetType);
    });

/// Gia hien tai cho danh sach ma da nam giu - family theo 1 CHUOI symbol noi
/// dau phay (KHONG PHAI List truc tiep - List mac dinh so sanh theo
/// identity trong Dart, nen 1 List MOI tao moi lan build (vd tu .toList())
/// khong bao gio duoc coi la "cung 1 key" voi lan truoc, khien family tao
/// provider MOI moi lan rebuild va lien tuc huy fetch dang cho de bat dau
/// lai - man Watchlist tung khong bao gio hien duoc gia vi bi rebuild lien
/// tuc theo ticker crypto truoc khi fetch kip xong. String thi Dart so sanh
/// theo NOI DUNG nen an toan lam key family du tao moi lan build.
final stocksIntlQuotesProvider = FutureProvider.autoDispose
    .family<List<StockQuote>, String>(
      (ref, symbolsKey) => ref
          .watch(stocksIntlRepositoryProvider)
          .fetchQuotes(_splitSymbolsKey(symbolsKey)),
    );

final stocksVnRepositoryProvider = Provider<StocksVnRepository>(
  (ref) => StocksVnRepository(ref.watch(supabaseClientProvider)),
);

/// Gia co phieu Viet Nam (san HOSE) - xem [StocksVnRepository]. Tach rieng
/// provider voi [stocksIntlQuotesProvider] vi khac Edge Function + currency
/// (VND thay vi USD). Cung dung String key - xem giai thich o
/// [stocksIntlQuotesProvider].
final stocksVnQuotesProvider = FutureProvider.autoDispose
    .family<List<StockQuote>, String>(
      (ref, symbolsKey) => ref
          .watch(stocksVnRepositoryProvider)
          .fetchQuotes(_splitSymbolsKey(symbolsKey)),
    );

List<String> _splitSymbolsKey(String key) =>
    key.isEmpty ? const [] : key.split(',');

/// Toan bo ma dang giao dich tren HOSE (kem ten) - dung cho picker tim
/// kiem/chon khi them co phieu Viet Nam vao Portfolio. Khong autoDispose -
/// danh sach ~400 dong, giu lai giua cac lan mo/dong man them co phieu de
/// khong phai tai lai moi lan.
final stocksVnAllProvider = FutureProvider<List<StockQuote>>(
  (ref) => ref.watch(stocksVnRepositoryProvider).fetchAll(),
);

// --- Vi (Wallet) - Phase A/B: so du Tien mat/Ngan hang theo tung ngan hang,
// tong tai san quy doi VND. Xem ke hoach build lai Wealth trong lich su
// trao doi voi nguoi dung (khong co file docs rieng cho phan nay).

final vnBankRepositoryProvider = Provider<VnBankRepository>(
  (ref) => VnBankRepository(),
);

final vnBanksProvider = FutureProvider<List<VnBank>>(
  (ref) => ref.watch(vnBankRepositoryProvider).getAll(),
);

final wealthBalanceEntryRepositoryProvider =
    Provider<WealthBalanceEntryRepository>(
      (ref) => WealthBalanceEntryRepository(ref.watch(supabaseClientProvider)),
    );

final walletBalanceEntriesProvider =
    FutureProvider.autoDispose<List<WealthBalanceEntry>>((ref) {
      final userId = ref.watch(supabaseClientProvider).auth.currentUser?.id;
      if (userId == null) return Future.value(<WealthBalanceEntry>[]);
      return ref.watch(wealthBalanceEntryRepositoryProvider).fetchAll(userId);
    });

/// Tong so du gop theo (accountType, bankCode/bankName, currency) - tinh lai
/// tu [walletBalanceEntriesProvider] moi khi danh sach thay doi.
final walletTotalsProvider = Provider.autoDispose<List<WealthAccountTotal>>((
  ref,
) {
  final entries = ref.watch(walletBalanceEntriesProvider).valueOrNull ?? [];
  return ref.watch(wealthBalanceEntryRepositoryProvider).computeTotals(entries);
});

final exchangeRateRepositoryProvider = Provider<ExchangeRateRepository>(
  (ref) => ExchangeRateRepository(ref.watch(supabaseClientProvider)),
);

/// Snapshot gia Vang VN + ty gia USD/VND + gia The gioi Bac/Dong quy doi -
/// goi qua Edge Function `wealth-vn-assets` (cache 5 phut o tang server).
final wealthVnAssetsProvider =
    FutureProvider.autoDispose<WealthVnAssetSnapshot>(
      (ref) => ref.watch(exchangeRateRepositoryProvider).fetchSnapshot(),
    );

/// Tong Tien mat + Tien ngan hang quy doi ve 1 so VND duy nhat (khoan USD
/// nhan ty gia tu [wealthVnAssetsProvider]) - dung cho the tong o Home. Tra
/// ve null neu chua tai xong ty gia va co khoan USD can quy doi.
final netWorthVndProvider = Provider.autoDispose<double?>((ref) {
  final totals = ref.watch(walletTotalsProvider);
  final rate = ref.watch(wealthVnAssetsProvider).valueOrNull?.usdVnd;
  double sumVnd = 0;
  double sumUsd = 0;
  for (final t in totals) {
    if (t.currency == 'USD') {
      sumUsd += t.total;
    } else {
      sumVnd += t.total;
    }
  }
  if (sumUsd == 0) return sumVnd;
  if (rate == null) return null;
  return sumVnd + sumUsd * rate;
});

/// Tong gia tri Tai san dau tu (Crypto+Co phieu+Kim loai quy+Nha dat) quy
/// doi VND - logic giong het `WalletInvestmentAssetsTab` (tach ra day de
/// the tong o Home co the switch sang xem tong nay ma khong phai lap lai).
final totalInvestmentValueVndProvider = Provider.autoDispose<double>((ref) {
  final cryptoHoldings = ref.watch(cryptoPortfolioProvider);
  final liveCoins = ref.watch(liveCoinsProvider(CryptoCurrency.usd));
  final coinPriceById = {for (final c in liveCoins) c.id: c.price};
  final usdVnd = ref.watch(wealthVnAssetsProvider).valueOrNull?.usdVnd;
  double cryptoValueVnd = 0;
  if (usdVnd != null) {
    for (final h in cryptoHoldings) {
      final price = coinPriceById[h.coinId];
      if (price != null) cryptoValueVnd += price * h.quantity * usdVnd;
    }
  }

  final stockHoldings =
      ref.watch(wealthHoldingsProvider('stock_intl')).valueOrNull ?? [];
  double stockValueVnd = 0;
  if (usdVnd != null) {
    for (final h in stockHoldings) {
      stockValueVnd += (h.avgCost ?? 0) * (h.quantity ?? 0) * usdVnd;
    }
  }

  final snap = ref.watch(wealthVnAssetsProvider).valueOrNull;
  final goldHoldings =
      ref.watch(wealthHoldingsProvider('gold')).valueOrNull ?? [];
  final silverHoldings =
      ref.watch(wealthHoldingsProvider('silver')).valueOrNull ?? [];
  final copperHoldings =
      ref.watch(wealthHoldingsProvider('copper')).valueOrNull ?? [];
  double metalValueVnd = 0;
  if (snap != null) {
    final goldPrice = snap.goldSjcSell ?? snap.goldPnjSell;
    if (goldPrice != null) {
      for (final h in goldHoldings) {
        metalValueVnd += goldPrice * (h.quantity ?? 0);
      }
    }
    if (snap.xagVndPerLuong != null) {
      for (final h in silverHoldings) {
        metalValueVnd += snap.xagVndPerLuong! * (h.quantity ?? 0);
      }
    }
    if (snap.xcuVndPerKg != null) {
      for (final h in copperHoldings) {
        metalValueVnd += snap.xcuVndPerKg! * (h.quantity ?? 0);
      }
    }
  }

  final realEstateHoldings =
      ref.watch(wealthHoldingsProvider('real_estate')).valueOrNull ?? [];
  final realEstateValueVnd = realEstateHoldings.fold<double>(
    0,
    (s, h) => s + (h.manualValue ?? 0),
  );

  return cryptoValueVnd + stockValueVnd + metalValueVnd + realEstateValueVnd;
});

/// So tien lai/lo (VND) + % lai/lo cua TOAN BO Tai san dau tu, gop tu 3
/// nguon co "moc so sanh" (Crypto dung % thay doi 24h lam moc, Co phieu/Kim
/// loai dung gia von avgCost lam moc - Nha dat KHONG co moc nao nen bo qua)
/// - dung cho the tong o Home khi dang xem "Tong tai san dau tu". Tra ve
/// pnlPercent null neu khong co du lieu moc nao de tinh %.
final investmentPnlProvider = Provider.autoDispose<(double, double?)>((ref) {
  final cryptoHoldings = ref.watch(cryptoPortfolioProvider);
  final liveCoins = ref.watch(liveCoinsProvider(CryptoCurrency.usd));
  final coinById = {for (final c in liveCoins) c.id: c};
  final usdVnd = ref.watch(wealthVnAssetsProvider).valueOrNull?.usdVnd;
  double cryptoPnlVnd = 0;
  double cryptoCostVnd = 0;
  if (usdVnd != null) {
    for (final h in cryptoHoldings) {
      final c = coinById[h.coinId];
      if (c == null) continue;
      final valueNow = c.price * h.quantity * usdVnd;
      final valueBefore = valueNow / (1 + c.change24hPercent / 100);
      cryptoPnlVnd += valueNow - valueBefore;
      cryptoCostVnd += valueBefore;
    }
  }

  final stockHoldings =
      ref.watch(wealthHoldingsProvider('stock_intl')).valueOrNull ?? [];
  final stockSymbols = stockHoldings
      .map((h) => h.symbol ?? '')
      .where((s) => s.isNotEmpty)
      .join(',');
  final stockQuotes =
      ref.watch(stocksIntlQuotesProvider(stockSymbols)).valueOrNull ?? [];
  final stockPriceBySymbol = {for (final q in stockQuotes) q.symbol: q.price};
  double stockPnlVnd = 0;
  double stockCostVnd = 0;
  if (usdVnd != null) {
    for (final h in stockHoldings) {
      final qty = h.quantity ?? 0;
      final avgCost = h.avgCost ?? 0;
      final price = stockPriceBySymbol[h.symbol] ?? avgCost;
      stockPnlVnd += (price - avgCost) * qty * usdVnd;
      stockCostVnd += avgCost * qty * usdVnd;
    }
  }

  final snap = ref.watch(wealthVnAssetsProvider).valueOrNull;
  final goldHoldings =
      ref.watch(wealthHoldingsProvider('gold')).valueOrNull ?? [];
  final silverHoldings =
      ref.watch(wealthHoldingsProvider('silver')).valueOrNull ?? [];
  final copperHoldings =
      ref.watch(wealthHoldingsProvider('copper')).valueOrNull ?? [];
  double metalValueVnd = 0;
  double metalCostVnd = 0;
  for (final h in [...goldHoldings, ...silverHoldings, ...copperHoldings]) {
    metalCostVnd += (h.avgCost ?? 0) * (h.quantity ?? 0);
  }
  if (snap != null) {
    final goldPrice = snap.goldSjcSell ?? snap.goldPnjSell;
    if (goldPrice != null) {
      for (final h in goldHoldings) {
        metalValueVnd += goldPrice * (h.quantity ?? 0);
      }
    }
    if (snap.xagVndPerLuong != null) {
      for (final h in silverHoldings) {
        metalValueVnd += snap.xagVndPerLuong! * (h.quantity ?? 0);
      }
    }
    if (snap.xcuVndPerKg != null) {
      for (final h in copperHoldings) {
        metalValueVnd += snap.xcuVndPerKg! * (h.quantity ?? 0);
      }
    }
  }
  final metalPnlVnd = metalValueVnd - metalCostVnd;

  final totalPnl = cryptoPnlVnd + stockPnlVnd + metalPnlVnd;
  final totalCost = cryptoCostVnd + stockCostVnd + metalCostVnd;
  final pnlPercent = totalCost == 0 ? null : totalPnl / totalCost * 100;
  return (totalPnl, pnlPercent);
});

/// Bat/tat che so tien bang mot dau `••••••` - dung chung 1 controller cho
/// ca 2 nut con mat (tong o Home la [wealthPrivacyModeProvider], tong tab
/// Tai san dau tu la [investmentPrivacyModeProvider]) vi cung 1 logic, chi
/// khac key luu SharedPreferences - giong pattern CryptoPrivacyModeController
/// da co trong crypto_providers.dart.
class _PrivacyModeController extends StateNotifier<bool> {
  _PrivacyModeController(this._prefsKey) : super(false) {
    _load();
  }
  final String _prefsKey;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_prefsKey) ?? false;
  }

  Future<void> toggle() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, state);
  }
}

final wealthPrivacyModeProvider =
    StateNotifierProvider<_PrivacyModeController, bool>(
      (ref) => _PrivacyModeController('wealth_privacy_mode_v1'),
    );

final investmentPrivacyModeProvider =
    StateNotifierProvider<_PrivacyModeController, bool>(
      (ref) => _PrivacyModeController('wealth_investment_privacy_mode_v1'),
    );

const _investmentDisplayCurrencyKey = 'wealth_investment_display_currency_v1';

/// Luu lai lua chon xem tong Tai san dau tu theo VND/USD (SharedPreferences)
/// - giu nguyen lua chon nay o cac lan mo lai man sau, khong reset ve VND
/// moi lan mo Vi.
class _InvestmentDisplayCurrencyController extends StateNotifier<String> {
  _InvestmentDisplayCurrencyController() : super('VND') {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString(_investmentDisplayCurrencyKey) ?? 'VND';
  }

  Future<void> set(String currency) async {
    state = currency;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_investmentDisplayCurrencyKey, currency);
  }
}

final investmentDisplayCurrencyProvider =
    StateNotifierProvider<_InvestmentDisplayCurrencyController, String>(
      (ref) => _InvestmentDisplayCurrencyController(),
    );

/// Danh sach "theo doi" gop chung cho Co phieu + Kim loai o man Market (xem
/// [AssetWatchlistRepository]) - moi phan tu la key "type:id". Goi `.toggle`
/// de bat/tat 1 item, `.contains` de kiem tra trang thai hien tai cua item.
class AssetWatchlistController extends StateNotifier<Set<String>> {
  AssetWatchlistController() : super({}) {
    _load();
  }

  Future<void> _load() async {
    state = await AssetWatchlistRepository.load();
  }

  bool contains(String key) => state.contains(key);

  Future<void> toggle(String key) async {
    final next = {...state};
    if (!next.remove(key)) next.add(key);
    state = next;
    await AssetWatchlistRepository.save(next);
  }
}

final assetWatchlistProvider =
    StateNotifierProvider<AssetWatchlistController, Set<String>>(
      (ref) => AssetWatchlistController(),
    );

/// Ma cac ngan hang nguoi dung chon "dang su dung" trong man Cai dat Quan ly
/// tai san - CHI cac ma nay moi hien trong bank_picker_sheet.dart khi chon
/// hinh thuc thanh toan/them so du Vi/tra no. Tap RONG = chua loc (hien tat
/// ca), xem giai thich trong [UsedBankRepository].
class UsedBankController extends StateNotifier<Set<String>> {
  UsedBankController() : super({}) {
    _load();
  }

  Future<void> _load() async {
    state = await UsedBankRepository.load();
  }

  bool contains(String code) => state.contains(code);

  Future<void> toggle(String code) async {
    final next = {...state};
    if (!next.remove(code)) next.add(code);
    state = next;
    await UsedBankRepository.save(next);
  }
}

final usedBankCodesProvider =
    StateNotifierProvider<UsedBankController, Set<String>>(
      (ref) => UsedBankController(),
    );

// --- No (Debt) - Phase E: "Dang no" (minh no nguoi khac) / "Nguoi khac no
// minh", CRUD khoan no theo tung nguoi (autocomplete ten da co), tra no/nhan
// tra no tu dong tru/cong vao Vi giong Chi tieu.

final wealthDebtPersonRepositoryProvider = Provider<WealthDebtPersonRepository>(
  (ref) => WealthDebtPersonRepository(ref.watch(supabaseClientProvider)),
);

final wealthDebtRepositoryProvider = Provider<WealthDebtRepository>(
  (ref) => WealthDebtRepository(ref.watch(supabaseClientProvider)),
);

final wealthDebtPaymentRepositoryProvider =
    Provider<WealthDebtPaymentRepository>(
      (ref) => WealthDebtPaymentRepository(ref.watch(supabaseClientProvider)),
    );

final debtPersonsProvider = FutureProvider.autoDispose<List<WealthDebtPerson>>((
  ref,
) {
  final userId = ref.watch(supabaseClientProvider).auth.currentUser?.id;
  if (userId == null) return Future.value(<WealthDebtPerson>[]);
  return ref.watch(wealthDebtPersonRepositoryProvider).fetchAll(userId);
});

/// `direction` la 'i_owe' hoac 'owed_to_me' - xem [WealthDebt].
final debtsProvider = FutureProvider.autoDispose
    .family<List<WealthDebt>, String>((ref, direction) {
      final userId = ref.watch(supabaseClientProvider).auth.currentUser?.id;
      if (userId == null) return Future.value(<WealthDebt>[]);
      return ref
          .watch(wealthDebtRepositoryProvider)
          .fetchAll(userId, direction);
    });

final debtsByPersonProvider = FutureProvider.autoDispose
    .family<List<WealthDebt>, String>((ref, personId) {
      final userId = ref.watch(supabaseClientProvider).auth.currentUser?.id;
      if (userId == null) return Future.value(<WealthDebt>[]);
      return ref
          .watch(wealthDebtRepositoryProvider)
          .fetchByPerson(userId, personId);
    });

// --- Dich vu dinh ky (Recurring Services) - Phase G: theo doi dich vu tra
// phi (Netflix, hosting...), nhac han qua push (xem check-service-expiry +
// cron hang ngay), gia han tu tru vao Vi.

final recurringServiceRepositoryProvider = Provider<RecurringServiceRepository>(
  (ref) => RecurringServiceRepository(ref.watch(supabaseClientProvider)),
);

final recurringServicesProvider =
    FutureProvider.autoDispose<List<RecurringService>>((ref) {
      final userId = ref.watch(supabaseClientProvider).auth.currentUser?.id;
      if (userId == null) return Future.value(<RecurringService>[]);
      return ref.watch(recurringServiceRepositoryProvider).fetchAll(userId);
    });

final debtPaymentsProvider = FutureProvider.autoDispose
    .family<List<WealthDebtPayment>, String>((ref, debtId) {
      final userId = ref.watch(supabaseClientProvider).auth.currentUser?.id;
      if (userId == null) return Future.value(<WealthDebtPayment>[]);
      return ref
          .watch(wealthDebtPaymentRepositoryProvider)
          .fetchAll(userId, debtId);
    });
