import '../../learning_path/data/learning_path_models.dart';
import 'vocabulary_data.dart';

/// Loc tu vung theo cap hoc - xem docs/research-level-based-content.md muc
/// 2-3. [level] null = "Tu hoc"/chua chon -> KHONG loc gi (hien day du).

/// Nhom muc do thong dung duoc hien o moi cap. Nang cao an `common` vi nguoi
/// da di lam/luyen thi gan nhu chac chan da biet cac tu do.
Set<VocabFrequency>? frequenciesForLevel(LearnerLevel? level) =>
    switch (level) {
      null => null,
      LearnerLevel.basic => const {VocabFrequency.common},
      LearnerLevel.intermediate => const {
        VocabFrequency.common,
        VocabFrequency.medium,
      },
      LearnerLevel.advanced => const {
        VocabFrequency.medium,
        VocabFrequency.rare,
      },
    };

/// Tu cua [topic] thuoc cap [level] (tu chua gan nhan frequency van hien o
/// moi cap - khong an nham tu moi soan chua kip phan loai).
List<VocabWord> wordsForLevel(VocabTopic topic, LearnerLevel? level) {
  final allowed = frequenciesForLevel(level);
  if (allowed == null) return topic.words;
  return topic.words
      .where((w) => w.frequency == null || allowed.contains(w.frequency))
      .toList();
}

/// Chu de co it hon so tu nay (sau khi loc theo cap) bi an khoi danh sach -
/// vd o cap Co ban, "Art" chi con 3 tu common, vao gan nhu trong rong.
const kMinWordsPerTopicForLevel = 10;

/// Danh sach chu de hien o cap [level]: an chu de qua it tu; rieng cap Co
/// ban xep chu de NHIEU tu co ban len dau (Daily Routines, Actions, Food...)
/// de nguoi moi bat dau tu cho de nhat. Cap khac giu nguyen thu tu goc.
List<VocabTopic> topicsForLevel(List<VocabTopic> topics, LearnerLevel? level) {
  if (level == null) return topics;
  final counts = {for (final t in topics) t: wordsForLevel(t, level).length};
  final visible = topics
      .where((t) => counts[t]! >= kMinWordsPerTopicForLevel)
      .toList();
  if (level == LearnerLevel.basic) {
    // Sap xep on dinh (giu thu tu goc khi bang so tu).
    final indexed = visible.asMap().entries.toList()
      ..sort((a, b) {
        final byCount = counts[b.value]!.compareTo(counts[a.value]!);
        return byCount != 0 ? byCount : a.key.compareTo(b.key);
      });
    return [for (final e in indexed) e.value];
  }
  return visible;
}
