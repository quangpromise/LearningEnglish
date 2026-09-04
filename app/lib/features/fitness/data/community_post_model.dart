/// 1 bai chia se buoi tap trong Cong dong Fitness - port tinh than
/// WORKOUT_SHARE cua FitViet (Gate 40/41), nhung la 1 feed THAT nhieu user
/// cung thay (xem migration 0031_fitness_community.sql).
class CommunityPost {
  const CommunityPost({
    required this.id,
    required this.userId,
    required this.displayName,
    required this.programTitle,
    required this.durationSeconds,
    required this.totalVolumeKg,
    required this.createdAt,
    required this.likeCount,
    required this.likedByMe,
  });

  final int id;
  final String userId;
  final String displayName;
  final String? programTitle;
  final int durationSeconds;
  final double totalVolumeKg;
  final DateTime createdAt;
  final int likeCount;
  final bool likedByMe;
}
