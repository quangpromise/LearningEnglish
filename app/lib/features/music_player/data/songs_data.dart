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
/// `startSeconds` được canh bằng forced-alignment tự động (ASR - xem
/// scripts/realign_lyrics.py) khớp với timestamp cấp-từ thật lấy từ chính
/// file audio, KHÔNG còn là ước lượng theo tỉ lệ độ dài câu như trước. Một
/// số ít dòng (ASR không nhận diện khớp được, vd đoạn nhạc nền át giọng)
/// vẫn giữ giá trị ước lượng cũ - xem ghi chú trong
/// docs/research-music-libraries.md. Chạy lại script trên khi thêm bài mới
/// hoặc muốn canh lại chính xác hơn.
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
        9.7,
        'Cold hands, sore feet',
        'Đôi tay lạnh cóng, đôi chân rã rời',
      ),
      LyricLine(
        14.4,
        "You've been walking for an hour on abandoned streets",
        'Bạn đã đi bộ hàng giờ trên những con phố hoang vắng',
      ),
      LyricLine(
        20.1,
        'Weak knees, and fresh scars',
        'Đầu gối run rẩy, và những vết sẹo còn mới',
      ),
      LyricLine(
        24.8,
        "It's a struggle when you're losing track of who you are",
        'Thật chật vật khi bạn dần quên mất mình là ai',
      ),
      LyricLine(
        28.9,
        "The words you stole won't save your soul",
        'Những lời bạn đánh cắp không cứu được tâm hồn bạn',
      ),
      LyricLine(
        34.2,
        'They can only buy you time',
        'Chúng chỉ giúp bạn có thêm chút thời gian',
      ),
      LyricLine(
        41.3,
        'Light a candle, or curse the dark',
        'Thắp một ngọn nến, hay nguyền rủa bóng tối',
      ),
      LyricLine(
        52.3,
        "It's all the same to me",
        'Với tôi, điều đó chẳng khác gì nhau',
      ),
      LyricLine(
        60.8,
        'Start a fire, or drown the spark',
        'Nhóm lên một ngọn lửa, hay dập tắt tia lửa ấy',
      ),
      LyricLine(76.4, 'And shake away the heat', 'Rồi rũ bỏ hơi ấm đi'),
      LyricLine(
        84.7,
        'Tell the truth or live a lie',
        'Nói thật, hay sống trong dối trá',
      ),
      LyricLine(
        85.9,
        "Just don't close your eyes",
        'Chỉ xin đừng nhắm mắt lại',
      ),
      LyricLine(86.8, 'Let down, and so spent', 'Thất vọng, và kiệt sức'),
      LyricLine(
        87.4,
        "You've been holding up the world with your good intent",
        'Bạn đã gồng gánh cả thế giới bằng thiện chí của mình',
      ),
      LyricLine(
        88.8,
        'Help out, like you should',
        'Giúp đỡ người khác, như bạn vẫn nên làm',
      ),
      LyricLine(
        97.8,
        "It's a burden that you never really understood",
        'Đó là gánh nặng mà bạn chưa từng thực sự hiểu',
      ),
      LyricLine(
        100.7,
        "But Caroline, I'm doing fine",
        'Nhưng Caroline à, tôi vẫn ổn',
      ),
      LyricLine(
        107.4,
        "It's the others who are dying",
        'Chính những người khác mới đang gục ngã',
      ),
      LyricLine(
        120.4,
        'Light a candle, or curse the dark',
        'Thắp một ngọn nến, hay nguyền rủa bóng tối',
      ),
      LyricLine(
        120.9,
        "It's all the same to me",
        'Với tôi, điều đó chẳng khác gì nhau',
      ),
      LyricLine(
        122.2,
        'Start a fire, or drown the spark',
        'Nhóm lên một ngọn lửa, hay dập tắt tia lửa ấy',
      ),
      LyricLine(127.7, 'And shake away the heat', 'Rồi rũ bỏ hơi ấm đi'),
      LyricLine(
        133.1,
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
        151.3,
        "Just don't close your eyes",
        'Chỉ xin đừng nhắm mắt lại',
      ),
      LyricLine(152.2, "And you're breaking", 'Và bạn đang vỡ vụn'),
      LyricLine(
        152.8,
        "But you're faking nothing's ever wrong",
        'Nhưng bạn giả vờ như chẳng có gì sai',
      ),
      LyricLine(
        154.2,
        "And concealing what you're feeling",
        'Che giấu đi những gì bạn đang cảm nhận',
      ),
      LyricLine(154.6, 'Always standing strong', 'Luôn tỏ ra mạnh mẽ'),
      LyricLine(154.9, "But you don't need", 'Nhưng bạn đâu cần phải'),
      LyricLine(
        155.1,
        "To act like you don't bleed",
        'Giả vờ như mình không hề đau',
      ),
      LyricLine(155.2, 'When you come falling down', 'Khi bạn đang gục ngã'),
      LyricLine(
        155.3,
        "Cuz there is no healing when you're not feeling",
        'Vì sẽ chẳng thể chữa lành nếu bạn không cho phép mình cảm nhận',
      ),
      LyricLine(155.5, 'Anything at all', 'Bất cứ điều gì'),
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
        1.4,
        "You're crying in your Mazda 3",
        'Bạn đang khóc trong chiếc Mazda 3 của mình',
      ),
      LyricLine(
        6.4,
        'Trying just to focus and breathe',
        'Cố gắng tập trung và hít thở',
      ),
      LyricLine(
        11.3,
        'You gave him another shot, but you forgot',
        'Bạn đã cho anh ta thêm một cơ hội, nhưng bạn quên mất',
      ),
      LyricLine(16.5, 'His aim is never true', 'Anh ta chưa bao giờ thật lòng'),
      LyricLine(
        194.5,
        'When you gonna open your eyes?',
        'Khi nào bạn mới chịu mở mắt ra?',
      ),
      LyricLine(
        195.1,
        'The wolf is in another disguise',
        'Con sói lại khoác lên một lớp ngụy trang khác',
      ),
      LyricLine(
        196.5,
        'Convincing apologies on bended knee',
        'Những lời xin lỗi quỳ gối đầy thuyết phục',
      ),
      LyricLine(
        198,
        'The poison in a silver spoon',
        'Chất độc trong chiếc thìa bạc',
      ),
      LyricLine(
        199.1,
        'Stand and wave, the grand parade',
        'Đứng đó vẫy tay, cuộc diễu hành hoành tráng',
      ),
      LyricLine(
        199.8,
        'Marching in circles in the pouring rain',
        'Diễu hành vòng quanh trong cơn mưa tầm tã',
      ),
      LyricLine(
        200.3,
        "It's just a turn to run away but",
        'Đây chỉ là lượt để bỏ chạy, nhưng',
      ),
      LyricLine(201.5, 'No, no, ohh', 'Không, không, ồ'),
      LyricLine(
        202.1,
        'Dizzy on the merry-go-round',
        'Chóng mặt trên vòng quay ngựa gỗ',
      ),
      LyricLine(
        203.5,
        'Yearning for your feet on the ground',
        'Khao khát được đặt chân xuống mặt đất',
      ),
      LyricLine(
        204.5,
        "For only a moment's rest to catch your breath",
        'Chỉ để nghỉ một chút, lấy lại hơi thở',
      ),
      LyricLine(
        205.5,
        'To clear your cloudy mind',
        'Để làm quang đãng tâm trí đang mù mịt',
      ),
      LyricLine(
        207,
        "The promises that he's going to change",
        'Những lời hứa rằng anh ta sẽ thay đổi',
      ),
      LyricLine(
        208.1,
        'They wash away like chalk in the rain',
        'Chúng trôi đi như phấn gặp mưa',
      ),
      LyricLine(
        208.8,
        'The moment the storm descends, the pageant ends',
        'Khoảnh khắc cơn bão ập đến, màn kịch cũng kết thúc',
      ),
      LyricLine(209.3, 'Exhausted and resigned', 'Kiệt sức và cam chịu'),
      LyricLine(
        210.5,
        'Paradise at any price',
        'Thiên đường bằng bất cứ giá nào',
      ),
      LyricLine(
        211.5,
        "You're skating circles on the thinning ice",
        'Bạn đang trượt vòng quanh trên lớp băng mỏng dần',
      ),
      LyricLine(
        212.5,
        "Just a turn to save your life but",
        'Chỉ cần một lượt để cứu lấy đời mình, nhưng',
      ),
      LyricLine(213.5, 'No, no, ohh', 'Không, không, ồ'),
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
        19.7,
        "We're in the same boat",
        'Chúng ta cùng chung một con thuyền',
      ),
      LyricLine(
        24.6,
        'Heading for different shores',
        'Nhưng hướng đến những bến bờ khác nhau',
      ),
      LyricLine(30.2, 'Facing each other', 'Đối diện nhau'),
      LyricLine(
        34.1,
        'Grasping at different oars',
        'Mỗi người nắm một mái chèo riêng',
      ),
      LyricLine(
        41.9,
        "We're cornered in a stalemate",
        'Chúng ta mắc kẹt trong thế bế tắc',
      ),
      LyricLine(
        45.9,
        "But the sun is down, it's getting late",
        'Nhưng mặt trời đã lặn, trời cũng đã muộn',
      ),
      LyricLine(51.8, "I've either gotta turn around", 'Tôi phải quay đầu lại'),
      LyricLine(55.5, 'Or learn how to swim', 'Hoặc học cách tự bơi'),
      LyricLine(
        61.2,
        "We're in the same boat",
        'Chúng ta cùng chung một con thuyền',
      ),
      LyricLine(
        65.9,
        'Heading for different shores',
        'Nhưng hướng đến những bến bờ khác nhau',
      ),
      LyricLine(71.3, 'Should I take a break', 'Tôi nên dừng lại nghỉ ngơi'),
      LyricLine(
        74.3,
        'Or throw myself overboard?',
        'Hay nhảy hẳn khỏi thuyền?',
      ),
      LyricLine(
        82.3,
        'Do I find another way back home',
        'Tôi có nên tìm đường khác để về nhà',
      ),
      LyricLine(
        86.8,
        'Or take a leap into the great unknown',
        'Hay liều mình bước vào miền vô định',
      ),
      LyricLine(93.7, "I've either gotta turn around", 'Tôi phải quay đầu lại'),
      LyricLine(96.9, 'Or learn how to swim', 'Hoặc học cách tự bơi'),
      LyricLine(
        143.5,
        "We're in the same boat",
        'Chúng ta cùng chung một con thuyền',
      ),
      LyricLine(
        148.1,
        'Heading for different shores',
        'Nhưng hướng đến những bến bờ khác nhau',
      ),
      LyricLine(153.9, "I've chosen my path", 'Tôi đã chọn con đường của mình'),
      LyricLine(
        159.1,
        "And you've chosen yours",
        'Và bạn cũng đã chọn con đường của bạn',
      ),
      LyricLine(
        165.4,
        'I look away and dive right in',
        'Tôi ngoảnh mặt đi và lao thẳng xuống nước',
      ),
      LyricLine(
        169.9,
        'The frigid water stings my skin',
        'Làn nước lạnh buốt cứa vào da tôi',
      ),
      LyricLine(176.6, "I'm either gonna fade away", 'Tôi sẽ dần biến mất'),
      LyricLine(179.3, 'Or learn how to swim', 'Hoặc học cách tự bơi'),
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
      LyricLine(11.2, 'I saved the world', 'Tôi đã cứu cả thế giới'),
      LyricLine(15.1, 'And made it mine', 'Và biến nó thành của riêng tôi'),
      LyricLine(
        18.2,
        'Now I\'m the air and the sunshine',
        'Giờ đây tôi chính là không khí và ánh mặt trời',
      ),
      LyricLine(22.7, 'Look on my works', 'Hãy nhìn vào những gì tôi làm nên'),
      LyricLine(25.8, 'They\'re pretty sweet', 'Chúng thật tuyệt vời'),
      LyricLine(
        27.8,
        'The rest of history is obsolete',
        'Phần còn lại của lịch sử đã lỗi thời',
      ),
      LyricLine(
        32.4,
        'This whole place was a lousy disgrace',
        'Cả nơi này từng là một nỗi hổ thẹn thảm hại',
      ),
      LyricLine(
        37.6,
        'Before I came along to lead',
        'Trước khi tôi xuất hiện để dẫn dắt',
      ),
      LyricLine(
        43,
        'I gave chase to the weak and the fake',
        'Tôi truy đuổi những kẻ yếu đuối và giả tạo',
      ),
      LyricLine(
        47.8,
        'And scattered them away like sheep',
        'Và xua họ đi như một bầy cừu',
      ),
      LyricLine(53.3, 'My earthly frame', 'Tấm thân trần thế của tôi'),
      LyricLine(56.1, 'Will soon dissolve', 'Rồi sẽ sớm tan biến'),
      LyricLine(
        58.5,
        'They\'ll build a statue that\'s a mile tall',
        'Họ sẽ dựng nên một bức tượng cao cả dặm',
      ),
      LyricLine(63.6, 'The future kings', 'Những vị vua tương lai'),
      LyricLine(66.3, 'Will all despair', 'Rồi sẽ phải tuyệt vọng'),
      LyricLine(
        68.1,
        'They\'ll gaze upon me with a reverent stare',
        'Họ sẽ nhìn tôi với ánh mắt đầy tôn kính',
      ),
      LyricLine(
        73.4,
        'They\'ll cry to my soul in the sky',
        'Họ sẽ khóc gọi linh hồn tôi trên bầu trời',
      ),
      LyricLine(
        78.5,
        'Searching for my sage advice',
        'Tìm kiếm lời khuyên khôn ngoan của tôi',
      ),
      LyricLine(
        83.7,
        'But not one in the ages to come',
        'Nhưng chẳng một ai trong những thế hệ mai sau',
      ),
      LyricLine(
        89,
        'Will ever reach my soaring heights',
        'Có thể vươn tới tầm cao mà tôi đã đạt được',
      ),
      LyricLine(
        94.8,
        'Kingdoms fall and castles crumble',
        'Vương quốc sụp đổ, lâu đài tan vỡ',
      ),
      LyricLine(
        99,
        'But I will never disappear',
        'Nhưng tôi sẽ không bao giờ biến mất',
      ),
      LyricLine(
        105.3,
        'Fortunes fade and legends stumble',
        'Vận may phai nhạt, huyền thoại vấp ngã',
      ),
      LyricLine(
        108.2,
        'But I will reign a thousand years',
        'Nhưng tôi sẽ trị vì suốt ngàn năm',
      ),
      LyricLine(
        138.6,
        'Some say that I’m petty and vain',
        'Có người bảo tôi nhỏ nhen và kiêu ngạo',
      ),
      LyricLine(
        142.1,
        'I know you are but what am I?',
        'Tôi biết anh cũng vậy, nhưng còn tôi thì sao?',
      ),
      LyricLine(
        148,
        'I\'m too strong to ever be wrong',
        'Tôi quá mạnh mẽ để có thể sai lầm',
      ),
      LyricLine(
        152.5,
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
        20.7,
        'The skies are cold and gray',
        'Bầu trời lạnh lẽo và xám xịt',
      ),
      LyricLine(26.9, 'The storm is on its way', 'Cơn bão đang kéo đến'),
      LyricLine(
        32.5,
        'The flat horizon, leafless trees, there\'s nothing far as you can see, out here',
        'Đường chân trời phẳng lặng, hàng cây trơ trụi lá, chẳng có gì để thấy xa hơn nơi đây',
      ),
      LyricLine(
        43.9,
        'You shiver like a waif',
        'Em run rẩy như một đứa trẻ lạc loài',
      ),
      LyricLine(
        56,
        'Your snow boot soles are chafed',
        'Đế giày tuyết của em đã mòn',
      ),
      LyricLine(
        57.8,
        'You left your heart in paradise, you left it all to roll the dice with me',
        'Em bỏ lại trái tim mình nơi thiên đường, bỏ lại tất cả để đánh cược cùng tôi',
      ),
      LyricLine(
        64,
        'And I will shake away the cloudy skies',
        'Và tôi sẽ xua tan bầu trời u ám',
      ),
      LyricLine(
        76.9,
        'With a California lullabye',
        'Bằng một khúc ru California',
      ),
      LyricLine(
        80.6,
        'And when you\'re frozen with desire',
        'Và khi em run rẩy vì khao khát',
      ),
      LyricLine(
        83.8,
        'We\'ll put our toes up to the fire',
        'Ta sẽ đưa chân sưởi ấm bên lửa',
      ),
      LyricLine(
        86.7,
        'And I will sing your cares away',
        'Và tôi sẽ hát cho nỗi lo của em tan biến',
      ),
      LyricLine(
        88.8,
        'The sand between my toes',
        'Cát giữa những ngón chân tôi',
      ),
      LyricLine(
        93.6,
        'Your hands beneath my clothes',
        'Bàn tay em luồn dưới lớp áo tôi',
      ),
      LyricLine(
        98.3,
        'The memories of golden days, where first we met, and parted ways so soon',
        'Những kỷ niệm ngày vàng son, nơi ta gặp nhau lần đầu, rồi vội chia xa',
      ),
      LyricLine(
        105.9,
        'But distance lost its fight',
        'Nhưng khoảng cách đã thua cuộc',
      ),
      LyricLine(
        114.5,
        'When you laid down at night',
        'Khi em nằm xuống trong đêm',
      ),
      LyricLine(
        120.6,
        'Without a map, you chose your heart, now we are one, but you\'re still far from home',
        'Không cần bản đồ, em chọn theo trái tim, giờ ta là một, nhưng em vẫn còn xa nhà',
      ),
      LyricLine(
        129.5,
        'So let me shake away the cloudy skies',
        'Vậy hãy để tôi xua tan bầu trời u ám',
      ),
      LyricLine(
        142.4,
        'With a California lullabye',
        'Bằng một khúc ru California',
      ),
      LyricLine(
        146.1,
        'And when you\'re frozen with desire',
        'Và khi em run rẩy vì khao khát',
      ),
      LyricLine(
        154.7,
        'We\'ll put our toes up to the fire',
        'Ta sẽ đưa chân sưởi ấm bên lửa',
      ),
      LyricLine(
        157.1,
        'And I will sing your cares away',
        'Và tôi sẽ hát cho nỗi lo của em tan biến',
      ),
      LyricLine(
        159.2,
        'And when you\'re frozen with desire',
        'Và khi em run rẩy vì khao khát',
      ),
      LyricLine(
        164.1,
        'We\'ll put our toes up to the fire',
        'Ta sẽ đưa chân sưởi ấm bên lửa',
      ),
      LyricLine(
        164.3,
        'And I will sing your cares away',
        'Và tôi sẽ hát cho nỗi lo của em tan biến',
      ),
      LyricLine(
        164.9,
        'I know it feels, like spinning wheels aredigging you much deeper in the snow',
        'Tôi biết cảm giác như những bánh xe đang xoay, kéo em lún sâu hơn vào tuyết',
      ),
      LyricLine(
        178.5,
        'Don\'t worry, ‘cause the winter thaws, and you will watch the river start to flow',
        'Đừng lo, vì mùa đông rồi sẽ tan, và em sẽ thấy dòng sông bắt đầu chảy',
      ),
      LyricLine(
        206.4,
        'And in that place, the empty space, will fill you in a warm embrace',
        'Và nơi khoảng trống ấy, sẽ được lấp đầy bằng một vòng tay ấm áp',
      ),
      LyricLine(
        228.3,
        'And I will hold you tight until it\'s home',
        'Và tôi sẽ ôm em thật chặt cho đến khi về đến nhà',
      ),
      LyricLine(
        228.7,
        'I will shake away the cloudy skies',
        'Tôi sẽ xua tan bầu trời u ám',
      ),
      LyricLine(
        229.6,
        'With a California lullabye',
        'Bằng một khúc ru California',
      ),
      LyricLine(
        233.3,
        'And when you\'re frozen with desire',
        'Và khi em run rẩy vì khao khát',
      ),
      LyricLine(
        239,
        'We\'ll put our toes up to the fire',
        'Ta sẽ đưa chân sưởi ấm bên lửa',
      ),
      LyricLine(
        252.4,
        'And I will sing your cares away',
        'Và tôi sẽ hát cho nỗi lo của em tan biến',
      ),
      LyricLine(
        253.4,
        'Now let me take you back to paradise',
        'Giờ hãy để tôi đưa em trở lại thiên đường',
      ),
      LyricLine(
        254.4,
        'All you gotta do is close your eyes',
        'Em chỉ cần nhắm mắt lại thôi',
      ),
      LyricLine(
        255.4,
        'And when you\'re frozen with desire',
        'Và khi em run rẩy vì khao khát',
      ),
      LyricLine(
        256.4,
        'We\'ll put our toes up to the fire',
        'Ta sẽ đưa chân sưởi ấm bên lửa',
      ),
      LyricLine(
        257.4,
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
      LyricLine(16.3, 'Running in the sand', 'Chạy trên cát'),
      LyricLine(17.6, 'Living on the land', 'Sống trên mảnh đất này'),
      LyricLine(
        20.8,
        'The salty breeze was in our eyes',
        'Làn gió mặn mòi lùa vào mắt ta',
      ),
      LyricLine(
        24.7,
        'We stood beneath the dragonflies and danced all night',
        'Ta đứng dưới đàn chuồn chuồn và nhảy múa suốt đêm',
      ),
      LyricLine(44.8, 'We polished all the chrome', 'Ta đánh bóng cả lớp crôm'),
      LyricLine(
        48.3,
        'On our rusty little home',
        'Trên ngôi nhà nhỏ đã hoen gỉ của mình',
      ),
      LyricLine(
        49.9,
        'We slept all night in parking lots',
        'Ta ngủ suốt đêm trong những bãi đỗ xe',
      ),
      LyricLine(
        51,
        'We tied our hearts in double knots, so tight',
        'Ta buộc chặt trái tim mình bằng những nút thắt đôi',
      ),
      LyricLine(53.7, 'So free, so right', 'Thật tự do, thật đúng đắn'),
      LyricLine(63.3, 'Remember when', 'Còn nhớ không'),
      LyricLine(
        65.1,
        'We were just cherubs in our tender skins',
        'Ta từng chỉ là những thiên thần nhỏ trong lớp da non nớt',
      ),
      LyricLine(
        72,
        'Waiting patiently for life to begin',
        'Kiên nhẫn chờ cuộc sống bắt đầu',
      ),
      LyricLine(85.1, 'Flowing so free', 'Trôi thật tự do'),
      LyricLine(88, 'Blowing in the breeze', 'Lay động trong làn gió'),
      LyricLine(
        91.2,
        'The songs we sung so long ago',
        'Những bài ca ta từng hát từ rất lâu',
      ),
      LyricLine(
        94.2,
        'With whiskey and an afterglow, we shined like new',
        'Cùng rượu whiskey và ánh hoàng hôn, ta rực rỡ như mới',
      ),
      LyricLine(108.6, 'But there along the way', 'Nhưng rồi trên đường đi'),
      LyricLine(
        112.2,
        'Something seemed to change',
        'Có điều gì đó dường như đổi thay',
      ),
      LyricLine(
        114.3,
        'As weeks turned into months we knew',
        'Khi từng tuần hoá thành từng tháng, ta nhận ra',
      ),
      LyricLine(
        117.6,
        'As life caught up we slowly grew, apart',
        'Khi cuộc sống ập đến, ta dần lớn lên, xa cách nhau',
      ),
      LyricLine(
        122.6,
        'And untied our hearts',
        'Và cởi bỏ những nút thắt trái tim',
      ),
      LyricLine(
        153.7,
        'The summer went away and the skies went gray',
        'Mùa hè trôi qua và bầu trời chuyển xám',
      ),
      LyricLine(
        154.1,
        'We slowly ran out of things to say',
        'Ta dần chẳng còn gì để nói với nhau',
      ),
      LyricLine(
        154.3,
        'The river turned into drought',
        'Dòng sông rồi cũng cạn khô',
      ),
      LyricLine(
        154.9,
        'Our time was fading out',
        'Thời gian của ta dần phai nhạt',
      ),
      LyricLine(
        164.9,
        'Defeated and alone, we returned back home',
        'Thất bại và cô đơn, ta trở về nhà',
      ),
      LyricLine(
        167,
        'Like a bird without a wing who had never flown',
        'Như một chú chim gãy cánh chưa từng được bay',
      ),
      LyricLine(
        170.5,
        'Surrendered to, suspended dreams',
        'Đầu hàng trước những giấc mơ còn dang dở',
      ),
      LyricLine(178.7, 'Remember when', 'Còn nhớ không'),
      LyricLine(
        182.8,
        'You walked away in the December wind',
        'Em bước đi trong cơn gió tháng Mười Hai',
      ),
      LyricLine(
        192.5,
        'I felt the stinging on my pale skin',
        'Tôi cảm nhận cái rát trên làn da nhợt nhạt của mình',
      ),
      LyricLine(
        194.8,
        'I knew that things would never be the same again',
        'Tôi biết rằng mọi thứ sẽ chẳng bao giờ như xưa nữa',
      ),
      LyricLine(233.2, 'Remember when', 'Còn nhớ không'),
      LyricLine(
        254.9,
        'The clouds rolled in and then the sunlight dimmed',
        'Mây kéo đến rồi ánh nắng dần mờ đi',
      ),
      LyricLine(
        255.9,
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
        14.3,
        'There\'s no gravity that sucked me in your orbit',
        'Chẳng có lực hấp dẫn nào hút tôi vào quỹ đạo của em',
      ),
      LyricLine(
        18.2,
        'There\'s no magnet that was in your heart',
        'Cũng chẳng có nam châm nào trong trái tim em',
      ),
      LyricLine(
        21.6,
        'The one restriction was the friction that was keeping us',
        'Điều duy nhất cản trở là ma sát đã giữ chúng ta',
      ),
      LyricLine(25.3, 'A little too far apart', 'Cách nhau một chút quá xa'),
      LyricLine(
        29.5,
        'Why fight it, I was secretly delighted',
        'Sao phải chống lại, tôi thầm vui sướng',
      ),
      LyricLine(
        32.8,
        'I gave chase but then I let you win',
        'Tôi đuổi theo rồi lại để em thắng',
      ),
      LyricLine(
        36.3,
        'You felt lovely when you loved me like a fool',
        'Em cảm thấy thật dễ thương khi yêu tôi như một kẻ khờ',
      ),
      LyricLine(
        39.1,
        'But now I can\'t let go of your skin',
        'Nhưng giờ tôi chẳng thể rời xa làn da em',
      ),
      LyricLine(42.1, 'You know that,', 'Em biết đấy,'),
      LyricLine(43.2, 'I never knew', 'Tôi chưa từng biết'),
      LyricLine(
        45.5,
        'That you, are, crazy glue, my darling',
        'Rằng em chính là keo dính diệu kỳ, em yêu à',
      ),
      LyricLine(50.2, 'And I\'m stuck to you', 'Và tôi đã dính chặt lấy em'),
      LyricLine(
        54.1,
        'I am cozy and I don\'t gonna wiggle loose',
        'Tôi thấy ấm áp và chẳng muốn rời đi đâu cả',
      ),
      LyricLine(
        57.8,
        'You\'re honey like a finger in the beehive',
        'Em ngọt như mật ong nơi tổ ong',
      ),
      LyricLine(
        61.8,
        'The bees are buzzing in a tizzy fit',
        'Những chú ong đang vo ve rộn ràng',
      ),
      LyricLine(
        69.4,
        'They\'re stinging but I\'m singing like a fool',
        'Chúng chích tôi nhưng tôi vẫn hát vang như một kẻ khờ',
      ),
      LyricLine(
        71.1,
        'Cuz you\'re as sweet as a banana split',
        'Vì em ngọt ngào như một que kem chuối',
      ),
      LyricLine(
        75.1,
        'You\'re sticky like a hippie in the summer',
        'Em dính như một cô nàng hippie giữa mùa hè',
      ),
      LyricLine(
        76.2,
        'You\'re like syrup in the slushie tray',
        'Em như xi-rô trong ly đá bào',
      ),
      LyricLine(
        79.9,
        'One touch of you and I will never leave',
        'Chỉ cần chạm vào em, tôi sẽ chẳng bao giờ rời đi',
      ),
      LyricLine(
        86.5,
        'Cuz I believe that I can\'t get away',
        'Vì tôi tin rằng mình không thể thoát khỏi em',
      ),
      LyricLine(90.3, 'You know that', 'Em biết đấy'),
      LyricLine(104.6, 'Hold onto me', 'Hãy giữ chặt lấy tôi'),
      LyricLine(
        106.8,
        'And hand in hand we\'ll follow',
        'Và tay trong tay ta sẽ cùng bước',
      ),
      LyricLine(112.1, 'Hold onto me', 'Hãy giữ chặt lấy tôi'),
      LyricLine(
        113.1,
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
        12.1,
        'In the twilight of summer, you shook like a leaf',
        'Trong buổi hoàng hôn mùa hè, em run rẩy như chiếc lá',
      ),
      LyricLine(
        18.7,
        'And blew to the ground in a pile at my feet',
        'Rồi rơi xuống thành đống dưới chân tôi',
      ),
      LyricLine(
        23.8,
        'I picked you up, we fell into place',
        'Tôi nhặt em lên, và ta hoà vào nhau',
      ),
      LyricLine(
        33.4,
        'On the park bench in silence, we spoke with no words',
        'Trên băng ghế công viên trong im lặng, ta chẳng nói lời nào',
      ),
      LyricLine(
        39.6,
        'You held me like water, to placate your thirst',
        'Em ôm lấy tôi như dòng nước, để làm dịu cơn khát của mình',
      ),
      LyricLine(
        44.6,
        'Your lifeboat, your anchor, your perfect mistake',
        'Em là chiếc phao cứu sinh, là mỏ neo, là sai lầm hoàn hảo của tôi',
      ),
      LyricLine(
        54.3,
        'The white coat of winter, you wore like a veil',
        'Chiếc áo khoác trắng của mùa đông, em khoác lên như tấm màn che',
      ),
      LyricLine(
        60.7,
        'Thin as a whisper, but sharp as a nail',
        'Mỏng manh như hơi thở, nhưng sắc như mũi đinh',
      ),
      LyricLine(
        65.7,
        'The wind on the river is calling your name, with a voice so tame',
        'Cơn gió trên dòng sông đang gọi tên em, bằng giọng thật dịu dàng',
      ),
      LyricLine(
        74.1,
        'Be my light, my flickering flame',
        'Hãy là ánh sáng của tôi, ngọn lửa chập chờn của tôi',
      ),
      LyricLine(
        82.1,
        'In the bell tower basement, beneath the cold world',
        'Trong tầng hầm tháp chuông, dưới thế giới lạnh giá',
      ),
      LyricLine(
        99.2,
        'The feelings you\'d bunched up so gently unfurled',
        'Những cảm xúc em dồn nén bấy lâu dần bung nở dịu dàng',
      ),
      LyricLine(
        104.4,
        'You held me close, I tried to hold on',
        'Em ôm chặt lấy tôi, tôi cố gắng bám víu',
      ),
      LyricLine(
        114.9,
        'The next cloudy morning, you woke in my arms',
        'Sáng hôm sau nhiều mây, em tỉnh dậy trong vòng tay tôi',
      ),
      LyricLine(
        120.5,
        'I made you some coffee, you showed me your scars',
        'Tôi pha cho em một tách cà phê, em cho tôi xem những vết sẹo',
      ),
      LyricLine(
        125,
        'And I knew, one day, that I\'d be your next',
        'Và tôi biết, một ngày nào đó, tôi sẽ là người tiếp theo',
      ),
      LyricLine(
        135.3,
        'The stray light was running, you touched me and said,',
        'Ánh sáng lạc lối đang trôi đi, em chạm vào tôi và nói,',
      ),
      LyricLine(
        141.4,
        '"As young as I was, I felt older back then"',
        '"Dù khi ấy tôi còn trẻ, tôi đã cảm thấy mình già hơn rồi"',
      ),
      LyricLine(
        146.3,
        'Two parallel lines on an infinite plane, trying to cross in vain',
        'Hai đường thẳng song song trên một mặt phẳng vô tận, cố chạm nhau trong vô vọng',
      ),
      LyricLine(
        157,
        'Be my light, my flickering flame',
        'Hãy là ánh sáng của tôi, ngọn lửa chập chờn của tôi',
      ),
      LyricLine(
        207.9,
        'The cascades are thawing, and flowing again',
        'Những dòng thác đang tan băng, và chảy trở lại',
      ),
      LyricLine(
        240.7,
        'The ice that was frozen is slowly beginning',
        'Lớp băng từng đóng cứng giờ đang dần',
      ),
      LyricLine(
        245,
        'To move down the river, as it had to be',
        'Trôi xuôi theo dòng sông, như lẽ tất nhiên phải thế',
      ),
      LyricLine(
        249.9,
        'There\'s a lake in the country, where dreams go to die',
        'Có một hồ nước nơi miền quê, nơi những giấc mơ tìm đến cái chết',
      ),
      LyricLine(
        261.2,
        'It\'s flooding the banks where it once had been dry',
        'Nó đang tràn qua bờ, nơi từng khô cạn',
      ),
      LyricLine(
        266.4,
        'The petrified spirits are finally free',
        'Những linh hồn hoá đá cuối cùng cũng được tự do',
      ),
      LyricLine(
        275.9,
        'No flame is eternal, it just takes a drip',
        'Không ngọn lửa nào là vĩnh cửu, chỉ cần một giọt nước cũng đủ tắt',
      ),
      LyricLine(
        282,
        'No life is forever, it\'s all just a blip',
        'Không cuộc đời nào là mãi mãi, tất cả chỉ là thoáng chốc',
      ),
      LyricLine(
        287.5,
        'The ashes were carried on down to the drain by the callous rain',
        'Tro tàn bị cuốn trôi xuống rãnh nước bởi cơn mưa vô tình',
      ),
      LyricLine(
        288.5,
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
        16.7,
        'Lay, and put your weary soul to rest',
        'Nằm xuống, để tâm hồn mệt mỏi của con được nghỉ ngơi',
      ),
      LyricLine(
        20.9,
        'Yeah, I will try to do my best to keep you safe inside this nest',
        'Vâng, cha sẽ cố gắng hết sức để giữ con an toàn trong tổ ấm này',
      ),
      LyricLine(
        27.2,
        'And keep the gravity from pulling you to earth',
        'Và giữ cho trọng lực không kéo con xuống mặt đất',
      ),
      LyricLine(
        31.2,
        'I\'d like to say this gets more clear, when it\'s more cloudy every day',
        'Cha muốn nói rằng mọi thứ sẽ rõ ràng hơn, dù mỗi ngày trời một nhiều mây hơn',
      ),
      LyricLine(
        39.2,
        'But summer\'s gonna come and burn the stormy clouds and all the doubt away',
        'Nhưng mùa hè sẽ đến và thiêu cháy những đám mây giông cùng mọi nghi ngờ',
      ),
      LyricLine(
        47.5,
        'Sleep, little girl, \'cause when you wake it\'s gonna be a different world',
        'Ngủ đi, cô bé nhỏ, vì khi con tỉnh dậy thế giới sẽ khác đi',
      ),
      LyricLine(
        55.1,
        'So close your eyes and say goodbye to spring',
        'Vậy hãy nhắm mắt lại và nói lời tạm biệt mùa xuân',
      ),
      LyricLine(
        63.3,
        'It\'s true, this spring is coming to an end',
        'Đúng vậy, mùa xuân này sắp kết thúc rồi',
      ),
      LyricLine(
        70.7,
        'You\'re not that fragile anymore, I know what\'s there behind that door',
        'Con không còn mong manh như trước nữa, cha biết điều gì đang chờ sau cánh cửa đó',
      ),
      LyricLine(
        75.2,
        'And it\'s just waiting in the wings to pull you in',
        'Và nó chỉ đang chờ trong cánh gà để kéo con vào',
      ),
      LyricLine(
        79.2,
        'I know you think you\'re safe in here, inside these insulated walls',
        'Cha biết con nghĩ mình an toàn ở đây, trong những bức tường cách ly này',
      ),
      LyricLine(
        85.8,
        'But I can\'t hold this house together, not forever, yeah and soon it\'s gonna fall',
        'Nhưng cha không thể giữ ngôi nhà này mãi mãi, và rồi nó sẽ sớm sụp đổ',
      ),
      LyricLine(
        95.3,
        'Sleep, little girl, \'cause when you wake it\'s gonna be a different world',
        'Ngủ đi, cô bé nhỏ, vì khi con tỉnh dậy thế giới sẽ khác đi',
      ),
      LyricLine(
        103,
        'Everything will change, everything will change',
        'Mọi thứ sẽ đổi thay, mọi thứ sẽ đổi thay',
      ),
      LyricLine(
        111.8,
        'This door\'s slamming shut, it\'s gonna catch you if you\'re ready or you\'re not',
        'Cánh cửa này sắp đóng sầm lại, nó sẽ bắt lấy con dù con đã sẵn sàng hay chưa',
      ),
      LyricLine(
        118.8,
        'So close your eyes and say goodbye to spring',
        'Vậy hãy nhắm mắt lại và nói lời tạm biệt mùa xuân',
      ),
      LyricLine(
        126.7,
        'Slow down, \'cause winter\'s just around the bend',
        'Chậm lại thôi, vì mùa đông đã ở ngay khúc quanh',
      ),
      LyricLine(
        134.7,
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
        19.7,
        'I\'ve been sleeping with the lights on, buried in regrets',
        'Tôi vẫn ngủ với đèn bật sáng, chìm trong hối tiếc',
      ),
      LyricLine(
        23.4,
        'Breaking into sweats, naked as a falling leaf',
        'Toát mồ hôi lạnh, trần trụi như chiếc lá đang rơi',
      ),
      LyricLine(
        29.8,
        'It\'s a natural reaction, driven to distraction,',
        'Đó là phản ứng tự nhiên, bị cuốn theo sự xao lãng,',
      ),
      LyricLine(
        32.3,
        'Clawing at the ghosts I\'ll never meet',
        'Cào cấu vào những bóng ma tôi sẽ chẳng bao giờ gặp lại',
      ),
      LyricLine(
        38.4,
        'Oh, I don\'t know, where they go',
        'Ôi, tôi chẳng biết chúng đi đâu',
      ),
      LyricLine(
        42.7,
        'When they vanish in the corner of my eye',
        'Khi chúng biến mất nơi khóe mắt tôi',
      ),
      LyricLine(
        48.1,
        'And I, don\'t know why, I don\'t know',
        'Và tôi, chẳng biết vì sao, tôi chẳng biết',
      ),
      LyricLine(
        51.9,
        'If they stay below or rise up to the sky',
        'Liệu chúng ở lại phía dưới hay bay lên bầu trời',
      ),
      LyricLine(59, 'But I\'m letting go', 'Nhưng tôi đang buông bỏ'),
      LyricLine(62.5, 'I\'m letting go', 'Tôi đang buông bỏ'),
      LyricLine(
        65.7,
        'It\'s a history that never really grows',
        'Đó là một quá khứ chẳng bao giờ lớn thêm được nữa',
      ),
      LyricLine(71.3, 'I\'m letting go', 'Tôi đang buông bỏ'),
      LyricLine(74.3, 'I\'m letting go', 'Tôi đang buông bỏ'),
      LyricLine(
        78.4,
        'It\'s a silent wind that never really blows',
        'Đó là cơn gió lặng thinh chẳng bao giờ thực sự thổi',
      ),
      LyricLine(84, 'I\'m letting go', 'Tôi đang buông bỏ'),
      LyricLine(
        96.3,
        'I\'m a slave without a master, heading for disaster',
        'Tôi là nô lệ không chủ nhân, đang tiến về phía thảm hoạ',
      ),
      LyricLine(
        100.3,
        'Kicking up the dust in the middle of the road',
        'Đá tung bụi mù giữa con đường',
      ),
      LyricLine(
        105.7,
        'I\'ve been waiting on a free ride ticket',
        'Tôi vẫn chờ một tấm vé đi nhờ miễn phí',
      ),
      LyricLine(
        108.4,
        'To a seaside thicket on the edge of Puget Sound',
        'Đến bụi cây ven biển bên rìa vịnh Puget Sound',
      ),
      LyricLine(
        116.4,
        'And there I\'ll sit, and I\'ll admit',
        'Và tôi sẽ ngồi đó, và tôi sẽ thừa nhận',
      ),
      LyricLine(
        118.4,
        'That I was only just a guest inside my skin',
        'Rằng tôi chỉ là một vị khách trong chính làn da mình',
      ),
      LyricLine(
        124.9,
        'And by the dawn, I\'ll be gone',
        'Và khi bình minh lên, tôi sẽ rời đi',
      ),
      LyricLine(
        127.6,
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
        0,
        'It starts with an itch and a tingle',
        'Nó bắt đầu bằng một cơn ngứa ran nhẹ',
      ),
      LyricLine(
        4.7,
        'Then it builds and expands',
        'Rồi nó lớn dần và lan rộng',
      ),
      LyricLine(
        8.1,
        'And suddenly all at once my legs won\'t let me stand',
        'Và bỗng nhiên đôi chân tôi không thể đứng vững',
      ),
      LyricLine(
        16.1,
        'I scratch till my fingers go numb',
        'Tôi gãi đến khi ngón tay tê dại',
      ),
      LyricLine(
        19.9,
        'But my skin never bleeds',
        'Nhưng da tôi chẳng bao giờ chảy máu',
      ),
      LyricLine(
        25,
        'A silent accomplice waits and feeds when I\'m asleep',
        'Một kẻ đồng loã thầm lặng chờ đợi và ăn mòn tôi khi tôi ngủ say',
      ),
      LyricLine(
        32.3,
        'There\'s something that lives inside me',
        'Có điều gì đó đang sống bên trong tôi',
      ),
      LyricLine(
        35.7,
        'I promise I never let it in',
        'Tôi thề tôi chưa từng để nó bước vào',
      ),
      LyricLine(
        48.4,
        'It grows and divides inside me',
        'Nó lớn lên và phân chia bên trong tôi',
      ),
      LyricLine(
        51.8,
        'It\'s making a home beneath my skin',
        'Nó đang tự làm tổ dưới làn da tôi',
      ),
      LyricLine(
        71.8,
        'The seeds have been buried deeply',
        'Những hạt giống đã được chôn thật sâu',
      ),
      LyricLine(76.1, 'The roots are in place', 'Rễ của nó đã bám chắc'),
      LyricLine(
        81.8,
        'It\'s crowding the sun and it\'s darkened my days',
        'Nó che khuất ánh mặt trời và làm tối tăm những ngày của tôi',
      ),
      LyricLine(
        87.5,
        'I\'ve taken it all for granted',
        'Tôi đã xem mọi thứ là điều hiển nhiên',
      ),
      LyricLine(91.7, 'But now it\'s too late', 'Nhưng giờ đã quá muộn'),
      LyricLine(
        94.9,
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
      LyricLine(24, 'The day that we met', 'Ngày ta gặp nhau'),
      LyricLine(28.3, 'I\'ll never forget', 'Tôi sẽ không bao giờ quên'),
      LyricLine(
        30.8,
        'I knew from the moment she spoke',
        'Tôi biết ngay từ khoảnh khắc nàng cất lời',
      ),
      LyricLine(
        36.9,
        'The she, was destined to be',
        'Rằng nàng, định sẵn sẽ là',
      ),
      LyricLine(
        40.5,
        'My favorite regret',
        'Nỗi hối tiếc yêu thích nhất của tôi',
      ),
      LyricLine(48, 'And all through the years', 'Và suốt bao năm tháng'),
      LyricLine(50.4, 'The joy and the tears', 'Niềm vui và nước mắt'),
      LyricLine(
        53.4,
        'We shared like as greatest of friends',
        'Ta sẻ chia như những người bạn thân thiết nhất',
      ),
      LyricLine(
        58.4,
        'But she, was destined to be',
        'Nhưng nàng, định sẵn sẽ là',
      ),
      LyricLine(
        62.7,
        'My favorite regret',
        'Nỗi hối tiếc yêu thích nhất của tôi',
      ),
      LyricLine(
        68.9,
        'Well, each moment we\'ve spent',
        'Mỗi khoảnh khắc ta đã cùng trải qua',
      ),
      LyricLine(72.4, 'I\'ve been almost content', 'Tôi gần như đã mãn nguyện'),
      LyricLine(
        74.9,
        'Just to talk to her all through the night',
        'Chỉ cần được trò chuyện cùng nàng suốt đêm',
      ),
      LyricLine(
        80.7,
        'But a part of me mourns',
        'Nhưng một phần trong tôi vẫn tiếc nuối',
      ),
      LyricLine(
        83.7,
        'What will never be born',
        'Cho những gì sẽ chẳng bao giờ thành hiện thực',
      ),
      LyricLine(
        85.7,
        'She\'s forever my favorite regret',
        'Nàng mãi mãi là nỗi hối tiếc yêu thích nhất của tôi',
      ),
      LyricLine(97.9, 'He\'s gentle and kind', 'Anh ấy dịu dàng và tốt bụng'),
      LyricLine(100.8, 'And totally blind', 'Nhưng hoàn toàn không nhận ra'),
      LyricLine(
        103.3,
        'To not see the life we could lead',
        'Cuộc sống mà ta có thể cùng nhau xây đắp',
      ),
      LyricLine(108.6, 'And he, is destined to be', 'Và anh, định sẵn sẽ là'),
      LyricLine(
        112.4,
        'My favorite regret',
        'Nỗi hối tiếc yêu thích nhất của tôi',
      ),
      LyricLine(121.7, 'In bad times and good', 'Dù lúc khó khăn hay êm đềm'),
      LyricLine(
        122.2,
        'I\'ve steadfastly stood',
        'Tôi vẫn luôn kiên định đứng đó',
      ),
      LyricLine(
        125.3,
        'My passion just waits to be freed',
        'Đam mê trong tôi chỉ chờ được giải phóng',
      ),
      LyricLine(
        129.9,
        'But he, is destined to be',
        'Nhưng anh, định sẵn sẽ là',
      ),
      LyricLine(
        134.6,
        'My favorite regret',
        'Nỗi hối tiếc yêu thích nhất của tôi',
      ),
      LyricLine(
        140.9,
        'Well, I\'ve got more to give',
        'Tôi vẫn còn nhiều điều muốn trao',
      ),
      LyricLine(
        144.3,
        'But I\'m happy to live',
        'Nhưng tôi hạnh phúc khi được sống',
      ),
      LyricLine(
        147,
        'In the shadow, of what could’ve been',
        'Trong cái bóng của những gì có thể đã xảy ra',
      ),
      LyricLine(
        152.2,
        'But a part of me yearns',
        'Nhưng một phần trong tôi vẫn khao khát',
      ),
      LyricLine(
        155.7,
        'Like an ember, it burns',
        'Như một tia lửa âm ỉ, nó vẫn cháy',
      ),
      LyricLine(
        161.2,
        'Forever, my favorite regret',
        'Mãi mãi, là nỗi hối tiếc yêu thích nhất của tôi',
      ),
      LyricLine(
        169.8,
        'One day, when the stars fade',
        'Một ngày nào đó, khi những vì sao lụi tàn',
      ),
      LyricLine(
        180.6,
        'Will the echoes of my love',
        'Liệu tiếng vọng tình yêu của tôi',
      ),
      LyricLine(
        185.2,
        'Arrive to you above',
        'Có bay đến được nơi nàng trên cao',
      ),
      LyricLine(189, 'And wake you up at last', 'Và đánh thức nàng lần cuối'),
      LyricLine(
        227.8,
        'I\'ll take what I\'ve got',
        'Tôi sẽ giữ lấy những gì mình có',
      ),
      LyricLine(
        230.6,
        'Put the rest in a box',
        'Cất phần còn lại vào một chiếc hộp',
      ),
      LyricLine(
        234.1,
        'Addressed to the stars in the sky',
        'Gửi đến những vì sao trên bầu trời',
      ),
      LyricLine(
        238.7,
        'And soon, up there with the moon',
        'Và sớm thôi, trên đó cùng vầng trăng',
      ),
      LyricLine(
        242.7,
        'My favorite regret',
        'Nỗi hối tiếc yêu thích nhất của tôi',
      ),
      LyricLine(
        250.3,
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
        21.4,
        'And everyday, everyday, everyday you give and I take',
        'Và mỗi ngày, mỗi ngày, mỗi ngày em cho đi còn tôi thì nhận lấy',
      ),
      LyricLine(
        36.9,
        'I\'m living the best that I can',
        'Tôi đang sống hết sức mình có thể',
      ),
      LyricLine(
        37.7,
        'But fate never followed my plans',
        'Nhưng số phận chưa bao giờ theo đúng kế hoạch của tôi',
      ),
      LyricLine(
        39.7,
        'I’m holding you back, so I want you to pack up and grow',
        'Tôi đang kìm hãm em, nên tôi muốn em thu dọn và trưởng thành',
      ),
      LyricLine(
        68.5,
        'Everything, everything, everything you\'ve done is great',
        'Mọi thứ, mọi thứ, mọi thứ em đã làm đều tuyệt vời',
      ),
      LyricLine(
        73.9,
        'But your back has been feeling exhausted from all of the weight',
        'Nhưng tấm lưng em đã mệt mỏi vì gánh nặng ấy',
      ),
      LyricLine(
        86.2,
        'I\'ll carry this burden myself',
        'Tôi sẽ tự mình mang gánh nặng này',
      ),
      LyricLine(
        90.8,
        'Just put me up high on the shelf',
        'Cứ đặt tôi lên cao trên kệ sách',
      ),
      LyricLine(
        95.7,
        'Think of me fondly, but please move beyond me and go',
        'Hãy nhớ về tôi với sự trìu mến, nhưng xin hãy bước tiếp và rời đi',
      ),
      LyricLine(
        122,
        'There\'s so much that you want to do',
        'Có rất nhiều điều em muốn làm',
      ),
      LyricLine(
        126.5,
        'The world is just waiting for you',
        'Thế giới đang chờ đợi em',
      ),
      LyricLine(
        130.3,
        'But I\'m holding you down',
        'Nhưng tôi lại đang kéo em xuống',
      ),
      LyricLine(
        133.8,
        'From the dreams that you found',
        'Khỏi những giấc mơ em đã tìm thấy',
      ),
      LyricLine(
        136,
        'In a life that you left when we met',
        'Trong cuộc đời mà em đã bỏ lại khi ta gặp nhau',
      ),
      LyricLine(
        141.1,
        'So please just escape',
        'Vậy nên xin hãy trốn thoát đi',
      ),
      LyricLine(
        145,
        'Before my resolve goes away',
        'Trước khi quyết tâm của tôi lung lay',
      ),
      LyricLine(146, 'And I ask you to stay', 'Và tôi lại xin em ở lại'),
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
      LyricLine(19, 'Burn who I’ve been', 'Thiêu rụi con người tôi từng là'),
      LyricLine(
        23.1,
        'Wipe the slate, a clean escape again',
        'Xoá sạch mọi thứ, một lần trốn thoát trong sạch nữa',
      ),
      LyricLine(31.4, 'Run like the wind', 'Chạy như gió cuốn'),
      LyricLine(
        35,
        'The present’s gone, the past has never been',
        'Hiện tại đã mất, quá khứ chưa từng tồn tại',
      ),
      LyricLine(42.3, 'The firewood is spent', 'Củi lửa đã cháy hết'),
      LyricLine(45.2, 'The daylight came and went', 'Ánh ngày đến rồi lại đi'),
      LyricLine(
        48.5,
        'Now I’m just alone inside my head',
        'Giờ tôi chỉ còn lại một mình trong tâm trí',
      ),
      LyricLine(
        54,
        'And barely on the lam',
        'Và chỉ vừa mới thoát khỏi truy đuổi',
      ),
      LyricLine(
        57.3,
        'The demons I outran',
        'Những con quỷ tôi từng chạy thoát',
      ),
      LyricLine(59.6, 'Are at the door', 'Giờ đang đứng trước cửa'),
      LyricLine(
        65.6,
        'My saboteurs are passengers, they follow where I lead',
        'Những kẻ phá hoại trong tôi là hành khách, chúng theo bất cứ nơi nào tôi dẫn lối',
      ),
      LyricLine(
        71.6,
        'I can\'t escape the trouble, when the trouble’s part of me',
        'Tôi không thể thoát khỏi rắc rối, khi rắc rối chính là một phần của tôi',
      ),
      LyricLine(
        77.5,
        'And I run, as fast as lightning, from the mountains to the shore',
        'Và tôi chạy, nhanh như tia chớp, từ núi non đến bờ biển',
      ),
      LyricLine(
        83.3,
        'Still the wolves are clawing at the door',
        'Nhưng lũ sói vẫn cào cấu ngoài cửa',
      ),
      LyricLine(
        94.8,
        'A tap, then a knock',
        'Một cái chạm nhẹ, rồi một tiếng gõ',
      ),
      LyricLine(
        102.6,
        'Crecendoing and growing ever wilder',
        'Ngày càng dồn dập và dữ dội hơn',
      ),
      LyricLine(107.1, 'I stare at the lock', 'Tôi nhìn chằm chằm vào ổ khoá'),
      LyricLine(
        112.4,
        'The pounding shakes, the plaster breaks apart',
        'Tiếng đập rung chuyển, lớp thạch cao vỡ vụn',
      ),
      LyricLine(
        117.4,
        'A crackle then a spark',
        'Một tiếng nổ lách tách rồi một tia lửa',
      ),
      LyricLine(
        122,
        'Then everything goes dark',
        'Rồi mọi thứ chìm vào bóng tối',
      ),
      LyricLine(
        125.3,
        'I feel the winds constricting on the walls',
        'Tôi cảm nhận những cơn gió siết chặt quanh tường',
      ),
      LyricLine(
        131.2,
        'The shattered windows fall',
        'Những ô cửa sổ vỡ vụn rơi xuống',
      ),
      LyricLine(
        133.1,
        'A voice is in the hall, it calls me in',
        'Có một giọng nói trong sảnh, nó gọi tôi vào',
      ),
      LyricLine(201.1, 'Burn who I’ve been', 'Thiêu rụi con người tôi từng là'),
      LyricLine(
        205.4,
        'Wipe the slate, a clean escape, the end',
        'Xoá sạch mọi thứ, một lần trốn thoát trong sạch, đến hồi kết',
      ),
      LyricLine(208.4, 'Run like the wind', 'Chạy như gió cuốn'),
      LyricLine(
        215.4,
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
        20.5,
        'The tiptoes on the bedroom floor',
        'Những bước chân rón rén trên sàn phòng ngủ',
      ),
      LyricLine(
        24,
        'These quiet eyes are spinning in the dark',
        'Đôi mắt lặng lẽ ấy đang xoay tròn trong bóng tối',
      ),
      LyricLine(
        31.2,
        'The secret wish that none will know',
        'Điều ước thầm kín mà chẳng ai biết được',
      ),
      LyricLine(
        34.3,
        'She keeps it locked up in her pale heart',
        'Nàng khoá chặt nó trong trái tim nhợt nhạt của mình',
      ),
      LyricLine(
        43,
        'Wait for it, it\'s tired and it\'s true',
        'Hãy chờ đợi, nó mệt mỏi nhưng có thật',
      ),
      LyricLine(
        52.4,
        'Wait for it, it\'s all she ever knew',
        'Hãy chờ đợi, đó là tất cả những gì nàng từng biết',
      ),
      LyricLine(75.4, 'She dreams in blue', 'Nàng mơ trong sắc xanh'),
      LyricLine(
        82.5,
        'Wait for it, it\'s all she ever knew',
        'Hãy chờ đợi, đó là tất cả những gì nàng từng biết',
      ),
      LyricLine(
        108.5,
        'The background hum of city streets',
        'Tiếng ồn nền của những con phố thành thị',
      ),
      LyricLine(
        111.7,
        'And whispers from the neighbors intertwine',
        'Và những lời thì thầm từ hàng xóm đan xen vào nhau',
      ),
      LyricLine(
        119,
        'The distant glow of beacon lights are',
        'Ánh sáng xa xăm từ những ngọn đèn hiệu',
      ),
      LyricLine(
        122.4,
        'Breaking through the cracks between the blinds',
        'Xuyên qua những khe hở giữa tấm rèm',
      ),
      LyricLine(
        130.4,
        'Wait for it, it\'s hiding out of view',
        'Hãy chờ đợi, nó đang ẩn mình khỏi tầm mắt',
      ),
      LyricLine(
        140.6,
        'Wait for it, it\'s all she ever knew',
        'Hãy chờ đợi, đó là tất cả những gì nàng từng biết',
      ),
      LyricLine(163.4, 'She dreams in blue', 'Nàng mơ trong sắc xanh'),
      LyricLine(
        170.2,
        'Wait for it, it\'s all she ever knew',
        'Hãy chờ đợi, đó là tất cả những gì nàng từng biết',
      ),
      LyricLine(
        215.2,
        'She opens up her weary eyes',
        'Nàng mở đôi mắt mệt mỏi của mình',
      ),
      LyricLine(
        218.7,
        'The foggy cloud of vision fills the air',
        'Màn sương mờ ảo lấp đầy không gian',
      ),
      LyricLine(
        225.9,
        'She strains to make some sense of all the',
        'Nàng cố gắng tìm ra ý nghĩa của tất cả',
      ),
      LyricLine(
        229.4,
        'Abstract shapes and colors everywhere',
        'Những hình khối và sắc màu trừu tượng khắp nơi',
      ),
      LyricLine(
        236.8,
        'But all the blue just fades away dissolving in a haze of grey',
        'Nhưng sắc xanh ấy cứ nhạt dần, tan biến trong làn sương xám',
      ),
      LyricLine(
        241.7,
        'And lost inside her empty mind is everything she tried to find',
        'Và lạc mất trong tâm trí trống rỗng là tất cả những gì nàng từng cố tìm kiếm',
      ),
      LyricLine(
        247.7,
        'And all the blue just fades away, she lost it in a haze of grey',
        'Và sắc xanh ấy cứ nhạt dần, nàng đánh mất nó trong làn sương xám',
      ),
      LyricLine(261.3, 'She dreams in blue', 'Nàng mơ trong sắc xanh'),
      LyricLine(
        276.7,
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
        29.7,
        'I never thought I\'d see the day',
        'Tôi chưa từng nghĩ mình sẽ thấy ngày này',
      ),
      LyricLine(
        38.8,
        'I thought that I had finally moved along',
        'Tôi tưởng rằng mình cuối cùng cũng đã bước tiếp',
      ),
      LyricLine(
        64.9,
        'And I had let you go so long ago, so long',
        'Và tôi đã buông em ra từ rất lâu rồi, rất lâu rồi',
      ),
      LyricLine(
        75.9,
        'This is not, this is not where I belong',
        'Đây không phải, đây không phải nơi tôi thuộc về',
      ),
      LyricLine(
        86.4,
        'So I wait for this shallow itch to pass',
        'Nên tôi chờ cơn ngứa ngáy nông cạn này qua đi',
      ),
      LyricLine(94.3, 'And I wait, yeah I wait', 'Và tôi chờ, vâng tôi chờ'),
      LyricLine(100.3, 'Hey hey, I\'m ok', 'Này này, tôi ổn mà'),
      LyricLine(
        114.3,
        'I don\'t need this anyway, I\'m fine',
        'Dù sao tôi cũng không cần điều này, tôi ổn',
      ),
      LyricLine(114.5, 'What\'s yours and mine', 'Cái gì là của em và của tôi'),
      LyricLine(115, 'Oh oh, I don\'t know', 'Ồ, tôi chẳng biết'),
      LyricLine(
        127,
        'What I was ever hoping I would find',
        'Điều tôi từng hy vọng mình sẽ tìm thấy là gì',
      ),
      LyricLine(
        142,
        'But it\'s time for me to leave this all behind',
        'Nhưng đã đến lúc tôi bỏ lại tất cả phía sau',
      ),
      LyricLine(
        155.7,
        'I don\'t regret a single thing',
        'Tôi chẳng hối tiếc một điều gì',
      ),
      LyricLine(
        157.1,
        'I couldn\'t say it didn\'t feel alright',
        'Tôi không thể nói là nó không ổn',
      ),
      LyricLine(
        160.9,
        'But I don\'t want to stay and I don\'t want to fight',
        'Nhưng tôi không muốn ở lại và cũng không muốn tranh cãi',
      ),
      LyricLine(
        165.1,
        'All alone, with my foolish appetite',
        'Chỉ một mình, với ham muốn dại khờ của tôi',
      ),
      LyricLine(
        175,
        'So I wait for this shallow itch to pass',
        'Nên tôi chờ cơn ngứa ngáy nông cạn này qua đi',
      ),
      LyricLine(189.8, 'And I wait, yeah I wait', 'Và tôi chờ, vâng tôi chờ'),
      LyricLine(191.6, 'Hey hey, I\'m ok', 'Này này, tôi ổn mà'),
      LyricLine(
        200.6,
        'I don\'t need this anyway, I\'m fine',
        'Dù sao tôi cũng không cần điều này, tôi ổn',
      ),
      LyricLine(200.7, 'What\'s yours and mine', 'Cái gì là của em và của tôi'),
      LyricLine(201, 'Oh oh, I don\'t know', 'Ồ, tôi chẳng biết'),
      LyricLine(
        203.2,
        'What I was ever hoping I would find',
        'Điều tôi từng hy vọng mình sẽ tìm thấy là gì',
      ),
      LyricLine(
        206.1,
        'But it\'s time for me to leave this all behind',
        'Nhưng đã đến lúc tôi bỏ lại tất cả phía sau',
      ),
      LyricLine(
        213.2,
        'I don\'t have the heart to give away to you again',
        'Tôi không còn đủ can đảm để trao trái tim mình cho em thêm lần nữa',
      ),
      LyricLine(
        222.7,
        'I don\'t have the stomach for it, no one ever wins',
        'Tôi không đủ dũng khí cho điều đó, chẳng ai thắng cuộc cả',
      ),
      LyricLine(
        225.8,
        'We had our fun but I have sung this song to you before',
        'Ta đã có những khoảnh khắc vui vẻ nhưng tôi từng hát bài này cho em nghe rồi',
      ),
      LyricLine(
        226.8,
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
        5.4,
        'Underneath the stairs, on the basement floor',
        'Dưới gầm cầu thang, trên sàn tầng hầm',
      ),
      LyricLine(
        12.3,
        'Behind a stack of records and a plywood door',
        'Sau chồng đĩa nhạc cũ và cánh cửa gỗ ép',
      ),
      LyricLine(
        18.1,
        'There’s a cardboard box, with a coat of dust',
        'Có một chiếc hộp các-tông, phủ đầy bụi',
      ),
      LyricLine(
        25.9,
        'I brought it from your attic with your other stuff',
        'Tôi mang nó từ gác mái của em cùng những món đồ khác',
      ),
      LyricLine(
        31.7,
        'And on the side, it says “photographs and memories” in black',
        'Bên cạnh hộp, dòng chữ đen ghi "ảnh chụp và kỷ niệm"',
      ),
      LyricLine(
        42.8,
        'And I’ve tried, to avoid it but I want you back',
        'Tôi đã cố tránh né nó nhưng tôi muốn em quay lại',
      ),
      LyricLine(
        57.1,
        'This was Cedar Point, maybe ‘83',
        'Đây là Cedar Point, có lẽ vào năm \'83',
      ),
      LyricLine(
        65,
        'I got queasy on the coaster so you sat with me',
        'Tôi say tàu lượn nên em đã ngồi cạnh tôi',
      ),
      LyricLine(
        70.6,
        'And the kids all laughed, but I didn’t care',
        'Bọn trẻ đều cười, nhưng tôi chẳng bận tâm',
      ),
      LyricLine(
        77.9,
        'They were flashes in the pan, but you were always there',
        'Chúng chỉ là những khoảnh khắc thoáng qua, nhưng em thì luôn ở đó',
      ),
      LyricLine(
        83.6,
        'Even when, I got older and I thought I was cool, but I was cruel',
        'Ngay cả khi tôi lớn hơn và tưởng mình ngầu, nhưng tôi đã thật tàn nhẫn',
      ),
      LyricLine(
        96.4,
        'I still loved you and you somehow knew',
        'Tôi vẫn yêu em và bằng cách nào đó em đã biết',
      ),
      LyricLine(
        107.5,
        'Graduation day, I was moving on',
        'Ngày tốt nghiệp, tôi đang bước tiếp',
      ),
      LyricLine(
        121,
        'We’re posing on the corner of the high school lawn',
        'Ta tạo dáng chụp ảnh nơi góc sân trường trung học',
      ),
      LyricLine(
        127.3,
        'You were smiling wide, but I now can see',
        'Em cười thật tươi, nhưng giờ tôi mới nhận ra',
      ),
      LyricLine(
        134.6,
        'You were torn up at the thought of slowly losing me',
        'Em đã đau lòng khi nghĩ đến việc dần mất tôi',
      ),
      LyricLine(
        148.4,
        'And now I know, you were also slowly losing yourself',
        'Và giờ tôi biết, em cũng đang dần đánh mất chính mình',
      ),
      LyricLine(
        150,
        'But you held, all the pieces tied together so well',
        'Nhưng em đã giữ mọi mảnh ghép gắn kết thật tốt',
      ),
      LyricLine(
        215,
        'In the Florida sun, on the crowded coast',
        'Dưới nắng Florida, trên bờ biển đông đúc',
      ),
      LyricLine(
        222.1,
        'The picture is so faded that we look like ghosts',
        'Bức ảnh đã phai màu đến mức ta trông như những bóng ma',
      ),
      LyricLine(
        229.1,
        'You were made of sand, in a castle skin',
        'Em được tạo nên từ cát, khoác lớp vỏ lâu đài',
      ),
      LyricLine(
        235.9,
        'There was beauty for a moment till the tide rolled in',
        'Có vẻ đẹp thoáng qua cho đến khi con nước tràn vào',
      ),
      LyricLine(
        243.9,
        'But I still taste, the faintest touch of salt in the air, we’re still there',
        'Nhưng tôi vẫn cảm nhận được chút vị mặn thoảng trong không khí, ta vẫn còn ở đó',
      ),
      LyricLine(
        258.3,
        'You’re the summer breeze that ruffles my hair',
        'Em là làn gió mùa hè lay động mái tóc tôi',
      ),
      LyricLine(
        263.2,
        'In the box beneath the stairs',
        'Trong chiếc hộp dưới gầm cầu thang',
      ),
      LyricLine(
        269.6,
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
        10.3,
        'It\'s a long fade, down to blank tape',
        'Đó là một sự phai nhạt kéo dài, đến tận cuốn băng trống',
      ),
      LyricLine(
        20.1,
        'I\'ve never been too good at goodbyes',
        'Tôi chưa bao giờ giỏi nói lời tạm biệt',
      ),
      LyricLine(
        27.6,
        'There\'s no ending, just extending',
        'Chẳng có hồi kết, chỉ có kéo dài mãi',
      ),
      LyricLine(
        38.1,
        'Past infinity, the band is playing on',
        'Vượt qua cả vô tận, ban nhạc vẫn cứ chơi tiếp',
      ),
      LyricLine(
        47.1,
        'The party never stops',
        'Bữa tiệc chẳng bao giờ dừng lại',
      ),
      LyricLine(54.8, 'The coda never drops', 'Đoạn kết chẳng bao giờ đến'),
      LyricLine(
        60.8,
        'The dream it never sees the light of day',
        'Giấc mơ ấy chẳng bao giờ thấy được ánh sáng ban ngày',
      ),
      LyricLine(
        84.8,
        'A sound repeating, is slowly fleeting',
        'Một âm thanh lặp lại, đang dần phai nhạt',
      ),
      LyricLine(
        86.3,
        'It\'s feeding back forever in a loop',
        'Nó cứ vọng lại mãi mãi trong một vòng lặp',
      ),
      LyricLine(
        89.7,
        'But every mirror, becomes less clearer',
        'Nhưng mỗi tấm gương, lại càng thêm mờ đục',
      ),
      LyricLine(
        97.6,
        'A fuzzy haze descends upon the room',
        'Một làn sương mờ ảo phủ xuống căn phòng',
      ),
      LyricLine(106, 'The blemishes compound', 'Những vết xước cứ chồng chất'),
      LyricLine(112.7, 'And chip away the sound', 'Và bào mòn dần âm thanh'),
      LyricLine(
        118.2,
        'Until the hands of entropy take hold',
        'Cho đến khi bàn tay của sự hỗn loạn nắm quyền kiểm soát',
      ),
      LyricLine(
        134,
        'I won\'t let go, of your echo',
        'Tôi sẽ không buông tay, khỏi tiếng vọng của em',
      ),
      LyricLine(
        139.3,
        'I won\'t let you fade to nothing',
        'Tôi sẽ không để em phai nhạt thành hư vô',
      ),
      LyricLine(
        144.2,
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
        0,
        'Inside every mind, if you look, you will find',
        'Trong tâm trí mỗi người, nếu bạn nhìn kỹ, bạn sẽ thấy',
      ),
      LyricLine(
        7.1,
        'There’s a child who never grew old',
        'Có một đứa trẻ chưa bao giờ lớn lên',
      ),
      LyricLine(
        13.8,
        'Who sings to the trees, like nobody can see',
        'Nó hát cho hàng cây nghe, mà chẳng ai nhìn thấy',
      ),
      LyricLine(
        20.6,
        'With a fire that never went cold',
        'Với một ngọn lửa chưa bao giờ nguội lạnh',
      ),
      LyricLine(
        35.2,
        'He looks up to the stars, and the moon, and at Mars',
        'Nó ngước nhìn những vì sao, mặt trăng, và sao Hỏa',
      ),
      LyricLine(
        40.6,
        'And the endless expanse of the sky',
        'Và khoảng không vô tận của bầu trời',
      ),
      LyricLine(
        46.6,
        'Devoid of all doubt, just a question of how',
        'Không chút nghi ngờ, chỉ băn khoăn làm cách nào',
      ),
      LyricLine(
        50.4,
        'To climb up to the heavens and fly',
        'Để trèo lên tận trời cao và bay đi',
      ),
      LyricLine(55.6, 'But time is advancing', 'Nhưng thời gian cứ thế trôi'),
      LyricLine(59.7, 'A drip, then a flood', 'Một giọt, rồi thành cơn lũ'),
      LyricLine(
        61,
        'He’s adrift while you’re stuck on the shore',
        'Nó chông chênh trong khi bạn mắc kẹt trên bờ',
      ),
      LyricLine(
        65.4,
        'And he sails away to the depths of our brains',
        'Và nó trôi dạt vào sâu trong tâm trí ta',
      ),
      LyricLine(
        74.1,
        'And we can’t seem to dream anymore',
        'Và ta dường như không thể mơ mộng được nữa',
      ),
      LyricLine(
        79.8,
        'With the passing of days, we get lost in the maze',
        'Ngày qua ngày, ta lạc lối trong mê cung',
      ),
      LyricLine(
        84.7,
        'That we built out of habit and fear',
        'Mà ta tự xây nên từ thói quen và nỗi sợ',
      ),
      LyricLine(
        89.5,
        'The longer we run, the more lost we become',
        'Càng chạy trốn lâu, ta càng lạc lối hơn',
      ),
      LyricLine(
        94.1,
        'As the days disappear into years',
        'Khi ngày tháng cứ thế trôi thành năm',
      ),
      LyricLine(
        107.6,
        'When we’re sleeping in bed, the child in our heads',
        'Khi ta ngủ trên giường, đứa trẻ trong tâm trí ta',
      ),
      LyricLine(
        113.4,
        'Is reminding us how to break out',
        'Vẫn nhắc ta cách thoát ra',
      ),
      LyricLine(
        118.3,
        'But the moment we wake, it just up and escapes',
        'Nhưng vừa tỉnh giấc, nó liền biến mất',
      ),
      LyricLine(
        122.9,
        'And we’re back to the fear and doubt',
        'Và ta lại quay về với nỗi sợ và hoài nghi',
      ),
      LyricLine(
        126.9,
        'But the answer’s inside us, it never did leave',
        'Nhưng câu trả lời vẫn luôn ở trong ta, chưa từng rời đi',
      ),
      LyricLine(
        132.7,
        'We just never believed it before',
        'Chỉ là ta chưa từng tin vào nó',
      ),
      LyricLine(
        136.9,
        'Well, I’m done with the maze for the rest of my days',
        'Thôi, tôi sẽ không lạc trong mê cung này nữa suốt quãng đời còn lại',
      ),
      LyricLine(
        145.5,
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
        14,
        'The broken wing, it didn’t last a spring',
        'Chiếc cánh gãy ấy, chẳng trụ được qua một mùa xuân',
      ),
      LyricLine(
        21.8,
        'You shoved me out, before the nest was cold',
        'Người đã đẩy tôi ra ngoài, trước khi tổ ấm kịp lạnh',
      ),
      LyricLine(
        28.5,
        'I couldn\'t fly, but god I tried',
        'Tôi không thể bay, nhưng trời ơi tôi đã cố',
      ),
      LyricLine(
        35.6,
        'I hit the ground, and I was on my own',
        'Tôi rơi xuống đất, và chỉ còn lại một mình',
      ),
      LyricLine(
        42.4,
        'Alone in the big blue land',
        'Một mình giữa vùng đất xanh thẳm rộng lớn',
      ),
      LyricLine(
        45.5,
        'With only my legs to stand',
        'Chỉ còn đôi chân để đứng vững',
      ),
      LyricLine(
        48.9,
        'And no one to lend a hand, or to pick me up',
        'Và chẳng ai đưa tay giúp đỡ, hay đỡ tôi dậy',
      ),
      LyricLine(
        70.6,
        'I see the sky, where you would fly',
        'Tôi nhìn lên bầu trời, nơi người từng bay lượn',
      ),
      LyricLine(
        78.9,
        'And I would wait for you so patiently',
        'Và tôi đã kiên nhẫn chờ đợi người biết bao',
      ),
      LyricLine(
        86.1,
        'But I was weak, and soon I had an empty beak',
        'Nhưng tôi quá yếu ớt, và chẳng mấy chốc chiếc mỏ tôi trống rỗng',
      ),
      LyricLine(
        93.7,
        'I guess I wasn\'t worth the time',
        'Tôi đoán mình chẳng đáng để người bỏ thời gian',
      ),
      LyricLine(
        99.7,
        'And I never had the chance',
        'Và tôi chẳng bao giờ có cơ hội',
      ),
      LyricLine(
        103,
        'To float in a weightless dance',
        'Để bay lượn trong điệu nhảy không trọng lượng',
      ),
      LyricLine(
        106.7,
        'To swim in the great expanse above me',
        'Để bơi giữa khoảng không bao la trên đầu mình',
      ),
      LyricLine(119.2, 'The gravity holds me down', 'Trọng lực cứ giữ tôi lại'),
      LyricLine(
        119.7,
        'I’ll never escape the ground',
        'Tôi sẽ chẳng bao giờ thoát khỏi mặt đất',
      ),
      LyricLine(
        121,
        'To live in the careless clouds where I belong',
        'Để sống giữa những đám mây vô tư nơi tôi thuộc về',
      ),
    ],
  ),
];
