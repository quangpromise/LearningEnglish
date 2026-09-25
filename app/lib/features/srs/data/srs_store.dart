import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Khoang cach on (ngay) theo hop Leitner: hop 0 on ngay trong hom, hop 1
/// sau 1 ngay, ... hop 5 sau 35 ngay.
const kSrsIntervalsDays = [0, 1, 3, 7, 16, 35];

/// Hop tu duoc coi la "da thuoc" (xep cuoi khi chon tu moi cho buoi tap).
const kSrsMasteredBox = 4;

/// Hop cao nhat (= so phan tu [kSrsIntervalsDays] - 1).
const kSrsMaxBox = 5;

/// Ngay (khong gio) theo gio may - moc tinh han on.
DateTime srsDateOnly(DateTime t) => DateTime(t.year, t.month, t.day);

/// 1 the on tap. Luu KEM noi dung (khong chi khoa) vi tu hoc tu "Tu moi moi
/// ngay" het han luc nua dem - khong con nguon nao khac de hien lai.
@immutable
class SrsCard {
  const SrsCard({
    required this.key,
    required this.en,
    required this.vi,
    this.ipa = '',
    this.exampleEn = '',
    this.exampleVi = '',
    this.box = 0,
    required this.due,
    this.reviewedAt,
  });

  factory SrsCard.fromJson(Map<String, dynamic> json) => SrsCard(
    key: json['key'] as String,
    en: json['en'] as String? ?? '',
    vi: json['vi'] as String? ?? '',
    ipa: json['ipa'] as String? ?? '',
    exampleEn: json['exEn'] as String? ?? '',
    exampleVi: json['exVi'] as String? ?? '',
    box: (json['box'] as num?)?.toInt() ?? 0,
    due: DateTime.tryParse(json['due'] as String? ?? '') ?? DateTime(2000),
    reviewedAt: DateTime.tryParse(json['rev'] as String? ?? ''),
  );

  /// Khoa on dinh = tu tieng Anh viet thuong.
  final String key;
  final String en;
  final String vi;
  final String ipa;
  final String exampleEn;
  final String exampleVi;
  final int box;

  /// Ngay den han on (chi phan ngay co y nghia).
  final DateTime due;

  /// Lan on gan nhat (UTC) - dung de gop giua 2 may: lan on MOI HON thang,
  /// ke ca khi do la lan "Quen" (han on lui ve hom nay).
  final DateTime? reviewedAt;

  bool isDue(DateTime now) => !srsDateOnly(due).isAfter(srsDateOnly(now));

  SrsCard copyWith({int? box, DateTime? due, DateTime? reviewedAt}) => SrsCard(
    key: key,
    en: en,
    vi: vi,
    ipa: ipa,
    exampleEn: exampleEn,
    exampleVi: exampleVi,
    box: box ?? this.box,
    due: due ?? this.due,
    reviewedAt: reviewedAt ?? this.reviewedAt,
  );

  Map<String, dynamic> toJson() => {
    'key': key,
    'en': en,
    'vi': vi,
    'ipa': ipa,
    'exEn': exampleEn,
    'exVi': exampleVi,
    'box': box,
    'due': srsDateOnly(due).toIso8601String(),
    if (reviewedAt != null) 'rev': reviewedAt!.toUtc().toIso8601String(),
  };
}

/// Bo the on tap lap lai ngat quang (Leitner co lich theo ngay) dung chung
/// cho ca app: tu vung gym (the "Hoc khi nghi") va tu hoc qua "Tu moi moi
/// ngay". Luu tren may (SharedPreferences) - chi la lich on ca nhan.
///
/// Singleton + ChangeNotifier de man Hom nay/On tap tu cap nhat so the den
/// han ngay khi nguoi dung on o bat ky dau.
class SrsStore extends ChangeNotifier {
  SrsStore._();
  static final SrsStore instance = SrsStore._();

  /// Tao store rieng (test) - khong dung chung singleton.
  @visibleForTesting
  factory SrsStore.forTest() => SrsStore._();

  static const _prefKey = 'srs_cards_v1';

  final Map<String, SrsCard> _cards = {};
  Future<void>? _loading;

  Future<void> ensureLoaded() => _loading ??= _load();

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefKey);
      if (raw != null) {
        final list = jsonDecode(raw) as List;
        for (final item in list) {
          final card = SrsCard.fromJson(Map<String, dynamic>.from(item as Map));
          _cards.putIfAbsent(card.key, () => card);
        }
      }
    } catch (e) {
      debugPrint('SrsStore load failed: $e');
    }
    notifyListeners();
  }

  Future<void> _writeChain = Future.value();

  /// Xep hang cac lan ghi (xem WorkoutOutbox._persist) - on nhanh 2 the lien
  /// tiep khong lam lan ghi cu de len lan ghi moi.
  Future<void> _save() => _writeChain = _writeChain.then((_) => _write());

  Future<void> _write() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _prefKey,
        jsonEncode([for (final c in _cards.values) c.toJson()]),
      );
    } catch (e) {
      debugPrint('SrsStore save failed: $e');
    }
  }

  /// Moi khoa luu o dang chu thuong (boxOf/review/boxes deu tra theo dang
  /// nay) - tranh 1 tu bi luu 2 lan khac hoa/thuong.
  static SrsCard _withKey(SrsCard card, String key) => SrsCard(
    key: key,
    en: card.en,
    vi: card.vi,
    ipa: card.ipa,
    exampleEn: card.exampleEn,
    exampleVi: card.exampleVi,
    box: card.box,
    due: card.due,
    reviewedAt: card.reviewedAt,
  );

  int boxOf(String key) => _cards[key.toLowerCase()]?.box ?? 0;

  bool contains(String key) => _cards.containsKey(key.toLowerCase());

  /// Hop hien tai cua moi the (khoa -> hop) - dung de chon tu cho buoi tap.
  Map<String, int> get boxes => {for (final c in _cards.values) c.key: c.box};

  /// The den han on tinh den [now], han som nhat + hop thap nhat truoc.
  List<SrsCard> dueCards(DateTime now) {
    final due = _cards.values.where((c) => c.isDue(now)).toList()
      ..sort((a, b) {
        final byDue = a.due.compareTo(b.due);
        return byDue != 0 ? byDue : a.box - b.box;
      });
    return due;
  }

  // ---------------------------------------------------------------------
  // Dong bo tai khoan (xem gymtalk_sync_service.dart)
  // ---------------------------------------------------------------------

  /// Toan bo the dang JSON de day len Supabase.
  List<Map<String, dynamic>> exportJson() => [
    for (final c in _cards.values) c.toJson(),
  ];

  /// Gop bo the tu server vao may. Moi khoa giu the co han on MUON hon (vua
  /// on/nho gan day hon), bang nhau thi hop cao hon - gop nhieu lan van ra
  /// cung ket qua. Tra ve true neu bo the tren may thay doi.
  Future<bool> mergeRemote(List<dynamic> remote) async {
    await ensureLoaded();
    var changed = false;
    for (final item in remote) {
      if (item is! Map) continue;
      final incoming = SrsCard.fromJson(Map<String, dynamic>.from(item));
      final key = incoming.key.toLowerCase();
      final local = _cards[key];
      if (local == null || _isNewer(incoming, local)) {
        _cards[key] = incoming.key == key ? incoming : _withKey(incoming, key);
        changed = true;
      }
    }
    if (changed) {
      notifyListeners();
      await _save();
    }
    return changed;
  }

  static bool _isNewer(SrsCard a, SrsCard b) {
    final ra = a.reviewedAt, rb = b.reviewedAt;
    if (ra != null || rb != null) {
      if (ra == null) return false;
      if (rb == null) return true;
      return ra.isAfter(rb);
    }
    final byDue = srsDateOnly(a.due).compareTo(srsDateOnly(b.due));
    return byDue != 0 ? byDue > 0 : a.box > b.box;
  }

  /// Xoa sach bo the tren may (doi sang tai khoan khac).
  Future<void> clearLocal() async {
    await ensureLoaded();
    _cards.clear();
    notifyListeners();
    await _save();
  }

  int dueCount(DateTime now) => _cards.values.where((c) => c.isDue(now)).length;

  int get totalCards => _cards.length;

  /// Them the moi (den han on ngay hom nay) neu chua co.
  Future<void> addIfAbsent(SrsCard card) async {
    await ensureLoaded();
    final key = card.key.toLowerCase();
    if (_cards.containsKey(key)) return;
    _cards[key] = card.key == key ? card : _withKey(card, key);
    notifyListeners();
    await _save();
  }

  /// Ghi nhan 1 lan on: [known] -> len 1 hop, han on lui theo khoang cach
  /// cua hop moi; quen -> ve hop 0, on lai ngay trong hom. [content] dung
  /// khi the chua co trong bo (vd lan dau gap tu gym luc nghi).
  Future<void> review(
    String key, {
    required bool known,
    required DateTime now,
    SrsCard? content,
  }) async {
    await ensureLoaded();
    final lower = key.toLowerCase();
    final existing = _cards[lower];
    final current =
        existing ??
        (content == null || content.key == lower
            ? content
            : _withKey(content, lower));
    if (current == null) return;
    final box = known ? min(current.box + 1, kSrsMaxBox) : 0;
    _cards[lower] = current.copyWith(
      box: box,
      due: srsDateOnly(now).add(Duration(days: kSrsIntervalsDays[box])),
      reviewedAt: now.toUtc(),
    );
    notifyListeners();
    await _save();
  }
}
