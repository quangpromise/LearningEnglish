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

    // Grammar TOPICS feature (grammar_topics_*.dart) - khac voi "Grammar
    // screen" o duoi (phan tich ngu phap theo 1 cau lyric cu the) - day la
    // 31 chu de ngu phap co ban duyet doc lap, vao tu man Vocabulary.
    'grammar_topics_title': {
      AppLanguage.vi: 'Ngữ pháp',
      AppLanguage.en: 'Grammar',
    },
    'grammar_search_hint': {
      AppLanguage.vi: 'Tìm chủ điểm ngữ pháp...',
      AppLanguage.en: 'Search grammar topics...',
    },
    'grammar_topics_subtitle': {
      AppLanguage.vi: '31 chủ điểm ngữ pháp cơ bản, kèm bài tập luyện tập',
      AppLanguage.en: '31 core grammar topics, with practice exercises',
    },
    'grammar_topics_quick_subtitle': {
      AppLanguage.vi: '31 chủ điểm cơ bản kèm bài tập',
      AppLanguage.en: '31 core topics with exercises',
    },
    'grammar_topics_examples_title': {
      AppLanguage.vi: 'VÍ DỤ',
      AppLanguage.en: 'EXAMPLES',
    },
    'grammar_topics_start_practice': {
      AppLanguage.vi: 'Bắt đầu luyện tập',
      AppLanguage.en: 'Start practice',
    },

    // Reading feature (reading_*_screen.dart) - sach public domain, xem
    // assets/books/ATTRIBUTION.md.
    'reading_title': {AppLanguage.vi: 'Đọc sách', AppLanguage.en: 'Reading'},
    'reading_subtitle': {
      AppLanguage.vi: 'Sách tiếng Anh miễn phí bản quyền, chạm từ để dịch',
      AppLanguage.en: 'Free public-domain books, tap any word to translate',
    },
    'reading_quick_subtitle': {
      AppLanguage.vi: '4 cuốn sách kinh điển, chạm từ để dịch',
      AppLanguage.en: '4 classic books, tap any word to translate',
    },
    'reading_tap_hint': {
      AppLanguage.vi: 'Chạm vào 1 từ bất kỳ để xem nghĩa',
      AppLanguage.en: 'Tap any word to see its meaning',
    },

    // Crypto feature (crypto_screen.dart) - bang xep hang gia coin, du lieu
    // lay tu API cong khai mien phi CoinGecko (khong can API key).
    'crypto_title': {AppLanguage.vi: 'Crypto', AppLanguage.en: 'Crypto'},
    'crypto_subtitle': {
      AppLanguage.vi: 'Top 100 coin theo vốn hoá',
      AppLanguage.en: 'Top 100 coins by market cap',
    },
    'crypto_quick_subtitle': {
      AppLanguage.vi: 'Giá top 100 coin, cập nhật trực tiếp',
      AppLanguage.en: 'Live prices for the top 100 coins',
    },
    'voice_chat_title': {
      AppLanguage.vi: 'AI Voice Chat',
      AppLanguage.en: 'AI Voice Chat',
    },
    'voice_chat_quick_subtitle': {
      AppLanguage.vi: 'Trò chuyện tự do bằng giọng nói với AI',
      AppLanguage.en: 'Free-form voice conversation with AI',
    },
    // Chi dich CHU TREN GIAO DIEN (tieu de, trang thai, thong bao loi...) -
    // ban than cuoc tro chuyen voi AI van luon bang tieng Anh du app dang o
    // ngon ngu nao, vi day la tinh nang luyen tieng Anh.
    'voice_chat_subtitle': {
      AppLanguage.vi: 'Trò chuyện tự do bằng tiếng Anh — AI sẽ chỉ ra lỗi sai',
      AppLanguage.en:
          'Chat freely in English — the AI will point out your mistakes',
    },
    'voice_chat_empty': {
      AppLanguage.vi:
          'Chưa có cuộc trò chuyện nào.\nBấm micro bên dưới để bắt đầu.',
      AppLanguage.en: 'No conversation yet.\nTap the mic below to start.',
    },
    'voice_chat_tap_to_start': {
      AppLanguage.vi: 'Bấm micro để bắt đầu trò chuyện',
      AppLanguage.en: 'Tap the mic to start chatting',
    },
    'voice_chat_connecting': {
      AppLanguage.vi: 'Đang kết nối...',
      AppLanguage.en: 'Connecting...',
    },
    'voice_chat_recording_stop': {
      AppLanguage.vi: 'Đang ghi âm — bấm micro lần nữa khi bạn nói xong',
      AppLanguage.en: 'Recording — tap the mic again when you\'re done talking',
    },
    'voice_chat_thinking': {
      AppLanguage.vi: 'Đang suy nghĩ...',
      AppLanguage.en: 'Thinking...',
    },
    'voice_chat_error_generic': {
      AppLanguage.vi: 'Đã xảy ra lỗi',
      AppLanguage.en: 'Something went wrong',
    },
    'voice_chat_sign_in_required': {
      AppLanguage.vi: 'Bạn cần đăng nhập để dùng AI Voice Chat',
      AppLanguage.en: 'You need to sign in to use AI Voice Chat',
    },
    'voice_chat_could_not_connect': {
      AppLanguage.vi: 'Không kết nối được: {msg}',
      AppLanguage.en: 'Could not connect: {msg}',
    },
    'voice_chat_correction_prefix': {
      AppLanguage.vi: 'Nói đúng là: ',
      AppLanguage.en: 'Correct way to say it: ',
    },
    'voice_chat_choose_voice': {
      AppLanguage.vi: 'Chọn giọng',
      AppLanguage.en: 'Choose a voice',
    },
    'voice_chat_voice_note': {
      AppLanguage.vi: 'Có hiệu lực từ lần bắt đầu trò chuyện tiếp theo',
      AppLanguage.en: 'Takes effect the next time you start a new chat session',
    },
    'crypto_error': {
      AppLanguage.vi: 'Không tải được dữ liệu, thử lại nhé',
      AppLanguage.en: 'Could not load data, please try again',
    },
    'crypto_retry': {AppLanguage.vi: 'Thử lại', AppLanguage.en: 'Retry'},
    'crypto_tab_market': {
      AppLanguage.vi: 'Thị trường',
      AppLanguage.en: 'Market',
    },
    'crypto_tab_portfolio': {
      AppLanguage.vi: 'Danh mục',
      AppLanguage.en: 'Portfolio',
    },
    'crypto_tab_watchlist': {
      AppLanguage.vi: 'Theo dõi',
      AppLanguage.en: 'Watchlist',
    },
    'crypto_watchlist_empty': {
      AppLanguage.vi: 'Chưa theo dõi coin nào.\nBấm dấu sao ở tab Thị trường để thêm vào đây.',
      AppLanguage.en:
          'No coins watched yet.\nTap the star on Market to add one here.',
    },
    'crypto_col_price': {AppLanguage.vi: 'Giá', AppLanguage.en: 'Price'},
    'crypto_col_change': {AppLanguage.vi: '24h %', AppLanguage.en: '24h %'},
    'crypto_col_market_cap': {
      AppLanguage.vi: 'Vốn hoá',
      AppLanguage.en: 'Market Cap',
    },
    'crypto_col_supply': {
      AppLanguage.vi: 'Lượng lưu hành',
      AppLanguage.en: 'Circulating Supply',
    },
    'crypto_add_coin': {
      AppLanguage.vi: 'Thêm coin vào danh mục',
      AppLanguage.en: 'Add a coin to your portfolio',
    },
    'crypto_search_hint': {
      AppLanguage.vi: 'Tìm theo tên hoặc ký hiệu...',
      AppLanguage.en: 'Search by name or symbol...',
    },
    'crypto_no_results': {
      AppLanguage.vi: 'Không tìm thấy coin nào',
      AppLanguage.en: 'No coins found',
    },
    'crypto_quantity_of': {
      AppLanguage.vi: 'Số lượng',
      AppLanguage.en: 'Quantity of',
    },
    'crypto_cancel': {AppLanguage.vi: 'Huỷ', AppLanguage.en: 'Cancel'},
    'crypto_confirm_add': {AppLanguage.vi: 'Thêm', AppLanguage.en: 'Add'},
    'crypto_currently_holding': {
      AppLanguage.vi: 'Đang giữ',
      AppLanguage.en: 'Currently holding',
    },
    'crypto_buy': {AppLanguage.vi: 'Mua', AppLanguage.en: 'Buy'},
    'crypto_sell': {AppLanguage.vi: 'Bán', AppLanguage.en: 'Sell'},
    'crypto_history_title': {
      AppLanguage.vi: 'Lịch sử giao dịch',
      AppLanguage.en: 'Transaction history',
    },
    'crypto_history_empty': {
      AppLanguage.vi: 'Chưa có giao dịch nào',
      AppLanguage.en: 'No transactions yet',
    },
    'crypto_total_value': {
      AppLanguage.vi: 'TỔNG GIÁ TRỊ DANH MỤC',
      AppLanguage.en: 'TOTAL PORTFOLIO VALUE',
    },
    'crypto_portfolio_empty': {
      AppLanguage.vi: 'Chưa có coin nào trong danh mục.\nBấm nút + để thêm.',
      AppLanguage.en: 'No coins in your portfolio yet.\nTap + to add one.',
    },

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
    'vocab_search_hint': {
      AppLanguage.vi: 'Tìm chủ đề từ vựng...',
      AppLanguage.en: 'Search vocabulary topics...',
    },
    'search_no_results': {
      AppLanguage.vi: 'Không tìm thấy kết quả nào',
      AppLanguage.en: 'No results found',
    },
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
    'vocab_add_to_daily': {
      AppLanguage.vi: 'Học hôm nay',
      AppLanguage.en: 'Learn today',
    },
    'vocab_added_to_daily': {
      AppLanguage.vi: 'Đã thêm {n} từ vào danh sách học hôm nay',
      AppLanguage.en: "Added {n} words to today's learning list",
    },
    'word_saved_to_daily': {
      AppLanguage.vi: 'Đã thêm vào danh sách học hôm nay',
      AppLanguage.en: "Added to today's learning list",
    },
    'daily_words_full': {
      AppLanguage.vi: 'Danh sách học hôm nay đã đủ 10 từ',
      AppLanguage.en: "Today's learning list is already full (10 words)",
    },
    'daily_quiz_title': {
      AppLanguage.vi: 'Quiz nhanh',
      AppLanguage.en: 'Quick quiz',
    },
    'daily_quiz_empty': {
      AppLanguage.vi: 'Chưa có từ nào trong danh sách học hôm nay.',
      AppLanguage.en: "There are no words in today's learning list.",
    },
    'daily_quiz_correct': {
      AppLanguage.vi: 'Chính xác! Đã ghi vào từ đã học.',
      AppLanguage.en: 'Correct! Recorded as learned.',
    },
    'daily_quiz_wrong': {
      AppLanguage.vi: 'Chưa đúng, sẽ hỏi lại ở lần nhắc sau.',
      AppLanguage.en: "Not quite — you'll be asked again next reminder.",
    },
    'daily_quiz_close': {AppLanguage.vi: 'Đóng', AppLanguage.en: 'Close'},

    // Profile - "Học 10 từ hôm nay" (chon o Vocabulary hoac khi luu tu tra
    // cuu, nhac hoc bang thong bao dinh ky)
    'profile_daily_words_title': {
      AppLanguage.vi: 'Học 10 từ hôm nay',
      AppLanguage.en: 'Learn 10 words today',
    },
    'profile_daily_words_empty': {
      AppLanguage.vi: 'Chưa có từ nào — vào Từ vựng theo chủ đề để chọn, hoặc bấm "Lưu" khi tra một từ.',
      AppLanguage.en: 'No words yet — pick some in Vocabulary by Topic, or tap "Save" when looking up a word.',
    },
    'profile_daily_words_progress': {
      AppLanguage.vi: '{learned}/{total} từ đã học hôm nay',
      AppLanguage.en: '{learned}/{total} words learned today',
    },
    'profile_daily_words_interval_label': {
      AppLanguage.vi: 'Nhắc quiz mỗi',
      AppLanguage.en: 'Quiz reminder every',
    },
    'profile_daily_words_minutes_suffix': {
      AppLanguage.vi: 'phút',
      AppLanguage.en: 'min',
    },
    'profile_daily_words_start': {
      AppLanguage.vi: 'Bắt đầu học',
      AppLanguage.en: 'Start learning',
    },
    'profile_daily_words_stop': {
      AppLanguage.vi: 'Kết thúc học',
      AppLanguage.en: 'End learning',
    },
    'profile_daily_words_active_hint': {
      AppLanguage.vi:
          'Đang bật nhắc quiz — thông báo sẽ hiện kể cả khi tắt app',
      AppLanguage.en: 'Reminders are on — notifications will show even if the app is closed',
    },

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
    'profile_friends_title': {
      AppLanguage.vi: 'Bạn bè',
      AppLanguage.en: 'Friends',
    },
    'profile_friends_subtitle': {
      AppLanguage.vi: 'Kết bạn, nhắn tin, xem ai đang online',
      AppLanguage.en: 'Add friends, chat, see who is online',
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
    'profile_tab_activity': {
      AppLanguage.vi: 'Hoạt động',
      AppLanguage.en: 'Activity',
    },
    'profile_tab_settings': {
      AppLanguage.vi: 'Cài đặt',
      AppLanguage.en: 'Settings',
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
    'common_confirm': {AppLanguage.vi: 'Xác nhận', AppLanguage.en: 'Confirm'},
    'common_delete': {AppLanguage.vi: 'Xóa', AppLanguage.en: 'Delete'},
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
    // Friends & chat (friends_screen.dart, chat_screen.dart)
    'home_messages_tooltip': {
      AppLanguage.vi: 'Tin nhắn',
      AppLanguage.en: 'Messages',
    },
    'friends_title': {AppLanguage.vi: 'Bạn bè', AppLanguage.en: 'Friends'},
    'friends_search_hint': {
      AppLanguage.vi: 'Tìm bạn theo tên...',
      AppLanguage.en: 'Search people by name...',
    },
    'friends_pending_requests': {
      AppLanguage.vi: 'LỜI MỜI KẾT BẠN',
      AppLanguage.en: 'FRIEND REQUESTS',
    },
    'friends_list_title': {AppLanguage.vi: 'BẠN BÈ', AppLanguage.en: 'FRIENDS'},
    'friends_load_error': {
      AppLanguage.vi: 'Không tải được danh sách bạn bè.',
      AppLanguage.en: "Couldn't load your friends list.",
    },
    'friends_empty': {
      AppLanguage.vi:
          'Chưa có bạn bè nào. Tìm và kết bạn ở ô tìm kiếm phía trên.',
      AppLanguage.en: 'No friends yet. Search above to add some.',
    },
    'friends_no_results': {
      AppLanguage.vi: 'Không tìm thấy ai phù hợp',
      AppLanguage.en: 'No matching users found',
    },
    'friends_status_friends': {
      AppLanguage.vi: 'Bạn bè',
      AppLanguage.en: 'Friends',
    },
    'friends_status_pending': {
      AppLanguage.vi: 'Đã gửi lời mời',
      AppLanguage.en: 'Request sent',
    },
    'friends_add_button': {AppLanguage.vi: 'Kết bạn', AppLanguage.en: 'Add'},
    'friends_set_nickname_title': {
      AppLanguage.vi: 'Đặt biệt danh',
      AppLanguage.en: 'Set nickname',
    },
    'friends_save_nickname': {AppLanguage.vi: 'Lưu', AppLanguage.en: 'Save'},
    'friends_unfriend_title': {
      AppLanguage.vi: 'Hủy kết bạn',
      AppLanguage.en: 'Unfriend',
    },
    'friends_unfriend_body': {
      AppLanguage.vi: 'Bạn có thể gửi lại lời mời kết bạn sau nếu muốn.',
      AppLanguage.en: 'You can send a friend request again later if you want.',
    },
    'friends_unfriend_confirm': {
      AppLanguage.vi: 'Hủy kết bạn',
      AppLanguage.en: 'Unfriend',
    },
    'friends_online': {AppLanguage.vi: 'Đang online', AppLanguage.en: 'Online'},
    'friends_offline': {
      AppLanguage.vi: 'Không hoạt động',
      AppLanguage.en: 'Offline',
    },
    'chat_load_error': {
      AppLanguage.vi: 'Không tải được tin nhắn.',
      AppLanguage.en: "Couldn't load messages.",
    },
    'chat_say_hi': {
      AppLanguage.vi: 'Chưa có tin nhắn nào. Gửi lời chào đầu tiên nhé!',
      AppLanguage.en: 'No messages yet. Say hi!',
    },
    'chat_input_hint': {
      AppLanguage.vi: 'Nhắn gì đó...',
      AppLanguage.en: 'Type a message...',
    },
    'chat_send_failed': {
      AppLanguage.vi: 'Gửi tin nhắn thất bại, thử lại nhé.',
      AppLanguage.en: 'Failed to send, please try again.',
    },
    'chat_seen': {AppLanguage.vi: 'Đã xem', AppLanguage.en: 'Seen'},
    'chat_pick_image': {
      AppLanguage.vi: 'Gửi ảnh',
      AppLanguage.en: 'Send photo',
    },
    'chat_pick_file': {AppLanguage.vi: 'Gửi tệp', AppLanguage.en: 'Send file'},
    'chat_upload_error': {
      AppLanguage.vi: 'Gửi thất bại, thử lại nhé.',
      AppLanguage.en: 'Upload failed, please try again.',
    },
    'chat_media_expired': {
      AppLanguage.vi: 'Tệp đã hết hạn (tự xóa sau 1 ngày)',
      AppLanguage.en: 'Expired (auto-deleted after 1 day)',
    },
    'call_permission_denied': {
      AppLanguage.vi: 'Cần cấp quyền micro/camera để gọi.',
      AppLanguage.en: 'Microphone/camera permission is required to call.',
    },
    'call_connect_error': {
      AppLanguage.vi: 'Không kết nối được cuộc gọi.',
      AppLanguage.en: 'Could not connect the call.',
    },
    'call_connecting': {
      AppLanguage.vi: 'Đang kết nối...',
      AppLanguage.en: 'Connecting...',
    },
    'call_ringing': {
      AppLanguage.vi: 'Đang đổ chuông...',
      AppLanguage.en: 'Ringing...',
    },
    'call_in_progress': {
      AppLanguage.vi: 'Đang trong cuộc gọi',
      AppLanguage.en: 'In call',
    },
    'call_incoming_video': {
      AppLanguage.vi: 'Cuộc gọi video đến',
      AppLanguage.en: 'Incoming video call',
    },
    'call_incoming_voice': {
      AppLanguage.vi: 'Cuộc gọi thoại đến',
      AppLanguage.en: 'Incoming voice call',
    },
    'call_decline': {AppLanguage.vi: 'Từ chối', AppLanguage.en: 'Decline'},
    'call_accept': {AppLanguage.vi: 'Chấp nhận', AppLanguage.en: 'Accept'},
    'chat_sticker_title': {
      AppLanguage.vi: 'Sticker',
      AppLanguage.en: 'Stickers',
    },
    'chat_sticker_search_hint': {
      AppLanguage.vi: 'Tìm sticker...',
      AppLanguage.en: 'Search stickers...',
    },
    'chat_sticker_load_error': {
      AppLanguage.vi: 'Không tải được sticker, thử lại nhé.',
      AppLanguage.en: "Couldn't load stickers, please try again.",
    },
    'chat_react': {AppLanguage.vi: 'Thả cảm xúc', AppLanguage.en: 'React'},
    'chat_edit': {AppLanguage.vi: 'Chỉnh sửa', AppLanguage.en: 'Edit'},
    'chat_delete': {AppLanguage.vi: 'Xóa', AppLanguage.en: 'Delete'},
    'chat_delete_title': {
      AppLanguage.vi: 'Xóa tin nhắn?',
      AppLanguage.en: 'Delete message?',
    },
    'chat_delete_body': {
      AppLanguage.vi: 'Người còn lại sẽ thấy tin nhắn này đã bị xóa.',
      AppLanguage.en: 'The other person will see this message as deleted.',
    },
    'chat_delete_confirm': {AppLanguage.vi: 'Xóa', AppLanguage.en: 'Delete'},
    'chat_message_deleted': {
      AppLanguage.vi: 'Tin nhắn đã bị xóa',
      AppLanguage.en: 'This message was deleted',
    },
    'chat_edited': {AppLanguage.vi: 'đã chỉnh sửa', AppLanguage.en: 'edited'},
    'chat_editing_hint': {
      AppLanguage.vi: 'Đang chỉnh sửa tin nhắn',
      AppLanguage.en: 'Editing message',
    },
    'chat_theme_title': {
      AppLanguage.vi: 'Đổi màu nền đoạn chat',
      AppLanguage.en: 'Chat theme',
    },
    'chat_open_file_error': {
      AppLanguage.vi: 'Không mở được tệp này.',
      AppLanguage.en: "Couldn't open this file.",
    },
    'conversations_no_message': {
      AppLanguage.vi: 'Chưa có tin nhắn nào',
      AppLanguage.en: 'No messages yet',
    },
    'conversations_you_prefix': {
      AppLanguage.vi: 'Bạn: ',
      AppLanguage.en: 'You: ',
    },

    'profile_avatar_error': {
      AppLanguage.vi: 'Không tải được avatar:',
      AppLanguage.en: "Couldn't upload avatar:",
    },
    'profile_quick_open_full': {
      AppLanguage.vi: 'Xem tất cả cài đặt',
      AppLanguage.en: 'View all settings',
    },

    // App switcher (core/navigation/app_switcher_sheet.dart) - mo tu the
    // duoi loi chao tren Home, chuyen doi giua cac "app" trong cung 1 APK.
    'app_switcher_title': {
      AppLanguage.vi: 'Chuyển đổi ứng dụng',
      AppLanguage.en: 'Switch app',
    },
    'app_switcher_learn_english': {
      AppLanguage.vi: 'Học Tiếng Anh',
      AppLanguage.en: 'Learn English',
    },
    'app_switcher_fitness': {
      AppLanguage.vi: 'Fitness',
      AppLanguage.en: 'Fitness',
    },
    'app_switcher_wealth': {
      AppLanguage.vi: 'Assets Management',
      AppLanguage.en: 'Assets Management',
    },
    'app_switcher_current_badge': {
      AppLanguage.vi: 'Đang dùng',
      AppLanguage.en: 'Current',
    },
    'app_switcher_coming_soon': {
      AppLanguage.vi: 'Sắp ra mắt',
      AppLanguage.en: 'Coming soon',
    },
    'app_switcher_coming_soon_toast': {
      AppLanguage.vi: 'Tính năng đang được phát triển, sẽ bổ sung sau.',
      AppLanguage.en: 'This feature is still in development.',
    },

    // Wealth Management (features/wealth/) - Phase 1: Chi tieu/Thu nhap +
    // Dau tu (crypto + co phieu quoc te).
    'wealth_title': {
      AppLanguage.vi: 'Assets Management',
      AppLanguage.en: 'Assets Management',
    },
    'wealth_home_category_manage': {
      AppLanguage.vi: 'Quản lý tài chính',
      AppLanguage.en: 'Manage finances',
    },
    'wealth_tab_expense': {
      AppLanguage.vi: 'Chi tiêu',
      AppLanguage.en: 'Expense',
    },
    'wealth_tab_income': {AppLanguage.vi: 'Thu nhập', AppLanguage.en: 'Income'},
    'wealth_tab_investments': {
      AppLanguage.vi: 'Đầu tư',
      AppLanguage.en: 'Investments',
    },
    'wealth_add_transaction': {
      AppLanguage.vi: 'Thêm giao dịch',
      AppLanguage.en: 'Add transaction',
    },
    'wealth_amount_hint': {
      AppLanguage.vi: 'Số tiền (VNĐ)',
      AppLanguage.en: 'Amount (VND)',
    },
    'wealth_note_hint': {
      AppLanguage.vi: 'Ghi chú (không bắt buộc)',
      AppLanguage.en: 'Note (optional)',
    },
    'wealth_save': {AppLanguage.vi: 'Lưu', AppLanguage.en: 'Save'},
    'wealth_empty_expense': {
      AppLanguage.vi: 'Chưa có giao dịch chi tiêu nào.',
      AppLanguage.en: 'No expense transactions yet.',
    },
    'wealth_empty_income': {
      AppLanguage.vi: 'Chưa có giao dịch thu nhập nào.',
      AppLanguage.en: 'No income transactions yet.',
    },
    'wealth_filter_all': {AppLanguage.vi: 'Tất cả', AppLanguage.en: 'All'},
    'wealth_filter_active': {
      AppLanguage.vi: 'Chủ động',
      AppLanguage.en: 'Active',
    },
    'wealth_filter_passive': {
      AppLanguage.vi: 'Thụ động',
      AppLanguage.en: 'Passive',
    },
    'wealth_total_expense': {
      AppLanguage.vi: 'Tổng chi',
      AppLanguage.en: 'Total expense',
    },
    'wealth_total_income': {
      AppLanguage.vi: 'Tổng thu',
      AppLanguage.en: 'Total income',
    },
    'wealth_investments_crypto_title': {
      AppLanguage.vi: 'Crypto',
      AppLanguage.en: 'Crypto',
    },
    'wealth_investments_crypto_subtitle': {
      AppLanguage.vi: 'Theo dõi giá & danh mục crypto',
      AppLanguage.en: 'Track crypto prices & portfolio',
    },
    'wealth_investments_stocks_title': {
      AppLanguage.vi: 'Cổ phiếu quốc tế',
      AppLanguage.en: 'International stocks',
    },
    'wealth_investments_total': {
      AppLanguage.vi: 'Tổng tài sản đầu tư',
      AppLanguage.en: 'Total investment assets',
    },
    'wealth_investments_metal_title': {
      AppLanguage.vi: 'Vàng / Bạc / Đồng',
      AppLanguage.en: 'Gold / Silver / Copper',
    },
    'wealth_metal_world_price_note': {
      AppLanguage.vi: 'Giá thế giới quy đổi, không phải giá bán lẻ trong nước.',
      AppLanguage.en: 'World price converted — not a domestic retail price.',
    },
    'wealth_metal_current_price': {
      AppLanguage.vi: 'Giá hiện tại',
      AppLanguage.en: 'Current price',
    },
    'wealth_metal_cost_price': {
      AppLanguage.vi: 'Giá vốn',
      AppLanguage.en: 'Cost price',
    },
    'wealth_investments_real_estate_title': {
      AppLanguage.vi: 'Nhà đất',
      AppLanguage.en: 'Real estate',
    },
    'wealth_real_estate_manual_note': {
      AppLanguage.vi: 'Không có giá thị trường tự động theo từng căn — bạn tự nhập giá trị ước tính.',
      AppLanguage.en: 'No automatic per-property market price — enter your own estimated value.',
    },
    'wealth_real_estate_add': {
      AppLanguage.vi: 'Thêm bất động sản',
      AppLanguage.en: 'Add property',
    },
    'wealth_real_estate_name_hint': {
      AppLanguage.vi: 'Tên bất động sản',
      AppLanguage.en: 'Property name',
    },
    'wealth_real_estate_value_hint': {
      AppLanguage.vi: 'Giá trị ước tính (VND)',
      AppLanguage.en: 'Estimated value (VND)',
    },
    'wealth_add_holding': {
      AppLanguage.vi: 'Thêm mã cổ phiếu',
      AppLanguage.en: 'Add stock holding',
    },
    'wealth_symbol_hint': {
      AppLanguage.vi: 'Mã cổ phiếu (vd AAPL)',
      AppLanguage.en: 'Symbol (e.g. AAPL)',
    },
    'wealth_quantity_hint': {
      AppLanguage.vi: 'Số lượng',
      AppLanguage.en: 'Quantity',
    },
    'wealth_avg_cost_hint': {
      AppLanguage.vi: 'Giá vốn / cổ phiếu (USD)',
      AppLanguage.en: 'Average cost / share (USD)',
    },
    'wealth_empty_holdings': {
      AppLanguage.vi: 'Chưa có mã cổ phiếu nào trong danh mục.',
      AppLanguage.en: 'No stock holdings yet.',
    },
    'wealth_quote_error': {
      AppLanguage.vi: 'Không tải được giá hiện tại',
      AppLanguage.en: 'Could not load current price',
    },
    'wealth_delete_confirm_title': {
      AppLanguage.vi: 'Xoá mục này?',
      AppLanguage.en: 'Delete this item?',
    },
    'wealth_market_title': {AppLanguage.vi: 'Market', AppLanguage.en: 'Market'},
    'wealth_expense_category_food': {
      AppLanguage.vi: 'Ăn uống',
      AppLanguage.en: 'Food',
    },
    'wealth_expense_category_transport': {
      AppLanguage.vi: 'Di chuyển',
      AppLanguage.en: 'Transport',
    },
    'wealth_expense_category_housing': {
      AppLanguage.vi: 'Nhà ở',
      AppLanguage.en: 'Housing',
    },
    'wealth_expense_category_entertainment': {
      AppLanguage.vi: 'Giải trí',
      AppLanguage.en: 'Entertainment',
    },
    'wealth_expense_category_health': {
      AppLanguage.vi: 'Sức khoẻ',
      AppLanguage.en: 'Health',
    },
    'wealth_expense_category_shopping': {
      AppLanguage.vi: 'Mua sắm',
      AppLanguage.en: 'Shopping',
    },
    'wealth_expense_category_bills': {
      AppLanguage.vi: 'Hoá đơn',
      AppLanguage.en: 'Bills',
    },
    'wealth_expense_category_other': {
      AppLanguage.vi: 'Khác',
      AppLanguage.en: 'Other',
    },
    'wealth_income_category_salary': {
      AppLanguage.vi: 'Lương',
      AppLanguage.en: 'Salary',
    },
    'wealth_income_category_bonus': {
      AppLanguage.vi: 'Thưởng',
      AppLanguage.en: 'Bonus',
    },
    'wealth_income_category_freelance': {
      AppLanguage.vi: 'Freelance / Làm thêm',
      AppLanguage.en: 'Freelance',
    },
    'wealth_income_category_business': {
      AppLanguage.vi: 'Kinh doanh',
      AppLanguage.en: 'Business',
    },
    'wealth_income_category_rental': {
      AppLanguage.vi: 'Cho thuê nhà',
      AppLanguage.en: 'Rental income',
    },
    'wealth_income_category_dividend': {
      AppLanguage.vi: 'Cổ tức',
      AppLanguage.en: 'Dividend',
    },
    'wealth_income_category_savings_interest': {
      AppLanguage.vi: 'Lãi tiết kiệm',
      AppLanguage.en: 'Savings interest',
    },
    'wealth_income_category_investment_gain': {
      AppLanguage.vi: 'Đầu tư sinh lời',
      AppLanguage.en: 'Investment gain',
    },
    'wealth_metal_gold_sjc': {
      AppLanguage.vi: 'Vàng SJC',
      AppLanguage.en: 'SJC Gold',
    },
    'wealth_metal_gold_pnj': {
      AppLanguage.vi: 'Vàng PNJ',
      AppLanguage.en: 'PNJ Gold',
    },
    'wealth_metal_silver_world': {
      AppLanguage.vi: 'Bạc (thế giới quy đổi)',
      AppLanguage.en: 'Silver (world price)',
    },
    'wealth_metal_copper_world': {
      AppLanguage.vi: 'Đồng (thế giới quy đổi)',
      AppLanguage.en: 'Copper (world price)',
    },
    'wealth_metal_buy_price': {AppLanguage.vi: 'Mua', AppLanguage.en: 'Buy'},
    'wealth_metal_unit_luong': {
      AppLanguage.vi: 'lượng',
      AppLanguage.en: 'tael',
    },
    'wealth_metal_unit_kg': {AppLanguage.vi: 'kg', AppLanguage.en: 'kg'},
    'wealth_metal_name_gold': {AppLanguage.vi: 'Vàng', AppLanguage.en: 'Gold'},
    'wealth_metal_name_silver': {
      AppLanguage.vi: 'Bạc',
      AppLanguage.en: 'Silver',
    },
    'wealth_metal_name_copper': {
      AppLanguage.vi: 'Đồng',
      AppLanguage.en: 'Copper',
    },
    'wealth_stock_unit_share': {AppLanguage.vi: 'cp', AppLanguage.en: 'sh'},
    'wealth_stock_avg_cost_label': {
      AppLanguage.vi: 'giá vốn',
      AppLanguage.en: 'avg cost',
    },
    'wealth_add_payment_method': {
      AppLanguage.vi: 'Thêm hình thức',
      AppLanguage.en: 'Add payment method',
    },
    'wealth_split_remaining': {
      AppLanguage.vi: 'Còn thiếu',
      AppLanguage.en: 'Remaining',
    },
    'wealth_market_stocks_note': {
      AppLanguage.vi: 'Danh sách mã tiêu biểu (không phải toàn bộ sàn) — thêm mã khác trong Ví.',
      AppLanguage.en: 'A curated watchlist, not the full market — add other symbols in Wallet.',
    },
    'wealth_market_metals_note': {
      AppLanguage.vi: 'Giá tham khảo, cập nhật mỗi vài phút. Bạc/Đồng là giá thế giới quy đổi.',
      AppLanguage.en: 'Reference prices, updated every few minutes. Silver/Copper are world prices converted.',
    },
    'wealth_market_real_estate_note': {
      AppLanguage.vi: 'Không có nguồn giá thị trường real-time cho bất động sản theo từng khu vực — đây là danh sách bạn tự nhập trong Ví.',
      AppLanguage.en: 'No real-time regional real-estate price source — this is your own list from Wallet.',
    },
    'wealth_market_usd_vnd': {
      AppLanguage.vi: 'Tỷ giá USD/VND',
      AppLanguage.en: 'USD/VND rate',
    },
    'wealth_service_title': {
      AppLanguage.vi: 'Dịch vụ định kỳ',
      AppLanguage.en: 'Recurring services',
    },
    'wealth_service_edit': {
      AppLanguage.vi: 'Sửa dịch vụ',
      AppLanguage.en: 'Edit service',
    },
    'wealth_service_add': {
      AppLanguage.vi: 'Thêm dịch vụ',
      AppLanguage.en: 'Add service',
    },
    'wealth_service_empty': {
      AppLanguage.vi: 'Chưa có dịch vụ định kỳ nào.',
      AppLanguage.en: 'No recurring services yet.',
    },
    'wealth_service_days_left': {
      AppLanguage.vi: 'Còn lại',
      AppLanguage.en: 'Days left',
    },
    'wealth_service_overdue': {
      AppLanguage.vi: 'Đã quá hạn',
      AppLanguage.en: 'Overdue',
    },
    'wealth_service_renew': {
      AppLanguage.vi: 'Gia hạn',
      AppLanguage.en: 'Renew',
    },
    'wealth_service_name_hint': {
      AppLanguage.vi: 'Tên dịch vụ (VD: Netflix)',
      AppLanguage.en: 'Service name (e.g. Netflix)',
    },
    'wealth_service_start_date': {
      AppLanguage.vi: 'Ngày bắt đầu',
      AppLanguage.en: 'Start date',
    },
    'wealth_service_cycle': {
      AppLanguage.vi: 'Chu kỳ',
      AppLanguage.en: 'Billing cycle',
    },
    'wealth_service_cycle_week': {
      AppLanguage.vi: 'Hàng tuần',
      AppLanguage.en: 'Weekly',
    },
    'wealth_service_cycle_month': {
      AppLanguage.vi: 'Hàng tháng',
      AppLanguage.en: 'Monthly',
    },
    'wealth_service_cycle_year': {
      AppLanguage.vi: 'Hàng năm',
      AppLanguage.en: 'Yearly',
    },
    'wealth_service_cycle_custom_years': {
      AppLanguage.vi: 'Số năm tuỳ chọn',
      AppLanguage.en: 'Custom (years)',
    },
    'wealth_service_cycle_manual': {
      AppLanguage.vi: 'Ngày cụ thể',
      AppLanguage.en: 'Specific date',
    },
    'wealth_service_years_hint': {
      AppLanguage.vi: 'Số năm',
      AppLanguage.en: 'Number of years',
    },
    'wealth_service_pick_expiry': {
      AppLanguage.vi: 'Chọn ngày hết hạn',
      AppLanguage.en: 'Pick expiry date',
    },
    'wealth_service_expiry_preview': {
      AppLanguage.vi: 'Ngày hết hạn',
      AppLanguage.en: 'Expiry date',
    },
    'wealth_service_reminder_lead': {
      AppLanguage.vi: 'Nhắc trước',
      AppLanguage.en: 'Remind before',
    },
    'wealth_service_lead_1_week': {
      AppLanguage.vi: '1 tuần',
      AppLanguage.en: '1 week',
    },
    'wealth_service_lead_half_month': {
      AppLanguage.vi: 'Nửa tháng',
      AppLanguage.en: 'Half a month',
    },
    'wealth_service_lead_1_month': {
      AppLanguage.vi: '1 tháng',
      AppLanguage.en: '1 month',
    },
    'wealth_calculator_title': {
      AppLanguage.vi: 'Máy tính',
      AppLanguage.en: 'Calculator',
    },
    'wealth_debt_title': {AppLanguage.vi: 'Nợ', AppLanguage.en: 'Debt'},
    'wealth_debt_tab_i_owe': {
      AppLanguage.vi: 'Đang nợ',
      AppLanguage.en: 'I owe',
    },
    'wealth_debt_tab_owed_to_me': {
      AppLanguage.vi: 'Người khác nợ mình',
      AppLanguage.en: 'Owed to me',
    },
    'wealth_debt_empty': {
      AppLanguage.vi: 'Chưa có khoản nợ nào.',
      AppLanguage.en: 'No debts yet.',
    },
    'wealth_debt_add': {
      AppLanguage.vi: 'Thêm khoản nợ',
      AppLanguage.en: 'Add debt',
    },
    'wealth_debt_add_i_owe': {
      AppLanguage.vi: 'Thêm khoản đang nợ',
      AppLanguage.en: 'Add a debt you owe',
    },
    'wealth_debt_add_owed_to_me': {
      AppLanguage.vi: 'Thêm khoản người khác nợ',
      AppLanguage.en: 'Add a debt owed to you',
    },
    'wealth_debt_pay': {AppLanguage.vi: 'Trả nợ', AppLanguage.en: 'Pay debt'},
    'wealth_debt_collect': {
      AppLanguage.vi: 'Thu nợ',
      AppLanguage.en: 'Collect debt',
    },
    'wealth_debt_settled': {
      AppLanguage.vi: 'Đã trả xong',
      AppLanguage.en: 'Settled',
    },
    'wealth_debt_person_hint': {
      AppLanguage.vi: 'Tên chủ nợ / người nợ',
      AppLanguage.en: 'Creditor / debtor name',
    },
    'wealth_debt_entries_suffix': {
      AppLanguage.vi: 'khoản',
      AppLanguage.en: 'entries',
    },
    'wealth_debt_split_mode': {
      AppLanguage.vi: 'Chia cho nhiều người',
      AppLanguage.en: 'Split among multiple people',
    },
    'wealth_debt_split_total_hint': {
      AppLanguage.vi: 'Tổng số tiền',
      AppLanguage.en: 'Total amount',
    },
    'wealth_debt_split_add_person': {
      AppLanguage.vi: 'Thêm người',
      AppLanguage.en: 'Add person',
    },
    'wealth_debt_split_equal': {
      AppLanguage.vi: 'Chia đều',
      AppLanguage.en: 'Split evenly',
    },
    'wealth_debt_view_history': {
      AppLanguage.vi: 'Xem lịch sử',
      AppLanguage.en: 'View history',
    },
    'wealth_pay_by': {
      AppLanguage.vi: 'Thanh toán bằng',
      AppLanguage.en: 'Pay by',
    },
    'wealth_pay_by_bank': {
      AppLanguage.vi: 'Chọn ngân hàng',
      AppLanguage.en: 'Choose bank',
    },

    // Vi (Wallet) - xem Phase A-C ke hoach build lai Wealth
    'wallet_title': {AppLanguage.vi: 'Ví', AppLanguage.en: 'Wallet'},
    'wallet_tab_existing': {
      AppLanguage.vi: 'Tài sản hiện có',
      AppLanguage.en: 'Current assets',
    },
    'wallet_tab_investments': {
      AppLanguage.vi: 'Đầu tư',
      AppLanguage.en: 'Investment',
    },
    'wallet_section_cash': {AppLanguage.vi: 'Tiền mặt', AppLanguage.en: 'Cash'},
    'wallet_section_bank': {
      AppLanguage.vi: 'Tiền ngân hàng',
      AppLanguage.en: 'Bank money',
    },
    'wallet_add_entry': {
      AppLanguage.vi: 'Thêm giao dịch',
      AppLanguage.en: 'Add entry',
    },
    'wallet_empty_cash': {
      AppLanguage.vi: 'Chưa có giao dịch tiền mặt nào.',
      AppLanguage.en: 'No cash entries yet.',
    },
    'wallet_empty_bank': {
      AppLanguage.vi: 'Chưa có ngân hàng nào được thêm.',
      AppLanguage.en: 'No bank accounts added yet.',
    },
    'wallet_pick_bank_title': {
      AppLanguage.vi: 'Chọn ngân hàng',
      AppLanguage.en: 'Choose a bank',
    },
    'wallet_pick_bank_search_hint': {
      AppLanguage.vi: 'Tìm ngân hàng...',
      AppLanguage.en: 'Search bank...',
    },
    'wallet_pick_bank_other_title': {
      AppLanguage.vi: 'Nhập tên ngân hàng',
      AppLanguage.en: 'Enter bank name',
    },
    'wallet_pick_bank_other_hint': {
      AppLanguage.vi: 'VD: Ngân hàng ABC',
      AppLanguage.en: 'e.g. ABC Bank',
    },
    'wealth_load_error': {
      AppLanguage.vi: 'Không tải được dữ liệu',
      AppLanguage.en: 'Could not load data',
    },
    'wealth_edit_holding': {
      AppLanguage.vi: 'Sửa mã cổ phiếu',
      AppLanguage.en: 'Edit stock holding',
    },
    'wealth_edit_transaction': {
      AppLanguage.vi: 'Sửa giao dịch',
      AppLanguage.en: 'Edit transaction',
    },
    'wallet_load_error': {
      AppLanguage.vi: 'Không tải được danh sách ngân hàng',
      AppLanguage.en: 'Could not load bank list',
    },
    'wallet_amount_direction_add': {
      AppLanguage.vi: 'Nạp thêm',
      AppLanguage.en: 'Deposit',
    },
    'wallet_amount_direction_subtract': {
      AppLanguage.vi: 'Rút bớt',
      AppLanguage.en: 'Withdraw',
    },
    'wallet_amount_hint': {AppLanguage.vi: 'Số tiền', AppLanguage.en: 'Amount'},
    'wallet_note_hint': {
      AppLanguage.vi: 'Ghi chú (không bắt buộc)',
      AppLanguage.en: 'Note (optional)',
    },
    'wallet_save': {AppLanguage.vi: 'Lưu', AppLanguage.en: 'Save'},
    'wallet_total_assets': {
      AppLanguage.vi: 'Tổng tài sản',
      AppLanguage.en: 'Total assets',
    },
    'wallet_view_all_history': {
      AppLanguage.vi: 'Xem tất cả lịch sử',
      AppLanguage.en: 'View all history',
    },
    'wallet_hidden_amount': {AppLanguage.vi: 'Đã ẩn', AppLanguage.en: 'Hidden'},

    // Home screen
    'home_greeting': {AppLanguage.vi: 'Xin chào', AppLanguage.en: 'Hello'},
    'home_dictionary_tooltip': {
      AppLanguage.vi: 'Từ điển',
      AppLanguage.en: 'Dictionary',
    },
    'home_stat_streak': {
      AppLanguage.vi: 'Ngày liên tục',
      AppLanguage.en: 'Day streak',
    },
    'home_stat_words': {
      AppLanguage.vi: 'Từ đã học',
      AppLanguage.en: 'Words learned',
    },
    'home_stat_pronunciation': {
      AppLanguage.vi: 'Điểm phát âm',
      AppLanguage.en: 'Pronunciation',
    },
    'home_level_section_title': {
      AppLanguage.vi: 'Chọn trình độ',
      AppLanguage.en: 'Choose your level',
    },
    'home_category_listening': {
      AppLanguage.vi: 'Nghe nói',
      AppLanguage.en: 'Listening & Speaking',
    },
    'home_category_reading': {
      AppLanguage.vi: 'Đọc viết',
      AppLanguage.en: 'Reading & Writing',
    },
    'home_category_other': {AppLanguage.vi: 'Khác', AppLanguage.en: 'Other'},
    'dictionary_title': {
      AppLanguage.vi: 'Từ điển Anh - Việt',
      AppLanguage.en: 'English - Vietnamese Dictionary',
    },
    'dictionary_en_to_vi': {
      AppLanguage.vi: 'Anh → Việt',
      AppLanguage.en: 'English → Vietnamese',
    },
    'dictionary_vi_to_en': {
      AppLanguage.vi: 'Việt → Anh',
      AppLanguage.en: 'Vietnamese → English',
    },
    'dictionary_hint_en': {
      AppLanguage.vi: 'Nhập từ hoặc câu tiếng Anh...',
      AppLanguage.en: 'Type an English word or sentence...',
    },
    'dictionary_hint_vi': {
      AppLanguage.vi: 'Nhập từ hoặc câu tiếng Việt...',
      AppLanguage.en: 'Type a Vietnamese word or sentence...',
    },
    'dictionary_error': {
      AppLanguage.vi: 'Không tra được, thử lại nhé',
      AppLanguage.en: 'Could not look this up, please try again',
    },
    'home_search_hint': {
      AppLanguage.vi: 'Tìm bài hát, ca sĩ...',
      AppLanguage.en: 'Search songs, artists...',
    },
    'home_suggested_for_you': {
      AppLanguage.vi: 'Gợi ý cho bạn',
      AppLanguage.en: 'Suggested for you',
    },
    'home_vocabulary_quick_title': {
      AppLanguage.vi: 'Từ vựng theo chủ đề',
      AppLanguage.en: 'Vocabulary by Topic',
    },
    'home_vocabulary_quick_subtitle': {
      AppLanguage.vi: 'Học từ mới qua 46 chủ đề quen thuộc',
      AppLanguage.en: 'Learn new words across 46 familiar topics',
    },
    'home_song_count': {AppLanguage.vi: 'bài hát', AppLanguage.en: 'songs'},
    'home_music_quick_title': {
      AppLanguage.vi: 'Nghe nhạc',
      AppLanguage.en: 'Listen to Music',
    },
    'home_music_quick_subtitle': {
      AppLanguage.vi: 'Nghe nhạc học tiếng Anh, tìm bài hát yêu thích',
      AppLanguage.en: 'Listen and learn English through songs',
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
    'player_tab_now_playing': {
      AppLanguage.vi: 'Đang phát',
      AppLanguage.en: 'Now playing',
    },
    'player_tab_suggested': {
      AppLanguage.vi: 'Gợi ý cho bạn',
      AppLanguage.en: 'Suggested for you',
    },
    'player_suggested_empty': {
      AppLanguage.vi: 'Chưa có gợi ý nào khác.',
      AppLanguage.en: 'No other suggestions yet.',
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
    'word_in_text': {
      AppLanguage.vi: 'TRONG ĐOẠN VĂN',
      AppLanguage.en: 'IN THE TEXT',
    },
    'word_in_chat': {
      AppLanguage.vi: 'TRONG ĐOẠN CHAT',
      AppLanguage.en: 'IN THE CHAT',
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

    // Onboarding carousel (onboarding_screen.dart) - hien 1 lan duy nhat
    // cho moi tai khoan, ngay sau khi dang nhap/dang ky thanh cong lan dau,
    // truoc khi vao RootShell.
    'onboarding_skip': {AppLanguage.vi: 'Bỏ qua', AppLanguage.en: 'Skip'},
    'onboarding_next': {AppLanguage.vi: 'Tiếp theo', AppLanguage.en: 'Next'},
    'onboarding_start': {
      AppLanguage.vi: 'Bắt đầu học ngay',
      AppLanguage.en: 'Start learning',
    },
    'onboarding_page1_title': {
      AppLanguage.vi: 'Học tiếng Anh qua âm nhạc',
      AppLanguage.en: 'Learn English through music',
    },
    'onboarding_page1_body': {
      AppLanguage.vi: 'Nghe nhạc, xem lời bài hát song ngữ Anh-Việt theo thời gian thực, chạm vào bất kỳ từ nào để xem nghĩa và nghe phát âm mẫu.',
      AppLanguage.en: 'Listen to songs, follow bilingual lyrics in real time, and tap any word to see its meaning and hear it pronounced.',
    },
    'onboarding_page2_title': {
      AppLanguage.vi: 'Luyện phát âm có chấm điểm',
      AppLanguage.en: 'Practice pronunciation with scoring',
    },
    'onboarding_page2_body': {
      AppLanguage.vi: 'Ghi âm giọng nói của bạn, app sẽ so khớp với câu gốc và chấm điểm để bạn biết mình đang phát âm đúng đến đâu.',
      AppLanguage.en: 'Record your voice and the app compares it to the original sentence, scoring how close your pronunciation is.',
    },
    'onboarding_page3_title': {
      AppLanguage.vi: 'Học 10 từ mới mỗi ngày',
      AppLanguage.en: 'Learn 10 new words a day',
    },
    'onboarding_page3_body': {
      AppLanguage.vi: 'Chọn 10 từ muốn học, đặt giờ nhắc, app sẽ tự mở đố vui theo lịch để ôn lại — kể cả khi app đang đóng.',
      AppLanguage.en: 'Pick 10 words to learn, set a reminder interval, and the app quizzes you on schedule — even while it\'s closed.',
    },
    'onboarding_page4_title': {
      AppLanguage.vi: 'Trò chuyện với AI bằng giọng nói',
      AppLanguage.en: 'Chat with AI using your voice',
    },
    'onboarding_page4_body': {
      AppLanguage.vi: 'Chạm vào nút AI nổi ở mọi màn hình để trò chuyện tự do bằng tiếng Anh, được góp ý ngữ pháp và từ vựng ngay khi nói.',
      AppLanguage.en: 'Tap the floating AI button on any screen to have a free conversation in English, with grammar and vocabulary feedback as you speak.',
    },
    'onboarding_page5_title': {
      AppLanguage.vi: 'Đố vui & thi đấu bạn bè',
      AppLanguage.en: 'Quizzes & compete with friends',
    },
    // Phonics lessons feature (phonics_*.dart) - 12 bai hoc phat am co cau
    // truc, vao tu man Menu.
    'phonics_title': {
      AppLanguage.vi: 'Bài học phát âm',
      AppLanguage.en: 'Pronunciation Lessons',
    },
    'phonics_subtitle': {
      AppLanguage.vi: '12 bài học từ âm cơ bản đến ngữ điệu, nối âm',
      AppLanguage.en: '12 lessons from basic sounds to intonation & linking',
    },
    'phonics_quick_subtitle': {
      AppLanguage.vi: '12 bài, đi từ âm cơ bản đến ngữ điệu',
      AppLanguage.en: '12 lessons, from basic sounds to intonation',
    },
    'phonics_sound_count': {AppLanguage.vi: 'mục', AppLanguage.en: 'items'},
    'phonics_lesson_label': {
      AppLanguage.vi: 'Bài học',
      AppLanguage.en: 'Lesson',
    },
    'onboarding_page5_body': {
      AppLanguage.vi: 'Làm đố vui từ vựng, ngữ pháp theo chủ đề và leo hạng trên bảng xếp hạng cùng bạn bè.',
      AppLanguage.en: 'Take vocabulary and grammar quizzes by topic and climb the leaderboard together with your friends.',
    },

    // Fitness (features/fitness/) - Phase 1: thu vien bai tap. Chi dich CHU
    // GIAO DIEN (tieu de, danh muc, trang thai...) - noi dung 155 bai tap
    // (ten/huong dan) van giu nguyen tieng Viet, xem exercise_model.dart.
    'fitness_menu_title': {
      AppLanguage.vi: 'Fitness (Beta)',
      AppLanguage.en: 'Fitness (Beta)',
    },
    'fitness_library_title': {
      AppLanguage.vi: 'Thư viện bài tập',
      AppLanguage.en: 'Exercise library',
    },
    'fitness_home_category_workout': {
      AppLanguage.vi: 'Luyện tập',
      AppLanguage.en: 'Workout',
    },
    'fitness_categories_title': {
      AppLanguage.vi: 'Các bài tập',
      AppLanguage.en: 'Exercises',
    },
    'fitness_search_hint': {
      AppLanguage.vi: 'Tìm kiếm',
      AppLanguage.en: 'Search',
    },
    'fitness_search_placeholder': {
      AppLanguage.vi: 'Tìm bài tập...',
      AppLanguage.en: 'Search exercises...',
    },
    'fitness_filter_all': {AppLanguage.vi: 'Tất cả', AppLanguage.en: 'All'},
    'fitness_load_error': {
      AppLanguage.vi: 'Không tải được thư viện bài tập.',
      AppLanguage.en: 'Could not load the exercise library.',
    },
    'fitness_no_results': {
      AppLanguage.vi: 'Không tìm thấy bài tập phù hợp.',
      AppLanguage.en: 'No matching exercises found.',
    },
    'fitness_involvement_title': {
      AppLanguage.vi: 'Mức độ tham gia nhóm cơ',
      AppLanguage.en: 'Muscle involvement',
    },
    'fitness_instructions_title': {
      AppLanguage.vi: 'Hướng dẫn thực hiện',
      AppLanguage.en: 'Instructions',
    },
    'fitness_muscle_chest': {AppLanguage.vi: 'Ngực', AppLanguage.en: 'Chest'},
    'fitness_muscle_back': {AppLanguage.vi: 'Lưng', AppLanguage.en: 'Back'},
    'fitness_muscle_shoulders': {
      AppLanguage.vi: 'Vai',
      AppLanguage.en: 'Shoulders',
    },
    'fitness_muscle_arms': {AppLanguage.vi: 'Tay', AppLanguage.en: 'Arms'},
    'fitness_muscle_legs': {AppLanguage.vi: 'Chân', AppLanguage.en: 'Legs'},
    'fitness_muscle_core': {AppLanguage.vi: 'Bụng', AppLanguage.en: 'Core'},
    'fitness_muscle_full_body': {
      AppLanguage.vi: 'Toàn thân',
      AppLanguage.en: 'Full body',
    },
    'fitness_muscle_functional': {
      AppLanguage.vi: 'Chức năng',
      AppLanguage.en: 'Functional',
    },
    'fitness_muscle_cardio': {
      AppLanguage.vi: 'Tim mạch',
      AppLanguage.en: 'Cardio',
    },
    'fitness_difficulty_beginner': {
      AppLanguage.vi: 'Cơ bản',
      AppLanguage.en: 'Beginner',
    },
    'fitness_difficulty_intermediate': {
      AppLanguage.vi: 'Trung cấp',
      AppLanguage.en: 'Intermediate',
    },
    'fitness_difficulty_advanced': {
      AppLanguage.vi: 'Nâng cao',
      AppLanguage.en: 'Advanced',
    },
    'fitness_menu_subtitle': {
      AppLanguage.vi: 'Thư viện bài tập theo nhóm cơ',
      AppLanguage.en: 'Exercise library by muscle group',
    },

    // Fitness Phase 2: Giao an (Programs) + Tap luyen (Workout) - port tu FitViet
    'fitness_programs_title': {
      AppLanguage.vi: 'Giáo án',
      AppLanguage.en: 'Programs',
    },
    'fitness_programs_load_error': {
      AppLanguage.vi: 'Không tải được danh sách giáo án.',
      AppLanguage.en: 'Could not load the programs list.',
    },
    'fitness_program_sessions_per_week': {
      AppLanguage.vi: '{n} buổi/tuần',
      AppLanguage.en: '{n} sessions/week',
    },
    'fitness_program_duration_weeks': {
      AppLanguage.vi: '{n} tuần',
      AppLanguage.en: '{n} weeks',
    },
    'fitness_program_set_active': {
      AppLanguage.vi: 'Đặt làm giáo án hiện tại',
      AppLanguage.en: 'Set as current program',
    },
    'fitness_program_active_badge': {
      AppLanguage.vi: 'Đang theo',
      AppLanguage.en: 'Active',
    },
    'fitness_program_rest_day': {
      AppLanguage.vi: 'Ngày nghỉ',
      AppLanguage.en: 'Rest day',
    },
    'fitness_program_weekday_1': {
      AppLanguage.vi: 'Thứ Hai',
      AppLanguage.en: 'Monday',
    },
    'fitness_program_weekday_2': {
      AppLanguage.vi: 'Thứ Ba',
      AppLanguage.en: 'Tuesday',
    },
    'fitness_program_weekday_3': {
      AppLanguage.vi: 'Thứ Tư',
      AppLanguage.en: 'Wednesday',
    },
    'fitness_program_weekday_4': {
      AppLanguage.vi: 'Thứ Năm',
      AppLanguage.en: 'Thursday',
    },
    'fitness_program_weekday_5': {
      AppLanguage.vi: 'Thứ Sáu',
      AppLanguage.en: 'Friday',
    },
    'fitness_program_weekday_6': {
      AppLanguage.vi: 'Thứ Bảy',
      AppLanguage.en: 'Saturday',
    },
    'fitness_program_weekday_7': {
      AppLanguage.vi: 'Chủ Nhật',
      AppLanguage.en: 'Sunday',
    },
    'fitness_program_start_today': {
      AppLanguage.vi: 'Bắt đầu tập hôm nay',
      AppLanguage.en: 'Start today\'s workout',
    },
    'fitness_home_no_active_program': {
      AppLanguage.vi: 'Bạn chưa chọn giáo án nào',
      AppLanguage.en: 'You haven\'t picked a program yet',
    },
    'fitness_home_view_programs': {
      AppLanguage.vi: 'Xem giáo án',
      AppLanguage.en: 'View programs',
    },
    'fitness_workout_preview_title': {
      AppLanguage.vi: 'Bài tập hôm nay',
      AppLanguage.en: 'Today\'s workout',
    },
    'fitness_workout_sets_reps': {
      AppLanguage.vi: '{sets} set × {min}–{max} reps',
      AppLanguage.en: '{sets} sets × {min}–{max} reps',
    },
    'fitness_workout_recommended_weight': {
      AppLanguage.vi: 'Gợi ý: {kg}kg',
      AppLanguage.en: 'Recommended: {kg}kg',
    },
    'fitness_workout_begin': {
      AppLanguage.vi: 'Bắt đầu',
      AppLanguage.en: 'Begin',
    },
    'fitness_workout_set_label': {
      AppLanguage.vi: 'Set {current}/{total}',
      AppLanguage.en: 'Set {current}/{total}',
    },
    'fitness_workout_weight_kg': {
      AppLanguage.vi: 'Mức tạ (kg)',
      AppLanguage.en: 'Weight (kg)',
    },
    'fitness_workout_reps': {AppLanguage.vi: 'Số reps', AppLanguage.en: 'Reps'},
    'fitness_workout_complete_set': {
      AppLanguage.vi: 'Xong set',
      AppLanguage.en: 'Finish set',
    },
    'fitness_workout_resting': {
      AppLanguage.vi: 'Đang nghỉ',
      AppLanguage.en: 'Resting',
    },
    'fitness_workout_add_rest': {
      AppLanguage.vi: '+15s',
      AppLanguage.en: '+15s',
    },
    'fitness_workout_skip_rest': {
      AppLanguage.vi: 'Bỏ qua',
      AppLanguage.en: 'Skip',
    },
    'fitness_workout_finished_title': {
      AppLanguage.vi: 'Hoàn thành buổi tập!',
      AppLanguage.en: 'Workout complete!',
    },
    'fitness_workout_duration': {
      AppLanguage.vi: 'Thời lượng',
      AppLanguage.en: 'Duration',
    },
    'fitness_workout_total_volume': {
      AppLanguage.vi: 'Tổng khối lượng',
      AppLanguage.en: 'Total volume',
    },
    'fitness_workout_total_sets': {
      AppLanguage.vi: 'Số set',
      AppLanguage.en: 'Sets',
    },
    'fitness_workout_back_home': {
      AppLanguage.vi: 'Về trang chủ',
      AppLanguage.en: 'Back home',
    },
    'fitness_workout_superset_badge': {
      AppLanguage.vi: '2 BÀI LIÊN TIẾP',
      AppLanguage.en: 'SUPERSET',
    },
    'fitness_workout_superset_no_rest': {
      AppLanguage.vi: 'không nghỉ',
      AppLanguage.en: 'no rest',
    },
    'fitness_workout_share': {
      AppLanguage.vi: 'Chia sẻ lên Cộng đồng',
      AppLanguage.en: 'Share to Community',
    },
    'fitness_workout_shared': {
      AppLanguage.vi: 'Đã chia sẻ ✓',
      AppLanguage.en: 'Shared ✓',
    },

    // Fitness Phase 6: Cong dong (Community) - port tu FitViet
    'fitness_community_title': {
      AppLanguage.vi: 'Cộng đồng',
      AppLanguage.en: 'Community',
    },
    'fitness_community_empty': {
      AppLanguage.vi: 'Chưa có bài chia sẻ nào. Hãy là người đầu tiên!',
      AppLanguage.en: 'No shares yet. Be the first!',
    },
    'fitness_community_load_error': {
      AppLanguage.vi: 'Không tải được Cộng đồng.',
      AppLanguage.en: 'Could not load Community.',
    },
    'fitness_community_post_summary': {
      AppLanguage.vi: 'đã tập {duration} · {kg}kg',
      AppLanguage.en: 'trained for {duration} · {kg}kg',
    },

    // Fitness Phase 3: Dinh duong - port tu FitViet
    'fitness_nutrition_title': {
      AppLanguage.vi: 'Dinh dưỡng',
      AppLanguage.en: 'Nutrition',
    },
    'fitness_nutrition_kcal_of_goal': {
      AppLanguage.vi: '/{goal} kcal',
      AppLanguage.en: '/{goal} kcal',
    },
    'fitness_nutrition_protein': {
      AppLanguage.vi: 'Đạm',
      AppLanguage.en: 'Protein',
    },
    'fitness_nutrition_carb': {
      AppLanguage.vi: 'Tinh bột',
      AppLanguage.en: 'Carbs',
    },
    'fitness_nutrition_fat': {
      AppLanguage.vi: 'Chất béo',
      AppLanguage.en: 'Fat',
    },
    'fitness_nutrition_today_meals': {
      AppLanguage.vi: 'Bữa ăn hôm nay',
      AppLanguage.en: "Today's meals",
    },
    'fitness_nutrition_no_meals': {
      AppLanguage.vi: 'Chưa log bữa ăn nào hôm nay.',
      AppLanguage.en: "You haven't logged any meals today.",
    },
    'fitness_nutrition_add_meal': {
      AppLanguage.vi: '+ Thêm món',
      AppLanguage.en: '+ Add food',
    },
    'fitness_nutrition_pick_food_title': {
      AppLanguage.vi: 'Chọn món ăn',
      AppLanguage.en: 'Pick a food',
    },
    'fitness_nutrition_slot_breakfast': {
      AppLanguage.vi: 'Sáng',
      AppLanguage.en: 'Breakfast',
    },
    'fitness_nutrition_slot_lunch': {
      AppLanguage.vi: 'Trưa',
      AppLanguage.en: 'Lunch',
    },
    'fitness_nutrition_slot_dinner': {
      AppLanguage.vi: 'Tối',
      AppLanguage.en: 'Dinner',
    },
    'fitness_nutrition_slot_snack': {
      AppLanguage.vi: 'Ăn vặt',
      AppLanguage.en: 'Snack',
    },

    // Fitness Phase 4: Trang chu (Dashboard) - port tu FitViet
    'fitness_dashboard_streak': {
      AppLanguage.vi: 'Chuỗi ngày',
      AppLanguage.en: 'Day streak',
    },
    'fitness_dashboard_sessions_week': {
      AppLanguage.vi: 'Buổi tuần này',
      AppLanguage.en: 'Sessions this week',
    },
    'fitness_dashboard_volume_week': {
      AppLanguage.vi: 'Tổng kg tuần',
      AppLanguage.en: 'Total kg this week',
    },
    'fitness_dashboard_weekly_volume_title': {
      AppLanguage.vi: 'Khối lượng 7 ngày',
      AppLanguage.en: '7-day volume',
    },
    'fitness_dashboard_tip_come_back': {
      AppLanguage.vi: 'Đã lâu bạn chưa tập rồi, quay lại luyện tập nhé!',
      AppLanguage.en: "It's been a while — let's get back to training!",
    },
    'fitness_dashboard_tip_streak_praise': {
      AppLanguage.vi: 'Tuyệt vời! Bạn đang duy trì chuỗi {n} ngày liên tiếp.',
      AppLanguage.en: "Great job! You're on a {n}-day streak.",
    },
    'fitness_dashboard_tip_generic_1': {
      AppLanguage.vi: 'Uống đủ nước giúp cơ bắp phục hồi nhanh hơn.',
      AppLanguage.en: 'Staying hydrated helps your muscles recover faster.',
    },
    'fitness_dashboard_tip_generic_2': {
      AppLanguage.vi: 'Ngủ đủ 7-8 tiếng để cơ thể phục hồi tốt nhất.',
      AppLanguage.en: 'Get 7-8 hours of sleep for the best recovery.',
    },
    'fitness_dashboard_tip_generic_3': {
      AppLanguage.vi: 'Khởi động kỹ trước khi tập để tránh chấn thương.',
      AppLanguage.en: 'Warm up properly before training to avoid injury.',
    },

    // Attribution/Credits screen (features/attribution/)
    'attribution_menu_title': {
      AppLanguage.vi: 'Ghi công',
      AppLanguage.en: 'Attribution',
    },
    'attribution_menu_subtitle': {
      AppLanguage.vi: 'Nguồn & giấy phép nhạc dùng trong app',
      AppLanguage.en: 'Sources & licenses for music used in the app',
    },
    'attribution_title': {
      AppLanguage.vi: 'Ghi công',
      AppLanguage.en: 'Attribution',
    },
    'attribution_subtitle': {
      AppLanguage.vi: 'Nhạc trong app dùng giấy phép Creative Commons',
      AppLanguage.en: 'Music in this app is used under Creative Commons',
    },
    'attribution_songs_suffix': {
      AppLanguage.vi: 'bài hát',
      AppLanguage.en: 'songs',
    },
    'attribution_view_license': {
      AppLanguage.vi: 'Xem điều khoản giấy phép →',
      AppLanguage.en: 'View license terms →',
    },
    'attribution_original_content_title': {
      AppLanguage.vi: 'NỘI DUNG GỐC',
      AppLanguage.en: 'ORIGINAL CONTENT',
    },
    'attribution_original_content_body': {
      AppLanguage.vi:
          'Từ vựng, ngữ pháp, câu đố và các bài học (Chuyện ngắn, phát âm...) '
          'do đội ngũ app tự biên soạn, không trích từ nguồn bên ngoài nào '
          'nên không cần ghi công.',
      AppLanguage.en:
          'Vocabulary, grammar, quizzes and lessons (Stories, pronunciation...) '
          'are written in-house and not taken from any external source, so '
          'no attribution is required.',
    },

    // Word popup (story)
    'word_in_story': {
      AppLanguage.vi: 'TRONG CHUYỆN NGẮN',
      AppLanguage.en: 'IN THE STORY',
    },

    // Story feature (features/story/) - micro-story B1, xem
    // docs/architecture-multimedia-platform.md Phase 1
    'home_story_quick_title': {
      AppLanguage.vi: 'Chuyện ngắn',
      AppLanguage.en: 'Stories',
    },
    'home_story_quick_subtitle': {
      AppLanguage.vi: 'Nghe + đọc 1 câu chuyện ngắn trình độ B1',
      AppLanguage.en: 'Listen & read a short B1-level story',
    },
    'story_original_label': {
      AppLanguage.vi: 'Nội dung gốc',
      AppLanguage.en: 'Original content',
    },
    'story_completed_badge': {
      AppLanguage.vi: 'Hoàn thành',
      AppLanguage.en: 'Completed',
    },
    'story_segment_label': {AppLanguage.vi: 'Đoạn', AppLanguage.en: 'Line'},
    'story_vocabulary_title': {
      AppLanguage.vi: 'TỪ VỰNG TRONG BÀI',
      AppLanguage.en: 'VOCABULARY IN THIS STORY',
    },
    'story_shadow_section_title': {
      AppLanguage.vi: 'LUYỆN NÓI THEO (SHADOWING)',
      AppLanguage.en: 'SHADOWING PRACTICE',
    },
    'story_shadow_title': {
      AppLanguage.vi: 'Luyện nói theo đoạn này',
      AppLanguage.en: 'Practice this line',
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
