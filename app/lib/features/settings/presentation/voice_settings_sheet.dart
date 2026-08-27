import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/tts/app_tts.dart';

const _localeLabels = {
  'en-us': 'Tiếng Anh (Mỹ)',
  'en_us': 'Tiếng Anh (Mỹ)',
  'en-gb': 'Tiếng Anh (Anh)',
  'en_gb': 'Tiếng Anh (Anh)',
  'en-au': 'Tiếng Anh (Úc)',
  'en_au': 'Tiếng Anh (Úc)',
  'en-in': 'Tiếng Anh (Ấn Độ)',
  'en_in': 'Tiếng Anh (Ấn Độ)',
  'en-ie': 'Tiếng Anh (Ireland)',
  'en_ie': 'Tiếng Anh (Ireland)',
  'en-za': 'Tiếng Anh (Nam Phi)',
  'en_za': 'Tiếng Anh (Nam Phi)',
  'en-ca': 'Tiếng Anh (Canada)',
  'en_ca': 'Tiếng Anh (Canada)',
};

String _labelFor(String locale) =>
    _localeLabels[locale.toLowerCase()] ?? 'Tiếng Anh ($locale)';

Future<void> showVoiceSettingsSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => const _VoiceSettingsSheet(),
  );
}

class _VoiceSettingsSheet extends StatefulWidget {
  const _VoiceSettingsSheet();

  @override
  State<_VoiceSettingsSheet> createState() => _VoiceSettingsSheetState();
}

class _VoiceSettingsSheetState extends State<_VoiceSettingsSheet> {
  List<VoiceOption>? _voices;
  VoiceOption? _selected;

  @override
  void initState() {
    super.initState();
    _selected = AppTts.instance.selected;
    AppTts.instance.loadEnglishVoices().then((voices) {
      if (mounted) setState(() => _voices = voices);
    });
  }

  Future<void> _choose(VoiceOption voice) async {
    setState(() => _selected = voice);
    await AppTts.instance.selectVoice(voice);
    await AppTts.instance.speak('Hello, this is a preview of my voice.');
  }

  @override
  Widget build(BuildContext context) {
    final voices = _voices;
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
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
          Text('Giọng đọc tiếng Anh', style: AppTextStyles.heading(size: 18)),
          const SizedBox(height: 4),
          Text(
            'Chạm để chọn và nghe thử — áp dụng cho mọi chỗ phát âm mẫu trong app.',
            style: AppTextStyles.muted(),
          ),
          const SizedBox(height: 14),
          Flexible(
            child: voices == null
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.blue),
                    ),
                  )
                : voices.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'Không tìm thấy giọng tiếng Anh nào trên máy này. '
                      'Hãy kiểm tra cài đặt Text-to-Speech của điện thoại.',
                      style: AppTextStyles.muted(),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: voices.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final voice = voices[i];
                      final isSelected = _selected == voice;
                      return GestureDetector(
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _labelFor(voice.locale),
                                      style: AppTextStyles.body(
                                        weight: FontWeight.w800,
                                      ),
                                    ),
                                    Text(
                                      voice.name,
                                      style: AppTextStyles.muted(size: 11),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                isSelected
                                    ? Icons.check_circle_rounded
                                    : Icons.volume_up_rounded,
                                color: isSelected
                                    ? AppColors.teal
                                    : AppColors.textMuted,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
