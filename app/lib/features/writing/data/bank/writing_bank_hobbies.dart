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

const kWritingBankHobbies = WritingTopic(
  id: 'hobbies',
  titleVi: 'Sở thích',
  titleEn: 'Hobbies',
  icon: Icons.sports_esports_rounded,
  color: AppColors.purple,
  paragraphs: [
    // ---------------- Co ban ----------------
    WritingParagraph(
      id: 'hobbies_b1',
      level: _b,
      titleVi: 'Sở thích của tôi',
      titleEn: 'My hobbies',
      sentences: [
        WritingSentence.of(
          'Tôi có nhiều sở thích.',
          'I have many hobbies.',
          G.presentSimple,
          alternatives: ['I have a lot of hobbies.'],
        ),
        WritingSentence.of(
          'Tôi thích đọc sách và vẽ tranh.',
          'I like reading books and drawing pictures.',
          G.presentSimple,
          alternatives: ['I like reading and drawing.'],
        ),
        WritingSentence.of(
          'Tôi vẽ tranh vào mỗi tối thứ bảy.',
          'I draw pictures every Saturday evening.',
          G.presentSimple,
          alternatives: ['I paint every Saturday evening.'],
        ),
        WritingSentence.of(
          'Bạn tôi thích chơi bóng đá.',
          'My friend likes playing football.',
          G.presentSimple,
          alternatives: ['My friend likes playing soccer.'],
        ),
        WritingSentence.of(
          'Chúng tôi có thể chơi cùng nhau.',
          'We can play together.',
          G.modal,
        ),
      ],
    ),
    WritingParagraph(
      id: 'hobbies_b2',
      level: _b,
      titleVi: 'Học đàn guitar',
      titleEn: 'Learning the guitar',
      sentences: [
        WritingSentence.of(
          'Tôi đang học chơi đàn guitar.',
          'I am learning to play the guitar.',
          G.presentContinuous,
          alternatives: ['I am learning the guitar.'],
        ),
        WritingSentence.of(
          'Thầy giáo của tôi rất kiên nhẫn.',
          'My teacher is very patient.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tôi luyện tập mỗi ngày.',
          'I practice every day.',
          G.presentSimple,
          alternatives: ['I practise every day.'],
        ),
        WritingSentence.of(
          'Ngón tay tôi hơi đau.',
          'My fingers hurt a little.',
          G.presentSimple,
          alternatives: ['My fingers are a bit sore.'],
        ),
        WritingSentence.of(
          'Tôi sẽ chơi một bài hát cho mẹ.',
          'I will play a song for my mother.',
          G.futureSimple,
          alternatives: ['I will play a song for my mom.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'hobbies_b3',
      level: _b,
      titleVi: 'Một ngày Chủ nhật',
      titleEn: 'A Sunday',
      sentences: [
        WritingSentence.of(
          'Hôm qua là Chủ nhật.',
          'Yesterday was Sunday.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Tôi đã đi câu cá với ông.',
          'I went fishing with my grandfather.',
          G.pastSimple,
          alternatives: ['I went fishing with my grandpa.'],
        ),
        WritingSentence.of(
          'Chúng tôi đã câu được ba con cá.',
          'We caught three fish.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Sau đó, tôi chơi cờ với bố.',
          'Then I played chess with my father.',
          G.pastSimple,
          alternatives: ['After that, I played chess with my dad.'],
        ),
        WritingSentence.of(
          'Tôi đã thắng một ván.',
          'I won one game.',
          G.pastSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'hobbies_b4',
      level: _b,
      titleVi: 'Chụp ảnh',
      titleEn: 'Taking photos',
      sentences: [
        WritingSentence.of(
          'Chị tôi thích chụp ảnh.',
          'My sister likes taking photos.',
          G.presentSimple,
          alternatives: ['My sister likes taking pictures.'],
        ),
        WritingSentence.of(
          'Chị ấy có một chiếc máy ảnh mới.',
          'She has a new camera.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Bây giờ chị ấy đang chụp những bông hoa.',
          'Now she is taking photos of the flowers.',
          G.presentContinuous,
          alternatives: ['She is taking photos of the flowers now.'],
        ),
        WritingSentence.of(
          'Ảnh của chị ấy rất đẹp.',
          'Her photos are very beautiful.',
          G.presentSimple,
          alternatives: ['Her pictures are very beautiful.'],
        ),
        WritingSentence.of(
          'Tôi muốn học chụp ảnh.',
          'I want to learn photography.',
          G.presentSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'hobbies_b5',
      level: _b,
      titleVi: 'Kế hoạch mùa hè',
      titleEn: 'Summer plans',
      sentences: [
        WritingSentence.of(
          'Mùa hè này, tôi định học bơi.',
          'This summer, I am going to learn to swim.',
          G.goingTo,
        ),
        WritingSentence.of(
          'Em trai tôi định học vẽ.',
          'My brother is going to learn to draw.',
          G.goingTo,
          alternatives: ['My younger brother is going to learn drawing.'],
        ),
        WritingSentence.of(
          'Chúng tôi sẽ đi cắm trại với bố mẹ.',
          'We will go camping with our parents.',
          G.futureSimple,
        ),
        WritingSentence.of(
          'Tôi sẽ đọc năm cuốn sách.',
          'I will read five books.',
          G.futureSimple,
        ),
        WritingSentence.of(
          'Đó sẽ là một mùa hè vui vẻ.',
          'It will be a fun summer.',
          G.futureSimple,
          alternatives: ['It will be a happy summer.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'hobbies_b6',
      level: _b,
      titleVi: 'Làm vườn',
      titleEn: 'Gardening',
      sentences: [
        WritingSentence.of(
          'Mẹ tôi thích làm vườn.',
          'My mother likes gardening.',
          G.presentSimple,
          alternatives: ['My mom likes gardening.'],
        ),
        WritingSentence.of(
          'Mẹ trồng rau và hoa.',
          'She grows vegetables and flowers.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tôi đang tưới cây.',
          'I am watering the plants.',
          G.presentContinuous,
        ),
        WritingSentence.of(
          'Những bông hoa hồng rất thơm.',
          'The roses smell very nice.',
          G.presentSimple,
          alternatives: ['The roses smell very good.'],
        ),
        WritingSentence.of(
          'Chúng ta không nên tưới quá nhiều nước.',
          'We should not water them too much.',
          G.modal,
          alternatives: ['We shouldn\'t water them too much.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'hobbies_b7',
      level: _b,
      titleVi: 'Đọc sách',
      titleEn: 'Reading',
      sentences: [
        WritingSentence.of(
          'Tôi đọc sách trước khi đi ngủ.',
          'I read books before I go to bed.',
          G.presentSimple,
          alternatives: [
            'I read before going to bed.',
            'I read before I go to bed.',
          ],
        ),
        WritingSentence.of(
          'Tôi thích truyện cổ tích.',
          'I like fairy tales.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tháng trước, tôi đã đọc bốn cuốn sách.',
          'Last month, I read four books.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Tôi mượn sách ở thư viện.',
          'I borrow books from the library.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Thư viện ở gần trường tôi.',
          'The library is near my school.',
          G.presentSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'hobbies_b8',
      level: _b,
      titleVi: 'Đi xem phim',
      titleEn: 'Going to the cinema',
      sentences: [
        WritingSentence.of(
          'Tôi thích xem phim hoạt hình.',
          'I like watching cartoons.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tối nay có một bộ phim mới.',
          'There is a new film tonight.',
          G.presentSimple,
          alternatives: ['There is a new movie tonight.'],
        ),
        WritingSentence.of(
          'Tôi định đi xem với bạn.',
          'I am going to see it with my friend.',
          G.goingTo,
          alternatives: ['I am going to watch it with my friend.'],
        ),
        WritingSentence.of(
          'Chúng tôi sẽ mua bỏng ngô.',
          'We will buy popcorn.',
          G.futureSimple,
        ),
        WritingSentence.of(
          'Tôi không thể chờ được nữa.',
          'I can\'t wait.',
          G.modal,
          alternatives: ['I cannot wait.'],
        ),
      ],
    ),

    // ---------------- Trung cap ----------------
    WritingParagraph(
      id: 'hobbies_i1',
      level: _i,
      titleVi: 'Chạy bộ buổi sáng',
      titleEn: 'Morning runs',
      sentences: [
        WritingSentence.of(
          'Tôi đã chạy bộ mỗi sáng được sáu tháng rồi.',
          'I have gone running every morning for six months.',
          G.presentPerfect,
          alternatives: ['I have been running every morning for six months.'],
        ),
        WritingSentence.of(
          'Lúc đầu, tôi chỉ chạy được một ki-lô-mét.',
          'At first, I could only run one kilometer.',
          G.modal,
          alternatives: ['At first, I could only run one kilometre.'],
        ),
        WritingSentence.of(
          'Bây giờ tôi chạy nhanh hơn và xa hơn trước.',
          'Now I run faster and farther than before.',
          G.comparison,
          alternatives: ['Now I run faster and further than before.'],
        ),
        WritingSentence.of(
          'Sáng qua, trong khi tôi đang chạy quanh hồ, tôi gặp một người bạn cũ.',
          'Yesterday morning, while I was running around the lake, I met an old friend.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Chạy bộ được coi là môn thể thao dễ bắt đầu nhất.',
          'Running is considered the easiest sport to start.',
          G.passive,
          alternatives: [
            'Running is considered the easiest sport to begin with.',
          ],
        ),
        WritingSentence.of(
          'Nếu thời tiết đẹp, chúng tôi sẽ chạy cùng nhau vào cuối tuần.',
          'If the weather is nice, we will run together at the weekend.',
          G.conditional1,
          alternatives: [
            'If the weather is nice, we will run together on the weekend.',
          ],
        ),
      ],
    ),
    WritingParagraph(
      id: 'hobbies_i2',
      level: _i,
      titleVi: 'Bộ sưu tập tem của ông',
      titleEn: 'Grandpa\'s stamp collection',
      sentences: [
        WritingSentence.of(
          'Ông tôi đã sưu tầm tem được hơn bốn mươi năm.',
          'My grandfather has collected stamps for over forty years.',
          G.presentPerfect,
          alternatives: [
            'My grandpa has collected stamps for more than forty years.',
          ],
        ),
        WritingSentence.of(
          'Bộ sưu tập của ông lớn hơn tôi tưởng rất nhiều.',
          'His collection is much bigger than I thought.',
          G.comparison,
          alternatives: ['His collection is much larger than I thought.'],
        ),
        WritingSentence.of(
          'Nhiều con tem được gửi từ những nước rất xa.',
          'Many of the stamps were sent from faraway countries.',
          G.passive,
          alternatives: [
            'Many of the stamps were sent from very distant countries.',
          ],
        ),
        WritingSentence.of(
          'Con tem cũ nhất đã hơn một trăm năm tuổi.',
          'The oldest stamp is more than a hundred years old.',
          G.comparison,
        ),
        WritingSentence.of(
          'Hôm qua, khi tôi đang xem chúng, ông kể cho tôi nghe câu chuyện của chúng.',
          'Yesterday, while I was looking at them, he told me their stories.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Nếu ông đồng ý, tôi sẽ giữ gìn bộ sưu tập này.',
          'If he agrees, I will look after this collection.',
          G.conditional1,
          alternatives: ['If he agrees, I will take care of this collection.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'hobbies_i3',
      level: _i,
      titleVi: 'Học nhảy',
      titleEn: 'Learning to dance',
      sentences: [
        WritingSentence.of(
          'Tháng trước, tôi đã đăng ký một lớp học nhảy.',
          'Last month, I signed up for a dance class.',
          G.pastSimple,
          alternatives: ['Last month, I joined a dance class.'],
        ),
        WritingSentence.of(
          'Tôi chưa bao giờ nhảy trước mặt người khác.',
          'I have never danced in front of other people.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Buổi học đầu tiên khó hơn tôi nghĩ.',
          'The first lesson was harder than I expected.',
          G.comparison,
          alternatives: ['The first lesson was harder than I thought.'],
        ),
        WritingSentence.of(
          'Trong khi mọi người đang nhảy, tôi cứ giẫm lên chân bạn nhảy.',
          'While everyone was dancing, I kept stepping on my partner\'s feet.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Lớp học được dạy bởi một giáo viên rất vui tính.',
          'The class is taught by a very funny teacher.',
          G.passive,
          alternatives: ['The class is taught by a very cheerful teacher.'],
        ),
        WritingSentence.of(
          'Nếu tôi luyện tập chăm chỉ, tôi sẽ nhảy trong buổi biểu diễn cuối năm.',
          'If I practice hard, I will dance in the end of year show.',
          G.conditional1,
          alternatives: [
            'If I practise hard, I will dance in the end of year show.',
            'If I practice hard, I will dance in the end-of-year show.',
            'If I practice hard, I will dance in the show at the end of the year.',
          ],
        ),
      ],
    ),
    WritingParagraph(
      id: 'hobbies_i4',
      level: _i,
      titleVi: 'Em trai mê game',
      titleEn: 'My brother loves games',
      sentences: [
        WritingSentence.of(
          'Em trai tôi chơi game nhiều hơn tôi.',
          'My brother plays video games more than I do.',
          G.comparison,
          alternatives: ['My brother plays video games more than me.'],
        ),
        WritingSentence.of(
          'Nó đã chơi trò chơi này được hai năm.',
          'He has played this game for two years.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Tối qua, khi mẹ gọi đi ăn tối, nó vẫn đang chơi.',
          'Last night, when Mom called him for dinner, he was still playing.',
          G.pastContinuous,
          alternatives: [
            'Last night, when our mother called him for dinner, he was still playing.',
          ],
        ),
        WritingSentence.of(
          'Máy tính của nó bị mẹ cất đi trong một tuần.',
          'His computer was taken away by Mom for a week.',
          G.passive,
          alternatives: [
            'His computer was taken away by our mother for a week.',
          ],
        ),
        WritingSentence.of(
          'Theo tôi, đọc sách tốt hơn chơi game.',
          'In my opinion, reading is better than playing games.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nếu nó chơi ít hơn, nó sẽ có nhiều thời gian học hơn.',
          'If he plays less, he will have more time to study.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'hobbies_i5',
      level: _i,
      titleVi: 'Đan len cùng bà',
      titleEn: 'Knitting with grandma',
      sentences: [
        WritingSentence.of(
          'Gần đây, tôi đã học được cách đan len.',
          'Recently, I have learned how to knit.',
          G.presentPerfect,
          alternatives: ['Recently, I have learnt how to knit.'],
        ),
        WritingSentence.of(
          'Tôi được bà dạy đan.',
          'I was taught by my grandmother.',
          G.passive,
          alternatives: ['I was taught by my grandma.'],
        ),
        WritingSentence.of(
          'Chiếc khăn đầu tiên của tôi ngắn hơn khăn của bà rất nhiều.',
          'My first scarf was much shorter than my grandmother\'s.',
          G.comparison,
          alternatives: ['My first scarf was much shorter than my grandma\'s.'],
        ),
        WritingSentence.of(
          'Trong khi chúng tôi đang đan, bà kể về thời trẻ của mình.',
          'While we were knitting, she told me about her youth.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Tôi đã đan xong ba chiếc khăn.',
          'I have finished three scarves.',
          G.presentPerfect,
          alternatives: ['I have knitted three scarves.'],
        ),
        WritingSentence.of(
          'Nếu kịp, tôi sẽ tặng một chiếc cho bạn thân vào mùa đông này.',
          'If I have time, I will give one to my best friend this winter.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'hobbies_i6',
      level: _i,
      titleVi: 'Cắm trại ở Ba Vì',
      titleEn: 'Camping in Ba Vi',
      sentences: [
        WritingSentence.of(
          'Tuần trước, lớp tôi đã đi cắm trại ở Ba Vì.',
          'Last week, my class went camping in Ba Vi.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Đó là chuyến cắm trại thú vị nhất tôi từng tham gia.',
          'It was the most exciting camping trip I have ever been on.',
          G.comparison,
        ),
        WritingSentence.of(
          'Lều được dựng bên cạnh một con suối nhỏ.',
          'The tents were put up next to a small stream.',
          G.passive,
          alternatives: ['The tents were set up next to a small stream.'],
        ),
        WritingSentence.of(
          'Buổi tối, trong khi chúng tôi đang nướng thịt, trời bắt đầu mưa.',
          'In the evening, while we were grilling meat, it started to rain.',
          G.pastContinuous,
          alternatives: [
            'In the evening, while we were having a barbecue, it started to rain.',
          ],
        ),
        WritingSentence.of(
          'Tôi chưa bao giờ ngủ ngoài trời trước đây.',
          'I have never slept outdoors before.',
          G.presentPerfect,
          alternatives: ['I have never slept outside before.'],
        ),
        WritingSentence.of(
          'Nếu có dịp, tôi sẽ đi cắm trại lần nữa.',
          'If I have a chance, I will go camping again.',
          G.conditional1,
          alternatives: ['If I get the chance, I will go camping again.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'hobbies_i7',
      level: _i,
      titleVi: 'Vẽ màu nước',
      titleEn: 'Watercolor painting',
      sentences: [
        WritingSentence.of(
          'Tôi đã học vẽ màu nước được ba tháng.',
          'I have studied watercolor painting for three months.',
          G.presentPerfect,
          alternatives: [
            'I have studied watercolour painting for three months.',
          ],
        ),
        WritingSentence.of(
          'Vẽ màu nước khó hơn vẽ bằng bút chì.',
          'Watercolor painting is harder than drawing with a pencil.',
          G.comparison,
          alternatives: [
            'Watercolour painting is harder than drawing with a pencil.',
          ],
        ),
        WritingSentence.of(
          'Bức tranh đầu tiên của tôi được treo trong lớp.',
          'My first painting was hung in the classroom.',
          G.passive,
        ),
        WritingSentence.of(
          'Hôm qua, trong khi tôi đang vẽ ngoài công viên, một cậu bé đến xem.',
          'Yesterday, while I was painting in the park, a little boy came to watch.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Cậu bé nói tranh của tôi đẹp nhất.',
          'He said my painting was the best.',
          G.comparison,
          alternatives: ['He said that my painting was the best.'],
        ),
        WritingSentence.of(
          'Nếu tôi tiếp tục học, tôi sẽ tổ chức một buổi triển lãm nhỏ.',
          'If I keep studying, I will hold a small exhibition.',
          G.conditional1,
          alternatives: ['If I keep learning, I will hold a small exhibition.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'hobbies_i8',
      level: _i,
      titleVi: 'Bể cá của bố',
      titleEn: 'Dad\'s fish tank',
      sentences: [
        WritingSentence.of(
          'Bố tôi đã nuôi cá cảnh được hơn mười năm.',
          'My father has kept pet fish for over ten years.',
          G.presentPerfect,
          alternatives: ['My dad has kept pet fish for more than ten years.'],
        ),
        WritingSentence.of(
          'Bể cá của bố to hơn cả bàn học của tôi.',
          'His fish tank is bigger than my desk.',
          G.comparison,
        ),
        WritingSentence.of(
          'Cá được cho ăn hai lần một ngày.',
          'The fish are fed twice a day.',
          G.passive,
        ),
        WritingSentence.of(
          'Tối qua, trong khi bố đang lau bể, một con cá nhảy ra ngoài.',
          'Last night, while my father was cleaning the tank, a fish jumped out.',
          G.pastContinuous,
          alternatives: [
            'Last night, while my dad was cleaning the tank, a fish jumped out.',
          ],
        ),
        WritingSentence.of(
          'May mắn thay, nó được thả lại vào nước kịp thời.',
          'Luckily, it was put back in the water in time.',
          G.passive,
        ),
        WritingSentence.of(
          'Nếu bố cho phép, tôi sẽ nuôi một bể cá riêng.',
          'If my father allows me, I will keep my own fish tank.',
          G.conditional1,
          alternatives: ['If my dad lets me, I will have my own fish tank.'],
        ),
      ],
    ),

    // ---------------- Nang cao ----------------
    WritingParagraph(
      id: 'hobbies_a1',
      level: _a,
      titleVi: 'Nhiếp ảnh đường phố',
      titleEn: 'Street photography',
      sentences: [
        WritingSentence.of(
          'Nhiếp ảnh đường phố, thứ tôi bắt đầu thử cách đây hai năm, đã thay đổi cách tôi nhìn thành phố.',
          'Street photography, which I started two years ago, has changed the way I see my city.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Tôi đã và đang ghi lại những khoảnh khắc đời thường ở khu phố cổ Hà Nội.',
          'I have been capturing everyday moments in the old quarter of Hanoi.',
          G.presentPerfectContinuous,
        ),
        WritingSentence.of(
          'Một nhiếp ảnh gia nổi tiếng khuyên tôi rằng tôi nên luôn xin phép trước khi chụp chân dung.',
          'A famous photographer advised me that I should always ask permission before taking portraits.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Trước khi nghe lời khuyên đó, tôi đã chụp nhiều người mà không hỏi họ.',
          'Before hearing that advice, I had photographed many people without asking them.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Nếu tôi có một chiếc máy ảnh tốt hơn, tôi sẽ thử chụp đêm nhiều hơn.',
          'If I had a better camera, I would try more night photography.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Đến tháng sau, tôi sẽ chụp đủ ảnh cho một cuốn sách ảnh nhỏ.',
          'By next month, I will have taken enough photos for a small photo book.',
          G.futurePerfect,
        ),
      ],
    ),
    WritingParagraph(
      id: 'hobbies_a2',
      level: _a,
      titleVi: 'Học piano khi đã lớn',
      titleEn: 'Learning the piano as an adult',
      sentences: [
        WritingSentence.of(
          'Tôi luôn ước giá như mình đã được học piano từ nhỏ.',
          'I have always wished that I had learned the piano as a child.',
          G.pastPerfect,
          alternatives: [
            'I have always wished that I had learnt the piano as a child.',
          ],
        ),
        WritingSentence.of(
          'Năm ngoái, ở tuổi ba mươi, cuối cùng tôi cũng đăng ký một khoá học.',
          'Last year, at the age of thirty, I finally signed up for lessons.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Cô giáo của tôi, người trẻ hơn tôi mười tuổi, rất kiên nhẫn với những lỗi của tôi.',
          'My teacher, who is ten years younger than me, is very patient with my mistakes.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Suốt một năm qua, tối nào tôi cũng luyện tập.',
          'I have been practicing every evening for the past year.',
          G.presentPerfectContinuous,
          alternatives: [
            'I have been practising every evening for the past year.',
          ],
        ),
        WritingSentence.of(
          'Nếu tôi bắt đầu sớm hơn, giờ này tôi đã chơi giỏi hơn nhiều.',
          'If I had started earlier, I would have become much better by now.',
          G.conditional3,
        ),
        WritingSentence.of(
          'Vào giờ này năm sau, tôi sẽ đang biểu diễn trong buổi hoà nhạc đầu tiên của mình.',
          'This time next year, I will be performing in my first concert.',
          G.futureContinuous,
        ),
      ],
    ),
    WritingParagraph(
      id: 'hobbies_a3',
      level: _a,
      titleVi: 'Cuộc chạy marathon đầu tiên',
      titleEn: 'A first marathon',
      sentences: [
        WritingSentence.of(
          'Chị gái tôi, người từng ghét thể thao, vừa hoàn thành cuộc chạy marathon đầu tiên.',
          'My sister, who used to hate sport, has just finished her first marathon.',
          G.relativeClause,
          alternatives: [
            'My sister, who used to hate sports, has just finished her first marathon.',
          ],
        ),
        WritingSentence.of(
          'Chị ấy đã tập luyện gần một năm trước cuộc đua.',
          'She had been training for almost a year before the race.',
          G.pastPerfectContinuous,
        ),
        WritingSentence.of(
          'Huấn luyện viên nói với chị rằng điều quan trọng nhất là giữ nhịp độ ổn định.',
          'Her coach told her that the most important thing was to keep a steady pace.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Khi đến ki-lô-mét thứ ba mươi, chị ấy suýt bỏ cuộc.',
          'When she reached the thirtieth kilometer, she almost gave up.',
          G.pastSimple,
          alternatives: [
            'When she reached the thirtieth kilometre, she almost gave up.',
          ],
        ),
        WritingSentence.of(
          'Nếu cả nhà không đứng cổ vũ ở vạch đích, có lẽ chị đã không cố gắng đến cùng.',
          'If our family had not been cheering at the finish line, she might not have kept going.',
          G.conditional3,
        ),
        WritingSentence.of(
          'Sau cuộc đua, chị ấy đăng ký luôn một giải khác vào mùa xuân năm sau.',
          'After the race, she signed up for another one next spring.',
          G.pastSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'hobbies_a4',
      level: _a,
      titleVi: 'Khu vườn trên sân thượng',
      titleEn: 'A rooftop garden',
      sentences: [
        WritingSentence.of(
          'Căn hộ của chúng tôi, vốn không có sân, giờ đã có một khu vườn nhỏ trên sân thượng.',
          'Our apartment, which has no yard, now has a small garden on the roof.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Từ đầu năm đến nay, bố tôi đã và đang trồng rau sạch trên đó.',
          'My father has been growing clean vegetables up there since the beginning of the year.',
          G.presentPerfectContinuous,
          alternatives: [
            'My dad has been growing clean vegetables up there since the beginning of the year.',
          ],
        ),
        WritingSentence.of(
          'Trước khi bắt đầu, bố đã xem hàng chục video hướng dẫn trên mạng.',
          'Before starting, he had watched dozens of tutorial videos online.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Mỗi sáng, cây được tưới bằng nước mưa hứng từ mái nhà.',
          'Every morning, the plants are watered with rainwater collected from the roof.',
          G.passive,
        ),
        WritingSentence.of(
          'Nếu nhiều gia đình trong thành phố làm như vậy, không khí sẽ trong lành hơn.',
          'If more families in the city did the same, the air would be fresher.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Bố tôi hay nói rằng làm vườn giúp ông quên hết mệt mỏi sau giờ làm.',
          'My father often says that gardening helps him forget the stress of work.',
          G.presentSimple,
          alternatives: [
            'My dad often says that gardening helps him forget the stress of work.',
          ],
        ),
      ],
    ),
    WritingParagraph(
      id: 'hobbies_a5',
      level: _a,
      titleVi: 'Khi sở thích thành nghề',
      titleEn: 'When a hobby becomes a job',
      sentences: [
        WritingSentence.of(
          'Anh họ tôi bắt đầu làm bánh chỉ như một sở thích khi còn học đại học.',
          'My cousin started baking just as a hobby when he was at university.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Bánh của anh ấy ngon đến mức bạn bè liên tục nhờ anh làm cho các bữa tiệc.',
          'His cakes were so good that his friends kept asking him to bake for parties.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Anh ấy đã bán bánh trên mạng suốt ba năm trước khi mở tiệm đầu tiên.',
          'He had been selling cakes online for three years before he opened his first shop.',
          G.pastPerfectContinuous,
        ),
        WritingSentence.of(
          'Anh ấy thừa nhận rằng biến sở thích thành công việc không hề dễ dàng.',
          'He admitted that turning a hobby into a job had not been easy.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu anh ấy làm kế toán như bố mẹ muốn, có lẽ anh đã không bao giờ tìm thấy đam mê của mình.',
          'If he had become an accountant as his parents wanted, he might never have found his passion.',
          G.conditional3,
        ),
        WritingSentence.of(
          'Đến cuối năm nay, tiệm bánh của anh sẽ phục vụ được hơn mười nghìn khách hàng.',
          'By the end of this year, his bakery will have served more than ten thousand customers.',
          G.futurePerfect,
        ),
      ],
    ),
    WritingParagraph(
      id: 'hobbies_a6',
      level: _a,
      titleVi: 'Thời gian rảnh và mạng xã hội',
      titleEn: 'Free time and social media',
      sentences: [
        WritingSentence.of(
          'Nhiều người trẻ dành phần lớn thời gian rảnh cho mạng xã hội thay vì theo đuổi sở thích.',
          'Many young people spend most of their free time on social media instead of pursuing hobbies.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tôi từng như vậy cho đến khi tính ra mình đã lãng phí bao nhiêu giờ.',
          'I used to be like that until I calculated how many hours I had wasted.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Một cuộc khảo sát cho thấy người dùng trung bình dành hơn ba tiếng mỗi ngày trên điện thoại.',
          'A survey found that the average user spends more than three hours a day on their phone.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Nếu tôi dùng số thời gian đó để học ngoại ngữ, tôi sẽ tiến bộ nhanh hơn nhiều.',
          'If I spent that time learning a language, I would make much faster progress.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Từ khi xoá bớt ứng dụng, tôi đã đọc xong mười cuốn sách.',
          'Since I deleted some apps, I have finished ten books.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Bạn bè hỏi tôi liệu tôi có sợ bỏ lỡ tin tức không.',
          'My friends asked me whether I was afraid of missing out on the news.',
          G.reportedSpeech,
          alternatives: [
            'My friends asked me if I was afraid of missing out on the news.',
          ],
        ),
      ],
    ),
    WritingParagraph(
      id: 'hobbies_a7',
      level: _a,
      titleVi: 'Học ngoại ngữ thứ ba',
      titleEn: 'Learning a third language',
      sentences: [
        WritingSentence.of(
          'Sau khi thành thạo tiếng Anh, tôi quyết định học thêm tiếng Hàn như một sở thích.',
          'After becoming fluent in English, I decided to learn Korean as a hobby.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Tôi đã học tiếng Hàn được tám tháng, chủ yếu qua phim và bài hát.',
          'I have been learning Korean for eight months, mainly through films and songs.',
          G.presentPerfectContinuous,
          alternatives: [
            'I have been learning Korean for eight months, mainly through movies and songs.',
          ],
        ),
        WritingSentence.of(
          'Bảng chữ cái Hangul, được tạo ra từ thế kỷ mười lăm, dễ học hơn tôi tưởng.',
          'The Hangul alphabet, which was created in the fifteenth century, was easier to learn than I expected.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Cô giáo nói rằng phát âm của tôi đã tiến bộ rất nhiều.',
          'My teacher said that my pronunciation had improved a lot.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu tôi có cơ hội sống ở Seoul một năm, tôi sẽ nói trôi chảy nhanh hơn nhiều.',
          'If I had the chance to live in Seoul for a year, I would become fluent much faster.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Đến kỳ nghỉ hè, tôi sẽ học xong cuốn giáo trình đầu tiên.',
          'By the summer holiday, I will have finished my first textbook.',
          G.futurePerfect,
        ),
      ],
    ),
    WritingParagraph(
      id: 'hobbies_a8',
      level: _a,
      titleVi: 'Làm tình nguyện',
      titleEn: 'Volunteering',
      sentences: [
        WritingSentence.of(
          'Mỗi cuối tuần, tôi dạy tiếng Anh miễn phí cho trẻ em ở một mái ấm.',
          'Every weekend, I spend time teaching English for free to children at a shelter.',
          G.presentSimple,
          alternatives: [
            'Every weekend, I teach English for free to children at a shelter.',
          ],
        ),
        WritingSentence.of(
          'Tôi đã làm tình nguyện viên ở đó được gần hai năm.',
          'I have been volunteering there for almost two years.',
          G.presentPerfectContinuous,
        ),
        WritingSentence.of(
          'Những đứa trẻ mà tôi dạy luôn chào đón tôi bằng những nụ cười.',
          'The children whom I teach always welcome me with big smiles.',
          G.relativeClause,
          alternatives: [
            'The children that I teach always welcome me with big smiles.',
            'The children I teach always welcome me with big smiles.',
          ],
        ),
        WritingSentence.of(
          'Trước khi làm tình nguyện, tôi chưa từng nghĩ mình đủ kiên nhẫn để dạy học.',
          'Before volunteering, I had never thought I was patient enough to teach.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Người quản lý mái ấm nói rằng các em đã tiến bộ rất nhiều trong năm qua.',
          'The shelter manager said that the children had made great progress over the past year.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu có thêm người tham gia, chúng tôi sẽ mở thêm một lớp vào tối thứ tư.',
          'If more people join, we will open another class on Wednesday evenings.',
          G.conditional1,
        ),
      ],
    ),
  ],
);
