import 'package:flutter/material.dart';

import '../../../core/dictionary/free_dictionary_api.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/translation/app_translator.dart';
import '../../../core/tts/app_tts.dart';

class _WordLookup {
  const _WordLookup({
    required this.ipa,
    required this.pos,
    required this.meaningVi,
    required this.definitionEn,
  });
  final String ipa;
  final String pos;
  final String meaningVi;
  final String definitionEn;
}

class WordPopupSheet extends StatefulWidget {
  const WordPopupSheet({
    super.key,
    required this.word,
    required this.sentenceEn,
    required this.sentenceVi,
  });

  final String word;
  final String sentenceEn;
  final String sentenceVi;

  @override
  State<WordPopupSheet> createState() => _WordPopupSheetState();
}

class _WordPopupSheetState extends State<WordPopupSheet> {
  late final Future<_WordLookup> _lookup = _load();

  Future<_WordLookup> _load() async {
    final results = await Future.wait([
      FreeDictionaryApi.lookup(widget.word),
      AppTranslator.instance
          .translateToVietnamese(widget.word)
          .catchError((_) => ''),
    ]);
    final entry = results[0] as DictionaryEntry?;
    final meaningVi = results[1] as String;
    return _WordLookup(
      ipa: entry?.ipa ?? '—',
      pos: entry != null && entry.partOfSpeech.isNotEmpty
          ? posLabel(entry.partOfSpeech)
          : 'Chưa rõ từ loại',
      meaningVi: meaningVi.isNotEmpty
          ? meaningVi
          : '(không dịch được — kiểm tra mạng)',
      definitionEn: entry?.definition ?? '',
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
                    if (info.definitionEn.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        info.definitionEn,
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
                  'TRONG BÀI HÁT',
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
                  label: 'Nghe phát âm',
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
                  label: 'Lưu từ',
                  filled: false,
                  icon: const Icon(
                    Icons.add_rounded,
                    color: AppColors.textPrimary,
                    size: 16,
                  ),
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
