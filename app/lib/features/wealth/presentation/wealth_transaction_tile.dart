import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_format.dart';

/// 1 dong giao dich trong danh sach - dung chung cho ca tab Chi tieu va
/// Thu nhap (chi khac mau/dau +-).
class WealthTransactionTile extends StatelessWidget {
  const WealthTransactionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.note,
    required this.amount,
    required this.amountColor,
    required this.sign,
    this.trailing,
  });
  final IconData icon;
  final String label;
  final String? note;
  final double amount;
  final Color amountColor;
  final String sign;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return GlowBox(
      borderRadius: 18,
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: amountColor.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 16, color: amountColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (trailing != null)
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          label,
                          style: AppTextStyles.body(weight: FontWeight.w800),
                        ),
                      ),
                      const SizedBox(width: 6),
                      trailing!,
                    ],
                  )
                else
                  Text(
                    label,
                    style: AppTextStyles.body(weight: FontWeight.w800),
                  ),
                if (note != null && note!.isNotEmpty)
                  Text(note!, style: AppTextStyles.muted(size: 11)),
              ],
            ),
          ),
          Text(
            '$sign${formatVnd(amount)}',
            style: AppTextStyles.body(
              weight: FontWeight.w800,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }
}
