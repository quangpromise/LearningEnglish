import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../learning_path/data/learning_path_models.dart';
import '../writing_bank.dart';
import '../writing_grammar.dart';
import '../writing_paragraph_data.dart';

// Noi dung TU SOAN (khong sao chep tu nguon nao) - quy uoc cap do/ngu phap:
// xem writing_grammar.dart va docs/research-level-based-content.md muc 4b.
// Goi y tieng Viet: "dang" -> tiep dien, "se" -> will, "dinh/sap" -> going
// to, "da ... duoc/roi", "chua bao gio", "vua" -> hien tai hoan thanh.

const _b = LearnerLevel.basic;
const _i = LearnerLevel.intermediate;
const _a = LearnerLevel.advanced;

const kWritingBankFamily = WritingTopic(
  id: 'family',
  titleVi: 'Gia đình',
  titleEn: 'Family',
  icon: Icons.family_restroom_rounded,
  color: AppColors.blue,
  paragraphs: [
    // ---------------- Co ban ----------------
    WritingParagraph(
      id: 'family_b1',
      level: _b,
      titleVi: 'Gia đình tôi',
      titleEn: 'My family',
      sentences: [
        WritingSentence.of(
          'Gia đình tôi có bốn người.',
          'There are four people in my family.',
          G.presentSimple,
          alternatives: ['My family has four people.'],
        ),
        WritingSentence.of(
          'Bố tôi là bác sĩ.',
          'My father is a doctor.',
          G.presentSimple,
          alternatives: ['My dad is a doctor.'],
        ),
        WritingSentence.of(
          'Mẹ tôi là giáo viên.',
          'My mother is a teacher.',
          G.presentSimple,
          alternatives: ['My mom is a teacher.'],
        ),
        WritingSentence.of(
          'Tôi có một em trai.',
          'I have a younger brother.',
          G.presentSimple,
          alternatives: ['I have a little brother.'],
        ),
        WritingSentence.of(
          'Chúng tôi sống ở Hà Nội.',
          'We live in Hanoi.',
          G.presentSimple,
          alternatives: ['We live in Ha Noi.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'family_b2',
      level: _b,
      titleVi: 'Buổi sáng ở nhà',
      titleEn: 'Morning at home',
      sentences: [
        WritingSentence.of(
          'Bây giờ là bảy giờ sáng.',
          'It is seven o\'clock in the morning now.',
          G.presentSimple,
          alternatives: ['It is seven in the morning now.'],
        ),
        WritingSentence.of(
          'Mẹ tôi đang nấu bữa sáng.',
          'My mother is cooking breakfast.',
          G.presentContinuous,
          alternatives: ['My mom is cooking breakfast.'],
        ),
        WritingSentence.of(
          'Bố tôi đang đọc báo.',
          'My father is reading the newspaper.',
          G.presentContinuous,
          alternatives: ['My dad is reading the newspaper.'],
        ),
        WritingSentence.of(
          'Em gái tôi đang đánh răng.',
          'My sister is brushing her teeth.',
          G.presentContinuous,
          alternatives: ['My younger sister is brushing her teeth.'],
        ),
        WritingSentence.of(
          'Tôi đang uống sữa.',
          'I am drinking milk.',
          G.presentContinuous,
        ),
      ],
    ),
    WritingParagraph(
      id: 'family_b3',
      level: _b,
      titleVi: 'Ông bà tôi',
      titleEn: 'My grandparents',
      sentences: [
        WritingSentence.of(
          'Ông bà tôi sống ở quê.',
          'My grandparents live in the countryside.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Ông tôi thích trồng cây.',
          'My grandfather likes planting trees.',
          G.presentSimple,
          alternatives: [
            'My grandfather likes to plant trees.',
            'My grandpa likes planting trees.',
          ],
        ),
        WritingSentence.of(
          'Bà tôi nấu ăn rất ngon.',
          'My grandmother cooks very well.',
          G.presentSimple,
          alternatives: ['My grandma cooks very well.'],
        ),
        WritingSentence.of(
          'Tháng trước, tôi đã về thăm ông bà.',
          'Last month, I visited my grandparents.',
          G.pastSimple,
          alternatives: ['I visited my grandparents last month.'],
        ),
        WritingSentence.of(
          'Chúng tôi đã ăn tối cùng nhau.',
          'We had dinner together.',
          G.pastSimple,
          alternatives: ['We ate dinner together.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'family_b4',
      level: _b,
      titleVi: 'Cuối tuần',
      titleEn: 'The weekend',
      sentences: [
        WritingSentence.of(
          'Cuối tuần này, chúng tôi định đi biển.',
          'This weekend, we are going to visit the beach.',
          G.goingTo,
          alternatives: [
            'This weekend, we are going to go to the beach.',
            'We are going to go to the beach this weekend.',
          ],
        ),
        WritingSentence.of(
          'Bố tôi định lái xe.',
          'My father is going to drive.',
          G.goingTo,
          alternatives: ['My dad is going to drive.'],
        ),
        WritingSentence.of(
          'Mẹ tôi sẽ mang theo đồ ăn.',
          'My mother will bring some food.',
          G.futureSimple,
          alternatives: [
            'My mom will bring some food.',
            'My mother will bring food.',
          ],
        ),
        WritingSentence.of(
          'Em trai tôi muốn bơi.',
          'My brother wants to swim.',
          G.presentSimple,
          alternatives: ['My younger brother wants to swim.'],
        ),
        WritingSentence.of(
          'Chúng tôi sẽ rất vui.',
          'We will be very happy.',
          G.futureSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'family_b5',
      level: _b,
      titleVi: 'Sinh nhật mẹ',
      titleEn: 'Mom\'s birthday',
      sentences: [
        WritingSentence.of(
          'Hôm qua là sinh nhật mẹ tôi.',
          'Yesterday was my mother\'s birthday.',
          G.pastSimple,
          alternatives: ['Yesterday was my mom\'s birthday.'],
        ),
        WritingSentence.of(
          'Tôi đã mua cho mẹ một bó hoa.',
          'I bought my mother a bunch of flowers.',
          G.pastSimple,
          alternatives: [
            'I bought my mom a bunch of flowers.',
            'I bought a bunch of flowers for my mother.',
          ],
        ),
        WritingSentence.of(
          'Bố tôi đã làm một chiếc bánh.',
          'My father made a cake.',
          G.pastSimple,
          alternatives: ['My dad made a cake.'],
        ),
        WritingSentence.of(
          'Chúng tôi đã hát bài chúc mừng sinh nhật.',
          'We sang Happy Birthday.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Mẹ tôi đã rất vui.',
          'My mother was very happy.',
          G.pastSimple,
          alternatives: ['My mom was very happy.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'family_b6',
      level: _b,
      titleVi: 'Anh trai tôi',
      titleEn: 'My older brother',
      sentences: [
        WritingSentence.of(
          'Anh trai tôi hai mươi tuổi.',
          'My older brother is twenty years old.',
          G.presentSimple,
          alternatives: ['My brother is twenty years old.'],
        ),
        WritingSentence.of(
          'Anh ấy là sinh viên.',
          'He is a student.',
          G.presentSimple,
          alternatives: ['He is a university student.'],
        ),
        WritingSentence.of(
          'Anh ấy có thể nói tiếng Anh rất tốt.',
          'He can speak English very well.',
          G.modal,
        ),
        WritingSentence.of(
          'Anh ấy thường giúp tôi làm bài tập.',
          'He often helps me with my homework.',
          G.presentSimple,
          alternatives: ['He often helps me do my homework.'],
        ),
        WritingSentence.of(
          'Tôi rất yêu anh ấy.',
          'I love him very much.',
          G.presentSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'family_b7',
      level: _b,
      titleVi: 'Việc nhà',
      titleEn: 'Housework',
      sentences: [
        WritingSentence.of(
          'Mọi người trong nhà tôi đều làm việc nhà.',
          'Everyone in my family does housework.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tôi rửa bát sau bữa tối.',
          'I wash the dishes after dinner.',
          G.presentSimple,
          alternatives: ['I do the dishes after dinner.'],
        ),
        WritingSentence.of(
          'Em gái tôi dọn phòng của nó.',
          'My sister cleans her room.',
          G.presentSimple,
          alternatives: ['My younger sister cleans her room.'],
        ),
        WritingSentence.of(
          'Bố tôi thường đi chợ vào Chủ nhật.',
          'My father often goes to the market on Sundays.',
          G.presentSimple,
          alternatives: ['My dad often goes to the market on Sundays.'],
        ),
        WritingSentence.of(
          'Chúng ta nên giúp đỡ bố mẹ.',
          'We should help our parents.',
          G.modal,
        ),
      ],
    ),
    WritingParagraph(
      id: 'family_b8',
      level: _b,
      titleVi: 'Chuẩn bị đón Tết',
      titleEn: 'Getting ready for Tet',
      sentences: [
        WritingSentence.of(
          'Tết đang đến gần.',
          'Tet is coming soon.',
          G.presentContinuous,
        ),
        WritingSentence.of(
          'Gia đình tôi định dọn dẹp nhà cửa.',
          'My family is going to clean the house.',
          G.goingTo,
        ),
        WritingSentence.of(
          'Mẹ tôi sẽ nấu nhiều món ăn ngon.',
          'My mother will cook a lot of delicious food.',
          G.futureSimple,
          alternatives: [
            'My mom will cook a lot of delicious food.',
            'My mother will cook lots of delicious food.',
          ],
        ),
        WritingSentence.of(
          'Tôi định mua quần áo mới.',
          'I am going to buy new clothes.',
          G.goingTo,
        ),
        WritingSentence.of(
          'Chúng tôi sẽ đi thăm họ hàng.',
          'We will visit our relatives.',
          G.futureSimple,
          alternatives: ['We will visit relatives.'],
        ),
      ],
    ),

    // ---------------- Trung cap ----------------
    WritingParagraph(
      id: 'family_i1',
      level: _i,
      titleVi: 'Đại gia đình',
      titleEn: 'My big family',
      sentences: [
        WritingSentence.of(
          'Tôi đến từ một đại gia đình ở Huế.',
          'I come from a big family in Hue.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Ông bà tôi đã sống cùng chúng tôi được mười năm rồi.',
          'My grandparents have lived with us for ten years.',
          G.presentPerfect,
          alternatives: [
            'My grandparents have lived with us for ten years now.',
          ],
        ),
        WritingSentence.of(
          'Nhà chúng tôi to hơn nhà hàng xóm.',
          'Our house is bigger than our neighbor\'s house.',
          G.comparison,
          alternatives: [
            'Our house is bigger than our neighbour\'s house.',
            'Our house is bigger than our neighbor\'s.',
          ],
        ),
        WritingSentence.of(
          'Bữa tối luôn được mẹ tôi nấu.',
          'Dinner is always cooked by my mother.',
          G.passive,
          alternatives: ['Dinner is always cooked by my mom.'],
        ),
        WritingSentence.of(
          'Em họ tôi là người vui tính nhất trong nhà.',
          'My cousin is the funniest person in the family.',
          G.comparison,
          alternatives: ['My cousin is the funniest person in our family.'],
        ),
        WritingSentence.of(
          'Nếu có thời gian, cả nhà sẽ đi dạo buổi tối.',
          'If we have time, the whole family will go for an evening walk.',
          G.conditional1,
          alternatives: [
            'If we have time, our whole family will go for an evening walk.',
          ],
        ),
      ],
    ),
    WritingParagraph(
      id: 'family_i2',
      level: _i,
      titleVi: 'Một bức ảnh cũ',
      titleEn: 'An old photo',
      sentences: [
        WritingSentence.of(
          'Hôm qua tôi đã tìm thấy một bức ảnh cũ của gia đình.',
          'Yesterday I found an old family photo.',
          G.pastSimple,
          alternatives: [
            'I found an old family photo yesterday.',
            'Yesterday, I found an old photo of my family.',
          ],
        ),
        WritingSentence.of(
          'Bức ảnh được chụp cách đây hai mươi năm.',
          'The photo was taken twenty years ago.',
          G.passive,
        ),
        WritingSentence.of(
          'Trong ảnh, bố mẹ tôi đang đứng trước một ngôi nhà nhỏ.',
          'In the photo, my parents are standing in front of a small house.',
          G.presentContinuous,
        ),
        WritingSentence.of(
          'Lúc đó bố tôi gầy hơn bây giờ nhiều.',
          'At that time, my father was much thinner than he is now.',
          G.comparison,
          alternatives: [
            'At that time, my dad was much thinner than he is now.',
          ],
        ),
        WritingSentence.of(
          'Tôi chưa bao giờ nhìn thấy bức ảnh này trước đây.',
          'I have never seen this photo before.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Tôi sẽ treo nó trong phòng khách.',
          'I will hang it in the living room.',
          G.futureSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'family_i3',
      level: _i,
      titleVi: 'Khi tôi còn nhỏ',
      titleEn: 'When I was little',
      sentences: [
        WritingSentence.of(
          'Khi tôi còn nhỏ, gia đình tôi sống ở một ngôi làng.',
          'When I was little, my family lived in a village.',
          G.pastSimple,
          alternatives: ['When I was young, my family lived in a village.'],
        ),
        WritingSentence.of(
          'Mỗi tối, bà thường kể chuyện cho tôi nghe.',
          'Every evening, my grandmother told me stories.',
          G.pastSimple,
          alternatives: [
            'Every evening, my grandma told me stories.',
            'My grandmother told me stories every evening.',
          ],
        ),
        WritingSentence.of(
          'Một đêm, trong khi bà đang kể chuyện thì mất điện.',
          'One night, while my grandmother was telling a story, the power went out.',
          G.pastContinuous,
          alternatives: [
            'One night, while my grandma was telling a story, the power went out.',
          ],
        ),
        WritingSentence.of(
          'Tôi sợ hơn anh trai tôi rất nhiều.',
          'I was much more scared than my brother.',
          G.comparison,
          alternatives: ['I was much more afraid than my brother.'],
        ),
        WritingSentence.of(
          'Từ đó đến nay, tôi đã chuyển nhà ba lần.',
          'Since then, I have moved house three times.',
          G.presentPerfect,
          alternatives: ['Since then, I have moved three times.'],
        ),
        WritingSentence.of(
          'Nhưng tôi vẫn nhớ ngôi làng đó.',
          'But I still miss that village.',
          G.presentSimple,
          alternatives: ['But I still remember that village.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'family_i4',
      level: _i,
      titleVi: 'Bố tôi',
      titleEn: 'My father',
      sentences: [
        WritingSentence.of(
          'Bố tôi đã làm kỹ sư được hơn mười lăm năm.',
          'My father has worked as an engineer for over fifteen years.',
          G.presentPerfect,
          alternatives: [
            'My father has been an engineer for more than fifteen years.',
            'My dad has worked as an engineer for over fifteen years.',
          ],
        ),
        WritingSentence.of(
          'Ông ấy dậy sớm hơn mọi người trong nhà.',
          'He gets up earlier than everyone else in the house.',
          G.comparison,
          alternatives: [
            'He wakes up earlier than everyone else in the family.',
          ],
        ),
        WritingSentence.of(
          'Sáng nào ông cũng tập thể dục ở công viên.',
          'He exercises in the park every morning.',
          G.presentSimple,
          alternatives: ['Every morning, he exercises in the park.'],
        ),
        WritingSentence.of(
          'Hôm qua, lúc tôi gọi điện, bố đang sửa xe máy.',
          'Yesterday, when I called, my father was fixing his motorbike.',
          G.pastContinuous,
          alternatives: [
            'Yesterday, when I called, my dad was repairing his motorbike.',
            'Yesterday, when I called, my father was fixing the motorbike.',
          ],
        ),
        WritingSentence.of(
          'Chiếc xe của ông được mua cách đây mười năm.',
          'His motorbike was bought ten years ago.',
          G.passive,
        ),
        WritingSentence.of(
          'Nếu tôi cần giúp đỡ, bố sẽ luôn ở bên tôi.',
          'If I need help, my father will always be there for me.',
          G.conditional1,
          alternatives: ['If I need help, my dad will always be there for me.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'family_i5',
      level: _i,
      titleVi: 'Đám cưới của chị họ',
      titleEn: 'My cousin\'s wedding',
      sentences: [
        WritingSentence.of(
          'Tuần trước, chị họ tôi đã kết hôn.',
          'Last week, my cousin got married.',
          G.pastSimple,
          alternatives: ['My cousin got married last week.'],
        ),
        WritingSentence.of(
          'Đám cưới được tổ chức ở một khách sạn lớn.',
          'The wedding was held in a big hotel.',
          G.passive,
          alternatives: ['The wedding was held at a big hotel.'],
        ),
        WritingSentence.of(
          'Đó là đám cưới đẹp nhất mà tôi từng dự.',
          'It was the most beautiful wedding I have ever attended.',
          G.comparison,
          alternatives: [
            'It was the most beautiful wedding that I have ever attended.',
            'It was the most beautiful wedding I have ever been to.',
          ],
        ),
        WritingSentence.of(
          'Trong khi mọi người đang ăn, ban nhạc chơi những bài hát cũ.',
          'While everyone was eating, the band played old songs.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Chị ấy và chồng vừa chuyển đến Đà Nẵng.',
          'She and her husband have just moved to Da Nang.',
          G.presentPerfect,
          alternatives: ['She and her husband have just moved to Danang.'],
        ),
        WritingSentence.of(
          'Nếu có dịp, tôi sẽ đến thăm họ.',
          'If I have a chance, I will visit them.',
          G.conditional1,
          alternatives: [
            'If I have the chance, I will visit them.',
            'If I get a chance, I will visit them.',
          ],
        ),
      ],
    ),
    WritingParagraph(
      id: 'family_i6',
      level: _i,
      titleVi: 'Chuyển nhà',
      titleEn: 'Moving house',
      sentences: [
        WritingSentence.of(
          'Gia đình tôi vừa chuyển đến một căn hộ mới.',
          'My family has just moved to a new apartment.',
          G.presentPerfect,
          alternatives: [
            'My family has just moved into a new apartment.',
            'My family has just moved to a new flat.',
          ],
        ),
        WritingSentence.of(
          'Căn hộ mới rộng hơn và sáng hơn nhà cũ.',
          'The new apartment is bigger and brighter than our old house.',
          G.comparison,
          alternatives: [
            'The new apartment is larger and brighter than our old house.',
          ],
        ),
        WritingSentence.of(
          'Đồ đạc được một công ty vận chuyển mang đến.',
          'Our furniture was brought by a moving company.',
          G.passive,
          alternatives: [
            'The furniture was brought by a moving company.',
            'Our furniture was delivered by a moving company.',
          ],
        ),
        WritingSentence.of(
          'Lúc họ đang chuyển đồ, trời bắt đầu mưa.',
          'While they were moving our things, it started to rain.',
          G.pastContinuous,
          alternatives: [
            'While they were moving our things, it started raining.',
            'When they were moving our things, it started to rain.',
          ],
        ),
        WritingSentence.of(
          'Tôi chưa gặp người hàng xóm mới nào.',
          'I haven\'t met any new neighbors yet.',
          G.presentPerfect,
          alternatives: ['I have not met any new neighbours yet.'],
        ),
        WritingSentence.of(
          'Nếu thời tiết đẹp, chúng tôi sẽ mời họ đến ăn tối.',
          'If the weather is nice, we will invite them for dinner.',
          G.conditional1,
          alternatives: [
            'If the weather is good, we will invite them to dinner.',
            'If the weather is nice, we will invite them over for dinner.',
          ],
        ),
      ],
    ),
    WritingParagraph(
      id: 'family_i7',
      level: _i,
      titleVi: 'Chị gái tôi',
      titleEn: 'My older sister',
      sentences: [
        WritingSentence.of(
          'Chị gái tôi lớn hơn tôi năm tuổi.',
          'My sister is five years older than me.',
          G.comparison,
          alternatives: [
            'My older sister is five years older than me.',
            'My sister is five years older than I am.',
          ],
        ),
        WritingSentence.of(
          'Chị ấy đã học ở Úc được hai năm rồi.',
          'She has studied in Australia for two years.',
          G.presentPerfect,
          alternatives: ['She has studied in Australia for two years now.'],
        ),
        WritingSentence.of(
          'Tuần nào chị ấy cũng gọi điện cho cả nhà.',
          'She calls our family every week.',
          G.presentSimple,
          alternatives: [
            'She calls us every week.',
            'She phones our family every week.',
          ],
        ),
        WritingSentence.of(
          'Tối qua, khi chị ấy gọi, tôi đang ngủ.',
          'Last night, when she called, I was sleeping.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Món quà của chị ấy được gửi qua đường bưu điện.',
          'Her gift was sent by post.',
          G.passive,
          alternatives: [
            'Her present was sent by post.',
            'Her gift was sent by mail.',
          ],
        ),
        WritingSentence.of(
          'Nếu chị ấy về vào mùa hè, chúng tôi sẽ đi du lịch cùng nhau.',
          'If she comes home in the summer, we will travel together.',
          G.conditional1,
          alternatives: [
            'If she comes back in the summer, we will travel together.',
          ],
        ),
      ],
    ),
    WritingParagraph(
      id: 'family_i8',
      level: _i,
      titleVi: 'Bữa cơm cuối tuần',
      titleEn: 'The weekend family meal',
      sentences: [
        WritingSentence.of(
          'Chủ nhật nào cả nhà tôi cũng ăn trưa cùng nhau.',
          'My whole family has lunch together every Sunday.',
          G.presentSimple,
          alternatives: [
            'Every Sunday, my whole family has lunch together.',
            'My whole family eats lunch together every Sunday.',
          ],
        ),
        WritingSentence.of(
          'Tuần này, món chính được bố tôi nấu.',
          'This week, the main dish was cooked by my father.',
          G.passive,
          alternatives: ['This week, the main dish was cooked by my dad.'],
        ),
        WritingSentence.of(
          'Món cá của bố ngon hơn món cá ở nhà hàng.',
          'My father\'s fish is more delicious than the fish at restaurants.',
          G.comparison,
          alternatives: [
            'My father\'s fish is tastier than the fish at restaurants.',
            'My dad\'s fish is more delicious than the fish at restaurants.',
          ],
        ),
        WritingSentence.of(
          'Tôi đã học được cách làm món này.',
          'I have learned how to make this dish.',
          G.presentPerfect,
          alternatives: [
            'I have learnt how to make this dish.',
            'I have learned how to cook this dish.',
          ],
        ),
        WritingSentence.of(
          'Trong khi chúng tôi đang ăn, ông kể chuyện hồi trẻ.',
          'While we were eating, my grandfather told stories about his youth.',
          G.pastContinuous,
          alternatives: [
            'While we were eating, my grandpa told stories about his youth.',
          ],
        ),
        WritingSentence.of(
          'Nếu tuần sau trời đẹp, chúng tôi sẽ ăn ngoài vườn.',
          'If the weather is nice next week, we will eat in the garden.',
          G.conditional1,
          alternatives: [
            'If the weather is good next week, we will eat in the garden.',
          ],
        ),
      ],
    ),

    // ---------------- Nang cao ----------------
    WritingParagraph(
      id: 'family_a1',
      level: _a,
      titleVi: 'Ba thế hệ dưới một mái nhà',
      titleEn: 'Three generations under one roof',
      sentences: [
        WritingSentence.of(
          'Trong nhiều thế hệ, gia đình tôi đã sống theo kiểu ba thế hệ chung một nhà.',
          'For many generations, my family has lived with three generations under one roof.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Ông bà tôi, những người đã nuôi dạy bố tôi, giờ đang giúp chăm sóc các cháu.',
          'My grandparents, who raised my father, are now helping to look after their grandchildren.',
          G.relativeClause,
          alternatives: [
            'My grandparents, who raised my father, are now helping to take care of their grandchildren.',
          ],
        ),
        WritingSentence.of(
          'Mẹ tôi đã đi làm toàn thời gian suốt từ khi tôi còn học tiểu học.',
          'My mother has been working full time since I was in primary school.',
          G.presentPerfectContinuous,
          alternatives: [
            'My mother has been working full-time since I was in primary school.',
          ],
        ),
        WritingSentence.of(
          'Nếu ông bà không giúp đỡ, bố mẹ tôi đã không thể theo đuổi sự nghiệp của mình.',
          'If my grandparents had not helped, my parents could not have pursued their careers.',
          G.conditional3,
          alternatives: [
            'If my grandparents hadn\'t helped, my parents couldn\'t have pursued their careers.',
          ],
        ),
        WritingSentence.of(
          'Tất nhiên, sống cùng nhau đôi khi cũng gây ra bất đồng về cách nuôi dạy con.',
          'Of course, living together sometimes causes disagreements about raising children.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Mẹ tôi từng nói với tôi rằng bà đã học được cách kiên nhẫn hơn.',
          'My mother once told me that she had learned to be more patient.',
          G.reportedSpeech,
          alternatives: [
            'My mother once told me that she had learnt to be more patient.',
          ],
        ),
        WritingSentence.of(
          'Đến khi tôi ra trường, ông bà sẽ sống cùng chúng tôi được hơn hai mươi năm.',
          'By the time I graduate, my grandparents will have lived with us for over twenty years.',
          G.futurePerfect,
          alternatives: [
            'By the time I graduate, my grandparents will have lived with us for more than twenty years.',
          ],
        ),
      ],
    ),
    WritingParagraph(
      id: 'family_a2',
      level: _a,
      titleVi: 'Lá thư của bà',
      titleEn: 'A letter from grandma',
      sentences: [
        WritingSentence.of(
          'Tuần trước, khi dọn gác mái, tôi tìm thấy một lá thư bà đã viết từ năm mươi năm trước.',
          'Last week, while cleaning the attic, I found a letter my grandmother had written fifty years earlier.',
          G.pastPerfect,
          alternatives: [
            'Last week, while cleaning the attic, I found a letter that my grandmother had written fifty years earlier.',
          ],
        ),
        WritingSentence.of(
          'Lá thư được gửi cho ông tôi khi ông đang đi lính ở xa.',
          'The letter was sent to my grandfather while he was serving in the army far away.',
          G.passive,
        ),
        WritingSentence.of(
          'Bà viết rằng bà đã chờ thư của ông suốt nhiều tháng.',
          'She wrote that she had been waiting for his letters for months.',
          G.pastPerfectContinuous,
          alternatives: [
            'She wrote that she had been waiting for his letters for many months.',
          ],
        ),
        WritingSentence.of(
          'Nếu lá thư đó bị thất lạc, có lẽ ông đã không bao giờ biết bà yêu ông nhiều đến thế.',
          'If that letter had been lost, he might never have known how much she loved him.',
          G.conditional3,
        ),
        WritingSentence.of(
          'Tôi đã đọc đi đọc lại lá thư ấy suốt cả buổi chiều nay.',
          'I have been reading that letter over and over all afternoon.',
          G.presentPerfectContinuous,
        ),
        WritingSentence.of(
          'Tôi tự hỏi nếu bây giờ tôi viết thư tay, người nhận sẽ cảm thấy thế nào.',
          'I wonder how people would feel if I wrote them a handwritten letter today.',
          G.conditional2,
          alternatives: [
            'I wonder how people would feel if I wrote them a handwritten letter now.',
          ],
        ),
        WritingSentence.of(
          'Bà tôi, người vẫn còn giữ tất cả thư của ông, đã đồng ý cho tôi scan lại chúng.',
          'My grandmother, who still keeps all his letters, has agreed to let me scan them.',
          G.relativeClause,
        ),
      ],
    ),
    WritingParagraph(
      id: 'family_a3',
      level: _a,
      titleVi: 'Khoảng cách thế hệ',
      titleEn: 'The generation gap',
      sentences: [
        WritingSentence.of(
          'Bố mẹ tôi lớn lên vào thời mà Internet vẫn còn là điều xa lạ.',
          'My parents grew up at a time when the Internet was still unfamiliar.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Vì vậy, họ thường lo lắng khi thấy tôi dành hàng giờ trên điện thoại.',
          'As a result, they often worry when they see me spending hours on my phone.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tháng trước, bố hỏi tôi rằng tôi đã dùng mạng xã hội được bao lâu rồi.',
          'Last month, my father asked me how long I had been using social media.',
          G.reportedSpeech,
          alternatives: [
            'Last month, my dad asked me how long I had been using social media.',
          ],
        ),
        WritingSentence.of(
          'Nếu chúng tôi nói chuyện cởi mở hơn, có lẽ chúng tôi sẽ hiểu nhau hơn.',
          'If we talked more openly, we would probably understand each other better.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Gần đây, cả nhà đã và đang cố gắng ăn tối mà không dùng điện thoại.',
          'Recently, the whole family has been trying to have dinner without phones.',
          G.presentPerfectContinuous,
          alternatives: [
            'Recently, our whole family has been trying to have dinner without phones.',
            'Recently, the whole family has been trying to eat dinner without our phones.',
          ],
        ),
        WritingSentence.of(
          'Đến cuối năm nay, chúng tôi sẽ duy trì thói quen này được sáu tháng.',
          'By the end of this year, we will have kept this habit for six months.',
          G.futurePerfect,
          alternatives: [
            'By the end of this year, we will have kept up this habit for six months.',
          ],
        ),
      ],
    ),
    WritingParagraph(
      id: 'family_a4',
      level: _a,
      titleVi: 'Cách bố mẹ nuôi dạy tôi',
      titleEn: 'How my parents raised me',
      sentences: [
        WritingSentence.of(
          'Bố mẹ tôi luôn tin rằng trẻ em nên được khuyến khích tự đưa ra quyết định.',
          'My parents have always believed that children should be encouraged to make their own decisions.',
          G.passive,
        ),
        WritingSentence.of(
          'Khi mười lăm tuổi, tôi đã tự chọn ngôi trường cấp ba mà tôi muốn học.',
          'When I was fifteen, I chose the high school that I wanted to attend.',
          G.relativeClause,
          alternatives: [
            'When I was fifteen, I chose the high school I wanted to attend.',
          ],
        ),
        WritingSentence.of(
          'Trước khi quyết định, tôi đã tìm hiểu về nhiều trường khác nhau.',
          'Before making the decision, I had researched many different schools.',
          G.pastPerfect,
          alternatives: [
            'Before I made the decision, I had researched many different schools.',
          ],
        ),
        WritingSentence.of(
          'Nếu bố mẹ chọn thay tôi, có lẽ tôi đã không trân trọng lựa chọn đó đến vậy.',
          'If my parents had chosen for me, I might not have valued that choice so much.',
          G.conditional3,
        ),
        WritingSentence.of(
          'Giờ tôi hiểu rằng tự do luôn đi kèm với trách nhiệm.',
          'Now I understand that freedom always comes with responsibility.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Nếu sau này có con, tôi sẽ nuôi dạy chúng theo cách tương tự.',
          'If I have children one day, I will raise them in the same way.',
          G.conditional1,
          alternatives: [
            'If I have children in the future, I will raise them in the same way.',
          ],
        ),
      ],
    ),
    WritingParagraph(
      id: 'family_a5',
      level: _a,
      titleVi: 'Kỷ niệm ngày cưới của bố mẹ',
      titleEn: 'My parents\' anniversary',
      sentences: [
        WritingSentence.of(
          'Tháng sau, bố mẹ tôi sẽ kỷ niệm ba mươi năm ngày cưới.',
          'Next month, my parents will celebrate their thirtieth wedding anniversary.',
          G.futureSimple,
        ),
        WritingSentence.of(
          'Đến lúc đó, họ đã ở bên nhau được hơn nửa cuộc đời.',
          'By then, they will have been together for more than half their lives.',
          G.futurePerfect,
        ),
        WritingSentence.of(
          'Anh chị em chúng tôi đã lên kế hoạch cho một bữa tiệc bất ngờ suốt nhiều tuần nay.',
          'My siblings and I have been planning a surprise party for weeks.',
          G.presentPerfectContinuous,
        ),
        WritingSentence.of(
          'Vào giờ này tuần sau, chúng tôi sẽ đang trang trí nhà hàng.',
          'This time next week, we will be decorating the restaurant.',
          G.futureContinuous,
        ),
        WritingSentence.of(
          'Mẹ kể với chúng tôi rằng bố mẹ đã gặp nhau lần đầu ở một hiệu sách cũ.',
          'My mother told us that they had first met in an old bookshop.',
          G.reportedSpeech,
          alternatives: [
            'My mother told us that they had met for the first time in an old bookshop.',
            'My mother told us that they had first met in an old bookstore.',
          ],
        ),
        WritingSentence.of(
          'Nếu hôm đó bố không đến hiệu sách, có lẽ tôi đã không có mặt trên đời.',
          'If my father had not gone to the bookshop that day, I might not have been born.',
          G.conditional3,
          alternatives: [
            'If my dad hadn\'t gone to the bookshop that day, I might not have been born.',
            'If my father had not gone to the bookstore that day, I might not have been born.',
          ],
        ),
      ],
    ),
    WritingParagraph(
      id: 'family_a6',
      level: _a,
      titleVi: 'Khi bố làm việc tại nhà',
      titleEn: 'When dad works from home',
      sentences: [
        WritingSentence.of(
          'Từ khi bố tôi bắt đầu làm việc tại nhà, không khí gia đình đã thay đổi đáng kể.',
          'Since my father started working from home, the atmosphere in our family has changed significantly.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Trước đây, bố thường về nhà muộn đến mức chúng tôi hiếm khi ăn tối cùng nhau.',
          'In the past, he came home so late that we rarely had dinner together.',
          G.pastSimple,
          alternatives: [
            'In the past, he used to come home so late that we rarely had dinner together.',
          ],
        ),
        WritingSentence.of(
          'Giờ đây, bố là người đón em gái tôi ở trường mỗi chiều.',
          'Now he is the one who picks up my younger sister from school every afternoon.',
          G.relativeClause,
          alternatives: [
            'Now he is the one who picks my younger sister up from school every afternoon.',
          ],
        ),
        WritingSentence.of(
          'Tuy nhiên, bố thừa nhận rằng rất khó để tách công việc khỏi cuộc sống riêng.',
          'However, he admits that it is hard to separate work from his private life.',
          G.presentSimple,
          alternatives: [
            'However, he admits that it is difficult to separate work from his private life.',
          ],
        ),
        WritingSentence.of(
          'Nếu nhà chúng tôi có thêm một phòng, bố sẽ biến nó thành văn phòng.',
          'If our house had one more room, he would turn it into an office.',
          G.conditional2,
          alternatives: [
            'If our house had an extra room, he would turn it into an office.',
          ],
        ),
        WritingSentence.of(
          'Mẹ tôi đã đề nghị cả nhà giữ yên lặng trong giờ làm việc của bố.',
          'My mother has suggested that everyone should stay quiet during my father\'s working hours.',
          G.presentPerfect,
        ),
      ],
    ),
    WritingParagraph(
      id: 'family_a7',
      level: _a,
      titleVi: 'Người ông đáng kính',
      titleEn: 'My remarkable grandfather',
      sentences: [
        WritingSentence.of(
          'Ông tôi, người từng dạy học suốt bốn mươi năm, vẫn đọc sách mỗi ngày.',
          'My grandfather, who was a teacher for forty years, still reads every day.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Ông đã dạy hàng nghìn học sinh trước khi nghỉ hưu ở tuổi sáu mươi.',
          'He had taught thousands of students before he retired at the age of sixty.',
          G.pastPerfect,
          alternatives: [
            'He had taught thousands of students before he retired at sixty.',
          ],
        ),
        WritingSentence.of(
          'Nhiều học trò cũ vẫn đến thăm ông vào ngày Nhà giáo Việt Nam.',
          'Many of his former students still visit him on Vietnamese Teachers\' Day.',
          G.presentSimple,
          alternatives: [
            'Many of his former students still visit him on Vietnamese Teachers Day.',
          ],
        ),
        WritingSentence.of(
          'Gần đây, ông đã học cách dùng máy tính bảng để đọc tin tức.',
          'Recently, he has learned how to use a tablet to read the news.',
          G.presentPerfect,
          alternatives: [
            'Recently, he has learnt how to use a tablet to read the news.',
          ],
        ),
        WritingSentence.of(
          'Ông từng nói với tôi rằng học không bao giờ là quá muộn.',
          'He once told me that it was never too late to learn.',
          G.reportedSpeech,
          alternatives: ['He once told me that it is never too late to learn.'],
        ),
        WritingSentence.of(
          'Nếu tôi kiên nhẫn được như ông, tôi sẽ trở thành một giáo viên giỏi.',
          'If I had his patience, I would become a good teacher.',
          G.conditional2,
          alternatives: [
            'If I were as patient as him, I would become a good teacher.',
          ],
        ),
      ],
    ),
    WritingParagraph(
      id: 'family_a8',
      level: _a,
      titleVi: 'Gia đình hiện đại',
      titleEn: 'The modern family',
      sentences: [
        WritingSentence.of(
          'Cấu trúc gia đình Việt Nam đã thay đổi nhanh chóng trong vài thập kỷ qua.',
          'The structure of Vietnamese families has changed rapidly over the past few decades.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Ngày càng nhiều cặp vợ chồng trẻ chọn sống riêng thay vì sống với bố mẹ.',
          'More and more young couples choose to live on their own instead of with their parents.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Những gia đình mà cả hai vợ chồng đều đi làm đang ngày càng phổ biến.',
          'Families in which both partners work are becoming increasingly common.',
          G.relativeClause,
          alternatives: [
            'Families where both partners work are becoming increasingly common.',
          ],
        ),
        WritingSentence.of(
          'Một số chuyên gia cho rằng trẻ em ngày nay dành ít thời gian với ông bà hơn trước.',
          'Some experts believe that children today spend less time with their grandparents than before.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nếu các gia đình không cố gắng giữ liên lạc, những giá trị truyền thống có thể dần mai một.',
          'If families do not make an effort to stay in touch, traditional values may gradually fade.',
          G.conditional1,
        ),
        WritingSentence.of(
          'Trong hai mươi năm tới, có lẽ gia đình sẽ tiếp tục thay đổi theo những cách ta chưa thể hình dung.',
          'In the next twenty years, families will probably continue to change in ways we cannot yet imagine.',
          G.futureSimple,
        ),
      ],
    ),
  ],
);
