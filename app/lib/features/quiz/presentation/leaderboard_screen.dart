import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class _Player {
  const _Player(this.name, this.xp, {this.isMe = false});
  final String name;
  final int xp;
  final bool isMe;
}

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key, this.myXp = 0});
  final int myXp;

  @override
  Widget build(BuildContext context) {
    final players = <_Player>[
      const _Player('Lan Phương', 2540),
      const _Player('Minh Anh', 2180),
      const _Player('Đức Huy', 1960),
      const _Player('Thảo Vy', 1720),
      const _Player('Khánh Duy', 1540),
      const _Player('Ngọc Hà', 1390),
      _Player('Quang (Bạn)', 1120 + myXp, isMe: true),
      const _Player('Phúc An', 1180),
    ]..sort((a, b) => b.xp.compareTo(a.xp));

    final myRank = players.indexWhere((p) => p.isMe) + 1;
    final me = players.firstWhere((p) => p.isMe);

    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.glassFill,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: const Icon(
                      Icons.chevron_left_rounded,
                      size: 18,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Text('Bảng xếp hạng', style: AppTextStyles.heading(size: 16)),
                const SizedBox(width: 36),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: const [
                _Tab('Tuần này', active: true),
                SizedBox(width: 8),
                _Tab('Tháng này'),
                SizedBox(width: 8),
                _Tab('Mọi lúc'),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: players.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final p = players[i];
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: p.isMe
                          ? AppColors.blue.withValues(alpha: 0.16)
                          : AppColors.glassFill,
                      border: Border.all(
                        color: p.isMe
                            ? AppColors.blue.withValues(alpha: 0.5)
                            : AppColors.glassBorder,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          child: Text(
                            '${i + 1}',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.muted(size: 13),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: AppColors.accentGradient,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              p.name[0],
                              style: AppTextStyles.heading(size: 13),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            p.name,
                            style: AppTextStyles.body(weight: FontWeight.w700),
                          ),
                        ),
                        Text(
                          '${p.xp} XP',
                          style: const TextStyle(
                            color: Color(0xFF9DB4FF),
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                gradient: AppColors.accentGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blue.withValues(alpha: 0.5),
                    blurRadius: 40,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Text(
                    '#$myRank',
                    style: AppTextStyles.heading(
                      size: 20,
                      weight: FontWeight.w700,
                    ).copyWith(color: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Hạng của bạn tuần này',
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          '${me.xp} XP',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
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

class _Tab extends StatelessWidget {
  const _Tab(this.label, {this.active = false});
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: active ? AppColors.accentGradient : null,
        color: active ? null : AppColors.glassFill,
        border: active ? null : Border.all(color: AppColors.glassBorder),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? Colors.white : AppColors.textMuted,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}
