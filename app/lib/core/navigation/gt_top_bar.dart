import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/english_path/data/english_path_providers.dart';
import '../../features/fitness/data/body_level.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/social/presentation/conversations_screen.dart';
import '../../features/today/data/daily_progress_store.dart';
import '../../features/today/data/gymtalk_rank.dart';
import '../../features/today/data/shell_presentation.dart';
import '../config/gymtalk_flags.dart';
import '../i18n/app_strings.dart';
import '../providers/app_providers.dart';
import '../theme/gt_tokens.dart';
import 'app_popup.dart';
import 'app_switcher_sheet.dart';

/// Top bar cua ban redesign (spec #70, ADR-0005): avatar co vong Daily
/// Rings + huy hieu bac GymTalk Rank, loi chao + ten, chip chuoi ngay, nut
/// apps (chi khi co Wealth) va tin nhan.
class GtTopBar extends ConsumerWidget {
  const GtTopBar({super.key, required this.greetingKey});

  /// Khoa chuoi loi chao theo buoi (vd greeting_morning).
  final String greetingKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.gt;
    final profile = ref.watch(myProfileProvider).valueOrNull;
    final name = profile?.nameLabel ?? '';
    final unread = ref.watch(unreadMessageCountProvider).valueOrNull ?? 0;
    final body = ref.watch(bodyStatsProvider).valueOrNull;
    final rank = body == null
        ? null
        : gymTalkRank(bodyLevelFor(body), ref.watch(englishLevelProvider));
    final store = DailyProgressStore.instance;
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 2, 6, 2),
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            GestureDetector(
              onTap: () => openAppPopup(context, const ProfileScreen()),
              child: ListenableBuilder(
                listenable: store,
                builder: (context, _) => _RingAvatar(
                  progress: dailyRingsProgress(store.today),
                  initials: nameInitials(name),
                  avatarUrl: profile?.avatarUrl,
                  rankBadge: rank == null ? null : '${rank.tier + 1}',
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${ref.tr(greetingKey)},',
                    style: GtText.body(t.tx2, size: 13),
                  ),
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GtText.topName(t.tx),
                  ),
                ],
              ),
            ),
            ListenableBuilder(
              listenable: store,
              builder: (context, _) => _StreakChip(days: store.bodyBrainStreak),
            ),
            if (kShowWealthSection) ...[
              const SizedBox(width: 8),
              const AppSwitcherPill(),
            ],
            const SizedBox(width: 8),
            _TopIconButton(
              icon: Icons.chat_bubble_outline_rounded,
              dot: unread > 0,
              label: ref.tr('top_messages'),
              onTap: () => openAppPopup(context, const ConversationsScreen()),
            ),
          ],
        ),
      ),
    );
  }
}

class _RingAvatar extends StatelessWidget {
  const _RingAvatar({
    required this.progress,
    required this.initials,
    required this.avatarUrl,
    required this.rankBadge,
  });

  final double progress;
  final String initials;
  final String? avatarUrl;
  final String? rankBadge;

  @override
  Widget build(BuildContext context) {
    final t = context.gt;
    final url = avatarUrl;
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CustomPaint(
            size: const Size(48, 48),
            painter: _RingPainter(progress, t.gold, t.s2),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: ClipOval(
                child: ColoredBox(
                  color: t.s1,
                  child: url != null
                      ? Image.network(
                          url,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Center(
                            child: Text(initials, style: GtText.rowTitle(t.tx)),
                          ),
                        )
                      : Center(
                          child: Text(initials, style: GtText.rowTitle(t.tx)),
                        ),
                ),
              ),
            ),
          ),
          if (rankBadge != null)
            Positioned(
              right: -4,
              bottom: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: t.gold,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: t.bg, width: 2),
                ),
                child: Text(
                  rankBadge!,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: t.onGold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.progress, this.color, this.track);
  final double progress;
  final Color color;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect.deflate(1.5), 0, 2 * pi, false, stroke..color = track);
    if (progress > 0) {
      canvas.drawArc(
        rect.deflate(1.5),
        -pi / 2,
        2 * pi * progress.clamp(0.0, 1.0),
        false,
        stroke..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color;
}

class _StreakChip extends StatelessWidget {
  const _StreakChip({required this.days});
  final int days;

  @override
  Widget build(BuildContext context) {
    final t = context.gt;
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: t.s1,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: t.bd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_fire_department_rounded, color: t.streak, size: 20),
          const SizedBox(width: 4),
          Text('$days', style: GtText.cardTitle(t.tx).copyWith(fontSize: 16)),
        ],
      ),
    );
  }
}

class _TopIconButton extends StatelessWidget {
  const _TopIconButton({
    required this.icon,
    required this.dot,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final bool dot;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.gt;
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: t.s1,
                  shape: BoxShape.circle,
                  border: Border.all(color: t.bd),
                ),
                child: Icon(icon, color: t.tx, size: 20),
              ),
              if (dot)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: t.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
