import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/features/story/data/story_data.dart';

void main() {
  group('kStories', () {
    test('co it nhat 1 story cho moi chu de trong StoryCategory - mo rong '
        'tu Phase 1 (chi co dung 1 micro-story B1) sang day du 13 chu de '
        'kieu dailydictation.com, noi dung TU VIET MOI, xem '
        'docs/architecture-multimedia-platform.md Phase 1', () {
      final categoriesCovered = kStories.map((s) => s.category).toSet();
      for (final category in StoryCategory.values) {
        expect(
          categoriesCovered.contains(category),
          isTrue,
          reason: 'Thieu story cho chu de $category',
        );
      }
    });

    test('moi story co du du lieu de man hinh hien thi', () {
      const validLevels = {'A1', 'A2', 'B1', 'B2', 'C1', 'C2'};
      for (final story in kStories) {
        expect(story.id, isNotEmpty, reason: story.title);
        expect(story.title, isNotEmpty);
        expect(validLevels.contains(story.level), isTrue, reason: story.title);
        expect(story.segments, isNotEmpty, reason: story.title);
        expect(
          story.vocabulary.length,
          greaterThanOrEqualTo(5),
          reason: story.title,
        );
      }
    });

    test('id story la duy nhat tren toan bo kStories - dung lam lesson_id '
        'ghi tien do, trung id se ghi de tien do sai story', () {
      final ids = kStories.map((s) => s.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('id doan la duy nhat trong pham vi 1 story - dung lam key on dinh '
        'khi cuon toi / chon lam muc tieu shadowing', () {
      for (final story in kStories) {
        final ids = story.segments.map((s) => s.id).toList();
        expect(ids.toSet().length, ids.length, reason: story.title);
      }
    });

    test('moi doan co ca EN va VI, khong rong', () {
      for (final story in kStories) {
        for (final segment in story.segments) {
          expect(segment.en.trim(), isNotEmpty, reason: segment.id);
          expect(segment.vi.trim(), isNotEmpty, reason: segment.id);
        }
      }
    });

    test(
      'moi tu vung co du IPA/nghia/cau vi du de WordPopupSheet-style UI dung',
      () {
        for (final story in kStories) {
          for (final word in story.vocabulary) {
            expect(word.en.trim(), isNotEmpty, reason: story.title);
            expect(word.ipa.trim(), isNotEmpty, reason: word.en);
            expect(word.vi.trim(), isNotEmpty, reason: word.en);
            expect(word.exampleEn.trim(), isNotEmpty, reason: word.en);
            expect(word.exampleVi.trim(), isNotEmpty, reason: word.en);
          }
        }
      },
    );
  });
}
