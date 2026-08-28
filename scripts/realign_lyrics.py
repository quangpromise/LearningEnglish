"""
Canh lai startSeconds cho tung dong lyric trong songs_data.dart bang cach
chay ASR (faster-whisper) tren file audio that de lay timestamp cap-tu that,
roi align tuan tu voi text lyric da co san (chi ASR ra timestamp, KHONG doi
noi dung tieng Anh/Viet da viet san - tranh ASR nghe nham lam sai loi bai hat).

Usage: python scripts/realign_lyrics.py [--dry-run] [--only SONG_FILE_STEM]
"""

import re
import sys
import json
from pathlib import Path

from faster_whisper import WhisperModel

ROOT = Path(__file__).resolve().parent.parent
DART_FILE = ROOT / "app" / "lib" / "features" / "music_player" / "data" / "songs_data.dart"
AUDIO_DIR = ROOT / "content" / "audio"
CACHE_FILE = ROOT / "scripts" / ".whisper_cache.json"

STRING_RE = r'"(?:[^"\\]|\\.)*"|\'(?:[^\'\\]|\\.)*\''

SONG_RE = re.compile(
    r"audioUrl:\s*'\$\{_audioBaseUrl\}([\w\-]+)\.mp3'", re.MULTILINE
)

LYRIC_RE = re.compile(
    r"LyricLine\(\s*(?P<num>[\d.]+)\s*,\s*(?P<en>" + STRING_RE + r")\s*,\s*(?P<vi>" + STRING_RE + r")\s*,?\s*\)",
    re.MULTILINE | re.DOTALL,
)


def unquote(s: str) -> str:
    return s[1:-1]


def normalize_word(w: str) -> str:
    w = w.lower()
    w = re.sub(r"[^a-z']", "", w)
    return w


def normalize_line_words(en: str) -> list[str]:
    words = re.split(r"\s+", en.strip())
    return [normalize_word(w) for w in words if normalize_word(w)]


def find_song_blocks(text: str):
    """Return list of dicts: {stem, lyrics_start, lyrics_end, lines: [(num_start, num_end, en, vi)]}"""
    song_matches = list(SONG_RE.finditer(text))
    blocks = []
    for i, m in enumerate(song_matches):
        stem = m.group(1)
        block_start = m.end()
        block_end = song_matches[i + 1].start() if i + 1 < len(song_matches) else len(text)
        block_text = text[block_start:block_end]
        lines = []
        for lm in LYRIC_RE.finditer(block_text):
            num_start = block_start + lm.start("num")
            num_end = block_start + lm.end("num")
            en = unquote(lm.group("en"))
            vi = unquote(lm.group("vi"))
            lines.append((num_start, num_end, en, vi, float(lm.group("num"))))
        blocks.append({"stem": stem, "lines": lines})
    return blocks


def transcribe_words(model, audio_path: Path, cache: dict):
    key = audio_path.name
    if key in cache:
        return cache[key]
    print(f"  [ASR] transcribing {audio_path.name} ...", flush=True)
    segments, info = model.transcribe(
        str(audio_path), language="en", word_timestamps=True, vad_filter=False
    )
    words = []
    for seg in segments:
        if not seg.words:
            continue
        for w in seg.words:
            nw = normalize_word(w.word)
            if nw:
                words.append({"w": nw, "t": round(w.start, 3)})
    cache[key] = words
    return words


def align_lines(lines, asr_words):
    """
    lines: list of (num_start, num_end, en, vi, old_num)
    asr_words: list of {"w":..., "t":...}
    Returns dict num_start -> new_time (float) for lines we're confident about.
    """
    expected = []  # flat list of normalized words, with (line_idx, word_idx_in_line)
    line_word_start_idx = []  # index into `expected` where each line's first word is
    for li, (_, _, en, _, _) in enumerate(lines):
        line_word_start_idx.append(len(expected))
        for w in normalize_line_words(en):
            expected.append(w)

    asr_seq = [w["w"] for w in asr_words]
    n_asr = len(asr_seq)

    # Khop TUAN TU TIEN (greedy, khong bao gio nhay lui) thay vi
    # difflib.SequenceMatcher (global). Nhieu bai co doan diep khuc/verse
    # duoc HAT LAI y nguyen o cuoi bai (reprise) - vi du "Circles": ca doan
    # mo dau duoc hat lai gan cuoi. Global matcher co the "an nham" ca khoi
    # chu dau tien vao LAN HAT LAI (vi no cung la 1 chuoi khop dai), khien
    # tat ca cac dong ngay sau bi dồn sai ve cuoi bai. Quet tien voi con tro
    # CHI TANG, tim tu khop TRONG PHAM VI gan nhat phia truoc, dam bao luon
    # bat duoc LAN HAT DAU TIEN cua moi cau, khong bao gio nhay lui.
    # Gioi han hep (khong phai 40-60) CO CHU DICH: tu pho bien (vd "you",
    # "the") lap lai rat nhieu trong bai hat - neu cho phep tim xa, 1 tu
    # khong khop se khien con tro "nhay co hoi" toi 1 lan xuat hien XA VA SAI
    # cua tu pho bien do, lam sai lech ca doan sau. Gioi han hep buoc loi
    # (neu co) chi lam lech vai giay thay vi hang chuc giay.
    LOOKAHEAD = 12
    ptr = 0
    asr_idx_for_expected = {}
    for ei, w in enumerate(expected):
        limit = min(n_asr, ptr + LOOKAHEAD)
        found = None
        for j in range(ptr, limit):
            if asr_seq[j] == w:
                found = j
                break
        if found is not None:
            asr_idx_for_expected[ei] = found
            ptr = found + 1

    result = {}
    for li, (num_start, _, en, _, old_num) in enumerate(lines):
        start_expected_idx = line_word_start_idx[li]
        end_expected_idx = (
            line_word_start_idx[li + 1] if li + 1 < len(lines) else len(expected)
        )
        found_asr_idx = None
        for ei in range(start_expected_idx, end_expected_idx):
            if ei in asr_idx_for_expected:
                offset_words = ei - start_expected_idx
                asr_idx = asr_idx_for_expected[ei]
                t = asr_words[asr_idx]["t"]
                if offset_words > 0 and asr_idx > 0:
                    # Uoc luong lui thoi gian bang trung binh khoang cach tu
                    # truoc do trong cung 1 cau ASR de ra thoi diem TU DAU dong.
                    lookback = min(offset_words, asr_idx)
                    t_prev = asr_words[asr_idx - lookback]["t"]
                    span = t - t_prev
                    avg_gap = span / lookback if lookback else 0
                    t = max(0.0, t - avg_gap * offset_words)
                found_asr_idx = t
                break
        if found_asr_idx is not None:
            result[num_start] = round(found_asr_idx, 1)
    return result


def main():
    dry_run = "--dry-run" in sys.argv
    only = None
    if "--only" in sys.argv:
        only = sys.argv[sys.argv.index("--only") + 1]

    text = DART_FILE.read_text(encoding="utf-8")
    blocks = find_song_blocks(text)
    print(f"Found {len(blocks)} songs in songs_data.dart")

    cache = {}
    if CACHE_FILE.exists():
        cache = json.loads(CACHE_FILE.read_text(encoding="utf-8"))

    model = WhisperModel("base", device="cpu", compute_type="int8")

    all_replacements = []  # (start, end, new_text)
    stats = []

    for block in blocks:
        stem = block["stem"]
        if only and stem != only:
            continue
        audio_path = AUDIO_DIR / f"{stem}.mp3"
        if not audio_path.exists():
            print(f"  !! missing audio for {stem}, skipping")
            continue
        print(f"== {stem} ({len(block['lines'])} lines) ==")
        asr_words = transcribe_words(model, audio_path, cache)
        CACHE_FILE.write_text(json.dumps(cache), encoding="utf-8")
        if not asr_words:
            print(f"  !! no ASR words for {stem}, skipping")
            continue
        mapping = align_lines(block["lines"], asr_words)

        # resolved[i] = [num_start, num_end, value, matched?]. Dong khong
        # khop giu gia tri CU (uoc luong ty le) tam thoi - buoc sau se sua
        # lai neu gia tri cu do gay nhay lui so voi dong truoc/sau da khop.
        resolved = []
        matched = 0
        for num_start, num_end, en, vi, old_num in block["lines"]:
            new_val = mapping.get(num_start)
            if new_val is not None:
                matched += 1
                resolved.append([num_start, num_end, new_val, True, en, old_num])
            else:
                resolved.append([num_start, num_end, old_num, False, en, old_num])
        print(f"  matched {matched}/{len(block['lines'])} lines")

        # Chong nhay lui: dong KHONG khop (van giu gia tri uoc luong cu) co
        # the nam "lac cho" so voi cac dong lang gieng DA duoc cap nhat that
        # tu ASR (vd 1 dong giua bai giu uoc luong ~194s trong khi 2 dong
        # ke no vua duoc canh lai that ve ~16s va ~38s). Noi suy lai gia tri
        # cho nhung dong nay giua 2 moc da "chot" (matched=True) gan nhat.
        for i in range(1, len(resolved)):
            if resolved[i][2] < resolved[i - 1][2]:
                prev_val = resolved[i - 1][2]
                next_ok = None
                for k in range(i + 1, len(resolved)):
                    if resolved[k][2] > prev_val:
                        next_ok = resolved[k][2]
                        break
                new_val = round(
                    prev_val + (next_ok - prev_val) * 0.3, 1
                ) if next_ok is not None else round(prev_val + 1.0, 1)
                resolved[i][2] = new_val

        for num_start, num_end, val, was_matched, en, old_num in resolved:
            stats.append((stem, old_num, val if was_matched else None, en))
            if abs(val - old_num) >= 0.05:
                all_replacements.append((num_start, num_end, f"{val:g}"))

    print()
    print("=== Summary (old -> new, song) ===")
    big_changes = [s for s in stats if s[1] is not None and s[2] is not None and abs(s[2] - s[1]) >= 3]
    unmatched = [s for s in stats if s[2] is None]
    print(f"Total lines: {len(stats)}, unmatched: {len(unmatched)}, big shifts (>=3s): {len(big_changes)}")
    for stem, old, new, en in big_changes[:30]:
        print(f"  {stem}: {old} -> {new}  | {en[:50]}")
    if unmatched:
        print("Unmatched lines (kept old value):")
        for stem, old, new, en in unmatched[:30]:
            print(f"  {stem}: {old}  | {en[:50]}")

    if dry_run:
        print(f"\n[dry-run] Would apply {len(all_replacements)} replacements. No file written.")
        return

    # Apply replacements in reverse order of position so offsets stay valid.
    all_replacements.sort(key=lambda r: r[0], reverse=True)
    new_text = text
    for start, end, new_str in all_replacements:
        new_text = new_text[:start] + new_str + new_text[end:]

    DART_FILE.write_text(new_text, encoding="utf-8")
    print(f"\nApplied {len(all_replacements)} timestamp updates to {DART_FILE}")


if __name__ == "__main__":
    main()
