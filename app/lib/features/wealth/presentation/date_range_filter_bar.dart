import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';

/// Chip loc theo khoang ngay - dung chung cho cac man lich su (Chi tieu,
/// Tien mat, Ngan hang) de nguoi dung tim lai giao dich trong 1 khoang thoi
/// gian cu the thay vi phai cuon qua toan bo danh sach.
class DateRangeFilterBar extends ConsumerWidget {
  const DateRangeFilterBar({
    super.key,
    required this.range,
    required this.onChanged,
  });
  final DateTimeRange? range;
  final ValueChanged<DateTimeRange?> onChanged;

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final label = range == null
        ? ref.tr('wealth_filter_by_date')
        : '${_fmt(range!.start)} - ${_fmt(range!.end)}';
    return GestureDetector(
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(now.year - 10),
          lastDate: now,
          initialDateRange: range,
        );
        if (picked != null) onChanged(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: range != null
              ? AppColors.wealthAccent.withValues(alpha: 0.16)
              : AppColors.glassFill,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: range != null
                ? AppColors.wealthAccent
                : AppColors.glassBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.calendar_month_rounded,
              size: 14,
              color: AppColors.wealthAccent,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.body(size: 11.5, weight: FontWeight.w700),
            ),
            if (range != null) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => onChanged(null),
                child: const Icon(
                  Icons.close_rounded,
                  size: 14,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Kiem tra [occurredAt] co nam trong [range] hay khong - bao gom TRON VEN
/// ngay cuoi (end cua DateTimeRange mac dinh la 00:00 ngay do, can cong
/// them gan 1 ngay de khong bo sot giao dich xay ra trong chinh ngay cuoi).
bool isWithinDateRange(DateTime occurredAt, DateTimeRange? range) {
  if (range == null) return true;
  final start = DateTime(range.start.year, range.start.month, range.start.day);
  final end = DateTime(
    range.end.year,
    range.end.month,
    range.end.day,
  ).add(const Duration(days: 1));
  return !occurredAt.isBefore(start) && occurredAt.isBefore(end);
}
