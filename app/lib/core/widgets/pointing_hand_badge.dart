import 'package:flutter/material.dart';

/// Hinh ban tay CHAM VAO man hinh, tu chay animation len-xuong lien tuc de
/// gay chu y vao muc duoc goi y (tile tren Home, chu de tu vung, che do
/// Luyen viet... theo cap hoc - xem docs/research-level-based-content.md
/// muc 7). Truoc nam rieng trong home_screen.dart, tach ra day de moi feature
/// dung chung 1 ngon ngu hinh anh.
class PointingHandBadge extends StatefulWidget {
  const PointingHandBadge({super.key, required this.color});
  final Color color;

  @override
  State<PointingHandBadge> createState() => _PointingHandBadgeState();
}

class _PointingHandBadgeState extends State<PointingHandBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _bounce;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
    _bounce = Tween<double>(
      begin: 0,
      end: -6,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounce,
      builder: (context, child) =>
          Transform.translate(offset: Offset(0, _bounce.value), child: child),
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
          boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 6)],
        ),
        child: const Icon(
          Icons.touch_app_rounded,
          size: 15,
          color: Colors.white,
        ),
      ),
    );
  }
}
