import 'package:flutter/material.dart';

import '../../learning_path/data/learning_path_models.dart';
import 'bank/writing_bank_books.dart';
import 'bank/writing_bank_city.dart';
import 'bank/writing_bank_countryside.dart';
import 'bank/writing_bank_education.dart';
import 'bank/writing_bank_environment.dart';
import 'bank/writing_bank_family.dart';
import 'bank/writing_bank_festival.dart';
import 'bank/writing_bank_finance.dart';
import 'bank/writing_bank_food.dart';
import 'bank/writing_bank_friendship.dart';
import 'bank/writing_bank_health.dart';
import 'bank/writing_bank_hobbies.dart';
import 'bank/writing_bank_internet.dart';
import 'bank/writing_bank_movies.dart';
import 'bank/writing_bank_music.dart';
import 'bank/writing_bank_pets.dart';
import 'bank/writing_bank_science.dart';
import 'bank/writing_bank_shopping.dart';
import 'bank/writing_bank_sports.dart';
import 'bank/writing_bank_technology.dart';
import 'bank/writing_bank_traffic.dart';
import 'bank/writing_bank_travel.dart';
import 'bank/writing_bank_weather.dart';
import 'bank/writing_bank_work.dart';
import 'writing_paragraph_data.dart';

/// 1 chu de trong ngan hang Doan van theo cap: moi chu de 24 bai = 8 Co ban
/// + 8 Trung cap + 8 Nang cao (xem docs/research-level-based-content.md muc
/// 4c). Noi dung TU SOAN, moi chu de 1 file rieng trong thu muc bank/ de
/// nhieu nguoi soan song song khong dung conflict.
class WritingTopic {
  const WritingTopic({
    required this.id,
    required this.titleVi,
    required this.titleEn,
    required this.icon,
    required this.color,
    required this.paragraphs,
  });

  final String id;
  final String titleVi;
  final String titleEn;
  final IconData icon;
  final Color color;
  final List<WritingParagraph> paragraphs;

  /// Bai cua 1 cap - [level] null (Tu hoc) = tat ca bai cua chu de.
  List<WritingParagraph> paragraphsFor(LearnerLevel? level) => level == null
      ? paragraphs
      : paragraphs.where((p) => p.level == level).toList();
}

/// Du ca 24 chu de (khop dung 24 chu de cua bo "On tong hop 12 thi" cu -
/// xem writing_mixed_list_screen.dart) - moi chu de 8 bai/cap.
const kWritingTopics = <WritingTopic>[
  kWritingBankFamily,
  kWritingBankFood,
  kWritingBankShopping,
  kWritingBankWeather,
  kWritingBankHobbies,
  kWritingBankTravel,
  kWritingBankHealth,
  kWritingBankWork,
  kWritingBankTechnology,
  kWritingBankEnvironment,
  kWritingBankEducation,
  kWritingBankSports,
  kWritingBankTraffic,
  kWritingBankFinance,
  kWritingBankMusic,
  kWritingBankMovies,
  kWritingBankPets,
  kWritingBankFriendship,
  kWritingBankInternet,
  kWritingBankCity,
  kWritingBankCountryside,
  kWritingBankFestival,
  kWritingBankBooks,
  kWritingBankScience,
];
