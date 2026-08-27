import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/data/auth_repository.dart';
import '../../features/profile/data/profile_repository.dart';
import '../../features/quiz/data/leaderboard_repository.dart';
import '../../features/rewards/data/rewards_repository.dart';
import '../../features/stats/data/stats_repository.dart';

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
