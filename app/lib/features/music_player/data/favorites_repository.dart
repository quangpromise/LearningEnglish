import 'package:supabase_flutter/supabase_flutter.dart';

/// Danh sách bài hát yêu thích của user hiện tại — lưu theo tên bài hát
/// (xem migration 0010_favorite_songs.sql).
class FavoritesRepository {
  FavoritesRepository(this._supabase);
  final SupabaseClient _supabase;

  Future<Set<String>> fetchFavoriteTitles() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return {};
    final rows = await _supabase
        .from('user_favorite_songs')
        .select('song_title')
        .eq('user_id', userId);
    return (rows as List)
        .map((r) => (r as Map<String, dynamic>)['song_title'] as String)
        .toSet();
  }

  Future<void> addFavorite(String songTitle) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    await _supabase.from('user_favorite_songs').upsert({
      'user_id': userId,
      'song_title': songTitle,
    }, onConflict: 'user_id,song_title');
  }

  Future<void> removeFavorite(String songTitle) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    await _supabase
        .from('user_favorite_songs')
        .delete()
        .eq('user_id', userId)
        .eq('song_title', songTitle);
  }
}
