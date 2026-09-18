import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/navigation/app_popup.dart';
import '../../../core/theme/app_theme.dart';
import '../../learning_path/presentation/learner_level_banner.dart';
import '../data/vocab_level_filter.dart';
import '../data/vocabulary_data.dart';
import 'vocabulary_topic_detail_screen.dart';

enum _VocabStep { topics, detail }

/// Man goc cua tinh nang Tu vung theo chu de - dong thoi la "khung" duy
/// nhat cho CA luong (chon chu de -> xem/chon tu), KHONG mo them bat ky
/// popup/route nao khac cho buoc sau (xem [_step]) - chi 1
/// showModalBottomSheet duy nhat (openAppPopup goi tu home_screen.dart) ton
/// tai tu dau den cuoi. Ly do: vuot xuong/tap ra ngoai la gesture CO SAN
/// cua CHINH sheet do - neu tung mo THEM 1 sheet/route khac chong len (thu
/// da lam truoc, bi loi: nen trang lo ra, vuot/tap ngoai khong dong duoc gi
/// vi route moi khong co gesture do), nguoi dung se khong con dong duoc het
/// ca luong bang 1 thao tac vuot/tap o BAT KY buoc nao - phai dung dung 1
/// State duy nhat, chuyen "man hinh" bang doi noi dung hien thi (switch
/// theo [_step]) thay vi Navigator.
class VocabularyTopicsScreen extends ConsumerStatefulWidget {
  const VocabularyTopicsScreen({super.key});

  @override
  ConsumerState<VocabularyTopicsScreen> createState() =>
      _VocabularyTopicsScreenState();
}

class _VocabularyTopicsScreenState
    extends ConsumerState<VocabularyTopicsScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  _VocabStep _step = _VocabStep.topics;
  VocabTopic? _activeTopic;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openTopic(VocabTopic topic) {
    setState(() {
      _activeTopic = topic;
      _step = _VocabStep.detail;
    });
  }

  void _backToTopics() => setState(() => _step = _VocabStep.topics);

  @override
  Widget build(BuildContext context) {
    switch (_step) {
      case _VocabStep.detail:
        // _activeTopic null khong the xay ra qua luong _openTopic binh thuong
        // - phong ho truong hop hot-reload/state la giua chung, tranh crash.
        return VocabularyTopicDetailScreen(
          topic: _activeTopic ?? kVocabTopics.first,
          onBack: _backToTopics,
        );
      case _VocabStep.topics:
        return _buildTopicsGrid(context);
    }
  }

  Widget _buildTopicsGrid(BuildContext context) {
    // Cap hoc tu "Goi y lo trinh" (null = Tu hoc -> hien du 59 chu de, dem
    // du tu nhu cu) - xem vocab_level_filter.dart.
    final level = ref.watch(learnerLevelProvider);
    final topics = topicsForLevel(kVocabTopics, level).where((t) {
      if (_query.isEmpty) return true;
      return t.name.toLowerCase().contains(_query) ||
          t.nameEn.toLowerCase().contains(_query);
    }).toList();
    // So tu CON LAI (chua danh dau "Da hoc") cua tung chu de - tu da hoc bi
    // an khoi man chi tiet chu de (xem VocabularyTopicDetailScreen.build)
    // nen o day cung phai tru bot de khop voi so luong nguoi dung se thay
    // khi bam vao.
    final learned = ref.watch(learnedWordsProvider).valueOrNull ?? const {};
    int remainingCount(VocabTopic t) {
      final words = wordsForLevel(t, level);
      return learned.isEmpty
          ? words.length
          : words.where((w) => !learned.contains(w.en.toLowerCase())).length;
    }

    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const PopupBackButton(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ref.tr('vocab_title'),
                        style: AppTextStyles.heading(size: 18),
                      ),
                      Text(
                        ref.tr('vocab_subtitle'),
                        style: AppTextStyles.muted(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (level != null) ...[
              const SizedBox(height: 10),
              const LearnerLevelBanner(),
            ],
            const SizedBox(height: 14),
            GlowBox(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              borderRadius: 999,
              child: Row(
                children: [
                  const Icon(
                    Icons.search_rounded,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) =>
                          setState(() => _query = v.trim().toLowerCase()),
                      style: AppTextStyles.body(size: 13),
                      cursorColor: AppColors.purple,
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: ref.tr('vocab_search_hint'),
                        hintStyle: AppTextStyles.muted(size: 13),
                      ),
                    ),
                  ),
                  if (_query.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                      child: const Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: AppColors.textMuted,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: topics.isEmpty
                  ? Center(
                      child: Text(
                        ref.tr('search_no_results'),
                        style: AppTextStyles.muted(),
                      ),
                    )
                  : GridView.builder(
                      itemCount: topics.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            childAspectRatio: 0.95,
                          ),
                      itemBuilder: (context, i) {
                        final topic = topics[i];
                        return GestureDetector(
                          onTap: () => _openTopic(topic),
                          child: GlowBox(
                            borderRadius: 22,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        topic.color,
                                        topic.color.withValues(alpha: 0.6),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(
                                    topic.icon,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  topicLabel(ref, topic),
                                  style: AppTextStyles.body(
                                    weight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  '${remainingCount(topic)} ${ref.tr('vocab_word_count')}',
                                  style: AppTextStyles.muted(size: 11),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
