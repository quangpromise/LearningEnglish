import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../data/onboarding_repository.dart';

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.icon,
    required this.gradient,
    required this.titleKey,
    required this.bodyKey,
  });

  final IconData icon;
  final List<Color> gradient;
  final String titleKey;
  final String bodyKey;
}

const _kPages = [
  _OnboardingPageData(
    icon: Icons.music_note_rounded,
    gradient: [AppColors.blue, AppColors.purple],
    titleKey: 'onboarding_page1_title',
    bodyKey: 'onboarding_page1_body',
  ),
  _OnboardingPageData(
    icon: Icons.mic_rounded,
    gradient: [AppColors.teal, AppColors.blue],
    titleKey: 'onboarding_page2_title',
    bodyKey: 'onboarding_page2_body',
  ),
  _OnboardingPageData(
    icon: Icons.event_repeat_rounded,
    gradient: [AppColors.amber, AppColors.pink],
    titleKey: 'onboarding_page3_title',
    bodyKey: 'onboarding_page3_body',
  ),
  _OnboardingPageData(
    icon: Icons.auto_awesome_rounded,
    gradient: [AppColors.purple, AppColors.pink],
    titleKey: 'onboarding_page4_title',
    bodyKey: 'onboarding_page4_body',
  ),
  _OnboardingPageData(
    icon: Icons.emoji_events_rounded,
    gradient: [AppColors.blue, AppColors.teal],
    titleKey: 'onboarding_page5_title',
    bodyKey: 'onboarding_page5_body',
  ),
];

/// Carousel giới thiệu tính năng, hiện đúng 1 lần cho mỗi tài khoản ngay
/// sau khi đăng nhập/đăng ký thành công lần đầu (xem _AuthGate trong
/// main.dart) - trước khi vào RootShell.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({
    super.key,
    required this.userId,
    required this.onDone,
  });

  final String userId;
  final VoidCallback onDone;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;
  bool _finishing = false;

  Future<void> _finish() async {
    if (_finishing) return;
    setState(() => _finishing = true);
    await OnboardingRepository.markSeen(widget.userId);
    widget.onDone();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _page == _kPages.length - 1;
    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finishing ? null : _finish,
                child: Text(
                  ref.tr('onboarding_skip'),
                  style: AppTextStyles.muted(size: 13),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _kPages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) {
                  final p = _kPages[i];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: p.gradient),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: p.gradient.first.withValues(alpha: 0.4),
                              blurRadius: 40,
                              offset: const Offset(0, 16),
                            ),
                          ],
                        ),
                        child: Icon(p.icon, size: 56, color: Colors.white),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        ref.tr(p.titleKey),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.heading(size: 22),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          ref.tr(p.bodyKey),
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body(
                            size: 14,
                            weight: FontWeight.w500,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_kPages.length, (i) {
                final active = i == _page;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 22 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: active ? AppColors.blue : AppColors.glassBorder,
                    borderRadius: BorderRadius.circular(999),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: PillButton(
                label: isLast
                    ? ref.tr('onboarding_start')
                    : ref.tr('onboarding_next'),
                onTap: _finishing
                    ? null
                    : () {
                        if (isLast) {
                          _finish();
                        } else {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        }
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
