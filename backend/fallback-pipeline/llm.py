"""LLM hội thoại qua Ollama tự host (mã nguồn mở, miễn phí, chạy local)."""

import ollama

SYSTEM_PROMPT = """Bạn là một người bạn bản ngữ tiếng Anh, trò chuyện tự nhiên,
thân thiện với người đang học tiếng Anh. Quy tắc trả lời:
1. Luôn trả lời bằng tiếng Anh, câu ngắn gọn, tự nhiên như hội thoại đời thường.
2. Nếu câu người dùng nói có lỗi ngữ pháp/từ vựng rõ ràng, nhẹ nhàng chỉ ra
   cách nói đúng trước khi tiếp tục hội thoại (không giảng giải dài dòng).
3. Nếu một từ bị nhận diện sai lặp lại nhiều lần một cách bất thường, đó có
   thể là dấu hiệu phát âm chưa chuẩn — gợi ý người dùng thử phát âm lại từ đó.
4. Giữ không khí hội thoại thoải mái, khích lệ, không chê bai.
"""

_history: list[dict] = [{"role": "system", "content": SYSTEM_PROMPT}]
_MODEL = "llama3.2"  # đổi sang "phi4" hoặc model khác đã `ollama pull` sẵn


def reply(user_text: str) -> str:
    """Gửi câu nói (đã chuyển từ giọng nói sang văn bản) tới LLM, trả về câu trả lời."""
    _history.append({"role": "user", "content": user_text})
    response = ollama.chat(model=_MODEL, messages=_history)
    reply_text = response["message"]["content"]
    _history.append({"role": "assistant", "content": reply_text})
    return reply_text


def reset_conversation() -> None:
    global _history
    _history = [{"role": "system", "content": SYSTEM_PROMPT}]
