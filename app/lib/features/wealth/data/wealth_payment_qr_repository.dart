import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'wealth_payment_qr_model.dart';

class WealthPaymentQrRepository {
  WealthPaymentQrRepository(this._supabase);
  final SupabaseClient _supabase;

  Future<WealthPaymentQr?> fetch(String userId) async {
    final row = await _supabase
        .from('wealth_payment_qr')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    if (row == null) return null;
    return WealthPaymentQr.fromRow(row);
  }

  /// Tai anh QR len bucket `wealth-qr` (thu muc theo user_id de khop policy -
  /// xem migration 0048_wealth_payment_qr.sql), tra ve URL cong khai kem
  /// query string chong cache khi doi anh (giong uploadAvatar).
  Future<String> uploadImage(
    String userId,
    Uint8List bytes,
    String fileExt,
  ) async {
    final path = '$userId/qr.$fileExt';
    await _supabase.storage
        .from('wealth-qr')
        .uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );
    final url = _supabase.storage.from('wealth-qr').getPublicUrl(path);
    return '$url?t=${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> save({
    required String userId,
    String? imageUrl,
    String? bankName,
    String? accountNumber,
    String? holderName,
  }) async {
    await _supabase.from('wealth_payment_qr').upsert({
      'user_id': userId,
      'image_url': imageUrl,
      'bank_name': bankName,
      'account_number': accountNumber,
      'holder_name': holderName,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}
