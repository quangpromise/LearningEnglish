import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/tts/app_tts.dart';
import '../../pronunciation/presentation/pronunciation_practice.dart';
import '../../reading/data/gutenberg_text.dart'
    show isWordToken, tokenizeSentence;
import '../../translation/presentation/word_popup_sheet.dart';
import '../../vocabulary/data/vocabulary_data.dart';
import '../data/story_data.dart';
import 'story_illustration.dart';

/// Micro-story B1 - ảnh tĩnh + narration (TTS đọc tuần tự, xem
/// `ReadingScreen` - đây là "động cơ" thứ 2 trong 2 động cơ "phát + đồng bộ
/// chữ" đã có sẵn, KHÔNG phải bộ karaoke theo audio-position của
/// `PlayerScreen`/`KaraokeLyricsView`, vì narration TTS không có 1 file mp3
/// đã canh timestamp sẵn để phát - xem
/// docs/architecture-multimedia-platform.md §A.4, §C.6, §D Phase 1) + phụ
/// đề song ngữ + từ vựng + shadowing lồng ngay trong bài.
class StoryScreen extends ConsumerStatefulWidget {
  const StoryScreen({super.key, required this.story});
  final Story story;

  @override
  ConsumerState<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends ConsumerState<StoryScreen> {
  late final List<GlobalKey> _segmentKeys;
  late final DateTime _openedAt;
  int _currentIndex = 0;
  bool _playing = false;
  bool _bilingual = true;
  bool _completedLocally = false;
  int _speechToken = 0;

  /// true trong luc PronunciationPractice dang ghi am/cham diem doan hien
  /// tai. PronunciationPractice duoc gan key: ValueKey(current.id) nen doi
  /// _currentIndex (chon doan khac / bam Phat lai) se REMOUNT no - dispose()
  /// cua widget cu chay ngay, huy ghi am/cham diem dang do MA KHONG BAO cho
  /// nguoi dung, mat lang le ket qua ho vua luyen. Chan doi doan khi dang
  /// ban, giong cach _busy cua PronunciationScreen (tab) chan doi cau ngau
  /// nhien khi dang ghi am.
  bool _shadowingBusy = false;

  List<StorySegment> get _segments => widget.story.segments;

  @override
  void initState() {
    super.initState();
    _openedAt = DateTime.now();
    _segmentKeys = List.generate(_segments.length, (_) => GlobalKey());
  }

  @override
  void dispose() {
    _speechToken++;
    AppTts.instance.stopSpeaking();
    final elapsed = DateTime.now().difference(_openedAt).inSeconds;
    // MOT phien hoc ghi MOT khoang thoi gian (nghe narration + shadowing
    // long trong bai deu tinh chung vao day) - xem §F.4 cua tai lieu kien
    // truc: "Shadowing nam TRONG phien hoc cua bai, khong cong doi". Vi vay
    // PronunciationPractice duoc nhung ben duoi PHAI truyen
    // countsPracticeTime: false, khong tu cong gio rieng.
    if (elapsed > 0) {
      ref.read(statsRepositoryProvider).addPracticeSeconds(elapsed);
    }
    super.dispose();
  }

  void _scrollToCurrent() {
    final ctx = _segmentKeys[_currentIndex].currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      alignment: 0.3,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _playFrom(int startIndex) async {
    final token = ++_speechToken;
    var index = startIndex;
    setState(() {
      _playing = true;
      _currentIndex = index;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrent());
    while (mounted && token == _speechToken && index < _segments.length) {
      await AppTts.instance.speakAndWait(_segments[index].en);
      if (!mounted || token != _speechToken) return;
      index++;
      if (index >= _segments.length) break;
      setState(() => _currentIndex = index);
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrent());
    }
    if (!mounted || token != _speechToken) return;
    setState(() => _playing = false);
    if (index >= _segments.length) _onFinishedNarration();
  }

  void _onFinishedNarration() {
    if (_completedLocally) return;
    setState(() => _completedLocally = true);
    ref
        .read(lessonProgressRepositoryProvider)
        .markCompleted(widget.story.id)
        .then((_) => ref.invalidate(lessonCompletedProvider(widget.story.id)))
        .catchError((_) {});
  }

  void _stopNarration() {
    _speechToken++;
    AppTts.instance.stopSpeaking();
    if (mounted) setState(() => _playing = false);
  }

  void _togglePlay() {
    if (_playing) {
      _stopNarration();
    } else if (!_shadowingBusy) {
      _playFrom(_currentIndex);
    }
  }

  void _selectSegment(int i) {
    if (_shadowingBusy) return;
    if (_playing) {
      _playFrom(i);
    } else {
      setState(() => _currentIndex = i);
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrent());
    }
  }

  void _onWordTap(String word, StorySegment segment) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => WordPopupSheet(
        word: word,
        sentenceEn: segment.en,
        sentenceVi: segment.vi,
        sourceLabelKey: 'word_in_story',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.story;
    final current = _segments[_currentIndex];
    final completedAsync = ref.watch(lessonCompletedProvider(story.id));
    final completed =
        _completedLocally || (completedAsync.valueOrNull ?? false);

    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
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
                      Icons.chevron_left_rounded,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(story.title, style: AppTextStyles.heading(size: 17)),
                      Text(
                        '${story.level} · ${ref.tr('story_original_label')}',
                        style: AppTextStyles.muted(size: 11),
                      ),
                    ],
                  ),
                ),
                if (completed)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.teal.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 14,
                          color: AppColors.teal,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          ref.tr('story_completed_badge'),
                          style: const TextStyle(
                            color: AppColors.teal,
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StoryIllustration(color: story.color),
                    const SizedBox(height: 14),
                    _NarrationBar(
                      color: story.color,
                      playing: _playing,
                      positionLabel:
                          '${ref.tr('story_segment_label')} '
                          '${(_currentIndex + 1).clamp(1, _segments.length)}/'
                          '${_segments.length}',
                      bilingualLabel: ref.tr('player_bilingual_toggle'),
                      onTogglePlay: _togglePlay,
                      bilingual: _bilingual,
                      onToggleBilingual: (v) => setState(() => _bilingual = v),
                    ),
                    const SizedBox(height: 14),
                    for (var i = 0; i < _segments.length; i++)
                      Padding(
                        key: _segmentKeys[i],
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _SegmentTile(
                          segment: _segments[i],
                          active: i == _currentIndex,
                          bilingual: _bilingual,
                          color: story.color,
                          onTap: () => _selectSegment(i),
                          onWordTap: (w) => _onWordTap(w, _segments[i]),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      ref.tr('story_vocabulary_title'),
                      style: AppTextStyles.muted(size: 10)
                          .copyWith(letterSpacing: 0.6),
                    ),
                    const SizedBox(height: 8),
                    for (final word in story.vocabulary) ...[
                      _VocabRow(word: word, color: story.color),
                      const SizedBox(height: 8),
                    ],
                    const SizedBox(height: 12),
                    Text(
                      ref.tr('story_shadow_section_title'),
                      style: AppTextStyles.muted(size: 10)
                          .copyWith(letterSpacing: 0.6),
                    ),
                    const SizedBox(height: 8),
                    PronunciationPractice(
                      key: ValueKey(current.id),
                      targetEn: current.en,
                      targetVi: current.vi,
                      source: 'story:${story.id}',
                      title: ref.tr('story_shadow_title'),
                      // Nhac narration van co the dang phat vao mic neu
                      // nguoi dung bam ghi am giua luc dang nghe - tam dung
                      // truoc (bay #1 trong §E cua tai lieu kien truc).
                      onBeforeRecord: _stopNarration,
                      // Chan doi doan (tap doan khac / bam Phat lai) trong
                      // luc dang ghi am/cham diem - xem _shadowingBusy o
                      // tren, tranh remount lam mat ket qua dang luyen.
                      onBusyChanged: (busy) => _shadowingBusy = busy,
                      // Man nay tu tinh TOAN BO thoi gian mo->dong lam 1
                      // phien hoc duy nhat o dispose() ben tren - shadowing
                      // KHONG tu cong gio rieng de tranh dem trung.
                      countsPracticeTime: false,
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NarrationBar extends StatelessWidget {
  const _NarrationBar({
    required this.color,
    required this.playing,
    required this.positionLabel,
    required this.bilingualLabel,
    required this.onTogglePlay,
    required this.bilingual,
    required this.onToggleBilingual,
  });

  final Color color;
  final bool playing;
  final String positionLabel;
  final String bilingualLabel;
  final VoidCallback onTogglePlay;
  final bool bilingual;
  final ValueChanged<bool> onToggleBilingual;

  @override
  Widget build(BuildContext context) {
    // Switch can Material ancestor de ve (ripple/thumb) - man nay (nhu moi
    // man khac trong app) chi boc trong ScreenBackground (Container +
    // SafeArea), khong co Scaffold/Material nao ben tren. Boc rieng o day
    // thay vi o toan StoryScreen de khong doi shadow/background cua ca man.
    return Material(
      type: MaterialType.transparency,
      child: GlowBox(
        borderRadius: 999,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            GestureDetector(
              onTap: onTogglePlay,
              child: Icon(
                playing
                    ? Icons.pause_circle_filled_rounded
                    : Icons.play_circle_fill_rounded,
                size: 34,
                color: color,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                positionLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.muted(size: 11),
              ),
            ),
            const SizedBox(width: 8),
            // Flexible (khong phai Text thuong) - nhan "Bilingual English –
            // Vietnamese" (ban tieng Anh) kha dai, neu khong gioi han se choan
            // het cho trong Row va ep positionLabel (Expanded) ben tren xuong
            // gan nhu 0px, khien no bi be xuong dong TUNG KY TU MOT thay vi
            // hien binh thuong tren 1 dong.
            Flexible(
              child: Text(
                bilingualLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.muted(),
              ),
            ),
            Switch(
              value: bilingual,
              activeTrackColor: color,
              onChanged: onToggleBilingual,
            ),
          ],
        ),
      ),
    );
  }
}

class _SegmentTile extends StatelessWidget {
  const _SegmentTile({
    required this.segment,
    required this.active,
    required this.bilingual,
    required this.color,
    required this.onTap,
    required this.onWordTap,
  });

  final StorySegment segment;
  final bool active;
  final bool bilingual;
  final Color color;
  final VoidCallback onTap;
  final void Function(String word) onWordTap;

  @override
  Widget build(BuildContext context) {
    // GlowBox(light: active) doi nen sang mau khi active - chu phai DAM lai
    // (den) luc do, chu khong phai sang nhu tren nen kinh toi binh thuong.
    final style = AppTextStyles.body(
      size: 15,
      weight: FontWeight.w700,
    ).copyWith(height: 1.5, color: active ? Colors.black : AppColors.textMuted);
    final spans = <InlineSpan>[
      for (final token in tokenizeSentence(segment.en))
        if (isWordToken(token))
          TextSpan(
            text: token,
            style: style,
            recognizer: TapGestureRecognizer()..onTap = () => onWordTap(token),
          )
        else
          TextSpan(text: token, style: style),
    ];
    return GestureDetector(
      onTap: onTap,
      child: GlowBox(
        light: active,
        borderRadius: 16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(TextSpan(children: spans)),
            if (bilingual) ...[
              const SizedBox(height: 4),
              Text(
                segment.vi,
                style: active
                    ? const TextStyle(
                        color: Colors.black54,
                        fontFamily: 'Manrope',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      )
                    : AppTextStyles.muted(size: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _VocabRow extends StatelessWidget {
  const _VocabRow({required this.word, required this.color});
  final VocabWord word;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GlowBox(
      borderRadius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      word.en,
                      style: AppTextStyles.body(weight: FontWeight.w800),
                    ),
                    const SizedBox(width: 8),
                    Text(word.ipa, style: AppTextStyles.muted(size: 11)),
                  ],
                ),
                Text(word.vi, style: AppTextStyles.muted(size: 12)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => AppTts.instance.speak(word.en),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Icon(Icons.volume_up_rounded, size: 20, color: color),
            ),
          ),
        ],
      ),
    );
  }
}
