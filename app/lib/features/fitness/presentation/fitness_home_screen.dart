import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/navigation/app_popup.dart';
import '../../../core/navigation/app_switcher_sheet.dart';
import '../../../core/navigation/app_top_bar.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../social/presentation/conversations_screen.dart';
import '../../wealth/presentation/service_expiry_banner.dart';
import '../data/program_model.dart';
import 'community_screen.dart';
import 'fitness_statistics_screen.dart';
import 'heart_rate_screen.dart';
import 'home/fitness_hero_card.dart';
import 'home/fitness_home_theme.dart';
import 'home/fitness_program_carousel.dart';
import 'home/fitness_quick_actions.dart';
import 'home/fitness_stats_row.dart';
import 'home/fitness_today_card.dart';
import 'muscle_group_categories_screen.dart';
import 'nutrition_screen.dart';
import 'programs_list_screen.dart';
import 'sleep_screen.dart';

/// Trang chu cua khu vuc Fitness - dung theo anh thiet ke
/// `docs/design/fitness-redesign/_ref.jpg` (ban do kich thuoc/mau:
/// TOKENS.md cung thu muc).
///
/// **Man nay KHONG CUON.** Toan bo noi dung duoc dung tren 1 khung thiet ke
/// cao co dinh [_designHeight] roi thu/phong DONG DEU cho vua man hinh that
/// (xem [_FittedCanvas]). Nho vay moi thiet bi deu thay du 6 khoi - the lon,
/// 4 chi so, ke hoach hom nay, hang giao an, tien ich nhanh - ma khong phai
/// vuot, va ti le giua cac khoi luon dung nhu ban thiet ke thay vi "bom
/// phan cao con thua vao vai khoi" (kieu Expanded) lam bo cuc bien dang
/// khac nhau tung may.
///
/// Nen o day la DEN DAC (#050505) chu khong dung [ScreenBackground] nhu cac
/// man Fitness khac: anh thiet ke khong co anh nen phong gym mo phia sau,
/// va chinh no lam cac the #111111 khong con tach duoc khoi nen.
class FitnessHomeScreen extends ConsumerWidget {
  const FitnessHomeScreen({super.key});

  /// Chieu cao khung thiet ke (dp). Tong cac khoi ben duoi vua khit so nay;
  /// doi bat ky chieu cao nao trong [FitnessHome] thi phai cong tru lai day.
  static const _designHeight = 716.0;

  /// Chieu cao danh cho bang bao het han dich vu khi no co noi dung.
  static const _bannerHeight = 52.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Bang bao het han chi hien khi that su co dich vu sap het han - phai
    // biet TRUOC de cong them vao chieu cao khung thiet ke, neu khong no se
    // day cac khoi ben duoi tran ra ngoai man hinh.
    final hasExpiryBanner =
        ref
            .watch(recurringServicesForSectionProvider(AppSection.fitness))
            .valueOrNull
            ?.isNotEmpty ??
        false;

    return ColoredBox(
      color: FitnessHome.background,
      child: SafeArea(
        bottom: false,
        child: DefaultTextStyle.merge(
          style: const TextStyle(decoration: TextDecoration.none),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              FitnessHome.pagePadding,
              10,
              FitnessHome.pagePadding,
              0,
            ),
            child: _FittedCanvas(
              designHeight:
                  _designHeight + (hasExpiryBanner ? _bannerHeight : 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _FitnessHeader(),
                  const SizedBox(height: 12),
                  if (hasExpiryBanner)
                    const SizedBox(
                      height: _bannerHeight,
                      child: ServiceExpiryBanner(section: AppSection.fitness),
                    ),
                  FitnessHeroCard(
                    kicker: ref.tr('fitness_hero_kicker'),
                    title: ref.tr('fitness_hero_title'),
                    subtitle: ref.tr('fitness_hero_subtitle'),
                    ctaLabel: ref.tr('fitness_hero_cta'),
                    onStart: () => _openTodayWorkout(context, ref),
                  ),
                  const SizedBox(height: 10),
                  // Bam vao the chi so mo man Thong ke - day la loi vao DUY
                  // NHAT cua Thong ke; cau dong luc ben duoi khong con mo
                  // cung man do nua (truoc day trung lap).
                  FitnessStatsRow(
                    onTap: () =>
                        openAppPopup(context, const FitnessStatisticsScreen()),
                  ),
                  const SizedBox(height: 10),
                  FitnessTodayCard(
                    onOpenPlan: () => _openTodayWorkout(context, ref),
                    quote: _quote(ref),
                  ),
                  const SizedBox(height: 12),
                  FitnessSectionHeader(
                    title: ref.tr('fitness_home_category_workout'),
                    actionLabel: ref.tr('fitness_see_all'),
                    onAction: () =>
                        openAppPopup(context, const ProgramsListScreen()),
                  ),
                  const SizedBox(height: 8),
                  FitnessProgramCarousel(
                    onOpenProgram: (Program program) => openAppPopup(
                      context,
                      ProgramsListScreen(initialProgramId: program.id),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FitnessSectionHeader(
                    title: ref.tr('fitness_quick_actions_title'),
                  ),
                  const SizedBox(height: 8),
                  // 5 o vua khit 1 hang, KHONG cuon ngang - ban truoc giau
                  // mat 2 tinh nang (Thu vien bai tap, Cong dong) o phan
                  // phai vuot sang moi thay. O "Lich tap" cu da bo vi no mo
                  // dung man ma khu "Tap luyen" ngay ben tren da mo.
                  FitnessQuickActions(
                    actions: [
                      FitnessQuickAction(
                        icon: Icons.fitness_center_rounded,
                        label: ref.tr('fitness_quick_exercises'),
                        onTap: () => openAppPopup(
                          context,
                          const MuscleGroupCategoriesScreen(),
                        ),
                      ),
                      FitnessQuickAction(
                        icon: Icons.restaurant_rounded,
                        label: ref.tr('fitness_nutrition_title'),
                        onTap: () =>
                            openAppPopup(context, const NutritionScreen()),
                      ),
                      FitnessQuickAction(
                        icon: Icons.bedtime_rounded,
                        label: ref.tr('fitness_sleep_title'),
                        onTap: () => openAppPopup(context, const SleepScreen()),
                      ),
                      FitnessQuickAction(
                        icon: Icons.monitor_heart_rounded,
                        label: ref.tr('fitness_heart_rate_title'),
                        onTap: () async {
                          await openAppPopup(context, const HeartRateScreen());
                          // Lan do moi lam thay doi the "Nhip tim" o tren -
                          // nap lai lich su sau khi dong man do.
                          ref.invalidate(heartRateHistoryProvider);
                        },
                      ),
                      FitnessQuickAction(
                        icon: Icons.groups_rounded,
                        label: ref.tr('fitness_community_title'),
                        onTap: () =>
                            openAppPopup(context, const CommunityScreen()),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Mo dung buoi tap cua hom nay neu da chon giao an; chua chon thi mo
  /// danh sach giao an de chon truoc - khong co nhanh nao dan den man hinh
  /// trong.
  void _openTodayWorkout(BuildContext context, WidgetRef ref) {
    final plan = ref.read(todayWorkoutPlanProvider).valueOrNull;
    openAppPopup(
      context,
      ProgramsListScreen(initialProgramId: plan?.program.id),
    );
  }

  /// Cau o day the "Ke hoach hom nay" - chon theo TINH TRANG TAP THAT cua
  /// nguoi dung: lau khong tap -> nhac quay lai, dang co chuoi -> khen, con
  /// lai -> cau dong luc chung.
  String _quote(WidgetRef ref) {
    final stats = ref.watch(fitnessDashboardStatsProvider).valueOrNull;
    if (stats == null) return ref.tr('fitness_quote_default');
    if (stats.dailyVolumeLast7.every((v) => v <= 0)) {
      return ref.tr('fitness_dashboard_tip_come_back');
    }
    if (stats.streakDays >= 3) {
      return ref
          .tr('fitness_dashboard_tip_streak_praise')
          .replaceFirst('{n}', '${stats.streakDays}');
    }
    return ref.tr('fitness_quote_default');
  }
}

/// Dung [child] tren 1 khung logic cao dung [designHeight] roi thu/phong
/// dong deu ca 2 chieu cho vua o trong. Be rong khung duoc chia nguoc lai
/// cho he so thu phong, nen sau khi thu phong noi dung lap DUNG be rong
/// that cua man hinh - khong co le trai/phai thua.
class _FittedCanvas extends StatelessWidget {
  const _FittedCanvas({required this.designHeight, required this.child});

  final double designHeight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxHeight;
        if (!available.isFinite || available <= 0) return child;
        // Chan tren 1.18: tren may rat dai, phong to qua muc se lam chu to
        // bat thuong; de trong 1 khoang o day man (ngay tren thanh nhac)
        // trong hon la keo gian het co.
        final scale = (available / designHeight).clamp(0.6, 1.18);
        return ClipRect(
          child: Align(
            alignment: Alignment.topLeft,
            child: Transform.scale(
              scale: scale,
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: constraints.maxWidth / scale,
                height: designHeight,
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Thanh dau man Fitness - KHAC [AppTopBar] dung chung o 2 khu vuc kia o
/// 2 diem, deu de tiet kiem chieu cao cho bo cuc khong cuon:
///  - pill chuyen app ("Fitness") nam CHUNG HANG voi nut Tin nhan ben phai
///    (ban gon) thay vi chiem rieng 1 dong duoi ten.
///  - khong co nut Cai dat: moi cai dat deu nam trong man Ho so ma chinh
///    avatar ben trai da mo.
class _FitnessHeader extends ConsumerWidget {
  const _FitnessHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(myProfileProvider);
    final displayName = profile.when(
      data: (p) => p.nameLabel,
      loading: () => '...',
      error: (_, _) => '...',
    );
    final avatarUrl = profile.valueOrNull?.avatarUrl;
    final unread = ref.watch(unreadMessageCountProvider).valueOrNull ?? 0;

    return Row(
      children: [
        GestureDetector(
          onTap: () => openAppPopup(context, const ProfileScreen()),
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: FitnessHome.card,
              shape: BoxShape.circle,
              border: Border.all(color: FitnessHome.red, width: 1.4),
            ),
            clipBehavior: Clip.antiAlias,
            child: avatarUrl != null
                ? Image.network(avatarUrl, fit: BoxFit.cover)
                : const Icon(Icons.person_rounded, color: FitnessHome.red),
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                ref.tr('home_greeting'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: FitnessHome.bodySecondary(),
              ),
              Text(
                displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.heading(size: 18),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        const AppSwitcherPill(compact: true),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => openAppPopup(context, const ConversationsScreen()),
          child: TopBarIconChip(
            icon: Icons.sms_outlined,
            dotColor: FitnessHome.red,
            badge: unread > 0,
          ),
        ),
      ],
    );
  }
}
