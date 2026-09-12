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

const kWritingBankSports = WritingTopic(
  id: 'sports',
  titleVi: 'Thể thao',
  titleEn: 'Sports',
  icon: Icons.sports_soccer_rounded,
  color: AppColors.pink,
  paragraphs: [
    // ---------------- Co ban ----------------
    WritingParagraph(
      id: 'sports_b1',
      level: _b,
      titleVi: 'Môn thể thao yêu thích',
      titleEn: 'My favorite sport',
      sentences: [
        WritingSentence.of(
          'Tôi thích bóng đá nhất.',
          'I like football the most.',
          G.presentSimple,
          alternatives: ['I like soccer the most.'],
        ),
        WritingSentence.of(
          'Tôi chơi bóng đá mỗi chiều thứ bảy.',
          'I play football every Saturday afternoon.',
          G.presentSimple,
          alternatives: ['I play soccer every Saturday afternoon.'],
        ),
        WritingSentence.of(
          'Tôi có thể chạy rất nhanh.',
          'I can run very fast.',
          G.modal,
        ),
        WritingSentence.of(
          'Bạn tôi là thủ môn.',
          'My friend is the goalkeeper.',
          G.presentSimple,
          alternatives: ['My friend is a goalkeeper.'],
        ),
        WritingSentence.of(
          'Chúng tôi chơi trong công viên.',
          'We play in the park.',
          G.presentSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'sports_b2',
      level: _b,
      titleVi: 'Trận đấu hôm qua',
      titleEn: 'Yesterday\'s match',
      sentences: [
        WritingSentence.of(
          'Hôm qua đội tôi đã chơi một trận.',
          'Yesterday my team played a match.',
          G.pastSimple,
          alternatives: ['My team played a match yesterday.'],
        ),
        WritingSentence.of(
          'Tôi đã ghi hai bàn.',
          'I scored two goals.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Đội tôi đã thắng ba một.',
          'My team won three to one.',
          G.pastSimple,
          alternatives: ['We won three to one.'],
        ),
        WritingSentence.of(
          'Bố mẹ tôi đã đến xem.',
          'My parents came to watch.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Họ đã rất tự hào.',
          'They were very proud.',
          G.pastSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'sports_b3',
      level: _b,
      titleVi: 'Ở bể bơi',
      titleEn: 'At the pool',
      sentences: [
        WritingSentence.of(
          'Bây giờ tôi đang ở bể bơi.',
          'I am at the swimming pool now.',
          G.presentSimple,
          alternatives: ['Now I am at the swimming pool.'],
        ),
        WritingSentence.of(
          'Em gái tôi đang học bơi.',
          'My sister is learning to swim.',
          G.presentContinuous,
          alternatives: ['My younger sister is learning to swim.'],
        ),
        WritingSentence.of(
          'Huấn luyện viên đang giúp em ấy.',
          'The coach is helping her.',
          G.presentContinuous,
        ),
        WritingSentence.of(
          'Nước hơi lạnh.',
          'The water is a little cold.',
          G.presentSimple,
          alternatives: ['The water is a bit cold.'],
        ),
        WritingSentence.of(
          'Chúng ta phải đội mũ bơi.',
          'We must wear a swimming cap.',
          G.modal,
          alternatives: ['We have to wear swimming caps.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'sports_b4',
      level: _b,
      titleVi: 'Cầu lông với bố',
      titleEn: 'Badminton with dad',
      sentences: [
        WritingSentence.of(
          'Bố tôi thích chơi cầu lông.',
          'My father likes playing badminton.',
          G.presentSimple,
          alternatives: ['My dad likes playing badminton.'],
        ),
        WritingSentence.of(
          'Chúng tôi chơi trước nhà mỗi tối.',
          'We play in front of our house every evening.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Bố đánh rất mạnh.',
          'He hits very hard.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tôi thường thua.',
          'I usually lose.',
          G.presentSimple,
          alternatives: ['I often lose.'],
        ),
        WritingSentence.of(
          'Một ngày nào đó, tôi sẽ thắng bố.',
          'One day, I will beat him.',
          G.futureSimple,
          alternatives: ['Someday, I will beat him.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'sports_b5',
      level: _b,
      titleVi: 'Ngày hội thể thao',
      titleEn: 'Sports day',
      sentences: [
        WritingSentence.of(
          'Thứ sáu tới là ngày hội thể thao của trường.',
          'Next Friday is our school sports day.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tôi định chạy thi một trăm mét.',
          'I am going to run the hundred meters.',
          G.goingTo,
          alternatives: ['I am going to run the hundred metres.'],
        ),
        WritingSentence.of(
          'Bạn tôi định nhảy xa.',
          'My friend is going to do the long jump.',
          G.goingTo,
        ),
        WritingSentence.of(
          'Lớp tôi sẽ chơi kéo co.',
          'My class will play tug of war.',
          G.futureSimple,
        ),
        WritingSentence.of(
          'Chắc chắn sẽ rất vui.',
          'It will be a lot of fun.',
          G.futureSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'sports_b6',
      level: _b,
      titleVi: 'Tập thể dục buổi sáng',
      titleEn: 'Morning exercise',
      sentences: [
        WritingSentence.of(
          'Ông bà tôi tập thể dục mỗi sáng.',
          'My grandparents exercise every morning.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Họ tập ở bờ hồ.',
          'They exercise by the lake.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Bà đang tập thái cực quyền.',
          'My grandmother is doing tai chi.',
          G.presentContinuous,
          alternatives: ['My grandma is doing tai chi.'],
        ),
        WritingSentence.of(
          'Ông đang đi bộ quanh hồ.',
          'My grandfather is walking around the lake.',
          G.presentContinuous,
          alternatives: ['My grandpa is walking around the lake.'],
        ),
        WritingSentence.of(
          'Họ khoẻ mạnh và vui vẻ.',
          'They are healthy and happy.',
          G.presentSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'sports_b7',
      level: _b,
      titleVi: 'Xem bóng đá',
      titleEn: 'Watching football',
      sentences: [
        WritingSentence.of(
          'Tối qua cả nhà tôi đã xem bóng đá.',
          'Last night my family watched football.',
          G.pastSimple,
          alternatives: ['Last night my family watched a football match.'],
        ),
        WritingSentence.of(
          'Việt Nam đã đá với Thái Lan.',
          'Vietnam played against Thailand.',
          G.pastSimple,
          alternatives: ['Vietnam played Thailand.'],
        ),
        WritingSentence.of(
          'Chúng tôi đã hét rất to.',
          'We shouted very loudly.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Việt Nam đã thắng hai không.',
          'Vietnam won two nil.',
          G.pastSimple,
          alternatives: [
            'Vietnam won two to nothing.',
            'Vietnam won two to zero.',
          ],
        ),
        WritingSentence.of(
          'Mọi người đã xuống đường ăn mừng.',
          'Everyone went into the streets to celebrate.',
          G.pastSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'sports_b8',
      level: _b,
      titleVi: 'Học võ',
      titleEn: 'Learning martial arts',
      sentences: [
        WritingSentence.of(
          'Anh trai tôi học võ.',
          'My brother does martial arts.',
          G.presentSimple,
          alternatives: ['My older brother learns martial arts.'],
        ),
        WritingSentence.of(
          'Anh ấy tập ba buổi mỗi tuần.',
          'He trains three times a week.',
          G.presentSimple,
          alternatives: ['He practices three times a week.'],
        ),
        WritingSentence.of(
          'Anh ấy có thể đá rất cao.',
          'He can kick very high.',
          G.modal,
        ),
        WritingSentence.of(
          'Tháng sau, anh ấy định thi lấy đai đen.',
          'He is going to get his black belt next month.',
          G.goingTo,
        ),
        WritingSentence.of(
          'Tôi sẽ đến cổ vũ anh ấy.',
          'I will go and cheer for him.',
          G.futureSimple,
        ),
      ],
    ),

    // ---------------- Trung cap ----------------
    WritingParagraph(
      id: 'sports_i1',
      level: _i,
      titleVi: 'Đội bóng của trường',
      titleEn: 'The school football team',
      sentences: [
        WritingSentence.of(
          'Tôi đã chơi cho đội bóng của trường được hai năm.',
          'I have played for the school football team for two years.',
          G.presentPerfect,
          alternatives: [
            'I have played for the school soccer team for two years.',
          ],
        ),
        WritingSentence.of(
          'Đội năm nay mạnh hơn đội năm ngoái nhiều.',
          'This year\'s team is much stronger than last year\'s.',
          G.comparison,
        ),
        WritingSentence.of(
          'Chúng tôi được huấn luyện bởi một cựu cầu thủ chuyên nghiệp.',
          'We are trained by a former professional player.',
          G.passive,
        ),
        WritingSentence.of(
          'Trận trước, trong khi tôi đang chạy, tôi bị trẹo chân.',
          'In the last match, while I was running, I twisted my ankle.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Đó là chấn thương đau nhất tôi từng gặp.',
          'It was the most painful injury I have ever had.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nếu chân tôi lành, tôi sẽ đá trận chung kết.',
          'If my ankle heals, I will play in the final.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'sports_i2',
      level: _i,
      titleVi: 'Chạy bộ vì cộng đồng',
      titleEn: 'A charity run',
      sentences: [
        WritingSentence.of(
          'Chủ nhật tuần trước, tôi đã tham gia một giải chạy từ thiện.',
          'Last Sunday, I took part in a charity run.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Tiền được quyên góp cho trẻ em vùng cao.',
          'The money was donated to children in the mountains.',
          G.passive,
        ),
        WritingSentence.of(
          'Quãng đường dài hơn tôi nghĩ.',
          'The route was longer than I thought.',
          G.comparison,
        ),
        WritingSentence.of(
          'Trong khi tôi đang chạy, nhiều người dân đứng hai bên đường cổ vũ.',
          'While I was running, many people stood along the road cheering.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Tôi chưa bao giờ chạy xa như vậy.',
          'I have never run so far.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Nếu năm sau có giải, tôi sẽ rủ bạn bè cùng chạy.',
          'If there is another race next year, I will ask my friends to join.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'sports_i3',
      level: _i,
      titleVi: 'Bóng rổ',
      titleEn: 'Basketball',
      sentences: [
        WritingSentence.of(
          'Bóng rổ đang ngày càng phổ biến ở Việt Nam.',
          'Basketball is becoming more and more popular in Vietnam.',
          G.presentContinuous,
        ),
        WritingSentence.of(
          'Anh họ tôi cao nhất trong đội bóng rổ.',
          'My cousin is the tallest player on the basketball team.',
          G.comparison,
        ),
        WritingSentence.of(
          'Anh ấy đã chơi bóng rổ từ năm mười tuổi.',
          'He has played basketball since he was ten.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Tối qua, khi anh ấy đang ném bóng, đèn sân vận động tắt.',
          'Last night, while he was shooting, the stadium lights went out.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Trận đấu bị hoãn đến tuần sau.',
          'The game was put off until next week.',
          G.passive,
          alternatives: ['The game was postponed until next week.'],
        ),
        WritingSentence.of(
          'Nếu đội anh ấy thắng, họ sẽ vào chung kết.',
          'If his team wins, they will reach the final.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'sports_i4',
      level: _i,
      titleVi: 'Leo núi trong nhà',
      titleEn: 'Indoor climbing',
      sentences: [
        WritingSentence.of(
          'Tháng trước, tôi đã thử leo núi trong nhà lần đầu tiên.',
          'Last month, I tried indoor climbing for the first time.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Tường leo cao hơn tôi tưởng rất nhiều.',
          'The wall was much higher than I imagined.',
          G.comparison,
        ),
        WritingSentence.of(
          'Mỗi người leo đều được buộc dây an toàn.',
          'Every climber is tied to a safety rope.',
          G.passive,
        ),
        WritingSentence.of(
          'Trong khi tôi đang leo lên đỉnh, tay tôi bắt đầu run.',
          'While I was climbing to the top, my hands started shaking.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Kể từ đó, tôi đã đi leo mỗi cuối tuần.',
          'Since then, I have gone climbing every weekend.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Nếu tôi tập đều, tôi sẽ leo được tường khó nhất.',
          'If I train regularly, I will climb the hardest wall.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'sports_i5',
      level: _i,
      titleVi: 'SEA Games',
      titleEn: 'The SEA Games',
      sentences: [
        WritingSentence.of(
          'SEA Games là đại hội thể thao lớn nhất Đông Nam Á.',
          'The SEA Games is the biggest sports event in Southeast Asia.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nó được tổ chức hai năm một lần.',
          'It is held every two years.',
          G.passive,
        ),
        WritingSentence.of(
          'Việt Nam đã giành được nhiều huy chương vàng.',
          'Vietnam has won many gold medals.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Khi đội tuyển đang thi đấu trận chung kết, cả phố im lặng theo dõi.',
          'While the national team was playing the final, the whole street watched in silence.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Chiến thắng năm đó ngọt ngào hơn bất kỳ chiến thắng nào khác.',
          'That victory was sweeter than any other.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nếu kỳ tới được tổ chức ở Việt Nam, tôi sẽ đi xem trực tiếp.',
          'If the next games are held in Vietnam, I will watch them live.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'sports_i6',
      level: _i,
      titleVi: 'Học bơi khi đã lớn',
      titleEn: 'Learning to swim as a teenager',
      sentences: [
        WritingSentence.of(
          'Tôi đã sợ nước từ khi còn nhỏ.',
          'I have been afraid of water since I was small.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Mùa hè này, tôi được bố mẹ đăng ký một khoá học bơi.',
          'This summer, I was signed up for swimming lessons by my parents.',
          G.passive,
        ),
        WritingSentence.of(
          'Buổi học đầu tiên đáng sợ hơn tôi nghĩ.',
          'The first lesson was scarier than I thought.',
          G.comparison,
        ),
        WritingSentence.of(
          'Trong khi tôi đang tập thở, tôi bị sặc nước.',
          'While I was practicing breathing, I swallowed some water.',
          G.pastContinuous,
          alternatives: [
            'While I was practising breathing, I swallowed some water.',
          ],
        ),
        WritingSentence.of(
          'Bây giờ tôi đã bơi được hai mươi lăm mét.',
          'Now I can swim twenty five meters.',
          G.modal,
          alternatives: [
            'Now I can swim twenty-five meters.',
            'Now I can swim twenty five metres.',
          ],
        ),
        WritingSentence.of(
          'Nếu tôi tiếp tục, tôi sẽ không sợ nước nữa.',
          'If I keep going, I will not be afraid of water anymore.',
          G.conditional1,
          alternatives: [
            'If I keep going, I won\'t be afraid of water anymore.',
          ],
        ),
      ],
    ),
    WritingParagraph(
      id: 'sports_i7',
      level: _i,
      titleVi: 'Đá cầu và trò chơi dân gian',
      titleEn: 'Traditional games',
      sentences: [
        WritingSentence.of(
          'Đá cầu là một trò chơi truyền thống của Việt Nam.',
          'Shuttlecock kicking is a traditional Vietnamese game.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Chiếc cầu được làm từ lông gà và đế cao su.',
          'The shuttlecock is made from feathers and a rubber base.',
          G.passive,
        ),
        WritingSentence.of(
          'Nó rẻ hơn và dễ chơi hơn nhiều môn thể thao khác.',
          'It is cheaper and easier than many other sports.',
          G.comparison,
        ),
        WritingSentence.of(
          'Tôi đã chơi đá cầu với bạn bè từ hồi tiểu học.',
          'I have played shuttlecock with my friends since primary school.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Hôm qua, khi chúng tôi đang chơi, quả cầu bay lên mái nhà.',
          'Yesterday, while we were playing, the shuttlecock flew onto a roof.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Nếu có thời gian, tôi sẽ dạy em trai chơi.',
          'If I have time, I will teach my brother to play.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'sports_i8',
      level: _i,
      titleVi: 'Thua trận',
      titleEn: 'Losing a match',
      sentences: [
        WritingSentence.of(
          'Tuần trước, đội bóng chuyền của tôi đã thua trận bán kết.',
          'Last week, my volleyball team lost the semi final.',
          G.pastSimple,
          alternatives: ['Last week, my volleyball team lost the semi-final.'],
        ),
        WritingSentence.of(
          'Đội bạn cao hơn và kinh nghiệm hơn chúng tôi.',
          'The other team was taller and more experienced than us.',
          G.comparison,
        ),
        WritingSentence.of(
          'Trong khi chúng tôi đang dẫn điểm, đội trưởng bị chấn thương.',
          'While we were leading, our captain got injured.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Cô ấy được đưa ra khỏi sân ngay lập tức.',
          'She was taken off the court immediately.',
          G.passive,
        ),
        WritingSentence.of(
          'Chúng tôi đã học được rằng thua cũng là một bài học.',
          'We have learned that losing is also a lesson.',
          G.presentPerfect,
          alternatives: ['We have learnt that losing is also a lesson.'],
        ),
        WritingSentence.of(
          'Nếu tập luyện chăm chỉ, năm sau chúng tôi sẽ vào chung kết.',
          'If we train hard, we will reach the final next year.',
          G.conditional1,
        ),
      ],
    ),

    // ---------------- Nang cao ----------------
    WritingParagraph(
      id: 'sports_a1',
      level: _a,
      titleVi: 'Bóng đá Việt Nam',
      titleEn: 'Vietnamese football',
      sentences: [
        WritingSentence.of(
          'Bóng đá, môn thể thao được yêu thích nhất ở Việt Nam, có thể khiến cả nước xuống đường ăn mừng.',
          'Football, which is the most popular sport in Vietnam, can bring the whole country onto the streets.',
          G.relativeClause,
          alternatives: [
            'Soccer, which is the most popular sport in Vietnam, can bring the whole country onto the streets.',
          ],
        ),
        WritingSentence.of(
          'Đội tuyển quốc gia đã tiến bộ vượt bậc trong mười năm qua.',
          'The national team has improved enormously over the past ten years.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Trước khi có huấn luyện viên mới, đội chưa từng vào đến vòng loại cuối cùng của World Cup.',
          'Before the new coach arrived, the team had never reached the final round of World Cup qualifying.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Một bình luận viên nói rằng thế hệ cầu thủ này là thế hệ tài năng nhất từ trước đến nay.',
          'A commentator said that this generation of players was the most talented ever.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu các câu lạc bộ đầu tư nhiều hơn vào cầu thủ trẻ, đội tuyển sẽ còn mạnh hơn nữa.',
          'If clubs invested more in young players, the national team would be even stronger.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Nhiều người hy vọng đến cuối thập kỷ này, Việt Nam sẽ được dự một kỳ World Cup.',
          'Many people hope that by the end of this decade, Vietnam will have played at a World Cup.',
          G.futurePerfect,
        ),
      ],
    ),
    WritingParagraph(
      id: 'sports_a2',
      level: _a,
      titleVi: 'Vận động viên khuyết tật',
      titleEn: 'A para athlete',
      sentences: [
        WritingSentence.of(
          'Chú hàng xóm của tôi, người mất một chân trong một tai nạn, là vận động viên cử tạ quốc gia.',
          'My neighbor, who lost a leg in an accident, is a national weightlifting champion.',
          G.relativeClause,
          alternatives: [
            'My neighbour, who lost a leg in an accident, is a national weightlifting champion.',
          ],
        ),
        WritingSentence.of(
          'Chú đã tập luyện sáu ngày mỗi tuần suốt mười năm qua.',
          'He has been training six days a week for the past ten years.',
          G.presentPerfectContinuous,
        ),
        WritingSentence.of(
          'Trước tai nạn, chú chưa từng chơi môn thể thao nào một cách nghiêm túc.',
          'Before the accident, he had never played any sport seriously.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Chú nói với tôi rằng thể thao đã cho chú một cuộc sống mới.',
          'He told me that sport had given him a new life.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu chú bỏ cuộc sau tai nạn, chú đã không bao giờ đứng trên bục nhận huy chương.',
          'If he had given up after the accident, he would never have stood on the podium.',
          G.conditional3,
        ),
        WritingSentence.of(
          'Vào giờ này năm sau, chú sẽ đang thi đấu tại Paralympic.',
          'This time next year, he will be competing at the Paralympics.',
          G.futureContinuous,
        ),
      ],
    ),
    WritingParagraph(
      id: 'sports_a3',
      level: _a,
      titleVi: 'Thể thao điện tử',
      titleEn: 'Esports',
      sentences: [
        WritingSentence.of(
          'Thể thao điện tử, từng bị coi chỉ là trò chơi, giờ đã có mặt tại các đại hội thể thao lớn.',
          'Esports, which were once seen as just games, are now part of major sporting events.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Anh họ tôi đã chơi game chuyên nghiệp được ba năm.',
          'My cousin has been playing games professionally for three years.',
          G.presentPerfectContinuous,
        ),
        WritingSentence.of(
          'Khi anh ấy giành giải đầu tiên, bố mẹ anh đã phản đối suốt nhiều năm.',
          'By the time he won his first prize, his parents had opposed his career for years.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Anh ấy giải thích rằng game thủ chuyên nghiệp phải luyện tập như vận động viên thật sự.',
          'He explained that professional gamers had to train like real athletes.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu thể thao điện tử được công nhận rộng rãi hơn, nhiều bạn trẻ sẽ theo đuổi nghề này.',
          'If esports were more widely accepted, more young people would choose this career.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Tuy nhiên, các bác sĩ cảnh báo rằng ngồi quá lâu có thể gây hại cho sức khỏe.',
          'However, doctors have warned that sitting for too long can damage your health.',
          G.presentPerfect,
        ),
      ],
    ),
    WritingParagraph(
      id: 'sports_a4',
      level: _a,
      titleVi: 'Chuyến leo Fansipan',
      titleEn: 'Climbing Fansipan',
      sentences: [
        WritingSentence.of(
          'Fansipan, ngọn núi cao nhất Đông Dương, luôn là thử thách với những người yêu leo núi.',
          'Fansipan, which is the highest mountain in Indochina, is always a challenge for climbers.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Chúng tôi đã leo suốt mười tiếng khi cuối cùng cũng lên đến đỉnh.',
          'We had been climbing for ten hours when we finally reached the top.',
          G.pastPerfectContinuous,
        ),
        WritingSentence.of(
          'Người porter kể rằng anh đã leo ngọn núi này hơn ba trăm lần.',
          'The porter told us that he had climbed the mountain more than three hundred times.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu chúng tôi đi cáp treo, chúng tôi đã không có được cảm giác tự hào như vậy.',
          'If we had taken the cable car, we would not have felt so proud.',
          G.conditional3,
        ),
        WritingSentence.of(
          'Cảnh bình minh trên đỉnh núi đẹp hơn bất kỳ bức ảnh nào tôi từng thấy.',
          'The sunrise from the summit was more beautiful than any photo I had seen.',
          G.comparison,
        ),
        WritingSentence.of(
          'Năm sau, chúng tôi sẽ đang chinh phục một ngọn núi ở Nepal.',
          'Next year, we will be climbing a mountain in Nepal.',
          G.futureContinuous,
        ),
      ],
    ),
    WritingParagraph(
      id: 'sports_a5',
      level: _a,
      titleVi: 'Doping trong thể thao',
      titleEn: 'Doping in sport',
      sentences: [
        WritingSentence.of(
          'Một vận động viên nổi tiếng vừa bị tước huy chương vì sử dụng chất cấm.',
          'A famous athlete has just been stripped of his medal for using banned drugs.',
          G.passive,
        ),
        WritingSentence.of(
          'Anh ta đã sử dụng chất kích thích suốt nhiều năm trước khi bị phát hiện.',
          'He had been taking drugs for years before he was caught.',
          G.pastPerfectContinuous,
        ),
        WritingSentence.of(
          'Người hâm mộ, những người từng coi anh là thần tượng, cảm thấy bị phản bội.',
          'His fans, who had once seen him as a hero, felt betrayed.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Huấn luyện viên của anh khẳng định rằng ông không hề biết chuyện đó.',
          'His coach insisted that he had not known anything about it.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu việc kiểm tra được làm chặt chẽ hơn, anh ta đã bị phát hiện sớm hơn nhiều.',
          'If the tests had been stricter, he would have been caught much earlier.',
          G.conditional3,
        ),
        WritingSentence.of(
          'Các tổ chức thể thao đã và đang áp dụng những phương pháp kiểm tra mới.',
          'Sports organizations have been introducing new testing methods.',
          G.presentPerfectContinuous,
          alternatives: [
            'Sports organisations have been introducing new testing methods.',
          ],
        ),
      ],
    ),
    WritingParagraph(
      id: 'sports_a6',
      level: _a,
      titleVi: 'Thể thao cho phụ nữ',
      titleEn: 'Women in sport',
      sentences: [
        WritingSentence.of(
          'Đội tuyển bóng đá nữ Việt Nam, đội từng dự World Cup, đã truyền cảm hứng cho hàng triệu cô gái.',
          'Vietnam\'s women\'s football team, which has played at a World Cup, has inspired millions of girls.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Trong nhiều năm, cầu thủ nữ được trả lương thấp hơn nhiều so với cầu thủ nam.',
          'For many years, female players were paid much less than male players.',
          G.passive,
        ),
        WritingSentence.of(
          'Một cầu thủ kể rằng cô đã phải làm thêm để tiếp tục chơi bóng.',
          'One player said that she had had to take a second job to keep playing.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu thể thao nữ được quan tâm nhiều hơn, sẽ có nhiều nhà tài trợ hơn.',
          'If women\'s sport received more attention, there would be more sponsors.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Em gái tôi đã chơi cho đội bóng nữ của trường từ đầu năm học.',
          'My sister has been playing for the school girls\' team since the start of the year.',
          G.presentPerfectContinuous,
        ),
        WritingSentence.of(
          'Đến khi em ấy tốt nghiệp, em có lẽ đã được gọi vào đội tuyển trẻ.',
          'By the time she graduates, she may have been called up to the youth team.',
          G.futurePerfect,
        ),
      ],
    ),
    WritingParagraph(
      id: 'sports_a7',
      level: _a,
      titleVi: 'Chấn thương và hồi phục',
      titleEn: 'Injury and recovery',
      sentences: [
        WritingSentence.of(
          'Tháng ba năm ngoái, tôi bị đứt dây chằng đầu gối trong một trận bóng.',
          'Last March, I tore a ligament in my knee during a football match.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Tôi đã chơi thể thao hơn mười năm mà chưa từng bị chấn thương nặng.',
          'I had played sport for over ten years without a serious injury.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Bác sĩ nói rằng tôi sẽ phải nghỉ ít nhất sáu tháng.',
          'The doctor said that I would have to rest for at least six months.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu tôi khởi động kỹ hơn, có lẽ chấn thương đã không xảy ra.',
          'If I had warmed up properly, the injury might not have happened.',
          G.conditional3,
        ),
        WritingSentence.of(
          'Suốt mấy tháng qua, tôi đã tập vật lý trị liệu ba buổi mỗi tuần.',
          'For the past few months, I have been doing physiotherapy three times a week.',
          G.presentPerfectContinuous,
          alternatives: [
            'For the past few months, I have been doing physical therapy three times a week.',
          ],
        ),
        WritingSentence.of(
          'Đến mùa hè, tôi hy vọng sẽ trở lại sân bóng.',
          'By the summer, I hope to be back on the pitch.',
          G.presentSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'sports_a8',
      level: _a,
      titleVi: 'Thể thao và tính cách',
      titleEn: 'What sport teaches us',
      sentences: [
        WritingSentence.of(
          'Nhiều người tin rằng thể thao dạy trẻ em những kỹ năng mà sách vở không thể dạy.',
          'Many people believe that sport teaches children skills that books cannot teach.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Tôi đã học được tinh thần đồng đội từ những năm chơi bóng rổ.',
          'I have learned teamwork from my years of playing basketball.',
          G.presentPerfect,
          alternatives: [
            'I have learnt teamwork from my years of playing basketball.',
          ],
        ),
        WritingSentence.of(
          'Huấn luyện viên đầu tiên của tôi luôn nói rằng thua không có nghĩa là thất bại.',
          'My first coach always told us that losing did not mean failing.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Trước khi vào đội, tôi đã rất nhút nhát và ít nói.',
          'Before I joined the team, I had been very shy and quiet.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Nếu trường học dành nhiều thời gian hơn cho thể thao, học sinh sẽ khoẻ mạnh và tự tin hơn.',
          'If schools spent more time on sport, students would be healthier and more confident.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Sau này, tôi sẽ cho con mình chơi thể thao từ khi còn nhỏ.',
          'In the future, I will let my children play sport from an early age.',
          G.futureSimple,
        ),
      ],
    ),
  ],
);
