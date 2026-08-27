import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../settings/presentation/change_password_sheet.dart';
import '../../settings/presentation/voice_settings_sheet.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF12172E),
        title: const Text(
          'Đăng xuất?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Bạn có chắc muốn đăng xuất khỏi tài khoản này?',
          style: AppTextStyles.muted(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Huỷ'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Đăng xuất',
              style: TextStyle(color: AppColors.pink),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authRepositoryProvider).signOut();
    }
  }

  Future<void> _confirmResetStats(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF12172E),
        title: const Text(
          'Đặt lại thống kê?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Toàn bộ số liệu (từ đã học, bài hoàn thành, điểm phát âm, thời gian luyện tập) sẽ về 0. Không thể hoàn tác.',
          style: AppTextStyles.muted(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Huỷ'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Đặt lại',
              style: TextStyle(color: AppColors.pink),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(statsRepositoryProvider).resetStats();
      ref.invalidate(myStatsProvider);
    }
  }

  Future<void> _pickAndUploadAvatar(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    final ext = picked.path.split('.').last.toLowerCase();
    try {
      await ref.read(profileRepositoryProvider).uploadAvatar(bytes, ext);
      ref.invalidate(myProfileProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Không tải được avatar: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(myStatsProvider);
    final profileAsync = ref.watch(myProfileProvider);
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
                GestureDetector(
                  onTap: () => _pickAndUploadAvatar(context, ref),
                  child: Stack(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: AppColors.accentGradient,
                          shape: BoxShape.circle,
                          image: profileAsync.valueOrNull?.avatarUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(
                                    profileAsync.valueOrNull!.avatarUrl!,
                                  ),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: profileAsync.valueOrNull?.avatarUrl == null
                            ? Center(
                                child: Text(
                                  profileAsync.valueOrNull?.initial ?? '?',
                                  style: AppTextStyles.heading(size: 22),
                                ),
                              )
                            : null,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppColors.bgMid,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.bgTop,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            size: 11,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profileAsync.valueOrNull?.nameLabel ?? '...',
                      style: AppTextStyles.heading(size: 18),
                    ),
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
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.local_fire_department_rounded,
                            size: 14,
                            color: AppColors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${statsAsync.valueOrNull?.streakDays ?? 0} ngày liên tiếp',
                            style: const TextStyle(
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
                  statsAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: CircularProgressIndicator(color: AppColors.blue),
                      ),
                    ),
                    error: (e, _) => Text(
                      'Không tải được thống kê: $e',
                      style: AppTextStyles.muted(),
                    ),
                    data: (stats) => GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: [
                        _StatCard(
                          icon: Icons.menu_book_rounded,
                          color: AppColors.blue,
                          value: '${stats.wordsLearned}',
                          label: 'Từ đã học',
                        ),
                        _StatCard(
                          icon: Icons.music_note_rounded,
                          color: AppColors.purple,
                          value: '${stats.songsCompleted}',
                          label: 'Bài hát hoàn thành',
                        ),
                        _StatCard(
                          icon: Icons.mic_rounded,
                          color: AppColors.teal,
                          value: stats.avgPronunciationScore > 0
                              ? '${stats.avgPronunciationScore}%'
                              : '—',
                          label: 'Điểm phát âm TB',
                        ),
                        _StatCard(
                          icon: Icons.timer_outlined,
                          color: AppColors.amber,
                          value: stats.practiceTimeLabel,
                          label: 'Thời gian luyện tập',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () => showVoiceSettingsSheet(context),
                    child: GlowBox(
                      borderRadius: 20,
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: AppColors.blue.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.record_voice_over_rounded,
                              size: 16,
                              color: AppColors.blue,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Giọng đọc tiếng Anh',
                                  style: AppTextStyles.body(
                                    weight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  'Chọn giọng phát âm mẫu bạn thích',
                                  style: AppTextStyles.muted(size: 11),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.textMuted,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () => showChangePasswordSheet(context),
                    child: GlowBox(
                      borderRadius: 20,
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: AppColors.purple.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.lock_reset_rounded,
                              size: 16,
                              color: AppColors.purple,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Đổi mật khẩu',
                                  style: AppTextStyles.body(
                                    weight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  'Chỉ áp dụng cho tài khoản đăng ký email',
                                  style: AppTextStyles.muted(size: 11),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.textMuted,
                          ),
                        ],
                      ),
                    ),
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
                          child: statsAsync.when(
                            loading: () => const SizedBox.shrink(),
                            error: (_, _) => const SizedBox.shrink(),
                            data: (stats) {
                              final week = stats.weeklyActivity;
                              if (week.isEmpty) {
                                return Center(
                                  child: Text(
                                    'Chưa có hoạt động nào tuần này',
                                    style: AppTextStyles.muted(size: 11),
                                  ),
                                );
                              }
                              // Quy đổi giây -> chiều cao thanh: tỉ lệ theo
                              // ngày luyện tập nhiều nhất trong tuần, thanh
                              // tối thiểu 14px để vẫn thấy được ngày 0 giây.
                              final maxSeconds = week
                                  .map((d) => d.seconds)
                                  .fold(0, (a, b) => a > b ? a : b);
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: week.map((d) {
                                  final ratio = maxSeconds > 0
                                      ? d.seconds / maxSeconds
                                      : 0.0;
                                  final height = 14.0 + ratio * 46.0;
                                  return _Bar(
                                    h: height,
                                    d: d.weekdayLabel,
                                    low: d.seconds == 0,
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () => _confirmResetStats(context, ref),
                    child: GlowBox(
                      borderRadius: 20,
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: AppColors.amber.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.restart_alt_rounded,
                              size: 16,
                              color: AppColors.amber,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              'Đặt lại thống kê',
                              style: AppTextStyles.body(
                                weight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () => _confirmSignOut(context, ref),
                    child: GlowBox(
                      borderRadius: 20,
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: AppColors.pink.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.logout_rounded,
                              size: 16,
                              color: AppColors.pink,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              'Đăng xuất',
                              style: AppTextStyles.body(
                                weight: FontWeight.w800,
                                color: AppColors.pink,
                              ),
                            ),
                          ),
                        ],
                      ),
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
