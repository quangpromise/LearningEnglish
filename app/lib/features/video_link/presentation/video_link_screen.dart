import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';

/// Man "dan link mo video" - nguoi dung dan bat ky link nao (YouTube, trang
/// web thuong...) va xem NGAY trong app qua WebView (khong roi app), thay vi
/// chuyen sang trinh duyet ngoai. Dung `webview_flutter` - goi CHINH THUC
/// cua Flutter team, mien phi, khong gioi han thuong mai (xem pubspec.yaml).
class VideoLinkScreen extends ConsumerStatefulWidget {
  const VideoLinkScreen({super.key});

  @override
  ConsumerState<VideoLinkScreen> createState() => _VideoLinkScreenState();
}

class _VideoLinkScreenState extends ConsumerState<VideoLinkScreen> {
  final _urlController = TextEditingController();
  WebViewController? _webController;
  String? _error;
  bool _loading = false;
  String? _currentUrl;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _openLink() {
    var input = _urlController.text.trim();
    if (input.isEmpty) return;
    if (!input.startsWith('http://') && !input.startsWith('https://')) {
      input = 'https://$input';
    }
    final uri = Uri.tryParse(input);
    if (uri == null || !uri.hasAuthority) {
      setState(() => _error = ref.tr('video_link_invalid'));
      return;
    }
    setState(() {
      _error = null;
      _currentUrl = input;
      _loading = true;
    });
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
          onWebResourceError: (_) {
            if (mounted) {
              setState(() {
                _loading = false;
                _error = ref.tr('video_link_load_error');
              });
            }
          },
        ),
      )
      ..loadRequest(uri);
    setState(() => _webController = controller);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.glassFill,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: const Icon(
                      Icons.chevron_left_rounded,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    ref.tr('video_link_screen_title'),
                    style: AppTextStyles.heading(size: 18),
                  ),
                ),
                if (_currentUrl != null)
                  GestureDetector(
                    onTap: () => launchUrl(
                      Uri.parse(_currentUrl!),
                      mode: LaunchMode.externalApplication,
                    ),
                    child: Tooltip(
                      message: ref.tr('video_link_open_external'),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: AppColors.glassFill,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.glassBorder),
                        ),
                        child: const Icon(
                          Icons.open_in_browser_rounded,
                          size: 18,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _urlController,
                    keyboardType: TextInputType.url,
                    style: AppTextStyles.body(),
                    onSubmitted: (_) => _openLink(),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.glassFill,
                      hintText: ref.tr('video_link_hint'),
                      hintStyle: const TextStyle(color: AppColors.textMuted),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                PillButton(
                  label: ref.tr('video_link_open_button'),
                  accentGradient: AppColors.accentGradient,
                  accentColor: AppColors.blue,
                  onTap: _openLink,
                ),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: AppTextStyles.muted().copyWith(color: AppColors.pink),
              ),
            ],
            const SizedBox(height: 14),
            Expanded(
              child: _webController == null
                  ? Center(
                      child: Text(
                        ref.tr('video_link_hint'),
                        style: AppTextStyles.muted(),
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: WebViewWidget(controller: _webController!),
                          ),
                          if (_loading)
                            const Positioned.fill(
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.blue,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
