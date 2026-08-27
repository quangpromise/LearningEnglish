import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../data/quiz_data.dart';
import 'leaderboard_screen.dart';

class QuizResultScreen extends StatelessWidget {
  const QuizResultScreen({
    super.key,
    required this.riddles,
    required this.results,
  });
  final List<Riddle> riddles;
  final List<bool> results;

  @override
  Widget build(BuildContext context) {
    final correct = results.where((r) => r).length;
    final xp = correct * 15;
    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        child: Column(
          children: [
            Text(
              'HOÀN THÀNH THỬ THÁCH',
              style: AppTextStyles.muted(size: 11)
                  .copyWith(color: const Color(0xFFC9A8FF), letterSpacing: 1),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: 140,
              height: 140,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: results.isEmpty ? 0 : correct / results.length,
                    strokeWidth: 10,
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    color: AppColors.blue,
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$correct/${results.length}',
                        style: AppTextStyles.heading(size: 26),
                      ),
                      Text('câu đúng', style: AppTextStyles.muted(size: 11)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
              decoration: BoxDecoration(
                gradient: AppColors.accentGradient,
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blue.withValues(alpha: 0.45),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.bolt_rounded, color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    '+$xp XP',
                    style: AppTextStyles.body(
                      weight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: ListView.separated(
                itemCount: riddles.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final ok = i < results.length && results[i];
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.glassFill,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: (ok ? AppColors.teal : AppColors.pink)
                                .withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            ok ? Icons.check_rounded : Icons.close_rounded,
                            size: 13,
                            color: ok ? AppColors.teal : AppColors.pink,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            riddles[i].en,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.body(
                              size: 12,
                              weight: FontWeight.w600,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: PillButton(
                    label: 'Làm lại',
                    filled: false,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PillButton(
                    label: 'Xem bảng xếp hạng',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => LeaderboardScreen(myXp: xp),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
