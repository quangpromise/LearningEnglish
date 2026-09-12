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

const kWritingBankFinance = WritingTopic(
  id: 'finance',
  titleVi: 'Tiền bạc',
  titleEn: 'Money & Finance',
  icon: Icons.savings_rounded,
  color: AppColors.amber,
  paragraphs: [
    // ---------------- Co ban ----------------
    WritingParagraph(
      id: 'finance_b1',
      level: _b,
      titleVi: 'Con heo đất',
      titleEn: 'My piggy bank',
      sentences: [
        WritingSentence.of(
          'Tôi có một con heo đất.',
          'I have a piggy bank.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tôi bỏ tiền vào đó mỗi tuần.',
          'I put money in it every week.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Bây giờ nó rất nặng.',
          'Now it is very heavy.',
          G.presentSimple,
          alternatives: ['It is very heavy now.'],
        ),
        WritingSentence.of(
          'Tôi định mua một chiếc xe đạp.',
          'I am going to buy a bike.',
          G.goingTo,
          alternatives: ['I am going to buy a bicycle.'],
        ),
        WritingSentence.of(
          'Tôi sẽ đập heo vào tháng sau.',
          'I will open it next month.',
          G.futureSimple,
          alternatives: ['I will break it next month.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'finance_b2',
      level: _b,
      titleVi: 'Tiền mừng tuổi',
      titleEn: 'Lucky money',
      sentences: [
        WritingSentence.of(
          'Tết năm nay tôi đã nhận được nhiều tiền mừng tuổi.',
          'This Tet I got a lot of lucky money.',
          G.pastSimple,
          alternatives: ['This Tet I received a lot of lucky money.'],
        ),
        WritingSentence.of(
          'Ông bà đã cho tôi phong bao đỏ.',
          'My grandparents gave me red envelopes.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Tôi đã đưa hết tiền cho mẹ.',
          'I gave all the money to my mother.',
          G.pastSimple,
          alternatives: ['I gave all the money to my mom.'],
        ),
        WritingSentence.of(
          'Mẹ đã gửi nó vào ngân hàng.',
          'She put it in the bank.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Tôi đã mua một cuốn sách bằng một ít tiền.',
          'I bought a book with a little money.',
          G.pastSimple,
          alternatives: ['I used a little money to buy a book.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'finance_b3',
      level: _b,
      titleVi: 'Ở ngân hàng',
      titleEn: 'At the bank',
      sentences: [
        WritingSentence.of(
          'Hôm nay bố tôi đang ở ngân hàng.',
          'Today my father is at the bank.',
          G.presentSimple,
          alternatives: ['My dad is at the bank today.'],
        ),
        WritingSentence.of(
          'Bố đang mở một tài khoản mới.',
          'He is opening a new account.',
          G.presentContinuous,
        ),
        WritingSentence.of(
          'Nhân viên đang giúp bố.',
          'A bank clerk is helping him.',
          G.presentContinuous,
          alternatives: ['A staff member is helping him.'],
        ),
        WritingSentence.of(
          'Bố phải mang theo chứng minh thư.',
          'He must bring his ID card.',
          G.modal,
          alternatives: ['He has to bring his ID card.'],
        ),
        WritingSentence.of(
          'Bố có thể dùng thẻ ngay hôm nay.',
          'He can use the card today.',
          G.modal,
        ),
      ],
    ),
    WritingParagraph(
      id: 'finance_b4',
      level: _b,
      titleVi: 'Tiền tiêu vặt',
      titleEn: 'Pocket money',
      sentences: [
        WritingSentence.of(
          'Mẹ cho tôi tiền tiêu vặt mỗi tuần.',
          'My mother gives me pocket money every week.',
          G.presentSimple,
          alternatives: ['My mom gives me pocket money every week.'],
        ),
        WritingSentence.of(
          'Tôi thường mua bánh và nước uống.',
          'I usually buy snacks and drinks.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tôi ghi lại mọi khoản chi tiêu.',
          'I write down everything I spend.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tôi không nên tiêu hết tiền.',
          'I should not spend all my money.',
          G.modal,
          alternatives: ['I shouldn\'t spend all my money.'],
        ),
        WritingSentence.of(
          'Tôi muốn tiết kiệm một nửa.',
          'I want to save half of it.',
          G.presentSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'finance_b5',
      level: _b,
      titleVi: 'Trả tiền bằng điện thoại',
      titleEn: 'Paying by phone',
      sentences: [
        WritingSentence.of(
          'Chị tôi không mang tiền mặt.',
          'My sister does not carry cash.',
          G.presentSimple,
          alternatives: ['My sister doesn\'t carry cash.'],
        ),
        WritingSentence.of(
          'Chị ấy trả tiền bằng điện thoại.',
          'She pays with her phone.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Chị ấy chỉ cần quét mã.',
          'She only needs to scan a code.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Nó rất nhanh và tiện lợi.',
          'It is very fast and convenient.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tôi sẽ thử cách này vào ngày mai.',
          'I will try it tomorrow.',
          G.futureSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'finance_b6',
      level: _b,
      titleVi: 'Đi làm thêm kiếm tiền',
      titleEn: 'Earning my own money',
      sentences: [
        WritingSentence.of(
          'Mùa hè năm ngoái, tôi đã bán nước chanh.',
          'Last summer, I sold lemonade.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Tôi đã làm việc mỗi buổi chiều.',
          'I worked every afternoon.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Nhiều người đã mua nước của tôi.',
          'Many people bought my lemonade.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Tôi đã kiếm được năm trăm nghìn đồng.',
          'I earned five hundred thousand dong.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Tôi đã rất tự hào.',
          'I was very proud.',
          G.pastSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'finance_b7',
      level: _b,
      titleVi: 'Mất ví',
      titleEn: 'A lost wallet',
      sentences: [
        WritingSentence.of(
          'Hôm qua tôi đã làm mất ví.',
          'Yesterday I lost my wallet.',
          G.pastSimple,
          alternatives: ['I lost my wallet yesterday.'],
        ),
        WritingSentence.of(
          'Trong ví có tiền và thẻ.',
          'It had money and cards in it.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Một bà cụ đã tìm thấy nó.',
          'An old woman found it.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Bà ấy đã gọi cho tôi.',
          'She called me.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Tôi đã cảm ơn bà rất nhiều.',
          'I thanked her very much.',
          G.pastSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'finance_b8',
      level: _b,
      titleVi: 'Kế hoạch tiết kiệm',
      titleEn: 'A saving plan',
      sentences: [
        WritingSentence.of(
          'Năm nay, tôi định tiết kiệm tiền.',
          'This year, I am going to save money.',
          G.goingTo,
        ),
        WritingSentence.of(
          'Tôi sẽ không mua trà sữa mỗi ngày.',
          'I will not buy bubble tea every day.',
          G.futureSimple,
          alternatives: [
            'I won\'t buy bubble tea every day.',
            'I will not buy milk tea every day.',
          ],
        ),
        WritingSentence.of(
          'Tôi sẽ tự nấu bữa trưa.',
          'I will cook my own lunch.',
          G.futureSimple,
        ),
        WritingSentence.of(
          'Tôi có thể tiết kiệm được nhiều tiền.',
          'I can save a lot of money.',
          G.modal,
        ),
        WritingSentence.of(
          'Tôi muốn đi du lịch vào mùa hè.',
          'I want to travel in the summer.',
          G.presentSimple,
        ),
      ],
    ),

    // ---------------- Trung cap ----------------
    WritingParagraph(
      id: 'finance_i1',
      level: _i,
      titleVi: 'Tài khoản tiết kiệm đầu tiên',
      titleEn: 'My first savings account',
      sentences: [
        WritingSentence.of(
          'Tôi vừa mở tài khoản tiết kiệm đầu tiên.',
          'I have just opened my first savings account.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Lãi suất ở ngân hàng này cao hơn ngân hàng khác.',
          'The interest rate at this bank is higher than at other banks.',
          G.comparison,
        ),
        WritingSentence.of(
          'Tiền lương được chuyển vào tài khoản mỗi tháng.',
          'My salary is paid into the account every month.',
          G.passive,
        ),
        WritingSentence.of(
          'Hôm qua, khi tôi đang chờ ở quầy, tôi gặp một người bạn cũ.',
          'Yesterday, while I was waiting at the counter, I met an old friend.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Cô ấy đã tiết kiệm được đủ tiền mua nhà.',
          'She has saved enough money to buy a house.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Nếu tôi tiết kiệm đều đặn, tôi cũng sẽ làm được như vậy.',
          'If I save regularly, I will be able to do the same.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'finance_i2',
      level: _i,
      titleVi: 'Lừa đảo qua điện thoại',
      titleEn: 'A phone scam',
      sentences: [
        WritingSentence.of(
          'Tuần trước, bà tôi nhận được một cuộc gọi lạ.',
          'Last week, my grandmother got a strange phone call.',
          G.pastSimple,
          alternatives: [
            'Last week, my grandma received a strange phone call.',
          ],
        ),
        WritingSentence.of(
          'Người gọi hứa tặng bà một giải thưởng lớn.',
          'The caller offered her a big prize.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Trong khi bà đang đọc số tài khoản, tôi giật lấy điện thoại.',
          'While she was reading out her account number, I grabbed the phone.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Nhiều người già đã bị lừa theo cách này.',
          'Many old people have been cheated in this way.',
          G.passive,
        ),
        WritingSentence.of(
          'Những kẻ lừa đảo ngày càng tinh vi hơn.',
          'Scammers are becoming more and more clever.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nếu có ai hỏi mã OTP, bà sẽ cúp máy ngay.',
          'If anyone asks for her code, she will hang up immediately.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'finance_i3',
      level: _i,
      titleVi: 'Chi tiêu sinh viên',
      titleEn: 'A student budget',
      sentences: [
        WritingSentence.of(
          'Cuộc sống sinh viên ở thành phố đắt đỏ hơn tôi nghĩ.',
          'Student life in the city is more expensive than I thought.',
          G.comparison,
        ),
        WritingSentence.of(
          'Tiền thuê nhà được chia cho ba người.',
          'The rent is shared by three people.',
          G.passive,
          alternatives: ['The rent is split between three people.'],
        ),
        WritingSentence.of(
          'Tôi đã dùng ứng dụng quản lý chi tiêu được hai tháng.',
          'I have used a budgeting app for two months.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Tối qua, khi tôi đang xem lại chi tiêu, tôi rất ngạc nhiên.',
          'Last night, while I was checking my spending, I was very surprised.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Tôi tiêu cho cà phê nhiều hơn cho sách.',
          'I spend more on coffee than on books.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nếu tôi tự pha cà phê, tôi sẽ tiết kiệm được nhiều tiền.',
          'If I make my own coffee, I will save a lot of money.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'finance_i4',
      level: _i,
      titleVi: 'Giá vàng',
      titleEn: 'The price of gold',
      sentences: [
        WritingSentence.of(
          'Nhiều gia đình Việt Nam thích mua vàng để tiết kiệm.',
          'Many Vietnamese families like buying gold as savings.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Giá vàng năm nay cao hơn bao giờ hết.',
          'The price of gold this year is higher than ever.',
          G.comparison,
        ),
        WritingSentence.of(
          'Mẹ tôi đã mua một ít vàng từ nhiều năm trước.',
          'My mother bought a little gold many years ago.',
          G.pastSimple,
          alternatives: ['My mom bought some gold many years ago.'],
        ),
        WritingSentence.of(
          'Vàng thường được mua vào ngày vía Thần Tài.',
          'Gold is often bought on the God of Wealth day.',
          G.passive,
        ),
        WritingSentence.of(
          'Năm ngoái, khi mọi người đang xếp hàng mua vàng, cửa hàng hết hàng.',
          'Last year, while people were queuing to buy gold, the shop ran out.',
          G.pastContinuous,
          alternatives: [
            'Last year, while people were lining up to buy gold, the shop ran out.',
          ],
        ),
        WritingSentence.of(
          'Nếu giá giảm, mẹ tôi sẽ mua thêm.',
          'If the price falls, my mother will buy more.',
          G.conditional1,
          alternatives: ['If the price goes down, my mom will buy more.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'finance_i5',
      level: _i,
      titleVi: 'Vay tiền bạn bè',
      titleEn: 'Lending money to a friend',
      sentences: [
        WritingSentence.of(
          'Tháng trước, một người bạn đã vay tôi hai triệu đồng.',
          'Last month, a friend borrowed two million dong from me.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Cậu ấy vẫn chưa trả lại tiền.',
          'He has not paid it back yet.',
          G.presentPerfect,
          alternatives: ['He hasn\'t paid me back yet.'],
        ),
        WritingSentence.of(
          'Hôm qua, khi tôi đang định hỏi, cậu ấy đổi chủ đề.',
          'Yesterday, while I was about to ask, he changed the subject.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Nói chuyện tiền bạc với bạn bè khó hơn với người lạ.',
          'Talking about money with friends is harder than with strangers.',
          G.comparison,
        ),
        WritingSentence.of(
          'Tôi được mẹ khuyên nên nói thẳng với cậu ấy.',
          'I was advised by my mother to talk to him directly.',
          G.passive,
        ),
        WritingSentence.of(
          'Nếu cậu ấy không trả, tôi sẽ không cho vay nữa.',
          'If he does not pay me back, I will not lend him money again.',
          G.conditional1,
          alternatives: [
            'If he doesn\'t pay me back, I won\'t lend him money again.',
          ],
        ),
      ],
    ),
    WritingParagraph(
      id: 'finance_i6',
      level: _i,
      titleVi: 'Giá cả tăng',
      titleEn: 'Rising prices',
      sentences: [
        WritingSentence.of(
          'Giá thực phẩm đã tăng nhanh trong năm nay.',
          'Food prices have risen quickly this year.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Một bát phở bây giờ đắt hơn năm ngoái mười nghìn đồng.',
          'A bowl of pho is now ten thousand dong more expensive than last year.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nhiều gia đình được khuyên nên chi tiêu cẩn thận hơn.',
          'Many families are advised to spend more carefully.',
          G.passive,
        ),
        WritingSentence.of(
          'Sáng nay, trong khi mẹ đang đi chợ, mẹ gọi cho tôi than giá thịt.',
          'This morning, while Mom was shopping, she called me to complain about meat prices.',
          G.pastContinuous,
          alternatives: [
            'This morning, while Mum was shopping, she called me to complain about meat prices.',
          ],
        ),
        WritingSentence.of(
          'Chúng tôi đã bắt đầu ăn nhiều rau hơn.',
          'We have started eating more vegetables.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Nếu giá tiếp tục tăng, chúng tôi sẽ tự trồng rau.',
          'If prices keep rising, we will grow our own vegetables.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'finance_i7',
      level: _i,
      titleVi: 'Mua trả góp',
      titleEn: 'Buying in instalments',
      sentences: [
        WritingSentence.of(
          'Anh trai tôi vừa mua một chiếc laptop trả góp.',
          'My brother has just bought a laptop in instalments.',
          G.presentPerfect,
          alternatives: [
            'My brother has just bought a laptop in installments.',
          ],
        ),
        WritingSentence.of(
          'Anh ấy sẽ trả tiền trong mười hai tháng.',
          'He will pay for it over twelve months.',
          G.futureSimple,
        ),
        WritingSentence.of(
          'Tổng số tiền cao hơn giá gốc một chút.',
          'The total cost is a little higher than the original price.',
          G.comparison,
        ),
        WritingSentence.of(
          'Hợp đồng đã được anh ấy đọc rất kỹ.',
          'The contract was read very carefully by him.',
          G.passive,
        ),
        WritingSentence.of(
          'Khi anh ấy đang ký hợp đồng, nhân viên mời mua thêm bảo hiểm.',
          'While he was signing the contract, the staff offered him insurance.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Nếu anh ấy trả chậm, anh sẽ phải trả thêm phí.',
          'If he pays late, he will have to pay extra fees.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'finance_i8',
      level: _i,
      titleVi: 'Lương đầu tiên',
      titleEn: 'My first salary',
      sentences: [
        WritingSentence.of(
          'Tôi vừa nhận được tháng lương đầu tiên.',
          'I have just received my first salary.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Đó là số tiền lớn nhất tôi từng tự kiếm được.',
          'It is the most money I have ever earned myself.',
          G.comparison,
        ),
        WritingSentence.of(
          'Một phần tiền được tôi gửi về cho bố mẹ.',
          'Part of the money was sent home to my parents.',
          G.passive,
        ),
        WritingSentence.of(
          'Khi tôi đang chuyển tiền, mẹ gọi điện và khóc.',
          'While I was sending the money, my mother called and cried.',
          G.pastContinuous,
          alternatives: [
            'While I was sending the money, my mom called and cried.',
          ],
        ),
        WritingSentence.of(
          'Mẹ tự hào về tôi hơn bao giờ hết.',
          'She is prouder of me than ever.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nếu công việc ổn định, tôi sẽ tiết kiệm một nửa lương mỗi tháng.',
          'If my job stays stable, I will save half my salary every month.',
          G.conditional1,
        ),
      ],
    ),

    // ---------------- Nang cao ----------------
    WritingParagraph(
      id: 'finance_a1',
      level: _a,
      titleVi: 'Đầu tư chứng khoán',
      titleEn: 'Investing in stocks',
      sentences: [
        WritingSentence.of(
          'Anh họ tôi, người mới hai mươi lăm tuổi, đã đầu tư chứng khoán được ba năm.',
          'My cousin, who is only twenty five, has been investing in stocks for three years.',
          G.relativeClause,
          alternatives: [
            'My cousin, who is only twenty-five, has been investing in stocks for three years.',
          ],
        ),
        WritingSentence.of(
          'Anh ấy đã mất gần một nửa số vốn trước khi hiểu cách thị trường vận hành.',
          'He had lost almost half his money before he understood how the market worked.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Một chuyên gia tài chính khuyên anh rằng anh nên đầu tư lâu dài thay vì lướt sóng.',
          'A financial adviser told him that he should invest for the long term instead of trading quickly.',
          G.reportedSpeech,
          alternatives: [
            'A financial advisor told him that he should invest for the long term instead of trading quickly.',
          ],
        ),
        WritingSentence.of(
          'Nếu anh ấy học về tài chính sớm hơn, anh đã không mất nhiều tiền như vậy.',
          'If he had studied finance earlier, he would not have lost so much money.',
          G.conditional3,
        ),
        WritingSentence.of(
          'Gần đây, anh ấy đã và đang đầu tư đều đặn vào các quỹ chỉ số.',
          'Recently, he has been investing regularly in index funds.',
          G.presentPerfectContinuous,
        ),
        WritingSentence.of(
          'Đến khi ba mươi tuổi, anh hy vọng sẽ tích luỹ đủ tiền để mua căn hộ đầu tiên.',
          'By the time he is thirty, he hopes he will have saved enough for his first apartment.',
          G.futurePerfect,
        ),
      ],
    ),
    WritingParagraph(
      id: 'finance_a2',
      level: _a,
      titleVi: 'Xã hội không tiền mặt',
      titleEn: 'A cashless society',
      sentences: [
        WritingSentence.of(
          'Chỉ trong vài năm, thanh toán bằng mã QR đã trở nên phổ biến ở mọi nơi.',
          'In just a few years, QR code payments have become common everywhere.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Ngay cả bà bán rau, người chưa từng dùng ngân hàng, giờ cũng dán mã QR ở sạp.',
          'Even the old vegetable seller, who had never used a bank, now has a QR code at her stall.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Bà kể rằng con trai bà đã hướng dẫn bà cách nhận tiền qua điện thoại.',
          'She told me that her son had shown her how to receive money on her phone.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu hệ thống ngân hàng gặp sự cố, nhiều người sẽ không thể mua được gì.',
          'If the banking system broke down, many people would not be able to buy anything.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Một số chuyên gia cảnh báo rằng người cao tuổi đang bị bỏ lại phía sau.',
          'Some experts have warned that older people are being left behind.',
          G.passive,
        ),
        WritingSentence.of(
          'Đến cuối thập kỷ này, tiền mặt có lẽ đã gần như biến mất ở các thành phố lớn.',
          'By the end of this decade, cash will probably have almost disappeared in big cities.',
          G.futurePerfect,
        ),
      ],
    ),
    WritingParagraph(
      id: 'finance_a3',
      level: _a,
      titleVi: 'Nợ thẻ tín dụng',
      titleEn: 'Credit card debt',
      sentences: [
        WritingSentence.of(
          'Khi mới đi làm, tôi đăng ký thẻ tín dụng mà không đọc kỹ các điều khoản.',
          'When I first started working, I got a credit card without reading the terms carefully.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Tôi đã tiêu bằng thẻ suốt nhiều tháng trước khi nhận ra mình nợ bao nhiêu.',
          'I had been spending on the card for months before I realized how much I owed.',
          G.pastPerfectContinuous,
          alternatives: [
            'I had been spending on the card for months before I realised how much I owed.',
          ],
        ),
        WritingSentence.of(
          'Lãi suất, vốn cao hơn nhiều so với tôi tưởng, khiến khoản nợ tăng rất nhanh.',
          'The interest rate, which was much higher than I thought, made the debt grow very quickly.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Bố tôi khuyên rằng tôi nên trả hết nợ trước khi mua bất cứ thứ gì khác.',
          'My father advised me that I should pay off the debt before buying anything else.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu tôi hiểu về lãi suất sớm hơn, tôi đã không rơi vào tình cảnh đó.',
          'If I had understood interest rates earlier, I would not have got into that situation.',
          G.conditional3,
          alternatives: [
            'If I had understood interest rates earlier, I would not have gotten into that situation.',
          ],
        ),
        WritingSentence.of(
          'Đến cuối năm nay, tôi sẽ trả hết toàn bộ khoản nợ.',
          'By the end of this year, I will have paid off all my debt.',
          G.futurePerfect,
        ),
      ],
    ),
    WritingParagraph(
      id: 'finance_a4',
      level: _a,
      titleVi: 'Khởi nghiệp từ số vốn nhỏ',
      titleEn: 'A small business on a small budget',
      sentences: [
        WritingSentence.of(
          'Chị tôi bắt đầu kinh doanh bánh handmade với số vốn chỉ năm triệu đồng.',
          'My sister started a homemade cake business with just five million dong.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Chị ấy đã bán bánh trên mạng suốt một năm trước khi thuê cửa hàng.',
          'She had been selling cakes online for a year before she rented a shop.',
          G.pastPerfectContinuous,
        ),
        WritingSentence.of(
          'Mọi khoản thu chi đều được chị ghi chép cẩn thận trong một cuốn sổ.',
          'Every expense and payment has been recorded carefully in a notebook.',
          G.passive,
        ),
        WritingSentence.of(
          'Chị nói với tôi rằng quản lý dòng tiền quan trọng hơn bán được nhiều hàng.',
          'She told me that managing cash flow was more important than selling a lot.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu chị ấy vay ngân hàng để mở rộng quá sớm, có lẽ chị đã phá sản.',
          'If she had borrowed money to expand too early, she might have gone bankrupt.',
          G.conditional3,
        ),
        WritingSentence.of(
          'Vào giờ này năm sau, chị ấy sẽ đang mở cửa hàng thứ hai.',
          'This time next year, she will be opening her second shop.',
          G.futureContinuous,
        ),
      ],
    ),
    WritingParagraph(
      id: 'finance_a5',
      level: _a,
      titleVi: 'Bảo hiểm',
      titleEn: 'Why insurance matters',
      sentences: [
        WritingSentence.of(
          'Nhiều người trẻ cho rằng bảo hiểm là thứ chỉ người lớn tuổi mới cần.',
          'Many young people think that insurance is something only older people need.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Bạn tôi đã không mua bảo hiểm y tế trước khi phải nhập viện vì một ca phẫu thuật.',
          'My friend had not bought health insurance before he needed an operation.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Hoá đơn viện phí, vốn lên tới hàng trăm triệu đồng, đã lấy hết tiền tiết kiệm của cậu ấy.',
          'The hospital bill, which came to hundreds of millions of dong, took all his savings.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Nếu cậu ấy có bảo hiểm, cậu đã không phải vay tiền bạn bè.',
          'If he had had insurance, he would not have had to borrow from friends.',
          G.conditional3,
        ),
        WritingSentence.of(
          'Kể từ đó, cậu ấy đã đóng bảo hiểm đều đặn hàng tháng.',
          'Since then, he has been paying for insurance every month.',
          G.presentPerfectContinuous,
        ),
        WritingSentence.of(
          'Cậu ấy thường khuyên mọi người rằng bảo hiểm nên được coi là một khoản đầu tư.',
          'He often tells people that insurance should be seen as an investment.',
          G.passive,
        ),
      ],
    ),
    WritingParagraph(
      id: 'finance_a6',
      level: _a,
      titleVi: 'Tiền điện tử',
      titleEn: 'Cryptocurrency',
      sentences: [
        WritingSentence.of(
          'Tiền điện tử, thứ mà nhiều người vẫn chưa hiểu rõ, đã thu hút rất nhiều nhà đầu tư trẻ.',
          'Cryptocurrency, which many people still do not understand, has attracted many young investors.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Bạn cùng phòng của tôi đã mua tiền điện tử suốt nhiều tháng trước khi thị trường sụp đổ.',
          'My roommate had been buying crypto for months before the market crashed.',
          G.pastPerfectContinuous,
        ),
        WritingSentence.of(
          'Anh ấy thừa nhận rằng anh đã đầu tư chỉ vì thấy người khác kiếm được nhiều tiền.',
          'He admitted that he had invested only because he had seen others making money.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu anh ấy chỉ đầu tư số tiền có thể chấp nhận mất, anh đã không lo lắng đến vậy.',
          'If he had only invested money he could afford to lose, he would not have been so worried.',
          G.conditional3,
        ),
        WritingSentence.of(
          'Giá trị của các đồng tiền này thay đổi nhanh hơn bất kỳ tài sản nào khác.',
          'The value of these coins changes faster than any other asset.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nhiều quốc gia đã và đang xây dựng luật để quản lý thị trường này.',
          'Many countries have been creating laws to regulate this market.',
          G.presentPerfectContinuous,
        ),
      ],
    ),
    WritingParagraph(
      id: 'finance_a7',
      level: _a,
      titleVi: 'Nghỉ hưu sớm',
      titleEn: 'Retiring early',
      sentences: [
        WritingSentence.of(
          'Phong trào nghỉ hưu sớm, bắt nguồn từ Mỹ, đang thu hút nhiều người trẻ Việt Nam.',
          'The early retirement movement, which started in America, is attracting many young Vietnamese.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Người theo phong trào này thường tiết kiệm hơn một nửa thu nhập mỗi tháng.',
          'People who follow it often save more than half their income every month.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Anh đồng nghiệp của tôi đã sống rất tiết kiệm từ khi mới ra trường.',
          'My colleague has been living very frugally since he graduated.',
          G.presentPerfectContinuous,
        ),
        WritingSentence.of(
          'Anh nói rằng anh muốn ngừng làm việc trước bốn mươi tuổi.',
          'He said that he wanted to stop working before he turned forty.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu tôi sống như anh ấy, tôi sẽ không thể tận hưởng tuổi trẻ.',
          'If I lived like him, I would not be able to enjoy my youth.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Đến năm ba mươi tám tuổi, anh ấy sẽ tiết kiệm đủ để sống bằng tiền lãi.',
          'By the age of thirty eight, he will have saved enough to live on the interest.',
          G.futurePerfect,
          alternatives: [
            'By the age of thirty-eight, he will have saved enough to live on the interest.',
          ],
        ),
      ],
    ),
    WritingParagraph(
      id: 'finance_a8',
      level: _a,
      titleVi: 'Dạy con về tiền',
      titleEn: 'Teaching children about money',
      sentences: [
        WritingSentence.of(
          'Nhiều chuyên gia tin rằng trẻ em nên được dạy về tiền từ khi còn nhỏ.',
          'Many experts believe that children should be taught about money from an early age.',
          G.passive,
        ),
        WritingSentence.of(
          'Bố mẹ tôi, những người từng rất nghèo, luôn dạy tôi giá trị của từng đồng tiền.',
          'My parents, who were once very poor, always taught me the value of every coin.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Khi tôi mười tuổi, tôi đã tự tiết kiệm đủ tiền mua chiếc xe đạp đầu tiên.',
          'By the time I was ten, I had saved enough to buy my first bike.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Mẹ tôi nói rằng tự kiếm tiền giúp trẻ hiểu công sức của bố mẹ.',
          'My mother said that earning money helped children understand their parents\' hard work.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu trường học dạy về tài chính cá nhân, học sinh sẽ ít mắc sai lầm hơn khi trưởng thành.',
          'If schools taught personal finance, students would make fewer mistakes as adults.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Sau này, tôi sẽ cho con mình một khoản tiền tiêu vặt nhỏ mỗi tuần.',
          'In the future, I will give my children a small amount of pocket money every week.',
          G.futureSimple,
        ),
      ],
    ),
  ],
);
