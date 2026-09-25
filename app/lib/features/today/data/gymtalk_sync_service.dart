import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../srs/data/srs_store.dart';
import 'daily_progress_store.dart';

/// Dong bo bo the SRS + so lieu 3 vong Tap/Hoc/Noi voi Supabase
/// (bang user_gymtalk_state, migration 0074) de khong mat chuoi ngay khi
/// doi may, va de ban be thay tien do trong "Thu thach tuan".
///
/// Moi lan dong bo: doc dong tren server -> GOP vao may (SRS: the co han
/// on muon hon thang; vong: MAX tung bo dem) -> ghi ban da gop len server.
/// Gop kieu nay khong lam mat du lieu du 2 may cung dung, va chay lai bao
/// nhieu lan cung ra cung ket qua.
///
/// Dang nhap tai khoan KHAC tren cung may -> xoa du lieu tren may truoc
/// khi keo ve, tranh lan so lieu cua 2 nguoi.
class GymTalkSyncService {
  GymTalkSyncService({
    required SupabaseClient supabase,
    SrsStore? srs,
    DailyProgressStore? daily,
  }) : _supabase = supabase,
       _srs = srs ?? SrsStore.instance,
       _daily = daily ?? DailyProgressStore.instance;

  static const _table = 'user_gymtalk_state';
  static const _lastUserKey = 'gymtalk_sync_last_user';

  final SupabaseClient _supabase;
  final SrsStore _srs;
  final DailyProgressStore _daily;

  Timer? _debounce;
  bool _listening = false;
  bool _applyingRemote = false;
  Future<void>? _running;

  /// Bat dau nghe thay doi tren may (tu day len sau 5 giay) - goi 1 lan.
  void start() {
    if (_listening) return;
    _listening = true;
    _srs.addListener(_onLocalChanged);
    _daily.addListener(_onLocalChanged);
  }

  void _onLocalChanged() {
    if (_applyingRemote) return;
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 5), () => syncNow());
  }

  /// Dong bo ngay (mo app, quay lai app, sau thay doi). Loi mang chi log -
  /// du lieu van an toan tren may, lan sau thu lai.
  Future<void> syncNow() => _running ??= _sync().whenComplete(() {
    _running = null;
  });

  Future<void> _sync() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    await _srs.ensureLoaded();
    await _daily.ensureLoaded();

    final prefs = await SharedPreferences.getInstance();
    final lastUser = prefs.getString(_lastUserKey);
    if (lastUser != null && lastUser != userId) {
      await _applyRemote(() async {
        await _srs.clearLocal();
        await _daily.clearLocal();
      });
    }
    await prefs.setString(_lastUserKey, userId);

    try {
      final row = await _supabase
          .from(_table)
          .select('srs, daily')
          .eq('user_id', userId)
          .maybeSingle();
      if (row != null) {
        await _applyRemote(() async {
          final srs = row['srs'];
          final daily = row['daily'];
          if (srs is List) await _srs.mergeRemote(srs);
          if (daily is Map) {
            await _daily.mergeRemote(Map<String, dynamic>.from(daily));
          }
        });
      }
      await _supabase.from(_table).upsert({
        'user_id': userId,
        'srs': _srs.exportJson(),
        'daily': _daily.exportJson(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }, onConflict: 'user_id');
    } catch (e) {
      debugPrint('GymTalkSyncService sync failed: $e');
    }
  }

  /// Ap du lieu tu server/xoa may ma KHONG kich hoat vong day len lai.
  Future<void> _applyRemote(Future<void> Function() action) async {
    _applyingRemote = true;
    try {
      await action();
    } finally {
      _applyingRemote = false;
    }
  }

  void dispose() {
    _debounce?.cancel();
    if (_listening) {
      _srs.removeListener(_onLocalChanged);
      _daily.removeListener(_onLocalChanged);
    }
  }
}
