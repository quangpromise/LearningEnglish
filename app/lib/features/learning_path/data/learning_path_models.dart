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
