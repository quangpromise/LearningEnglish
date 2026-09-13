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

/// Dieu huong "trong CUNG 1 popup" - dung khi 1 man DA duoc mo boi
/// [openAppPopup] (vd VocabularyTopicsScreen) can di sau hon trong CHINH
/// tinh nang do (vd bam 1 chu de -> xem tu vung chu de do) - PUSH 1 route
/// MOI len CUNG Navigator (moi "popup" thuc chat la 1 route
/// ModalBottomSheetRoute tren CUNG 1 Navigator goc, khong phai overlay
/// rieng) thay vi mo THEM 1 [openAppPopup] khac (se tao cam giac sai la "2
/// lop popup chong len nhau", vi ModalBottomSheetRoute moi luon truot dot
/// ngot tu duoi len + phu them 1 lop backdrop toi ngay ca khi route cu da
/// la 1 popup roi).
///
/// Giu NGUYEN khung 94% chieu cao + bo goc tren giong het [openAppPopup] de
/// nhin nhu van dang o trong "chiec the" ban dau, chi doi hieu ung chuyen
/// canh sang TRUOT NGANG (tu phai sang, kieu "di toi 1 buoc" thay vi "mo 1
/// thu moi") - back (`Navigator.of(context).maybePop()`) hoat dong y het
/// binh thuong, khong can doi gi o man duoc push.
///
/// CHI dung cho dieu huong NOI BO trong 1 tinh nang (drill-down) - nhay
/// SANG tinh nang khac hoan toan (vd tu Tu vung nhay sang Ho so) van nen
/// dung [openAppPopup] nhu cu, vi do la 1 diem den doc lap, khong phai
/// "buoc tiep theo" cua cung 1 luong.
Future<T?> pushWithinPopup<T>(BuildContext context, Widget child) {
  return Navigator.of(context).push<T>(
    PageRouteBuilder<T>(
      transitionDuration: const Duration(milliseconds: 260),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, _, _) => FractionallySizedBox(
        heightFactor: 0.94,
        alignment: Alignment.bottomCenter,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: child,
        ),
      ),
      transitionsBuilder: (_, animation, _, pageChild) => SlideTransition(
        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
        child: pageChild,
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
