import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Dong huong dan cho 1 NHOM cau hoi (vd "Questions 1-5. Do the following
/// statements agree with..."), dac trung cua IELTS (TOEIC khong co). Man
/// thi chi hien widget nay khi `groupInstructionEn` cua cau hien tai khac
/// cau truoc do - cung logic da dung cho passage/audio cua TOEIC.
class IeltsGroupInstructionBanner extends StatelessWidget {
  const IeltsGroupInstructionBanner({super.key, required this.instructionEn});

  final String instructionEn;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.wealthAccent.withValues(alpha: 0.1),
        border: Border.all(
          color: AppColors.wealthAccent.withValues(alpha: 0.35),
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        instructionEn,
        style: AppTextStyles.body(
          size: 12,
          weight: FontWeight.w700,
        ).copyWith(height: 1.5),
      ),
    );
  }
}
