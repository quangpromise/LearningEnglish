import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/env.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/gt_tokens.dart';

const _kLogoAsset = 'assets/icon/splash_logo.webp';

/// Tac gia hien o Launch Intro va o day (spec #135, quyet dinh #2-3).
const kGtAuthors = ('Quang Promise', 'Tùng Micky');

/// Ban build dang chay: SHA rut gon cua CI, "dev" khi build tai cho.
String gtBuildLabel([String sha = Env.buildSha]) =>
    sha.isEmpty ? 'dev' : sha.substring(0, sha.length < 7 ? sha.length : 7);

/// Trang Gioi thieu (#138): tac gia, ban build, ghi cong va giay phep.
class GtAboutScreen extends ConsumerWidget {
  const GtAboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.gt;
    final build = gtBuildLabel();
    return ColoredBox(
      color: t.bg,
      child: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: Icon(Icons.close_rounded, color: t.tx2),
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
              ),
            ),
            Center(child: _Logo(size: 112, border: t.gold)),
            const SizedBox(height: 18),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Gym',
                    style: TextStyle(color: t.tx),
                  ),
                  TextSpan(
                    text: 'Talk',
                    style: TextStyle(color: t.gold),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
              style: GtText.heroTitle(t.tx),
            ),
            const SizedBox(height: 6),
            Text(
              'Train your body. Train your English.',
              textAlign: TextAlign.center,
              style: GtText.body(t.tx2, size: 15),
            ),
            const SizedBox(height: 24),
            _Card(
              label: ref.tr('gt_about_made_by'),
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                children: [
                  Text(kGtAuthors.$1, style: GtText.rowTitle(t.tx)),
                  Text('×', style: GtText.rowTitle(t.gold)),
                  Text(kGtAuthors.$2, style: GtText.rowTitle(t.tx)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _Card(
              label: ref.tr('gt_about_version'),
              child: Text(
                build,
                textAlign: TextAlign.center,
                style: GtText.body(
                  t.tx,
                  size: 15,
                ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
              ),
            ),
            const SizedBox(height: 12),
            _Card(
              label: ref.tr('gt_about_credits'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final key in const [
                    'gt_about_credit_music',
                    'gt_about_credit_sounds',
                    'gt_about_credit_words',
                    'gt_about_credit_sentences',
                  ])
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        ref.tr(key),
                        style: GtText.body(t.tx2, size: 13),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: t.tx,
                side: BorderSide(color: t.bd),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () => showLicensePage(
                context: context,
                applicationName: 'GymTalk',
                applicationVersion: build,
                applicationIcon: Padding(
                  padding: const EdgeInsets.all(12),
                  child: _Logo(size: 56, border: t.gold),
                ),
              ),
              icon: const Icon(Icons.description_outlined),
              label: Text(
                ref.tr('gt_about_licenses'),
                style: GtText.rowTitle(t.tx),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo({required this.size, required this.border});

  final double size;
  final Color border;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: border, width: 2),
    ),
    child: ClipOval(
      child: Image.asset(
        _kLogoAsset,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const SizedBox.shrink(),
      ),
    ),
  );
}

class _Card extends StatelessWidget {
  const _Card({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = context.gt;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        color: t.s1,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: t.bd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            style: GtText.body(t.tx3, size: 11).copyWith(letterSpacing: 1.6),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
