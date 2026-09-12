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

const kWritingBankHealth = WritingTopic(
  id: 'health',
  titleVi: 'Sức khỏe',
  titleEn: 'Health',
  icon: Icons.healing_rounded,
  color: AppColors.teal,
  paragraphs: [
    // ---------------- Co ban ----------------
    WritingParagraph(
      id: 'health_b1',
      level: _b,
      titleVi: 'Tôi bị ốm',
      titleEn: 'I am sick',
      sentences: [
        WritingSentence.of(
          'Hôm nay tôi bị ốm.',
          'I am sick today.',
          G.presentSimple,
          alternatives: ['I am ill today.'],
        ),
        WritingSentence.of(
          'Tôi bị đau đầu.',
          'I have a headache.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tôi cũng bị sốt.',
          'I also have a fever.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Mẹ tôi đang nấu cháo cho tôi.',
          'My mother is cooking rice porridge for me.',
          G.presentContinuous,
          alternatives: [
            'My mom is cooking rice porridge for me.',
            'My mother is making porridge for me.',
          ],
        ),
        WritingSentence.of(
          'Hôm nay tôi phải ở nhà.',
          'I must stay at home today.',
          G.modal,
          alternatives: [
            'I have to stay home today.',
            'I have to stay at home today.',
          ],
        ),
      ],
    ),
    WritingParagraph(
      id: 'health_b2',
      level: _b,
      titleVi: 'Đi khám bác sĩ',
      titleEn: 'Seeing a doctor',
      sentences: [
        WritingSentence.of(
          'Hôm qua tôi đã đi khám bác sĩ.',
          'Yesterday I went to see a doctor.',
          G.pastSimple,
          alternatives: ['I went to the doctor yesterday.'],
        ),
        WritingSentence.of(
          'Bác sĩ đã khám họng cho tôi.',
          'The doctor checked my throat.',
          G.pastSimple,
          alternatives: ['The doctor looked at my throat.'],
        ),
        WritingSentence.of(
          'Tôi đã bị cảm lạnh.',
          'I had a cold.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Bác sĩ đã cho tôi thuốc.',
          'The doctor gave me some medicine.',
          G.pastSimple,
          alternatives: ['The doctor gave me medicine.'],
        ),
        WritingSentence.of(
          'Tôi đã ngủ rất nhiều.',
          'I slept a lot.',
          G.pastSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'health_b3',
      level: _b,
      titleVi: 'Thói quen lành mạnh',
      titleEn: 'Healthy habits',
      sentences: [
        WritingSentence.of(
          'Tôi dậy sớm mỗi ngày.',
          'I get up early every day.',
          G.presentSimple,
          alternatives: ['I wake up early every day.'],
        ),
        WritingSentence.of(
          'Tôi tập thể dục ba mươi phút.',
          'I exercise for thirty minutes.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tôi ăn nhiều rau và trái cây.',
          'I eat a lot of vegetables and fruit.',
          G.presentSimple,
          alternatives: ['I eat lots of vegetables and fruit.'],
        ),
        WritingSentence.of(
          'Tôi không uống nước ngọt.',
          'I do not drink soda.',
          G.presentSimple,
          alternatives: [
            'I don\'t drink soft drinks.',
            'I do not drink soft drinks.',
          ],
        ),
        WritingSentence.of(
          'Tôi đi ngủ lúc mười giờ tối.',
          'I go to bed at ten o\'clock at night.',
          G.presentSimple,
          alternatives: ['I go to bed at ten at night.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'health_b4',
      level: _b,
      titleVi: 'Đau răng',
      titleEn: 'A toothache',
      sentences: [
        WritingSentence.of(
          'Em trai tôi bị đau răng.',
          'My brother has a toothache.',
          G.presentSimple,
          alternatives: ['My younger brother has a toothache.'],
        ),
        WritingSentence.of(
          'Nó đang khóc.',
          'He is crying.',
          G.presentContinuous,
        ),
        WritingSentence.of(
          'Nó đã ăn quá nhiều kẹo.',
          'He ate too many sweets.',
          G.pastSimple,
          alternatives: ['He ate too much candy.'],
        ),
        WritingSentence.of(
          'Ngày mai, mẹ sẽ đưa nó đến nha sĩ.',
          'Tomorrow, Mom will take him to the dentist.',
          G.futureSimple,
          alternatives: [
            'Tomorrow, our mother will take him to the dentist.',
            'Tomorrow, Mum will take him to the dentist.',
          ],
        ),
        WritingSentence.of(
          'Chúng ta nên đánh răng hai lần một ngày.',
          'We should brush our teeth twice a day.',
          G.modal,
        ),
      ],
    ),
    WritingParagraph(
      id: 'health_b5',
      level: _b,
      titleVi: 'Giữ ấm',
      titleEn: 'Keeping warm',
      sentences: [
        WritingSentence.of(
          'Trời đang trở lạnh.',
          'It is getting cold.',
          G.presentContinuous,
          alternatives: ['The weather is getting cold.'],
        ),
        WritingSentence.of(
          'Bạn nên mặc áo ấm.',
          'You should wear warm clothes.',
          G.modal,
        ),
        WritingSentence.of(
          'Bạn không nên tắm nước lạnh.',
          'You should not take cold showers.',
          G.modal,
          alternatives: ['You shouldn\'t take cold showers.'],
        ),
        WritingSentence.of(
          'Tôi uống nước ấm vào buổi sáng.',
          'I drink warm water in the morning.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tôi sẽ không bị ốm.',
          'I will not get sick.',
          G.futureSimple,
          alternatives: ['I won\'t get sick.', 'I will not get ill.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'health_b6',
      level: _b,
      titleVi: 'Bố tôi bỏ thuốc lá',
      titleEn: 'Dad quits smoking',
      sentences: [
        WritingSentence.of(
          'Bố tôi đã hút thuốc nhiều năm.',
          'My father smoked for many years.',
          G.pastSimple,
          alternatives: ['My dad smoked for many years.'],
        ),
        WritingSentence.of(
          'Năm ngoái, bố đã bỏ thuốc lá.',
          'Last year, he stopped smoking.',
          G.pastSimple,
          alternatives: ['Last year, he quit smoking.'],
        ),
        WritingSentence.of(
          'Bây giờ bố cảm thấy rất khoẻ.',
          'Now he feels very healthy.',
          G.presentSimple,
          alternatives: ['He feels very healthy now.'],
        ),
        WritingSentence.of(
          'Bố đi bộ mỗi buổi tối.',
          'He walks every evening.',
          G.presentSimple,
          alternatives: ['He goes for a walk every evening.'],
        ),
        WritingSentence.of(
          'Cả nhà rất vui.',
          'The whole family is very happy.',
          G.presentSimple,
          alternatives: ['Our whole family is very happy.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'health_b7',
      level: _b,
      titleVi: 'Uống đủ nước',
      titleEn: 'Drinking enough water',
      sentences: [
        WritingSentence.of(
          'Cơ thể chúng ta cần nước.',
          'Our bodies need water.',
          G.presentSimple,
          alternatives: ['Our body needs water.'],
        ),
        WritingSentence.of(
          'Tôi luôn mang theo một chai nước.',
          'I always carry a bottle of water.',
          G.presentSimple,
          alternatives: ['I always carry a water bottle.'],
        ),
        WritingSentence.of(
          'Hôm nay tôi đang uống cốc thứ năm.',
          'I am drinking my fifth glass today.',
          G.presentContinuous,
          alternatives: ['Today I am drinking my fifth glass.'],
        ),
        WritingSentence.of(
          'Nước giúp làn da khoẻ mạnh.',
          'Water keeps your skin healthy.',
          G.presentSimple,
          alternatives: ['Water helps keep your skin healthy.'],
        ),
        WritingSentence.of(
          'Bạn nên uống nước trước khi thấy khát.',
          'You should drink water before you feel thirsty.',
          G.modal,
        ),
      ],
    ),
    WritingParagraph(
      id: 'health_b8',
      level: _b,
      titleVi: 'Khám sức khỏe',
      titleEn: 'A health check',
      sentences: [
        WritingSentence.of(
          'Tuần sau, tôi định đi khám sức khỏe.',
          'Next week, I am going to have a health check.',
          G.goingTo,
          alternatives: ['Next week, I am going to have a checkup.'],
        ),
        WritingSentence.of(
          'Tôi sẽ đến bệnh viện lúc tám giờ.',
          'I will arrive at the hospital at eight.',
          G.futureSimple,
          alternatives: ['I will go to the hospital at eight.'],
        ),
        WritingSentence.of(
          'Tôi không được ăn sáng trước khi khám.',
          'I must not eat breakfast before the check.',
          G.modal,
          alternatives: ['I mustn\'t have breakfast before the check.'],
        ),
        WritingSentence.of(
          'Bác sĩ sẽ đo huyết áp của tôi.',
          'The doctor will check my blood pressure.',
          G.futureSimple,
          alternatives: ['The doctor will measure my blood pressure.'],
        ),
        WritingSentence.of(
          'Tôi hy vọng mọi thứ đều ổn.',
          'I hope everything is fine.',
          G.presentSimple,
          alternatives: ['I hope everything is OK.'],
        ),
      ],
    ),

    // ---------------- Trung cap ----------------
    WritingParagraph(
      id: 'health_i1',
      level: _i,
      titleVi: 'Bị gãy tay',
      titleEn: 'A broken arm',
      sentences: [
        WritingSentence.of(
          'Tháng trước, tôi bị ngã khi đang chơi bóng rổ.',
          'Last month, I fell while I was playing basketball.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Tay trái của tôi bị gãy.',
          'My left arm was broken.',
          G.passive,
        ),
        WritingSentence.of(
          'Tôi được đưa đến bệnh viện ngay lập tức.',
          'I was taken to the hospital immediately.',
          G.passive,
          alternatives: ['I was taken to hospital immediately.'],
        ),
        WritingSentence.of(
          'Đó là cơn đau tồi tệ nhất tôi từng trải qua.',
          'It was the worst pain I have ever felt.',
          G.comparison,
        ),
        WritingSentence.of(
          'Tôi đã bó bột được ba tuần rồi.',
          'I have worn a cast for three weeks.',
          G.presentPerfect,
          alternatives: ['I have had a cast for three weeks.'],
        ),
        WritingSentence.of(
          'Nếu tay tôi lành, tôi sẽ chơi lại vào tháng sau.',
          'If my arm heals, I will play again next month.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'health_i2',
      level: _i,
      titleVi: 'Ngủ đủ giấc',
      titleEn: 'Getting enough sleep',
      sentences: [
        WritingSentence.of(
          'Học sinh cấp ba thường ngủ ít hơn mức cần thiết.',
          'High school students often sleep less than they need.',
          G.comparison,
        ),
        WritingSentence.of(
          'Tuần trước, đêm nào tôi cũng học đến hai giờ sáng.',
          'Last week, I studied until two in the morning every night.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Hôm thứ sáu, trong khi tôi đang làm bài kiểm tra, tôi suýt ngủ gật.',
          'On Friday, while I was doing a test, I almost fell asleep.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Tôi đã quyết định thay đổi thói quen này.',
          'I have decided to change this habit.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Giấc ngủ được coi là quan trọng như ăn uống.',
          'Sleep is considered as important as food.',
          G.passive,
        ),
        WritingSentence.of(
          'Nếu tôi ngủ đủ tám tiếng, tôi sẽ học tốt hơn.',
          'If I sleep for eight hours, I will study better.',
          G.conditional1,
          alternatives: ['If I get eight hours of sleep, I will study better.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'health_i3',
      level: _i,
      titleVi: 'Đi tập gym',
      titleEn: 'Going to the gym',
      sentences: [
        WritingSentence.of(
          'Tôi đã tập ở phòng gym được ba tháng.',
          'I have gone to the gym for three months.',
          G.presentPerfect,
          alternatives: ['I have been going to the gym for three months.'],
        ),
        WritingSentence.of(
          'Bây giờ tôi khoẻ hơn và tràn đầy năng lượng hơn.',
          'Now I am stronger and more energetic.',
          G.comparison,
          alternatives: ['I am stronger and more energetic now.'],
        ),
        WritingSentence.of(
          'Huấn luyện viên của tôi là người kiên nhẫn nhất mà tôi biết.',
          'My trainer is the most patient person I know.',
          G.comparison,
        ),
        WritingSentence.of(
          'Mỗi bài tập đều được anh ấy giải thích rất kỹ.',
          'Every exercise is explained very carefully by him.',
          G.passive,
          alternatives: ['Each exercise is explained very carefully by him.'],
        ),
        WritingSentence.of(
          'Hôm qua, khi tôi đang nâng tạ, tôi bị đau lưng.',
          'Yesterday, while I was lifting weights, I hurt my back.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Nếu lưng tôi vẫn đau, tôi sẽ nghỉ tập một tuần.',
          'If my back still hurts, I will take a week off training.',
          G.conditional1,
          alternatives: [
            'If my back still hurts, I will stop training for a week.',
          ],
        ),
      ],
    ),
    WritingParagraph(
      id: 'health_i4',
      level: _i,
      titleVi: 'Bà và bệnh huyết áp',
      titleEn: 'Grandma\'s blood pressure',
      sentences: [
        WritingSentence.of(
          'Bà tôi đã bị cao huyết áp nhiều năm nay.',
          'My grandmother has had high blood pressure for many years.',
          G.presentPerfect,
          alternatives: [
            'My grandma has had high blood pressure for many years.',
          ],
        ),
        WritingSentence.of(
          'Bà được bác sĩ khuyên ăn ít muối hơn.',
          'She was advised by her doctor to eat less salt.',
          G.passive,
        ),
        WritingSentence.of(
          'Bây giờ các bữa ăn của bà nhạt hơn trước.',
          'Now her meals are less salty than before.',
          G.comparison,
        ),
        WritingSentence.of(
          'Sáng qua, trong khi bà đang tưới cây, bà cảm thấy chóng mặt.',
          'Yesterday morning, while she was watering the plants, she felt dizzy.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Chúng tôi vừa mua cho bà một chiếc máy đo huyết áp.',
          'We have just bought her a blood pressure monitor.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Nếu bà uống thuốc đều đặn, bà sẽ khoẻ hơn.',
          'If she takes her medicine regularly, she will be healthier.',
          G.conditional1,
          alternatives: [
            'If she takes her medicine regularly, she will feel better.',
          ],
        ),
      ],
    ),
    WritingParagraph(
      id: 'health_i5',
      level: _i,
      titleVi: 'Căng thẳng mùa thi',
      titleEn: 'Exam stress',
      sentences: [
        WritingSentence.of(
          'Mùa thi là khoảng thời gian căng thẳng nhất trong năm.',
          'Exam season is the most stressful time of the year.',
          G.comparison,
        ),
        WritingSentence.of(
          'Em gái tôi đã không ngủ ngon suốt một tuần nay.',
          'My sister has not slept well for a week.',
          G.presentPerfect,
          alternatives: ['My sister hasn\'t slept well for a week.'],
        ),
        WritingSentence.of(
          'Tối qua, trong khi em ấy đang ôn bài, em ấy bật khóc.',
          'Last night, while she was studying, she started crying.',
          G.pastContinuous,
          alternatives: [
            'Last night, while she was revising, she burst into tears.',
          ],
        ),
        WritingSentence.of(
          'Em ấy được mẹ khuyên nghỉ ngơi nhiều hơn.',
          'She was advised by our mother to rest more.',
          G.passive,
          alternatives: ['She was told by our mother to rest more.'],
        ),
        WritingSentence.of(
          'Đi bộ nhẹ nhàng giúp em ấy thấy thư giãn hơn.',
          'A gentle walk helps her feel more relaxed.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nếu em ấy giữ bình tĩnh, em ấy sẽ làm bài tốt.',
          'If she stays calm, she will do well in the exam.',
          G.conditional1,
          alternatives: ['If she stays calm, she will do well on the test.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'health_i6',
      level: _i,
      titleVi: 'Học sơ cứu',
      titleEn: 'First aid lessons',
      sentences: [
        WritingSentence.of(
          'Tuần trước, lớp tôi đã học một khoá sơ cứu.',
          'Last week, my class took a first aid course.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Chúng tôi được dạy cách băng bó vết thương.',
          'We were taught how to bandage a wound.',
          G.passive,
        ),
        WritingSentence.of(
          'Đó là buổi học hữu ích nhất trong năm.',
          'It was the most useful lesson of the year.',
          G.comparison,
        ),
        WritingSentence.of(
          'Trong khi chúng tôi đang thực hành, một bạn bị ngất thật.',
          'While we were practicing, a classmate really fainted.',
          G.pastContinuous,
          alternatives: [
            'While we were practising, a classmate really fainted.',
          ],
        ),
        WritingSentence.of(
          'Tôi chưa bao giờ thấy ai bình tĩnh như cô giáo lúc đó.',
          'I have never seen anyone as calm as our teacher was then.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Nếu có ai bị thương, tôi sẽ biết phải làm gì.',
          'If someone gets hurt, I will know what to do.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'health_i7',
      level: _i,
      titleVi: 'Đừng bỏ bữa sáng',
      titleEn: 'Don\'t skip breakfast',
      sentences: [
        WritingSentence.of(
          'Trước đây tôi thường bỏ bữa sáng.',
          'I often skipped breakfast before.',
          G.pastSimple,
          alternatives: ['I used to skip breakfast.'],
        ),
        WritingSentence.of(
          'Tôi luôn thấy mệt hơn vào buổi trưa.',
          'I always felt more tired at noon.',
          G.comparison,
          alternatives: ['I always felt more tired by lunchtime.'],
        ),
        WritingSentence.of(
          'Gần đây, tôi đã bắt đầu ăn sáng mỗi ngày.',
          'Recently, I have started eating breakfast every day.',
          G.presentPerfect,
          alternatives: [
            'Recently, I have started having breakfast every day.',
          ],
        ),
        WritingSentence.of(
          'Bữa sáng của tôi được chuẩn bị từ tối hôm trước.',
          'My breakfast is prepared the night before.',
          G.passive,
        ),
        WritingSentence.of(
          'Bây giờ tôi tập trung ở trường tốt hơn.',
          'Now I concentrate better at school.',
          G.comparison,
          alternatives: ['Now I can focus better at school.'],
        ),
        WritingSentence.of(
          'Nếu bạn muốn khoẻ mạnh, bạn không nên bỏ bữa sáng.',
          'If you want to be healthy, you should not skip breakfast.',
          G.conditional1,
          alternatives: [
            'If you want to be healthy, you shouldn\'t skip breakfast.',
          ],
        ),
      ],
    ),
    WritingParagraph(
      id: 'health_i8',
      level: _i,
      titleVi: 'Đeo kính',
      titleEn: 'Getting glasses',
      sentences: [
        WritingSentence.of(
          'Gần đây, tôi không nhìn rõ bảng trong lớp.',
          'Recently, I haven\'t been able to see the board clearly.',
          G.presentPerfect,
          alternatives: [
            'Recently, I have not been able to see the board clearly.',
          ],
        ),
        WritingSentence.of(
          'Mắt tôi được bác sĩ kiểm tra vào thứ hai.',
          'My eyes were checked by a doctor on Monday.',
          G.passive,
        ),
        WritingSentence.of(
          'Mắt trái của tôi kém hơn mắt phải.',
          'My left eye is weaker than my right one.',
          G.comparison,
          alternatives: ['My left eye is weaker than my right eye.'],
        ),
        WritingSentence.of(
          'Trong khi tôi đang chọn gọng kính, em gái tôi cứ cười.',
          'While I was choosing frames, my sister kept laughing.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Tôi đã đeo kính được một tuần.',
          'I have worn glasses for a week.',
          G.presentPerfect,
          alternatives: ['I have had glasses for a week.'],
        ),
        WritingSentence.of(
          'Nếu tôi dùng điện thoại ít hơn, mắt tôi sẽ không kém đi.',
          'If I use my phone less, my eyes will not get worse.',
          G.conditional1,
          alternatives: ['If I use my phone less, my eyes won\'t get worse.'],
        ),
      ],
    ),

    // ---------------- Nang cao ----------------
    WritingParagraph(
      id: 'health_a1',
      level: _a,
      titleVi: 'Sức khỏe tinh thần',
      titleEn: 'Mental health',
      sentences: [
        WritingSentence.of(
          'Sức khỏe tinh thần, vốn từng bị xem nhẹ, giờ đã được nhiều người quan tâm hơn.',
          'Mental health, which used to be ignored, is now taken more seriously by many people.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Bạn tôi đã thấy lo âu suốt nhiều tháng trước khi quyết định đi gặp chuyên gia.',
          'My friend had been feeling anxious for months before she decided to see a therapist.',
          G.pastPerfectContinuous,
        ),
        WritingSentence.of(
          'Chuyên gia tâm lý nói với cô ấy rằng lo âu là điều rất phổ biến.',
          'The therapist told her that anxiety was very common.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu cô ấy tìm kiếm sự giúp đỡ sớm hơn, cô đã không phải chịu đựng lâu như vậy.',
          'If she had looked for help earlier, she would not have suffered for so long.',
          G.conditional3,
        ),
        WritingSentence.of(
          'Gần đây, sáng nào cô ấy cũng thiền mười phút.',
          'Recently, she has been meditating for ten minutes every morning.',
          G.presentPerfectContinuous,
        ),
        WritingSentence.of(
          'Tôi tin rằng việc nói chuyện cởi mở về cảm xúc nên được khuyến khích ở trường học.',
          'I believe that talking openly about feelings should be encouraged in schools.',
          G.passive,
        ),
      ],
    ),
    WritingParagraph(
      id: 'health_a2',
      level: _a,
      titleVi: 'Sau đại dịch',
      titleEn: 'Life after the pandemic',
      sentences: [
        WritingSentence.of(
          'Đại dịch đã thay đổi cách chúng ta nghĩ về sức khỏe và vệ sinh.',
          'The pandemic has changed the way we think about health and hygiene.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Trước đại dịch, rất ít người đeo khẩu trang khi bị cảm.',
          'Before the pandemic, very few people wore masks when they had a cold.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Những thói quen mà chúng ta hình thành trong thời gian đó vẫn còn đến hôm nay.',
          'The habits that we formed during that time are still with us today.',
          G.relativeClause,
          alternatives: [
            'The habits we formed during that time are still with us today.',
          ],
        ),
        WritingSentence.of(
          'Mẹ tôi kể rằng năm đó bà đã rửa tay nhiều hơn bao giờ hết.',
          'My mother said that she had washed her hands more than ever that year.',
          G.reportedSpeech,
          alternatives: [
            'My mom said that she had washed her hands more than ever that year.',
          ],
        ),
        WritingSentence.of(
          'Nếu hệ thống y tế không được chuẩn bị tốt, tình hình đã còn tệ hơn nhiều.',
          'If the health system had not been well prepared, the situation would have been much worse.',
          G.conditional3,
        ),
        WritingSentence.of(
          'Đến khi con tôi lớn lên, đại dịch có lẽ sẽ chỉ còn là một chương trong sách lịch sử.',
          'By the time my children grow up, the pandemic will have become just a chapter in history books.',
          G.futurePerfect,
        ),
      ],
    ),
    WritingParagraph(
      id: 'health_a3',
      level: _a,
      titleVi: 'Mẹ tôi tập yoga',
      titleEn: 'My mother\'s yoga',
      sentences: [
        WritingSentence.of(
          'Mẹ tôi, người từng bị đau lưng kinh niên, bắt đầu tập yoga cách đây hai năm.',
          'My mother, who used to suffer from chronic back pain, started yoga two years ago.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Kể từ đó, mẹ đều đặn tập ba buổi mỗi tuần.',
          'She has been practicing three times a week since then.',
          G.presentPerfectContinuous,
          alternatives: [
            'She has been practising three times a week since then.',
          ],
        ),
        WritingSentence.of(
          'Trước khi tập yoga, mẹ đã thử rất nhiều loại thuốc mà không hiệu quả.',
          'Before she took up yoga, she had tried many medicines without success.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Bác sĩ nói rằng tư thế của mẹ đã cải thiện đáng kể.',
          'Her doctor said that her posture had improved significantly.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu mẹ không kiên trì, có lẽ cơn đau đã quay lại.',
          'If she had not kept going, the pain might have come back.',
          G.conditional3,
        ),
        WritingSentence.of(
          'Tháng sau, mẹ sẽ dạy một lớp yoga miễn phí cho người cao tuổi trong khu phố.',
          'Next month, she will be teaching a free yoga class for older people in our neighborhood.',
          G.futureContinuous,
          alternatives: [
            'Next month, she will be teaching a free yoga class for older people in our neighbourhood.',
          ],
        ),
      ],
    ),
    WritingParagraph(
      id: 'health_a4',
      level: _a,
      titleVi: 'Bác sĩ vùng cao',
      titleEn: 'A doctor in the mountains',
      sentences: [
        WritingSentence.of(
          'Chú tôi là bác sĩ ở một trạm y tế vùng cao, nơi gần như thứ gì cũng thiếu.',
          'My uncle is a doctor at a clinic in the mountains, where almost everything is scarce.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Chú đã làm việc ở đó hơn mười năm, dù có nhiều cơ hội chuyển về thành phố.',
          'He has been working there for over ten years, despite many chances to move to the city.',
          G.presentPerfectContinuous,
        ),
        WritingSentence.of(
          'Khi chú mới đến, người dân chưa từng được tiêm chủng đầy đủ.',
          'When he first arrived, the villagers had never been fully vaccinated.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Chú kể rằng có lần chú đã đi bộ bốn tiếng để giúp một sản phụ sinh con.',
          'He told me that he had once walked four hours to help a woman give birth.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu có thêm nhiều bác sĩ như chú, sức khỏe người dân vùng cao sẽ được cải thiện nhiều.',
          'If there were more doctors like him, health in the mountains would improve greatly.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Năm nay, chú đã được trao giải thưởng dành cho những bác sĩ xuất sắc.',
          'This year, he has been given an award for outstanding doctors.',
          G.passive,
        ),
      ],
    ),
    WritingParagraph(
      id: 'health_a5',
      level: _a,
      titleVi: 'Béo phì ở trẻ em',
      titleEn: 'Childhood obesity',
      sentences: [
        WritingSentence.of(
          'Tỷ lệ béo phì ở trẻ em Việt Nam đã tăng nhanh trong mười năm qua.',
          'The rate of childhood obesity in Vietnam has risen quickly over the past ten years.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Nhiều trẻ em dành hàng giờ trước màn hình thay vì chơi ngoài trời.',
          'Many children spend hours in front of screens instead of playing outside.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Đồ ăn nhanh, thứ vừa rẻ vừa tiện, đang dần thay thế bữa cơm gia đình.',
          'Fast food, which is cheap and convenient, is gradually replacing family meals.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Một bác sĩ nhi khoa cảnh báo rằng nhiều trẻ đã có dấu hiệu tiểu đường.',
          'A pediatrician warned that many children were already showing signs of diabetes.',
          G.reportedSpeech,
          alternatives: [
            'A paediatrician warned that many children were already showing signs of diabetes.',
          ],
        ),
        WritingSentence.of(
          'Nếu trường học có nhiều giờ thể dục hơn, trẻ em sẽ khoẻ mạnh hơn.',
          'If schools had more physical education classes, children would be healthier.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Đến năm sau, chương trình bữa trưa lành mạnh sẽ được áp dụng ở mọi trường tiểu học trong thành phố.',
          'By next year, the healthy lunch program will have been introduced in every primary school in the city.',
          G.futurePerfect,
          alternatives: [
            'By next year, the healthy lunch programme will have been introduced in every primary school in the city.',
          ],
        ),
      ],
    ),
    WritingParagraph(
      id: 'health_a6',
      level: _a,
      titleVi: 'Hiến máu',
      titleEn: 'Donating blood',
      sentences: [
        WritingSentence.of(
          'Tôi hiến máu lần đầu khi vừa tròn mười tám tuổi.',
          'I donated blood for the first time when I had just turned eighteen.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Kể từ đó, tôi đều đặn hiến máu ba tháng một lần.',
          'Since then, I have been donating blood every three months.',
          G.presentPerfectContinuous,
        ),
        WritingSentence.of(
          'Y tá giải thích rằng một đơn vị máu có thể cứu sống tới ba người.',
          'The nurse explained that one unit of blood could save up to three lives.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Những người hiến máu thường xuyên được kiểm tra sức khỏe miễn phí.',
          'People who donate regularly are given free health checks.',
          G.passive,
        ),
        WritingSentence.of(
          'Nếu nhiều người trẻ hiến máu hơn, bệnh viện sẽ không bao giờ thiếu máu.',
          'If more young people donated blood, hospitals would never run short.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Đến cuối năm nay, tôi sẽ hiến máu được hai mươi lần.',
          'By the end of this year, I will have donated blood twenty times.',
          G.futurePerfect,
        ),
      ],
    ),
    WritingParagraph(
      id: 'health_a7',
      level: _a,
      titleVi: 'Hồi phục sau tai nạn',
      titleEn: 'Recovering from an accident',
      sentences: [
        WritingSentence.of(
          'Năm ngoái, anh họ tôi bị thương nặng trong một vụ tai nạn xe máy.',
          'Last year, my cousin was seriously injured in a motorbike accident.',
          G.passive,
        ),
        WritingSentence.of(
          'Anh ấy đã không đội mũ bảo hiểm khi chuyện đó xảy ra.',
          'He had not been wearing a helmet when it happened.',
          G.pastPerfectContinuous,
        ),
        WritingSentence.of(
          'Các bác sĩ nói rằng anh ấy may mắn vì vẫn còn sống.',
          'The doctors said that he was lucky to be alive.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Suốt sáu tháng qua, anh ấy đã tập vật lý trị liệu.',
          'He has been doing physical therapy for the past six months.',
          G.presentPerfectContinuous,
          alternatives: [
            'He has been doing physiotherapy for the past six months.',
          ],
        ),
        WritingSentence.of(
          'Nếu anh ấy đội mũ bảo hiểm, chấn thương đã không nghiêm trọng đến vậy.',
          'If he had worn a helmet, his injuries would not have been so serious.',
          G.conditional3,
        ),
        WritingSentence.of(
          'Giờ đây, anh ấy là người luôn nhắc cả nhà đội mũ bảo hiểm.',
          'Now he is the one who always reminds everyone in the family to wear a helmet.',
          G.relativeClause,
        ),
      ],
    ),
    WritingParagraph(
      id: 'health_a8',
      level: _a,
      titleVi: 'Bí quyết sống thọ',
      titleEn: 'The secret of a long life',
      sentences: [
        WritingSentence.of(
          'Mẹ của ông tôi, người sống đến gần một trăm tuổi, chưa bao giờ phải nằm viện.',
          'My grandfather\'s mother, who lived to almost a hundred, never had to stay in hospital.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Cụ kể rằng cụ đã làm vườn mỗi sáng từ khi còn là một cô gái trẻ.',
          'She said that she had worked in her garden every morning since she was a young girl.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Các nhà khoa học đã nghiên cứu những người sống thọ trong nhiều thập kỷ.',
          'Scientists have been studying people who live long lives for decades.',
          G.presentPerfectContinuous,
        ),
        WritingSentence.of(
          'Họ phát hiện ra rằng các mối quan hệ xã hội quan trọng không kém chế độ ăn uống.',
          'They have found that social relationships are just as important as diet.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nếu tôi sống lành mạnh như cụ, có lẽ tôi cũng sẽ sống lâu như vậy.',
          'If I lived as healthily as she did, I might live that long too.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Đến khi nghỉ hưu, tôi hy vọng mình sẽ tập thể dục mỗi ngày được ba mươi năm.',
          'By the time I retire, I hope I will have exercised every day for thirty years.',
          G.futurePerfect,
        ),
      ],
    ),
  ],
);
