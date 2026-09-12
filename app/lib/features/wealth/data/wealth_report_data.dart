// Ham tong hop THUAN (khong goi Supabase) cho man Bao cao
// (wealth_report_screen.dart) - tach rieng de test doc lap
// (wealth_report_aggregation_test.dart) khong can mock Supabase.

import 'recurring_service_model.dart';
import 'wealth_balance_entry_model.dart';
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

/// Tong tien THUC SU di vao Cash/Ngan hang trong thang (moi dong
/// wealth_balance_entries co amount duong) - dung cho "Thu nhap" o man Bao
/// cao THAY VI wealth_transactions.type=income, vi Thu nhap tu khai bao rieng
/// (tab Thu nhap) de nguoi dung quen cap nhat/nhap thu, con so tien THAT vao
/// Vi (luong that nhan, thu no, nap tien...) moi la con so ho muon doi chieu.
double computeMonthlyWalletInflow(
  List<WealthBalanceEntry> entries,
  DateTime month, {
  double? usdVnd,
}) {
  var total = 0.0;
  for (final e in entries) {
    if (!_sameMonth(e.occurredAt, month)) continue;
    if (e.amount <= 0) continue;
    total += _toVnd(e.amount, e.currency, usdVnd);
  }
  return total;
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

/// Tong Thu/Chi CONG DON toan bo lich su (khong loc theo 1 thang cu the) -
/// dung cho che do xem "Tat ca" o man Bao cao (WealthReportScreen).
MonthlyTotals computeAllTimeTotals(
  List<WealthTransaction> transactions, {
  double? usdVnd,
}) {
  var income = 0.0;
  var expense = 0.0;
  for (final t in transactions) {
    final vnd = _toVnd(t.amount, t.currency, usdVnd);
    if (t.type == WealthTransactionType.income) {
      income += vnd;
    } else {
      expense += vnd;
    }
  }
  return MonthlyTotals(income: income, expense: expense);
}

/// Ban all-time cua computeMonthlyWalletInflow - tong tien THAT vao Vi
/// (Cash/Ngan hang) tu truoc gio, khong loc theo thang.
double computeAllTimeWalletInflow(
  List<WealthBalanceEntry> entries, {
  double? usdVnd,
}) {
  var total = 0.0;
  for (final e in entries) {
    if (e.amount <= 0) continue;
    total += _toVnd(e.amount, e.currency, usdVnd);
  }
  return total;
}

/// Ban all-time cua computeExpenseByCategory - gop chi tieu theo danh muc
/// tu TRUOC GIO, khong loc theo thang.
Map<WealthExpenseCategory, double> computeAllTimeExpenseByCategory(
  List<WealthTransaction> transactions, {
  double? usdVnd,
}) {
  final result = <WealthExpenseCategory, double>{};
  for (final t in transactions) {
    if (t.type != WealthTransactionType.expense) continue;
    final category = WealthExpenseCategory.fromCode(t.categoryCode);
    final vnd = _toVnd(t.amount, t.currency, usdVnd);
    result[category] = (result[category] ?? 0) + vnd;
  }
  return result;
}

/// Ban all-time cua computeMonthlyServiceRenewalTotal - tong tien dich vu
/// dinh ky da renew tu TRUOC GIO, khong loc theo thang.
double computeAllTimeServiceRenewalTotal(
  List<ServiceRenewalRecord> renewals, {
  double? usdVnd,
}) {
  var total = 0.0;
  for (final r in renewals) {
    total += _toVnd(r.amount, r.currency, usdVnd);
  }
  return total;
}

/// Danh sach cac thang tu ban ghi CU NHAT (trong ca 3 nguon du lieu) den
/// THANG HIEN TAI, gioi han toi da [maxMonths] thang GAN NHAT - dung cho
/// bieu do xu huong khi dang xem che do "Tat ca" (thay vi co dinh 6 thang
/// gan nhat nhu che do xem theo 1 thang cu the).
List<DateTime> allMonthsRange(
  List<WealthTransaction> transactions,
  List<WealthBalanceEntry> balanceEntries,
  List<ServiceRenewalRecord> renewals, {
  int maxMonths = 24,
}) {
  DateTime? earliest;
  void consider(DateTime d) {
    if (earliest == null || d.isBefore(earliest!)) earliest = d;
  }

  for (final t in transactions) {
    consider(t.occurredAt);
  }
  for (final e in balanceEntries) {
    consider(e.occurredAt);
  }
  for (final r in renewals) {
    consider(r.occurredAt);
  }

  final now = DateTime.now();
  final start = earliest ?? now;
  final startIndex = start.year * 12 + (start.month - 1);
  final endIndex = now.year * 12 + (now.month - 1);
  final totalMonths = (endIndex - startIndex + 1).clamp(1, maxMonths);
  return lastNMonths(DateTime(now.year, now.month, 1), totalMonths);
}
