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

const kWritingBankEducation = WritingTopic(
  id: 'education',
  titleVi: 'Học tập',
  titleEn: 'School & Education',
  icon: Icons.school_rounded,
  color: AppColors.blue,
  paragraphs: [
    // ---------------- Co ban ----------------
    WritingParagraph(
      id: 'education_b1',
      level: _b,
      titleVi: 'Trường của tôi',
      titleEn: 'My school',
      sentences: [
        WritingSentence.of(
          'Trường của tôi rất lớn.',
          'My school is very big.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Nó có một thư viện và một sân bóng.',
          'It has a library and a football field.',
          G.presentSimple,
          alternatives: ['It has a library and a soccer field.'],
        ),
        WritingSentence.of(
          'Lớp tôi có ba mươi học sinh.',
          'My class has thirty students.',
          G.presentSimple,
          alternatives: ['There are thirty students in my class.'],
        ),
        WritingSentence.of(
          'Cô giáo của tôi rất tốt bụng.',
          'My teacher is very kind.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tôi yêu trường của tôi.',
          'I love my school.',
          G.presentSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'education_b2',
      level: _b,
      titleVi: 'Trong lớp học',
      titleEn: 'In the classroom',
      sentences: [
        WritingSentence.of(
          'Bây giờ là giờ học toán.',
          'Now it is math class.',
          G.presentSimple,
          alternatives: ['It is maths class now.', 'Now it is maths class.'],
        ),
        WritingSentence.of(
          'Thầy giáo đang viết lên bảng.',
          'The teacher is writing on the board.',
          G.presentContinuous,
        ),
        WritingSentence.of(
          'Chúng tôi đang chép bài.',
          'We are copying the lesson.',
          G.presentContinuous,
          alternatives: ['We are taking notes.'],
        ),
        WritingSentence.of(
          'Bạn tôi đang giơ tay.',
          'My friend is raising his hand.',
          G.presentContinuous,
          alternatives: ['My friend is putting up his hand.'],
        ),
        WritingSentence.of(
          'Cậu ấy muốn hỏi một câu hỏi.',
          'He wants to ask a question.',
          G.presentSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'education_b3',
      level: _b,
      titleVi: 'Môn học yêu thích',
      titleEn: 'My favorite subject',
      sentences: [
        WritingSentence.of(
          'Môn học yêu thích của tôi là tiếng Anh.',
          'My favorite subject is English.',
          G.presentSimple,
          alternatives: ['My favourite subject is English.'],
        ),
        WritingSentence.of(
          'Tôi học tiếng Anh ba lần một tuần.',
          'I study English three times a week.',
          G.presentSimple,
          alternatives: ['I have English three times a week.'],
        ),
        WritingSentence.of(
          'Tôi có thể hát nhiều bài hát tiếng Anh.',
          'I can sing many English songs.',
          G.modal,
        ),
        WritingSentence.of(
          'Tôi không thích môn hoá học.',
          'I do not like chemistry.',
          G.presentSimple,
          alternatives: ['I don\'t like chemistry.'],
        ),
        WritingSentence.of(
          'Nó rất khó.',
          'It is very difficult.',
          G.presentSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'education_b4',
      level: _b,
      titleVi: 'Bài kiểm tra',
      titleEn: 'The test',
      sentences: [
        WritingSentence.of(
          'Hôm qua chúng tôi đã làm bài kiểm tra.',
          'We had a test yesterday.',
          G.pastSimple,
          alternatives: ['Yesterday we had a test.'],
        ),
        WritingSentence.of(
          'Bài kiểm tra khá dễ.',
          'The test was quite easy.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Tôi đã làm xong sớm.',
          'I finished early.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Tôi đã được chín điểm.',
          'I got nine points.',
          G.pastSimple,
          alternatives: ['I got a nine.'],
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
      id: 'education_b5',
      level: _b,
      titleVi: 'Năm học mới',
      titleEn: 'A new school year',
      sentences: [
        WritingSentence.of(
          'Tuần sau là năm học mới.',
          'Next week is the new school year.',
          G.presentSimple,
          alternatives: ['The new school year starts next week.'],
        ),
        WritingSentence.of(
          'Tôi định mua sách vở mới.',
          'I am going to buy new books.',
          G.goingTo,
          alternatives: ['I am going to buy new books and notebooks.'],
        ),
        WritingSentence.of(
          'Mẹ tôi sẽ mua cho tôi một chiếc cặp.',
          'My mother will buy me a school bag.',
          G.futureSimple,
          alternatives: ['My mom will buy me a schoolbag.'],
        ),
        WritingSentence.of(
          'Tôi sẽ gặp lại bạn bè.',
          'I will see my friends again.',
          G.futureSimple,
        ),
        WritingSentence.of(
          'Tôi rất hào hứng.',
          'I am very excited.',
          G.presentSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'education_b6',
      level: _b,
      titleVi: 'Làm bài tập về nhà',
      titleEn: 'Homework',
      sentences: [
        WritingSentence.of(
          'Tối nào tôi cũng làm bài tập về nhà.',
          'I do my homework every evening.',
          G.presentSimple,
          alternatives: ['I do my homework every night.'],
        ),
        WritingSentence.of(
          'Tối nay tôi có nhiều bài tập.',
          'I have a lot of homework tonight.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Bây giờ tôi đang học từ mới.',
          'Now I am learning new words.',
          G.presentContinuous,
          alternatives: ['I am learning new words now.'],
        ),
        WritingSentence.of(
          'Chị tôi đang giúp tôi.',
          'My sister is helping me.',
          G.presentContinuous,
        ),
        WritingSentence.of(
          'Tôi phải làm xong trước mười giờ.',
          'I must finish before ten o\'clock.',
          G.modal,
          alternatives: ['I have to finish before ten.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'education_b7',
      level: _b,
      titleVi: 'Chuyến tham quan',
      titleEn: 'A school trip',
      sentences: [
        WritingSentence.of(
          'Tuần trước lớp tôi đã đi thăm bảo tàng.',
          'Last week my class visited a museum.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Chúng tôi đã đi bằng xe buýt.',
          'We went by bus.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Chúng tôi đã xem nhiều đồ vật cổ.',
          'We saw many old things.',
          G.pastSimple,
          alternatives: ['We saw many old objects.'],
        ),
        WritingSentence.of(
          'Hướng dẫn viên đã kể nhiều câu chuyện.',
          'The guide told us many stories.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Tôi đã học được nhiều điều.',
          'I learned a lot.',
          G.pastSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'education_b8',
      level: _b,
      titleVi: 'Giờ ra chơi',
      titleEn: 'Break time',
      sentences: [
        WritingSentence.of(
          'Giờ ra chơi bắt đầu lúc chín giờ.',
          'Break time starts at nine o\'clock.',
          G.presentSimple,
          alternatives: ['Break time starts at nine.'],
        ),
        WritingSentence.of(
          'Các bạn nam đang chơi đá cầu.',
          'The boys are playing shuttlecock.',
          G.presentContinuous,
        ),
        WritingSentence.of(
          'Các bạn nữ đang nhảy dây.',
          'The girls are skipping rope.',
          G.presentContinuous,
          alternatives: ['The girls are jumping rope.'],
        ),
        WritingSentence.of(
          'Tôi đang ăn bánh mì.',
          'I am eating bread.',
          G.presentContinuous,
        ),
        WritingSentence.of(
          'Chúng tôi phải về lớp lúc chín giờ hai mươi.',
          'We must go back to class at nine twenty.',
          G.modal,
          alternatives: ['We have to go back to class at nine twenty.'],
        ),
      ],
    ),

    // ---------------- Trung cap ----------------
    WritingParagraph(
      id: 'education_i1',
      level: _i,
      titleVi: 'Kỳ thi quan trọng',
      titleEn: 'An important exam',
      sentences: [
        WritingSentence.of(
          'Kỳ thi vào lớp mười là kỳ thi khó nhất mà tôi từng làm.',
          'The high school entrance exam is the hardest exam I have ever taken.',
          G.comparison,
        ),
        WritingSentence.of(
          'Tôi đã ôn tập suốt ba tháng.',
          'I have studied for three months.',
          G.presentPerfect,
          alternatives: ['I have revised for three months.'],
        ),
        WritingSentence.of(
          'Mọi đề thi đều được giữ bí mật cho đến ngày thi.',
          'All the exam papers are kept secret until the exam day.',
          G.passive,
        ),
        WritingSentence.of(
          'Tối qua, trong khi tôi đang ôn bài, mất điện.',
          'Last night, while I was revising, the power went out.',
          G.pastContinuous,
          alternatives: [
            'Last night, while I was studying, the power went out.',
          ],
        ),
        WritingSentence.of(
          'Tôi phải học dưới ánh nến.',
          'I had to study by candlelight.',
          G.modal,
        ),
        WritingSentence.of(
          'Nếu tôi đỗ, tôi sẽ vào trường mà tôi mơ ước.',
          'If I pass, I will go to my dream school.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'education_i2',
      level: _i,
      titleVi: 'Người thầy đáng nhớ',
      titleEn: 'A teacher I remember',
      sentences: [
        WritingSentence.of(
          'Thầy dạy văn năm lớp chín là người thầy tuyệt vời nhất của tôi.',
          'My literature teacher in grade nine was my best teacher ever.',
          G.comparison,
        ),
        WritingSentence.of(
          'Thầy đã dạy ở trường tôi hơn hai mươi năm.',
          'He has taught at my school for over twenty years.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Mỗi bài học được thầy biến thành một câu chuyện.',
          'Every lesson was turned into a story by him.',
          G.passive,
        ),
        WritingSentence.of(
          'Một lần, khi thầy đang đọc thơ, cả lớp đều im lặng lắng nghe.',
          'Once, while he was reading a poem, the whole class listened in silence.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Nhờ thầy, tôi yêu văn học hơn trước.',
          'Thanks to him, I love literature more than before.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nếu có dịp về trường, tôi sẽ đến thăm thầy.',
          'If I have a chance to visit my old school, I will see him.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'education_i3',
      level: _i,
      titleVi: 'Học nhóm',
      titleEn: 'Group study',
      sentences: [
        WritingSentence.of(
          'Nhóm học của tôi gặp nhau vào mỗi chiều thứ bảy.',
          'My study group meets every Saturday afternoon.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Học nhóm hiệu quả hơn học một mình.',
          'Studying in a group is more effective than studying alone.',
          G.comparison,
        ),
        WritingSentence.of(
          'Chúng tôi đã học cùng nhau được một năm.',
          'We have studied together for a year.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Mỗi tuần, một chủ đề được chọn bởi một thành viên.',
          'Every week, a topic is chosen by one member.',
          G.passive,
        ),
        WritingSentence.of(
          'Tuần trước, trong khi chúng tôi đang thảo luận, hai bạn cãi nhau.',
          'Last week, while we were discussing, two members argued.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Nếu mọi người tôn trọng nhau, nhóm sẽ làm việc tốt hơn.',
          'If everyone respects each other, the group will work better.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'education_i4',
      level: _i,
      titleVi: 'Học thêm',
      titleEn: 'Extra classes',
      sentences: [
        WritingSentence.of(
          'Nhiều học sinh Việt Nam đi học thêm sau giờ học.',
          'Many Vietnamese students take extra classes after school.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Em trai tôi đã học thêm toán được hai năm.',
          'My brother has taken extra math classes for two years.',
          G.presentPerfect,
          alternatives: [
            'My brother has taken extra maths classes for two years.',
          ],
        ),
        WritingSentence.of(
          'Nó bận rộn hơn tôi hồi bằng tuổi nó.',
          'He is busier than I was at his age.',
          G.comparison,
        ),
        WritingSentence.of(
          'Tối qua, khi nó đang làm bài, nó ngủ gật trên bàn.',
          'Last night, while he was doing his homework, he fell asleep at his desk.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Học sinh được khuyên nên nghỉ ngơi đầy đủ.',
          'Students are advised to get enough rest.',
          G.passive,
        ),
        WritingSentence.of(
          'Nếu nó học quá nhiều, nó sẽ bị kiệt sức.',
          'If he studies too much, he will be exhausted.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'education_i5',
      level: _i,
      titleVi: 'Thư viện trường',
      titleEn: 'The school library',
      sentences: [
        WritingSentence.of(
          'Thư viện là nơi yên tĩnh nhất trong trường.',
          'The library is the quietest place in the school.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nó vừa được sửa lại vào mùa hè.',
          'It was renovated in the summer.',
          G.passive,
        ),
        WritingSentence.of(
          'Tôi đã mượn hơn hai mươi cuốn sách trong năm nay.',
          'I have borrowed more than twenty books this year.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Hôm qua, khi tôi đang tìm sách, tôi gặp cô giáo cũ.',
          'Yesterday, while I was looking for a book, I met my old teacher.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Cô ấy giới thiệu cho tôi một cuốn tiểu thuyết hay.',
          'She recommended a good novel to me.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Nếu cuốn sách hay, tôi sẽ viết bài giới thiệu cho báo trường.',
          'If the book is good, I will write a review for the school paper.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'education_i6',
      level: _i,
      titleVi: 'Hoạt động ngoại khoá',
      titleEn: 'After-school activities',
      sentences: [
        WritingSentence.of(
          'Trường tôi có nhiều câu lạc bộ hơn trường cũ.',
          'My school has more clubs than my old school.',
          G.comparison,
        ),
        WritingSentence.of(
          'Tôi đã tham gia câu lạc bộ kịch được một học kỳ.',
          'I have been in the drama club for one term.',
          G.presentPerfect,
          alternatives: ['I have been in the drama club for a semester.'],
        ),
        WritingSentence.of(
          'Vở kịch năm nay được viết bởi chính học sinh.',
          'This year\'s play was written by the students themselves.',
          G.passive,
        ),
        WritingSentence.of(
          'Trong khi chúng tôi đang tập, đèn sân khấu bị hỏng.',
          'While we were rehearsing, the stage lights broke.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Buổi diễn chính thức sẽ diễn ra vào tháng sau.',
          'The real performance will take place next month.',
          G.futureSimple,
        ),
        WritingSentence.of(
          'Nếu bố mẹ đến xem, tôi sẽ rất vui.',
          'If my parents come to watch, I will be very happy.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'education_i7',
      level: _i,
      titleVi: 'Du học hè',
      titleEn: 'A summer course abroad',
      sentences: [
        WritingSentence.of(
          'Hè năm ngoái, tôi đã tham gia một khoá học ở Singapore.',
          'Last summer, I joined a course in Singapore.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Các lớp học ở đó được dạy hoàn toàn bằng tiếng Anh.',
          'The classes there were taught completely in English.',
          G.passive,
        ),
        WritingSentence.of(
          'Tuần đầu tiên khó khăn hơn tôi tưởng.',
          'The first week was harder than I expected.',
          G.comparison,
        ),
        WritingSentence.of(
          'Trong khi tôi đang thuyết trình, tôi quên mất một từ quan trọng.',
          'While I was giving a presentation, I forgot an important word.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Kể từ đó, tiếng Anh của tôi đã tiến bộ rất nhiều.',
          'Since then, my English has improved a lot.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Nếu có học bổng, tôi sẽ quay lại vào năm sau.',
          'If I get a scholarship, I will go back next year.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'education_i8',
      level: _i,
      titleVi: 'Chọn ngành đại học',
      titleEn: 'Choosing a major',
      sentences: [
        WritingSentence.of(
          'Chọn ngành học là quyết định khó nhất của tôi năm nay.',
          'Choosing a major is my hardest decision this year.',
          G.comparison,
        ),
        WritingSentence.of(
          'Tôi đã nói chuyện với nhiều anh chị sinh viên.',
          'I have talked to many university students.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Ngành công nghệ thông tin được nhiều bạn trẻ lựa chọn.',
          'Information technology is chosen by many young people.',
          G.passive,
        ),
        WritingSentence.of(
          'Tối qua, khi cả nhà đang ăn cơm, bố hỏi tôi muốn học ngành gì.',
          'Last night, while we were having dinner, Dad asked me about my future major.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Tôi thích thiết kế hơn lập trình.',
          'I prefer design to programming.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nếu bố mẹ đồng ý, tôi sẽ học thiết kế đồ hoạ.',
          'If my parents agree, I will study graphic design.',
          G.conditional1,
        ),
      ],
    ),

    // ---------------- Nang cao ----------------
    WritingParagraph(
      id: 'education_a1',
      level: _a,
      titleVi: 'Áp lực thi cử',
      titleEn: 'Exam pressure',
      sentences: [
        WritingSentence.of(
          'Kỳ thi tốt nghiệp, vốn quyết định tương lai của nhiều học sinh, gây ra áp lực rất lớn.',
          'The graduation exam, which decides the future of many students, creates enormous pressure.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Em họ tôi đã học mười hai tiếng mỗi ngày suốt nhiều tháng trước kỳ thi.',
          'My cousin had been studying twelve hours a day for months before the exam.',
          G.pastPerfectContinuous,
        ),
        WritingSentence.of(
          'Sau kỳ thi, em ấy thừa nhận rằng em đã gần như kiệt sức.',
          'After the exam, she admitted that she had almost burned out.',
          G.reportedSpeech,
          alternatives: [
            'After the exam, she admitted that she had almost burnt out.',
          ],
        ),
        WritingSentence.of(
          'Nếu em ấy được nghỉ ngơi hợp lý hơn, có lẽ em đã làm bài tốt hơn.',
          'If she had rested properly, she might have done better.',
          G.conditional3,
        ),
        WritingSentence.of(
          'Nhiều chuyên gia cho rằng học sinh nên được đánh giá bằng nhiều cách khác nhau.',
          'Many experts believe that students should be assessed in different ways.',
          G.passive,
        ),
        WritingSentence.of(
          'Trong những năm gần đây, Bộ Giáo dục đã và đang thử nghiệm các hình thức thi mới.',
          'In recent years, the Ministry of Education has been testing new types of exams.',
          G.presentPerfectContinuous,
        ),
      ],
    ),
    WritingParagraph(
      id: 'education_a2',
      level: _a,
      titleVi: 'Học suốt đời',
      titleEn: 'Lifelong learning',
      sentences: [
        WritingSentence.of(
          'Mẹ tôi, người bỏ học đại học khi còn trẻ, vừa tốt nghiệp ở tuổi năm mươi.',
          'My mother, who left university when she was young, has just graduated at the age of fifty.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Bà đã học buổi tối suốt bốn năm trong khi vẫn đi làm ban ngày.',
          'She studied in the evenings for four years while still working during the day.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Trước khi đăng ký, bà đã lo rằng mình quá già để học lại.',
          'Before she enrolled, she had worried that she was too old to study again.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Bà nói với tôi rằng việc học đã giúp bà tự tin hơn bao giờ hết.',
          'She told me that studying had made her more confident than ever.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu bà không dám bắt đầu, bà sẽ không bao giờ biết mình có thể làm được.',
          'If she had not dared to start, she would never have known she could do it.',
          G.conditional3,
        ),
        WritingSentence.of(
          'Năm sau, bà sẽ đang học lên thạc sĩ cùng lúc với tôi.',
          'Next year, she will be studying for a master\'s degree at the same time as me.',
          G.futureContinuous,
        ),
      ],
    ),
    WritingParagraph(
      id: 'education_a3',
      level: _a,
      titleVi: 'Trường học vùng cao',
      titleEn: 'A school in the mountains',
      sentences: [
        WritingSentence.of(
          'Ngôi trường nơi chị tôi dạy học nằm ở một bản làng xa xôi ở Hà Giang.',
          'The school where my sister teaches is in a remote village in Ha Giang.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Nhiều học sinh phải đi bộ hơn một giờ qua núi để đến lớp.',
          'Many students have to walk for over an hour through the mountains to get to class.',
          G.modal,
        ),
        WritingSentence.of(
          'Khi chị ấy mới đến, trường chưa từng có điện hay internet.',
          'When she first arrived, the school had never had electricity or the internet.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Chị kể rằng các em luôn đến lớp đúng giờ, dù trời mưa hay rét.',
          'She said that the children always came to class on time, even in rain or cold.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu có thêm giáo viên tình nguyện, các em sẽ được học nhiều môn hơn.',
          'If there were more volunteer teachers, the children could study more subjects.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Một tổ chức từ thiện đã và đang xây một khu nội trú cho học sinh ở xa.',
          'A charity has been building a dormitory for students who live far away.',
          G.presentPerfectContinuous,
        ),
      ],
    ),
    WritingParagraph(
      id: 'education_a4',
      level: _a,
      titleVi: 'Học trực tuyến hay trực tiếp',
      titleEn: 'Online or in person',
      sentences: [
        WritingSentence.of(
          'Trong đại dịch, hàng triệu học sinh buộc phải chuyển sang học trực tuyến.',
          'During the pandemic, millions of students were forced to switch to online learning.',
          G.passive,
        ),
        WritingSentence.of(
          'Nhiều gia đình ở nông thôn chưa từng sở hữu máy tính trước đó.',
          'Many families in the countryside had never owned a computer before that.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Giáo viên của tôi thừa nhận rằng giữ sự chú ý của học sinh qua màn hình rất khó.',
          'My teacher admitted that keeping students\' attention through a screen was very difficult.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Tuy nhiên, học trực tuyến lại linh hoạt hơn nhiều so với học trên lớp.',
          'However, online learning is much more flexible than classroom learning.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nếu kết hợp cả hai hình thức, học sinh sẽ có được lợi ích của cả hai.',
          'If schools combined both methods, students would get the benefits of each.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Đến cuối thập kỷ này, hầu hết các trường đại học sẽ đưa ra các khoá học kết hợp.',
          'By the end of this decade, most universities will have introduced blended courses.',
          G.futurePerfect,
        ),
      ],
    ),
    WritingParagraph(
      id: 'education_a5',
      level: _a,
      titleVi: 'Bài học từ thất bại',
      titleEn: 'Learning from failure',
      sentences: [
        WritingSentence.of(
          'Năm ngoái, tôi trượt kỳ thi học bổng mà tôi đã chuẩn bị suốt cả năm.',
          'Last year, I failed the scholarship exam that I had prepared for all year.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Tôi đã học rất chăm chỉ nhưng lại quá lo lắng trong phòng thi.',
          'I had studied very hard, but I was too nervous in the exam room.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Cô giáo khuyên tôi rằng tôi nên luyện thi thử nhiều lần hơn.',
          'My teacher advised me that I should take more practice tests.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Suốt sáu tháng qua, tôi đã làm một đề thi thử mỗi cuối tuần.',
          'For the past six months, I have been doing a practice test every weekend.',
          G.presentPerfectContinuous,
        ),
        WritingSentence.of(
          'Nếu tôi không trượt lần đó, tôi đã không học được cách kiểm soát lo âu.',
          'If I had not failed that time, I would not have learned to control my anxiety.',
          G.conditional3,
          alternatives: [
            'If I had not failed that time, I would not have learnt to control my anxiety.',
          ],
        ),
        WritingSentence.of(
          'Tháng sau, tôi sẽ thi lại với tâm thế hoàn toàn khác.',
          'Next month, I will take the exam again with a completely different mindset.',
          G.futureSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'education_a6',
      level: _a,
      titleVi: 'Giáo dục STEM',
      titleEn: 'STEM education',
      sentences: [
        WritingSentence.of(
          'Giáo dục STEM, vốn kết hợp khoa học, công nghệ, kỹ thuật và toán học, đang được nhiều trường áp dụng.',
          'STEM education, which combines science, technology, engineering and maths, is being adopted by many schools.',
          G.relativeClause,
          alternatives: [
            'STEM education, which combines science, technology, engineering and math, is being adopted by many schools.',
          ],
        ),
        WritingSentence.of(
          'Thay vì chỉ ghi nhớ công thức, học sinh được khuyến khích tự làm thí nghiệm.',
          'Instead of only memorizing formulas, students are encouraged to do experiments themselves.',
          G.passive,
          alternatives: [
            'Instead of only memorising formulas, students are encouraged to do experiments themselves.',
          ],
        ),
        WritingSentence.of(
          'Trước khi có môn học này, tôi chưa từng tự lắp một mạch điện nào.',
          'Before this subject was introduced, I had never built an electric circuit myself.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Thầy giáo nói rằng những dự án thực tế giúp học sinh nhớ bài lâu hơn.',
          'Our teacher said that practical projects helped students remember lessons longer.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu trường có phòng thí nghiệm hiện đại hơn, chúng tôi có thể làm những dự án lớn hơn.',
          'If our school had a more modern lab, we could do bigger projects.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Vào giờ này tuần sau, nhóm tôi sẽ đang trình bày dự án tại cuộc thi cấp thành phố.',
          'This time next week, my team will be presenting our project at the city competition.',
          G.futureContinuous,
        ),
      ],
    ),
    WritingParagraph(
      id: 'education_a7',
      level: _a,
      titleVi: 'Học ngoại ngữ từ nhỏ',
      titleEn: 'Learning languages early',
      sentences: [
        WritingSentence.of(
          'Nhiều phụ huynh cho con học tiếng Anh từ khi các con mới ba, bốn tuổi.',
          'Many parents start their children on English when they are only three or four.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Các nhà nghiên cứu đã chứng minh rằng trẻ nhỏ học phát âm dễ hơn người lớn.',
          'Researchers have shown that young children learn pronunciation more easily than adults.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Tuy nhiên, một số chuyên gia cảnh báo rằng trẻ cần nắm vững tiếng mẹ đẻ trước.',
          'However, some experts have warned that children need to master their mother tongue first.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Cháu tôi, người đã học song ngữ từ mẫu giáo, giờ nói cả hai thứ tiếng rất tự nhiên.',
          'My nephew, who has studied in a bilingual school since kindergarten, now speaks both languages naturally.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Nếu tôi được học sớm như cháu, tôi đã không gặp khó khăn với phát âm như bây giờ.',
          'If I had started as early as him, I would not have struggled so much with pronunciation.',
          G.conditional3,
        ),
        WritingSentence.of(
          'Khi cháu vào đại học, cháu có lẽ đã nói thành thạo ba ngôn ngữ.',
          'By the time he goes to university, he will probably have mastered three languages.',
          G.futurePerfect,
        ),
      ],
    ),
    WritingParagraph(
      id: 'education_a8',
      level: _a,
      titleVi: 'Nghề giáo',
      titleEn: 'Becoming a teacher',
      sentences: [
        WritingSentence.of(
          'Nghề giáo, vốn được xã hội tôn trọng, lại không phải lúc nào cũng được trả lương xứng đáng.',
          'Teaching, which is highly respected in society, is not always well paid.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Tôi đã mơ trở thành giáo viên từ khi còn học tiểu học.',
          'I have dreamed of becoming a teacher since I was in primary school.',
          G.presentPerfect,
          alternatives: [
            'I have dreamt of becoming a teacher since I was in primary school.',
          ],
        ),
        WritingSentence.of(
          'Khi tôi nói với bố mẹ, họ hỏi liệu tôi đã suy nghĩ kỹ chưa.',
          'When I told my parents, they asked whether I had thought it through.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu lương giáo viên cao hơn, nhiều người trẻ tài năng sẽ chọn nghề này.',
          'If teachers\' salaries were higher, more talented young people would choose this job.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Suốt học kỳ này, tôi đã thực tập tại một trường cấp hai gần nhà.',
          'This term, I have been doing a teaching placement at a secondary school near my home.',
          G.presentPerfectContinuous,
        ),
        WritingSentence.of(
          'Đến lúc tốt nghiệp, tôi sẽ đứng lớp được hơn hai trăm giờ.',
          'By the time I graduate, I will have taught more than two hundred hours of classes.',
          G.futurePerfect,
        ),
      ],
    ),
  ],
);
