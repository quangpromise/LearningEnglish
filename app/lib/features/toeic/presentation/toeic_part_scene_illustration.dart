import 'package:flutter/material.dart';

import '../data/toeic_models.dart';

/// "Ảnh chụp" cho TOEIC Part 1 (Photographs) - vẽ HOÀN TOÀN bằng widget
/// (Icon đặt trên nền màu), KHÔNG dùng ảnh chụp thật để tránh rủi ro bản
/// quyền (xem CLAUDE.md) - cùng kỹ thuật với StoryIllustration
/// (story_illustration.dart), chỉ khác là vị trí icon lấy từ dữ liệu
/// [ToeicIllustrationSpec] (tỷ lệ 0.0-1.0 trong khung 16:9) thay vì toạ độ
/// pixel cố định, vì mỗi câu Part 1 cần 1 "cảnh" khác nhau.
class ToeicPartSceneIllustration extends StatelessWidget {
  const ToeicPartSceneIllustration({super.key, required this.spec});

  final ToeicIllustrationSpec spec;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: ColoredBox(
          color: spec.backgroundColor,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  for (final scene in spec.icons)
                    Positioned(
                      left: scene.dx * constraints.maxWidth - scene.size / 2,
                      top: scene.dy * constraints.maxHeight - scene.size / 2,
                      child: Icon(
                        scene.icon,
                        size: scene.size,
                        color: Colors.white.withValues(alpha: 0.95),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
