import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/core/providers/app_providers.dart';
import 'package:learn_english_music/features/wealth/data/recurring_service_model.dart';

Map<String, dynamic> _baseRow({String? appSection}) => {
  'id': 's1',
  'name': 'Gym membership',
  'default_amount': 500000,
  'currency': 'VND',
  'cycle_type': 'month',
  'start_date': '2026-01-01',
  'expiry_date': '2026-02-01',
  'reminder_lead_days': 7,
  'app_section': appSection,
};

void main() {
  group('RecurringService.appSection', () {
    test('fromRow doc dung app_section khi co', () {
      final s = RecurringService.fromRow(
        _baseRow(appSection: kServiceAppSectionFitness),
      );
      expect(s.appSection, kServiceAppSectionFitness);
    });

    test('fromRow tra ve null khi khong co app_section (dich vu chung)', () {
      final s = RecurringService.fromRow(_baseRow());
      expect(s.appSection, isNull);
    });
  });

  group('AppSectionServiceCodeX.recurringServiceCode', () {
    test('anh xa dung ma cho tung AppSection', () {
      expect(
        AppSection.fitness.recurringServiceCode,
        kServiceAppSectionFitness,
      );
      expect(
        AppSection.learnEnglish.recurringServiceCode,
        kServiceAppSectionLearnEnglish,
      );
      expect(AppSection.wealth.recurringServiceCode, isNull);
    });
  });
}
