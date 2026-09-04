import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';

/// Hop thoai xac nhan truoc khi xoa - dung lam `confirmDismiss` cho moi
/// `Dismissible` (vuot de xoa) trong khu vuc Wealth, tranh xoa nham do vuot
/// tay lo (yeu cau nguoi dung 2026-09-05).
Future<bool> confirmDelete(BuildContext context, WidgetRef ref) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.bgMid,
      title: Text(
        ref.tr('wealth_delete_confirm_title'),
        style: AppTextStyles.heading(size: 16),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(ref.tr('common_cancel')),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(
            ref.tr('common_delete'),
            style: const TextStyle(color: AppColors.pink),
          ),
        ),
      ],
    ),
  );
  return result ?? false;
}
