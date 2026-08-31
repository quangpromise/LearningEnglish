import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Bo emoji tha cam xuc nhanh kieu Messenger (thumbs up, tim, haha, wow,
/// buon, gian) - dung Unicode emoji chuan thay vi bo icon Reactions rieng
/// cua Facebook (co ban quyen/thuong hieu, khong duoc dung lai trong app
/// khac - xem CLAUDE.md quy tac ban quyen).
const kQuickReactionEmojis = ['👍', '❤️', '😆', '😮', '😢', '😡'];

/// Hien 1 hang emoji tha cam xuc dang bottom sheet - dung chung cho ca
/// ChatScreen (bam giu 1 tin nhan) va banner tin nhan ngoai man hinh.
Future<void> showEmojiReactionPicker(
  BuildContext context, {
  required ValueChanged<String> onSelected,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xEB0F1326),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.glassBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: kQuickReactionEmojis
              .map(
                (emoji) => GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    onSelected(emoji);
                  },
                  child: Text(emoji, style: const TextStyle(fontSize: 28)),
                ),
              )
              .toList(),
        ),
      ),
    ),
  );
}
