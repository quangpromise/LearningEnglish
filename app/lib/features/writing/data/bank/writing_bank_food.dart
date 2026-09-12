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

const kWritingBankFood = WritingTopic(
  id: 'food',
  titleVi: 'Đồ ăn',
  titleEn: 'Food',
  icon: Icons.restaurant_rounded,
  color: AppColors.amber,
  paragraphs: [
    // ---------------- Co ban ----------------
    WritingParagraph(
      id: 'food_b1',
      level: _b,
      titleVi: 'Bữa sáng của tôi',
      titleEn: 'My breakfast',
      sentences: [
        WritingSentence.of(
          'Tôi ăn sáng lúc sáu giờ rưỡi.',
          'I have breakfast at half past six.',
          G.presentSimple,
          alternatives: [
            'I eat breakfast at half past six.',
            'I have breakfast at six thirty.',
          ],
        ),
        WritingSentence.of(
          'Tôi thường ăn phở.',
          'I usually eat pho.',
          G.presentSimple,
          alternatives: ['I often eat pho.'],
        ),
        WritingSentence.of(
          'Phở rất nóng và ngon.',
          'Pho is very hot and delicious.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tôi uống một cốc trà đá.',
          'I drink a glass of iced tea.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Sau đó tôi đi học.',
          'Then I go to school.',
          G.presentSimple,
          alternatives: ['After that, I go to school.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'food_b2',
      level: _b,
      titleVi: 'Món ăn yêu thích',
      titleEn: 'My favorite food',
      sentences: [
        WritingSentence.of(
          'Món ăn yêu thích của tôi là cơm rang.',
          'My favorite food is fried rice.',
          G.presentSimple,
          alternatives: ['My favourite food is fried rice.'],
        ),
        WritingSentence.of(
          'Mẹ tôi làm cơm rang rất ngon.',
          'My mother makes very good fried rice.',
          G.presentSimple,
          alternatives: [
            'My mom makes very good fried rice.',
            'My mother makes delicious fried rice.',
          ],
        ),
        WritingSentence.of(
          'Tôi có thể ăn hai đĩa.',
          'I can eat two plates.',
          G.modal,
        ),
        WritingSentence.of(
          'Em trai tôi không thích hành.',
          'My brother does not like onions.',
          G.presentSimple,
          alternatives: ['My younger brother doesn\'t like onions.'],
        ),
        WritingSentence.of(
          'Nó luôn để hành lại trên đĩa.',
          'He always leaves the onions on his plate.',
          G.presentSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'food_b3',
      level: _b,
      titleVi: 'Ở chợ',
      titleEn: 'At the market',
      sentences: [
        WritingSentence.of(
          'Hôm nay mẹ và tôi đang ở chợ.',
          'Today my mother and I are at the market.',
          G.presentSimple,
          alternatives: ['Today my mom and I are at the market.'],
        ),
        WritingSentence.of(
          'Mẹ tôi đang mua cá.',
          'My mother is buying fish.',
          G.presentContinuous,
          alternatives: ['My mom is buying fish.'],
        ),
        WritingSentence.of(
          'Tôi đang cầm một túi rau.',
          'I am holding a bag of vegetables.',
          G.presentContinuous,
        ),
        WritingSentence.of(
          'Cà chua ở đây rất tươi.',
          'The tomatoes here are very fresh.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tối nay chúng tôi sẽ nấu canh chua.',
          'We will cook sour soup tonight.',
          G.futureSimple,
          alternatives: ['We will make sour soup tonight.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'food_b4',
      level: _b,
      titleVi: 'Nấu ăn cùng bố',
      titleEn: 'Cooking with dad',
      sentences: [
        WritingSentence.of(
          'Tối qua tôi đã nấu ăn cùng bố.',
          'Last night I cooked with my father.',
          G.pastSimple,
          alternatives: [
            'I cooked with my dad last night.',
            'Last night, I cooked with my dad.',
          ],
        ),
        WritingSentence.of(
          'Chúng tôi đã làm trứng rán.',
          'We made fried eggs.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Tôi đã cắt cà chua.',
          'I cut the tomatoes.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Bố tôi đã rán trứng.',
          'My father fried the eggs.',
          G.pastSimple,
          alternatives: ['My dad fried the eggs.'],
        ),
        WritingSentence.of(
          'Món ăn trông không đẹp nhưng rất ngon.',
          'The dish did not look nice, but it tasted great.',
          G.pastSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'food_b5',
      level: _b,
      titleVi: 'Đồ uống',
      titleEn: 'Drinks',
      sentences: [
        WritingSentence.of(
          'Tôi thích uống nước cam.',
          'I like drinking orange juice.',
          G.presentSimple,
          alternatives: ['I like to drink orange juice.'],
        ),
        WritingSentence.of(
          'Bố tôi uống cà phê mỗi sáng.',
          'My father drinks coffee every morning.',
          G.presentSimple,
          alternatives: ['My dad drinks coffee every morning.'],
        ),
        WritingSentence.of(
          'Bạn không nên uống quá nhiều nước ngọt.',
          'You should not drink too much soda.',
          G.modal,
          alternatives: [
            'You shouldn\'t drink too much soda.',
            'You should not drink too many soft drinks.',
          ],
        ),
        WritingSentence.of(
          'Nước lọc tốt cho sức khỏe.',
          'Water is good for your health.',
          G.presentSimple,
          alternatives: ['Water is good for health.'],
        ),
        WritingSentence.of(
          'Tôi uống tám cốc nước mỗi ngày.',
          'I drink eight glasses of water every day.',
          G.presentSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'food_b6',
      level: _b,
      titleVi: 'Bữa trưa ở trường',
      titleEn: 'School lunch',
      sentences: [
        WritingSentence.of(
          'Tôi ăn trưa ở trường.',
          'I have lunch at school.',
          G.presentSimple,
          alternatives: ['I eat lunch at school.'],
        ),
        WritingSentence.of(
          'Hôm nay có cơm, gà và rau.',
          'Today there is rice, chicken and vegetables.',
          G.presentSimple,
          alternatives: ['Today we have rice, chicken and vegetables.'],
        ),
        WritingSentence.of(
          'Bạn tôi đang ăn một quả chuối.',
          'My friend is eating a banana.',
          G.presentContinuous,
        ),
        WritingSentence.of(
          'Tôi sẽ ăn kem sau bữa trưa.',
          'I will eat ice cream after lunch.',
          G.futureSimple,
          alternatives: ['I will have ice cream after lunch.'],
        ),
        WritingSentence.of(
          'Chúng tôi phải rửa tay trước khi ăn.',
          'We must wash our hands before eating.',
          G.modal,
          alternatives: [
            'We must wash our hands before we eat.',
            'We have to wash our hands before eating.',
          ],
        ),
      ],
    ),
    WritingParagraph(
      id: 'food_b7',
      level: _b,
      titleVi: 'Chuẩn bị tiệc',
      titleEn: 'Planning a party',
      sentences: [
        WritingSentence.of(
          'Thứ bảy tới, tôi định tổ chức một bữa tiệc.',
          'Next Saturday, I am going to have a party.',
          G.goingTo,
          alternatives: ['I am going to have a party next Saturday.'],
        ),
        WritingSentence.of(
          'Tôi sẽ mời năm người bạn.',
          'I will invite five friends.',
          G.futureSimple,
        ),
        WritingSentence.of(
          'Mẹ tôi định làm bánh pizza.',
          'My mother is going to make pizza.',
          G.goingTo,
          alternatives: ['My mom is going to make pizza.'],
        ),
        WritingSentence.of(
          'Chúng tôi sẽ uống nước chanh.',
          'We will drink lemonade.',
          G.futureSimple,
        ),
        WritingSentence.of(
          'Tôi có thể làm bánh quy.',
          'I can make cookies.',
          G.modal,
          alternatives: ['I can bake cookies.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'food_b8',
      level: _b,
      titleVi: 'Ăn tối ở nhà hàng',
      titleEn: 'Dinner at a restaurant',
      sentences: [
        WritingSentence.of(
          'Tối qua gia đình tôi đã đi ăn nhà hàng.',
          'Last night my family went to a restaurant.',
          G.pastSimple,
          alternatives: [
            'My family went to a restaurant last night.',
            'Last night, my family ate at a restaurant.',
          ],
        ),
        WritingSentence.of(
          'Nhà hàng rất đông người.',
          'The restaurant was very crowded.',
          G.pastSimple,
          alternatives: ['The restaurant was very busy.'],
        ),
        WritingSentence.of(
          'Tôi đã gọi một bát mì bò.',
          'I ordered a bowl of beef noodles.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Chị tôi đã ăn lẩu hải sản.',
          'My sister had seafood hot pot.',
          G.pastSimple,
          alternatives: [
            'My sister ate seafood hot pot.',
            'My sister had a seafood hotpot.',
          ],
        ),
        WritingSentence.of(
          'Chúng tôi đã về nhà lúc chín giờ.',
          'We went home at nine o\'clock.',
          G.pastSimple,
          alternatives: [
            'We got home at nine o\'clock.',
            'We went home at nine.',
          ],
        ),
      ],
    ),

    // ---------------- Trung cap ----------------
    WritingParagraph(
      id: 'food_i1',
      level: _i,
      titleVi: 'Phở Hà Nội',
      titleEn: 'Hanoi pho',
      sentences: [
        WritingSentence.of(
          'Phở là một trong những món ăn nổi tiếng nhất của Việt Nam.',
          'Pho is one of the most famous dishes in Vietnam.',
          G.comparison,
          alternatives: [
            'Pho is one of Vietnam\'s most famous dishes.',
            'Pho is one of the most famous Vietnamese dishes.',
          ],
        ),
        WritingSentence.of(
          'Nước dùng được ninh từ xương bò trong nhiều giờ.',
          'The broth is simmered with beef bones for many hours.',
          G.passive,
          alternatives: ['The broth is cooked with beef bones for many hours.'],
        ),
        WritingSentence.of(
          'Tôi đã ăn phở ở nhiều thành phố khác nhau.',
          'I have eaten pho in many different cities.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Theo tôi, phở Hà Nội ngon hơn phở ở những nơi khác.',
          'In my opinion, Hanoi pho is tastier than pho in other places.',
          G.comparison,
          alternatives: [
            'In my opinion, Hanoi pho is more delicious than pho in other places.',
            'I think Hanoi pho is tastier than pho in other places.',
          ],
        ),
        WritingSentence.of(
          'Sáng qua, khi tôi đang ăn phở thì trời bắt đầu mưa.',
          'Yesterday morning, while I was eating pho, it started to rain.',
          G.pastContinuous,
          alternatives: [
            'Yesterday morning, while I was eating pho, it started raining.',
          ],
        ),
        WritingSentence.of(
          'Nếu bạn đến Hà Nội, bạn nên thử phở.',
          'If you come to Hanoi, you should try pho.',
          G.conditional1,
          alternatives: ['If you visit Hanoi, you should try pho.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'food_i2',
      level: _i,
      titleVi: 'Học làm bánh xèo',
      titleEn: 'Learning to make banh xeo',
      sentences: [
        WritingSentence.of(
          'Tôi đã học được cách nấu mười món ăn Việt Nam.',
          'I have learned to cook ten Vietnamese dishes.',
          G.presentPerfect,
          alternatives: [
            'I have learnt to cook ten Vietnamese dishes.',
            'I have learned how to cook ten Vietnamese dishes.',
          ],
        ),
        WritingSentence.of(
          'Món khó nhất là bánh xèo.',
          'The most difficult dish is banh xeo.',
          G.comparison,
          alternatives: ['The hardest dish is banh xeo.'],
        ),
        WritingSentence.of(
          'Lần đầu tiên, chiếc bánh bị cháy vì chảo quá nóng.',
          'The first time, the pancake burned because the pan was too hot.',
          G.pastSimple,
          alternatives: [
            'The first time, the pancake burnt because the pan was too hot.',
          ],
        ),
        WritingSentence.of(
          'Trong khi tôi đang nấu, cả nhà đứng xem và cười.',
          'While I was cooking, my whole family watched and laughed.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Bây giờ bánh xèo của tôi giòn hơn trước nhiều.',
          'Now my banh xeo is much crispier than before.',
          G.comparison,
          alternatives: ['Now my pancakes are much crispier than before.'],
        ),
        WritingSentence.of(
          'Nếu tôi luyện tập thêm, tôi sẽ nấu cho bạn bè ăn.',
          'If I practice more, I will cook for my friends.',
          G.conditional1,
          alternatives: ['If I practise more, I will cook for my friends.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'food_i3',
      level: _i,
      titleVi: 'Ăn uống lành mạnh',
      titleEn: 'Eating healthily',
      sentences: [
        WritingSentence.of(
          'Gần đây, tôi đã thay đổi thói quen ăn uống.',
          'Recently, I have changed my eating habits.',
          G.presentPerfect,
          alternatives: ['I have changed my eating habits recently.'],
        ),
        WritingSentence.of(
          'Tôi ăn nhiều rau hơn và ít thịt hơn.',
          'I eat more vegetables and less meat.',
          G.comparison,
          alternatives: ['I eat more vegetables and less meat than before.'],
        ),
        WritingSentence.of(
          'Đồ ăn nhanh không tốt cho sức khỏe bằng đồ ăn tự nấu.',
          'Fast food is not as healthy as food cooked at home.',
          G.comparison,
          alternatives: [
            'Fast food is not as healthy as home-cooked food.',
            'Fast food is not as healthy as home cooked food.',
          ],
        ),
        WritingSentence.of(
          'Trái cây được mua ở chợ mỗi sáng.',
          'Fruit is bought at the market every morning.',
          G.passive,
          alternatives: ['The fruit is bought at the market every morning.'],
        ),
        WritingSentence.of(
          'Tôi đã không ăn đồ chiên suốt hai tuần nay.',
          'I haven\'t eaten fried food for two weeks.',
          G.presentPerfect,
          alternatives: ['I have not eaten fried food for two weeks.'],
        ),
        WritingSentence.of(
          'Nếu tôi tiếp tục như vậy, tôi sẽ khỏe hơn.',
          'If I continue like this, I will be healthier.',
          G.conditional1,
          alternatives: [
            'If I keep doing this, I will be healthier.',
            'If I continue like this, I will become healthier.',
          ],
        ),
      ],
    ),
    WritingParagraph(
      id: 'food_i4',
      level: _i,
      titleVi: 'Đồ ăn đường phố',
      titleEn: 'Street food',
      sentences: [
        WritingSentence.of(
          'Đồ ăn đường phố rẻ hơn đồ ăn nhà hàng rất nhiều.',
          'Street food is much cheaper than restaurant food.',
          G.comparison,
        ),
        WritingSentence.of(
          'Tối qua, khi tôi đang đi dạo, tôi đã nhìn thấy một quầy bánh mì.',
          'Last night, while I was walking, I saw a banh mi stall.',
          G.pastContinuous,
          alternatives: [
            'Last night, when I was walking, I saw a banh mi stall.',
          ],
        ),
        WritingSentence.of(
          'Bánh mì được làm bởi một bà cụ rất thân thiện.',
          'The banh mi was made by a very friendly old woman.',
          G.passive,
          alternatives: ['The sandwich was made by a very friendly old woman.'],
        ),
        WritingSentence.of(
          'Đó là chiếc bánh mì ngon nhất tôi từng ăn.',
          'It was the best banh mi I have ever eaten.',
          G.comparison,
          alternatives: [
            'It was the best banh mi that I have ever eaten.',
            'It was the best sandwich I have ever eaten.',
          ],
        ),
        WritingSentence.of(
          'Tôi đã quay lại quầy đó ba lần rồi.',
          'I have been back to that stall three times.',
          G.presentPerfect,
          alternatives: [
            'I have gone back to that stall three times.',
            'I have returned to that stall three times.',
          ],
        ),
        WritingSentence.of(
          'Nếu bạn muốn, tôi sẽ đưa bạn đến đó.',
          'If you want, I will take you there.',
          G.conditional1,
          alternatives: ['If you like, I will take you there.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'food_i5',
      level: _i,
      titleVi: 'Bữa cơm Việt',
      titleEn: 'A Vietnamese family meal',
      sentences: [
        WritingSentence.of(
          'Một bữa cơm Việt thường có cơm, canh, rau và một món mặn.',
          'A Vietnamese meal usually has rice, soup, vegetables and a main dish.',
          G.presentSimple,
          alternatives: [
            'A Vietnamese meal usually includes rice, soup, vegetables and a main dish.',
          ],
        ),
        WritingSentence.of(
          'Tất cả các món được đặt ở giữa mâm.',
          'All the dishes are placed in the middle of the tray.',
          G.passive,
          alternatives: [
            'All the dishes are put in the middle of the tray.',
            'All the dishes are placed in the middle of the table.',
          ],
        ),
        WritingSentence.of(
          'Mọi người ăn chung các món thay vì ăn riêng.',
          'Everyone shares the dishes instead of eating separately.',
          G.presentSimple,
          alternatives: [
            'People share the dishes instead of eating separately.',
          ],
        ),
        WritingSentence.of(
          'Người lớn tuổi nhất thường được mời ăn trước.',
          'The oldest person is usually invited to eat first.',
          G.passive,
        ),
        WritingSentence.of(
          'Tôi đã ăn theo cách này từ khi còn nhỏ.',
          'I have eaten this way since I was a child.',
          G.presentPerfect,
          alternatives: [
            'I have eaten like this since I was a child.',
            'I have eaten this way since I was little.',
          ],
        ),
        WritingSentence.of(
          'Nếu bạn đến nhà tôi, bạn sẽ được ăn một bữa cơm như vậy.',
          'If you come to my house, you will have a meal like this.',
          G.conditional1,
          alternatives: [
            'If you visit my house, you will have a meal like this.',
          ],
        ),
      ],
    ),
    WritingParagraph(
      id: 'food_i6',
      level: _i,
      titleVi: 'Lần đầu làm bánh',
      titleEn: 'Baking for the first time',
      sentences: [
        WritingSentence.of(
          'Tuần trước tôi đã làm bánh lần đầu tiên.',
          'Last week, I baked a cake for the first time.',
          G.pastSimple,
          alternatives: ['I baked a cake for the first time last week.'],
        ),
        WritingSentence.of(
          'Công thức được tìm thấy trên một trang web nấu ăn.',
          'The recipe was found on a cooking website.',
          G.passive,
        ),
        WritingSentence.of(
          'Trong khi bánh đang nướng, cả căn bếp thơm mùi bơ.',
          'While the cake was baking, the whole kitchen smelled of butter.',
          G.pastContinuous,
          alternatives: [
            'While the cake was baking, the whole kitchen smelled like butter.',
          ],
        ),
        WritingSentence.of(
          'Chiếc bánh nhỏ hơn trong ảnh nhưng vẫn rất ngon.',
          'The cake was smaller than in the photo, but it was still delicious.',
          G.comparison,
          alternatives: [
            'The cake was smaller than the one in the photo, but it was still delicious.',
          ],
        ),
        WritingSentence.of(
          'Tôi chưa bao giờ tự hào về bản thân như vậy.',
          'I have never been so proud of myself.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Nếu có thời gian, tôi sẽ làm bánh cho sinh nhật mẹ.',
          'If I have time, I will bake a cake for my mother\'s birthday.',
          G.conditional1,
          alternatives: [
            'If I have time, I will bake a cake for my mom\'s birthday.',
          ],
        ),
      ],
    ),
    WritingParagraph(
      id: 'food_i7',
      level: _i,
      titleVi: 'Ăn chay',
      titleEn: 'Going vegetarian',
      sentences: [
        WritingSentence.of(
          'Chị tôi đã ăn chay được một năm.',
          'My sister has been a vegetarian for a year.',
          G.presentPerfect,
          alternatives: [
            'My sister has been vegetarian for one year.',
            'My sister has been a vegetarian for one year.',
          ],
        ),
        WritingSentence.of(
          'Chị ấy nói ăn chay tốt cho sức khỏe hơn.',
          'She says a vegetarian diet is healthier.',
          G.comparison,
          alternatives: ['She says that a vegetarian diet is healthier.'],
        ),
        WritingSentence.of(
          'Món chay thường được làm từ đậu phụ và rau.',
          'Vegetarian dishes are often made from tofu and vegetables.',
          G.passive,
          alternatives: [
            'Vegetarian dishes are usually made from tofu and vegetables.',
            'Vegetarian dishes are often made with tofu and vegetables.',
          ],
        ),
        WritingSentence.of(
          'Hôm qua, khi chị ấy đang nấu ăn, tôi đã giúp chị rửa rau.',
          'Yesterday, while she was cooking, I helped her wash the vegetables.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Món đậu sốt cà chua ngon hơn tôi nghĩ.',
          'The tofu in tomato sauce was better than I expected.',
          G.comparison,
          alternatives: [
            'The tofu with tomato sauce was tastier than I thought.',
            'The tofu in tomato sauce was better than I thought.',
          ],
        ),
        WritingSentence.of(
          'Nếu chị ấy dạy tôi, tôi sẽ thử ăn chay một tuần.',
          'If she teaches me, I will try eating vegetarian for a week.',
          G.conditional1,
          alternatives: [
            'If she teaches me, I will try being vegetarian for a week.',
            'If she teaches me, I will try a vegetarian diet for a week.',
          ],
        ),
      ],
    ),
    WritingParagraph(
      id: 'food_i8',
      level: _i,
      titleVi: 'Trái cây miền Tây',
      titleEn: 'Fruits of the Mekong Delta',
      sentences: [
        WritingSentence.of(
          'Tháng trước, tôi đã đi du lịch miền Tây.',
          'Last month, I traveled to the Mekong Delta.',
          G.pastSimple,
          alternatives: [
            'Last month, I travelled to the Mekong Delta.',
            'I traveled to the Mekong Delta last month.',
          ],
        ),
        WritingSentence.of(
          'Tôi chưa bao giờ nhìn thấy nhiều trái cây như vậy.',
          'I have never seen so much fruit.',
          G.presentPerfect,
          alternatives: ['I have never seen so many fruits.'],
        ),
        WritingSentence.of(
          'Sầu riêng có mùi nồng hơn bất kỳ loại quả nào khác.',
          'Durian has a stronger smell than any other fruit.',
          G.comparison,
        ),
        WritingSentence.of(
          'Trái cây ở đó được bán rất rẻ.',
          'The fruit there is sold very cheaply.',
          G.passive,
          alternatives: ['Fruit there is sold very cheaply.'],
        ),
        WritingSentence.of(
          'Trong khi chúng tôi đang đi thuyền, một người bán đưa cho tôi một quả xoài.',
          'While we were riding a boat, a seller gave me a mango.',
          G.pastContinuous,
          alternatives: ['While we were on a boat, a seller gave me a mango.'],
        ),
        WritingSentence.of(
          'Nếu năm sau có dịp, tôi sẽ quay lại đó.',
          'If I have a chance next year, I will go back there.',
          G.conditional1,
          alternatives: [
            'If I have the chance next year, I will go back there.',
            'If I get a chance next year, I will return there.',
          ],
        ),
      ],
    ),

    // ---------------- Nang cao ----------------
    WritingParagraph(
      id: 'food_a1',
      level: _a,
      titleVi: 'Văn hoá ẩm thực Việt',
      titleEn: 'Vietnamese food culture',
      sentences: [
        WritingSentence.of(
          'Ẩm thực Việt Nam, vốn nổi tiếng với sự cân bằng hương vị, đã thu hút du khách khắp thế giới.',
          'Vietnamese cuisine, which is famous for its balance of flavors, has attracted visitors from all over the world.',
          G.relativeClause,
          alternatives: [
            'Vietnamese cuisine, which is famous for its balance of flavours, has attracted visitors from all over the world.',
          ],
        ),
        WritingSentence.of(
          'Mỗi vùng có những đặc sản mà nơi khác khó có thể làm giống được.',
          'Each region has specialties that are difficult to recreate anywhere else.',
          G.relativeClause,
          alternatives: [
            'Each region has specialities that are difficult to recreate anywhere else.',
          ],
        ),
        WritingSentence.of(
          'Nếu bạn chưa từng thử bún chả, bạn đã bỏ lỡ một món ăn tuyệt vời.',
          'If you have never tried bun cha, you have missed a wonderful dish.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Nhiều người nước ngoài đã nói với tôi rằng họ chưa bao giờ ăn thứ gì tươi như vậy.',
          'Many foreigners have told me that they had never eaten anything so fresh.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Những năm gần đây, món Việt đã và đang xuất hiện ngày càng nhiều ở nước ngoài.',
          'In recent years, Vietnamese dishes have been appearing more and more abroad.',
          G.presentPerfectContinuous,
        ),
        WritingSentence.of(
          'Nếu nhiều đầu bếp được đào tạo bài bản hơn, ẩm thực Việt sẽ còn nổi tiếng hơn nữa.',
          'If more chefs were properly trained, Vietnamese cuisine would become even more famous.',
          G.conditional2,
        ),
      ],
    ),
    WritingParagraph(
      id: 'food_a2',
      level: _a,
      titleVi: 'Lãng phí thực phẩm',
      titleEn: 'Food waste',
      sentences: [
        WritingSentence.of(
          'Mỗi năm, một lượng lớn thực phẩm bị bỏ đi trong khi nhiều người vẫn đang đói.',
          'Every year, a huge amount of food is thrown away while many people are still hungry.',
          G.passive,
        ),
        WritingSentence.of(
          'Nhà hàng nơi tôi làm thêm vứt bỏ hàng chục suất ăn mỗi tối.',
          'The restaurant where I work part time throws away dozens of meals every night.',
          G.relativeClause,
          alternatives: [
            'The restaurant where I work part-time throws away dozens of meals every night.',
          ],
        ),
        WritingSentence.of(
          'Trước khi làm ở đó, tôi chưa từng nhận ra vấn đề này nghiêm trọng đến mức nào.',
          'Before I worked there, I had never realized how serious this problem was.',
          G.pastPerfect,
          alternatives: [
            'Before I worked there, I had never realised how serious this problem was.',
          ],
        ),
        WritingSentence.of(
          'Quản lý của tôi nói rằng họ đang tìm cách tặng đồ ăn thừa cho người vô gia cư.',
          'My manager said that they were looking for ways to give leftover food to homeless people.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu mọi gia đình chỉ mua những gì họ cần, lượng rác thải thực phẩm sẽ giảm đáng kể.',
          'If every family bought only what they needed, food waste would fall significantly.',
          G.conditional2,
          alternatives: [
            'If every family bought only what they needed, food waste would decrease significantly.',
          ],
        ),
        WritingSentence.of(
          'Đến cuối năm nay, nhà hàng sẽ tặng được hơn một nghìn suất ăn.',
          'By the end of this year, the restaurant will have donated more than a thousand meals.',
          G.futurePerfect,
        ),
      ],
    ),
    WritingParagraph(
      id: 'food_a3',
      level: _a,
      titleVi: 'Bánh chưng của bà',
      titleEn: 'Grandma\'s banh chung',
      sentences: [
        WritingSentence.of(
          'Mỗi dịp Tết, bà tôi dành trọn một ngày để gói bánh chưng cho cả gia đình.',
          'Every Tet, my grandmother spends a whole day wrapping banh chung for the whole family.',
          G.presentSimple,
          alternatives: [
            'Every Tet, my grandma spends a whole day wrapping banh chung for the whole family.',
          ],
        ),
        WritingSentence.of(
          'Bà đã gói bánh theo cùng một cách trong hơn năm mươi năm.',
          'She has been wrapping the cakes in the same way for over fifty years.',
          G.presentPerfectContinuous,
          alternatives: [
            'She has been wrapping the cakes in the same way for more than fifty years.',
          ],
        ),
        WritingSentence.of(
          'Năm ngoái, trước khi tôi kịp hỏi, bà đã chuẩn bị xong toàn bộ nguyên liệu.',
          'Last year, before I could ask, she had already prepared all the ingredients.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Bánh được luộc suốt mười tiếng trong một chiếc nồi khổng lồ.',
          'The cakes are boiled for ten hours in a huge pot.',
          G.passive,
        ),
        WritingSentence.of(
          'Trong khi bánh đang luộc, cả nhà ngồi quanh bếp lửa kể chuyện.',
          'While the cakes were boiling, the whole family sat around the fire telling stories.',
          G.pastContinuous,
          alternatives: [
            'While the cakes were boiling, the whole family sat around the fire and told stories.',
          ],
        ),
        WritingSentence.of(
          'Nếu bà không dạy tôi, truyền thống này có lẽ đã biến mất khỏi gia đình tôi.',
          'If my grandmother had not taught me, this tradition might have disappeared from my family.',
          G.conditional3,
          alternatives: [
            'If my grandma hadn\'t taught me, this tradition might have disappeared from my family.',
          ],
        ),
      ],
    ),
    WritingParagraph(
      id: 'food_a4',
      level: _a,
      titleVi: 'Trào lưu ăn kiêng',
      titleEn: 'Diet trends',
      sentences: [
        WritingSentence.of(
          'Ngày càng nhiều người trẻ quan tâm đến những chế độ ăn kiêng mà họ thấy trên mạng.',
          'More and more young people are interested in diets that they see online.',
          G.relativeClause,
          alternatives: [
            'More and more young people are interested in diets they see online.',
          ],
        ),
        WritingSentence.of(
          'Nhiều chế độ trong số đó chưa được các chuyên gia dinh dưỡng kiểm chứng.',
          'Many of these diets have not been tested by nutrition experts.',
          G.passive,
        ),
        WritingSentence.of(
          'Bạn tôi đã nhịn ăn tối suốt ba tháng trước khi nhận ra mình luôn mệt mỏi.',
          'My friend had been skipping dinner for three months before she realized she was always tired.',
          G.pastPerfectContinuous,
          alternatives: [
            'My friend had been skipping dinner for three months before she realised she was always tired.',
          ],
        ),
        WritingSentence.of(
          'Bác sĩ khuyên cô ấy rằng cô nên ăn uống cân bằng thay vì bỏ bữa.',
          'The doctor advised her that she should eat a balanced diet instead of skipping meals.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu cô ấy hỏi ý kiến bác sĩ sớm hơn, cô đã không bị ốm.',
          'If she had asked a doctor earlier, she would not have got sick.',
          G.conditional3,
          alternatives: [
            'If she had asked a doctor earlier, she would not have gotten sick.',
            'If she had asked a doctor earlier, she wouldn\'t have got sick.',
          ],
        ),
        WritingSentence.of(
          'Giờ đây, cô ấy đã ăn uống lành mạnh được vài tháng và cảm thấy tràn đầy năng lượng.',
          'She has been eating healthily for a few months now and feels full of energy.',
          G.presentPerfectContinuous,
        ),
      ],
    ),
    WritingParagraph(
      id: 'food_a5',
      level: _a,
      titleVi: 'Quán cà phê của anh họ',
      titleEn: 'My cousin\'s coffee shop',
      sentences: [
        WritingSentence.of(
          'Anh họ tôi, người đã làm pha chế nhiều năm, vừa mở một quán cà phê nhỏ.',
          'My cousin, who worked as a barista for years, has just opened a small coffee shop.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Anh ấy đã tiết kiệm tiền cho dự án này từ khi còn là sinh viên.',
          'He has been saving money for this project since he was a student.',
          G.presentPerfectContinuous,
        ),
        WritingSentence.of(
          'Trước khi mở quán, anh ấy đã học cách rang cà phê ở Đà Lạt.',
          'Before opening the shop, he had learned how to roast coffee in Da Lat.',
          G.pastPerfect,
          alternatives: [
            'Before opening the shop, he had learnt how to roast coffee in Da Lat.',
            'Before opening the shop, he had learned how to roast coffee in Dalat.',
          ],
        ),
        WritingSentence.of(
          'Mỗi ly cà phê được pha bằng hạt cà phê từ Tây Nguyên.',
          'Every cup is made with coffee beans from the Central Highlands.',
          G.passive,
        ),
        WritingSentence.of(
          'Nếu quán thành công, năm sau anh ấy sẽ mở thêm một chi nhánh.',
          'If the shop is successful, he will open another branch next year.',
          G.conditional1,
        ),
        WritingSentence.of(
          'Vào giờ này tháng sau, anh ấy sẽ đang tổ chức một lớp pha chế miễn phí.',
          'This time next month, he will be running a free coffee class.',
          G.futureContinuous,
        ),
      ],
    ),
    WritingParagraph(
      id: 'food_a6',
      level: _a,
      titleVi: 'Một bữa tối sang trọng',
      titleEn: 'A fancy dinner',
      sentences: [
        WritingSentence.of(
          'Để mừng lễ tốt nghiệp, tôi được mời đến một nhà hàng sang trọng.',
          'To celebrate my graduation, I was invited to a fancy restaurant.',
          G.passive,
          alternatives: [
            'To celebrate my graduation, I was invited to an elegant restaurant.',
            'To celebrate my graduation, I was invited to a luxurious restaurant.',
          ],
        ),
        WritingSentence.of(
          'Trước đó, tôi chưa từng đến một nơi nào như vậy.',
          'I had never been to a place like that before.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Người phục vụ giải thích rằng mỗi món ăn đã được chuẩn bị từ sáng sớm hôm đó.',
          'The waiter explained that each dish had been prepared early that morning.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Món tráng miệng, thứ trông như một tác phẩm nghệ thuật, là phần tôi nhớ nhất.',
          'The dessert, which looked like a work of art, was the part I remember most.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Nếu tôi giàu có, tôi sẽ đến những nơi như thế thường xuyên hơn.',
          'If I were rich, I would go to places like that more often.',
          G.conditional2,
          alternatives: [
            'If I was rich, I would go to places like that more often.',
          ],
        ),
        WritingSentence.of(
          'Tuy nhiên, tôi vẫn nghĩ một bát phở vỉa hè cũng đáng nhớ không kém.',
          'However, I still think that a bowl of street pho is just as memorable.',
          G.comparison,
          alternatives: [
            'However, I still think a bowl of street pho is just as memorable.',
          ],
        ),
      ],
    ),
    WritingParagraph(
      id: 'food_a7',
      level: _a,
      titleVi: 'Rau hữu cơ',
      titleEn: 'Organic vegetables',
      sentences: [
        WritingSentence.of(
          'Gia đình bạn tôi đã chuyển sang trồng rau hữu cơ cách đây ba năm.',
          'My friend\'s family switched to growing organic vegetables three years ago.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Kể từ đó, họ đã và đang bán rau cho các nhà hàng trong thành phố.',
          'Since then, they have been selling vegetables to restaurants in the city.',
          G.presentPerfectContinuous,
        ),
        WritingSentence.of(
          'Rau hữu cơ được trồng mà không dùng bất kỳ loại thuốc trừ sâu hoá học nào.',
          'Organic vegetables are grown without any chemical pesticides.',
          G.passive,
        ),
        WritingSentence.of(
          'Dù giá cao hơn, nhiều khách hàng vẫn sẵn sàng trả thêm để có thực phẩm an toàn.',
          'Although the price is higher, many customers are willing to pay more for safe food.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nếu nhà nước hỗ trợ nhiều hơn, sẽ có nhiều nông dân chuyển sang canh tác hữu cơ hơn.',
          'If the government offered more support, more farmers would switch to organic farming.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Đến năm sau, trang trại của họ sẽ mở rộng gấp đôi diện tích.',
          'By next year, their farm will have doubled in size.',
          G.futurePerfect,
        ),
      ],
    ),
    WritingParagraph(
      id: 'food_a8',
      level: _a,
      titleVi: 'Món ăn và ký ức',
      titleEn: 'Food and memories',
      sentences: [
        WritingSentence.of(
          'Có những món ăn gợi lại ký ức mà ta tưởng mình đã quên.',
          'Some dishes bring back memories that we thought we had forgotten.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Lần đầu ăn canh chua sau khi đi du học về, tôi đã suýt khóc.',
          'The first time I ate sour soup after studying abroad, I almost cried.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Tôi đã sống ở nước ngoài bốn năm và suốt thời gian đó không được ăn món này.',
          'I had lived abroad for four years and had not eaten that dish the whole time.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Mẹ tôi nói rằng bà nấu món đó vì biết tôi nhớ nhà.',
          'My mother said that she had cooked it because she knew I was homesick.',
          G.reportedSpeech,
          alternatives: [
            'My mom said that she had cooked it because she knew I was homesick.',
          ],
        ),
        WritingSentence.of(
          'Nếu tôi không đi xa, có lẽ tôi đã không nhận ra những bữa cơm gia đình quý giá đến thế nào.',
          'If I had not gone away, I might not have realized how precious family meals were.',
          G.conditional3,
          alternatives: [
            'If I had not gone away, I might not have realised how precious family meals were.',
          ],
        ),
        WritingSentence.of(
          'Giờ đây, mỗi khi tự nấu canh chua, tôi lại nghĩ đến mẹ.',
          'Now, whenever I cook sour soup myself, I think of my mother.',
          G.presentSimple,
          alternatives: [
            'Now, whenever I cook sour soup myself, I think of my mom.',
          ],
        ),
      ],
    ),
  ],
);
