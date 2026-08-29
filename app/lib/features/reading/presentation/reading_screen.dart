import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../translation/presentation/word_popup_sheet.dart';
import '../data/gutenberg_text.dart';
import '../data/reading_data.dart';

/// Doc 1 cuon sach, cham vao 1 tu de xem nghia + phat am (tai dung
/// WordPopupSheet dang dung o man Player cho lyric). Sach duoc tai tu
/// asset (.txt) va cat bo header/footer Project Gutenberg de de doc hon
/// - xem gutenberg_text.dart.
class ReadingScreen extends ConsumerStatefulWidget {
  const ReadingScreen({super.key, required this.book});
  final Book book;

  @override
  ConsumerState<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends ConsumerState<ReadingScreen> {
  late final Future<List<String>> _paragraphs = _load();

  Future<List<String>> _load() async {
    final raw = await rootBundle.loadString(widget.book.assetPath);
    return parseBookParagraphs(raw);
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
              ],
            ),
            const SizedBox(height: 6),
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
              child: FutureBuilder<List<String>>(
                future: _paragraphs,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.blue),
                    );
                  }
                  final paragraphs = snapshot.data!;
                  return ListView.builder(
                    itemCount: paragraphs.length,
                    itemBuilder: (context, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _ParagraphText(
                        paragraph: paragraphs[i],
                        onWordTap: _onWordTap,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParagraphText extends StatelessWidget {
  const _ParagraphText({required this.paragraph, required this.onWordTap});
  final String paragraph;
  final void Function(String word, String sentence) onWordTap;

  @override
  Widget build(BuildContext context) {
    final spans = <InlineSpan>[];
    for (final sentence in splitSentences(paragraph)) {
      for (final token in tokenizeSentence(sentence)) {
        if (isWordToken(token)) {
          spans.add(
            TextSpan(
              text: token,
              style: AppTextStyles.body(size: 15).copyWith(height: 1.6),
              recognizer: TapGestureRecognizer()
                ..onTap = () => onWordTap(token, sentence),
            ),
          );
        } else {
          spans.add(
            TextSpan(
              text: token,
              style: AppTextStyles.body(size: 15).copyWith(height: 1.6),
            ),
          );
        }
      }
    }
    return Text.rich(TextSpan(children: spans));
  }
}
