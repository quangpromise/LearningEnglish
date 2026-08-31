import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';

enum CallType { voice, video }

enum CallStatus { ringing, accepted, declined, ended, missed }

class Call {
  const Call({
    required this.id,
    required this.callerId,
    required this.calleeId,
    required this.channelName,
    required this.type,
    required this.status,
  });

  factory Call.fromRow(Map<String, dynamic> row) => Call(
    id: row['id'] as int,
    callerId: row['caller_id'] as String,
    calleeId: row['callee_id'] as String,
    channelName: row['channel_name'] as String,
    type: (row['call_type'] as String) == 'video'
        ? CallType.video
        : CallType.voice,
    status: CallStatus.values.firstWhere(
      (s) => s.name == row['status'],
      orElse: () => CallStatus.ringing,
    ),
  );

  final int id;
  final String callerId;
  final String calleeId;
  final String channelName;
  final CallType type;
  final CallStatus status;
}

/// Goi thoai/video 1-1 qua Agora RTC - bang 'calls' (Supabase) CHI dung de
/// bao hieu (ai goi ai, chap nhan/tu choi/ket thuc), am thanh/hinh anh that
/// su truyen truc tiep qua ha tang Agora, khong qua Supabase - xem
/// supabase/migrations/0020_calls.sql va supabase/functions/agora-token.
class CallRepository {
  CallRepository(this._supabase);
  final SupabaseClient _supabase;

  String? get _myId => _supabase.auth.currentUser?.id;

  /// Agora can 1 uid dang so nguyen 32-bit cho moi nguoi trong 1 kenh - lay
  /// 8 ky tu hex dau cua user id (UUID) de co 1 gia tri ON DINH (cung 1
  /// nguoi luon ra cung uid) thay vi random moi lan, du khong lien quan gi
  /// den danh tinh that (chi Agora dung noi bo de phan biet cac nguoi tham
  /// gia trong kenh).
  int uidFor(String userId) =>
      int.parse(userId.replaceAll('-', '').substring(0, 8), radix: 16);

  Future<Call> startCall(String calleeId, CallType type) async {
    final myId = _myId;
    if (myId == null) throw StateError('Chua dang nhap');
    final channelName =
        'call_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1 << 32)}';
    final row = await _supabase
        .from('calls')
        .insert({
          'caller_id': myId,
          'callee_id': calleeId,
          'channel_name': channelName,
          'call_type': type.name,
        })
        .select()
        .single();
    return Call.fromRow(row);
  }

  Future<void> updateStatus(int callId, CallStatus status) async {
    await _supabase
        .from('calls')
        .update({
          'status': status.name,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', callId);
  }

  /// Xin token RTC tu Edge Function agora-token (server ky bang App
  /// Certificate bi mat, khong bao gio nhung vao app) - phai goi lai moi lan
  /// vao 1 kenh, token het han sau 1 gio.
  Future<String> fetchToken(String channelName, int uid) async {
    final res = await _supabase.functions.invoke(
      'agora-token',
      body: {'channel_name': channelName, 'uid': uid},
    );
    return (res.data as Map)['token'] as String;
  }

  /// Realtime: cuoc goi MOI dang do chuong toi minh (callee) - dung de hien
  /// man hinh "co cuoc goi den" ngay tren bat ky man hinh nao dang mo, giong
  /// cach watchNewIncomingMessages() lam voi tin nhan.
  Stream<Call?> watchIncomingCalls() {
    final myId = _myId;
    if (myId == null) return const Stream.empty();
    final seenIds = <int>{};
    return _supabase
        .from('calls')
        .stream(primaryKey: ['id'])
        .eq('callee_id', myId)
        .map((rows) {
          final ringing = rows
              .map(Call.fromRow)
              .where((c) => c.status == CallStatus.ringing)
              .toList();
          for (final c in ringing) {
            if (seenIds.add(c.id)) return c;
          }
          return null;
        })
        .where((c) => c != null)
        .cast<Call>();
  }

  /// Realtime: theo doi trang thai 1 cuoc goi cu the - dung o phia nguoi GOI
  /// de biet khi nao ben kia chap nhan/tu choi/cup may, tu dong dong man
  /// hinh "dang goi..." tuong ung.
  Stream<Call> watchCall(int callId) {
    return _supabase
        .from('calls')
        .stream(primaryKey: ['id'])
        .eq('id', callId)
        .map((rows) => Call.fromRow(rows.first));
  }
}
