import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_format.dart';
import '../../../core/utils/date_format.dart';
import '../data/recurring_service_model.dart';
import 'add_service_sheet.dart';
import 'confirm_delete.dart';
import 'renew_service_sheet.dart';

/// Man Dich vu dinh ky (Phase G) - theo doi phi dich vu dang dung (Netflix,
/// hosting...), nhac han qua push truoc N ngay (tuy chon 1 tuan/nua thang/
/// 1 thang, xem check-service-expiry chay hang ngay qua pg_cron), gia han
/// tu tru vao Vi.
class RecurringServicesScreen extends ConsumerWidget {
  const RecurringServicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(recurringServicesProvider);
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
                    ref.tr('wealth_service_title'),
                    style: AppTextStyles.heading(size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: servicesAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.wealthAccent,
                  ),
                ),
                error: (_, _) => Center(
                  child: Text(
                    ref.tr('wealth_load_error'),
                    style: AppTextStyles.muted(),
                  ),
                ),
                data: (services) {
                  if (services.isEmpty) {
                    return Center(
                      child: Text(
                        ref.tr('wealth_service_empty'),
                        style: AppTextStyles.muted(),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: services.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, i) =>
                        _ServiceCard(service: services[i]),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: PillButton(
                label: ref.tr('wealth_service_add'),
                accentGradient: AppColors.wealthAccentGradient,
                accentColor: AppColors.wealthAccent,
                icon: const Icon(
                  Icons.add_rounded,
                  size: 16,
                  color: Colors.white,
                ),
                onTap: () => showAddServiceSheet(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showAssignSheet(
  BuildContext context,
  WidgetRef ref,
  RecurringService service,
) async {
  final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;
  if (userId == null) return;
  final choice = await showModalBottomSheet<String?>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 26),
      decoration: const BoxDecoration(
        color: Color(0xFF12172E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ref.tr('wealth_service_assign_title'),
            style: AppTextStyles.heading(size: 16),
          ),
          const SizedBox(height: 4),
          Text(service.name, style: AppTextStyles.muted(size: 12)),
          const SizedBox(height: 14),
          _AssignOption(
            label: ref.tr('wealth_service_assign_none'),
            selected: service.appSection == null,
            onTap: () => Navigator.of(sheetContext).pop(''),
          ),
          const SizedBox(height: 8),
          _AssignOption(
            label: ref.tr('planner_app_fitness'),
            selected: service.appSection == kServiceAppSectionFitness,
            onTap: () =>
                Navigator.of(sheetContext).pop(kServiceAppSectionFitness),
          ),
          const SizedBox(height: 8),
          _AssignOption(
            label: ref.tr('planner_app_english'),
            selected: service.appSection == kServiceAppSectionLearnEnglish,
            onTap: () =>
                Navigator.of(sheetContext).pop(kServiceAppSectionLearnEnglish),
          ),
        ],
      ),
    ),
  );
  if (choice == null) return;
  await ref
      .read(recurringServiceRepositoryProvider)
      .assignToSection(
        userId: userId,
        id: service.id,
        appSection: choice.isEmpty ? null : choice,
      );
  ref.invalidate(recurringServicesProvider);
}

class _AssignOption extends StatelessWidget {
  const _AssignOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.wealthAccent.withValues(alpha: 0.18)
              : AppColors.glassFill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.wealthAccent : AppColors.glassBorder,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.body(weight: FontWeight.w700, size: 13),
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_rounded,
                size: 18,
                color: AppColors.wealthAccent,
              ),
          ],
        ),
      ),
    );
  }
}

class _ServiceCard extends ConsumerStatefulWidget {
  const _ServiceCard({required this.service});
  final RecurringService service;

  @override
  ConsumerState<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends ConsumerState<_ServiceCard> {
  bool _historyExpanded = false;

  @override
  Widget build(BuildContext context) {
    final service = widget.service;
    final daysLeft = service.daysLeft;
    final isUrgent = daysLeft <= service.reminderLeadDays;
    return Dismissible(
      key: ValueKey(service.id),
      direction: DismissDirection.endToStart,
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
        await ref
            .read(recurringServiceRepositoryProvider)
            .deactivate(userId, service.id);
        ref.invalidate(recurringServicesProvider);
      },
      child: GlowBox(
        borderRadius: 18,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    service.name,
                    style: AppTextStyles.body(weight: FontWeight.w800),
                  ),
                ),
                Text(
                  formatByCurrency(service.defaultAmount, service.currency),
                  style: AppTextStyles.body(weight: FontWeight.w700, size: 12),
                ),
                GestureDetector(
                  onTap: () => _showAssignSheet(context, ref, service),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Icon(
                      Icons.link_rounded,
                      size: 16,
                      color: service.appSection != null
                          ? AppColors.wealthAccent
                          : AppColors.textMuted,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => showAddServiceSheet(context, existing: service),
                  child: const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(
                      Icons.edit_rounded,
                      size: 16,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () =>
                      setState(() => _historyExpanded = !_historyExpanded),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Icon(
                      Icons.history_rounded,
                      size: 16,
                      color: _historyExpanded
                          ? AppColors.wealthAccent
                          : AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${daysLeft < 0 ? ref.tr('wealth_service_overdue') : '${ref.tr('wealth_service_days_left')}: $daysLeft'} '
              '(${formatDateMdy(service.expiryDate)})',
              style: AppTextStyles.muted(size: 11)
                  .copyWith(color: isUrgent ? AppColors.pink : null),
            ),
            if (service.appSection != null) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.wealthAccent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.link_rounded,
                      size: 11,
                      color: AppColors.wealthAccent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      ref.tr(
                        service.appSection == kServiceAppSectionFitness
                            ? 'planner_app_fitness'
                            : 'planner_app_english',
                      ),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.wealthAccent,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (_historyExpanded) ...[
              const SizedBox(height: 10),
              _ServiceHistorySection(serviceId: service.id),
            ],
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: PillButton(
                label: ref.tr('wealth_service_renew'),
                accentColor: AppColors.wealthAccent,
                filled: false,
                onTap: () => showRenewServiceSheet(context, service),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Lich su gia han cua 1 dich vu + so sanh so tien lan gia han gan nhat voi
/// lan truoc do - dung "lan gia han truoc" thay vi "thang truoc" theo lich
/// vi nhieu dich vu (Gym Elite goi nam, 4G Viettel goi thang...) khong renew
/// dung moi thang, so sanh theo thang se ra 0 sai lech gay hieu lam.
class _ServiceHistorySection extends ConsumerWidget {
  const _ServiceHistorySection({required this.serviceId});
  final String serviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final renewalsAsync = ref.watch(serviceRenewalsProvider);
    return renewalsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.wealthAccent,
            ),
          ),
        ),
      ),
      error: (_, _) => Text(
        ref.tr('wealth_load_error'),
        style: AppTextStyles.muted(size: 11),
      ),
      data: (all) {
        final history = all.where((r) => r.serviceId == serviceId).toList()
          ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
        if (history.isEmpty) {
          return Text(
            ref.tr('wealth_report_no_data'),
            style: AppTextStyles.muted(size: 11),
          );
        }
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.glassFill,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ref.tr('wealth_service_history_toggle'),
                style: AppTextStyles.body(size: 11.5, weight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              if (history.length >= 2)
                _RenewalDeltaLabel(
                  current: history[0].amount,
                  previous: history[1].amount,
                )
              else
                Text(
                  ref.tr('wealth_service_no_previous_renewal'),
                  style: AppTextStyles.muted(size: 10.5),
                ),
              const SizedBox(height: 8),
              for (final r in history)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          formatDateMdy(r.occurredAt),
                          style: AppTextStyles.muted(size: 11),
                        ),
                      ),
                      Text(
                        formatByCurrency(r.amount, r.currency),
                        style: AppTextStyles.body(
                          size: 11.5,
                          weight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _RenewalDeltaLabel extends ConsumerWidget {
  const _RenewalDeltaLabel({required this.current, required this.previous});
  final double current;
  final double previous;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (previous == 0) {
      return Text(
        ref.tr('wealth_service_no_previous_renewal'),
        style: AppTextStyles.muted(size: 10.5),
      );
    }
    final percent = (current - previous) / previous * 100;
    final increased = percent >= 0;
    final color = increased ? AppColors.pink : AppColors.teal;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          increased ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
          size: 12,
          color: color,
        ),
        const SizedBox(width: 2),
        Text(
          '${percent.abs().toStringAsFixed(1)}% ${ref.tr('wealth_service_vs_previous_renewal')}',
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: color,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }
}
