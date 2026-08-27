import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/tts/app_tts.dart';

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
  bool _listening = false;
  bool _available = false;
  String _recognized = '';
  int? _score;
  List<bool> _wordResults = [];
  DateTime? _listenStartedAt;

  @override
  void initState() {
    super.initState();
    _speech.initialize().then((ok) => setState(() => _available = ok));
  }

  List<String> _normalize(String s) => s
      .toLowerCase()
      .replaceAll(RegExp(r"[^a-z' ]"), '')
      .split(' ')
      .where((w) => w.isNotEmpty)
      .toList();

  void _scoreAttempt() {
    final target = _normalize(widget.targetEn);
    final said = _normalize(_recognized);
    final results = <bool>[];
    for (var i = 0; i < target.length; i++) {
      results.add(i < said.length && said[i] == target[i]);
    }
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
    if (!_available) return;
    if (_listening) {
      await _speech.stop();
      setState(() => _listening = false);
      final startedAt = _listenStartedAt;
      if (startedAt != null) {
        final elapsed = DateTime.now().difference(startedAt).inSeconds;
        if (elapsed > 0) {
          ref.read(statsRepositoryProvider).addPracticeSeconds(elapsed);
        }
      }
      _scoreAttempt();
      return;
    }
    _listenStartedAt = DateTime.now();
    setState(() {
      _listening = true;
      _score = null;
      _recognized = '';
    });
    await _speech.listen(
      onResult: (result) =>
          setState(() => _recognized = result.recognizedWords),
      listenOptions: stt.SpeechListenOptions(localeId: 'en_US'),
    );
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final targetWords = _normalize(widget.targetEn);

    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.glassFill,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: const Icon(
                      Icons.chevron_left_rounded,
                      size: 18,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Text('Luyện phát âm', style: AppTextStyles.heading(size: 15)),
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
            GlowBox(
              borderRadius: 22,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ĐỌC THEO CÂU NÀY',
                    style: AppTextStyles.muted(size: 10)
                        .copyWith(letterSpacing: 0.6),
                  ),
                  const SizedBox(height: 6),
                  Text(widget.targetEn, style: AppTextStyles.heading(size: 18)),
                  Text(widget.targetVi, style: AppTextStyles.muted()),
                ],
              ),
            ),
            const Spacer(),
            if (!_available)
              Text(
                'Thiết bị chưa hỗ trợ hoặc chưa cấp quyền micro.',
                style: AppTextStyles.muted(),
              )
            else
              GestureDetector(
                onTap: _toggleListening,
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    gradient: AppColors.accentGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (_listening ? AppColors.pink : AppColors.blue)
                            .withValues(alpha: 0.5),
                        blurRadius: 50,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                  child: Icon(
                    _listening ? Icons.stop_rounded : Icons.mic_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Text(
              _listening
                  ? 'Đang nghe... chạm để dừng'
                  : 'Chạm để bắt đầu ghi âm',
              style: AppTextStyles.muted(),
            ),
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
                    label: 'Thử lại',
                    filled: false,
                    onTap: () => setState(() {
                      _score = null;
                      _recognized = '';
                    }),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PillButton(
                    label: 'Xong',
                    onTap: () => Navigator.of(context).maybePop(),
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
