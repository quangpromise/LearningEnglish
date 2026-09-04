import 'package:supabase_flutter/supabase_flutter.dart';

/// Ket qua tu Edge Function `wealth-vn-assets` - xem
/// supabase/functions/wealth-vn-assets/index.ts. Gia Vang SJC/PNJ la tham
/// khao tong hop tu ben thu ba, ty gia tham khao Vietcombank/thi truong, gia
/// Bac/Dong la GIA THE GIOI quy doi (khong phai gia ban le VN that).
class WealthVnAssetSnapshot {
  const WealthVnAssetSnapshot({
    this.goldSjcBuy,
    this.goldSjcSell,
    this.goldPnjBuy,
    this.goldPnjSell,
    this.usdVnd,
    this.xagVndPerLuong,
    this.xcuVndPerKg,
  });

  final double? goldSjcBuy;
  final double? goldSjcSell;
  final double? goldPnjBuy;
  final double? goldPnjSell;
  final double? usdVnd;
  final double? xagVndPerLuong;
  final double? xcuVndPerKg;

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
      xagVndPerLuong: asDouble(json['xagVndPerLuong']),
      xcuVndPerKg: asDouble(json['xcuVndPerKg']),
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
