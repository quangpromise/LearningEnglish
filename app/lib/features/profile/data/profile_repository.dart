import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

class MyProfile {
  const MyProfile({
    required this.email,
    required this.displayName,
    required this.username,
    required this.avatarUrl,
  });

  final String email;
  final String? displayName;
  final String? username;
  final String? avatarUrl;

  String get nameLabel => displayName ?? username ?? email.split('@').first;
  String get initial => nameLabel.isNotEmpty ? nameLabel[0].toUpperCase() : '?';
}

/// Đọc/cập nhật hồ sơ (profiles) của user hiện tại — hồ sơ được tạo tự động
/// bởi trigger `handle_new_user` khi đăng ký lần đầu (xem migration 0001).
class ProfileRepository {
  ProfileRepository(this._supabase);
  final SupabaseClient _supabase;

  Future<MyProfile> fetchMyProfile() async {
    final userId = _supabase.auth.currentUser!.id;
    final row = await _supabase
        .from('profiles')
        .select('email, display_name, username, avatar_url')
        .eq('id', userId)
        .single();
    return MyProfile(
      email: row['email'] as String,
      displayName: row['display_name'] as String?,
      username: row['username'] as String?,
      avatarUrl: row['avatar_url'] as String?,
    );
  }

  /// Tải ảnh lên Supabase Storage (bucket `avatars`, thư mục theo user_id để
  /// khớp policy — xem migration 0005_avatar_storage.sql), rồi cập nhật
  /// avatar_url trong profiles. Trả về URL công khai của ảnh vừa tải.
  Future<String> uploadAvatar(Uint8List bytes, String fileExt) async {
    final userId = _supabase.auth.currentUser!.id;
    final path = '$userId/avatar.$fileExt';

    await _supabase.storage
        .from('avatars')
        .uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );

    final url = _supabase.storage.from('avatars').getPublicUrl(path);
    // Query string chống cache ảnh cũ trên CDN/trình duyệt khi đổi avatar.
    final freshUrl = '$url?t=${DateTime.now().millisecondsSinceEpoch}';

    await _supabase
        .from('profiles')
        .update({'avatar_url': freshUrl})
        .eq('id', userId);

    return freshUrl;
  }
}
