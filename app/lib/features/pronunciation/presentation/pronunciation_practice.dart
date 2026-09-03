import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart' as rec;
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/tts/app_tts.dart';
import '../data/pronunciation_scoring.dart';

/// Luyện phát âm cho 1 câu MỤC TIÊU CỤ THỂ — ghi âm qua mic, chấm điểm bằng
/// [scorePronunciation]. Đây là phần thực sự dùng lại được của
/// `pronunciation_screen.dart` cũ: trước đây `targetEn`/`targetVi` là code
/// chết vì `initState()` luôn ghi đè bằng 1 dòng lyric ngẫu nhiên (xem
/// docs/architecture-multimedia-platform.md §A.5) - widget này KHÔNG tự
/// chọn câu, nó chỉ luyện đúng câu được truyền vào. Việc "chọn câu ngẫu
/// nhiên từ bài hát / đổi câu" giờ là trách nhiệm riêng của
/// `PronunciationScreen` (tab), widget này dùng được ở bất kỳ đâu khác cần
/// shadowing 1 câu cố định (vd `StoryScreen`).
class PronunciationPractice extends ConsumerStatefulWidget {
  const PronunciationPractice({
    super.key,
    required this.targetEn,
    required this.targetVi,
    required this.source,
    this.title,
    this.onChangeTarget,
    this.onBeforeRecord,
    this.onBusyChanged,
    this.countsPracticeTime = true,
  });

  final String targetEn;
  final String targetVi;

  /// Ghi vào cột `source` của `user_pronunciation_attempts` (xem migration
  /// 0027) - vd `pronunciation_tab` hoặc `story:{id}`.
  final String source;

  /// Tiêu đề hiện phía trên - mặc định `pron_title` ("Luyện phát âm") khi
  /// null, dùng cho tab gốc. Màn khác (vd StoryScreen) truyền tiêu đề riêng
  /// phù hợp ngữ cảnh (vd "Luyện nói theo đoạn này").
  final String? title;

  /// Khác `null` = cho phép người dùng đổi câu (hiện nút "Đổi câu", chạm vào
  /// ô câu mẫu gọi callback này) - dùng cho tab gốc (mở bottom sheet chọn từ
  /// bài hát). `null` = câu mục tiêu cố định theo ngữ cảnh (vd đúng đoạn
  /// đang học trong StoryScreen), ẩn hẳn nút đổi câu.
  final VoidCallback? onChangeTarget;

  /// Gọi TRƯỚC khi bắt đầu ghi âm (vd tạm dừng audio narration đang phát để
  /// mic không thu cả giọng đọc - xem bẫy #1 trong §E của tài liệu kiến
  /// trúc). Không bắt buộc phải async xong mới ghi âm.
  final VoidCallback? onBeforeRecord;

  /// Báo lên widget cha mỗi khi đang ghi âm/chấm điểm hay không (true = 1
  /// trong 2) - dùng để widget cha (vd tab gốc) tránh đổi câu mục tiêu giữa
  /// lúc người dùng đang luyện dở, kể cả khi widget cha rebuild vì lý do
  /// khác (vd chuyển tab đi rồi quay lại).
  final ValueChanged<bool>? onBusyChanged;

  /// false = KHÔNG tự cộng giây luyện tập ở đây - dùng khi widget cha (vd
  /// StoryScreen) đã tự tính TOÀN BỘ thời gian mở màn hình làm 1 phiên học
  /// duy nhất, để tránh cộng trùng (xem §F.4: "Shadowing nằm TRONG phiên học
  /// của bài, không cộng đôi").
  final bool countsPracticeTime;

  @override
  ConsumerState<PronunciationPractice> createState() =>
      _PronunciationPracticeState();
}

class _PronunciationPracticeState extends ConsumerState<PronunciationPractice> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final rec.AudioRecorder _recorder = rec.AudioRecorder();
  final AudioPlayer _playbackPlayer = AudioPlayer();
  bool _listening = false;
  bool _available = false;
  String _recognized = '';
  PronunciationScore? _result;
  DateTime? _listenStartedAt;
  Completer<void>? _finalResultCompleter;
  String? _recordedPath;
  bool _playingBack = false;
  bool _scoring = false;
  String? _recordError;

  @override
  void initState() {
    super.initState();
    _speech
        .initialize(onError: _handleSttError)
        .then((ok) {
          if (mounted) setState(() => _available = ok);
        })
        .catchError((_) {
          if (mounted) setState(() => _available = false);
        });
  }

  @override
  void didUpdateWidget(covariant PronunciationPractice oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Cau muc tieu doi (vd sang doan tiep theo trong StoryScreen, hoac bam
    // "Doi cau" o tab goc) - xoa ket qua lan luyen truoc, tru khi dang ghi
    // am/cham diem do (khong ngat ngang nguoi dung giua chung).
    if ((widget.targetEn != oldWidget.targetEn ||
            widget.targetVi != oldWidget.targetVi) &&
        !_listening &&
        !_scoring) {
      setState(() {
        _result = null;
        _recognized = '';
        _recordedPath = null;
        _recordError = null;
      });
    }
  }

  void _handleSttError(SpeechRecognitionError error) {
    if (!(_finalResultCompleter?.isCompleted ?? true)) {
      _finalResultCompleter!.complete();
    }
  }

  void _scoreAttempt() {
    final result = scorePronunciation(
      targetEn: widget.targetEn,
      recognized: _recognized,
    );
    setState(() => _result = result);
    ref
        .read(statsRepositoryProvider)
        .recordPronunciationScore(result.score, source: widget.source)
        .then((_) => ref.invalidate(myStatsProvider))
        .catchError((_) {});
  }

  Future<void> _toggleListening() async {
    if (!_available || _scoring) return;
    if (_listening) {
      setState(() {
        _listening = false;
        _scoring = true;
      });
      widget.onBusyChanged?.call(true);
      final startedAt = _listenStartedAt;
      if (widget.countsPracticeTime && startedAt != null) {
        final elapsed = DateTime.now().difference(startedAt).inSeconds;
        if (elapsed > 0) {
          ref.read(statsRepositoryProvider).addPracticeSeconds(elapsed);
        }
      }

      final completer = _finalResultCompleter;
      await _speech.stop();
      if (completer != null) {
        await completer.future.timeout(
          const Duration(milliseconds: 1500),
          onTimeout: () {},
        );
      }

      String? recordedPath;
      try {
        recordedPath = await _recorder.stop();
      } catch (_) {
        recordedPath = null;
      }

      if (mounted) {
        setState(() {
          _recordedPath = recordedPath;
          _scoring = false;
        });
      }
      widget.onBusyChanged?.call(false);
      _scoreAttempt();
      return;
    }

    widget.onBeforeRecord?.call();

    _listenStartedAt = DateTime.now();
    setState(() {
      _listening = true;
      _result = null;
      _recognized = '';
      _recordedPath = null;
      _recordError = null;
    });
    widget.onBusyChanged?.call(true);

    final completer = Completer<void>();
    _finalResultCompleter = completer;
    try {
      await _speech.listen(
        onResult: (result) {
          setState(() => _recognized = result.recognizedWords);
          if (result.finalResult && !completer.isCompleted) {
            completer.complete();
          }
        },
        listenOptions: stt.SpeechListenOptions(localeId: 'en_US'),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _listening = false;
          _recordError = '${ref.tr('pron_record_failed')} $e';
        });
      }
      widget.onBusyChanged?.call(false);
      return;
    }

    try {
      if (await _recorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        final path =
            '${dir.path}/pronunciation_attempt_${DateTime.now().millisecondsSinceEpoch}.m4a';
        await _recorder.start(const rec.RecordConfig(), path: path);
      }
    } catch (_) {
      // Bo qua - chi mat tinh nang nghe lai, cham diem khong bi anh huong.
    }
  }

  Future<void> _playRecording() async {
    final path = _recordedPath;
    if (path == null) return;
    setState(() {
      _playingBack = true;
      _recordError = null;
    });
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
      await _playbackPlayer.setFilePath(path);
      unawaited(_playbackPlayer.play());
      await _playbackPlayer.processingStateStream.firstWhere(
        (s) => s == ProcessingState.completed,
      );
    } catch (e) {
      if (mounted) {
        setState(() => _recordError = '${ref.tr('pron_playback_failed')} $e');
      }
    } finally {
      if (mounted) setState(() => _playingBack = false);
    }
  }

  void _resetAttempt() {
    setState(() {
      _result = null;
      _recognized = '';
      _recordedPath = null;
    });
  }

  @override
  void dispose() {
    _speech.stop();
    _recorder.dispose();
    _playbackPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 48),
            Text(
              widget.title ?? ref.tr('pron_title'),
              style: AppTextStyles.heading(size: 15),
            ),
            IconButton(
              onPressed: () => AppTts.instance.speak(widget.targetEn),
              icon: const Icon(
                Icons.volume_up_rounded,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: widget.onChangeTarget,
          child: GlowBox(
            borderRadius: 22,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      ref.tr('pron_read_this'),
                      style: AppTextStyles.muted(size: 10)
                          .copyWith(letterSpacing: 0.6),
                    ),
                    if (widget.onChangeTarget != null)
                      Row(
                        children: [
                          Icon(
                            Icons.swap_horiz_rounded,
                            size: 14,
                            color: AppColors.blue,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            ref.tr('pron_change_sentence'),
                            style: AppTextStyles.muted(size: 11)
                                .copyWith(color: AppColors.blue),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(widget.targetEn, style: AppTextStyles.heading(size: 18)),
                if (widget.targetVi.isNotEmpty)
                  Text(widget.targetVi, style: AppTextStyles.muted()),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (!_available)
          Text(ref.tr('pron_no_mic'), style: AppTextStyles.muted())
        else
          GestureDetector(
            onTap: _scoring ? null : _toggleListening,
            child: Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                gradient: AppColors.accentGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (_listening ? AppColors.pink : AppColors.blue)
                        .withValues(alpha: _scoring ? 0.2 : 0.5),
                    blurRadius: 44,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: _scoring
                  ? const Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : Icon(
                      _listening ? Icons.stop_rounded : Icons.mic_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
            ),
          ),
        const SizedBox(height: 10),
        Text(
          _scoring
              ? ref.tr('pron_scoring')
              : _listening
              ? ref.tr('pron_listening_stop')
              : ref.tr('pron_tap_to_record'),
          style: AppTextStyles.muted(),
        ),
        if (!_listening && !_scoring && _recordedPath != null) ...[
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _playingBack ? null : _playRecording,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _playingBack
                      ? Icons.graphic_eq_rounded
                      : Icons.play_circle_outline_rounded,
                  size: 16,
                  color: AppColors.blue,
                ),
                const SizedBox(width: 6),
                Text(
                  _playingBack
                      ? ref.tr('pron_playing')
                      : ref.tr('pron_play_recording'),
                  style: AppTextStyles.body(
                    size: 12,
                    weight: FontWeight.w700,
                    color: AppColors.blue,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (_recordError != null) ...[
          const SizedBox(height: 8),
          Text(
            _recordError!,
            textAlign: TextAlign.center,
            style: AppTextStyles.body(size: 11, color: AppColors.pink),
          ),
        ],
        if (result != null) ...[
          const SizedBox(height: 16),
          GlowBox(
            light: true,
            borderRadius: 22,
            child: Row(
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                          value: result.score / 100,
                          strokeWidth: 6,
                          backgroundColor: Colors.black12,
                          color: AppColors.blue,
                        ),
                      ),
                      Text(
                        '${result.score}%',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          height: 1.0,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: List.generate(result.targetWords.length, (i) {
                      final ok =
                          i < result.wordResults.length &&
                          result.wordResults[i];
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: (ok ? AppColors.teal : AppColors.pink)
                              .withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          result.targetWords[i],
                          style: TextStyle(
                            color: ok
                                ? const Color(0xFF1A8F7E)
                                : const Color(0xFFC22A54),
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: PillButton(
                  label: ref.tr('pron_retry'),
                  filled: false,
                  onTap: _resetAttempt,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                // "Done" va "Retry" cung dua ve trang thai san sang ghi lai -
                // giu nguyen hanh vi tu pronunciation_screen.dart cu (man
                // nay khong bao gio duoc push nen "Done" khong co gi de
                // dong/pop, chi la dong bang ket qua).
                child: PillButton(
                  label: ref.tr('pron_done'),
                  onTap: _resetAttempt,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
