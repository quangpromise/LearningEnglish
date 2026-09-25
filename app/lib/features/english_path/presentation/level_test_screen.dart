import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/navigation/app_popup.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/speaker_button.dart';
import '../data/cefr_level.dart';
import '../data/content_pack.dart';
import '../data/english_path_store.dart';
import '../data/level_test.dart';
import 'path_option_button.dart';
import 'unit_session_screen.dart';

/// XP thuong khi qua Level Test (spec #45).
const kLevelTestPassXp = 50;

/// Cau disclaimer bat buoc di kem Estimated Band (spec #45, nguyen van).
const kEstimatedBandDisclaimer =
    'Estimated band — for learning guidance only; not an official IELTS score.';

/// Level Test cuoi Stage: 20 cau, khong hien dung/sai tung cau; cham xong
/// moi hien ket qua, band (B1+) va nut on cau sai khi truot.
class LevelTestScreen extends ConsumerStatefulWidget {
  const LevelTestScreen({super.key, required this.pack, required this.stage});
  final ContentPack pack;
  final CefrLevel stage;

  @override
  ConsumerState<LevelTestScreen> createState() => _LevelTestScreenState();
}

class _LevelTestScreenState extends ConsumerState<LevelTestScreen> {
  late final List<PracticeItem> _items = buildLevelTest(
    widget.pack,
    widget.stage,
    Random(),
  );
  final List<int> _answers = [];
  int? _chosen;
  Timer? _next;
  LevelTestResult? _result;

  @override
  void dispose() {
    _next?.cancel();
    super.dispose();
  }

  void _pick(int option) {
    if (_chosen != null || _result != null) return;
    HapticFeedback.selectionClick();
    _answers.add(option);
    if (_answers.length == _items.length) _finish();
    setState(() => _chosen = option);
    _next = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _chosen = null);
    });
  }

  /// Cham + luu ngay khi tra loi cau cuoi (dong man cung khong mat ket qua).
  void _finish() {
    final result = scoreLevelTest(
      stage: widget.stage,
      items: _items,
      answers: _answers,
      takenAt: DateTime.now(),
    );
    _result = result;
    EnglishPathStore.instance.recordLevelTest(result);
    if (result.passed) {
      HapticFeedback.heavyImpact();
      // XP la diem tich luy tren server - loi mang/chua dang nhap thi bo qua.
      // myLearningXpProvider la autoDispose nen tu tai lai khi mo Tien do.
      unawaited(
        ref
            .read(learningXpRepositoryProvider)
            .addBonusXp(kLevelTestPassXp)
            .then<void>((_) {})
            .catchError((Object e) => debugPrint('Level Test XP failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final showQuestion =
        _result == null ||
        (_chosen != null && _answers.length == _items.length);
    final index = min(
      _answers.length - (_chosen != null ? 1 : 0),
      _items.length - 1,
    );
    return ScreenBackground(
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      ref
                          .tr('level_test_title')
                          .replaceFirst('{stage}', widget.stage.code),
                      style: AppTextStyles.heading(size: 20),
                    ),
                  ),
                  if (showQuestion)
                    Text(
                      '${index + 1}/${_items.length}',
                      style: AppTextStyles.muted(size: 14),
                    ),
                  SpeakerButton(
                    icon: Icons.close_rounded,
                    tapSize: 44,
                    color: AppColors.textPrimary,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: showQuestion
                    ? _question(_items[index])
                    : _LevelTestResultView(result: _result!, pack: widget.pack),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _question(PracticeItem item) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(ref.tr('path_meaning_prompt'), style: AppTextStyles.muted(size: 13)),
      const SizedBox(height: 8),
      Text(item.prompt, style: AppTextStyles.heading(size: 32)),
      const SizedBox(height: 20),
      for (var i = 0; i < item.options.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: PathOptionButton(
            label: item.options[i],
            state: _chosen == null
                ? PathOptionState.idle
                : (_chosen == i
                      ? PathOptionState.selected
                      : PathOptionState.dimmed),
            onTap: () => _pick(i),
          ),
        ),
    ],
  );
}

class _LevelTestResultView extends ConsumerWidget {
  const _LevelTestResultView({required this.result, required this.pack});
  final LevelTestResult result;
  final ContentPack pack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passed = result.passed;
    final band = result.estimatedBand;
    final percent = result.correct * 100 ~/ result.total;
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          Icon(
            passed ? Icons.emoji_events_rounded : Icons.fitness_center_rounded,
            size: 72,
            color: passed ? AppColors.amber : AppColors.blue,
          ),
          const SizedBox(height: 12),
          Text(
            ref.tr(passed ? 'level_test_passed' : 'level_test_failed'),
            textAlign: TextAlign.center,
            style: AppTextStyles.heading(size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            ref
                .tr('level_test_score')
                .replaceFirst('{c}', '${result.correct}')
                .replaceFirst('{t}', '${result.total}')
                .replaceFirst('{p}', '$percent'),
            textAlign: TextAlign.center,
            style: AppTextStyles.body(size: 16),
          ),
          if (passed) ...[
            const SizedBox(height: 6),
            Text(
              ref
                  .tr('level_test_passed_body')
                  .replaceFirst('{xp}', '$kLevelTestPassXp'),
              textAlign: TextAlign.center,
              style: AppTextStyles.muted(size: 14),
            ),
          ] else ...[
            const SizedBox(height: 6),
            Text(
              ref.tr('level_test_failed_body'),
              textAlign: TextAlign.center,
              style: AppTextStyles.muted(size: 14),
            ),
          ],
          if (band != null) ...[
            const SizedBox(height: 18),
            GlowBox(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Text(
                    ref.tr('level_test_band'),
                    style: AppTextStyles.muted(size: 13),
                  ),
                  Text(
                    band.toStringAsFixed(1),
                    style: AppTextStyles.heading(size: 34),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    kEstimatedBandDisclaimer,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.muted(size: 12),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 22),
          if (!passed && result.wrongItemIds.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: PillButton(
                label: ref.tr('level_test_review_wrong'),
                onTap: () => openAppPopup(
                  context,
                  reviewWrongSession(ref, pack, result),
                ),
              ),
            ),
          PillButton(
            label: ref.tr('path_back_to_path'),
            filled: passed,
            accentColor: AppColors.blue,
            onTap: () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
    );
  }
}

/// Phien on chi gom cac cau sai cua lan Level Test [result].
Widget reviewWrongSession(
  WidgetRef ref,
  ContentPack pack,
  LevelTestResult result,
) {
  final wrong = result.wrongItemIds.toSet();
  final units = [
    for (final s in pack.stages)
      if (s.stage == result.stage) ...s.units,
  ];
  return PracticeSessionScreen(
    title: ref.tr('level_test_review_title'),
    items: [
      for (final u in units)
        for (final i in u.items)
          if (wrong.contains(i.id)) i,
    ],
    words: [for (final u in units) ...u.words],
  );
}
