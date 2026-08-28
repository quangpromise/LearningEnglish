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
    'nav_vocab': {AppLanguage.vi: 'Từ vựng', AppLanguage.en: 'Vocabulary'},

    // Vocabulary feature (vocabulary_*_screen.dart)
    'vocab_title': {
      AppLanguage.vi: 'Từ vựng theo chủ đề',
      AppLanguage.en: 'Vocabulary by topic',
    },
    'vocab_subtitle': {
      AppLanguage.vi: 'Chọn một chủ đề để bắt đầu học',
      AppLanguage.en: 'Pick a topic to start learning',
    },
    'vocab_word_count': {AppLanguage.vi: 'từ', AppLanguage.en: 'words'},
    'vocab_select_hint': {
      AppLanguage.vi: 'Chọn tối đa {max} từ để học hôm nay',
      AppLanguage.en: 'Select up to {max} words to learn today',
    },
    'vocab_start_learning': {
      AppLanguage.vi: 'Bắt đầu học',
      AppLanguage.en: 'Start learning',
    },
    'vocab_question_label': {AppLanguage.vi: 'Câu', AppLanguage.en: 'Question'},
    'vocab_choose_word_for': {
      AppLanguage.vi: 'CHỌN TỪ TIẾNG ANH ĐÚNG CHO',
      AppLanguage.en: 'CHOOSE THE CORRECT ENGLISH WORD FOR',
    },
    'vocab_completed': {
      AppLanguage.vi: 'HOÀN THÀNH',
      AppLanguage.en: 'COMPLETED',
    },
    'vocab_correct_count': {
      AppLanguage.vi: 'câu đúng',
      AppLanguage.en: 'correct',
    },
    'vocab_done': {AppLanguage.vi: 'Xong', AppLanguage.en: 'Done'},

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
      AppLanguage.vi: 'Không tải được thống kê lúc này.',
      AppLanguage.en: "Couldn't load stats right now.",
    },
    'profile_stats_retry': {AppLanguage.vi: 'Thử lại', AppLanguage.en: 'Retry'},
    'profile_no_activity': {
      AppLanguage.vi: 'Chưa có hoạt động nào tuần này',
      AppLanguage.en: 'No activity this week yet',
    },
    'profile_avatar_error': {
      AppLanguage.vi: 'Không tải được avatar:',
      AppLanguage.en: "Couldn't upload avatar:",
    },

    // Home screen
    'home_greeting': {AppLanguage.vi: 'Xin chào', AppLanguage.en: 'Hello'},
    'home_search_hint': {
      AppLanguage.vi: 'Tìm bài hát, ca sĩ...',
      AppLanguage.en: 'Search songs, artists...',
    },
    'home_try_listening': {
      AppLanguage.vi: 'GỢI Ý NGHE THỬ',
      AppLanguage.en: 'TRY LISTENING',
    },
    'home_suggested_for_you': {
      AppLanguage.vi: 'Gợi ý cho bạn',
      AppLanguage.en: 'Suggested for you',
    },
    'home_search_results': {
      AppLanguage.vi: 'Kết quả tìm kiếm',
      AppLanguage.en: 'Search results',
    },
    'home_favorites_title': {
      AppLanguage.vi: 'Bài hát yêu thích',
      AppLanguage.en: 'Favorite songs',
    },
    'home_no_favorites': {
      AppLanguage.vi: 'Chưa có bài hát yêu thích nào.\nBấm biểu tượng trái tim khi nghe để lưu.',
      AppLanguage.en: 'No favorite songs yet.\nTap the heart icon while listening to save one.',
    },
    'home_no_results': {
      AppLanguage.vi: 'Không tìm thấy bài hát nào',
      AppLanguage.en: 'No songs found',
    },
    'song_level_basic': {AppLanguage.vi: 'Cơ bản', AppLanguage.en: 'Basic'},
    'song_level_intermediate': {
      AppLanguage.vi: 'Trung cấp',
      AppLanguage.en: 'Intermediate',
    },
    'song_level_advanced': {
      AppLanguage.vi: 'Nâng cao',
      AppLanguage.en: 'Advanced',
    },

    // Player screen
    'player_now_playing': {
      AppLanguage.vi: 'ĐANG PHÁT',
      AppLanguage.en: 'NOW PLAYING',
    },
    'player_load_error': {
      AppLanguage.vi: 'Không tải được nhạc. Kiểm tra kết nối mạng.',
      AppLanguage.en: 'Couldn\'t load the song. Check your connection.',
    },
    'player_bilingual_toggle': {
      AppLanguage.vi: 'Song ngữ Anh – Việt',
      AppLanguage.en: 'Bilingual English – Vietnamese',
    },

    // Word popup
    'word_listen_pronunciation': {
      AppLanguage.vi: 'Nghe phát âm',
      AppLanguage.en: 'Listen to pronunciation',
    },
    'word_save': {AppLanguage.vi: 'Lưu từ', AppLanguage.en: 'Save word'},
    'word_in_song': {
      AppLanguage.vi: 'TRONG BÀI HÁT',
      AppLanguage.en: 'IN THE SONG',
    },
    'word_no_pos': {
      AppLanguage.vi: 'Chưa rõ từ loại',
      AppLanguage.en: 'Unknown part of speech',
    },
    'word_translate_error': {
      AppLanguage.vi: '(không dịch được — kiểm tra mạng)',
      AppLanguage.en: "(couldn't translate — check your network)",
    },

    // Grammar screen
    'grammar_title': {AppLanguage.vi: 'Ngữ pháp', AppLanguage.en: 'Grammar'},
    'grammar_structure': {
      AppLanguage.vi: 'CẤU TRÚC',
      AppLanguage.en: 'STRUCTURE',
    },
    'grammar_quick_quiz': {
      AppLanguage.vi: 'BÀI TẬP NHANH',
      AppLanguage.en: 'QUICK QUIZ',
    },
    'grammar_next_question': {
      AppLanguage.vi: 'Câu tiếp theo',
      AppLanguage.en: 'Next question',
    },
    'grammar_see_result': {
      AppLanguage.vi: 'Xem kết quả',
      AppLanguage.en: 'See result',
    },
    'grammar_continue': {
      AppLanguage.vi: 'Tiếp tục',
      AppLanguage.en: 'Continue',
    },
    'grammar_score_prefix': {
      AppLanguage.vi: 'Bạn đúng',
      AppLanguage.en: 'You got',
    },
    'grammar_score_suffix': {
      AppLanguage.vi: 'câu.',
      AppLanguage.en: 'correct.',
    },

    // Pronunciation screen
    'pron_title': {
      AppLanguage.vi: 'Luyện phát âm',
      AppLanguage.en: 'Pronunciation practice',
    },
    'pron_read_this': {
      AppLanguage.vi: 'ĐỌC THEO CÂU NÀY',
      AppLanguage.en: 'READ THIS SENTENCE',
    },
    'pron_change_sentence': {
      AppLanguage.vi: 'Đổi câu',
      AppLanguage.en: 'Change',
    },
    'pron_no_mic': {
      AppLanguage.vi: 'Thiết bị chưa hỗ trợ hoặc chưa cấp quyền micro.',
      AppLanguage.en:
          'Device unsupported or microphone permission not granted.',
    },
    'pron_listening_stop': {
      AppLanguage.vi: 'Đang nghe... chạm để dừng',
      AppLanguage.en: 'Listening... tap to stop',
    },
    'pron_tap_to_record': {
      AppLanguage.vi: 'Chạm để bắt đầu ghi âm',
      AppLanguage.en: 'Tap to start recording',
    },
    'pron_scoring': {
      AppLanguage.vi: 'Đang chấm điểm...',
      AppLanguage.en: 'Scoring...',
    },
    'pron_play_recording': {
      AppLanguage.vi: 'Nghe lại giọng của bạn',
      AppLanguage.en: 'Listen back to your recording',
    },
    'pron_playing': {
      AppLanguage.vi: 'Đang phát...',
      AppLanguage.en: 'Playing...',
    },
    'pron_retry': {AppLanguage.vi: 'Thử lại', AppLanguage.en: 'Try again'},
    'pron_done': {AppLanguage.vi: 'Xong', AppLanguage.en: 'Done'},
    'pron_pick_title': {
      AppLanguage.vi: 'Chọn câu luyện tập',
      AppLanguage.en: 'Choose a sentence to practice',
    },
    'pron_custom_label': {
      AppLanguage.vi: 'TỰ NHẬP TỪ HOẶC CÂU',
      AppLanguage.en: 'TYPE YOUR OWN WORD OR SENTENCE',
    },
    'pron_custom_hint': {
      AppLanguage.vi: 'vd: pronunciation',
      AppLanguage.en: 'e.g. pronunciation',
    },
    'pron_pick_from_song': {
      AppLanguage.vi: 'HOẶC CHỌN LỜI TỪ BÀI HÁT',
      AppLanguage.en: 'OR PICK A LYRIC FROM A SONG',
    },
    'pron_mic_permission_missing': {
      AppLanguage.vi: 'Chưa có quyền micro để ghi âm.',
      AppLanguage.en: 'Microphone permission not granted.',
    },
    'pron_record_failed': {
      AppLanguage.vi: 'Không ghi âm được:',
      AppLanguage.en: "Couldn't record:",
    },
    'pron_playback_failed': {
      AppLanguage.vi: 'Không phát lại được:',
      AppLanguage.en: "Couldn't play back:",
    },

    // Quiz
    'quiz_title': {
      AppLanguage.vi: 'Đố vui tiếng Anh',
      AppLanguage.en: 'English riddles',
    },
    'quiz_subtitle': {
      AppLanguage.vi: 'Chọn chủ đề để bắt đầu thử thách',
      AppLanguage.en: 'Pick a category to start the challenge',
    },
    'quiz_riddle_count': {AppLanguage.vi: 'câu đố', AppLanguage.en: 'riddles'},
    'quiz_completed': {
      AppLanguage.vi: 'HOÀN THÀNH THỬ THÁCH',
      AppLanguage.en: 'CHALLENGE COMPLETE',
    },
    'quiz_correct_count': {
      AppLanguage.vi: 'câu đúng',
      AppLanguage.en: 'correct',
    },
    'quiz_retry': {AppLanguage.vi: 'Làm lại', AppLanguage.en: 'Retry'},
    'quiz_leaderboard_button': {
      AppLanguage.vi: 'Bảng xếp hạng',
      AppLanguage.en: 'Leaderboard',
    },
    'quiz_question_label': {AppLanguage.vi: 'Câu', AppLanguage.en: 'Question'},
    'quiz_reward_hint': {
      AppLanguage.vi: 'Trả lời đúng để nhận +10 XP',
      AppLanguage.en: 'Answer correctly to earn +10 XP',
    },

    // Leaderboard
    'leaderboard_title': {
      AppLanguage.vi: 'Bảng xếp hạng',
      AppLanguage.en: 'Leaderboard',
    },
    'leaderboard_subtitle': {
      AppLanguage.vi: 'Xếp hạng theo tổng XP đố vui của tất cả người dùng',
      AppLanguage.en: 'Ranked by total quiz XP across all users',
    },
    'leaderboard_error': {
      AppLanguage.vi: 'Không tải được bảng xếp hạng:',
      AppLanguage.en: "Couldn't load the leaderboard:",
    },
    'leaderboard_empty': {
      AppLanguage.vi: 'Chưa có ai trên bảng xếp hạng.\nHoàn thành 1 lượt đố vui để lên hạng đầu tiên!',
      AppLanguage.en: 'No one on the leaderboard yet.\nFinish a quiz to claim the first spot!',
    },
    'leaderboard_you_suffix': {
      AppLanguage.vi: '(Bạn)',
      AppLanguage.en: '(You)',
    },
    'leaderboard_your_rank': {
      AppLanguage.vi: 'Hạng của bạn',
      AppLanguage.en: 'Your rank',
    },
    'leaderboard_rank_error': {
      AppLanguage.vi: 'Không tải được hạng của bạn',
      AppLanguage.en: "Couldn't load your rank",
    },

    // Voice settings
    'voice_settings_title': {
      AppLanguage.vi: 'Giọng đọc tiếng Anh',
      AppLanguage.en: 'English voice',
    },
    'voice_settings_subtitle': {
      AppLanguage.vi: 'Chạm để chọn và nghe thử — áp dụng cho mọi chỗ phát âm mẫu trong app.',
      AppLanguage.en: 'Tap to choose and preview — applies everywhere the app plays a sample pronunciation.',
    },
    'voice_preview_text': {
      AppLanguage.vi: 'Hello, this is a preview of my voice.',
      AppLanguage.en: 'Hello, this is a preview of my voice.',
    },
    'voice_en_us': {
      AppLanguage.vi: 'Tiếng Anh (Mỹ)',
      AppLanguage.en: 'English (US)',
    },
    'voice_en_gb': {
      AppLanguage.vi: 'Tiếng Anh (Anh)',
      AppLanguage.en: 'English (UK)',
    },
    'voice_en_au': {
      AppLanguage.vi: 'Tiếng Anh (Úc)',
      AppLanguage.en: 'English (Australia)',
    },
    'voice_en_in': {
      AppLanguage.vi: 'Tiếng Anh (Ấn Độ)',
      AppLanguage.en: 'English (India)',
    },
    'voice_en_ca': {
      AppLanguage.vi: 'Tiếng Anh (Canada)',
      AppLanguage.en: 'English (Canada)',
    },

    // Change password sheet
    'change_password_title': {
      AppLanguage.vi: 'Đổi mật khẩu',
      AppLanguage.en: 'Change password',
    },
    'change_password_subtitle': {
      AppLanguage.vi: 'Chỉ áp dụng cho tài khoản đăng ký bằng email.',
      AppLanguage.en: 'Only applies to email-registered accounts.',
    },
    'change_password_new': {
      AppLanguage.vi: 'Mật khẩu mới',
      AppLanguage.en: 'New password',
    },
    'change_password_confirm': {
      AppLanguage.vi: 'Nhập lại mật khẩu mới',
      AppLanguage.en: 'Confirm new password',
    },
    'change_password_short': {
      AppLanguage.vi: 'Mật khẩu cần ít nhất 6 ký tự.',
      AppLanguage.en: 'Password must be at least 6 characters.',
    },
    'change_password_mismatch': {
      AppLanguage.vi: 'Mật khẩu nhập lại không khớp.',
      AppLanguage.en: "Passwords don't match.",
    },
    'change_password_success': {
      AppLanguage.vi: 'Đổi mật khẩu thành công!',
      AppLanguage.en: 'Password changed successfully!',
    },
    'change_password_failed': {
      AppLanguage.vi: 'Thất bại:',
      AppLanguage.en: 'Failed:',
    },
    'change_password_confirm_button': {
      AppLanguage.vi: 'Xác nhận đổi mật khẩu',
      AppLanguage.en: 'Confirm password change',
    },
    'processing_ellipsis': {
      AppLanguage.vi: 'Đang xử lý...',
      AppLanguage.en: 'Processing...',
    },

    // Reset password screen
    'reset_password_title': {
      AppLanguage.vi: 'Đặt mật khẩu mới',
      AppLanguage.en: 'Set a new password',
    },
    'reset_password_subtitle': {
      AppLanguage.vi: 'Nhập mật khẩu mới cho tài khoản của bạn.',
      AppLanguage.en: 'Enter a new password for your account.',
    },
    'reset_password_confirm_button': {
      AppLanguage.vi: 'Xác nhận',
      AppLanguage.en: 'Confirm',
    },

    // Update dialog
    'update_available_title': {
      AppLanguage.vi: 'Có bản cập nhật mới',
      AppLanguage.en: 'New update available',
    },
    'update_available_body': {
      AppLanguage.vi: 'Tải và cài đè trực tiếp lên app hiện tại — dữ liệu & đăng nhập của bạn vẫn được giữ nguyên.',
      AppLanguage.en: 'Downloads and installs over the current app — your data & login are kept.',
    },
    'update_later': {AppLanguage.vi: 'Để sau', AppLanguage.en: 'Later'},
    'update_download': {AppLanguage.vi: 'Tải về', AppLanguage.en: 'Download'},
    'update_downloading': {
      AppLanguage.vi: 'Đang tải...',
      AppLanguage.en: 'Downloading...',
    },
    'update_download_failed': {
      AppLanguage.vi: 'Tải cập nhật thất bại:',
      AppLanguage.en: 'Update download failed:',
    },
    'update_install_failed': {
      AppLanguage.vi: 'Không mở được trình cài đặt: {msg}. Hãy cho phép "Cài đặt ứng dụng không rõ nguồn gốc" nếu được hỏi.',
      AppLanguage.en: 'Couldn\'t open the installer: {msg}. Allow "Install unknown apps" if prompted.',
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
