import 'package:supabase_flutter/supabase_flutter.dart';

/// 1 lan lam bai TOEIC da luu - xem migration
/// supabase/migrations/0039_toeic_attempts.sql.
class ToeicAttemptRecord {
  const ToeicAttemptRecord({
    required this.id,
    required this.testId,
    required this.mode,
    required this.listeningCorrect,
    required this.listeningTotal,
    required this.readingCorrect,
    required this.readingTotal,
    required this.scaledListening,
    required this.scaledReading,
    required this.scaledTotal,
    required this.durationSeconds,
    required this.createdAt,
  });

  final String id;
  final String testId;
  final String mode;
  final int listeningCorrect;
  final int listeningTotal;
  final int readingCorrect;
  final int readingTotal;
  final int? scaledListening;
  final int? scaledReading;
  final int? scaledTotal;
  final int? durationSeconds;
  final DateTime createdAt;

  factory ToeicAttemptRecord.fromRow(Map<String, dynamic> row) {
    int? asInt(dynamic v) => v == null ? null : (v as num).toInt();
    return ToeicAttemptRecord(
      id: row['id'] as String,
      testId: row['test_id'] as String,
      mode: row['mode'] as String,
      listeningCorrect: asInt(row['listening_correct']) ?? 0,
      listeningTotal: asInt(row['listening_total']) ?? 0,
      readingCorrect: asInt(row['reading_correct']) ?? 0,
      readingTotal: asInt(row['reading_total']) ?? 0,
      scaledListening: asInt(row['scaled_listening']),
      scaledReading: asInt(row['scaled_reading']),
      scaledTotal: asInt(row['scaled_total']),
      durationSeconds: asInt(row['duration_seconds']),
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }
}

class ToeicAttemptRepository {
  ToeicAttemptRepository(this._supabase);
  final SupabaseClient _supabase;

  Future<void> saveAttempt({
    required String testId,
    required String mode,
    required int listeningCorrect,
    required int listeningTotal,
    required int readingCorrect,
    required int readingTotal,
    required int scaledListening,
    required int scaledReading,
    required int scaledTotal,
    required int durationSeconds,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    await _supabase.from('toeic_attempts').insert({
      'user_id': userId,
      'test_id': testId,
      'mode': mode,
      'listening_correct': listeningCorrect,
      'listening_total': listeningTotal,
      'reading_correct': readingCorrect,
      'reading_total': readingTotal,
      'scaled_listening': scaledListening,
      'scaled_reading': scaledReading,
      'scaled_total': scaledTotal,
      'duration_seconds': durationSeconds,
    });
  }

  Future<List<ToeicAttemptRecord>> fetchMyHistory() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];
    final rows = await _supabase
        .from('toeic_attempts')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (rows as List)
        .map((r) => ToeicAttemptRecord.fromRow(r as Map<String, dynamic>))
        .toList();
  }
}
