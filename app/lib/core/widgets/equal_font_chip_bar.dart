import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Thanh chip chuyen tab dang segment CHIA DEU be rong (dung cho hang 4
/// nhan Crypto/Co phieu/Kim loai hiem/Ngoai te o man Market va Watchlist) -
/// TAT CA nhan dung CHUNG 1 co chu thay vi moi o tu FittedBox rieng (cach
/// lam CU khien nhan ngan nhu "Crypto" to han han nhan dai nhu "Foreign
/// currency" du cung 1 style goc, vi FittedBox chi thu nho o NAO thuc su
/// tran, con o du cho thi giu nguyen size goc).
///
/// Cach lam: do truoc be rong THAT SU cua tung nhan (bang TextPainter) o co
/// chu goc [_maxFontSize], tim nhan can THU NHO NHIEU NHAT de vua khung hep
/// nhat (moi segment rong bang nhau, = tong be rong / so nhan), roi ap dung
/// DONG LOAT co chu da thu nho do cho CA 4 nhan - dam bao luon nam gon 1
/// hang VA nhin dong deu kich co giua cac nhan.
class EqualFontChipBar<T> extends StatelessWidget {
  const EqualFontChipBar({
    super.key,
    required this.items,
    required this.selected,
    required this.onChanged,
    required this.accentColor,
  });

  /// (gia tri cua tab, nhan hien thi) - thu tu trong danh sach quyet dinh
  /// thu tu hien tren hang.
  final List<(T, String)> items;
  final T selected;
  final ValueChanged<T> onChanged;
  final Color accentColor;

  static const _maxFontSize = 12.0;
  static const _minFontSize = 8.0;
  static const _chipHPadding = 8.0;
  static const _chipVPadding = 8.0;
  static const _chipGap = 6.0;
  static const _barPadding = 8.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final n = items.length;
        final totalGaps = _chipGap * (n - 1);
        final segmentWidth =
            (constraints.maxWidth - _barPadding * 2 - totalGaps) / n;
        final maxTextWidth = (segmentWidth - _chipHPadding * 2).clamp(
          1.0,
          double.infinity,
        );

        var fontSize = _maxFontSize;
        for (final item in items) {
          final painter = TextPainter(
            text: TextSpan(
              text: item.$2,
              style: AppTextStyles.body(
                size: fontSize,
                weight: FontWeight.w700,
              ),
            ),
            maxLines: 1,
            textDirection: TextDirection.ltr,
          )..layout();
          if (painter.width > maxTextWidth) {
            final scale = (maxTextWidth / painter.width).clamp(0.01, 1.0);
            fontSize = (fontSize * scale).clamp(_minFontSize, fontSize);
          }
        }

        return Container(
          padding: const EdgeInsets.all(_barPadding),
          decoration: BoxDecoration(
            color: AppColors.glassFill.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Row(
            children: [
              for (final item in items) ...[
                Expanded(
                  child: GestureDetector(
                    onTap: () => onChanged(item.$1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: _chipHPadding,
                        vertical: _chipVPadding,
                      ),
                      decoration: BoxDecoration(
                        color: selected == item.$1
                            ? accentColor.withValues(alpha: 0.22)
                            : AppColors.glassFill,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: selected == item.$1
                              ? accentColor
                              : AppColors.glassBorder,
                        ),
                      ),
                      child: Text(
                        item.$2,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body(
                          size: fontSize,
                          weight: FontWeight.w700,
                          color: selected == item.$1
                              ? accentColor
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
                if (item != items.last) const SizedBox(width: _chipGap),
              ],
            ],
          ),
        );
      },
    );
  }
}
