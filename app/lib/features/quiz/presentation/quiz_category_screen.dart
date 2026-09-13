import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../data/quiz_data.dart';
import 'leaderboard_screen.dart';
import 'quiz_question_screen.dart';
import 'quiz_result_screen.dart';

// Danh sach icon/mau CO DINH theo dung thu tu [kCategories] trong
// quiz_data.dart. QUAN TRONG: 2 danh sach nay phai co it nhat bang so luong
// phan tu cua kCategories - neu khong `_catIcons[i]`/`_catColors[i]` se nem
// RangeError ngay trong itemBuilder, khien Flutter (o che do release) render
// 1 o trong/xam thay vi loi do, nhin giong "man hinh trang xoa" (bug thuc te
// da gap khi them 5 chu de moi ma quen cap nhat 2 danh sach nay). Moi khi
// them chu de moi vao kCategories, PHAI them 1 dong tuong ung o day.
const _catIcons = [
  Icons.extension_rounded, // Choi chu
  Icons.psychology_alt_rounded, // Suy luan
  Icons.pets_rounded, // Dong vat
  Icons.home_rounded, // Cuoc song
  Icons.abc_rounded, // Bang chu cai
  Icons.directions_car_filled_rounded, // Trai cay & xe co
  Icons.eco_rounded, // Trai cay & rau cu
  Icons.local_shipping_rounded, // Phuong tien giao thong
  Icons.wb_sunny_rounded, // Thoi tiet & thien nhien
  Icons.chair_rounded, // Do vat trong nha
  Icons.palette_rounded, // Mau sac
];
const _catColors = [
  AppColors.blue,
  AppColors.teal,
  AppColors.pink,
  AppColors.amber,
  AppColors.purple,
  AppColors.blue,
  AppColors.teal,
  AppColors.pink,
  AppColors.amber,
  AppColors.purple,
  AppColors.blue,
];

enum _QuizStep { categories, question, result, leaderboard }

/// Khung duy nhat cho ca tinh nang Do vui (chon chu de -> tra loi cau hoi ->
/// ket qua -> bang xep hang) - KHONG mo them popup/route nao, chuyen "man
/// hinh" bang setState doi noi dung - xem giai thich chi tiet trong
/// VocabularyTopicsScreen (cung nguyen tac, dung lam mau).
class QuizCategoryScreen extends ConsumerStatefulWidget {
  const QuizCategoryScreen({super.key});

  @override
  ConsumerState<QuizCategoryScreen> createState() => _QuizCategoryScreenState();
}

class _QuizCategoryScreenState extends ConsumerState<QuizCategoryScreen> {
  _QuizStep _step = _QuizStep.categories;
  String _activeCategory = '';
  List<Riddle> _activeRiddles = const [];
  List<bool> _results = const [];
  int _xp = 0;

  void _openCategory(String cat, List<Riddle> riddles) {
    setState(() {
      _activeCategory = cat;
      _activeRiddles = riddles;
      _step = _QuizStep.question;
    });
  }

  void _backToCategories() => setState(() => _step = _QuizStep.categories);

  void _finishQuestions(List<bool> results) {
    setState(() {
      _results = results;
      _step = _QuizStep.result;
    });
  }

  void _openLeaderboard(int xp) {
    setState(() {
      _xp = xp;
      _step = _QuizStep.leaderboard;
    });
  }

  void _backToResult() => setState(() => _step = _QuizStep.result);

  @override
  Widget build(BuildContext context) {
    switch (_step) {
      case _QuizStep.question:
        return QuizQuestionScreen(
          category: _activeCategory,
          riddles: _activeRiddles,
          onBack: _backToCategories,
          onFinished: _finishQuestions,
        );
      case _QuizStep.result:
        return QuizResultScreen(
          riddles: _activeRiddles,
          results: _results,
          onRetry: _backToCategories,
          onOpenLeaderboard: _openLeaderboard,
        );
      case _QuizStep.leaderboard:
        return LeaderboardScreen(myXp: _xp, onBack: _backToResult);
      case _QuizStep.categories:
        return _buildCategories(context);
    }
  }

  Widget _buildCategories(BuildContext context) {
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
                        ref.tr('quiz_title'),
                        style: AppTextStyles.heading(size: 20),
                      ),
                      Text(
                        ref.tr('quiz_subtitle'),
                        style: AppTextStyles.muted(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Expanded(
              child: GridView.builder(
                itemCount: kCategories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.95,
                ),
                itemBuilder: (context, i) {
                  final cat = kCategories[i];
                  final count = kRiddles.where((r) => r.category == cat).length;
                  return GestureDetector(
                    onTap: () {
                      final riddles = kRiddles
                          .where((r) => r.category == cat)
                          .toList();
                      _openCategory(cat, riddles.isEmpty ? kRiddles : riddles);
                    },
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
                                  _catColors[i],
                                  _catColors[i].withValues(alpha: 0.6),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              _catIcons[i],
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            categoryLabel(ref, cat),
                            style: AppTextStyles.body(weight: FontWeight.w800),
                          ),
                          Text(
                            '$count ${ref.tr('quiz_riddle_count')}',
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
