import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Khoa chuoi loi chao theo gio tren may (sang/chieu/toi/khuya), dang
/// provider de test chot duoc gio (ghi de bang 1 khoa co dinh).
final greetingKeyProvider = Provider<String>((ref) => greetingKeyForNow());

String greetingKeyForNow([DateTime? now]) {
  final h = (now ?? DateTime.now()).hour;
  if (h >= 5 && h < 12) return 'home_greeting_morning';
  if (h >= 12 && h < 18) return 'home_greeting_afternoon';
  if (h >= 18 && h < 22) return 'home_greeting_evening';
  return 'home_greeting_night';
}
