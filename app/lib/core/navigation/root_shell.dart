import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../notifications/chat_push.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../../features/fitness/presentation/fitness_home_screen.dart';
import '../../features/music_player/presentation/center_media_button.dart';
import '../../features/music_player/presentation/home_screen.dart';
import '../../features/today/data/gymtalk_reminders.dart';
import '../../features/today/presentation/progress_screen.dart';
import '../../features/today/presentation/today_screen.dart';
import '../../features/update/presentation/update_dialog.dart';
import 'root_tabs.dart';

/// Man goc GymTalk: 4 tab Hom nay | Tap | Hoc | Tien do (xem root_tabs.dart)
/// + thanh nhac o tren thanh tab. Tab "Tap" la FitnessHomeScreen va tab "Hoc"
/// la HomeScreen tieng Anh - truoc day la 2 "app con" rieng (Fitness duoc
/// push len bang FitnessShell qua AppSwitcherPill). Moi tinh nang con van mo
/// dang POPUP (app_popup.dart) nhu cu. Wealth van la app rieng (WealthShell).
///
/// IndexedStack giu nguyen trang thai tung tab khi chuyen qua lai.
class RootShell extends ConsumerStatefulWidget {
  const RootShell({super.key});

  @override
  ConsumerState<RootShell> createState() => _RootShellState();
}

class _RootShellState extends ConsumerState<RootShell>
    with WidgetsBindingObserver {
  Timer? _updateCheckTimer;
  Timer? _presenceTimer;

  /// Thoi diem bat dau o tab Tap (null khi dang o tab khac/app o nen) - thay
  /// cho viec FitnessShell.dispose() ghi thoi gian dung Fitness truoc day.
  DateTime? _trainSince;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showUpdateDialogIfAvailable(context);
    });
    // Ngoai kiem tra luc mo app/resume, kiem tra dinh ky moi 15 phut - phong
    // truong hop nguoi dung khong bao gio dua app xuong nen (didChange
    // AppLifecycleState.resumed se khong bao gio ban), ho van thay thong
    // bao neu ban build moi duoc publish trong luc dang dung app.
    _updateCheckTimer = Timer.periodic(const Duration(minutes: 15), (_) {
      if (mounted) showUpdateDialogIfAvailable(context);
    });
    // "Dang online" duoc tinh o server bang last_seen_at trong vong 90s gan
    // nhat (xem my_friends() trong migration) - can heartbeat thuong xuyen
    // hon khoang do de ban be thay minh dang online chinh xac trong luc app
    // dang mo o foreground.
    ref.read(socialRepositoryProvider).updatePresence().catchError((_) {});
    _presenceTimer = Timer.periodic(const Duration(seconds: 45), (_) {
      ref.read(socialRepositoryProvider).updatePresence().catchError((_) {});
    });
    ChatPush.instance.registerIfSignedInAndNotYet();
    // Gui not buoi tap con ket trong hang doi tu lan truoc (xem
    // workout_outbox.dart) - truoc day chi chay khi mo FitnessShell.
    ref.read(workoutOutboxProvider).flush();
    // Dong bo SRS + 3 vong theo tai khoan (migration 0074).
    ref.read(gymTalkSyncProvider)
      ..start()
      ..syncNow();
    GymTalkReminders.instance.rescheduleFromPrefs(ref);
    GymTalkReminders.instance.openTodayRequests.addListener(_openToday);
    final initialTab = ref.read(rootTabProvider);
    if (initialTab == RootTab.train) _trainSince = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _syncSection(ref.read(rootTabProvider));
    });
  }

  /// Dong bo khu vuc (theme/nen/mac dinh Lap ke hoach) theo tab - tru khi
  /// dang mo Wealth (WealthShell phu len tren, tu quan khu vuc cua no).
  void _syncSection(RootTab tab) {
    final sectionNotifier = ref.read(currentAppSectionProvider.notifier);
    if (sectionNotifier.state == AppSection.wealth) return;
    sectionNotifier.state = tab.section;
  }

  /// Cham thong bao "nhac tap + hoc" -> tab Hom nay.
  void _openToday() {
    if (mounted) ref.read(rootTabProvider.notifier).state = RootTab.today;
  }

  void _flushTrainTime() {
    final since = _trainSince;
    if (since == null) return;
    _trainSince = null;
    final seconds = DateTime.now().difference(since).inSeconds;
    if (seconds > 0) {
      ref
          .read(statsRepositoryProvider)
          .addPracticeSeconds(seconds, source: 'fitness')
          .catchError((_) {});
    }
  }

  void _onTabChanged(RootTab? previous, RootTab next) {
    if (previous == RootTab.train && next != RootTab.train) _flushTrainTime();
    if (next == RootTab.train && previous != RootTab.train) {
      _trainSince = DateTime.now();
      ref.read(workoutOutboxProvider).flush();
    }
    _syncSection(next);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _updateCheckTimer?.cancel();
    _presenceTimer?.cancel();
    GymTalkReminders.instance.openTodayRequests.removeListener(_openToday);
    _flushTrainTime();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Truoc day chi kiem tra cap nhat 1 lan luc app moi mo - neu ban build
    // moi duoc publish trong luc app dang mo san, nguoi dung khong bao gio
    // thay thong bao tru khi tat han app roi mo lai. Kiem tra lai moi khi
    // app quay lai foreground.
    if (state == AppLifecycleState.resumed && mounted) {
      showUpdateDialogIfAvailable(context);
      ref.read(socialRepositoryProvider).updatePresence().catchError((_) {});
      if (ref.read(rootTabProvider) == RootTab.train) {
        _trainSince ??= DateTime.now();
      }
      ref.read(gymTalkSyncProvider).syncNow();
    } else if (state == AppLifecycleState.paused) {
      // App xuong nen khi dang o tab Tap -> ghi phan thoi gian da dung.
      _flushTrainTime();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<RootTab>(rootTabProvider, _onTabChanged);
    // WealthShell dong lai tu tra khu vuc ve Hoc tieng Anh - neu dang o tab
    // Tap thi dua ve lai Fitness cho dung theme.
    ref.listen<AppSection>(currentAppSectionProvider, (previous, next) {
      if (previous == AppSection.wealth && next != AppSection.wealth) {
        _syncSection(ref.read(rootTabProvider));
      }
    });
    final tab = ref.watch(rootTabProvider);
    // Popup thong bao tin nhan moi kieu Messenger - da chuyen len _AuthGate
    // trong main.dart (xem giai thich o do) de hoat dong o CA 3 app.
    return Scaffold(
      backgroundColor: AppColors.bgTop,
      body: IndexedStack(
        index: tab.index,
        children: const [
          TodayScreen(),
          FitnessHomeScreen(),
          HomeScreen(),
          ProgressScreen(),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
            child: CenterMediaButton(accentColor: tab.accent),
          ),
          const GymTalkTabBar(),
        ],
      ),
    );
  }
}
