import 'package:flutter/material.dart';

/// Nut loa dung CHUNG de nghe phat am mau 1 tu/cau (hoac phat lai 1 doan ghi
/// am) - vung bam CO DINH toi thieu 40x40 (gan chuan toi thieu 44x44 cua
/// Material/HIG) BAT KE icon to nho, dung InkWell hinh tron de luon co phan
/// hoi cham ro rang (ripple).
///
/// THAY THE cho pattern cu lap lai o nhieu man hinh (Icon boc GestureDetector
/// tran, khong Padding/Container du lon) - vung bam khi do dung bang dung
/// kich thuoc hinh hoc cua icon (18-20px), rat kho bam trung tren dien thoai
/// that (nguoi dung da phan anh ro o man Tu vung theo chu de).
class SpeakerButton extends StatelessWidget {
  const SpeakerButton({
    super.key,
    required this.onTap,
    this.icon = Icons.volume_up_rounded,
    this.iconSize = 22,
    this.tapSize = 40,
    this.color,
  });

  final VoidCallback onTap;
  final IconData icon;
  final double iconSize;
  final double tapSize;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: tapSize,
          height: tapSize,
          child: Icon(icon, size: iconSize, color: color),
        ),
      ),
    );
  }
}
