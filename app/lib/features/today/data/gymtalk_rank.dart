import '../../english_path/data/cefr_level.dart';
import '../../fitness/data/body_level.dart';

/// Thang nao dang giu GymTalk Rank lai.
enum RankSide { body, english, balanced }

/// GymTalk Rank (CONTEXT.md): bac THAP hon giua Body Level va English Level
/// - 2 thang ghep tung bac: Rookie-A1, Regular-A2, Athlete-B1, Pro-B2,
/// Beast-C1. Chi khuyen khich can bang, khong khoa gi (ADR-0002).
class GymTalkRank {
  const GymTalkRank({
    required this.tier,
    required this.body,
    required this.english,
    required this.limitedBy,
  });

  /// 0 (Rookie/A1) .. 4 (Beast/C1).
  final int tier;
  final BodyLevel body;
  final CefrLevel english;
  final RankSide limitedBy;
}

GymTalkRank gymTalkRank(BodyLevel body, CefrLevel english) {
  final b = body.index;
  final e = english.index;
  return GymTalkRank(
    tier: b < e ? b : e,
    body: body,
    english: english,
    limitedBy: b == e
        ? RankSide.balanced
        : (b < e ? RankSide.body : RankSide.english),
  );
}
