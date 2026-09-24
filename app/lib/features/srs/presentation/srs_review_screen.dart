import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/tts/app_tts.dart';
import '../../../core/widgets/speaker_button.dart';
import '../../today/data/daily_progress_store.dart';
import '../data/srs_store.dart';

/// On tap tu den han (SRS) - mo dang popup tu man Hom nay. Moi the: nghe
/// phat am (chi khi bam), "Hien nghia", roi tu danh gia Quen/Nho. Toi da
/// [maxCards] the moi lan de 1 luot on vua 3-5 phut.
class SrsReviewScreen extends ConsumerStatefulWidget {
  const SrsReviewScreen({super.key, this.maxCards = 20});
  final int maxCards;

  @override
  ConsumerState<SrsReviewScreen> createState() => _SrsReviewScreenState();
}

class _SrsReviewScreenState extends ConsumerState<SrsReviewScreen> {
  List<SrsCard>? _queue;
  int _index = 0;
  int _reviewed = 0;
  int _remembered = 0;
  bool _revealed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await SrsStore.instance.ensureLoaded();
    if (!mounted) return;
    setState(() {
      _queue = SrsStore.instance
          .dueCards(DateTime.now())
          .take(widget.maxCards)
          .toList();
    });
  }

  @override
  void dispose() {
    AppTts.instance.stopSpeaking();
    super.dispose();
  }

  void _answer(SrsCard card, {required bool known}) {
    AppTts.instance.stopSpeaking();
    SrsStore.instance.review(card.key, known: known, now: DateTime.now());
    DailyProgressStore.instance.addWordsReviewed();
    setState(() {
      _reviewed++;
      if (known) _remembered++;
      _revealed = false;
      _index++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final queue = _queue;
    return ScreenBackground(
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      ref.tr('srs_review_title'),
                      style: AppTextStyles.heading(size: 20),
                    ),
                  ),
                  if (queue != null && queue.isNotEmpty)
                    Text(
                      '${_index.clamp(0, queue.length)}/${queue.length}',
                      style: AppTextStyles.muted(size: 14),
                    ),
                  SpeakerButton(
                    icon: Icons.close_rounded,
                    tapSize: 44,
                    color: AppColors.textPrimary,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(child: _body(queue)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body(List<SrsCard>? queue) {
    if (queue == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.blue),
      );
    }
    if (queue.isEmpty) {
      return _Message(
        icon: Icons.celebration_rounded,
        title: ref.tr('srs_review_empty_title'),
        body: ref.tr('srs_review_empty_body'),
      );
    }
    if (_index >= queue.length) {
      return _Message(
        icon: Icons.check_circle_rounded,
        title: ref.tr('srs_review_done_title'),
        body: ref
            .tr('srs_review_done_body')
            .replaceFirst('{reviewed}', '$_reviewed')
            .replaceFirst('{remembered}', '$_remembered'),
      );
    }
    final card = queue[_index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LinearProgressIndicator(
          value: _index / queue.length,
          minHeight: 4,
          color: AppColors.blue,
          backgroundColor: AppColors.glassBorder,
        ),
        const SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            child: GlowBox(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          card.en,
                          style: AppTextStyles.heading(size: 30),
                        ),
                      ),
                      SpeakerButton(
                        tapSize: 56,
                        iconSize: 30,
                        color: AppColors.blue,
                        onTap: () => AppTts.instance.speak(card.en),
                      ),
                    ],
                  ),
                  if (card.ipa.isNotEmpty)
                    Text(card.ipa, style: AppTextStyles.muted(size: 15)),
                  const SizedBox(height: 16),
                  if (_revealed) ...[
                    Text(
                      card.vi,
                      style: AppTextStyles.body(
                        size: 18,
                        weight: FontWeight.w800,
                        color: AppColors.teal,
                      ),
                    ),
                    if (card.exampleEn.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              card.exampleEn,
                              style: AppTextStyles.body(size: 15),
                            ),
                          ),
                          SpeakerButton(
                            iconSize: 20,
                            tapSize: 44,
                            color: AppColors.blue,
                            onTap: () => AppTts.instance.speak(card.exampleEn),
                          ),
                        ],
                      ),
                    ],
                    if (card.exampleVi.isNotEmpty)
                      Text(
                        card.exampleVi,
                        style: AppTextStyles.muted(size: 13),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (!_revealed)
          PillButton(
            label: ref.tr('srs_review_show_meaning'),
            accentColor: AppColors.blue,
            onTap: () => setState(() => _revealed = true),
          )
        else
          Row(
            children: [
              Expanded(
                child: PillButton(
                  label: ref.tr('srs_review_forgot'),
                  accentColor: AppColors.pink,
                  filled: false,
                  onTap: () => _answer(card, known: false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PillButton(
                  label: ref.tr('srs_review_remembered'),
                  accentColor: AppColors.blue,
                  onTap: () => _answer(card, known: true),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.title, required this.body});
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: AppColors.blue),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.heading(size: 18),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            textAlign: TextAlign.center,
            style: AppTextStyles.body(size: 14, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
