import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import 'profile_screen.dart';

/// Popup nhanh mo tu nut mui ten canh avatar tren Home - thay the cho viec
/// phai vao han tab Ho so (da bo khoi thanh tab, xem root_shell.dart) chi de
/// doi avatar. Cac cai dat con lai (doi mat khau, ngon ngu, dang xuat...) van
/// nam trong [ProfileScreen] day du, mo qua nut "Xem tat ca cai dat" ben duoi.
void showProfileQuickPopup(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => const _ProfileQuickPopup(),
  );
}

class _ProfileQuickPopup extends ConsumerWidget {
  const _ProfileQuickPopup();

  Future<void> _pickAndUploadAvatar(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    final ext = picked.path.split('.').last.toLowerCase();
    try {
      await ref.read(profileRepositoryProvider).uploadAvatar(bytes, ext);
      ref.invalidate(myProfileProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${ref.tr('profile_avatar_error')} $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(myProfileProvider);
    final profile = profileAsync.valueOrNull;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      decoration: const BoxDecoration(
        color: Color(0xFF12172E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: AppColors.glassBorder,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          GestureDetector(
            onTap: () => _pickAndUploadAvatar(context, ref),
            child: Stack(
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    gradient: AppColors.accentGradient,
                    shape: BoxShape.circle,
                    image: profile?.avatarUrl != null
                        ? DecorationImage(
                            image: NetworkImage(profile!.avatarUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: profile?.avatarUrl == null
                      ? Center(
                          child: Text(
                            profile?.initial ?? '?',
                            style: AppTextStyles.heading(size: 26),
                          ),
                        )
                      : null,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.bgMid,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.bgTop, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            profile?.nameLabel ?? '...',
            style: AppTextStyles.heading(size: 18),
          ),
          if (profile != null) ...[
            const SizedBox(height: 2),
            Text(profile.email, style: AppTextStyles.muted()),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: PillButton(
              label: ref.tr('profile_quick_open_full'),
              filled: false,
              icon: const Icon(
                Icons.settings_rounded,
                size: 16,
                color: AppColors.textPrimary,
              ),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
