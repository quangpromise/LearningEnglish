"""Tao am bao gio nghi cua buoi tap (GymTalk, issue #131).

Tai 2 file goc CC0 (kiem tra sha256), cat / fade / tron mono / chuan hoa roi
ghi WAV PCM 16-bit mono 44.1 kHz vao app/assets/audio/:

- rest_end_bell.wav  - het gio nghi: "Pleasing Bell Sound Effect" cua Spring
  Spring (Julie Damsgaard), OpenGameArt, CC0.
- rest_tick.wav      - 3-2-1 cuoi gio nghi: woodblock `wood_click_pp_rr1.wav`
  cua VCSL (Versilian Studios LLC), CC0.

Nguon, giay phep va ly do chon: docs/research-rest-timer-sound.md,
ATTRIBUTION.md. Can ffmpeg trong PATH. Chay lai: python scripts/make_rest_sounds.py
"""

import array
import hashlib
import math
import subprocess
import tempfile
import urllib.request
import wave
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / 'app' / 'assets' / 'audio'
RATE = 44100

SOURCES = {
    'bell': {
        'url': 'https://opengameart.org/sites/default/files/pleasing-bell.wav',
        'sha256': '3c851939ccf9146e49c1be0272386fdca1b1442bb034a5e6dcdfb3e0e144a411',
    },
    'tick': {
        'url': 'https://raw.githubusercontent.com/sgossner/VCSL/master/'
        'Idiophones/Struck%20Idiophones/Woodblock/wood_click_pp_rr1.wav',
        'sha256': '2c21a5de6f3ddd51ce851325ba6caa4a187422c51299da7b2fdc4f51ae5e9ee1',
    },
}

# (file ra, nguon, do dai toi da (s), fade-out (s), dinh (dBFS)). Chuong to
# nhat (nghe ro trong phong gym); tieng mo nho hon de khong at chuong.
OUTPUTS = [
    ('rest_end_bell.wav', 'bell', None, 0.06, -1.0),
    ('rest_tick.wav', 'tick', 0.16, 0.06, -4.0),
]


def fetch(name, cache):
    src = SOURCES[name]
    path = cache / f'{name}.wav'
    if not path.exists():
        with urllib.request.urlopen(src['url'], timeout=60) as r:
            path.write_bytes(r.read())
    digest = hashlib.sha256(path.read_bytes()).hexdigest()
    if digest != src['sha256']:
        raise SystemExit(f'{name}: sha256 khac ban da duyet ({digest})')
    return path


def decode_mono(path):
    """Giai ma ve float32 mono 44.1 kHz (trung binh 2 kenh)."""
    raw = subprocess.run(
        ['ffmpeg', '-v', 'error', '-i', str(path), '-ac', '1', '-ar',
         str(RATE), '-f', 'f32le', '-'],
        check=True, capture_output=True,
    ).stdout
    return array.array('f', raw).tolist()


def process(x, max_len, fade, peak_db):
    peak = max(abs(v) for v in x)
    # Cat lang dau: giu 2 ms truoc diem bat dau (attack con sac).
    onset = next(i for i, v in enumerate(x) if abs(v) > 0.02 * peak)
    x = x[max(0, onset - int(0.002 * RATE)):]
    if max_len is not None:
        x = x[: int(max_len * RATE)]
    # Fade-out nua cosin o cuoi: khong "tach" khi het file.
    n = min(len(x), int(fade * RATE))
    for i in range(n):
        x[len(x) - n + i] *= 0.5 * (1 + math.cos(math.pi * (i + 1) / n))
    gain = 10 ** (peak_db / 20) / max(abs(v) for v in x)
    return [v * gain for v in x]


def write_wav(path, x):
    pcm = array.array('h', (max(-32768, min(32767, round(v * 32767))) for v in x))
    with wave.open(str(path), 'wb') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(pcm.tobytes())


def main():
    with tempfile.TemporaryDirectory() as tmp:
        cache = Path(tmp)
        for out, name, max_len, fade, peak_db in OUTPUTS:
            x = process(decode_mono(fetch(name, cache)), max_len, fade, peak_db)
            write_wav(OUT / out, x)
            print(f'{out}: {len(x) / RATE:.3f} s, dinh {peak_db} dBFS')


if __name__ == '__main__':
    main()
