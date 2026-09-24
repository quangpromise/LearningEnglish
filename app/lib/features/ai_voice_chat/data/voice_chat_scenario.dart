/// Tinh huong hoi thoai cho AI Voice Chat. [free] = tro chuyen tu do nhu
/// truoc day; cac tinh huong khac them 1 doan huong dan vao system prompt
/// (xem GeminiLiveDirectClient.scenarioInstruction).
enum VoiceChatScenario {
  free,

  /// GymTalk: nhap vai huan luyen vien ca nhan trong phong gym - luyen dung
  /// tieng Anh nguoi hoc can khi tap (hoi may, dat lich PT, mo ta chan
  /// thuong, hoi ky thuat...).
  personalTrainer;

  /// Key AppStrings cho tieu de man hinh.
  String get titleKey => switch (this) {
    VoiceChatScenario.free => 'voice_chat_title',
    VoiceChatScenario.personalTrainer => 'voice_chat_pt_title',
  };

  /// Doan huong dan them vao system prompt (tieng Anh - noi dung hoi thoai
  /// luon la tieng Anh). null = khong them gi.
  String? get instruction => switch (this) {
    VoiceChatScenario.free => null,
    VoiceChatScenario.personalTrainer =>
      'ROLE-PLAY: You are Alex, an energetic but kind personal trainer at a '
          'gym. The learner is your gym member. Stay in this role for the '
          'whole conversation. Start by greeting them and asking what they '
          'are training today. Rotate through realistic gym situations, one '
          'at a time: asking how to use a machine, booking a personal '
          'training session, describing a sore muscle or a minor injury, '
          'asking about sets, reps and rest time, talking about their '
          'fitness goals and diet. Naturally use gym vocabulary (reps, '
          'sets, form, warm up, brace your core, range of motion, spotter) '
          'and briefly explain a word if the learner seems confused. Never '
          'give medical advice beyond "rest and see a doctor if it hurts". '
          'Keep correcting mistakes with the exact "Correction: " format.',
  };
}
