import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';
import '../data/update_checker.dart';

Future<void> showUpdateDialogIfAvailable(BuildContext context) async {
  final update = await checkForUpdate();
  if (update == null || !context.mounted) return;

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      child: GlowBox(
        light: true,
        borderRadius: 24,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(gradient: AppColors.accentGradient, borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.system_update_rounded, color: Colors.white),
            ),
            const SizedBox(height: 14),
            const Text('Có bản cập nhật mới', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 6),
            const Text(
              'Tải và cài đè trực tiếp lên app hiện tại — dữ liệu & đăng nhập của bạn vẫn được giữ nguyên.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Để sau', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w700)),
                  ),
                ),
                Expanded(
                  child: PillButton(
                    label: 'Tải về',
                    onTap: () {
                      launchUrl(Uri.parse(update.downloadUrl), mode: LaunchMode.externalApplication);
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
