import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../vocabulary/data/vocabulary_data.dart';

/// 1 đoạn trong micro-story - KHÔNG có mốc thời gian (khác `LyricLine` của
/// bài hát): narration đọc TUẦN TỰ bằng TTS (giống `ReadingScreen`, xem
/// `story_screen.dart`), không phải audio đã canh thời gian trước, nên
/// không có "giây bắt đầu" nào để lưu - đoạn đang đọc là đoạn đang có chỉ số
/// hiện tại, không phải đoạn có mốc thời gian gần nhất.
class StorySegment {
  const StorySegment({required this.id, required this.en, required this.vi});

  /// Khoá ổn định cho 1 đoạn (dùng làm `ValueKey` khi cuộn tới) - KHÔNG phải
  /// thứ hiển thị.
  final String id;
  final String en;
  final String vi;
}

/// 1 micro-story B1 tự viết - xem
/// docs/architecture-multimedia-platform.md Phase 1/§E (MVP-1). Nội dung
/// GỐC, không trích từ nguồn nào nên không cần mục trong `ATTRIBUTION.md`
/// (khác 20 bài hát CC-BY, xem features/attribution/).
class Story {
  const Story({
    required this.id,
    required this.title,
    required this.level,
    required this.color,
    required this.segments,
    required this.vocabulary,
  });

  /// Slug ổn định, dùng làm `lesson_id` khi ghi tiến độ
  /// (`user_lesson_progress`, migration 0026) - KHÔNG BAO GIỜ đổi sau khi
  /// phát hành, giống quy tắc `Song.audioUrl` không đổi.
  final String id;
  final String title;

  /// Nhãn hiển thị (vd 'B1') - ánh xạ tạm theo §F.1 của tài liệu kiến trúc,
  /// KHÔNG phải enum CEFR đầy đủ (nằm ngoài phạm vi lát cắt này).
  final String level;
  final Color color;
  final List<StorySegment> segments;

  /// Tái dùng thẳng `VocabWord` (vocabulary_data.dart) - không cần model
  /// riêng, cùng 1 hình dạng (en/ipa/vi/câu ví dụ).
  final List<VocabWord> vocabulary;
}

const kStories = <Story>[
  Story(
    id: 'a-rainy-morning',
    title: 'A Rainy Morning',
    level: 'B1',
    color: AppColors.teal,
    segments: [
      StorySegment(
        id: 'a-rainy-morning-01',
        en: 'It was a rainy morning in October.',
        vi: 'Đó là một buổi sáng mưa vào tháng Mười.',
      ),
      StorySegment(
        id: 'a-rainy-morning-02',
        en: 'Mai woke up late and had to hurry.',
        vi: 'Mai thức dậy muộn và phải vội vàng.',
      ),
      StorySegment(
        id: 'a-rainy-morning-03',
        en: 'She grabbed her bag and ran to the bus station.',
        vi: 'Cô ấy vớ lấy túi xách và chạy đến bến xe buýt.',
      ),
      StorySegment(
        id: 'a-rainy-morning-04',
        en: 'The rain was falling harder every minute.',
        vi: 'Mưa mỗi phút một nặng hạt hơn.',
      ),
      StorySegment(
        id: 'a-rainy-morning-05',
        en: 'When Mai arrived, the bus was already leaving.',
        vi: 'Khi Mai đến nơi, xe buýt đã bắt đầu rời bến.',
      ),
      StorySegment(
        id: 'a-rainy-morning-06',
        en: 'She stood there, cold and completely wet.',
        vi: 'Cô đứng đó, lạnh và ướt sũng.',
      ),
      StorySegment(
        id: 'a-rainy-morning-07',
        en: 'An old man nearby noticed her and smiled.',
        vi: 'Một ông cụ gần đó để ý thấy cô và mỉm cười.',
      ),
      StorySegment(
        id: 'a-rainy-morning-08',
        en: 'He offered to share his umbrella with her.',
        vi: 'Ông đề nghị cho cô đi chung ô với mình.',
      ),
      StorySegment(
        id: 'a-rainy-morning-09',
        en: 'Mai thanked him and they waited together.',
        vi: 'Mai cảm ơn ông và họ cùng nhau chờ đợi.',
      ),
      StorySegment(
        id: 'a-rainy-morning-10',
        en: 'They talked about the weather and their day.',
        vi: 'Họ nói chuyện về thời tiết và một ngày của mình.',
      ),
      StorySegment(
        id: 'a-rainy-morning-11',
        en: 'The next bus finally arrived a few minutes later.',
        vi: 'Chuyến xe buýt tiếp theo cuối cùng cũng đến sau vài phút.',
      ),
      StorySegment(
        id: 'a-rainy-morning-12',
        en:
            'Mai smiled and realized kindness can turn a bad morning into a '
            'good one.',
        vi:
            'Mai mỉm cười và nhận ra rằng lòng tốt có thể biến một buổi sáng '
            'tồi tệ thành một buổi sáng tốt đẹp.',
      ),
    ],
    vocabulary: [
      VocabWord(
        en: 'rainy',
        ipa: '/ˈreɪni/',
        vi: 'có mưa',
        exampleEn: "It's rainy today, so bring an umbrella.",
        exampleVi: 'Hôm nay trời mưa, vậy hãy mang theo ô.',
      ),
      VocabWord(
        en: 'hurry',
        ipa: '/ˈhʌri/',
        vi: 'vội vàng',
        exampleEn: "Don't hurry, we have enough time.",
        exampleVi: 'Đừng vội, chúng ta có đủ thời gian.',
      ),
      VocabWord(
        en: 'station',
        ipa: '/ˈsteɪʃn/',
        vi: 'bến, ga',
        exampleEn: 'Meet me at the bus station.',
        exampleVi: 'Gặp tôi ở bến xe buýt nhé.',
      ),
      VocabWord(
        en: 'arrive',
        ipa: '/əˈraɪv/',
        vi: 'đến nơi',
        exampleEn: 'The train will arrive at six.',
        exampleVi: 'Tàu sẽ đến lúc sáu giờ.',
      ),
      VocabWord(
        en: 'wet',
        ipa: '/wet/',
        vi: 'ướt',
        exampleEn: 'My shoes are wet from the rain.',
        exampleVi: 'Giày của tôi bị ướt vì mưa.',
      ),
      VocabWord(
        en: 'notice',
        ipa: '/ˈnəʊtɪs/',
        vi: 'để ý, nhận ra',
        exampleEn: 'I noticed a new café on my street.',
        exampleVi: 'Tôi để ý thấy một quán cà phê mới trên phố mình.',
      ),
      VocabWord(
        en: 'offer',
        ipa: '/ˈɒfə(r)/',
        vi: 'đề nghị',
        exampleEn: 'He offered to help me carry the bags.',
        exampleVi: 'Anh ấy đề nghị giúp tôi xách túi.',
      ),
      VocabWord(
        en: 'share',
        ipa: '/ʃeə(r)/',
        vi: 'chia sẻ, dùng chung',
        exampleEn: 'Can we share this umbrella?',
        exampleVi: 'Chúng ta có thể dùng chung cái ô này không?',
      ),
      VocabWord(
        en: 'umbrella',
        ipa: '/ʌmˈbrelə/',
        vi: 'cái ô, cái dù',
        exampleEn: 'I forgot my umbrella at home.',
        exampleVi: 'Tôi quên cái ô ở nhà rồi.',
      ),
      VocabWord(
        en: 'kindness',
        ipa: '/ˈkaɪndnəs/',
        vi: 'lòng tốt',
        exampleEn: "A small act of kindness can make someone's day.",
        exampleVi: 'Một hành động tử tế nhỏ có thể làm ngày của ai đó tốt hơn.',
      ),
    ],
  ),
];
