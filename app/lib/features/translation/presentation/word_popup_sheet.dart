import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/tts/app_tts.dart';

/// Từ điển rút gọn cho demo — sau này thay bằng google_mlkit_translation
/// hoặc dữ liệu song ngữ đi kèm từng bài hát (xem docs/research-translation-tts.md).
const Map<String, _WordInfo> _miniDictionary = {
  'rain': _WordInfo(ipa: '/reɪn/', pos: 'Danh từ', meaning: 'mưa'),
  'storm': _WordInfo(
    ipa: '/stɔːrm/',
    pos: 'Danh từ',
    meaning: 'cơn bão, cơn giông',
  ),
  'warmth': _WordInfo(ipa: '/wɔːrmθ/', pos: 'Danh từ', meaning: 'hơi ấm'),
  'standing': _WordInfo(
    ipa: '/ˈstændɪŋ/',
    pos: 'Động từ (V-ing)',
    meaning: 'đang đứng',
  ),
  'learning': _WordInfo(
    ipa: '/ˈlɜːrnɪŋ/',
    pos: 'Động từ (V-ing)',
    meaning: 'đang học',
  ),
};

class _WordInfo {
  const _WordInfo({
    required this.ipa,
    required this.pos,
    required this.meaning,
  });
  final String ipa;
  final String pos;
  final String meaning;
}

class WordPopupSheet extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final key = word.toLowerCase();
    final info =
        _miniDictionary[key] ??
        const _WordInfo(
          ipa: '—',
          pos: 'Chưa có dữ liệu',
          meaning: '(chưa có trong từ điển demo)',
        );

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(word, style: AppTextStyles.heading(size: 28)),
                  Text(
                    info.ipa,
                    style: AppTextStyles.body(
                      size: 14,
                      color: const Color(0xFF9DB4FF),
                    ),
                  ),
                ],
              ),
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
                  info.pos,
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
          Text(
            info.meaning,
            style: AppTextStyles.body(size: 16, weight: FontWeight.w700),
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
                  sentenceEn,
                  style: AppTextStyles.body(size: 14, weight: FontWeight.w700),
                ),
                Text(sentenceVi, style: AppTextStyles.muted()),
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
                  onTap: () => AppTts.instance.speak(word),
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
