import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Danh dau bai Doan van (ngan hang theo cap) da lam xong - luu tren may
/// (SharedPreferences), dung de hien dau tick va dat ban tay goi y vao bai
/// CHUA lam dau tien. Khong dong bo server: chi la tien do tren thiet bi,
/// mat khi go app thi chi mat dau tick, khong mat du lieu hoc nao khac.
class WritingProgressRepository {
  static const _key = 'writing_done_paragraph_ids';

  Future<Set<String>> fetchDone() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_key) ?? const []).toSet();
  }

  Future<void> markDone(String paragraphId) async {
    final prefs = await SharedPreferences.getInstance();
    final done = (prefs.getStringList(_key) ?? const []).toSet()
      ..add(paragraphId);
    await prefs.setStringList(_key, done.toList());
  }
}

final writingProgressRepositoryProvider = Provider(
  (ref) => WritingProgressRepository(),
);

/// Tap id bai da lam xong - invalidate sau moi lan markDone de cap nhat dau
/// tick/ban tay ngay khi quay lai danh sach.
final writingDoneParagraphsProvider = FutureProvider<Set<String>>(
  (ref) => ref.watch(writingProgressRepositoryProvider).fetchDone(),
);
