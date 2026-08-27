"""Speech-to-text bằng faster-whisper (mã nguồn mở, chạy local, miễn phí)."""

from faster_whisper import WhisperModel

# "base" đủ nhanh cho hội thoại thời gian thực trên CPU; đổi sang "small"/"medium"
# nếu server có GPU và cần độ chính xác cao hơn.
_model: WhisperModel | None = None


def get_model() -> WhisperModel:
    global _model
    if _model is None:
        _model = WhisperModel("base", device="auto", compute_type="int8")
    return _model


def transcribe(audio_path: str) -> str:
    """Nhận đường dẫn file audio (wav 16kHz mono), trả về văn bản nhận diện được."""
    segments, _info = get_model().transcribe(audio_path, language="en")
    return " ".join(seg.text.strip() for seg in segments)
