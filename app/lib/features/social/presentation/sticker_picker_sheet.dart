import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../data/sticker_repository.dart';

/// Bang chon sticker kieu Zalo/Messenger - luoi sticker xu huong (trending)
/// mac dinh, co o tim kiem rieng. Nguon: GIPHY Stickers API (xem
/// sticker_repository.dart) - KHONG phai sticker that cua Zalo/Facebook.
Future<void> showStickerPicker(
  BuildContext context, {
  required ValueChanged<String> onPicked,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: FractionallySizedBox(
        heightFactor: 0.7,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: _StickerPickerBody(onPicked: onPicked),
        ),
      ),
    ),
  );
}

class _StickerPickerBody extends ConsumerStatefulWidget {
  const _StickerPickerBody({required this.onPicked});
  final ValueChanged<String> onPicked;

  @override
  ConsumerState<_StickerPickerBody> createState() => _StickerPickerBodyState();
}

class _StickerPickerBodyState extends ConsumerState<_StickerPickerBody> {
  final _repo = StickerRepository();
  final _searchCtrl = TextEditingController();
  List<StickerResult>? _stickers;
  bool _loading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load(null);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load(String? query) async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    final result = query == null || query.isEmpty
        ? await _repo.trending()
        : await _repo.search(query);
    if (!mounted) return;
    setState(() {
      _stickers = result;
      _loading = false;
      _failed = result.isEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0D1330),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  ref.tr('chat_sticker_title'),
                  style: AppTextStyles.heading(size: 16),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.glassFill,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GlowBox(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            borderRadius: 999,
            child: Row(
              children: [
                const Icon(Icons.search, size: 18, color: AppColors.textMuted),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    style: AppTextStyles.body(),
                    onSubmitted: _load,
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: ref.tr('chat_sticker_search_hint'),
                      hintStyle: AppTextStyles.muted(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.blue),
      );
    }
    if (_failed || _stickers == null || _stickers!.isEmpty) {
      return Center(
        child: Text(
          ref.tr('chat_sticker_load_error'),
          textAlign: TextAlign.center,
          style: AppTextStyles.muted(),
        ),
      );
    }
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemCount: _stickers!.length,
      itemBuilder: (context, i) {
        final sticker = _stickers![i];
        return GestureDetector(
          onTap: () {
            Navigator.of(context).maybePop();
            widget.onPicked(sticker.sendUrl);
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(sticker.previewUrl, fit: BoxFit.cover),
          ),
        );
      },
    );
  }
}
