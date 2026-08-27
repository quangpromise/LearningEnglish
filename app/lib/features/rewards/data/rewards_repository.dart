import 'package:supabase_flutter/supabase_flutter.dart';

class UserRewardsInfo {
  const UserRewardsInfo({required this.points, required this.tier, required this.unlockedFeatures});
  final int points;
  final String tier;
  final List<String> unlockedFeatures;
}

/// Đọc điểm thưởng & hạng (tier) của user hiện tại từ Supabase.
///
/// LƯU Ý BẢO MẬT: đây chỉ là điều kiện để ẨN/HIỆN UI. Mọi hành động thật sự
/// nhạy cảm (vd cấp điểm) phải luôn được kiểm tra lại ở phía server (Edge
/// Function/RLS) — không bao giờ tin tưởng tuyệt đối vào check ở client.
class RewardsRepository {
  RewardsRepository(this._supabase);

  final SupabaseClient _supabase;

  Future<UserRewardsInfo> fetchMyRewards() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Chưa đăng nhập');

    final points = await _supabase.rpc('user_points_balance', params: {'target_user_id': userId}) as int;
    final tierName = await _supabase.rpc('user_tier', params: {'target_user_id': userId}) as String;

    final tierRow = await _supabase.from('tiers').select('unlocked_features').eq('name', tierName).single();
    final unlocked = (tierRow['unlocked_features'] as List).cast<String>();

    return UserRewardsInfo(points: points, tier: tierName, unlockedFeatures: unlocked);
  }

  /// Gọi Edge Function `grant-points` — chỉ admin gọi thành công (server tự kiểm tra role).
  Future<int> grantPoints({required String userId, required int amount, String? reason}) async {
    final response = await _supabase.functions.invoke(
      'grant-points',
      body: {'userId': userId, 'amount': amount, 'reason': reason},
    );
    if (response.status != 200) {
      throw Exception('Cấp điểm thất bại: ${response.data}');
    }
    return response.data['newBalance'] as int;
  }
}
