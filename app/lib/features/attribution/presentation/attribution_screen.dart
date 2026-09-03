import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../data/attribution_data.dart';

/// Màn hình ghi công (Attribution/Credits) — bề mặt hiển thị TRONG app cho
/// giấy phép CC-BY 4.0 của 20 bài hát (trước đây chỉ có trong
/// ATTRIBUTION.md, không ai cài APK thấy được). Vào từ Menu, xem
/// docs/architecture-multimedia-platform.md §A.7/§D.
class AttributionScreen extends ConsumerWidget {
  const AttributionScreen({super.key});

  Future<void> _open(String url) => launchUrl(
    Uri.parse(url),
    mode: LaunchMode.externalApplication,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ref.tr('attribution_title'),
                        style: AppTextStyles.heading(size: 18),
                      ),
                      Text(
                        ref.tr('attribution_subtitle'),
                        style: AppTextStyles.muted(size: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  GlowBox(
                    light: true,
                    borderRadius: 18,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          kSongAttributions.first.creator,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${kSongAttributions.first.licenseId} · '
                          '${kSongAttributions.length} '
                          '${ref.tr('attribution_songs_suffix')}',
                          style: TextStyle(
                            color: Colors.black.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () => _open(kSongAttributions.first.licenseUrl),
                          child: Text(
                            ref.tr('attribution_view_license'),
                            style: const TextStyle(
                              color: AppColors.blue,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (final a in kSongAttributions) ...[
                    GestureDetector(
                      onTap: () => _open(a.sourceUrl),
                      child: GlowBox(
                        borderRadius: 16,
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    a.songTitle,
                                    style: AppTextStyles.body(
                                      weight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(a.creator, style: AppTextStyles.muted()),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.open_in_new_rounded,
                              size: 16,
                              color: AppColors.textMuted,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    ref.tr('attribution_original_content_title'),
                    style: AppTextStyles.muted(size: 10)
                        .copyWith(letterSpacing: 0.6),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    ref.tr('attribution_original_content_body'),
                    style: AppTextStyles.muted(size: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
