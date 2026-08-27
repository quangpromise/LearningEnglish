import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';
import 'app_language.dart';

/// Từ điển chuỗi UI theo ngôn ngữ. Đây là chrome của app (nút, tiêu đề,
/// thông báo...) — KHÔNG áp dụng cho bảng từ vựng học Anh→Việt (word popup,
/// grammar, lyric...), vốn phải giữ nguyên cặp Anh-Việt vì đó là nội dung
/// học, không phải giao diện. Thêm key mới vào đây khi mở rộng sang màn
/// hình khác thay vì viết chuỗi cứng trong widget.
class AppStrings {
  const AppStrings._();

  static const Map<String, Map<AppLanguage, String>> _dict = {
    // Bottom nav (root_shell.dart)
    'nav_home': {AppLanguage.vi: 'Trang chủ', AppLanguage.en: 'Home'},
    'nav_quiz': {AppLanguage.vi: 'Đố vui', AppLanguage.en: 'Quiz'},
    'nav_pronunciation': {
      AppLanguage.vi: 'Luyện phát âm',
      AppLanguage.en: 'Pronunciation',
    },
    'nav_profile': {AppLanguage.vi: 'Hồ sơ', AppLanguage.en: 'Profile'},

    // Sign-in screen
    'auth_tagline': {
      AppLanguage.vi: 'Đăng nhập để lưu tiến độ & điểm thưởng',
      AppLanguage.en: 'Sign in to save your progress & rewards',
    },
    'auth_tab_signin': {AppLanguage.vi: 'Đăng nhập', AppLanguage.en: 'Sign in'},
    'auth_tab_signup': {AppLanguage.vi: 'Đăng ký', AppLanguage.en: 'Sign up'},
    'auth_username': {
      AppLanguage.vi: 'Tên người dùng',
      AppLanguage.en: 'Username',
    },
    'auth_email': {AppLanguage.vi: 'Email', AppLanguage.en: 'Email'},
    'auth_email_or_username': {
      AppLanguage.vi: 'Email hoặc tên người dùng',
      AppLanguage.en: 'Email or username',
    },
    'auth_password': {AppLanguage.vi: 'Mật khẩu', AppLanguage.en: 'Password'},
    'auth_forgot_password': {
      AppLanguage.vi: 'Quên mật khẩu?',
      AppLanguage.en: 'Forgot password?',
    },
    'auth_processing': {
      AppLanguage.vi: 'Đang xử lý...',
      AppLanguage.en: 'Processing...',
    },
    'auth_create_account': {
      AppLanguage.vi: 'Tạo tài khoản',
      AppLanguage.en: 'Create account',
    },
    'auth_signin_button': {
      AppLanguage.vi: 'Đăng nhập',
      AppLanguage.en: 'Sign in',
    },
    'auth_or': {AppLanguage.vi: 'hoặc', AppLanguage.en: 'or'},
    'auth_google_signin': {
      AppLanguage.vi: 'Đăng nhập bằng Google',
      AppLanguage.en: 'Sign in with Google',
    },
    'auth_google_processing': {
      AppLanguage.vi: 'Đang đăng nhập...',
      AppLanguage.en: 'Signing in...',
    },

    // Profile screen
    'profile_title': {AppLanguage.vi: 'Hồ sơ', AppLanguage.en: 'Profile'},
    'profile_streak_suffix': {
      AppLanguage.vi: 'ngày liên tiếp',
      AppLanguage.en: 'day streak',
    },
    'profile_words_learned': {
      AppLanguage.vi: 'Từ đã học',
      AppLanguage.en: 'Words learned',
    },
    'profile_songs_completed': {
      AppLanguage.vi: 'Bài hát hoàn thành',
      AppLanguage.en: 'Songs completed',
    },
    'profile_avg_score': {
      AppLanguage.vi: 'Điểm phát âm TB',
      AppLanguage.en: 'Avg. pronunciation',
    },
    'profile_practice_time': {
      AppLanguage.vi: 'Thời gian luyện tập',
      AppLanguage.en: 'Practice time',
    },
    'profile_voice_title': {
      AppLanguage.vi: 'Giọng đọc tiếng Anh',
      AppLanguage.en: 'English voice',
    },
    'profile_voice_subtitle': {
      AppLanguage.vi: 'Chọn giọng phát âm mẫu bạn thích',
      AppLanguage.en: 'Pick the sample voice you like',
    },
    'profile_change_password': {
      AppLanguage.vi: 'Đổi mật khẩu',
      AppLanguage.en: 'Change password',
    },
    'profile_change_password_subtitle': {
      AppLanguage.vi: 'Chỉ áp dụng cho tài khoản đăng ký email',
      AppLanguage.en: 'Only for email-registered accounts',
    },
    'profile_language_title': {
      AppLanguage.vi: 'Ngôn ngữ ứng dụng',
      AppLanguage.en: 'App language',
    },
    'profile_language_subtitle': {
      AppLanguage.vi: 'Đổi ngôn ngữ hiển thị giao diện',
      AppLanguage.en: 'Change the interface display language',
    },
    'profile_weekly_activity': {
      AppLanguage.vi: 'HOẠT ĐỘNG TUẦN NÀY',
      AppLanguage.en: 'THIS WEEK\'S ACTIVITY',
    },
    'profile_reset_stats': {
      AppLanguage.vi: 'Đặt lại thống kê',
      AppLanguage.en: 'Reset statistics',
    },
    'profile_sign_out': {
      AppLanguage.vi: 'Đăng xuất',
      AppLanguage.en: 'Sign out',
    },
    'common_cancel': {AppLanguage.vi: 'Huỷ', AppLanguage.en: 'Cancel'},
    'profile_signout_title': {
      AppLanguage.vi: 'Đăng xuất?',
      AppLanguage.en: 'Sign out?',
    },
    'profile_signout_body': {
      AppLanguage.vi: 'Bạn có chắc muốn đăng xuất khỏi tài khoản này?',
      AppLanguage.en: 'Are you sure you want to sign out of this account?',
    },
    'profile_reset_title': {
      AppLanguage.vi: 'Đặt lại thống kê?',
      AppLanguage.en: 'Reset statistics?',
    },
    'profile_reset_body': {
      AppLanguage.vi: 'Toàn bộ số liệu (từ đã học, bài hoàn thành, điểm phát âm, thời gian luyện tập) sẽ về 0. Không thể hoàn tác.',
      AppLanguage.en: 'All stats (words learned, songs completed, pronunciation score, practice time) will reset to 0. This cannot be undone.',
    },
    'profile_reset_confirm': {
      AppLanguage.vi: 'Đặt lại',
      AppLanguage.en: 'Reset',
    },
    'profile_stats_error': {
      AppLanguage.vi: 'Không tải được thống kê:',
      AppLanguage.en: "Couldn't load stats:",
    },
    'profile_no_activity': {
      AppLanguage.vi: 'Chưa có hoạt động nào tuần này',
      AppLanguage.en: 'No activity this week yet',
    },
    'profile_avatar_error': {
      AppLanguage.vi: 'Không tải được avatar:',
      AppLanguage.en: "Couldn't upload avatar:",
    },
  };

  static String t(String key, AppLanguage lang) =>
      _dict[key]?[lang] ?? _dict[key]?[AppLanguage.vi] ?? key;
}

/// `ref.tr('key')` thay vì phải watch(appLanguageProvider) + gọi
/// AppStrings.t thủ công ở từng widget.
extension AppTr on WidgetRef {
  String tr(String key) => AppStrings.t(key, watch(appLanguageProvider));
}
