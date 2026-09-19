import 'package:supabase_flutter/supabase_flutter.dart';

/// 1 lan do gia tri danh muc dau tu (xem migration
/// 0068_wealth_investment_snapshots.sql).
class InvestmentSnapshot {
  const InvestmentSnapshot({required this.takenAt, required this.valueVnd});

  final DateTime takenAt;
  final double valueVnd;

  factory InvestmentSnapshot.fromRow(Map<String, dynamic> row) =>
      InvestmentSnapshot(
        takenAt: DateTime.parse(row['taken_at'] as String).toLocal(),
        valueVnd: (row['value_vnd'] as num).toDouble(),
      );
}

/// Ghi/doc lich su gia tri danh muc dau tu.
///
/// Gia tri danh muc duoc tinh TUC THOI tu gia song (xem
/// totalInvestmentValueVndProvider) nen muon ve duoc bieu do theo thoi gian
/// thi phai TU GHI LAI cac moc - day la noi lam viec do.
class WealthInvestmentSnapshotRepository {
  static const _table = 'wealth_investment_snapshots';

  /// Khoang cach TOI THIEU giua 2 lan ghi. App tinh lai tong moi khi gia
  /// song nhay (vai lan/giay) - ghi het thi vua nat bang vua ton bang thong.
  ///
  /// 5 phut chu KHONG phai 1 tieng nhu truoc: voi 1 tieng/moc thi khung 1D
  /// chi co vai diem nen phan LICH SU cua bieu do la mot duong thang noi 2
  /// diem, con toan bo nhuc nhich lai don vao vai phut cuoi (chuoi live trong
  /// phien) - dung hien tuong "khong dan trai ca cay" nguoi dung thay. 5 phut
  /// cho toi da 288 diem/ngay, du day de duong song deu tren ca chieu rong.
  static const minGap = Duration(minutes: 5);

  static DateTime? _lastRecordedAt;

  /// Dang co 1 lan ghi chay do. Bieu do build lai moi giay, nen tu luc qua
  /// [minGap] den luc INSERT xong (vai tram ms) se co nhieu lan goi cung lot
  /// qua cua _lastRecordedAt va ghi trung nhieu ban ghi cung 1 moc.
  static bool _recording = false;

  /// Ghi 1 moc neu da qua [minGap] ke tu moc gan nhat. An toan khi goi nhieu
  /// lan: chan 2 lop - bien tinh trong phien nay, va kiem tra moc moi nhat
  /// tren server (de may vua mo lai app khong ghi de day ban ghi).
  ///
  /// [breakdown] = gia tri tung nhom (crypto/stock/gold/real_estate) - luu
  /// san de sau nay ve bieu do co cau ma khong phai them migration.
  static Future<void> record({
    required String userId,
    required double valueVnd,
    Map<String, double> breakdown = const {},
  }) async {
    // Tong = 0 thuong la luc gia song CHUA ve kip (holdings da co nhung
    // coinPriceById con rong) chu khong phai nguoi dung that su khong co
    // tai san nao - ghi lai se tao 1 diem 0 gia tao lam gay bieu do.
    if (valueVnd <= 0) return;
    final now = DateTime.now();
    final last = _lastRecordedAt;
    if (last != null && now.difference(last) < minGap) return;
    if (_recording) return;
    _recording = true;

    final client = Supabase.instance.client;
    try {
      final latest = await client
          .from(_table)
          .select('taken_at')
          .eq('user_id', userId)
          .order('taken_at', ascending: false)
          .limit(1)
          .maybeSingle();
      if (latest != null) {
        final lastServer = DateTime.parse(latest['taken_at'] as String)
            .toLocal();
        if (now.difference(lastServer) < minGap) {
          _lastRecordedAt = lastServer;
          return;
        }
      }
      await client.from(_table).insert({
        'user_id': userId,
        'taken_at': now.toUtc().toIso8601String(),
        'value_vnd': valueVnd,
        'breakdown': breakdown,
      });
      _lastRecordedAt = now;
    } catch (_) {
      // Mat mang/chua dang nhap: bo qua lang le - day chi la du lieu phu
      // cho bieu do, khong duoc phep lam hong luong chinh cua man hinh.
    } finally {
      _recording = false;
    }
  }

  /// Doc cac moc TU [since] toi nay, cu -> moi.
  static Future<List<InvestmentSnapshot>> fetch({
    required String userId,
    required DateTime since,
  }) async {
    final rows = await Supabase.instance.client
        .from(_table)
        .select('taken_at, value_vnd')
        .eq('user_id', userId)
        .gte('taken_at', since.toUtc().toIso8601String())
        .order('taken_at');
    return (rows as List)
        .map((r) => InvestmentSnapshot.fromRow(r as Map<String, dynamic>))
        .toList();
  }
}
