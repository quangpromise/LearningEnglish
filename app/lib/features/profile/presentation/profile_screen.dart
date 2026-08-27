import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hồ sơ', style: AppTextStyles.heading(size: 16)),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: AppColors.accentGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text('Q', style: AppTextStyles.heading(size: 22)),
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Quang Hứa', style: AppTextStyles.heading(size: 18)),
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.amber.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.local_fire_department_rounded,
                            size: 14,
                            color: AppColors.amber,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '12 ngày liên tiếp',
                            style: TextStyle(
                              color: AppColors.amber,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: const [
                      _StatCard(
                        icon: Icons.menu_book_rounded,
                        color: AppColors.blue,
                        value: '248',
                        label: 'Từ đã học',
                      ),
                      _StatCard(
                        icon: Icons.music_note_rounded,
                        color: AppColors.purple,
                        value: '32',
                        label: 'Bài hát hoàn thành',
                      ),
                      _StatCard(
                        icon: Icons.mic_rounded,
                        color: AppColors.teal,
                        value: '88%',
                        label: 'Điểm phát âm TB',
                      ),
                      _StatCard(
                        icon: Icons.timer_outlined,
                        color: AppColors.amber,
                        value: '14h 20p',
                        label: 'Thời gian luyện tập',
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  GlowBox(
                    borderRadius: 22,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'HOẠT ĐỘNG TUẦN NÀY',
                          style: AppTextStyles.muted(size: 11)
                              .copyWith(letterSpacing: 0.6),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          height: 70,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              _Bar(h: 30, d: 'T2'),
                              _Bar(h: 48, d: 'T3'),
                              _Bar(h: 14, d: 'T4', low: true),
                              _Bar(h: 60, d: 'T5'),
                              _Bar(h: 38, d: 'T6'),
                              _Bar(h: 52, d: 'T7'),
                              _Bar(h: 22, d: 'CN'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return GlowBox(
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const Spacer(),
          Text(value, style: AppTextStyles.heading(size: 19)),
          Text(label, style: AppTextStyles.muted(size: 11)),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.h, required this.d, this.low = false});
  final double h;
  final String d;
  final bool low;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 14,
          height: h,
          decoration: BoxDecoration(
            gradient: low
                ? null
                : const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.purple, AppColors.blue],
                  ),
            color: low ? AppColors.glassFill : null,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(8),
              bottom: Radius.circular(4),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(d, style: AppTextStyles.muted(size: 10)),
      ],
    );
  }
}
