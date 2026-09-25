import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/tts/app_tts.dart';
import '../../../core/utils/keep_screen_on.dart';
import '../../../core/widgets/speaker_button.dart';
import '../../pronunciation/data/pronunciation_scoring.dart';
import '../../speaking/data/speech_listener.dart';
import '../../srs/data/srs_store.dart';
import '../data/exercise_i18n.dart';
import '../data/exercise_model.dart';
import '../data/exercise_tutorial.dart';
import '../data/gym_vocabulary.dart';
import 'exercise_photo_animator.dart';

enum _Phase { playing, paused, prompt, listening, scored, finished }

/// Diem toi thieu de tinh 1 cau "Noi theo" la dat.
const _kPassScore = 70;

/// "Video" huong dan bai tap DUNG TRONG APP (khong phai file MP4): ghep anh
/// 2 tu the + cau huong dan Anh/Viet + giong doc TTS thanh trinh phat doc
/// 9:16 toan man hinh. Vi app biet tung cau nen lam duoc: thanh chuong kieu
/// Stories, cham trai/phai doi buoc, toc do 0.75x, bat/tat dich, cum chu
/// sang dan theo giong doc, "Noi theo" cham diem sau moi buoc, man ket thuc
/// them tu khoa vao On tap / tap bai ngay. Chay offline, co ngay cho ca 155
/// bai (xem docs/gymtalk-exercise-tutorial.md).
class ExerciseTutorialPlayer extends ConsumerStatefulWidget {
  const ExerciseTutorialPlayer({
    super.key,
    required this.exercise,
    this.startChapter = 0,
    this.onStartWorkout,
  });

  final Exercise exercise;

  /// Chuong bat dau (bam chuong o man chi tiet).
  final int startChapter;

  /// "Tap bai nay ngay" o man ket thuc - null thi an nut.
  final VoidCallback? onStartWorkout;

  @override
  ConsumerState<ExerciseTutorialPlayer> createState() =>
      _ExerciseTutorialPlayerState();
}

class _ExerciseTutorialPlayerState
    extends ConsumerState<ExerciseTutorialPlayer> {
  late ExerciseTutorial _tutorial = buildExerciseTutorial(
    widget.exercise,
    boxes: SrsStore.instance.boxes,
  );
  final SpeechListener _listener = SpeechListener();

  int _index = 0;
  _Phase _phase = _Phase.playing;

  /// Tang moi khi doi chuong/tam dung - vong phat dang cho (await) tu thoat
  /// neu da cu.
  int _runId = 0;

  double _speed = 1;
  bool _showVi = true;

  DateTime? _chapterStartedAt;
  double _chapterSeconds = 1;
  bool _chapterDone = false;
  Timer? _ticker;
  Timer? _autoAdvance;
  int _keywordIndex = -1;

  String _heard = '';
  int? _lastScore;
  final List<int> _scores = [];
  bool _addedToSrs = false;

  List<TutorialChapter> get _chapters => _tutorial.chapters;
  TutorialChapter get _chapter => _chapters[_index];

  @override
  void initState() {
    super.initState();
    KeepScreenOn.enable();
    _listener.onPartial = (partial) {
      if (mounted) setState(() => _heard = partial);
    };
    // Tai lai bo SRS de chon tu khoa uu tien tu chua thuoc (thuong da tai
    // san tu man Hom nay/tap - nhanh).
    SrsStore.instance.ensureLoaded().then((_) {
      if (!mounted || _index != widget.startChapter) return;
      if (_phase == _Phase.finished) return;
      final rebuilt = buildExerciseTutorial(
        widget.exercise,
        boxes: SrsStore.instance.boxes,
      );
      if (rebuilt.chapters.length == _chapters.length) {
        setState(() => _tutorial = rebuilt);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _play(widget.startChapter.clamp(0, _chapters.length - 1));
      }
    });
  }

  @override
  void dispose() {
    _runId++;
    _ticker?.cancel();
    _autoAdvance?.cancel();
    _listener.dispose();
    AppTts.instance.stopSpeaking();
    AppTts.instance.setNarrationRate(AppTts.defaultRate);
    KeepScreenOn.disable();
    super.dispose();
  }

  // ---------------------------------------------------------------------
  // Dieu khien phat
  // ---------------------------------------------------------------------

  void _stopAudio() {
    _ticker?.cancel();
    _autoAdvance?.cancel();
    AppTts.instance.stopSpeaking();
    _listener.stop();
  }

  bool _stale(int runId) => !mounted || runId != _runId;

  Future<void> _play(int index) async {
    final runId = ++_runId;
    _stopAudio();
    await AppTts.instance.setNarrationRate(AppTts.defaultRate * _speed);
    if (_stale(runId)) return;
    setState(() {
      _index = index;
      _phase = _Phase.playing;
      _keywordIndex = -1;
      _heard = '';
      _lastScore = null;
      _chapterDone = false;
      _chapterStartedAt = null;
    });
    final chapter = _chapters[index];

    if (chapter.kind == TutorialChapterKind.keywords) {
      for (var k = 0; k < _tutorial.keywords.length; k++) {
        setState(() => _keywordIndex = k);
        await AppTts.instance.speakAndWait(_tutorial.keywords[k].en);
        await Future<void>.delayed(const Duration(milliseconds: 600));
        if (_stale(runId)) return;
      }
      _next();
      return;
    }

    _chapterSeconds = estimateSpeechSeconds(chapter.narration, speed: _speed);
    _chapterStartedAt = DateTime.now();
    _ticker = Timer.periodic(const Duration(milliseconds: 120), (_) {
      if (mounted) setState(() {});
    });
    await AppTts.instance.speakAndWait(chapter.narration);
    if (_stale(runId)) return;
    _ticker?.cancel();
    setState(() => _chapterDone = true);

    if (chapter.practiceText.isNotEmpty) {
      setState(() => _phase = _Phase.prompt);
      // Khong ai tuong tac -> tu sang buoc sau (xem nhu bo qua).
      _autoAdvance = Timer(const Duration(seconds: 12), () {
        if (!_stale(runId) && _phase == _Phase.prompt) _next();
      });
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (_stale(runId)) return;
    _next();
  }

  void _next() {
    if (_index + 1 < _chapters.length) {
      _play(_index + 1);
    } else {
      _finish();
    }
  }

  void _prev() => _play(_index > 0 ? _index - 1 : 0);

  void _finish() {
    _runId++;
    _stopAudio();
    setState(() => _phase = _Phase.finished);
  }

  void _togglePause() {
    if (_phase == _Phase.paused) {
      _play(_index); // Phat lai tu dau chuong.
      return;
    }
    if (_phase != _Phase.playing) return;
    _runId++;
    _stopAudio();
    setState(() => _phase = _Phase.paused);
  }

  void _toggleSpeed() {
    setState(() => _speed = _speed == 1 ? 0.75 : 1);
    if (_phase == _Phase.playing) _play(_index);
  }

  Future<void> _practice() async {
    final runId = _runId;
    _autoAdvance?.cancel();
    setState(() {
      _phase = _Phase.listening;
      _heard = '';
      _lastScore = null;
    });
    final heard = await _listener.listenOnce();
    if (_stale(runId)) return;
    final score = scorePronunciation(
      targetEn: _chapter.practiceText,
      recognized: heard,
    ).score;
    ref
        .read(statsRepositoryProvider)
        .recordPronunciationScore(score, source: 'exercise_tutorial')
        .catchError((_) {});
    setState(() {
      _heard = heard;
      _lastScore = score;
      _scores.add(score);
      _phase = _Phase.scored;
    });
    await AppTts.instance.speakAndWait(
      score >= _kPassScore ? 'Great job!' : 'Nice try!',
    );
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (_stale(runId)) return;
    _next();
  }

  Future<void> _addKeywordsToSrs() async {
    final now = DateTime.now();
    for (final word in _tutorial.keywords) {
      await SrsStore.instance.addIfAbsent(word.toSrsCard(now));
    }
    if (mounted) setState(() => _addedToSrs = true);
  }

  void _replay() {
    setState(() {
      _scores.clear();
      _addedToSrs = false;
    });
    _play(0);
  }

  void _onBodyTap(TapUpDetails details, double width) {
    if (_phase == _Phase.finished) return;
    final x = details.localPosition.dx;
    if (x < width / 3) {
      _prev();
    } else if (x > width * 2 / 3) {
      _next();
    } else {
      _togglePause();
    }
  }

  // ---------------------------------------------------------------------
  // Tien do
  // ---------------------------------------------------------------------

  double get _elapsed {
    final start = _chapterStartedAt;
    if (_chapterDone) return double.infinity;
    if (start == null) return 0;
    return DateTime.now().difference(start).inMilliseconds / 1000;
  }

  double _segmentFraction(int i) {
    if (_phase == _Phase.finished || i < _index) return 1;
    if (i > _index) return 0;
    if (_chapter.kind == TutorialChapterKind.keywords) {
      final n = _tutorial.keywords.length;
      return n == 0 ? 1 : ((_keywordIndex + 1) / n).clamp(0.0, 1.0);
    }
    if (_chapterDone) return 1;
    return (_elapsed / _chapterSeconds).clamp(0.0, 1.0);
  }

  int get _litPhrases {
    final chapter = _chapter;
    if (_chapterDone) return chapter.phrases.length;
    final display = chapter.displayText;
    final lead = chapter.narration.endsWith(display)
        ? chapter.narration.substring(
            0,
            chapter.narration.length - display.length,
          )
        : '';
    final times = phraseStartTimes(
      lead: lead,
      phrases: chapter.phrases,
      totalSeconds: _chapterSeconds,
    );
    final elapsed = _elapsed;
    return times.where((t) => t <= elapsed).length;
  }

  // ---------------------------------------------------------------------
  // Giao dien
  // ---------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgTop,
      body: SafeArea(
        child: _phase == _Phase.finished ? _endView() : _playerView(),
      ),
    );
  }

  Widget _playerView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: Row(
            children: [
              for (var i = 0; i < _chapters.length; i++)
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _play(i),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 2,
                        vertical: 8,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: _segmentFraction(i),
                          minHeight: 4,
                          color: Colors.white,
                          backgroundColor: Colors.white.withValues(alpha: 0.25),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              SpeakerButton(
                icon: Icons.close_rounded,
                tapSize: 48,
                color: AppColors.textPrimary,
                onTap: () => Navigator.of(context).maybePop(),
              ),
              const Spacer(),
              _ControlChip(
                label: _speed == 1 ? '1×' : '0.75×',
                onTap: _toggleSpeed,
              ),
              const SizedBox(width: 8),
              _ControlChip(
                label: 'CC VI',
                active: _showVi,
                onTap: () => setState(() => _showVi = !_showVi),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) => GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (d) => _onBodyTap(d, constraints.maxWidth),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: SingleChildScrollView(child: _chapterBody()),
                  ),
                  if (_phase == _Phase.paused)
                    const Center(
                      child: Icon(
                        Icons.play_circle_fill_rounded,
                        size: 96,
                        color: Colors.white70,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (_phase == _Phase.prompt ||
            _phase == _Phase.listening ||
            _phase == _Phase.scored)
          _practicePanel(),
      ],
    );
  }

  Widget _chapterBody() {
    final lang = ref.watch(appLanguageProvider);
    final exercise = widget.exercise;
    final chapter = _chapter;
    switch (chapter.kind) {
      case TutorialChapterKind.overview:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            ExercisePhotoAnimator(assets: exercise.photoAssets, height: 300),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(exercise.nameEn, style: AppTextStyles.heading(size: 32)),
                  Text(exercise.nameVi, style: AppTextStyles.muted(size: 16)),
                  const SizedBox(height: 16),
                  _phrasesText(chapter),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final m in exercise.displayedMuscles.take(4))
                        _Pill(
                          label: exerciseMuscleLabel(
                            m.split(' · ').first,
                            lang,
                          ),
                          color: AppColors.fitnessAccentBright,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      case TutorialChapterKind.step:
        final steps = _chapters
            .where((c) => c.kind == TutorialChapterKind.step)
            .length;
        final photos = exercise.photoAssets;
        final Widget photo = chapter.stepIndex == 0
            ? _StillPhoto(asset: photos.first)
            : chapter.stepIndex == steps - 1
            ? _StillPhoto(asset: photos.last)
            : ExercisePhotoAnimator(assets: photos, height: 300);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            photo,
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Pill(
                    label:
                        '${ref.tr('tutorial_step')} ${chapter.stepIndex + 1}'
                        ' / $steps',
                    color: AppColors.fitnessAccentBright,
                  ),
                  const SizedBox(height: 14),
                  _phrasesText(chapter),
                  if (_showVi && chapter.vi.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text(
                      chapter.vi,
                      style: AppTextStyles.body(
                        size: 16,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      case TutorialChapterKind.keywords:
        return Padding(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                ref.tr('tutorial_keywords_title'),
                style: AppTextStyles.heading(size: 26),
              ),
              const SizedBox(height: 18),
              for (var k = 0; k < _tutorial.keywords.length; k++) ...[
                _KeywordCard(
                  word: _tutorial.keywords[k],
                  active: k == _keywordIndex,
                  showVi: _showVi,
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        );
    }
  }

  /// Cau tieng Anh: cum da doc sang, cum chua doc mo; tu khoa gach chan.
  Widget _phrasesText(TutorialChapter chapter) {
    final lit = _litPhrases;
    final keywords = _tutorial.keywords.map((w) => w.en).toList();
    return Text.rich(
      TextSpan(
        children: [
          for (var i = 0; i < chapter.phrases.length; i++)
            ..._phraseSpans(
              chapter.phrases[i],
              keywords,
              AppTextStyles.heading(size: 26).copyWith(
                height: 1.35,
                color: i < lit
                    ? AppColors.textPrimary
                    : AppColors.textPrimary.withValues(alpha: 0.35),
              ),
            ),
        ],
      ),
    );
  }

  List<InlineSpan> _phraseSpans(
    String phrase,
    List<String> keywords,
    TextStyle style,
  ) {
    final lower = phrase.toLowerCase();
    final marks = <(int, int)>[];
    for (final k in keywords) {
      final kl = k.toLowerCase();
      var from = 0;
      while (true) {
        final at = lower.indexOf(kl, from);
        if (at < 0) break;
        marks.add((at, at + kl.length));
        from = at + kl.length;
      }
    }
    marks.sort((a, b) => a.$1 - b.$1);
    final spans = <InlineSpan>[];
    var pos = 0;
    for (final (start, end) in marks) {
      if (start < pos) continue;
      if (start > pos) {
        spans.add(TextSpan(text: phrase.substring(pos, start), style: style));
      }
      spans.add(
        TextSpan(
          text: phrase.substring(start, end),
          style: style.copyWith(
            decoration: TextDecoration.underline,
            decorationColor: AppColors.blue,
            decorationThickness: 3,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () => AppTts.instance.speak(phrase.substring(start, end)),
        ),
      );
      pos = end;
    }
    if (pos < phrase.length) {
      spans.add(TextSpan(text: phrase.substring(pos), style: style));
    }
    return spans;
  }

  Widget _practicePanel() {
    final listening = _phase == _Phase.listening;
    final score = _lastScore;
    final String title;
    final String subtitle;
    if (listening) {
      title = ref.tr('tutorial_listening');
      subtitle = _heard.isEmpty ? '…' : '"$_heard"';
    } else if (score != null) {
      title = ref.tr('tutorial_score').replaceFirst('{score}', '$score');
      subtitle = _heard.isEmpty ? ref.tr('tutorial_not_heard') : '"$_heard"';
    } else {
      title = ref.tr('tutorial_say_it');
      subtitle = ref.tr('tutorial_say_it_sub');
    }
    final color = score == null
        ? AppColors.teal
        : score >= _kPassScore
        ? AppColors.wealthUp
        : AppColors.amber;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withValues(alpha: 0.55)),
      ),
      child: Row(
        children: [
          Material(
            color: color,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: _phase == _Phase.prompt ? _practice : null,
              child: SizedBox(
                width: 60,
                height: 60,
                child: Icon(
                  listening ? Icons.graphic_eq_rounded : Icons.mic_rounded,
                  color: Colors.black87,
                  size: 30,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body(size: 16, weight: FontWeight.w800),
                ),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.muted(size: 13),
                ),
              ],
            ),
          ),
          if (_phase == _Phase.prompt)
            TextButton(onPressed: _next, child: Text(ref.tr('tutorial_skip'))),
        ],
      ),
    );
  }

  Widget _endView() {
    final passed = _scores.where((s) => s >= _kPassScore).length;
    final avg = _scores.isEmpty
        ? null
        : (_scores.reduce((a, b) => a + b) / _scores.length).round();
    final onStartWorkout = widget.onStartWorkout;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: SpeakerButton(
            icon: Icons.close_rounded,
            tapSize: 48,
            color: AppColors.textPrimary,
            onTap: () => Navigator.of(context).maybePop(),
          ),
        ),
        const Icon(Icons.celebration_rounded, size: 56, color: AppColors.amber),
        const SizedBox(height: 8),
        Text(
          ref
              .tr('tutorial_done_title')
              .replaceFirst('{name}', widget.exercise.nameEn),
          textAlign: TextAlign.center,
          style: AppTextStyles.heading(size: 24),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            _Stat(
              value: '$passed/${_scores.length}',
              label: ref.tr('tutorial_stat_passed'),
            ),
            const SizedBox(width: 10),
            _Stat(
              value: avg == null ? '–' : '$avg',
              label: ref.tr('tutorial_stat_score'),
            ),
            const SizedBox(width: 10),
            _Stat(
              value: '+${_scores.length}',
              label: ref.tr('tutorial_stat_speak'),
            ),
          ],
        ),
        const SizedBox(height: 18),
        for (final word in _tutorial.keywords) ...[
          _KeywordCard(word: word, active: false, showVi: true),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 8),
        PillButton(
          label: ref
              .tr(_addedToSrs ? 'tutorial_added' : 'tutorial_add_srs')
              .replaceFirst('{count}', '${_tutorial.keywords.length}'),
          accentColor: AppColors.blue,
          filled: false,
          onTap: _addedToSrs ? null : _addKeywordsToSrs,
        ),
        if (onStartWorkout != null) ...[
          const SizedBox(height: 12),
          PillButton(
            label: ref.tr('tutorial_start_workout'),
            accentColor: AppColors.fitnessAccent,
            accentGradient: AppColors.fitnessAccentGradient,
            onTap: () {
              Navigator.of(context).pop();
              onStartWorkout();
            },
          ),
        ],
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: _replay,
          icon: const Icon(Icons.replay_rounded),
          label: Text(ref.tr('tutorial_replay')),
        ),
      ],
    );
  }
}

class _StillPhoto extends StatelessWidget {
  const _StillPhoto({required this.asset});
  final String asset;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.asset(
        asset,
        height: 300,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }
}

class _ControlChip extends StatelessWidget {
  const _ControlChip({
    required this.label,
    required this.onTap,
    this.active = true,
  });
  final String label;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.4),
      shape: StadiumBorder(
        side: BorderSide(
          color: active ? Colors.white54 : AppColors.glassBorder,
        ),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Text(
            label,
            style: AppTextStyles.body(
              size: 13,
              weight: FontWeight.w800,
              color: active ? AppColors.textPrimary : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyles.body(
          size: 13,
          weight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

class _KeywordCard extends StatelessWidget {
  const _KeywordCard({
    required this.word,
    required this.active,
    required this.showVi,
  });
  final GymWord word;
  final bool active;
  final bool showVi;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      decoration: BoxDecoration(
        color: AppColors.blue.withValues(alpha: active ? 0.2 : 0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.blue.withValues(alpha: active ? 1 : 0.45),
          width: active ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(word.en, style: AppTextStyles.heading(size: 22)),
                if (word.ipa.isNotEmpty)
                  Text(word.ipa, style: AppTextStyles.muted(size: 13)),
                if (showVi)
                  Text(
                    word.vi,
                    style: AppTextStyles.body(
                      size: 14,
                      weight: FontWeight.w800,
                      color: AppColors.teal,
                    ),
                  ),
              ],
            ),
          ),
          SpeakerButton(
            tapSize: 48,
            color: AppColors.blue,
            onTap: () => AppTts.instance.speak(word.en),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.glassFill,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Column(
          children: [
            Text(value, style: AppTextStyles.heading(size: 22)),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.muted(size: 11),
            ),
          ],
        ),
      ),
    );
  }
}
