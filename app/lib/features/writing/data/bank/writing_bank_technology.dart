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

const kWritingBankTechnology = WritingTopic(
  id: 'technology',
  titleVi: 'Công nghệ',
  titleEn: 'Technology',
  icon: Icons.devices_rounded,
  color: AppColors.purple,
  paragraphs: [
    // ---------------- Co ban ----------------
    WritingParagraph(
      id: 'technology_b1',
      level: _b,
      titleVi: 'Điện thoại của tôi',
      titleEn: 'My phone',
      sentences: [
        WritingSentence.of(
          'Tôi có một chiếc điện thoại mới.',
          'I have a new phone.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Nó rất nhanh.',
          'It is very fast.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tôi dùng nó để nghe nhạc.',
          'I use it to listen to music.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tôi có thể chụp ảnh đẹp.',
          'I can take nice photos.',
          G.modal,
        ),
        WritingSentence.of(
          'Tôi sạc pin mỗi tối.',
          'I charge the battery every night.',
          G.presentSimple,
          alternatives: ['I charge my phone every night.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'technology_b2',
      level: _b,
      titleVi: 'Cả nhà dùng công nghệ',
      titleEn: 'A family of gadgets',
      sentences: [
        WritingSentence.of(
          'Bố tôi có một chiếc máy tính xách tay.',
          'My father has a laptop.',
          G.presentSimple,
          alternatives: ['My dad has a laptop.'],
        ),
        WritingSentence.of(
          'Bố đang viết email.',
          'He is writing an email.',
          G.presentContinuous,
        ),
        WritingSentence.of(
          'Em trai tôi đang chơi trò chơi trên máy tính bảng.',
          'My brother is playing a game on the tablet.',
          G.presentContinuous,
          alternatives: ['My younger brother is playing a game on the tablet.'],
        ),
        WritingSentence.of(
          'Mẹ tôi đang đọc tin tức trên điện thoại.',
          'My mother is reading the news on her phone.',
          G.presentContinuous,
          alternatives: ['My mom is reading the news on her phone.'],
        ),
        WritingSentence.of(
          'Mọi người trong nhà tôi đều dùng công nghệ.',
          'Everyone in my family uses technology.',
          G.presentSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'technology_b3',
      level: _b,
      titleVi: 'Robot hút bụi',
      titleEn: 'A robot vacuum',
      sentences: [
        WritingSentence.of(
          'Tuần trước, bố mẹ tôi đã mua một robot hút bụi.',
          'Last week, my parents bought a robot vacuum.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Nó tự dọn nhà.',
          'It cleans the house by itself.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Con mèo đã sợ nó.',
          'The cat was afraid of it.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Hôm qua, nó bị kẹt dưới gầm giường.',
          'Yesterday, it got stuck under the bed.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Tôi đã giúp nó ra ngoài.',
          'I helped it get out.',
          G.pastSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'technology_b4',
      level: _b,
      titleVi: 'Ti vi thông minh',
      titleEn: 'A smart TV',
      sentences: [
        WritingSentence.of(
          'Nhà tôi có một chiếc ti vi thông minh.',
          'We have a smart TV at home.',
          G.presentSimple,
          alternatives: ['My family has a smart TV.'],
        ),
        WritingSentence.of(
          'Tôi có thể xem phim trên đó.',
          'I can watch films on it.',
          G.modal,
          alternatives: ['I can watch movies on it.'],
        ),
        WritingSentence.of(
          'Tôi có thể nói chuyện với nó.',
          'I can talk to it.',
          G.modal,
        ),
        WritingSentence.of(
          'Tối nay, chúng tôi sẽ xem bóng đá.',
          'Tonight, we will watch football.',
          G.futureSimple,
          alternatives: [
            'Tonight, we will watch a football match.',
            'Tonight, we will watch soccer.',
          ],
        ),
        WritingSentence.of(
          'Bố tôi sẽ rất vui.',
          'My father will be very happy.',
          G.futureSimple,
          alternatives: ['My dad will be very happy.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'technology_b5',
      level: _b,
      titleVi: 'Học trực tuyến',
      titleEn: 'Online classes',
      sentences: [
        WritingSentence.of(
          'Tôi học tiếng Anh trực tuyến.',
          'I study English online.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Lớp học bắt đầu lúc bảy giờ tối.',
          'The class starts at seven in the evening.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Giáo viên của tôi sống ở Úc.',
          'My teacher lives in Australia.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Chúng tôi nói chuyện qua máy tính.',
          'We talk on the computer.',
          G.presentSimple,
          alternatives: ['We talk through the computer.'],
        ),
        WritingSentence.of(
          'Tôi phải bật camera.',
          'I must turn on my camera.',
          G.modal,
          alternatives: ['I have to turn on my camera.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'technology_b6',
      level: _b,
      titleVi: 'Tai nghe mới',
      titleEn: 'New headphones',
      sentences: [
        WritingSentence.of(
          'Tôi định mua tai nghe mới.',
          'I am going to buy new headphones.',
          G.goingTo,
        ),
        WritingSentence.of(
          'Tai nghe cũ của tôi bị hỏng.',
          'My old headphones are broken.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tôi muốn tai nghe không dây.',
          'I want wireless headphones.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Chúng sẽ không rẻ.',
          'They will not be cheap.',
          G.futureSimple,
          alternatives: ['They won\'t be cheap.'],
        ),
        WritingSentence.of(
          'Tôi sẽ tiết kiệm tiền.',
          'I will save money.',
          G.futureSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'technology_b7',
      level: _b,
      titleVi: 'Máy ảnh của ông',
      titleEn: 'Grandpa\'s camera',
      sentences: [
        WritingSentence.of(
          'Ông tôi có một chiếc máy ảnh cũ.',
          'My grandfather has an old camera.',
          G.presentSimple,
          alternatives: ['My grandpa has an old camera.'],
        ),
        WritingSentence.of(
          'Nó không dùng thẻ nhớ.',
          'It does not use a memory card.',
          G.presentSimple,
          alternatives: ['It doesn\'t use a memory card.'],
        ),
        WritingSentence.of(
          'Ngày xưa ông chụp ảnh bằng phim.',
          'He took photos on film.',
          G.pastSimple,
          alternatives: [
            'He took pictures on film.',
            'He took photos with film.',
          ],
        ),
        WritingSentence.of(
          'Bây giờ ông dùng điện thoại.',
          'Now he uses his phone.',
          G.presentSimple,
          alternatives: ['Now he uses a phone.'],
        ),
        WritingSentence.of(
          'Ông vẫn giữ chiếc máy ảnh cũ.',
          'He still keeps the old camera.',
          G.presentSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'technology_b8',
      level: _b,
      titleVi: 'Dùng điện thoại quá nhiều',
      titleEn: 'Too much screen time',
      sentences: [
        WritingSentence.of(
          'Em gái tôi dùng điện thoại cả ngày.',
          'My sister uses her phone all day.',
          G.presentSimple,
          alternatives: ['My younger sister uses her phone all day.'],
        ),
        WritingSentence.of(
          'Mắt em ấy hay bị đau.',
          'Her eyes often hurt.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Em ấy nên ra ngoài chơi.',
          'She should play outside.',
          G.modal,
        ),
        WritingSentence.of(
          'Mẹ tôi sẽ cất điện thoại vào buổi tối.',
          'My mother will put the phone away in the evening.',
          G.futureSimple,
          alternatives: ['My mom will put the phone away in the evening.'],
        ),
        WritingSentence.of(
          'Chúng ta phải cho đôi mắt nghỉ ngơi.',
          'We must rest our eyes.',
          G.modal,
          alternatives: ['We have to rest our eyes.'],
        ),
      ],
    ),

    // ---------------- Trung cap ----------------
    WritingParagraph(
      id: 'technology_i1',
      level: _i,
      titleVi: 'Chiếc điện thoại đầu tiên',
      titleEn: 'My first smartphone',
      sentences: [
        WritingSentence.of(
          'Tôi có chiếc điện thoại thông minh đầu tiên khi mười hai tuổi.',
          'I got my first smartphone when I was twelve.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Nó chậm hơn điện thoại bây giờ rất nhiều.',
          'It was much slower than today\'s phones.',
          G.comparison,
        ),
        WritingSentence.of(
          'Kể từ đó, tôi đã dùng nhiều điện thoại khác nhau.',
          'I have used many different phones since then.',
          G.presentPerfect,
          alternatives: ['Since then, I have used many different phones.'],
        ),
        WritingSentence.of(
          'Một lần, trong khi tôi đang gọi điện, nó rơi xuống hồ.',
          'Once, while I was making a call, it fell into a lake.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Chiếc điện thoại đó được bố tôi sửa lại.',
          'That phone was repaired by my father.',
          G.passive,
          alternatives: ['That phone was fixed by my dad.'],
        ),
        WritingSentence.of(
          'Nếu tìm thấy nó, tôi sẽ giữ lại làm kỷ niệm.',
          'If I find it, I will keep it as a souvenir.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'technology_i2',
      level: _i,
      titleVi: 'Ngôi nhà thông minh',
      titleEn: 'A smart home',
      sentences: [
        WritingSentence.of(
          'Chú tôi vừa lắp hệ thống nhà thông minh.',
          'My uncle has just installed a smart home system.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Đèn được bật bằng giọng nói.',
          'The lights are turned on by voice.',
          G.passive,
          alternatives: ['The lights are switched on by voice.'],
        ),
        WritingSentence.of(
          'Nhà của chú hiện đại hơn nhà tôi nhiều.',
          'His house is much more modern than mine.',
          G.comparison,
        ),
        WritingSentence.of(
          'Tối qua, khi chúng tôi đang ăn tối, chiếc loa tự bật nhạc.',
          'Last night, while we were having dinner, the speaker played music by itself.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Đó là điều kỳ lạ nhất tôi từng thấy.',
          'It was the strangest thing I have ever seen.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nếu nhà tôi lắp thiết bị như vậy, bà tôi sẽ không biết cách dùng.',
          'If we get devices like that, my grandmother will not know how to use them.',
          G.conditional1,
          alternatives: [
            'If we get devices like that, my grandma won\'t know how to use them.',
          ],
        ),
      ],
    ),
    WritingParagraph(
      id: 'technology_i3',
      level: _i,
      titleVi: 'Máy tính bị lỗi',
      titleEn: 'A computer problem',
      sentences: [
        WritingSentence.of(
          'Hôm qua, máy tính của tôi đột nhiên ngừng hoạt động.',
          'Yesterday, my computer suddenly stopped working.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Tôi đang viết bài luận thì màn hình chuyển sang màu đen.',
          'I was writing an essay when the screen went black.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Tôi đã mất ba trang bài viết.',
          'I lost three pages of work.',
          G.pastSimple,
          alternatives: ['I lost three pages of writing.'],
        ),
        WritingSentence.of(
          'Máy tính được mang đến tiệm sửa chữa.',
          'The computer was taken to a repair shop.',
          G.passive,
        ),
        WritingSentence.of(
          'Tôi đã học được một bài học quan trọng.',
          'I have learned an important lesson.',
          G.presentPerfect,
          alternatives: ['I have learnt an important lesson.'],
        ),
        WritingSentence.of(
          'Nếu tôi lưu bài thường xuyên, tôi sẽ không mất dữ liệu nữa.',
          'If I save my work often, I will not lose data again.',
          G.conditional1,
          alternatives: ['If I save my work often, I won\'t lose data again.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'technology_i4',
      level: _i,
      titleVi: 'Xe máy điện',
      titleEn: 'Electric motorbikes',
      sentences: [
        WritingSentence.of(
          'Ngày càng nhiều người mua xe máy điện.',
          'More and more people are buying electric motorbikes.',
          G.presentContinuous,
        ),
        WritingSentence.of(
          'Xe điện êm hơn xe máy thường.',
          'Electric motorbikes are quieter than normal ones.',
          G.comparison,
          alternatives: [
            'Electric motorbikes are quieter than ordinary motorbikes.',
          ],
        ),
        WritingSentence.of(
          'Chị tôi đã đi xe điện được một năm.',
          'My sister has ridden an electric motorbike for a year.',
          G.presentPerfect,
          alternatives: ['My sister has had an electric motorbike for a year.'],
        ),
        WritingSentence.of(
          'Pin được sạc ở nhà mỗi đêm.',
          'The battery is charged at home every night.',
          G.passive,
          alternatives: ['The battery is charged every night at home.'],
        ),
        WritingSentence.of(
          'Tuần trước, trong khi chị ấy đang đi làm, xe hết pin.',
          'Last week, while she was riding to work, the battery ran out.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Nếu có thêm trạm sạc, xe điện sẽ phổ biến hơn.',
          'If there are more charging stations, electric bikes will be more popular.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'technology_i5',
      level: _i,
      titleVi: 'Ứng dụng học tiếng Anh',
      titleEn: 'A language learning app',
      sentences: [
        WritingSentence.of(
          'Tôi đã dùng ứng dụng này được ba tháng.',
          'I have used this app for three months.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Nó thú vị hơn sách giáo khoa.',
          'It is more interesting than a textbook.',
          G.comparison,
        ),
        WritingSentence.of(
          'Mỗi bài học được thiết kế như một trò chơi.',
          'Every lesson is designed like a game.',
          G.passive,
        ),
        WritingSentence.of(
          'Tối qua, khi tôi đang học, ứng dụng nhắc tôi luyện phát âm.',
          'Last night, while I was studying, the app reminded me to practice pronunciation.',
          G.pastContinuous,
          alternatives: [
            'Last night, while I was studying, the app reminded me to practise pronunciation.',
          ],
        ),
        WritingSentence.of(
          'Phát âm là phần khó nhất với tôi.',
          'Pronunciation is the hardest part for me.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nếu tôi học mỗi ngày, tôi sẽ tiến bộ nhanh hơn.',
          'If I study every day, I will improve faster.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'technology_i6',
      level: _i,
      titleVi: 'Đồng hồ thông minh',
      titleEn: 'A smartwatch',
      sentences: [
        WritingSentence.of(
          'Bố tôi được tặng một chiếc đồng hồ thông minh.',
          'My father was given a smartwatch.',
          G.passive,
          alternatives: ['My dad was given a smartwatch.'],
        ),
        WritingSentence.of(
          'Nó đếm số bước bố đi mỗi ngày.',
          'It counts his steps every day.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Từ khi có nó, bố đã đi bộ nhiều hơn.',
          'He has walked more since he got it.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Sáng nay, trong khi bố đang chạy bộ, đồng hồ cảnh báo về nhịp tim.',
          'This morning, while he was jogging, the watch warned him about his heart rate.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Đồng hồ thông minh hữu ích hơn tôi nghĩ.',
          'Smartwatches are more useful than I thought.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nếu thấy mệt, bố sẽ đi khám bác sĩ.',
          'If he feels tired, he will see a doctor.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'technology_i7',
      level: _i,
      titleVi: 'Thực tế ảo',
      titleEn: 'Virtual reality',
      sentences: [
        WritingSentence.of(
          'Cuối tuần trước, tôi đã thử kính thực tế ảo lần đầu tiên.',
          'Last weekend, I tried a virtual reality headset for the first time.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Trải nghiệm đó thú vị hơn tôi mong đợi.',
          'The experience was more exciting than I expected.',
          G.comparison,
        ),
        WritingSentence.of(
          'Trong khi tôi đang chơi, tôi đã đi thẳng vào tường.',
          'While I was playing, I walked into a wall.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Trò chơi được làm bởi một công ty Việt Nam.',
          'The game was made by a Vietnamese company.',
          G.passive,
          alternatives: ['The game was created by a Vietnamese company.'],
        ),
        WritingSentence.of(
          'Tôi chưa bao giờ thấy thứ gì chân thực như vậy.',
          'I have never seen anything so realistic.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Nếu giá giảm, tôi sẽ mua một chiếc.',
          'If the price goes down, I will buy one.',
          G.conditional1,
          alternatives: ['If it gets cheaper, I will buy one.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'technology_i8',
      level: _i,
      titleVi: 'Câu lạc bộ robot',
      titleEn: 'The robotics club',
      sentences: [
        WritingSentence.of(
          'Trường tôi vừa mở một câu lạc bộ robot.',
          'My school has just opened a robotics club.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Mỗi nhóm được phát một bộ linh kiện.',
          'Each group is given a kit of parts.',
          G.passive,
        ),
        WritingSentence.of(
          'Nhóm tôi đã chế tạo được hai robot nhỏ.',
          'My group has built two small robots.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Robot của chúng tôi chậm hơn robot của nhóm khác.',
          'Our robot is slower than the other group\'s robot.',
          G.comparison,
        ),
        WritingSentence.of(
          'Hôm qua, trong khi chúng tôi đang thử nghiệm, robot đâm vào bàn giáo viên.',
          'Yesterday, while we were testing it, our robot crashed into the teacher\'s desk.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Nếu chúng tôi thắng cuộc thi, trường sẽ mua thêm linh kiện.',
          'If we win the competition, the school will buy more parts.',
          G.conditional1,
        ),
      ],
    ),

    // ---------------- Nang cao ----------------
    WritingParagraph(
      id: 'technology_a1',
      level: _a,
      titleVi: 'AI trong đời sống',
      titleEn: 'AI in everyday life',
      sentences: [
        WritingSentence.of(
          'Trí tuệ nhân tạo, thứ từng chỉ xuất hiện trong phim, giờ có mặt trong hầu hết điện thoại.',
          'Artificial intelligence, which once only appeared in films, is now in almost every phone.',
          G.relativeClause,
          alternatives: [
            'Artificial intelligence, which once only appeared in movies, is now in almost every phone.',
          ],
        ),
        WritingSentence.of(
          'Các nhà khoa học đã và đang phát triển AI trong hơn nửa thế kỷ.',
          'Scientists have been developing AI for more than half a century.',
          G.presentPerfectContinuous,
        ),
        WritingSentence.of(
          'Tôi đã dùng trợ lý ảo cả năm trước khi nhận ra nó ghi lại mọi điều tôi nói.',
          'I had been using a virtual assistant for a year before I realized it recorded everything I said.',
          G.pastPerfectContinuous,
          alternatives: [
            'I had been using a virtual assistant for a year before I realised it recorded everything I said.',
          ],
        ),
        WritingSentence.of(
          'Một chuyên gia bảo mật nói rằng người dùng nên đọc kỹ chính sách quyền riêng tư.',
          'A security expert said that users should read privacy policies carefully.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu mọi người hiểu rõ hơn về dữ liệu của mình, họ sẽ cẩn thận hơn với các ứng dụng.',
          'If people understood their data better, they would be more careful with apps.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Đến cuối thập kỷ này, có lẽ AI sẽ thay đổi gần như mọi ngành nghề.',
          'By the end of this decade, AI will probably have changed almost every industry.',
          G.futurePerfect,
        ),
      ],
    ),
    WritingParagraph(
      id: 'technology_a2',
      level: _a,
      titleVi: 'Một tuần không điện thoại',
      titleEn: 'A week without my phone',
      sentences: [
        WritingSentence.of(
          'Tháng trước, tôi quyết định không dùng điện thoại thông minh trong một tuần.',
          'Last month, I decided not to use my smartphone for a week.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Trước đó, tôi đã kiểm tra điện thoại hơn một trăm lần mỗi ngày.',
          'Before that, I had checked my phone more than a hundred times a day.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Những ngày đầu khó khăn hơn tôi tưởng rất nhiều.',
          'The first few days were much harder than I had imagined.',
          G.comparison,
        ),
        WritingSentence.of(
          'Bạn bè hỏi tôi liệu tôi có thấy bị cô lập không.',
          'My friends asked me whether I felt isolated.',
          G.reportedSpeech,
          alternatives: ['My friends asked me if I felt isolated.'],
        ),
        WritingSentence.of(
          'Nếu không thử, tôi đã không nhận ra mình phụ thuộc vào công nghệ đến mức nào.',
          'If I had not tried it, I would not have realized how dependent I was on technology.',
          G.conditional3,
          alternatives: [
            'If I had not tried it, I would not have realised how dependent I was on technology.',
          ],
        ),
        WritingSentence.of(
          'Giờ tôi để điện thoại bên ngoài phòng ngủ mỗi đêm.',
          'Now I leave my phone outside the bedroom every night.',
          G.presentSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'technology_a3',
      level: _a,
      titleVi: 'Rác thải điện tử',
      titleEn: 'Electronic waste',
      sentences: [
        WritingSentence.of(
          'Mỗi năm, hàng triệu chiếc điện thoại cũ bị vứt bỏ trên khắp thế giới.',
          'Every year, millions of old phones are thrown away around the world.',
          G.passive,
        ),
        WritingSentence.of(
          'Nhiều thiết bị chứa kim loại độc hại có thể làm ô nhiễm đất và nước.',
          'Many devices contain toxic metals that can pollute soil and water.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Tôi đã giữ ba chiếc điện thoại hỏng trong ngăn kéo suốt nhiều năm.',
          'I have kept three broken phones in a drawer for years.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Một nhân viên cửa hàng giải thích rằng họ có thể tái chế linh kiện bên trong.',
          'A shop assistant explained that they could recycle the parts inside.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu các hãng làm điện thoại dễ sửa hơn, người dùng sẽ không phải thay máy thường xuyên.',
          'If companies made phones easier to repair, people would not need to replace them so often.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Thành phố tôi đã và đang mở thêm các điểm thu gom rác điện tử.',
          'My city has been opening more collection points for electronic waste.',
          G.presentPerfectContinuous,
        ),
      ],
    ),
    WritingParagraph(
      id: 'technology_a4',
      level: _a,
      titleVi: 'Làm việc cùng robot',
      titleEn: 'Working alongside robots',
      sentences: [
        WritingSentence.of(
          'Nhà máy nơi dì tôi làm việc đã lắp đặt hàng chục robot vào năm ngoái.',
          'The factory where my aunt works installed dozens of robots last year.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Trước khi có robot, công nhân đã phải làm những việc nặng nhọc hàng giờ liền.',
          'Before the robots arrived, workers had done heavy tasks for hours.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Dì kể rằng lúc đầu mọi người đã sợ bị mất việc.',
          'My aunt said that at first people had been afraid of losing their jobs.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Thật ra, nhiều công nhân đã được đào tạo để vận hành và bảo trì robot.',
          'In fact, many workers have been trained to operate and maintain the robots.',
          G.passive,
        ),
        WritingSentence.of(
          'Nếu nhà máy không đầu tư vào công nghệ, có lẽ nó đã phải đóng cửa.',
          'If the factory had not invested in technology, it might have had to close.',
          G.conditional3,
        ),
        WritingSentence.of(
          'Vào giờ này năm sau, dì tôi sẽ đang quản lý cả một dây chuyền tự động.',
          'This time next year, my aunt will be managing a whole automated production line.',
          G.futureContinuous,
        ),
      ],
    ),
    WritingParagraph(
      id: 'technology_a5',
      level: _a,
      titleVi: 'Xe tự lái',
      titleEn: 'Driverless cars',
      sentences: [
        WritingSentence.of(
          'Xe tự lái, thứ nghe như khoa học viễn tưởng mười năm trước, giờ đã chạy trên đường ở nhiều nước.',
          'Driverless cars, which sounded like science fiction ten years ago, are now on the roads in many countries.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Những chiếc xe này được điều khiển bằng camera, cảm biến và phần mềm phức tạp.',
          'These cars are controlled by cameras, sensors and complex software.',
          G.passive,
        ),
        WritingSentence.of(
          'Khi tôi đi thử một chiếc ở Singapore, tôi đã tự lái xe được mười năm.',
          'When I tried one in Singapore, I had been driving myself for ten years.',
          G.pastPerfectContinuous,
        ),
        WritingSentence.of(
          'Người kỹ sư đi cùng nói rằng hệ thống an toàn hơn phần lớn tài xế.',
          'The engineer with us said that the system was safer than most drivers.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu giao thông ở Việt Nam trật tự hơn, xe tự lái có thể hoạt động ở đây.',
          'If traffic in Vietnam were more orderly, driverless cars could work here.',
          G.conditional2,
          alternatives: [
            'If traffic in Vietnam was more orderly, driverless cars could work here.',
          ],
        ),
        WritingSentence.of(
          'Dù vậy, tôi vẫn thích tự mình cầm lái hơn.',
          'Even so, I still prefer to drive myself.',
          G.presentSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'technology_a6',
      level: _a,
      titleVi: 'Bà tôi học gọi video',
      titleEn: 'Grandma goes digital',
      sentences: [
        WritingSentence.of(
          'Bà tôi, người chưa từng dùng máy tính, vừa học cách gọi video cho các cháu.',
          'My grandmother, who had never used a computer, has just learned to make video calls to her grandchildren.',
          G.relativeClause,
          alternatives: [
            'My grandmother, who had never used a computer, has just learnt to make video calls to her grandchildren.',
          ],
        ),
        WritingSentence.of(
          'Suốt hai tháng qua, cuối tuần nào tôi cũng dạy bà.',
          'I have been teaching her every weekend for the past two months.',
          G.presentPerfectContinuous,
        ),
        WritingSentence.of(
          'Lúc đầu, bà nói rằng công nghệ quá phức tạp với người ở tuổi bà.',
          'At first, she said that technology was too complicated for someone her age.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu các ứng dụng được thiết kế đơn giản hơn, nhiều người cao tuổi sẽ tự tin sử dụng chúng.',
          'If apps were designed more simply, many older people would use them confidently.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Giờ đây, gần như ngày nào bà cũng gọi cho chú tôi ở Đức.',
          'Now she calls my uncle in Germany almost every day.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Đến Tết năm nay, bà sẽ tự đặt được vé tàu trên mạng.',
          'By Tet this year, she will be able to book train tickets online by herself.',
          G.futureSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'technology_a7',
      level: _a,
      titleVi: 'Điện mặt trời',
      titleEn: 'Solar power at home',
      sentences: [
        WritingSentence.of(
          'Mùa hè năm ngoái, gia đình tôi đã lắp tấm pin mặt trời trên mái nhà.',
          'My family installed solar panels on our roof last summer.',
          G.pastSimple,
          alternatives: [
            'Last summer, my family installed solar panels on our roof.',
          ],
        ),
        WritingSentence.of(
          'Kể từ đó, hoá đơn tiền điện của chúng tôi đã giảm gần một nửa.',
          'Since then, our electricity bill has fallen by almost half.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Bố tôi, người rất quan tâm đến môi trường, đã tìm hiểu công nghệ này nhiều tháng trước khi lắp.',
          'My father, who cares a lot about the environment, had researched this technology for months before installing it.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Người thợ nói rằng hệ thống có thể hoạt động ít nhất hai mươi năm.',
          'The technician said that the system could work for at least twenty years.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu nhiều gia đình dùng điện mặt trời, thành phố sẽ bớt phụ thuộc vào than đá.',
          'If more families used solar power, the city would depend less on coal.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Đến cuối năm sau, số tiền đầu tư cho các tấm pin sẽ được thu hồi đủ.',
          'By the end of next year, the panels will have paid for themselves.',
          G.futurePerfect,
        ),
      ],
    ),
    WritingParagraph(
      id: 'technology_a8',
      level: _a,
      titleVi: 'Công nghệ trong lớp học',
      titleEn: 'Technology in the classroom',
      sentences: [
        WritingSentence.of(
          'Trong vài năm qua, nhiều trường học đã thay bảng đen bằng màn hình thông minh.',
          'Many schools have replaced blackboards with smart screens over the past few years.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Cô giáo tôi, người đã dạy hơn hai mươi năm, phải học lại cách soạn bài.',
          'My teacher, who has taught for over twenty years, had to learn how to prepare lessons again.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Cô thừa nhận rằng lúc đầu cô đã rất lo lắng.',
          'She admitted that she had felt very nervous at first.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Một số phụ huynh cho rằng học sinh đang dành quá nhiều thời gian trước màn hình.',
          'Some parents believe that students are spending too much time in front of screens.',
          G.presentContinuous,
        ),
        WritingSentence.of(
          'Nếu công nghệ được dùng hợp lý, nó có thể giúp học sinh học hiệu quả hơn.',
          'If technology is used wisely, it can help students learn more effectively.',
          G.conditional1,
        ),
        WritingSentence.of(
          'Trong tương lai, sách giáo khoa giấy có thể sẽ bị thay thế hoàn toàn.',
          'In the future, paper textbooks may be completely replaced.',
          G.passive,
        ),
      ],
    ),
  ],
);
