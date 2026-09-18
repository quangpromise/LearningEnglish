import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../i18n/app_strings.dart';
import '../theme/app_theme.dart';

/// Hop thoai xac nhan DUNG CHUNG cho moi thao tac ghi/xoa du lieu trong app
/// (yeu cau nguoi dung 2026-09-19: "delete, save, hay add deu phai co man
/// hinh xac nhan").
///
/// DAT O core/ chu khong phai trong 1 feature: truoc day moi khu Wealth co
/// `confirmDelete` rieng (features/wealth/presentation/confirm_delete.dart)
/// nen To do/Lap ke hoach xoa thang khong hoi gi - dung la loi da bao.
///
/// LUON mo bang useRootNavigator: gan het man hinh trong app la popup
/// (openAppPopup - modal bottom sheet phu 94% man hinh), hop thoai neo vao
/// Navigator cua popup se bi chinh popup do che.
Future<bool> confirmAction(
  BuildContext context,
  WidgetRef ref, {
  required String title,
  String? message,
  required String confirmLabel,

  /// true = hanh dong pha huy (xoa) -> nut xac nhan mau hong canh bao.
  bool danger = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    useRootNavigator: true,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.bgMid,
      title: Text(title, style: AppTextStyles.heading(size: 16)),
      content: message == null
          ? null
          : Text(message, style: AppTextStyles.body(size: 13)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(ref.tr('common_cancel')),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(
            confirmLabel,
            style: TextStyle(
              color: danger ? AppColors.pink : AppColors.wealthUp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Xac nhan truoc khi LUU/THEM. [message] de mo ta ro thu sap ghi (vd so
/// tien, ten khoan) khi man hinh do co du thong tin dang gia de nhac lai.
Future<bool> confirmSave(
  BuildContext context,
  WidgetRef ref, {
  String? message,
}) => confirmAction(
  context,
  ref,
  title: ref.tr('confirm_save_title'),
  message: message,
  confirmLabel: ref.tr('wallet_save'),
);

/// Xac nhan truoc khi XOA - thay cho `confirmDelete` cu cua rieng khu Wealth.
Future<bool> confirmDeleteAction(
  BuildContext context,
  WidgetRef ref, {
  String? message,
}) => confirmAction(
  context,
  ref,
  title: ref.tr('wealth_delete_confirm_title'),
  message: message,
  confirmLabel: ref.tr('common_delete'),
  danger: true,
);
