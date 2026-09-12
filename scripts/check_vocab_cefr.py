"""Doi chieu nhan muc do (common/medium/rare) trong vocabulary_data.dart voi
CEFR-J Wordlist 1.5 - xem docs/research-level-based-content.md muc 2.

CHI IN RA BAO CAO de nguoi soan duyet tay, KHONG tu dong sua file Dart (nhan
hien tai la nhan dinh chu quan, CEFR-J cung chi la 1 nguon tham khao).

Nguon: The CEFR-J Wordlist Version 1.5. Compiled by Yukio Tono, Tokyo
University of Foreign Studies (http://www.cefr-j.org/). Dung thuong mai mien
phi, bat buoc trich dan (da ghi trong ATTRIBUTION.md). File CSV KHONG duoc
dua vao repo - script tai truc tiep tu GitHub moi lan chay (hoac doc file
cuc bo qua --csv).

Quy doi: A1 -> common, A2/B1 -> medium, B2 -> rare. Tu/cum tu khong co trong
CEFR-J (thanh ngu, ten rieng, tu chuyen nganh...) duoc bo qua - khong the
ket luan gi.

Chay:  python scripts/check_vocab_cefr.py [--csv duong_dan.csv] [--out bao_cao.md]
"""

import argparse
import csv
import io
import re
import sys
import urllib.request
from collections import Counter, defaultdict
from pathlib import Path

CSV_URL = (
    "https://raw.githubusercontent.com/openlanguageprofiles/olp-en-cefrj/"
    "master/cefrj-vocabulary-profile-1.5.csv"
)
VOCAB_DART = (
    Path(__file__).resolve().parent.parent
    / "app/lib/features/vocabulary/data/vocabulary_data.dart"
)
LEVEL_TO_FREQ = {"A1": "common", "A2": "medium", "B1": "medium", "B2": "rare"}
LEVEL_ORDER = ["A1", "A2", "B1", "B2"]


def load_cefr(csv_path: str | None) -> dict[str, str]:
    """headword (lowercase) -> cap CEFR THAP NHAT (1 tu co nhieu tu loai)."""
    if csv_path:
        text = Path(csv_path).read_text(encoding="utf-8")
    else:
        with urllib.request.urlopen(CSV_URL, timeout=60) as resp:
            text = resp.read().decode("utf-8")
    levels: dict[str, str] = {}
    for row in csv.DictReader(io.StringIO(text)):
        level = row["CEFR"].strip()
        if level not in LEVEL_TO_FREQ:
            continue
        # "a.m./A.M./am/AM" -> nhieu bien the cach nhau boi "/".
        for variant in row["headword"].split("/"):
            key = variant.strip().lower()
            if not key:
                continue
            old = levels.get(key)
            if old is None or LEVEL_ORDER.index(level) < LEVEL_ORDER.index(old):
                levels[key] = level
    return levels


def load_vocab() -> list[tuple[str, str, str]]:
    """(chu de, tu tieng Anh, nhan frequency) doc thang tu file Dart."""
    src = VOCAB_DART.read_text(encoding="utf-8")
    items = []
    topic = "?"
    for block in re.split(r"(?=VocabTopic\(|VocabWord\()", src):
        if block.startswith("VocabTopic("):
            m = re.search(r"nameEn:\s*'((?:[^'\\]|\\.)*)'", block)
            if m:
                topic = m.group(1)
        elif block.startswith("VocabWord("):
            en = re.search(r"en:\s*'((?:[^'\\]|\\.)*)'", block)
            freq = re.search(r"VocabFrequency\.(\w+)", block)
            if en and freq:
                items.append((topic, en.group(1).replace("\\'", "'"), freq.group(1)))
    return items


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--csv", help="Duong dan CSV CEFR-J cuc bo (bo qua tai mang)")
    parser.add_argument("--out", help="Ghi bao cao Markdown ra file nay")
    args = parser.parse_args()

    cefr = load_cefr(args.csv)
    vocab = load_vocab()

    matched = 0
    mismatches: dict[str, list[tuple[str, str, str, str]]] = defaultdict(list)
    confusion: Counter = Counter()
    for topic, en, freq in vocab:
        level = cefr.get(en.lower())
        if level is None:
            continue
        matched += 1
        expected = LEVEL_TO_FREQ[level]
        confusion[(freq, expected)] += 1
        if expected != freq:
            mismatches[f"{freq} -> {expected}"].append((topic, en, level, freq))

    lines = [
        "# Doi chieu nhan tu vung voi CEFR-J 1.5",
        "",
        f"- Tong so tu trong app: {len(vocab)}",
        f"- Co trong CEFR-J: {matched} ({matched * 100 // max(len(vocab), 1)}%)",
        f"- Lech nhan: {sum(len(v) for v in mismatches.values())}",
        "",
        "Quy doi: A1 -> common, A2/B1 -> medium, B2 -> rare. Chi la goi y de "
        "duyet tay, khong tu dong sua.",
        "",
        "| Nhan hien tai \\ Theo CEFR-J | common | medium | rare |",
        "|---|---|---|---|",
    ]
    for freq in ["common", "medium", "rare"]:
        cells = [str(confusion[(freq, e)]) for e in ["common", "medium", "rare"]]
        lines.append(f"| {freq} | {' | '.join(cells)} |")
    # Uu tien nhom lech 2 bac (common <-> rare) len dau - dang nghi sai nhat.
    order = sorted(
        mismatches,
        key=lambda k: -abs(
            ["common", "medium", "rare"].index(k.split(" -> ")[0])
            - ["common", "medium", "rare"].index(k.split(" -> ")[1])
        ),
    )
    for key in order:
        rows = sorted(mismatches[key])
        lines += ["", f"## {key} ({len(rows)} tu)", "", "| Chu de | Tu | CEFR-J |", "|---|---|---|"]
        lines += [f"| {t} | {en} | {lv} |" for t, en, lv, _ in rows]

    report = "\n".join(lines) + "\n"
    if args.out:
        Path(args.out).write_text(report, encoding="utf-8")
        print(f"Da ghi bao cao: {args.out}")
    else:
        sys.stdout.write(report)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
