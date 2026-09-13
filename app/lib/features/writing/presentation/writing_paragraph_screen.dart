import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_language.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../data/writing_paragraph_data.dart';
import '../data/writing_progress.dart';
import '../data/writing_scoring.dart';

/// Man dich TUNG CAU mot cua 1 doan van - moi cau go xong bam "Cham diem" la
/// thay ket qua NGAY (khac ban truoc: go het ca doan roi moi cham 1 lan),
/// mirror dung flow cua WritingVocabQuizScreen (progress bar + tu dong
/// chuyen cau sau khi cham). Het cau cuoi -> man ket qua tong % + danh sach
/// tung cau.
class WritingParagraphScreen extends ConsumerStatefulWidget {
  const WritingParagraphScreen({super.key, required this.paragraph});

  final WritingParagraph paragraph;

  @override
  ConsumerState<WritingParagraphScreen> createState() =>
      _WritingParagraphScreenState();
}

class _WritingParagraphScreenState
    extends ConsumerState<WritingParagraphScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  int _index = 0;
  SentenceScore? _result;
  final List<SentenceScore> _results = [];
  bool _finished = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  WritingSentence get _current => widget.paragraph.sentences[_index];

  void _submit() {
    if (_result != null) return;
    final result = scoreSentenceBest(
      targetEn: _current.en,
      alternatives: _current.alternatives,
      userInput: _controller.text,
    );
    setState(() {
      _result = result;
      _results.add(result);
    });
  }

  /// Nguoi dung tu bam de chuyen cau (khong con tu dong chuyen sau khi
  /// cham) - theo yeu cau: xem xong ket qua/giai thich roi moi qua cau moi.
  void _next() {
    if (_index < widget.paragraph.sentences.length - 1) {
      setState(() {
        _index++;
        _result = null;
        _controller.clear();
      });
      _focusNode.requestFocus();
    } else {
      setState(() => _finished = true);
      _markDone();
    }
  }

  /// Bai thuoc ngan hang theo cap -> danh dau da lam xong (dau tick + ban
  /// tay goi y chuyen sang bai ke tiep). Bo 24 doan cu (level null) khong
  /// theo doi tien do.
  Future<void> _markDone() async {
    if (widget.paragraph.level == null) return;
    await ref
        .read(writingProgressRepositoryProvider)
        .markDone(widget.paragraph.id);
    ref.invalidate(writingDoneParagraphsProvider);
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) return _buildResult(context);

    final sentences = widget.paragraph.sentences;
    final borderColor = _result == null
        ? AppColors.glassBorder
        : (_result!.score >= 80
              ? AppColors.teal
              : (_result!.score >= 40 ? AppColors.amber : AppColors.pink));

    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
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
                      Icons.close_rounded,
                      size: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    children: List.generate(sentences.length, (i) {
                      final done = i <= _index;
                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          height: 8,
                          decoration: BoxDecoration(
                            gradient: done ? AppColors.accentGradient : null,
                            color: done ? null : AppColors.glassFill,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.teal.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${ref.tr('vocab_question_label')} ${_index + 1}/${sentences.length}',
                style: const TextStyle(
                  color: AppColors.teal,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(height: 14),
            GlowBox(
              borderRadius: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ref.tr('writing_paragraph_translate_for'),
                    style: AppTextStyles.muted(size: 10)
                        .copyWith(letterSpacing: 0.6),
                  ),
                  const SizedBox(height: 6),
                  Text(_current.vi, style: AppTextStyles.heading(size: 18)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              autofocus: true,
              enabled: _result == null,
              // maxLines: null van cho tu dong xuong hang khi go qua dai
              // (word-wrap tu nhien cua TextField) - KHONG lien quan gi den
              // phim Enter, chi anh huong hien thi. textInputAction.done +
              // onSubmitted moi la thu quyet dinh phim Enter lam gi: an nut
              // "Done" tren ban phim thay vi nut xuong dong, bam vao se goi
              // _submit() giong nhap tu vung (1 dong, Enter = nop bai) thay
              // vi chen ky tu \n nhu truoc (theo yeu cau nguoi dung).
              maxLines: null,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              style: AppTextStyles.body(size: 14.5, weight: FontWeight.w700),
              decoration: InputDecoration(
                hintText: ref.tr('writing_paragraph_type_hint'),
                hintStyle: AppTextStyles.muted(),
                filled: true,
                fillColor: AppColors.glassFill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: borderColor),
                ),
              ),
            ),
            if (_result != null) ...[
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: _ResultExplain(
                    result: _result!,
                    sentence: _current,
                    borderColor: borderColor,
                  ),
                ),
              ),
            ] else
              const Spacer(),
            SizedBox(
              width: double.infinity,
              child: PillButton(
                label: ref.tr(
                  _result == null
                      ? 'writing_check_button'
                      : (_index < sentences.length - 1
                            ? 'writing_next_button'
                            : 'writing_see_result_button'),
                ),
                accentGradient: LinearGradient(
                  colors: [
                    AppColors.teal,
                    AppColors.teal.withValues(alpha: 0.65),
                  ],
                ),
                accentColor: AppColors.teal,
                onTap: _result == null ? _submit : _next,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResult(BuildContext context) {
    final total = _results.isEmpty
        ? 0
        : (_results.fold<int>(0, (sum, s) => sum + s.score) / _results.length)
              .round();
    final lang = ref.watch(appLanguageProvider);
    final title = lang == AppLanguage.en
        ? widget.paragraph.titleEn
        : widget.paragraph.titleVi;
    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        child: Column(
          children: [
            Text(
              title.toUpperCase(),
              style: AppTextStyles.muted(size: 11)
                  .copyWith(color: const Color(0xFF7BE6D6), letterSpacing: 1),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: 160,
              height: 160,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: CircularProgressIndicator(
                      value: total / 100,
                      strokeWidth: 10,
                      backgroundColor: Colors.white.withValues(alpha: 0.08),
                      color: AppColors.teal,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$total%',
                        style: AppTextStyles.heading(size: 24)
                            .copyWith(height: 1.0),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ref.tr('writing_overall_score'),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.muted(size: 11)
                            .copyWith(height: 1.0),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: ListView.separated(
                itemCount: widget.paragraph.sentences.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final s = widget.paragraph.sentences[i];
                  final score = i < _results.length ? _results[i].score : 0;
                  final color = score >= 80
                      ? AppColors.teal
                      : (score >= 40 ? AppColors.amber : AppColors.pink);
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.glassFill,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.18),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '$score',
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.w800,
                                fontSize: 10.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            s.en,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.body(
                              size: 12,
                              weight: FontWeight.w600,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: PillButton(
                label: ref.tr('vocab_done'),
                accentGradient: LinearGradient(
                  colors: [
                    AppColors.teal,
                    AppColors.teal.withValues(alpha: 0.65),
                  ],
                ),
                accentColor: AppColors.teal,
                onTap: () {
                  final nav = Navigator.of(context);
                  nav.pop();
                  nav.pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultExplain extends ConsumerWidget {
  const _ResultExplain({
    required this.result,
    required this.sentence,
    required this.borderColor,
  });

  final SentenceScore result;
  final WritingSentence sentence;
  final Color borderColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '${result.score}%',
              style: TextStyle(
                color: borderColor,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (var i = 0; i < result.targetWords.length; i++)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color:
                      (result.wordResults[i] ? AppColors.teal : AppColors.pink)
                          .withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  result.targetWords[i],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: result.wordResults[i]
                        ? AppColors.teal
                        : AppColors.pink,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${ref.tr('writing_correct_answer_label')}: '
                '${result.targetText.isEmpty ? sentence.en : result.targetText}',
                style: AppTextStyles.body(size: 12, weight: FontWeight.w700),
              ),
              const SizedBox(height: 3),
              Text(
                '${ref.tr('writing_tense_label')}: ${sentence.tenseLabel}',
                style: AppTextStyles.muted(size: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
