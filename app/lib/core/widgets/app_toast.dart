import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Thong bao ngan sau moi thao tac Save/Add/Edit/Delete - truoc day moi man
/// tu goi ScaffoldMessenger voi 1 SnackBar mac dinh (nen/chu theo theme goc,
/// khong co icon), nhieu man con KHONG bao gi ca nen nguoi dung khong biet
/// thao tac da an hay chua. Gom ve 1 cho de moi man dung CUNG 1 kieu: dau
/// tick xanh + chu ngan, noi len tren thanh dieu huong (floating).
///
/// Dung [showSuccessToast] cho luong thanh cong va [showErrorToast] khi ghi
/// len Supabase that bai - truoc day loi bi nuot trong `try/finally` khong co
/// `catch`, sheet van dong lai nhu da luu (xem bug danh muc dau tu ve 0).
void showSuccessToast(BuildContext context, String message) {
  _show(
    context,
    message,
    icon: Icons.check_circle_rounded,
    iconColor: AppColors.wealthUp,
  );
}

void showErrorToast(BuildContext context, String message) {
  _show(context, message, icon: Icons.error_rounded, iconColor: AppColors.pink);
}

void _show(
  BuildContext context,
  String message, {
  required IconData icon,
  required Color iconColor,
}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  messenger
    // Bam lien tuc (vd xoa nhieu dong) khong xep hang doi toast cu -> luon
    // thay phan hoi cua thao tac VUA lam.
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.bgTop,
        elevation: 0,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.glassBorder),
        ),
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.body(size: 13, weight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
}
