import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/tts/app_tts.dart';

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
  Future<void> _choose(CloudVoice voice) async {
    await AppTts.instance.selectCloudVoice(voice);
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
          Text('Giọng đọc tiếng Anh', style: AppTextStyles.heading(size: 18)),
          const SizedBox(height: 4),
          Text(
            'Chạm để chọn và nghe thử — áp dụng cho mọi chỗ phát âm mẫu trong app.',
            style: AppTextStyles.muted(),
          ),
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
                          voice.label,
                          style: AppTextStyles.body(weight: FontWeight.w800),
                        ),
                      ),
                      Icon(
                        AppTts.instance.selectedCloud == voice
                            ? Icons.check_circle_rounded
                            : Icons.volume_up_rounded,
                        color: AppTts.instance.selectedCloud == voice
                            ? AppColors.teal
                            : AppColors.textMuted,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
