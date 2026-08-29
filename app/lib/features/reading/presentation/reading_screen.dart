import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
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
    _pageController.dispose();
    super.dispose();
  }

  List<String> _paragraphsForPage(int page) {
    final all = _paragraphs!;
    final start = page * _paragraphsPerPage;
    final end = ((page + 1) * _paragraphsPerPage).clamp(0, all.length);
    return all.sublist(start, end);
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    ReadingPrefs.saveParagraphProgress(
      widget.book.assetPath,
      index * _paragraphsPerPage,
    );
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
      builder: (_) =>
          WordPopupSheet(word: word, sentenceEn: sentence, sentenceVi: ''),
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
