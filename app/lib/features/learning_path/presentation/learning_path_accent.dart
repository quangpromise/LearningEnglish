import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../data/learning_path_models.dart';

/// Mau rieng cho tung persona - dung CHUNG cho ca chip dap an trong khao sat
/// (learning_path_survey_screen.dart) LAN highlight tile tren Home
/// (home_screen.dart), giup nguoi dung noi dung 2 man voi nhau va phan biet
/// ro cac muc "cap do" khac nhau (yeu cau: "mau chu cho moi cap do nen phan
/// biet de nhin").
Color personaColor(LearningPersona persona) => switch (persona) {
  LearningPersona.beginner => AppColors.pink,
  LearningPersona.grammarOverhaul => AppColors.amber,
  LearningPersona.dailyConversation => AppColors.teal,
  LearningPersona.officeEnglish => AppColors.blue,
  LearningPersona.toeicPrep => AppColors.purple,
  LearningPersona.ieltsPrep => AppColors.wealthAccent,
};
