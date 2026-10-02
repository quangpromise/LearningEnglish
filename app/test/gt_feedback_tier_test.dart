import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/core/feedback/gt_feedback_tier.dart';

void main() {
  group('feedback tier (ADR-0008)', () {
    test('small actions stay inline', () {
      for (final e in [
        GtFeedbackEvent.setTicked,
        GtFeedbackEvent.cardGraded,
        GtFeedbackEvent.ringCompleted,
        GtFeedbackEvent.pronunciationScored,
      ]) {
        expect(feedbackTier(e), GtFeedbackTier.inline, reason: '$e');
      }
    });

    test('everyday XP is a toast: quests and finished decks', () {
      expect(
        feedbackTier(GtFeedbackEvent.questCompleted),
        GtFeedbackTier.toast,
      );
      expect(feedbackTier(GtFeedbackEvent.deckFinished), GtFeedbackTier.toast);
    });

    test('only the first workout of the day is a Milestone', () {
      expect(
        feedbackTier(GtFeedbackEvent.workoutFinished, firstToday: true),
        GtFeedbackTier.celebration,
      );
      expect(
        feedbackTier(GtFeedbackEvent.workoutFinished),
        GtFeedbackTier.toast,
      );
    });

    test('Milestones get the Celebration', () {
      for (final e in [
        GtFeedbackEvent.chestOpened,
        GtFeedbackEvent.levelTestPassed,
        GtFeedbackEvent.streakMilestone,
        GtFeedbackEvent.rankUp,
        GtFeedbackEvent.bodyLevelUp,
      ]) {
        expect(feedbackTier(e), GtFeedbackTier.celebration, reason: '$e');
      }
    });

    test('firstToday only matters for workouts', () {
      for (final e in GtFeedbackEvent.values) {
        if (e == GtFeedbackEvent.workoutFinished) continue;
        expect(
          feedbackTier(e, firstToday: true),
          feedbackTier(e),
          reason: '$e',
        );
      }
    });
  });
}
