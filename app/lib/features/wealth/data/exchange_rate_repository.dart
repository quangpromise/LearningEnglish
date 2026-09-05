import 'package:supabase_flutter/supabase_flutter.dart';

/// Ket qua tu Edge Function `wealth-vn-assets` - xem
/// supabase/functions/wealth-vn-assets/index.ts. Gia Vang SJC/PNJ la tham
/// khao tong hop tu ben thu ba, ty gia tham khao Vietcombank/thi truong.
/// KHONG con Bac/Dong (da bo hoan toan - khong tim duoc nguon gia mien phi
/// hop le ve dieu khoan thuong mai cho ca 2 kim loai nay, xem
/// docs/research-wealth-stock-apis.md) - gia vang quoc te thay the dung
/// XAUT tu OKX (xem okxXautTickerProvider), khong qua function nay.
class WealthVnAssetSnapshot {
  const WealthVnAssetSnapshot({
    this.goldSjcBuy,
    this.goldSjcSell,
    this.goldPnjBuy,
    this.goldPnjSell,
    this.usdVnd,
  });

  final double? goldSjcBuy;
  final double? goldSjcSell;
  final double? goldPnjBuy;
  final double? goldPnjSell;
  final double? usdVnd;

  factory WealthVnAssetSnapshot.fromJson(Map<String, dynamic> json) {
    double? asDouble(dynamic v) => v == null ? null : (v as num).toDouble();
    final sjc = json['goldSjc'] as Map<String, dynamic>?;
    final pnj = json['goldPnj'] as Map<String, dynamic>?;
    return WealthVnAssetSnapshot(
      goldSjcBuy: asDouble(sjc?['buy']),
      goldSjcSell: asDouble(sjc?['sell']),
      goldPnjBuy: asDouble(pnj?['buy']),
      goldPnjSell: asDouble(pnj?['sell']),
      usdVnd: asDouble(json['usdVnd']),
    );
  }
}

class ExchangeRateRepository {
  ExchangeRateRepository(this._supabase);
  final SupabaseClient _supabase;

  Future<WealthVnAssetSnapshot> fetchSnapshot() async {
    final res = await _supabase.functions.invoke('wealth-vn-assets');
    return WealthVnAssetSnapshot.fromJson(res.data as Map<String, dynamic>);
  }
}
