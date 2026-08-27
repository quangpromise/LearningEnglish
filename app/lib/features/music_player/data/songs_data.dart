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
  Song(
    title: 'A Thousand Years',
    artist: 'Josh Woodward',
    duration: '3:31',
    level: 'Nâng cao',
    color: AppColors.pink,
    audioUrl: '${_audioBaseUrl}a-thousand-years.mp3',
    lyrics: [
      LyricLine(6, 'I saved the world', 'Tôi đã cứu cả thế giới'),
      LyricLine(10.5, 'And made it mine', 'Và biến nó thành của riêng tôi'),
      LyricLine(
        15,
        'Now I\'m the air and the sunshine',
        'Giờ đây tôi chính là không khí và ánh mặt trời',
      ),
      LyricLine(23, 'Look on my works', 'Hãy nhìn vào những gì tôi làm nên'),
      LyricLine(27.4, 'They\'re pretty sweet', 'Chúng thật tuyệt vời'),
      LyricLine(
        32.4,
        'The rest of history is obsolete',
        'Phần còn lại của lịch sử đã lỗi thời',
      ),
      LyricLine(
        40.2,
        'This whole place was a lousy disgrace',
        'Cả nơi này từng là một nỗi hổ thẹn thảm hại',
      ),
      LyricLine(
        49.4,
        'Before I came along to lead',
        'Trước khi tôi xuất hiện để dẫn dắt',
      ),
      LyricLine(
        56.1,
        'I gave chase to the weak and the fake',
        'Tôi truy đuổi những kẻ yếu đuối và giả tạo',
      ),
      LyricLine(
        65.4,
        'And scattered them away like sheep',
        'Và xua họ đi như một bầy cừu',
      ),
      LyricLine(73.8, 'My earthly frame', 'Tấm thân trần thế của tôi'),
      LyricLine(78.3, 'Will soon dissolve', 'Rồi sẽ sớm tan biến'),
      LyricLine(
        82.8,
        'They\'ll build a statue that\'s a mile tall',
        'Họ sẽ dựng nên một bức tượng cao cả dặm',
      ),
      LyricLine(93, 'The future kings', 'Những vị vua tương lai'),
      LyricLine(97.5, 'Will all despair', 'Rồi sẽ phải tuyệt vọng'),
      LyricLine(
        102,
        'They\'ll gaze upon me with a reverent stare',
        'Họ sẽ nhìn tôi với ánh mắt đầy tôn kính',
      ),
      LyricLine(
        112.5,
        'They\'ll cry to my soul in the sky',
        'Họ sẽ khóc gọi linh hồn tôi trên bầu trời',
      ),
      LyricLine(
        120.7,
        'Searching for my sage advice',
        'Tìm kiếm lời khuyên khôn ngoan của tôi',
      ),
      LyricLine(
        127.7,
        'But not one in the ages to come',
        'Nhưng chẳng một ai trong những thế hệ mai sau',
      ),
      LyricLine(
        135.4,
        'Will ever reach my soaring heights',
        'Có thể vươn tới tầm cao mà tôi đã đạt được',
      ),
      LyricLine(
        143.9,
        'Kingdoms fall and castles crumble',
        'Vương quốc sụp đổ, lâu đài tan vỡ',
      ),
      LyricLine(
        152.1,
        'But I will never disappear',
        'Nhưng tôi sẽ không bao giờ biến mất',
      ),
      LyricLine(
        158.6,
        'Fortunes fade and legends stumble',
        'Vận may phai nhạt, huyền thoại vấp ngã',
      ),
      LyricLine(
        166.8,
        'But I will reign a thousand years',
        'Nhưng tôi sẽ trị vì suốt ngàn năm',
      ),
      LyricLine(
        175.1,
        'Some say that I’m petty and vain',
        'Có người bảo tôi nhỏ nhen và kiêu ngạo',
      ),
      LyricLine(
        183.1,
        'I know you are but what am I?',
        'Tôi biết anh cũng vậy, nhưng còn tôi thì sao?',
      ),
      LyricLine(
        190.3,
        'I\'m too strong to ever be wrong',
        'Tôi quá mạnh mẽ để có thể sai lầm',
      ),
      LyricLine(
        198,
        'So god is clearly on my side',
        'Nên rõ ràng thượng đế đang đứng về phía tôi',
      ),
    ],
  ),
  Song(
    title: 'California Lullabye',
    artist: 'Josh Woodward',
    duration: '4:13',
    level: 'Trung cấp',
    color: AppColors.blue,
    audioUrl: '${_audioBaseUrl}california-lullabye.mp3',
    lyrics: [
      LyricLine(
        6,
        'The skies are cold and gray',
        'Bầu trời lạnh lẽo và xám xịt',
      ),
      LyricLine(10.3, 'The storm is on its way', 'Cơn bão đang kéo đến'),
      LyricLine(
        13.9,
        'The flat horizon, leafless trees, there\'s nothing far as you can see, out here',
        'Đường chân trời phẳng lặng, hàng cây trơ trụi lá, chẳng có gì để thấy xa hơn nơi đây',
      ),
      LyricLine(
        26.2,
        'You shiver like a waif',
        'Em run rẩy như một đứa trẻ lạc loài',
      ),
      LyricLine(
        29.7,
        'Your snow boot soles are chafed',
        'Đế giày tuyết của em đã mòn',
      ),
      LyricLine(
        34.5,
        'You left your heart in paradise, you left it all to roll the dice with me',
        'Em bỏ lại trái tim mình nơi thiên đường, bỏ lại tất cả để đánh cược cùng tôi',
      ),
      LyricLine(
        46.1,
        'And I will shake away the cloudy skies',
        'Và tôi sẽ xua tan bầu trời u ám',
      ),
      LyricLine(
        52.1,
        'With a California lullabye',
        'Bằng một khúc ru California',
      ),
      LyricLine(
        56.2,
        'And when you\'re frozen with desire',
        'Và khi em run rẩy vì khao khát',
      ),
      LyricLine(
        61.5,
        'We\'ll put our toes up to the fire',
        'Ta sẽ đưa chân sưởi ấm bên lửa',
      ),
      LyricLine(
        66.7,
        'And I will sing your cares away',
        'Và tôi sẽ hát cho nỗi lo của em tan biến',
      ),
      LyricLine(
        71.6,
        'The sand between my toes',
        'Cát giữa những ngón chân tôi',
      ),
      LyricLine(
        75.4,
        'Your hands beneath my clothes',
        'Bàn tay em luồn dưới lớp áo tôi',
      ),
      LyricLine(
        80,
        'The memories of golden days, where first we met, and parted ways so soon',
        'Những kỷ niệm ngày vàng son, nơi ta gặp nhau lần đầu, rồi vội chia xa',
      ),
      LyricLine(
        91.3,
        'But distance lost its fight',
        'Nhưng khoảng cách đã thua cuộc',
      ),
      LyricLine(
        95.6,
        'When you laid down at night',
        'Khi em nằm xuống trong đêm',
      ),
      LyricLine(
        99.8,
        'Without a map, you chose your heart, now we are one, but you\'re still far from home',
        'Không cần bản đồ, em chọn theo trái tim, giờ ta là một, nhưng em vẫn còn xa nhà',
      ),
      LyricLine(
        112.9,
        'So let me shake away the cloudy skies',
        'Vậy hãy để tôi xua tan bầu trời u ám',
      ),
      LyricLine(
        118.8,
        'With a California lullabye',
        'Bằng một khúc ru California',
      ),
      LyricLine(
        122.9,
        'And when you\'re frozen with desire',
        'Và khi em run rẩy vì khao khát',
      ),
      LyricLine(
        128.2,
        'We\'ll put our toes up to the fire',
        'Ta sẽ đưa chân sưởi ấm bên lửa',
      ),
      LyricLine(
        133.4,
        'And I will sing your cares away',
        'Và tôi sẽ hát cho nỗi lo của em tan biến',
      ),
      LyricLine(
        138.3,
        'And when you\'re frozen with desire',
        'Và khi em run rẩy vì khao khát',
      ),
      LyricLine(
        143.7,
        'We\'ll put our toes up to the fire',
        'Ta sẽ đưa chân sưởi ấm bên lửa',
      ),
      LyricLine(
        148.9,
        'And I will sing your cares away',
        'Và tôi sẽ hát cho nỗi lo của em tan biến',
      ),
      LyricLine(
        153.8,
        'I know it feels, like spinning wheels aredigging you much deeper in the snow',
        'Tôi biết cảm giác như những bánh xe đang xoay, kéo em lún sâu hơn vào tuyết',
      ),
      LyricLine(
        165.8,
        'Don\'t worry, ‘cause the winter thaws, and you will watch the river start to flow',
        'Đừng lo, vì mùa đông rồi sẽ tan, và em sẽ thấy dòng sông bắt đầu chảy',
      ),
      LyricLine(
        178.4,
        'And in that place, the empty space, will fill you in a warm embrace',
        'Và nơi khoảng trống ấy, sẽ được lấp đầy bằng một vòng tay ấm áp',
      ),
      LyricLine(
        189,
        'And I will hold you tight until it\'s home',
        'Và tôi sẽ ôm em thật chặt cho đến khi về đến nhà',
      ),
      LyricLine(
        195.4,
        'I will shake away the cloudy skies',
        'Tôi sẽ xua tan bầu trời u ám',
      ),
      LyricLine(
        200.8,
        'With a California lullabye',
        'Bằng một khúc ru California',
      ),
      LyricLine(
        204.9,
        'And when you\'re frozen with desire',
        'Và khi em run rẩy vì khao khát',
      ),
      LyricLine(
        210.3,
        'We\'ll put our toes up to the fire',
        'Ta sẽ đưa chân sưởi ấm bên lửa',
      ),
      LyricLine(
        215.5,
        'And I will sing your cares away',
        'Và tôi sẽ hát cho nỗi lo của em tan biến',
      ),
      LyricLine(
        220.3,
        'Now let me take you back to paradise',
        'Giờ hãy để tôi đưa em trở lại thiên đường',
      ),
      LyricLine(
        226,
        'All you gotta do is close your eyes',
        'Em chỉ cần nhắm mắt lại thôi',
      ),
      LyricLine(
        231.5,
        'And when you\'re frozen with desire',
        'Và khi em run rẩy vì khao khát',
      ),
      LyricLine(
        236.9,
        'We\'ll put our toes up to the fire',
        'Ta sẽ đưa chân sưởi ấm bên lửa',
      ),
      LyricLine(
        242.1,
        'And I will sing your cares away',
        'Và tôi sẽ hát cho nỗi lo của em tan biến',
      ),
    ],
  ),
  Song(
    title: 'Cherubs',
    artist: 'Josh Woodward',
    duration: '4:16',
    level: 'Trung cấp',
    color: AppColors.teal,
    audioUrl: '${_audioBaseUrl}cherubs.mp3',
    lyrics: [
      LyricLine(6, 'Running in the sand', 'Chạy trên cát'),
      LyricLine(10.1, 'Living on the land', 'Sống trên mảnh đất này'),
      LyricLine(
        14,
        'The salty breeze was in our eyes',
        'Làn gió mặn mòi lùa vào mắt ta',
      ),
      LyricLine(
        21,
        'We stood beneath the dragonflies and danced all night',
        'Ta đứng dưới đàn chuồn chuồn và nhảy múa suốt đêm',
      ),
      LyricLine(32.5, 'We polished all the chrome', 'Ta đánh bóng cả lớp crôm'),
      LyricLine(
        38.1,
        'On our rusty little home',
        'Trên ngôi nhà nhỏ đã hoen gỉ của mình',
      ),
      LyricLine(
        43.3,
        'We slept all night in parking lots',
        'Ta ngủ suốt đêm trong những bãi đỗ xe',
      ),
      LyricLine(
        50.7,
        'We tied our hearts in double knots, so tight',
        'Ta buộc chặt trái tim mình bằng những nút thắt đôi',
      ),
      LyricLine(60.3, 'So free, so right', 'Thật tự do, thật đúng đắn'),
      LyricLine(64.2, 'Remember when', 'Còn nhớ không'),
      LyricLine(
        68.1,
        'We were just cherubs in our tender skins',
        'Ta từng chỉ là những thiên thần nhỏ trong lớp da non nớt',
      ),
      LyricLine(
        76.8,
        'Waiting patiently for life to begin',
        'Kiên nhẫn chờ cuộc sống bắt đầu',
      ),
      LyricLine(84.4, 'Flowing so free', 'Trôi thật tự do'),
      LyricLine(88.3, 'Blowing in the breeze', 'Lay động trong làn gió'),
      LyricLine(
        92.8,
        'The songs we sung so long ago',
        'Những bài ca ta từng hát từ rất lâu',
      ),
      LyricLine(
        99.1,
        'With whiskey and an afterglow, we shined like new',
        'Cùng rượu whiskey và ánh hoàng hôn, ta rực rỡ như mới',
      ),
      LyricLine(109.8, 'But there along the way', 'Nhưng rồi trên đường đi'),
      LyricLine(
        114.8,
        'Something seemed to change',
        'Có điều gì đó dường như đổi thay',
      ),
      LyricLine(
        120.4,
        'As weeks turned into months we knew',
        'Khi từng tuần hoá thành từng tháng, ta nhận ra',
      ),
      LyricLine(
        128,
        'As life caught up we slowly grew, apart',
        'Khi cuộc sống ập đến, ta dần lớn lên, xa cách nhau',
      ),
      LyricLine(
        136.5,
        'And untied our hearts',
        'Và cởi bỏ những nút thắt trái tim',
      ),
      LyricLine(
        141,
        'The summer went away and the skies went gray',
        'Mùa hè trôi qua và bầu trời chuyển xám',
      ),
      LyricLine(
        150.6,
        'We slowly ran out of things to say',
        'Ta dần chẳng còn gì để nói với nhau',
      ),
      LyricLine(
        158,
        'The river turned into drought',
        'Dòng sông rồi cũng cạn khô',
      ),
      LyricLine(
        164.3,
        'Our time was fading out',
        'Thời gian của ta dần phai nhạt',
      ),
      LyricLine(
        169.2,
        'Defeated and alone, we returned back home',
        'Thất bại và cô đơn, ta trở về nhà',
      ),
      LyricLine(
        178.1,
        'Like a bird without a wing who had never flown',
        'Như một chú chim gãy cánh chưa từng được bay',
      ),
      LyricLine(
        188.1,
        'Surrendered to, suspended dreams',
        'Đầu hàng trước những giấc mơ còn dang dở',
      ),
      LyricLine(195.1, 'Remember when', 'Còn nhớ không'),
      LyricLine(
        199,
        'You walked away in the December wind',
        'Em bước đi trong cơn gió tháng Mười Hai',
      ),
      LyricLine(
        206.8,
        'I felt the stinging on my pale skin',
        'Tôi cảm nhận cái rát trên làn da nhợt nhạt của mình',
      ),
      LyricLine(
        214.4,
        'I knew that things would never be the same again',
        'Tôi biết rằng mọi thứ sẽ chẳng bao giờ như xưa nữa',
      ),
      LyricLine(224.8, 'Remember when', 'Còn nhớ không'),
      LyricLine(
        228.7,
        'The clouds rolled in and then the sunlight dimmed',
        'Mây kéo đến rồi ánh nắng dần mờ đi',
      ),
      LyricLine(
        239.4,
        'And what will be blacked out what might have been',
        'Và những gì có thể đã xảy ra, giờ chỉ còn là bóng tối',
      ),
    ],
  ),
  Song(
    title: 'Crazy Glue',
    artist: 'Josh Woodward',
    duration: '2:44',
    level: 'Cơ bản',
    color: AppColors.amber,
    audioUrl: '${_audioBaseUrl}crazy-glue.mp3',
    lyrics: [
      LyricLine(
        5,
        'There\'s no gravity that sucked me in your orbit',
        'Chẳng có lực hấp dẫn nào hút tôi vào quỹ đạo của em',
      ),
      LyricLine(
        13.4,
        'There\'s no magnet that was in your heart',
        'Cũng chẳng có nam châm nào trong trái tim em',
      ),
      LyricLine(
        20.5,
        'The one restriction was the friction that was keeping us',
        'Điều duy nhất cản trở là ma sát đã giữ chúng ta',
      ),
      LyricLine(30.5, 'A little too far apart', 'Cách nhau một chút quá xa'),
      LyricLine(
        34.4,
        'Why fight it, I was secretly delighted',
        'Sao phải chống lại, tôi thầm vui sướng',
      ),
      LyricLine(
        41.1,
        'I gave chase but then I let you win',
        'Tôi đuổi theo rồi lại để em thắng',
      ),
      LyricLine(
        47.4,
        'You felt lovely when you loved me like a fool',
        'Em cảm thấy thật dễ thương khi yêu tôi như một kẻ khờ',
      ),
      LyricLine(
        55.4,
        'But now I can\'t let go of your skin',
        'Nhưng giờ tôi chẳng thể rời xa làn da em',
      ),
      LyricLine(61.6, 'You know that,', 'Em biết đấy,'),
      LyricLine(64.8, 'I never knew', 'Tôi chưa từng biết'),
      LyricLine(
        68,
        'That you, are, crazy glue, my darling',
        'Rằng em chính là keo dính diệu kỳ, em yêu à',
      ),
      LyricLine(74.6, 'And I\'m stuck to you', 'Và tôi đã dính chặt lấy em'),
      LyricLine(
        78.2,
        'I am cozy and I don\'t gonna wiggle loose',
        'Tôi thấy ấm áp và chẳng muốn rời đi đâu cả',
      ),
      LyricLine(
        85.3,
        'You\'re honey like a finger in the beehive',
        'Em ngọt như mật ong nơi tổ ong',
      ),
      LyricLine(
        92.6,
        'The bees are buzzing in a tizzy fit',
        'Những chú ong đang vo ve rộn ràng',
      ),
      LyricLine(
        98.8,
        'They\'re stinging but I\'m singing like a fool',
        'Chúng chích tôi nhưng tôi vẫn hát vang như một kẻ khờ',
      ),
      LyricLine(
        106.7,
        'Cuz you\'re as sweet as a banana split',
        'Vì em ngọt ngào như một que kem chuối',
      ),
      LyricLine(
        113.2,
        'You\'re sticky like a hippie in the summer',
        'Em dính như một cô nàng hippie giữa mùa hè',
      ),
      LyricLine(
        120.5,
        'You\'re like syrup in the slushie tray',
        'Em như xi-rô trong ly đá bào',
      ),
      LyricLine(
        127.1,
        'One touch of you and I will never leave',
        'Chỉ cần chạm vào em, tôi sẽ chẳng bao giờ rời đi',
      ),
      LyricLine(
        134.1,
        'Cuz I believe that I can\'t get away',
        'Vì tôi tin rằng mình không thể thoát khỏi em',
      ),
      LyricLine(140.3, 'You know that', 'Em biết đấy'),
      LyricLine(143.5, 'Hold onto me', 'Hãy giữ chặt lấy tôi'),
      LyricLine(
        146.7,
        'And hand in hand we\'ll follow',
        'Và tay trong tay ta sẽ cùng bước',
      ),
      LyricLine(151.9, 'Hold onto me', 'Hãy giữ chặt lấy tôi'),
      LyricLine(
        155.1,
        'As if you had a choice',
        'Như thể em chẳng có lựa chọn nào khác',
      ),
    ],
  ),
  Song(
    title: 'Flickering Flame',
    artist: 'Josh Woodward',
    duration: '5:16',
    level: 'Nâng cao',
    color: AppColors.purple,
    audioUrl: '${_audioBaseUrl}flickering-flame.mp3',
    lyrics: [
      LyricLine(
        6,
        'In the twilight of summer, you shook like a leaf',
        'Trong buổi hoàng hôn mùa hè, em run rẩy như chiếc lá',
      ),
      LyricLine(
        16.8,
        'And blew to the ground in a pile at my feet',
        'Rồi rơi xuống thành đống dưới chân tôi',
      ),
      LyricLine(
        26.4,
        'I picked you up, we fell into place',
        'Tôi nhặt em lên, và ta hoà vào nhau',
      ),
      LyricLine(
        34.2,
        'On the park bench in silence, we spoke with no words',
        'Trên băng ghế công viên trong im lặng, ta chẳng nói lời nào',
      ),
      LyricLine(
        45.9,
        'You held me like water, to placate your thirst',
        'Em ôm lấy tôi như dòng nước, để làm dịu cơn khát của mình',
      ),
      LyricLine(
        56.2,
        'Your lifeboat, your anchor, your perfect mistake',
        'Em là chiếc phao cứu sinh, là mỏ neo, là sai lầm hoàn hảo của tôi',
      ),
      LyricLine(
        66.9,
        'The white coat of winter, you wore like a veil',
        'Chiếc áo khoác trắng của mùa đông, em khoác lên như tấm màn che',
      ),
      LyricLine(
        77.2,
        'Thin as a whisper, but sharp as a nail',
        'Mỏng manh như hơi thở, nhưng sắc như mũi đinh',
      ),
      LyricLine(
        85.8,
        'The wind on the river is calling your name, with a voice so tame',
        'Cơn gió trên dòng sông đang gọi tên em, bằng giọng thật dịu dàng',
      ),
      LyricLine(
        100.1,
        'Be my light, my flickering flame',
        'Hãy là ánh sáng của tôi, ngọn lửa chập chờn của tôi',
      ),
      LyricLine(
        107.3,
        'In the bell tower basement, beneath the cold world',
        'Trong tầng hầm tháp chuông, dưới thế giới lạnh giá',
      ),
      LyricLine(
        118.5,
        'The feelings you\'d bunched up so gently unfurled',
        'Những cảm xúc em dồn nén bấy lâu dần bung nở dịu dàng',
      ),
      LyricLine(
        129.2,
        'You held me close, I tried to hold on',
        'Em ôm chặt lấy tôi, tôi cố gắng bám víu',
      ),
      LyricLine(
        137.5,
        'The next cloudy morning, you woke in my arms',
        'Sáng hôm sau nhiều mây, em tỉnh dậy trong vòng tay tôi',
      ),
      LyricLine(
        147.4,
        'I made you some coffee, you showed me your scars',
        'Tôi pha cho em một tách cà phê, em cho tôi xem những vết sẹo',
      ),
      LyricLine(
        158.1,
        'And I knew, one day, that I\'d be your next',
        'Và tôi biết, một ngày nào đó, tôi sẽ là người tiếp theo',
      ),
      LyricLine(
        167.5,
        'The stray light was running, you touched me and said,',
        'Ánh sáng lạc lối đang trôi đi, em chạm vào tôi và nói,',
      ),
      LyricLine(
        179.4,
        '"As young as I was, I felt older back then"',
        '"Dù khi ấy tôi còn trẻ, tôi đã cảm thấy mình già hơn rồi"',
      ),
      LyricLine(
        189,
        'Two parallel lines on an infinite plane, trying to cross in vain',
        'Hai đường thẳng song song trên một mặt phẳng vô tận, cố chạm nhau trong vô vọng',
      ),
      LyricLine(
        203.4,
        'Be my light, my flickering flame',
        'Hãy là ánh sáng của tôi, ngọn lửa chập chờn của tôi',
      ),
      LyricLine(
        210.5,
        'The cascades are thawing, and flowing again',
        'Những dòng thác đang tan băng, và chảy trở lại',
      ),
      LyricLine(
        220.2,
        'The ice that was frozen is slowly beginning',
        'Lớp băng từng đóng cứng giờ đang dần',
      ),
      LyricLine(
        229.8,
        'To move down the river, as it had to be',
        'Trôi xuôi theo dòng sông, như lẽ tất nhiên phải thế',
      ),
      LyricLine(
        238.5,
        'There\'s a lake in the country, where dreams go to die',
        'Có một hồ nước nơi miền quê, nơi những giấc mơ tìm đến cái chết',
      ),
      LyricLine(
        250.4,
        'It\'s flooding the banks where it once had been dry',
        'Nó đang tràn qua bờ, nơi từng khô cạn',
      ),
      LyricLine(
        261.6,
        'The petrified spirits are finally free',
        'Những linh hồn hoá đá cuối cùng cũng được tự do',
      ),
      LyricLine(
        270.1,
        'No flame is eternal, it just takes a drip',
        'Không ngọn lửa nào là vĩnh cửu, chỉ cần một giọt nước cũng đủ tắt',
      ),
      LyricLine(
        279.3,
        'No life is forever, it\'s all just a blip',
        'Không cuộc đời nào là mãi mãi, tất cả chỉ là thoáng chốc',
      ),
      LyricLine(
        288.3,
        'The ashes were carried on down to the drain by the callous rain',
        'Tro tàn bị cuốn trôi xuống rãnh nước bởi cơn mưa vô tình',
      ),
      LyricLine(
        302.4,
        'Say goodnight, my flickering flame',
        'Chúc ngủ ngon, ngọn lửa chập chờn của tôi',
      ),
    ],
  ),
  Song(
    title: 'Goodbye to Spring',
    artist: 'Josh Woodward',
    duration: '4:06',
    level: 'Trung cấp',
    color: AppColors.teal,
    audioUrl: '${_audioBaseUrl}goodbye-to-spring.mp3',
    lyrics: [
      LyricLine(
        5,
        'Lay, and put your weary soul to rest',
        'Nằm xuống, để tâm hồn mệt mỏi của con được nghỉ ngơi',
      ),
      LyricLine(
        13,
        'Yeah, I will try to do my best to keep you safe inside this nest',
        'Vâng, cha sẽ cố gắng hết sức để giữ con an toàn trong tổ ấm này',
      ),
      LyricLine(
        27.3,
        'And keep the gravity from pulling you to earth',
        'Và giữ cho trọng lực không kéo con xuống mặt đất',
      ),
      LyricLine(
        37.6,
        'I\'d like to say this gets more clear, when it\'s more cloudy every day',
        'Cha muốn nói rằng mọi thứ sẽ rõ ràng hơn, dù mỗi ngày trời một nhiều mây hơn',
      ),
      LyricLine(
        53,
        'But summer\'s gonna come and burn the stormy clouds and all the doubt away',
        'Nhưng mùa hè sẽ đến và thiêu cháy những đám mây giông cùng mọi nghi ngờ',
      ),
      LyricLine(
        69.3,
        'Sleep, little girl, \'cause when you wake it\'s gonna be a different world',
        'Ngủ đi, cô bé nhỏ, vì khi con tỉnh dậy thế giới sẽ khác đi',
      ),
      LyricLine(
        85.4,
        'So close your eyes and say goodbye to spring',
        'Vậy hãy nhắm mắt lại và nói lời tạm biệt mùa xuân',
      ),
      LyricLine(
        95.2,
        'It\'s true, this spring is coming to an end',
        'Đúng vậy, mùa xuân này sắp kết thúc rồi',
      ),
      LyricLine(
        104.6,
        'You\'re not that fragile anymore, I know what\'s there behind that door',
        'Con không còn mong manh như trước nữa, cha biết điều gì đang chờ sau cánh cửa đó',
      ),
      LyricLine(
        120,
        'And it\'s just waiting in the wings to pull you in',
        'Và nó chỉ đang chờ trong cánh gà để kéo con vào',
      ),
      LyricLine(
        130.9,
        'I know you think you\'re safe in here, inside these insulated walls',
        'Cha biết con nghĩ mình an toàn ở đây, trong những bức tường cách ly này',
      ),
      LyricLine(
        145.7,
        'But I can\'t hold this house together, not forever, yeah and soon it\'s gonna fall',
        'Nhưng cha không thể giữ ngôi nhà này mãi mãi, và rồi nó sẽ sớm sụp đổ',
      ),
      LyricLine(
        163.5,
        'Sleep, little girl, \'cause when you wake it\'s gonna be a different world',
        'Ngủ đi, cô bé nhỏ, vì khi con tỉnh dậy thế giới sẽ khác đi',
      ),
      LyricLine(
        179.6,
        'Everything will change, everything will change',
        'Mọi thứ sẽ đổi thay, mọi thứ sẽ đổi thay',
      ),
      LyricLine(
        189.9,
        'This door\'s slamming shut, it\'s gonna catch you if you\'re ready or you\'re not',
        'Cánh cửa này sắp đóng sầm lại, nó sẽ bắt lấy con dù con đã sẵn sàng hay chưa',
      ),
      LyricLine(
        207.1,
        'So close your eyes and say goodbye to spring',
        'Vậy hãy nhắm mắt lại và nói lời tạm biệt mùa xuân',
      ),
      LyricLine(
        216.9,
        'Slow down, \'cause winter\'s just around the bend',
        'Chậm lại thôi, vì mùa đông đã ở ngay khúc quanh',
      ),
      LyricLine(
        227.4,
        'Don\'t make a sound, and close your eyes and say goodbye, yeah',
        'Đừng gây tiếng động, nhắm mắt lại và nói lời tạm biệt nhé',
      ),
    ],
  ),
  Song(
    title: 'I\'m Letting Go',
    artist: 'Josh Woodward',
    duration: '3:12',
    level: 'Trung cấp',
    color: AppColors.pink,
    audioUrl: '${_audioBaseUrl}im-letting-go.mp3',
    lyrics: [
      LyricLine(
        5,
        'I\'ve been sleeping with the lights on, buried in regrets',
        'Tôi vẫn ngủ với đèn bật sáng, chìm trong hối tiếc',
      ),
      LyricLine(
        17.3,
        'Breaking into sweats, naked as a falling leaf',
        'Toát mồ hôi lạnh, trần trụi như chiếc lá đang rơi',
      ),
      LyricLine(
        27.1,
        'It\'s a natural reaction, driven to distraction,',
        'Đó là phản ứng tự nhiên, bị cuốn theo sự xao lãng,',
      ),
      LyricLine(
        37.4,
        'Clawing at the ghosts I\'ll never meet',
        'Cào cấu vào những bóng ma tôi sẽ chẳng bao giờ gặp lại',
      ),
      LyricLine(
        45.5,
        'Oh, I don\'t know, where they go',
        'Ôi, tôi chẳng biết chúng đi đâu',
      ),
      LyricLine(
        52.3,
        'When they vanish in the corner of my eye',
        'Khi chúng biến mất nơi khóe mắt tôi',
      ),
      LyricLine(
        61.1,
        'And I, don\'t know why, I don\'t know',
        'Và tôi, chẳng biết vì sao, tôi chẳng biết',
      ),
      LyricLine(
        68.7,
        'If they stay below or rise up to the sky',
        'Liệu chúng ở lại phía dưới hay bay lên bầu trời',
      ),
      LyricLine(77.5, 'But I\'m letting go', 'Nhưng tôi đang buông bỏ'),
      LyricLine(81.4, 'I\'m letting go', 'Tôi đang buông bỏ'),
      LyricLine(
        85.4,
        'It\'s a history that never really grows',
        'Đó là một quá khứ chẳng bao giờ lớn thêm được nữa',
      ),
      LyricLine(93.7, 'I\'m letting go', 'Tôi đang buông bỏ'),
      LyricLine(97.6, 'I\'m letting go', 'Tôi đang buông bỏ'),
      LyricLine(
        101.6,
        'It\'s a silent wind that never really blows',
        'Đó là cơn gió lặng thinh chẳng bao giờ thực sự thổi',
      ),
      LyricLine(110.8, 'I\'m letting go', 'Tôi đang buông bỏ'),
      LyricLine(
        114.7,
        'I\'m a slave without a master, heading for disaster',
        'Tôi là nô lệ không chủ nhân, đang tiến về phía thảm hoạ',
      ),
      LyricLine(
        125.7,
        'Kicking up the dust in the middle of the road',
        'Đá tung bụi mù giữa con đường',
      ),
      LyricLine(
        135.5,
        'I\'ve been waiting on a free ride ticket',
        'Tôi vẫn chờ một tấm vé đi nhờ miễn phí',
      ),
      LyricLine(
        144.1,
        'To a seaside thicket on the edge of Puget Sound',
        'Đến bụi cây ven biển bên rìa vịnh Puget Sound',
      ),
      LyricLine(
        154.4,
        'And there I\'ll sit, and I\'ll admit',
        'Và tôi sẽ ngồi đó, và tôi sẽ thừa nhận',
      ),
      LyricLine(
        161.8,
        'That I was only just a guest inside my skin',
        'Rằng tôi chỉ là một vị khách trong chính làn da mình',
      ),
      LyricLine(
        171.2,
        'And by the dawn, I\'ll be gone',
        'Và khi bình minh lên, tôi sẽ rời đi',
      ),
      LyricLine(
        177.6,
        'And I won\'t be holding on to anything again',
        'Và tôi sẽ chẳng còn bám víu vào điều gì nữa',
      ),
    ],
  ),
  Song(
    title: 'Let It In',
    artist: 'Josh Woodward',
    duration: '4:01',
    level: 'Nâng cao',
    color: AppColors.purple,
    audioUrl: '${_audioBaseUrl}let-it-in.mp3',
    lyrics: [
      LyricLine(
        5,
        'It starts with an itch and a tingle',
        'Nó bắt đầu bằng một cơn ngứa ran nhẹ',
      ),
      LyricLine(
        19.9,
        'Then it builds and expands',
        'Rồi nó lớn dần và lan rộng',
      ),
      LyricLine(
        31,
        'And suddenly all at once my legs won\'t let me stand',
        'Và bỗng nhiên đôi chân tôi không thể đứng vững',
      ),
      LyricLine(
        52.6,
        'I scratch till my fingers go numb',
        'Tôi gãi đến khi ngón tay tê dại',
      ),
      LyricLine(
        66.7,
        'But my skin never bleeds',
        'Nhưng da tôi chẳng bao giờ chảy máu',
      ),
      LyricLine(
        76.9,
        'A silent accomplice waits and feeds when I\'m asleep',
        'Một kẻ đồng loã thầm lặng chờ đợi và ăn mòn tôi khi tôi ngủ say',
      ),
      LyricLine(
        98.6,
        'There\'s something that lives inside me',
        'Có điều gì đó đang sống bên trong tôi',
      ),
      LyricLine(
        114.8,
        'I promise I never let it in',
        'Tôi thề tôi chưa từng để nó bước vào',
      ),
      LyricLine(
        126.2,
        'It grows and divides inside me',
        'Nó lớn lên và phân chia bên trong tôi',
      ),
      LyricLine(
        139,
        'It\'s making a home beneath my skin',
        'Nó đang tự làm tổ dưới làn da tôi',
      ),
      LyricLine(
        153.5,
        'The seeds have been buried deeply',
        'Những hạt giống đã được chôn thật sâu',
      ),
      LyricLine(167.5, 'The roots are in place', 'Rễ của nó đã bám chắc'),
      LyricLine(
        176.9,
        'It\'s crowding the sun and it\'s darkened my days',
        'Nó che khuất ánh mặt trời và làm tối tăm những ngày của tôi',
      ),
      LyricLine(
        196.9,
        'I\'ve taken it all for granted',
        'Tôi đã xem mọi thứ là điều hiển nhiên',
      ),
      LyricLine(209.2, 'But now it\'s too late', 'Nhưng giờ đã quá muộn'),
      LyricLine(
        218.1,
        'There\'s nothing that\'s left to do but wait',
        'Chẳng còn gì để làm ngoài chờ đợi',
      ),
    ],
  ),
  Song(
    title: 'My Favorite Regret',
    artist: 'Josh Woodward',
    duration: '4:27',
    level: 'Trung cấp',
    color: AppColors.blue,
    audioUrl: '${_audioBaseUrl}my-favorite-regret.mp3',
    lyrics: [
      LyricLine(6, 'The day that we met', 'Ngày ta gặp nhau'),
      LyricLine(10.6, 'I\'ll never forget', 'Tôi sẽ không bao giờ quên'),
      LyricLine(
        15,
        'I knew from the moment she spoke',
        'Tôi biết ngay từ khoảnh khắc nàng cất lời',
      ),
      LyricLine(
        22.7,
        'The she, was destined to be',
        'Rằng nàng, định sẵn sẽ là',
      ),
      LyricLine(
        29.2,
        'My favorite regret',
        'Nỗi hối tiếc yêu thích nhất của tôi',
      ),
      LyricLine(33.6, 'And all through the years', 'Và suốt bao năm tháng'),
      LyricLine(39.7, 'The joy and the tears', 'Niềm vui và nước mắt'),
      LyricLine(
        44.7,
        'We shared like as greatest of friends',
        'Ta sẻ chia như những người bạn thân thiết nhất',
      ),
      LyricLine(
        53.7,
        'But she, was destined to be',
        'Nhưng nàng, định sẵn sẽ là',
      ),
      LyricLine(
        60.2,
        'My favorite regret',
        'Nỗi hối tiếc yêu thích nhất của tôi',
      ),
      LyricLine(
        64.6,
        'Well, each moment we\'ve spent',
        'Mỗi khoảnh khắc ta đã cùng trải qua',
      ),
      LyricLine(71.6, 'I\'ve been almost content', 'Tôi gần như đã mãn nguyện'),
      LyricLine(
        77.4,
        'Just to talk to her all through the night',
        'Chỉ cần được trò chuyện cùng nàng suốt đêm',
      ),
      LyricLine(
        87.4,
        'But a part of me mourns',
        'Nhưng một phần trong tôi vẫn tiếc nuối',
      ),
      LyricLine(
        92.9,
        'What will never be born',
        'Cho những gì sẽ chẳng bao giờ thành hiện thực',
      ),
      LyricLine(
        98.5,
        'She\'s forever my favorite regret',
        'Nàng mãi mãi là nỗi hối tiếc yêu thích nhất của tôi',
      ),
      LyricLine(106.3, 'He\'s gentle and kind', 'Anh ấy dịu dàng và tốt bụng'),
      LyricLine(111.1, 'And totally blind', 'Nhưng hoàn toàn không nhận ra'),
      LyricLine(
        115.5,
        'To not see the life we could lead',
        'Cuộc sống mà ta có thể cùng nhau xây đắp',
      ),
      LyricLine(123.5, 'And he, is destined to be', 'Và anh, định sẵn sẽ là'),
      LyricLine(
        129.5,
        'My favorite regret',
        'Nỗi hối tiếc yêu thích nhất của tôi',
      ),
      LyricLine(133.9, 'In bad times and good', 'Dù lúc khó khăn hay êm đềm'),
      LyricLine(
        138.9,
        'I\'ve steadfastly stood',
        'Tôi vẫn luôn kiên định đứng đó',
      ),
      LyricLine(
        144.3,
        'My passion just waits to be freed',
        'Đam mê trong tôi chỉ chờ được giải phóng',
      ),
      LyricLine(
        152.3,
        'But he, is destined to be',
        'Nhưng anh, định sẵn sẽ là',
      ),
      LyricLine(
        158.3,
        'My favorite regret',
        'Nỗi hối tiếc yêu thích nhất của tôi',
      ),
      LyricLine(
        162.7,
        'Well, I\'ve got more to give',
        'Tôi vẫn còn nhiều điều muốn trao',
      ),
      LyricLine(
        169.2,
        'But I\'m happy to live',
        'Nhưng tôi hạnh phúc khi được sống',
      ),
      LyricLine(
        174.3,
        'In the shadow, of what could’ve been',
        'Trong cái bóng của những gì có thể đã xảy ra',
      ),
      LyricLine(
        183,
        'But a part of me yearns',
        'Nhưng một phần trong tôi vẫn khao khát',
      ),
      LyricLine(
        188.6,
        'Like an ember, it burns',
        'Như một tia lửa âm ỉ, nó vẫn cháy',
      ),
      LyricLine(
        194.2,
        'Forever, my favorite regret',
        'Mãi mãi, là nỗi hối tiếc yêu thích nhất của tôi',
      ),
      LyricLine(
        200.7,
        'One day, when the stars fade',
        'Một ngày nào đó, khi những vì sao lụi tàn',
      ),
      LyricLine(
        207.5,
        'Will the echoes of my love',
        'Liệu tiếng vọng tình yêu của tôi',
      ),
      LyricLine(
        213.8,
        'Arrive to you above',
        'Có bay đến được nơi nàng trên cao',
      ),
      LyricLine(218.4, 'And wake you up at last', 'Và đánh thức nàng lần cuối'),
      LyricLine(
        223.9,
        'I\'ll take what I\'ve got',
        'Tôi sẽ giữ lấy những gì mình có',
      ),
      LyricLine(
        229.5,
        'Put the rest in a box',
        'Cất phần còn lại vào một chiếc hộp',
      ),
      LyricLine(
        234.6,
        'Addressed to the stars in the sky',
        'Gửi đến những vì sao trên bầu trời',
      ),
      LyricLine(
        242.6,
        'And soon, up there with the moon',
        'Và sớm thôi, trên đó cùng vầng trăng',
      ),
      LyricLine(
        250.3,
        'My favorite regret',
        'Nỗi hối tiếc yêu thích nhất của tôi',
      ),
      LyricLine(
        254.7,
        'Forever my favorite regret',
        'Mãi mãi là nỗi hối tiếc yêu thích nhất của tôi',
      ),
    ],
  ),
  Song(
    title: 'Release',
    artist: 'Josh Woodward',
    duration: '3:50',
    level: 'Cơ bản',
    color: AppColors.teal,
    audioUrl: '${_audioBaseUrl}release.mp3',
    lyrics: [
      LyricLine(
        5,
        'Everything, everything, everything I touch will break',
        'Mọi thứ, mọi thứ, mọi thứ tôi chạm vào rồi cũng vỡ tan',
      ),
      LyricLine(
        22.2,
        'And everyday, everyday, everyday you give and I take',
        'Và mỗi ngày, mỗi ngày, mỗi ngày em cho đi còn tôi thì nhận lấy',
      ),
      LyricLine(
        39,
        'I\'m living the best that I can',
        'Tôi đang sống hết sức mình có thể',
      ),
      LyricLine(
        48.7,
        'But fate never followed my plans',
        'Nhưng số phận chưa bao giờ theo đúng kế hoạch của tôi',
      ),
      LyricLine(
        59.1,
        'I’m holding you back, so I want you to pack up and grow',
        'Tôi đang kìm hãm em, nên tôi muốn em thu dọn và trưởng thành',
      ),
      LyricLine(
        76.9,
        'Everything, everything, everything you\'ve done is great',
        'Mọi thứ, mọi thứ, mọi thứ em đã làm đều tuyệt vời',
      ),
      LyricLine(
        94.7,
        'But your back has been feeling exhausted from all of the weight',
        'Nhưng tấm lưng em đã mệt mỏi vì gánh nặng ấy',
      ),
      LyricLine(
        115.2,
        'I\'ll carry this burden myself',
        'Tôi sẽ tự mình mang gánh nặng này',
      ),
      LyricLine(
        124.6,
        'Just put me up high on the shelf',
        'Cứ đặt tôi lên cao trên kệ sách',
      ),
      LyricLine(
        134.9,
        'Think of me fondly, but please move beyond me and go',
        'Hãy nhớ về tôi với sự trìu mến, nhưng xin hãy bước tiếp và rời đi',
      ),
      LyricLine(
        151.8,
        'There\'s so much that you want to do',
        'Có rất nhiều điều em muốn làm',
      ),
      LyricLine(
        163.1,
        'The world is just waiting for you',
        'Thế giới đang chờ đợi em',
      ),
      LyricLine(
        173.8,
        'But I\'m holding you down',
        'Nhưng tôi lại đang kéo em xuống',
      ),
      LyricLine(
        181.6,
        'From the dreams that you found',
        'Khỏi những giấc mơ em đã tìm thấy',
      ),
      LyricLine(
        191.3,
        'In a life that you left when we met',
        'Trong cuộc đời mà em đã bỏ lại khi ta gặp nhau',
      ),
      LyricLine(
        202.6,
        'So please just escape',
        'Vậy nên xin hãy trốn thoát đi',
      ),
      LyricLine(
        209.4,
        'Before my resolve goes away',
        'Trước khi quyết tâm của tôi lung lay',
      ),
      LyricLine(218.2, 'And I ask you to stay', 'Và tôi lại xin em ở lại'),
    ],
  ),
  Song(
    title: 'Saboteurs',
    artist: 'Josh Woodward',
    duration: '4:21',
    level: 'Nâng cao',
    color: AppColors.amber,
    audioUrl: '${_audioBaseUrl}saboteurs.mp3',
    lyrics: [
      LyricLine(5, 'Burn who I’ve been', 'Thiêu rụi con người tôi từng là'),
      LyricLine(
        10.3,
        'Wipe the slate, a clean escape again',
        'Xoá sạch mọi thứ, một lần trốn thoát trong sạch nữa',
      ),
      LyricLine(20.9, 'Run like the wind', 'Chạy như gió cuốn'),
      LyricLine(
        26.3,
        'The present’s gone, the past has never been',
        'Hiện tại đã mất, quá khứ chưa từng tồn tại',
      ),
      LyricLine(39, 'The firewood is spent', 'Củi lửa đã cháy hết'),
      LyricLine(45.2, 'The daylight came and went', 'Ánh ngày đến rồi lại đi'),
      LyricLine(
        52.8,
        'Now I’m just alone inside my head',
        'Giờ tôi chỉ còn lại một mình trong tâm trí',
      ),
      LyricLine(
        62.6,
        'And barely on the lam',
        'Và chỉ vừa mới thoát khỏi truy đuổi',
      ),
      LyricLine(
        68.8,
        'The demons I outran',
        'Những con quỷ tôi từng chạy thoát',
      ),
      LyricLine(74.4, 'Are at the door', 'Giờ đang đứng trước cửa'),
      LyricLine(
        79.7,
        'My saboteurs are passengers, they follow where I lead',
        'Những kẻ phá hoại trong tôi là hành khách, chúng theo bất cứ nơi nào tôi dẫn lối',
      ),
      LyricLine(
        95.4,
        'I can\'t escape the trouble, when the trouble’s part of me',
        'Tôi không thể thoát khỏi rắc rối, khi rắc rối chính là một phần của tôi',
      ),
      LyricLine(
        112.2,
        'And I run, as fast as lightning, from the mountains to the shore',
        'Và tôi chạy, nhanh như tia chớp, từ núi non đến bờ biển',
      ),
      LyricLine(
        131.1,
        'Still the wolves are clawing at the door',
        'Nhưng lũ sói vẫn cào cấu ngoài cửa',
      ),
      LyricLine(
        142.9,
        'A tap, then a knock',
        'Một cái chạm nhẹ, rồi một tiếng gõ',
      ),
      LyricLine(
        148.5,
        'Crecendoing and growing ever wilder',
        'Ngày càng dồn dập và dữ dội hơn',
      ),
      LyricLine(158.8, 'I stare at the lock', 'Tôi nhìn chằm chằm vào ổ khoá'),
      LyricLine(
        164.5,
        'The pounding shakes, the plaster breaks apart',
        'Tiếng đập rung chuyển, lớp thạch cao vỡ vụn',
      ),
      LyricLine(
        177.7,
        'A crackle then a spark',
        'Một tiếng nổ lách tách rồi một tia lửa',
      ),
      LyricLine(
        184.2,
        'Then everything goes dark',
        'Rồi mọi thứ chìm vào bóng tối',
      ),
      LyricLine(
        191.6,
        'I feel the winds constricting on the walls',
        'Tôi cảm nhận những cơn gió siết chặt quanh tường',
      ),
      LyricLine(
        204,
        'The shattered windows fall',
        'Những ô cửa sổ vỡ vụn rơi xuống',
      ),
      LyricLine(
        211.7,
        'A voice is in the hall, it calls me in',
        'Có một giọng nói trong sảnh, nó gọi tôi vào',
      ),
      LyricLine(222.9, 'Burn who I’ve been', 'Thiêu rụi con người tôi từng là'),
      LyricLine(
        228.2,
        'Wipe the slate, a clean escape, the end',
        'Xoá sạch mọi thứ, một lần trốn thoát trong sạch, đến hồi kết',
      ),
      LyricLine(239.8, 'Run like the wind', 'Chạy như gió cuốn'),
      LyricLine(
        245.1,
        'And leave behind my broken mind again',
        'Và bỏ lại phía sau tâm trí đã vỡ vụn của tôi, một lần nữa',
      ),
    ],
  ),
  Song(
    title: 'She Dreams in Blue',
    artist: 'Josh Woodward',
    duration: '5:17',
    level: 'Nâng cao',
    color: AppColors.purple,
    audioUrl: '${_audioBaseUrl}she-dreams-in-blue.mp3',
    lyrics: [
      LyricLine(
        8,
        'The tiptoes on the bedroom floor',
        'Những bước chân rón rén trên sàn phòng ngủ',
      ),
      LyricLine(
        18.3,
        'These quiet eyes are spinning in the dark',
        'Đôi mắt lặng lẽ ấy đang xoay tròn trong bóng tối',
      ),
      LyricLine(
        31.6,
        'The secret wish that none will know',
        'Điều ước thầm kín mà chẳng ai biết được',
      ),
      LyricLine(
        42.8,
        'She keeps it locked up in her pale heart',
        'Nàng khoá chặt nó trong trái tim nhợt nhạt của mình',
      ),
      LyricLine(
        55.8,
        'Wait for it, it\'s tired and it\'s true',
        'Hãy chờ đợi, nó mệt mỏi nhưng có thật',
      ),
      LyricLine(
        67.7,
        'Wait for it, it\'s all she ever knew',
        'Hãy chờ đợi, đó là tất cả những gì nàng từng biết',
      ),
      LyricLine(79, 'She dreams in blue', 'Nàng mơ trong sắc xanh'),
      LyricLine(
        84.8,
        'Wait for it, it\'s all she ever knew',
        'Hãy chờ đợi, đó là tất cả những gì nàng từng biết',
      ),
      LyricLine(
        96.1,
        'The background hum of city streets',
        'Tiếng ồn nền của những con phố thành thị',
      ),
      LyricLine(
        107.1,
        'And whispers from the neighbors intertwine',
        'Và những lời thì thầm từ hàng xóm đan xen vào nhau',
      ),
      LyricLine(
        120.6,
        'The distant glow of beacon lights are',
        'Ánh sáng xa xăm từ những ngọn đèn hiệu',
      ),
      LyricLine(
        132.6,
        'Breaking through the cracks between the blinds',
        'Xuyên qua những khe hở giữa tấm rèm',
      ),
      LyricLine(
        147.4,
        'Wait for it, it\'s hiding out of view',
        'Hãy chờ đợi, nó đang ẩn mình khỏi tầm mắt',
      ),
      LyricLine(
        159,
        'Wait for it, it\'s all she ever knew',
        'Hãy chờ đợi, đó là tất cả những gì nàng từng biết',
      ),
      LyricLine(170.3, 'She dreams in blue', 'Nàng mơ trong sắc xanh'),
      LyricLine(
        176.1,
        'Wait for it, it\'s all she ever knew',
        'Hãy chờ đợi, đó là tất cả những gì nàng từng biết',
      ),
      LyricLine(
        187.4,
        'She opens up her weary eyes',
        'Nàng mở đôi mắt mệt mỏi của mình',
      ),
      LyricLine(
        196.1,
        'The foggy cloud of vision fills the air',
        'Màn sương mờ ảo lấp đầy không gian',
      ),
      LyricLine(
        208.7,
        'She strains to make some sense of all the',
        'Nàng cố gắng tìm ra ý nghĩa của tất cả',
      ),
      LyricLine(
        221.9,
        'Abstract shapes and colors everywhere',
        'Những hình khối và sắc màu trừu tượng khắp nơi',
      ),
      LyricLine(
        233.9,
        'But all the blue just fades away dissolving in a haze of grey',
        'Nhưng sắc xanh ấy cứ nhạt dần, tan biến trong làn sương xám',
      ),
      LyricLine(
        253.6,
        'And lost inside her empty mind is everything she tried to find',
        'Và lạc mất trong tâm trí trống rỗng là tất cả những gì nàng từng cố tìm kiếm',
      ),
      LyricLine(
        273.6,
        'And all the blue just fades away, she lost it in a haze of grey',
        'Và sắc xanh ấy cứ nhạt dần, nàng đánh mất nó trong làn sương xám',
      ),
      LyricLine(293.9, 'She dreams in blue', 'Nàng mơ trong sắc xanh'),
      LyricLine(
        299.7,
        'Wait for it, it\'s all she ever knew',
        'Hãy chờ đợi, đó là tất cả những gì nàng từng biết',
      ),
    ],
  ),
  Song(
    title: 'Swansong',
    artist: 'Josh Woodward',
    duration: '4:21',
    level: 'Trung cấp',
    color: AppColors.pink,
    audioUrl: '${_audioBaseUrl}swansong.mp3',
    lyrics: [
      LyricLine(
        5,
        'I never thought I\'d see the day',
        'Tôi chưa từng nghĩ mình sẽ thấy ngày này',
      ),
      LyricLine(
        13.3,
        'I thought that I had finally moved along',
        'Tôi tưởng rằng mình cuối cùng cũng đã bước tiếp',
      ),
      LyricLine(
        23.9,
        'And I had let you go so long ago, so long',
        'Và tôi đã buông em ra từ rất lâu rồi, rất lâu rồi',
      ),
      LyricLine(
        34.8,
        'This is not, this is not where I belong',
        'Đây không phải, đây không phải nơi tôi thuộc về',
      ),
      LyricLine(
        45.2,
        'So I wait for this shallow itch to pass',
        'Nên tôi chờ cơn ngứa ngáy nông cạn này qua đi',
      ),
      LyricLine(55.6, 'And I wait, yeah I wait', 'Và tôi chờ, vâng tôi chờ'),
      LyricLine(61.7, 'Hey hey, I\'m ok', 'Này này, tôi ổn mà'),
      LyricLine(
        66.5,
        'I don\'t need this anyway, I\'m fine',
        'Dù sao tôi cũng không cần điều này, tôi ổn',
      ),
      LyricLine(75.5, 'What\'s yours and mine', 'Cái gì là của em và của tôi'),
      LyricLine(81.1, 'Oh oh, I don\'t know', 'Ồ, tôi chẳng biết'),
      LyricLine(
        86.2,
        'What I was ever hoping I would find',
        'Điều tôi từng hy vọng mình sẽ tìm thấy là gì',
      ),
      LyricLine(
        95.5,
        'But it\'s time for me to leave this all behind',
        'Nhưng đã đến lúc tôi bỏ lại tất cả phía sau',
      ),
      LyricLine(
        107.5,
        'I don\'t regret a single thing',
        'Tôi chẳng hối tiếc một điều gì',
      ),
      LyricLine(
        115.2,
        'I couldn\'t say it didn\'t feel alright',
        'Tôi không thể nói là nó không ổn',
      ),
      LyricLine(
        125,
        'But I don\'t want to stay and I don\'t want to fight',
        'Nhưng tôi không muốn ở lại và cũng không muốn tranh cãi',
      ),
      LyricLine(
        138.4,
        'All alone, with my foolish appetite',
        'Chỉ một mình, với ham muốn dại khờ của tôi',
      ),
      LyricLine(
        147.7,
        'So I wait for this shallow itch to pass',
        'Nên tôi chờ cơn ngứa ngáy nông cạn này qua đi',
      ),
      LyricLine(158, 'And I wait, yeah I wait', 'Và tôi chờ, vâng tôi chờ'),
      LyricLine(164.2, 'Hey hey, I\'m ok', 'Này này, tôi ổn mà'),
      LyricLine(
        169,
        'I don\'t need this anyway, I\'m fine',
        'Dù sao tôi cũng không cần điều này, tôi ổn',
      ),
      LyricLine(178, 'What\'s yours and mine', 'Cái gì là của em và của tôi'),
      LyricLine(183.6, 'Oh oh, I don\'t know', 'Ồ, tôi chẳng biết'),
      LyricLine(
        188.7,
        'What I was ever hoping I would find',
        'Điều tôi từng hy vọng mình sẽ tìm thấy là gì',
      ),
      LyricLine(
        198,
        'But it\'s time for me to leave this all behind',
        'Nhưng đã đến lúc tôi bỏ lại tất cả phía sau',
      ),
      LyricLine(
        210,
        'I don\'t have the heart to give away to you again',
        'Tôi không còn đủ can đảm để trao trái tim mình cho em thêm lần nữa',
      ),
      LyricLine(
        222.7,
        'I don\'t have the stomach for it, no one ever wins',
        'Tôi không đủ dũng khí cho điều đó, chẳng ai thắng cuộc cả',
      ),
      LyricLine(
        235.8,
        'We had our fun but I have sung this song to you before',
        'Ta đã có những khoảnh khắc vui vẻ nhưng tôi từng hát bài này cho em nghe rồi',
      ),
      LyricLine(
        250.1,
        'Here\'s my last refrain',
        'Đây là điệp khúc cuối cùng của tôi',
      ),
    ],
  ),
  Song(
    title: 'The Box',
    artist: 'Josh Woodward',
    duration: '4:52',
    level: 'Trung cấp',
    color: AppColors.blue,
    audioUrl: '${_audioBaseUrl}the-box.mp3',
    lyrics: [
      LyricLine(
        6,
        'Underneath the stairs, on the basement floor',
        'Dưới gầm cầu thang, trên sàn tầng hầm',
      ),
      LyricLine(
        16.3,
        'Behind a stack of records and a plywood door',
        'Sau chồng đĩa nhạc cũ và cánh cửa gỗ ép',
      ),
      LyricLine(
        26.6,
        'There’s a cardboard box, with a coat of dust',
        'Có một chiếc hộp các-tông, phủ đầy bụi',
      ),
      LyricLine(
        36.9,
        'I brought it from your attic with your other stuff',
        'Tôi mang nó từ gác mái của em cùng những món đồ khác',
      ),
      LyricLine(
        48.5,
        'And on the side, it says “photographs and memories” in black',
        'Bên cạnh hộp, dòng chữ đen ghi "ảnh chụp và kỷ niệm"',
      ),
      LyricLine(
        62.6,
        'And I’ve tried, to avoid it but I want you back',
        'Tôi đã cố tránh né nó nhưng tôi muốn em quay lại',
      ),
      LyricLine(
        73.5,
        'This was Cedar Point, maybe ‘83',
        'Đây là Cedar Point, có lẽ vào năm \'83',
      ),
      LyricLine(
        80.8,
        'I got queasy on the coaster so you sat with me',
        'Tôi say tàu lượn nên em đã ngồi cạnh tôi',
      ),
      LyricLine(
        91.5,
        'And the kids all laughed, but I didn’t care',
        'Bọn trẻ đều cười, nhưng tôi chẳng bận tâm',
      ),
      LyricLine(
        101.6,
        'They were flashes in the pan, but you were always there',
        'Chúng chỉ là những khoảnh khắc thoáng qua, nhưng em thì luôn ở đó',
      ),
      LyricLine(
        114.4,
        'Even when, I got older and I thought I was cool, but I was cruel',
        'Ngay cả khi tôi lớn hơn và tưởng mình ngầu, nhưng tôi đã thật tàn nhẫn',
      ),
      LyricLine(
        129.4,
        'I still loved you and you somehow knew',
        'Tôi vẫn yêu em và bằng cách nào đó em đã biết',
      ),
      LyricLine(
        138.3,
        'Graduation day, I was moving on',
        'Ngày tốt nghiệp, tôi đang bước tiếp',
      ),
      LyricLine(
        145.5,
        'We’re posing on the corner of the high school lawn',
        'Ta tạo dáng chụp ảnh nơi góc sân trường trung học',
      ),
      LyricLine(
        157.2,
        'You were smiling wide, but I now can see',
        'Em cười thật tươi, nhưng giờ tôi mới nhận ra',
      ),
      LyricLine(
        166.6,
        'You were torn up at the thought of slowly losing me',
        'Em đã đau lòng khi nghĩ đến việc dần mất tôi',
      ),
      LyricLine(
        178.5,
        'And now I know, you were also slowly losing yourself',
        'Và giờ tôi biết, em cũng đang dần đánh mất chính mình',
      ),
      LyricLine(
        190.6,
        'But you held, all the pieces tied together so well',
        'Nhưng em đã giữ mọi mảnh ghép gắn kết thật tốt',
      ),
      LyricLine(
        202.3,
        'In the Florida sun, on the crowded coast',
        'Dưới nắng Florida, trên bờ biển đông đúc',
      ),
      LyricLine(
        211.7,
        'The picture is so faded that we look like ghosts',
        'Bức ảnh đã phai màu đến mức ta trông như những bóng ma',
      ),
      LyricLine(
        222.9,
        'You were made of sand, in a castle skin',
        'Em được tạo nên từ cát, khoác lớp vỏ lâu đài',
      ),
      LyricLine(
        232,
        'There was beauty for a moment till the tide rolled in',
        'Có vẻ đẹp thoáng qua cho đến khi con nước tràn vào',
      ),
      LyricLine(
        244.4,
        'But I still taste, the faintest touch of salt in the air, we’re still there',
        'Nhưng tôi vẫn cảm nhận được chút vị mặn thoảng trong không khí, ta vẫn còn ở đó',
      ),
      LyricLine(
        261.9,
        'You’re the summer breeze that ruffles my hair',
        'Em là làn gió mùa hè lay động mái tóc tôi',
      ),
      LyricLine(
        272.4,
        'In the box beneath the stairs',
        'Trong chiếc hộp dưới gầm cầu thang',
      ),
      LyricLine(
        279.2,
        'In the box beneath the stairs',
        'Trong chiếc hộp dưới gầm cầu thang',
      ),
    ],
  ),
  Song(
    title: 'The Long Fade',
    artist: 'Josh Woodward',
    duration: '4:50',
    level: 'Nâng cao',
    color: AppColors.purple,
    audioUrl: '${_audioBaseUrl}the-long-fade.mp3',
    lyrics: [
      LyricLine(
        8,
        'It\'s a long fade, down to blank tape',
        'Đó là một sự phai nhạt kéo dài, đến tận cuốn băng trống',
      ),
      LyricLine(
        26.2,
        'I\'ve never been too good at goodbyes',
        'Tôi chưa bao giờ giỏi nói lời tạm biệt',
      ),
      LyricLine(
        44.4,
        'There\'s no ending, just extending',
        'Chẳng có hồi kết, chỉ có kéo dài mãi',
      ),
      LyricLine(
        61.1,
        'Past infinity, the band is playing on',
        'Vượt qua cả vô tận, ban nhạc vẫn cứ chơi tiếp',
      ),
      LyricLine(
        79.8,
        'The party never stops',
        'Bữa tiệc chẳng bao giờ dừng lại',
      ),
      LyricLine(90.4, 'The coda never drops', 'Đoạn kết chẳng bao giờ đến'),
      LyricLine(
        100.5,
        'The dream it never sees the light of day',
        'Giấc mơ ấy chẳng bao giờ thấy được ánh sáng ban ngày',
      ),
      LyricLine(
        120.7,
        'A sound repeating, is slowly fleeting',
        'Một âm thanh lặp lại, đang dần phai nhạt',
      ),
      LyricLine(
        139.4,
        'It\'s feeding back forever in a loop',
        'Nó cứ vọng lại mãi mãi trong một vòng lặp',
      ),
      LyricLine(
        157.1,
        'But every mirror, becomes less clearer',
        'Nhưng mỗi tấm gương, lại càng thêm mờ đục',
      ),
      LyricLine(
        176.3,
        'A fuzzy haze descends upon the room',
        'Một làn sương mờ ảo phủ xuống căn phòng',
      ),
      LyricLine(194, 'The blemishes compound', 'Những vết xước cứ chồng chất'),
      LyricLine(205.2, 'And chip away the sound', 'Và bào mòn dần âm thanh'),
      LyricLine(
        216.8,
        'Until the hands of entropy take hold',
        'Cho đến khi bàn tay của sự hỗn loạn nắm quyền kiểm soát',
      ),
      LyricLine(
        235,
        'I won\'t let go, of your echo',
        'Tôi sẽ không buông tay, khỏi tiếng vọng của em',
      ),
      LyricLine(
        249.1,
        'I won\'t let you fade to nothing',
        'Tôi sẽ không để em phai nhạt thành hư vô',
      ),
      LyricLine(
        264.8,
        'I won\'t let go, of your echo, dear',
        'Tôi sẽ không buông tay, khỏi tiếng vọng của em, em yêu à',
      ),
    ],
  ),
  Song(
    title: 'The Maze',
    artist: 'Josh Woodward',
    duration: '2:47',
    level: 'Trung cấp',
    color: AppColors.teal,
    audioUrl: '${_audioBaseUrl}the-maze.mp3',
    lyrics: [
      LyricLine(
        5,
        'Inside every mind, if you look, you will find',
        'Trong tâm trí mỗi người, nếu bạn nhìn kỹ, bạn sẽ thấy',
      ),
      LyricLine(
        12.1,
        'There’s a child who never grew old',
        'Có một đứa trẻ chưa bao giờ lớn lên',
      ),
      LyricLine(
        17.4,
        'Who sings to the trees, like nobody can see',
        'Nó hát cho hàng cây nghe, mà chẳng ai nhìn thấy',
      ),
      LyricLine(
        24.1,
        'With a fire that never went cold',
        'Với một ngọn lửa chưa bao giờ nguội lạnh',
      ),
      LyricLine(
        29.2,
        'He looks up to the stars, and the moon, and at Mars',
        'Nó ngước nhìn những vì sao, mặt trăng, và sao Hỏa',
      ),
      LyricLine(
        37.2,
        'And the endless expanse of the sky',
        'Và khoảng không vô tận của bầu trời',
      ),
      LyricLine(
        42.5,
        'Devoid of all doubt, just a question of how',
        'Không chút nghi ngờ, chỉ băn khoăn làm cách nào',
      ),
      LyricLine(
        49.2,
        'To climb up to the heavens and fly',
        'Để trèo lên tận trời cao và bay đi',
      ),
      LyricLine(54.6, 'But time is advancing', 'Nhưng thời gian cứ thế trôi'),
      LyricLine(57.9, 'A drip, then a flood', 'Một giọt, rồi thành cơn lũ'),
      LyricLine(
        61,
        'He’s adrift while you’re stuck on the shore',
        'Nó chông chênh trong khi bạn mắc kẹt trên bờ',
      ),
      LyricLine(
        67.7,
        'And he sails away to the depths of our brains',
        'Và nó trôi dạt vào sâu trong tâm trí ta',
      ),
      LyricLine(
        74.8,
        'And we can’t seem to dream anymore',
        'Và ta dường như không thể mơ mộng được nữa',
      ),
      LyricLine(
        80.1,
        'With the passing of days, we get lost in the maze',
        'Ngày qua ngày, ta lạc lối trong mê cung',
      ),
      LyricLine(
        87.8,
        'That we built out of habit and fear',
        'Mà ta tự xây nên từ thói quen và nỗi sợ',
      ),
      LyricLine(
        93.3,
        'The longer we run, the more lost we become',
        'Càng chạy trốn lâu, ta càng lạc lối hơn',
      ),
      LyricLine(
        99.9,
        'As the days disappear into years',
        'Khi ngày tháng cứ thế trôi thành năm',
      ),
      LyricLine(
        104.9,
        'When we’re sleeping in bed, the child in our heads',
        'Khi ta ngủ trên giường, đứa trẻ trong tâm trí ta',
      ),
      LyricLine(
        112.8,
        'Is reminding us how to break out',
        'Vẫn nhắc ta cách thoát ra',
      ),
      LyricLine(
        117.8,
        'But the moment we wake, it just up and escapes',
        'Nhưng vừa tỉnh giấc, nó liền biến mất',
      ),
      LyricLine(
        125,
        'And we’re back to the fear and doubt',
        'Và ta lại quay về với nỗi sợ và hoài nghi',
      ),
      LyricLine(
        130.6,
        'But the answer’s inside us, it never did leave',
        'Nhưng câu trả lời vẫn luôn ở trong ta, chưa từng rời đi',
      ),
      LyricLine(
        137.8,
        'We just never believed it before',
        'Chỉ là ta chưa từng tin vào nó',
      ),
      LyricLine(
        142.9,
        'Well, I’m done with the maze for the rest of my days',
        'Thôi, tôi sẽ không lạc trong mê cung này nữa suốt quãng đời còn lại',
      ),
      LyricLine(
        151,
        'I’m not wasting my dreams anymore',
        'Tôi sẽ không lãng phí những giấc mơ của mình nữa',
      ),
      LyricLine(
        156.2,
        'No, I’m not wasting my dreams anymore',
        'Không, tôi sẽ không lãng phí những giấc mơ của mình nữa',
      ),
    ],
  ),
  Song(
    title: 'The Nest',
    artist: 'Josh Woodward',
    duration: '3:21',
    level: 'Cơ bản',
    color: AppColors.amber,
    audioUrl: '${_audioBaseUrl}the-nest.mp3',
    lyrics: [
      LyricLine(
        5,
        'The broken wing, it didn’t last a spring',
        'Chiếc cánh gãy ấy, chẳng trụ được qua một mùa xuân',
      ),
      LyricLine(
        18.1,
        'You shoved me out, before the nest was cold',
        'Người đã đẩy tôi ra ngoài, trước khi tổ ấm kịp lạnh',
      ),
      LyricLine(
        32.2,
        'I couldn\'t fly, but god I tried',
        'Tôi không thể bay, nhưng trời ơi tôi đã cố',
      ),
      LyricLine(
        42.3,
        'I hit the ground, and I was on my own',
        'Tôi rơi xuống đất, và chỉ còn lại một mình',
      ),
      LyricLine(
        54.5,
        'Alone in the big blue land',
        'Một mình giữa vùng đất xanh thẳm rộng lớn',
      ),
      LyricLine(
        63,
        'With only my legs to stand',
        'Chỉ còn đôi chân để đứng vững',
      ),
      LyricLine(
        71.5,
        'And no one to lend a hand, or to pick me up',
        'Và chẳng ai đưa tay giúp đỡ, hay đỡ tôi dậy',
      ),
      LyricLine(
        85.6,
        'I see the sky, where you would fly',
        'Tôi nhìn lên bầu trời, nơi người từng bay lượn',
      ),
      LyricLine(
        96.7,
        'And I would wait for you so patiently',
        'Và tôi đã kiên nhẫn chờ đợi người biết bao',
      ),
      LyricLine(
        108.9,
        'But I was weak, and soon I had an empty beak',
        'Nhưng tôi quá yếu ớt, và chẳng mấy chốc chiếc mỏ tôi trống rỗng',
      ),
      LyricLine(
        123.3,
        'I guess I wasn\'t worth the time',
        'Tôi đoán mình chẳng đáng để người bỏ thời gian',
      ),
      LyricLine(
        133.4,
        'And I never had the chance',
        'Và tôi chẳng bao giờ có cơ hội',
      ),
      LyricLine(
        141.9,
        'To float in a weightless dance',
        'Để bay lượn trong điệu nhảy không trọng lượng',
      ),
      LyricLine(
        151.8,
        'To swim in the great expanse above me',
        'Để bơi giữa khoảng không bao la trên đầu mình',
      ),
      LyricLine(163.9, 'The gravity holds me down', 'Trọng lực cứ giữ tôi lại'),
      LyricLine(
        172.1,
        'I’ll never escape the ground',
        'Tôi sẽ chẳng bao giờ thoát khỏi mặt đất',
      ),
      LyricLine(
        181.3,
        'To live in the careless clouds where I belong',
        'Để sống giữa những đám mây vô tư nơi tôi thuộc về',
      ),
    ],
  ),
];
