import 'package:supabase_flutter/supabase_flutter.dart';

/// Luu/xoa token FCM cua thiet bi hien tai (bang device_tokens) - Edge
/// Function send-chat-push tra cuu bang nay de biet gui push toi dau khi
/// co tin nhan chat moi. Xem supabase/migrations/0014_chat_push_notifications.sql.
class DeviceTokenRepository {
  DeviceTokenRepository._();

  static Future<void> saveToken({
    required String userId,
    required String token,
  }) async {
    await Supabase.instance.client.from('device_tokens').upsert({
      'fcm_token': token,
      'user_id': userId,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> deleteToken(String token) async {
    await Supabase.instance.client
        .from('device_tokens')
        .delete()
        .eq('fcm_token', token);
  }
}
