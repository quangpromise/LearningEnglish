import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import 'planner_providers.dart';

/// Chup lai danh sach viec, chay [action], roi hien snackbar co nut "Hoan
/// tac" (4 giay) tra ve dung trang thai truoc do - dung cho hoan thanh, xoa,
/// keo-tha, doi ngay, dua ve Inbox (docs/research-planner-app-ux.md §7.3).
///
/// [messenger] nen la ScaffoldMessenger RIENG cua man Lap ke hoach (xem
/// PlannerScreen) - messenger goc cua app nam khuat sau popup 94%.
Future<void> runPlannerActionWithUndo({
  required WidgetRef ref,
  required ScaffoldMessengerState? messenger,
  required String messageKey,
  required Future<void> Function() action,
}) async {
  final notifier = ref.read(plannerTasksProvider.notifier);
  final message = ref.tr(messageKey);
  final undoLabel = ref.tr('planner_undo');
  final snapshot = notifier.snapshot();
  await action();
  if (messenger == null || !messenger.mounted) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: undoLabel,
          onPressed: () => notifier.restoreSnapshot(snapshot),
        ),
      ),
    );
}
