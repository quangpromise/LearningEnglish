import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/data/auth_repository.dart';
import '../../features/rewards/data/rewards_repository.dart';

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
