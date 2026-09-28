import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';

/// 4 tab cua man goc GymTalk (xem root_shell.dart). Ho so van mo tu avatar
/// tren GtTopBar (ProfileScreen duoc thiet ke dang popup).
enum RootTab {
  today,
  train,
  learn,
  progress;

  /// Khu vuc (theme/nen/mac dinh Lap ke hoach...) tuong ung voi tab.
  AppSection get section =>
      this == RootTab.train ? AppSection.fitness : AppSection.learnEnglish;

  String get labelKey => switch (this) {
    RootTab.today => 'tab_today',
    RootTab.train => 'tab_train',
    RootTab.learn => 'tab_learn',
    RootTab.progress => 'tab_progress',
  };

  IconData get icon => switch (this) {
    RootTab.today => Icons.wb_sunny_outlined,
    RootTab.train => Icons.fitness_center_rounded,
    RootTab.learn => Icons.school_outlined,
    RootTab.progress => Icons.insights_rounded,
  };

  IconData get selectedIcon => switch (this) {
    RootTab.today => Icons.wb_sunny_rounded,
    RootTab.train => Icons.fitness_center_rounded,
    RootTab.learn => Icons.school_rounded,
    RootTab.progress => Icons.insights_rounded,
  };
}

/// Tab dang chon. Doi tab qua provider nay (AppSwitcherPill, khoi phuc sau
/// dang nhap...) - RootShell nghe thay doi de dong bo khu vuc + ghi thoi
/// gian dung Fitness.
final rootTabProvider = StateProvider<RootTab>((ref) => RootTab.today);
