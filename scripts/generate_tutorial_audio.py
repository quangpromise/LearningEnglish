"""Tao giong doc Kokoro-82M cho trinh phat huong dan bai tap (GymTalk).

Sinh DUNG cac cau ma app se doc (xem app/lib/features/fitness/data/
exercise_tutorial.dart):
  - Tong quan moi bai: "Today's exercise: the {nameEn}. It works your ..."
  - Tung buoc: "Step one. {instructionsEn[i]}"
  - Tung tu vung gym (the tu khoa) + cau phan hoi "Great job!" / "Nice try!"

Moi cau -> app/assets/tutorial_audio/<fnv1a32(cau)>.mp3. App tinh cung ma
bam tu cau can doc: co file thi phat giong Kokoro, khong co thi quay ve TTS
cua may (khong bao gio cam). manifest.json liet ke {ma: cau} - test
test/tutorial_audio_manifest_test.dart kiem tra MOI cau app sinh ra deu co
file, nen neu script nay dung cau lech app 1 ky tu la CI bao ngay.

Chay (lan dau ~20-40 phut tren CPU; chay lai chi tao phan con thieu):
    python scripts/generate_tutorial_audio.py            # tao tat ca
    python scripts/generate_tutorial_audio.py --dry-run  # chi dem/xem mau
    python scripts/generate_tutorial_audio.py --limit 5  # thu vai cau

Yeu cau: kokoro_onnx + soundfile (pip), model Kokoro trong
~/.cache/hyperframes/tts (co san sau khi chay `npx hyperframes tts` 1 lan),
ffmpeg trong PATH. Model Kokoro-82M: Apache-2.0 - dung thuong mai duoc.
"""

import argparse
import json
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path

STEP_WORDS = ['one', 'two', 'three', 'four', 'five', 'six', 'seven']
FEEDBACK = ['Great job!', 'Nice try!']


def fnv1a32(text: str) -> str:
    """FNV-1a 32-bit tren UTF-8 -> 8 ky tu hex (khop tutorialAudioKey)."""
    h = 0x811C9DC5
    for b in text.encode('utf-8'):
        h ^= b
        h = (h * 0x01000193) & 0xFFFFFFFF
    return f'{h:08x}'


def load_muscle_map(i18n_path: Path) -> dict:
    src = i18n_path.read_text(encoding='utf-8')
    block = src[src.index('const _muscleEn'):]
    block = block[:block.index('};')]
    return dict(re.findall(r"'([^']+)': '([^']+)',", block))


def load_gym_words(vocab_path: Path) -> list:
    src = vocab_path.read_text(encoding='utf-8')
    block = src[src.index('const kGymWords'):]
    words = re.findall(r"^\s+en: '([^']+)',", block, re.M)
    words += re.findall(r'^\s+en: "([^"]+)",', block, re.M)
    return words


def join_english(items: list) -> str:
    unique = []
    for item in items:
        if item and item not in unique:
            unique.append(item)
    if len(unique) <= 1:
        return ''.join(unique)
    return ', '.join(unique[:-1]) + ' and ' + unique[-1]


def exercise_texts(ex: dict, muscle_en: dict) -> list:
    """Cac cau app doc cho 1 bai - PHAI khop buildExerciseTutorial."""
    muscles = ([ex['primaryMuscle']] + list(ex['secondaryMuscles']))[:3]
    labels = []
    for m in muscles:
        part = m.split(' · ')[0].strip()
        labels.append(muscle_en.get(part, part).lower())
    muscle_list = join_english(labels)
    overview = f"Today's exercise: the {ex['nameEn']}."
    if muscle_list:
        overview += f' It works your {muscle_list}.'
    steps = ex.get('instructionsEn') or ex['instructions']
    texts = [overview]
    for i, step in enumerate(steps):
        word = STEP_WORDS[i] if i < len(STEP_WORDS) else str(i + 1)
        texts.append(f'Step {word}. {step}')
    return texts


def all_texts(app_dir: Path) -> list:
    exercises = json.loads(
        (app_dir / 'assets/fitness/exercises_seed.json').read_text(encoding='utf-8'),
    )
    muscle_en = load_muscle_map(app_dir / 'lib/features/fitness/data/exercise_i18n.dart')
    texts = []
    for ex in exercises:
        texts += exercise_texts(ex, muscle_en)
    texts += load_gym_words(app_dir / 'lib/features/fitness/data/gym_vocabulary.dart')
    texts += FEEDBACK
    seen, unique = set(), []
    for t in texts:
        if t not in seen:
            seen.add(t)
            unique.append(t)
    return unique


def main() -> int:
    root = Path(__file__).resolve().parent.parent
    parser = argparse.ArgumentParser(description=__doc__.split('\n')[0])
    parser.add_argument('--app-dir', default=str(root / 'app'))
    parser.add_argument('--voice', default='am_michael')
    parser.add_argument('--speed', type=float, default=0.95)
    parser.add_argument('--bitrate', default='40k')
    parser.add_argument('--limit', type=int, default=0)
    parser.add_argument('--dry-run', action='store_true')
    args = parser.parse_args()

    app_dir = Path(args.app_dir)
    out_dir = app_dir / 'assets/tutorial_audio'
    texts = all_texts(app_dir)
    manifest = {fnv1a32(t): t for t in texts}
    if len(manifest) != len(texts):
        print('LOI: trung ma bam giua 2 cau khac nhau', file=sys.stderr)
        return 1
    todo = [t for t in texts if not (out_dir / f'{fnv1a32(t)}.mp3').exists()]
    print(f'{len(texts)} cau, con thieu {len(todo)}')
    if args.dry_run:
        for t in todo[:8]:
            print(f'  {fnv1a32(t)}  {t}')
        return 0
    if args.limit:
        todo = todo[: args.limit]

    import kokoro_onnx  # noqa: E402 - chi can khi tao that
    import soundfile as sf

    cache = Path.home() / '.cache/hyperframes/tts'
    model = kokoro_onnx.Kokoro(
        str(cache / 'models/kokoro-v1.0.onnx'),
        str(cache / 'voices/voices-v1.0.bin'),
    )
    out_dir.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory() as tmp:
        for n, text in enumerate(todo, 1):
            key = fnv1a32(text)
            samples, rate = model.create(
                text, voice=args.voice, speed=args.speed, lang='en-us',
            )
            wav = os.path.join(tmp, f'{key}.wav')
            sf.write(wav, samples, rate)
            subprocess.run(
                [
                    'ffmpeg', '-hide_banner', '-loglevel', 'error', '-y',
                    '-i', wav, '-ac', '1', '-b:a', args.bitrate,
                    str(out_dir / f'{key}.mp3'),
                ],
                check=True,
            )
            print(f'[{n}/{len(todo)}] {key} {text[:60]}', flush=True)

    # manifest chi gom cau DA co file (chay --limit van dung).
    done = {k: t for k, t in manifest.items() if (out_dir / f'{k}.mp3').exists()}
    (out_dir / 'manifest.json').write_text(
        json.dumps(dict(sorted(done.items())), ensure_ascii=False, indent=1),
        encoding='utf-8',
    )
    print(f'manifest: {len(done)}/{len(manifest)} cau co audio')
    return 0


if __name__ == '__main__':
    sys.exit(main())
