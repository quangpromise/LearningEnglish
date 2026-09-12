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

const kWritingBankBooks = WritingTopic(
  id: 'books',
  titleVi: 'Sách',
  titleEn: 'Books',
  icon: Icons.menu_book_rounded,
  color: AppColors.amber,
  paragraphs: [
    // ---------------- Co ban ----------------
    WritingParagraph(
      id: 'books_b1',
      level: _b,
      titleVi: 'Cuốn sách yêu thích',
      titleEn: 'My favorite book',
      sentences: [
        WritingSentence.of(
          'Tôi thích đọc sách.',
          'I like reading books.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Cuốn sách yêu thích của tôi kể về một chú thỏ.',
          'My favorite book is about a rabbit.',
          G.presentSimple,
          alternatives: ['My favourite book is about a rabbit.'],
        ),
        WritingSentence.of(
          'Tôi đã đọc nó nhiều lần.',
          'I read it many times.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Nhân vật chính rất dũng cảm.',
          'The main character is very brave.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tôi muốn đọc lại nó.',
          'I want to read it again.',
          G.presentSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'books_b2',
      level: _b,
      titleVi: 'Ở thư viện',
      titleEn: 'At the library',
      sentences: [
        WritingSentence.of(
          'Bây giờ tôi đang ở thư viện.',
          'I am at the library now.',
          G.presentSimple,
          alternatives: ['Now I am at the library.'],
        ),
        WritingSentence.of(
          'Tôi đang tìm một cuốn sách.',
          'I am looking for a book.',
          G.presentContinuous,
        ),
        WritingSentence.of(
          'Nhân viên thư viện đang giúp tôi.',
          'The librarian is helping me.',
          G.presentContinuous,
        ),
        WritingSentence.of(
          'Tôi có thể mượn ba cuốn sách.',
          'I can borrow three books.',
          G.modal,
        ),
        WritingSentence.of(
          'Tôi phải trả sách trong hai tuần.',
          'I must return the books in two weeks.',
          G.modal,
          alternatives: ['I have to return the books in two weeks.'],
        ),
      ],
    ),
    WritingParagraph(
      id: 'books_b3',
      level: _b,
      titleVi: 'Đọc trước khi ngủ',
      titleEn: 'Reading before bed',
      sentences: [
        WritingSentence.of(
          'Tôi đọc sách trước khi đi ngủ.',
          'I read books before I go to bed.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Mẹ tôi đọc truyện cho em gái tôi.',
          'My mother reads stories to my sister.',
          G.presentSimple,
          alternatives: ['My mom reads stories to my sister.'],
        ),
        WritingSentence.of(
          'Em ấy thích truyện cổ tích.',
          'She likes fairy tales.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tối qua tôi đã đọc hai chương.',
          'Last night I read two chapters.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Tôi đã ngủ quên khi đang đọc.',
          'I fell asleep while reading.',
          G.pastSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'books_b4',
      level: _b,
      titleVi: 'Mua sách mới',
      titleEn: 'Buying a new book',
      sentences: [
        WritingSentence.of(
          'Cuối tuần trước tôi đã đi hiệu sách.',
          'Last weekend I went to a bookshop.',
          G.pastSimple,
          alternatives: ['Last weekend I went to a bookstore.'],
        ),
        WritingSentence.of(
          'Tôi đã mua hai cuốn truyện tranh.',
          'I bought two comic books.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Chúng có giá rẻ hơn tôi nghĩ.',
          'They were cheaper than I thought.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Tôi đã đọc hết chúng trong một ngày.',
          'I finished them in one day.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Tôi sẽ mua thêm vào tuần sau.',
          'I will buy more next week.',
          G.futureSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'books_b5',
      level: _b,
      titleVi: 'Câu lạc bộ đọc sách',
      titleEn: 'A reading club',
      sentences: [
        WritingSentence.of(
          'Trường tôi có một câu lạc bộ đọc sách.',
          'My school has a reading club.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Chúng tôi họp mỗi thứ sáu.',
          'We meet every Friday.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tuần này tôi định đọc một cuốn sách mới.',
          'This week I am going to read a new book.',
          G.goingTo,
        ),
        WritingSentence.of(
          'Chúng tôi sẽ thảo luận về nó.',
          'We will discuss it.',
          G.futureSimple,
        ),
        WritingSentence.of(
          'Tôi rất mong đến buổi họp.',
          'I am really looking forward to the meeting.',
          G.presentContinuous,
        ),
      ],
    ),
    WritingParagraph(
      id: 'books_b6',
      level: _b,
      titleVi: 'Sách của ông',
      titleEn: 'Grandpa\'s books',
      sentences: [
        WritingSentence.of(
          'Ông tôi có rất nhiều sách cũ.',
          'My grandfather has many old books.',
          G.presentSimple,
          alternatives: ['My grandpa has many old books.'],
        ),
        WritingSentence.of(
          'Ông giữ chúng trong một tủ lớn.',
          'He keeps them in a big cabinet.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tôi thích đọc chúng cùng ông.',
          'I like reading them with him.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Một số cuốn rất cũ.',
          'Some of them are very old.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tôi sẽ giữ gìn chúng thật cẩn thận.',
          'I will take good care of them.',
          G.futureSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'books_b7',
      level: _b,
      titleVi: 'Viết nhật ký',
      titleEn: 'Writing a diary',
      sentences: [
        WritingSentence.of(
          'Tôi viết nhật ký mỗi tối.',
          'I write a diary every night.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Tôi kể về ngày của tôi.',
          'I write about my day.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Đêm qua tôi đã viết về sinh nhật của bạn.',
          'Last night I wrote about my friend\'s birthday.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Tôi giữ cuốn nhật ký rất kín đáo.',
          'I keep my diary very private.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Không ai được đọc nó.',
          'No one is allowed to read it.',
          G.modal,
        ),
      ],
    ),
    WritingParagraph(
      id: 'books_b8',
      level: _b,
      titleVi: 'Sách nói',
      titleEn: 'Audiobooks',
      sentences: [
        WritingSentence.of(
          'Chị tôi thích nghe sách nói.',
          'My sister likes audiobooks.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Chị ấy nghe trên đường đi làm.',
          'She listens to them on her way to work.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Bây giờ chị ấy đang nghe một câu chuyện trinh thám.',
          'Now she is listening to a detective story.',
          G.presentContinuous,
        ),
        WritingSentence.of(
          'Sách nói rất tiện khi đi đường.',
          'Audiobooks are very convenient when traveling.',
          G.presentSimple,
          alternatives: ['Audiobooks are very convenient when travelling.'],
        ),
        WritingSentence.of(
          'Tôi cũng sẽ thử nghe sách nói.',
          'I will also try listening to audiobooks.',
          G.futureSimple,
        ),
      ],
    ),

    // ---------------- Trung cap ----------------
    WritingParagraph(
      id: 'books_i1',
      level: _i,
      titleVi: 'Cuốn sách thay đổi tôi',
      titleEn: 'A book that changed me',
      sentences: [
        WritingSentence.of(
          'Tôi đã đọc cuốn sách này hơn năm lần.',
          'I have read this book more than five times.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Nó được viết bởi một tác giả người Nhật.',
          'It was written by a Japanese author.',
          G.passive,
        ),
        WritingSentence.of(
          'Câu chuyện sâu sắc hơn tôi tưởng lúc đầu.',
          'The story is deeper than I thought at first.',
          G.comparison,
        ),
        WritingSentence.of(
          'Trong khi tôi đang đọc chương cuối, tôi đã khóc.',
          'While I was reading the last chapter, I cried.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Nó đã dạy tôi cách nhìn cuộc sống khác đi.',
          'It has taught me to see life differently.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Nếu bạn thích đọc, tôi sẽ cho bạn mượn nó.',
          'If you like reading, I will lend it to you.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'books_i2',
      level: _i,
      titleVi: 'Sách điện tử',
      titleEn: 'E-books',
      sentences: [
        WritingSentence.of(
          'Sách điện tử đang trở nên phổ biến hơn sách giấy.',
          'E-books are becoming more popular than paper books.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nhiều thư viện đã bắt đầu cho mượn sách điện tử.',
          'Many libraries have started lending e-books.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Một cuốn sách điện tử được tải xuống chỉ trong vài giây.',
          'An e-book is downloaded in just a few seconds.',
          G.passive,
        ),
        WritingSentence.of(
          'Hôm qua, trong khi tôi đang đọc trên máy tính bảng, pin hết.',
          'Yesterday, while I was reading on my tablet, the battery died.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Tôi vẫn thích cảm giác cầm sách giấy hơn.',
          'I still prefer the feeling of holding a paper book.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nếu tôi đi du lịch xa, tôi sẽ mang theo sách điện tử.',
          'If I travel far, I will bring e-books.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'books_i3',
      level: _i,
      titleVi: 'Tác giả yêu thích',
      titleEn: 'My favorite author',
      sentences: [
        WritingSentence.of(
          'Tôi đã đọc tất cả sách của tác giả này.',
          'I have read all of this author\'s books.',
          G.presentPerfect,
          alternatives: ['I have read all this author\'s books.'],
        ),
        WritingSentence.of(
          'Cuốn mới nhất của cô ấy được xuất bản tháng trước.',
          'Her latest book was published last month.',
          G.passive,
        ),
        WritingSentence.of(
          'Nó hay hơn tất cả các cuốn trước.',
          'It is better than all her previous books.',
          G.comparison,
        ),
        WritingSentence.of(
          'Trong khi tôi đang đọc, tôi không thể đặt sách xuống.',
          'While I was reading, I could not put the book down.',
          G.pastContinuous,
          alternatives: ['While I was reading, I couldn\'t put the book down.'],
        ),
        WritingSentence.of(
          'Cô ấy đã viết văn được hai mươi năm.',
          'She has written novels for twenty years.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Nếu cô ấy ra sách mới, tôi sẽ mua ngay.',
          'If she releases a new book, I will buy it immediately.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'books_i4',
      level: _i,
      titleVi: 'Truyện trinh thám',
      titleEn: 'Detective novels',
      sentences: [
        WritingSentence.of(
          'Tôi thích truyện trinh thám hơn truyện tình cảm.',
          'I like detective novels more than romance novels.',
          G.comparison,
        ),
        WritingSentence.of(
          'Manh mối luôn được giấu rất khéo.',
          'The clues are always hidden very cleverly.',
          G.passive,
        ),
        WritingSentence.of(
          'Tôi đã đoán sai thủ phạm trong cuốn sách này.',
          'I guessed the wrong culprit in this book.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Trong khi tôi đang đọc chương giữa, tôi thay đổi suy đoán.',
          'While I was reading the middle chapters, I changed my guess.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Kết thúc bất ngờ hơn tôi tưởng rất nhiều.',
          'The ending was much more surprising than I expected.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nếu có phần hai, tôi sẽ đọc ngay khi ra mắt.',
          'If there is a sequel, I will read it as soon as it comes out.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'books_i5',
      level: _i,
      titleVi: 'Hội chợ sách',
      titleEn: 'A book fair',
      sentences: [
        WritingSentence.of(
          'Tuần trước tôi đã đi hội chợ sách của thành phố.',
          'Last week I went to the city book fair.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Nó đông hơn tôi tưởng rất nhiều.',
          'It was much more crowded than I expected.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nhiều cuốn sách được giảm giá đến năm mươi phần trăm.',
          'Many books were discounted by up to fifty percent.',
          G.passive,
        ),
        WritingSentence.of(
          'Trong khi tôi đang xếp hàng mua sách, tôi gặp một nhà văn nổi tiếng.',
          'While I was queuing to buy books, I met a famous writer.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Tôi đã xin chữ ký của cô ấy.',
          'I asked for her autograph.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Nếu hội chợ tổ chức lại năm sau, tôi sẽ đi sớm hơn.',
          'If the fair is held again next year, I will go earlier.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'books_i6',
      level: _i,
      titleVi: 'Đọc để thư giãn',
      titleEn: 'Reading to relax',
      sentences: [
        WritingSentence.of(
          'Sau một ngày căng thẳng, tôi thường đọc sách để thư giãn.',
          'After a stressful day, I often read to relax.',
          G.presentSimple,
        ),
        WritingSentence.of(
          'Đọc sách giúp tôi bình tĩnh hơn xem điện thoại.',
          'Reading helps me stay calmer than looking at my phone.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nhiều nghiên cứu đã chỉ ra lợi ích này.',
          'Many studies have shown this benefit.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Tối qua, trong khi tôi đang đọc, tôi quên hết mọi lo lắng.',
          'Last night, while I was reading, I forgot all my worries.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Tôi đã ngủ ngon hơn hẳn tối hôm đó.',
          'I slept much better that night.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nếu bạn khó ngủ, bạn nên thử đọc sách trước khi ngủ.',
          'If you have trouble sleeping, you should try reading before bed.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'books_i7',
      level: _i,
      titleVi: 'Tủ sách gia đình',
      titleEn: 'The family bookshelf',
      sentences: [
        WritingSentence.of(
          'Tủ sách nhà tôi lớn hơn tủ sách nhà bạn tôi rất nhiều.',
          'My family\'s bookshelf is much bigger than my friend\'s.',
          G.comparison,
        ),
        WritingSentence.of(
          'Nhiều cuốn sách được truyền lại từ đời ông.',
          'Many books were passed down from my grandfather.',
          G.passive,
        ),
        WritingSentence.of(
          'Tôi đã sắp xếp lại tủ sách được ba lần.',
          'I have reorganized the bookshelf three times.',
          G.presentPerfect,
          alternatives: ['I have reorganised the bookshelf three times.'],
        ),
        WritingSentence.of(
          'Trong khi tôi đang lau bụi, tôi tìm thấy một cuốn sách rất cũ.',
          'While I was dusting, I found a very old book.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Nó được xuất bản trước cả khi bố tôi sinh ra.',
          'It was published even before my father was born.',
          G.passive,
        ),
        WritingSentence.of(
          'Nếu tôi có con, tôi sẽ giữ tủ sách này cho chúng.',
          'If I have children, I will keep this bookshelf for them.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'books_i8',
      level: _i,
      titleVi: 'Viết bài đánh giá sách',
      titleEn: 'Writing a book review',
      sentences: [
        WritingSentence.of(
          'Tôi đã bắt đầu viết bài đánh giá sách trên blog.',
          'I have started writing book reviews on a blog.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Mỗi bài viết được đọc bởi khoảng một trăm người.',
          'Each post is read by about a hundred people.',
          G.passive,
        ),
        WritingSentence.of(
          'Viết đánh giá giúp tôi nhớ nội dung lâu hơn.',
          'Writing reviews helps me remember the content longer.',
          G.comparison,
        ),
        WritingSentence.of(
          'Tối qua, trong khi tôi đang viết bài, một độc giả bình luận ngay.',
          'Last night, while I was writing a post, a reader commented right away.',
          G.pastContinuous,
        ),
        WritingSentence.of(
          'Tôi đã kết bạn với nhiều người yêu sách khác.',
          'I have made friends with many other book lovers.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Nếu blog phát triển, tôi sẽ viết thường xuyên hơn.',
          'If the blog grows, I will write more often.',
          G.conditional1,
        ),
      ],
    ),

    // ---------------- Nang cao ----------------
    WritingParagraph(
      id: 'books_a1',
      level: _a,
      titleVi: 'Sách cấm',
      titleEn: 'Banned books',
      sentences: [
        WritingSentence.of(
          'Trong suốt lịch sử, nhiều cuốn sách đã bị cấm vì thách thức tư tưởng của chính quyền đương thời.',
          'Throughout history, many books have been banned for challenging the ideas of the ruling powers.',
          G.passive,
        ),
        WritingSentence.of(
          'Một cuốn tiểu thuyết mà tôi từng đọc đã bị cấm ở một số quốc gia suốt nhiều thập kỷ.',
          'A novel that I once read was banned in some countries for decades.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Tác giả nói rằng bà chưa bao giờ ngờ tác phẩm của mình lại gây tranh cãi đến vậy.',
          'The author said that she had never expected her work to become so controversial.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu cuốn sách không bị cấm, có lẽ nó đã không nổi tiếng đến mức đó.',
          'If the book had not been banned, it might not have become so famous.',
          G.conditional3,
        ),
        WritingSentence.of(
          'Việc cấm sách thường khiến người đọc tò mò hơn thay vì ngăn cản họ.',
          'Banning books often makes readers more curious instead of stopping them.',
          G.comparison,
        ),
        WritingSentence.of(
          'Tôi tin rằng tự do đọc sách là một quyền cơ bản nên được bảo vệ.',
          'I believe that the freedom to read is a basic right that should be protected.',
          G.passive,
        ),
      ],
    ),
    WritingParagraph(
      id: 'books_a2',
      level: _a,
      titleVi: 'Người thợ đóng sách',
      titleEn: 'A bookbinder\'s craft',
      sentences: [
        WritingSentence.of(
          'Ông cụ mà tôi gặp ở phố sách cũ đã làm nghề đóng sách suốt sáu mươi năm.',
          'The old man I met at the old book street had been bookbinding for sixty years.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Ông kể rằng khi còn trẻ, ông đã học nghề từ cha mình trong ba năm trước khi được tự làm.',
          'He said that when he was young, he had learned the craft from his father for three years before working alone.',
          G.reportedSpeech,
          alternatives: [
            'He said that when he was young, he had learnt the craft from his father for three years before working alone.',
          ],
        ),
        WritingSentence.of(
          'Mỗi cuốn sách được đóng lại bằng tay với keo và chỉ truyền thống.',
          'Each book is rebound by hand with traditional glue and thread.',
          G.passive,
        ),
        WritingSentence.of(
          'Nếu ông không giữ nghề này, có lẽ kỹ thuật cổ đã biến mất hoàn toàn.',
          'If he had not kept the craft alive, the old technique might have disappeared completely.',
          G.conditional3,
        ),
        WritingSentence.of(
          'Gần đây, một vài bạn trẻ đã và đang đến học nghề từ ông.',
          'Recently, a few young people have been coming to learn the craft from him.',
          G.presentPerfectContinuous,
        ),
        WritingSentence.of(
          'Đến khi ông nghỉ hưu, ông hy vọng sẽ có ít nhất một người tiếp tục công việc này.',
          'By the time he retires, he hopes at least one person will have taken over his work.',
          G.futurePerfect,
        ),
      ],
    ),
    WritingParagraph(
      id: 'books_a3',
      level: _a,
      titleVi: 'Từ tiểu thuyết đến phim',
      titleEn: 'From novel to film',
      sentences: [
        WritingSentence.of(
          'Cuốn tiểu thuyết, tác phẩm đã bán được hơn mười triệu bản, vừa được chuyển thể thành phim.',
          'The novel, which has sold more than ten million copies, has just been adapted into a film.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Tác giả đã từ chối nhiều lời đề nghị chuyển thể trước khi đồng ý với đạo diễn này.',
          'The author had turned down many adaptation offers before agreeing to work with this director.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Bà giải thích rằng bà muốn đảm bảo tinh thần của cuốn sách được giữ nguyên.',
          'She explained that she wanted to make sure the spirit of the book was kept intact.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu bộ phim khác quá nhiều so với sách, người hâm mộ chắc chắn sẽ thất vọng.',
          'If the film differs too much from the book, fans will certainly be disappointed.',
          G.conditional1,
        ),
        WritingSentence.of(
          'Kể từ khi công bố dự án, người hâm mộ đã và đang tranh luận về diễn viên phù hợp.',
          'Since the project was announced, fans have been debating who should play the roles.',
          G.presentPerfectContinuous,
        ),
        WritingSentence.of(
          'Đến khi phim ra rạp, cuốn sách sẽ đã được dịch sang hơn ba mươi ngôn ngữ.',
          'By the time the film is released, the book will have been translated into more than thirty languages.',
          G.futurePerfect,
        ),
      ],
    ),
    WritingParagraph(
      id: 'books_a4',
      level: _a,
      titleVi: 'Đọc sách trong thời đại số',
      titleEn: 'Reading in the digital age',
      sentences: [
        WritingSentence.of(
          'Nhiều chuyên gia lo ngại rằng khả năng tập trung của con người đã giảm sút vì mạng xã hội.',
          'Many experts worry that people\'s attention spans have declined because of social media.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Trước khi có điện thoại thông minh, tôi từng đọc hết một cuốn tiểu thuyết chỉ trong một buổi chiều.',
          'Before smartphones existed, I used to finish a whole novel in just one afternoon.',
          G.pastSimple,
        ),
        WritingSentence.of(
          'Một nhà nghiên cứu nói rằng não bộ đang dần quen với việc đọc lướt thay vì đọc sâu.',
          'A researcher said that our brains were gradually getting used to skimming instead of deep reading.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu tôi không đặt điện thoại ở phòng khác, tôi sẽ không thể tập trung đọc quá mười phút.',
          'If I do not leave my phone in another room, I cannot concentrate on reading for more than ten minutes.',
          G.conditional1,
        ),
        WritingSentence.of(
          'Gần đây, tôi đã và đang cố gắng đọc ít nhất ba mươi phút mỗi ngày không bị gián đoạn.',
          'Recently, I have been trying to read for at least thirty minutes a day without interruption.',
          G.presentPerfectContinuous,
        ),
        WritingSentence.of(
          'Tôi tin rằng nếu con người ngừng đọc sâu, tư duy phản biện của cả xã hội sẽ yếu đi.',
          'I believe that if people stop reading deeply, society\'s critical thinking will weaken.',
          G.conditional1,
        ),
      ],
    ),
    WritingParagraph(
      id: 'books_a5',
      level: _a,
      titleVi: 'Nhà văn khiếm thị',
      titleEn: 'A blind author',
      sentences: [
        WritingSentence.of(
          'Nhà văn mà tôi ngưỡng mộ nhất đã mất thị lực năm hai mươi lăm tuổi nhưng vẫn tiếp tục viết.',
          'The author I admire most lost her sight at twenty-five but continued writing.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Bà đã học chữ nổi suốt hai năm trước khi viết được cuốn sách đầu tiên sau khi mất thị lực.',
          'She had studied braille for two years before she could write her first book after losing her sight.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Bà nói với tôi rằng việc mất thị lực đã dạy bà cách "nhìn" thế giới theo cách khác.',
          'She told me that losing her sight had taught her to "see" the world differently.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu bà bỏ cuộc sau tai nạn đó, thế giới đã không bao giờ biết đến những tác phẩm tuyệt vời của bà.',
          'If she had given up after that accident, the world would never have known her wonderful works.',
          G.conditional3,
        ),
        WritingSentence.of(
          'Sách của bà đã được chuyển thành sách nói cho hàng nghìn độc giả khiếm thị khác.',
          'Her books have been turned into audiobooks for thousands of other visually impaired readers.',
          G.passive,
        ),
        WritingSentence.of(
          'Câu chuyện của bà nhắc tôi rằng những giới hạn không quyết định được điều chúng ta có thể tạo ra.',
          'Her story reminds me that limitations do not determine what we can create.',
          G.presentSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'books_a6',
      level: _a,
      titleVi: 'Thư viện công cộng',
      titleEn: 'Public libraries',
      sentences: [
        WritingSentence.of(
          'Thư viện công cộng, nơi bất kỳ ai cũng có thể vào miễn phí, đóng vai trò quan trọng trong việc giảm bất bình đẳng giáo dục.',
          'Public libraries, which anyone can enter for free, play an important role in reducing educational inequality.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Nhiều trẻ em nghèo đã học được cách yêu thích đọc sách nhờ những chuyến đi thư viện miễn phí.',
          'Many poor children have learned to love reading thanks to free library trips.',
          G.presentPerfect,
          alternatives: [
            'Many poor children have learnt to love reading thanks to free library trips.',
          ],
        ),
        WritingSentence.of(
          'Một quản lý thư viện nói rằng ngân sách của họ đã bị cắt giảm nghiêm trọng trong những năm gần đây.',
          'A library manager said that their budget had been seriously cut in recent years.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu chính phủ đầu tư nhiều hơn vào thư viện, nhiều cộng đồng nghèo sẽ được hưởng lợi.',
          'If the government invested more in libraries, many poor communities would benefit.',
          G.conditional2,
        ),
        WritingSentence.of(
          'Trước khi Internet phổ biến, thư viện từng là nơi duy nhất nhiều người có thể tiếp cận thông tin miễn phí.',
          'Before the Internet became common, libraries had been the only place many people could access free information.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Tôi tin rằng thư viện sẽ vẫn quan trọng dù công nghệ thay đổi thế nào đi nữa.',
          'I believe libraries will remain important no matter how technology changes.',
          G.futureSimple,
        ),
      ],
    ),
    WritingParagraph(
      id: 'books_a7',
      level: _a,
      titleVi: 'Dịch thuật văn học',
      titleEn: 'Literary translation',
      sentences: [
        WritingSentence.of(
          'Người dịch, người đã dành ba năm để chuyển ngữ cuốn tiểu thuyết này, nói rằng công việc khó hơn viết sách mới.',
          'The translator, who spent three years translating this novel, said the work was harder than writing a new book.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Trước khi tìm được từ phù hợp, cô đã thử hàng chục cách diễn đạt khác nhau cho một câu duy nhất.',
          'Before finding the right word, she had tried dozens of different phrasings for a single sentence.',
          G.pastPerfect,
        ),
        WritingSentence.of(
          'Cô kể rằng có những cụm từ trong tiếng gốc hoàn toàn không có từ tương đương trong ngôn ngữ đích.',
          'She said that some phrases in the original language had no equivalent at all in the target language.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu bản dịch không giữ được giọng văn gốc, độc giả sẽ mất đi trải nghiệm thật sự của tác phẩm.',
          'If the translation does not keep the original voice, readers will lose the true experience of the work.',
          G.conditional1,
        ),
        WritingSentence.of(
          'Nhiều tác phẩm kinh điển đã được dịch lại nhiều lần qua các thế hệ dịch giả khác nhau.',
          'Many classic works have been retranslated many times across generations of translators.',
          G.passive,
        ),
        WritingSentence.of(
          'Nhờ những người dịch như vậy, độc giả khắp nơi trên thế giới có thể chia sẻ cùng một câu chuyện.',
          'Thanks to translators like her, readers all over the world can share the same story.',
          G.modal,
        ),
      ],
    ),
    WritingParagraph(
      id: 'books_a8',
      level: _a,
      titleVi: 'Vì sao chúng ta đọc',
      titleEn: 'Why we read',
      sentences: [
        WritingSentence.of(
          'Từ khi còn nhỏ, sách đã cho tôi cơ hội sống hàng nghìn cuộc đời mà tôi chưa bao giờ có thể trải nghiệm thật.',
          'Since I was a child, books have given me the chance to live thousands of lives I could never truly experience.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Những nhân vật mà tôi từng đọc về đã dạy tôi sự đồng cảm nhiều hơn bất kỳ bài học nào ở trường.',
          'The characters I have read about have taught me empathy more than any lesson at school.',
          G.relativeClause,
        ),
        WritingSentence.of(
          'Một nhà tâm lý học từng nói rằng đọc tiểu thuyết giúp con người hiểu cảm xúc của người khác tốt hơn.',
          'A psychologist once said that reading fiction helped people understand others\' emotions better.',
          G.reportedSpeech,
        ),
        WritingSentence.of(
          'Nếu tôi chưa bao giờ đọc sách, có lẽ tôi đã không hiểu được những trải nghiệm khác với chính mình.',
          'If I had never read books, I might not have understood experiences different from my own.',
          G.conditional3,
        ),
        WritingSentence.of(
          'Trong thế giới ngày càng ồn ào này, việc ngồi yên với một cuốn sách trở thành một hành động quý giá.',
          'In this increasingly noisy world, sitting quietly with a book has become a precious act.',
          G.presentPerfect,
        ),
        WritingSentence.of(
          'Tôi hy vọng mình sẽ tiếp tục đọc, dù công nghệ có thay đổi cuộc sống của chúng ta như thế nào.',
          'I hope I will keep reading, no matter how technology changes our lives.',
          G.futureSimple,
        ),
      ],
    ),
  ],
);
