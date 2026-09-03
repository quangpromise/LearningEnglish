import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// "Ảnh tĩnh" cho micro-story - vẽ HOÀN TOÀN bằng widget (không phải file
/// ảnh/asset bên ngoài) nên KHÔNG cần mục ghi công nào (khác 20 bài hát
/// CC-BY, xem features/attribution/) và không cần thêm dependency mới
/// (vd flutter_svg). Cùng tinh thần với `PlayerScreen` hiện tại - màn đó
/// cũng chưa có ảnh bìa riêng từng bài, dùng logo app thay thế
/// (`now_playing_service.dart`) - đây chỉ là 1 bước làm đẹp hơn logo app,
/// không phải hạ tầng ảnh dùng chung cho nhiều bài sau này.
class StoryIllustration extends StatelessWidget {
  const StoryIllustration({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color.withValues(alpha: 0.85), AppColors.bgTop],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.35),
              blurRadius: 40,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          alignment: Alignment.center,
          children: [
            for (final drop in _kRaindrops)
              Positioned(
                left: drop.dx,
                top: drop.dy,
                child: Opacity(
                  opacity: 0.5,
                  child: Icon(
                    Icons.water_drop_rounded,
                    size: drop.size,
                    color: Colors.white,
                  ),
                ),
              ),
            Icon(
              Icons.beach_access_rounded,
              size: 64,
              color: Colors.white.withValues(alpha: 0.95),
            ),
          ],
        ),
      ),
    );
  }
}

class _Raindrop {
  const _Raindrop(this.dx, this.dy, this.size);
  final double dx;
  final double dy;
  final double size;
}

/// Toạ độ tương đối cố định (không random) - tránh vẽ lại khác nhau mỗi lần
/// build.
const _kRaindrops = [
  _Raindrop(30, 20, 14),
  _Raindrop(70, 55, 10),
  _Raindrop(230, 30, 16),
  _Raindrop(270, 70, 11),
  _Raindrop(150, 15, 12),
  _Raindrop(310, 50, 9),
];
