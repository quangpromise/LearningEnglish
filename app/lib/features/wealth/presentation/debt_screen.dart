import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/navigation/app_popup.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_format.dart';
import '../data/wealth_debt_model.dart';
import 'add_debt_sheet.dart';
import 'batch_pay_debt_sheet.dart';
import 'confirm_delete.dart';
import 'debt_person_history_screen.dart';

/// Man No (Phase E) - 2 tab "Dang no" (minh no nguoi khac) va "Nguoi khac no
/// minh". So sach doc lap, KHONG cong vao tong tai san o Home/Vi (xem ke
/// hoach build lai Wealth - liability/receivable khac ban chat voi tai san
/// dang co/dau tu).
class DebtScreen extends StatefulWidget {
  const DebtScreen({super.key});

  @override
  State<DebtScreen> createState() => _DebtScreenState();
}

class _DebtScreenState extends State<DebtScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer(
              builder: (context, ref, _) => Row(
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
                      ref.tr('wealth_debt_title'),
                      style: AppTextStyles.heading(size: 20),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _DebtSummaryCard(tabController: _tabController),
            const SizedBox(height: 14),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  _DebtList(direction: 'i_owe'),
                  _DebtList(direction: 'owed_to_me'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The tong "Dang no" (mau do, phai tra) va "Cho muon" (mau xanh, phai thu)
/// - gop theo tung loai tien te neu nguoi dung co ca khoan VND lan USD. Bam
/// vao 1 the se chuyen TabBarView sang danh sach tuong ung - thay the cho
/// hang nut "I owe"/"Owed to me" rieng biet truoc day (2 bo dieu khien lam
/// cung 1 viec la thua, theo yeu cau nguoi dung gop lai).
class _DebtSummaryCard extends ConsumerWidget {
  const _DebtSummaryCard({required this.tabController});
  final TabController tabController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final owe = ref.watch(debtsProvider('i_owe')).valueOrNull ?? [];
    final lend = ref.watch(debtsProvider('owed_to_me')).valueOrNull ?? [];
    return AnimatedBuilder(
      animation: tabController,
      builder: (context, _) => Row(
        children: [
          Expanded(
            child: _SummaryTile(
              label: ref.tr('wealth_debt_tab_i_owe'),
              color: AppColors.pink,
              totalsByCurrency: _sumByCurrency(owe),
              selected: tabController.index == 0,
              onTap: () => tabController.animateTo(0),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _SummaryTile(
              label: ref.tr('wealth_debt_tab_owed_to_me'),
              color: AppColors.teal,
              totalsByCurrency: _sumByCurrency(lend),
              selected: tabController.index == 1,
              onTap: () => tabController.animateTo(1),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, double> _sumByCurrency(List<WealthDebt> debts) {
    final map = <String, double>{};
    for (final d in debts) {
      map[d.currency] = (map[d.currency] ?? 0) + d.remainingAmount;
    }
    return map;
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.color,
    required this.totalsByCurrency,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final Color color;
  final Map<String, double> totalsByCurrency;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlowBox(
        borderRadius: 16,
        border: selected
            ? Border.all(color: color.withValues(alpha: 0.6), width: 1.4)
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.muted(size: 12.5)),
            const SizedBox(height: 4),
            if (totalsByCurrency.isEmpty)
              Text(
                formatVnd(0),
                style: AppTextStyles.heading(size: 18).copyWith(color: color),
              )
            else
              for (final entry in totalsByCurrency.entries)
                Text(
                  formatByCurrency(entry.value, entry.key),
                  style: AppTextStyles.heading(size: 18).copyWith(color: color),
                ),
          ],
        ),
      ),
    );
  }
}

class _DebtList extends ConsumerStatefulWidget {
  const _DebtList({required this.direction});
  final String direction;

  @override
  ConsumerState<_DebtList> createState() => _DebtListState();
}

class _DebtListState extends ConsumerState<_DebtList> {
  bool _selecting = false;
  final Set<String> _selectedPersonIds = {};

  void _toggleSelectMode() {
    setState(() {
      _selecting = !_selecting;
      _selectedPersonIds.clear();
    });
  }

  void _toggleSelected(String personId) {
    setState(() {
      if (_selectedPersonIds.contains(personId)) {
        _selectedPersonIds.remove(personId);
      } else {
        _selectedPersonIds.add(personId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final debtsAsync = ref.watch(debtsProvider(widget.direction));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: _toggleSelectMode,
            child: Text(
              ref.tr(
                _selecting
                    ? 'wealth_debt_select_cancel'
                    : 'wealth_debt_select_mode',
              ),
              style: AppTextStyles.body(
                size: 12,
                weight: FontWeight.w700,
                color: AppColors.wealthAccent,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: debtsAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.wealthAccent),
            ),
            error: (_, _) => Center(
              child: Text(
                ref.tr('wealth_load_error'),
                style: AppTextStyles.muted(),
              ),
            ),
            data: (debts) {
              if (debts.isEmpty) {
                return Center(
                  child: Text(
                    ref.tr('wealth_debt_empty'),
                    style: AppTextStyles.muted(),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              // Gop nhieu khoan no cua CUNG 1 nguoi thanh 1 the duy nhat -
              // chi tiet tung khoan (ngay gio + note) chuyen het vao
              // DebtPersonHistoryScreen thay vi hien lap lai ten nguoi
              // nhieu lan o danh sach chinh (xem yeu cau nguoi dung).
              final groups = <String, List<WealthDebt>>{};
              for (final d in debts) {
                groups.putIfAbsent(d.personId, () => []).add(d);
              }
              final groupList = groups.values.toList();
              return ListView.separated(
                itemCount: groupList.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, i) => _PersonGroupTile(
                  debts: groupList[i],
                  selecting: _selecting,
                  selected: _selectedPersonIds.contains(
                    groupList[i].first.personId,
                  ),
                  onToggleSelect: () =>
                      _toggleSelected(groupList[i].first.personId),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        if (_selecting)
          SizedBox(
            width: double.infinity,
            child: PillButton(
              label: ref
                  .tr(
                    widget.direction == 'i_owe'
                        ? 'wealth_debt_batch_pay'
                        : 'wealth_debt_batch_collect',
                  )
                  .replaceFirst('{n}', '${_selectedPersonIds.length}'),
              accentColor: widget.direction == 'i_owe'
                  ? AppColors.pink
                  : AppColors.teal,
              onTap: _selectedPersonIds.isEmpty
                  ? null
                  : () async {
                      final debtsAsync = ref.read(
                        debtsProvider(widget.direction),
                      );
                      final debts = debtsAsync.valueOrNull ?? [];
                      final selected = debts
                          .where(
                            (d) =>
                                _selectedPersonIds.contains(d.personId) &&
                                !d.isSettled,
                          )
                          .toList();
                      await showBatchPayDebtSheet(
                        context,
                        widget.direction,
                        selected,
                      );
                      if (mounted) {
                        setState(() {
                          _selecting = false;
                          _selectedPersonIds.clear();
                        });
                      }
                    },
            ),
          )
        else
          SizedBox(
            width: double.infinity,
            child: PillButton(
              label: ref.tr('wealth_debt_add'),
              accentGradient: AppColors.wealthAccentGradient,
              accentColor: AppColors.wealthAccent,
              icon: const Icon(
                Icons.add_rounded,
                size: 16,
                color: Colors.white,
              ),
              onTap: () => showAddDebtSheet(context, widget.direction),
            ),
          ),
      ],
    );
  }
}

/// The gop TAT CA khoan no cua 1 nguoi (cung 1 chieu) - tong so du con lai
/// theo tung loai tien te, bam vao mo lich su chi tiet tung khoan (ngay gio
/// + note + tra/thu tung phan) trong DebtPersonHistoryScreen. Sua/xoa tung
/// khoan cu the cung chuyen het vao man lich su do.
class _PersonGroupTile extends ConsumerWidget {
  const _PersonGroupTile({
    required this.debts,
    required this.selecting,
    required this.selected,
    required this.onToggleSelect,
  });
  final List<WealthDebt> debts;
  final bool selecting;
  final bool selected;
  final VoidCallback onToggleSelect;

  Map<String, double> _totalsByCurrency() {
    final map = <String, double>{};
    for (final d in debts) {
      map[d.currency] = (map[d.currency] ?? 0) + d.remainingAmount;
    }
    return map;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final first = debts.first;
    final allSettled = debts.every((d) => d.isSettled);
    final totals = _totalsByCurrency();
    return Dismissible(
      key: ValueKey('${first.personId}_${first.direction}'),
      direction: selecting
          ? DismissDirection.none
          : DismissDirection.endToStart,
      confirmDismiss: (_) => confirmDelete(context, ref),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.pink.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: AppColors.pink),
      ),
      onDismissed: (_) async {
        final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;
        if (userId == null) return;
        // Xoa TAT CA khoan no cua nguoi nay (cung 1 chieu) - moi khoan
        // cascade xoa het payments + balance entries lien quan.
        final repo = ref.read(wealthDebtRepositoryProvider);
        for (final d in debts) {
          await repo.delete(userId, d.id);
        }
        ref.invalidate(walletBalanceEntriesProvider);
        ref.invalidate(debtsProvider(first.direction));
        ref.invalidate(debtsByPersonProvider(first.personId));
      },
      child: GestureDetector(
        onTap: selecting
            ? onToggleSelect
            : () => openAppPopup(
                context,
                DebtPersonHistoryScreen(
                  personId: first.personId,
                  personName: first.personName,
                ),
              ),
        child: GlowBox(
          borderRadius: 16,
          border: selecting && selected
              ? Border.all(color: AppColors.wealthAccent, width: 1.4)
              : null,
          child: Row(
            children: [
              if (selecting) ...[
                Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 20,
                  color: selected
                      ? AppColors.wealthAccent
                      : AppColors.textMuted,
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      first.personName,
                      style: AppTextStyles.body(
                        size: 16,
                        weight: FontWeight.w800,
                      ),
                    ),
                    if (debts.length > 1)
                      Consumer(
                        builder: (context, ref, _) => Text(
                          '${debts.length} ${ref.tr('wealth_debt_entries_suffix')}',
                          style: AppTextStyles.muted(size: 12),
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final entry in totals.entries)
                    Text(
                      formatByCurrency(entry.value, entry.key),
                      style:
                          AppTextStyles.body(
                            size: 16,
                            weight: FontWeight.w800,
                          ).copyWith(
                            color: first.isIOwe
                                ? AppColors.pink
                                : AppColors.teal,
                          ),
                    ),
                  if (allSettled)
                    Consumer(
                      builder: (context, ref, _) => Text(
                        ref.tr('wealth_debt_settled'),
                        style: AppTextStyles.muted(size: 11.5),
                      ),
                    ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 22,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
