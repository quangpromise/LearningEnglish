import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/tts/app_tts.dart';
import '../../translation/presentation/word_popup_sheet.dart';
import '../data/gutenberg_text.dart';
import '../data/reading_data.dart';
import '../data/reading_prefs.dart';

const _baseFontSize = 15.0;

/// So doan van goi thanh 1 "trang" - co dinh, khong phu thuoc kich co chu,
/// de tranh phai do lai chieu cao that su (phuc tap, de loi) moi lan doi
/// co chu. Trang co the dai/ngan hon 1 man hinh tuy do dai doan van - moi
/// trang duoc boc trong 1 scroll view rieng de khong bao gio bi cat mat
/// noi dung khi co chu lon.
const _paragraphsPerPage = 6;

/// Doc 1 cuon sach theo tung trang (bam mui ten hoac vuot de chuyen trang),
/// cham vao 1 tu de xem nghia + phat am (tai dung WordPopupSheet dang dung
/// o man Player cho lyric), co the chinh co chu va tu dong nho trang dang
/// doc de lan sau mo lai dung vi tri.
class ReadingScreen extends ConsumerStatefulWidget {
  const ReadingScreen({super.key, required this.book});
  final Book book;

  @override
  ConsumerState<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends ConsumerState<ReadingScreen> {
  final _pageController = PageController();
  List<String>? _paragraphs;
  double _fontScale = ReadingPrefs.defaultFontScale;
  int _currentPage = 0;
  int _pageCount = 1;
  bool _ready = false;

  // Doc trang thanh tieng tung cau (nut loa) - xem _playFromSentence(). Dung
  // 1 "token" tang dan de biet loi await speakAndWait() dang cho co con hop
  // le khong (bi huy giua chung boi rewind/stop/doi trang thi token doi,
  // vong lap tu dung lai dung luc thay vi doc tiep cau cu).
  bool _reading = false;
  int _sentenceIndex = 0;
  int _speechToken = 0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final results = await Future.wait([
      rootBundle.loadString(widget.book.assetPath),
      ReadingPrefs.loadFontScale(),
      ReadingPrefs.loadParagraphProgress(widget.book.assetPath),
    ]);
    final paragraphs = parseBookParagraphs(results[0] as String);
    final fontScale = results[1] as double;
    final savedParagraphIndex = results[2] as int;
    final pageCount = paragraphs.isEmpty
        ? 1
        : (paragraphs.length / _paragraphsPerPage).ceil();
    final initialPage = (savedParagraphIndex ~/ _paragraphsPerPage).clamp(
      0,
      pageCount - 1,
    );
    if (!mounted) return;
    setState(() {
      _paragraphs = paragraphs;
      _fontScale = fontScale;
      _pageCount = pageCount;
      _currentPage = initialPage;
      _ready = true;
    });
    if (initialPage != 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _pageController.hasClients) {
          _pageController.jumpToPage(initialPage);
        }
      });
    }
  }

  @override
  void dispose() {
    _speechToken++;
    AppTts.instance.stopSpeaking();
    _pageController.dispose();
    super.dispose();
  }

  List<String> _paragraphsForPage(int page) {
    final all = _paragraphs!;
    final start = page * _paragraphsPerPage;
    final end = ((page + 1) * _paragraphsPerPage).clamp(0, all.length);
    return all.sublist(start, end);
  }

  List<String> _sentencesForPage(int page) {
    final sentences = <String>[];
    for (final p in _paragraphsForPage(page)) {
      sentences.addAll(splitSentences(p));
    }
    return sentences;
  }

  void _onPageChanged(int index) {
    _stopReading();
    setState(() {
      _currentPage = index;
      _sentenceIndex = 0;
    });
    ReadingPrefs.saveParagraphProgress(
      widget.book.assetPath,
      index * _paragraphsPerPage,
    );
  }

  /// Doc lien tuc tu cau [startIndex] tro di, tu dung lai khi het trang, bi
  /// bam Dung, hoac chuyen trang/thoat man hinh giua chung.
  Future<void> _playFromSentence(int startIndex) async {
    final sentences = _sentencesForPage(_currentPage);
    if (sentences.isEmpty) return;
    final token = ++_speechToken;
    var index = startIndex.clamp(0, sentences.length - 1);
    setState(() {
      _reading = true;
      _sentenceIndex = index;
    });
    while (mounted && token == _speechToken && index < sentences.length) {
      await AppTts.instance.speakAndWait(sentences[index]);
      if (!mounted || token != _speechToken) return;
      index++;
      if (index >= sentences.length) break;
      setState(() => _sentenceIndex = index);
    }
    if (mounted && token == _speechToken) setState(() => _reading = false);
  }

  void _togglePlay() {
    if (_reading) {
      _stopReading();
    } else {
      _playFromSentence(_sentenceIndex);
    }
  }

  void _stopReading() {
    _speechToken++;
    AppTts.instance.stopSpeaking();
    if (mounted) setState(() => _reading = false);
  }

  /// "Tua lai" = quay ve cau TRUOC do (khong the tua theo giay vi giong doc
  /// may/cloud khac nhau khong chia se chung 1 timeline audio) - neu dang
  /// doc thi tiep tuc doc luon tu cau do, neu dang dung thi chi luu vi tri
  /// cho lan bam Play tiep theo.
  void _rewind() {
    final sentences = _sentencesForPage(_currentPage);
    if (sentences.isEmpty) return;
    final target = _sentenceIndex > 0 ? _sentenceIndex - 1 : 0;
    _speechToken++;
    AppTts.instance.stopSpeaking();
    if (_reading) {
      _playFromSentence(target);
    } else {
      setState(() => _sentenceIndex = target);
    }
  }

  void _changeFontScale(double delta) {
    final next = (_fontScale + delta).clamp(
      ReadingPrefs.minFontScale,
      ReadingPrefs.maxFontScale,
    );
    if (next == _fontScale) return;
    setState(() => _fontScale = next);
    ReadingPrefs.saveFontScale(next);
  }

  void _onWordTap(String word, String sentence) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => WordPopupSheet(
        word: word,
        sentenceEn: sentence,
        sentenceVi: '',
        sourceLabelKey: 'word_in_text',
      ),
    );
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
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
                      Text(
                        widget.book.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.heading(size: 15),
                      ),
                      Text(
                        widget.book.author,
                        style: AppTextStyles.muted(size: 11),
                      ),
                    ],
                  ),
                ),
                _FontSizeButton(
                  icon: Icons.text_decrease_rounded,
                  onTap: () => _changeFontScale(-0.1),
                ),
                const SizedBox(width: 6),
                _FontSizeButton(
                  icon: Icons.text_increase_rounded,
                  onTap: () => _changeFontScale(0.1),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: widget.book.color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                ref.tr('reading_tap_hint'),
                style: TextStyle(
                  color: widget.book.color,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
            if (_ready) ...[
              const SizedBox(height: 10),
              _ReadingAudioBar(
                color: widget.book.color,
                reading: _reading,
                sentenceIndex: _sentenceIndex,
                sentenceCount: _sentencesForPage(_currentPage).length,
                onTogglePlay: _togglePlay,
                onRewind: _rewind,
                onStop: _stopReading,
              ),
            ],
            const SizedBox(height: 12),
            Expanded(
              child: !_ready
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.blue),
                    )
                  : PageView.builder(
                      controller: _pageController,
                      itemCount: _pageCount,
                      onPageChanged: _onPageChanged,
                      itemBuilder: (context, i) => SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _paragraphsForPage(i)
                              .map(
                                (p) => Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _ParagraphText(
                                    paragraph: p,
                                    fontSize: _baseFontSize * _fontScale,
                                    onWordTap: _onWordTap,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
            ),
            if (_ready) ...[
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _PageNavButton(
                    icon: Icons.chevron_left_rounded,
                    onTap: _currentPage > 0
                        ? () => _goToPage(_currentPage - 1)
                        : null,
                  ),
                  Text(
                    '${_currentPage + 1} / $_pageCount',
                    style: AppTextStyles.muted(size: 12),
                  ),
                  _PageNavButton(
                    icon: Icons.chevron_right_rounded,
                    onTap: _currentPage < _pageCount - 1
                        ? () => _goToPage(_currentPage + 1)
                        : null,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FontSizeButton extends StatelessWidget {
  const _FontSizeButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: AppColors.glassFill,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Icon(icon, size: 16, color: AppColors.textPrimary),
      ),
    );
  }
}

class _PageNavButton extends StatelessWidget {
  const _PageNavButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.glassFill,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Icon(
          icon,
          color: enabled ? AppColors.textPrimary : AppColors.textMuted,
        ),
      ),
    );
  }
}

/// Thanh dieu khien doc trang thanh tieng - nut loa bat/tam dung, tua lai 1
/// cau, va dung han. Moi trang deu co thanh nay (khong an di khi khong doc)
/// de nguoi dung luon thay duoc tinh nang.
class _ReadingAudioBar extends StatelessWidget {
  const _ReadingAudioBar({
    required this.color,
    required this.reading,
    required this.sentenceIndex,
    required this.sentenceCount,
    required this.onTogglePlay,
    required this.onRewind,
    required this.onStop,
  });

  final Color color;
  final bool reading;
  final int sentenceIndex;
  final int sentenceCount;
  final VoidCallback onTogglePlay;
  final VoidCallback onRewind;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    if (sentenceCount == 0) return const SizedBox.shrink();
    return GlowBox(
      borderRadius: 999,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        children: [
          _AudioIconButton(
            icon: Icons.replay_5_rounded,
            onTap: onRewind,
            color: color,
          ),
          const SizedBox(width: 4),
          _AudioIconButton(
            icon: reading
                ? Icons.pause_circle_filled_rounded
                : Icons.play_circle_fill_rounded,
            onTap: onTogglePlay,
            color: color,
            large: true,
          ),
          const SizedBox(width: 4),
          _AudioIconButton(
            icon: Icons.stop_circle_rounded,
            onTap: reading ? onStop : null,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Câu ${(sentenceIndex + 1).clamp(1, sentenceCount)}/$sentenceCount',
              style: AppTextStyles.muted(size: 11).copyWith(height: 1.0),
            ),
          ),
        ],
      ),
    );
  }
}

class _AudioIconButton extends StatelessWidget {
  const _AudioIconButton({
    required this.icon,
    required this.onTap,
    required this.color,
    this.large = false,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final Color color;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        icon,
        size: large ? 32 : 24,
        color: enabled ? color : AppColors.textMuted,
      ),
    );
  }
}

class _ParagraphText extends StatelessWidget {
  const _ParagraphText({
    required this.paragraph,
    required this.fontSize,
    required this.onWordTap,
  });
  final String paragraph;
  final double fontSize;
  final void Function(String word, String sentence) onWordTap;

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.body(size: fontSize).copyWith(height: 1.6);
    final spans = <InlineSpan>[];
    for (final sentence in splitSentences(paragraph)) {
      for (final token in tokenizeSentence(sentence)) {
        if (isWordToken(token)) {
          spans.add(
            TextSpan(
              text: token,
              style: style,
              recognizer: TapGestureRecognizer()
                ..onTap = () => onWordTap(token, sentence),
            ),
          );
        } else {
          spans.add(TextSpan(text: token, style: style));
        }
      }
    }
    return Text.rich(TextSpan(children: spans));
  }
}
