import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/dictionary/free_dictionary_api.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/translation/app_translator.dart';
import '../../../core/tts/app_tts.dart';
import '../../vocabulary/data/daily_words_repository.dart';
import '../../vocabulary/presentation/daily_words_controller.dart';

class _WordLookup {
  const _WordLookup({
    required this.ipa,
    required this.pos,
    required this.meaningVi,
    required this.definitionVi,
  });
  final String ipa;
  final String pos;
  final String meaningVi;

  /// Giai thich (dictionary definition) da dich sang tieng Viet - truoc day
  /// hien nguyen ban tieng Anh tu FreeDictionaryApi, kho hieu voi nguoi moi
  /// hoc; gio dich luon sang tieng Viet giong nhu nghia chinh.
  final String definitionVi;
}

class WordPopupSheet extends ConsumerStatefulWidget {
  const WordPopupSheet({
    super.key,
    required this.word,
    required this.sentenceEn,
    required this.sentenceVi,
    this.sourceLabelKey = 'word_in_song',
  });

  final String word;
  final String sentenceEn;
  final String sentenceVi;

  /// Key i18n cho nhan phia tren cau ngu canh - 'word_in_song' (mac dinh,
  /// dung khi mo tu Player) hoac 'word_in_text' (dung khi mo tu man Doc
  /// sach, vi khong phai "bai hat").
  final String sourceLabelKey;

  @override
  ConsumerState<WordPopupSheet> createState() => _WordPopupSheetState();
}

class _WordPopupSheetState extends ConsumerState<WordPopupSheet> {
  late final Future<_WordLookup> _lookup = _load();

  // Ket qua tra tu, luu lai de nut "Luu" ben duoi dung khi them vao danh
  // sach hoc hom nay (can vi/ipa, khong chi rieng "word"). Tu tra tu KHONG
  // con tu dong tinh la "da hoc" nua - chi khi tra loi DUNG trong quiz nhac
  // hom nay (DailyQuizPopupScreen) moi ghi vao thong ke "Tu da hoc" o Ho so.
  _WordLookup? _result;

  Future<_WordLookup> _load() async {
    final entry = await FreeDictionaryApi.lookup(widget.word);
    final results = await Future.wait([
      AppTranslator.instance
          .translateToVietnamese(widget.word)
          .catchError((_) => ''),
      (entry != null && entry.definition.isNotEmpty)
          ? AppTranslator.instance
                .translateToVietnamese(entry.definition)
                .catchError((_) => '')
          : Future.value(''),
    ]);
    final meaningVi = results[0];
    final definitionVi = results[1];
    final result = _WordLookup(
      ipa: (entry != null && entry.ipa.isNotEmpty) ? entry.ipa : '—',
      pos: entry != null && entry.partOfSpeech.isNotEmpty
          ? posLabel(entry.partOfSpeech)
          : ref.tr('word_no_pos'),
      meaningVi: meaningVi.isNotEmpty
          ? meaningVi
          : ref.tr('word_translate_error'),
      definitionVi: definitionVi,
    );
    if (mounted) setState(() => _result = result);
    return result;
  }

  Future<void> _saveToDaily() async {
    final info = _result;
    if (info == null) return;
    final added = await ref
        .read(dailyWordsControllerProvider.notifier)
        .addWord(
          DailyWordEntry(
            en: widget.word,
            vi: info.meaningVi,
            ipa: info.ipa == '—' ? '' : info.ipa,
          ),
        );
    if (!mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    final nav = Navigator.of(context);
    nav.pop();
    messenger?.showSnackBar(
      SnackBar(
        content: Text(
          ref.tr(added ? 'word_saved_to_daily' : 'daily_words_full'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
      decoration: const BoxDecoration(
        color: Color(0xEB0F1326),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder<_WordLookup>(
            future: _lookup,
            builder: (context, snapshot) {
              final loading = !snapshot.hasData;
              final info = snapshot.data;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.word,
                            style: AppTextStyles.heading(size: 28),
                          ),
                          Text(
                            loading ? '...' : info!.ipa,
                            style: AppTextStyles.body(
                              size: 14,
                              color: const Color(0xFF9DB4FF),
                            ),
                          ),
                        ],
                      ),
                      if (!loading)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.teal.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            info!.pos,
                            style: const TextStyle(
                              color: AppColors.teal,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (loading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.blue,
                        ),
                      ),
                    )
                  else ...[
                    Text(
                      info!.meaningVi,
                      style: AppTextStyles.body(
                        size: 16,
                        weight: FontWeight.w700,
                      ),
                    ),
                    if (info.definitionVi.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        info.definitionVi,
                        style: AppTextStyles.muted(size: 12),
                      ),
                    ],
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          GlowBox(
            borderRadius: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ref.tr(widget.sourceLabelKey),
                  style: AppTextStyles.muted(size: 10)
                      .copyWith(letterSpacing: 0.6),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.sentenceEn,
                  style: AppTextStyles.body(size: 14, weight: FontWeight.w700),
                ),
                Text(widget.sentenceVi, style: AppTextStyles.muted()),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: PillButton(
                  label: ref.tr('word_listen_pronunciation'),
                  icon: const Icon(
                    Icons.volume_up_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                  onTap: () => AppTts.instance.speak(widget.word),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PillButton(
                  label: ref.tr('word_save'),
                  filled: false,
                  icon: const Icon(
                    Icons.add_rounded,
                    color: AppColors.textPrimary,
                    size: 16,
                  ),
                  onTap: _result == null ? null : _saveToDaily,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
