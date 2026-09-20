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
    'grammar_irregular_verbs_title': {
      AppLanguage.vi: 'Bảng động từ bất quy tắc',
      AppLanguage.en: 'Irregular verbs table',
    },
    'grammar_irregular_verbs_subtitle': {
      AppLanguage.vi: '{n} động từ bất quy tắc thường gặp (V1 - V2 - V3)',
      AppLanguage.en: '{n} common irregular verbs (V1 - V2 - V3)',
    },
    'grammar_irregular_verbs_search_hint': {
      AppLanguage.vi: 'Tìm động từ hoặc nghĩa tiếng Việt...',
      AppLanguage.en: 'Search verb or Vietnamese meaning...',
    },
    'grammar_irregular_verbs_meaning': {
      AppLanguage.vi: 'Nghĩa',
      AppLanguage.en: 'Meaning',
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
    'assistive_menu_home': {
      AppLanguage.vi: 'Trang chủ',
      AppLanguage.en: 'Home',
    },
    'assistive_menu_translate': {
      AppLanguage.vi: 'Dịch',
      AppLanguage.en: 'Translate',
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
    'crypto_other_results': {
      AppLanguage.vi: 'Kết quả khác trên OKX (ngoài top 100)',
      AppLanguage.en: 'Other results on OKX (outside top 100)',
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
    'vocab_mark_learned': {
      AppLanguage.vi: 'Đánh dấu đã học',
      AppLanguage.en: 'Mark as learned',
    },
    'vocab_mark_learned_confirm_title': {
      AppLanguage.vi: 'Đánh dấu đã học?',
      AppLanguage.en: 'Mark as learned?',
    },
    'vocab_mark_learned_confirm_body': {
      AppLanguage.vi: '"{word}" sẽ ẩn khỏi danh sách Từ vựng và chuyển vào Words Learned. Bạn có thể xem lại hoặc bỏ đánh dấu bất cứ lúc nào.',
      AppLanguage.en: '"{word}" will be hidden from the Vocabulary list and moved to Words Learned. You can review or unmark it anytime.',
    },
    'vocab_unmark_learned': {
      AppLanguage.vi: 'Bỏ đánh dấu đã học',
      AppLanguage.en: 'Unmark as learned',
    },
    'vocab_unmark_learned_confirm_title': {
      AppLanguage.vi: 'Bỏ đánh dấu đã học?',
      AppLanguage.en: 'Unmark as learned?',
    },
    'vocab_unmark_learned_confirm_body': {
      AppLanguage.vi: '"{word}" sẽ quay lại danh sách Từ vựng theo chủ đề.',
      AppLanguage.en: '"{word}" will go back to the Vocabulary by topic list.',
    },
    'vocab_learned_empty': {
      AppLanguage.vi: 'Chưa có từ nào được đánh dấu đã học',
      AppLanguage.en: 'No words marked as learned yet',
    },
    'vocab_frequency_common': {
      AppLanguage.vi: 'Thông dụng',
      AppLanguage.en: 'Common',
    },
    'vocab_frequency_medium': {
      AppLanguage.vi: 'Thường gặp',
      AppLanguage.en: 'Medium',
    },
    'vocab_frequency_rare': {AppLanguage.vi: 'Ít gặp', AppLanguage.en: 'Rare'},
    'vocab_frequency_all_desc': {
      AppLanguage.vi: 'Xem toàn bộ từ trong chủ đề, không phân biệt mức độ.',
      AppLanguage.en: 'Shows every word in this topic, regardless of level.',
    },
    'vocab_frequency_common_desc': {
      AppLanguage.vi: 'Từ gặp hằng ngày (vd "mother", "water") - phù hợp người mới bắt đầu, nên học nhóm này trước.',
      AppLanguage.en: 'Words you meet every day (e.g. "mother", "water") - best for beginners, learn these first.',
    },
    'vocab_frequency_medium_desc': {
      AppLanguage.vi: 'Từ thường gặp nhưng không cơ bản (vd "colleague", "umbrella") - phù hợp người đã nắm vững từ thông dụng.',
      AppLanguage.en: 'Common but not basic words (e.g. "colleague", "umbrella") - for learners who already know the common set.',
    },
    'vocab_frequency_rare_desc': {
      AppLanguage.vi: 'Từ ít gặp, chuyên sâu/trang trọng (vd "sibling", "itinerary") - phù hợp người muốn mở rộng vốn từ nâng cao.',
      AppLanguage.en: 'Less common, more formal/advanced words (e.g. "sibling", "itinerary") - for learners wanting to expand further.',
    },
    'vocab_pos_noun': {AppLanguage.vi: 'Danh từ', AppLanguage.en: 'Noun'},
    'vocab_pos_verb': {AppLanguage.vi: 'Động từ', AppLanguage.en: 'Verb'},
    'vocab_pos_adjective': {
      AppLanguage.vi: 'Tính từ',
      AppLanguage.en: 'Adjective',
    },
    'vocab_pos_adverb': {AppLanguage.vi: 'Trạng từ', AppLanguage.en: 'Adverb'},
    'vocab_pos_phrase': {AppLanguage.vi: 'Cụm từ', AppLanguage.en: 'Phrase'},
    'vocab_filter_all': {AppLanguage.vi: 'Tất cả', AppLanguage.en: 'All'},
    'vocab_search_hint': {
      AppLanguage.vi: 'Tìm chủ đề từ vựng...',
      AppLanguage.en: 'Search vocabulary topics...',
    },
    'search_no_results': {
      AppLanguage.vi: 'Không tìm thấy kết quả nào',
      AppLanguage.en: 'No results found',
    },
    'vocab_select_hint': {
      AppLanguage.vi: 'Chọn các từ muốn học hôm nay',
      AppLanguage.en: 'Select the words you want to learn today',
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
    'writing_title': {AppLanguage.vi: 'Luyện viết', AppLanguage.en: 'Writing'},
    'writing_subtitle': {
      AppLanguage.vi: 'Gõ tiếng Anh, chấm điểm tự động',
      AppLanguage.en: 'Type in English, get graded automatically',
    },
    'writing_mode_vocab_title': {
      AppLanguage.vi: 'Từ vựng',
      AppLanguage.en: 'Vocabulary',
    },
    'writing_mode_vocab_desc': {
      AppLanguage.vi: 'Xem nghĩa tiếng Việt, gõ lại từ tiếng Anh',
      AppLanguage.en: 'See the Vietnamese meaning, type the English word',
    },
    'writing_mode_paragraph_title': {
      AppLanguage.vi: 'Đoạn văn',
      AppLanguage.en: 'Paragraph',
    },
    'writing_mode_paragraph_desc': {
      AppLanguage.vi: 'Dịch đoạn văn ngắn sang tiếng Anh, bài theo từng cấp độ',
      AppLanguage.en: 'Translate short paragraphs, graded by level',
    },
    'writing_vocab_pick_topic': {
      AppLanguage.vi: 'Chọn 1 chủ đề để bắt đầu',
      AppLanguage.en: 'Pick a topic to start',
    },
    'writing_vocab_type_for': {
      AppLanguage.vi: 'GÕ TỪ TIẾNG ANH CHO',
      AppLanguage.en: 'TYPE THE ENGLISH WORD FOR',
    },
    'writing_vocab_hint': {
      AppLanguage.vi: 'Gõ từ tiếng Anh...',
      AppLanguage.en: 'Type the English word...',
    },
    'writing_check_button': {
      AppLanguage.vi: 'Kiểm tra',
      AppLanguage.en: 'Check',
    },
    'writing_next_button': {
      AppLanguage.vi: 'Câu tiếp theo',
      AppLanguage.en: 'Next',
    },
    'writing_see_result_button': {
      AppLanguage.vi: 'Xem kết quả',
      AppLanguage.en: 'See result',
    },
    'writing_result_correct': {
      AppLanguage.vi: 'Chính xác!',
      AppLanguage.en: 'Correct!',
    },
    'writing_result_close': {
      AppLanguage.vi: 'Gần đúng, sai chính tả',
      AppLanguage.en: 'Close, spelling mistake',
    },
    'writing_result_wrong': {
      AppLanguage.vi: 'Sai rồi, đáp án đúng là',
      AppLanguage.en: 'Wrong, the correct answer is',
    },
    'writing_paragraph_pick_hint': {
      AppLanguage.vi: 'Chọn 1 đoạn văn để dịch',
      AppLanguage.en: 'Pick a paragraph to translate',
    },
    'writing_topic_pick_hint': {
      AppLanguage.vi: 'Chọn chủ đề, mỗi chủ đề có bài theo từng cấp',
      AppLanguage.en: 'Pick a topic - each has lessons for every level',
    },
    'writing_mixed_title': {
      AppLanguage.vi: 'Ôn tổng hợp 12 thì',
      AppLanguage.en: 'Mixed review: 12 tenses',
    },
    'writing_mixed_desc': {
      AppLanguage.vi:
          '24 đoạn, mỗi đoạn trộn nhiều thì - hợp người đã học đủ các thì',
      AppLanguage.en:
          '24 paragraphs mixing many tenses - for learners who know them all',
    },
    'writing_lesson_count': {AppLanguage.vi: 'bài', AppLanguage.en: 'lessons'},
    'writing_done_count': {
      AppLanguage.vi: '{done}/{total} đã làm',
      AppLanguage.en: '{done}/{total} done',
    },
    'writing_sentence_count': {
      AppLanguage.vi: 'câu',
      AppLanguage.en: 'sentences',
    },
    'writing_paragraph_hint': {
      AppLanguage.vi: 'Dịch từng câu sang tiếng Anh rồi bấm Chấm điểm',
      AppLanguage.en: 'Translate each sentence, then tap Grade',
    },
    'writing_paragraph_translate_for': {
      AppLanguage.vi: 'DỊCH SANG TIẾNG ANH',
      AppLanguage.en: 'TRANSLATE TO ENGLISH',
    },
    'writing_paragraph_type_hint': {
      AppLanguage.vi: 'Gõ bản dịch tiếng Anh...',
      AppLanguage.en: 'Type the English translation...',
    },
    'writing_overall_score': {
      AppLanguage.vi: 'Điểm tổng',
      AppLanguage.en: 'Overall score',
    },
    'writing_grade_button': {
      AppLanguage.vi: 'Chấm điểm',
      AppLanguage.en: 'Grade',
    },
    'writing_regrade_button': {
      AppLanguage.vi: 'Chấm lại',
      AppLanguage.en: 'Grade again',
    },
    'writing_correct_answer_label': {
      AppLanguage.vi: 'Đáp án đúng',
      AppLanguage.en: 'Correct answer',
    },
    'writing_tense_label': {
      AppLanguage.vi: 'Ngữ pháp',
      AppLanguage.en: 'Grammar',
    },
    'media_bar_not_playing': {
      AppLanguage.vi: 'Chưa phát nhạc',
      AppLanguage.en: 'No music playing',
    },
    'learning_path_tooltip': {
      AppLanguage.vi: 'Gợi ý lộ trình học',
      AppLanguage.en: 'Suggest a learning path',
    },
    'learning_path_hint_text': {
      AppLanguage.vi: 'Bấm để nhận gợi ý lộ trình học',
      AppLanguage.en: 'Tap for a learning path tip',
    },
    'learning_path_survey_title': {
      AppLanguage.vi: 'Gợi ý lộ trình học',
      AppLanguage.en: 'Suggest a learning path',
    },
    'learning_path_survey_subtitle': {
      AppLanguage.vi: 'Trả lời nhanh để app gợi ý tính năng phù hợp với bạn',
      AppLanguage.en: 'Answer quickly so the app can suggest what fits you',
    },
    'learning_path_q1_title': {
      AppLanguage.vi: 'Trình độ hiện tại của bạn?',
      AppLanguage.en: 'What is your current level?',
    },
    'learning_path_q1_a1': {
      AppLanguage.vi: 'Tôi gần như mất gốc / mới bắt đầu',
      AppLanguage.en: "I'm almost a complete beginner",
    },
    'learning_path_q1_a2': {
      AppLanguage.vi: 'Tôi biết cơ bản nhưng ngữ pháp còn yếu',
      AppLanguage.en: 'I know basics but my grammar is weak',
    },
    'learning_path_q1_a3': {
      AppLanguage.vi: 'Tôi khá ổn, muốn học theo mục tiêu cụ thể',
      AppLanguage.en: "I'm decent, I want a goal-specific path",
    },
    'learning_path_q2_title': {
      AppLanguage.vi: 'Mục tiêu chính của bạn là gì?',
      AppLanguage.en: 'What is your main goal?',
    },
    'learning_path_q2_a1': {
      AppLanguage.vi: 'Giao tiếp hằng ngày, tự tin nói chuyện',
      AppLanguage.en: 'Everyday conversation, speak confidently',
    },
    'learning_path_q2_a2': {
      AppLanguage.vi: 'Dùng trong công việc (email, họp, thuyết trình)',
      AppLanguage.en: 'Use at work (email, meetings, presentations)',
    },
    'learning_path_q2_a3': {
      AppLanguage.vi: 'Luyện thi TOEIC',
      AppLanguage.en: 'Prepare for TOEIC',
    },
    'learning_path_q2_a4': {
      AppLanguage.vi: 'Luyện thi IELTS',
      AppLanguage.en: 'Prepare for IELTS',
    },
    'learning_path_turn_off': {
      AppLanguage.vi: 'Tôi muốn tự học, tắt gợi ý',
      AppLanguage.en: "I'll study on my own, turn off suggestions",
    },

    // Personalized learning plan survey.
    'learning_survey_title': {
      AppLanguage.vi: 'Tạo kế hoạch học cùng AI',
      AppLanguage.en: 'Create a learning plan with AI',
    },
    'learning_survey_progress_1': {
      AppLanguage.vi:
          'Bước 1/5 · Kế hoạch dựa trên thời gian và mục tiêu thực tế của bạn.',
      AppLanguage.en: 'Step 1/5 · Your plan will fit your time and real goal.',
    },
    'learning_survey_progress_2': {
      AppLanguage.vi:
          'Bước 2/5 · Kế hoạch dựa trên thời gian và mục tiêu thực tế của bạn.',
      AppLanguage.en: 'Step 2/5 · Your plan will fit your time and real goal.',
    },
    'learning_survey_progress_3': {
      AppLanguage.vi:
          'Bước 3/5 · Kế hoạch dựa trên thời gian và mục tiêu thực tế của bạn.',
      AppLanguage.en: 'Step 3/5 · Your plan will fit your time and real goal.',
    },
    'learning_survey_progress_4': {
      AppLanguage.vi:
          'Bước 4/5 · Kế hoạch dựa trên thời gian và mục tiêu thực tế của bạn.',
      AppLanguage.en: 'Step 4/5 · Your plan will fit your time and real goal.',
    },
    'learning_survey_progress_5': {
      AppLanguage.vi:
          'Bước 5/5 · Kế hoạch dựa trên thời gian và mục tiêu thực tế của bạn.',
      AppLanguage.en: 'Step 5/5 · Your plan will fit your time and real goal.',
    },
    'learning_survey_level_title': {
      AppLanguage.vi: '1. Trình độ hiện tại của bạn?',
      AppLanguage.en: '1. What is your current level?',
    },
    'learning_survey_level_beginner': {
      AppLanguage.vi: 'Mới bắt đầu / gần như mất gốc',
      AppLanguage.en: 'New to English / almost a complete beginner',
    },
    'learning_survey_level_grammar_weak': {
      AppLanguage.vi: 'Biết cơ bản nhưng ngữ pháp còn yếu',
      AppLanguage.en: 'I know the basics, but my grammar is weak',
    },
    'learning_survey_level_goal_ready': {
      AppLanguage.vi: 'Khá ổn, muốn học theo mục tiêu',
      AppLanguage.en: 'I am doing okay and want to study for a goal',
    },
    'learning_survey_goal_title': {
      AppLanguage.vi: '2. Mục tiêu chính của bạn là gì?',
      AppLanguage.en: '2. What is your main goal?',
    },
    'learning_survey_goal_daily': {
      AppLanguage.vi: 'Giao tiếp hằng ngày',
      AppLanguage.en: 'Everyday conversation',
    },
    'learning_survey_goal_office': {
      AppLanguage.vi: 'Tiếng Anh công sở',
      AppLanguage.en: 'English for work',
    },
    'learning_survey_goal_toeic': {
      AppLanguage.vi: 'Luyện thi TOEIC',
      AppLanguage.en: 'Prepare for TOEIC',
    },
    'learning_survey_goal_ielts': {
      AppLanguage.vi: 'Luyện thi IELTS',
      AppLanguage.en: 'Prepare for IELTS',
    },
    'learning_survey_goal_foundation': {
      AppLanguage.vi: 'Củng cố nền tảng toàn diện',
      AppLanguage.en: 'Build a solid foundation',
    },
    'learning_survey_time_title': {
      AppLanguage.vi: '3. Bạn có thể học bao lâu mỗi ngày?',
      AppLanguage.en: '3. How long can you study each day?',
    },
    'learning_survey_time_10': {
      AppLanguage.vi: '10 phút',
      AppLanguage.en: '10 minutes',
    },
    'learning_survey_time_20': {
      AppLanguage.vi: '20 phút',
      AppLanguage.en: '20 minutes',
    },
    'learning_survey_time_30': {
      AppLanguage.vi: '30 phút',
      AppLanguage.en: '30 minutes',
    },
    'learning_survey_time_45': {
      AppLanguage.vi: '45 phút',
      AppLanguage.en: '45 minutes',
    },
    'learning_survey_skills_title': {
      AppLanguage.vi: '4. Chọn tối đa 2 kỹ năng ưu tiên',
      AppLanguage.en: '4. Choose up to two priority skills',
    },
    'learning_survey_skill_vocabulary': {
      AppLanguage.vi: 'Từ vựng',
      AppLanguage.en: 'Vocabulary',
    },
    'learning_survey_skill_grammar': {
      AppLanguage.vi: 'Ngữ pháp',
      AppLanguage.en: 'Grammar',
    },
    'learning_survey_skill_listening': {
      AppLanguage.vi: 'Nghe',
      AppLanguage.en: 'Listening',
    },
    'learning_survey_skill_speaking': {
      AppLanguage.vi: 'Nói',
      AppLanguage.en: 'Speaking',
    },
    'learning_survey_skill_reading': {
      AppLanguage.vi: 'Đọc',
      AppLanguage.en: 'Reading',
    },
    'learning_survey_skill_writing': {
      AppLanguage.vi: 'Viết',
      AppLanguage.en: 'Writing',
    },
    'learning_survey_topics_title': {
      AppLanguage.vi: '5. Chủ đề bạn muốn gặp nhiều hơn? (có thể bỏ qua)',
      AppLanguage.en: '5. What topics would you like more of? (optional)',
    },
    'learning_survey_topic_daily_life': {
      AppLanguage.vi: 'Đời sống',
      AppLanguage.en: 'Daily life',
    },
    'learning_survey_topic_work': {
      AppLanguage.vi: 'Công việc',
      AppLanguage.en: 'Work',
    },
    'learning_survey_topic_travel': {
      AppLanguage.vi: 'Du lịch',
      AppLanguage.en: 'Travel',
    },
    'learning_survey_topic_technology': {
      AppLanguage.vi: 'Công nghệ',
      AppLanguage.en: 'Technology',
    },
    'learning_survey_topic_music': {
      AppLanguage.vi: 'Âm nhạc',
      AppLanguage.en: 'Music',
    },
    'learning_survey_back': {
      AppLanguage.vi: 'Quay lại',
      AppLanguage.en: 'Back',
    },
    'learning_survey_continue': {
      AppLanguage.vi: 'Tiếp tục',
      AppLanguage.en: 'Continue',
    },
    'learning_survey_create_plan': {
      AppLanguage.vi: 'Tạo kế hoạch 7 ngày',
      AppLanguage.en: 'Create 7-day plan',
    },
    'learning_survey_turn_off': {
      AppLanguage.vi: 'Tôi muốn tự học, tắt gợi ý',
      AppLanguage.en: 'I want to study on my own',
    },
    'learning_plan_title': {
      AppLanguage.vi: 'Kế hoạch 7 ngày của bạn',
      AppLanguage.en: 'Your 7-day plan',
    },
    'learning_plan_subtitle': {
      AppLanguage.vi:
          'AI sẽ dùng kết quả học thực tế để điều chỉnh kế hoạch tuần tới.',
      AppLanguage.en:
          'AI will use your learning results to adjust next week’s plan.',
    },
    'learning_plan_start': {
      AppLanguage.vi: 'Bắt đầu học',
      AppLanguage.en: 'Start learning',
    },
    'learning_plan_day1_title': {
      AppLanguage.vi: 'Khởi động với chủ đề đã chọn',
      AppLanguage.en: 'Warm up with your chosen topic',
    },
    'learning_plan_day1_reason': {
      AppLanguage.vi: 'Bắt đầu từ kỹ năng bạn ưu tiên.',
      AppLanguage.en: 'Start with the skill you chose.',
    },
    'learning_plan_day2_title': {
      AppLanguage.vi: 'Củng cố cấu trúc câu',
      AppLanguage.en: 'Strengthen sentence structure',
    },
    'learning_plan_day2_reason': {
      AppLanguage.vi: 'Giúp dùng từ mới thành câu đúng.',
      AppLanguage.en: 'Turn new words into correct sentences.',
    },
    'learning_plan_day3_title': {
      AppLanguage.vi: 'Luyện nói câu ngắn',
      AppLanguage.en: 'Practise short spoken sentences',
    },
    'learning_plan_day3_reason': {
      AppLanguage.vi: 'Tăng phản xạ và sự tự tin.',
      AppLanguage.en: 'Build fluency and confidence.',
    },
    'learning_plan_day4_title': {
      AppLanguage.vi: 'Bài học theo mục tiêu',
      AppLanguage.en: 'Goal-focused lesson',
    },
    'learning_plan_day4_reason': {
      AppLanguage.vi: 'Phục vụ trực tiếp mục tiêu đã chọn.',
      AppLanguage.en: 'Directly supports your chosen goal.',
    },
    'learning_plan_day5_title': {
      AppLanguage.vi: 'Viết để ghi nhớ',
      AppLanguage.en: 'Write to remember',
    },
    'learning_plan_day5_reason': {
      AppLanguage.vi: 'Vận dụng từ vựng và ngữ pháp.',
      AppLanguage.en: 'Apply vocabulary and grammar.',
    },
    'learning_plan_day6_title': {
      AppLanguage.vi: 'Nghe và đọc hiểu',
      AppLanguage.en: 'Listen and read for meaning',
    },
    'learning_plan_day6_reason': {
      AppLanguage.vi: 'Tiếp xúc tiếng Anh trong ngữ cảnh.',
      AppLanguage.en: 'Meet English in context.',
    },
    'learning_plan_day7_title': {
      AppLanguage.vi: 'Ôn tập trong tuần',
      AppLanguage.en: 'Weekly review',
    },
    'learning_plan_day7_reason': {
      AppLanguage.vi: 'Củng cố kiến thức trước tuần tiếp theo.',
      AppLanguage.en: 'Consolidate learning before next week.',
    },

    // 3 cap hoc suy tu persona - xem docs/research-level-based-content.md.
    'learner_level_basic': {AppLanguage.vi: 'Cơ bản', AppLanguage.en: 'Basic'},
    'learner_level_intermediate': {
      AppLanguage.vi: 'Trung cấp',
      AppLanguage.en: 'Intermediate',
    },
    'learner_level_advanced': {
      AppLanguage.vi: 'Nâng cao',
      AppLanguage.en: 'Advanced',
    },
    'learner_level_showing': {
      AppLanguage.vi: 'Đang hiển thị cấp',
      AppLanguage.en: 'Showing level',
    },
    'learner_level_change': {AppLanguage.vi: 'Đổi', AppLanguage.en: 'Change'},
    'pron_level_random': {
      AppLanguage.vi: 'Câu ngẫu nhiên hợp cấp {level}',
      AppLanguage.en: 'Random sentence for {level} level',
    },
    'vocab_frequency_level_desc': {
      AppLanguage.vi: 'Chỉ hiện từ hợp với cấp bạn đã chọn ở Gợi ý lộ trình.',
      AppLanguage.en: 'Only words that match the level you picked are shown.',
    },
    'writing_vocab_hint_letters': {
      AppLanguage.vi: 'Gợi ý: {hint} ({count} chữ cái)',
      AppLanguage.en: 'Hint: {hint} ({count} letters)',
    },
    'writing_vocab_hint_count': {
      AppLanguage.vi: 'Gợi ý: từ có {count} chữ cái',
      AppLanguage.en: 'Hint: the word has {count} letters',
    },

    'persona_name_beginner': {
      AppLanguage.vi: 'Mất gốc',
      AppLanguage.en: 'Absolute beginner',
    },
    'persona_name_dailyConversation': {
      AppLanguage.vi: 'Giao tiếp hằng ngày',
      AppLanguage.en: 'Daily conversation',
    },
    'persona_name_officeEnglish': {
      AppLanguage.vi: 'Tiếng Anh công sở',
      AppLanguage.en: 'Office English',
    },
    'persona_name_grammarOverhaul': {
      AppLanguage.vi: 'Ôn tập toàn diện',
      AppLanguage.en: 'Full grammar review',
    },
    'persona_name_toeicPrep': {
      AppLanguage.vi: 'Luyện thi TOEIC',
      AppLanguage.en: 'TOEIC prep',
    },
    'persona_name_ieltsPrep': {
      AppLanguage.vi: 'Luyện thi IELTS',
      AppLanguage.en: 'IELTS prep',
    },

    'vocab_add_to_daily': {
      AppLanguage.vi: 'Học {n} từ hôm nay',
      AppLanguage.en: 'Learn {n} words today',
    },
    'vocab_added_to_daily': {
      AppLanguage.vi: 'Đã thêm {n} từ vào danh sách học hôm nay',
      AppLanguage.en: "Added {n} words to today's learning list",
    },
    'word_saved_to_daily': {
      AppLanguage.vi: 'Đã thêm vào danh sách học hôm nay',
      AppLanguage.en: "Added to today's learning list",
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

    'daily_writing_title': {
      AppLanguage.vi: 'Luyện viết từ',
      AppLanguage.en: 'Word writing',
    },
    'daily_speaking_title': {
      AppLanguage.vi: 'Luyện nói từ',
      AppLanguage.en: 'Word speaking',
    },
    'daily_speaking_say_for': {
      AppLanguage.vi: 'NÓI TỪ TIẾNG ANH CHO',
      AppLanguage.en: 'SAY THE ENGLISH WORD FOR',
    },
    'daily_speaking_listen': {
      AppLanguage.vi: 'Nghe phát âm mẫu',
      AppLanguage.en: 'Hear pronunciation',
    },
    'daily_speaking_you_said': {
      AppLanguage.vi: 'Bạn nói:',
      AppLanguage.en: 'You said:',
    },
    'daily_speaking_nothing_heard': {
      AppLanguage.vi: '(không nghe rõ)',
      AppLanguage.en: '(nothing heard)',
    },
    'daily_speaking_pass': {
      AppLanguage.vi: 'Phát âm tốt!',
      AppLanguage.en: 'Well pronounced!',
    },
    'daily_speaking_fail': {
      AppLanguage.vi: 'Chưa đúng — nghe mẫu rồi thử lại nhé',
      AppLanguage.en: 'Not quite — listen and try again',
    },
    'daily_skip_button': {AppLanguage.vi: 'Bỏ qua', AppLanguage.en: 'Skip'},

    // Profile - "Học {n} từ hôm nay" (chon o Vocabulary hoac khi luu tu tra
    // cuu, nhac hoc bang thong bao dinh ky)
    'profile_daily_words_title': {
      AppLanguage.vi: 'Học {n} từ hôm nay',
      AppLanguage.en: 'Learn {n} words today',
    },
    'profile_daily_words_mode_label': {
      AppLanguage.vi: 'Cách ôn tập',
      AppLanguage.en: 'Review method',
    },
    'profile_daily_words_mode_quiz': {
      AppLanguage.vi: 'Quiz',
      AppLanguage.en: 'Quiz',
    },
    'profile_daily_words_mode_writing': {
      AppLanguage.vi: 'Writing',
      AppLanguage.en: 'Writing',
    },
    'profile_daily_words_mode_speaking': {
      AppLanguage.vi: 'Speaking',
      AppLanguage.en: 'Speaking',
    },
    'profile_daily_words_mode_random': {
      AppLanguage.vi: 'Ngẫu nhiên',
      AppLanguage.en: 'Random',
    },
    'profile_daily_words_tutorial_pick_mode': {
      AppLanguage.vi: 'Chọn 1 cách ôn tập bên dưới',
      AppLanguage.en: 'Pick a study mode below',
    },
    'profile_daily_words_relearn': {
      AppLanguage.vi: 'Học lại',
      AppLanguage.en: 'Learn again',
    },
    'profile_daily_words_expired_hint': {
      AppLanguage.vi: 'Đã sang ngày mới — học lại các từ này hoặc kết thúc để lưu vào Từ đã học.',
      AppLanguage.en: "It's a new day — learn these words again, or end to save them to Words Learned.",
    },
    'profile_daily_words_empty': {
      AppLanguage.vi: 'Chưa có từ nào — vào Từ vựng theo chủ đề để chọn, hoặc bấm "Lưu" khi tra một từ.',
      AppLanguage.en: 'No words yet — pick some in Vocabulary by Topic, or tap "Save" when looking up a word.',
    },
    'profile_daily_words_select': {
      AppLanguage.vi: 'Chọn từ để học',
      AppLanguage.en: 'Select words',
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
    'profile_daily_words_custom_interval': {
      AppLanguage.vi: 'Khác',
      AppLanguage.en: 'Custom',
    },
    'profile_daily_words_custom_interval_title': {
      AppLanguage.vi: 'Nhắc lại mỗi... phút',
      AppLanguage.en: 'Remind every... minutes',
    },
    'profile_daily_words_custom_interval_error': {
      AppLanguage.vi: 'Nhập số phút từ 1 trở lên',
      AppLanguage.en: 'Enter a number of minutes, 1 or more',
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
    // Huong dan ngon tay 2 buoc khi vua bam "Hoc hom nay" tu Vocabulary -
    // xem ProfileScreen.highlightDailyWords / _TutorialFingerPointer.
    'profile_daily_words_tutorial_pick_minutes': {
      AppLanguage.vi: 'Chọn thời gian nhắc bên dưới',
      AppLanguage.en: 'Pick a reminder interval below',
    },
    'profile_daily_words_tutorial_start': {
      AppLanguage.vi: 'Bấm để bắt đầu học',
      AppLanguage.en: 'Tap to start learning',
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
    'wealth_pay_action_button': {
      AppLanguage.vi: 'Thanh toán',
      AppLanguage.en: 'Pay',
    },
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
      AppLanguage.vi: 'Cổ phiếu',
      AppLanguage.en: 'Stocks',
    },
    'wealth_watchlist_stocks': {
      AppLanguage.vi: 'Cổ phiếu',
      AppLanguage.en: 'Stocks',
    },
    'wealth_watchlist_stocks_vn': {
      AppLanguage.vi: 'Việt Nam',
      AppLanguage.en: 'Vietnam',
    },
    'wealth_watchlist_stocks_intl': {
      AppLanguage.vi: 'Quốc tế',
      AppLanguage.en: 'International',
    },
    'wealth_investments_total': {
      AppLanguage.vi: 'Tổng tài sản đầu tư',
      AppLanguage.en: 'Total investment assets',
    },
    'wealth_investments_metal_title': {
      AppLanguage.vi: 'Kim loại hiếm',
      AppLanguage.en: 'Rare metals',
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
    'wealth_investments_currency_title': {
      AppLanguage.vi: 'Ngoại tệ',
      AppLanguage.en: 'Foreign currency',
    },
    'wealth_currency_bank_note': {
      AppLanguage.vi: 'Tỷ giá Vietcombank thời gian thực, định giá theo giá ngân hàng mua chuyển khoản.',
      AppLanguage.en:
          'Real-time Vietcombank rate, valued at the bank buy-transfer price.',
    },
    'wealth_currency_rate_buy_cash': {
      AppLanguage.vi: 'Mua tiền mặt',
      AppLanguage.en: 'Buy cash',
    },
    'wealth_currency_rate_buy_transfer': {
      AppLanguage.vi: 'Mua chuyển khoản',
      AppLanguage.en: 'Buy transfer',
    },
    'wealth_currency_rate_sell': {
      AppLanguage.vi: 'Bán ra',
      AppLanguage.en: 'Sell',
    },
    'wealth_currency_add_new': {
      AppLanguage.vi: '+ Thêm ngoại tệ khác',
      AppLanguage.en: '+ Add another currency',
    },
    'wealth_holding_current_value': {
      AppLanguage.vi: 'Giá trị hiện tại',
      AppLanguage.en: 'Current value',
    },
    'wealth_holding_history_title': {
      AppLanguage.vi: 'Lịch sử giao dịch',
      AppLanguage.en: 'Transaction history',
    },
    'wealth_add_currency_holding': {
      AppLanguage.vi: 'Thêm ngoại tệ',
      AppLanguage.en: 'Add foreign currency',
    },
    'wealth_currency_pick_title': {
      AppLanguage.vi: 'Chọn loại ngoại tệ',
      AppLanguage.en: 'Choose currency',
    },
    'wealth_currency_rates_loading': {
      AppLanguage.vi: 'Chưa tải được tỷ giá ngân hàng, thử lại sau.',
      AppLanguage.en: 'Bank rates not loaded yet, try again later.',
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
    'wealth_real_estate_purchase_hint': {
      AppLanguage.vi: 'Giá mua ban đầu (VND)',
      AppLanguage.en: 'Original purchase price (VND)',
    },
    'wealth_real_estate_purchase_label': {
      AppLanguage.vi: 'Giá mua ban đầu',
      AppLanguage.en: 'Original purchase price',
    },
    'wealth_real_estate_current_label': {
      AppLanguage.vi: 'Giá hiện tại',
      AppLanguage.en: 'Current value',
    },
    'wealth_add_holding': {
      AppLanguage.vi: 'Thêm mã cổ phiếu',
      AppLanguage.en: 'Add stock holding',
    },
    'wealth_symbol_hint': {
      AppLanguage.vi: 'Mã cổ phiếu (vd AAPL)',
      AppLanguage.en: 'Symbol (e.g. AAPL)',
    },
    'wealth_stock_pick_title': {
      AppLanguage.vi: 'Chọn cổ phiếu',
      AppLanguage.en: 'Choose a stock',
    },
    'wealth_stock_pick_search_hint': {
      AppLanguage.vi: 'Tìm mã hoặc tên công ty...',
      AppLanguage.en: 'Search symbol or company name...',
    },
    'wealth_stock_pick_manual_add': {
      AppLanguage.vi: 'Không tìm thấy? Thêm thủ công',
      AppLanguage.en: "Can't find it? Add manually",
    },
    'wealth_stock_pick_manual_note': {
      AppLanguage.vi: 'Nhập mã, tên và giá hiện tại - vì đây là mã không có nguồn giá tự động, giá sẽ không tự cập nhật, bạn cần tự sửa lại khi cần.',
      AppLanguage.en: "Enter symbol, name and current price - since there's no live price source for this one, it won't auto-update; edit it manually when needed.",
    },
    'wealth_stock_pick_name_hint': {
      AppLanguage.vi: 'Tên công ty (không bắt buộc)',
      AppLanguage.en: 'Company name (optional)',
    },
    'wealth_stock_pick_price_hint_vn': {
      AppLanguage.vi: 'Giá hiện tại (VND)',
      AppLanguage.en: 'Current price (VND)',
    },
    'wealth_stock_pick_price_hint_intl': {
      AppLanguage.vi: 'Giá hiện tại (USD)',
      AppLanguage.en: 'Current price (USD)',
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
    'wealth_dashboard_title': {
      AppLanguage.vi: 'Tổng quan',
      AppLanguage.en: 'Dashboard',
    },
    'wealth_dashboard_net_worth': {
      AppLanguage.vi: 'Tổng tài sản ròng',
      AppLanguage.en: 'Total net worth',
    },
    'wealth_dashboard_expense_month': {
      AppLanguage.vi: 'Chi tiêu',
      AppLanguage.en: 'Expense',
    },
    'wealth_dashboard_income_month': {
      AppLanguage.vi: 'Thu nhập',
      AppLanguage.en: 'Income',
    },
    'wealth_dashboard_period_day': {
      AppLanguage.vi: 'Ngày',
      AppLanguage.en: 'Day',
    },
    'wealth_dashboard_period_week': {
      AppLanguage.vi: 'Tuần',
      AppLanguage.en: 'Week',
    },
    'wealth_dashboard_period_month': {
      AppLanguage.vi: 'Tháng',
      AppLanguage.en: 'Month',
    },
    'wealth_dashboard_debt_summary': {
      AppLanguage.vi: 'Công nợ',
      AppLanguage.en: 'Debt overview',
    },
    'wealth_dashboard_services_summary': {
      AppLanguage.vi: 'Dịch vụ định kỳ',
      AppLanguage.en: 'Recurring services',
    },
    'wealth_dashboard_services_active': {
      AppLanguage.vi: 'Đang theo dõi',
      AppLanguage.en: 'Active',
    },
    'wealth_dashboard_services_expiring': {
      AppLanguage.vi: 'Sắp hết hạn',
      AppLanguage.en: 'Expiring soon',
    },
    'wealth_dashboard_nearest_expiry': {
      AppLanguage.vi: 'Gần hết hạn nhất',
      AppLanguage.en: 'Nearest expiry',
    },
    'wealth_dashboard_no_services': {
      AppLanguage.vi: 'Chưa có dịch vụ nào',
      AppLanguage.en: 'No services yet',
    },
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
    'wealth_expense_category_debt': {
      AppLanguage.vi: 'Trả nợ',
      AppLanguage.en: 'Debt payment',
    },
    'wealth_expense_category_investment': {
      AppLanguage.vi: 'Đầu tư',
      AppLanguage.en: 'Investment',
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
    'wealth_metal_gold_xaut': {
      AppLanguage.vi: 'Vàng quốc tế (XAUT)',
      AppLanguage.en: 'International Gold (XAUT)',
    },
    'wealth_metal_xaut_note': {
      AppLanguage.vi: 'XAUT (Tether Gold) - token 1:1 với vàng vật lý, giá quốc tế qua OKX, không phải giá bán lẻ trong nước.',
      AppLanguage.en: 'XAUT (Tether Gold) - 1:1 physical gold-backed token, international price via OKX, not a domestic retail price.',
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
    'wealth_stock_current_price_label': {
      AppLanguage.vi: 'Giá hiện tại',
      AppLanguage.en: 'Current price',
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
    'wealth_market_stocks_intl': {
      AppLanguage.vi: 'Quốc tế',
      AppLanguage.en: 'International',
    },
    'wealth_market_stocks_vn': {
      AppLanguage.vi: 'Việt Nam',
      AppLanguage.en: 'Vietnam',
    },
    'wealth_market_stocks_vn_note': {
      AppLanguage.vi: 'Giá khớp lệnh/đóng cửa gần nhất từ HOSE, chỉ mang tính tham khảo, không phải giá real-time chuẩn giao dịch. Sắp xếp theo giá trị giao dịch trong phiên (KHÔNG phải vốn hóa thị trường thật — HOSE không công bố số cổ phiếu lưu hành qua nguồn này).',
      AppLanguage.en: 'Last matched/closing price from HOSE, for reference only — not exchange-grade real-time data. Sorted by trading value (NOT real market cap — HOSE does not publish outstanding shares via this source).',
    },
    'wealth_market_stocks_okx_note': {
      AppLanguage.vi: 'Giá token mô phỏng cổ phiếu (tokenized stock) trên OKX, KHÔNG phải giá thật từ NASDAQ/NYSE — có thể lệch giá. Sắp xếp theo thanh khoản 24h (KHÔNG phải vốn hóa thị trường thật — không có nguồn miễn phí nào cung cấp số này).',
      AppLanguage.en: 'Tokenized stock price on OKX, NOT the real NASDAQ/NYSE price — may deviate. Sorted by 24h liquidity (NOT real market cap — no free data source provides that figure).',
    },
    'wealth_market_trading_value': {
      AppLanguage.vi: 'GT giao dịch',
      AppLanguage.en: 'Trading value',
    },
    'wealth_market_stocks_search_hint': {
      AppLanguage.vi: 'Tìm mã cổ phiếu...',
      AppLanguage.en: 'Search stock symbol...',
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
    'wealth_service_history_toggle': {
      AppLanguage.vi: 'Lịch sử gia hạn',
      AppLanguage.en: 'Renewal history',
    },
    'wealth_service_vs_previous_renewal': {
      AppLanguage.vi: 'so với lần gia hạn trước',
      AppLanguage.en: 'vs previous renewal',
    },
    'wealth_service_no_previous_renewal': {
      AppLanguage.vi: 'Chưa có lần gia hạn trước để so sánh',
      AppLanguage.en: 'No previous renewal to compare',
    },
    'wealth_service_will_assign_to': {
      AppLanguage.vi: 'Sẽ gán cho:',
      AppLanguage.en: 'Will be assigned to:',
    },
    'wealth_service_assign_title': {
      AppLanguage.vi: 'Gán dịch vụ cho app',
      AppLanguage.en: 'Assign service to app',
    },
    'wealth_service_assign_none': {
      AppLanguage.vi: 'Không gán (dịch vụ chung)',
      AppLanguage.en: 'Unassigned (general service)',
    },
    'profile_fee_services_title': {
      AppLanguage.vi: 'Dịch vụ phí',
      AppLanguage.en: 'Fee services',
    },
    'profile_fee_services_empty': {
      AppLanguage.vi: 'Chưa có dịch vụ nào gán cho app này.',
      AppLanguage.en: 'No services assigned to this app yet.',
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
    'wealth_service_renew_via_debt': {
      AppLanguage.vi: 'Ghi nợ (mượn tiền để gia hạn)',
      AppLanguage.en: 'Pay via debt (borrow to renew)',
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
    'wealth_report_title': {
      AppLanguage.vi: 'Báo cáo',
      AppLanguage.en: 'Reports',
    },
    'wealth_report_income_expense_title': {
      AppLanguage.vi: 'Thu chi trong tháng',
      AppLanguage.en: 'Income & expense this month',
    },
    'wealth_report_income_expense_title_all_time': {
      AppLanguage.vi: 'Thu chi tất cả các tháng',
      AppLanguage.en: 'Income & expense (all time)',
    },
    'wealth_report_all_time': {
      AppLanguage.vi: 'Tất cả',
      AppLanguage.en: 'All time',
    },
    'wealth_report_category_title': {
      AppLanguage.vi: 'Chi tiêu theo danh mục',
      AppLanguage.en: 'Expense by category',
    },
    'wealth_report_service_title': {
      AppLanguage.vi: 'Dịch vụ định kỳ',
      AppLanguage.en: 'Recurring services',
    },
    'wealth_report_renewal_history_title': {
      AppLanguage.vi: 'Lịch sử gia hạn',
      AppLanguage.en: 'Renewal history',
    },
    'wealth_report_renewal_history_more': {
      AppLanguage.vi: '+{n} mục khác',
      AppLanguage.en: '+{n} more',
    },
    'wealth_report_renewal_total': {
      AppLanguage.vi: 'Tổng gia hạn',
      AppLanguage.en: 'Total renewals',
    },
    'wealth_report_show_less': {
      AppLanguage.vi: 'Thu gọn',
      AppLanguage.en: 'Show less',
    },
    'wealth_report_vs_last_month': {
      AppLanguage.vi: 'so với tháng trước',
      AppLanguage.en: 'vs last month',
    },
    'wealth_report_no_previous_data': {
      AppLanguage.vi: 'Chưa có dữ liệu tháng trước để so sánh',
      AppLanguage.en: 'No previous month data to compare',
    },
    'wealth_report_no_data': {
      AppLanguage.vi: 'Chưa có dữ liệu',
      AppLanguage.en: 'No data yet',
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
    'wealth_debt_edit_payment': {
      AppLanguage.vi: 'Sửa lần trả nợ',
      AppLanguage.en: 'Edit payment',
    },
    'wealth_debt_collect': {
      AppLanguage.vi: 'Thu nợ',
      AppLanguage.en: 'Collect debt',
    },
    'wealth_debt_settled': {
      AppLanguage.vi: 'Đã trả xong',
      AppLanguage.en: 'Settled',
    },
    'wealth_debt_net_off_title': {
      AppLanguage.vi: 'Bù trừ nợ 2 chiều',
      AppLanguage.en: 'Net off both directions',
    },
    'wealth_debt_net_off_desc': {
      AppLanguage.vi: 'Người này vừa nợ mình vừa được mình nợ - bù trừ để chỉ còn 1 khoản chênh lệch.',
      AppLanguage.en: 'This person both owes you and is owed by you - net them off into a single remaining balance.',
    },
    'wealth_debt_net_off_button': {
      AppLanguage.vi: 'Bù trừ ngay',
      AppLanguage.en: 'Net off now',
    },
    'wealth_debt_net_off_confirm': {
      AppLanguage.vi: 'Xác nhận bù trừ',
      AppLanguage.en: 'Confirm netting',
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
    'wealth_debt_select_mode': {
      AppLanguage.vi: 'Chọn nhiều',
      AppLanguage.en: 'Select multiple',
    },
    'wealth_debt_select_cancel': {
      AppLanguage.vi: 'Hủy chọn',
      AppLanguage.en: 'Cancel',
    },
    'wealth_debt_batch_pay': {
      AppLanguage.vi: 'Trả nợ ({n})',
      AppLanguage.en: 'Pay debts ({n})',
    },
    'wealth_debt_batch_collect': {
      AppLanguage.vi: 'Thu nợ ({n})',
      AppLanguage.en: 'Collect debts ({n})',
    },
    'wealth_debt_batch_pay_title': {
      AppLanguage.vi: 'Trả nợ nhiều người',
      AppLanguage.en: 'Pay multiple people',
    },
    'wealth_debt_batch_collect_title': {
      AppLanguage.vi: 'Thu nợ nhiều người',
      AppLanguage.en: 'Collect from multiple people',
    },
    'wealth_pay_by': {
      AppLanguage.vi: 'Thanh toán bằng',
      AppLanguage.en: 'Pay by',
    },
    'wealth_receive_by': {
      AppLanguage.vi: 'Nhận vào',
      AppLanguage.en: 'Receive into',
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
    'wealth_settings_title': {
      AppLanguage.vi: 'Cài đặt',
      AppLanguage.en: 'Settings',
    },
    'wealth_settings_banks_title': {
      AppLanguage.vi: 'Ngân hàng đang sử dụng',
      AppLanguage.en: 'Banks you use',
    },
    'wealth_settings_banks_desc': {
      AppLanguage.vi: 'Chỉ những ngân hàng được chọn ở đây mới xuất hiện khi thêm chi tiêu, thêm số dư vào Ví hoặc thanh toán nợ. Chưa chọn ngân hàng nào thì hiện tất cả.',
      AppLanguage.en: 'Only banks selected here will show up when adding an expense, a wallet balance, or a debt payment. If none is selected, all banks are shown.',
    },
    'wealth_home_view_wallet': {
      AppLanguage.vi: 'Xem chi tiết Ví',
      AppLanguage.en: 'View wallet details',
    },
    'wealth_home_pay_receive': {
      AppLanguage.vi: 'Chi/Thu',
      AppLanguage.en: 'Pay/Receive',
    },
    'wealth_home_qr_code': {AppLanguage.vi: 'Mã QR', AppLanguage.en: 'QR Code'},
    'wealth_split_bill_title': {
      AppLanguage.vi: 'Chia tiền bill',
      AppLanguage.en: 'Split bill',
    },
    'wealth_split_bill_edit_title': {
      AppLanguage.vi: 'Sửa bill',
      AppLanguage.en: 'Edit bill',
    },
    'wealth_split_bill_update_button': {
      AppLanguage.vi: 'Cập nhật',
      AppLanguage.en: 'Update',
    },
    'wealth_split_bill_update_confirm_title': {
      AppLanguage.vi: 'Cập nhật bill này?',
      AppLanguage.en: 'Update this bill?',
    },
    'wealth_split_bill_update_confirm_desc': {
      AppLanguage.vi: 'Ghi chi tiêu/nợ cũ của bill này sẽ bị xóa và tạo lại theo dữ liệu vừa sửa.',
      AppLanguage.en: "This bill's old expense/debt records will be deleted and recreated from your edits.",
    },
    'wealth_split_bill_total_hint': {
      AppLanguage.vi: 'Tổng số tiền (VNĐ)',
      AppLanguage.en: 'Total amount (VND)',
    },
    'wealth_split_bill_people_count_hint': {
      AppLanguage.vi: 'Số người (kể cả bạn)',
      AppLanguage.en: 'Number of people (including you)',
    },
    'wealth_split_bill_continue': {
      AppLanguage.vi: 'Tiếp tục',
      AppLanguage.en: 'Continue',
    },
    'wealth_split_bill_me_label': {AppLanguage.vi: 'Tôi', AppLanguage.en: 'Me'},
    'wealth_split_bill_payment_method_label': {
      AppLanguage.vi: 'Thanh toán bằng',
      AppLanguage.en: 'Pay with',
    },
    'wealth_split_bill_pay_button': {
      AppLanguage.vi: 'Pay',
      AppLanguage.en: 'Pay',
    },
    'wealth_split_bill_confirm_title': {
      AppLanguage.vi: 'Xác nhận thanh toán',
      AppLanguage.en: 'Confirm payment',
    },
    'wealth_split_bill_confirm_desc': {
      AppLanguage.vi: 'Trừ toàn bộ số tiền dưới đây khỏi nguồn đã chọn?',
      AppLanguage.en: 'Deduct the full amount below from the chosen source?',
    },
    'wealth_split_bill_debt_button': {
      AppLanguage.vi: 'Ghi nợ',
      AppLanguage.en: 'Debt',
    },
    'wealth_split_bill_paid_button': {
      AppLanguage.vi: 'Đã trả',
      AppLanguage.en: 'Paid',
    },
    'wealth_split_bill_status_debt': {
      AppLanguage.vi: 'Đã ghi nợ',
      AppLanguage.en: 'Marked as debt',
    },
    'wealth_split_bill_status_paid': {
      AppLanguage.vi: 'Đã nhận tiền',
      AppLanguage.en: 'Received',
    },
    // Chon nguoi tra bill (xem WealthSplitBillScreen._payer)
    'wealth_split_bill_payer_label': {
      AppLanguage.vi: 'Người trả bill',
      AppLanguage.en: 'Who paid the bill',
    },
    'wealth_split_bill_status_payer': {
      AppLanguage.vi: 'Trả bill',
      AppLanguage.en: 'Paid bill',
    },
    'wealth_split_bill_status_i_owe': {
      AppLanguage.vi: 'Tôi nợ',
      AppLanguage.en: 'I owe',
    },
    'wealth_split_bill_my_share_to': {
      AppLanguage.vi: 'Trả phần của tôi cho {name} bằng',
      AppLanguage.en: 'Pay my share to {name} with',
    },
    'wealth_split_bill_pays_payer': {
      AppLanguage.vi: 'Trả cho {name} — chỉ hiển thị',
      AppLanguage.en: 'Pays {name} — info only',
    },
    'wealth_split_bill_debt_to': {
      AppLanguage.vi: 'Ghi nợ {name}',
      AppLanguage.en: 'Owe {name}',
    },
    'wealth_split_bill_done_button': {
      AppLanguage.vi: 'Xong',
      AppLanguage.en: 'Done',
    },
    'wealth_split_bill_no_qr_note': {
      AppLanguage.vi:
          'Chưa có mã QR nhận tiền - thêm ở nút "Mã QR" trong thẻ Tổng Ví.',
      AppLanguage.en: 'No payment QR yet - add one from the "QR Code" button on the Wallet card.',
    },
    'wealth_split_bill_qr_show_info': {
      AppLanguage.vi: 'Xem tên/số tài khoản',
      AppLanguage.en: 'Show name/account number',
    },
    'wealth_split_bill_qr_hide_info': {
      AppLanguage.vi: 'Ẩn bớt',
      AppLanguage.en: 'Hide',
    },
    'wealth_split_bill_preview_title': {
      AppLanguage.vi: 'Xem trước bill',
      AppLanguage.en: 'Preview bill',
    },
    'wealth_split_bill_note_hint': {
      AppLanguage.vi: 'Ghi chú (không bắt buộc)',
      AppLanguage.en: 'Note (optional)',
    },
    'wealth_split_bill_edit_note_title': {
      AppLanguage.vi: 'Sửa ghi chú',
      AppLanguage.en: 'Edit note',
    },
    'wealth_split_bill_history_title': {
      AppLanguage.vi: 'Lịch sử chia bill',
      AppLanguage.en: 'Split bill history',
    },
    'wealth_split_bill_history_empty': {
      AppLanguage.vi: 'Chưa có lần chia bill nào',
      AppLanguage.en: 'No split bills yet',
    },
    'wealth_split_bill_name_missing': {
      AppLanguage.vi: 'Nhập đủ tên tất cả mọi người trước khi thanh toán',
      AppLanguage.en: 'Enter everyone\'s name before paying',
    },
    'wealth_pay_screen_title': {
      AppLanguage.vi: 'Chi / Thu',
      AppLanguage.en: 'Pay / Receive',
    },
    'wealth_pay_tab_pay': {AppLanguage.vi: 'Chi tiêu', AppLanguage.en: 'Pay'},
    'wealth_pay_tab_receive': {
      AppLanguage.vi: 'Nạp tiền',
      AppLanguage.en: 'Receive',
    },
    'wealth_pay_tab_withdraw': {
      AppLanguage.vi: 'Rút tiền mặt',
      AppLanguage.en: 'Withdraw',
    },
    'wealth_pay_tab_investment': {
      AppLanguage.vi: 'Đầu tư',
      AppLanguage.en: 'Investment',
    },
    'wealth_pay_pay_desc': {
      AppLanguage.vi: 'Ghi lại 1 khoản chi tiêu - trừ thẳng vào Tiền mặt hoặc Ngân hàng bạn chọn.',
      AppLanguage.en: 'Log an expense - deducted straight from the cash or bank account you choose.',
    },
    'wealth_pay_pay_button': {
      AppLanguage.vi: 'Ghi khoản chi tiêu',
      AppLanguage.en: 'Log expense',
    },
    'wealth_pay_receive_desc': {
      AppLanguage.vi: 'Nạp thêm tiền vào Tiền mặt hoặc 1 tài khoản Ngân hàng.',
      AppLanguage.en: 'Add money into Cash or a bank account.',
    },
    'wealth_pay_receive_button': {
      AppLanguage.vi: 'Nạp tiền',
      AppLanguage.en: 'Receive money',
    },
    'wealth_pay_withdraw_desc': {
      AppLanguage.vi:
          'Rút tiền từ 1 tài khoản Ngân hàng, tự động cộng sang Tiền mặt.',
      AppLanguage.en:
          'Withdraw from a bank account - automatically credited to Cash.',
    },
    'wealth_pay_withdraw_button': {
      AppLanguage.vi: 'Rút tiền mặt',
      AppLanguage.en: 'Withdraw cash',
    },
    'wealth_pay_choose_source': {
      AppLanguage.vi: 'Chọn nguồn tiền',
      AppLanguage.en: 'Choose account',
    },
    'wealth_pay_add_bank': {
      AppLanguage.vi: 'Ngân hàng khác',
      AppLanguage.en: 'Other bank',
    },
    'wealth_pay_withdraw_need_bank': {
      AppLanguage.vi: 'Chọn 1 ngân hàng để rút tiền mặt',
      AppLanguage.en: 'Choose a bank to withdraw cash from',
    },
    'wealth_investment_desc': {
      AppLanguage.vi: 'Nhập số tiền lấy từ Ví, chọn khoản đầu tư và số lượng mua tương ứng.',
      AppLanguage.en: 'Enter the amount taken from your wallet, then pick an investment and the quantity bought.',
    },
    'wealth_investment_asset_type_label': {
      AppLanguage.vi: 'Loại đầu tư',
      AppLanguage.en: 'Investment type',
    },
    'wealth_investment_asset_crypto': {
      AppLanguage.vi: 'Crypto',
      AppLanguage.en: 'Crypto',
    },
    'wealth_investment_asset_stock': {
      AppLanguage.vi: 'Chứng khoán',
      AppLanguage.en: 'Stocks',
    },
    'wealth_investment_asset_gold': {
      AppLanguage.vi: 'Vàng',
      AppLanguage.en: 'Gold',
    },
    'wealth_investment_asset_real_estate': {
      AppLanguage.vi: 'Bất động sản',
      AppLanguage.en: 'Real estate',
    },
    'wealth_investment_pick_asset_label': {
      AppLanguage.vi: 'Chọn khoản đầu tư',
      AppLanguage.en: 'Pick an investment',
    },
    'wealth_investment_search_add': {
      AppLanguage.vi: 'Tìm để thêm',
      AppLanguage.en: 'Search to add',
    },
    'wealth_investment_no_watchlist_crypto': {
      AppLanguage.vi:
          'Chưa có coin nào trong Theo dõi - vào Market để thêm trước.',
      AppLanguage.en:
          'No coins in your Watchlist yet - add one from Market first.',
    },
    'wealth_investment_no_watchlist_stock': {
      AppLanguage.vi:
          'Chưa có mã nào trong Theo dõi - bấm "Tìm để thêm" để chọn mã mới.',
      AppLanguage.en:
          'No symbols in your Watchlist yet - tap "Search to add" to pick one.',
    },
    'wealth_investment_quantity_hint': {
      AppLanguage.vi: 'Số lượng mua',
      AppLanguage.en: 'Quantity bought',
    },
    'wealth_investment_realestate_name_hint': {
      AppLanguage.vi: 'Tên bất động sản',
      AppLanguage.en: 'Property name',
    },
    'wealth_saved': {AppLanguage.vi: 'Đã lưu', AppLanguage.en: 'Saved'},
    // Thong bao chung sau moi thao tac - dung cho showSuccessToast/
    // showErrorToast o MOI man hinh (core/widgets/app_toast.dart).
    'toast_saved': {AppLanguage.vi: 'Đã lưu', AppLanguage.en: 'Saved'},
    'toast_added': {AppLanguage.vi: 'Đã thêm', AppLanguage.en: 'Added'},
    'toast_updated': {AppLanguage.vi: 'Đã cập nhật', AppLanguage.en: 'Updated'},
    'toast_deleted': {AppLanguage.vi: 'Đã xoá', AppLanguage.en: 'Deleted'},
    'toast_failed': {
      AppLanguage.vi: 'Thất bại, vui lòng thử lại',
      AppLanguage.en: 'Failed, please try again',
    },
    'wealth_investment_confirm_button': {
      AppLanguage.vi: 'Xác nhận mua',
      AppLanguage.en: 'Confirm purchase',
    },
    'wealth_qr_title': {
      AppLanguage.vi: 'Mã QR nhận tiền',
      AppLanguage.en: 'Payment QR code',
    },
    'wealth_qr_empty_title': {
      AppLanguage.vi: 'Chưa có mã QR',
      AppLanguage.en: 'No QR code yet',
    },
    'wealth_qr_empty_desc': {
      AppLanguage.vi:
          'Thêm ảnh mã QR nhận tiền của bạn để chia sẻ nhanh khi cần.',
      AppLanguage.en:
          'Add your payment QR image to share it quickly when needed.',
    },
    'wealth_qr_add_button': {
      AppLanguage.vi: 'Thêm mã QR',
      AppLanguage.en: 'Add QR code',
    },
    'wealth_qr_edit_title': {
      AppLanguage.vi: 'Sửa mã QR',
      AppLanguage.en: 'Edit QR code',
    },
    'wealth_qr_pick_image': {
      AppLanguage.vi: 'Chạm để chọn ảnh QR',
      AppLanguage.en: 'Tap to choose a QR image',
    },
    'wealth_qr_change_image': {
      AppLanguage.vi: 'Chạm để đổi ảnh',
      AppLanguage.en: 'Tap to change image',
    },
    'wealth_qr_holder_name_hint': {
      AppLanguage.vi: 'Tên chủ tài khoản',
      AppLanguage.en: 'Account holder name',
    },
    'wealth_qr_account_number_hint': {
      AppLanguage.vi: 'Số tài khoản',
      AppLanguage.en: 'Account number',
    },
    'wealth_qr_bank_name_hint': {
      AppLanguage.vi: 'Tên ngân hàng',
      AppLanguage.en: 'Bank name',
    },
    'wealth_debt_person_remove_confirm': {
      AppLanguage.vi: 'Xóa người này khỏi danh sách gợi ý? Bạn có thể thêm lại bất cứ lúc nào bằng cách nhập đúng tên.',
      AppLanguage.en: 'Remove this person from suggestions? You can add them back anytime by typing the exact name again.',
    },
    'wealth_settings_tab_categories': {
      AppLanguage.vi: 'Danh mục',
      AppLanguage.en: 'Categories',
    },
    'wealth_settings_tab_banks': {
      AppLanguage.vi: 'Ngân hàng',
      AppLanguage.en: 'Banks',
    },
    'wealth_settings_price_alerts_title': {
      AppLanguage.vi: 'Thông báo giá biến động mạnh',
      AppLanguage.en: 'Big price move alerts',
    },
    'wealth_settings_price_alerts_desc': {
      AppLanguage.vi:
          'Báo khi coin/cổ phiếu trong watchlist tăng hoặc giảm hơn 5% (24h)',
      AppLanguage.en:
          'Notify when a coin/stock in your watchlist moves more than 5% (24h)',
    },
    'wealth_settings_price_alerts_test': {
      AppLanguage.vi: 'Gửi thử 1 thông báo',
      AppLanguage.en: 'Send a test notification',
    },
    'investment_chart_title': {
      AppLanguage.vi: 'Giá trị danh mục',
      AppLanguage.en: 'Portfolio value',
    },
    'investment_chart_empty': {
      AppLanguage.vi: 'Đang lấy dữ liệu giá... Đường biểu đồ sẽ hiện sau vài giây, khi có đủ 2 điểm giá.',
      AppLanguage.en: 'Collecting price data... The chart appears within a few seconds, once there are two data points.',
    },
    'confirm_save_title': {
      AppLanguage.vi: 'Lưu thay đổi này?',
      AppLanguage.en: 'Save this change?',
    },
    'assistive_voice_chat_mic_busy': {
      AppLanguage.vi: 'Đang luyện phát âm nên mic đang bận. Đóng màn Luyện phát âm rồi mở lại Trò chuyện AI.',
      AppLanguage.en: 'The mic is busy with pronunciation practice. Close that screen first, then open AI Voice Chat.',
    },
    'wealth_settings_price_alerts_test_sent': {
      AppLanguage.vi: 'Đã gửi - kéo thanh trạng thái xuống để xem',
      AppLanguage.en: 'Sent - pull down the status bar to see it',
    },
    'wealth_settings_price_alerts_test_blocked': {
      AppLanguage.vi: 'Máy đang chặn thông báo của app. Vào Cài đặt điện thoại > Ứng dụng > app này > Thông báo và bật lên.',
      AppLanguage.en: 'Your phone is blocking this app\'s notifications. Go to system Settings > Apps > this app > Notifications and turn them on.',
    },
    'wealth_settings_price_alerts_test_failed': {
      AppLanguage.vi: 'Không gửi được thông báo thử: ',
      AppLanguage.en: 'Could not send the test notification: ',
    },
    'wealth_settings_categories_title': {
      AppLanguage.vi: 'Danh mục chi tiêu',
      AppLanguage.en: 'Expense categories',
    },
    'wealth_settings_categories_desc': {
      AppLanguage.vi: 'Ngoài các danh mục có sẵn, bạn có thể thêm danh mục riêng để dùng khi ghi chi tiêu.',
      AppLanguage.en: 'Besides the built-in categories, you can add your own to use when logging expenses.',
    },
    'wealth_settings_categories_builtin': {
      AppLanguage.vi: 'Có sẵn',
      AppLanguage.en: 'Built-in',
    },
    'wealth_settings_categories_custom': {
      AppLanguage.vi: 'Tự thêm',
      AppLanguage.en: 'Your categories',
    },
    'wealth_settings_categories_empty': {
      AppLanguage.vi: 'Chưa có danh mục tự thêm nào',
      AppLanguage.en: 'No custom categories yet',
    },
    'wealth_settings_add_category': {
      AppLanguage.vi: 'Thêm danh mục',
      AppLanguage.en: 'Add category',
    },
    'wealth_settings_edit_category': {
      AppLanguage.vi: 'Sửa danh mục',
      AppLanguage.en: 'Edit category',
    },
    'wealth_settings_category_name_hint': {
      AppLanguage.vi: 'Tên danh mục (VD: Học phí con)',
      AppLanguage.en: 'Category name (e.g. Kids tuition)',
    },
    'wealth_settings_delete_category_title': {
      AppLanguage.vi: 'Xóa danh mục?',
      AppLanguage.en: 'Delete category?',
    },
    'wealth_settings_category_delete_confirm': {
      AppLanguage.vi: 'Xóa danh mục này? Các khoản chi đã dùng danh mục này sẽ chuyển về "Khác".',
      AppLanguage.en:
          'Delete this category? Expenses using it will fall back to "Other".',
    },
    'wealth_category_no_custom': {
      AppLanguage.vi: 'Không liên kết danh mục',
      AppLanguage.en: 'No linked category',
    },
    'wealth_edit_holding': {
      AppLanguage.vi: 'Sửa mã cổ phiếu',
      AppLanguage.en: 'Edit stock holding',
    },
    'wealth_buy_more': {AppLanguage.vi: 'Mua thêm', AppLanguage.en: 'Buy more'},
    'wealth_sell': {AppLanguage.vi: 'Bán', AppLanguage.en: 'Sell'},
    'wealth_buy_more_title': {
      AppLanguage.vi: 'Mua thêm',
      AppLanguage.en: 'Buy more',
    },
    'wealth_sell_title': {AppLanguage.vi: 'Bán', AppLanguage.en: 'Sell'},
    'wealth_sell_quantity_hint': {
      AppLanguage.vi: 'Số lượng muốn bán',
      AppLanguage.en: 'Quantity to sell',
    },
    'wealth_sell_price_hint': {
      AppLanguage.vi: 'Giá bán',
      AppLanguage.en: 'Sell price',
    },
    'wealth_buy_price_hint': {
      AppLanguage.vi: 'Giá mua',
      AppLanguage.en: 'Buy price',
    },
    'wealth_sell_max_note': {
      AppLanguage.vi: 'Hiện đang có',
      AppLanguage.en: 'Currently holding',
    },
    'wealth_sell_exceeds_holding': {
      AppLanguage.vi: 'Số lượng bán vượt quá số đang có',
      AppLanguage.en: 'Sell quantity exceeds current holding',
    },
    'wealth_realized_pnl_label': {
      AppLanguage.vi: 'Lãi/lỗ thực hiện',
      AppLanguage.en: 'Realized P&L',
    },
    'wealth_real_estate_sell': {
      AppLanguage.vi: 'Bán bất động sản',
      AppLanguage.en: 'Sell property',
    },
    'wealth_real_estate_sell_price_hint': {
      AppLanguage.vi: 'Giá bán cuối cùng',
      AppLanguage.en: 'Final sale price',
    },
    'wealth_real_estate_sell_confirm': {
      AppLanguage.vi: 'Xác nhận bán bất động sản này? Sẽ xóa khỏi danh sách nắm giữ và ghi lại vào lịch sử.',
      AppLanguage.en: 'Confirm selling this property? It will be removed from holdings and recorded in history.',
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
    'wallet_withdraw_push_to_cash': {
      AppLanguage.vi: 'Chuyển số tiền rút vào Tiền mặt',
      AppLanguage.en: 'Move the withdrawn amount into Cash',
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
    'wealth_filter_by_date': {
      AppLanguage.vi: 'Lọc theo ngày',
      AppLanguage.en: 'Filter by date',
    },
    'wallet_history_today': {
      AppLanguage.vi: 'Hôm nay',
      AppLanguage.en: 'Today',
    },
    'wallet_history_yesterday': {
      AppLanguage.vi: 'Hôm qua',
      AppLanguage.en: 'Yesterday',
    },
    'wallet_view_all_history': {
      AppLanguage.vi: 'Xem tất cả lịch sử',
      AppLanguage.en: 'View all history',
    },
    'wallet_hidden_amount': {AppLanguage.vi: 'Đã ẩn', AppLanguage.en: 'Hidden'},

    // Home screen
    'home_greeting': {AppLanguage.vi: 'Xin chào', AppLanguage.en: 'Hello'},
    // Loi chao doi theo gio tren may (xem greetingKeyForNow() trong
    // home_screen.dart) - thay cho 'home_greeting' co dinh o man Home moi.
    'home_greeting_morning': {
      AppLanguage.vi: 'Chào buổi sáng',
      AppLanguage.en: 'Good morning',
    },
    'home_greeting_afternoon': {
      AppLanguage.vi: 'Chào buổi chiều',
      AppLanguage.en: 'Good afternoon',
    },
    'home_greeting_evening': {
      AppLanguage.vi: 'Chào buổi tối',
      AppLanguage.en: 'Good evening',
    },
    'home_greeting_night': {
      AppLanguage.vi: 'Chào buổi khuya',
      AppLanguage.en: 'Good night',
    },
    // Ten cap do - server (my_learning_xp) chi tra ve KHOA, app tu dich.
    'level_beginner': {
      AppLanguage.vi: 'Mới bắt đầu',
      AppLanguage.en: 'Beginner',
    },
    'level_elementary': {
      AppLanguage.vi: 'Sơ cấp',
      AppLanguage.en: 'Elementary',
    },
    'level_intermediate': {
      AppLanguage.vi: 'Trung cấp',
      AppLanguage.en: 'Intermediate',
    },
    'level_upper': {
      AppLanguage.vi: 'Trung cao cấp',
      AppLanguage.en: 'Upper-Intermediate',
    },
    'level_advanced': {AppLanguage.vi: 'Nâng cao', AppLanguage.en: 'Advanced'},
    'home_xp_to_next': {
      AppLanguage.vi: 'Còn {n} XP nữa',
      AppLanguage.en: 'Next level in {n} XP',
    },
    'home_day_streak': {
      AppLanguage.vi: 'Ngày liên tiếp',
      AppLanguage.en: 'Day streak',
    },
    'home_main_skill': {
      AppLanguage.vi: 'KỸ NĂNG CHÍNH',
      AppLanguage.en: 'MAIN SKILL',
    },
    'home_continue': {AppLanguage.vi: 'Tiếp tục', AppLanguage.en: 'Continue'},
    'home_practice_label': {
      AppLanguage.vi: 'LUYỆN TẬP',
      AppLanguage.en: 'PRACTICE',
    },
    'home_achieve_label': {
      AppLanguage.vi: 'CHINH PHỤC',
      AppLanguage.en: 'ACHIEVE',
    },
    'home_listening_speaking': {
      AppLanguage.vi: 'Nghe nói',
      AppLanguage.en: 'Listening & Speaking',
    },
    'home_listening_speaking_sub': {
      AppLanguage.vi: 'Nghe kỹ. Nói lại. Tự tin hơn.',
      AppLanguage.en: 'Hear it. Say it. Be confident.',
    },
    'home_test_prep_sub': {
      AppLanguage.vi: 'Luyện tập. Tiến bộ. Đạt mục tiêu.',
      AppLanguage.en: 'Practice. Improve. Achieve.',
    },
    'home_sub_vocabulary': {
      AppLanguage.vi: 'Học từ mới',
      AppLanguage.en: 'Learn smarter',
    },
    'home_sub_grammar': {
      AppLanguage.vi: 'Dùng đúng',
      AppLanguage.en: 'Use naturally',
    },
    'home_sub_reading': {
      AppLanguage.vi: 'Hiểu sâu',
      AppLanguage.en: 'Understand deeper',
    },
    'home_sub_writing': {
      AppLanguage.vi: 'Tự diễn đạt',
      AppLanguage.en: 'Express yourself',
    },
    'home_sub_phonics': {
      AppLanguage.vi: 'Phát âm chuẩn',
      AppLanguage.en: 'Sound natural',
    },
    'home_sub_pronunciation': {
      AppLanguage.vi: 'Có chấm điểm',
      AppLanguage.en: 'Real-life practice',
    },
    'home_sub_story': {
      AppLanguage.vi: 'Nghe + đọc',
      AppLanguage.en: 'Learn with stories',
    },
    'home_sub_ai_chat': {
      AppLanguage.vi: 'Nói mọi lúc',
      AppLanguage.en: 'Chat anytime',
    },
    'home_sub_toeic': {
      AppLanguage.vi: 'Đề chuẩn',
      AppLanguage.en: 'Official format',
    },
    'home_sub_ielts': {
      AppLanguage.vi: 'Nâng band',
      AppLanguage.en: 'Score higher',
    },
    'home_sub_quiz': {
      AppLanguage.vi: 'Thử thách nhanh',
      AppLanguage.en: 'Think & learn',
    },
    'home_badge_new': {AppLanguage.vi: 'MỚI', AppLanguage.en: 'New'},
    // Ten NGAN cho the o luoi Home - the chi rong ~1/4 man nen dung ten day
    // du ('Tu vung theo chu de') se bi cat giua chung.
    'home_skill_vocabulary': {
      AppLanguage.vi: 'Từ vựng',
      AppLanguage.en: 'Vocabulary',
    },
    // Ba o luyen thi nam canh icon nen chi con ~1/3 be ngang the: ten day du
    // ('Luyen Thi TOEIC' / 'TOEIC Practice') bi cat thanh 'TOEIC P...'.
    'home_skill_toeic': {AppLanguage.vi: 'TOEIC', AppLanguage.en: 'TOEIC'},
    'home_skill_ielts': {AppLanguage.vi: 'IELTS', AppLanguage.en: 'IELTS'},
    'home_skill_quiz': {AppLanguage.vi: 'Đố vui', AppLanguage.en: 'Quiz'},
    // Nhan NGAN cho 4 o o Home - o chi rong ~1/4 man nen ten day du
    // ('Chia tien bill') bi thu nho qua muc hoac cat mat chu.
    'wealth_home_tile_split': {
      AppLanguage.vi: 'Chia bill',
      AppLanguage.en: 'Split bill',
    },
    // Dong mo ta duoi ten trong dai hanh dong cua the Tong tai san.
    // Dong mo ta duoi "Chua phat nhac" tren thanh nhac (theo anh thiet ke).
    'media_bar_not_playing_sub': {
      AppLanguage.vi: 'Chọn nhạc để tăng năng lượng',
      AppLanguage.en: 'Pick a song to get going',
    },
    'wealth_home_pay_receive_sub': {
      AppLanguage.vi: 'Nhanh chóng · An toàn',
      AppLanguage.en: 'Fast & secure',
    },
    'wealth_home_qr_code_sub': {
      AppLanguage.vi: 'Thanh toán tiện lợi',
      AppLanguage.en: 'Easy payments',
    },
    'wealth_home_market_sub': {
      AppLanguage.vi: 'Giá thị trường',
      AppLanguage.en: 'Market prices',
    },
    'wealth_home_watchlist_sub': {
      AppLanguage.vi: 'Mã đang theo dõi',
      AppLanguage.en: 'Your watchlist',
    },
    'wealth_home_overview_title': {
      AppLanguage.vi: 'Tổng quan tài chính',
      AppLanguage.en: 'Financial overview',
    },
    'wealth_home_overview_sub': {
      AppLanguage.vi: 'Biến động tài sản của bạn',
      AppLanguage.en: 'How your money moved',
    },
    'wealth_home_overview_empty': {
      AppLanguage.vi: 'Chưa có giao dịch nào trong 6 tháng gần đây',
      AppLanguage.en: 'No transactions in the last 6 months',
    },
    'wealth_home_report_all': {
      AppLanguage.vi: 'Xem tất cả',
      AppLanguage.en: 'View all',
    },
    // --- Man Home Quan ly tai san (thiet ke lai) ---
    'wealth_home_sub_expense': {
      AppLanguage.vi: 'Quản lý chi tiêu',
      AppLanguage.en: 'Manage spending',
    },
    'wealth_home_sub_debt': {
      AppLanguage.vi: 'Các khoản đang nợ',
      AppLanguage.en: 'Debts you owe',
    },
    'wealth_home_sub_service': {
      AppLanguage.vi: 'Đăng ký định kỳ',
      AppLanguage.en: 'Recurring payments',
    },
    'wealth_home_sub_split': {
      AppLanguage.vi: 'Chia hóa đơn',
      AppLanguage.en: 'Split a bill',
    },
    'wealth_home_report_sub': {
      AppLanguage.vi: 'Phân tích thông minh · Định hướng tương lai',
      AppLanguage.en: 'Smart analysis · Plan ahead',
    },
    'wealth_home_messages_title': {
      AppLanguage.vi: 'Tin nhắn',
      AppLanguage.en: 'Messages',
    },
    'wealth_home_messages_unread': {
      AppLanguage.vi: 'Bạn có {n} tin nhắn chưa đọc',
      AppLanguage.en: 'You have {n} unread messages',
    },
    'wealth_home_messages_none': {
      AppLanguage.vi: 'Chưa có tin nhắn mới',
      AppLanguage.en: 'No new messages',
    },
    'wealth_home_messages_badge': {
      AppLanguage.vi: '{n} mới',
      AppLanguage.en: '{n} new',
    },
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
    'home_category_test_prep': {
      AppLanguage.vi: 'Luyện thi',
      AppLanguage.en: 'Test Prep',
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
    'player_speed_title': {
      AppLanguage.vi: 'Tốc độ phát',
      AppLanguage.en: 'Playback speed',
    },
    'player_speed_normal': {
      AppLanguage.vi: 'Bình thường',
      AppLanguage.en: 'Normal',
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
      AppLanguage.vi: 'Học từ mới mỗi ngày',
      AppLanguage.en: 'Learn new words every day',
    },
    'onboarding_page3_body': {
      AppLanguage.vi: 'Chọn từ muốn học, đặt giờ nhắc, chọn Quiz hoặc Writing — app sẽ tự mở bài ôn theo lịch, kể cả khi app đang đóng.',
      AppLanguage.en: 'Pick words to learn, set a reminder interval, choose Quiz or Writing — the app opens a review on schedule, even while it\'s closed.',
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
      AppLanguage.vi: 'Tập luyện',
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
    'story_category_short_stories': {
      AppLanguage.vi: 'Truyện ngắn',
      AppLanguage.en: 'Short Stories',
    },
    'story_category_conversations': {
      AppLanguage.vi: 'Hội thoại',
      AppLanguage.en: 'Conversations',
    },
    'story_category_kids_stories': {
      AppLanguage.vi: 'Truyện thiếu nhi',
      AppLanguage.en: 'Stories for Kids',
    },
    'story_category_toeic': {
      AppLanguage.vi: 'Luyện TOEIC',
      AppLanguage.en: 'TOEIC Listening',
    },
    'story_category_ielts': {
      AppLanguage.vi: 'Luyện IELTS',
      AppLanguage.en: 'IELTS Listening',
    },
    'story_category_random_videos': {
      AppLanguage.vi: 'Video thực tế',
      AppLanguage.en: 'Random Videos',
    },
    'story_category_news': {AppLanguage.vi: 'Tin tức', AppLanguage.en: 'News'},
    'story_category_ted': {AppLanguage.vi: 'TED', AppLanguage.en: 'TED'},
    'story_category_toefl': {
      AppLanguage.vi: 'Luyện TOEFL',
      AppLanguage.en: 'TOEFL Listening',
    },
    'story_category_medical': {
      AppLanguage.vi: 'Tiếng Anh y tế',
      AppLanguage.en: 'Medical English',
    },
    'story_category_ipa': {
      AppLanguage.vi: 'Phát âm (IPA)',
      AppLanguage.en: 'IPA',
    },
    'story_category_numbers': {
      AppLanguage.vi: 'Luyện nghe số',
      AppLanguage.en: 'Numbers',
    },
    'story_category_spelling_names': {
      AppLanguage.vi: 'Đánh vần tên',
      AppLanguage.en: 'Spelling Names',
    },
    'story_list_title': {
      AppLanguage.vi: 'Luyện nghe',
      AppLanguage.en: 'Listening Practice',
    },
    'story_sleep_mode': {
      AppLanguage.vi: 'Chế độ nghe khi ngủ',
      AppLanguage.en: 'Sleep listening mode',
    },
    'story_sleep_mode_note': {
      AppLanguage.vi: 'Đọc chậm hơn và tự lặp lại liên tục - phù hợp nghe khi thư giãn hoặc trước khi ngủ.',
      AppLanguage.en: 'Slower narration that repeats continuously - good for relaxing or listening before sleep.',
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

    // TOEIC feature (toeic_*_screen.dart) - chi chua text chrome UI (nut
    // bam, nhan, tieu de) - noi dung cau hoi/giai thich la text tieng
    // Anh/Viet viet thang trong toeic_test_data.dart, KHONG qua day.
    'toeic_title': {
      AppLanguage.vi: 'Luyện Thi TOEIC',
      AppLanguage.en: 'TOEIC Practice',
    },
    'toeic_home_subtitle': {
      AppLanguage.vi: 'Đề thi thử đầy đủ 7 phần, mô phỏng thi thật',
      AppLanguage.en: 'Full 7-part mock tests, exam-realistic',
    },
    'toeic_choose_test': {
      AppLanguage.vi: 'Chọn đề thi',
      AppLanguage.en: 'Choose a test',
    },
    'toeic_question_count': {
      AppLanguage.vi: '200 câu · 7 phần',
      AppLanguage.en: '200 questions · 7 parts',
    },
    'toeic_mode_practice': {
      AppLanguage.vi: 'Luyện tập',
      AppLanguage.en: 'Practice',
    },
    'toeic_mode_practice_desc': {
      AppLanguage.vi:
          'Xem đáp án và giải thích ngay sau mỗi câu, không giới hạn giờ',
      AppLanguage.en: 'See the answer and explanation right after each question, no time limit',
    },
    'toeic_mode_exam': {AppLanguage.vi: 'Thi thử', AppLanguage.en: 'Mock exam'},
    'toeic_mode_exam_desc': {
      AppLanguage.vi: 'Đếm giờ Reading 75 phút, chỉ xem điểm sau khi nộp bài',
      AppLanguage.en: 'Timed 75-minute Reading section, see your score only after submitting',
    },
    'toeic_start_button': {AppLanguage.vi: 'Bắt đầu', AppLanguage.en: 'Start'},
    'toeic_history_title': {
      AppLanguage.vi: 'Lịch sử làm bài',
      AppLanguage.en: 'Attempt history',
    },
    'toeic_history_empty': {
      AppLanguage.vi: 'Bạn chưa làm bài thi nào',
      AppLanguage.en: 'You haven\'t taken any tests yet',
    },
    'toeic_part_label': {AppLanguage.vi: 'Phần', AppLanguage.en: 'Part'},
    'toeic_question_label': {AppLanguage.vi: 'Câu', AppLanguage.en: 'Question'},
    'toeic_listening_section_title': {
      AppLanguage.vi: 'Nghe hiểu',
      AppLanguage.en: 'Listening',
    },
    'toeic_reading_section_title': {
      AppLanguage.vi: 'Đọc hiểu',
      AppLanguage.en: 'Reading',
    },
    'toeic_time_remaining': {
      AppLanguage.vi: 'Thời gian còn lại',
      AppLanguage.en: 'Time remaining',
    },
    'toeic_time_elapsed': {
      AppLanguage.vi: 'Thời gian đã trôi qua',
      AppLanguage.en: 'Time elapsed',
    },
    'toeic_exit_confirm_title': {
      AppLanguage.vi: 'Thoát bài thi?',
      AppLanguage.en: 'Exit the test?',
    },
    'toeic_exit_confirm_body': {
      AppLanguage.vi: 'Tiến trình làm bài hiện tại sẽ không được lưu.',
      AppLanguage.en: 'Your current progress will not be saved.',
    },
    'toeic_exit_confirm_stay': {
      AppLanguage.vi: 'Tiếp tục làm bài',
      AppLanguage.en: 'Keep going',
    },
    'toeic_exit_confirm_leave': {
      AppLanguage.vi: 'Thoát',
      AppLanguage.en: 'Exit',
    },
    'toeic_submit_test': {
      AppLanguage.vi: 'Nộp bài',
      AppLanguage.en: 'Submit test',
    },
    'toeic_submit_confirm_title': {
      AppLanguage.vi: 'Nộp bài thi?',
      AppLanguage.en: 'Submit the test?',
    },
    'toeic_submit_confirm_body': {
      AppLanguage.vi: 'Bạn sẽ không thể sửa đáp án sau khi nộp bài.',
      AppLanguage.en:
          'You won\'t be able to change your answers after submitting.',
    },
    'toeic_next_question': {
      AppLanguage.vi: 'Câu tiếp theo',
      AppLanguage.en: 'Next question',
    },
    'toeic_prev_question': {
      AppLanguage.vi: 'Câu trước',
      AppLanguage.en: 'Previous question',
    },
    'toeic_now_playing': {
      AppLanguage.vi: 'Đang phát âm thanh...',
      AppLanguage.en: 'Now playing audio...',
    },
    'toeic_replay_audio': {
      AppLanguage.vi: 'Nghe lại',
      AppLanguage.en: 'Replay',
    },
    'toeic_replay_disabled_note': {
      AppLanguage.vi: 'Chế độ Thi thử: chỉ nghe được 1 lần, giống thi thật',
      AppLanguage.en:
          'Exam mode: audio plays only once, just like the real test',
    },
    'toeic_correct_label': {
      AppLanguage.vi: 'Chính xác!',
      AppLanguage.en: 'Correct!',
    },
    'toeic_incorrect_label': {
      AppLanguage.vi: 'Chưa đúng',
      AppLanguage.en: 'Not quite',
    },
    'toeic_continue_button': {
      AppLanguage.vi: 'Tiếp tục',
      AppLanguage.en: 'Continue',
    },
    'toeic_result_title': {
      AppLanguage.vi: 'Kết quả bài thi',
      AppLanguage.en: 'Test Results',
    },
    'toeic_score_listening': {
      AppLanguage.vi: 'Điểm Nghe',
      AppLanguage.en: 'Listening score',
    },
    'toeic_score_reading': {
      AppLanguage.vi: 'Điểm Đọc',
      AppLanguage.en: 'Reading score',
    },
    'toeic_score_total': {
      AppLanguage.vi: 'Tổng điểm',
      AppLanguage.en: 'Total score',
    },
    'toeic_score_disclaimer': {
      AppLanguage.vi:
          'Điểm quy đổi gần đúng, không phải thang điểm chính thức của ETS.',
      AppLanguage.en:
          'Approximate scaled score, not the official ETS scoring scale.',
    },
    'toeic_review_answers': {
      AppLanguage.vi: 'Xem lại đáp án',
      AppLanguage.en: 'Review answers',
    },
    'toeic_retry_test': {AppLanguage.vi: 'Làm lại', AppLanguage.en: 'Retry'},
    'toeic_view_history': {
      AppLanguage.vi: 'Xem lịch sử',
      AppLanguage.en: 'View history',
    },
    'toeic_your_answer': {
      AppLanguage.vi: 'Bạn chọn',
      AppLanguage.en: 'Your answer',
    },
    'toeic_correct_answer': {
      AppLanguage.vi: 'Đáp án đúng',
      AppLanguage.en: 'Correct answer',
    },
    'toeic_unanswered': {
      AppLanguage.vi: 'Bỏ trống',
      AppLanguage.en: 'Left blank',
    },

    // IELTS feature (ielts_*_screen.dart) - Phase 1 chi Reading + Listening
    // (Writing/Speaking se dung Gemini AI cham diem, lam o phase sau). Chi
    // chua text chrome UI, noi dung cau hoi/bai doc/giai thich la text
    // tieng Anh/Viet viet thang trong ielts_test_data.dart, KHONG qua day.
    'ielts_title': {
      AppLanguage.vi: 'Luyện Thi IELTS',
      AppLanguage.en: 'IELTS Practice',
    },
    'ielts_home_subtitle': {
      AppLanguage.vi: 'Đề thi thử Reading + Listening, mô phỏng thi thật (Writing/Speaking sắp ra mắt)',
      AppLanguage.en: 'Reading + Listening mock tests, exam-realistic (Writing/Speaking coming soon)',
    },
    'ielts_question_count': {
      AppLanguage.vi: '80 câu · Reading + Listening',
      AppLanguage.en: '80 questions · Reading + Listening',
    },
    'ielts_mode_exam_desc': {
      AppLanguage.vi: 'Đếm giờ Reading 60 phút, chỉ xem điểm sau khi nộp bài',
      AppLanguage.en: 'Timed 60-minute Reading section, see your score only after submitting',
    },
    'ielts_score_overall': {
      AppLanguage.vi: 'Band tổng',
      AppLanguage.en: 'Overall band',
    },
    'ielts_score_disclaimer': {
      AppLanguage.vi: 'Band điểm quy đổi gần đúng (thang bậc tự xây dựng), không phải bảng quy đổi chính thức của IELTS/British Council/IDP/Cambridge. Đây là điểm trung bình 2/4 kỹ năng (chưa có Writing/Speaking), không phải overall band thật.',
      AppLanguage.en: 'Approximate band score (a self-built step table), not the official IELTS/British Council/IDP/Cambridge conversion. This averages only 2 of 4 skills (no Writing/Speaking yet), not a real overall band.',
    },
    'ielts_check_answer': {AppLanguage.vi: 'Kiểm tra', AppLanguage.en: 'Check'},

    // Mo ta ngan gon dang lam cua tung Part TOEIC - hien duoi tieu de Part
    // trong toeic_exam_screen.dart (xem ToeicPartNumberX.descriptionKey).
    'toeic_part_1_desc': {
      AppLanguage.vi: 'Nhìn ảnh và chọn câu mô tả đúng nhất',
      AppLanguage.en: 'Look at the photo and choose the best description',
    },
    'toeic_part_2_desc': {
      AppLanguage.vi: 'Nghe câu hỏi và chọn câu trả lời phù hợp nhất',
      AppLanguage.en: 'Listen to the question and choose the best response',
    },
    'toeic_part_3_desc': {
      AppLanguage.vi: 'Nghe đoạn hội thoại và trả lời câu hỏi',
      AppLanguage.en: 'Listen to the conversation and answer the questions',
    },
    'toeic_part_4_desc': {
      AppLanguage.vi: 'Nghe bài nói ngắn và trả lời câu hỏi',
      AppLanguage.en: 'Listen to the short talk and answer the questions',
    },
    'toeic_part_5_desc': {
      AppLanguage.vi: 'Chọn từ/cụm từ đúng để hoàn thành câu',
      AppLanguage.en: 'Choose the correct word/phrase to complete the sentence',
    },
    'toeic_part_6_desc': {
      AppLanguage.vi: 'Chọn từ/câu đúng để hoàn thành đoạn văn',
      AppLanguage.en: 'Choose the correct word/sentence to complete the text',
    },
    'toeic_part_7_desc': {
      AppLanguage.vi: 'Đọc đoạn văn và trả lời câu hỏi',
      AppLanguage.en: 'Read the passage and answer the questions',
    },

    // Mo ta ngan gon cho Reading/Listening cua IELTS - hien duoi tieu de
    // trong ielts_exam_screen.dart.
    'ielts_reading_desc': {
      AppLanguage.vi:
          'Đọc đoạn văn và trả lời câu hỏi (trắc nghiệm hoặc điền từ)',
      AppLanguage.en: 'Read the passage and answer the questions (multiple choice or fill-in)',
    },
    'ielts_listening_1_desc': {
      AppLanguage.vi: 'Nghe hội thoại đời thường và trả lời câu hỏi',
      AppLanguage.en:
          'Listen to an everyday conversation and answer the questions',
    },
    'ielts_listening_2_desc': {
      AppLanguage.vi: 'Nghe bài độc thoại đời thường và trả lời câu hỏi',
      AppLanguage.en:
          'Listen to an everyday monologue and answer the questions',
    },
    'ielts_listening_3_desc': {
      AppLanguage.vi: 'Nghe thảo luận học thuật và trả lời câu hỏi',
      AppLanguage.en:
          'Listen to an academic discussion and answer the questions',
    },
    'ielts_listening_4_desc': {
      AppLanguage.vi: 'Nghe bài giảng học thuật và trả lời câu hỏi',
      AppLanguage.en: 'Listen to an academic lecture and answer the questions',
    },

    // Planner feature (features/planner/) - man "Lap ke hoach" dung chung 3
    // mini-app + menu noi AssistiveTouch, xem docs/research-planner-app-ux.md
    // ===== To do list (features/todo) - tinh nang RIENG, khong dung chung
    // chuoi voi Lap ke hoach (planner_*) du vai nhan trung nghia.
    'todo_title': {AppLanguage.vi: 'To do list', AppLanguage.en: 'To do list'},
    'todo_today': {AppLanguage.vi: 'HÔM NAY', AppLanguage.en: 'TODAY'},
    'todo_tasks': {AppLanguage.vi: 'CÔNG VIỆC', AppLanguage.en: 'TASKS'},
    'todo_progress': {
      AppLanguage.vi: 'TIẾN ĐỘ HÔM NAY',
      AppLanguage.en: "TODAY'S PROGRESS",
    },
    'todo_this_week': {AppLanguage.vi: 'TUẦN NÀY', AppLanguage.en: 'THIS WEEK'},
    'todo_empty': {
      AppLanguage.vi: 'Chưa có việc nào. Bấm + để thêm.',
      AppLanguage.en: 'No tasks yet. Tap + to add one.',
    },
    'todo_status_completed': {
      AppLanguage.vi: 'Đã hoàn thành',
      AppLanguage.en: 'Completed',
    },
    'todo_status_incomplete': {
      AppLanguage.vi: 'Chưa hoàn thành',
      AppLanguage.en: 'Incomplete',
    },
    'todo_status_overdue': {
      AppLanguage.vi: 'Quá hạn',
      AppLanguage.en: 'Overdue',
    },
    'todo_status_carried': {
      AppLanguage.vi: 'Chuyển từ hôm qua',
      AppLanguage.en: 'Carried from yesterday',
    },
    'todo_completed_n': {
      AppLanguage.vi: 'hoàn thành',
      AppLanguage.en: 'completed',
    },
    'todo_remaining_n': {
      AppLanguage.vi: 'còn lại',
      AppLanguage.en: 'remaining',
    },
    'todo_overdue_n': {AppLanguage.vi: 'quá hạn', AppLanguage.en: 'overdue'},
    'todo_of_completed': {
      AppLanguage.vi: 'trên tổng số việc',
      AppLanguage.en: 'of tasks done',
    },
    'todo_new_task': {AppLanguage.vi: 'VIỆC MỚI', AppLanguage.en: 'NEW TASK'},
    'todo_edit_task': {AppLanguage.vi: 'SỬA VIỆC', AppLanguage.en: 'EDIT TASK'},
    'todo_title_hint': {
      AppLanguage.vi: 'Cần làm gì?',
      AppLanguage.en: 'What needs to be done?',
    },
    'todo_date': {AppLanguage.vi: 'Ngày', AppLanguage.en: 'Date'},
    'todo_time': {AppLanguage.vi: 'Giờ', AppLanguage.en: 'Time'},
    'todo_create': {AppLanguage.vi: 'Tạo việc', AppLanguage.en: 'Create'},
    'todo_delete': {AppLanguage.vi: 'Xoá việc', AppLanguage.en: 'Delete'},
    'planner_title': {
      AppLanguage.vi: 'Lập kế hoạch',
      AppLanguage.en: 'Planner',
    },
    'planner_add_task': {
      AppLanguage.vi: 'Thêm việc',
      AppLanguage.en: 'Add task',
    },
    'planner_today': {AppLanguage.vi: 'Hôm nay', AppLanguage.en: 'Today'},
    'planner_view_week': {
      AppLanguage.vi: 'Xem tuần',
      AppLanguage.en: 'View week',
    },
    'planner_filter_apps': {
      AppLanguage.vi: 'Lọc mini-app',
      AppLanguage.en: 'Filter mini-apps',
    },
    'planner_status_completed': {
      AppLanguage.vi: 'Hoàn thành',
      AppLanguage.en: 'Completed',
    },
    'planner_status_running': {
      AppLanguage.vi: 'Đang chạy',
      AppLanguage.en: 'Running',
    },
    'planner_status_rejected': {
      AppLanguage.vi: 'Từ chối',
      AppLanguage.en: 'Rejected',
    },
    'planner_status_upcoming': {
      AppLanguage.vi: 'Sắp tới',
      AppLanguage.en: 'Upcoming',
    },
    'planner_task_icon_label': {
      AppLanguage.vi: 'Loại việc',
      AppLanguage.en: 'Task type',
    },
    'planner_task_icon_none': {
      AppLanguage.vi: 'Mặc định',
      AppLanguage.en: 'Default',
    },
    'planner_task_icon_work': {
      AppLanguage.vi: 'Công việc',
      AppLanguage.en: 'Work',
    },
    'planner_task_icon_game': {AppLanguage.vi: 'Game', AppLanguage.en: 'Game'},
    'planner_task_icon_relax': {
      AppLanguage.vi: 'Thư giãn',
      AppLanguage.en: 'Relax',
    },
    'planner_task_icon_study': {
      AppLanguage.vi: 'Học tập',
      AppLanguage.en: 'Study',
    },
    'planner_task_icon_sleep': {AppLanguage.vi: 'Ngủ', AppLanguage.en: 'Sleep'},
    'planner_task_icon_other': {
      AppLanguage.vi: 'Khác',
      AppLanguage.en: 'Other',
    },
    'planner_more_tasks': {AppLanguage.vi: 'việc khác', AppLanguage.en: 'more'},
    'planner_empty_day': {
      AppLanguage.vi: 'Chưa có việc nào trong ngày này',
      AppLanguage.en: 'No tasks for this day yet',
    },
    'planner_task_title_hint': {
      AppLanguage.vi: 'Tên việc cần làm',
      AppLanguage.en: 'Task name',
    },
    'planner_start_time': {
      AppLanguage.vi: 'Giờ bắt đầu',
      AppLanguage.en: 'Start time',
    },
    'planner_end_time': {
      AppLanguage.vi: 'Giờ kết thúc',
      AppLanguage.en: 'End time',
    },
    'planner_reminder_toggle': {
      AppLanguage.vi: 'Nhắc nhở khi đến giờ',
      AppLanguage.en: 'Remind me at start time',
    },
    'planner_save': {AppLanguage.vi: 'Lưu', AppLanguage.en: 'Save'},
    'planner_delete': {
      AppLanguage.vi: 'Xoá việc',
      AppLanguage.en: 'Delete task',
    },
    'planner_edit_title': {
      AppLanguage.vi: 'Sửa việc',
      AppLanguage.en: 'Edit task',
    },
    'planner_add_title': {
      AppLanguage.vi: 'Việc mới',
      AppLanguage.en: 'New task',
    },
    'planner_settings_title': {
      AppLanguage.vi: 'Cài đặt nhắc nhở',
      AppLanguage.en: 'Reminder settings',
    },
    'planner_settings_subtitle': {
      AppLanguage.vi: 'Áp dụng cho mọi việc có bật nhắc nhở',
      AppLanguage.en: 'Applies to every task with reminders on',
    },
    'planner_ringtone_label': {
      AppLanguage.vi: 'Loại chuông',
      AppLanguage.en: 'Ringtone',
    },
    'planner_ringtone_default': {
      AppLanguage.vi: 'Mặc định (Chuông dịu)',
      AppLanguage.en: 'Default (Soft chime)',
    },
    'planner_ringtone_cheerful': {
      AppLanguage.vi: 'Giai điệu vui',
      AppLanguage.en: 'Cheerful tone',
    },
    'planner_preview_mode_off': {
      AppLanguage.vi: 'Kiểu nhắc đang "Tắt cả hai" - đổi kiểu nhắc để nghe thử',
      AppLanguage.en: 'Alert style is "Both off" - change it to preview',
    },
    'planner_lead_time_label': {
      AppLanguage.vi: 'Nhắc trước',
      AppLanguage.en: 'Remind before',
    },
    'planner_lead_on_time': {
      AppLanguage.vi: 'Đúng giờ',
      AppLanguage.en: 'On time',
    },
    'planner_lead_5': {
      AppLanguage.vi: 'Trước 5 phút',
      AppLanguage.en: '5 min before',
    },
    'planner_lead_15': {
      AppLanguage.vi: 'Trước 15 phút',
      AppLanguage.en: '15 min before',
    },
    'planner_lead_30': {
      AppLanguage.vi: 'Trước 30 phút',
      AppLanguage.en: '30 min before',
    },
    'planner_lead_60': {
      AppLanguage.vi: 'Trước 1 giờ',
      AppLanguage.en: '1 hour before',
    },
    'planner_mode_label': {
      AppLanguage.vi: 'Kiểu nhắc',
      AppLanguage.en: 'Alert style',
    },
    'planner_mode_both': {
      AppLanguage.vi: 'Rung + Chuông',
      AppLanguage.en: 'Vibrate + Sound',
    },
    'planner_mode_vibrate': {
      AppLanguage.vi: 'Chỉ rung',
      AppLanguage.en: 'Vibrate only',
    },
    'planner_mode_sound': {
      AppLanguage.vi: 'Chỉ chuông',
      AppLanguage.en: 'Sound only',
    },
    'planner_mode_off': {
      AppLanguage.vi: 'Tắt cả hai',
      AppLanguage.en: 'Both off',
    },
    'planner_filter_sheet_title': {
      AppLanguage.vi: 'Lọc theo mini-app',
      AppLanguage.en: 'Filter by mini-app',
    },
    'planner_filter_all': {AppLanguage.vi: 'Tất cả', AppLanguage.en: 'All'},
    'planner_app_english': {
      AppLanguage.vi: 'Học tiếng Anh',
      AppLanguage.en: 'Learn English',
    },
    'planner_app_fitness': {
      AppLanguage.vi: 'Fitness',
      AppLanguage.en: 'Fitness',
    },
    'planner_app_wealth': {
      AppLanguage.vi: 'Quản lý tài sản',
      AppLanguage.en: 'Wealth',
    },

    // Planner v2 - timeline 3 cot, lap lai, Inbox, xu ly qua han, chuong bao
    // thuc cua may (docs/research-planner-app-ux.md §7).
    'planner_status_overdue': {
      AppLanguage.vi: 'Quá hạn',
      AppLanguage.en: 'Overdue',
    },
    'planner_reminder_web_notice': {
      AppLanguage.vi: 'Bản web chưa gửi được nhắc nhở. Hãy dùng app Android để nhận thông báo đúng giờ.',
      AppLanguage.en: 'Reminders are not available on the web version. Use the Android app to get notified on time.',
    },
    'planner_alarm_sound_label': {
      AppLanguage.vi: 'CHUÔNG BÁO THỨC (CÓ SẴN TRÊN MÁY)',
      AppLanguage.en: 'ALARM SOUND (FROM THIS DEVICE)',
    },
    'planner_alarm_sound_android_only': {
      AppLanguage.vi: 'Danh sách chuông báo thức chỉ có trên app Android.',
      AppLanguage.en:
          'The device alarm list is only available in the Android app.',
    },
    'planner_alarm_sound_empty': {
      AppLanguage.vi: 'Không đọc được chuông báo thức trên máy này.',
      AppLanguage.en: 'Could not read alarm sounds on this device.',
    },
    'planner_alarm_sound_device_default': {
      AppLanguage.vi: 'Chuông báo thức mặc định của máy',
      AppLanguage.en: 'Device default alarm',
    },
    'planner_test_notification': {
      AppLanguage.vi: 'Thử thông báo',
      AppLanguage.en: 'Test notification',
    },
    'planner_undo': {AppLanguage.vi: 'Hoàn tác', AppLanguage.en: 'Undo'},
    'planner_done_toast': {
      AppLanguage.vi: 'Đã hoàn thành',
      AppLanguage.en: 'Marked as done',
    },
    'planner_undone_toast': {
      AppLanguage.vi: 'Đã bỏ đánh dấu hoàn thành',
      AppLanguage.en: 'Marked as not done',
    },
    'planner_deleted_toast': {
      AppLanguage.vi: 'Đã xoá việc',
      AppLanguage.en: 'Task deleted',
    },
    'planner_moved_toast': {
      AppLanguage.vi: 'Đã đổi giờ',
      AppLanguage.en: 'Task moved',
    },
    'planner_inbox_toast': {
      AppLanguage.vi: 'Đã chuyển vào Chưa xếp giờ',
      AppLanguage.en: 'Moved to Unscheduled',
    },
    'planner_postponed_toast': {
      AppLanguage.vi: 'Đã dời sang hôm sau',
      AppLanguage.en: 'Moved to the next day',
    },
    'planner_skipped_toast': {
      AppLanguage.vi: 'Đã bỏ qua',
      AppLanguage.en: 'Skipped',
    },
    'planner_scheduled_toast': {
      AppLanguage.vi: 'Đã xếp vào lịch',
      AppLanguage.en: 'Scheduled',
    },
    'planner_inbox_title': {
      AppLanguage.vi: 'Chưa xếp giờ',
      AppLanguage.en: 'Unscheduled',
    },
    'planner_inbox_hint': {
      AppLanguage.vi: 'Nhấn giữ rồi kéo vào timeline',
      AppLanguage.en: 'Long-press and drag onto the timeline',
    },
    'planner_overdue_banner': {
      AppLanguage.vi: '{n} việc ở các ngày trước chưa xong',
      AppLanguage.en: '{n} unfinished tasks from previous days',
    },
    'planner_overdue_title': {
      AppLanguage.vi: 'Việc chưa xong',
      AppLanguage.en: 'Unfinished tasks',
    },
    'planner_overdue_subtitle': {
      AppLanguage.vi: 'Chọn cách xử lý từng việc',
      AppLanguage.en: 'Choose what to do with each task',
    },
    'planner_overdue_empty': {
      AppLanguage.vi: 'Đã xử lý hết!',
      AppLanguage.en: 'All caught up!',
    },
    'planner_action_done': {AppLanguage.vi: 'Xong', AppLanguage.en: 'Done'},
    'planner_action_today': {
      AppLanguage.vi: 'Làm hôm nay',
      AppLanguage.en: 'Do today',
    },
    'planner_action_inbox': {
      AppLanguage.vi: 'Chưa xếp giờ',
      AppLanguage.en: 'Unschedule',
    },
    'planner_action_skip': {AppLanguage.vi: 'Bỏ qua', AppLanguage.en: 'Skip'},
    'planner_date': {AppLanguage.vi: 'Ngày', AppLanguage.en: 'Date'},
    'planner_repeat_label': {
      AppLanguage.vi: 'Lặp lại',
      AppLanguage.en: 'Repeat',
    },
    'planner_repeat_none': {AppLanguage.vi: 'Không', AppLanguage.en: 'Never'},
    'planner_repeat_daily': {
      AppLanguage.vi: 'Hằng ngày',
      AppLanguage.en: 'Daily',
    },
    'planner_repeat_weekly': {
      AppLanguage.vi: 'Theo thứ',
      AppLanguage.en: 'Weekly',
    },
    'planner_repeat_monthly': {
      AppLanguage.vi: 'Hằng tháng',
      AppLanguage.en: 'Monthly',
    },
    'planner_repeat_until': {
      AppLanguage.vi: 'Đến ngày',
      AppLanguage.en: 'Until',
    },
    'planner_repeat_forever': {
      AppLanguage.vi: 'Không kết thúc',
      AppLanguage.en: 'Forever',
    },
    'planner_notes_hint': {
      AppLanguage.vi: 'Ghi chú (không bắt buộc)',
      AppLanguage.en: 'Notes (optional)',
    },
    'planner_reminder_offset_label': {
      AppLanguage.vi: 'Nhắc trước',
      AppLanguage.en: 'Remind me',
    },
    'planner_reminder_follow_settings': {
      AppLanguage.vi: 'Theo cài đặt',
      AppLanguage.en: 'Default',
    },
    'planner_offset_on_time': {
      AppLanguage.vi: 'Đúng giờ',
      AppLanguage.en: 'On time',
    },
    'planner_offset_minutes': {
      AppLanguage.vi: '{n} phút',
      AppLanguage.en: '{n} min',
    },
    'planner_offset_hour': {AppLanguage.vi: '1 giờ', AppLanguage.en: '1 hour'},
    'planner_offset_day': {AppLanguage.vi: '1 ngày', AppLanguage.en: '1 day'},
    'planner_save_to_inbox': {
      AppLanguage.vi: 'Chưa chọn giờ (lưu vào Chưa xếp giờ)',
      AppLanguage.en: 'No time yet (save to Unscheduled)',
    },
    'planner_duplicate': {
      AppLanguage.vi: 'Nhân bản',
      AppLanguage.en: 'Duplicate',
    },
    'planner_delete_recurring_title': {
      AppLanguage.vi: 'Xoá việc lặp lại',
      AppLanguage.en: 'Delete repeating task',
    },
    'planner_delete_this': {
      AppLanguage.vi: 'Chỉ lần này',
      AppLanguage.en: 'This one only',
    },
    'planner_delete_all': {
      AppLanguage.vi: 'Tất cả các lần',
      AppLanguage.en: 'All occurrences',
    },
    'planner_cancel': {AppLanguage.vi: 'Huỷ', AppLanguage.en: 'Cancel'},
    'planner_edit_series_note': {
      AppLanguage.vi: 'Thay đổi sẽ áp dụng cho mọi lần lặp. Trạng thái bên dưới chỉ áp dụng cho ngày {d}.',
      AppLanguage.en: 'Changes apply to every occurrence. The status below only applies to {d}.',
    },
    'planner_overnight_hint': {
      AppLanguage.vi: 'Kết thúc vào hôm sau',
      AppLanguage.en: 'Ends the next day',
    },
    'planner_open_source': {AppLanguage.vi: 'Mở', AppLanguage.en: 'Open'},
    'planner_add_to_plan': {
      AppLanguage.vi: 'Thêm vào kế hoạch',
      AppLanguage.en: 'Add to planner',
    },
    'planner_added_to_plan': {
      AppLanguage.vi: 'Đã thêm vào Lập kế hoạch',
      AppLanguage.en: 'Added to Planner',
    },
    'planner_src_vocab_title': {
      AppLanguage.vi: 'Ôn từ vựng hôm nay',
      AppLanguage.en: "Review today's words",
    },
    'planner_src_workout_title': {
      AppLanguage.vi: 'Tập: {name}',
      AppLanguage.en: 'Workout: {name}',
    },
    'planner_src_renew_title': {
      AppLanguage.vi: 'Gia hạn: {name}',
      AppLanguage.en: 'Renew: {name}',
    },
    'planner_status_label': {
      AppLanguage.vi: 'Trạng thái',
      AppLanguage.en: 'Status',
    },
    'planner_duplicated_toast': {
      AppLanguage.vi: 'Đã nhân bản việc',
      AppLanguage.en: 'Task duplicated',
    },
    'planner_in_plan': {
      AppLanguage.vi: 'Đã có trong kế hoạch ✓',
      AppLanguage.en: 'In your planner ✓',
    },
    'planner_checklist_label': {
      AppLanguage.vi: 'Checklist',
      AppLanguage.en: 'Checklist',
    },
    'planner_checklist_hint': {
      AppLanguage.vi: 'Thêm bước nhỏ…',
      AppLanguage.en: 'Add a step…',
    },
    'planner_status_auto': {AppLanguage.vi: 'Tự động', AppLanguage.en: 'Auto'},

    // Fitness - Trang chu thiet ke lai (xem docs/design/fitness-redesign/).
    'fitness_hero_kicker': {
      AppLanguage.vi: 'Hành trình sức khỏe',
      AppLanguage.en: 'Your health journey',
    },
    'fitness_hero_title': {
      AppLanguage.vi: 'Kỷ luật hôm nay\nlà kết quả ngày mai',
      AppLanguage.en: "Today's discipline\nis tomorrow's result",
    },
    'fitness_hero_subtitle': {
      AppLanguage.vi: 'Tập luyện – Ăn uống – Nghỉ ngơi\nvà tiến bộ mỗi ngày.',
      AppLanguage.en: 'Train – Eat – Rest\nand improve every day.',
    },
    'fitness_hero_cta': {
      AppLanguage.vi: 'Bắt đầu tập',
      AppLanguage.en: 'Start training',
    },
    'fitness_see_all': {
      AppLanguage.vi: 'Xem tất cả',
      AppLanguage.en: 'See all',
    },
    'fitness_place_gym': {AppLanguage.vi: 'Phòng gym', AppLanguage.en: 'Gym'},
    'fitness_place_home': {
      AppLanguage.vi: 'Tại nhà',
      AppLanguage.en: 'At home',
    },
    'fitness_sessions_per_week': {
      AppLanguage.vi: '{n} buổi/tuần',
      AppLanguage.en: '{n} sessions/week',
    },
    'fitness_level_beginner': {
      AppLanguage.vi: 'Mới bắt đầu',
      AppLanguage.en: 'Beginner',
    },
    'fitness_level_intermediate': {
      AppLanguage.vi: 'Trung cấp',
      AppLanguage.en: 'Intermediate',
    },
    'fitness_level_advanced': {
      AppLanguage.vi: 'Nâng cao',
      AppLanguage.en: 'Advanced',
    },
    'fitness_level_all': {
      AppLanguage.vi: 'Mọi trình độ',
      AppLanguage.en: 'All levels',
    },
    'fitness_quick_actions_title': {
      AppLanguage.vi: 'Tiện ích nhanh',
      AppLanguage.en: 'Quick actions',
    },
    'fitness_quote_default': {
      AppLanguage.vi:
          'Không có giới hạn nào ngoài những giới hạn bạn tự đặt ra.',
      AppLanguage.en: 'There are no limits but the ones you set yourself.',
    },

    // Fitness - 4 the chi so o Trang chu.
    'fitness_stat_calories': {
      AppLanguage.vi: 'Calo nạp vào',
      AppLanguage.en: 'Calories in',
    },
    'fitness_stat_sessions': {
      AppLanguage.vi: 'Buổi tập',
      AppLanguage.en: 'Workouts',
    },
    'fitness_stat_volume': {
      AppLanguage.vi: 'Tổng khối lượng',
      AppLanguage.en: 'Total volume',
    },
    'fitness_stat_volume_unit': {AppLanguage.vi: 'tấn', AppLanguage.en: 't'},
    'fitness_stat_heart_rate': {
      AppLanguage.vi: 'Nhịp tim',
      AppLanguage.en: 'Heart rate',
    },

    // Fitness - the "Ke hoach hom nay".
    'fitness_today_caption': {
      AppLanguage.vi: 'Kế hoạch hôm nay',
      AppLanguage.en: "Today's plan",
    },
    'fitness_today_no_program': {
      AppLanguage.vi: 'Chưa chọn giáo án',
      AppLanguage.en: 'No program yet',
    },
    'fitness_today_rest_day': {
      AppLanguage.vi: 'Hôm nay là ngày nghỉ',
      AppLanguage.en: 'Rest day today',
    },
    'fitness_today_exercise_count': {
      AppLanguage.vi: '{n} bài tập',
      AppLanguage.en: '{n} exercises',
    },
    'fitness_today_set_count': {
      AppLanguage.vi: '{n} hiệp',
      AppLanguage.en: '{n} sets',
    },

    // Fitness - man Thong ke.
    'fitness_stats_title': {
      AppLanguage.vi: 'Thống kê',
      AppLanguage.en: 'Statistics',
    },
    'fitness_stats_range_week': {
      AppLanguage.vi: '7 ngày',
      AppLanguage.en: '7 days',
    },
    'fitness_stats_range_month': {
      AppLanguage.vi: '30 ngày',
      AppLanguage.en: '30 days',
    },
    'fitness_stats_range_quarter': {
      AppLanguage.vi: '3 tháng',
      AppLanguage.en: '3 months',
    },
    'fitness_stats_range_year': {
      AppLanguage.vi: '1 năm',
      AppLanguage.en: '1 year',
    },
    'fitness_stats_sessions': {
      AppLanguage.vi: 'Buổi tập',
      AppLanguage.en: 'Workouts',
    },
    'fitness_stats_duration': {
      AppLanguage.vi: 'Thời lượng',
      AppLanguage.en: 'Duration',
    },
    'fitness_stats_volume': {
      AppLanguage.vi: 'Khối lượng',
      AppLanguage.en: 'Volume',
    },
    'fitness_stats_volume_chart': {
      AppLanguage.vi: 'Khối lượng theo thời gian',
      AppLanguage.en: 'Volume over time',
    },
    'fitness_stats_sessions_chart': {
      AppLanguage.vi: 'Số buổi tập',
      AppLanguage.en: 'Workout count',
    },
    'fitness_stats_empty': {
      AppLanguage.vi: 'Chưa có buổi tập nào trong khoảng này.\nHoàn thành 1 buổi để thấy biểu đồ.',
      AppLanguage.en:
          'No workouts in this range yet.\nFinish one to see the chart.',
    },
    'fitness_stats_error': {
      AppLanguage.vi: 'Không tải được số liệu tập luyện.',
      AppLanguage.en: 'Could not load your training data.',
    },

    // Fitness - man Nhip tim (do bang camera, xem heart_rate_service.dart).
    'fitness_heart_rate_title': {
      AppLanguage.vi: 'Sức khỏe',
      AppLanguage.en: 'Health',
    },
    'fitness_heart_rate_intro': {
      AppLanguage.vi: 'Đo nhịp tim bằng camera',
      AppLanguage.en: 'Measure heart rate with the camera',
    },
    'fitness_heart_rate_step_1': {
      AppLanguage.vi: 'Đặt ngón tay lên camera sau.',
      AppLanguage.en: 'Place a fingertip on the rear camera.',
    },
    'fitness_heart_rate_step_2': {
      AppLanguage.vi: 'Che kín cả ống kính và đèn flash.',
      AppLanguage.en: 'Cover both the lens and the flash.',
    },
    'fitness_heart_rate_step_3': {
      AppLanguage.vi: 'Giữ yên tay trong suốt 30 giây đo.',
      AppLanguage.en: 'Hold still for the full 30 seconds.',
    },
    'fitness_heart_rate_disclaimer': {
      AppLanguage.vi:
          'Kết quả chỉ để tham khảo khi tập, không phải thiết bị y tế.',
      AppLanguage.en: 'For training reference only, not a medical device.',
    },
    'fitness_heart_rate_start': {
      AppLanguage.vi: 'Bắt đầu đo',
      AppLanguage.en: 'Start measuring',
    },
    'fitness_heart_rate_cancel': {
      AppLanguage.vi: 'Dừng',
      AppLanguage.en: 'Stop',
    },
    'fitness_heart_rate_measuring': {
      AppLanguage.vi: 'Đang đo... giữ yên tay',
      AppLanguage.en: 'Measuring... hold still',
    },
    'fitness_heart_rate_cover_lens': {
      AppLanguage.vi: 'Hãy che kín camera và đèn flash',
      AppLanguage.en: 'Cover the camera and the flash',
    },
    'fitness_heart_rate_seconds_left': {
      AppLanguage.vi: 'còn {n} giây',
      AppLanguage.en: '{n}s left',
    },
    'fitness_heart_rate_result_title': {
      AppLanguage.vi: 'Nhịp tim của bạn',
      AppLanguage.en: 'Your heart rate',
    },
    'fitness_heart_rate_measured_at': {
      AppLanguage.vi: 'Đo lúc {t}',
      AppLanguage.en: 'Measured at {t}',
    },
    'fitness_heart_rate_remeasure': {
      AppLanguage.vi: 'Đo lại',
      AppLanguage.en: 'Measure again',
    },
    'fitness_heart_rate_error_title': {
      AppLanguage.vi: 'Không đo được nhịp tim',
      AppLanguage.en: 'Could not measure your heart rate',
    },
    'fitness_heart_rate_error_noisy': {
      AppLanguage.vi: 'Tín hiệu quá nhiễu. Hãy che kín ống kính, giữ tay thật yên rồi đo lại.',
      AppLanguage.en: 'The signal was too noisy. Cover the lens fully, hold still and try again.',
    },
    'fitness_heart_rate_error_camera': {
      AppLanguage.vi: 'Không mở được camera. Kiểm tra quyền truy cập camera của app rồi thử lại.',
      AppLanguage.en: 'Could not open the camera. Check the camera permission and try again.',
    },
    'fitness_heart_rate_error_range': {
      AppLanguage.vi: 'Kết quả nằm ngoài khoảng nhịp tim thông thường nên không hiển thị. Hãy đo lại khi đã nghỉ ngơi.',
      AppLanguage.en: 'The result fell outside the usual range, so it is not shown. Rest a moment and measure again.',
    },
    'fitness_heart_rate_retry': {
      AppLanguage.vi: 'Đo lại',
      AppLanguage.en: 'Try again',
    },
    'fitness_heart_rate_today': {
      AppLanguage.vi: 'Hôm nay',
      AppLanguage.en: 'Today',
    },
    'fitness_heart_rate_empty': {
      AppLanguage.vi: 'Hôm nay bạn chưa đo lần nào.',
      AppLanguage.en: 'No measurements today yet.',
    },

    // Fitness - man Giac ngu.
    'fitness_sleep_title': {
      AppLanguage.vi: 'Giấc ngủ',
      AppLanguage.en: 'Sleep',
    },
    'fitness_sleep_last_night': {
      AppLanguage.vi: 'Đêm gần nhất',
      AppLanguage.en: 'Last night',
    },
    'fitness_sleep_log': {
      AppLanguage.vi: 'Ghi giấc ngủ',
      AppLanguage.en: 'Log sleep',
    },
    'fitness_sleep_pick_bed': {
      AppLanguage.vi: 'Mấy giờ bạn đi ngủ?',
      AppLanguage.en: 'What time did you go to bed?',
    },
    'fitness_sleep_pick_wake': {
      AppLanguage.vi: 'Mấy giờ bạn thức dậy?',
      AppLanguage.en: 'What time did you wake up?',
    },
    'fitness_sleep_week': {
      AppLanguage.vi: '7 ngày gần nhất',
      AppLanguage.en: 'Last 7 days',
    },
    'fitness_sleep_history': {
      AppLanguage.vi: 'Lịch sử',
      AppLanguage.en: 'History',
    },
    'fitness_sleep_empty': {
      AppLanguage.vi: 'Chưa có giấc ngủ nào được ghi.',
      AppLanguage.en: 'No sleep logged yet.',
    },

    'football_title': {
      AppLanguage.vi: 'Football Center',
      AppLanguage.en: 'Football Center',
    },
    'football_live_now': {
      AppLanguage.vi: 'Đang thi đấu',
      AppLanguage.en: 'Live now',
    },
    'football_no_live': {
      AppLanguage.vi: 'Hiện không có trận nào đang diễn ra.',
      AppLanguage.en: 'No matches in play right now.',
    },
    'football_competitions': {
      AppLanguage.vi: 'Giải đấu',
      AppLanguage.en: 'Competitions',
    },
    'football_see_all': {
      AppLanguage.vi: 'Xem tất cả',
      AppLanguage.en: 'See all',
    },
    'football_today_matches': {
      AppLanguage.vi: 'Trận hôm nay',
      AppLanguage.en: 'Today’s matches',
    },
    'football_no_match_today': {
      AppLanguage.vi: 'Hôm nay không có trận nào ở các giải đang theo dõi.',
      AppLanguage.en: 'No matches today in the leagues you follow.',
    },
    'football_standings': {
      AppLanguage.vi: 'Bảng xếp hạng',
      AppLanguage.en: 'Standings',
    },
    'football_no_standings': {
      AppLanguage.vi: 'Chưa có bảng xếp hạng cho giải này.',
      AppLanguage.en: 'No standings for this competition yet.',
    },
    'football_pick_competition': {
      AppLanguage.vi: 'Chọn một giải đấu để xem bảng xếp hạng.',
      AppLanguage.en: 'Pick a competition to see its table.',
    },
    'football_recent_form': {
      AppLanguage.vi: '5 trận gần nhất',
      AppLanguage.en: 'Last 5 matches',
    },
    'football_load_error': {
      AppLanguage.vi:
          'Không tải được dữ liệu. Kiểm tra kết nối mạng rồi thử lại.',
      AppLanguage.en:
          'Could not load data. Check your connection and try again.',
    },
    'football_no_data_yet': {
      AppLanguage.vi: 'Dữ liệu đang được đồng bộ, quay lại sau ít phút.',
      AppLanguage.en: 'Data is still syncing, check back in a few minutes.',
    },
    'football_last_updated': {
      AppLanguage.vi: 'Cập nhật lúc {time}',
      AppLanguage.en: 'Updated at {time}',
    },
    'football_finished_short': {
      AppLanguage.vi: 'Kết thúc',
      AppLanguage.en: 'FT',
    },
    'football_postponed_short': {
      AppLanguage.vi: 'Hoãn',
      AppLanguage.en: 'PSTP',
    },
    'football_col_team': {AppLanguage.vi: 'Đội', AppLanguage.en: 'Team'},
    'football_col_played': {AppLanguage.vi: 'ST', AppLanguage.en: 'P'},
    'football_col_win': {AppLanguage.vi: 'T', AppLanguage.en: 'W'},
    'football_col_draw': {AppLanguage.vi: 'H', AppLanguage.en: 'D'},
    'football_col_loss': {AppLanguage.vi: 'B', AppLanguage.en: 'L'},
    'football_col_diff': {AppLanguage.vi: 'HS', AppLanguage.en: 'GD'},
    'football_col_points': {AppLanguage.vi: 'Đ', AppLanguage.en: 'Pts'},
    'football_favorites': {
      AppLanguage.vi: 'Đội yêu thích',
      AppLanguage.en: 'Favorite teams',
    },
    'football_manage': {AppLanguage.vi: 'Quản lý', AppLanguage.en: 'Manage'},
    'football_add_favorite_hint': {
      AppLanguage.vi: 'Chọn đội yêu thích để nhận thông báo trận đấu',
      AppLanguage.en: 'Pick favorite teams to get match alerts',
    },
    'football_search_team': {
      AppLanguage.vi: 'Tìm đội bóng...',
      AppLanguage.en: 'Search teams...',
    },
    'football_your_teams': {
      AppLanguage.vi: 'Đội của bạn',
      AppLanguage.en: 'Your teams',
    },
    'football_all_teams': {
      AppLanguage.vi: 'Tất cả đội',
      AppLanguage.en: 'All teams',
    },
    'football_search_results': {
      AppLanguage.vi: 'Kết quả tìm kiếm',
      AppLanguage.en: 'Search results',
    },
    'football_no_team_found': {
      AppLanguage.vi: 'Không tìm thấy đội nào khớp.',
      AppLanguage.en: 'No teams match that search.',
    },
    'football_no_team_fixtures': {
      AppLanguage.vi: 'Chưa có trận nào của đội này trong dữ liệu đã đồng bộ.',
      AppLanguage.en: 'No matches for this team in the synced data yet.',
    },
    'football_filter_all': {AppLanguage.vi: 'Tất cả', AppLanguage.en: 'All'},
    'football_upcoming': {
      AppLanguage.vi: 'Sắp diễn ra',
      AppLanguage.en: 'Upcoming',
    },
    'football_results': {AppLanguage.vi: 'Kết quả', AppLanguage.en: 'Results'},
    'football_match_center': {
      AppLanguage.vi: 'Chi tiết trận đấu',
      AppLanguage.en: 'Match Center',
    },
    'football_tab_overview': {
      AppLanguage.vi: 'Tổng quan',
      AppLanguage.en: 'Overview',
    },
    'football_tab_events': {
      AppLanguage.vi: 'Sự kiện',
      AppLanguage.en: 'Events',
    },
    'football_tab_stats': {AppLanguage.vi: 'Thống kê', AppLanguage.en: 'Stats'},
    'football_tab_lineup': {
      AppLanguage.vi: 'Đội hình',
      AppLanguage.en: 'Lineup',
    },
    'football_no_events': {
      AppLanguage.vi: 'Chưa có sự kiện nào trong trận này.',
      AppLanguage.en: 'No events in this match yet.',
    },
    'football_no_stats': {
      AppLanguage.vi: 'Chưa có thống kê cho trận này.',
      AppLanguage.en: 'No stats for this match yet.',
    },
    'football_lineup_not_ready': {
      AppLanguage.vi: 'Đội hình chưa được công bố.',
      AppLanguage.en: 'Lineup has not been announced yet.',
    },
    'football_substitutes': {
      AppLanguage.vi: 'Dự bị',
      AppLanguage.en: 'Substitutes',
    },
    'football_notifications': {
      AppLanguage.vi: 'Thông báo',
      AppLanguage.en: 'Notifications',
    },
    'football_notifications_hint': {
      AppLanguage.vi: 'Chọn loại thông báo bạn muốn nhận cho đội yêu thích. Tắt mục nào thì hệ thống bỏ qua mục đó.',
      AppLanguage.en: 'Choose which alerts you want for your favorite teams. Anything you turn off is skipped.',
    },
    'football_notif_group_inplay': {
      AppLanguage.vi: 'Trong trận',
      AppLanguage.en: 'In play',
    },
    'football_notif_group_milestones': {
      AppLanguage.vi: 'Mốc trận đấu',
      AppLanguage.en: 'Match milestones',
    },
    'football_notif_group_prematch': {
      AppLanguage.vi: 'Trước trận',
      AppLanguage.en: 'Before kick-off',
    },
    'football_notif_goal': {
      AppLanguage.vi: 'Bàn thắng',
      AppLanguage.en: 'Goals',
    },
    'football_notif_yellow': {
      AppLanguage.vi: 'Thẻ vàng',
      AppLanguage.en: 'Yellow cards',
    },
    'football_notif_red': {
      AppLanguage.vi: 'Thẻ đỏ',
      AppLanguage.en: 'Red cards',
    },
    'football_notif_subst': {
      AppLanguage.vi: 'Thay người',
      AppLanguage.en: 'Substitutions',
    },
    'football_notif_start': {
      AppLanguage.vi: 'Bắt đầu trận',
      AppLanguage.en: 'Kick-off',
    },
    'football_notif_halftime': {
      AppLanguage.vi: 'Hết hiệp 1',
      AppLanguage.en: 'Half time',
    },
    'football_notif_finish': {
      AppLanguage.vi: 'Kết thúc trận',
      AppLanguage.en: 'Full time',
    },
    'football_notif_lineup': {
      AppLanguage.vi: 'Đội hình ra sân',
      AppLanguage.en: 'Lineup announced',
    },
    'football_notif_lineup_sub': {
      AppLanguage.vi: 'Khi đội hình chính thức được công bố',
      AppLanguage.en: 'When the official lineup is published',
    },
    'football_notif_reminder': {
      AppLanguage.vi: 'Nhắc trước 1 ngày',
      AppLanguage.en: 'Remind me a day before',
    },
    'football_notif_reminder_sub': {
      AppLanguage.vi: 'Tự động, không cần tự đặt lịch',
      AppLanguage.en: 'Automatic, no need to set it yourself',
    },
    'football_notif_account_note': {
      AppLanguage.vi: 'Cài đặt lưu theo tài khoản, đồng bộ mọi thiết bị',
      AppLanguage.en: 'Saved to your account, synced across devices',
    },
    'assistive_menu_football': {
      AppLanguage.vi: 'Bóng đá',
      AppLanguage.en: 'Football',
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
