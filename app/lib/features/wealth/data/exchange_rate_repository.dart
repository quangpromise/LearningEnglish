import 'package:supabase_flutter/supabase_flutter.dart';

/// 1 dong ty gia ngoai te theo cach niem yet cua Vietcombank - 3 muc gia
/// (mua tien mat/mua chuyen khoan/ban ra), dung cho tinh nang Ngoai te o Vi >
/// Tai san dau tu. [buyCash] co the null (mot so ngoai te hiem VCB khong
/// nhan doi tien mat, chi giao dich chuyen khoan).
class ForeignCurrencyRate {
  const ForeignCurrencyRate({
    required this.code,
    required this.name,
    this.buyCash,
    this.buyTransfer,
    this.sell,
  });

  final String code;
  final String name;
  final double? buyCash;
  final double? buyTransfer;
  final double? sell;

  factory ForeignCurrencyRate.fromJson(Map<String, dynamic> json) {
    double? asDouble(dynamic v) => v == null ? null : (v as num).toDouble();
    return ForeignCurrencyRate(
      code: json['code'] as String,
      name: json['name'] as String? ?? '',
      buyCash: asDouble(json['buyCash']),
      buyTransfer: asDouble(json['buyTransfer']),
      sell: asDouble(json['sell']),
    );
  }
}

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
    this.rates = const [],
  });

  final double? goldSjcBuy;
  final double? goldSjcSell;
  final double? goldPnjBuy;
  final double? goldPnjSell;
  final double? usdVnd;
  // Ty gia TAT CA ngoai te tu Vietcombank (rong neu VCB tam thoi khong len
  // duoc - xem wealth-vn-assets/index.ts) - dung cho man Ngoai te.
  final List<ForeignCurrencyRate> rates;

  ForeignCurrencyRate? rateFor(String code) {
    for (final r in rates) {
      if (r.code == code) return r;
    }
    return null;
  }

  factory WealthVnAssetSnapshot.fromJson(Map<String, dynamic> json) {
    double? asDouble(dynamic v) => v == null ? null : (v as num).toDouble();
    final sjc = json['goldSjc'] as Map<String, dynamic>?;
    final pnj = json['goldPnj'] as Map<String, dynamic>?;
    final ratesJson = json['rates'] as List? ?? const [];
    return WealthVnAssetSnapshot(
      goldSjcBuy: asDouble(sjc?['buy']),
      goldSjcSell: asDouble(sjc?['sell']),
      goldPnjBuy: asDouble(pnj?['buy']),
      goldPnjSell: asDouble(pnj?['sell']),
      usdVnd: asDouble(json['usdVnd']),
      rates: [
        for (final r in ratesJson)
          ForeignCurrencyRate.fromJson(r as Map<String, dynamic>),
      ],
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
