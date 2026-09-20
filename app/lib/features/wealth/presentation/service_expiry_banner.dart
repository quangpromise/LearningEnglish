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
  const ServiceExpiryBanner({
    super.key,
    required this.section,
    this.compact = false,
  });

  final AppSection section;

  /// Ban GON: 1 nut tron nho (icon + so ngay con lai) dat chung hang voi
  /// cac nut o thanh dau man, thay vi bang ngang chiem han 1 dong. Dung o
  /// man Fitness Home - man do khong cuon nen khong con cho cho 1 dong
  /// rieng. Bam vao van mo dung man Gia han nhu ban day du.
  final bool compact;

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

    if (compact) {
      return GestureDetector(
        onTap: () => showRenewServiceSheet(context, service),
        child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 9),
          decoration: BoxDecoration(
            color: tint.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: tint.withValues(alpha: 0.45)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.workspace_premium_rounded, size: 14, color: tint),
              const SizedBox(width: 5),
              // Ghi ro TEN GOI chu khong chi con so: "512d" tran trui thi
              // khong ai doan ra day la han cua goi tap nao.
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 62),
                child: Text(
                  service.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Text(
                // Qua han thi hien dau tru de phan biet ngay voi con han,
                // khong chi doi mau (nguoi kho phan biet mau van doc duoc).
                isOverdue ? '-${daysLeft.abs()}d' : '${daysLeft}d',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: tint,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      );
    }

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
