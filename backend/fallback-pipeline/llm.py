"""LLM hội thoại qua Ollama tự host (mã nguồn mở, miễn phí, chạy local)."""

import ollama

BASE_PROMPT = """Bạn là một người bạn bản ngữ tiếng Anh, trò chuyện tự nhiên,
thân thiện với người đang học tiếng Anh ({learner}). Quy tắc trả lời:
1. Luôn trả lời bằng tiếng Anh, câu ngắn gọn, tự nhiên như hội thoại đời thường.
2. Nếu câu người dùng nói có lỗi ngữ pháp/từ vựng rõ ràng, nhẹ nhàng chỉ ra
   cách nói đúng trước khi tiếp tục hội thoại (không giảng giải dài dòng).
3. Nếu một từ bị nhận diện sai lặp lại nhiều lần một cách bất thường, đó có
   thể là dấu hiệu phát âm chưa chuẩn — gợi ý người dùng thử phát âm lại từ đó.
4. Giữ không khí hội thoại thoải mái, khích lệ, không chê bai.
5. {guide}
"""

# Hướng dẫn riêng theo cấp học — khớp LEVEL_PROMPTS trong
# gemini-proxy/src/geminiClient.js và docs/research-level-based-content.md mục 6.
LEVEL_PROMPTS = {
    "basic": (
        "người mới bắt đầu, trình độ A1-A2",
        "Nói chậm, chỉ dùng từ rất thông dụng, câu tối đa 8 từ. Hỏi câu dạng "
        "Có/Không hoặc chọn 1 trong 2. Mỗi lượt chỉ sửa 1 lỗi quan trọng nhất; "
        "nếu người học bí hoặc nói tiếng Việt, gợi ý từ tiếng Anh tương ứng.",
    ),
    "intermediate": (
        "trình độ trung bình",
        "Dùng từ vựng đời thường, hỏi câu mở về cuộc sống hằng ngày.",
    ),
    "advanced": (
        "nâng cao B1-C1, đang đi làm hoặc luyện thi TOEIC/IELTS",
        "Dùng thành ngữ và cụm động từ tự nhiên, đề xuất nhập vai tình huống thật "
        "(họp, phỏng vấn, câu hỏi kiểu IELTS Speaking). Nếu câu đúng nhưng chưa "
        "tự nhiên, gợi ý cách nói tự nhiên hơn.",
    ),
}

_MODEL = "llama3.2"  # đổi sang "phi4" hoặc model khác đã `ollama pull` sẵn


def normalize_level(level: str | None) -> str:
    return level if level in LEVEL_PROMPTS else "intermediate"


def system_prompt_for(level: str | None) -> str:
    learner, guide = LEVEL_PROMPTS[normalize_level(level)]
    return BASE_PROMPT.format(learner=learner, guide=guide)


class Conversation:
    """1 cuộc hội thoại riêng cho mỗi kết nối — trước đây dùng 1 lịch sử toàn
    cục, khiến nhiều người dùng cùng lúc bị trộn lẫn hội thoại của nhau."""

    def __init__(self, level: str | None = None) -> None:
        self._history: list[dict] = [
            {"role": "system", "content": system_prompt_for(level)}
        ]

    def reply(self, user_text: str) -> str:
        """Gửi câu nói (đã chuyển từ giọng nói sang văn bản) tới LLM, trả về câu trả lời."""
        self._history.append({"role": "user", "content": user_text})
        response = ollama.chat(model=_MODEL, messages=self._history)
        reply_text = response["message"]["content"]
        self._history.append({"role": "assistant", "content": reply_text})
        return reply_text
