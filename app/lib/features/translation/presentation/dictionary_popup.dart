import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/dictionary/free_dictionary_api.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/translation/app_translator.dart';
import '../../../core/tts/app_tts.dart';

enum _DictDirection { enToVi, viToEn }

/// Popup tra tu dien 2 chieu Anh<->Viet, mo tu icon rieng o man Home (khac
/// voi WordPopupSheet - popup do chi tra 1 tu co san trong lyric/sach, con
/// cai nay cho nguoi dung tu go bat ky tu/cau nao muon tra).
class DictionaryPopup extends ConsumerStatefulWidget {
  const DictionaryPopup({super.key});

  @override
  ConsumerState<DictionaryPopup> createState() => _DictionaryPopupState();
}

class _DictionaryPopupState extends ConsumerState<DictionaryPopup> {
  final _controller = TextEditingController();
  _DictDirection _direction = _DictDirection.enToVi;
  bool _loading = false;
  bool _searched = false;
  String? _error;
  String? _translated;
  String? _ipa;
  String? _pos;
  String? _definitionVi;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _lookup() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _loading = true;
      _searched = true;
      _error = null;
      _translated = null;
      _ipa = null;
      _pos = null;
      _definitionVi = null;
    });
    try {
      if (_direction == _DictDirection.enToVi) {
        final translated = await AppTranslator.instance.translateToVietnamese(
          text,
        );
        final entry = await FreeDictionaryApi.lookup(text);
        String? definitionVi;
        if (entry != null && entry.definition.isNotEmpty) {
          definitionVi = await AppTranslator.instance
              .translateToVietnamese(entry.definition)
              .catchError((_) => '');
        }
        if (!mounted) return;
        setState(() {
          _translated = translated;
          _ipa = (entry != null && entry.ipa.isNotEmpty) ? entry.ipa : null;
          _pos = (entry != null && entry.partOfSpeech.isNotEmpty)
              ? posLabel(entry.partOfSpeech)
              : null;
          _definitionVi = (definitionVi != null && definitionVi.isNotEmpty)
              ? definitionVi
              : null;
        });
      } else {
        final translated = await AppTranslator.instance.translateToEnglish(
          text,
        );
        if (!mounted) return;
        setState(() => _translated = translated);
      }
    } catch (_) {
      if (mounted) setState(() => _error = ref.tr('dictionary_error'));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _swapDirection() {
    setState(() {
      _direction = _direction == _DictDirection.enToVi
          ? _DictDirection.viToEn
          : _DictDirection.enToVi;
      _controller.clear();
      _searched = false;
      _translated = null;
      _ipa = null;
      _pos = null;
      _definitionVi = null;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEnToVi = _direction == _DictDirection.enToVi;
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        14,
        24,
        28 + MediaQuery.of(context).viewInsets.bottom,
      ),
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
          Text(
            ref.tr('dictionary_title'),
            style: AppTextStyles.heading(size: 18),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.glassFill,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: Text(
                    isEnToVi
                        ? ref.tr('dictionary_en_to_vi')
                        : ref.tr('dictionary_vi_to_en'),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body(
                      weight: FontWeight.w800,
                      size: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _swapDirection,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: AppColors.accentGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.swap_horiz_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GlowBox(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            borderRadius: 999,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    style: AppTextStyles.body(),
                    cursorColor: AppColors.purple,
                    onSubmitted: (_) => _lookup(),
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: isEnToVi
                          ? ref.tr('dictionary_hint_en')
                          : ref.tr('dictionary_hint_vi'),
                      hintStyle: AppTextStyles.muted(),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _lookup,
                  child: const Icon(
                    Icons.search_rounded,
                    color: AppColors.purple,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.blue,
                  ),
                ),
              ),
            )
          else if (_error != null)
            Text(
              _error!,
              style: AppTextStyles.muted().copyWith(color: AppColors.pink),
            )
          else if (_searched && _translated != null)
            GlowBox(
              borderRadius: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          _translated!,
                          style: AppTextStyles.body(
                            size: 18,
                            weight: FontWeight.w800,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => AppTts.instance.speak(
                          isEnToVi ? _controller.text.trim() : _translated!,
                        ),
                        child: const Icon(
                          Icons.volume_up_rounded,
                          color: AppColors.blue,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  if (_ipa != null || _pos != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (_ipa != null)
                          Text(
                            _ipa!,
                            style: AppTextStyles.body(
                              size: 13,
                              color: const Color(0xFF9DB4FF),
                            ),
                          ),
                        if (_ipa != null && _pos != null)
                          const SizedBox(width: 10),
                        if (_pos != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.teal.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              _pos!,
                              style: const TextStyle(
                                color: AppColors.teal,
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                  if (_definitionVi != null) ...[
                    const SizedBox(height: 8),
                    Text(_definitionVi!, style: AppTextStyles.muted(size: 12)),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}
