import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/features/wealth/data/recurring_service_model.dart';
import 'package:learn_english_music/features/wealth/data/wealth_balance_entry_model.dart';
import 'package:learn_english_music/features/wealth/data/wealth_category.dart';
import 'package:learn_english_music/features/wealth/data/wealth_report_data.dart';
import 'package:learn_english_music/features/wealth/data/wealth_transaction_model.dart';

WealthTransaction _tx({
  required WealthTransactionType type,
  required double amount,
  required DateTime occurredAt,
  String category = 'FOOD',
  String currency = 'VND',
}) => WealthTransaction(
  id: 'id',
  type: type,
  categoryCode: category,
  amount: amount,
  currency: currency,
  occurredAt: occurredAt,
);

ServiceRenewalRecord _renewal({
  required double amount,
  required DateTime occurredAt,
  String currency = 'VND',
}) => ServiceRenewalRecord(
  id: 'r',
  serviceId: 's1',
  serviceName: 'Netflix',
  amount: amount,
  currency: currency,
  occurredAt: occurredAt,
);

WealthBalanceEntry _entry({
  required double amount,
  required DateTime occurredAt,
  String currency = 'VND',
}) => WealthBalanceEntry(
  id: 'e',
  accountType: 'cash',
  currency: currency,
  amount: amount,
  occurredAt: occurredAt,
);

void main() {
  group('computeMonthlyTotals', () {
    test('khong co giao dich nao trong thang -> tong 0', () {
      final totals = computeMonthlyTotals([], DateTime(2026, 3));
      expect(totals.income, 0);
      expect(totals.expense, 0);
    });

    test('chi cong dung giao dich trong DUNG thang, loai khac thang khac', () {
      final transactions = [
        _tx(
          type: WealthTransactionType.income,
          amount: 1000,
          occurredAt: DateTime(2026, 3, 5),
        ),
        _tx(
          type: WealthTransactionType.expense,
          amount: 300,
          occurredAt: DateTime(2026, 3, 20),
        ),
        // Khac thang - phai bi loai
        _tx(
          type: WealthTransactionType.income,
          amount: 9999,
          occurredAt: DateTime(2026, 2, 5),
        ),
      ];
      final totals = computeMonthlyTotals(transactions, DateTime(2026, 3));
      expect(totals.income, 1000);
      expect(totals.expense, 300);
    });

    test('quy doi USD sang VND dung khi co usdVnd', () {
      final transactions = [
        _tx(
          type: WealthTransactionType.expense,
          amount: 10,
          currency: 'USD',
          occurredAt: DateTime(2026, 3, 1),
        ),
      ];
      final totals = computeMonthlyTotals(
        transactions,
        DateTime(2026, 3),
        usdVnd: 25000,
      );
      expect(totals.expense, 250000);
    });

    test('USD bi bo qua (khong cong nham) khi chua co usdVnd', () {
      final transactions = [
        _tx(
          type: WealthTransactionType.expense,
          amount: 10,
          currency: 'USD',
          occurredAt: DateTime(2026, 3, 1),
        ),
      ];
      final totals = computeMonthlyTotals(transactions, DateTime(2026, 3));
      expect(totals.expense, 0);
    });
  });

  group('computeExpenseByCategory', () {
    test('chi gom giao dich type=expense, dung thang, gop theo danh muc', () {
      final transactions = [
        _tx(
          type: WealthTransactionType.expense,
          amount: 100,
          category: 'FOOD',
          occurredAt: DateTime(2026, 3, 1),
        ),
        _tx(
          type: WealthTransactionType.expense,
          amount: 50,
          category: 'FOOD',
          occurredAt: DateTime(2026, 3, 2),
        ),
        _tx(
          type: WealthTransactionType.expense,
          amount: 200,
          category: 'TRANSPORT',
          occurredAt: DateTime(2026, 3, 3),
        ),
        _tx(
          type: WealthTransactionType.income,
          amount: 999,
          category: 'FOOD',
          occurredAt: DateTime(2026, 3, 3),
        ),
      ];
      final result = computeExpenseByCategory(transactions, DateTime(2026, 3));
      expect(result[WealthExpenseCategory.food], 150);
      expect(result[WealthExpenseCategory.transport], 200);
      expect(result.containsKey(WealthExpenseCategory.housing), false);
    });
  });

  group('computeMonthlyServiceRenewalTotal', () {
    test('tong dung cac lan renew trong thang, loai khac thang', () {
      final renewals = [
        _renewal(amount: 100000, occurredAt: DateTime(2026, 3, 10)),
        _renewal(amount: 50000, occurredAt: DateTime(2026, 3, 20)),
        _renewal(amount: 999999, occurredAt: DateTime(2026, 2, 10)),
      ];
      final total = computeMonthlyServiceRenewalTotal(
        renewals,
        DateTime(2026, 3),
      );
      expect(total, 150000);
    });

    test('khong co renew nao -> 0', () {
      expect(computeMonthlyServiceRenewalTotal([], DateTime(2026, 3)), 0);
    });
  });

  group('computeMonthlyWalletInflow', () {
    test('chi cong dong duong (tien vao), loai dong am (tien ra)', () {
      final entries = [
        _entry(amount: 500000, occurredAt: DateTime(2026, 3, 5)),
        _entry(amount: -200000, occurredAt: DateTime(2026, 3, 6)),
        _entry(amount: 100000, occurredAt: DateTime(2026, 3, 7)),
      ];
      final total = computeMonthlyWalletInflow(entries, DateTime(2026, 3));
      expect(total, 600000);
    });

    test('loai dong khac thang', () {
      final entries = [
        _entry(amount: 500000, occurredAt: DateTime(2026, 2, 28)),
        _entry(amount: 100000, occurredAt: DateTime(2026, 3, 1)),
      ];
      final total = computeMonthlyWalletInflow(entries, DateTime(2026, 3));
      expect(total, 100000);
    });

    test('khong co dong nao -> 0', () {
      expect(computeMonthlyWalletInflow([], DateTime(2026, 3)), 0);
    });
  });

  group('lastNMonths', () {
    test('sinh dung N thang ket thuc tai end, tang dan', () {
      final months = lastNMonths(DateTime(2026, 3), 3);
      expect(months, [DateTime(2026, 1), DateTime(2026, 2), DateTime(2026, 3)]);
    });

    test('lui qua nam truoc khi end o dau nam', () {
      final months = lastNMonths(DateTime(2026, 2), 6);
      expect(months, [
        DateTime(2025, 9),
        DateTime(2025, 10),
        DateTime(2025, 11),
        DateTime(2025, 12),
        DateTime(2026, 1),
        DateTime(2026, 2),
      ]);
    });
  });
}
