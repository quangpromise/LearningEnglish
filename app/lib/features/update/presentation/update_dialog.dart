import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../data/update_checker.dart';

Future<void> showUpdateDialogIfAvailable(BuildContext context) async {
  final update = await checkForUpdate();
  if (update == null || !context.mounted) return;

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => _UpdateDialog(update: update),
  );
}

class _UpdateDialog extends ConsumerStatefulWidget {
  const _UpdateDialog({required this.update});
  final UpdateInfo update;

  @override
  ConsumerState<_UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends ConsumerState<_UpdateDialog> {
  bool _downloading = false;
  String? _error;

  Future<void> _downloadAndInstall() async {
    setState(() {
      _downloading = true;
      _error = null;
    });
    try {
      // Tai thang file APK trong app roi mo bang trinh cai dat cua Android,
      // thay vi launchUrl(externalApplication) day nguoi dung sang Chrome -
      // Chrome tai xong roi nguoi dung con phai tu mo file tai muc Downloads.
      final res = await http
          .get(Uri.parse(widget.update.downloadUrl))
          .timeout(const Duration(minutes: 3));
      if (res.statusCode != 200) {
        throw Exception('Tải file thất bại (HTTP ${res.statusCode})');
      }
      final dir = await getTemporaryDirectory();
      final file = await File('${dir.path}/learn-english-music-update.apk')
          .writeAsBytes(res.bodyBytes);
      final result = await OpenFile.open(file.path);
      if (result.type != ResultType.done && mounted) {
        setState(
          () => _error = ref
              .tr('update_install_failed')
              .replaceFirst('{msg}', result.message),
        );
      } else if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = '${ref.tr('update_download_failed')} $e');
      }
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
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
              decoration: BoxDecoration(
                gradient: AppColors.accentGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.system_update_rounded,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              ref.tr('update_available_title'),
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              ref.tr('update_available_body'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.pink,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _downloading
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: Text(
                      ref.tr('update_later'),
                      style: const TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: PillButton(
                    label: _downloading
                        ? ref.tr('update_downloading')
                        : ref.tr('update_download'),
                    onTap: _downloading ? null : _downloadAndInstall,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
