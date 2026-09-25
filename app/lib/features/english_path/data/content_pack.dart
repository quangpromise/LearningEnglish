import 'dart:convert';

import 'package:flutter/services.dart';

import 'cefr_level.dart';

/// Content Pack dong goi trong app, sinh offline boi
/// `scripts/english_path_pipeline.py` (ADR-0003). Khong sua tay file JSON -
/// hash noi dung se lech va pack mat approval.
const kContentPackAsset = 'assets/english_path/pack.json';

/// Loai Practice Item. Cac loai khac (listening, gapFill, wordScramble,
/// grammar, ieltsMicro) duoc them cung ticket sinh ra chung.
enum PracticeItemType { meaning }

class ContentSource {
  const ContentSource({
    required this.id,
    required this.name,
    required this.license,
    required this.url,
  });

  factory ContentSource.fromJson(Map<String, dynamic> json) => ContentSource(
    id: json['id'] as String,
    name: json['name'] as String,
    license: json['license'] as String,
    url: json['url'] as String,
  );

  final String id;
  final String name;
  final String license;
  final String url;
}

/// Ket qua buoc cuoi cua quality gate: nguoi duyet da approve dung noi dung
/// co hash [contentHash].
class PackApproval {
  const PackApproval({
    required this.contentHash,
    required this.reviewer,
    required this.approvedAt,
  });

  factory PackApproval.fromJson(Map<String, dynamic> json) => PackApproval(
    contentHash: json['contentHash'] as String,
    reviewer: json['reviewer'] as String,
    approvedAt: json['approvedAt'] as String,
  );

  final String contentHash;
  final String reviewer;
  final String approvedAt;
}

class PathWord {
  const PathWord({
    required this.en,
    required this.ipa,
    required this.vi,
    required this.exampleEn,
    required this.exampleVi,
  });

  factory PathWord.fromJson(Map<String, dynamic> json) => PathWord(
    en: json['en'] as String,
    ipa: json['ipa'] as String,
    vi: json['vi'] as String,
    exampleEn: json['exampleEn'] as String,
    exampleVi: json['exampleVi'] as String,
  );

  final String en;
  final String ipa;
  final String vi;
  final String exampleEn;
  final String exampleVi;
}

class PracticeItem {
  const PracticeItem({
    required this.id,
    required this.unitId,
    required this.type,
    required this.prompt,
    required this.options,
    required this.answerIndex,
    required this.sourceIds,
    this.wordEn,
  });

  factory PracticeItem.fromJson(Map<String, dynamic> json) => PracticeItem(
    id: json['id'] as String,
    unitId: json['unitId'] as String,
    type: PracticeItemType.values.byName(json['type'] as String),
    prompt: json['prompt'] as String,
    options: (json['options'] as List).cast<String>(),
    answerIndex: json['answerIndex'] as int,
    sourceIds: (json['sourceIds'] as List).cast<String>(),
    wordEn: json['wordEn'] as String?,
  );

  final String id;
  final String unitId;
  final PracticeItemType type;
  final String prompt;
  final List<String> options;
  final int answerIndex;
  final List<String> sourceIds;

  /// Tu vung ma item nay luyen (neu co) - de noi voi SRS/audio.
  final String? wordEn;

  String get correctAnswer => options[answerIndex];
}

class PathUnit {
  const PathUnit({
    required this.id,
    required this.index,
    required this.titleEn,
    required this.titleVi,
    required this.words,
    required this.items,
  });

  factory PathUnit.fromJson(Map<String, dynamic> json) => PathUnit(
    id: json['id'] as String,
    index: json['index'] as int,
    titleEn: json['titleEn'] as String,
    titleVi: json['titleVi'] as String,
    words: [
      for (final w in json['words'] as List)
        PathWord.fromJson(w as Map<String, dynamic>),
    ],
    items: [
      for (final i in json['items'] as List)
        PracticeItem.fromJson(i as Map<String, dynamic>),
    ],
  );

  final String id;
  final int index;
  final String titleEn;
  final String titleVi;
  final List<PathWord> words;
  final List<PracticeItem> items;
}

class PathStage {
  const PathStage({required this.stage, required this.units});

  factory PathStage.fromJson(Map<String, dynamic> json) => PathStage(
    stage: CefrLevel.fromCode(json['cefr'] as String),
    units: [
      for (final u in json['units'] as List)
        PathUnit.fromJson(u as Map<String, dynamic>),
    ],
  );

  final CefrLevel stage;
  final List<PathUnit> units;
}

class ContentPack {
  const ContentPack({
    required this.schemaVersion,
    required this.packVersion,
    required this.contentHash,
    required this.approval,
    required this.sources,
    required this.stages,
  });

  factory ContentPack.fromJson(Map<String, dynamic> json) {
    final approval = json['approval'] as Map<String, dynamic>?;
    return ContentPack(
      schemaVersion: json['schemaVersion'] as int,
      packVersion: json['packVersion'] as String,
      contentHash: json['contentHash'] as String,
      approval: approval == null ? null : PackApproval.fromJson(approval),
      sources: [
        for (final s in json['sources'] as List)
          ContentSource.fromJson(s as Map<String, dynamic>),
      ],
      stages: [
        for (final s in json['stages'] as List)
          PathStage.fromJson(s as Map<String, dynamic>),
      ],
    );
  }

  static Future<ContentPack> load([AssetBundle? bundle]) async {
    final raw = await (bundle ?? rootBundle).loadString(kContentPackAsset);
    return ContentPack.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  final int schemaVersion;

  /// Phien ban noi dung, luu kem ket qua Placement de audit.
  final String packVersion;
  final String contentHash;
  final PackApproval? approval;
  final List<ContentSource> sources;
  final List<PathStage> stages;

  /// Da qua quality gate cho dung noi dung hien tai.
  bool get isApproved => approval?.contentHash == contentHash;

  PathUnit? unitById(String id) {
    for (final stage in stages) {
      for (final unit in stage.units) {
        if (unit.id == id) return unit;
      }
    }
    return null;
  }
}
