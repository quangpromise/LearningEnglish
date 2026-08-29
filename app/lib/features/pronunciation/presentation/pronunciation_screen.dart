import 'dart:async';
import 'dart:math';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart' as rec;
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/tts/app_tts.dart';
import '../../music_player/data/songs_data.dart';

/// Luyện phát âm: ghi âm qua mic (speech_to_text), so khớp với câu mẫu
/// bằng thuật toán word-match đơn giản. Xem giới hạn kỹ thuật (ASR không
/// chấm được lỗi phát âm ở mức âm vị) trong docs/research-ai-voice.md.
class PronunciationScreen extends ConsumerStatefulWidget {
  const PronunciationScreen({
    super.key,
    this.targetEn = "Now I'm standing in the rain",
    this.targetVi = 'Giờ tôi đứng lặng giữa cơn mưa',
  });

  final String targetEn;
  final String targetVi;

  @override
  ConsumerState<PronunciationScreen> createState() =>
      _PronunciationScreenState();
}

class _PronunciationScreenState extends ConsumerState<PronunciationScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final rec.AudioRecorder _recorder = rec.AudioRecorder();
  final AudioPlayer _playbackPlayer = AudioPlayer();
  bool _listening = false;
  bool _available = false;
  String _recognized = '';
  int? _score;
  List<bool> _wordResults = [];
  DateTime? _listenStartedAt;
  late String _targetEn;
  late String _targetVi;
  Completer<void>? _finalResultCompleter;
  String? _recordedPath;
  bool _playingBack = false;
  bool _scoring = false;
  String? _recordError;

  @override
  void initState() {
    super.initState();
    final initial = _randomSongLine();
    _targetEn = initial.en;
    _targetVi = initial.vi;
    _speech.initialize().then((ok) => setState(() => _available = ok));
  }

  /// Lay ngau nhien 1 dong lyric bat ky trong toan bo danh sach bai hat lam
  /// cau mac dinh de luyen phat am, thay vi luon la 1 cau co dinh - nguoi
  /// dung van co the tu doi cau khac qua nut "Doi cau" nhu cu.
  _PracticeChoice _randomSongLine() {
    final allLines = <_PracticeChoice>[
      for (final song in kSongs)
        for (final line in song.lyrics) _PracticeChoice(line.en, line.vi),
    ];
    if (allLines.isEmpty) {
      return _PracticeChoice(widget.targetEn, widget.targetVi);
    }
    return allLines[Random().nextInt(allLines.length)];
  }

  Future<void> _pickPracticeSentence() async {
    final picked = await showModalBottomSheet<_PracticeChoice>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _PracticeSourcePicker(),
    );
    if (picked == null) return;
    setState(() {
      _targetEn = picked.en;
      _targetVi = picked.vi;
      _score = null;
      _recognized = '';
      _wordResults = [];
      _recordedPath = null;
    });
  }

  // Bo may nhan dien giong noi cua Android thuong "danh may lai" contraction
  // theo cach rieng (vd nguoi dung noi "I'm" nhung tra ve "I am") - neu
  // khong quy ve cung 1 dang, ca cau se bi lech vi tri va diem luon gan 0%
  // du doc dung.
  static const _contractions = {
    "i'm": 'i am',
    "it's": 'it is',
    "don't": 'do not',
    "can't": 'cannot',
    "won't": 'will not',
    "didn't": 'did not',
    "doesn't": 'does not',
    "isn't": 'is not',
    "aren't": 'are not',
    "wasn't": 'was not',
    "weren't": 'were not',
    "haven't": 'have not',
    "hasn't": 'has not',
    "hadn't": 'had not',
    "you're": 'you are',
    "they're": 'they are',
    "we're": 'we are',
    "i've": 'i have',
    "you've": 'you have',
    "we've": 'we have',
    "they've": 'they have',
    "i'll": 'i will',
    "you'll": 'you will',
    "he'll": 'he will',
    "she'll": 'she will',
    "we'll": 'we will',
    "they'll": 'they will',
    "let's": 'let us',
    "that's": 'that is',
    "who's": 'who is',
    "what's": 'what is',
    "there's": 'there is',
    "here's": 'here is',
  };

  List<String> _normalize(String s) {
    final words = s
        .toLowerCase()
        .replaceAll(RegExp(r"[^a-z' ]"), '')
        .split(' ')
        .where((w) => w.isNotEmpty);
    final expanded = <String>[];
    for (final w in words) {
      final mapped = _contractions[w];
      if (mapped != null) {
        expanded.addAll(mapped.split(' '));
      } else {
        expanded.add(w);
      }
    }
    return expanded;
  }

  /// So khop bang Longest Common Subsequence thay vi doi vi tri tuyet doi -
  /// chiu duoc truong hop nguoi noi dung nhung may nhan dien them/bot/doi
  /// cho 1 tu (vd nghe nham 1 tu) ma khong lam sai lech toan bo cau con lai.
  List<bool> _lcsMatch(List<String> target, List<String> said) {
    final n = target.length, m = said.length;
    final dp = List.generate(n + 1, (_) => List.filled(m + 1, 0));
    for (var i = 1; i <= n; i++) {
      for (var j = 1; j <= m; j++) {
        dp[i][j] = target[i - 1] == said[j - 1]
            ? dp[i - 1][j - 1] + 1
            : (dp[i - 1][j] >= dp[i][j - 1] ? dp[i - 1][j] : dp[i][j - 1]);
      }
    }
    final matched = List.filled(n, false);
    var i = n, j = m;
    while (i > 0 && j > 0) {
      if (target[i - 1] == said[j - 1]) {
        matched[i - 1] = true;
        i--;
        j--;
      } else if (dp[i - 1][j] >= dp[i][j - 1]) {
        i--;
      } else {
        j--;
      }
    }
    return matched;
  }

  void _scoreAttempt() {
    final target = _normalize(_targetEn);
    final said = _normalize(_recognized);
    final results = _lcsMatch(target, said);
    final correct = results.where((r) => r).length;
    final score = target.isEmpty
        ? 0
        : ((correct / target.length) * 100).round();
    setState(() {
      _wordResults = results;
      _score = score;
    });
    ref
        .read(statsRepositoryProvider)
        .recordPronunciationScore(score)
        .then((_) => ref.invalidate(myStatsProvider))
        .catchError((_) {});
  }

  Future<void> _toggleListening() async {
    if (!_available || _scoring) return;
    if (_listening) {
      // Da thu chay `record` (ghi file tho) va `speech_to_text` (nhan dien
      // song song) CUNG LUC nhieu lan - Android luon "cam" file cua `record`
      // (im lang hoan toan) du doi audioSource nao, vi day la gioi han nen
      // tang cua he dieu hanh (khong cho 2 phien capture mic tranh nhau tin
      // hieu that khi 1 ben la SpeechRecognizer he thong), khong phai loi
      // config sua duoc. Nen tach lam 2 GIAI DOAN TUAN TU thay vi chay song
      // song: (1) chi `record` ghi am sach (khong co gi tranh chap mic),
      // (2) sau khi dung, PHAT LAI chinh file do qua loa trong luc
      // `speech_to_text` dang nghe qua mic de lay transcript cham diem -
      // mic luc nay cung chi co 1 ben dung (STT), khong con xung dot.
      final recordedPath = await _recorder.stop();
      if (!mounted) return;
      setState(() {
        _listening = false;
        _recordedPath = recordedPath;
        _scoring = recordedPath != null;
      });
      final startedAt = _listenStartedAt;
      if (startedAt != null) {
        final elapsed = DateTime.now().difference(startedAt).inSeconds;
        if (elapsed > 0) {
          ref.read(statsRepositoryProvider).addPracticeSeconds(elapsed);
        }
      }
      if (recordedPath != null) {
        await _scoreViaLoopback(recordedPath);
      }
      return;
    }
    _listenStartedAt = DateTime.now();
    setState(() {
      _listening = true;
      _score = null;
      _recognized = '';
      _recordedPath = null;
      _recordError = null;
    });
    try {
      if (await _recorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        final path =
            '${dir.path}/pronunciation_attempt_${DateTime.now().millisecondsSinceEpoch}.m4a';
        await _recorder.start(const rec.RecordConfig(), path: path);
      } else if (mounted) {
        setState(() => _recordError = ref.tr('pron_mic_permission_missing'));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _recordError = '${ref.tr('pron_record_failed')} $e');
      }
    }
  }

  /// Phat lai file vua ghi qua loa trong luc `speech_to_text` dang nghe qua
  /// mic, de lay transcript cham diem MA KHONG can chay 2 phien capture mic
  /// cung luc (xem giai thich trong _toggleListening). Rui ro da biet: che
  /// do chong vong (AEC) cua may co the lam giam do chinh xac nhan dien so
  /// voi noi truc tiep vao mic - chap nhan danh doi nay de nut "nghe lai
  /// ghi am" luon phat ra am thanh that thay vi im lang.
  Future<void> _scoreViaLoopback(String path) async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());

      final completer = Completer<void>();
      _finalResultCompleter = completer;
      await _speech.listen(
        onResult: (result) {
          setState(() => _recognized = result.recognizedWords);
          if (result.finalResult &&
              !(_finalResultCompleter?.isCompleted ?? true)) {
            _finalResultCompleter!.complete();
          }
        },
        listenOptions: stt.SpeechListenOptions(localeId: 'en_US'),
      );
      // Cho STT thuc su vao trang thai dang nghe truoc khi phat, tranh mat
      // vai tu dau do phien nhan dien chua kip khoi dong xong.
      await Future.delayed(const Duration(milliseconds: 400));

      await _playbackPlayer.setFilePath(path);
      unawaited(_playbackPlayer.play());
      await _playbackPlayer.processingStateStream.firstWhere(
        (s) => s == ProcessingState.completed,
      );
      await _speech.stop();
      await completer.future.timeout(
        const Duration(milliseconds: 1500),
        onTimeout: () {},
      );
    } catch (e) {
      if (mounted) {
        setState(() => _recordError = '${ref.tr('pron_record_failed')} $e');
      }
    } finally {
      if (mounted) setState(() => _scoring = false);
    }
    _scoreAttempt();
  }

  Future<void> _playRecording() async {
    final path = _recordedPath;
    if (path == null) return;
    setState(() {
      _playingBack = true;
      _recordError = null;
    });
    try {
      // Sau khi dung mic (record + speech_to_text) de ghi am, Android giu
      // nguyen audio mode cho ghi am - neu phat lai ngay, AudioPlayer se
      // phat qua loa THOAI (earpiece) rat nho thay vi loa ngoai, khien
      // nguoi dung tuong nhu khong nghe duoc gi du file ghi am hoan toan
      // binh thuong. Ep lai session ve che do nhac truoc khi phat.
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
      await _playbackPlayer.setFilePath(path);
      // KHONG await play(): just_audio's play() chi hoan tat future khi phat
      // XONG hoac bi tam dung, khong phai luc bat dau - await no o day se
      // treo ham nay cho toi khi phat het, khien nut "dang phat" ket dinh va
      // (tuy theo hanh vi may) co cam giac nhu khong phat duoc gi ca.
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

  @override
  void dispose() {
    _speech.stop();
    _recorder.dispose();
    _playbackPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final targetWords = _normalize(_targetEn);

    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Man hinh nay la 1 tab goc trong IndexedStack cua RootShell
                // (khong bao gio duoc Navigator.push), nen khong co man
                // truoc do de "back" - dat 1 khoang trong bang chieu rong
                // nut am luong o phai de tieu de van can giua.
                const SizedBox(width: 48),
                Text(
                  ref.tr('pron_title'),
                  style: AppTextStyles.heading(size: 15),
                ),
                IconButton(
                  onPressed: () => AppTts.instance.speak(_targetEn),
                  icon: const Icon(
                    Icons.volume_up_rounded,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickPracticeSentence,
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
                    Text(_targetEn, style: AppTextStyles.heading(size: 18)),
                    Text(_targetVi, style: AppTextStyles.muted()),
                  ],
                ),
              ),
            ),
            const Spacer(),
            if (!_available)
              Text(ref.tr('pron_no_mic'), style: AppTextStyles.muted())
            else
              GestureDetector(
                onTap: _scoring ? null : _toggleListening,
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    gradient: AppColors.accentGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (_listening ? AppColors.pink : AppColors.blue)
                            .withValues(alpha: _scoring ? 0.2 : 0.5),
                        blurRadius: 50,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                  child: _scoring
                      ? const Padding(
                          padding: EdgeInsets.all(28),
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : Icon(
                          _listening ? Icons.stop_rounded : Icons.mic_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                ),
              ),
            const SizedBox(height: 12),
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
            const Spacer(),
            if (_score != null) ...[
              GlowBox(
                light: true,
                borderRadius: 22,
                child: Row(
                  children: [
                    SizedBox(
                      width: 64,
                      height: 64,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: _score! / 100,
                            strokeWidth: 6,
                            backgroundColor: Colors.black12,
                            color: AppColors.blue,
                          ),
                          Text(
                            '$_score%',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
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
                        children: List.generate(targetWords.length, (i) {
                          final ok = i < _wordResults.length && _wordResults[i];
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
                              targetWords[i],
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
            ],
            Row(
              children: [
                Expanded(
                  child: PillButton(
                    label: ref.tr('pron_retry'),
                    filled: false,
                    onTap: () => setState(() {
                      _score = null;
                      _recognized = '';
                      _recordedPath = null;
                    }),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PillButton(
                    label: ref.tr('pron_done'),
                    // Man hinh nay la 1 tab goc trong IndexedStack cua
                    // RootShell (khong bao gio duoc Navigator.push), nen
                    // Navigator.maybePop() truoc day khong co gi de pop -
                    // nut bam khong lam gi ca. "Done" o day nghia la dong
                    // bang ket qua, quay ve trang thai san sang ghi lai.
                    onTap: () => setState(() {
                      _score = null;
                      _recognized = '';
                      _recordedPath = null;
                    }),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Câu (tiếng Anh + nghĩa tiếng Việt) người dùng chọn để luyện phát âm —
/// có thể lấy từ lời 1 bài hát có sẵn hoặc tự gõ tay.
class _PracticeChoice {
  const _PracticeChoice(this.en, this.vi);
  final String en;
  final String vi;
}

/// Bottom sheet chọn câu/từ để luyện phát âm: hoặc gõ tay, hoặc chọn 1 dòng
/// lời trong danh sách bài hát có sẵn (`kSongs`).
class _PracticeSourcePicker extends ConsumerStatefulWidget {
  const _PracticeSourcePicker();

  @override
  ConsumerState<_PracticeSourcePicker> createState() =>
      _PracticeSourcePickerState();
}

class _PracticeSourcePickerState extends ConsumerState<_PracticeSourcePicker> {
  final _customController = TextEditingController();
  int? _expandedSongIndex;

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  void _useCustomText() {
    final text = _customController.text.trim();
    if (text.isEmpty) return;
    Navigator.of(context).pop(_PracticeChoice(text, ''));
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF12172E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.glassBorder,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                ref.tr('pron_pick_title'),
                style: AppTextStyles.heading(size: 16),
              ),
              const SizedBox(height: 14),
              Text(
                ref.tr('pron_custom_label'),
                style: AppTextStyles.muted(size: 10)
                    .copyWith(letterSpacing: 0.6),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _customController,
                      style: AppTextStyles.body(),
                      cursorColor: AppColors.purple,
                      onSubmitted: (_) => _useCustomText(),
                      decoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: AppColors.glassFill,
                        hintText: ref.tr('pron_custom_hint'),
                        hintStyle: AppTextStyles.muted(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _useCustomText,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: AppColors.accentGradient,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                ref.tr('pron_pick_from_song'),
                style: AppTextStyles.muted(size: 10)
                    .copyWith(letterSpacing: 0.6),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: kSongs.length,
                  itemBuilder: (context, songIndex) {
                    final song = kSongs[songIndex];
                    final expanded = _expandedSongIndex == songIndex;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => setState(
                            () => _expandedSongIndex = expanded
                                ? null
                                : songIndex,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.music_note_rounded,
                                  size: 18,
                                  color: song.color,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        song.title,
                                        style: AppTextStyles.body(
                                          weight: FontWeight.w800,
                                        ),
                                      ),
                                      Text(
                                        song.artist,
                                        style: AppTextStyles.muted(size: 11),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  expanded
                                      ? Icons.expand_less_rounded
                                      : Icons.expand_more_rounded,
                                  color: AppColors.textMuted,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (expanded)
                          ...song.lyrics.map(
                            (line) => GestureDetector(
                              onTap: () =>
                                  Navigator.of(context)
                                      .pop(_PracticeChoice(line.en, line.vi)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 12,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(line.en, style: AppTextStyles.body()),
                                    Text(
                                      line.vi,
                                      style: AppTextStyles.muted(size: 11),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        const Divider(color: AppColors.glassBorder, height: 1),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
