import 'package:flutter/material.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';

/// Mau "chrome" (nut Them viec, pill ngay chon, FAB...) doi theo app dang mo
/// - CHI anh huong chrome, KHONG anh huong 4 mau trang thai co dinh cua
/// PlannerTaskStatus (xem planner_models.dart). Giong dung cach
/// ai_fab_overlay.dart da lam cho FAB AI Voice Chat.
(Gradient, Color) plannerAccentFor(AppSection section) => switch (section) {
  AppSection.fitness => (
    AppColors.fitnessAccentGradient,
    AppColors.fitnessAccent,
  ),
  AppSection.wealth => (AppColors.wealthAccentGradient, AppColors.wealthAccent),
  AppSection.learnEnglish => (AppColors.accentGradient, AppColors.blue),
};

IconData plannerSectionIcon(AppSection section) => switch (section) {
  AppSection.learnEnglish => Icons.menu_book_rounded,
  AppSection.fitness => Icons.fitness_center_rounded,
  AppSection.wealth => Icons.account_balance_wallet_rounded,
};

Color plannerSectionTint(AppSection section) => switch (section) {
  AppSection.learnEnglish => AppColors.blue,
  AppSection.fitness => AppColors.fitnessAccent,
  AppSection.wealth => AppColors.wealthAccent,
};
