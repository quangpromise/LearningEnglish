import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/navigation/app_top_bar.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../music_player/data/songs_data.dart';
import 'pronunciation_practice.dart';

/// Man "Luyen phat am" - truoc day la 1 tab co dinh o thanh Menu duoi (giu
/// song qua IndexedStack), gio la 1 the truy cap nhanh trong nhom "Nghe noi"
/// tren Home (push moi lan bam), nen MOI LAN MO la 1 instance HOAN TOAN MOI -
/// khong con can theo doi "vua quay lai tab" (didUpdateWidget) nhu truoc,
/// chi random 1 cau luyen trong initState() la du. Chon NGAU NHIEN 1 cau
/// lyric de luyen, hoac cho nguoi dung tu chon qua bottom sheet "Doi cau".
/// Phan ghi am/cham diem that nam o [PronunciationPractice] (dung lai duoc o
/// noi khac, vd StoryScreen cho shadowing).
class PronunciationScreen extends ConsumerStatefulWidget {
  const PronunciationScreen({super.key});

  @override
  ConsumerState<PronunciationScreen> createState() =>
      _PronunciationScreenState();
}

class _PronunciationScreenState extends ConsumerState<PronunciationScreen> {
  late String _targetEn;
  late String _targetVi;

  @override
  void initState() {
    super.initState();
    final initial = _randomSongLine();
    _targetEn = initial.en;
    _targetVi = initial.vi;
    // An FAB AI Voice Chat trong luc man nay mo - ca 2 deu dung mic, tranh
    // xung dot quyen truy cap/xac nhan nham (xem ai_fab_overlay.dart).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(pronunciationTabActiveProvider.notifier).state = true;
      }
    });
  }

  @override
  void dispose() {
    ref.read(pronunciationTabActiveProvider.notifier).state = false;
    super.dispose();
  }

  _PracticeChoice _randomSongLine() {
    final allLines = <_PracticeChoice>[
      for (final song in kSongs)
        for (final line in song.lyrics) _PracticeChoice(line.en, line.vi),
    ];
    if (allLines.isEmpty) {
      return const _PracticeChoice(
        "Now I'm standing in the rain",
        'Giờ tôi đứng lặng giữa cơn mưa',
      );
    }
    return allLines[Random().nextInt(allLines.length)];
  }

  Future<void> _pickPracticeSentence() async {
    final picked = await showModalBottomSheet<_PracticeChoice>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _PracticeSourcePicker(),
    );
    if (picked == null) return;
    setState(() {
      _targetEn = picked.en;
      _targetVi = picked.vi;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppTopBar(showBackButton: true),
            const SizedBox(height: 16),
            // SingleChildScrollView thay vi Column+Spacer nhu ban goc:
            // PronunciationPractice dung mainAxisSize.min de dung lai duoc
            // ca o day (man toan thoi gian, khong cuon) lan long trong
            // StoryScreen (dang cuon san) - Spacer doi 1 Column co chieu cao
            // GIOI HAN, se nem loi "kich thuoc vo han" trong ngu canh cuon.
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: PronunciationPractice(
                    targetEn: _targetEn,
                    targetVi: _targetVi,
                    source: 'pronunciation_tab',
                    onChangeTarget: _pickPracticeSentence,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Câu (tiếng Anh + nghĩa tiếng Việt) người dùng chọn để luyện phát âm —
/// có thể lấy từ lời 1 bài hát có sẵn hoặc tự gõ tay.
class _PracticeChoice {
  const _PracticeChoice(this.en, this.vi);
  final String en;
  final String vi;
}

/// Bottom sheet chọn câu/từ để luyện phát âm: hoặc gõ tay, hoặc chọn 1 dòng
/// lời trong danh sách bài hát có sẵn (`kSongs`).
class _PracticeSourcePicker extends ConsumerStatefulWidget {
  const _PracticeSourcePicker();

  @override
  ConsumerState<_PracticeSourcePicker> createState() =>
      _PracticeSourcePickerState();
}

class _PracticeSourcePickerState extends ConsumerState<_PracticeSourcePicker> {
  final _customController = TextEditingController();
  int? _expandedSongIndex;

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  void _useCustomText() {
    final text = _customController.text.trim();
    if (text.isEmpty) return;
    Navigator.of(context).pop(_PracticeChoice(text, ''));
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF12172E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.glassBorder,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                ref.tr('pron_pick_title'),
                style: AppTextStyles.heading(size: 16),
              ),
              const SizedBox(height: 14),
              Text(
                ref.tr('pron_custom_label'),
                style: AppTextStyles.muted(size: 10)
                    .copyWith(letterSpacing: 0.6),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _customController,
                      style: AppTextStyles.body(),
                      cursorColor: AppColors.purple,
                      onSubmitted: (_) => _useCustomText(),
                      decoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: AppColors.glassFill,
                        hintText: ref.tr('pron_custom_hint'),
                        hintStyle: AppTextStyles.muted(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _useCustomText,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: AppColors.accentGradient,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                ref.tr('pron_pick_from_song'),
                style: AppTextStyles.muted(size: 10)
                    .copyWith(letterSpacing: 0.6),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: kSongs.length,
                  itemBuilder: (context, songIndex) {
                    final song = kSongs[songIndex];
                    final expanded = _expandedSongIndex == songIndex;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => setState(
                            () => _expandedSongIndex = expanded
                                ? null
                                : songIndex,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.music_note_rounded,
                                  size: 18,
                                  color: song.color,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        song.title,
                                        style: AppTextStyles.body(
                                          weight: FontWeight.w800,
                                        ),
                                      ),
                                      Text(
                                        song.artist,
                                        style: AppTextStyles.muted(size: 11),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  expanded
                                      ? Icons.expand_less_rounded
                                      : Icons.expand_more_rounded,
                                  color: AppColors.textMuted,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (expanded)
                          ...song.lyrics.map(
                            (line) => GestureDetector(
                              onTap: () =>
                                  Navigator.of(context)
                                      .pop(_PracticeChoice(line.en, line.vi)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 12,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(line.en, style: AppTextStyles.body()),
                                    Text(
                                      line.vi,
                                      style: AppTextStyles.muted(size: 11),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        const Divider(color: AppColors.glassBorder, height: 1),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
