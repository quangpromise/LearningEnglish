import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/audio/audio_service_diagnostics.dart';
import '../../../core/config/env.dart';
import '../../../core/diagnostics/crash_diagnostics.dart';
import '../../../core/i18n/app_language.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../core/navigation/app_popup.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../attribution/presentation/attribution_screen.dart';
import '../../settings/presentation/change_password_sheet.dart';
import '../../settings/presentation/voice_settings_sheet.dart';
import '../../planner/presentation/planner_links.dart';
import '../../stats/data/stats_repository.dart';
import '../../update/data/update_checker.dart';
import '../../vocabulary/data/daily_words_repository.dart';
import '../../vocabulary/presentation/daily_quiz_popup_screen.dart';
import '../../vocabulary/presentation/daily_words_controller.dart';
import '../../vocabulary/presentation/learned_words_popup.dart';
import '../../vocabulary/presentation/vocabulary_topics_screen.dart';
import '../../wealth/data/recurring_service_model.dart';
import '../../wealth/presentation/add_service_sheet.dart';
import '../../wealth/presentation/renew_service_sheet.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({
    super.key,
    this.initialTab = 0,
    this.highlightDailyWords = false,
  });

  /// Tab mo san khi man hien ra (0 = Settings, 1 = Activity) - dung khi mo
  /// TU nut "Hoc hom nay" o VocabularyTopicDetailScreen (xem
  /// highlightDailyWords) de nhay thang toi tab Activity thay vi Settings
  /// mac dinh.
  final int initialTab;

  /// true = vua bam "Hoc (x) tu hom nay" xong, can TU DONG cuon toi
  /// [DailyWordsSection] VA hien huong dan ngon tay tung buoc (so phut
  /// nhac lai -> Quiz/Writing -> nut "Bat dau hoc") - xem
  /// DailyWordsSectionState.
  final bool highlightDailyWords;

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // Tab Settings o vi tri 0 (trai), Activity o vi tri 1 (phai) - mac dinh
  // mo o Settings theo yeu cau, TRU KHI duoc mo voi initialTab rieng (xem
  // widget.initialTab).
  late int _tab = widget.initialTab;

  // Gan vao DailyWordsSection de tu dong cuon toi dung vi tri cua no khi
  // widget.highlightDailyWords (xem initState) - Scrollable.ensureVisible
  // hoat dong voi BAT KY Scrollable to nao boc no (ListView cua
  // _buildActivityTab), khong can tu quan ly ScrollController rieng.
  final _dailyWordsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (widget.highlightDailyWords) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = _dailyWordsKey.currentContext;
        if (ctx == null) return;
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutCubic,
          alignment: 0.05,
        );
      });
    }
  }

  /// Kiem tra cap nhat thu cong, hien chi tiet TUNG BUOC thay vi im lang -
  /// dung khi popup tu dong (showUpdateDialogIfAvailable, chay ngam luc mo
  /// app) khong hien ra du nguoi dung nghi da co ban moi, de tu chan doan
  /// (rate-limit GitHub API, mang loi, hay that su da la ban moi nhat).
  Future<void> _checkForUpdateNow(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          const Center(child: CircularProgressIndicator(color: AppColors.blue)),
    );
    final result = await debugCheckForUpdate();
    if (!context.mounted) return;
    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF12172E),
        title: const Text(
          'Update check',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(result, style: AppTextStyles.muted()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF12172E),
        title: Text(
          ref.tr('profile_signout_title'),
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          ref.tr('profile_signout_body'),
          style: AppTextStyles.muted(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(ref.tr('common_cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              ref.tr('profile_sign_out'),
              style: const TextStyle(color: AppColors.pink),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      // Ghi nho dang o Fitness/Wealth NGAY TRUOC khi dang xuat (khong doi
      // sau) - de main.dart khoi phuc dung app nay khi dang nhap lai, thay
      // vi luon quay ve Hoc Tieng Anh (xem pendingRestoreAppSectionProvider).
      final section = ref.read(currentAppSectionProvider);
      if (section != AppSection.learnEnglish) {
        ref.read(pendingRestoreAppSectionProvider.notifier).state = section;
      }
      await ref.read(authRepositoryProvider).signOut();
      // Man Ho so nay la 1 route (bottom sheet) DUNG TREN Navigator goc cua
      // app - main.dart doi "home" tu RootShell sang SignInScreen ngay khi
      // signedIn=false, nhung route bottom sheet nay khong tu dong mat vi no
      // la 1 route rieng chong len tren, khong phai 1 phan cua subtree bi
      // thay the. Phai tu tay pop het ve goc, neu khong popup Ho so se con
      // hien de len tren man Dang nhap sau khi sign out.
      if (context.mounted) Navigator.of(context).popUntil((r) => r.isFirst);
    }
  }

  void _showLanguagePicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
        decoration: const BoxDecoration(
          color: Color(0xFF12172E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ref.tr('profile_language_title'),
              style: AppTextStyles.heading(size: 16),
            ),
            const SizedBox(height: 14),
            for (final lang in AppLanguage.values)
              Consumer(
                builder: (context, innerRef, _) {
                  final current = innerRef.watch(appLanguageProvider);
                  final active = current == lang;
                  return GestureDetector(
                    onTap: () {
                      innerRef
                          .read(appLanguageProvider.notifier)
                          .setLanguage(lang);
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.blue.withValues(alpha: 0.16)
                            : AppColors.glassFill,
                        border: Border.all(
                          color: active
                              ? AppColors.blue.withValues(alpha: 0.5)
                              : AppColors.glassBorder,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Text(lang.flag, style: const TextStyle(fontSize: 22)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              lang.label,
                              style: AppTextStyles.body(
                                weight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (active)
                            const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.blue,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${ref.tr('profile_avatar_error')} $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(myStatsProvider);
    final profileAsync = ref.watch(myProfileProvider);
    // Ho so dung CHUNG cho ca 3 "app" (Hoc Tieng Anh/Fitness/Assets
    // Management) - cac muc chi lien quan hoc tieng Anh (thong ke tu/bai
    // hat/diem phat am, chon giong doc, "Hoc 10 tu", Ghi cong) CHI hien khi
    // mo tu chinh Hoc Tieng Anh, tranh gay nham lan khi xem tu 2 app kia.
    final section = ref.watch(currentAppSectionProvider);
    final isFitness = section == AppSection.fitness;
    final isEnglishContext = section == AppSection.learnEnglish;
    // Chia 2 tab Hoat dong/Cai dat cho Hoc Tieng Anh va Fitness (co du lieu
    // hoat dong rieng de hien); Wealth chua co so lieu hoat dong nao nen
    // giu 1 danh sach don (khong tab) giong truoc.
    final showTabs = isEnglishContext || isFitness;
    // Mau nhan (avatar, tab dang chon...) doi theo "app" dang mo - dong bo
    // voi mau chu dao cua tung khu vuc thay vi luon co dinh 1 mau (giong
    // cach lam voi nut noi AI Voice Chat).
    final accentGradient = switch (section) {
      AppSection.fitness => AppColors.fitnessAccentGradient,
      AppSection.wealth => AppColors.wealthAccentGradient,
      AppSection.learnEnglish => AppColors.accentGradient,
    };
    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    ref.tr('profile_title'),
                    style: AppTextStyles.heading(size: 16),
                  ),
                ),
                // Man nay gio mo dang popup (bottom sheet) - can 1 nut dong
                // ro rang thay vi chi dua vao vuot xuong/nut back he thong.
                GestureDetector(
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.glassFill,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
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
                          gradient: accentGradient,
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profileAsync.valueOrNull?.nameLabel ?? '...',
                        style: AppTextStyles.heading(size: 18),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _HeaderPill(
                            icon: Icons.local_fire_department_rounded,
                            color: AppColors.amber,
                            label:
                                '${statsAsync.valueOrNull?.streakDays ?? 0} ${ref.tr('profile_streak_suffix')}',
                          ),
                          // "Dich vu phi" gon thanh 1 nut nho canh day streak
                          // (truoc la ca 1 khung lon dau tab Cai dat) - bam mo
                          // bottom sheet chua danh sach day du.
                          if (showTabs)
                            _HeaderPill(
                              icon: Icons.workspace_premium_rounded,
                              color: AppColors.wealthAccent,
                              label: ref.tr('profile_fee_services_title'),
                              onTap: () =>
                                  _showFeeServicesSheet(context, section),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (showTabs) ...[
              _ProfileTabBar(
                tab: _tab,
                onChanged: (i) => setState(() => _tab = i),
                accentGradient: accentGradient,
              ),
              const SizedBox(height: 14),
            ],
            Expanded(
              child: !showTabs
                  ? _buildSettingsTab(isEnglishContext: false)
                  : (_tab == 0
                        ? _buildSettingsTab(isEnglishContext: isEnglishContext)
                        : _buildActivityTab(
                            isEnglishContext: isEnglishContext,
                            isFitness: isFitness,
                          )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTab({
    required bool isEnglishContext,
    required bool isFitness,
  }) {
    final statsAsync = ref.watch(myStatsProvider);
    return ListView(
      children: [
        if (isEnglishContext) ...[
          statsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.blue),
              ),
            ),
            // Khong hien nguyen object exception ra man hinh -
            // fetchMyStats() da tu thu lai truong hop loi tam thoi
            // thuong gap (PGRST303 ngay sau khi cap nhat APK), neu
            // van that bai o day thi la loi that su, chi can 1 dong
            // thong bao ngan + nut thu lai thay vi chi tiet ky thuat.
            error: (e, _) => GestureDetector(
              onTap: () => ref.invalidate(myStatsProvider),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      ref.tr('profile_stats_error'),
                      style: AppTextStyles.muted(),
                    ),
                  ),
                  Text(
                    ref.tr('profile_stats_retry'),
                    style: AppTextStyles.body(
                      size: 12,
                      weight: FontWeight.w700,
                      color: AppColors.blue,
                    ),
                  ),
                ],
              ),
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
                  label: ref.tr('profile_words_learned'),
                  onTap: () => openAppPopup(context, const LearnedWordsPopup()),
                ),
                _StatCard(
                  icon: Icons.music_note_rounded,
                  color: AppColors.purple,
                  value: '${stats.songsCompleted}',
                  label: ref.tr('profile_songs_completed'),
                ),
                _StatCard(
                  icon: Icons.mic_rounded,
                  color: AppColors.teal,
                  value: stats.avgPronunciationScore > 0
                      ? '${stats.avgPronunciationScore}%'
                      : '—',
                  label: ref.tr('profile_avg_score'),
                ),
                _StatCard(
                  icon: Icons.timer_outlined,
                  color: AppColors.amber,
                  value: stats.practiceTimeLabel,
                  label: ref.tr('profile_practice_time'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],
        _WeeklyActivityCard(
          activityAsync: isEnglishContext
              ? ref.watch(myStatsProvider).whenData((s) => s.weeklyActivity)
              : ref.watch(fitnessWeeklyActivityProvider),
        ),
      ],
    );
  }

  /// Danh sach "Dich vu phi" day du, mo tu nut nho canh day streak.
  void _showFeeServicesSheet(BuildContext context, AppSection section) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        decoration: const BoxDecoration(
          color: Color(0xFF12172E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          child: _FeeServicesSection(section: section),
        ),
      ),
    );
  }

  Widget _buildSettingsTab({required bool isEnglishContext}) {
    return ListView(
      children: [
        if (isEnglishContext) ...[
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
                          ref.tr('profile_voice_title'),
                          style: AppTextStyles.body(weight: FontWeight.w800),
                        ),
                        Text(
                          ref.tr('profile_voice_subtitle'),
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
        ],
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
                        ref.tr('profile_change_password'),
                        style: AppTextStyles.body(weight: FontWeight.w800),
                      ),
                      Text(
                        ref.tr('profile_change_password_subtitle'),
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
          onTap: () => _showLanguagePicker(context, ref),
          child: GlowBox(
            borderRadius: 20,
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.teal.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    ref.watch(appLanguageProvider).flag,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ref.tr('profile_language_title'),
                        style: AppTextStyles.body(weight: FontWeight.w800),
                      ),
                      Text(
                        ref.tr('profile_language_subtitle'),
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
          onTap: () => _checkForUpdateNow(context),
          child: GlowBox(
            borderRadius: 20,
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.blue.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.system_update_rounded,
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
                        'Check for updates',
                        style: AppTextStyles.body(weight: FontWeight.w800),
                      ),
                      Text(
                        'See exactly why the update popup did or didn\'t show',
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
                    ref.tr('profile_sign_out'),
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
        const SizedBox(height: 14),
        // "Ghi cong" - nut chu nho gon ngay tren dong version (truoc la ca 1
        // khung lon trong danh sach cai dat).
        if (isEnglishContext) ...[
          Center(
            child: GestureDetector(
              onTap: () => openAppPopup(context, const AttributionScreen()),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.glassFill,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.copyright_rounded,
                      size: 11,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      ref.tr('attribution_menu_title'),
                      style: AppTextStyles.muted(size: 10.5),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
        ],
        Center(
          child: Consumer(
            builder: (context, innerRef, _) {
              final versionAsync = innerRef.watch(appVersionProvider);
              final version = versionAsync.valueOrNull ?? '';
              final buildLabel = Env.buildSha.isNotEmpty
                  ? 'commit ${Env.buildSha.substring(0, 7)}'
                  : 'local';
              return Text(
                version.isEmpty ? buildLabel : '$version · $buildLabel',
                style: AppTextStyles.muted(size: 10),
              );
            },
          ),
        ),
        // TAM THOI - chan doan tai sao thong bao "dang phat nhac"/
        // dieu khien tai nghe Bluetooth khong hoat dong tren 1 so
        // may (khong xem duoc log thiet bi that) - xoa dong nay
        // sau khi da xac dinh xong nguyen nhan goc.
        const SizedBox(height: 4),
        Center(
          child: Text(
            AudioServiceDiagnostics.succeeded == true
                ? 'Nhạc nền: OK'
                : 'Nhạc nền lỗi: ${AudioServiceDiagnostics.errorMessage ?? "chưa chạy"}',
            textAlign: TextAlign.center,
            style: AppTextStyles.muted(size: 9).copyWith(
              color: AudioServiceDiagnostics.succeeded == true
                  ? Colors.greenAccent
                  : AppColors.amber,
            ),
          ),
        ),
        // Chan doan loi "Ung dung da dung" khi app o nen/khoa man hinh.
        const CrashLogButton(),
        const BackgroundRunButton(),
      ],
    );
  }
}

/// Nhan tron nho o header Ho so (day streak, nut "Dich vu phi").
class _HeaderPill extends StatelessWidget {
  const _HeaderPill({
    required this.icon,
    required this.color,
    required this.label,
    this.onTap,
  });
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final pill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: onTap != null
            ? Border.all(color: color.withValues(alpha: 0.4))
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
          if (onTap != null) ...[
            const SizedBox(width: 2),
            Icon(Icons.chevron_right_rounded, size: 14, color: color),
          ],
        ],
      ),
    );
    if (onTap == null) return pill;
    return GestureDetector(onTap: onTap, child: pill);
  }
}

class _ProfileTabBar extends ConsumerWidget {
  const _ProfileTabBar({
    required this.tab,
    required this.onChanged,
    required this.accentGradient,
  });
  final int tab;
  final ValueChanged<int> onChanged;
  final Gradient accentGradient;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.06),
            Colors.white.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _ProfileTabButton(
              label: ref.tr('profile_tab_settings'),
              selected: tab == 0,
              accentGradient: accentGradient,
              onTap: () => onChanged(0),
            ),
          ),
          Expanded(
            child: _ProfileTabButton(
              label: ref.tr('profile_tab_activity'),
              selected: tab == 1,
              accentGradient: accentGradient,
              onTap: () => onChanged(1),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTabButton extends StatelessWidget {
  const _ProfileTabButton({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.accentGradient,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Gradient accentGradient;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: selected ? accentGradient : null,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textMuted,
            fontWeight: FontWeight.w800,
            fontSize: 12.5,
          ),
        ),
      ),
    );
  }
}

/// Bieu do "Hoat dong tuan nay" - dung chung cho ca man Hoc Tieng Anh
/// (nguon 'english', qua myStatsProvider) va Fitness (nguon 'fitness', qua
/// fitnessWeeklyActivityProvider) - nhan 1 `AsyncValue<List<DailyActivity>>`
/// da chuan hoa san thay vi tu doc provider, de dung duoc voi ca 2 nguon.
class _WeeklyActivityCard extends ConsumerWidget {
  const _WeeklyActivityCard({required this.activityAsync});
  final AsyncValue<List<DailyActivity>> activityAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlowBox(
      borderRadius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ref.tr('profile_weekly_activity'),
            style: AppTextStyles.muted(size: 11).copyWith(letterSpacing: 0.6),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 70,
            child: activityAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
              data: (week) {
                if (week.isEmpty) {
                  return Center(
                    child: Text(
                      ref.tr('profile_no_activity'),
                      style: AppTextStyles.muted(size: 11),
                    ),
                  );
                }
                // Quy đổi giây -> chiều cao thanh: tỉ lệ theo ngày luyện
                // tập nhiều nhất trong tuần, thanh tối thiểu 14px để vẫn
                // thấy được ngày 0 giây.
                final maxSeconds = week
                    .map((d) => d.seconds)
                    .fold(0, (a, b) => a > b ? a : b);
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: week.map((d) {
                    final ratio = maxSeconds > 0 ? d.seconds / maxSeconds : 0.0;
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
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
    this.onTap,
  });
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = GlowBox(
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
    if (onTap == null) return card;
    return GestureDetector(onTap: onTap, child: card);
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

/// "Dich vu phi" - danh sach dich vu tra phi da GAN cho dung app nay
/// (Fitness/Hoc Tieng Anh, xem recurring_service_model.dart), cho tao moi
/// truc tiep tu day (tu dong gan cho app nay - showAddServiceSheet). Quan
/// ly ĐẦY ĐỦ (sua/gia han/xoa/gan lai app khac) van chi lam duoc o man Dich
/// vu dinh ky rieng ben Quan ly tai san - o day chi la loi tat xem nhanh +
/// them moi.
class _FeeServicesSection extends ConsumerWidget {
  const _FeeServicesSection({required this.section});
  final AppSection section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(
      recurringServicesForSectionProvider(section),
    );
    return GlowBox(
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.wealthAccent.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  size: 16,
                  color: AppColors.wealthAccent,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  ref.tr('profile_fee_services_title'),
                  style: AppTextStyles.body(weight: FontWeight.w800),
                ),
              ),
              GestureDetector(
                onTap: () =>
                    showAddServiceSheet(context, presetAppSection: section),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: AppColors.wealthAccentGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          servicesAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.only(top: 14),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.wealthAccent,
                  ),
                ),
              ),
            ),
            error: (_, _) => const SizedBox.shrink(),
            data: (services) {
              if (services.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    ref.tr('profile_fee_services_empty'),
                    style: AppTextStyles.muted(size: 11.5),
                  ),
                );
              }
              return Column(
                children: [
                  const SizedBox(height: 10),
                  for (final s in services) ...[
                    _FeeServiceRow(service: s),
                    const SizedBox(height: 8),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FeeServiceRow extends ConsumerWidget {
  const _FeeServiceRow({required this.service});
  final RecurringService service;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daysLeft = service.daysLeft;
    final isUrgent = daysLeft <= service.reminderLeadDays;
    return GestureDetector(
      onTap: () => showRenewServiceSheet(context, service),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                service.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body(size: 12.5, weight: FontWeight.w700),
              ),
            ),
            Text(
              daysLeft < 0
                  ? ref.tr('wealth_service_overdue')
                  : '${ref.tr('wealth_service_days_left')}: $daysLeft',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: isUrgent ? AppColors.pink : AppColors.wealthAccent,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ngon tay nhap nhay (bounce len xuong) + bong bong chu ngan, dat NGAY
/// TREN 1 muc tieu can chi dan (khoang chon phut / nut "Bat dau hoc") qua
/// Positioned(top: -34...) boc no - xem DailyWordsSectionState.build().
class _TutorialFingerPointer extends StatefulWidget {
  const _TutorialFingerPointer({required this.label});
  final String label;

  @override
  State<_TutorialFingerPointer> createState() => _TutorialFingerPointerState();
}

/// Nhan ben TRAI + ngon tay CHI XUONG ben phai, cham mep tren khung/nut dang
/// can bam (xem _withFramePointer).
class _TutorialFingerPointerState extends State<_TutorialFingerPointer>
    with SingleTickerProviderStateMixin {
  late final _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(padding: const EdgeInsets.only(bottom: 14), child: _bubble()),
          AnimatedBuilder(
            animation: _ctrl,
            builder: (context, child) => Transform.translate(
              offset: Offset(0, _ctrl.value * 5),
              child: child,
            ),
            // touch_app xoay 180 do = ngon tay chi xuong.
            child: const RotatedBox(
              quarterTurns: 2,
              child: Icon(
                Icons.touch_app_rounded,
                color: AppColors.blue,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bubble() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: AppColors.blue,
      borderRadius: BorderRadius.circular(999),
      boxShadow: [
        BoxShadow(color: AppColors.blue.withValues(alpha: 0.5), blurRadius: 10),
      ],
    ),
    child: Text(
      widget.label,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 11,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

const _kIntervalChoicesMinutes = [15, 30, 60, 90, 120];
const _kMinCustomIntervalMinutes = 1;

/// "Học {n} từ hôm nay" - hien danh sach tu da chon (o Vocabulary hoac luu
/// tu khi tra cuu, khong gioi han so tu), cho chon so phut nhac lai + cach
/// on (Quiz/Writing) roi bat/tat nhac. Sang ngay moi (DailyWordsState.
/// expired) chi con 2 nut "Ket thuc hoc"/"Hoc lai".
class DailyWordsSection extends ConsumerStatefulWidget {
  const DailyWordsSection({super.key, this.showTutorial = false});

  /// true = vua duoc mo TU nut "Hoc (x) tu hom nay" (xem ProfileScreen.
  /// highlightDailyWords) - hien huong dan ngon tay tung buoc theo dung
  /// thu tu con thieu: so phut nhac lai -> Quiz/Writing -> "Bat dau hoc".
  /// Moi ban tay tu bien mat ngay khi buoc do da chon xong; an het khi da
  /// bat nhac.
  final bool showTutorial;

  @override
  ConsumerState<DailyWordsSection> createState() => DailyWordsSectionState();
}

class DailyWordsSectionState extends ConsumerState<DailyWordsSection> {
  /// Hop thoai nhap so phut nhac lai TUY Y (toi thieu
  /// _kMinCustomIntervalMinutes) - dung cho cac moc khong co san trong danh
  /// sach chip dinh san (vd de test nhanh chi 1 phut). [currentValue] khac
  /// null se dien san vao o nhap (dang chon 1 gia tri tuy chinh tu truoc).
  Future<void> _pickCustomInterval(
    BuildContext context,
    int? currentValue,
  ) async {
    final controller = TextEditingController(
      text: currentValue == null ? '' : '$currentValue',
    );
    // "error" phai nam O NGOAI builder cua StatefulBuilder - neu khong, moi
    // lan setDialogState() goi lai builder se tu XOA error vua gan.
    String? error;
    final result = await showDialog<int>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          void trySubmit() {
            final value = int.tryParse(controller.text.trim());
            if (value == null || value < _kMinCustomIntervalMinutes) {
              setDialogState(
                () =>
                    error = ref.tr('profile_daily_words_custom_interval_error'),
              );
              return;
            }
            Navigator.of(context).pop(value);
          }

          return AlertDialog(
            backgroundColor: const Color(0xFF12172E),
            title: Text(
              ref.tr('profile_daily_words_custom_interval_title'),
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            content: TextField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: '$_kMinCustomIntervalMinutes',
                hintStyle: AppTextStyles.muted(),
                suffixText: ref.tr('profile_daily_words_minutes_suffix'),
                suffixStyle: AppTextStyles.muted(),
                errorText: error,
              ),
              onSubmitted: (_) => trySubmit(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(ref.tr('common_cancel')),
              ),
              TextButton(
                onPressed: trySubmit,
                child: Text(ref.tr('common_confirm')),
              ),
            ],
          );
        },
      ),
    );
    if (result == null) return;
    await ref
        .read(dailyWordsControllerProvider.notifier)
        .setIntervalMinutes(result);
  }

  /// "Ket thuc hoc" - ghi TOAN BO cac tu cua phien vao thong ke "Tu da hoc"
  /// (popup Words Learned, an khoi man Tu vung theo chu de) roi xoa danh
  /// sach + tat nhac.
  Future<void> _endLearning(DailyWordsState state) async {
    final repo = ref.read(statsRepositoryProvider);
    try {
      for (final w in state.words) {
        await repo.recordWordLearned(w.en);
      }
      ref.invalidate(myStatsProvider);
      ref.invalidate(learnedWordsProvider);
    } catch (_) {
      // Mang loi tam thoi - khong chan viec ket thuc phien, chi la cac tu do
      // chua kip ghi vao thong ke toan cuc lan nay.
    }
    await ref.read(dailyWordsControllerProvider.notifier).stop();
  }

  Future<void> _relearn(BuildContext context) async {
    final started = await ref
        .read(dailyWordsControllerProvider.notifier)
        .relearn();
    if (!started || !context.mounted) return;
    openAppPopup(context, const DailyQuizPopupScreen());
  }

  Future<void> _start(BuildContext context) async {
    await ref.read(dailyWordsControllerProvider.notifier).start();
    if (!context.mounted) return;
    openAppPopup(context, const DailyQuizPopupScreen());
  }

  /// Huong dan cho 1 KHUNG nhieu lua chon (vd luoi 4 cach on tap): vien sang
  /// bao quanh ca khung + ngon tay CHI XUONG cham mep tren khung, nhan dat ben
  /// phai (khong che tieu de muc ben trai). Khong chiem cho trong bo cuc.
  Widget _withFramePointer({
    required bool show,
    required String labelKey,
    required Widget child,
    double borderRadius = 20,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (show) ...[
          Positioned(
            left: -5,
            right: -5,
            top: -5,
            bottom: -5,
            child: IgnorePointer(
              child: Container(
                // CHI vien - khong boxShadow: bong cua 1 khung trong suot
                // se phu mau xanh len ca ben trong o.
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border.all(color: AppColors.blue, width: 1.6),
                ),
              ),
            ),
          ),
          Positioned(
            top: -44,
            right: 24,
            child: _TutorialFingerPointer(label: ref.tr(labelKey)),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dailyWordsControllerProvider);
    final notifier = ref.read(dailyWordsControllerProvider.notifier);
    final total = state.words.length;
    final learned = total - state.pending.length;
    // Huong dan ngon tay tung buoc (xem widget.showTutorial) - suy thang tu
    // state: buoc nao chua chon thi ban tay tro vao buoc do.
    final tutorial = widget.showTutorial && !state.active && !state.expired;
    final showIntervalPointer = tutorial && state.intervalMinutes == null;
    final showModePointer =
        tutorial && state.intervalMinutes != null && state.mode == null;
    final showStartPointer = tutorial && state.canStart;

    return GlowBox(
      borderRadius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.purple.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.checklist_rounded,
                  size: 16,
                  color: AppColors.purple,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  ref
                      .tr('profile_daily_words_title')
                      .replaceFirst('{n}', '$total'),
                  style: AppTextStyles.body(weight: FontWeight.w800),
                ),
              ),
            ],
          ),
          // Dua "On tu vung hom nay" vao Lap ke hoach (viec lap hang ngay,
          // tu tick Hoan thanh khi on het tu - xem planner_links.dart).
          if (total > 0) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => addVocabReviewToPlanner(ref),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.event_available_rounded,
                    size: 14,
                    color: AppColors.purple,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    ref.tr(
                      plannerHasSource(
                            ref,
                            PlannerSourceKinds.englishVocabReview,
                            'daily',
                          )
                          ? 'planner_in_plan'
                          : 'planner_add_to_plan',
                    ),
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.purple,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          if (total == 0) ...[
            Text(
              ref.tr('profile_daily_words_empty'),
              style: AppTextStyles.muted(size: 12),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: PillButton(
                label: ref.tr('profile_daily_words_select'),
                onTap: () =>
                    openAppPopup(context, const VocabularyTopicsScreen()),
              ),
            ),
          ] else ...[
            if (!state.expired) ...[
              Text(
                ref
                    .tr('profile_daily_words_progress')
                    .replaceFirst('{learned}', '$learned')
                    .replaceFirst('{total}', '$total'),
                style: AppTextStyles.muted(size: 12),
              ),
              const SizedBox(height: 10),
            ],
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final w in state.words)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          state.learnedTodayEnLower.contains(w.en.toLowerCase())
                          ? AppColors.teal.withValues(alpha: 0.16)
                          : AppColors.glassFill,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: Text(
                      w.en,
                      style: AppTextStyles.body(
                        size: 11.5,
                        weight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            if (state.expired) ...[
              Text(
                ref.tr('profile_daily_words_expired_hint'),
                style: AppTextStyles.muted(size: 11.5),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: PillButton(
                      label: ref.tr('profile_daily_words_stop'),
                      filled: false,
                      onTap: () => _endLearning(state),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PillButton(
                      label: ref.tr('profile_daily_words_relearn'),
                      onTap: () => _relearn(context),
                    ),
                  ),
                ],
              ),
            ] else ...[
              _sectionLabel('profile_daily_words_interval_label'),
              const SizedBox(height: 8),
              _withFramePointer(
                show: showIntervalPointer,
                labelKey: 'profile_daily_words_tutorial_pick_minutes',
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final m in _kIntervalChoicesMinutes)
                      _ChoiceChip(
                        label:
                            '$m ${ref.tr('profile_daily_words_minutes_suffix')}',
                        selected: state.intervalMinutes == m,
                        onTap: () => notifier.setIntervalMinutes(m),
                      ),
                    // Chip "Khac" - mo dialog nhap so phut TUY Y. Neu gia tri
                    // dang chon khong trung moc nao co san, chip nay TU hien
                    // chinh gia tri do va duoc to sang nhu da chon.
                    Builder(
                      builder: (context) {
                        final interval = state.intervalMinutes;
                        final isCustom =
                            interval != null &&
                            !_kIntervalChoicesMinutes.contains(interval);
                        return _ChoiceChip(
                          icon: Icons.edit_rounded,
                          label: isCustom
                              ? '$interval ${ref.tr('profile_daily_words_minutes_suffix')}'
                              : ref.tr('profile_daily_words_custom_interval'),
                          selected: isCustom,
                          onTap: () => _pickCustomInterval(
                            context,
                            isCustom ? interval : null,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _sectionLabel('profile_daily_words_mode_label'),
              const SizedBox(height: 8),
              _withFramePointer(
                show: showModePointer,
                labelKey: 'profile_daily_words_tutorial_pick_mode',
                // Luoi 2x2: Quiz/Writing o hang tren, Speaking/Random o hang
                // duoi - 4 chip tren 1 hang se bi chat chu o man hinh hep.
                child: Column(
                  children: [
                    Row(
                      children: [
                        _modeChip(
                          DailyStudyMode.quiz,
                          Icons.quiz_rounded,
                          'profile_daily_words_mode_quiz',
                        ),
                        const SizedBox(width: 8),
                        _modeChip(
                          DailyStudyMode.writing,
                          Icons.edit_note_rounded,
                          'profile_daily_words_mode_writing',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _modeChip(
                          DailyStudyMode.speaking,
                          Icons.mic_rounded,
                          'profile_daily_words_mode_speaking',
                        ),
                        const SizedBox(width: 8),
                        _modeChip(
                          DailyStudyMode.random,
                          Icons.shuffle_rounded,
                          'profile_daily_words_mode_random',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Luc dang huong dan buoc "Bat dau": noi rong khe de nhan +
              // ngon tay chi xuong nam GIUA khung cach on va nut, khong de len
              // khung cach on phia tren.
              SizedBox(height: showStartPointer ? 44 : 14),
              _withFramePointer(
                show: showStartPointer,
                labelKey: 'profile_daily_words_tutorial_start',
                borderRadius: 999,
                child: SizedBox(
                  width: double.infinity,
                  child: state.active
                      ? PillButton(
                          label: ref.tr('profile_daily_words_stop'),
                          filled: false,
                          onTap: () => _endLearning(state),
                        )
                      : PillButton(
                          label: ref.tr('profile_daily_words_start'),
                          // Chi bam duoc khi da chon DU so phut + cach on
                          // (khong con gia tri mac dinh).
                          onTap: state.canStart ? () => _start(context) : null,
                        ),
                ),
              ),
              if (state.active) ...[
                const SizedBox(height: 8),
                Text(
                  ref.tr('profile_daily_words_active_hint'),
                  style: AppTextStyles.muted(size: 10.5),
                ),
              ],
            ],
          ],
        ],
      ),
    );
  }

  Widget _sectionLabel(String key) => Text(
    ref.tr(key),
    style: AppTextStyles.muted(size: 11).copyWith(letterSpacing: 0.4),
  );

  /// 1 o chon cach on (chiem nua hang trong luoi 2x2).
  Widget _modeChip(DailyStudyMode mode, IconData icon, String labelKey) {
    final selected = ref.watch(
      dailyWordsControllerProvider.select((s) => s.mode == mode),
    );
    return Expanded(
      child: _ChoiceChip(
        icon: icon,
        label: ref.tr(labelKey),
        selected: selected,
        expand: true,
        onTap: () =>
            ref.read(dailyWordsControllerProvider.notifier).setMode(mode),
      ),
    );
  }
}

/// Chip chon 1 gia tri (so phut nhac lai / cach on) - to sang khi dang chon.
class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.expand = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  /// true = noi dung can giua (dung khi chip chiem het 1 o Expanded).
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.blue : AppColors.textPrimary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.blue.withValues(alpha: 0.22)
              : AppColors.glassFill,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? AppColors.blue.withValues(alpha: 0.6)
                : AppColors.glassBorder,
          ),
        ),
        child: Row(
          mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 13,
                color: selected ? AppColors.blue : AppColors.textMuted,
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: AppTextStyles.body(
                size: 12,
                weight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mo popup "Hoc {n} tu hom nay".
///
/// Khoi nay TRUOC DAY nam trong than man Ho so; tu ban thiet ke lai man Home
/// no thanh the "Ky nang chinh" o Home va mo len dang popup tu day (xem
/// home_screen.dart). Giu ham o cung file voi [DailyWordsSection] vi khoi do
/// dung chung vai widget rieng tu cua man Ho so (_ChoiceChip,
/// _TutorialFingerPointer) nen khong tach ra file khac duoc.
Future<void> openDailyWordsPopup(
  BuildContext context, {
  bool showTutorial = false,
}) {
  return openAppPopup(context, _DailyWordsPopup(showTutorial: showTutorial));
}

class _DailyWordsPopup extends ConsumerWidget {
  const _DailyWordsPopup({this.showTutorial = false});
  final bool showTutorial;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = ref.watch(dailyWordsControllerProvider).words.length;
    return ScreenBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PopupHeader(
                title: ref
                    .tr('profile_daily_words_title')
                    .replaceFirst('{n}', '$total'),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: DailyWordsSection(showTutorial: showTutorial),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
