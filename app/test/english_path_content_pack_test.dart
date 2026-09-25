import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/features/english_path/data/cefr_stage.dart';
import 'package:learn_english_music/features/english_path/data/content_pack.dart';

/// Pack nho viet tay de test loader, doc lap voi asset that.
Map<String, dynamic> _fixture() => {
  'schemaVersion': 1,
  'contentHash': 'abc',
  'approval': {
    'contentHash': 'abc',
    'reviewer': 'maintainer',
    'approvedAt': '2026-09-25',
  },
  'sources': [
    {
      'id': 'cefrj',
      'name': 'CEFR-J',
      'license': 'Free with citation',
      'url': 'https://example.org',
    },
  ],
  'stages': [
    {
      'cefr': 'A1',
      'units': [
        {
          'id': 'a1-u01',
          'index': 1,
          'titleEn': 'Actions',
          'titleVi': 'Hành động',
          'words': [
            {
              'en': 'jump',
              'ipa': '/dʒʌmp/',
              'vi': 'nhảy',
              'exampleEn': 'Jump high.',
              'exampleVi': 'Nhảy cao.',
            },
          ],
          'items': [
            {
              'id': 'a1-u01-meaning-jump',
              'unitId': 'a1-u01',
              'type': 'meaning',
              'prompt': 'jump',
              'options': ['đá', 'nhảy', 'cười', 'khóc'],
              'answerIndex': 1,
              'wordEn': 'jump',
              'sourceIds': ['cefrj'],
            },
          ],
        },
      ],
    },
  ],
};

ContentPack _bundledPack() => ContentPack.fromJson(
  jsonDecode(File(kContentPackAsset).readAsStringSync())
      as Map<String, dynamic>,
);

String _norm(String s) =>
    s.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

void main() {
  group('ContentPack.fromJson', () {
    test('reads stages, units, words and items', () {
      final pack = ContentPack.fromJson(_fixture());
      final unit = pack.stages.single.units.single;
      expect(pack.stages.single.stage, CefrStage.a1);
      expect(unit.id, 'a1-u01');
      expect(unit.words.single.vi, 'nhảy');
      final item = unit.items.single;
      expect(item.type, PracticeItemType.meaning);
      expect(item.correctAnswer, 'nhảy');
      expect(pack.unitById('a1-u01'), same(unit));
      expect(pack.isApproved, isTrue);
    });

    test('is not approved when the approval hash is stale', () {
      final json = _fixture()
        ..['approval'] = {
          'contentHash': 'old',
          'reviewer': 'maintainer',
          'approvedAt': '2026-09-01',
        };
      expect(ContentPack.fromJson(json).isApproved, isFalse);
    });

    test('is not approved without an approval record', () {
      final json = _fixture()..['approval'] = null;
      expect(ContentPack.fromJson(json).isApproved, isFalse);
    });
  });

  group('bundled Content Pack integrity', () {
    test('asset folder is declared in pubspec', () {
      expect(
        File('pubspec.yaml').readAsStringSync(),
        contains('- assets/english_path/'),
      );
    });

    test('pack passed the quality gate (approved for this content hash)', () {
      final pack = _bundledPack();
      expect(pack.approval, isNotNull, reason: 'chua approve - xem pipeline');
      expect(pack.isApproved, isTrue, reason: 'approval cua noi dung cu');
      expect(pack.approval!.reviewer.trim(), isNotEmpty);
    });

    test('every source carries license and provenance', () {
      for (final s in _bundledPack().sources) {
        expect(s.license.trim(), isNotEmpty, reason: s.id);
        expect(s.url.trim(), isNotEmpty, reason: s.id);
      }
    });

    test('every item is well-formed and traceable to a licensed source', () {
      final pack = _bundledPack();
      final sourceIds = {for (final s in pack.sources) s.id};
      final seen = <String>{};
      var count = 0;
      for (final stage in pack.stages) {
        for (final unit in stage.units) {
          expect(unit.id, startsWith(stage.stage.code.toLowerCase()));
          for (final word in unit.words) {
            expect(word.vi.trim(), isNotEmpty, reason: word.en);
            expect(word.exampleVi.trim(), isNotEmpty, reason: word.en);
          }
          for (final item in unit.items) {
            count++;
            expect(seen.add(item.id), isTrue, reason: 'trung id ${item.id}');
            expect(item.unitId, unit.id, reason: item.id);
            expect(
              item.answerIndex,
              inInclusiveRange(0, item.options.length - 1),
              reason: item.id,
            );
            expect(
              item.options.map(_norm).toSet().length,
              item.options.length,
              reason: 'options trung ${item.id}',
            );
            expect(item.sourceIds, isNotEmpty, reason: item.id);
            expect(sourceIds.containsAll(item.sourceIds), isTrue);
          }
        }
      }
      expect(count, greaterThan(0));
    });
  });
}
