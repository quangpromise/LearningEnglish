import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Nhạc thật, cấp phép CC-BY 4.0 từ Josh Woodward (joshwoodward.com) — xem
/// ATTRIBUTION.md và docs/research-music-libraries.md để biết chi tiết
/// license/nguồn. File audio được commit tại `content/audio/` và app phát
/// trực tiếp qua raw.githubusercontent.com (self-host, không qua API nào bị
/// giới hạn thương mại).
const _audioBaseUrl =
    'https://raw.githubusercontent.com/quangpromise/LearningEnglish/main/content/audio/';

/// Một dòng lyric kèm bản dịch và thời điểm xuất hiện trong bài hát (giây).
///
/// LƯU Ý: `startSeconds` hiện là ƯỚC LƯỢNG (phân bổ tỉ lệ theo độ dài câu
/// trên tổng thời lượng bài hát), chưa phải forced-alignment thật từ việc
/// nghe file gốc — xem ghi chú trong docs/research-music-libraries.md.
class LyricLine {
  const LyricLine(this.startSeconds, this.en, this.vi);
  final double startSeconds;
  final String en;
  final String vi;
}

class Song {
  const Song({
    required this.title,
    required this.artist,
    required this.duration,
    required this.level,
    required this.color,
    required this.audioUrl,
    required this.lyrics,
  });
  final String title;
  final String artist;
  final String duration;
  final String level;
  final Color color;
  final String audioUrl;
  final List<LyricLine> lyrics;
}

const kSongs = [
  Song(
    title: "Don't Close Your Eyes",
    artist: 'Josh Woodward',
    duration: '3:34',
    level: 'Trung cấp',
    color: AppColors.blue,
    audioUrl: '${_audioBaseUrl}dont-close-your-eyes.mp3',
    lyrics: [
      LyricLine(
        6,
        'Cold hands, sore feet',
        'Đôi tay lạnh cóng, đôi chân rã rời',
      ),
      LyricLine(
        10,
        "You've been walking for an hour on abandoned streets",
        'Bạn đã đi bộ hàng giờ trên những con phố hoang vắng',
      ),
      LyricLine(
        20,
        'Weak knees, and fresh scars',
        'Đầu gối run rẩy, và những vết sẹo còn mới',
      ),
      LyricLine(
        25.2,
        "It's a struggle when you're losing track of who you are",
        'Thật chật vật khi bạn dần quên mất mình là ai',
      ),
      LyricLine(
        35.7,
        "The words you stole won't save your soul",
        'Những lời bạn đánh cắp không cứu được tâm hồn bạn',
      ),
      LyricLine(
        43.4,
        'They can only buy you time',
        'Chúng chỉ giúp bạn có thêm chút thời gian',
      ),
      LyricLine(
        48.4,
        'Light a candle, or curse the dark',
        'Thắp một ngọn nến, hay nguyền rủa bóng tối',
      ),
      LyricLine(
        54.7,
        "It's all the same to me",
        'Với tôi, điều đó chẳng khác gì nhau',
      ),
      LyricLine(
        59.1,
        'Start a fire, or drown the spark',
        'Nhóm lên một ngọn lửa, hay dập tắt tia lửa ấy',
      ),
      LyricLine(65.3, 'And shake away the heat', 'Rồi rũ bỏ hơi ấm đi'),
      LyricLine(
        69.7,
        'Tell the truth or live a lie',
        'Nói thật, hay sống trong dối trá',
      ),
      LyricLine(
        75.1,
        "Just don't close your eyes",
        'Chỉ xin đừng nhắm mắt lại',
      ),
      LyricLine(80, 'Let down, and so spent', 'Thất vọng, và kiệt sức'),
      LyricLine(
        84.3,
        "You've been holding up the world with your good intent",
        'Bạn đã gồng gánh cả thế giới bằng thiện chí của mình',
      ),
      LyricLine(
        94.6,
        'Help out, like you should',
        'Giúp đỡ người khác, như bạn vẫn nên làm',
      ),
      LyricLine(
        99.4,
        "It's a burden that you never really understood",
        'Đó là gánh nặng mà bạn chưa từng thực sự hiểu',
      ),
      LyricLine(
        108.2,
        "But Caroline, I'm doing fine",
        'Nhưng Caroline à, tôi vẫn ổn',
      ),
      LyricLine(
        113.6,
        "It's the others who are dying",
        'Chính những người khác mới đang gục ngã',
      ),
      LyricLine(
        119.2,
        'Light a candle, or curse the dark',
        'Thắp một ngọn nến, hay nguyền rủa bóng tối',
      ),
      LyricLine(
        125.5,
        "It's all the same to me",
        'Với tôi, điều đó chẳng khác gì nhau',
      ),
      LyricLine(
        129.9,
        'Start a fire, or drown the spark',
        'Nhóm lên một ngọn lửa, hay dập tắt tia lửa ấy',
      ),
      LyricLine(136.1, 'And shake away the heat', 'Rồi rũ bỏ hơi ấm đi'),
      LyricLine(
        140.5,
        'Tell the truth or live a lie',
        'Nói thật, hay sống trong dối trá',
      ),
      LyricLine(
        145.8,
        'Be a burden or a prize',
        'Là gánh nặng, hay là phần thưởng',
      ),
      LyricLine(
        150.1,
        'Stick around or say goodbye',
        'Ở lại, hay nói lời tạm biệt',
      ),
      LyricLine(
        155.2,
        "Just don't close your eyes",
        'Chỉ xin đừng nhắm mắt lại',
      ),
      LyricLine(160.2, "And you're breaking", 'Và bạn đang vỡ vụn'),
      LyricLine(
        163.9,
        "But you're faking nothing's ever wrong",
        'Nhưng bạn giả vờ như chẳng có gì sai',
      ),
      LyricLine(
        171.2,
        "And concealing what you're feeling",
        'Che giấu đi những gì bạn đang cảm nhận',
      ),
      LyricLine(177.7, 'Always standing strong', 'Luôn tỏ ra mạnh mẽ'),
      LyricLine(181.9, "But you don't need", 'Nhưng bạn đâu cần phải'),
      LyricLine(
        185.4,
        "To act like you don't bleed",
        'Giả vờ như mình không hề đau',
      ),
      LyricLine(190.5, 'When you come falling down', 'Khi bạn đang gục ngã'),
      LyricLine(
        195.5,
        "Cuz there is no healing when you're not feeling",
        'Vì sẽ chẳng thể chữa lành nếu bạn không cho phép mình cảm nhận',
      ),
      LyricLine(204.5, 'Anything at all', 'Bất cứ điều gì'),
    ],
  ),
  Song(
    title: 'Circles',
    artist: 'Josh Woodward',
    duration: '3:22',
    level: 'Trung cấp',
    color: AppColors.purple,
    audioUrl: '${_audioBaseUrl}circles.mp3',
    lyrics: [
      LyricLine(
        10,
        "You're crying in your Mazda 3",
        'Bạn đang khóc trong chiếc Mazda 3 của mình',
      ),
      LyricLine(
        16.9,
        'Trying just to focus and breathe',
        'Cố gắng tập trung và hít thở',
      ),
      LyricLine(
        24.5,
        'You gave him another shot, but you forgot',
        'Bạn đã cho anh ta thêm một cơ hội, nhưng bạn quên mất',
      ),
      LyricLine(34.2, 'His aim is never true', 'Anh ta chưa bao giờ thật lòng'),
      LyricLine(
        39.2,
        'When you gonna open your eyes?',
        'Khi nào bạn mới chịu mở mắt ra?',
      ),
      LyricLine(
        46.3,
        'The wolf is in another disguise',
        'Con sói lại khoác lên một lớp ngụy trang khác',
      ),
      LyricLine(
        53.6,
        'Convincing apologies on bended knee',
        'Những lời xin lỗi quỳ gối đầy thuyết phục',
      ),
      LyricLine(
        61.9,
        'The poison in a silver spoon',
        'Chất độc trong chiếc thìa bạc',
      ),
      LyricLine(
        68.6,
        'Stand and wave, the grand parade',
        'Đứng đó vẫy tay, cuộc diễu hành hoành tráng',
      ),
      LyricLine(
        76.2,
        'Marching in circles in the pouring rain',
        'Diễu hành vòng quanh trong cơn mưa tầm tã',
      ),
      LyricLine(
        85.4,
        "It's just a turn to run away but",
        'Đây chỉ là lượt để bỏ chạy, nhưng',
      ),
      LyricLine(93, 'No, no, ohh', 'Không, không, ồ'),
      LyricLine(
        97.3,
        'Dizzy on the merry-go-round',
        'Chóng mặt trên vòng quay ngựa gỗ',
      ),
      LyricLine(
        103.7,
        'Yearning for your feet on the ground',
        'Khao khát được đặt chân xuống mặt đất',
      ),
      LyricLine(
        112.2,
        "For only a moment's rest to catch your breath",
        'Chỉ để nghỉ một chút, lấy lại hơi thở',
      ),
      LyricLine(
        122.9,
        'To clear your cloudy mind',
        'Để làm quang đãng tâm trí đang mù mịt',
      ),
      LyricLine(
        128.8,
        "The promises that he's going to change",
        'Những lời hứa rằng anh ta sẽ thay đổi',
      ),
      LyricLine(
        137.8,
        'They wash away like chalk in the rain',
        'Chúng trôi đi như phấn gặp mưa',
      ),
      LyricLine(
        146.6,
        'The moment the storm descends, the pageant ends',
        'Khoảnh khắc cơn bão ập đến, màn kịch cũng kết thúc',
      ),
      LyricLine(157.7, 'Exhausted and resigned', 'Kiệt sức và cam chịu'),
      LyricLine(
        163,
        'Paradise at any price',
        'Thiên đường bằng bất cứ giá nào',
      ),
      LyricLine(
        167.9,
        "You're skating circles on the thinning ice",
        'Bạn đang trượt vòng quanh trên lớp băng mỏng dần',
      ),
      LyricLine(
        177.9,
        "Just a turn to save your life but",
        'Chỉ cần một lượt để cứu lấy đời mình, nhưng',
      ),
      LyricLine(185.7, 'No, no, ohh', 'Không, không, ồ'),
    ],
  ),
  Song(
    title: 'Same Boat',
    artist: 'Josh Woodward',
    duration: '3:22',
    level: 'Cơ bản',
    color: AppColors.teal,
    audioUrl: '${_audioBaseUrl}same-boat.mp3',
    lyrics: [
      LyricLine(
        8,
        "We're in the same boat",
        'Chúng ta cùng chung một con thuyền',
      ),
      LyricLine(
        14.5,
        'Heading for different shores',
        'Nhưng hướng đến những bến bờ khác nhau',
      ),
      LyricLine(22.8, 'Facing each other', 'Đối diện nhau'),
      LyricLine(
        28.1,
        'Grasping at different oars',
        'Mỗi người nắm một mái chèo riêng',
      ),
      LyricLine(
        35.8,
        "We're cornered in a stalemate",
        'Chúng ta mắc kẹt trong thế bế tắc',
      ),
      LyricLine(
        44.4,
        "But the sun is down, it's getting late",
        'Nhưng mặt trời đã lặn, trời cũng đã muộn',
      ),
      LyricLine(55.6, "I've either gotta turn around", 'Tôi phải quay đầu lại'),
      LyricLine(64.2, 'Or learn how to swim', 'Hoặc học cách tự bơi'),
      LyricLine(
        70.1,
        "We're in the same boat",
        'Chúng ta cùng chung một con thuyền',
      ),
      LyricLine(
        76.6,
        'Heading for different shores',
        'Nhưng hướng đến những bến bờ khác nhau',
      ),
      LyricLine(84.9, 'Should I take a break', 'Tôi nên dừng lại nghỉ ngơi'),
      LyricLine(
        91.1,
        'Or throw myself overboard?',
        'Hay nhảy hẳn khỏi thuyền?',
      ),
      LyricLine(
        98.8,
        'Do I find another way back home',
        'Tôi có nên tìm đường khác để về nhà',
      ),
      LyricLine(
        108,
        'Or take a leap into the great unknown',
        'Hay liều mình bước vào miền vô định',
      ),
      LyricLine(
        118.9,
        "I've either gotta turn around",
        'Tôi phải quay đầu lại',
      ),
      LyricLine(127.5, 'Or learn how to swim', 'Hoặc học cách tự bơi'),
      LyricLine(
        133.4,
        "We're in the same boat",
        'Chúng ta cùng chung một con thuyền',
      ),
      LyricLine(
        139.9,
        'Heading for different shores',
        'Nhưng hướng đến những bến bờ khác nhau',
      ),
      LyricLine(148.2, "I've chosen my path", 'Tôi đã chọn con đường của mình'),
      LyricLine(
        153.8,
        "And you've chosen yours",
        'Và bạn cũng đã chọn con đường của bạn',
      ),
      LyricLine(
        160.6,
        'I look away and dive right in',
        'Tôi ngoảnh mặt đi và lao thẳng xuống nước',
      ),
      LyricLine(
        169.2,
        'The frigid water stings my skin',
        'Làn nước lạnh buốt cứa vào da tôi',
      ),
      LyricLine(178.4, "I'm either gonna fade away", 'Tôi sẽ dần biến mất'),
      LyricLine(186.1, 'Or learn how to swim', 'Hoặc học cách tự bơi'),
    ],
  ),
];
