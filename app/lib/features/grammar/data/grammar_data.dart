import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../core/i18n/app_language.dart";
import "../../../core/providers/app_providers.dart";
import "../../../core/theme/app_theme.dart";

/// 31 chu de ngu phap tieng Anh cot loi (thi, tu loai, cau truc cau, menh
/// de quan he) danh cho nguoi Viet hoc tieng Anh qua bai hat. Toan bo giai
/// thich, vi du va cau hoi trac nghiem trong file nay la noi dung TU BIEN
/// SOAN (khong sao chep/dich sat tu bat ky website hay sach giao khoa cu
/// the nao) - ten cau truc ngu phap va cong thuc (vd "S + V(s/es) + O",
/// cac loai cau dieu kien 0-3) la kien thuc giao duc pho thong, khong
/// thuoc ban quyen cua ai.
class GrammarExample {
  const GrammarExample({required this.en, required this.vi});

  /// Cau vi du tieng Anh.
  final String en;

  /// Ban dich tieng Viet.
  final String vi;
}

class GrammarQuestion {
  const GrammarQuestion({
    required this.promptEn,
    required this.options,
    required this.correctIndex,
  });

  /// Cau co cho trong, vd "She ___ (go) to school every day."
  final String promptEn;

  /// Dung 4 lua chon ngan bang tieng Anh de dien vao cho trong.
  final List<String> options;

  /// Vi tri (0-3) cua dap an dung trong [options].
  final int correctIndex;
}

class GrammarTopic {
  const GrammarTopic({
    required this.name,
    required this.nameEn,
    required this.icon,
    required this.color,
    required this.formula,
    required this.explanationVi,
    required this.examples,
    required this.questions,
  });

  /// Ten chu de bang tieng Viet, vd "Thi hien tai don".
  final String name;

  /// Ten chu de bang tieng Anh, vd "Present Simple".
  final String nameEn;
  final IconData icon;
  final Color color;

  /// Cong thuc cau truc ngan gon, vd "S + V(s/es) + O".
  final String formula;

  /// Doan giai thich tieng Viet (2-4 cau) ve khi nao/cach dung diem ngu
  /// phap nay.
  final String explanationVi;

  final List<GrammarExample> examples;
  final List<GrammarQuestion> questions;
}

const kGrammarTopics = <GrammarTopic>[
  // ===================== THI (TENSES) =====================
  GrammarTopic(
    name: "Thì hiện tại đơn",
    nameEn: "Present Simple",
    icon: Icons.wb_sunny_rounded,
    color: AppColors.blue,
    formula: "S + V(s/es) + O",
    explanationVi: "Thì hiện tại đơn diễn tả thói quen, sự thật hiển nhiên, lịch trình cố định hoặc trạng thái lâu dài. Với chủ ngữ số ít (he/she/it), động từ thường thêm 's' hoặc 'es'. Câu phủ định và nghi vấn dùng trợ động từ do/does.",
    examples: [
      GrammarExample(
        en: "She works at a hospital every day.",
        vi: "Cô ấy làm việc ở bệnh viện mỗi ngày.",
      ),
      GrammarExample(
        en: "The sun rises in the east.",
        vi: "Mặt trời mọc ở hướng đông.",
      ),
      GrammarExample(
        en: "My brother plays football on weekends.",
        vi: "Anh trai tôi chơi bóng đá vào cuối tuần.",
      ),
    ],
    questions: [
      GrammarQuestion(
        promptEn: "He ___ to the gym three times a week.",
        options: ["go", "goes", "going", "gone"],
        correctIndex: 1,
      ),
      GrammarQuestion(
        promptEn: "Water ___ at 100 degrees Celsius.",
        options: ["boil", "boils", "boiling", "boiled"],
        correctIndex: 1,
      ),
      GrammarQuestion(
        promptEn: "___ your sister speak French?",
        options: ["Do", "Does", "Is", "Are"],
        correctIndex: 1,
      ),
      GrammarQuestion(
        promptEn: "They ___ not like spicy food.",
        options: ["does", "do", "is", "are"],
        correctIndex: 1,
      ),
      GrammarQuestion(
        promptEn: "The train ___ at 7 a.m. every morning.",
        options: ["leave", "leaves", "leaving", "left"],
        correctIndex: 1,
      ),
    ],
  ),
  GrammarTopic(
    name: "Thì hiện tại tiếp diễn",
    nameEn: "Present Continuous",
    icon: Icons.directions_run_rounded,
    color: AppColors.purple,
    formula: "S + am/is/are + V-ing",
    explanationVi: "Thì hiện tại tiếp diễn dùng để diễn tả hành động đang xảy ra ngay lúc nói, hoặc một kế hoạch đã sắp xếp trong tương lai gần. Ta chia động từ to be theo chủ ngữ rồi thêm V-ing vào sau.",
    examples: [
      GrammarExample(
        en: "I am cooking dinner right now.",
        vi: "Tôi đang nấu bữa tối ngay bây giờ.",
      ),
      GrammarExample(
        en: "They are watching a movie at the cinema.",
        vi: "Họ đang xem phim ở rạp.",
      ),
      GrammarExample(
        en: "She is meeting her friend tomorrow evening.",
        vi: "Cô ấy sẽ gặp bạn vào tối mai (đã lên kế hoạch).",
      ),
    ],
    questions: [
      GrammarQuestion(
        promptEn: "Look! The baby ___.",
        options: ["cry", "crying", "is crying", "cries"],
        correctIndex: 2,
      ),
      GrammarQuestion(
        promptEn: "We ___ dinner at the moment.",
        options: ["are having", "have", "has", "having"],
        correctIndex: 0,
      ),
      GrammarQuestion(
        promptEn: "I ___ not listening to you right now.",
        options: ["is", "am", "are", "be"],
        correctIndex: 1,
      ),
      GrammarQuestion(
        promptEn: "___ you working on the report now?",
        options: ["Do", "Does", "Are", "Is"],
        correctIndex: 2,
      ),
      GrammarQuestion(
        promptEn: "She ___ to the airport at 6 p.m. tonight.",
        options: ["drive", "drives", "is driving", "drove"],
        correctIndex: 2,
      ),
    ],
  ),
  GrammarTopic(
    name: "Thì hiện tại hoàn thành",
    nameEn: "Present Perfect",
    icon: Icons.check_circle_rounded,
    color: AppColors.teal,
    formula: "S + have/has + V3/ed",
    explanationVi: "Thì hiện tại hoàn thành diễn tả hành động đã xảy ra trong quá khứ nhưng còn liên quan đến hiện tại, hoặc kinh nghiệm chưa xác định thời gian cụ thể. Thường đi cùng các từ như already, just, yet, ever, never, since, for.",
    examples: [
      GrammarExample(
        en: "I have already finished my homework.",
        vi: "Tôi đã hoàn thành bài tập về nhà rồi.",
      ),
      GrammarExample(
        en: "She has never been to Japan.",
        vi: "Cô ấy chưa từng đến Nhật Bản.",
      ),
      GrammarExample(
        en: "We have lived in this city since 2015.",
        vi: "Chúng tôi đã sống ở thành phố này từ năm 2015.",
      ),
    ],
    questions: [
      GrammarQuestion(
        promptEn: "He ___ finished his project yet.",
        options: ["hasn't", "haven't", "doesn't", "didn't"],
        correctIndex: 0,
      ),
      GrammarQuestion(
        promptEn: "___ you ever tried Vietnamese coffee?",
        options: ["Do", "Have", "Did", "Are"],
        correctIndex: 1,
      ),
      GrammarQuestion(
        promptEn: "They have ___ in this house for ten years.",
        options: ["live", "lived", "living", "lives"],
        correctIndex: 1,
      ),
      GrammarQuestion(
        promptEn: "I have known him ___ we were children.",
        options: ["for", "since", "ago", "during"],
        correctIndex: 1,
      ),
      GrammarQuestion(
        promptEn: "She has just ___ home.",
        options: ["arrive", "arrived", "arriving", "arrives"],
        correctIndex: 1,
      ),
    ],
  ),
  GrammarTopic(
    name: "Thì hiện tại hoàn thành tiếp diễn",
    nameEn: "Present Perfect Continuous",
    icon: Icons.hourglass_bottom_rounded,
    color: AppColors.amber,
    formula: "S + have/has + been + V-ing",
    explanationVi: "Thì này nhấn mạnh tính liên tục của một hành động bắt đầu trong quá khứ và vẫn tiếp diễn đến hiện tại, hoặc vừa mới kết thúc nhưng còn để lại kết quả rõ rệt. Thường dùng với for/since để chỉ khoảng thời gian.",
    examples: [
      GrammarExample(
        en: "I have been studying English for three years.",
        vi: "Tôi đã học tiếng Anh được ba năm rồi.",
      ),
      GrammarExample(
        en: "It has been raining since this morning.",
        vi: "Trời đã mưa từ sáng đến giờ.",
      ),
      GrammarExample(
        en: "She looks tired because she has been working all day.",
        vi: "Cô ấy trông mệt vì đã làm việc cả ngày.",
      ),
    ],
    questions: [
      GrammarQuestion(
        promptEn: "He ___ been playing video games for two hours.",
        options: ["have", "has", "is", "was"],
        correctIndex: 1,
      ),
      GrammarQuestion(
        promptEn: "We have been waiting ___ nine o'clock.",
        options: ["for", "since", "at", "in"],
        correctIndex: 1,
      ),
      GrammarQuestion(
        promptEn: "Why are your hands dirty? I ___ been fixing the car.",
        options: ["have", "has", "am", "was"],
        correctIndex: 0,
      ),
      GrammarQuestion(
        promptEn: "They have been ___ soccer since morning.",
        options: ["play", "played", "playing", "plays"],
        correctIndex: 2,
      ),
      GrammarQuestion(
        promptEn: "How long ___ you been learning the guitar?",
        options: ["do", "have", "has", "did"],
        correctIndex: 1,
      ),
    ],
  ),
  GrammarTopic(
    name: "Thì quá khứ đơn",
    nameEn: "Past Simple",
    icon: Icons.history_rounded,
    color: AppColors.pink,
    formula: "S + V2/ed + O",
    explanationVi: "Thì quá khứ đơn diễn tả hành động đã xảy ra và kết thúc hoàn toàn trong quá khứ, thường đi kèm mốc thời gian xác định như yesterday, last week, in 2010. Động từ có quy tắc thêm -ed, động từ bất quy tắc phải học thuộc dạng V2.",
    examples: [
      GrammarExample(
        en: "I visited my grandmother last weekend.",
        vi: "Tôi đã thăm bà vào cuối tuần trước.",
      ),
      GrammarExample(
        en: "She didn't go to school yesterday because she was sick.",
        vi: "Cô ấy không đi học hôm qua vì bị ốm.",
      ),
      GrammarExample(
        en: "They watched a great concert last night.",
        vi: "Họ đã xem một buổi hòa nhạc tuyệt vời tối qua.",
      ),
    ],
    questions: [
      GrammarQuestion(
        promptEn: "He ___ to Paris last summer.",
        options: ["go", "goes", "went", "gone"],
        correctIndex: 2,
      ),
      GrammarQuestion(
        promptEn: "I ___ not see you at the party.",
        options: ["did", "do", "was", "were"],
        correctIndex: 0,
      ),
      GrammarQuestion(
        promptEn: "___ she call you yesterday?",
        options: ["Does", "Did", "Do", "Is"],
        correctIndex: 1,
      ),
      GrammarQuestion(
        promptEn: "We ___ dinner together last Friday.",
        options: ["have", "had", "has", "having"],
        correctIndex: 1,
      ),
      GrammarQuestion(
        promptEn: "The movie ___ at 8 p.m. last night.",
        options: ["start", "starts", "started", "starting"],
        correctIndex: 2,
      ),
    ],
  ),
  GrammarTopic(
    name: "Thì quá khứ tiếp diễn",
    nameEn: "Past Continuous",
    icon: Icons.access_time_rounded,
    color: AppColors.blue,
    formula: "S + was/were + V-ing",
    explanationVi: "Thì quá khứ tiếp diễn diễn tả hành động đang xảy ra tại một thời điểm xác định trong quá khứ, hoặc hai hành động song song, hoặc một hành động đang xảy ra thì bị hành động khác (ở quá khứ đơn) xen vào.",
    examples: [
      GrammarExample(
        en: "I was sleeping when you called me.",
        vi: "Tôi đang ngủ khi bạn gọi tôi.",
      ),
      GrammarExample(
        en: "They were playing chess while we were cooking.",
        vi: "Họ đang chơi cờ trong khi chúng tôi đang nấu ăn.",
      ),
      GrammarExample(
        en: "She was walking home at 9 p.m. last night.",
        vi: "Cô ấy đang đi bộ về nhà lúc 9 giờ tối qua.",
      ),
    ],
    questions: [
      GrammarQuestion(
        promptEn: "What ___ you doing at 8 p.m. yesterday?",
        options: ["was", "were", "did", "are"],
        correctIndex: 1,
      ),
      GrammarQuestion(
        promptEn: "He ___ reading a book when the lights went out.",
        options: ["was", "were", "is", "are"],
        correctIndex: 0,
      ),
      GrammarQuestion(
        promptEn: "While I ___ studying, my brother was watching TV.",
        options: ["was", "were", "am", "is"],
        correctIndex: 0,
      ),
      GrammarQuestion(
        promptEn:
            "They ___ not listening when the teacher explained the lesson.",
        options: ["was", "were", "did", "do"],
        correctIndex: 1,
      ),
      GrammarQuestion(
        promptEn: "It ___ raining heavily when we left the house.",
        options: ["was", "were", "is", "did"],
        correctIndex: 0,
      ),
    ],
  ),
  GrammarTopic(
    name: "Thì quá khứ hoàn thành",
    nameEn: "Past Perfect",
    icon: Icons.undo_rounded,
    color: AppColors.purple,
    formula: "S + had + V3/ed",
    explanationVi: "Thì quá khứ hoàn thành diễn tả một hành động xảy ra và hoàn tất trước một hành động hoặc thời điểm khác trong quá khứ. Nó giúp làm rõ thứ tự trước-sau của hai sự việc đã qua.",
    examples: [
      GrammarExample(
        en: "By the time I arrived, the movie had already started.",
        vi: "Vào lúc tôi đến, bộ phim đã bắt đầu rồi.",
      ),
      GrammarExample(
        en: "She had finished her homework before her mother came home.",
        vi: "Cô ấy đã làm xong bài tập trước khi mẹ về nhà.",
      ),
      GrammarExample(
        en: "We had never seen snow before we visited Sapa.",
        vi: "Chúng tôi chưa từng thấy tuyết trước khi đến Sapa.",
      ),
    ],
    questions: [
      GrammarQuestion(
        promptEn: "The train ___ left before we got to the station.",
        options: ["has", "had", "have", "was"],
        correctIndex: 1,
      ),
      GrammarQuestion(
        promptEn: "She ___ never traveled abroad before that trip.",
        options: ["has", "had", "have", "did"],
        correctIndex: 1,
      ),
      GrammarQuestion(
        promptEn: "By the time he called, I ___ already gone to bed.",
        options: ["have", "has", "had", "was"],
        correctIndex: 2,
      ),
      GrammarQuestion(
        promptEn: "After they ___ eaten dinner, they watched TV.",
        options: ["have", "had", "has", "were"],
        correctIndex: 1,
      ),
      GrammarQuestion(
        promptEn: "We ___ finished the project before the deadline.",
        options: ["had", "have", "has", "was"],
        correctIndex: 0,
      ),
    ],
  ),
  GrammarTopic(
    name: "Thì quá khứ hoàn thành tiếp diễn",
    nameEn: "Past Perfect Continuous",
    icon: Icons.timelapse_rounded,
    color: AppColors.teal,
    formula: "S + had + been + V-ing",
    explanationVi: "Thì này nhấn mạnh khoảng thời gian một hành động đã diễn ra liên tục trước một thời điểm hoặc hành động khác trong quá khứ. Thường dùng để giải thích nguyên nhân của một sự việc đã xảy ra.",
    examples: [
      GrammarExample(
        en: "She was tired because she had been working all night.",
        vi: "Cô ấy mệt vì đã làm việc suốt đêm.",
      ),
      GrammarExample(
        en: "They had been waiting for two hours before the bus arrived.",
        vi: "Họ đã đợi hai tiếng trước khi xe buýt đến.",
      ),
      GrammarExample(
        en: "I had been living in Hanoi for five years before I moved abroad.",
        vi: "Tôi đã sống ở Hà Nội năm năm trước khi chuyển ra nước ngoài.",
      ),
    ],
    questions: [
      GrammarQuestion(
        promptEn: "He had ___ studying for three hours when I called.",
        options: ["be", "been", "being", "was"],
        correctIndex: 1,
      ),
      GrammarQuestion(
        promptEn: "They ___ been playing football before it started to rain.",
        options: ["had", "have", "has", "was"],
        correctIndex: 0,
      ),
      GrammarQuestion(
        promptEn: "How long ___ she been waiting when the doctor arrived?",
        options: ["did", "had", "has", "was"],
        correctIndex: 1,
      ),
      GrammarQuestion(
        promptEn: "We had been ___ for hours before we found the answer.",
        options: ["think", "thought", "thinking", "thinks"],
        correctIndex: 2,
      ),
      GrammarQuestion(
        promptEn: "The road was wet because it had been ___ all day.",
        options: ["rain", "rained", "raining", "rains"],
        correctIndex: 2,
      ),
    ],
  ),
  GrammarTopic(
    name: "Thì tương lai đơn",
    nameEn: "Simple Future (will)",
    icon: Icons.bolt_rounded,
    color: AppColors.amber,
    formula: "S + will + V(bare)",
    explanationVi: "Thì tương lai đơn với 'will' dùng để diễn tả một quyết định tức thời, một dự đoán không có căn cứ rõ ràng, hoặc một lời hứa/đề nghị. 'Will' không thay đổi theo chủ ngữ và theo sau là động từ nguyên mẫu không 'to'.",
    examples: [
      GrammarExample(
        en: "I think it will rain tomorrow.",
        vi: "Tôi nghĩ ngày mai trời sẽ mưa.",
      ),
      GrammarExample(
        en: "I will help you carry those bags.",
        vi: "Tôi sẽ giúp bạn xách những cái túi đó.",
      ),
      GrammarExample(
        en: "She will call you as soon as she arrives.",
        vi: "Cô ấy sẽ gọi cho bạn ngay khi đến nơi.",
      ),
    ],
    questions: [
      GrammarQuestion(
        promptEn: "I promise I ___ finish it tonight.",
        options: ["will", "am", "was", "would"],
        correctIndex: 0,
      ),
      GrammarQuestion(
        promptEn: "___ you help me move this table?",
        options: ["Do", "Will", "Are", "Did"],
        correctIndex: 1,
      ),
      GrammarQuestion(
        promptEn: "It ___ probably be cold tonight.",
        options: ["will", "is", "was", "did"],
        correctIndex: 0,
      ),
      GrammarQuestion(
        promptEn: "She ___ not attend the meeting tomorrow.",
        options: ["won't", "doesn't", "isn't", "didn't"],
        correctIndex: 0,
      ),
      GrammarQuestion(
        promptEn: "I bet the team ___ win the match.",
        options: ["will", "would", "did", "is"],
        correctIndex: 0,
      ),
    ],
  ),
  GrammarTopic(
    name: "Thì tương lai gần",
    nameEn: "Near Future (be going to)",
    icon: Icons.event_rounded,
    color: AppColors.pink,
    formula: "S + am/is/are + going to + V",
    explanationVi: "'Be going to' dùng để nói về dự định đã có kế hoạch từ trước, hoặc đưa ra dự đoán dựa trên bằng chứng cụ thể ở hiện tại. Khác với 'will', cấu trúc này thường thể hiện sự chắc chắn hơn về một kế hoạch đã được sắp xếp.",
    examples: [
      GrammarExample(
        en: "We are going to visit our grandparents this weekend.",
        vi: "Chúng tôi định thăm ông bà vào cuối tuần này.",
      ),
      GrammarExample(
        en: "Look at those dark clouds, it is going to rain.",
        vi: "Nhìn những đám mây đen kia kìa, trời sắp mưa.",
      ),
      GrammarExample(
        en: "He is going to start a new job next month.",
        vi: "Anh ấy sắp bắt đầu công việc mới vào tháng sau.",
      ),
    ],
    questions: [
      GrammarQuestion(
        promptEn: "She ___ going to travel to Da Nang next week.",
        options: ["is", "are", "am", "be"],
        correctIndex: 0,
      ),
      GrammarQuestion(
        promptEn: "Look at the sky! It ___ going to storm.",
        options: ["is", "are", "am", "were"],
        correctIndex: 0,
      ),
      GrammarQuestion(
        promptEn: "We ___ going to buy a new car soon.",
        options: ["is", "are", "am", "be"],
        correctIndex: 1,
      ),
      GrammarQuestion(
        promptEn: "I ___ not going to give up on my dream.",
        options: ["is", "are", "am", "be"],
        correctIndex: 2,
      ),
      GrammarQuestion(
        promptEn: "___ they going to move to a new house?",
        options: ["Is", "Are", "Do", "Will"],
        correctIndex: 1,
      ),
    ],
  ),
  GrammarTopic(
    name: "Thì tương lai tiếp diễn",
    nameEn: "Future Continuous",
    icon: Icons.schedule_rounded,
    color: AppColors.blue,
    formula: "S + will be + V-ing",
    explanationVi: "Thì tương lai tiếp diễn diễn tả một hành động đang xảy ra tại một thời điểm cụ thể trong tương lai. Nó giúp người nghe hình dung được bối cảnh sẽ diễn ra vào lúc đó.",
    examples: [
      GrammarExample(
        en: "This time tomorrow, I will be flying to London.",
        vi: "Giờ này ngày mai, tôi sẽ đang bay đến London.",
      ),
      GrammarExample(
        en: "She will be studying at 9 p.m. tonight.",
        vi: "Cô ấy sẽ đang học bài lúc 9 giờ tối nay.",
      ),
      GrammarExample(
        en: "They will be having dinner when we arrive.",
        vi: "Họ sẽ đang ăn tối khi chúng ta đến.",
      ),
    ],
    questions: [
      GrammarQuestion(
        promptEn: "At 8 p.m. tonight, I ___ be watching the final match.",
        options: ["will", "am", "was", "did"],
        correctIndex: 0,
      ),
      GrammarQuestion(
        promptEn: "This time next week, we ___ be relaxing on the beach.",
        options: ["will", "are", "were", "was"],
        correctIndex: 0,
      ),
      GrammarQuestion(
        promptEn: "She will ___ working when you call her.",
        options: ["be", "being", "is", "was"],
        correctIndex: 0,
      ),
      GrammarQuestion(
        promptEn: "They will be ___ dinner at 7 p.m.",
        options: ["have", "had", "having", "has"],
        correctIndex: 2,
      ),
      GrammarQuestion(
        promptEn: "___ you be using the car tomorrow morning?",
        options: ["Do", "Will", "Are", "Did"],
        correctIndex: 1,
      ),
    ],
  ),
  GrammarTopic(
    name: "Thì tương lai hoàn thành",
    nameEn: "Future Perfect",
    icon: Icons.done_all_rounded,
    color: AppColors.purple,
    formula: "S + will have + V3/ed",
    explanationVi: "Thì tương lai hoàn thành diễn tả một hành động sẽ hoàn thành trước một thời điểm hoặc sự việc cụ thể trong tương lai. Thường đi kèm 'by the time' hoặc 'by + mốc thời gian'.",
    examples: [
      GrammarExample(
        en: "By next year, I will have graduated from university.",
        vi: "Đến năm sau, tôi sẽ đã tốt nghiệp đại học.",
      ),
      GrammarExample(
        en: "She will have finished the report by Friday.",
        vi: "Cô ấy sẽ hoàn thành bản báo cáo trước thứ Sáu.",
      ),
      GrammarExample(
        en: "By the time you arrive, we will have cooked dinner.",
        vi: "Khi bạn đến, chúng tôi sẽ đã nấu xong bữa tối.",
      ),
    ],
    questions: [
      GrammarQuestion(
        promptEn: "By 2030, scientists ___ found a cure for many diseases.",
        options: ["will have", "will", "have", "had"],
        correctIndex: 0,
      ),
      GrammarQuestion(
        promptEn: "She will have ___ her homework by 6 p.m.",
        options: ["finish", "finished", "finishing", "finishes"],
        correctIndex: 1,
      ),
      GrammarQuestion(
        promptEn:
            "By the time he retires, he ___ have worked here for 30 years.",
        options: ["will", "is", "was", "did"],
        correctIndex: 0,
      ),
      GrammarQuestion(
        promptEn: "We will have ___ the house by next month.",
        options: ["sell", "sold", "selling", "sells"],
        correctIndex: 1,
      ),
      GrammarQuestion(
        promptEn: "By next week, they ___ have moved into their new home.",
        options: ["will", "are", "were", "did"],
        correctIndex: 0,
      ),
    ],
  ),
  GrammarTopic(
    name: "Thì tương lai hoàn thành tiếp diễn",
    nameEn: "Future Perfect Continuous",
    icon: Icons.update_rounded,
    color: AppColors.teal,
    formula: "S + will have been + V-ing",
    explanationVi: "Thì này nhấn mạnh khoảng thời gian một hành động sẽ liên tục kéo dài tính đến một mốc cụ thể trong tương lai. Nó thường trả lời cho câu hỏi 'đến lúc đó thì đã làm việc gì được bao lâu'.",
    examples: [
      GrammarExample(
        en: "By next month, I will have been working here for five years.",
        vi: "Đến tháng sau, tôi sẽ đã làm việc ở đây được năm năm.",
      ),
      GrammarExample(
        en: "She will have been studying for six hours by the time the exam starts.",
        vi: "Cô ấy sẽ đã học được sáu tiếng khi kỳ thi bắt đầu.",
      ),
      GrammarExample(
        en: "By 2027, they will have been living in this city for a decade.",
        vi: "Đến năm 2027, họ sẽ đã sống ở thành phố này được một thập kỷ.",
      ),
    ],
    questions: [
      GrammarQuestion(
        promptEn:
            "By the end of this year, I will have been ___ here for a decade.",
        options: ["work", "worked", "working", "works"],
        correctIndex: 2,
      ),
      GrammarQuestion(
        promptEn: "By 10 p.m., she will have been ___ for four hours straight.",
        options: ["drive", "drove", "driving", "drives"],
        correctIndex: 2,
      ),
      GrammarQuestion(
        promptEn: "By next spring, we ___ have been dating for two years.",
        options: ["will", "are", "were", "did"],
        correctIndex: 0,
      ),
      GrammarQuestion(
        promptEn:
            "By the time you finish reading, I will have been ___ for an hour.",
        options: ["wait", "waited", "waiting", "waits"],
        correctIndex: 2,
      ),
      GrammarQuestion(
        promptEn: "By June, he will have been ___ this course for a full year.",
        options: ["take", "took", "taking", "takes"],
        correctIndex: 2,
      ),
    ],
  ),
  // ===================== TU LOAI (PARTS OF SPEECH) =====================
  GrammarTopic(
    name: "Danh từ",
    nameEn: "Nouns",
    icon: Icons.label_rounded,
    color: AppColors.amber,
    formula: "Noun = person / place / thing / idea",
    explanationVi: "Danh từ là từ dùng để gọi tên người, vật, địa điểm hoặc khái niệm. Danh từ có thể chia thành danh từ đếm được (có số ít/số nhiều) và danh từ không đếm được (không có dạng số nhiều), việc phân biệt này ảnh hưởng đến cách dùng mạo từ và lượng từ đi kèm.",
    examples: [
      GrammarExample(
        en: "The teacher gave us some useful advice.",
        vi: "Giáo viên đã cho chúng tôi vài lời khuyên hữu ích.",
      ),
      GrammarExample(
        en: "There are three books on the table.",
        vi: "Có ba cuốn sách trên bàn.",
      ),
      GrammarExample(
        en: "Honesty is an important value in life.",
        vi: "Sự trung thực là một giá trị quan trọng trong cuộc sống.",
      ),
    ],
    questions: [
      GrammarQuestion(
        promptEn: "I need some ___ to write this letter.",
        options: ["paper", "papers", "a paper", "the papers"],
        correctIndex: 0,
      ),
      GrammarQuestion(
        promptEn: "There are many ___ in the garden.",
        options: ["flower", "flowers", "a flower", "flowery"],
        correctIndex: 1,
      ),
      GrammarQuestion(
        promptEn: "Choose the uncountable noun: ___",
        options: ["chair", "information", "apple", "book"],
        correctIndex: 1,
      ),
      GrammarQuestion(
        promptEn: "She bought two ___ of milk.",
        options: ["bottle", "bottles", "a bottle", "bottling"],
        correctIndex: 1,
      ),
      GrammarQuestion(
        promptEn: "___ is the key to success.",
        options: ["Patience", "Patients", "Patient", "Patiently"],
        correctIndex: 0,
      ),
    ],
  ),
  GrammarTopic(
    name: "Đại từ",
    nameEn: "Pronouns",
    icon: Icons.person_rounded,
    color: AppColors.pink,
    formula: "he/she/it/they, him/her/them, his/hers, myself...",
    explanationVi: "Đại từ dùng để thay thế cho danh từ đã được nhắc đến, giúp câu văn không bị lặp lại rườm rà. Có nhiều loại đại từ: chủ ngữ (I, you, he...), tân ngữ (me, him, them...), sở hữu (mine, his, theirs...) và phản thân (myself, yourself...).",
    examples: [
      GrammarExample(
        en: "Lan is my best friend. She helps me a lot.",
        vi: "Lan là bạn thân nhất của tôi. Cô ấy giúp tôi rất nhiều.",
      ),
      GrammarExample(
        en: "This book is mine, not yours.",
        vi: "Cuốn sách này là của tôi, không phải của bạn.",
      ),
      GrammarExample(
        en: "He hurt himself while playing basketball.",
        vi: "Anh ấy tự làm mình bị thương khi chơi bóng rổ.",
      ),
    ],
    questions: [
      GrammarQuestion(
        promptEn: "Can you give the pen to ___?",
        options: ["I", "me", "my", "mine"],
        correctIndex: 1,
      ),
      GrammarQuestion(
        promptEn: "That house is ___, not ours.",
        options: ["they", "them", "theirs", "their"],
        correctIndex: 2,
      ),
      GrammarQuestion(
        promptEn: "She made the cake ___.",
        options: ["her", "hers", "herself", "she"],
        correctIndex: 2,
      ),
      GrammarQuestion(
        promptEn: "___ are going to the market together.",
        options: ["Us", "We", "Our", "Ours"],
        correctIndex: 1,
      ),
      GrammarQuestion(
        promptEn: "The dog wagged ___ tail happily.",
        options: ["it", "its", "it's", "itself"],
        correctIndex: 1,
      ),
    ],
  ),
  GrammarTopic(
    name: "Tính từ",
    nameEn: "Adjectives",
    icon: Icons.palette_rounded,
    color: AppColors.blue,
    formula: "adjective + noun / to be + adjective",
    explanationVi: "Tính từ dùng để miêu tả đặc điểm, tính chất của danh từ, thường đứng trước danh từ hoặc sau động từ liên kết như 'to be', 'look', 'seem'. Tính từ trong tiếng Anh không thay đổi theo số ít/số nhiều của danh từ.",
    examples: [
      GrammarExample(
        en: "She has a beautiful voice.",
        vi: "Cô ấy có một giọng hát đẹp.",
      ),
      GrammarExample(
        en: "This soup tastes delicious.",
        vi: "Món súp này có vị ngon.",
      ),
      GrammarExample(
        en: "The children were extremely excited about the trip.",
        vi: "Bọn trẻ vô cùng phấn khích về chuyến đi.",
      ),
    ],
    questions: [
      GrammarQuestion(
        promptEn: "This is a ___ song.",
        options: ["beauty", "beautiful", "beautifully", "beautify"],
        correctIndex: 1,
      ),
      GrammarQuestion(
        promptEn: "The movie was really ___.",
        options: ["bore", "bored", "boring", "bore's"],
        correctIndex: 2,
      ),
      GrammarQuestion(
        promptEn: "He looks ___ today.",
        options: ["happy", "happily", "happiness", "happier than"],
        correctIndex: 0,
      ),
      GrammarQuestion(
        promptEn: "She felt ___ after the long trip.",
        options: ["tire", "tired", "tiring", "tires"],
        correctIndex: 1,
      ),
      GrammarQuestion(
        promptEn: "It's a ___ day for a picnic.",
        options: ["perfect", "perfectly", "perfection", "perfecting"],
        correctIndex: 0,
      ),
    ],
  ),
  GrammarTopic(
    name: "Động từ",
    nameEn: "Verbs",
    icon: Icons.flash_on_rounded,
    color: AppColors.purple,
    formula: "action verb / linking verb / modal verb / auxiliary verb",
    explanationVi: "Động từ diễn tả hành động hoặc trạng thái của chủ ngữ. Động từ hành động (run, eat) thể hiện việc làm cụ thể, động từ liên kết (be, seem, become) nối chủ ngữ với tính từ/danh từ bổ nghĩa, còn động từ khiếm khuyết (can, must, should) và trợ động từ (do, have, be) hỗ trợ tạo thì, thể phủ định, nghi vấn.",
    examples: [
      GrammarExample(
        en: "She runs five kilometers every morning.",
        vi: "Cô ấy chạy năm cây số mỗi sáng.",
      ),
      GrammarExample(
        en: "This cake tastes amazing.",
        vi: "Chiếc bánh này có vị tuyệt vời.",
      ),
      GrammarExample(
        en: "You must wear a helmet when riding a motorbike.",
        vi: "Bạn phải đội mũ bảo hiểm khi đi xe máy.",
      ),
    ],
    questions: [
      GrammarQuestion(
        promptEn: "Which is a linking verb?",
        options: ["run", "become", "eat", "write"],
        correctIndex: 1,
      ),
      GrammarQuestion(
        promptEn: "You ___ finish your homework before dinner.",
        options: ["must", "running", "happy", "quickly"],
        correctIndex: 0,
      ),
      GrammarQuestion(
        promptEn: "Which is an action verb?",
        options: ["seem", "dance", "be", "appear"],
        correctIndex: 1,
      ),
      GrammarQuestion(
        promptEn: "I ___ not understand this question.",
        options: ["do", "am", "is", "have"],
        correctIndex: 0,
      ),
      GrammarQuestion(
        promptEn: "She ___ speak three languages fluently.",
        options: ["can", "is", "was", "be"],
        correctIndex: 0,
      ),
    ],
  ),
  GrammarTopic(
    name: "Trạng từ",
    nameEn: "Adverbs",
    icon: Icons.speed_rounded,
    color: AppColors.teal,
    formula: "adjective + ly / modifies verb, adjective, or adverb",
    explanationVi: "Trạng từ bổ nghĩa cho động từ, tính từ hoặc trạng từ khác, thường trả lời cho câu hỏi 'như thế nào', 'khi nào', 'ở đâu', 'mức độ ra sao'. Nhiều trạng từ chỉ cách thức được tạo bằng cách thêm '-ly' vào sau tính từ.",
    examples: [
      GrammarExample(
        en: "He speaks English fluently.",
        vi: "Anh ấy nói tiếng Anh trôi chảy.",
      ),
      GrammarExample(
        en: "She arrived at the airport early.",
        vi: "Cô ấy đến sân bay sớm.",
      ),
      GrammarExample(
        en: "The movie was surprisingly good.",
        vi: "Bộ phim đó tốt một cách bất ngờ.",
      ),
    ],
    questions: [
      GrammarQuestion(
        promptEn: "She sings very ___.",
        options: ["beautiful", "beauty", "beautifully", "beautify"],
        correctIndex: 2,
      ),
      GrammarQuestion(
        promptEn: "He drives ___ on this street.",
        options: ["careful", "carefully", "care", "cares"],
        correctIndex: 1,
      ),
      GrammarQuestion(
        promptEn: "They finished the test ___.",
        options: ["quick", "quickly", "quickness", "quicker than"],
        correctIndex: 1,
      ),
      GrammarQuestion(
        promptEn: "The baby is sleeping ___ now.",
        options: ["peaceful", "peace", "peacefully", "peacefulness"],
        correctIndex: 2,
      ),
      GrammarQuestion(
        promptEn: "This test is ___ difficult.",
        options: ["extreme", "extremely", "extremity", "extremeness"],
        correctIndex: 1,
      ),
    ],
  ),
  GrammarTopic(
    name: "Lượng từ",
    nameEn: "Quantifiers",
    icon: Icons.pie_chart_rounded,
    color: AppColors.amber,
    formula: "some/any/much/many/a lot of/a few/a little + noun",
    explanationVi: "Lượng từ dùng để chỉ số lượng hoặc mức độ của danh từ. 'Many' và 'few' đi với danh từ đếm được, 'much' và 'little' đi với danh từ không đếm được, còn 'some/any/a lot of' có thể dùng cho cả hai loại danh từ tùy vào câu khẳng định, phủ định hay nghi vấn.",
    examples: [
      GrammarExample(
        en: "I have a few friends in this city.",
        vi: "Tôi có vài người bạn ở thành phố này.",
      ),
      GrammarExample(
        en: "There isn't much time left.",
        vi: "Không còn nhiều thời gian nữa.",
      ),
      GrammarExample(
        en: "She drinks a lot of water every day.",
        vi: "Cô ấy uống rất nhiều nước mỗi ngày.",
      ),
    ],
    questions: [
      GrammarQuestion(
        promptEn: "There are ___ apples in the basket.",
        options: ["much", "many", "little", "a little"],
        correctIndex: 1,
      ),
      GrammarQuestion(
        promptEn: "I don't have ___ money with me right now.",
        options: ["many", "much", "a few", "few"],
        correctIndex: 1,
      ),
      GrammarQuestion(
        promptEn: "She has ___ patience with children.",
        options: ["many", "a few", "a lot of", "few"],
        correctIndex: 2,
      ),
      GrammarQuestion(
        promptEn: "There is ___ sugar left in the jar.",
        options: ["few", "a few", "little", "many"],
        correctIndex: 2,
      ),
      GrammarQuestion(
        promptEn: "Do you have ___ questions about the lesson?",
        options: ["much", "any", "little", "a little"],
        correctIndex: 1,
      ),
    ],
  ),
  GrammarTopic(
    name: "Giới từ",
    nameEn: "Prepositions",
    icon: Icons.place_rounded,
    color: AppColors.pink,
    formula: "preposition + noun/pronoun (place, time, direction)",
    explanationVi: "Giới từ dùng để chỉ mối quan hệ về vị trí, thời gian hoặc phương hướng giữa các từ trong câu, và luôn theo sau bởi một danh từ hoặc đại từ. Việc chọn đúng giới từ (in, on, at, to, from...) phụ thuộc vào ngữ cảnh cụ thể và cần ghi nhớ qua thực hành nhiều.",
    examples: [
      GrammarExample(
        en: "The keys are on the table.",
        vi: "Chìa khóa ở trên bàn.",
      ),
      GrammarExample(
        en: "We will meet at 7 o'clock in the morning.",
        vi: "Chúng ta sẽ gặp nhau lúc 7 giờ sáng.",
      ),
      GrammarExample(
        en: "She walked into the room quietly.",
        vi: "Cô ấy bước vào phòng một cách yên lặng.",
      ),
    ],
    questions: [
      GrammarQuestion(
        promptEn: "The cat is sitting ___ the box.",
        options: ["in", "on", "at", "to"],
        correctIndex: 0,
      ),
      GrammarQuestion(
        promptEn: "I will see you ___ Monday morning.",
        options: ["in", "on", "at", "for"],
        correctIndex: 1,
      ),
      GrammarQuestion(
        promptEn: "We arrived ___ the airport two hours early.",
        options: ["in", "on", "at", "to"],
        correctIndex: 2,
      ),
      GrammarQuestion(
        promptEn: "She is afraid ___ spiders.",
        options: ["of", "for", "at", "in"],
        correctIndex: 0,
      ),
      GrammarQuestion(
        promptEn: "He walked ___ the park to get some fresh air.",
        options: ["into", "in", "to", "on"],
        correctIndex: 0,
      ),
    ],
  ),
  GrammarTopic(
    name: "Mạo từ",
    nameEn: "Articles",
    icon: Icons.text_fields_rounded,
    color: AppColors.blue,
    formula: "a / an + singular countable noun, the + specific noun",
    explanationVi: "'A' và 'an' là mạo từ không xác định, dùng khi nhắc đến một vật/người lần đầu tiên hoặc không cụ thể ('an' dùng trước âm nguyên âm). 'The' là mạo từ xác định, dùng khi cả người nói và người nghe đều biết rõ vật/người đang được nhắc đến.",
    examples: [
      GrammarExample(
        en: "I saw a dog in the park this morning.",
        vi: "Tôi thấy một con chó trong công viên sáng nay.",
      ),
      GrammarExample(
        en: "She is an honest person.",
        vi: "Cô ấy là một người trung thực.",
      ),
      GrammarExample(
        en: "The book you gave me was amazing.",
        vi: "Cuốn sách bạn đưa cho tôi thật tuyệt vời.",
      ),
    ],
    questions: [
      GrammarQuestion(
        promptEn: "She bought ___ umbrella because it was raining.",
        options: ["a", "an", "the", "-"],
        correctIndex: 1,
      ),
      GrammarQuestion(
        promptEn: "I met ___ interesting man at the conference.",
        options: ["a", "an", "the", "-"],
        correctIndex: 1,
      ),
      GrammarQuestion(
        promptEn: "Can you close ___ door, please?",
        options: ["a", "an", "the", "-"],
        correctIndex: 2,
      ),
      GrammarQuestion(
        promptEn: "He wants to be ___ doctor when he grows up.",
        options: ["a", "an", "the", "-"],
        correctIndex: 0,
      ),
      GrammarQuestion(
        promptEn: "___ moon is very bright tonight.",
        options: ["A", "An", "The", "-"],
        correctIndex: 2,
      ),
    ],
  ),
  GrammarTopic(
    name: "Liên từ",
    nameEn: "Conjunctions",
    icon: Icons.link_rounded,
    color: AppColors.purple,
    formula: "and / but / or / because / although + clause",
    explanationVi: "Liên từ dùng để nối hai từ, cụm từ hoặc mệnh đề lại với nhau, thể hiện mối quan hệ như bổ sung (and), tương phản (but, although), lựa chọn (or) hoặc nguyên nhân (because). Việc chọn đúng liên từ giúp câu văn mạch lạc và logic hơn.",
    examples: [
      GrammarExample(
        en: "I like tea, but my sister prefers coffee.",
        vi: "Tôi thích trà, nhưng em gái tôi thích cà phê hơn.",
      ),
      GrammarExample(
        en: "She stayed home because she was sick.",
        vi: "Cô ấy ở nhà vì bị ốm.",
      ),
      GrammarExample(
        en: "Although it was raining, we still went out.",
        vi: "Mặc dù trời mưa, chúng tôi vẫn ra ngoài.",
      ),
    ],
    questions: [
      GrammarQuestion(
        promptEn: "I was tired, ___ I kept working.",
        options: ["but", "and", "so", "or"],
        correctIndex: 0,
      ),
      GrammarQuestion(
        promptEn: "She studied hard ___ she wanted to pass the exam.",
        options: ["although", "because", "but", "or"],
        correctIndex: 1,
      ),
      GrammarQuestion(
        promptEn: "You can have tea ___ coffee.",
        options: ["and", "but", "or", "because"],
        correctIndex: 2,
      ),
      GrammarQuestion(
        promptEn: "___ he was late, he still caught the bus.",
        options: ["Because", "Although", "So", "And"],
        correctIndex: 1,
      ),
      GrammarQuestion(
        promptEn: "It was cold, ___ we wore warm coats.",
        options: ["so", "but", "or", "although"],
        correctIndex: 0,
      ),
    ],
  ),
  // ===================== CAU TRUC CAU (SENTENCE STRUCTURES) =====================
  GrammarTopic(
    name: "Câu so sánh",
    nameEn: "Comparisons",
    icon: Icons.compare_arrows_rounded,
    color: AppColors.teal,
    formula: "as + adj + as / adj-er than / the most + adj",
    explanationVi: "Câu so sánh dùng để đối chiếu hai hay nhiều đối tượng. So sánh bằng dùng 'as...as', so sánh hơn dùng '-er/more' + than, và so sánh nhất dùng 'the -est/the most'. Tính từ ngắn (1-2 âm tiết) thường thêm đuôi -er/-est, còn tính từ dài dùng more/most.",
    examples: [
      GrammarExample(
        en: "This book is as interesting as that one.",
        vi: "Cuốn sách này thú vị ngang với cuốn kia.",
      ),
      GrammarExample(
        en: "My brother is taller than me.",
        vi: "Anh trai tôi cao hơn tôi.",
      ),
      GrammarExample(
        en: "This is the most beautiful beach I have ever seen.",
        vi: "Đây là bãi biển đẹp nhất tôi từng thấy.",
      ),
    ],
    questions: [
      GrammarQuestion(
        promptEn: "This exam is ___ than the last one.",
        options: ["easy", "easier", "easiest", "more easy"],
        correctIndex: 1,
      ),
      GrammarQuestion(
        promptEn: "She is ___ student in the class.",
        options: ["smart", "smarter", "the smartest", "more smart"],
        correctIndex: 2,
      ),
      GrammarQuestion(
        promptEn: "He runs as ___ as his brother.",
        options: ["fast", "faster", "fastest", "more fast"],
        correctIndex: 0,
      ),
      GrammarQuestion(
        promptEn: "This phone is ___ expensive than that one.",
        options: ["more", "most", "much", "many"],
        correctIndex: 0,
      ),
      GrammarQuestion(
        promptEn: "It was ___ movie of the year.",
        options: ["good", "better", "the best", "more good"],
        correctIndex: 2,
      ),
    ],
  ),
  GrammarTopic(
    name: "Câu điều kiện",
    nameEn: "Conditional Sentences",
    icon: Icons.rule_rounded,
    color: AppColors.amber,
    formula: "If + present, will + V / If + past, would + V / If + past perfect, would have + V3",
    explanationVi: "Câu điều kiện diễn tả một sự việc có thể xảy ra tùy thuộc vào điều kiện đi kèm. Loại 0 nói về sự thật hiển nhiên, loại 1 nói về khả năng có thật ở tương lai, loại 2 nói về giả định không có thật ở hiện tại, và loại 3 nói về giả định trái với thực tế trong quá khứ.",
    examples: [
      GrammarExample(
        en: "If it rains, we will stay at home.",
        vi: "Nếu trời mưa, chúng tôi sẽ ở nhà.",
      ),
      GrammarExample(
        en: "If I had more time, I would learn to play the piano.",
        vi: "Nếu tôi có nhiều thời gian hơn, tôi sẽ học chơi piano.",
      ),
      GrammarExample(
        en: "If she had studied harder, she would have passed the exam.",
        vi: "Nếu cô ấy học chăm hơn, cô ấy đã đậu kỳ thi rồi.",
      ),
    ],
    questions: [
      GrammarQuestion(
        promptEn: "If you heat ice, it ___.",
        options: ["melt", "melts", "will melt", "melted"],
        correctIndex: 1,
      ),
      GrammarQuestion(
        promptEn: "If I have free time tomorrow, I ___ visit you.",
        options: ["will", "would", "had", "have"],
        correctIndex: 0,
      ),
      GrammarQuestion(
        promptEn: "If I ___ rich, I would travel around the world.",
        options: ["am", "was", "were", "be"],
        correctIndex: 2,
      ),
      GrammarQuestion(
        promptEn: "If she had studied, she ___ passed the test.",
        options: ["would", "would have", "will have", "will"],
        correctIndex: 1,
      ),
      GrammarQuestion(
        promptEn: "If it ___ tomorrow, we will cancel the picnic.",
        options: ["rain", "rains", "rained", "raining"],
        correctIndex: 1,
      ),
    ],
  ),
  GrammarTopic(
    name: "Câu ước",
    nameEn: "Wish Sentences",
    icon: Icons.star_rounded,
    color: AppColors.pink,
    formula: "S + wish(es) + S + V(past) / had + V3 / could + V",
    explanationVi: "Câu ước dùng để diễn tả mong muốn về điều không có thật ở hiện tại (wish + quá khứ đơn), điều tiếc nuối về quá khứ (wish + quá khứ hoàn thành) hoặc mong muốn thay đổi một tình huống (wish + could).",
    examples: [
      GrammarExample(
        en: "I wish I had more free time.",
        vi: "Tôi ước gì mình có nhiều thời gian rảnh hơn.",
      ),
      GrammarExample(
        en: "She wishes she had studied medicine.",
        vi: "Cô ấy ước gì mình đã học ngành y.",
      ),
      GrammarExample(
        en: "I wish I could speak French fluently.",
        vi: "Tôi ước gì mình có thể nói tiếng Pháp trôi chảy.",
      ),
    ],
    questions: [
      GrammarQuestion(
        promptEn: "I wish I ___ taller.",
        options: ["am", "was", "were", "be"],
        correctIndex: 2,
      ),
      GrammarQuestion(
        promptEn: "She wishes she ___ harder for the exam.",
        options: ["study", "studies", "had studied", "studying"],
        correctIndex: 2,
      ),
      GrammarQuestion(
        promptEn: "I wish I ___ drive a car.",
        options: ["can", "could", "will", "would"],
        correctIndex: 1,
      ),
      GrammarQuestion(
        promptEn: "He wishes he ___ more money right now.",
        options: ["has", "have", "had", "having"],
        correctIndex: 2,
      ),
      GrammarQuestion(
        promptEn: "They wish they ___ visited Da Lat last year.",
        options: ["have", "had", "has", "having"],
        correctIndex: 1,
      ),
    ],
  ),
  GrammarTopic(
    name: "Câu chủ động và bị động",
    nameEn: "Active & Passive Voice",
    icon: Icons.swap_horiz_rounded,
    color: AppColors.blue,
    formula: "Passive: S + be + V3/ed (+ by O)",
    explanationVi: "Câu chủ động nhấn mạnh người/vật thực hiện hành động, còn câu bị động nhấn mạnh người/vật chịu tác động của hành động đó, thường dùng khi không biết hoặc không cần nêu rõ ai thực hiện. Để chuyển sang bị động, ta dùng 'be' chia theo thì tương ứng cộng với động từ ở dạng quá khứ phân từ.",
    examples: [
      GrammarExample(
        en: "This dish is cooked by the chef every day.",
        vi: "Món này được đầu bếp nấu mỗi ngày.",
      ),
      GrammarExample(
        en: "My bicycle was stolen last night.",
        vi: "Xe đạp của tôi đã bị đánh cắp tối qua.",
      ),
      GrammarExample(
        en: "A new bridge is being built here.",
        vi: "Một cây cầu mới đang được xây ở đây.",
      ),
    ],
    questions: [
      GrammarQuestion(
        promptEn: "This letter ___ written by my father.",
        options: ["is", "are", "was", "were"],
        correctIndex: 2,
      ),
      GrammarQuestion(
        promptEn: "The windows ___ cleaned every week.",
        options: ["is", "are", "was", "be"],
        correctIndex: 1,
      ),
      GrammarQuestion(
        promptEn: "The cake ___ baked by my mother yesterday.",
        options: ["is", "was", "are", "were"],
        correctIndex: 1,
      ),
      GrammarQuestion(
        promptEn: "English ___ spoken in many countries.",
        options: ["is", "are", "was", "were"],
        correctIndex: 0,
      ),
      GrammarQuestion(
        promptEn: "The report will ___ finished by tomorrow.",
        options: ["be", "is", "was", "being"],
        correctIndex: 0,
      ),
    ],
  ),
  GrammarTopic(
    name: "Câu giả định",
    nameEn: "Subjunctive Mood",
    icon: Icons.auto_awesome_rounded,
    color: AppColors.purple,
    formula: "S + suggest/recommend/insist + (that) + S + V(bare) / If + S + were...",
    explanationVi: "Thức giả định dùng để diễn tả một điều mong muốn, đề nghị, yêu cầu hoặc một giả thiết không có thật. Sau các động từ như suggest, recommend, insist, demand, mệnh đề theo sau dùng động từ nguyên mẫu (không chia theo chủ ngữ), và trong câu giả định với 'if', 'be' luôn chia thành 'were' cho mọi chủ ngữ.",
    examples: [
      GrammarExample(
        en: "The doctor suggested that he rest for a few days.",
        vi: "Bác sĩ đề nghị anh ấy nên nghỉ ngơi vài ngày.",
      ),
      GrammarExample(
        en: "If I were you, I would apologize to her.",
        vi: "Nếu tôi là bạn, tôi sẽ xin lỗi cô ấy.",
      ),
      GrammarExample(
        en: "It is important that everyone arrive on time.",
        vi: "Điều quan trọng là mọi người phải đến đúng giờ.",
      ),
    ],
    questions: [
      GrammarQuestion(
        promptEn: "The teacher recommended that he ___ more carefully.",
        options: ["writes", "write", "wrote", "writing"],
        correctIndex: 1,
      ),
      GrammarQuestion(
        promptEn: "If I ___ you, I would take that job.",
        options: ["am", "was", "were", "be"],
        correctIndex: 2,
      ),
      GrammarQuestion(
        promptEn: "It is essential that she ___ present at the meeting.",
        options: ["is", "be", "was", "being"],
        correctIndex: 1,
      ),
      GrammarQuestion(
        promptEn: "The manager insisted that everyone ___ on time.",
        options: ["arrives", "arrive", "arrived", "arriving"],
        correctIndex: 1,
      ),
      GrammarQuestion(
        promptEn: "I wish it ___ Sunday today.",
        options: ["is", "was", "were", "be"],
        correctIndex: 2,
      ),
    ],
  ),
  GrammarTopic(
    name: "Câu mệnh lệnh",
    nameEn: "Imperative Sentences",
    icon: Icons.campaign_rounded,
    color: AppColors.teal,
    formula: "V(bare) + O / Don't + V(bare) + O",
    explanationVi: "Câu mệnh lệnh dùng để ra lệnh, yêu cầu, đưa lời khuyên hoặc hướng dẫn, thường không có chủ ngữ và bắt đầu bằng động từ nguyên mẫu. Thể phủ định thêm 'Don't' trước động từ, còn để lịch sự hơn có thể thêm 'please'.",
    examples: [
      GrammarExample(
        en: "Close the door, please.",
        vi: "Xin hãy đóng cửa lại.",
      ),
      GrammarExample(
        en: "Don't touch that, it's hot.",
        vi: "Đừng chạm vào đó, nóng lắm.",
      ),
      GrammarExample(
        en: "Turn left at the next intersection.",
        vi: "Rẽ trái ở ngã tư tiếp theo.",
      ),
    ],
    questions: [
      GrammarQuestion(
        promptEn: "___ the window, it's cold in here.",
        options: ["Close", "Closing", "Closed", "To close"],
        correctIndex: 0,
      ),
      GrammarQuestion(
        promptEn: "___ talk during the exam.",
        options: ["Not", "Don't", "Doesn't", "No"],
        correctIndex: 1,
      ),
      GrammarQuestion(
        promptEn: "___ careful when you cross the street.",
        options: ["Be", "Are", "Is", "Being"],
        correctIndex: 0,
      ),
      GrammarQuestion(
        promptEn: "Please ___ your homework before dinner.",
        options: ["finish", "finishes", "finishing", "finished"],
        correctIndex: 0,
      ),
      GrammarQuestion(
        promptEn: "___ be late for the meeting tomorrow.",
        options: ["Not", "No", "Don't", "Never mind"],
        correctIndex: 2,
      ),
    ],
  ),
  GrammarTopic(
    name: "Câu tường thuật",
    nameEn: "Reported Speech",
    icon: Icons.record_voice_over_rounded,
    color: AppColors.amber,
    formula: "S + said (that) + S + V(past) / asked if...",
    explanationVi: "Câu tường thuật dùng để thuật lại lời nói của người khác mà không trích dẫn nguyên văn. Khi chuyển từ câu trực tiếp sang gián tiếp, thì của động từ thường lùi về một bậc (hiện tại thành quá khứ, quá khứ thành quá khứ hoàn thành), đồng thời đại từ và trạng từ chỉ thời gian/nơi chốn cũng thay đổi cho phù hợp.",
    examples: [
      GrammarExample(
        en: "She said, \"I am tired.\" -> She said that she was tired.",
        vi: "Cô ấy nói rằng cô ấy mệt.",
      ),
      GrammarExample(
        en: "He said, \"I will call you tomorrow.\" -> He said that he would call me the next day.",
        vi: "Anh ấy nói rằng anh ấy sẽ gọi cho tôi vào ngày hôm sau.",
      ),
      GrammarExample(
        en: "They asked, \"Do you live here?\" -> They asked if I lived there.",
        vi: "Họ hỏi liệu tôi có sống ở đó không.",
      ),
    ],
    questions: [
      GrammarQuestion(
        promptEn: "She said that she ___ happy.",
        options: ["is", "was", "be", "being"],
        correctIndex: 1,
      ),
      GrammarQuestion(
        promptEn: "He said he ___ finished his homework.",
        options: ["has", "have", "had", "having"],
        correctIndex: 2,
      ),
      GrammarQuestion(
        promptEn: "They asked if I ___ coming to the party.",
        options: ["am", "was", "be", "is"],
        correctIndex: 1,
      ),
      GrammarQuestion(
        promptEn: "She told me she ___ visit her mother the next day.",
        options: ["will", "would", "is going to", "shall"],
        correctIndex: 1,
      ),
      GrammarQuestion(
        promptEn: "He said that he ___ to Da Nang the week before.",
        options: ["goes", "went", "had gone", "was going"],
        correctIndex: 2,
      ),
    ],
  ),
  // ===================== MENH DE QUAN HE (RELATIVE CLAUSES) =====================
  GrammarTopic(
    name: "Mệnh đề quan hệ xác định",
    nameEn: "Defining Relative Clauses",
    icon: Icons.filter_alt_rounded,
    color: AppColors.pink,
    formula: "Noun + who/which/that + clause (no comma)",
    explanationVi: "Mệnh đề quan hệ xác định cung cấp thông tin cần thiết để xác định rõ danh từ đang được nhắc đến, và không được ngăn cách bằng dấu phẩy với mệnh đề chính. 'Who' dùng cho người, 'which' dùng cho vật, và 'that' có thể thay thế cho cả hai trong loại mệnh đề này.",
    examples: [
      GrammarExample(
        en: "The man who lives next door is a doctor.",
        vi: "Người đàn ông sống ở nhà kế bên là một bác sĩ.",
      ),
      GrammarExample(
        en: "This is the song that made me fall in love with music.",
        vi: "Đây là bài hát đã khiến tôi yêu thích âm nhạc.",
      ),
      GrammarExample(
        en: "I need a book which explains grammar simply.",
        vi: "Tôi cần một cuốn sách giải thích ngữ pháp một cách đơn giản.",
      ),
    ],
    questions: [
      GrammarQuestion(
        promptEn: "The girl ___ is singing on stage is my sister.",
        options: ["which", "who", "whose", "where"],
        correctIndex: 1,
      ),
      GrammarQuestion(
        promptEn: "This is the car ___ I bought last year.",
        options: ["who", "which", "whom", "whose"],
        correctIndex: 1,
      ),
      GrammarQuestion(
        promptEn: "I met a man ___ speaks five languages.",
        options: ["which", "who", "whose", "where"],
        correctIndex: 1,
      ),
      GrammarQuestion(
        promptEn: "The house ___ roof is red belongs to my uncle.",
        options: ["who", "which", "whose", "that"],
        correctIndex: 2,
      ),
      GrammarQuestion(
        promptEn: "This is the restaurant ___ we had dinner last night.",
        options: ["who", "whose", "where", "whom"],
        correctIndex: 2,
      ),
    ],
  ),
  GrammarTopic(
    name: "Mệnh đề quan hệ không xác định",
    nameEn: "Non-defining Relative Clauses",
    icon: Icons.info_rounded,
    color: AppColors.blue,
    formula: "Noun, who/which + extra info, ...",
    explanationVi: "Mệnh đề quan hệ không xác định chỉ cung cấp thông tin bổ sung, không cần thiết để xác định danh từ vì danh từ đó đã rõ ràng (thường là tên riêng hoặc vật duy nhất), và luôn được ngăn cách bằng dấu phẩy. Khác với mệnh đề xác định, 'that' không được dùng trong loại này.",
    examples: [
      GrammarExample(
        en: "My father, who is 60 years old, still runs every morning.",
        vi: "Bố tôi, năm nay 60 tuổi, vẫn chạy bộ mỗi sáng.",
      ),
      GrammarExample(
        en: "Hanoi, which is the capital of Vietnam, has a long history.",
        vi: "Hà Nội, thủ đô của Việt Nam, có một lịch sử lâu đời.",
      ),
      GrammarExample(
        en: "My sister, who lives in Da Nang, is visiting us next week.",
        vi: "Chị tôi, người sống ở Đà Nẵng, sẽ đến thăm chúng tôi vào tuần sau.",
      ),
    ],
    questions: [
      GrammarQuestion(
        promptEn: "My mother, ___ is a teacher, loves reading books.",
        options: ["that", "who", "whom", "where"],
        correctIndex: 1,
      ),
      GrammarQuestion(
        promptEn: "Paris, ___ is the capital of France, is famous for its architecture.",
        options: ["that", "which", "whom", "whose"],
        correctIndex: 1,
      ),
      GrammarQuestion(
        promptEn: "This song, ___ I heard on the radio, became my favorite.",
        options: ["that", "which", "whom", "whose"],
        correctIndex: 1,
      ),
      GrammarQuestion(
        promptEn:
            "My best friend, ___ house is near the beach, invited me over.",
        options: ["who", "whom", "whose", "that"],
        correctIndex: 2,
      ),
      GrammarQuestion(
        promptEn: "Mr. Nam, ___ teaches us math, is very kind.",
        options: ["that", "who", "whose", "where"],
        correctIndex: 1,
      ),
    ],
  ),
];

/// Ten chu de theo ngon ngu giao dien hien tai - giong topicLabel() ben
/// vocabulary_data.dart.
String grammarTopicLabel(WidgetRef ref, GrammarTopic topic) =>
    ref.watch(appLanguageProvider) == AppLanguage.en
    ? topic.nameEn
    : topic.name;
