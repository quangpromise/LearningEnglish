import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../learning_path/data/learning_path_models.dart';
import '../writing_bank.dart';
import '../writing_grammar.dart';
import '../writing_paragraph_data.dart';

// Noi dung TU SOAN - quy uoc: xem writing_bank_family.dart.

const _b = LearnerLevel.basic;
const _i = LearnerLevel.intermediate;
const _a = LearnerLevel.advanced;

const kWritingBankMovies = WritingTopic(
  id: 'movies',
  titleVi: 'Phim ảnh',
  titleEn: 'Movies',
  icon: Icons.movie_rounded,
  color: AppColors.pink,
  paragraphs: [
    // ---------------- Co ban ----------------
    WritingParagraph(
      id: 'movies_b1',
      level: _b,
      titleVi: 'Đi xem phim',
      titleEn: 'At the cinema',
      sentences: [
        WritingSentence.of(
          'Tối nay tôi đi xem phim với bạn.',
          'Tonight I am going to the cinema with my friend.',
          G.presentContinuous,
          alternatives: ['Tonight I am going to the movies with my friend.'],
        ),
        WritingSentence.of(
          'Chúng tôi đang xếp hàng mua vé.',
          'We are waiting in line for tickets.',
          G.presentContinuous,
          alternatives: ['We are queuing for tickets.'],
        ),
        WritingSentence.of(
          'Bộ phim bắt đầu lúc tám giờ.',
          'The film starts at eight o\'clock.',
          G.presentSimple,
          alternatives: ['The movie starts at eight.'],
        ),
        WritingSentence.of(
          'Tôi sẽ mua bỏng ngô và nước ngọt.',
          'I will buy popcorn and a soft drink.',
          G.futureSimple,
          alternatives: ['I will buy popcorn and a soda.'],
        ),
        WritingSentence.of(
          'Chúng ta phải tắt điện thoại.',
          'We must turn off our phones.',
          G.modal,
          alternatives: ['We have to switch off our phones.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'movies_b2',
      level: _b,
      titleVi: 'Phim hoạt hình',
      titleEn: 'Cartoons',
      sentences: [
        WritingSentence.of(
          'Em trai tôi thích phim hoạt hình.',
          'My brother likes cartoons.',
          G.presentSimple,
          alternatives: ['My younger brother loves cartoons.'],
        ),
        WritingSentence.of(
          'Nó xem phim mỗi buổi sáng.',
          'He watches them every morning.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Nhân vật yêu thích của nó là một con mèo.',
          'His favorite character is a cat.',
          G.presentSimple,
          alternatives: ['His favourite character is a cat.'],
        ),
        WritingSentence.of(
          'Bây giờ nó đang cười rất to.',
          'Now he is laughing very loudly.',
          G.presentContinuous,
        ),
        WritingSentence.of(
          'Nó có thể hát bài hát trong phim.',
          'He can sing the song from the film.',
          G.modal,
          alternatives: ['He can sing the song from the cartoon.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'movies_b3',
      level: _b,
      titleVi: 'Phim kinh dị',
      titleEn: 'A horror film',
      sentences: [
        WritingSentence.of(
          'Tối qua tôi đã xem một bộ phim kinh dị.',
          'Last night I watched a horror film.',
          G.pastSimple,
          alternatives: ['Last night I watched a horror movie.'],
        ),
        WritingSentence.of(
          'Nó rất đáng sợ.',
          'It was very scary.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Tôi đã nhắm mắt nhiều lần.',
          'I closed my eyes many times.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Sau đó tôi không thể ngủ được.',
          'After that I could not sleep.',
          G.modal,
          alternatives: ['After that I couldn\'t sleep.'],
        ),
        WritingSentence.of(
          'Tôi sẽ không xem phim kinh dị nữa.',
          'I will not watch horror films again.',
          G.futureSimple,
          alternatives: ['I won\'t watch horror movies again.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'movies_b4',
      level: _b,
      titleVi: 'Xem phim ở nhà',
      titleEn: 'Movie night at home',
      sentences: [
        WritingSentence.of(
          'Tối thứ sáu nào nhà tôi cũng xem phim.',
          'My family watches a film every Friday night.',
          G.presentSimple,
          alternatives: ['My family watches a movie every Friday night.'],
        ),
        WritingSentence.of(
          'Mỗi tuần một người chọn phim.',
          'Each week, one person chooses the film.',
          G.presentSimple,
          alternatives: ['Each week, one person chooses the movie.'],
        ),
        WritingSentence.of(
          'Tuần này đến lượt tôi.',
          'This week it is my turn.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tôi định chọn một bộ phim hài.',
          'I am going to choose a comedy.',
          G.goingTo,
        ),
        WritingSentence.of(
          'Mẹ tôi sẽ làm bỏng ngô.',
          'My mother will make popcorn.',
          G.futureSimple,
          alternatives: ['My mom will make popcorn.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'movies_b5',
      level: _b,
      titleVi: 'Diễn viên yêu thích',
      titleEn: 'My favorite actor',
      sentences: [
        WritingSentence.of(
          'Tôi rất thích một nam diễn viên Hàn Quốc.',
          'I really like a Korean actor.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Anh ấy rất đẹp trai.',
          'He is very handsome.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Anh ấy có thể nói ba thứ tiếng.',
          'He can speak three languages.',
          G.modal,
        ),
        WritingSentence.of(
          'Tôi đã xem tất cả phim của anh ấy.',
          'I watched all his films.',
          G.pastSimple,
          alternatives: ['I watched all of his movies.'],
        ),
        WritingSentence.of(
          'Tôi muốn gặp anh ấy một ngày nào đó.',
          'I want to meet him one day.',
          G.presentSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'movies_b6',
      level: _b,
      titleVi: 'Phim có phụ đề',
      titleEn: 'Films with subtitles',
      sentences: [
        WritingSentence.of(
          'Tôi xem phim tiếng Anh để học.',
          'I watch English films to learn.',
          G.presentSimple,
          alternatives: ['I watch English movies to learn.'],
        ),
        WritingSentence.of(
          'Tôi thường bật phụ đề tiếng Anh.',
          'I usually turn on English subtitles.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tôi viết từ mới vào sổ.',
          'I write new words in my notebook.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Bây giờ tôi có thể hiểu gần hết.',
          'Now I can understand most of it.',
          G.modal,
        ),
        WritingSentence.of(
          'Bạn nên thử cách học này.',
          'You should try this way of learning.',
          G.modal,
        ),
      ],
    ),
    WritingParagraph(
      id: 'movies_b7',
      level: _b,
      titleVi: 'Phim mới ra mắt',
      titleEn: 'A new release',
      sentences: [
        WritingSentence.of(
          'Tuần sau có một bộ phim siêu anh hùng mới.',
          'There is a new superhero film next week.',
          G.presentSimple,
          alternatives: ['There is a new superhero movie next week.'],
        ),
        WritingSentence.of(
          'Tôi định xem nó vào ngày đầu tiên.',
          'I am going to see it on the first day.',
          G.goingTo,
        ),
        WritingSentence.of(
          'Tôi đã đặt vé trên mạng.',
          'I booked a ticket online.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Rạp sẽ rất đông.',
          'The cinema will be very crowded.',
          G.futureSimple,
        ),
        WritingSentence.of(
          'Tôi sẽ đến sớm.',
          'I will arrive early.',
          G.futureSimple,
          alternatives: ['I will get there early.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'movies_b8',
      level: _b,
      titleVi: 'Ông và phim cũ',
      titleEn: 'Grandpa\'s old films',
      sentences: [
        WritingSentence.of(
          'Ông tôi thích phim đen trắng.',
          'My grandfather likes black and white films.',
          G.presentSimple,
          alternatives: ['My grandpa likes black and white movies.'],
        ),
        WritingSentence.of(
          'Ông xem phim vào mỗi buổi chiều.',
          'He watches films every afternoon.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Hôm qua ông đã kể cho tôi về một bộ phim cũ.',
          'Yesterday he told me about an old film.',
          G.pastSimple,
          alternatives: ['Yesterday he told me about an old movie.'],
        ),
        WritingSentence.of(
          'Chúng tôi đã xem nó cùng nhau.',
          'We watched it together.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Tôi đã rất thích nó.',
          'I really liked it.',
          G.pastSimple,
        ),
      ],
    ),

    // ---------------- Trung cap ----------------
    WritingParagraph(
      id: 'movies_i1',
      level: _i,
      titleVi: 'Bộ phim Việt đáng nhớ',
      titleEn: 'A Vietnamese film to remember',
      sentences: [
        WritingSentence.of(
          'Tuần trước, tôi đã xem một bộ phim Việt Nam rất cảm động.',
          'Last week, I watched a very touching Vietnamese film.',
          G.pastSimple,
          alternatives: [
            'Last week, I watched a very moving Vietnamese movie.',
          ],
        ),
        WritingSentence.of(
          'Phim được quay ở một làng quê miền Trung.',
          'The film was shot in a village in central Vietnam.',
          G.passive,
        ),
        WritingSentence.of(
          'Đó là bộ phim hay nhất tôi xem trong năm nay.',
          'It is the best film I have seen this year.',
          G.comparison,
        ),
        WritingSentence.of(
          'Trong khi tôi đang xem cảnh cuối, tôi đã khóc.',
          'While I was watching the last scene, I cried.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Phim Việt ngày càng hay hơn trước.',
          'Vietnamese films are getting better and better.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nếu có phần hai, tôi sẽ đi xem ngay.',
          'If there is a sequel, I will see it right away.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'movies_i2',
      level: _i,
      titleVi: 'Sự cố ở rạp phim',
      titleEn: 'Trouble at the cinema',
      sentences: [
        WritingSentence.of(
          'Tối thứ bảy, rạp phim đông hơn bình thường rất nhiều.',
          'On Saturday night, the cinema was much busier than usual.',
          G.comparison,
        ),
        WritingSentence.of(
          'Trong khi chúng tôi đang xem phim, màn hình đột nhiên tắt.',
          'While we were watching the film, the screen suddenly went black.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Mọi người được mời ra ngoài chờ.',
          'Everyone was asked to wait outside.',
          G.passive,
        ),
        WritingSentence.of(
          'Chúng tôi đã chờ gần một tiếng.',
          'We waited for almost an hour.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Tôi chưa bao giờ gặp chuyện như vậy.',
          'I have never had that happen before.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Nếu rạp tặng vé, chúng tôi sẽ quay lại vào tuần sau.',
          'If the cinema gives us free tickets, we will come back next week.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'movies_i3',
      level: _i,
      titleVi: 'Phim hay sách',
      titleEn: 'The book or the film',
      sentences: [
        WritingSentence.of(
          'Tôi đã đọc cuốn sách trước khi xem phim.',
          'I read the book before I watched the film.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Theo tôi, cuốn sách hay hơn bộ phim.',
          'In my opinion, the book is better than the film.',
          G.comparison,
          alternatives: ['In my opinion, the book is better than the movie.'],
        ),
        WritingSentence.of(
          'Nhiều chi tiết quan trọng đã bị cắt bỏ.',
          'Many important details were cut out.',
          G.passive,
        ),
        WritingSentence.of(
          'Tuy nhiên, âm nhạc trong phim rất tuyệt.',
          'However, the music in the film was amazing.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Tôi đã xem bộ phim ba lần.',
          'I have watched the film three times.',
          G.presentPerfect,
          alternatives: ['I have seen the movie three times.'],
        ),
        WritingSentence.of(
          'Nếu bạn chưa đọc sách, bạn nên đọc trước khi xem.',
          'If you have not read the book, you should read it first.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'movies_i4',
      level: _i,
      titleVi: 'Làm phim ngắn',
      titleEn: 'Making a short film',
      sentences: [
        WritingSentence.of(
          'Nhóm tôi đang làm một bộ phim ngắn cho câu lạc bộ.',
          'My group is making a short film for our club.',
          G.presentContinuous,
        ),
        WritingSentence.of(
          'Kịch bản được viết bởi bạn thân của tôi.',
          'The script was written by my best friend.',
          G.passive,
        ),
        WritingSentence.of(
          'Chúng tôi đã quay được một nửa bộ phim.',
          'We have filmed half of the movie.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Hôm qua, khi chúng tôi đang quay ngoài công viên, trời đổ mưa.',
          'Yesterday, while we were filming in the park, it started pouring.',
          G.pastContinuous,
          alternatives: [
            'Yesterday, while we were filming in the park, it started to pour.',
          ],
        ),
        WritingSentence.of(
          'Làm phim khó hơn chúng tôi nghĩ rất nhiều.',
          'Making a film is much harder than we thought.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nếu phim hoàn thành kịp, chúng tôi sẽ gửi đi dự thi.',
          'If we finish in time, we will enter it into a competition.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'movies_i5',
      level: _i,
      titleVi: 'Nghiện phim bộ',
      titleEn: 'Binge watching',
      sentences: [
        WritingSentence.of(
          'Chị tôi đã xem hết ba mùa phim chỉ trong một tuần.',
          'My sister has watched three seasons of a series in one week.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Phim bộ này nổi tiếng hơn bất kỳ phim nào năm nay.',
          'This series is more popular than any other show this year.',
          G.comparison,
        ),
        WritingSentence.of(
          'Mỗi tập được phát hành vào tối thứ sáu.',
          'Each episode is released on Friday night.',
          G.passive,
        ),
        WritingSentence.of(
          'Tối qua, khi chị ấy đang xem tập cuối, mất điện.',
          'Last night, while she was watching the final episode, the power went out.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Chị ấy đã rất tức giận vì chuyện đó.',
          'She was really angry about it.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Nếu có điện lại, chị ấy sẽ thức cả đêm để xem.',
          'If the power comes back, she will stay up all night watching.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'movies_i6',
      level: _i,
      titleVi: 'Phim hoạt hình Nhật Bản',
      titleEn: 'Japanese animation',
      sentences: [
        WritingSentence.of(
          'Phim hoạt hình Nhật Bản rất được giới trẻ Việt Nam yêu thích.',
          'Japanese animation is loved by young Vietnamese people.',
          G.passive,
        ),
        WritingSentence.of(
          'Tôi đã xem phim hoạt hình Nhật từ khi còn nhỏ.',
          'I have watched Japanese cartoons since I was a child.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Hình ảnh trong những bộ phim này đẹp hơn phim khác.',
          'The pictures in these films are more beautiful than in other films.',
          G.comparison,
        ),
        WritingSentence.of(
          'Tuần trước, trong khi tôi đang xem một bộ phim cũ, tôi nhận ra nhiều điều mới.',
          'Last week, while I was rewatching an old film, I noticed many new things.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Những bộ phim này dạy tôi về tình bạn và lòng dũng cảm.',
          'These films teach me about friendship and courage.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Nếu có dịp đến Nhật, tôi sẽ thăm bảo tàng hoạt hình.',
          'If I have a chance to visit Japan, I will go to an animation museum.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'movies_i7',
      level: _i,
      titleVi: 'Rạp chiếu phim ngoài trời',
      titleEn: 'An outdoor cinema',
      sentences: [
        WritingSentence.of(
          'Thành phố vừa mở một rạp chiếu phim ngoài trời.',
          'The city has just opened an outdoor cinema.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Phim được chiếu trên một màn hình khổng lồ bên hồ.',
          'Films are shown on a huge screen by the lake.',
          G.passive,
        ),
        WritingSentence.of(
          'Nó thoáng mát hơn rạp trong nhà.',
          'It is cooler and fresher than an indoor cinema.',
          G.comparison,
        ),
        WritingSentence.of(
          'Tối qua, trong khi chúng tôi đang xem phim, muỗi cắn khắp chân tôi.',
          'Last night, while we were watching the film, mosquitoes bit my legs.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Tôi đã quên mang thuốc chống muỗi.',
          'I forgot to bring insect spray.',
          G.pastSimple,
          alternatives: ['I forgot to bring mosquito spray.'],
        ),
        WritingSentence.of(
          'Nếu đi lần nữa, tôi sẽ mặc quần dài.',
          'If I go again, I will wear long trousers.',
          G.conditional1,
          alternatives: ['If I go again, I will wear long pants.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'movies_i8',
      level: _i,
      titleVi: 'Lồng tiếng',
      titleEn: 'Dubbing',
      sentences: [
        WritingSentence.of(
          'Nhiều phim nước ngoài được lồng tiếng Việt.',
          'Many foreign films are dubbed into Vietnamese.',
          G.passive,
        ),
        WritingSentence.of(
          'Tôi thích xem phim với giọng gốc hơn.',
          'I prefer watching films in their original language.',
          G.comparison,
        ),
        WritingSentence.of(
          'Giọng gốc tự nhiên hơn giọng lồng tiếng.',
          'The original voices sound more natural than the dubbed ones.',
          G.comparison,
        ),
        WritingSentence.of(
          'Mẹ tôi đã xem phim lồng tiếng cả đời.',
          'My mother has watched dubbed films all her life.',
          G.presentPerfect,
          alternatives: ['My mom has watched dubbed movies all her life.'],
        ),
        WritingSentence.of(
          'Tối qua, khi chúng tôi đang chọn phim, hai mẹ con tranh cãi.',
          'Last night, while we were choosing a film, my mother and I argued.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Nếu có phụ đề, mẹ sẽ đồng ý xem phim gốc.',
          'If there are subtitles, she will agree to watch the original.',
          G.conditional1,
        ),
      ],
    ),

    // ---------------- Nang cao ----------------
    WritingParagraph(
      id: 'movies_a1',
      level: _a,
      titleVi: 'Điện ảnh Việt Nam trên thế giới',
      titleEn: 'Vietnamese cinema abroad',
      sentences: [
        WritingSentence.of(
          'Một bộ phim Việt Nam, được quay với kinh phí rất nhỏ, vừa giành giải tại một liên hoan phim quốc tế.',
          'A Vietnamese film, which was made on a very small budget, has just won an award at an international festival.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Đạo diễn đã phát triển kịch bản suốt bảy năm trước khi tìm được nhà đầu tư.',
          'The director had been developing the script for seven years before he found an investor.',
          G.pastPerfectContinuous,
        ),
        WritingSentence.of(
          'Trong bài phát biểu, anh nói rằng giải thưởng thuộc về cả đoàn làm phim.',
          'In his speech, he said that the award belonged to the whole crew.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu phim Việt được đầu tư nhiều hơn, chúng ta sẽ có nhiều tác phẩm như vậy.',
          'If Vietnamese films received more investment, we would see many more works like this.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Những năm gần đây, khán giả trong nước đã và đang ủng hộ phim Việt nhiều hơn.',
          'In recent years, local audiences have been supporting Vietnamese films more.',
          G.presentPerfectContinuous,
        ),
        WritingSentence.of(
          'Đến cuối năm, bộ phim sẽ được chiếu ở hơn hai mươi quốc gia.',
          'By the end of the year, the film will have been shown in more than twenty countries.',
          G.futurePerfect,
        ),
      ],
    ),
    WritingParagraph(
      id: 'movies_a2',
      level: _a,
      titleVi: 'Phim lậu',
      titleEn: 'Film piracy',
      sentences: [
        WritingSentence.of(
          'Phim lậu, thứ có thể xem miễn phí trên mạng, đang gây thiệt hại lớn cho các nhà làm phim.',
          'Pirated films, which can be watched for free online, are causing huge losses for filmmakers.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Một bộ phim Việt đã bị phát tán trái phép chỉ vài giờ sau khi ra rạp.',
          'One Vietnamese film was leaked illegally just a few hours after its release.',
          G.passive,
        ),
        WritingSentence.of(
          'Nhà sản xuất cho biết họ đã mất hàng tỷ đồng doanh thu.',
          'The producer said that they had lost billions of dong in ticket sales.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Trước khi hiểu những thiệt hại đó, tôi đã từng xem phim lậu mà không suy nghĩ.',
          'Before I understood the damage, I had watched pirated films without thinking.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Nếu mọi người trả tiền cho những gì họ xem, ngành điện ảnh sẽ phát triển mạnh hơn.',
          'If everyone paid for what they watched, the film industry would grow much stronger.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Từ năm ngoái, tôi chỉ xem phim trên các nền tảng có bản quyền.',
          'Since last year, I have only watched films on licensed platforms.',
          G.presentPerfect,
        ),
      ],
    ),
    WritingParagraph(
      id: 'movies_a3',
      level: _a,
      titleVi: 'Diễn viên đóng thế',
      titleEn: 'Life as a stunt performer',
      sentences: [
        WritingSentence.of(
          'Anh họ tôi làm diễn viên đóng thế, một công việc mà ít người dám làm.',
          'My cousin is a stunt performer, a job that few people dare to do.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Anh ấy đã tập võ và thể dục dụng cụ hơn mười năm trước khi vào nghề.',
          'He had trained in martial arts and gymnastics for over ten years before starting the job.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Anh kể rằng cảnh nguy hiểm nhất là nhảy từ tầng ba xuống.',
          'He told me that his most dangerous scene had been a jump from the third floor.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu đoàn phim không chuẩn bị kỹ, anh ấy có thể đã bị thương nặng.',
          'If the crew had not prepared carefully, he could have been badly injured.',
          G.conditional3,
        ),
        WritingSentence.of(
          'Khán giả hiếm khi biết tên những người đã thực hiện các pha hành động mà họ thấy.',
          'Audiences rarely know the names of the people who perform the action scenes they see.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Tháng sau, anh ấy sẽ đang quay một bộ phim hành động ở Thái Lan.',
          'Next month, he will be filming an action movie in Thailand.',
          G.futureContinuous,
        ),
      ],
    ),
    WritingParagraph(
      id: 'movies_a4',
      level: _a,
      titleVi: 'AI trong điện ảnh',
      titleEn: 'AI in filmmaking',
      sentences: [
        WritingSentence.of(
          'Trí tuệ nhân tạo đang được dùng để tạo hiệu ứng hình ảnh nhanh và rẻ hơn bao giờ hết.',
          'Artificial intelligence is being used to create visual effects faster and more cheaply than ever.',
          G.passive,
        ),
        WritingSentence.of(
          'Một số diễn viên lo sợ rằng khuôn mặt của họ có thể bị sao chép mà không xin phép.',
          'Some actors fear that their faces could be copied without permission.',
          G.passive,
        ),
        WritingSentence.of(
          'Năm ngoái, các diễn viên ở Hollywood đã đình công nhiều tháng để phản đối điều này.',
          'Last year, Hollywood actors went on strike for months to protest against this.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Một đạo diễn nói với tôi rằng AI sẽ không bao giờ thay thế được cảm xúc thật.',
          'A director told me that AI would never replace real emotion.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu không có luật rõ ràng, quyền của diễn viên sẽ khó được bảo vệ.',
          'If there were no clear laws, actors\' rights would be hard to protect.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Đến cuối thập kỷ này, nhiều bộ phim có lẽ sẽ được làm gần như hoàn toàn bằng máy tính.',
          'By the end of this decade, many films will probably have been made almost entirely by computers.',
          G.futurePerfect,
        ),
      ],
    ),
    WritingParagraph(
      id: 'movies_a5',
      level: _a,
      titleVi: 'Phim tài liệu thay đổi tôi',
      titleEn: 'A documentary that changed me',
      sentences: [
        WritingSentence.of(
          'Bộ phim tài liệu mà tôi xem tháng trước kể về những người nhặt rác ở Hà Nội.',
          'The documentary that I watched last month was about waste pickers in Hanoi.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Đạo diễn đã theo chân họ suốt một năm để ghi lại cuộc sống hằng ngày.',
          'The director had followed them for a whole year to record their daily lives.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Một người phụ nữ trong phim nói rằng bà làm việc từ ba giờ sáng mỗi ngày.',
          'A woman in the film said that she worked from three in the morning every day.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu tôi không xem bộ phim đó, tôi đã không bao giờ nghĩ về rác mình thải ra.',
          'If I had not watched that film, I would never have thought about my own waste.',
          G.conditional3,
        ),
        WritingSentence.of(
          'Kể từ đó, tôi đã luôn phân loại rác trước khi mang ra ngoài.',
          'Since then, I have always sorted my rubbish before taking it out.',
          G.presentPerfect,
          alternatives: [
            'Since then, I have always sorted my trash before taking it out.',
          ],
        ),
        WritingSentence.of(
          'Tôi tin rằng phim tài liệu có sức mạnh thay đổi xã hội.',
          'I believe that documentaries have the power to change society.',
          G.presentSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'movies_a6',
      level: _a,
      titleVi: 'Rạp phim trong thời đại trực tuyến',
      titleEn: 'Cinemas in the streaming age',
      sentences: [
        WritingSentence.of(
          'Nhiều người cho rằng các nền tảng trực tuyến sẽ khiến rạp chiếu phim biến mất.',
          'Many people believe that streaming platforms will make cinemas disappear.',
          G.futureSimple,
        ),
        WritingSentence.of(
          'Trong đại dịch, hàng nghìn rạp phim trên thế giới đã buộc phải đóng cửa.',
          'During the pandemic, thousands of cinemas around the world were forced to close.',
          G.passive,
        ),
        WritingSentence.of(
          'Khi các rạp mở cửa trở lại, nhiều khán giả đã quen xem phim ở nhà.',
          'By the time cinemas reopened, many viewers had got used to watching films at home.',
          G.pastPerfect,
          alternatives: [
            'By the time cinemas reopened, many viewers had gotten used to watching films at home.',
          ],
        ),
        WritingSentence.of(
          'Tuy vậy, trải nghiệm ở rạp, nơi hàng trăm người cùng cười và khóc, vẫn rất đặc biệt.',
          'However, the cinema experience, where hundreds of people laugh and cry together, is still special.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Nếu vé rẻ hơn, nhiều người trẻ sẽ quay lại rạp thường xuyên.',
          'If tickets were cheaper, more young people would go back to the cinema regularly.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Các rạp phim đã và đang thêm ghế nằm và đồ ăn cao cấp để thu hút khách.',
          'Cinemas have been adding reclining seats and better food to attract customers.',
          G.presentPerfectContinuous,
        ),
      ],
    ),
    WritingParagraph(
      id: 'movies_a7',
      level: _a,
      titleVi: 'Học làm đạo diễn',
      titleEn: 'Studying film',
      sentences: [
        WritingSentence.of(
          'Bạn tôi, người mơ làm đạo diễn từ nhỏ, vừa được nhận vào trường điện ảnh.',
          'My friend, who has dreamed of directing since childhood, has just been accepted into film school.',
          G.relativeClause,
          alternatives: [
            'My friend, who has dreamt of directing since childhood, has just been accepted into film school.',
          ],
        ),
        WritingSentence.of(
          'Cô ấy đã làm phim ngắn bằng điện thoại suốt những năm cấp ba.',
          'She made short films with her phone throughout high school.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Trước buổi phỏng vấn, cô ấy đã xem lại hơn một trăm bộ phim kinh điển.',
          'Before the interview, she had rewatched more than a hundred classic films.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Thầy giáo nói với cô rằng kỹ thuật có thể học, nhưng góc nhìn riêng thì không.',
          'Her teacher told her that technique could be learned, but a personal view could not.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu gia đình không ủng hộ, có lẽ cô ấy đã chọn một ngành khác.',
          'If her family had not supported her, she might have chosen a different career.',
          G.conditional3,
        ),
        WritingSentence.of(
          'Vào giờ này năm sau, cô ấy sẽ đang quay bộ phim tốt nghiệp đầu tiên.',
          'This time next year, she will be shooting her first student film.',
          G.futureContinuous,
        ),
      ],
    ),
    WritingParagraph(
      id: 'movies_a8',
      level: _a,
      titleVi: 'Phim và văn hoá',
      titleEn: 'Films and culture',
      sentences: [
        WritingSentence.of(
          'Phim ảnh là một trong những cách hiệu quả nhất để giới thiệu văn hoá của một quốc gia.',
          'Films are one of the most effective ways to introduce a country\'s culture.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nhờ phim Hàn Quốc, hàng triệu người đã bắt đầu học tiếng Hàn và ăn món Hàn.',
          'Thanks to Korean films, millions of people have started learning Korean and eating Korean food.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Một nhà nghiên cứu giải thích rằng chính phủ Hàn Quốc đã đầu tư vào điện ảnh từ những năm chín mươi.',
          'A researcher explained that the Korean government had invested in cinema since the nineties.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu Việt Nam có chiến lược tương tự, văn hoá Việt sẽ được biết đến rộng rãi hơn.',
          'If Vietnam had a similar strategy, Vietnamese culture would be known more widely.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Những bộ phim quay ở Việt Nam, như các phim bom tấn quay ở Quảng Bình, đã thu hút nhiều du khách.',
          'Films shot in Vietnam, like the blockbusters filmed in Quang Binh, have attracted many tourists.',
          G.passive,
        ),
        WritingSentence.of(
          'Đến năm sau, số du khách đến những địa điểm quay phim sẽ tăng gấp đôi.',
          'By next year, the number of visitors to filming locations will have doubled.',
          G.futurePerfect,
        ),
      ],
    ),
  ],
);
