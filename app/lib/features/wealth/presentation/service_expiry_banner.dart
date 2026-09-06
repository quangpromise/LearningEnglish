import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_format.dart';
import 'renew_service_sheet.dart';

/// Thanh gon hien o man Home cua Fitness/Hoc Tieng Anh, bao thoi han cua
/// (cac) dich vu phi da GAN cho dung app do (xem app_providers.dart:
/// recurringServicesForSectionProvider) - "goi tap", "khoa hoc tieng Anh
/// tra phi"... KHONG render gi (SizedBox.shrink) neu app nay chua co dich vu
/// nao duoc gan, tranh chiem cho vo ich tren man Home. Bam vao mo thang man
/// Gia han (dung lai renew_service_sheet.dart cua Quan ly tai san).
class ServiceExpiryBanner extends ConsumerWidget {
  const ServiceExpiryBanner({super.key, required this.section});

  final AppSection section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(
      recurringServicesForSectionProvider(section),
    );
    final services = servicesAsync.valueOrNull ?? const [];
    if (services.isEmpty) return const SizedBox.shrink();

    // Uu tien hien dich vu SAP HET HAN NHAT (con it ngay nhat) - quan trong
    // nhat de nguoi dung thay ngay, cac dich vu con lai xem trong Ho so.
    final sorted = [...services]
      ..sort((a, b) => a.daysLeft.compareTo(b.daysLeft));
    final service = sorted.first;
    final daysLeft = service.daysLeft;
    final isOverdue = daysLeft < 0;
    final isUrgent = isOverdue || daysLeft <= service.reminderLeadDays;
    final tint = isUrgent ? AppColors.pink : AppColors.wealthAccent;

    return GestureDetector(
      onTap: () => showRenewServiceSheet(context, service),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: tint.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: tint.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            Icon(Icons.workspace_premium_rounded, size: 16, color: tint),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    service.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body(
                      size: 12.5,
                      weight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    isOverdue
                        ? '${ref.tr('wealth_service_overdue')} · ${formatDateMdy(service.expiryDate)}'
                        : '${ref.tr('wealth_service_days_left')}: $daysLeft · ${formatDateMdy(service.expiryDate)}',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: tint,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
            if (services.length > 1)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '+${services.length - 1}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: tint,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
