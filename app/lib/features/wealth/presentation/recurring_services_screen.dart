import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_format.dart';
import '../data/recurring_service_model.dart';
import 'add_service_sheet.dart';
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

class _ServiceCard extends ConsumerWidget {
  const _ServiceCard({required this.service});
  final RecurringService service;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daysLeft = service.daysLeft;
    final isUrgent = daysLeft <= service.reminderLeadDays;
    return Dismissible(
      key: ValueKey(service.id),
      direction: DismissDirection.endToStart,
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
              ],
            ),
            const SizedBox(height: 4),
            Text(
              daysLeft < 0
                  ? ref.tr('wealth_service_overdue')
                  : '${ref.tr('wealth_service_days_left')}: $daysLeft',
              style: AppTextStyles.muted(size: 11)
                  .copyWith(color: isUrgent ? AppColors.pink : null),
            ),
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
