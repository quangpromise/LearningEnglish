import 'package:flutter/material.dart';

/// Doi qua lai 2 anh (tu the bat dau/ket thuc dong tac) theo chu ky - mo
/// phong hieu ung "anh dong" don gian tu 2 anh tinh that (FitViet chi co 2
/// anh/bai, khong co GIF that - xem docs/research-exercise-gifs.md), thay
/// vi phai mua nguon GIF ben ngoai.
class ExercisePhotoAnimator extends StatefulWidget {
  const ExercisePhotoAnimator({
    super.key,
    required this.assets,
    this.height = 200,
  });
  final List<String> assets;
  final double height;

  @override
  State<ExercisePhotoAnimator> createState() => _ExercisePhotoAnimatorState();
}

class _ExercisePhotoAnimatorState extends State<ExercisePhotoAnimator> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _scheduleNext();
  }

  void _scheduleNext() {
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() => _index = (_index + 1) % widget.assets.length);
      _scheduleNext();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Image.asset(
            widget.assets[_index],
            key: ValueKey(_index),
            fit: BoxFit.cover,
            width: double.infinity,
          ),
        ),
      ),
    );
  }
}
