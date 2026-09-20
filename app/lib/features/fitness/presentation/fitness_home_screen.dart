import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/navigation/app_popup.dart';
import '../../../core/navigation/app_top_bar.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
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
  static const _designHeight = 756.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadMessageCountProvider).valueOrNull ?? 0;

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
              designHeight: _designHeight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTopBar(
                    accentColor: FitnessHome.red,
                    greeting: ref.tr('home_greeting'),
                    // The bao han goi tap ("Gym Elite") thu gon thanh 1 nut
                    // tron canh nut Tin nhan thay vi 1 bang ngang chiem han
                    // 1 dong - man nay khong cuon nen tung dp deu quy.
                    trailing: const ServiceExpiryBanner(
                      section: AppSection.fitness,
                      compact: true,
                    ),
                    unreadCount: unread,
                    onMessagesTap: () =>
                        openAppPopup(context, const ConversationsScreen()),
                  ),
                  const SizedBox(height: 14),
                  FitnessHeroCard(
                    kicker: ref.tr('fitness_hero_kicker'),
                    title: ref.tr('fitness_hero_title'),
                    subtitle: ref.tr('fitness_hero_subtitle'),
                    ctaLabel: ref.tr('fitness_hero_cta'),
                    // "Bat dau tap" mo thang Thu vien bai tap - day la loi
                    // vao DUY NHAT cua thu vien sau khi bo o "Bai tap" o
                    // hang Tien ich nhanh. Buoi tap theo giao an van mo tu
                    // the "Ke hoach hom nay" ngay ben duoi.
                    onStart: () => openAppPopup(
                      context,
                      const MuscleGroupCategoriesScreen(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  FitnessStatsRow(
                    onOpenNutrition: () =>
                        openAppPopup(context, const NutritionScreen()),
                    onOpenStatistics: () =>
                        openAppPopup(context, const FitnessStatisticsScreen()),
                    onOpenHeartRate: () async {
                      await openAppPopup(context, const HeartRateScreen());
                      ref.invalidate(heartRateHistoryProvider);
                    },
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
                  // 4 o vua khit 1 hang, KHONG cuon ngang (ban dau tien
                  // cuon duoc nen o thu 5 tro di bi khuat han). Hai o da bo:
                  // "Lich tap" (mo dung man ma khu "Tap luyen" ngay tren da
                  // mo) va "Bai tap" (da chuyen thanh nut "Bat dau tap" o
                  // the lon dau man).
                  FitnessQuickActions(
                    actions: [
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
        // OverflowBox BAT BUOC o day: khung thiet ke thuong RONG/CAO hon o
        // chua no (truoc khi duoc thu nho lai), ma SizedBox thi luon bi cat
        // theo rang buoc cua cha. Thieu no, khung bi ep ve dung kich thuoc
        // man hinh roi con bi Transform thu nho them 1 lan nua - noi dung
        // lech han sang trai va phan duoi nam ngoai vung ve nen bam khong
        // an (da gap dung loi nay).
        return ClipRect(
          child: OverflowBox(
            alignment: Alignment.topLeft,
            minWidth: 0,
            minHeight: 0,
            maxWidth: double.infinity,
            maxHeight: double.infinity,
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
