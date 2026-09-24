import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// 1 vong muc tieu trong ngay (Tap/Hoc/Noi): vong tien do + icon o giua,
/// ten va so lieu ben duoi. Xong muc tieu -> icon doi sang dau tick.
class GoalRing extends StatelessWidget {
  const GoalRing({
    super.key,
    required this.ratio,
    required this.color,
    required this.icon,
    required this.label,
    required this.caption,
    this.size = 84,
  });

  final double ratio;
  final Color color;
  final IconData icon;
  final String label;
  final String caption;
  final double size;

  @override
  Widget build(BuildContext context) {
    final done = ratio >= 1;
    return Semantics(
      label: '$label $caption',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: Stack(
              fit: StackFit.expand,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: ratio.clamp(0.0, 1.0)),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) => CircularProgressIndicator(
                    value: value,
                    strokeWidth: 8,
                    strokeCap: StrokeCap.round,
                    color: color,
                    backgroundColor: color.withValues(alpha: 0.18),
                  ),
                ),
                Center(
                  child: Icon(
                    done ? Icons.check_rounded : icon,
                    size: size * 0.36,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: AppTextStyles.body(weight: FontWeight.w800)),
          Text(caption, style: AppTextStyles.muted(size: 12)),
        ],
      ),
    );
  }
}

/// Cham nho 3 mau cho 1 ngay trong lich su 7 ngay (man Tien do).
class MiniDayRings extends StatelessWidget {
  const MiniDayRings({
    super.key,
    required this.label,
    required this.train,
    required this.learn,
    required this.speak,
    this.highlight = false,
  });

  final String label;
  final bool train;
  final bool learn;
  final bool speak;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    Widget dot(bool on, Color color) => Container(
      width: 12,
      height: 12,
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: on ? color : Colors.transparent,
        border: Border.all(color: color.withValues(alpha: on ? 1 : 0.35)),
      ),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        dot(train, AppColors.fitnessAccent),
        dot(learn, AppColors.blue),
        dot(speak, AppColors.teal),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.body(
            size: 11,
            weight: highlight ? FontWeight.w800 : FontWeight.w600,
            color: highlight ? AppColors.textPrimary : AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
