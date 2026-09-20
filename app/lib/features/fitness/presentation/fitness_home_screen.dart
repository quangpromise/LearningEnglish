import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/navigation/app_popup.dart';
import '../../../core/navigation/app_top_bar.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../social/presentation/conversations_screen.dart';
import '../../wealth/presentation/service_expiry_banner.dart';
import '../data/program_model.dart';
import 'community_screen.dart';
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
import 'fitness_statistics_screen.dart';
import 'sleep_screen.dart';

/// Trang chu cua khu vuc Fitness - dung theo anh thiet ke
/// `docs/design/fitness-redesign/_ref.jpg` (ban do kich thuoc/mau:
/// TOKENS.md cung thu muc, ban dung lai bang HTML de doi chieu: Main.dc.html).
///
/// Bo cuc tu tren xuong: thanh dau (avatar + loi chao + pill Fitness) ->
/// the lon "Hanh trinh suc khoe" -> 4 chi so -> ke hoach hom nay -> hang
/// giao an cuon ngang -> tien ich nhanh. Thanh nhac o day man do
/// [FitnessShell] gan vao (MiniAppBottomNav), khong thuoc file nay.
///
/// Nen o day la DEN DAC (#050505) chu khong dung [ScreenBackground] nhu cac
/// man Fitness khac: anh thiet ke khong co anh nen phong gym mo phia sau,
/// va chinh no lam cac the #111111 khong con tach duoc khoi nen.
class FitnessHomeScreen extends ConsumerWidget {
  const FitnessHomeScreen({super.key});

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
              14,
              FitnessHome.pagePadding,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTopBar(
                  accentColor: FitnessHome.red,
                  greeting: ref.tr('home_greeting'),
                  // Hai nut tron ben phai: Tin nhan (co cham bao khi chua
                  // doc) roi den Cai dat. Dung DUNG icon tin nhan cua 2 khu
                  // vuc kia (Hoc Tieng Anh/Wealth) - xem AppTopBar - de ca
                  // 3 app nhat quan, khong dung icon chuong nhu anh mau.
                  // Truyen qua [trailing] thay vi onMessagesTap de giu dung
                  // thu tu nay (AppTopBar ve nut Tin nhan SAU trailing).
                  trailing: Row(
                    children: [
                      GestureDetector(
                        onTap: () =>
                            openAppPopup(context, const ConversationsScreen()),
                        child: TopBarIconChip(
                          icon: Icons.sms_outlined,
                          dotColor: FitnessHome.red,
                          badge: unread > 0,
                        ),
                      ),
                      const SizedBox(width: 9),
                      GestureDetector(
                        // Toan bo cai dat cua app nam trong man Ho so (doi
                        // ngon ngu, giong doc, thong bao, dang xuat...) -
                        // khong co man "Cai dat" rieng nao khac.
                        onTap: () =>
                            openAppPopup(context, const ProfileScreen()),
                        child: const TopBarIconChip(
                          icon: Icons.settings_outlined,
                          dotColor: FitnessHome.red,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 8),
                    children: [
                      const ServiceExpiryBanner(section: AppSection.fitness),
                      FitnessHeroCard(
                        kicker: ref.tr('fitness_hero_kicker'),
                        title: ref.tr('fitness_hero_title'),
                        subtitle: ref.tr('fitness_hero_subtitle'),
                        ctaLabel: ref.tr('fitness_hero_cta'),
                        onStart: () => _openTodayWorkout(context, ref),
                      ),
                      const SizedBox(height: 13),
                      FitnessStatsRow(
                        onTap: () => openAppPopup(
                          context,
                          const FitnessStatisticsScreen(),
                        ),
                      ),
                      const SizedBox(height: 13),
                      FitnessTodayCard(
                        onOpenPlan: () => _openTodayWorkout(context, ref),
                        quote: _quote(ref),
                        onQuoteTap: () => openAppPopup(
                          context,
                          const FitnessStatisticsScreen(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      FitnessSectionHeader(
                        title: ref.tr('fitness_home_category_workout'),
                        actionLabel: ref.tr('fitness_see_all'),
                        onAction: () =>
                            openAppPopup(context, const ProgramsListScreen()),
                      ),
                      const SizedBox(height: 10),
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
                      const SizedBox(height: 10),
                      FitnessQuickActions(
                        actions: [
                          FitnessQuickAction(
                            icon: Icons.calendar_month_rounded,
                            label: ref.tr('fitness_quick_schedule'),
                            onTap: () => openAppPopup(
                              context,
                              const ProgramsListScreen(),
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
                            onTap: () =>
                                openAppPopup(context, const SleepScreen()),
                          ),
                          FitnessQuickAction(
                            icon: Icons.monitor_heart_rounded,
                            label: ref.tr('fitness_heart_rate_title'),
                            onTap: () async {
                              await openAppPopup(
                                context,
                                const HeartRateScreen(),
                              );
                              // Lan do moi lam thay doi the "Nhip tim" o
                              // Trang chu - nap lai lich su sau khi dong.
                              ref.invalidate(heartRateHistoryProvider);
                            },
                          ),
                          // Hai tien ich duoi day nam ngoai 4 o dau tien cua
                          // anh thiet ke - giu lai (cuon ngang de thay) vi
                          // chung la loi vao DUY NHAT cua 2 tinh nang da co.
                          FitnessQuickAction(
                            icon: Icons.fitness_center_rounded,
                            label: ref.tr('fitness_library_title'),
                            onTap: () => openAppPopup(
                              context,
                              const MuscleGroupCategoriesScreen(),
                            ),
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
              ],
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
  /// nguoi dung (dung chung bo quy tac voi [FitnessDashboardSection]): lau
  /// khong tap -> nhac quay lai, dang co chuoi -> khen, con lai -> cau dong
  /// luc chung doi theo ngay.
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
