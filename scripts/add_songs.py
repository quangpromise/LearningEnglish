"""
Them bai hat moi tu joshwoodward.com (CC-BY 4.0) vao app.

Quy trinh 3 buoc, MOI BUOC CO NGUOI DUYET - co y khong lam 1 phat tu dau
den cuoi, vi day la app DAY tieng Anh: loi sai 1 tu la day sai 1 tu.

    1. python scripts/add_songs.py fetch TheSimpleLife
       -> tai mp3 ve content/audio/, lay loi tu trang bai hat,
          ghi ra content/pending/<slug>.json voi truong "vi" con TRONG

    2. Nguoi dich phan "vi" trong file json do (va doc lai phan "en" -
       loi lay tu trang tac gia nhung van nen liec qua)

    3. python scripts/add_songs.py emit TheSimpleLife
       -> chen Song(...) vao songs_data.dart + ghi cong vao ATTRIBUTION.md
       Sau do chay: python scripts/realign_lyrics.py --only <slug>
       de canh timestamp that bang ASR.

Vi sao khong tu dong dich luon: ban dich may cho lyrics rat hay sai sac
thai/an du, ma bang dich Anh-Viet chinh la noi dung hoc cua app chu khong
phai chrome giao dien. Buoc 2 bat buoc co nguoi.

Chi dung cho nguon da xac minh license bao trum CA PHAN LOI (xem
docs/research-music-libraries.md §2). Josh Woodward tu viet + tu thu + tu
so huu toan bo nen hop le tron ven.
"""

import argparse
import json
import re
import sys
import unicodedata
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DART_FILE = ROOT / "app" / "lib" / "features" / "music_player" / "data" / "songs_data.dart"
ATTRIBUTION_FILE = ROOT / "ATTRIBUTION.md"
AUDIO_DIR = ROOT / "content" / "audio"
PENDING_DIR = ROOT / "content" / "pending"

SONG_PAGE = "https://www.joshwoodward.com/song/{slug}"
USER_AGENT = "Mozilla/5.0 (compatible; LearningEnglish-song-importer/1.0)"

LEVELS = ("Cơ bản", "Trung cấp", "Nâng cao")
# Bang mau trong AppColors dung cho the bai hat o man Home.
COLORS = ("blue", "purple", "teal", "amber", "pink")


# ---------------------------------------------------------------------------
# Sinh code Dart
# ---------------------------------------------------------------------------


def dart_string(text: str) -> str:
    r"""Boc `text` thanh string literal Dart hop le.

    Ba thu BAT BUOC phai xu ly, deu co that trong loi bai hat:
      - `\` phai nhan doi truoc moi thu khac
      - `$` bat dau noi suy chuoi trong Dart -> phai escape thanh `\$`
      - dau nhay: uu tien nhay don, doi sang nhay kep neu loi co `'`
        (giong cach file songs_data.dart dang viet san)
    """
    text = text.replace("\\", "\\\\").replace("$", "\\$")
    if "'" not in text:
        return "'" + text + "'"
    if '"' not in text:
        return '"' + text + '"'
    return "'" + text.replace("'", "\\'") + "'"


def slugify(title: str) -> str:
    """'Don't Close Your Eyes' -> 'dont-close-your-eyes' (khop cach dat ten
    file mp3 dang co trong content/audio/)."""
    text = unicodedata.normalize("NFKD", title)
    text = "".join(c for c in text if not unicodedata.combining(c))
    text = re.sub(r"[^a-zA-Z0-9]+", "-", text.lower())
    return text.strip("-")


def render_song_block(song: dict) -> str:
    lines = []
    lines.append("  Song(")
    lines.append(f"    title: {dart_string(song['title'])},")
    lines.append(f"    artist: {dart_string(song['artist'])},")
    lines.append(f"    duration: {dart_string(song['duration'])},")
    lines.append(f"    level: {dart_string(song['level'])},")
    lines.append(f"    color: AppColors.{song['color']},")
    lines.append(
        "    audioUrl: '${_audioBaseUrl}" + song["slug"] + ".mp3',"
    )
    lines.append("    lyrics: [")
    for line in song["lines"]:
        # startSeconds de 0 - realign_lyrics.py se canh lai bang ASR ngay sau.
        lines.append(
            f"      LyricLine(0, {dart_string(line['en'])}, "
            f"{dart_string(line['vi'])}),"
        )
    lines.append("    ],")
    lines.append("  ),")
    return "\n".join(lines) + "\n"


def insert_into_dart(dart_text: str, song: dict) -> str:
    """Chen Song(...) vao ngay truoc dau dong `];` ket thuc `kSongs`."""
    marker = "\n];"
    idx = dart_text.rfind(marker)
    if idx == -1:
        raise SystemExit(
            f"Khong tim thay cho ket thuc danh sach kSongs trong {DART_FILE}"
        )
    return dart_text[: idx + 1] + render_song_block(song) + dart_text[idx + 1 :]


def append_attribution(text: str, song: dict) -> str:
    """Them 1 dong ghi cong vao cuoi danh sach bullet trong ATTRIBUTION.md."""
    bullets = list(re.finditer(r"^- \*\*\".*$", text, re.MULTILINE))
    if not bullets:
        raise SystemExit(
            "Khong tim thay danh sach ghi cong trong ATTRIBUTION.md"
        )
    last = bullets[-1]
    entry = (
        f"\n- **\"{song['title']}\"** — {song['artist']} — {song['source_url']}"
    )
    return text[: last.end()] + entry + text[last.end() :]


# ---------------------------------------------------------------------------
# Lay du lieu tu trang bai hat
# ---------------------------------------------------------------------------


def http_get(url: str) -> bytes:
    req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    with urllib.request.urlopen(req, timeout=60) as resp:
        return resp.read()


def iter_jsonld(html: str):
    for m in re.finditer(
        r'<script[^>]+type=["\']application/ld\+json["\'][^>]*>(.*?)</script>',
        html,
        re.DOTALL | re.IGNORECASE,
    ):
        try:
            data = json.loads(m.group(1))
        except json.JSONDecodeError:
            continue
        # JSON-LD co the la 1 object, 1 mang, hoac boc trong @graph.
        stack = [data]
        while stack:
            node = stack.pop()
            if isinstance(node, list):
                stack.extend(node)
            elif isinstance(node, dict):
                yield node
                if "@graph" in node:
                    stack.append(node["@graph"])


def as_text(value) -> str:
    """`lyrics` co the la chuoi thang, hoac {"@type":"CreativeWork","text":...}."""
    if isinstance(value, str):
        return value
    if isinstance(value, dict):
        for key in ("text", "name", "@value"):
            if isinstance(value.get(key), str):
                return value[key]
    return ""


def parse_iso_duration(value: str) -> str:
    """'PT3M34S' -> '3:34'."""
    m = re.match(r"^PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?$", value or "")
    if not m:
        return ""
    hours, minutes, seconds = (int(g or 0) for g in m.groups())
    minutes += hours * 60
    return f"{minutes}:{seconds:02d}"


def scrape_song(slug: str) -> dict:
    url = SONG_PAGE.format(slug=slug)
    print(f"  [GET] {url}", flush=True)
    html = http_get(url).decode("utf-8", errors="replace")

    title = artist = lyrics = duration = audio_url = ""
    for node in iter_jsonld(html):
        types = node.get("@type") or ""
        types = types if isinstance(types, list) else [types]
        if not any(
            t in ("MusicComposition", "MusicRecording", "MusicAlbum")
            for t in types
        ):
            continue
        title = title or as_text(node.get("name"))
        artist = artist or as_text(
            node.get("composer") or node.get("byArtist") or node.get("author")
        )
        lyrics = lyrics or as_text(node.get("lyrics"))
        duration = duration or parse_iso_duration(as_text(node.get("duration")))
        audio_url = audio_url or as_text(
            node.get("audio") or node.get("contentUrl")
        )

    if not audio_url:
        # Du phong: bat moi link .mp3 tren trang de nguoi dung tu chon.
        found = re.findall(r'href=["\']([^"\']+\.mp3)["\']', html)
        if len(found) == 1:
            audio_url = found[0]
        elif found:
            print("  Tim thay nhieu link mp3, chon 1 roi truyen --audio-url:")
            for f in found[:10]:
                print(f"    {f}")

    return {
        "title": title,
        "artist": artist or "Josh Woodward",
        "duration": duration,
        "lyrics": lyrics,
        "audio_url": audio_url,
        "source_url": url,
    }


def split_lyric_lines(raw: str) -> list:
    lines = []
    for line in re.split(r"(?:\r?\n|<br\s*/?>)+", raw):
        line = re.sub(r"<[^>]+>", "", line).strip()
        # Bo dong danh dau cau truc bai ([Chorus], [Verse 2]...) - khong phai
        # loi hat nen khong hien len man hinh.
        if not line or re.fullmatch(r"[\[(].*[\])]", line):
            continue
        lines.append(line)
    return lines


# ---------------------------------------------------------------------------
# Lenh
# ---------------------------------------------------------------------------


def cmd_fetch(args) -> int:
    PENDING_DIR.mkdir(parents=True, exist_ok=True)
    AUDIO_DIR.mkdir(parents=True, exist_ok=True)
    existing = DART_FILE.read_text(encoding="utf-8")

    for i, page_slug in enumerate(args.slugs):
        print(f"== {page_slug} ==")
        info = scrape_song(page_slug)
        if not info["title"]:
            print("  !! khong doc duoc ten bai tu trang, bo qua")
            continue
        if not info["lyrics"]:
            print(
                "  !! trang khong co san loi bai hat. Neu chac chan license "
                "bao trum ca phan loi, co the chep loi bang ASR - xem "
                "docs/research-music-libraries.md §3"
            )
            continue

        slug = args.slug_override or slugify(info["title"])
        if f"{slug}.mp3" in existing:
            print(f"  !! '{info['title']}' da co trong songs_data.dart, bo qua")
            continue

        audio_url = args.audio_url or info["audio_url"]
        if not audio_url:
            print("  !! khong tim thay file mp3, truyen tay bang --audio-url")
            continue
        dest = AUDIO_DIR / f"{slug}.mp3"
        if dest.exists():
            print(f"  [skip] {dest.name} da co san")
        else:
            print(f"  [GET] {audio_url}")
            dest.write_bytes(http_get(audio_url))
            print(f"  -> {dest.relative_to(ROOT)} ({dest.stat().st_size:,} bytes)")

        lines = split_lyric_lines(info["lyrics"])
        payload = {
            "slug": slug,
            "title": info["title"],
            "artist": info["artist"],
            "duration": info["duration"] or "0:00",
            "level": args.level,
            "color": args.color or COLORS[i % len(COLORS)],
            "source_url": info["source_url"],
            "license": "CC-BY 4.0",
            "lines": [{"en": line, "vi": ""} for line in lines],
        }
        out = PENDING_DIR / f"{slug}.json"
        out.write_text(
            json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8"
        )
        print(f"  -> {out.relative_to(ROOT)} ({len(lines)} dong, can dich)")

    print("\nBuoc tiep theo: dich phan \"vi\" trong content/pending/*.json,")
    print("roi chay: python scripts/add_songs.py emit <slug>")
    return 0


def cmd_emit(args) -> int:
    dart_file = Path(args.dart_file) if args.dart_file else DART_FILE
    attribution_file = (
        Path(args.attribution_file) if args.attribution_file else ATTRIBUTION_FILE
    )
    dart_text = dart_file.read_text(encoding="utf-8")
    attribution_text = attribution_file.read_text(encoding="utf-8")
    added = []

    for slug in args.slugs:
        path = PENDING_DIR / f"{slug}.json"
        if not path.exists():
            print(f"!! khong co {path.relative_to(ROOT)} - chay 'fetch' truoc")
            return 1
        song = json.loads(path.read_text(encoding="utf-8"))

        untranslated = [i for i, l in enumerate(song["lines"]) if not l["vi"].strip()]
        if untranslated and not args.allow_untranslated:
            print(
                f"!! {slug}: con {len(untranslated)}/{len(song['lines'])} dong "
                f"chua dich (dong dau tien: #{untranslated[0] + 1}). "
                "Dich xong roi chay lai."
            )
            return 1
        if not args.skip_audio_check:
            audio = AUDIO_DIR / f"{slug}.mp3"
            if not audio.exists():
                print(f"!! thieu {audio.relative_to(ROOT)}")
                return 1
        if f"{slug}.mp3" in dart_text:
            print(f"!! {slug} da co trong {dart_file.name}, bo qua")
            continue
        if song["level"] not in LEVELS:
            print(f"!! level '{song['level']}' khong hop le, phai la 1 trong {LEVELS}")
            return 1
        if song["color"] not in COLORS:
            print(f"!! color '{song['color']}' khong hop le, phai la 1 trong {COLORS}")
            return 1

        dart_text = insert_into_dart(dart_text, song)
        attribution_text = append_attribution(attribution_text, song)
        added.append(song)

    if not added:
        print("Khong co bai nao duoc them.")
        return 0

    dart_file.write_text(dart_text, encoding="utf-8")
    attribution_file.write_text(attribution_text, encoding="utf-8")
    print(f"Da them {len(added)} bai vao {dart_file.name} + {attribution_file.name}:")
    for song in added:
        print(f"  - {song['title']} ({len(song['lines'])} dong)")
    print("\nBuoc tiep theo:")
    print(
        "  1. python scripts/realign_lyrics.py --only "
        + " --only ".join(s["slug"] for s in added)
    )
    print(
        "     BAT BUOC - moi dong vua chen deu dang o giay 0. Neu commit ma"
    )
    print(
        "     chua canh, test karaoke se bao loi vi cac dong chong len nhau."
    )
    print("  2. cd app && dart format . && flutter analyze && flutter test")
    print("  3. Them dong tuong ung vao bang §9 docs/research-music-libraries.md")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="command", required=True)

    p_fetch = sub.add_parser("fetch", help="Tai mp3 + loi bai hat ve content/pending/")
    p_fetch.add_argument(
        "slugs",
        nargs="+",
        help="Slug tren joshwoodward.com/song/<slug>, vd TheSimpleLife",
    )
    p_fetch.add_argument("--level", default="Trung cấp", choices=LEVELS)
    p_fetch.add_argument("--color", choices=COLORS)
    p_fetch.add_argument("--audio-url", help="Chi dinh tay link mp3 neu khong tu tim duoc")
    p_fetch.add_argument("--slug-override", help="Dat ten file khac ten suy tu tieu de")
    p_fetch.set_defaults(func=cmd_fetch)

    p_emit = sub.add_parser("emit", help="Chen bai da dich vao songs_data.dart")
    p_emit.add_argument("slugs", nargs="+", help="Slug file trong content/pending/")
    p_emit.add_argument(
        "--allow-untranslated",
        action="store_true",
        help="Cho phep chen khi con dong chua dich (chi dung de thu)",
    )
    p_emit.add_argument("--skip-audio-check", action="store_true")
    p_emit.add_argument("--dart-file", help="Ghi vao file khac (dung cho test)")
    p_emit.add_argument("--attribution-file", help="Ghi vao file khac (dung cho test)")
    p_emit.set_defaults(func=cmd_emit)

    args = parser.parse_args()
    return args.func(args)


if __name__ == "__main__":
    sys.exit(main())
