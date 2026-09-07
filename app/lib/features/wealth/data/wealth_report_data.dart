// Ham tong hop THUAN (khong goi Supabase) cho man Bao cao
// (wealth_report_screen.dart) - tach rieng de test doc lap
// (wealth_report_aggregation_test.dart) khong can mock Supabase.

import 'recurring_service_model.dart';
import 'wealth_category.dart';
import 'wealth_transaction_model.dart';

bool _sameMonth(DateTime a, DateTime month) =>
    a.year == month.year && a.month == month.month;

/// Quy doi 1 khoan tien ve VND - USD can [usdVnd] (ty gia tu
/// wealthVnAssetsProvider); neu chua co ty gia (null) thi BO QUA khoan do
/// (coi nhu 0) thay vi cong nham so USD tho vao tong VND.
double _toVnd(double amount, String currency, double? usdVnd) {
  if (currency != 'USD') return amount;
  return usdVnd == null ? 0 : amount * usdVnd;
}

class MonthlyTotals {
  const MonthlyTotals({required this.income, required this.expense});
  final double income;
  final double expense;
}

MonthlyTotals computeMonthlyTotals(
  List<WealthTransaction> transactions,
  DateTime month, {
  double? usdVnd,
}) {
  var income = 0.0;
  var expense = 0.0;
  for (final t in transactions) {
    if (!_sameMonth(t.occurredAt, month)) continue;
    final vnd = _toVnd(t.amount, t.currency, usdVnd);
    if (t.type == WealthTransactionType.income) {
      income += vnd;
    } else {
      expense += vnd;
    }
  }
  return MonthlyTotals(income: income, expense: expense);
}

Map<WealthExpenseCategory, double> computeExpenseByCategory(
  List<WealthTransaction> transactions,
  DateTime month, {
  double? usdVnd,
}) {
  final result = <WealthExpenseCategory, double>{};
  for (final t in transactions) {
    if (t.type != WealthTransactionType.expense) continue;
    if (!_sameMonth(t.occurredAt, month)) continue;
    final category = WealthExpenseCategory.fromCode(t.categoryCode);
    final vnd = _toVnd(t.amount, t.currency, usdVnd);
    result[category] = (result[category] ?? 0) + vnd;
  }
  return result;
}

double computeMonthlyServiceRenewalTotal(
  List<ServiceRenewalRecord> renewals,
  DateTime month, {
  double? usdVnd,
}) {
  var total = 0.0;
  for (final r in renewals) {
    if (!_sameMonth(r.occurredAt, month)) continue;
    total += _toVnd(r.amount, r.currency, usdVnd);
  }
  return total;
}

/// Sinh day N thang KET THUC tai [end] (bao gom ca [end]), tang dan theo
/// thoi gian - vd end=2/2026, n=6 -> [9/2025, 10/2025, 11/2025, 12/2025,
/// 1/2026, 2/2026]. Dung ngay 1 cua thang de tranh loi "thang khong co ngay
/// 31" khi lui thang.
List<DateTime> lastNMonths(DateTime end, int n) {
  final endMonthIndex = end.year * 12 + (end.month - 1);
  return List.generate(n, (i) {
    final total = endMonthIndex - (n - 1 - i);
    final year = total ~/ 12;
    final month = total % 12 + 1;
    return DateTime(year, month, 1);
  });
}
