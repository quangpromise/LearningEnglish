import '../../../core/widgets/gt_celebration.dart';
import '../../english_path/data/cefr_level.dart';
import '../../fitness/data/body_level.dart';

/// The "Len GymTalk Rank" cho bac [from] -> [to] (0-based; bac k = Body Level
/// thu k ghep CEFR thu k, CONTEXT.md GymTalk Rank) - dung trong Celebration
/// cua Level Test va cua Body Level (#121). [tr]: chuoi theo ngon ngu app.
GtRankUp rankUpCard({
  required int from,
  required int to,
  required String Function(String key) tr,
}) => GtRankUp(
  fromTier: from + 1,
  toTier: to + 1,
  title: tr('gt_milestone_rank_title'),
  detail: rankDetail(to, tr),
);

/// "Bac 3: Athlete · B1" cho bac [tier] (0-based).
String rankDetail(int tier, String Function(String key) tr) =>
    tr('gt_milestone_rank_sub')
        .replaceFirst('{tier}', '${tier + 1}')
        .replaceFirst('{body}', tr('body_level_${BodyLevel.values[tier].name}'))
        .replaceFirst('{english}', CefrLevel.values[tier].code);
