import 'package:flutter/material.dart';

import '../data/toeic_models.dart';

/// "Ảnh chụp" cho TOEIC Part 1 (Photographs). Ưu tiên hiển thị
/// [ToeicIllustrationSpec.imageAssetPath] nếu có - ảnh THẬT do người dùng tự
/// tạo bằng Gemini AI (gốc hoàn toàn, không phải stock photo bên thứ ba, xem
/// pubspec.yaml). Nếu chưa có ảnh, rơi về vẽ minh hoạ bằng Icon đặt trên nền
/// màu (kỹ thuật giống StoryIllustration ở story_illustration.dart) để
/// tránh màn hình trống trong lúc chưa có đủ ảnh cho mọi câu.
class ToeicPartSceneIllustration extends StatelessWidget {
  const ToeicPartSceneIllustration({super.key, required this.spec});

  final ToeicIllustrationSpec spec;

  @override
  Widget build(BuildContext context) {
    final imagePath = spec.imageAssetPath;
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: imagePath != null
            ? Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _iconFallback(),
              )
            : _iconFallback(),
      ),
    );
  }

  Widget _iconFallback() {
    return ColoredBox(
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
    );
  }
}
