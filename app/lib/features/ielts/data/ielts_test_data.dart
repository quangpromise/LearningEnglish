import 'ielts_models.dart';

// ============================================================================
// READING PASSAGE 1 - "Beekeeping Comes to the City" (~13 cau, 1-13)
// ============================================================================

const _readingPassage1 = IeltsPassage(
  id: 'r1-passage',
  titleEn: 'Beekeeping Comes to the City',
  paragraphsEn: [
    'A. In the past two decades, a growing number of city dwellers across '
        'the world have taken up an unlikely hobby: keeping honeybees. '
        'Rooftops in New York, balconies in Paris, and community gardens in '
        'London now host thousands of small wooden hives. Local beekeeping '
        'associations report that membership has tripled in many major '
        'cities since 2010, and several municipal governments have begun '
        'actively encouraging the practice rather than restricting it, as '
        'they once did.',
    'B. One of the main reasons for this shift is a growing awareness of '
        'the vital role bees play in pollinating plants. Roughly one-third '
        'of the food crops that humans eat depend, at least partly, on '
        'pollination by bees and other insects. As wild bee populations '
        'have declined sharply in rural areas due to pesticide use and the '
        'loss of natural habitat, many environmentalists have argued that '
        'cities, with their parks, gardens and street trees, could '
        'actually offer bees a surprisingly safe refuge.',
    'C. Urban beekeeping is not without its difficulties, however. Many '
        'cities historically banned the practice altogether, fearing that '
        'bees would sting pedestrians or trigger allergic reactions. Even '
        'where beekeeping is now legal, hobbyists must often navigate a '
        'maze of local regulations concerning hive placement, distance '
        'from property boundaries, and maximum colony size. Complaints '
        'from nervous neighbours remain one of the most common reasons '
        'that new urban beekeepers give up within their first year.',
    'D. To address these concerns, experienced urban beekeepers have '
        'developed a range of practical solutions. Placing hives on '
        'rooftops, several metres above street level, keeps bees well '
        'away from passers-by, since foraging bees typically fly upward '
        'and outward rather than lingering near the ground. Some '
        'beekeeping groups have also formed partnerships with community '
        'gardens, offering to install hives in exchange for allowing '
        'garden members to harvest a small share of the honey each '
        'season.',
    'E. The honey produced by urban colonies has, somewhat unexpectedly, '
        'developed a reputation for exceptional quality among food '
        'enthusiasts. Because cities typically contain a wider variety of '
        'flowering plants within a small area than a single rural farm '
        'might, urban honey often has a more complex, layered flavour '
        'that changes noticeably from one neighbourhood to the next. A '
        'handful of small businesses have begun bottling and selling '
        '"neighbourhood honey" harvested from rooftop hives, marketing '
        'each batch by its precise location.',
    'F. Looking ahead, several city governments have started to formalise '
        'their support for the practice. Some now offer free training '
        'courses for first-time beekeepers, while others have relaxed '
        'zoning restrictions specifically to allow hives on rooftops and '
        'in community gardens. Whether urban beekeeping will remain a '
        'niche hobby or grow into something closer to a mainstream urban '
        'agriculture movement remains to be seen, but its popularity '
        'shows little sign of slowing.',
  ],
);

const _tfNgGroupInstruction1 =
    'Questions 1-5. Do the following statements agree with the information '
    'given in Reading Passage 1? Write TRUE if the statement agrees with '
    'the information, FALSE if the statement contradicts the information, '
    'or NOT GIVEN if there is no information on this.';

const _matchingInfoGroupInstruction1 =
    'Questions 6-9. Reading Passage 1 has six paragraphs, A-F. Which '
    'paragraph contains the following information?';

const _sentenceCompletionGroupInstruction1 =
    'Questions 10-13. Complete the sentences below. Choose NO MORE THAN '
    'TWO WORDS from the passage for each answer.';

final _readingPassage1Questions = <IeltsQuestion>[
  IeltsQuestion(
    id: 'r1-q1',
    section: IeltsSectionNumber.r1,
    answerType: IeltsAnswerType.multipleChoice,
    passageId: 'r1-passage',
    groupInstructionEn: _tfNgGroupInstruction1,
    promptEn: 'Membership of beekeeping associations has increased in many big cities since 2010.',
    options: const ['True', 'False', 'Not Given'],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: Membership of beekeeping associations has increased in '
        'many big cities since 2010. '
        '· Đáp án: True '
        '· Giải thích: Đoạn A nói rõ số hội viên đã tăng gấp 3 ("tripled") '
        'ở nhiều thành phố lớn kể từ 2010. '
        '· Dịch: Số hội viên các hội nuôi ong đã tăng ở nhiều thành phố lớn '
        'từ năm 2010 - Đúng.',
  ),
  IeltsQuestion(
    id: 'r1-q2',
    section: IeltsSectionNumber.r1,
    answerType: IeltsAnswerType.multipleChoice,
    passageId: 'r1-passage',
    groupInstructionEn: _tfNgGroupInstruction1,
    promptEn: 'City governments have always encouraged people to keep bees.',
    options: const ['True', 'False', 'Not Given'],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: City governments have always encouraged people to '
        'keep bees. '
        '· Đáp án: False '
        '· Giải thích: Đoạn A nói chính quyền "rather than restricting it, '
        'as they once did" - tức TRƯỚC ĐÂY từng hạn chế, không phải luôn '
        'khuyến khích. '
        '· Dịch: Chính quyền thành phố luôn khuyến khích nuôi ong - Sai.',
  ),
  IeltsQuestion(
    id: 'r1-q3',
    section: IeltsSectionNumber.r1,
    answerType: IeltsAnswerType.multipleChoice,
    passageId: 'r1-passage',
    groupInstructionEn: _tfNgGroupInstruction1,
    promptEn: 'Almost all food crops rely on bee pollination.',
    options: const ['True', 'False', 'Not Given'],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: Almost all food crops rely on bee pollination. '
        '· Đáp án: False '
        '· Giải thích: Đoạn B nói chỉ khoảng MỘT PHẦN BA ("one-third") cây '
        'trồng phụ thuộc vào thụ phấn của ong, không phải hầu hết. '
        '· Dịch: Hầu hết cây lương thực phụ thuộc vào thụ phấn của ong - '
        'Sai.',
  ),
  IeltsQuestion(
    id: 'r1-q4',
    section: IeltsSectionNumber.r1,
    answerType: IeltsAnswerType.multipleChoice,
    passageId: 'r1-passage',
    groupInstructionEn: _tfNgGroupInstruction1,
    promptEn: 'Wild bee populations in the countryside have been affected by pesticide use.',
    options: const ['True', 'False', 'Not Given'],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: Wild bee populations in the countryside have been '
        'affected by pesticide use. '
        '· Đáp án: True '
        '· Giải thích: Đoạn B nói trực tiếp quần thể ong hoang dã ở nông '
        'thôn suy giảm do dùng thuốc trừ sâu. '
        '· Dịch: Quần thể ong hoang dã ở nông thôn bị ảnh hưởng bởi thuốc '
        'trừ sâu - Đúng.',
  ),
  IeltsQuestion(
    id: 'r1-q5',
    section: IeltsSectionNumber.r1,
    answerType: IeltsAnswerType.multipleChoice,
    passageId: 'r1-passage',
    groupInstructionEn: _tfNgGroupInstruction1,
    promptEn: 'The maximum number of hives allowed per household is the same in every city.',
    options: const ['True', 'False', 'Not Given'],
    correctIndex: 2,
    explanationVi:
        '· Câu hỏi: The maximum number of hives allowed per household is '
        'the same in every city. '
        '· Đáp án: Not Given '
        '· Giải thích: Bài đọc chỉ nói có quy định về kích cỡ đàn ong tối '
        'đa, KHÔNG nói con số đó có giống nhau giữa các thành phố hay '
        'không. '
        '· Dịch: Số tổ ong tối đa cho phép mỗi hộ là giống nhau ở mọi thành '
        'phố - Không có thông tin.',
  ),
  IeltsQuestion(
    id: 'r1-q6',
    section: IeltsSectionNumber.r1,
    answerType: IeltsAnswerType.multipleChoice,
    passageId: 'r1-passage',
    groupInstructionEn: _matchingInfoGroupInstruction1,
    promptEn:
        'a description of how beekeepers avoid startling people in the street',
    options: const ['A', 'B', 'C', 'D', 'E', 'F'],
    correctIndex: 3,
    explanationVi:
        '· Câu hỏi: a description of how beekeepers avoid startling people '
        'in the street '
        '· Đáp án: D '
        '· Giải thích: Đoạn D mô tả việc đặt tổ ong trên mái nhà, cách xa '
        'người đi đường bên dưới. '
        '· Dịch: Mô tả cách người nuôi ong tránh làm người đi đường hoảng '
        'sợ → Đoạn D.',
  ),
  IeltsQuestion(
    id: 'r1-q7',
    section: IeltsSectionNumber.r1,
    answerType: IeltsAnswerType.multipleChoice,
    passageId: 'r1-passage',
    groupInstructionEn: _matchingInfoGroupInstruction1,
    promptEn: 'an example of a financial benefit for urban beekeepers',
    options: const ['A', 'B', 'C', 'D', 'E', 'F'],
    correctIndex: 4,
    explanationVi:
        '· Câu hỏi: an example of a financial benefit for urban beekeepers '
        '· Đáp án: E '
        '· Giải thích: Đoạn E nói về việc các doanh nghiệp nhỏ bán "mật ong '
        'khu phố" - lợi ích tài chính rõ ràng. '
        '· Dịch: Ví dụ về lợi ích tài chính cho người nuôi ong đô thị → '
        'Đoạn E.',
  ),
  IeltsQuestion(
    id: 'r1-q8',
    section: IeltsSectionNumber.r1,
    answerType: IeltsAnswerType.multipleChoice,
    passageId: 'r1-passage',
    groupInstructionEn: _matchingInfoGroupInstruction1,
    promptEn: 'a reason why some people are reluctant to allow beehives nearby',
    options: const ['A', 'B', 'C', 'D', 'E', 'F'],
    correctIndex: 2,
    explanationVi:
        '· Câu hỏi: a reason why some people are reluctant to allow '
        'beehives nearby '
        '· Đáp án: C '
        '· Giải thích: Đoạn C nói về nỗi lo bị ong đốt/dị ứng và khiếu nại '
        'từ hàng xóm. '
        '· Dịch: Lý do một số người ngần ngại cho đặt tổ ong gần nhà → '
        'Đoạn C.',
  ),
  IeltsQuestion(
    id: 'r1-q9',
    section: IeltsSectionNumber.r1,
    answerType: IeltsAnswerType.multipleChoice,
    passageId: 'r1-passage',
    groupInstructionEn: _matchingInfoGroupInstruction1,
    promptEn: 'government measures intended to support beekeepers in future',
    options: const ['A', 'B', 'C', 'D', 'E', 'F'],
    correctIndex: 5,
    explanationVi:
        '· Câu hỏi: government measures intended to support beekeepers in '
        'future '
        '· Đáp án: F '
        '· Giải thích: Đoạn F nói về các khoá đào tạo miễn phí và nới lỏng '
        'quy hoạch của chính quyền. '
        '· Dịch: Các biện pháp của chính quyền nhằm hỗ trợ người nuôi ong '
        'trong tương lai → Đoạn F.',
  ),
  const IeltsQuestion(
    id: 'r1-q10',
    section: IeltsSectionNumber.r1,
    answerType: IeltsAnswerType.shortAnswer,
    passageId: 'r1-passage',
    groupInstructionEn: _sentenceCompletionGroupInstruction1,
    promptEn:
        'Bees are important because they help with the ___ of many food crops.',
    acceptedAnswers: ['pollination', 'pollinating'],
    explanationVi:
        '· Câu hỏi: Bees are important because they help with the ___ of '
        'many food crops. '
        '· Đáp án: pollination '
        '· Giải thích: Đoạn B nói bees đóng vai trò thụ phấn ("pollinating '
        'plants") cho cây trồng. '
        '· Dịch: Ong quan trọng vì giúp thụ phấn cho nhiều loại cây lương '
        'thực.',
  ),
  const IeltsQuestion(
    id: 'r1-q11',
    section: IeltsSectionNumber.r1,
    answerType: IeltsAnswerType.shortAnswer,
    passageId: 'r1-passage',
    groupInstructionEn: _sentenceCompletionGroupInstruction1,
    promptEn:
        'A common reason inexperienced beekeepers quit is complaints from ___.',
    acceptedAnswers: ['neighbours', 'neighbors'],
    explanationVi:
        '· Câu hỏi: A common reason inexperienced beekeepers quit is '
        'complaints from ___. '
        '· Đáp án: neighbours '
        '· Giải thích: Đoạn C nói khiếu nại từ hàng xóm là lý do phổ biến '
        'khiến người mới bỏ cuộc. '
        '· Dịch: Một lý do phổ biến khiến người nuôi ong thiếu kinh nghiệm '
        'từ bỏ là khiếu nại từ hàng xóm.',
  ),
  const IeltsQuestion(
    id: 'r1-q12',
    section: IeltsSectionNumber.r1,
    answerType: IeltsAnswerType.shortAnswer,
    passageId: 'r1-passage',
    groupInstructionEn: _sentenceCompletionGroupInstruction1,
    promptEn: 'Honey taken from city hives is often praised for having a more complex ___.',
    acceptedAnswers: ['flavour', 'flavor'],
    explanationVi:
        '· Câu hỏi: Honey taken from city hives is often praised for '
        'having a more complex ___. '
        '· Đáp án: flavour '
        '· Giải thích: Đoạn E nói mật ong đô thị có hương vị phức tạp hơn '
        '("more complex, layered flavour"). '
        '· Dịch: Mật ong lấy từ tổ trong thành phố thường được khen vì có '
        'hương vị phức tạp hơn.',
  ),
  const IeltsQuestion(
    id: 'r1-q13',
    section: IeltsSectionNumber.r1,
    answerType: IeltsAnswerType.shortAnswer,
    passageId: 'r1-passage',
    groupInstructionEn: _sentenceCompletionGroupInstruction1,
    promptEn: 'Some cities now provide free ___ courses to help beginners start beekeeping.',
    acceptedAnswers: ['training'],
    explanationVi:
        '· Câu hỏi: Some cities now provide free ___ courses to help '
        'beginners start beekeeping. '
        '· Đáp án: training '
        '· Giải thích: Đoạn F nói một số thành phố cung cấp khoá "training '
        'courses" miễn phí. '
        '· Dịch: Một số thành phố hiện cung cấp khoá đào tạo miễn phí giúp '
        'người mới bắt đầu nuôi ong.',
  ),
];

// ============================================================================
// READING PASSAGE 2 - "Renewable Energy in Small Island Nations" (~13 cau,
// 14-26)
// ============================================================================

const _readingPassage2 = IeltsPassage(
  id: 'r2-passage',
  titleEn: 'Renewable Energy in Small Island Nations',
  paragraphsEn: [
    'A. For decades, most small island nations have relied almost '
        'entirely on imported diesel fuel to generate electricity. Because '
        'fuel must be shipped in, often across vast distances, the cost of '
        'electricity on many islands is several times higher than in '
        'neighbouring mainland countries, and supply can be disrupted '
        'whenever bad weather delays a delivery. This dependence has long '
        'been recognised as a serious economic vulnerability.',
    'B. In the last ten years, however, the falling price of solar '
        'panels has made solar power an increasingly attractive '
        'alternative. Many islands lie in tropical regions with abundant, '
        'reliable sunshine year-round, and the cost of installing a solar '
        'array has dropped by more than seventy percent since 2010. As a '
        'result, several island governments have begun replacing '
        'diesel generators with large-scale solar installations, often on '
        'unused land near airports or ports.',
    'C. Wind power has also played a growing role, particularly on '
        'islands with strong, consistent trade winds. Rather than relying '
        'on a single source, engineers on several islands have designed '
        'hybrid systems that combine wind turbines with solar panels, '
        'since wind tends to blow most strongly at night and in the early '
        'morning, precisely when solar panels produce no electricity at '
        'all. Combining the two sources in this way helps smooth out gaps '
        'in supply throughout the day.',
    'D. Despite this progress, island nations still face considerable '
        'obstacles. Because sunlight and wind are not constant, storing '
        'surplus electricity in batteries for use after dark or during '
        'calm weather remains expensive. Many islands also lack local '
        'engineers trained to maintain sophisticated renewable energy '
        'equipment, meaning that technicians sometimes have to be flown '
        'in from abroad for even minor repairs. Securing the initial '
        'financing to build large solar or wind installations can be '
        'equally difficult for governments with limited budgets.',
    'E. To help overcome these barriers, a number of international '
        'organisations and wealthier nations have stepped in to provide '
        'grants, low-interest loans, and technical training. Under '
        'several such partnerships, foreign engineers spend months on an '
        'island helping to install new equipment while simultaneously '
        'training local staff, so that maintenance can eventually be '
        'carried out entirely by residents rather than outside experts.',
    'F. The small island of Korovou offers a striking example of what '
        'is possible. Just eight years ago, Korovou generated almost all '
        'of its electricity from an ageing diesel plant. Today, following '
        'a combined investment from its own government and an '
        'international development fund, more than ninety percent of the '
        'island\'s electricity comes from a hybrid solar-and-wind system, '
        'and residents report far fewer power outages than before. '
        'Officials from several neighbouring nations have since visited '
        'Korovou to study its approach.',
  ],
);

const _headingsGroupInstruction2 =
    'Questions 14-18. Reading Passage 2 has six paragraphs, A-F. Choose the '
    'correct heading for paragraphs B-F from the list of headings below.\n'
    'i. A comparison of costs between fuel types\n'
    'ii. Combining energy from more than one natural source\n'
    'iii. Financial and technical hurdles to overcome\n'
    'iv. Falling equipment prices support one technology\n'
    'v. Outside assistance for developing infrastructure\n'
    'vi. A model for other nations to follow\n'
    'vii. The environmental risks of fossil fuels\n'
    'viii. Government subsidies for imported fuel';

const _headingOptions2 = [
  'i. A comparison of costs between fuel types',
  'ii. Combining energy from more than one natural source',
  'iii. Financial and technical hurdles to overcome',
  'iv. Falling equipment prices support one technology',
  'v. Outside assistance for developing infrastructure',
  'vi. A model for other nations to follow',
  'vii. The environmental risks of fossil fuels',
  'viii. Government subsidies for imported fuel',
];

const _mcGroupInstruction2 =
    'Questions 19-22. Choose the correct letter, A, B, C or D.';

const _ynNgGroupInstruction2 =
    'Questions 23-26. Do the following statements agree with the claims of '
    'the writer in Reading Passage 2? Write YES if the statement agrees '
    'with the claims of the writer, NO if the statement contradicts the '
    'claims of the writer, or NOT GIVEN if it is impossible to say what '
    'the writer thinks about this.';

final _readingPassage2Questions = <IeltsQuestion>[
  IeltsQuestion(
    id: 'r2-q14',
    section: IeltsSectionNumber.r2,
    answerType: IeltsAnswerType.multipleChoice,
    passageId: 'r2-passage',
    groupInstructionEn: _headingsGroupInstruction2,
    promptEn: 'Paragraph B',
    options: _headingOptions2,
    correctIndex: 3,
    explanationVi:
        '· Câu hỏi: Paragraph B '
        '· Đáp án: iv. Falling equipment prices support one technology '
        '· Giải thích: Đoạn B nói giá tấm pin mặt trời giảm hơn 70% từ '
        '2010, thúc đẩy năng lượng mặt trời phát triển. '
        '· Dịch: Đoạn B → tiêu đề iv (Giá thiết bị giảm thúc đẩy 1 công '
        'nghệ).',
  ),
  IeltsQuestion(
    id: 'r2-q15',
    section: IeltsSectionNumber.r2,
    answerType: IeltsAnswerType.multipleChoice,
    passageId: 'r2-passage',
    groupInstructionEn: _headingsGroupInstruction2,
    promptEn: 'Paragraph C',
    options: _headingOptions2,
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: Paragraph C '
        '· Đáp án: ii. Combining energy from more than one natural source '
        '· Giải thích: Đoạn C nói về hệ thống lai kết hợp gió và mặt trời '
        'để bù trừ nhau. '
        '· Dịch: Đoạn C → tiêu đề ii (Kết hợp năng lượng từ nhiều nguồn tự '
        'nhiên).',
  ),
  IeltsQuestion(
    id: 'r2-q16',
    section: IeltsSectionNumber.r2,
    answerType: IeltsAnswerType.multipleChoice,
    passageId: 'r2-passage',
    groupInstructionEn: _headingsGroupInstruction2,
    promptEn: 'Paragraph D',
    options: _headingOptions2,
    correctIndex: 2,
    explanationVi:
        '· Câu hỏi: Paragraph D '
        '· Đáp án: iii. Financial and technical hurdles to overcome '
        '· Giải thích: Đoạn D nói về khó khăn lưu trữ điện, thiếu kỹ '
        'thuật viên, và huy động vốn. '
        '· Dịch: Đoạn D → tiêu đề iii (Rào cản tài chính và kỹ thuật).',
  ),
  IeltsQuestion(
    id: 'r2-q17',
    section: IeltsSectionNumber.r2,
    answerType: IeltsAnswerType.multipleChoice,
    passageId: 'r2-passage',
    groupInstructionEn: _headingsGroupInstruction2,
    promptEn: 'Paragraph E',
    options: _headingOptions2,
    correctIndex: 4,
    explanationVi:
        '· Câu hỏi: Paragraph E '
        '· Đáp án: v. Outside assistance for developing infrastructure '
        '· Giải thích: Đoạn E nói về hỗ trợ quốc tế (viện trợ, khoản vay, '
        'đào tạo kỹ thuật). '
        '· Dịch: Đoạn E → tiêu đề v (Hỗ trợ từ bên ngoài để phát triển hạ '
        'tầng).',
  ),
  IeltsQuestion(
    id: 'r2-q18',
    section: IeltsSectionNumber.r2,
    answerType: IeltsAnswerType.multipleChoice,
    passageId: 'r2-passage',
    groupInstructionEn: _headingsGroupInstruction2,
    promptEn: 'Paragraph F',
    options: _headingOptions2,
    correctIndex: 5,
    explanationVi:
        '· Câu hỏi: Paragraph F '
        '· Đáp án: vi. A model for other nations to follow '
        '· Giải thích: Đoạn F kể về đảo Korovou, được các nước láng giềng '
        'đến học hỏi mô hình. '
        '· Dịch: Đoạn F → tiêu đề vi (Một hình mẫu cho các quốc gia khác '
        'noi theo).',
  ),
  IeltsQuestion(
    id: 'r2-q19',
    section: IeltsSectionNumber.r2,
    answerType: IeltsAnswerType.multipleChoice,
    passageId: 'r2-passage',
    groupInstructionEn: _mcGroupInstruction2,
    promptEn:
        'Why has electricity traditionally been expensive on small islands?',
    options: const [
      'The climate makes power generation difficult.',
      'Fuel has to be transported over long distances.',
      'Islands have very few electricity customers.',
      'Diesel generators are inefficient machines.',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: Why has electricity traditionally been expensive on '
        'small islands? '
        '· Đáp án: B. Fuel has to be transported over long distances. '
        '· Giải thích: Đoạn A nói nhiên liệu phải vận chuyển từ xa nên chi '
        'phí điện cao hơn nhiều. '
        '· Dịch: Vì sao điện ở các đảo nhỏ trước đây thường đắt đỏ? → Vì '
        'nhiên liệu phải vận chuyển từ xa.',
  ),
  IeltsQuestion(
    id: 'r2-q20',
    section: IeltsSectionNumber.r2,
    answerType: IeltsAnswerType.multipleChoice,
    passageId: 'r2-passage',
    groupInstructionEn: _mcGroupInstruction2,
    promptEn: 'Why do some islands combine wind and solar power?',
    options: const [
      'Wind turbines are cheaper than solar panels.',
      'Wind and solar produce power at different times of day.',
      'Combining them requires less land.',
      'International donors require both technologies.',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: Why do some islands combine wind and solar power? '
        '· Đáp án: B. Wind and solar produce power at different times of '
        'day. '
        '· Giải thích: Đoạn C nói gió thổi mạnh nhất vào ban đêm/sáng sớm, '
        'đúng lúc pin mặt trời không tạo ra điện. '
        '· Dịch: Vì sao một số đảo kết hợp điện gió và điện mặt trời? → Vì '
        'gió và nắng tạo ra điện vào các thời điểm khác nhau trong ngày.',
  ),
  IeltsQuestion(
    id: 'r2-q21',
    section: IeltsSectionNumber.r2,
    answerType: IeltsAnswerType.multipleChoice,
    passageId: 'r2-passage',
    groupInstructionEn: _mcGroupInstruction2,
    promptEn: 'What is one long-term goal of the foreign engineers mentioned in the passage?',
    options: const [
      'To operate the equipment permanently themselves',
      'To sell equipment to island governments',
      'To train local staff to maintain equipment',
      'To relocate to the islands permanently',
    ],
    correctIndex: 2,
    explanationVi:
        '· Câu hỏi: What is one long-term goal of the foreign engineers '
        'mentioned in the passage? '
        '· Đáp án: C. To train local staff to maintain equipment '
        '· Giải thích: Đoạn E nói kỹ sư nước ngoài vừa lắp đặt vừa đào tạo '
        'nhân sự địa phương để họ tự bảo trì sau này. '
        '· Dịch: Mục tiêu dài hạn của các kỹ sư nước ngoài là gì? → Đào '
        'tạo nhân sự địa phương để tự bảo trì thiết bị.',
  ),
  IeltsQuestion(
    id: 'r2-q22',
    section: IeltsSectionNumber.r2,
    answerType: IeltsAnswerType.multipleChoice,
    passageId: 'r2-passage',
    groupInstructionEn: _mcGroupInstruction2,
    promptEn: 'What percentage of Korovou\'s electricity now comes from renewable sources?',
    options: const ['Around 50%', 'Around 70%', 'More than 90%', '100%'],
    correctIndex: 2,
    explanationVi:
        '· Câu hỏi: What percentage of Korovou\'s electricity now comes '
        'from renewable sources? '
        '· Đáp án: C. More than 90% '
        '· Giải thích: Đoạn F nói rõ hơn 90% điện của đảo Korovou hiện đến '
        'từ hệ thống lai gió-mặt trời. '
        '· Dịch: Bao nhiêu phần trăm điện của Korovou hiện từ năng lượng '
        'tái tạo? → Hơn 90%.',
  ),
  IeltsQuestion(
    id: 'r2-q23',
    section: IeltsSectionNumber.r2,
    answerType: IeltsAnswerType.multipleChoice,
    passageId: 'r2-passage',
    groupInstructionEn: _ynNgGroupInstruction2,
    promptEn: 'Solar panel prices have fallen significantly since 2010.',
    options: const ['Yes', 'No', 'Not Given'],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: Solar panel prices have fallen significantly since '
        '2010. '
        '· Đáp án: Yes '
        '· Giải thích: Đoạn B nói giá lắp đặt giảm hơn 70% từ 2010. '
        '· Dịch: Giá tấm pin mặt trời đã giảm đáng kể từ 2010 - Đúng theo '
        'tác giả.',
  ),
  IeltsQuestion(
    id: 'r2-q24',
    section: IeltsSectionNumber.r2,
    answerType: IeltsAnswerType.multipleChoice,
    passageId: 'r2-passage',
    groupInstructionEn: _ynNgGroupInstruction2,
    promptEn: 'Battery storage for renewable energy is currently inexpensive.',
    options: const ['Yes', 'No', 'Not Given'],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: Battery storage for renewable energy is currently '
        'inexpensive. '
        '· Đáp án: No '
        '· Giải thích: Đoạn D nói việc lưu trữ điện dư vào pin vẫn còn '
        '"expensive" (đắt đỏ). '
        '· Dịch: Lưu trữ điện bằng pin hiện nay rẻ - Sai theo tác giả.',
  ),
  IeltsQuestion(
    id: 'r2-q25',
    section: IeltsSectionNumber.r2,
    answerType: IeltsAnswerType.multipleChoice,
    passageId: 'r2-passage',
    groupInstructionEn: _ynNgGroupInstruction2,
    promptEn: 'Korovou received financial help from an international development fund.',
    options: const ['Yes', 'No', 'Not Given'],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: Korovou received financial help from an international '
        'development fund. '
        '· Đáp án: Yes '
        '· Giải thích: Đoạn F nói khoản đầu tư đến từ cả chính phủ đảo và '
        'một quỹ phát triển quốc tế. '
        '· Dịch: Korovou nhận hỗ trợ tài chính từ một quỹ phát triển quốc '
        'tế - Đúng theo tác giả.',
  ),
  IeltsQuestion(
    id: 'r2-q26',
    section: IeltsSectionNumber.r2,
    answerType: IeltsAnswerType.multipleChoice,
    passageId: 'r2-passage',
    groupInstructionEn: _ynNgGroupInstruction2,
    promptEn: 'Every small island nation now generates most of its power from renewable sources.',
    options: const ['Yes', 'No', 'Not Given'],
    correctIndex: 2,
    explanationVi:
        '· Câu hỏi: Every small island nation now generates most of its '
        'power from renewable sources. '
        '· Đáp án: Not Given '
        '· Giải thích: Bài chỉ nêu ví dụ Korovou và xu hướng chung, KHÔNG '
        'khẳng định TẤT CẢ các đảo nhỏ đều đã đạt được điều này. '
        '· Dịch: Mọi quốc đảo nhỏ hiện đều tạo ra phần lớn điện từ năng '
        'lượng tái tạo - Không có thông tin.',
  ),
];

// ============================================================================
// READING PASSAGE 3 - "The Psychology of Decision-Making" (~14 cau, 27-40)
// ============================================================================

const _readingPassage3 = IeltsPassage(
  id: 'r3-passage',
  titleEn: 'The Psychology of Decision-Making',
  paragraphsEn: [
    'A. Classical economic theory long assumed that human beings make '
        'decisions rationally, carefully weighing every available option '
        'against its costs and benefits before arriving at the choice '
        'that maximises their personal advantage. Over the past half '
        'century, however, psychologists have accumulated substantial '
        'evidence that real decision-making rarely resembles this tidy '
        'model. Instead, people routinely rely on mental shortcuts, are '
        'swayed by irrelevant details, and sometimes act in ways that '
        'plainly contradict their own stated preferences.',
    'B. One influential concept to emerge from this research is the '
        'idea of the "heuristic" - a simple mental shortcut that allows '
        'people to make judgements quickly without conducting a full '
        'analysis. The availability heuristic, for example, leads people '
        'to judge how common or likely an event is based on how easily '
        'examples come to mind, rather than on actual statistics. This '
        'explains why many people overestimate the danger of dramatic but '
        'rare events, such as plane crashes, while underestimating far '
        'more common risks that receive less media attention.',
    'C. Another well-documented pattern is loss aversion: the tendency '
        'for people to feel the pain of a loss more intensely than the '
        'pleasure of an equivalent gain. In controlled experiments, most '
        'participants required a potential gain roughly twice the size of '
        'a potential loss before they were willing to accept a gamble, '
        'even when the mathematical odds were identical. This asymmetry '
        'helps explain why investors often hold onto a falling stock far '
        'longer than logic would suggest, hoping to avoid locking in a '
        'loss.',
    'D. The number of options available can also distort decision-'
        'making, a phenomenon researchers call choice overload. In one '
        'frequently cited study, shoppers offered a smaller selection of '
        'jam flavours at a tasting table were considerably more likely to '
        'actually purchase a jar than those offered a much larger '
        'selection, even though the larger display initially attracted '
        'more browsers. Having too many options, it seems, can make the '
        'act of choosing so mentally taxing that people simply choose '
        'nothing at all.',
    'E. The quality of a decision can also depend heavily on when, '
        'rather than what, is being decided. Making a long series of '
        'decisions appears to gradually deplete a limited mental '
        'resource, a state researchers refer to as decision fatigue. '
        'Several studies of professionals who must make repeated '
        'judgement calls throughout the working day, such as reviewing '
        'a long list of applications, have found that decisions made '
        'later in a session are measurably more likely to default to the '
        'easiest or most cautious option, regardless of the specific '
        'merits of each case.',
    'F. Recognising these predictable patterns has given rise to a '
        'practical field known as choice architecture, which involves '
        'deliberately designing the way options are presented so that '
        'people are more likely to make choices that benefit them. A '
        'well-known example is automatically enrolling employees in a '
        'workplace pension scheme, while still allowing them to opt out '
        'if they wish. Because most people simply accept whatever default '
        'option is presented to them, this single design change has been '
        'shown to dramatically increase retirement savings rates without '
        'removing anyone\'s freedom to choose otherwise.',
  ],
);

const _mcGroupInstruction3 =
    'Questions 27-30. Choose the correct letter, A, B, C or D.';

const _summaryGroupInstruction3 =
    'Questions 31-36. Complete the summary below. Choose NO MORE THAN TWO '
    'WORDS from the passage for each answer.';

const _tfNgGroupInstruction3 =
    'Questions 37-40. Do the following statements agree with the '
    'information given in Reading Passage 3? Write TRUE if the statement '
    'agrees with the information, FALSE if the statement contradicts the '
    'information, or NOT GIVEN if there is no information on this.';

final _readingPassage3Questions = <IeltsQuestion>[
  IeltsQuestion(
    id: 'r3-q27',
    section: IeltsSectionNumber.r3,
    answerType: IeltsAnswerType.multipleChoice,
    passageId: 'r3-passage',
    groupInstructionEn: _mcGroupInstruction3,
    promptEn: 'What did classical economic theory assume about human decision-making?',
    options: const [
      'It is guided mainly by emotion.',
      'It is carried out rationally.',
      'It depends on mental shortcuts.',
      'It is impossible to study scientifically.',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: What did classical economic theory assume about '
        'human decision-making? '
        '· Đáp án: B. It is carried out rationally. '
        '· Giải thích: Đoạn A nói lý thuyết kinh tế cổ điển cho rằng con '
        'người ra quyết định một cách hợp lý (rationally). '
        '· Dịch: Lý thuyết kinh tế cổ điển giả định gì về việc ra quyết '
        'định? → Nó được thực hiện một cách hợp lý.',
  ),
  IeltsQuestion(
    id: 'r3-q28',
    section: IeltsSectionNumber.r3,
    answerType: IeltsAnswerType.multipleChoice,
    passageId: 'r3-passage',
    groupInstructionEn: _mcGroupInstruction3,
    promptEn: 'According to the passage, why do people overestimate the danger of plane crashes?',
    options: const [
      'Plane crashes happen more often than most people think.',
      'The media exaggerates statistics about air travel.',
      'Dramatic events are easier to recall than common ones.',
      'People distrust the airline industry.',
    ],
    correctIndex: 2,
    explanationVi:
        '· Câu hỏi: According to the passage, why do people overestimate '
        'the danger of plane crashes? '
        '· Đáp án: C. Dramatic events are easier to recall than common '
        'ones. '
        '· Giải thích: Đoạn B nói availability heuristic khiến người ta '
        'đánh giá rủi ro dựa vào việc ví dụ đó dễ nhớ lại đến đâu, không '
        'phải số liệu thật. '
        '· Dịch: Vì sao người ta đánh giá quá cao nguy hiểm của tai nạn '
        'máy bay? → Các sự kiện gây ấn tượng mạnh dễ được nhớ lại hơn.',
  ),
  IeltsQuestion(
    id: 'r3-q29',
    section: IeltsSectionNumber.r3,
    answerType: IeltsAnswerType.multipleChoice,
    passageId: 'r3-passage',
    groupInstructionEn: _mcGroupInstruction3,
    promptEn: 'In the experiments described in paragraph C, what did most participants require?',
    options: const [
      'A guaranteed gain before taking any risk',
      'A potential gain about twice the size of a potential loss',
      'Equal odds of winning and losing',
      'A written guarantee against loss',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: In the experiments described in paragraph C, what did '
        'most participants require? '
        '· Đáp án: B. A potential gain about twice the size of a '
        'potential loss '
        '· Giải thích: Đoạn C nói người tham gia cần khoản lợi tiềm năng '
        'gấp khoảng 2 lần khoản lỗ tiềm năng mới chấp nhận đánh cược. '
        '· Dịch: Trong thí nghiệm ở đoạn C, hầu hết người tham gia yêu cầu '
        'điều gì? → Khoản lợi tiềm năng gấp khoảng 2 lần khoản lỗ tiềm '
        'năng.',
  ),
  IeltsQuestion(
    id: 'r3-q30',
    section: IeltsSectionNumber.r3,
    answerType: IeltsAnswerType.multipleChoice,
    passageId: 'r3-passage',
    groupInstructionEn: _mcGroupInstruction3,
    promptEn:
        'What happened in the jam-tasting study mentioned in paragraph D?',
    options: const [
      'The larger display attracted fewer browsers but more buyers.',
      'The smaller display attracted more browsers and more buyers.',
      'The smaller display attracted fewer browsers but more buyers.',
      'Both displays led to identical purchase rates.',
    ],
    correctIndex: 2,
    explanationVi:
        '· Câu hỏi: What happened in the jam-tasting study mentioned in '
        'paragraph D? '
        '· Đáp án: C. The smaller display attracted fewer browsers but '
        'more buyers. '
        '· Giải thích: Đoạn D nói bàn có ít lựa chọn hơn thu hút ít người '
        'xem hơn ban đầu nhưng lại có tỉ lệ MUA cao hơn hẳn. '
        '· Dịch: Điều gì xảy ra trong nghiên cứu về mứt ở đoạn D? → Bàn ít '
        'lựa chọn hơn thu hút ít người xem hơn nhưng bán được nhiều hơn.',
  ),
  const IeltsQuestion(
    id: 'r3-q31',
    section: IeltsSectionNumber.r3,
    answerType: IeltsAnswerType.shortAnswer,
    passageId: 'r3-passage',
    groupInstructionEn: _summaryGroupInstruction3,
    promptEn: 'Psychologists have found that people often rely on mental shortcuts called ___ rather than careful analysis.',
    acceptedAnswers: ['heuristics', 'heuristic'],
    explanationVi:
        '· Chỗ trống (31): mental shortcuts called ___ '
        '· Đáp án: heuristics '
        '· Giải thích: Đoạn B định nghĩa "heuristic" là 1 lối tắt tư duy. '
        '· Dịch: Các nhà tâm lý học phát hiện con người thường dùng "lối '
        'tắt tư duy" (heuristics) thay vì phân tích kỹ.',
  ),
  const IeltsQuestion(
    id: 'r3-q32',
    section: IeltsSectionNumber.r3,
    answerType: IeltsAnswerType.shortAnswer,
    passageId: 'r3-passage',
    groupInstructionEn: _summaryGroupInstruction3,
    promptEn: 'One such shortcut, the availability ___, causes people to misjudge risk based on how easily examples come to mind.',
    acceptedAnswers: ['heuristic'],
    explanationVi:
        '· Chỗ trống (32): the availability ___ '
        '· Đáp án: heuristic '
        '· Giải thích: Đoạn B gọi tên chính xác là "availability '
        'heuristic". '
        '· Dịch: "Lối tắt tính sẵn có" (availability heuristic) khiến '
        'người ta đánh giá sai rủi ro.',
  ),
  const IeltsQuestion(
    id: 'r3-q33',
    section: IeltsSectionNumber.r3,
    answerType: IeltsAnswerType.shortAnswer,
    passageId: 'r3-passage',
    groupInstructionEn: _summaryGroupInstruction3,
    promptEn: 'People also show ___, feeling losses more strongly than equivalent gains.',
    acceptedAnswers: ['loss aversion'],
    explanationVi:
        '· Chỗ trống (33): show ___, feeling losses more strongly '
        '· Đáp án: loss aversion '
        '· Giải thích: Đoạn C định nghĩa hiện tượng "loss aversion" (ác '
        'cảm với mất mát). '
        '· Dịch: Con người cũng thể hiện "ác cảm với mất mát" (loss '
        'aversion), cảm nhận mất mát mạnh hơn lợi ích tương đương.',
  ),
  const IeltsQuestion(
    id: 'r3-q34',
    section: IeltsSectionNumber.r3,
    answerType: IeltsAnswerType.shortAnswer,
    passageId: 'r3-passage',
    groupInstructionEn: _summaryGroupInstruction3,
    promptEn: 'Meanwhile, offering too many choices can lead to ___, making people less likely to choose anything.',
    acceptedAnswers: ['choice overload'],
    explanationVi:
        '· Chỗ trống (34): too many choices can lead to ___ '
        '· Đáp án: choice overload '
        '· Giải thích: Đoạn D gọi hiện tượng này là "choice overload" (quá '
        'tải lựa chọn). '
        '· Dịch: Có quá nhiều lựa chọn có thể dẫn đến "quá tải lựa chọn" '
        '(choice overload).',
  ),
  const IeltsQuestion(
    id: 'r3-q35',
    section: IeltsSectionNumber.r3,
    answerType: IeltsAnswerType.shortAnswer,
    passageId: 'r3-passage',
    groupInstructionEn: _summaryGroupInstruction3,
    promptEn: 'Making many decisions in a row can also cause ___, lowering the quality of later choices.',
    acceptedAnswers: ['decision fatigue'],
    explanationVi:
        '· Chỗ trống (35): many decisions in a row can also cause ___ '
        '· Đáp án: decision fatigue '
        '· Giải thích: Đoạn E gọi hiện tượng này là "decision fatigue" '
        '(mệt mỏi vì ra quyết định). '
        '· Dịch: Ra nhiều quyết định liên tiếp cũng có thể gây ra "mệt mỏi '
        'quyết định" (decision fatigue).',
  ),
  const IeltsQuestion(
    id: 'r3-q36',
    section: IeltsSectionNumber.r3,
    answerType: IeltsAnswerType.shortAnswer,
    passageId: 'r3-passage',
    groupInstructionEn: _summaryGroupInstruction3,
    promptEn: 'These findings have led to the field of choice ___, which designs how options are presented to help people choose well.',
    acceptedAnswers: ['architecture'],
    explanationVi:
        '· Chỗ trống (36): the field of choice ___ '
        '· Đáp án: architecture '
        '· Giải thích: Đoạn F gọi lĩnh vực này là "choice architecture" '
        '(kiến trúc lựa chọn). '
        '· Dịch: Những phát hiện này dẫn tới lĩnh vực "kiến trúc lựa chọn" '
        '(choice architecture).',
  ),
  IeltsQuestion(
    id: 'r3-q37',
    section: IeltsSectionNumber.r3,
    answerType: IeltsAnswerType.multipleChoice,
    passageId: 'r3-passage',
    groupInstructionEn: _tfNgGroupInstruction3,
    promptEn: 'Decisions made later in a working session tend to be riskier than earlier ones.',
    options: const ['True', 'False', 'Not Given'],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: Decisions made later in a working session tend to be '
        'riskier than earlier ones. '
        '· Đáp án: False '
        '· Giải thích: Đoạn E nói quyết định về sau có xu hướng chọn '
        'phương án AN TOÀN/dễ nhất (cautious), không phải rủi ro hơn. '
        '· Dịch: Quyết định vào cuối phiên làm việc có xu hướng rủi ro hơn '
        '- Sai.',
  ),
  IeltsQuestion(
    id: 'r3-q38',
    section: IeltsSectionNumber.r3,
    answerType: IeltsAnswerType.multipleChoice,
    passageId: 'r3-passage',
    groupInstructionEn: _tfNgGroupInstruction3,
    promptEn: 'Automatically enrolling employees in a pension scheme removes their freedom to opt out.',
    options: const ['True', 'False', 'Not Given'],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: Automatically enrolling employees in a pension scheme '
        'removes their freedom to opt out. '
        '· Đáp án: False '
        '· Giải thích: Đoạn F nói rõ nhân viên vẫn được phép rút khỏi '
        '("still allowing them to opt out"). '
        '· Dịch: Tự động đăng ký nhân viên vào quỹ hưu trí sẽ tước đi '
        'quyền từ chối - Sai.',
  ),
  IeltsQuestion(
    id: 'r3-q39',
    section: IeltsSectionNumber.r3,
    answerType: IeltsAnswerType.multipleChoice,
    passageId: 'r3-passage',
    groupInstructionEn: _tfNgGroupInstruction3,
    promptEn: 'Choice architecture has been shown to increase retirement savings rates.',
    options: const ['True', 'False', 'Not Given'],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: Choice architecture has been shown to increase '
        'retirement savings rates. '
        '· Đáp án: True '
        '· Giải thích: Đoạn F nói việc đặt mặc định "đã tăng đáng kể tỉ lệ '
        'tiết kiệm hưu trí". '
        '· Dịch: Kiến trúc lựa chọn đã được chứng minh làm tăng tỉ lệ tiết '
        'kiệm hưu trí - Đúng.',
  ),
  IeltsQuestion(
    id: 'r3-q40',
    section: IeltsSectionNumber.r3,
    answerType: IeltsAnswerType.multipleChoice,
    passageId: 'r3-passage',
    groupInstructionEn: _tfNgGroupInstruction3,
    promptEn: 'Most people actively change a default option when one is presented to them.',
    options: const ['True', 'False', 'Not Given'],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: Most people actively change a default option when one '
        'is presented to them. '
        '· Đáp án: False '
        '· Giải thích: Đoạn F nói "most people simply accept whatever '
        'default option is presented to them" - tức KHÔNG chủ động đổi. '
        '· Dịch: Hầu hết mọi người chủ động thay đổi lựa chọn mặc định khi '
        'được đưa ra - Sai.',
  ),
];

// ============================================================================
// LISTENING SECTION 1 - Dang ky lop gom (~10 cau, 1-10). Hoi thoai doi thuong
// (dat dich vu) - dung form completion + vai cau trac nghiem.
// ============================================================================

const _listeningSection1Script = IeltsAudioScript(
  id: 'l1-script',
  speakerLabels: ['Receptionist', 'Customer'],
  lines: [
    IeltsAudioLine(
      speakerIndex: 0,
      textEn:
          'Good morning, Brightwood Community Arts Center, how can I help you?',
    ),
    IeltsAudioLine(
      speakerIndex: 1,
      textEn: "Hi, I'd like to sign up for the beginner's pottery class.",
    ),
    IeltsAudioLine(
      speakerIndex: 0,
      textEn: 'Sure. Can I take your full name, please?',
    ),
    IeltsAudioLine(speakerIndex: 1, textEn: "It's Melissa Grant. G-R-A-N-T."),
    IeltsAudioLine(
      speakerIndex: 0,
      textEn: 'Thanks, Melissa. And could I get a contact phone number?',
    ),
    IeltsAudioLine(speakerIndex: 1, textEn: "Yes, it's 0798 341 226."),
    IeltsAudioLine(
      speakerIndex: 0,
      textEn:
          "Great. The beginner's class runs every Tuesday evening from six to eight, starting next week. "
          'The full course is six weeks and costs seventy-five dollars, which includes all materials.',
    ),
    IeltsAudioLine(
      speakerIndex: 1,
      textEn: 'That sounds good. Do I need to bring anything myself?',
    ),
    IeltsAudioLine(
      speakerIndex: 0,
      textEn:
          "Just an apron, if you have one — we do have spares if not. Also, please arrive about ten minutes "
          'early on the first day to complete a short registration form.',
    ),
    IeltsAudioLine(
      speakerIndex: 1,
      textEn: 'Okay, no problem. Is there parking at the center?',
    ),
    IeltsAudioLine(
      speakerIndex: 0,
      textEn:
          "Yes, there's a small car park at the back, but it fills up quickly, so we usually recommend the "
          "public car park on Elm Street, just two minutes' walk away.",
    ),
    IeltsAudioLine(speakerIndex: 1, textEn: 'Got it. And can I pay by card?'),
    IeltsAudioLine(
      speakerIndex: 0,
      textEn: 'Yes, you can pay by card on the first evening, or online in advance through our website.',
    ),
  ],
);

const _l1GroupInstruction =
    'Questions 1-10. Listen to the conversation and complete the notes/answer the questions below.';

final _listeningSection1Questions = <IeltsQuestion>[
  const IeltsQuestion(
    id: 'l1-q1',
    section: IeltsSectionNumber.l1,
    answerType: IeltsAnswerType.shortAnswer,
    audioScriptId: 'l1-script',
    groupInstructionEn: _l1GroupInstruction,
    promptEn: "What is the customer's surname?",
    acceptedAnswers: ['grant'],
    explanationVi:
        '· Câu hỏi: What is the customer\'s surname? '
        '· Đáp án: Grant '
        '· Giải thích: Khách đánh vần rõ "Grant, G-R-A-N-T". '
        '· Dịch: Họ của khách hàng là gì? → Grant.',
  ),
  const IeltsQuestion(
    id: 'l1-q2',
    section: IeltsSectionNumber.l1,
    answerType: IeltsAnswerType.shortAnswer,
    audioScriptId: 'l1-script',
    groupInstructionEn: _l1GroupInstruction,
    promptEn: "What is the customer's phone number?",
    acceptedAnswers: ['0798 341 226', '0798341226'],
    explanationVi:
        '· Câu hỏi: What is the customer\'s phone number? '
        '· Đáp án: 0798 341 226 '
        '· Giải thích: Khách đọc số điện thoại trực tiếp. '
        '· Dịch: Số điện thoại của khách là gì? → 0798 341 226.',
  ),
  IeltsQuestion(
    id: 'l1-q3',
    section: IeltsSectionNumber.l1,
    answerType: IeltsAnswerType.multipleChoice,
    audioScriptId: 'l1-script',
    groupInstructionEn: _l1GroupInstruction,
    promptEn: "What day does the beginner's class take place?",
    options: const ['Monday', 'Tuesday', 'Wednesday'],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: What day does the beginner\'s class take place? '
        '· Đáp án: Tuesday '
        '· Giải thích: Lễ tân nói lớp học diễn ra vào tối thứ Ba hàng '
        'tuần. '
        '· Dịch: Lớp học dành cho người mới diễn ra vào ngày nào? → Thứ '
        'Ba.',
  ),
  const IeltsQuestion(
    id: 'l1-q4',
    section: IeltsSectionNumber.l1,
    answerType: IeltsAnswerType.shortAnswer,
    audioScriptId: 'l1-script',
    groupInstructionEn: _l1GroupInstruction,
    promptEn: 'How many weeks does the course last?',
    acceptedAnswers: ['six', '6'],
    explanationVi:
        '· Câu hỏi: How many weeks does the course last? '
        '· Đáp án: six '
        '· Giải thích: Lễ tân nói khoá học kéo dài sáu tuần. '
        '· Dịch: Khoá học kéo dài bao nhiêu tuần? → Sáu tuần.',
  ),
  const IeltsQuestion(
    id: 'l1-q5',
    section: IeltsSectionNumber.l1,
    answerType: IeltsAnswerType.shortAnswer,
    audioScriptId: 'l1-script',
    groupInstructionEn: _l1GroupInstruction,
    promptEn: 'How much does the course cost?',
    acceptedAnswers: ['75', r'$75', 'seventy-five dollars'],
    explanationVi:
        '· Câu hỏi: How much does the course cost? '
        '· Đáp án: \$75 '
        '· Giải thích: Lễ tân nói giá khoá học là 75 đô la. '
        '· Dịch: Khoá học có giá bao nhiêu? → 75 đô la.',
  ),
  IeltsQuestion(
    id: 'l1-q6',
    section: IeltsSectionNumber.l1,
    answerType: IeltsAnswerType.multipleChoice,
    audioScriptId: 'l1-script',
    groupInstructionEn: _l1GroupInstruction,
    promptEn: 'What should students bring on the first day?',
    options: const ['Their own clay', 'An apron', 'A payment receipt'],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: What should students bring on the first day? '
        '· Đáp án: An apron '
        '· Giải thích: Lễ tân nói mang theo tạp dề nếu có. '
        '· Dịch: Học viên nên mang gì vào buổi đầu tiên? → Một chiếc tạp '
        'dề.',
  ),
  const IeltsQuestion(
    id: 'l1-q7',
    section: IeltsSectionNumber.l1,
    answerType: IeltsAnswerType.shortAnswer,
    audioScriptId: 'l1-script',
    groupInstructionEn: _l1GroupInstruction,
    promptEn: 'How many minutes early should students arrive on the first day?',
    acceptedAnswers: ['ten', '10'],
    explanationVi:
        '· Câu hỏi: How many minutes early should students arrive on the '
        'first day? '
        '· Đáp án: ten '
        '· Giải thích: Lễ tân nói đến sớm khoảng mười phút. '
        '· Dịch: Học viên nên đến sớm bao nhiêu phút vào buổi đầu? → Mười '
        'phút.',
  ),
  const IeltsQuestion(
    id: 'l1-q8',
    section: IeltsSectionNumber.l1,
    answerType: IeltsAnswerType.shortAnswer,
    audioScriptId: 'l1-script',
    groupInstructionEn: _l1GroupInstruction,
    promptEn: 'Where is the recommended alternative car park located?',
    acceptedAnswers: ['elm street', 'elm'],
    explanationVi:
        '· Câu hỏi: Where is the recommended alternative car park '
        'located? '
        '· Đáp án: Elm Street '
        '· Giải thích: Lễ tân giới thiệu bãi đậu xe công cộng trên đường '
        'Elm. '
        '· Dịch: Bãi đậu xe thay thế được đề xuất nằm ở đâu? → Đường Elm.',
  ),
  IeltsQuestion(
    id: 'l1-q9',
    section: IeltsSectionNumber.l1,
    answerType: IeltsAnswerType.multipleChoice,
    audioScriptId: 'l1-script',
    groupInstructionEn: _l1GroupInstruction,
    promptEn: 'How can the customer pay for the course?',
    options: const ['Cash only', 'Card or online', 'Bank transfer only'],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: How can the customer pay for the course? '
        '· Đáp án: Card or online '
        '· Giải thích: Lễ tân nói có thể trả bằng thẻ hoặc trả online '
        'trước. '
        '· Dịch: Khách hàng có thể thanh toán bằng cách nào? → Thẻ hoặc '
        'trả online.',
  ),
  const IeltsQuestion(
    id: 'l1-q10',
    section: IeltsSectionNumber.l1,
    answerType: IeltsAnswerType.shortAnswer,
    audioScriptId: 'l1-script',
    groupInstructionEn: _l1GroupInstruction,
    promptEn: 'What does the course fee include?',
    acceptedAnswers: ['materials', 'all materials'],
    explanationVi:
        '· Câu hỏi: What does the course fee include? '
        '· Đáp án: materials '
        '· Giải thích: Lễ tân nói giá đã bao gồm toàn bộ vật liệu. '
        '· Dịch: Học phí đã bao gồm những gì? → Vật liệu.',
  ),
];

// ============================================================================
// LISTENING SECTION 2 - Gioi thieu trung tam the thao (~10 cau, 11-20). Doc
// thoai boi canh doi thuong.
// ============================================================================

const _listeningSection2Script = IeltsAudioScript(
  id: 'l2-script',
  lines: [
    IeltsAudioLine(
      speakerIndex: 0,
      textEn:
          'Good afternoon everyone, and welcome to Fairview Leisure Centre. Before we begin the tour, let me '
          'give you a quick overview. The centre opened six months ago and has already attracted over two '
          'thousand members. We have three main areas: the swimming pool on the ground floor, the fitness suite '
          'on the first floor, and the studio spaces on the second floor, which are used for classes like yoga '
          'and dance. The pool is open from six in the morning until nine at night on weekdays, but on weekends '
          'it closes earlier, at seven. The fitness suite requires a separate induction session before first use, '
          'which takes about thirty minutes and must be booked in advance. We currently offer three membership '
          'types: the Basic plan, which only includes pool access; the Standard plan, which adds the fitness '
          'suite; and the Premium plan, which includes everything plus unlimited studio classes. The café on the '
          'ground floor serves light meals and is a popular spot after workouts, though it closes an hour before '
          'the rest of the building. Finally, please note that lockers require a two-dollar coin deposit, which '
          'is refunded when you return the key.',
    ),
  ],
);

const _l2GroupInstruction =
    'Questions 11-20. Listen to the talk and answer the questions below.';

final _listeningSection2Questions = <IeltsQuestion>[
  const IeltsQuestion(
    id: 'l2-q11',
    section: IeltsSectionNumber.l2,
    answerType: IeltsAnswerType.shortAnswer,
    audioScriptId: 'l2-script',
    groupInstructionEn: _l2GroupInstruction,
    promptEn: 'Where is the fitness suite located?',
    acceptedAnswers: ['first floor', 'the first floor'],
    explanationVi:
        '· Câu hỏi: Where is the fitness suite located? '
        '· Đáp án: first floor '
        '· Giải thích: Người nói đặt phòng gym ở tầng một. '
        '· Dịch: Phòng thể hình nằm ở đâu? → Tầng một.',
  ),
  const IeltsQuestion(
    id: 'l2-q12',
    section: IeltsSectionNumber.l2,
    answerType: IeltsAnswerType.shortAnswer,
    audioScriptId: 'l2-script',
    groupInstructionEn: _l2GroupInstruction,
    promptEn: 'What are the studio spaces mainly used for?',
    acceptedAnswers: ['classes', 'yoga and dance'],
    explanationVi:
        '· Câu hỏi: What are the studio spaces mainly used for? '
        '· Đáp án: classes (yoga and dance) '
        '· Giải thích: Người nói nói phòng studio dùng cho các lớp như '
        'yoga và khiêu vũ. '
        '· Dịch: Các phòng studio chủ yếu dùng để làm gì? → Các lớp học '
        '(yoga và khiêu vũ).',
  ),
  IeltsQuestion(
    id: 'l2-q13',
    section: IeltsSectionNumber.l2,
    answerType: IeltsAnswerType.multipleChoice,
    audioScriptId: 'l2-script',
    groupInstructionEn: _l2GroupInstruction,
    promptEn: 'What time does the pool close on weekdays?',
    options: const ['7pm', '8pm', '9pm'],
    correctIndex: 2,
    explanationVi:
        '· Câu hỏi: What time does the pool close on weekdays? '
        '· Đáp án: 9pm '
        '· Giải thích: Người nói nói hồ bơi mở đến 9 giờ tối các ngày '
        'trong tuần. '
        '· Dịch: Hồ bơi đóng cửa lúc mấy giờ vào các ngày trong tuần? → 9 '
        'giờ tối.',
  ),
  IeltsQuestion(
    id: 'l2-q14',
    section: IeltsSectionNumber.l2,
    answerType: IeltsAnswerType.multipleChoice,
    audioScriptId: 'l2-script',
    groupInstructionEn: _l2GroupInstruction,
    promptEn: 'What time does the pool close on weekends?',
    options: const ['6pm', '7pm', '9pm'],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: What time does the pool close on weekends? '
        '· Đáp án: 7pm '
        '· Giải thích: Người nói nói cuối tuần hồ bơi đóng sớm hơn, lúc 7 '
        'giờ tối. '
        '· Dịch: Hồ bơi đóng cửa lúc mấy giờ vào cuối tuần? → 7 giờ tối.',
  ),
  const IeltsQuestion(
    id: 'l2-q15',
    section: IeltsSectionNumber.l2,
    answerType: IeltsAnswerType.shortAnswer,
    audioScriptId: 'l2-script',
    groupInstructionEn: _l2GroupInstruction,
    promptEn: 'How long does the fitness suite induction session take?',
    acceptedAnswers: ['thirty minutes', '30 minutes'],
    explanationVi:
        '· Câu hỏi: How long does the fitness suite induction session '
        'take? '
        '· Đáp án: thirty minutes '
        '· Giải thích: Người nói nói buổi hướng dẫn sử dụng phòng gym kéo '
        'dài khoảng 30 phút. '
        '· Dịch: Buổi hướng dẫn sử dụng phòng gym kéo dài bao lâu? → Ba '
        'mươi phút.',
  ),
  IeltsQuestion(
    id: 'l2-q16',
    section: IeltsSectionNumber.l2,
    answerType: IeltsAnswerType.multipleChoice,
    audioScriptId: 'l2-script',
    groupInstructionEn: _l2GroupInstruction,
    promptEn: 'Which membership plan includes unlimited studio classes?',
    options: const ['Basic', 'Standard', 'Premium'],
    correctIndex: 2,
    explanationVi:
        '· Câu hỏi: Which membership plan includes unlimited studio '
        'classes? '
        '· Đáp án: Premium '
        '· Giải thích: Gói Premium bao gồm mọi thứ cộng thêm lớp studio '
        'không giới hạn. '
        '· Dịch: Gói thành viên nào bao gồm lớp studio không giới hạn? → '
        'Premium.',
  ),
  IeltsQuestion(
    id: 'l2-q17',
    section: IeltsSectionNumber.l2,
    answerType: IeltsAnswerType.multipleChoice,
    audioScriptId: 'l2-script',
    groupInstructionEn: _l2GroupInstruction,
    promptEn: 'Which membership plan only includes pool access?',
    options: const ['Basic', 'Standard', 'Premium'],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: Which membership plan only includes pool access? '
        '· Đáp án: Basic '
        '· Giải thích: Gói Basic chỉ bao gồm quyền dùng hồ bơi. '
        '· Dịch: Gói thành viên nào chỉ bao gồm quyền dùng hồ bơi? → '
        'Basic.',
  ),
  const IeltsQuestion(
    id: 'l2-q18',
    section: IeltsSectionNumber.l2,
    answerType: IeltsAnswerType.shortAnswer,
    audioScriptId: 'l2-script',
    groupInstructionEn: _l2GroupInstruction,
    promptEn: 'What does the café mainly serve?',
    acceptedAnswers: ['light meals'],
    explanationVi:
        '· Câu hỏi: What does the café mainly serve? '
        '· Đáp án: light meals '
        '· Giải thích: Người nói nói quán cà phê phục vụ các bữa ăn nhẹ. '
        '· Dịch: Quán cà phê chủ yếu phục vụ gì? → Bữa ăn nhẹ.',
  ),
  const IeltsQuestion(
    id: 'l2-q19',
    section: IeltsSectionNumber.l2,
    answerType: IeltsAnswerType.shortAnswer,
    audioScriptId: 'l2-script',
    groupInstructionEn: _l2GroupInstruction,
    promptEn: 'How much is the locker deposit?',
    acceptedAnswers: ['2', r'$2', 'two dollars'],
    explanationVi:
        '· Câu hỏi: How much is the locker deposit? '
        '· Đáp án: \$2 '
        '· Giải thích: Người nói nói tủ khoá cần đặt cọc 2 đô la tiền xu. '
        '· Dịch: Tiền cọc tủ khoá là bao nhiêu? → 2 đô la.',
  ),
  const IeltsQuestion(
    id: 'l2-q20',
    section: IeltsSectionNumber.l2,
    answerType: IeltsAnswerType.shortAnswer,
    audioScriptId: 'l2-script',
    groupInstructionEn: _l2GroupInstruction,
    promptEn: 'How many members has the centre attracted since opening?',
    acceptedAnswers: ['two thousand', '2000', '2,000'],
    explanationVi:
        '· Câu hỏi: How many members has the centre attracted since '
        'opening? '
        '· Đáp án: two thousand '
        '· Giải thích: Người nói nói trung tâm đã có hơn hai nghìn hội '
        'viên. '
        '· Dịch: Trung tâm đã thu hút bao nhiêu hội viên kể từ khi mở? → '
        'Hai nghìn.',
  ),
];

// ============================================================================
// LISTENING SECTION 3 - Thao luan nhom hoc thuat voi giang vien (~10 cau,
// 21-30). 3 nguoi noi (giang vien + 2 sinh vien).
// ============================================================================

const _listeningSection3Script = IeltsAudioScript(
  id: 'l3-script',
  speakerLabels: ['Tutor', 'Student A', 'Student B'],
  lines: [
    IeltsAudioLine(
      speakerIndex: 0,
      textEn: "So, how's the research going for your presentation on renewable energy?",
    ),
    IeltsAudioLine(
      speakerIndex: 1,
      textEn: "We've made good progress, but we're still deciding whether to focus on solar or wind power as our main case study.",
    ),
    IeltsAudioLine(
      speakerIndex: 2,
      textEn: "I think solar makes more sense — there's more recent data available, and it's easier to find case studies from smaller countries.",
    ),
    IeltsAudioLine(
      speakerIndex: 0,
      textEn: "That's a fair point. Have you thought about how you'll structure the presentation itself?",
    ),
    IeltsAudioLine(
      speakerIndex: 1,
      textEn: 'We were planning to start with a general introduction, then move into the case study, and finish with some policy recommendations.',
    ),
    IeltsAudioLine(
      speakerIndex: 0,
      textEn: "That should work well. Just make sure the case study section doesn't run over ten minutes — remember the whole presentation is only twenty minutes total.",
    ),
    IeltsAudioLine(
      speakerIndex: 2,
      textEn: 'Noted. We were also wondering if we should include a short video clip.',
    ),
    IeltsAudioLine(
      speakerIndex: 0,
      textEn: 'That can work, but keep it under two minutes, and make sure it directly supports your argument rather than just being decorative.',
    ),
    IeltsAudioLine(
      speakerIndex: 1,
      textEn: 'Understood. One more thing — should we submit our slides before the session, or bring them on the day?',
    ),
    IeltsAudioLine(
      speakerIndex: 0,
      textEn: 'Please email them to me at least 24 hours in advance, just in case there are any technical issues on the day.',
    ),
  ],
);

const _l3GroupInstruction =
    'Questions 21-30. Listen to the discussion and answer the questions below.';

final _listeningSection3Questions = <IeltsQuestion>[
  IeltsQuestion(
    id: 'l3-q21',
    section: IeltsSectionNumber.l3,
    answerType: IeltsAnswerType.multipleChoice,
    audioScriptId: 'l3-script',
    groupInstructionEn: _l3GroupInstruction,
    promptEn: 'What are the students deciding between?',
    options: const [
      'Solar and wind power',
      'Water and wind power',
      'Coal and solar power',
    ],
    correctIndex: 0,
    explanationVi:
        '· Câu hỏi: What are the students deciding between? '
        '· Đáp án: Solar and wind power '
        '· Giải thích: Sinh viên A nói vẫn đang phân vân giữa năng lượng '
        'mặt trời và gió. '
        '· Dịch: Các sinh viên đang phân vân giữa điều gì? → Năng lượng '
        'mặt trời và năng lượng gió.',
  ),
  IeltsQuestion(
    id: 'l3-q22',
    section: IeltsSectionNumber.l3,
    answerType: IeltsAnswerType.multipleChoice,
    audioScriptId: 'l3-script',
    groupInstructionEn: _l3GroupInstruction,
    promptEn: 'Why does Student B prefer solar as the case study?',
    options: const [
      "It's cheaper to research",
      'There is more recent data available',
      'Their tutor suggested it',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: Why does Student B prefer solar as the case study? '
        '· Đáp án: There is more recent data available '
        '· Giải thích: Sinh viên B nói có nhiều dữ liệu gần đây hơn cho '
        'năng lượng mặt trời. '
        '· Dịch: Vì sao sinh viên B thích chọn năng lượng mặt trời làm '
        'nghiên cứu điển hình? → Có nhiều dữ liệu gần đây hơn.',
  ),
  const IeltsQuestion(
    id: 'l3-q23',
    section: IeltsSectionNumber.l3,
    answerType: IeltsAnswerType.shortAnswer,
    audioScriptId: 'l3-script',
    groupInstructionEn: _l3GroupInstruction,
    promptEn: 'What will the presentation begin with?',
    acceptedAnswers: [
      'introduction',
      'a general introduction',
      'general introduction',
    ],
    explanationVi:
        '· Câu hỏi: What will the presentation begin with? '
        '· Đáp án: a general introduction '
        '· Giải thích: Sinh viên A nói sẽ bắt đầu bằng phần giới thiệu '
        'chung. '
        '· Dịch: Bài thuyết trình sẽ bắt đầu bằng gì? → Phần giới thiệu '
        'chung.',
  ),
  const IeltsQuestion(
    id: 'l3-q24',
    section: IeltsSectionNumber.l3,
    answerType: IeltsAnswerType.shortAnswer,
    audioScriptId: 'l3-script',
    groupInstructionEn: _l3GroupInstruction,
    promptEn: 'What is the maximum length of the whole presentation?',
    acceptedAnswers: ['twenty minutes', '20 minutes'],
    explanationVi:
        '· Câu hỏi: What is the maximum length of the whole presentation? '
        '· Đáp án: twenty minutes '
        '· Giải thích: Giảng viên nhắc cả bài chỉ được 20 phút. '
        '· Dịch: Toàn bộ bài thuyết trình tối đa bao lâu? → Hai mươi phút.',
  ),
  const IeltsQuestion(
    id: 'l3-q25',
    section: IeltsSectionNumber.l3,
    answerType: IeltsAnswerType.shortAnswer,
    audioScriptId: 'l3-script',
    groupInstructionEn: _l3GroupInstruction,
    promptEn: 'What is the maximum length allowed for the case study section?',
    acceptedAnswers: ['ten minutes', '10 minutes'],
    explanationVi:
        '· Câu hỏi: What is the maximum length allowed for the case study '
        'section? '
        '· Đáp án: ten minutes '
        '· Giải thích: Giảng viên nói phần nghiên cứu điển hình không quá '
        '10 phút. '
        '· Dịch: Phần nghiên cứu điển hình tối đa bao lâu? → Mười phút.',
  ),
  IeltsQuestion(
    id: 'l3-q26',
    section: IeltsSectionNumber.l3,
    answerType: IeltsAnswerType.multipleChoice,
    audioScriptId: 'l3-script',
    groupInstructionEn: _l3GroupInstruction,
    promptEn: 'What do the students ask about including?',
    options: const [
      'A guest speaker',
      'A short video clip',
      'A printed handout',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: What do the students ask about including? '
        '· Đáp án: A short video clip '
        '· Giải thích: Sinh viên B hỏi có nên thêm 1 đoạn video ngắn '
        'không. '
        '· Dịch: Các sinh viên hỏi về việc thêm gì? → Một đoạn video ngắn.',
  ),
  const IeltsQuestion(
    id: 'l3-q27',
    section: IeltsSectionNumber.l3,
    answerType: IeltsAnswerType.shortAnswer,
    audioScriptId: 'l3-script',
    groupInstructionEn: _l3GroupInstruction,
    promptEn: 'What is the maximum length of the video clip?',
    acceptedAnswers: ['two minutes', '2 minutes'],
    explanationVi:
        '· Câu hỏi: What is the maximum length of the video clip? '
        '· Đáp án: two minutes '
        '· Giải thích: Giảng viên nói giữ video dưới 2 phút. '
        '· Dịch: Đoạn video tối đa bao lâu? → Hai phút.',
  ),
  IeltsQuestion(
    id: 'l3-q28',
    section: IeltsSectionNumber.l3,
    answerType: IeltsAnswerType.multipleChoice,
    audioScriptId: 'l3-script',
    groupInstructionEn: _l3GroupInstruction,
    promptEn: 'What does the tutor say about the video clip?',
    options: const [
      'It must be funny',
      'It must support the argument',
      'It must include music',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: What does the tutor say about the video clip? '
        '· Đáp án: It must support the argument '
        '· Giải thích: Giảng viên nói video phải hỗ trợ trực tiếp cho lập '
        'luận, không chỉ để trang trí. '
        '· Dịch: Giảng viên nói gì về đoạn video? → Nó phải hỗ trợ lập '
        'luận.',
  ),
  const IeltsQuestion(
    id: 'l3-q29',
    section: IeltsSectionNumber.l3,
    answerType: IeltsAnswerType.shortAnswer,
    audioScriptId: 'l3-script',
    groupInstructionEn: _l3GroupInstruction,
    promptEn: 'How long before the session should slides be emailed?',
    acceptedAnswers: ['24 hours', 'twenty-four hours'],
    explanationVi:
        '· Câu hỏi: How long before the session should slides be emailed? '
        '· Đáp án: 24 hours '
        '· Giải thích: Giảng viên yêu cầu gửi slide trước ít nhất 24 giờ. '
        '· Dịch: Slide cần được gửi trước buổi thuyết trình bao lâu? → Hai '
        'mươi tư giờ.',
  ),
  IeltsQuestion(
    id: 'l3-q30',
    section: IeltsSectionNumber.l3,
    answerType: IeltsAnswerType.multipleChoice,
    audioScriptId: 'l3-script',
    groupInstructionEn: _l3GroupInstruction,
    promptEn: 'What is the main purpose of this conversation?',
    options: const [
      'To review completed work',
      'To plan an upcoming presentation',
      'To assign a grade',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: What is the main purpose of this conversation? '
        '· Đáp án: To plan an upcoming presentation '
        '· Giải thích: Toàn bộ cuộc trò chuyện xoay quanh việc lên kế '
        'hoạch cho bài thuyết trình sắp tới. '
        '· Dịch: Mục đích chính của cuộc trò chuyện là gì? → Để lên kế '
        'hoạch cho một bài thuyết trình sắp tới.',
  ),
];

// ============================================================================
// LISTENING SECTION 4 - Bai giang hoc thuat ve nong nghiep thang dung
// (~10 cau, 31-40). Doc thoai, chu yeu dien tu tu do (note completion).
// ============================================================================

const _listeningSection4Script = IeltsAudioScript(
  id: 'l4-script',
  lines: [
    IeltsAudioLine(
      speakerIndex: 0,
      textEn:
          'Today I want to talk about vertical farming, a method of growing crops in stacked layers, often '
          'indoors, under controlled conditions. Unlike traditional farming, vertical farms typically rely on '
          'artificial lighting rather than direct sunlight, most commonly LED lighting, because it produces less '
          'heat and can be tuned to the specific wavelengths that plants need for photosynthesis. Water usage is '
          'dramatically reduced as well — some vertical farms report using up to ninety-five percent less water '
          'than conventional soil-based farming, largely because water is recirculated in a closed system rather '
          'than draining away into the ground. One of the main advantages is location: because vertical farms '
          "don't need large plots of open land, they can be built directly inside cities, close to the consumers "
          'who will eventually buy the produce, cutting down transport costs and emissions significantly. '
          "However, the technology isn't without drawbacks. The initial cost of building a vertical farm, "
          'particularly the lighting and climate control systems, remains very high compared to a traditional '
          'field. Energy consumption is also a genuine concern, since running thousands of LED lights and cooling '
          'systems requires a significant and constant supply of electricity. Because of this, many current '
          'vertical farms focus on high-value, fast-growing crops such as lettuce and herbs, rather than staple '
          'crops like wheat or rice, which would not be economically viable to grow this way at present. '
          'Researchers are now exploring ways to reduce energy costs further, including combining vertical farms '
          "with renewable energy sources such as solar panels installed on the building's roof.",
    ),
  ],
);

const _l4GroupInstruction =
    'Questions 31-40. Listen to the lecture and complete the notes/answer the questions below.';

final _listeningSection4Questions = <IeltsQuestion>[
  const IeltsQuestion(
    id: 'l4-q31',
    section: IeltsSectionNumber.l4,
    answerType: IeltsAnswerType.shortAnswer,
    audioScriptId: 'l4-script',
    groupInstructionEn: _l4GroupInstruction,
    promptEn: 'What type of lighting do vertical farms most commonly use?',
    acceptedAnswers: ['led', 'led lighting'],
    explanationVi:
        '· Câu hỏi: What type of lighting do vertical farms most commonly '
        'use? '
        '· Đáp án: LED (lighting) '
        '· Giải thích: Người nói nói phổ biến nhất là đèn LED. '
        '· Dịch: Nông trại thẳng đứng thường dùng loại đèn nào nhất? → Đèn '
        'LED.',
  ),
  const IeltsQuestion(
    id: 'l4-q32',
    section: IeltsSectionNumber.l4,
    answerType: IeltsAnswerType.shortAnswer,
    audioScriptId: 'l4-script',
    groupInstructionEn: _l4GroupInstruction,
    promptEn: 'Why is LED lighting preferred? It produces less ___.',
    acceptedAnswers: ['heat'],
    explanationVi:
        '· Câu hỏi: Why is LED lighting preferred? It produces less ___. '
        '· Đáp án: heat '
        '· Giải thích: Người nói nói đèn LED tạo ít nhiệt hơn. '
        '· Dịch: Vì sao đèn LED được ưa chuộng? Nó tạo ra ít ___ hơn. → '
        'Nhiệt.',
  ),
  const IeltsQuestion(
    id: 'l4-q33',
    section: IeltsSectionNumber.l4,
    answerType: IeltsAnswerType.shortAnswer,
    audioScriptId: 'l4-script',
    groupInstructionEn: _l4GroupInstruction,
    promptEn: 'Vertical farms can use up to what percentage less water than conventional farming?',
    acceptedAnswers: ['95%', 'ninety-five percent', '95 percent'],
    explanationVi:
        '· Câu hỏi: Vertical farms can use up to what percentage less '
        'water than conventional farming? '
        '· Đáp án: 95% '
        '· Giải thích: Người nói nói tiết kiệm tới 95% nước so với nông '
        'nghiệp truyền thống. '
        '· Dịch: Nông trại thẳng đứng có thể tiết kiệm tối đa bao nhiêu '
        'phần trăm nước? → 95%.',
  ),
  const IeltsQuestion(
    id: 'l4-q34',
    section: IeltsSectionNumber.l4,
    answerType: IeltsAnswerType.shortAnswer,
    audioScriptId: 'l4-script',
    groupInstructionEn: _l4GroupInstruction,
    promptEn: 'Why is water usage reduced in vertical farms?',
    acceptedAnswers: ['recirculated', 'water is recirculated'],
    explanationVi:
        '· Câu hỏi: Why is water usage reduced in vertical farms? '
        '· Đáp án: (water is) recirculated '
        '· Giải thích: Người nói nói nước được tuần hoàn tái sử dụng '
        'trong hệ thống kín. '
        '· Dịch: Vì sao lượng nước sử dụng giảm trong nông trại thẳng '
        'đứng? → Nước được tuần hoàn tái sử dụng.',
  ),
  const IeltsQuestion(
    id: 'l4-q35',
    section: IeltsSectionNumber.l4,
    answerType: IeltsAnswerType.shortAnswer,
    audioScriptId: 'l4-script',
    groupInstructionEn: _l4GroupInstruction,
    promptEn: 'What is one advantage of building vertical farms in cities?',
    acceptedAnswers: [
      'transport costs',
      'lower transport costs',
      'reduces transport costs',
    ],
    explanationVi:
        '· Câu hỏi: What is one advantage of building vertical farms in '
        'cities? '
        '· Đáp án: (lower) transport costs '
        '· Giải thích: Người nói nói xây trong thành phố giúp giảm chi '
        'phí vận chuyển. '
        '· Dịch: Một lợi ích của việc xây nông trại thẳng đứng trong thành '
        'phố là gì? → Giảm chi phí vận chuyển.',
  ),
  const IeltsQuestion(
    id: 'l4-q36',
    section: IeltsSectionNumber.l4,
    answerType: IeltsAnswerType.shortAnswer,
    audioScriptId: 'l4-script',
    groupInstructionEn: _l4GroupInstruction,
    promptEn: 'What is described as a major cost of building a vertical farm?',
    acceptedAnswers: [
      'lighting and climate control',
      'lighting',
      'climate control systems',
      'climate control',
    ],
    explanationVi:
        '· Câu hỏi: What is described as a major cost of building a '
        'vertical farm? '
        '· Đáp án: lighting and climate control (systems) '
        '· Giải thích: Người nói nói chi phí ban đầu cho hệ thống chiếu '
        'sáng và kiểm soát khí hậu rất cao. '
        '· Dịch: Chi phí lớn khi xây nông trại thẳng đứng là gì? → Hệ '
        'thống chiếu sáng và kiểm soát khí hậu.',
  ),
  IeltsQuestion(
    id: 'l4-q37',
    section: IeltsSectionNumber.l4,
    answerType: IeltsAnswerType.multipleChoice,
    audioScriptId: 'l4-script',
    groupInstructionEn: _l4GroupInstruction,
    promptEn: 'What type of crops do most current vertical farms grow?',
    options: const [
      'Staple crops like wheat',
      'High-value, fast-growing crops',
      'Root vegetables only',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: What type of crops do most current vertical farms '
        'grow? '
        '· Đáp án: High-value, fast-growing crops '
        '· Giải thích: Người nói nói hầu hết nông trại hiện tại trồng cây '
        'giá trị cao, sinh trưởng nhanh. '
        '· Dịch: Hầu hết nông trại thẳng đứng hiện nay trồng loại cây nào? '
        '→ Cây giá trị cao, sinh trưởng nhanh.',
  ),
  const IeltsQuestion(
    id: 'l4-q38',
    section: IeltsSectionNumber.l4,
    answerType: IeltsAnswerType.shortAnswer,
    audioScriptId: 'l4-script',
    groupInstructionEn: _l4GroupInstruction,
    promptEn: 'Give one example of a crop mentioned as suitable for vertical farming.',
    acceptedAnswers: ['lettuce', 'herbs'],
    explanationVi:
        '· Câu hỏi: Give one example of a crop mentioned as suitable for '
        'vertical farming. '
        '· Đáp án: lettuce (hoặc herbs) '
        '· Giải thích: Người nói nêu ví dụ xà lách và các loại rau thơm. '
        '· Dịch: Nêu 1 ví dụ cây trồng phù hợp với nông trại thẳng đứng. → '
        'Xà lách (hoặc rau thơm).',
  ),
  const IeltsQuestion(
    id: 'l4-q39',
    section: IeltsSectionNumber.l4,
    answerType: IeltsAnswerType.shortAnswer,
    audioScriptId: 'l4-script',
    groupInstructionEn: _l4GroupInstruction,
    promptEn: 'What renewable energy source is mentioned as a possible solution to high energy costs?',
    acceptedAnswers: ['solar', 'solar panels'],
    explanationVi:
        '· Câu hỏi: What renewable energy source is mentioned as a '
        'possible solution to high energy costs? '
        '· Đáp án: solar (panels) '
        '· Giải thích: Người nói nói các nhà nghiên cứu đang kết hợp pin '
        'mặt trời trên mái nhà. '
        '· Dịch: Nguồn năng lượng tái tạo nào được nhắc tới như giải pháp '
        'giảm chi phí năng lượng? → Pin mặt trời.',
  ),
  IeltsQuestion(
    id: 'l4-q40',
    section: IeltsSectionNumber.l4,
    answerType: IeltsAnswerType.multipleChoice,
    audioScriptId: 'l4-script',
    groupInstructionEn: _l4GroupInstruction,
    promptEn: 'What is the main topic of the lecture?',
    options: const [
      'The history of farming',
      'Vertical farming methods and challenges',
      'Global food shortages',
    ],
    correctIndex: 1,
    explanationVi:
        '· Câu hỏi: What is the main topic of the lecture? '
        '· Đáp án: Vertical farming methods and challenges '
        '· Giải thích: Toàn bộ bài giảng nói về phương pháp và thách thức '
        'của nông trại thẳng đứng. '
        '· Dịch: Chủ đề chính của bài giảng là gì? → Phương pháp và thách '
        'thức của nông nghiệp thẳng đứng.',
  ),
];

/// Du lieu 1 de thi thu IELTS Phase 1 (Reading + Listening, chua co Writing/
/// Speaking - se lam o phase sau voi Gemini AI cham diem) - NOI DUNG TU VIET
/// HOAN TOAN MOI, chi tham khao dung cau truc/dinh dang bai thi IELTS that
/// (kien thuc pho bien, cong khai), KHONG copy tu bat ky nguon nao.
///
/// `kIeltsTests` la List (so nhieu) tu dau du hien chi co 1 de - them de #2
/// sau nay chi la them 1 IeltsTest(...) moi vao list, khong doi code.
final List<IeltsTest> kIeltsTests = [
  IeltsTest(
    id: 'ielts-test-1',
    titleVi: 'Đề thi thử IELTS số 1',
    questions: [
      ..._readingPassage1Questions,
      ..._readingPassage2Questions,
      ..._readingPassage3Questions,
      ..._listeningSection1Questions,
      ..._listeningSection2Questions,
      ..._listeningSection3Questions,
      ..._listeningSection4Questions,
    ],
    audioScripts: {
      for (final s in [
        _listeningSection1Script,
        _listeningSection2Script,
        _listeningSection3Script,
        _listeningSection4Script,
      ])
        s.id: s,
    },
    passages: {
      for (final p in [_readingPassage1, _readingPassage2, _readingPassage3])
        p.id: p,
    },
  ),
];
