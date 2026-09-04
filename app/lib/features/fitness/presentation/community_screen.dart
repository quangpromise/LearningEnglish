import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../data/community_post_model.dart';

/// Cong dong Fitness (Phase 6) - feed cac bai chia se buoi tap, xem giai
/// thich vi sao day la 1 feed THAT (khac ban local-only cua FitViet) trong
/// migration 0031_fitness_community.sql. Port tu WorkoutSharePostCard cua
/// FitViet (Gate 40/41): the hien thoi luong/tong kg, nut like.
class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(fitnessCommunityFeedProvider);

    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).maybePop(),
                  child: const _IconCircle(icon: Icons.chevron_left_rounded),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    ref.tr('fitness_community_title'),
                    style: AppTextStyles.heading(size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: feedAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.fitnessAccent,
                  ),
                ),
                error: (_, _) => Center(
                  child: Text(
                    ref.tr('fitness_community_load_error'),
                    style: AppTextStyles.muted(),
                  ),
                ),
                data: (posts) {
                  if (posts.isEmpty) {
                    return Center(
                      child: Text(
                        ref.tr('fitness_community_empty'),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.muted(),
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: posts.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, i) => _PostCard(post: posts[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostCard extends ConsumerWidget {
  const _PostCard({required this.post});
  final CommunityPost post;

  Future<void> _toggleLike(WidgetRef ref) async {
    final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;
    if (userId == null) return;
    await ref
        .read(communityRepositoryProvider)
        .toggleLike(post.id, userId, post.likedByMe);
    ref.invalidate(fitnessCommunityFeedProvider);
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    return '${minutes}p';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlowBox(
      padding: const EdgeInsets.all(14),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.fitnessAccent,
                child: Text(
                  post.displayName.isNotEmpty
                      ? post.displayName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  post.displayName,
                  style: AppTextStyles.body(weight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (post.programTitle != null) ...[
            Text(
              post.programTitle!,
              style: AppTextStyles.body(weight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
          ],
          Text(
            ref
                .tr('fitness_community_post_summary')
                .replaceFirst(
                  '{duration}',
                  _formatDuration(post.durationSeconds),
                )
                .replaceFirst('{kg}', post.totalVolumeKg.toStringAsFixed(0)),
            style: AppTextStyles.muted(),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => _toggleLike(ref),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  post.likedByMe
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  size: 18,
                  color: post.likedByMe ? AppColors.pink : AppColors.textMuted,
                ),
                const SizedBox(width: 6),
                Text('${post.likeCount}', style: AppTextStyles.muted()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IconCircle extends StatelessWidget {
  const _IconCircle({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: const BoxDecoration(
        color: AppColors.glassFill,
        shape: BoxShape.circle,
        border: Border.fromBorderSide(BorderSide(color: AppColors.glassBorder)),
      ),
      child: Icon(icon, size: 18, color: AppColors.textPrimary),
    );
  }
}
