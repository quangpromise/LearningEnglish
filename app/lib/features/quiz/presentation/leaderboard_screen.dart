import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';

final _leaderboardProvider = FutureProvider(
  (ref) => ref.watch(leaderboardRepositoryProvider).fetchTop(),
);
final _myRankProvider = FutureProvider(
  (ref) => ref.watch(leaderboardRepositoryProvider).fetchMyRank(),
);

/// [myXp] chỉ dùng để force làm mới bảng xếp hạng ngay sau khi vừa cộng XP
/// từ 1 lượt đố vui (invalidate provider trong initState) — số liệu hiển thị
/// luôn lấy từ server, không phải số truyền tay.
class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key, this.myXp = 0});
  final int myXp;

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(_leaderboardProvider);
      ref.invalidate(_myRankProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final leaderboardAsync = ref.watch(_leaderboardProvider);
    final myRankAsync = ref.watch(_myRankProvider);

    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.glassFill,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: const Icon(
                      Icons.chevron_left_rounded,
                      size: 18,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Text('Bảng xếp hạng', style: AppTextStyles.heading(size: 16)),
                const SizedBox(width: 36),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'Xếp hạng theo tổng XP đố vui của tất cả người dùng',
              style: AppTextStyles.muted(size: 11),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: leaderboardAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.blue),
                ),
                error: (e, _) => Center(
                  child: Text(
                    'Không tải được bảng xếp hạng: $e',
                    style: AppTextStyles.muted(),
                    textAlign: TextAlign.center,
                  ),
                ),
                data: (entries) {
                  if (entries.isEmpty) {
                    return Center(
                      child: Text(
                        'Chưa có ai trên bảng xếp hạng.\nHoàn thành 1 lượt đố vui để lên hạng đầu tiên!',
                        style: AppTextStyles.muted(),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: entries.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final p = entries[i];
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: p.isMe
                              ? AppColors.blue.withValues(alpha: 0.16)
                              : AppColors.glassFill,
                          border: Border.all(
                            color: p.isMe
                                ? AppColors.blue.withValues(alpha: 0.5)
                                : AppColors.glassBorder,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 24,
                              child: Text(
                                '${p.rank}',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.muted(size: 13),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                gradient: AppColors.accentGradient,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  p.displayName.isNotEmpty
                                      ? p.displayName[0].toUpperCase()
                                      : '?',
                                  style: AppTextStyles.heading(size: 13),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                p.isMe
                                    ? '${p.displayName} (Bạn)'
                                    : p.displayName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.body(
                                  weight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Text(
                              '${p.xp} XP',
                              style: const TextStyle(
                                color: Color(0xFF9DB4FF),
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                gradient: AppColors.accentGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blue.withValues(alpha: 0.5),
                    blurRadius: 40,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: myRankAsync.when(
                loading: () => const SizedBox(
                  height: 20,
                  child: Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                error: (_, _) => const Text(
                  'Không tải được hạng của bạn',
                  style: TextStyle(color: Colors.white),
                ),
                data: (myRank) => Row(
                  children: [
                    Text(
                      '#${myRank.rank}',
                      style: AppTextStyles.heading(
                        size: 20,
                        weight: FontWeight.w700,
                      ).copyWith(color: Colors.white),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Hạng của bạn',
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            '${myRank.xp} XP',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
