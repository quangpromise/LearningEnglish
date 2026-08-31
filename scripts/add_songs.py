"""
Pipeline them bai hat vao app - dung chung cho MOI nguon nhac.

    python scripts/add_songs.py list-sources
    python scripts/add_songs.py fetch joshwoodward TheSimpleLife
    python scripts/add_songs.py verify the-simple-life
    python scripts/add_songs.py emit the-simple-life
    python scripts/realign_lyrics.py --only the-simple-life

Bon cong gac, khong cai nao bo qua duoc bang co:

  1. BAN QUYEN (song_licensing.py) - khai bao RIENG giay phep cho ban thu
     va cho phan loi. Khong ro = tu choi. Giay phep ban thu KHONG tu dong
     bao trum phan loi (docs/research-music-libraries.md §2).

  2. CO LOI HAT - app day tieng Anh bang loi bai hat; track instrumental
     bi tu choi du giay phep co dep den may.

  3. NGUOI DICH - truong "vi" do nguoi dien. Ban dich la NOI DUNG HOC cua
     app chu khong phai chrome giao dien, dich may sai an du la day sai.

  4. CAN TIMESTAMP - `emit` chen moi dong o giay 0; bat buoc chay
     realign_lyrics.py ngay sau, neu khong test karaoke se do.

Them nguon moi: viet 1 lop trong song_sources.py, khai bao duoc gi thi
khai bao, cho nao khong chac chan thi DE TRONG - cong gac se bat nguoi
thuc hien tu xac minh, an toan hon la doan.
"""

import argparse
import json
import re
import sys
import unicodedata
from pathlib import Path

from song_licensing import KNOWN_LICENSES, evaluate
from song_sources import SOURCES, http_get

ROOT = Path(__file__).resolve().parent.parent
DART_FILE = (
    ROOT / "app" / "lib" / "features" / "music_player" / "data" / "songs_data.dart"
)
ATTRIBUTION_FILE = ROOT / "ATTRIBUTION.md"
AUDIO_DIR = ROOT / "content" / "audio"
PENDING_DIR = ROOT / "content" / "pending"

LEVELS = ("Cơ bản", "Trung cấp", "Nâng cao")
#: Bang mau trong AppColors dung cho the bai hat o man Home.
COLORS = ("blue", "purple", "teal", "amber", "pink")

#: Duoi nguong nay thi khong du loi de hoc, gan nhu chac la instrumental
#: hoac trang nguon chi dang 1 doan trich.
MIN_LYRIC_LINES = 4

ATTRIBUTION_BEGIN = "<!-- BEGIN ghi cong tu dong: scripts/add_songs.py -->"
ATTRIBUTION_END = "<!-- END ghi cong tu dong -->"


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
    # Bo dau nhay TRUOC khi thay ky tu la bang gach ngang, neu khong
    # "Don't" thanh "don-t" thay vi "dont" - lech voi ten file mp3 dang
    # dat trong content/audio/.
    text = re.sub(r"['’ʼ]", "", text)
    text = re.sub(r"[^a-zA-Z0-9]+", "-", text.lower())
    return text.strip("-")


def render_song_block(song: dict) -> str:
    out = [
        "  Song(",
        f"    title: {dart_string(song['title'])},",
        f"    artist: {dart_string(song['artist'])},",
        f"    duration: {dart_string(song['duration'])},",
        f"    level: {dart_string(song['level'])},",
        f"    color: AppColors.{song['color']},",
        "    audioUrl: '${_audioBaseUrl}" + song["slug"] + ".mp3',",
        "    lyrics: [",
    ]
    for line in song["lines"]:
        # startSeconds de 0 - realign_lyrics.py se canh lai bang ASR ngay sau.
        out.append(
            f"      LyricLine(0, {dart_string(line['en'])}, "
            f"{dart_string(line['vi'])}),"
        )
    out += ["    ],", "  ),"]
    return "\n".join(out) + "\n"


def insert_into_dart(dart_text: str, song: dict) -> str:
    """Chen Song(...) vao ngay truoc dau dong `];` ket thuc `kSongs`."""
    marker = "\n];"
    idx = dart_text.rfind(marker)
    if idx == -1:
        raise SystemExit(f"Khong tim thay cho ket thuc kSongs trong {DART_FILE}")
    return dart_text[: idx + 1] + render_song_block(song) + dart_text[idx + 1 :]


# ---------------------------------------------------------------------------
# Ghi cong
# ---------------------------------------------------------------------------


def render_attribution_entry(song: dict) -> str:
    """1 muc ghi cong day du TASL + giay phep RIENG cho tung phan.

    Ghi ca 2 phan (ban thu / phan loi) chu khong gop lam 1: co nhung track
    ma 2 phan khac giay phep, va 6 thang sau khong ai nho lai duoc.
    """
    lic = song["license"]
    lines = [
        f"### {song['title']} — {song['artist']}",
        "",
        f"- Nguon: {song['source'].get('page_url') or '(tu nhap tay)'}",
        f"- Adapter: `{song['source'].get('adapter', '?')}`",
    ]
    for part, label in (("recording", "Bản thu"), ("lyrics", "Phần lời")):
        claim = lic.get(part) or {}
        terms = KNOWN_LICENSES.get(claim.get("license_id", ""))
        name = terms.name if terms else claim.get("license_id", "?")
        entry = (
            f"- {label}: **{name}** — {claim.get('evidence_url', '')} "
            f"(xác minh: {claim.get('verified_by', '?')})"
        )
        if claim.get("note"):
            entry += f"\n  - {claim['note']}"
        lines.append(entry)
    lines.append(f"- Nguồn lời: `{song.get('lyrics_origin', '?')}`")
    return "\n".join(lines) + "\n"


def append_attribution(text: str, song: dict) -> str:
    """Them muc ghi cong vao khoi duoc danh dau la sinh tu dong.

    Dung khoi co marker thay vi chen vao danh sach nguoi viet tay: khoi
    nguoi viet co van phong rieng, chen may vao do vua de vo vua kho doc
    diff. Khoi nay ai cung biet la may ghi.
    """
    entry = render_attribution_entry(song)
    if ATTRIBUTION_BEGIN not in text:
        text = text.rstrip() + (
            f"\n\n## Track thêm bằng pipeline\n\n"
            f"Mục dưới đây do `scripts/add_songs.py` ghi, mỗi bài ghi riêng "
            f"giấy phép của **bản thu** và của **phần lời** — hai bản quyền "
            f"tách rời, xem `docs/research-music-libraries.md` §2.\n\n"
            f"{ATTRIBUTION_BEGIN}\n{ATTRIBUTION_END}\n"
        )
    idx = text.index(ATTRIBUTION_END)
    return text[:idx] + entry + "\n" + text[idx:]


# ---------------------------------------------------------------------------
# Doc/ghi ban ghi pending
# ---------------------------------------------------------------------------


def pending_path(slug: str) -> Path:
    return PENDING_DIR / f"{slug}.json"


def load_pending(slug: str):
    path = pending_path(slug)
    if not path.exists():
        print(f"!! khong co {path.relative_to(ROOT)} — chay 'fetch' truoc")
        return None
    return json.loads(path.read_text(encoding="utf-8"))


def save_pending(song: dict):
    PENDING_DIR.mkdir(parents=True, exist_ok=True)
    pending_path(song["slug"]).write_text(
        json.dumps(song, ensure_ascii=False, indent=2), encoding="utf-8"
    )


# ---------------------------------------------------------------------------
# Kiem tra
# ---------------------------------------------------------------------------


def content_problems(song: dict) -> list:
    """Cac loi KHONG lien quan ban quyen: thieu du lieu, khong co loi hat..."""
    problems = []
    for field_name in ("title", "artist", "duration"):
        if not (song.get(field_name) or "").strip():
            problems.append(f"thieu '{field_name}'")
    if song.get("level") not in LEVELS:
        problems.append(f"level '{song.get('level')}' khong hop le, phai la 1 trong {LEVELS}")
    if song.get("color") not in COLORS:
        problems.append(f"color '{song.get('color')}' khong hop le, phai la 1 trong {COLORS}")

    lines = song.get("lines") or []
    if song.get("instrumental"):
        problems.append(
            "track duoc danh dau instrumental - app day tieng Anh bang loi bai "
            "hat nen track khong loi khong dung duoc"
        )
    if len(lines) < MIN_LYRIC_LINES:
        problems.append(
            f"chi co {len(lines)} dong loi (toi thieu {MIN_LYRIC_LINES}) - "
            f"kiem tra lai xem co phai instrumental hoac trang nguon chi dang "
            f"1 doan trich khong"
        )
    return problems


def untranslated_lines(song: dict) -> list:
    return [
        i + 1
        for i, line in enumerate(song.get("lines") or [])
        if not (line.get("vi") or "").strip()
    ]


def print_report(song: dict, allow_share_alike: bool) -> bool:
    """In bao cao day du cho 1 bai. Tra ve True neu san sang `emit`."""
    slug = song["slug"]
    print(f"\n== {slug} — {song.get('title') or '(chua co ten)'} ==")
    print(f"   nguon: {song['source'].get('adapter')} · "
          f"{song['source'].get('page_url') or '(tu nhap tay)'}")

    report = evaluate(song, allow_share_alike=allow_share_alike)
    content = content_problems(song)
    missing = untranslated_lines(song)
    audio = AUDIO_DIR / f"{slug}.mp3"

    for err in report.errors:
        print(f"   [BAN QUYEN] {err}")
    for warn in report.warnings:
        print(f"   [luu y]     {warn}")
    for ob in report.obligations:
        print(f"   [nghia vu]  {ob}")
    for problem in content:
        print(f"   [noi dung]  {problem}")
    if missing:
        preview = ", ".join(f"#{i}" for i in missing[:5])
        more = "..." if len(missing) > 5 else ""
        print(f"   [dich]      con {len(missing)} dong chua dich ({preview}{more})")
    if not audio.exists():
        print(f"   [audio]     thieu {audio.relative_to(ROOT)}")

    ready = report.ok and not content and not missing and audio.exists()
    print(f"   -> {'SAN SANG emit' if ready else 'CHUA the emit'}")
    return ready


# ---------------------------------------------------------------------------
# Lenh
# ---------------------------------------------------------------------------


def cmd_list_sources(args) -> int:
    print("Cac nguon dang ho tro:\n")
    for name, source in SOURCES.items():
        print(f"  {name:<14} {source.summary}")
        print(f"  {'':<14} ref: {source.ref_help}\n")
    print("Giay phep da tham dinh (khac -> bi tu choi):")
    usable = [t for t in KNOWN_LICENSES.values() if t.commercial and t.derivatives]
    for terms in usable:
        flag = " (ShareAlike, can --allow-share-alike)" if terms.share_alike else ""
        print(f"  {terms.id}{flag}")
    return 0


def cmd_fetch(args) -> int:
    source = SOURCES[args.source]
    AUDIO_DIR.mkdir(parents=True, exist_ok=True)
    existing = DART_FILE.read_text(encoding="utf-8")

    for i, ref in enumerate(args.refs):
        print(f"== {args.source}: {ref} ==")
        draft = source.fetch(ref)
        slug = args.slug or slugify(draft.get("title") or ref)
        if not slug:
            print("  !! khong suy duoc slug, truyen --slug")
            continue
        if f"{slug}.mp3" in existing:
            print(f"  !! '{slug}' da co trong songs_data.dart, bo qua")
            continue

        song = dict(draft)
        song["slug"] = slug
        song["level"] = args.level
        song["color"] = args.color or COLORS[i % len(COLORS)]
        song["lines"] = [
            {"en": line, "vi": ""} if isinstance(line, str) else line
            for line in draft.get("lines") or []
        ]
        if args.audio_url:
            song["audio_url"] = args.audio_url

        # Chi tai audio khi giay phep BAN THU khong sai ro rang - tranh tai
        # ve mot track ma minh vua doc thay la NC/ND.
        recording = (song.get("license") or {}).get("recording") or {}
        terms = KNOWN_LICENSES.get(recording.get("license_id", ""))
        blocked = terms is not None and not (terms.commercial and terms.derivatives)
        if blocked:
            print(
                f"  !! ban thu la {terms.name} - khong dung thuong mai/phai sinh "
                f"duoc, KHONG tai file ve"
            )
        elif not song.get("audio_url"):
            print("  !! khong tim thay file mp3, truyen tay bang --audio-url")
        else:
            dest = AUDIO_DIR / f"{slug}.mp3"
            if dest.exists():
                print(f"  [skip] {dest.name} da co san")
            else:
                print(f"  [GET] {song['audio_url']}")
                dest.write_bytes(http_get(song["audio_url"]))
                print(f"  -> {dest.relative_to(ROOT)} ({dest.stat().st_size:,} bytes)")

        save_pending(song)
        print(f"  -> {pending_path(slug).relative_to(ROOT)}")
        print_report(song, args.allow_share_alike)

    print("\nBuoc tiep theo: sua/dien not file trong content/pending/,")
    print("dich phan \"vi\", roi chay: python scripts/add_songs.py verify <slug>")
    return 0


def cmd_verify(args) -> int:
    slugs = args.slugs or sorted(p.stem for p in PENDING_DIR.glob("*.json"))
    if not slugs:
        print("Khong co bai nao trong content/pending/")
        return 0
    all_ready = True
    for slug in slugs:
        song = load_pending(slug)
        if song is None:
            return 1
        all_ready &= print_report(song, args.allow_share_alike)
    return 0 if all_ready else 1


def cmd_emit(args) -> int:
    dart_file = Path(args.dart_file) if args.dart_file else DART_FILE
    attribution_file = (
        Path(args.attribution_file) if args.attribution_file else ATTRIBUTION_FILE
    )
    dart_text = dart_file.read_text(encoding="utf-8")
    attribution_text = attribution_file.read_text(encoding="utf-8")
    added = []

    for slug in args.slugs:
        song = load_pending(slug)
        if song is None:
            return 1
        if f"{slug}.mp3" in dart_text:
            print(f"!! {slug} da co trong {dart_file.name}, bo qua")
            continue

        report = evaluate(song, allow_share_alike=args.allow_share_alike)
        problems = list(report.errors) + content_problems(song)
        missing = untranslated_lines(song)
        if missing:
            problems.append(
                f"con {len(missing)}/{len(song['lines'])} dong chua dich "
                f"(dong dau tien: #{missing[0]})"
            )
        if not args.skip_audio_check and not (AUDIO_DIR / f"{slug}.mp3").exists():
            problems.append(f"thieu content/audio/{slug}.mp3")

        if problems:
            print(f"!! {slug} chua the them:")
            for problem in problems:
                print(f"   - {problem}")
            print("   (chay 'verify' de xem bao cao day du)")
            return 1

        dart_text = insert_into_dart(dart_text, song)
        attribution_text = append_attribution(attribution_text, song)
        added.append((song, report))

    if not added:
        print("Khong co bai nao duoc them.")
        return 0

    dart_file.write_text(dart_text, encoding="utf-8")
    attribution_file.write_text(attribution_text, encoding="utf-8")
    print(f"Da them {len(added)} bai vao {dart_file.name} + {attribution_file.name}:")
    for song, report in added:
        print(f"  - {song['title']} ({len(song['lines'])} dong)")
        for ob in report.obligations:
            print(f"      nghia vu: {ob}")

    slugs = [song["slug"] for song, _ in added]
    print("\nBuoc tiep theo:")
    print("  1. python scripts/realign_lyrics.py --only " + " --only ".join(slugs))
    print("     BAT BUOC — moi dong vua chen deu dang o giay 0. Neu commit ma")
    print("     chua canh, test karaoke se bao loi vi cac dong chong len nhau.")
    print("  2. cd app && dart format . && flutter analyze && flutter test")
    print("  3. Them dong tuong ung vao bang §10 docs/research-music-libraries.md")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter
    )
    sub = parser.add_subparsers(dest="command", required=True)

    p_list = sub.add_parser("list-sources", help="Liet ke nguon + giay phep chap nhan")
    p_list.set_defaults(func=cmd_list_sources)

    p_fetch = sub.add_parser("fetch", help="Lay 1 bai tu nguon ve content/pending/")
    p_fetch.add_argument("source", choices=sorted(SOURCES))
    p_fetch.add_argument("refs", nargs="+", help="Xem 'list-sources' de biet dang ref")
    p_fetch.add_argument("--level", default="Trung cấp", choices=LEVELS)
    p_fetch.add_argument("--color", choices=COLORS)
    p_fetch.add_argument("--audio-url", help="Chi dinh tay link mp3")
    p_fetch.add_argument("--slug", help="Dat ten file khac ten suy tu tieu de")
    p_fetch.add_argument("--allow-share-alike", action="store_true")
    p_fetch.set_defaults(func=cmd_fetch)

    p_verify = sub.add_parser("verify", help="Cham ban quyen + do san sang")
    p_verify.add_argument("slugs", nargs="*", help="Bo trong = cham het pending")
    p_verify.add_argument("--allow-share-alike", action="store_true")
    p_verify.set_defaults(func=cmd_verify)

    p_emit = sub.add_parser("emit", help="Chen bai da du dieu kien vao app")
    p_emit.add_argument("slugs", nargs="+")
    p_emit.add_argument(
        "--allow-share-alike",
        action="store_true",
        help="Chap nhan nghia vu ShareAlike cho lyrics cua bai nay (§5)",
    )
    p_emit.add_argument("--skip-audio-check", action="store_true")
    p_emit.add_argument("--dart-file", help="Ghi vao file khac (dung cho test)")
    p_emit.add_argument("--attribution-file", help="Ghi vao file khac (dung cho test)")
    p_emit.set_defaults(func=cmd_emit)

    args = parser.parse_args()
    return args.func(args)


if __name__ == "__main__":
    sys.exit(main())
