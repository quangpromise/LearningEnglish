/// 3 tang phan hoi (ADR-0008): tai cho (tick, so dem len, rung) -> XP Toast
/// cho viec thuong ngay -> Celebration toan man CHI cho Milestone.
enum GtFeedbackTier { inline, toast, celebration }

/// Cac su kien co phan hoi trong app (spec #96).
enum GtFeedbackEvent {
  setTicked,
  cardGraded,
  ringCompleted,
  pronunciationScored,
  questCompleted,
  deckFinished,
  workoutFinished,
  chestOpened,
  levelTestPassed,
  streakMilestone,
  rankUp,
  bodyLevelUp,
}

/// Tang phan hoi cua [event]. [firstToday] chi dung cho
/// [GtFeedbackEvent.workoutFinished]: buoi hoan thanh DAU TIEN trong ngay la
/// Milestone, cac buoi sau la viec thuong ngay.
GtFeedbackTier feedbackTier(GtFeedbackEvent event, {bool firstToday = false}) =>
    switch (event) {
      GtFeedbackEvent.setTicked ||
      GtFeedbackEvent.cardGraded ||
      GtFeedbackEvent.ringCompleted ||
      GtFeedbackEvent.pronunciationScored => GtFeedbackTier.inline,
      GtFeedbackEvent.questCompleted ||
      GtFeedbackEvent.deckFinished => GtFeedbackTier.toast,
      GtFeedbackEvent.workoutFinished =>
        firstToday ? GtFeedbackTier.celebration : GtFeedbackTier.toast,
      GtFeedbackEvent.chestOpened ||
      GtFeedbackEvent.levelTestPassed ||
      GtFeedbackEvent.streakMilestone ||
      GtFeedbackEvent.rankUp ||
      GtFeedbackEvent.bodyLevelUp => GtFeedbackTier.celebration,
    };
