import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Placeholder cho tính năng "AI Voice Chat" — trò chuyện tự nhiên bằng
/// giọng nói, AI góp ý phát âm/ngữ pháp trong lúc chat.
///
/// CHƯA kết nối backend thật. Kiến trúc & lý do kỹ thuật xem
/// docs/research-ai-voice.md và backend/README.md — cần dựng xong
/// backend/gemini-proxy + backend/fallback-pipeline rồi nối WebSocket vào
/// đây trước khi tính năng này hoạt động.
class AiVoiceChatScreen extends StatelessWidget {
  const AiVoiceChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenBackground(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.graphic_eq_rounded,
                color: AppColors.blue,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text('AI Voice Chat', style: AppTextStyles.heading(size: 20)),
              const SizedBox(height: 8),
              Text(
                'Tính năng đang chờ kết nối backend (Gemini Live + fallback tự host). '
                'Xem docs/research-ai-voice.md để biết kiến trúc.',
                textAlign: TextAlign.center,
                style: AppTextStyles.muted(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
