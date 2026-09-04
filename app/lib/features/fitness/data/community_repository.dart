import 'package:supabase_flutter/supabase_flutter.dart';

import 'community_post_model.dart';

/// Cong dong Fitness (Phase 6) - xem giai thich kien truc trong migration
/// 0031_fitness_community.sql. So voi ban goc FitViet (hoan toan local,
/// khong ai khac thay duoc), day la 1 feed THAT giua cac user cua app.
class CommunityRepository {
  CommunityRepository(this._supabase);
  final SupabaseClient _supabase;

  /// Dang 1 bai chia se tong ket buoi tap - CHU DONG boi nguoi dung (nut
  /// "Chia se" o man tong ket), khong tu dong dang moi buoi tap.
  Future<void> shareWorkout({
    required String userId,
    required String displayName,
    String? programTitle,
    required int durationSeconds,
    required double totalVolumeKg,
  }) async {
    await _supabase.from('fitness_community_posts').insert({
      'user_id': userId,
      'display_name': displayName,
      'program_title': programTitle,
      'duration_seconds': durationSeconds,
      'total_volume_kg': totalVolumeKg,
    });
  }

  /// 50 bai moi nhat + so like va trang thai "minh da like chua" cho tung
  /// bai - RLS cho phep xem het (feed cong khai), nen tinh like o client
  /// sau khi lay xong danh sach thay vi can 1 RPC rieng.
  Future<List<CommunityPost>> getFeed(String? currentUserId) async {
    final posts = await _supabase
        .from('fitness_community_posts')
        .select()
        .order('created_at', ascending: false)
        .limit(50);
    final postList = (posts as List).cast<Map<String, dynamic>>();
    if (postList.isEmpty) return [];

    final postIds = postList.map((p) => p['id'] as int).toList();
    final likes = await _supabase
        .from('fitness_community_likes')
        .select('post_id, user_id')
        .inFilter('post_id', postIds);
    final likeRows = (likes as List).cast<Map<String, dynamic>>();
    final likeCounts = <int, int>{};
    final likedByMeSet = <int>{};
    for (final l in likeRows) {
      final postId = l['post_id'] as int;
      likeCounts[postId] = (likeCounts[postId] ?? 0) + 1;
      if (l['user_id'] == currentUserId) likedByMeSet.add(postId);
    }

    return postList.map((p) {
      final id = p['id'] as int;
      return CommunityPost(
        id: id,
        userId: p['user_id'] as String,
        displayName: p['display_name'] as String,
        programTitle: p['program_title'] as String?,
        durationSeconds: p['duration_seconds'] as int,
        totalVolumeKg: (p['total_volume_kg'] as num).toDouble(),
        createdAt: DateTime.parse(p['created_at'] as String),
        likeCount: likeCounts[id] ?? 0,
        likedByMe: likedByMeSet.contains(id),
      );
    }).toList();
  }

  Future<void> toggleLike(
    int postId,
    String userId,
    bool currentlyLiked,
  ) async {
    if (currentlyLiked) {
      await _supabase
          .from('fitness_community_likes')
          .delete()
          .eq('post_id', postId)
          .eq('user_id', userId);
    } else {
      await _supabase.from('fitness_community_likes').upsert({
        'post_id': postId,
        'user_id': userId,
      }, onConflict: 'post_id,user_id');
    }
  }
}
