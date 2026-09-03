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
  });

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
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${ref.tr('home_greeting')}, $displayName',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.heading(size: 17),
              ),
              const SizedBox(height: 3),
              const AppSwitcherPill(),
            ],
          ),
        ),
        ?trailing,
      ],
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
