"""Text-to-speech bằng Piper (mã nguồn mở, chạy local, miễn phí).

Piper không có Python binding chính thức ổn định — cách phổ biến nhất là
gọi binary `piper` đã cài sẵn qua subprocess. Cài đặt & tải giọng nói tại:
https://github.com/rhasspy/piper
"""

import subprocess
import tempfile

PIPER_BIN = "piper"  # đổi thành đường dẫn đầy đủ nếu piper không nằm trong PATH
VOICE_MODEL = "en_US-lessac-medium.onnx"  # tải sẵn model giọng tại thư mục chạy piper


def synthesize(text: str) -> bytes:
    """Chuyển văn bản thành audio wav (bytes) bằng Piper."""
    with tempfile.NamedTemporaryFile(suffix=".wav") as tmp:
        process = subprocess.run(
            [PIPER_BIN, "--model", VOICE_MODEL, "--output_file", tmp.name],
            input=text.encode("utf-8"),
            capture_output=True,
            check=True,
        )
        if process.returncode != 0:
            raise RuntimeError(f"Piper lỗi: {process.stderr.decode()}")
        tmp.seek(0)
        return tmp.read()
