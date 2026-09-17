import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import 'wealth_home_screen.dart';

/// Man goc Quan ly tai san - CHI CON 1 man Home that su (WealthHomeScreen,
/// gom Chi tieu/Thu nhap/Dau tu thanh cac the danh muc), moi tinh nang khac
/// va Tin nhan deu mo popup (xem app_popup.dart) thay vi la tab rieng, nen
/// thanh Menu khong con nut Home. Ho so mo qua avatar tren AppTopBar cua
/// WealthHomeScreen, thoat khoi Wealth qua app-switcher.
class WealthShell extends ConsumerStatefulWidget {
  const WealthShell({super.key});

  @override
  ConsumerState<WealthShell> createState() => _WealthShellState();
}

class _WealthShellState extends ConsumerState<WealthShell> {
  @override
  void dispose() {
    // Xem giai thich trong FitnessShell.dispose(): tra ve Hoc Tieng Anh khi
    // man nay bi go (ke ca thoat qua nut back he thong), khong chi qua
    // app-switcher, de currentAppSectionProvider khong bi "ket" o Wealth.
    if (ref.read(currentAppSectionProvider) == AppSection.wealth) {
      ref.read(currentAppSectionProvider.notifier).state =
          AppSection.learnEnglish;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Da BO thanh Menu duoi theo ban thiet ke lai: thanh do truoc day chi
    // chua pill nhac, gio pill nhac nam ngay trong than trang (cuoi man
    // Home, xem wealth_home_screen.dart) nen man hinh ket thuc tu nhien sau
    // widget nhac thay vi co 1 thanh co dinh che mat noi dung.
    return const Scaffold(
      backgroundColor: AppColors.bgTop,
      body: WealthHomeScreen(),
    );
  }
}
