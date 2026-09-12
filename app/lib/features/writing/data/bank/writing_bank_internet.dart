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

const kWritingBankInternet = WritingTopic(
  id: 'internet',
  titleVi: 'Internet',
  titleEn: 'The Internet',
  icon: Icons.public_rounded,
  color: AppColors.blue,
  paragraphs: [
    // ---------------- Co ban ----------------
    WritingParagraph(
      id: 'internet_b1',
      level: _b,
      titleVi: 'Tôi dùng Internet',
      titleEn: 'I use the Internet',
      sentences: [
        WritingSentence.of(
          'Tôi dùng Internet mỗi ngày.',
          'I use the Internet every day.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tôi xem video trên mạng.',
          'I watch videos online.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tôi tìm thông tin cho bài tập.',
          'I search for information for my homework.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Bây giờ tôi đang xem tin tức.',
          'Now I am reading the news.',
          G.presentContinuous,
        ),
        WritingSentence.of(
          'Internet giúp tôi học tốt hơn.',
          'The Internet helps me study better.',
          G.presentSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'internet_b2',
      level: _b,
      titleVi: 'Mạng chậm',
      titleEn: 'Slow internet',
      sentences: [
        WritingSentence.of(
          'Hôm nay mạng rất chậm.',
          'The internet is very slow today.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tôi đang chờ video tải.',
          'I am waiting for a video to load.',
          G.presentContinuous,
        ),
        WritingSentence.of(
          'Bố tôi đang gọi cho nhà mạng.',
          'My father is calling the internet company.',
          G.presentContinuous,
          alternatives: ['My dad is calling the internet company.'],
        ),
        WritingSentence.of(
          'Chúng tôi phải chờ họ sửa.',
          'We must wait for them to fix it.',
          G.modal,
          alternatives: ['We have to wait for them to fix it.'],
        ),
        WritingSentence.of(
          'Nó sẽ nhanh hơn vào tối nay.',
          'It will be faster tonight.',
          G.futureSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'internet_b3',
      level: _b,
      titleVi: 'Mạng xã hội',
      titleEn: 'Social media',
      sentences: [
        WritingSentence.of(
          'Chị tôi dùng mạng xã hội mỗi ngày.',
          'My sister uses social media every day.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Chị ấy đăng ảnh của mình.',
          'She posts photos of herself.',
          G.presentSimple,
          alternatives: ['She posts pictures of herself.'],
        ),
        WritingSentence.of(
          'Bây giờ chị ấy đang đọc bình luận.',
          'Now she is reading comments.',
          G.presentContinuous,
        ),
        WritingSentence.of(
          'Bạn không nên chia sẻ thông tin cá nhân.',
          'You should not share personal information.',
          G.modal,
          alternatives: ['You shouldn\'t share personal information.'],
        ),
        WritingSentence.of(
          'Chúng ta phải cẩn thận trên mạng.',
          'We must be careful online.',
          G.modal,
        ),
      ],
    ),
    WritingParagraph(
      id: 'internet_b4',
      level: _b,
      titleVi: 'Học từ mới trên mạng',
      titleEn: 'Learning words online',
      sentences: [
        WritingSentence.of(
          'Hôm qua tôi đã học từ mới trên mạng.',
          'Yesterday I learned new words online.',
          G.pastSimple,
          alternatives: ['Yesterday I learnt new words online.'],
        ),
        WritingSentence.of(
          'Tôi đã xem ba video tiếng Anh.',
          'I watched three English videos.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Tôi đã viết chúng vào sổ.',
          'I wrote them in my notebook.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Tôi đã học được mười từ mới.',
          'I learned ten new words.',
          G.pastSimple,
          alternatives: ['I learnt ten new words.'],
        ),
        WritingSentence.of(
          'Tôi đã rất vui.',
          'I was very happy.',
          G.pastSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'internet_b5',
      level: _b,
      titleVi: 'Wifi ở nhà',
      titleEn: 'Wifi at home',
      sentences: [
        WritingSentence.of(
          'Nhà tôi có wifi.',
          'We have wifi at home.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Mật khẩu wifi rất dài.',
          'The wifi password is very long.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tôi thường quên nó.',
          'I often forget it.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Bố tôi sẽ đổi mật khẩu mới.',
          'My father will change the password.',
          G.futureSimple,
          alternatives: ['My dad will change the password.'],
        ),
        WritingSentence.of(
          'Tôi sẽ viết nó ra giấy.',
          'I will write it on paper.',
          G.futureSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'internet_b6',
      level: _b,
      titleVi: 'Học nhóm qua mạng',
      titleEn: 'Studying online with friends',
      sentences: [
        WritingSentence.of(
          'Tối nay tôi định học nhóm qua mạng.',
          'Tonight I am going to study with friends online.',
          G.goingTo,
        ),
        WritingSentence.of(
          'Chúng tôi sẽ dùng camera và micro.',
          'We will use cameras and microphones.',
          G.futureSimple,
        ),
        WritingSentence.of(
          'Bạn tôi sẽ chia sẻ màn hình.',
          'My friend will share her screen.',
          G.futureSimple,
        ),
        WritingSentence.of(
          'Chúng tôi có thể hỏi bài lẫn nhau.',
          'We can ask each other questions.',
          G.modal,
        ),
        WritingSentence.of(
          'Chúng tôi sẽ không cần học một mình nữa.',
          'We will not need to study alone anymore.',
          G.futureSimple,
          alternatives: ['We won\'t need to study alone anymore.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'internet_b7',
      level: _b,
      titleVi: 'Mua sách trên mạng',
      titleEn: 'Buying a book online',
      sentences: [
        WritingSentence.of(
          'Tôi đã tìm thấy một cuốn sách hay trên mạng.',
          'I found a good book online.',
          G.pastSimple,
        ),
        WritingSentence.of('Tôi đã đặt mua nó.', 'I ordered it.', G.pastSimple),
        WritingSentence.of(
          'Nó đã đến sau ba ngày.',
          'It arrived after three days.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Tôi đã đọc nó ngay lập tức.',
          'I read it right away.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Tôi đã rất thích nó.',
          'I really liked it.',
          G.pastSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'internet_b8',
      level: _b,
      titleVi: 'Trò chuyện với gia đình ở xa',
      titleEn: 'Video calling family',
      sentences: [
        WritingSentence.of(
          'Chú tôi sống ở nước ngoài.',
          'My uncle lives abroad.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Chúng tôi gọi video cho chú mỗi Chủ nhật.',
          'We video call him every Sunday.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Bây giờ chú đang cười với chúng tôi.',
          'Now he is laughing with us.',
          G.presentContinuous,
        ),
        WritingSentence.of(
          'Chúng tôi có thể nhìn thấy nhau rõ ràng.',
          'We can see each other clearly.',
          G.modal,
        ),
        WritingSentence.of(
          'Internet giúp gia đình tôi gần nhau hơn.',
          'The Internet keeps my family closer.',
          G.presentSimple,
        ),
      ],
    ),

    // ---------------- Trung cap ----------------
    WritingParagraph(
      id: 'internet_i1',
      level: _i,
      titleVi: 'Tin giả trên mạng',
      titleEn: 'Fake news online',
      sentences: [
        WritingSentence.of(
          'Tuần trước, một tin giả đã được chia sẻ hàng nghìn lần.',
          'Last week, a piece of fake news was shared thousands of times.',
          G.passive,
        ),
        WritingSentence.of(
          'Nhiều người đã tin nó ngay lập tức.',
          'Many people believed it immediately.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Tin thật khó phân biệt hơn tôi tưởng.',
          'Real news is harder to identify than I thought.',
          G.comparison,
        ),
        WritingSentence.of(
          'Trong khi tôi đang đọc bài báo, tôi nhận ra nguồn không đáng tin.',
          'While I was reading the article, I noticed the source was not reliable.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Chúng ta nên kiểm tra nguồn tin trước khi chia sẻ.',
          'We should check the source before sharing.',
          G.modal,
        ),
        WritingSentence.of(
          'Nếu mọi người cẩn thận hơn, tin giả sẽ lan ít hơn.',
          'If people were more careful, fake news would spread less.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'internet_i2',
      level: _i,
      titleVi: 'Nghiện mạng xã hội',
      titleEn: 'Addicted to social media',
      sentences: [
        WritingSentence.of(
          'Em trai tôi đã dùng điện thoại nhiều hơn trước rất nhiều.',
          'My brother has used his phone much more than before.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nó đã kiểm tra thông báo hơn một trăm lần mỗi ngày.',
          'It has checked notifications more than a hundred times a day.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Tối qua, trong khi nó đang lướt điện thoại, mẹ tôi tắt wifi.',
          'Last night, while it was scrolling on his phone, my mother turned off the wifi.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Nó đã giận dữ nhưng sau đó hiểu ra vấn đề.',
          'It was upset at first but then understood the problem.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Chúng ta được khuyên nên giới hạn thời gian dùng điện thoại.',
          'We are advised to limit our screen time.',
          G.passive,
        ),
        WritingSentence.of(
          'Nếu nó tiếp tục như vậy, mắt nó sẽ kém đi.',
          'If it keeps doing that, its eyes will get worse.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'internet_i3',
      level: _i,
      titleVi: 'Học kỹ năng mới trên mạng',
      titleEn: 'Learning a new skill online',
      sentences: [
        WritingSentence.of(
          'Tôi đã tự học thiết kế đồ hoạ qua Internet.',
          'I have taught myself graphic design through the Internet.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Có nhiều khoá học miễn phí hơn tôi nghĩ.',
          'There are more free courses than I thought.',
          G.comparison,
        ),
        WritingSentence.of(
          'Mỗi bài học được giải thích rất rõ ràng.',
          'Each lesson is explained very clearly.',
          G.passive,
        ),
        WritingSentence.of(
          'Tuần trước, trong khi tôi đang học, máy tính bị treo.',
          'Last week, while I was studying, my computer froze.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Tôi đã hoàn thành khoá học đầu tiên.',
          'I have completed my first course.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Nếu tôi học thêm, tôi sẽ tìm được việc làm thêm.',
          'If I learn more, I will find a part-time job.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'internet_i4',
      level: _i,
      titleVi: 'Riêng tư trên mạng',
      titleEn: 'Online privacy',
      sentences: [
        WritingSentence.of(
          'Thông tin cá nhân của tôi được lưu bởi nhiều ứng dụng.',
          'My personal information is stored by many apps.',
          G.passive,
        ),
        WritingSentence.of(
          'Tôi đã đọc chính sách quyền riêng tư lần đầu tiên tuần này.',
          'I have read a privacy policy for the first time this week.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Nó dài hơn tôi tưởng rất nhiều.',
          'It was much longer than I expected.',
          G.comparison,
        ),
        WritingSentence.of(
          'Trong khi tôi đang đọc, tôi nhận ra ứng dụng theo dõi vị trí của tôi.',
          'While I was reading, I realized the app was tracking my location.',
          G.pastContinuous,
          alternatives: [
            'While I was reading, I realised the app was tracking my location.',
          ],
        ),
        WritingSentence.of(
          'Chúng ta nên kiểm tra cài đặt quyền riêng tư thường xuyên.',
          'We should check our privacy settings regularly.',
          G.modal,
        ),
        WritingSentence.of(
          'Nếu tôi không cẩn thận, dữ liệu của tôi sẽ không an toàn.',
          'If I am not careful, my data will not be safe.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'internet_i5',
      level: _i,
      titleVi: 'Bắt nạt trên mạng',
      titleEn: 'Cyberbullying',
      sentences: [
        WritingSentence.of(
          'Bạn tôi đã bị bắt nạt trên mạng năm ngoái.',
          'My friend was cyberbullied last year.',
          G.passive,
        ),
        WritingSentence.of(
          'Nhiều bình luận xấu được viết dưới ảnh của cô ấy.',
          'Many mean comments were written under her photos.',
          G.passive,
        ),
        WritingSentence.of(
          'Cô ấy đã cảm thấy buồn hơn bao giờ hết.',
          'She felt sadder than ever.',
          G.comparison,
        ),
        WritingSentence.of(
          'Trong khi cô ấy đang khóc, tôi đã giúp cô báo cáo tài khoản đó.',
          'While she was crying, I helped her report the account.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Cô ấy đã học được cách bỏ qua những bình luận xấu.',
          'She has learned to ignore mean comments.',
          G.presentPerfect,
          alternatives: ['She has learnt to ignore mean comments.'],
        ),
        WritingSentence.of(
          'Nếu bạn thấy bắt nạt trên mạng, bạn nên báo cáo ngay.',
          'If you see cyberbullying, you should report it immediately.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'internet_i6',
      level: _i,
      titleVi: 'Kinh doanh trên mạng',
      titleEn: 'An online business',
      sentences: [
        WritingSentence.of(
          'Chị tôi đã mở một cửa hàng trên mạng được sáu tháng.',
          'My sister has run an online shop for six months.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Đơn hàng được đóng gói ngay tại phòng ngủ của chị.',
          'Orders are packed right in her bedroom.',
          G.passive,
        ),
        WritingSentence.of(
          'Kinh doanh trên mạng rẻ hơn thuê một cửa hàng thật.',
          'An online business is cheaper than renting a real shop.',
          G.comparison,
        ),
        WritingSentence.of(
          'Tối qua, trong khi chị ấy đang trả lời khách, có ba đơn hàng mới đến.',
          'Last night, while she was replying to customers, three new orders came in.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Chị ấy đã bán được hơn một nghìn sản phẩm.',
          'She has sold more than a thousand products.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Nếu doanh thu tăng, chị sẽ thuê thêm người.',
          'If sales increase, she will hire more people.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'internet_i7',
      level: _i,
      titleVi: 'Học ngôn ngữ mới qua ứng dụng',
      titleEn: 'A language app',
      sentences: [
        WritingSentence.of(
          'Tôi đã dùng ứng dụng học tiếng Nhật được ba tháng.',
          'I have used a Japanese learning app for three months.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Nó thú vị hơn học từ sách giáo khoa.',
          'It is more interesting than studying from a textbook.',
          G.comparison,
        ),
        WritingSentence.of(
          'Mỗi bài học được thiết kế như một trò chơi nhỏ.',
          'Each lesson is designed like a small game.',
          G.passive,
        ),
        WritingSentence.of(
          'Sáng nay, trong khi tôi đang học, ứng dụng nhắc tôi ôn từ cũ.',
          'This morning, while I was studying, the app reminded me to review old words.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Tôi đã học được hơn năm trăm từ.',
          'I have learned more than five hundred words.',
          G.presentPerfect,
          alternatives: ['I have learnt more than five hundred words.'],
        ),
        WritingSentence.of(
          'Nếu tôi học mỗi ngày, tôi sẽ nói được tiếng Nhật cơ bản trong một năm.',
          'If I study every day, I will speak basic Japanese in a year.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'internet_i8',
      level: _i,
      titleVi: 'Tìm việc trên mạng',
      titleEn: 'Job hunting online',
      sentences: [
        WritingSentence.of(
          'Tôi đã nộp đơn xin việc qua mạng được hai tuần.',
          'I have applied for jobs online for two weeks.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Hồ sơ của tôi được xem bởi nhiều nhà tuyển dụng.',
          'My resume has been viewed by many recruiters.',
          G.passive,
        ),
        WritingSentence.of(
          'Tìm việc trên mạng dễ hơn đi từng công ty hỏi.',
          'Job hunting online is easier than going to companies in person.',
          G.comparison,
        ),
        WritingSentence.of(
          'Hôm qua, trong khi tôi đang cập nhật hồ sơ, tôi nhận được một email phỏng vấn.',
          'Yesterday, while I was updating my resume, I received an interview email.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Tôi chưa bao giờ hồi hộp như vậy.',
          'I have never been so nervous.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Nếu tôi được nhận, tôi sẽ bắt đầu công việc mới vào tháng sau.',
          'If I get the job, I will start next month.',
          G.conditional1,
        ),
      ],
    ),

    // ---------------- Nang cao ----------------
    WritingParagraph(
      id: 'internet_a1',
      level: _a,
      titleVi: 'Thuật toán mạng xã hội',
      titleEn: 'Social media algorithms',
      sentences: [
        WritingSentence.of(
          'Thuật toán, thứ quyết định nội dung chúng ta thấy mỗi ngày, được thiết kế để giữ chân người dùng càng lâu càng tốt.',
          'Algorithms, which decide the content we see every day, are designed to keep users engaged for as long as possible.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Một cựu kỹ sư công nghệ nói rằng anh đã thiết kế những tính năng gây nghiện mà chính anh không dám cho con dùng.',
          'A former tech engineer said that he had designed addictive features that he himself would not let his children use.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Trước khi hiểu điều này, tôi đã dành hàng giờ lướt mạng mà không nhận ra.',
          'Before I understood this, I had spent hours scrolling without realizing it.',
          G.pastPerfect,
          alternatives: [
            'Before I understood this, I had spent hours scrolling without realising it.',
          ],
        ),
        WritingSentence.of(
          'Nếu các nền tảng minh bạch hơn về thuật toán, người dùng sẽ đưa ra lựa chọn tốt hơn.',
          'If platforms were more transparent about their algorithms, users would make better choices.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Một số quốc gia đã và đang xây dựng luật để kiểm soát nội dung gây hại cho trẻ em.',
          'Some countries have been drafting laws to control content harmful to children.',
          G.presentPerfectContinuous,
        ),
        WritingSentence.of(
          'Đến cuối thập kỷ này, quy định về công nghệ có lẽ đã thay đổi hoàn toàn cách các nền tảng vận hành.',
          'By the end of this decade, tech regulations will probably have completely changed how platforms operate.',
          G.futurePerfect,
        ),
      ],
    ),
    WritingParagraph(
      id: 'internet_a2',
      level: _a,
      titleVi: 'Khoảng cách số',
      titleEn: 'The digital divide',
      sentences: [
        WritingSentence.of(
          'Trong khi thanh niên thành phố có Internet tốc độ cao, nhiều trẻ em vùng cao vẫn chưa từng thấy máy tính.',
          'While city youth have high-speed internet, many children in remote areas have never seen a computer.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Trong đại dịch, nhiều học sinh nghèo đã bỏ lỡ hàng tháng học trực tuyến vì không có thiết bị.',
          'During the pandemic, many poor students missed months of online classes because they had no devices.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Một giáo viên kể rằng cô đã đi bộ hàng cây số mỗi ngày để mang bài tập giấy cho học sinh không có mạng.',
          'A teacher told us that she had walked miles every day to bring paper homework to students without internet.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu chính phủ đầu tư vào hạ tầng mạng nông thôn, khoảng cách này sẽ thu hẹp đáng kể.',
          'If the government invested in rural internet infrastructure, this gap would narrow significantly.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Nhiều tổ chức phi lợi nhuận đã và đang tặng máy tính cũ cho các trường học vùng sâu.',
          'Many nonprofits have been donating old computers to schools in remote areas.',
          G.presentPerfectContinuous,
        ),
        WritingSentence.of(
          'Đến khi mọi trẻ em đều được tiếp cận Internet, cơ hội học tập vẫn sẽ chưa thật sự công bằng.',
          'Until every child has internet access, learning opportunities will not truly be equal.',
          G.presentSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'internet_a3',
      level: _a,
      titleVi: 'Danh tính trên mạng',
      titleEn: 'Online identity',
      sentences: [
        WritingSentence.of(
          'Nhiều người xây dựng một hình ảnh hoàn hảo trên mạng khác xa với cuộc sống thật của họ.',
          'Many people build a perfect online image that is very different from their real lives.',
          G.comparison,
        ),
        WritingSentence.of(
          'Một nhà tâm lý học giải thích rằng việc so sánh bản thân với hình ảnh đó có thể gây trầm cảm.',
          'A psychologist explained that comparing yourself to that image could cause depression.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Tôi đã theo dõi một người có ảnh hưởng suốt nhiều năm trước khi nhận ra cuộc sống của cô ấy cũng có khó khăn.',
          'I had followed an influencer for years before I realized her life had struggles too.',
          G.pastPerfect,
          alternatives: [
            'I had followed an influencer for years before I realised her life had struggles too.',
          ],
        ),
        WritingSentence.of(
          'Nếu mọi người chia sẻ cả những khó khăn, mạng xã hội sẽ trở nên chân thực hơn.',
          'If more people shared their struggles too, social media would become more genuine.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Gần đây, tôi đã và đang giảm thời gian so sánh bản thân với người khác trên mạng.',
          'Recently, I have been reducing the time I spend comparing myself to others online.',
          G.presentPerfectContinuous,
        ),
        WritingSentence.of(
          'Danh tính thật của một người, cái mà mạng xã hội thường che giấu, luôn phức tạp hơn một bức ảnh.',
          'A person\'s true identity, which social media often hides, is always more complex than a photo.',
          G.relativeClause,
        ),
      ],
    ),
    WritingParagraph(
      id: 'internet_a4',
      level: _a,
      titleVi: 'Internet vạn vật',
      titleEn: 'The Internet of Things',
      sentences: [
        WritingSentence.of(
          'Internet vạn vật, hệ thống kết nối hàng tỷ thiết bị, đang thay đổi cách chúng ta sống.',
          'The Internet of Things, which connects billions of devices, is changing the way we live.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Ngay cả tủ lạnh và bóng đèn cũng có thể được kết nối với Internet.',
          'Even refrigerators and light bulbs can now be connected to the Internet.',
          G.modal,
        ),
        WritingSentence.of(
          'Một chuyên gia bảo mật cảnh báo rằng những thiết bị này thường dễ bị tấn công hơn máy tính.',
          'A security expert warned that these devices were often easier to hack than computers.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Trước khi hiểu rủi ro, nhiều người đã kết nối mọi thiết bị mà không đặt mật khẩu mạnh.',
          'Before understanding the risks, many people had connected every device without setting strong passwords.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Nếu các nhà sản xuất chú trọng bảo mật hơn, người dùng sẽ an toàn hơn nhiều.',
          'If manufacturers focused more on security, users would be much safer.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Trong tương lai gần, số thiết bị kết nối sẽ vượt xa số người trên Trái Đất.',
          'In the near future, the number of connected devices will have far outnumbered the people on Earth.',
          G.futurePerfect,
        ),
      ],
    ),
    WritingParagraph(
      id: 'internet_a5',
      level: _a,
      titleVi: 'Từ bỏ mạng xã hội',
      titleEn: 'Quitting social media',
      sentences: [
        WritingSentence.of(
          'Một người bạn của tôi, người từng có hàng nghìn người theo dõi, đã xoá hết tài khoản mạng xã hội năm ngoái.',
          'A friend of mine, who once had thousands of followers, deleted all her social media accounts last year.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Cô ấy đã đăng bài mỗi ngày suốt năm năm trước khi quyết định dừng lại.',
          'She had been posting every day for five years before she decided to stop.',
          G.pastPerfectContinuous,
        ),
        WritingSentence.of(
          'Cô nói rằng cô cảm thấy tự do hơn bao giờ hết kể từ khi rời mạng.',
          'She said that she had felt freer than ever since leaving.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu cô ấy không dứt khoát, có lẽ cô đã tiếp tục sống trong áp lực so sánh.',
          'If she had not been decisive, she might have continued living under the pressure of comparison.',
          G.conditional3,
        ),
        WritingSentence.of(
          'Từ khi rời mạng xã hội, cô ấy đã đọc được hơn hai mươi cuốn sách.',
          'Since leaving social media, she has read more than twenty books.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Tuy nhiên, bạn bè của cô đôi khi khó liên lạc hơn trước.',
          'However, her friends sometimes find it harder to reach her than before.',
          G.comparison,
        ),
      ],
    ),
    WritingParagraph(
      id: 'internet_a6',
      level: _a,
      titleVi: 'Học sinh và trí tuệ nhân tạo',
      titleEn: 'Students and AI tools',
      sentences: [
        WritingSentence.of(
          'Nhiều giáo viên lo ngại rằng học sinh đang dùng AI để làm bài thay vì tự suy nghĩ.',
          'Many teachers worry that students are using AI to do their work instead of thinking for themselves.',
          G.presentContinuous,
        ),
        WritingSentence.of(
          'Một học sinh, người từng nộp bài do AI viết hoàn toàn, đã bị phát hiện và phải viết lại.',
          'A student, who once submitted an essay written entirely by AI, was caught and had to redo it.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Cậu ấy thừa nhận rằng cậu đã không đọc lại bài trước khi nộp.',
          'He admitted that he had not read the essay before submitting it.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu trường học dạy học sinh cách dùng AI có trách nhiệm, công cụ này sẽ hữu ích hơn nhiều.',
          'If schools taught students to use AI responsibly, this tool would be much more useful.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Một số giáo viên đã và đang thiết kế lại bài kiểm tra để hạn chế gian lận bằng AI.',
          'Some teachers have been redesigning tests to reduce AI-based cheating.',
          G.presentPerfectContinuous,
        ),
        WritingSentence.of(
          'Đến năm sau, hầu hết các trường sẽ đưa ra quy định rõ ràng về việc dùng AI.',
          'By next year, most schools will have introduced clear rules on using AI.',
          G.futurePerfect,
        ),
      ],
    ),
    WritingParagraph(
      id: 'internet_a7',
      level: _a,
      titleVi: 'Quyền được lãng quên',
      titleEn: 'The right to be forgotten',
      sentences: [
        WritingSentence.of(
          'Những bức ảnh và bài đăng mà chúng ta chia sẻ khi còn nhỏ có thể tồn tại mãi mãi trên mạng.',
          'The photos and posts that we share as children can stay online forever.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Một phụ nữ trẻ đã cố gắng xoá những bức ảnh xấu hổ thời niên thiếu suốt nhiều năm.',
          'A young woman had been trying to delete embarrassing photos from her teenage years for years.',
          G.pastPerfectContinuous,
        ),
        WritingSentence.of(
          'Cô nói rằng nhà tuyển dụng đã tìm thấy chúng trước cả buổi phỏng vấn.',
          'She said that an employer had found them even before the interview.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu luật bảo vệ dữ liệu chặt chẽ hơn, người dùng sẽ dễ dàng xoá quá khứ của mình hơn.',
          'If data protection laws were stricter, users would find it easier to erase their past.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Một số quốc gia châu Âu đã ban hành luật cho phép công dân yêu cầu xoá thông tin cá nhân.',
          'Some European countries have passed laws allowing citizens to request the removal of personal information.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Trước khi đăng bất cứ điều gì, giới trẻ nên nhớ rằng Internet hiếm khi thực sự quên.',
          'Before posting anything, young people should remember that the Internet rarely truly forgets.',
          G.modal,
        ),
      ],
    ),
    WritingParagraph(
      id: 'internet_a8',
      level: _a,
      titleVi: 'Cộng đồng trực tuyến',
      titleEn: 'Online communities',
      sentences: [
        WritingSentence.of(
          'Diễn đàn nơi tôi tham gia, dành cho những người mắc bệnh hiếm, đã giúp tôi cảm thấy bớt cô đơn.',
          'The forum I joined, which is for people with rare diseases, has helped me feel less alone.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Trước khi tìm thấy nhóm này, tôi chưa từng gặp ai có cùng tình trạng như mình.',
          'Before finding this group, I had never met anyone with the same condition as me.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Một thành viên kể rằng cộng đồng này đã cứu cô khỏi những ngày tồi tệ nhất.',
          'A member told me that this community had saved her during her worst days.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu không có Internet, những người như chúng tôi sẽ khó tìm thấy nhau đến vậy.',
          'Without the Internet, people like us would find it much harder to find each other.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Chúng tôi đã và đang chia sẻ kinh nghiệm điều trị với nhau suốt ba năm qua.',
          'We have been sharing treatment experiences with each other for the past three years.',
          G.presentPerfectContinuous,
        ),
        WritingSentence.of(
          'Tôi tin rằng những cộng đồng như thế này chứng minh Internet có thể mang lại điều tốt đẹp.',
          'I believe communities like this prove that the Internet can bring real good.',
          G.modal,
        ),
      ],
    ),
  ],
);
