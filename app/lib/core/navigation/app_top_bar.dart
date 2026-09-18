import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/profile/presentation/profile_screen.dart';
import '../i18n/app_strings.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import 'app_switcher_sheet.dart';

/// Thanh dau man hinh dung chung cho CA 3 "app" (Hoc Tieng Anh/Fitness/
/// Wealth) - avatar (bam mo popup ho so nhanh) + loi chao + pill chuyen doi
/// ung dung. Dat o man goc cua tung khu vuc (HomeScreen,
/// MuscleGroupCategoriesScreen, WealthShell) thay vi moi noi tu ve rieng 1
/// header "back + title" khac nhau - dam bao dong nhat va de sua 1 cho.
class AppTopBar extends ConsumerWidget {
  const AppTopBar({
    super.key,
    this.showBackButton = false,
    this.trailing,
    this.accentColor = AppColors.blue,
    this.onMessagesTap,
    this.unreadCount = 0,
    this.greeting,
  });

  /// Loi chao hien thanh DONG RIENG phia tren ten (vd "Chao buoi sang,").
  /// Null = giu bo cuc cu 1 dong `Xin chao + ten` - cac man chua doi sang
  /// thiet ke moi van hien y nhu truoc.
  final String? greeting;

  /// true cho man duoc mo qua Navigator.push (Fitness/Wealth) de co duong
  /// quay lai; false cho man la tab goc (Home) khong can nut back.
  final bool showBackButton;

  /// Nut phu o cuoi thanh (vd icon tu dien tren Home, icon danh sach tren
  /// Fitness) - de trong neu khu vuc khong can.
  final Widget? trailing;

  /// Mau vien avatar + nut xo xuong - moi khu vuc truyen mau nhan rieng cua
  /// minh (vd AppColors.fitnessAccent, AppColors.wealthAccent) de header
  /// dong bo voi phan con lai cua man hinh.
  final Color accentColor;

  /// Nut Tin nhan - chuyen tu thanh Menu duoi len headpage, dat NGAY SAU
  /// dong chu "Hello, ten" theo yeu cau. Null (mac dinh) an han nut nay -
  /// chi 3 man Home chinh (HomeScreen/FitnessHomeScreen/WealthHomeScreen)
  /// truyen vao, cac man popup dung AppTopBar voi showBackButton khong can.
  final VoidCallback? onMessagesTap;
  final int unreadCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(myProfileProvider);
    final displayName = profileAsync.when(
      data: (p) => p.nameLabel,
      loading: () => '...',
      error: (_, _) => '...',
    );
    final avatarUrl = profileAsync.valueOrNull?.avatarUrl;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (showBackButton) ...[
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: const _IconCircle(icon: Icons.chevron_left_rounded),
          ),
          const SizedBox(width: 12),
        ],
        GestureDetector(
          onTap: () => showModalBottomSheet(
            context: context,
            // useRootNavigator: true - AppTopBar nam ben trong 1 Navigator
            // LONG cua tung tab (xem root_shell.dart), phai neo popup vao
            // Navigator GOC de no phu duoc TOAN MAN HINH (de len ca thanh
            // Menu) thay vi bi gioi han trong vung than (body) cua tab do.
            useRootNavigator: true,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => FractionallySizedBox(
              heightFactor: 0.94,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                child: const ProfileScreen(),
              ),
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.glassFill,
                  shape: BoxShape.circle,
                  border: Border.fromBorderSide(
                    BorderSide(color: accentColor, width: 1.4),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: avatarUrl != null
                    ? Image.network(avatarUrl, fit: BoxFit.cover)
                    : Icon(Icons.person_rounded, color: accentColor),
              ),
              // Nut xo xuong canh avatar - chi de BAO HIEU co the bam (cung
              // 1 vung cham voi avatar, KHONG phai 1 GestureDetector rieng)
              // - bam vao avatar mo THANG man Ho so day du (khong qua popup
              // trung gian nua, theo yeu cau bam 1 phat toi luon thay vi
              // phai bam them "Xem tat ca cai dat").
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.bgTop, width: 2),
                  ),
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Loi chao tach thanh DONG RIENG phia tren ten (ban thiet ke
              // lai): dong nho mo o tren, ten to dam o duoi. Truoc day ca hai
              // nam chung 1 dong "Xin chao + ten" nen ten bi ep nho lai va
              // de bi cat khi ten dai.
              if (greeting != null)
                Text(
                  greeting!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body(
                    size: 12.5,
                    weight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              // Loi (khong phai dang tai) - cho bam vao TEN de tu tai lai,
              // vi FutureProvider.autoDispose se KET LUON o trang thai loi
              // (khong tu retry) neu khong ai invalidate no - truoc day
              // nguoi dung bi ket "..." vinh vien khong co cach nao tu
              // phuc hoi ngoai dong/mo lai app.
              Row(
                children: [
                  Flexible(
                    child: GestureDetector(
                      onTap: profileAsync.hasError
                          ? () => ref.invalidate(myProfileProvider)
                          : null,
                      child: Text(
                        greeting == null
                            ? '${ref.tr('home_greeting')}, $displayName'
                                  '${profileAsync.hasError ? ' ↻' : ''}'
                            : '$displayName'
                                  '${profileAsync.hasError ? ' ↻' : ''}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.heading(
                          size: greeting == null ? 17 : 21,
                        ),
                      ),
                    ),
                  ),
                  // Khi CO loi chao (bo cuc 2 dong moi), nut Tin nhan chuyen
                  // sang cum nut tron ben phai cung [trailing] cho gon; giu
                  // cach cu (icon ngay sau ten) cho cac man chua doi bo cuc.
                  if (onMessagesTap != null && greeting == null) ...[
                    const SizedBox(width: 8),
                    _MessagesIconButton(
                      unreadCount: unreadCount,
                      onTap: onMessagesTap!,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 3),
              const AppSwitcherPill(),
            ],
          ),
        ),
        ?trailing,
        if (onMessagesTap != null && greeting != null) ...[
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onMessagesTap,
            child: TopBarIconChip(
              icon: Icons.chat_bubble_outline_rounded,
              dotColor: accentColor,
              // Cham bao tin nhan nam NGAY TREN duong vien nut (do tu ban
              // thiet ke: tam cham cach tam nut dung bang ban kinh), khong
              // phai lo han ra ngoai goc nhu truoc.
              badge: unreadCount > 0,
            ),
          ),
        ],
      ],
    );
  }
}

/// Nut tron dung trong thanh dau man (la ban, tin nhan, cai dat...) - nen la
/// quang sang tron mo dan ra bien, KHONG co vien cung, theo ban thiet ke lai.
class TopBarIconChip extends StatelessWidget {
  const TopBarIconChip({
    super.key,
    required this.icon,
    this.badge = false,
    this.size = 38,
    this.dotColor = AppColors.blue,
  });

  final IconData icon;
  final bool badge;
  final double size;

  /// Mau cham bao - xanh cho Hoc Tieng Anh, vang cho Quan ly tai san (dung
  /// mau cham vang nhu anh thiet ke).
  final Color dotColor;

  @override
  Widget build(BuildContext context) {
    final dot = size / 2 - (size / 2) / 1.4142;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // Vien xam sang - do tu anh thiet ke: vong vien sang len
              // rgb(73,78,83) tren nen rgb(4,9,14), tuc trang o khoang 27%.
              // Truoc day nut khong co vien nao, chi 1 quang sang mo, nen
              // nhin "chim" han so voi nut tron ro vanh trong anh goc.
              border: Border.fromBorderSide(
                BorderSide(color: Colors.white.withValues(alpha: 0.27)),
              ),
              gradient: const RadialGradient(
                center: Alignment(-0.2, -0.3),
                radius: 0.75,
                colors: [
                  Color(0x1FBED6FF),
                  Color(0x0EA0C4F8),
                  Color(0x00A0C4F8),
                ],
                stops: [0.0, 0.62, 1.0],
              ),
            ),
            child: Icon(icon, size: size * 0.46, color: AppColors.textPrimary),
          ),
          if (badge)
            Positioned(
              right: dot,
              top: dot,
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: dotColor.withValues(alpha: 0.75),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MessagesIconButton extends StatelessWidget {
  const _MessagesIconButton({required this.onTap, this.unreadCount = 0});
  final VoidCallback onTap;
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(
            Icons.chat_bubble_rounded,
            size: 20,
            color: AppColors.textMuted,
          ),
          if (unreadCount > 0)
            Positioned(
              right: -5,
              top: -4,
              child: Container(
                padding: const EdgeInsets.all(3),
                constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                decoration: BoxDecoration(
                  color: AppColors.pink,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.bgTop, width: 2),
                ),
                child: Text(
                  unreadCount > 9 ? '9+' : '$unreadCount',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 7,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _IconCircle extends StatelessWidget {
  const _IconCircle({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: const BoxDecoration(
        color: AppColors.glassFill,
        shape: BoxShape.circle,
        border: Border.fromBorderSide(BorderSide(color: AppColors.glassBorder)),
      ),
      child: Icon(icon, size: 18, color: AppColors.textPrimary),
    );
  }
}
