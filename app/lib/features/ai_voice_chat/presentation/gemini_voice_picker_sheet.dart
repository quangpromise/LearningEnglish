import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../data/gemini_voices.dart';

/// Bottom sheet chon 1 trong 30 giong dung san Gemini Live (xem
/// gemini_voices.dart) - dung chung cho AiVoiceChatScreen va man Ho so (muc
/// "English Voice"). Tra ve ten giong da chon qua Navigator.pop, hoac null
/// neu nguoi dung dong sheet ma khong chon.
class GeminiVoicePickerSheet extends StatelessWidget {
  const GeminiVoicePickerSheet({super.key, required this.current});

  final String current;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF12172E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.glassBorder,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Choose a voice', style: AppTextStyles.heading(size: 16)),
              const SizedBox(height: 4),
              Text(
                'Takes effect the next time you start a new chat session',
                style: AppTextStyles.muted(size: 11),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  itemCount: kGeminiVoices.length,
                  separatorBuilder: (_, _) =>
                      const Divider(color: AppColors.glassBorder, height: 1),
                  itemBuilder: (context, i) {
                    final voice = kGeminiVoices[i];
                    final selected = voice.name == current;
                    return GestureDetector(
                      onTap: () => Navigator.of(context).pop(voice.name),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    voice.name,
                                    style: AppTextStyles.body(
                                      weight: FontWeight.w800,
                                      color: selected ? AppColors.blue : null,
                                    ),
                                  ),
                                  Text(
                                    voice.style,
                                    style: AppTextStyles.muted(size: 11),
                                  ),
                                ],
                              ),
                            ),
                            if (selected)
                              const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.blue,
                                size: 20,
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
      },
    );
  }
}
