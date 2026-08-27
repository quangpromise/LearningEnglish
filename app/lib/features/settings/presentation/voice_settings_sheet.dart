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
  List<VoiceOption>? _deviceVoices;

  @override
  void initState() {
    super.initState();
    AppTts.instance.loadEnglishVoices().then((voices) {
      if (mounted) setState(() => _deviceVoices = voices);
    });
  }

  Future<void> _chooseCloud(CloudVoice voice) async {
    setState(() {});
    await AppTts.instance.selectCloudVoice(voice);
    setState(() {});
    await AppTts.instance.speak('Hello, this is a preview of my voice.');
  }

  Future<void> _chooseDevice(VoiceOption voice) async {
    setState(() {});
    await AppTts.instance.selectVoice(voice);
    setState(() {});
    await AppTts.instance.speak('Hello, this is a preview of my voice.');
  }

  @override
  Widget build(BuildContext context) {
    final deviceVoices = _deviceVoices;
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
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
          const SizedBox(height: 16),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                Row(
                  children: [
                    Text(
                      'CHẤT LƯỢNG CAO',
                      style: AppTextStyles.muted(size: 10)
                          .copyWith(letterSpacing: 0.6),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.wifi_rounded,
                      size: 12,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 2),
                    Text('cần mạng', style: AppTextStyles.muted(size: 10)),
                  ],
                ),
                const SizedBox(height: 8),
                ...kCloudVoices.map(
                  (voice) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _VoiceTile(
                      title: voice.label,
                      subtitle: 'VoiceRSS',
                      selected:
                          AppTts.instance.isCloudMode &&
                          AppTts.instance.selectedCloud == voice,
                      onTap: () => _chooseCloud(voice),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'OFFLINE (GIỌNG TRÊN MÁY)',
                  style: AppTextStyles.muted(size: 10)
                      .copyWith(letterSpacing: 0.6),
                ),
                const SizedBox(height: 8),
                if (deviceVoices == null)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.blue),
                    ),
                  )
                else if (deviceVoices.isEmpty)
                  Text(
                    'Không tìm thấy giọng tiếng Anh nào trên máy này.',
                    style: AppTextStyles.muted(),
                  )
                else
                  ...deviceVoices.map(
                    (voice) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _VoiceTile(
                        title: _labelFor(voice.locale),
                        subtitle: voice.name,
                        selected:
                            !AppTts.instance.isCloudMode &&
                            AppTts.instance.selected == voice,
                        onTap: () => _chooseDevice(voice),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VoiceTile extends StatelessWidget {
  const _VoiceTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlowBox(
        borderRadius: 16,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.body(weight: FontWeight.w800),
                  ),
                  Text(subtitle, style: AppTextStyles.muted(size: 11)),
                ],
              ),
            ),
            Icon(
              selected ? Icons.check_circle_rounded : Icons.volume_up_rounded,
              color: selected ? AppColors.teal : AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
