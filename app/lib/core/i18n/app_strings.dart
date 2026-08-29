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

    // Menu tab (menu_screen.dart) - gom cac muc it dung hon vao 1 danh
    // sach thay vi chiem rieng 1 tab o thanh dieu huong duoi.
    'menu_title': {AppLanguage.vi: 'Menu', AppLanguage.en: 'Menu'},
    'menu_subtitle': {
      AppLanguage.vi: 'Các tính năng khác',
      AppLanguage.en: 'More features',
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

    // Home screen
    'home_greeting': {AppLanguage.vi: 'Xin chào', AppLanguage.en: 'Hello'},
    'home_dictionary_tooltip': {
      AppLanguage.vi: 'Từ điển',
      AppLanguage.en: 'Dictionary',
    },
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
  };

  static String t(String key, AppLanguage lang) =>
      _dict[key]?[lang] ?? _dict[key]?[AppLanguage.vi] ?? key;
}

/// `ref.tr('key')` thay vì phải watch(appLanguageProvider) + gọi
/// AppStrings.t thủ công ở từng widget.
extension AppTr on WidgetRef {
  String tr(String key) => AppStrings.t(key, watch(appLanguageProvider));
}
