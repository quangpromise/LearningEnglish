/// Cac tile tren Home co the duoc "goi y" - dung de anh xa persona ->
/// tap hop tile lien quan, KHONG phai 1 man hinh rieng (xem
/// docs/research-learning-path.md muc 7 - da doi huong theo yeu cau nguoi
/// dung: van hien du moi tinh nang tren Home, chi highlight + gan hinh ban
/// tay vao tile goi y dau tien).
enum HomeFeature {
  vocabulary,
  grammar,
  reading,
  writing,
  phonics,
  pronunciation,
  story,
  toeic,
  ielts,
  quiz,
}

/// 6 nhom nguoi hoc (persona) - xem docs/research-learning-path.md muc 2.
enum LearningPersona {
  beginner,
  dailyConversation,
  officeEnglish,
  grammarOverhaul,
  toeicPrep,
  ieltsPrep,
}

/// 3 cap hoc gom tu 6 persona - moi feature (Tu vung, Luyen viet, AI Voice
/// Chat...) chi doc cap nay de loc noi dung, KHONG tu suy luan tu persona -
/// xem docs/research-level-based-content.md muc 2. Nguoi dung chon "Tu hoc"
/// (hoac chua lam khao sat) = khong co cap nao (null) -> hien day du, khong
/// loc, khong goi y.
enum LearnerLevel {
  basic, // A1-A2
  intermediate, // A2-B1
  advanced; // B1-C1

  String get labelKey => switch (this) {
    basic => 'learner_level_basic',
    intermediate => 'learner_level_intermediate',
    advanced => 'learner_level_advanced',
  };
}

/// Du lieu tu khao sat "Ke hoach hoc ca nhan". Persona van duoc luu rieng
/// de cac man hien co co the loc noi dung nhu cu; profile giu them ngu canh
/// de bo lap ke hoach (va sau nay de AI dieu chinh ke hoach).
class LearnerProfile {
  const LearnerProfile({
    required this.persona,
    required this.goal,
    required this.dailyMinutes,
    required this.prioritySkills,
    required this.interestTopics,
  });

  final LearningPersona persona;
  final LearningPersona goal;
  final int dailyMinutes;
  final List<String> prioritySkills;
  final List<String> interestTopics;

  Map<String, dynamic> toJson() => {
    'persona': persona.name,
    'goal': goal.name,
    'daily_minutes': dailyMinutes,
    'priority_skills': prioritySkills,
    'interest_topics': interestTopics,
  };
}

/// Mot bai trong ke hoach 7 ngay. V1 dung content da kiem duyet trong app;
/// AI sau nay chi can xep lai danh sach nay, khong tu sinh bai hoc vo kiem
/// chung.
class LearningPlanItem {
  const LearningPlanItem({
    required this.day,
    required this.feature,
    required this.title,
    required this.reason,
  });

  final int day;
  final HomeFeature feature;
  final String title;
  final String reason;
}

List<LearningPlanItem> buildFirstWeekPlan(LearnerProfile profile) {
  final primary = profile.prioritySkills.isEmpty
      ? HomeFeature.vocabulary
      : _featureForSkill(profile.prioritySkills.first);
  final goalFeature = switch (profile.goal) {
    LearningPersona.toeicPrep => HomeFeature.toeic,
    LearningPersona.ieltsPrep => HomeFeature.ielts,
    LearningPersona.dailyConversation => HomeFeature.pronunciation,
    LearningPersona.officeEnglish => HomeFeature.writing,
    LearningPersona.beginner => HomeFeature.phonics,
    LearningPersona.grammarOverhaul => HomeFeature.grammar,
  };
  final topic = profile.interestTopics.isEmpty
      ? 'chủ đề thiết thực'
      : 'chủ đề ${profile.interestTopics.first.toLowerCase()}';
  return [
    LearningPlanItem(
      day: 1,
      feature: primary,
      title: 'Khởi động với $topic',
      reason: 'Bắt đầu từ kỹ năng bạn ưu tiên.',
    ),
    LearningPlanItem(
      day: 2,
      feature: HomeFeature.grammar,
      title: 'Củng cố cấu trúc câu',
      reason: 'Giúp dùng từ mới thành câu đúng.',
    ),
    LearningPlanItem(
      day: 3,
      feature: HomeFeature.pronunciation,
      title: 'Luyện nói câu ngắn',
      reason: 'Tăng phản xạ và sự tự tin.',
    ),
    LearningPlanItem(
      day: 4,
      feature: goalFeature,
      title: 'Bài học theo mục tiêu',
      reason: 'Phục vụ trực tiếp mục tiêu đã chọn.',
    ),
    LearningPlanItem(
      day: 5,
      feature: HomeFeature.writing,
      title: 'Viết để ghi nhớ',
      reason: 'Vận dụng từ vựng và ngữ pháp.',
    ),
    LearningPlanItem(
      day: 6,
      feature: HomeFeature.story,
      title: 'Nghe và đọc hiểu',
      reason: 'Tiếp xúc tiếng Anh trong ngữ cảnh.',
    ),
    LearningPlanItem(
      day: 7,
      feature: HomeFeature.quiz,
      title: 'Ôn tập trong tuần',
      reason: 'Củng cố kiến thức trước tuần tiếp theo.',
    ),
  ];
}

HomeFeature _featureForSkill(String skill) => switch (skill) {
  'Nghe' => HomeFeature.story,
  'Nói' => HomeFeature.pronunciation,
  'Ngữ pháp' => HomeFeature.grammar,
  'Đọc' => HomeFeature.reading,
  'Viết' => HomeFeature.writing,
  _ => HomeFeature.vocabulary,
};

extension LearningPersonaLevel on LearningPersona {
  LearnerLevel get level => switch (this) {
    LearningPersona.beginner => LearnerLevel.basic,
    LearningPersona.dailyConversation => LearnerLevel.intermediate,
    LearningPersona.grammarOverhaul => LearnerLevel.intermediate,
    LearningPersona.officeEnglish => LearnerLevel.advanced,
    LearningPersona.toeicPrep => LearnerLevel.advanced,
    LearningPersona.ieltsPrep => LearnerLevel.advanced,
  };
}

/// Danh sach tinh nang goi y cho tung persona - PHAN TU DAU TIEN la "top
/// pick" (duoc gan hinh ban tay dong tren Home), cac phan tu con lai chi
/// duoc highlight vien/glow, khong co ban tay - xem
/// docs/research-learning-path.md muc 4.
const kPersonaRecommendations = <LearningPersona, List<HomeFeature>>{
  LearningPersona.beginner: [
    HomeFeature.phonics,
    HomeFeature.vocabulary,
    HomeFeature.grammar,
    HomeFeature.writing,
  ],
  LearningPersona.dailyConversation: [
    HomeFeature.vocabulary,
    HomeFeature.pronunciation,
    HomeFeature.grammar,
  ],
  LearningPersona.officeEnglish: [
    HomeFeature.vocabulary,
    HomeFeature.writing,
    HomeFeature.grammar,
  ],
  LearningPersona.grammarOverhaul: [
    HomeFeature.grammar,
    HomeFeature.vocabulary,
    HomeFeature.quiz,
    HomeFeature.writing,
  ],
  LearningPersona.toeicPrep: [
    HomeFeature.vocabulary,
    HomeFeature.grammar,
    HomeFeature.phonics,
    HomeFeature.toeic,
  ],
  LearningPersona.ieltsPrep: [
    HomeFeature.vocabulary,
    HomeFeature.grammar,
    HomeFeature.writing,
    HomeFeature.ielts,
  ],
};
