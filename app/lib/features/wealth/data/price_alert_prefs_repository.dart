import 'package:supabase_flutter/supabase_flutter.dart';

/// Cong tac tong bat/tat Thong bao gia bien dong >5% (Crypto + Co phieu
/// trong watchlist) - luu tren cot profiles.price_alerts_enabled (khong
/// phai local) vi Edge Function chay nen (price-alert-check) can doc duoc
/// gia tri nay de biet co gui push cho user hay khong. Xem
/// supabase/migrations/0054_price_alerts.sql.
class PriceAlertPrefsRepository {
  PriceAlertPrefsRepository._();

  static Future<bool> fetchEnabled(String userId) async {
    final row = await Supabase.instance.client
        .from('profiles')
        .select('price_alerts_enabled')
        .eq('id', userId)
        .single();
    return row['price_alerts_enabled'] as bool? ?? true;
  }

  static Future<void> setEnabled(String userId, bool value) async {
    await Supabase.instance.client
        .from('profiles')
        .update({'price_alerts_enabled': value})
        .eq('id', userId);
  }
}
