import 'package:supabase_flutter/supabase_flutter.dart';

import 'wealth_balance_entry_model.dart';

class WealthBalanceEntryRepository {
  WealthBalanceEntryRepository(this._supabase);
  final SupabaseClient _supabase;

  Future<List<WealthBalanceEntry>> fetchAll(String userId) async {
    final rows = await _supabase
        .from('wealth_balance_entries')
        .select()
        .eq('user_id', userId)
        .order('occurred_at', ascending: false);
    return (rows as List)
        .map((r) => WealthBalanceEntry.fromRow(r as Map<String, dynamic>))
        .toList();
  }

  Future<void> addEntry(String userId, WealthBalanceEntry entry) async {
    await _supabase
        .from('wealth_balance_entries')
        .insert(entry.toInsertRow(userId));
  }

  Future<void> deleteEntry(String userId, String id) async {
    await _supabase
        .from('wealth_balance_entries')
        .delete()
        .eq('id', id)
        .eq('user_id', userId);
  }

  /// Tong so du gop theo (accountType, bankCode/bankName, currency) - dung
  /// cho man Vi > Tai san hien co va tong o Home.
  List<WealthAccountTotal> computeTotals(List<WealthBalanceEntry> entries) {
    final totals = <String, WealthAccountTotal>{};
    for (final e in entries) {
      final key =
          '${e.accountType}|${e.bankCode ?? e.bankName ?? ''}|${e.currency}';
      final existing = totals[key];
      totals[key] = WealthAccountTotal(
        accountType: e.accountType,
        bankCode: e.bankCode,
        bankName: e.bankName,
        currency: e.currency,
        total: (existing?.total ?? 0) + e.amount,
      );
    }
    return totals.values.toList();
  }
}
