import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/tts/tutorial_voice.dart';
import '../../../core/utils/keep_screen_on.dart';
import '../../../core/widgets/speaker_button.dart';
import '../../pronunciation/data/pronunciation_scoring.dart';
import '../../srs/data/srs_store.dart';
import '../data/hands_free_drill.dart';
import '../data/speech_listener.dart';

/// "Luyen noi ranh tay": may doc cau tieng Anh, nguoi dung nhac lai, may
/// cham diem va noi phan hoi - khong can nhin/cham man hinh, dung khi chay
/// bo, dap xe hay giua cac hiep. Mo bang openAppPopup voi routeName
/// kPronunciationRouteName de nut AI Voice Chat biet mic dang ban.
class HandsFreeDrillScreen extends ConsumerStatefulWidget {
  const HandsFreeDrillScreen({super.key});

  @override
  ConsumerState<HandsFreeDrillScreen> createState() =>
      _HandsFreeDrillScreenState();
}

class _HandsFreeDrillScreenState extends ConsumerState<HandsFreeDrillScreen> {
  final SpeechListener _listener = SpeechListener();
  bool? _micAvailable;
  HandsFreeDrillController? _drill;
  String _heard = '';

  @override
  void initState() {
    super.initState();
    KeepScreenOn.enable();
    _init();
  }

  Future<void> _init() async {
    _listener.onPartial = (partial) {
      if (mounted) setState(() => _heard = partial);
    };
    final ok = await _listener.init();
    await SrsStore.instance.ensureLoaded();
    if (!mounted) return;
    final items = buildDrillItems(
      dueCards: SrsStore.instance.dueCards(DateTime.now()),
    );
    final drill = HandsFreeDrillController(
      items: items,
      // Cau vi du tu vung gym co san giong Kokoro (roi ve TTS neu thieu).
      speak: TutorialVoice.shared.speakAndWait,
      listen: _listenOnce,
      score: (target, heard) =>
          scorePronunciation(targetEn: target, recognized: heard).score,
      onScored: (score) {
        ref
            .read(statsRepositoryProvider)
            .recordPronunciationScore(score, source: 'hands_free')
            .catchError((_) {});
      },
    )..addListener(_onDrillChanged);
    setState(() {
      _micAvailable = ok;
      _drill = drill;
    });
  }

  void _onDrillChanged() {
    if (mounted) setState(() {});
  }

  /// Nghe toi da 8 giay, dung som khi im lang 2 giay.
  Future<String> _listenOnce() async {
    if (_micAvailable != true) return '';
    if (mounted) setState(() => _heard = '');
    return _listener.listenOnce();
  }

  // --- Dieu khien ----------------------------------------------------------

  void _stopAudio() {
    TutorialVoice.shared.stop();
    _listener.stop();
  }

  void _toggle() {
    final drill = _drill;
    if (drill == null) return;
    if (drill.running) {
      drill.pause();
      _stopAudio();
    } else {
      drill.start();
    }
  }

  void _skip() {
    final drill = _drill;
    if (drill == null) return;
    _stopAudio();
    drill.skip();
  }

  @override
  void dispose() {
    final drill = _drill;
    drill?.removeListener(_onDrillChanged);
    drill?.dispose();
    _stopAudio();
    _listener.dispose();
    KeepScreenOn.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final drill = _drill;
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
                  const Icon(Icons.headphones_rounded, color: AppColors.teal),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      ref.tr('hands_free_title'),
                      style: AppTextStyles.heading(size: 20),
                    ),
                  ),
                  SpeakerButton(
                    icon: Icons.close_rounded,
                    tapSize: 44,
                    color: AppColors.textPrimary,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                ],
              ),
              Text(
                ref.tr('hands_free_subtitle'),
                style: AppTextStyles.muted(size: 13),
              ),
              const SizedBox(height: 16),
              Expanded(child: _body(drill)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body(HandsFreeDrillController? drill) {
    if (drill == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.teal),
      );
    }
    if (_micAvailable != true) {
      return Center(
        child: Text(
          ref.tr('pron_no_mic'),
          textAlign: TextAlign.center,
          style: AppTextStyles.body(size: 15),
        ),
      );
    }
    final item = drill.current;
    final score = drill.lastScore;
    final (statusKey, statusColor) = switch (drill.phase) {
      DrillPhase.idle => ('hands_free_status_idle', AppColors.textMuted),
      DrillPhase.speaking => ('hands_free_status_speaking', AppColors.blue),
      DrillPhase.listening => ('hands_free_status_listening', AppColors.teal),
      DrillPhase.finished => ('hands_free_status_finished', AppColors.wealthUp),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LinearProgressIndicator(
          value: drill.items.isEmpty ? 0 : drill.index / drill.items.length,
          minHeight: 4,
          color: AppColors.teal,
          backgroundColor: AppColors.glassBorder,
        ),
        const SizedBox(height: 8),
        Text(
          '${drill.index.clamp(0, drill.items.length)}/${drill.items.length}'
          ' · ${ref.tr(statusKey)}',
          style: AppTextStyles.body(size: 14, color: statusColor),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            child: drill.phase == DrillPhase.finished || item == null
                ? Text(
                    ref
                        .tr('hands_free_done')
                        .replaceFirst('{passed}', '${drill.passed}')
                        .replaceFirst('{total}', '${drill.items.length}'),
                    style: AppTextStyles.heading(size: 22),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.text, style: AppTextStyles.heading(size: 28)),
                      const SizedBox(height: 6),
                      if (item.hint.isNotEmpty)
                        Text(item.hint, style: AppTextStyles.muted(size: 15)),
                      const SizedBox(height: 20),
                      if (_heard.isNotEmpty ||
                          drill.phase == DrillPhase.listening)
                        Text(
                          _heard.isEmpty ? '…' : '"$_heard"',
                          style: AppTextStyles.body(
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      if (score != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          ref
                              .tr('hands_free_score')
                              .replaceFirst('{score}', '$score'),
                          style: AppTextStyles.heading(size: 20).copyWith(
                            color: score >= kDrillPassScore
                                ? AppColors.teal
                                : AppColors.pink,
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _BigButton(
                icon: drill.running
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                label: ref.tr(
                  drill.running
                      ? 'hands_free_pause'
                      : drill.phase == DrillPhase.finished
                      ? 'hands_free_again'
                      : 'hands_free_start',
                ),
                onTap: _toggle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _BigButton(
                icon: Icons.skip_next_rounded,
                label: ref.tr('hands_free_skip'),
                filled: false,
                onTap: drill.phase == DrillPhase.finished ? null : _skip,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BigButton extends StatelessWidget {
  const _BigButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.filled = true,
  });
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final foreground = filled ? Colors.white : AppColors.teal;
    return Opacity(
      opacity: onTap == null ? 0.4 : 1,
      child: Material(
        color: filled
            ? AppColors.teal.withValues(alpha: 0.85)
            : AppColors.teal.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: foreground, size: 26),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.heading(size: 17)
                        .copyWith(color: foreground),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
