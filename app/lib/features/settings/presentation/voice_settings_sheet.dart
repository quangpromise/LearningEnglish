import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/tts/app_tts.dart';
import '../../ai_voice_chat/data/gemini_voices.dart';
import '../../ai_voice_chat/presentation/gemini_voice_picker_sheet.dart';

String _voiceLabel(WidgetRef ref, String locale) => switch (locale) {
  'en-us' => ref.tr('voice_en_us'),
  'en-gb' => ref.tr('voice_en_gb'),
  'en-au' => ref.tr('voice_en_au'),
  'en-in' => ref.tr('voice_en_in'),
  'en-ca' => ref.tr('voice_en_ca'),
  _ => locale,
};

Future<void> showVoiceSettingsSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => const _VoiceSettingsSheet(),
  );
}

class _VoiceSettingsSheet extends ConsumerStatefulWidget {
  const _VoiceSettingsSheet();

  @override
  ConsumerState<_VoiceSettingsSheet> createState() =>
      _VoiceSettingsSheetState();
}

class _VoiceSettingsSheetState extends ConsumerState<_VoiceSettingsSheet> {
  @override
  void initState() {
    super.initState();
    // Nghe GeminiVoiceSelection (nguon dung chung voi AiVoiceChatScreen) de
    // sheet nay luon hien dung giong dang chon, ke ca khi doi tu man kia.
    GeminiVoiceSelection.instance.addListener(_onGeminiVoiceChanged);
  }

  void _onGeminiVoiceChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    GeminiVoiceSelection.instance.removeListener(_onGeminiVoiceChanged);
    super.dispose();
  }

  Future<void> _choose(CloudVoice voice) async {
    await AppTts.instance.selectCloudVoice(voice);
    setState(() {});
    await AppTts.instance.speak('Hello, this is a preview of my voice.');
  }

  Future<void> _chooseGeminiVoice() async {
    final current = GeminiVoiceSelection.instance.value;
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => GeminiVoicePickerSheet(current: current),
    );
    if (picked == null) return;
    if (picked != current) await GeminiVoiceSelection.instance.select(picked);
    // Chon 1 giong Gemini o day nghia la dung Gemini cho MOI tinh nang doc
    // tu/cau trong app (khong chi rieng luc AI Voice Chat tro chuyen) - xem
    // AppTts.selectGeminiVoice.
    await AppTts.instance.selectGeminiVoice();
    setState(() {});
    await AppTts.instance.speak('Hello, this is a preview of my voice.');
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
          Text(
            ref.tr('voice_settings_title'),
            style: AppTextStyles.heading(size: 18),
          ),
          const SizedBox(height: 4),
          Text(ref.tr('voice_settings_subtitle'), style: AppTextStyles.muted()),
          const SizedBox(height: 16),
          ...kCloudVoices.map(
            (voice) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => _choose(voice),
                child: GlowBox(
                  borderRadius: 16,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _voiceLabel(ref, voice.locale),
                          style: AppTextStyles.body(weight: FontWeight.w800),
                        ),
                      ),
                      Icon(
                        (AppTts.instance.selectedCloud == voice &&
                                !AppTts.instance.useGemini)
                            ? Icons.check_circle_rounded
                            : Icons.volume_up_rounded,
                        color:
                            (AppTts.instance.selectedCloud == voice &&
                                !AppTts.instance.useGemini)
                            ? AppColors.teal
                            : AppColors.textMuted,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Gemini (used for AI Voice Chat too)',
            style: AppTextStyles.muted(size: 11).copyWith(letterSpacing: 0.4),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _chooseGeminiVoice,
            child: GlowBox(
              borderRadius: 16,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      GeminiVoiceSelection.instance.value,
                      style: AppTextStyles.body(
                        weight: FontWeight.w800,
                        color: AppTts.instance.useGemini
                            ? AppColors.teal
                            : null,
                      ),
                    ),
                  ),
                  Icon(
                    AppTts.instance.useGemini
                        ? Icons.check_circle_rounded
                        : Icons.chevron_right_rounded,
                    color: AppTts.instance.useGemini
                        ? AppColors.teal
                        : AppColors.textMuted,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
