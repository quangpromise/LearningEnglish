import 'package:supabase_flutter/supabase_flutter.dart';

/// 1 lan lam bai IELTS da luu - xem migration
/// supabase/migrations/0040_ielts_attempts.sql.
class IeltsAttemptRecord {
  const IeltsAttemptRecord({
    required this.id,
    required this.testId,
    required this.mode,
    required this.listeningCorrect,
    required this.listeningTotal,
    required this.readingCorrect,
    required this.readingTotal,
    required this.bandListening,
    required this.bandReading,
    required this.bandOverall,
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
  final double? bandListening;
  final double? bandReading;
  final double? bandOverall;
  final int? durationSeconds;
  final DateTime createdAt;

  factory IeltsAttemptRecord.fromRow(Map<String, dynamic> row) {
    int? asInt(dynamic v) => v == null ? null : (v as num).toInt();
    double? asDouble(dynamic v) => v == null ? null : (v as num).toDouble();
    return IeltsAttemptRecord(
      id: row['id'] as String,
      testId: row['test_id'] as String,
      mode: row['mode'] as String,
      listeningCorrect: asInt(row['listening_correct']) ?? 0,
      listeningTotal: asInt(row['listening_total']) ?? 0,
      readingCorrect: asInt(row['reading_correct']) ?? 0,
      readingTotal: asInt(row['reading_total']) ?? 0,
      bandListening: asDouble(row['band_listening']),
      bandReading: asDouble(row['band_reading']),
      bandOverall: asDouble(row['band_overall']),
      durationSeconds: asInt(row['duration_seconds']),
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }
}

class IeltsAttemptRepository {
  IeltsAttemptRepository(this._supabase);
  final SupabaseClient _supabase;

  Future<void> saveAttempt({
    required String testId,
    required String mode,
    required int listeningCorrect,
    required int listeningTotal,
    required int readingCorrect,
    required int readingTotal,
    required double bandListening,
    required double bandReading,
    required double bandOverall,
    required int durationSeconds,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    await _supabase.from('ielts_attempts').insert({
      'user_id': userId,
      'test_id': testId,
      'mode': mode,
      'listening_correct': listeningCorrect,
      'listening_total': listeningTotal,
      'reading_correct': readingCorrect,
      'reading_total': readingTotal,
      'band_listening': bandListening,
      'band_reading': bandReading,
      'band_overall': bandOverall,
      'duration_seconds': durationSeconds,
    });
  }

  Future<List<IeltsAttemptRecord>> fetchMyHistory() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];
    final rows = await _supabase
        .from('ielts_attempts')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (rows as List)
        .map((r) => IeltsAttemptRecord.fromRow(r as Map<String, dynamic>))
        .toList();
  }
}
