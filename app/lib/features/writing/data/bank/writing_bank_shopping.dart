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

const kWritingBankShopping = WritingTopic(
  id: 'shopping',
  titleVi: 'Mua sắm',
  titleEn: 'Shopping',
  icon: Icons.shopping_bag_rounded,
  color: AppColors.pink,
  paragraphs: [
    // ---------------- Co ban ----------------
    WritingParagraph(
      id: 'shopping_b1',
      level: _b,
      titleVi: 'Ở siêu thị',
      titleEn: 'At the supermarket',
      sentences: [
        WritingSentence.of(
          'Tôi đang ở siêu thị với mẹ.',
          'I am at the supermarket with my mother.',
          G.presentSimple,
          alternatives: ['I am at the supermarket with my mom.'],
        ),
        WritingSentence.of(
          'Chúng tôi cần mua sữa và bánh mì.',
          'We need to buy milk and bread.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Mẹ tôi đang chọn táo.',
          'My mother is choosing apples.',
          G.presentContinuous,
          alternatives: [
            'My mom is choosing apples.',
            'My mother is picking apples.',
          ],
        ),
        WritingSentence.of(
          'Tôi đang đẩy xe hàng.',
          'I am pushing the shopping cart.',
          G.presentContinuous,
          alternatives: ['I am pushing the trolley.', 'I am pushing the cart.'],
        ),
        WritingSentence.of(
          'Chúng tôi sẽ trả tiền ở quầy.',
          'We will pay at the counter.',
          G.futureSimple,
          alternatives: ['We will pay at the checkout.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'shopping_b2',
      level: _b,
      titleVi: 'Mua giày mới',
      titleEn: 'New shoes',
      sentences: [
        WritingSentence.of(
          'Tôi cần một đôi giày mới.',
          'I need a new pair of shoes.',
          G.presentSimple,
          alternatives: ['I need new shoes.'],
        ),
        WritingSentence.of(
          'Đôi giày cũ của tôi quá nhỏ.',
          'My old shoes are too small.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tôi thích đôi giày màu trắng này.',
          'I like these white shoes.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tôi có thể đi thử không?',
          'Can I try them on?',
          G.modal,
        ),
        WritingSentence.of(
          'Chúng rất vừa với tôi.',
          'They fit me very well.',
          G.presentSimple,
          alternatives: ['They fit me perfectly.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'shopping_b3',
      level: _b,
      titleVi: 'Hỏi giá',
      titleEn: 'Asking the price',
      sentences: [
        WritingSentence.of(
          'Cái áo này giá bao nhiêu?',
          'How much is this shirt?',
          G.presentSimple,
          alternatives: ['How much does this shirt cost?'],
        ),
        WritingSentence.of(
          'Nó giá hai trăm nghìn đồng.',
          'It costs two hundred thousand dong.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Cái đó hơi đắt.',
          'That is a bit expensive.',
          G.presentSimple,
          alternatives: ['It is a little expensive.'],
        ),
        WritingSentence.of(
          'Bạn có thể giảm giá cho tôi không?',
          'Can you give me a discount?',
          G.modal,
          alternatives: ['Can you lower the price?'],
        ),
        WritingSentence.of(
          'Được, tôi sẽ lấy nó.',
          'OK, I will take it.',
          G.futureSimple,
          alternatives: ['Okay, I will take it.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'shopping_b4',
      level: _b,
      titleVi: 'Mua sắm hôm qua',
      titleEn: 'Shopping yesterday',
      sentences: [
        WritingSentence.of(
          'Hôm qua tôi đã đi mua sắm với bạn.',
          'Yesterday I went shopping with my friend.',
          G.pastSimple,
          alternatives: ['I went shopping with my friend yesterday.'],
        ),
        WritingSentence.of(
          'Chúng tôi đã đến một trung tâm thương mại lớn.',
          'We went to a big shopping mall.',
          G.pastSimple,
          alternatives: ['We went to a large shopping mall.'],
        ),
        WritingSentence.of(
          'Tôi đã mua một chiếc váy màu xanh.',
          'I bought a blue dress.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Bạn tôi đã mua hai cuốn sách.',
          'My friend bought two books.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Chúng tôi đã ăn kem ở đó.',
          'We ate ice cream there.',
          G.pastSimple,
          alternatives: ['We had ice cream there.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'shopping_b5',
      level: _b,
      titleVi: 'Đi chợ Tết',
      titleEn: 'Tet shopping',
      sentences: [
        WritingSentence.of(
          'Tuần sau là Tết.',
          'Next week is Tet.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Mẹ tôi định mua hoa đào.',
          'My mother is going to buy peach blossoms.',
          G.goingTo,
          alternatives: ['My mom is going to buy peach blossoms.'],
        ),
        WritingSentence.of(
          'Tôi định mua một chiếc áo mới.',
          'I am going to buy a new shirt.',
          G.goingTo,
        ),
        WritingSentence.of(
          'Chợ sẽ rất đông.',
          'The market will be very crowded.',
          G.futureSimple,
          alternatives: ['The market will be very busy.'],
        ),
        WritingSentence.of(
          'Chúng ta nên đi sớm.',
          'We should go early.',
          G.modal,
        ),
      ],
    ),
    WritingParagraph(
      id: 'shopping_b6',
      level: _b,
      titleVi: 'Mua sắm trên mạng',
      titleEn: 'Online shopping',
      sentences: [
        WritingSentence.of(
          'Chị tôi thích mua sắm trên mạng.',
          'My sister likes shopping online.',
          G.presentSimple,
          alternatives: ['My sister likes to shop online.'],
        ),
        WritingSentence.of(
          'Chị ấy đang xem điện thoại.',
          'She is looking at her phone.',
          G.presentContinuous,
        ),
        WritingSentence.of(
          'Chị ấy đang chọn một chiếc túi.',
          'She is choosing a bag.',
          G.presentContinuous,
          alternatives: ['She is picking a bag.'],
        ),
        WritingSentence.of(
          'Chiếc túi sẽ đến vào ngày mai.',
          'The bag will arrive tomorrow.',
          G.futureSimple,
        ),
        WritingSentence.of(
          'Chị ấy có thể trả tiền khi nhận hàng.',
          'She can pay when it arrives.',
          G.modal,
          alternatives: ['She can pay on delivery.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'shopping_b7',
      level: _b,
      titleVi: 'Hiệu sách',
      titleEn: 'The bookshop',
      sentences: [
        WritingSentence.of(
          'Tôi thích đến hiệu sách vào cuối tuần.',
          'I like going to the bookshop at weekends.',
          G.presentSimple,
          alternatives: [
            'I like going to the bookstore on weekends.',
            'I like going to the bookshop on weekends.',
          ],
        ),
        WritingSentence.of(
          'Hiệu sách gần nhà tôi rất yên tĩnh.',
          'The bookshop near my house is very quiet.',
          G.presentSimple,
          alternatives: ['The bookstore near my house is very quiet.'],
        ),
        WritingSentence.of(
          'Tuần trước, tôi đã mua một cuốn truyện tranh.',
          'Last week, I bought a comic book.',
          G.pastSimple,
          alternatives: ['I bought a comic book last week.'],
        ),
        WritingSentence.of(
          'Bây giờ tôi đang đọc nó.',
          'Now I am reading it.',
          G.presentContinuous,
          alternatives: ['I am reading it now.'],
        ),
        WritingSentence.of(
          'Tôi sẽ mua tập hai vào tháng sau.',
          'I will buy the second book next month.',
          G.futureSimple,
          alternatives: ['I will buy the second volume next month.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'shopping_b8',
      level: _b,
      titleVi: 'Quà cho bạn',
      titleEn: 'A gift for a friend',
      sentences: [
        WritingSentence.of(
          'Thứ sáu này là sinh nhật bạn tôi.',
          'This Friday is my friend\'s birthday.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tôi định mua cho cô ấy một món quà.',
          'I am going to buy her a present.',
          G.goingTo,
          alternatives: [
            'I am going to buy her a gift.',
            'I am going to buy a gift for her.',
          ],
        ),
        WritingSentence.of(
          'Cô ấy thích gấu bông.',
          'She likes teddy bears.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tôi sẽ chọn một con gấu màu hồng.',
          'I will choose a pink teddy bear.',
          G.futureSimple,
          alternatives: ['I will choose a pink bear.'],
        ),
        WritingSentence.of(
          'Tôi phải gói quà thật đẹp.',
          'I must wrap it nicely.',
          G.modal,
          alternatives: [
            'I must wrap the gift nicely.',
            'I have to wrap it nicely.',
          ],
        ),
      ],
    ),

    // ---------------- Trung cap ----------------
    WritingParagraph(
      id: 'shopping_i1',
      level: _i,
      titleVi: 'Chợ Bến Thành',
      titleEn: 'Ben Thanh Market',
      sentences: [
        WritingSentence.of(
          'Chợ Bến Thành là một trong những khu chợ lâu đời nhất Sài Gòn.',
          'Ben Thanh Market is one of the oldest markets in Saigon.',
          G.comparison,
          alternatives: [
            'Ben Thanh Market is one of the oldest markets in Ho Chi Minh City.',
          ],
        ),
        WritingSentence.of(
          'Chợ được xây dựng cách đây hơn một trăm năm.',
          'The market was built more than a hundred years ago.',
          G.passive,
          alternatives: ['The market was built over a hundred years ago.'],
        ),
        WritingSentence.of(
          'Tôi đã đến đó nhiều lần.',
          'I have been there many times.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Hàng hoá ở đó đắt hơn ở các chợ nhỏ.',
          'The goods there are more expensive than at small markets.',
          G.comparison,
          alternatives: [
            'Things there are more expensive than at small markets.',
          ],
        ),
        WritingSentence.of(
          'Lần trước, trong khi tôi đang mặc cả, người bán hàng bật cười.',
          'Last time, while I was bargaining, the seller started laughing.',
          G.pastContinuous,
          alternatives: [
            'Last time, while I was bargaining, the seller laughed.',
          ],
        ),
        WritingSentence.of(
          'Nếu bạn đến đó, bạn nên mặc cả.',
          'If you go there, you should bargain.',
          G.conditional1,
          alternatives: ['If you go there, you should haggle.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'shopping_i2',
      level: _i,
      titleVi: 'Săn hàng giảm giá',
      titleEn: 'Hunting for sales',
      sentences: [
        WritingSentence.of(
          'Tuần này, cửa hàng yêu thích của tôi đang bán mọi thứ với giá một nửa.',
          'This week, my favorite shop is selling everything at half price.',
          G.presentContinuous,
          alternatives: [
            'This week, my favourite shop is selling everything at half price.',
          ],
        ),
        WritingSentence.of(
          'Tôi đã chờ đợt giảm giá này suốt hai tháng.',
          'I have waited for this sale for two months.',
          G.presentPerfect,
          alternatives: ['I have been waiting for this sale for two months.'],
        ),
        WritingSentence.of(
          'Sáng nay, cửa hàng đông hơn bình thường rất nhiều.',
          'This morning, the shop was much more crowded than usual.',
          G.comparison,
          alternatives: ['This morning, the shop was much busier than usual.'],
        ),
        WritingSentence.of(
          'Trong khi tôi đang xếp hàng, có người lấy mất chiếc áo tôi thích.',
          'While I was waiting in line, someone took the shirt I liked.',
          G.pastContinuous,
          alternatives: [
            'While I was queuing, someone took the shirt I liked.',
          ],
        ),
        WritingSentence.of(
          'May mắn thay, một chiếc khác được mang ra từ kho.',
          'Luckily, another one was brought out from the storeroom.',
          G.passive,
          alternatives: [
            'Luckily, another one was brought out from the warehouse.',
          ],
        ),
        WritingSentence.of(
          'Nếu còn tiền, tôi sẽ quay lại vào cuối tuần.',
          'If I have money left, I will come back at the weekend.',
          G.conditional1,
          alternatives: [
            'If I still have money, I will come back this weekend.',
            'If I have money left, I will come back on the weekend.',
          ],
        ),
      ],
    ),
    WritingParagraph(
      id: 'shopping_i3',
      level: _i,
      titleVi: 'Trả lại hàng',
      titleEn: 'Returning an item',
      sentences: [
        WritingSentence.of(
          'Tuần trước, tôi đã mua một chiếc áo khoác trên mạng.',
          'Last week, I bought a jacket online.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Khi mở hộp ra, tôi thấy nó to hơn tôi nghĩ.',
          'When I opened the box, I found it was bigger than I thought.',
          G.comparison,
          alternatives: [
            'When I opened the box, it was bigger than I expected.',
          ],
        ),
        WritingSentence.of(
          'Chiếc áo được làm từ loại vải rất mỏng.',
          'The jacket was made of very thin fabric.',
          G.passive,
          alternatives: ['The jacket was made from very thin material.'],
        ),
        WritingSentence.of(
          'Tôi đã gửi trả nó cho cửa hàng.',
          'I have sent it back to the shop.',
          G.presentPerfect,
          alternatives: ['I have returned it to the shop.'],
        ),
        WritingSentence.of(
          'Tôi vẫn chưa nhận được tiền hoàn lại.',
          'I haven\'t received my refund yet.',
          G.presentPerfect,
          alternatives: ['I have not received the refund yet.'],
        ),
        WritingSentence.of(
          'Nếu họ không hoàn tiền, tôi sẽ viết một đánh giá xấu.',
          'If they don\'t refund me, I will write a bad review.',
          G.conditional1,
          alternatives: [
            'If they do not give me a refund, I will write a bad review.',
          ],
        ),
      ],
    ),
    WritingParagraph(
      id: 'shopping_i4',
      level: _i,
      titleVi: 'Siêu thị hay chợ?',
      titleEn: 'Supermarket or market?',
      sentences: [
        WritingSentence.of(
          'Nhiều người trẻ thích siêu thị hơn chợ.',
          'Many young people prefer supermarkets to markets.',
          G.comparison,
        ),
        WritingSentence.of(
          'Siêu thị sạch hơn và tiện lợi hơn.',
          'Supermarkets are cleaner and more convenient.',
          G.comparison,
        ),
        WritingSentence.of(
          'Tuy nhiên, rau ở chợ thường tươi hơn.',
          'However, vegetables at the market are usually fresher.',
          G.comparison,
        ),
        WritingSentence.of(
          'Rau ở chợ được mang từ nông trại đến mỗi sáng.',
          'Market vegetables are brought from the farms every morning.',
          G.passive,
          alternatives: [
            'The vegetables at the market are brought from farms every morning.',
          ],
        ),
        WritingSentence.of(
          'Bà tôi đã đi chợ này suốt ba mươi năm.',
          'My grandmother has gone to this market for thirty years.',
          G.presentPerfect,
          alternatives: [
            'My grandmother has shopped at this market for thirty years.',
            'My grandma has gone to this market for thirty years.',
          ],
        ),
        WritingSentence.of(
          'Nếu bạn muốn đồ tươi, bạn nên đi chợ sớm.',
          'If you want fresh food, you should go to the market early.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'shopping_i5',
      level: _i,
      titleVi: 'Chiếc điện thoại mới',
      titleEn: 'A new phone',
      sentences: [
        WritingSentence.of(
          'Tôi đã dùng chiếc điện thoại cũ được bốn năm.',
          'I have used my old phone for four years.',
          G.presentPerfect,
          alternatives: ['I have had my old phone for four years.'],
        ),
        WritingSentence.of(
          'Pin của nó yếu hơn trước nhiều.',
          'Its battery is much weaker than before.',
          G.comparison,
        ),
        WritingSentence.of(
          'Hôm qua, trong khi tôi đang gọi điện, nó đột nhiên tắt.',
          'Yesterday, while I was making a call, it suddenly turned off.',
          G.pastContinuous,
          alternatives: [
            'Yesterday, while I was making a call, it suddenly switched off.',
          ],
        ),
        WritingSentence.of(
          'Vì vậy, tôi quyết định mua một chiếc mới.',
          'So I decided to buy a new one.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Chiếc điện thoại mới được giao đến nhà trong hai giờ.',
          'The new phone was delivered to my house in two hours.',
          G.passive,
          alternatives: [
            'The new phone was delivered to my house within two hours.',
          ],
        ),
        WritingSentence.of(
          'Nếu tôi giữ gìn cẩn thận, nó sẽ dùng được lâu hơn.',
          'If I take good care of it, it will last longer.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'shopping_i6',
      level: _i,
      titleVi: 'Quà Tết cho ông bà',
      titleEn: 'Tet gifts for my grandparents',
      sentences: [
        WritingSentence.of(
          'Năm nào tôi cũng mua quà Tết cho ông bà.',
          'I buy Tet gifts for my grandparents every year.',
          G.presentSimple,
          alternatives: ['Every year, I buy Tet gifts for my grandparents.'],
        ),
        WritingSentence.of(
          'Năm nay tôi đã tiết kiệm được nhiều tiền hơn năm ngoái.',
          'This year I have saved more money than last year.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Tôi đã mua cho ông một chiếc khăn len.',
          'I bought my grandfather a wool scarf.',
          G.pastSimple,
          alternatives: [
            'I bought a wool scarf for my grandfather.',
            'I bought my grandpa a wool scarf.',
          ],
        ),
        WritingSentence.of(
          'Chiếc khăn được đan bằng tay ở Sa Pa.',
          'The scarf was knitted by hand in Sa Pa.',
          G.passive,
          alternatives: ['The scarf was knitted by hand in Sapa.'],
        ),
        WritingSentence.of(
          'Bà thích trà, nên tôi chọn loại trà ngon nhất trong cửa hàng.',
          'My grandmother likes tea, so I chose the best tea in the shop.',
          G.comparison,
          alternatives: [
            'My grandma likes tea, so I chose the best tea in the shop.',
          ],
        ),
        WritingSentence.of(
          'Nếu ông bà vui, tôi sẽ rất hạnh phúc.',
          'If my grandparents are happy, I will be very happy.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'shopping_i7',
      level: _i,
      titleVi: 'Đi mua sắm với bạn thân',
      titleEn: 'Shopping with my best friend',
      sentences: [
        WritingSentence.of(
          'Bạn thân tôi và tôi đã quen nhau được mười năm.',
          'My best friend and I have known each other for ten years.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Cô ấy thích mua sắm hơn tôi nhiều.',
          'She likes shopping much more than I do.',
          G.comparison,
          alternatives: ['She likes shopping much more than me.'],
        ),
        WritingSentence.of(
          'Chủ nhật tuần trước, chúng tôi đã đi mua sắm cả ngày.',
          'Last Sunday, we went shopping all day.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Trong khi cô ấy đang thử váy, tôi ngồi đọc sách.',
          'While she was trying on dresses, I sat and read a book.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Cuối cùng, cô ấy mua chiếc váy rẻ nhất.',
          'In the end, she bought the cheapest dress.',
          G.comparison,
          alternatives: ['Finally, she bought the cheapest dress.'],
        ),
        WritingSentence.of(
          'Nếu cô ấy rủ tôi lần nữa, tôi sẽ mang theo sách.',
          'If she invites me again, I will bring a book.',
          G.conditional1,
          alternatives: ['If she asks me again, I will bring a book.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'shopping_i8',
      level: _i,
      titleVi: 'Cửa hàng tiện lợi',
      titleEn: 'The convenience store',
      sentences: [
        WritingSentence.of(
          'Có một cửa hàng tiện lợi ở gần ký túc xá của tôi.',
          'There is a convenience store near my dormitory.',
          G.presentSimple,
          alternatives: ['There is a convenience store near my dorm.'],
        ),
        WritingSentence.of(
          'Cửa hàng mở cửa cả ngày lẫn đêm.',
          'The store is open day and night.',
          G.presentSimple,
          alternatives: ['The shop is open day and night.'],
        ),
        WritingSentence.of(
          'Đồ ở đó đắt hơn ở siêu thị một chút.',
          'Things there are a little more expensive than at the supermarket.',
          G.comparison,
          alternatives: [
            'Things there are a bit more expensive than at the supermarket.',
          ],
        ),
        WritingSentence.of(
          'Tôi đã mua mì ở đó rất nhiều lần.',
          'I have bought noodles there many times.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Tối qua, khi tôi đang thanh toán thì mất điện.',
          'Last night, while I was paying, the power went out.',
          G.pastContinuous,
          alternatives: ['Last night, when I was paying, the power went out.'],
        ),
        WritingSentence.of(
          'Nếu cửa hàng đóng cửa, sinh viên sẽ rất bất tiện.',
          'If the store closes, students will find it very inconvenient.',
          G.conditional1,
          alternatives: [
            'If the shop closes, it will be very inconvenient for students.',
          ],
        ),
      ],
    ),

    // ---------------- Nang cao ----------------
    WritingParagraph(
      id: 'shopping_a1',
      level: _a,
      titleVi: 'Nghiện mua sắm trên mạng',
      titleEn: 'Hooked on online shopping',
      sentences: [
        WritingSentence.of(
          'Từ khi cài ứng dụng mua sắm, tôi đã tiêu nhiều tiền hơn bao giờ hết.',
          'Since I installed the shopping app, I have spent more money than ever.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Những món đồ tôi mua lúc nửa đêm thường là thứ tôi không thực sự cần.',
          'The things that I buy at midnight are usually things I do not really need.',
          G.relativeClause,
          alternatives: [
            'The things I buy at midnight are usually things I don\'t really need.',
          ],
        ),
        WritingSentence.of(
          'Tháng trước, tôi đã mua sắm liên tục nhiều tuần liền trước khi nhận ra tài khoản gần như trống rỗng.',
          'Last month, I had been shopping nonstop for weeks before I realized my account was almost empty.',
          G.pastPerfectContinuous,
          alternatives: [
            'Last month, I had been shopping non-stop for weeks before I realised my account was almost empty.',
          ],
        ),
        WritingSentence.of(
          'Chị tôi khuyên rằng tôi nên xoá ứng dụng khỏi điện thoại.',
          'My sister advised me that I should delete the app from my phone.',
          G.reportedSpeech,
          alternatives: [
            'My sister told me that I should delete the app from my phone.',
          ],
        ),
        WritingSentence.of(
          'Nếu tôi nghe lời chị ấy sớm hơn, tôi đã tiết kiệm được rất nhiều tiền.',
          'If I had listened to her earlier, I would have saved a lot of money.',
          G.conditional3,
        ),
        WritingSentence.of(
          'Đến cuối năm nay, tôi sẽ không mua gì trên mạng được sáu tháng.',
          'By the end of this year, I will have gone six months without shopping online.',
          G.futurePerfect,
        ),
      ],
    ),
    WritingParagraph(
      id: 'shopping_a2',
      level: _a,
      titleVi: 'Tiêu dùng xanh',
      titleEn: 'Green shopping',
      sentences: [
        WritingSentence.of(
          'Túi ni lông, thứ mất hàng trăm năm để phân huỷ, vẫn được dùng rộng rãi ở chợ.',
          'Plastic bags, which take hundreds of years to break down, are still widely used at markets.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Gần đây, nhiều siêu thị đã và đang thay chúng bằng lá chuối.',
          'Recently, many supermarkets have been replacing them with banana leaves.',
          G.presentPerfectContinuous,
        ),
        WritingSentence.of(
          'Mẹ tôi luôn mang theo giỏ riêng mỗi khi đi chợ.',
          'My mother always brings her own basket whenever she goes to the market.',
          G.presentSimple,
          alternatives: [
            'My mom always brings her own basket whenever she goes to the market.',
          ],
        ),
        WritingSentence.of(
          'Mẹ nói rằng mẹ đã làm vậy từ lâu trước khi mọi người bàn về môi trường.',
          'She said that she had done that long before people talked about the environment.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu ai cũng mang túi riêng, lượng rác nhựa sẽ giảm đáng kể.',
          'If everyone brought their own bags, plastic waste would fall significantly.',
          G.conditional2,
          alternatives: [
            'If everyone brought their own bags, plastic waste would decrease significantly.',
          ],
        ),
        WritingSentence.of(
          'Trong vài năm tới, túi ni lông có thể sẽ bị cấm ở nhiều thành phố.',
          'In the next few years, plastic bags may be banned in many cities.',
          G.passive,
        ),
      ],
    ),
    WritingParagraph(
      id: 'shopping_a3',
      level: _a,
      titleVi: 'Hàng giả',
      titleEn: 'Fake goods',
      sentences: [
        WritingSentence.of(
          'Chiếc đồng hồ mà tôi mua trên mạng hoá ra là hàng giả.',
          'The watch that I bought online turned out to be fake.',
          G.relativeClause,
          alternatives: ['The watch I bought online turned out to be fake.'],
        ),
        WritingSentence.of(
          'Người bán đã cam đoan với tôi rằng nó được sản xuất tại Thụy Sĩ.',
          'The seller had assured me that it was made in Switzerland.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Tôi đã đeo nó được hai tuần thì nó ngừng chạy.',
          'I had been wearing it for two weeks when it stopped working.',
          G.pastPerfectContinuous,
        ),
        WritingSentence.of(
          'Nếu tôi đọc kỹ các đánh giá, tôi đã không bị lừa.',
          'If I had read the reviews carefully, I would not have been cheated.',
          G.conditional3,
          alternatives: [
            'If I had read the reviews carefully, I wouldn\'t have been cheated.',
            'If I had read the reviews carefully, I would not have been tricked.',
          ],
        ),
        WritingSentence.of(
          'Hàng giả đang ngày càng khó phân biệt với hàng thật.',
          'Fake goods are becoming increasingly difficult to tell apart from real ones.',
          G.presentContinuous,
        ),
        WritingSentence.of(
          'Người tiêu dùng chỉ nên mua hàng từ những cửa hàng được cấp phép chính thức.',
          'Consumers should only buy products from shops that are officially licensed.',
          G.relativeClause,
        ),
      ],
    ),
    WritingParagraph(
      id: 'shopping_a4',
      level: _a,
      titleVi: 'Chợ nổi Cái Răng',
      titleEn: 'Cai Rang Floating Market',
      sentences: [
        WritingSentence.of(
          'Chợ nổi Cái Răng, nơi người ta mua bán ngay trên thuyền, là điểm đến nổi tiếng ở Cần Thơ.',
          'Cai Rang Floating Market, where people buy and sell on boats, is a famous destination in Can Tho.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Chúng tôi dậy từ bốn giờ sáng vì chợ họp rất sớm.',
          'We got up at four in the morning because the market opens very early.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Khi chúng tôi đến nơi, hàng trăm chiếc thuyền đã tập trung trên sông.',
          'By the time we arrived, hundreds of boats had gathered on the river.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Mỗi thuyền treo loại hàng mà họ bán lên một cây sào cao.',
          'Each boat hangs the goods that it sells on a tall pole.',
          G.relativeClause,
          alternatives: ['Each boat hangs the goods it sells on a tall pole.'],
        ),
        WritingSentence.of(
          'Người lái thuyền kể rằng anh ấy đã làm việc ở chợ này từ khi còn là một cậu bé.',
          'The boatman told us that he had worked at this market since he was a boy.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu bạn đến Cần Thơ mà không ghé chợ nổi, bạn sẽ bỏ lỡ một trải nghiệm độc đáo.',
          'If you visit Can Tho without seeing the floating market, you will miss a unique experience.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'shopping_a5',
      level: _a,
      titleVi: 'Bán hàng online',
      titleEn: 'Selling online',
      sentences: [
        WritingSentence.of(
          'Bạn tôi đã bán quần áo trên mạng được gần hai năm.',
          'My friend has been selling clothes online for almost two years.',
          G.presentPerfectContinuous,
        ),
        WritingSentence.of(
          'Ban đầu, cô ấy chỉ bán cho những người bạn mà cô quen trên mạng xã hội.',
          'At first, she only sold to friends that she knew on social media.',
          G.relativeClause,
          alternatives: [
            'At first, she only sold to friends she knew on social media.',
          ],
        ),
        WritingSentence.of(
          'Giờ đây, hàng trăm đơn hàng được gửi đi mỗi tuần.',
          'Now hundreds of orders are sent out every week.',
          G.passive,
        ),
        WritingSentence.of(
          'Cô ấy kể với tôi rằng việc khó nhất là trả lời tin nhắn của khách cả ngày.',
          'She told me that the hardest part was answering customers\' messages all day.',
          G.reportedSpeech,
          alternatives: [
            'She told me that the hardest part was answering customers messages all day.',
          ],
        ),
        WritingSentence.of(
          'Nếu cô ấy có thêm vốn, cô ấy sẽ mở một cửa hàng thật.',
          'If she had more money, she would open a real shop.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Đến cuối năm nay, cô ấy sẽ bán được hơn mười nghìn sản phẩm.',
          'By the end of this year, she will have sold more than ten thousand items.',
          G.futurePerfect,
        ),
      ],
    ),
    WritingParagraph(
      id: 'shopping_a6',
      level: _a,
      titleVi: 'Thói quen mua sắm thay đổi',
      titleEn: 'Changing shopping habits',
      sentences: [
        WritingSentence.of(
          'Trong mười năm qua, cách người Việt mua sắm đã thay đổi đáng kể.',
          'Over the past ten years, the way Vietnamese people shop has changed significantly.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Trước khi có ứng dụng giao hàng, hầu hết mọi người đều đi chợ mỗi ngày.',
          'Before delivery apps appeared, most people went to the market every day.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Giờ đây, ngay cả rau và thịt cũng được đặt mua qua điện thoại.',
          'Now even vegetables and meat are ordered by phone.',
          G.passive,
          alternatives: [
            'Now even vegetables and meat are ordered on the phone.',
          ],
        ),
        WritingSentence.of(
          'Một số người lo rằng chợ truyền thống, vốn là một phần văn hoá, sẽ dần biến mất.',
          'Some people worry that traditional markets, which are part of our culture, will slowly disappear.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Nếu các chợ không thay đổi để thích nghi, chúng có thể mất hết khách hàng trẻ.',
          'If markets do not adapt, they may lose all their young customers.',
          G.conditional1,
          alternatives: [
            'If markets don\'t adapt, they may lose all their young customers.',
          ],
        ),
        WritingSentence.of(
          'Vào giờ này năm sau, có lẽ chúng ta sẽ đang mua sắm bằng giọng nói.',
          'This time next year, we will probably be shopping by voice.',
          G.futureContinuous,
        ),
      ],
    ),
    WritingParagraph(
      id: 'shopping_a7',
      level: _a,
      titleVi: 'Mua nhà',
      titleEn: 'Buying a home',
      sentences: [
        WritingSentence.of(
          'Vợ chồng anh trai tôi đã tìm mua căn hộ suốt gần một năm nay.',
          'My brother and his wife have been looking for an apartment for almost a year.',
          G.presentPerfectContinuous,
        ),
        WritingSentence.of(
          'Căn hộ mà họ thích nhất lại nằm quá xa nơi làm việc.',
          'The apartment that they liked most was too far from their offices.',
          G.relativeClause,
          alternatives: [
            'The apartment they liked most was too far from their offices.',
          ],
        ),
        WritingSentence.of(
          'Trước khi xem căn hộ đó, họ đã xem hơn hai mươi căn khác.',
          'Before seeing that apartment, they had viewed more than twenty others.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Người môi giới nói rằng giá nhà sẽ còn tăng trong năm tới.',
          'The agent said that house prices would keep rising next year.',
          G.reportedSpeech,
          alternatives: [
            'The agent said that house prices would continue to rise next year.',
          ],
        ),
        WritingSentence.of(
          'Nếu họ mua sớm hơn hai năm, họ đã tiết kiệm được rất nhiều tiền.',
          'If they had bought two years earlier, they would have saved a lot of money.',
          G.conditional3,
        ),
        WritingSentence.of(
          'Dù vậy, họ vẫn hy vọng có nhà riêng trước khi đứa con đầu lòng chào đời.',
          'Even so, they still hope to have their own home before their first child is born.',
          G.presentSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'shopping_a8',
      level: _a,
      titleVi: 'Một năm không mua quần áo',
      titleEn: 'A year without new clothes',
      sentences: [
        WritingSentence.of(
          'Năm ngoái, tôi quyết định thử thách bản thân: không mua quần áo mới trong suốt một năm.',
          'Last year, I decided to try a challenge: no new clothes for a whole year.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Trước đó, tôi đã mua quần áo gần như mỗi tuần mà không suy nghĩ.',
          'Before that, I had bought clothes almost every week without thinking.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Nhiều bộ đồ mà tôi từng nghĩ là cần thiết hầu như chưa bao giờ được mặc.',
          'Many clothes that I once thought were necessary had hardly ever been worn.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Bạn bè hỏi tôi liệu tôi có thấy khó khăn không.',
          'My friends asked me whether I found it difficult.',
          G.reportedSpeech,
          alternatives: ['My friends asked me if I found it difficult.'],
        ),
        WritingSentence.of(
          'Thật ra, nếu không thử thách bản thân, tôi đã không biết mình có thể sống đơn giản như vậy.',
          'Actually, if I had not challenged myself, I would never have known I could live so simply.',
          G.conditional3,
        ),
        WritingSentence.of(
          'Từ giờ, tôi sẽ chỉ mua những thứ tôi thật sự cần.',
          'From now on, I will only buy things that I really need.',
          G.futureSimple,
          alternatives: ['From now on, I will only buy things I really need.'],
        ),
      ],
    ),
  ],
);
