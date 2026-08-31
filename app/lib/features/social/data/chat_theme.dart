import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_theme.dart';

/// 1 theme nen cho man chat - dung gradient MAU (nhu bo "Theme mau" cua
/// Messenger) thay vi anh nen/wallpaper tai tu 1 "kho theme" ben ngoai: anh
/// nen thuc su can ban quyen ro rang cho tung anh (giong quy tac nhac trong
/// CLAUDE.md), trong khi gradient sinh bang code thi mien phi tuyet doi va
/// khong gioi han so luong.
class ChatTheme {
  const ChatTheme(this.id, this.label, this.gradient);
  final String id;
  final String label;
  final LinearGradient gradient;
}

const kChatThemes = [
  ChatTheme('default', 'Mặc định', AppColors.screenGradient),
  ChatTheme(
    'ocean',
    'Đại dương',
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF0B2447), Color(0xFF19376D), Color(0xFF0A1128)],
    ),
  ),
  ChatTheme(
    'sunset',
    'Hoàng hôn',
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF3A0CA3), Color(0xFFB5179E), Color(0xFF480032)],
    ),
  ),
  ChatTheme(
    'forest',
    'Rừng xanh',
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF08361A), Color(0xFF14532D), Color(0xFF041C0D)],
    ),
  ),
  ChatTheme(
    'dream',
    'Tím mộng mơ',
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF231942), Color(0xFF5E60CE), Color(0xFF10062B)],
    ),
  ),
  ChatTheme(
    'rose',
    'Hồng pastel',
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF4A1942), Color(0xFFB23A6E), Color(0xFF2B0E28)],
    ),
  ),
  ChatTheme(
    'charcoal',
    'Than chì',
    LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF232526), Color(0xFF17181A), Color(0xFF0A0A0B)],
    ),
  ),
  ChatTheme(
    'fire',
    'Lửa cam',
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF5C1A00), Color(0xFFB5460F), Color(0xFF200800)],
    ),
  ),
];

ChatTheme themeById(String id) =>
    kChatThemes.firstWhere((t) => t.id == id, orElse: () => kChatThemes.first);

const _prefsKeyPrefix = 'chat_theme_';

/// Luu/doc theme nen DA CHON cho tung cuoc hoi thoai rieng (khong dung
/// chung 1 theme cho ca app) - key SharedPreferences theo id ban be, giong
/// cach appLanguageProvider luu lua chon ngon ngu.
class ChatThemeNotifier extends StateNotifier<String> {
  ChatThemeNotifier(this.friendId) : super('default') {
    _restore();
  }
  final String friendId;

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('$_prefsKeyPrefix$friendId');
    if (saved != null) state = saved;
  }

  Future<void> setTheme(String themeId) async {
    state = themeId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefsKeyPrefix$friendId', themeId);
  }
}

final chatThemeProvider =
    StateNotifierProvider.family<ChatThemeNotifier, String, String>(
      (ref, friendId) => ChatThemeNotifier(friendId),
    );
