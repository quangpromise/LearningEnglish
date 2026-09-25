import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Trang thai 1 dap an: chua chon / dung / sai / mo di / da chon (khong
/// hien dung sai - dung cho Placement Test).
enum PathOptionState { idle, right, wrong, dimmed, selected }

PathOptionState pathOptionState(int option, int answer, int? picked) {
  if (picked == null) return PathOptionState.idle;
  if (option == answer) return PathOptionState.right;
  if (option == picked) return PathOptionState.wrong;
  return PathOptionState.dimmed;
}

/// Nut dap an cao 56dp, bam 1 tay duoc.
class PathOptionButton extends StatelessWidget {
  const PathOptionButton({
    super.key,
    required this.label,
    required this.state,
    required this.onTap,
  });

  final String label;
  final PathOptionState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = switch (state) {
      PathOptionState.right => AppColors.teal,
      PathOptionState.wrong => AppColors.pink,
      PathOptionState.selected => AppColors.blue,
      PathOptionState.idle || PathOptionState.dimmed => AppColors.glassBorder,
    };
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: state == PathOptionState.idle ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: color.withValues(
              alpha: state == PathOptionState.idle ? 0.08 : 0.18,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color, width: 1.4),
          ),
          child: Opacity(
            opacity: state == PathOptionState.dimmed ? 0.5 : 1,
            child: Text(label, style: AppTextStyles.body(size: 16)),
          ),
        ),
      ),
    );
  }
}
