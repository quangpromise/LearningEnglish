import 'package:flutter/material.dart';

import '../../features/fitness/presentation/programs_list_screen.dart';
import '../../features/planner/presentation/planner_links.dart';
import '../../features/wealth/presentation/recurring_services_screen.dart';
import '../notifications/daily_quiz_notifications.dart';
import 'app_popup.dart';
import 'nav_keys.dart';

/// Dang ky nut "Mo" cho viec do 3 mini-app tao trong Lap ke hoach (xem
/// [registerPlannerSourceOpener]) - dat o core/ (noi DUY NHAT biet ca planner
/// lan cac mini-app) de planner khong phai import nguoc feature nao. Goi 1
/// lan trong main().
void registerPlannerSourceOpeners() {
  registerPlannerSourceOpener(PlannerSourceKinds.fitnessProgram, (source) {
    final context = rootNavigatorKey.currentContext;
    final programId = int.tryParse(source.refId);
    if (context == null || programId == null) return;
    openAppPopup(context, ProgramsListScreen(initialProgramId: programId));
  });
  registerPlannerSourceOpener(
    PlannerSourceKinds.englishVocabReview,
    (_) => DailyQuizNotifications.instance.openQuiz(),
  );
  registerPlannerSourceOpener(PlannerSourceKinds.wealthServiceRenewal, (_) {
    final context = rootNavigatorKey.currentContext;
    if (context == null) return;
    Navigator.of(
      context,
      rootNavigator: true,
    ).push(MaterialPageRoute(builder: (_) => const RecurringServicesScreen()));
  });
}
