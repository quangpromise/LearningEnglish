import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/features/story/data/story_data.dart';

void main() {
  group('kStories', () {
    test('co dung 1 micro-story cho Phase 1 (khong hon, khong kem - xem '
        'docs/architecture-multimedia-platform.md Phase 1: "implement '
        'exactly one B1 original micro-story")', () {
      expect(kStories.length, 1);
    });

    test('moi story co du du lieu de man hinh hien thi', () {
      for (final story in kStories) {
        expect(story.id, isNotEmpty, reason: story.title);
        expect(story.title, isNotEmpty);
        expect(story.level, 'B1');
        expect(story.segments, isNotEmpty, reason: story.title);
        expect(
          story.vocabulary.length,
          greaterThanOrEqualTo(8),
          reason: story.title,
        );
      }
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

    test('moi tu vung co du IPA/nghia/cau vi du de WordPopupSheet-style UI dung', () {
      for (final story in kStories) {
        for (final word in story.vocabulary) {
          expect(word.en.trim(), isNotEmpty, reason: story.title);
          expect(word.ipa.trim(), isNotEmpty, reason: word.en);
          expect(word.vi.trim(), isNotEmpty, reason: word.en);
          expect(word.exampleEn.trim(), isNotEmpty, reason: word.en);
          expect(word.exampleVi.trim(), isNotEmpty, reason: word.en);
        }
      }
    });
  });
}
