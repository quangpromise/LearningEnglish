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
/// [routeName] dat ten cho route popup de [topRouteObserver] nhan ra man nay
/// dang mo (mac dinh popup KHONG co ten - xem nav_keys.dart). Chi truyen khi
/// co cho khac thuc su can biet man nay dang mo hay khong, vd man Luyen phat
/// am (nut AI Voice Chat phai biet de tranh gianh mic).
Future<T?> openAppPopup<T>(
  BuildContext context,
  Widget child, {
  bool dismissible = true,
  String? routeName,
}) {
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: dismissible,
    enableDrag: dismissible,
    routeSettings: routeName == null ? null : RouteSettings(name: routeName),
    builder: (_) => FractionallySizedBox(
      heightFactor: 0.94,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: child,
      ),
    ),
  );
}

/// Dong HET cac man popup dang chong len nhau roi mo [child] nhu 1 popup moi
/// nam TRUC TIEP tren man Home.
///
/// Dung cho cac buoc "ket thuc 1 luong": vd chon tu vung (popup Tu vung theo
/// chu de) -> popup "Hoc {n} tu hom nay" -> bam "Bat dau hoc" mo man Quiz.
/// Neu chi chong them popup Quiz len tren, dong Quiz xong nguoi dung lai roi
/// ve 2 popup cu da xong viec; pop het truoc khi mo Quiz thi dong Quiz la ve
/// thang Home.
///
/// Cach nhan ra "den Home thi dung": moi popup deu la route KHONG co ten,
/// chi 3 man Home moi duoc dat ten (xem nav_keys.dart).
Future<T?> openAppPopupFromHome<T>(
  BuildContext context,
  Widget child, {
  bool dismissible = true,
  String? routeName,
}) {
  final navigator = Navigator.of(context, rootNavigator: true);
  navigator.popUntil((route) => route.isFirst || route.settings.name != null);
  // Dung navigator.context (khong phai [context]): sau popUntil, context cua
  // widget goi ham nay nam trong 1 route vua bi go khoi cay.
  return openAppPopup<T>(
    navigator.context,
    child,
    dismissible: dismissible,
    routeName: routeName,
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

/// Nut quay lai (<) dung chung - 57 man popup dang TU VE lai y het khoi nay
/// (vong tron 34x34, glassFill, vien glassBorder, icon chevron_left). Gom ve
/// 1 cho de sau nay doi kich thuoc/mau chi phai sua 1 lan.
class PopupBackButton extends StatelessWidget {
  const PopupBackButton({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onBack ?? () => Navigator.of(context).maybePop(),
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
    );
  }
}

/// Header cho man popup co nut QUAY LAI ben trai (khac [PopupHeader] dung nut
/// dong X ben phai) - dung cho man mo tu 1 man khac trong cung luong.
class PopupBackHeader extends StatelessWidget {
  const PopupBackHeader({
    super.key,
    required this.title,
    this.trailing,
    this.onBack,
  });

  final String title;
  final Widget? trailing;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        PopupBackButton(onBack: onBack),
        const SizedBox(width: 12),
        Expanded(child: Text(title, style: AppTextStyles.heading(size: 20))),
        ?trailing,
      ],
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
        // 20 (khong phai 18): phan lon man popup tu ve header rieng deu dung
        // heading(size: 20) - de PopupHeader o 18 khien 8 man dung no co tieu
        // de NHO HON han cac man con lai khi xem lien tiep.
        Expanded(child: Text(title, style: AppTextStyles.heading(size: 20))),
        if (trailing != null) ...[trailing!, const SizedBox(width: 10)],
        PopupCloseButton(onClose: onClose),
      ],
    );
  }
}
