import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../data/wealth_payment_qr_model.dart';

/// Man Ma QR nhan tien "cua toi" - mo tu nut "QR Code" o the Tong Vi man
/// Home Quan ly tai san (xem wealth_home_screen.dart). Chi 1 ma QR duy nhat
/// moi user (Phase 1, khong tach theo tung ngan hang) - anh do NGUOI DUNG TU
/// TAI LEN (chup san tu app ngan hang), app KHONG tu sinh/OCR gi tu anh.
class WealthQrScreen extends ConsumerWidget {
  const WealthQrScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qrAsync = ref.watch(wealthPaymentQrProvider);
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
                    ref.tr('wealth_qr_title'),
                    style: AppTextStyles.heading(size: 20),
                  ),
                ),
                if (qrAsync.valueOrNull?.hasImage ?? false)
                  GestureDetector(
                    onTap: () => _openEditSheet(context, ref, qrAsync.value),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.glassFill,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        size: 16,
                        color: AppColors.wealthAccent,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: qrAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.wealthAccent,
                  ),
                ),
                error: (_, _) =>
                    Center(child: Text(ref.tr('wealth_load_error'))),
                data: (qr) => qr == null || !qr.hasImage
                    ? _emptyState(context, ref)
                    : _qrDetail(ref, qr),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.qr_code_2_rounded,
              size: 64,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              ref.tr('wealth_qr_empty_title'),
              style: AppTextStyles.heading(size: 16),
            ),
            const SizedBox(height: 8),
            Text(
              ref.tr('wealth_qr_empty_desc'),
              textAlign: TextAlign.center,
              style: AppTextStyles.muted(),
            ),
            const SizedBox(height: 20),
            PillButton(
              label: ref.tr('wealth_qr_add_button'),
              accentGradient: AppColors.wealthAccentGradient,
              accentColor: AppColors.wealthAccent,
              icon: const Icon(
                Icons.add_rounded,
                size: 16,
                color: Colors.white,
              ),
              onTap: () => _openEditSheet(context, ref, null),
            ),
          ],
        ),
      ),
    );
  }

  Widget _qrDetail(WidgetRef ref, WealthPaymentQr qr) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(12),
                child: Image.network(
                  qr.imageUrl!,
                  width: 240,
                  height: 240,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 20),
            GlowBox(
              borderRadius: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if ((qr.holderName ?? '').isNotEmpty)
                    Text(
                      qr.holderName!,
                      style: AppTextStyles.heading(size: 15),
                    ),
                  if ((qr.bankName ?? '').isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(qr.bankName!, style: AppTextStyles.muted(size: 12.5)),
                  ],
                  if ((qr.accountNumber ?? '').isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      qr.accountNumber!,
                      style: AppTextStyles.body(
                        weight: FontWeight.w800,
                        size: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openEditSheet(
    BuildContext context,
    WidgetRef ref,
    WealthPaymentQr? existing,
  ) async {
    final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;
    if (userId == null) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _QrEditSheet(userId: userId, existing: existing),
    );
  }
}

class _QrEditSheet extends ConsumerStatefulWidget {
  const _QrEditSheet({required this.userId, this.existing});
  final String userId;
  final WealthPaymentQr? existing;

  @override
  ConsumerState<_QrEditSheet> createState() => _QrEditSheetState();
}

class _QrEditSheetState extends ConsumerState<_QrEditSheet> {
  late final _holderController = TextEditingController(
    text: widget.existing?.holderName ?? '',
  );
  late final _bankController = TextEditingController(
    text: widget.existing?.bankName ?? '',
  );
  late final _accountController = TextEditingController(
    text: widget.existing?.accountNumber ?? '',
  );
  Uint8List? _pickedBytes;
  String? _pickedExt;
  bool _saving = false;

  @override
  void dispose() {
    _holderController.dispose();
    _bankController.dispose();
    _accountController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 90,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() {
      _pickedBytes = bytes;
      _pickedExt = picked.path.split('.').last.toLowerCase();
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final repo = ref.read(wealthPaymentQrRepositoryProvider);
      var imageUrl = widget.existing?.imageUrl;
      if (_pickedBytes != null && _pickedExt != null) {
        imageUrl = await repo.uploadImage(
          widget.userId,
          _pickedBytes!,
          _pickedExt!,
        );
      }
      await repo.save(
        userId: widget.userId,
        imageUrl: imageUrl,
        bankName: _bankController.text.trim(),
        accountNumber: _accountController.text.trim(),
        holderName: _holderController.text.trim(),
      );
      ref.invalidate(wealthPaymentQrProvider);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).maybePop(),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: GestureDetector(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            decoration: const BoxDecoration(
              color: Color(0xFF12172E),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ref.tr('wealth_qr_edit_title'),
                    style: AppTextStyles.heading(size: 16),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: double.infinity,
                      height: 160,
                      decoration: BoxDecoration(
                        color: AppColors.glassFill,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: _pickedBytes != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.memory(
                                _pickedBytes!,
                                fit: BoxFit.contain,
                              ),
                            )
                          : (widget.existing?.hasImage ?? false)
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                widget.existing!.imageUrl!,
                                fit: BoxFit.contain,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.add_photo_alternate_rounded,
                                  color: AppColors.textMuted,
                                  size: 32,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  ref.tr('wealth_qr_pick_image'),
                                  style: AppTextStyles.muted(size: 12.5),
                                ),
                              ],
                            ),
                    ),
                  ),
                  if (widget.existing?.hasImage ?? false) ...[
                    const SizedBox(height: 6),
                    Text(
                      ref.tr('wealth_qr_change_image'),
                      style: AppTextStyles.muted(size: 11),
                    ),
                  ],
                  const SizedBox(height: 14),
                  TextField(
                    controller: _holderController,
                    style: AppTextStyles.body(),
                    decoration: InputDecoration(
                      hintText: ref.tr('wealth_qr_holder_name_hint'),
                      hintStyle: AppTextStyles.muted(),
                      filled: true,
                      fillColor: AppColors.glassFill,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _bankController,
                    style: AppTextStyles.body(),
                    decoration: InputDecoration(
                      hintText: ref.tr('wealth_qr_bank_name_hint'),
                      hintStyle: AppTextStyles.muted(),
                      filled: true,
                      fillColor: AppColors.glassFill,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _accountController,
                    keyboardType: TextInputType.number,
                    style: AppTextStyles.body(),
                    decoration: InputDecoration(
                      hintText: ref.tr('wealth_qr_account_number_hint'),
                      hintStyle: AppTextStyles.muted(),
                      filled: true,
                      fillColor: AppColors.glassFill,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: PillButton(
                      label: ref.tr('wealth_save'),
                      accentGradient: AppColors.wealthAccentGradient,
                      accentColor: AppColors.wealthAccent,
                      onTap: _saving ? null : _save,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
