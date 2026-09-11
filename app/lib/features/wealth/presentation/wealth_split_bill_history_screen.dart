import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/navigation/app_popup.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_format.dart';
import '../../../core/utils/date_format.dart';
import '../data/wealth_balance_entry_model.dart';
import '../data/wealth_split_bill_model.dart';
import 'confirm_delete.dart';
import 'wealth_split_bill_receipt.dart';
import 'wealth_split_bill_screen.dart';

/// Xoa 1 lan chia bill - don dep het cac ban ghi da sinh ra cung luc voi no
/// (khoan Chi tieu tru tong tien + khoan No "Ghi nợ" cho tung nguoi, xem
/// _confirmPay trong wealth_split_bill_screen.dart) truoc khi xoa chinh dong
/// wealth_split_bills, de KHONG con Chi tieu/No "mo coi" lam sai lech
/// Vi/Bao cao sau khi xoa. Dung CHUNG cho ca 2 noi: xoa han (_BillRow) va
/// sua bill (WealthSplitBillScreen o che do edit - xoa ban ghi CU truoc khi
/// tao lai ban ghi MOI theo du lieu da sua).
Future<void> deleteSplitBillCascade(WidgetRef ref, WealthSplitBill bill) async {
  final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;
  if (userId == null) return;
  final billRepo = ref.read(wealthSplitBillRepositoryProvider);
  final shares = await billRepo.fetchShares(userId, bill.id);
  final debtRepo = ref.read(wealthDebtRepositoryProvider);
  for (final s in shares) {
    // Xoa khoan No cascade xoa luon wealth_debt_payments + cac dong Vi da
    // sinh tu no (xem migration 0032) - vd truong hop da THU roi moi xoa.
    if (s.debtId != null) {
      await debtRepo.delete(userId, s.debtId!);
    }
  }
  // Xoa khoan Chi tieu cascade xoa dong Vi "-tong tien" cua "Toi"
  // (source_transaction_id on delete cascade, xem migration 0032).
  if (bill.transactionId != null) {
    await ref
        .read(wealthTransactionRepositoryProvider)
        .deleteTransaction(userId, bill.transactionId!);
  }
  // Xoa chinh bill - cascade xoa het cac dong share, keo theo cascade xoa
  // dong Vi "Da tra" cua tung nguoi (source_bill_share_id, migration 0052).
  await billRepo.delete(userId, bill.id);
  ref.invalidate(walletBalanceEntriesProvider);
  ref.invalidate(wealthTransactionsProvider);
  ref.invalidate(debtsProvider('owed_to_me'));
  ref.invalidate(wealthSplitBillsProvider);
}

/// Lich su cac lan Chia tien bill da luu (xem wealth_split_bill_screen.dart)
/// - bam vao 1 dong de xem lai hoa don day du, van co the bam "Ghi no"/"Da
/// tra" tiep cho nguoi con 'pending' (vd luc chia bill nguoi dung thoat man
/// giua chung chua xu ly het).
class WealthSplitBillHistoryScreen extends ConsumerWidget {
  const WealthSplitBillHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billsAsync = ref.watch(wealthSplitBillsProvider);
    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.glassFill,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: const Icon(
                      Icons.chevron_left_rounded,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    ref.tr('wealth_split_bill_history_title'),
                    style: AppTextStyles.heading(size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Expanded(
              child: billsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.wealthAccent,
                  ),
                ),
                error: (_, _) =>
                    Center(child: Text(ref.tr('wealth_load_error'))),
                data: (bills) => bills.isEmpty
                    ? Center(
                        child: Text(
                          ref.tr('wealth_split_bill_history_empty'),
                          style: AppTextStyles.muted(),
                        ),
                      )
                    : ListView.separated(
                        itemCount: bills.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, i) => _BillRow(bill: bills[i]),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BillRow extends ConsumerWidget {
  const _BillRow({required this.bill});
  final WealthSplitBill bill;

  /// Mo lai man Chia tien bill o CHE DO SUA - xoa het ban ghi CU (Chi
  /// tieu/No cua bill nay) roi tao lai TU DAU theo du lieu nguoi dung sua
  /// khi bam "Cap nhat" (xem WealthSplitBillScreen.editingBill va
  /// _confirmPay o do) - don gian va chac chan dung hon so voi doi chieu
  /// tung phan thay doi (nguoi them/bot, doi Ghi no <-> Da tra...).
  Future<void> _editBill(BuildContext context, WidgetRef ref) async {
    final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;
    if (userId == null) return;
    final shares = await ref
        .read(wealthSplitBillRepositoryProvider)
        .fetchShares(userId, bill.id);
    if (!context.mounted) return;
    openAppPopup(
      context,
      WealthSplitBillScreen(editingBill: bill, editingShares: shares),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey(bill.id),
      direction: DismissDirection.endToStart,
      // Chay HET logic xoa (nhieu buoc await: xoa No -> xoa Chi tieu -> xoa
      // bill) NGAY TRONG confirmDismiss, truoc khi tra ve true - Dismissible
      // chi thuc su go widget nay khoi cay sau khi confirmDismiss hoan tat.
      // TRUOC DAY logic xoa nam o onDismissed (chay SAU khi widget da bi go
      // khoi cay) - WidgetRef cua 1 ConsumerWidget khong con dung duoc sau
      // khi widget unmount, nen cac buoc xoa o GIUA/CUOI chuoi await (xoa
      // Chi tieu, invalidate lai danh sach) hay bi bo do ref da "chet",
      // trong khi buoc DAU (xoa No) vi chay som nen van kip thanh cong -
      // dung khop trieu chung "nợ đã xoá nhưng Chi tiêu/Vi chưa xoá".
      confirmDismiss: (_) async {
        final ok = await confirmDelete(context, ref);
        if (!ok) return false;
        await deleteSplitBillCascade(ref, bill);
        return true;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.pink.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: AppColors.pink),
      ),
      child: GestureDetector(
        onTap: () =>
            openAppPopup(context, WealthSplitBillDetailScreen(bill: bill)),
        child: GlowBox(
          borderRadius: 16,
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.wealthAccent.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.call_split_rounded,
                  color: AppColors.wealthAccent,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatVnd(bill.totalAmount),
                      style: AppTextStyles.body(weight: FontWeight.w800),
                    ),
                    Text(
                      bill.note?.isNotEmpty == true
                          ? '${formatDateMdy(bill.occurredAt)} · ${bill.note}'
                          : formatDateMdy(bill.occurredAt),
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.muted(size: 11.5),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _editBill(context, ref),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    Icons.edit_rounded,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Xem lai/tiep tuc xu ly 1 hoa don da luu - doc that tu DB
/// ([wealthSplitBillSharesProvider]) thay vi trang thai trong bo nho, nen
/// van dung duoc du mo lai o phien app khac.
class WealthSplitBillDetailScreen extends ConsumerWidget {
  const WealthSplitBillDetailScreen({super.key, required this.bill});
  final WealthSplitBill bill;

  Future<void> _markDebt(WidgetRef ref, WealthSplitBillShare share) async {
    final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;
    if (userId == null) return;
    final person = await ref
        .read(wealthDebtPersonRepositoryProvider)
        .findOrCreate(userId, share.personName);
    final debtId = await ref
        .read(wealthDebtRepositoryProvider)
        .create(
          userId: userId,
          personId: person.id,
          direction: 'owed_to_me',
          amount: share.amount,
          currency: 'VND',
          occurredAt: DateTime.now(),
          note: ref.tr('wealth_split_bill_title'),
        );
    ref.invalidate(debtsProvider('owed_to_me'));
    await ref
        .read(wealthSplitBillRepositoryProvider)
        .updateShareStatus(userId, share.id, status: 'debt', debtId: debtId);
    ref.invalidate(wealthSplitBillSharesProvider(bill.id));
  }

  Future<void> _markPaid(WidgetRef ref, WealthSplitBillShare share) async {
    final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;
    if (userId == null) return;
    await ref
        .read(wealthBalanceEntryRepositoryProvider)
        .addEntry(
          userId,
          WealthBalanceEntry(
            id: '',
            accountType: bill.paymentAccountType,
            bankCode: bill.paymentBankCode,
            bankName: bill.paymentBankName,
            currency: 'VND',
            amount: share.amount,
            note: '${share.personName} - ${ref.tr('wealth_split_bill_title')}',
            occurredAt: DateTime.now(),
            source: 'manual',
          ),
        );
    ref.invalidate(walletBalanceEntriesProvider);
    await ref
        .read(wealthSplitBillRepositoryProvider)
        .updateShareStatus(userId, share.id, status: 'paid');
    ref.invalidate(wealthSplitBillSharesProvider(bill.id));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sharesAsync = ref.watch(wealthSplitBillSharesProvider(bill.id));
    final qr = ref.watch(wealthPaymentQrProvider).valueOrNull;
    final paymentLabel = bill.paymentAccountType == 'cash'
        ? ref.tr('wallet_section_cash')
        : (bill.paymentBankName ?? bill.paymentBankCode ?? '');
    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.glassFill,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: const Icon(
                      Icons.chevron_left_rounded,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    ref.tr('wealth_split_bill_title'),
                    style: AppTextStyles.heading(size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Expanded(
              child: SingleChildScrollView(
                child: sharesAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.wealthAccent,
                    ),
                  ),
                  error: (_, _) =>
                      Center(child: Text(ref.tr('wealth_load_error'))),
                  data: (shares) => SplitBillReceiptCard(
                    totalAmount: bill.totalAmount,
                    paymentLabel: paymentLabel,
                    occurredAt: bill.occurredAt,
                    note: bill.note,
                    qr: qr,
                    people: [
                      for (final s in shares)
                        ReceiptPersonView(
                          name: s.personName,
                          amount: s.amount,
                          isMe: s.isMe,
                          status: s.status,
                          onDebt: (s.isMe || s.status != 'pending')
                              ? null
                              : () => _markDebt(ref, s),
                          onPaid: (s.isMe || s.status != 'pending')
                              ? null
                              : () => _markPaid(ref, s),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
