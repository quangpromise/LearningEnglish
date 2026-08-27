"""WebSocket server cho pipeline fallback: faster-whisper -> Ollama -> Piper.

gemini-proxy (Node.js) forward audio sang server này khi Gemini Live hết
quota. Giao thức: nhận audio (bytes) qua WebSocket, xử lý xong 1 lượt nói,
trả về audio phản hồi (bytes) qua cùng kết nối.

KHUNG CODE — luồng ghép audio theo chunk/silence-detection thực tế cần hoàn
thiện thêm (ví dụ dùng VAD để biết khi nào người dùng nói xong 1 câu).
"""

import asyncio
import tempfile
import wave

import websockets

from stt import transcribe
from llm import reply
from tts import synthesize

HOST = "localhost"
PORT = 8788


async def handle_connection(websocket):
    print("[fallback-pipeline] Client kết nối (thường là gemini-proxy)")
    audio_buffer = bytearray()

    async for message in websocket:
        # TODO: dùng VAD (vd webrtcvad) để phát hiện khi người dùng dừng nói,
        # thay vì giả định mỗi message là 1 câu hoàn chỉnh.
        audio_buffer.extend(message)

        with tempfile.NamedTemporaryFile(suffix=".wav") as tmp:
            with wave.open(tmp.name, "wb") as wav_file:
                wav_file.setnchannels(1)
                wav_file.setsampwidth(2)
                wav_file.setframerate(16000)
                wav_file.writeframes(bytes(audio_buffer))

            user_text = transcribe(tmp.name)

        if not user_text.strip():
            continue

        print(f"[fallback-pipeline] Nghe được: {user_text}")
        reply_text = reply(user_text)
        print(f"[fallback-pipeline] Trả lời: {reply_text}")

        audio_response = synthesize(reply_text)
        await websocket.send(audio_response)
        audio_buffer.clear()


async def main():
    print(f"[fallback-pipeline] Đang lắng nghe ws://{HOST}:{PORT}")
    async with websockets.serve(handle_connection, HOST, PORT):
        await asyncio.Future()  # chạy mãi


if __name__ == "__main__":
    asyncio.run(main())
