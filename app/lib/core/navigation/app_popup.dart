import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Mo 1 man hinh dang POPUP (bottom sheet gan full man hinh, boc goc tren) -
/// dung cho TAT CA man hinh "khac" trong 1 "app" (khong phai man Home chinh
/// cua app do) theo yeu cau thiet ke moi: chi man Home moi la 1 man hinh
/// that su nam duoi Menu, moi tinh nang khac (Phonics, Story, Vocabulary,
/// Grammar, Reading, Quiz, Luyen phat am, Thu vien bai tap, Chi tieu/Thu
/// nhap/Dau tu, Tin nhan...) deu mo len tren dang popup roi dong lai ve
/// dung Home - khong con "day sang man hinh rieng" (Navigator.push) nhu
/// truoc. useRootNavigator: true de popup luon phu duoc TOAN MAN HINH bat
/// ke duoc goi tu dau.
void openAppPopup(BuildContext context, Widget child) {
  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => FractionallySizedBox(
      heightFactor: 0.94,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: child,
      ),
    ),
  );
}

/// Nut dong (X) dung chung cho header cua MOI man popup - cac man nay
/// KHONG con AppTopBar/avatar (chi man Home chinh moi co "header nhu
/// headpage" voi avatar), nen can 1 cach ro rang de dong lai thay vi chi
/// dua vao vuot xuong.
class PopupCloseButton extends StatelessWidget {
  const PopupCloseButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
          Icons.close_rounded,
          size: 18,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

/// Header don gian (tieu de + nut dong) dung cho man popup thay cho
/// AppTopBar - khong avatar, khong pill chuyen app.
class PopupHeader extends StatelessWidget {
  const PopupHeader({super.key, required this.title, this.trailing});
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: AppTextStyles.heading(size: 18))),
        if (trailing != null) ...[trailing!, const SizedBox(width: 10)],
        const PopupCloseButton(),
      ],
    );
  }
}
