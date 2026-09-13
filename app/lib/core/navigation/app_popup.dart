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
/// [dismissible] = false cho cac man hinh KHONG duoc phep vuot xuong/bam ra
/// ngoai de dong ngoai y muon (vd man lam bai thi co tinh gio nhu
/// IeltsExamScreen/ToeicExamScreen mode "exam" - mat bai lam do neu vuot tay
/// lo) - man do phai tu co nut dong/xac nhan roi rieng va goi
/// `Navigator.of(context).maybePop()`/pop() tu ben trong.
///
/// Tra ve `Future<T?>` (gia tri duoc dua vao khi man con popup pop kem data
/// qua `Navigator.pop(context, value)`) de giu duoc cac luong dang can lay
/// ket qua tra ve giong `await Navigator.push<T>(...)` truoc day.
Future<T?> openAppPopup<T>(
  BuildContext context,
  Widget child, {
  bool dismissible = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: dismissible,
    enableDrag: dismissible,
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
  const PopupCloseButton({super.key, this.onClose});

  /// Ghi de hanh vi dong mac dinh (Navigator.maybePop) - dung khi man nay
  /// duoc gop chung 1 popup voi man cha (xem VocabularyTopicsScreen va cac
  /// man tuong tu) nen "dong" thuc chat la doi state noi bo ve buoc truoc,
  /// khong phai pop 1 route that su. Null (mac dinh) = giu hanh vi cu.
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClose ?? () => Navigator.of(context).maybePop(),
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
  const PopupHeader({
    super.key,
    required this.title,
    this.trailing,
    this.onClose,
  });
  final String title;
  final Widget? trailing;

  /// Xem [PopupCloseButton.onClose].
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: AppTextStyles.heading(size: 18))),
        if (trailing != null) ...[trailing!, const SizedBox(width: 10)],
        PopupCloseButton(onClose: onClose),
      ],
    );
  }
}
