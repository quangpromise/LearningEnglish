// ignore_for_file: prefer_initializing_formals
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../english_path/data/english_path_store.dart';
import '../../srs/data/srs_store.dart';
import 'daily_progress_store.dart';

/// Dong bo bo the SRS + so lieu 3 vong Tap/Hoc/Noi + tien do lo trinh tieng
/// Anh voi Supabase (bang user_gymtalk_state, migration 0074/0075) de khong
/// mat chuoi ngay/tien do khi doi may, va de ban be thay tien do trong "Thu
/// thach tuan".
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
    EnglishPathStore? path,
  }) : _supabase = supabase,
       _srs = srs ?? SrsStore.instance,
       _daily = daily ?? DailyProgressStore.instance,
       _path = path ?? EnglishPathStore.instance;

  static const _table = 'user_gymtalk_state';
  static const _lastUserKey = 'gymtalk_sync_last_user';

  final SupabaseClient _supabase;
  final SrsStore _srs;
  final DailyProgressStore _daily;
  final EnglishPathStore _path;

  /// Server chua chay migration 0075 (chua co cot path) - van dong bo
  /// srs/daily nhu cu, bo qua phan lo trinh.
  bool _pathColumnMissing = false;

  Timer? _debounce;
  bool _listening = false;
  bool _applyingRemote = false;
  bool _disposed = false;
  Future<void>? _running;

  final _settledUser = ValueNotifier<String?>(null);

  /// Tai khoan ma du lieu tren may (SRS, 3 vong, lo trinh) da thuoc ve sau 1
  /// luot dong bo trong phien nay - null = chua co luot nao xong. Milestone
  /// (MO-06) chi lay moc tu luc nay: truoc do so lieu co the con cua lan cai
  /// cu, cua tai khoan truoc, hoac chua keo ve.
  ValueListenable<String?> get settledUser => _settledUser;

  void _settle(String userId) {
    if (!_disposed) _settledUser.value = userId;
  }

  /// Bat dau nghe thay doi tren may (tu day len sau 5 giay) - goi 1 lan.
  void start() {
    if (_listening) return;
    _listening = true;
    _srs.addListener(_onLocalChanged);
    _daily.addListener(_onLocalChanged);
    _path.addListener(_onLocalChanged);
  }

  void _onLocalChanged() {
    if (_applyingRemote) return;
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 5), () => syncNow());
  }

  /// Co thay doi tren may TRONG LUC dang dong bo (sau khi da xuat du lieu)
  /// -> chay them 1 luot khi luot hien tai xong.
  bool _dirty = false;

  /// Dong bo ngay (mo app, quay lai app, sau thay doi). Loi mang chi log -
  /// du lieu van an toan tren may, lan sau thu lai.
  Future<void> syncNow() {
    final running = _running;
    if (running != null) {
      _dirty = true;
      return running;
    }
    _dirty = false;
    return _running = _sync().whenComplete(() {
      _running = null;
      if (_dirty) syncNow();
    });
  }

  Future<void> _sync() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    String? lastUser;
    var lastUserRead = false;
    try {
      await _srs.ensureLoaded();
      await _daily.ensureLoaded();
      await _path.ensureLoaded();
      final prefs = await SharedPreferences.getInstance();
      lastUser = prefs.getString(_lastUserKey);
      lastUserRead = true;

      final row = await _selectRow(userId);

      // CHI xoa du lieu may (cua tai khoan truoc) SAU khi da doc duoc du
      // lieu tai khoan moi - mat mang thi giu nguyen, khong day nham len.
      if (lastUser != null && lastUser != userId) {
        await _applyRemote(() async {
          await _srs.clearLocal();
          await _daily.clearLocal();
          await _path.clearLocal();
        });
      }
      if (row != null) {
        await _applyRemote(() async {
          final srs = row['srs'];
          final daily = row['daily'];
          if (srs is List) await _srs.mergeRemote(srs);
          if (daily is Map) {
            await _daily.mergeRemote(Map<String, dynamic>.from(daily));
          }
          // Cot path: gop theo luat merge; ban cua app moi hon thi giu
          // nguyen tren may va khong ghi de (canUpload = false).
          if (!_pathColumnMissing) await _path.mergeRemote(row['path']);
        });
      }
      await prefs.setString(_lastUserKey, userId);
      _settle(userId);
      await _supabase.from(_table).upsert({
        'user_id': userId,
        'srs': _srs.exportJson(),
        'daily': _daily.exportJson(),
        // Bo han khoa 'path' khi khong duoc ghi -> server giu gia tri cu.
        if (!_pathColumnMissing && _path.canUpload) 'path': _path.exportJson(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }, onConflict: 'user_id');
    } catch (e) {
      debugPrint('GymTalkSyncService sync failed: $e');
      if (lastUserRead && localDataBelongsTo(userId, lastUser: lastUser)) {
        _settle(userId);
      }
    }
  }

  Future<Map<String, dynamic>?> _selectRow(String userId) async {
    if (!_pathColumnMissing) {
      try {
        return await _supabase
            .from(_table)
            .select('srs, daily, path')
            .eq('user_id', userId)
            .maybeSingle();
      } on PostgrestException catch (e) {
        // 42703 = undefined_column (chua chay migration 0075). Chi dua vao
        // ma loi - loi khac van nem ra de lan sau thu lai.
        if (e.code != '42703') rethrow;
        _pathColumnMissing = true;
      }
    }
    return _supabase
        .from(_table)
        .select('srs, daily')
        .eq('user_id', userId)
        .maybeSingle();
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
    if (_disposed) return;
    _disposed = true;
    _settledUser.dispose();
    _debounce?.cancel();
    if (_listening) {
      _srs.removeListener(_onLocalChanged);
      _daily.removeListener(_onLocalChanged);
      _path.removeListener(_onLocalChanged);
      _listening = false;
    }
  }
}

/// Luot dong bo loi (vd mat mang) thi du lieu tren may co dung tam cho tai
/// khoan [userId] khong: co neu do la du lieu cua chinh tai khoan nay hoac
/// may chua dong bo lan nao; khong neu con la du lieu tai khoan truoc (chi
/// xoa sau khi keo duoc du lieu tai khoan moi).
@visibleForTesting
bool localDataBelongsTo(String userId, {required String? lastUser}) =>
    lastUser == null || lastUser == userId;
