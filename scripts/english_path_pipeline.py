"""Pipeline offline sinh Content Pack cho lo trinh tieng Anh A1 -> C1.

Xem CONTEXT.md (Content Pack, Content Source, Practice Item), ADR-0003 va
spec issue #45. Pack la JSON dong goi trong app (app/assets/english_path/),
KHONG sinh noi dung bang AI luc chay app.

Quality gate bat buoc truoc khi dong goi:
  1. validate_pack() - loi thi dung, khong ghi file.
  2. export_review_csv() - lay mau ngau nhien 10% (co dinh theo id) de nguoi
     duyet + Grok doi chieu cheo.
  3. `approve --reviewer <ten> --date YYYY-MM-DD` - ghi contentHash +
     packVersion da duyet vao scripts/english_path/approvals.json.
Pack chua approve CHI duoc ghi vao thu muc staging (scripts/english_path/
build/, khong dong goi); chi pack da approve moi duoc ghi vao assets cua app.
Test integrity (Dart + Python) fail neu pack trong assets chua approve.

Dap an nhieu dong nghia (khac chu nhung trung nghia) khong bat duoc bang may:
de cho buoc review nguoi 10% + Grok. Kiem tra bang WordNet se them o #55.

Nguon (Content Source) - moi nguon phai co license da xac minh cho thuong mai:
  - CEFR-J Wordlist 1.5 (Tono Lab, TUFS): dung thuong mai mien phi, bat buoc
    trich dan (ATTRIBUTION.md). CSV KHONG dua vao repo, tai luc chay.
  - Tu vung GymTalk (vocabulary_data.dart): noi dung tu soan cua du an.

Chay:
  python scripts/english_path_pipeline.py build [--csv cefrj.csv]
  python scripts/english_path_pipeline.py approve --reviewer "<ten>"
"""

import argparse
import csv
import hashlib
import json
import math
import random
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
VOCAB_DART = ROOT / "app/lib/features/vocabulary/data/vocabulary_data.dart"
PACK_ASSET = ROOT / "app/assets/english_path/pack.json"
APPROVALS = ROOT / "scripts/english_path/approvals.json"
REVIEW_CSV = ROOT / "scripts/english_path/review/pack_review.csv"
STAGING_PACK = ROOT / "scripts/english_path/build/pack.json"

PACK_SCHEMA_VERSION = 1
# Phien ban noi dung - tang moi lan doi quy mo/nguon (Placement luu kem).
PACK_VERSION = "0.1.0-tracer"
STAGES = ["A1", "A2", "B1", "B2", "C1"]
REVIEW_SAMPLE_RATE = 0.10
# Quy mo hien tai cua pack. Ticket #55/#56 nang len A1-B2 x 10 Unit + C1 x 3.
UNITS_PER_STAGE = {"A1": 1}
WORDS_PER_UNIT = 15

# Pin CEFR-J vao 1 commit de chay lai luon ra cung du lieu.
CEFRJ_COMMIT = "c5c6a64303a9fc2d3da22a06dd9827e471dc244c"
CEFRJ_CSV_URL = (
    "https://raw.githubusercontent.com/openlanguageprofiles/olp-en-cefrj/"
    f"{CEFRJ_COMMIT}/cefrj-vocabulary-profile-1.5.csv"
)

SOURCES = [
    {
        "id": "cefrj",
        "name": "CEFR-J Wordlist Version 1.5 (Yukio Tono, Tokyo University of Foreign Studies)",
        "license": "Free for research and commercial use with citation",
        "url": "https://github.com/openlanguageprofiles/olp-en-cefrj",
        "retrievedAt": "2026-09-25",
        "revision": CEFRJ_COMMIT,
        "files": ["cefrj-vocabulary-profile-1.5.csv"],
    },
    {
        "id": "gymtalk-vocab",
        "name": "GymTalk in-house vocabulary (IPA, Vietnamese meaning, examples)",
        "license": "Proprietary - written by the GymTalk team",
        "url": "app/lib/features/vocabulary/data/vocabulary_data.dart",
        "retrievedAt": "2026-09-25",
        "files": ["vocabulary_data.dart"],
    },
]
WORD_SOURCE_IDS = ["cefrj", "gymtalk-vocab"]

_STR = r"'((?:[^'\\]|\\.)*)'"


def _unescape(s: str) -> str:
    return s.replace("\\'", "'").replace("\\\\", "\\")


def parse_vocab_dart(src: str) -> list[dict]:
    """Doc VocabWord tu vocabulary_data.dart, kem chu de (nameEn/name)."""
    words = []
    topic, topic_vi = "?", "?"
    for block in re.split(r"(?=VocabTopic\(|VocabWord\()", src):
        if block.startswith("VocabTopic("):
            en = re.search(r"nameEn:\s*" + _STR, block)
            vi = re.search(r"\bname:\s*" + _STR, block)
            topic = _unescape(en.group(1)) if en else "?"
            topic_vi = _unescape(vi.group(1)) if vi else topic
        elif block.startswith("VocabWord("):
            fields = {}
            for key in ("en", "ipa", "vi", "exampleEn", "exampleVi"):
                m = re.search(r"\b" + key + r":\s*" + _STR, block)
                fields[key] = _unescape(m.group(1)) if m else ""
            if fields["en"]:
                words.append(dict(fields, topic=topic, topicVi=topic_vi))
    return words


def tag_cefr(words: list[dict], levels: dict[str, str]) -> list[dict]:
    """Gan cap CEFR-J (thap nhat) cho tu; tu khong co trong CEFR-J bi bo."""
    out, seen = [], set()
    for w in words:
        key = w["en"].strip().lower()
        if key in seen or key not in levels:
            continue
        seen.add(key)
        out.append(dict(w, cefr=levels[key]))
    return out


def _norm(s: str) -> str:
    return re.sub(r"\s+", " ", s).strip().lower()


def _slug(s: str) -> str:
    return re.sub(r"[^a-z0-9]+", "-", s.lower()).strip("-")


def _has_vietnamese(w: dict) -> bool:
    return bool(w.get("vi", "").strip()) and bool(w.get("exampleVi", "").strip())


def _pick_unit_words(pool: list[dict], count: int, n_units: int) -> list[list[dict]]:
    """Gom tu theo chu de (chu de nhieu tu nhat truoc) roi cat thanh Unit."""
    by_topic: dict[str, list[dict]] = {}
    for w in pool:
        by_topic.setdefault(w["topic"], []).append(w)
    ordered = []
    for topic in sorted(by_topic, key=lambda t: (-len(by_topic[t]), t)):
        ordered.extend(sorted(by_topic[topic], key=lambda w: w["en"].lower()))
    return [ordered[i * count:(i + 1) * count] for i in range(n_units)
            if len(ordered) >= (i + 1) * count]


def _meaning_item(unit_id: str, word: dict, unit_words: list[dict],
                  pool: list[dict]) -> dict:
    """Dap an nhieu uu tien tu cung Unit (cung chu de/tu loai) de cau hoi
    khong qua de, thieu thi lay them tu ca Stage."""
    item_id = f"{unit_id}-meaning-{_slug(word['en'])}"
    rng = random.Random(item_id)
    taken = {_norm(word["vi"])}
    same_unit = sorted(unit_words, key=lambda w: w["en"].lower())
    rest = sorted(pool, key=lambda w: w["en"].lower())
    rng.shuffle(same_unit)
    rng.shuffle(rest)
    candidates = same_unit + rest
    distractors = []
    for c in candidates:
        if _norm(c["vi"]) in taken:
            continue
        taken.add(_norm(c["vi"]))
        distractors.append(c["vi"])
        if len(distractors) == 3:
            break
    options = [word["vi"]] + distractors
    rng.shuffle(options)
    return {
        "id": item_id,
        "unitId": unit_id,
        "type": "meaning",
        "prompt": word["en"],
        "options": options,
        "answerIndex": options.index(word["vi"]),
        "wordEn": word["en"],
        "sourceIds": list(WORD_SOURCE_IDS),
    }


def build_pack(words: list[dict], units_per_stage: dict[str, int],
               words_per_unit: int) -> dict:
    stages = []
    for cefr in STAGES:
        n_units = units_per_stage.get(cefr, 0)
        if not n_units:
            continue
        pool = [w for w in words if w.get("cefr") == cefr and _has_vietnamese(w)]
        units = []
        for idx, unit_words in enumerate(_pick_unit_words(pool, words_per_unit, n_units), 1):
            unit_id = f"{cefr.lower()}-u{idx:02d}"
            units.append({
                "id": unit_id,
                "index": idx,
                "titleEn": unit_words[0]["topic"],
                "titleVi": unit_words[0].get("topicVi", unit_words[0]["topic"]),
                "words": [
                    {k: w[k] for k in ("en", "ipa", "vi", "exampleEn", "exampleVi")}
                    for w in unit_words
                ],
                "items": [_meaning_item(unit_id, w, unit_words, pool)
                          for w in unit_words],
            })
        stages.append({"cefr": cefr, "units": units})
    return {
        "schemaVersion": PACK_SCHEMA_VERSION,
        "packVersion": PACK_VERSION,
        "sources": [dict(s) for s in SOURCES],
        "stages": stages,
    }


def validate_pack(pack: dict) -> list[str]:
    errors = []
    sources = {}
    for s in pack.get("sources", []):
        if not s.get("license", "").strip():
            errors.append(f"source {s.get('id')}: missing license")
        if not s.get("url", "").strip():
            errors.append(f"source {s.get('id')}: missing provenance url")
        sources[s.get("id")] = s
    seen_ids = set()
    for stage in pack.get("stages", []):
        if stage.get("cefr") not in STAGES:
            errors.append(f"stage {stage.get('cefr')}: unknown CEFR stage")
        for unit in stage.get("units", []):
            unit_words = {w.get("en") for w in unit.get("words", [])}
            for w in unit.get("words", []):
                if not _has_vietnamese(w):
                    errors.append(f"{unit['id']}/{w.get('en')}: missing Vietnamese translation")
            for item in unit.get("items", []):
                iid = item.get("id")
                if iid in seen_ids:
                    errors.append(f"{iid}: duplicate item id")
                seen_ids.add(iid)
                if item.get("unitId") != unit["id"]:
                    errors.append(f"{iid}: invalid unit reference {item.get('unitId')}")
                if "wordEn" in item and item["wordEn"] not in unit_words:
                    errors.append(f"{iid}: word {item['wordEn']} is not in the unit")
                options = item.get("options", [])
                ans = item.get("answerIndex")
                if not isinstance(ans, int) or not 0 <= ans < len(options):
                    errors.append(f"{iid}: answer is not one of the options")
                normed = [_norm(o) for o in options]
                if len(set(normed)) != len(normed) or "" in normed:
                    errors.append(f"{iid}: duplicate or empty options")
                src_ids = item.get("sourceIds") or []
                if not src_ids:
                    errors.append(f"{iid}: missing sourceIds")
                for sid in src_ids:
                    if sid not in sources:
                        errors.append(f"{iid}: unknown source {sid}")
    approval = pack.get("approval")
    if approval is not None:
        if not str(approval.get("reviewer", "")).strip():
            errors.append("approval: missing reviewer")
        if not _ISO_DATE.fullmatch(str(approval.get("approvedAt", ""))):
            errors.append("approval: approvedAt must be YYYY-MM-DD")
    return errors


_ISO_DATE = re.compile(r"[0-9]{4}-[0-9]{2}-[0-9]{2}")


def approval_record(pack: dict, reviewer: str, date: str, note: str) -> dict:
    """Ban ghi final approval cho dung noi dung hien tai cua [pack]."""
    if not reviewer.strip():
        raise ValueError("reviewer is required")
    if not _ISO_DATE.fullmatch(date):
        raise ValueError("date must be YYYY-MM-DD")
    return {
        "contentHash": content_hash(pack),
        "packVersion": pack["packVersion"],
        "reviewer": reviewer.strip(),
        "approvedAt": date,
        "note": note,
    }


def write_outputs(pack: dict, asset: Path, staging: Path) -> bool:
    """Ghi pack vao staging; chi dong goi vao assets khi da approve dung hash.
    Tra ve True neu da dong goi."""
    _write_json(staging, pack)
    approved = (pack.get("approval") or {}).get("contentHash") == content_hash(pack)
    if approved:
        _write_json(asset, pack)
    return approved


def content_hash(pack: dict) -> str:
    """sha256 cua noi dung (bo approval/contentHash) - JSON chuan hoa."""
    body = {k: v for k, v in pack.items() if k not in ("approval", "contentHash")}
    canon = json.dumps(body, sort_keys=True, ensure_ascii=False, separators=(",", ":"))
    return hashlib.sha256(canon.encode("utf-8")).hexdigest()


def apply_approval(pack: dict, approvals: list[dict]) -> dict:
    h = content_hash(pack)
    match = next((a for a in approvals if a.get("contentHash") == h), None)
    out = dict(pack)
    out["contentHash"] = h
    out["approval"] = dict(match) if match else None
    return out


def _all_items(pack: dict):
    for stage in pack["stages"]:
        for unit in stage["units"]:
            words = {w["en"]: w for w in unit["words"]}
            for item in unit["items"]:
                yield stage["cefr"], unit, words.get(item.get("wordEn"), {}), item


def export_review_csv(pack: dict, path: Path) -> None:
    rows = list(_all_items(pack))
    k = math.ceil(len(rows) * REVIEW_SAMPLE_RATE)
    ranked = sorted(rows, key=lambda r: hashlib.sha256(r[3]["id"].encode()).hexdigest())
    sampled = {r[3]["id"] for r in ranked[:k]}
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8", newline="") as f:
        w = csv.writer(f)
        w.writerow(["sample", "stage", "unit", "id", "type", "prompt", "options",
                    "answer", "exampleEn", "exampleVi", "sources", "reviewer_note"])
        for cefr, unit, word, item in rows:
            w.writerow([
                "yes" if item["id"] in sampled else "",
                cefr, unit["id"], item["id"], item["type"], item["prompt"],
                " | ".join(item["options"]), item["options"][item["answerIndex"]],
                word.get("exampleEn", ""), word.get("exampleVi", ""),
                ",".join(item["sourceIds"]), "",
            ])


def _load_approvals() -> list[dict]:
    if not APPROVALS.exists():
        return []
    return json.loads(APPROVALS.read_text(encoding="utf-8"))


def _write_json(path: Path, data) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")


def cmd_build(args) -> int:
    sys.path.insert(0, str(Path(__file__).resolve().parent))
    from check_vocab_cefr import load_cefr

    csv_path = args.csv
    if csv_path is None:
        import tempfile
        import urllib.request
        with urllib.request.urlopen(CEFRJ_CSV_URL, timeout=60) as resp:
            tmp = Path(tempfile.gettempdir()) / f"cefrj-{CEFRJ_COMMIT[:8]}.csv"
            tmp.write_bytes(resp.read())
        csv_path = str(tmp)
    levels = load_cefr(csv_path)
    words = tag_cefr(parse_vocab_dart(VOCAB_DART.read_text(encoding="utf-8")), levels)
    pack = build_pack(words, UNITS_PER_STAGE, WORDS_PER_UNIT)
    errors = validate_pack(pack)
    if errors:
        print("VALIDATION FAILED - pack khong duoc ghi:", *errors, sep="\n  ")
        return 1
    pack = apply_approval(pack, _load_approvals())
    packaged = write_outputs(pack, PACK_ASSET, STAGING_PACK)
    export_review_csv(pack, REVIEW_CSV)
    n = sum(1 for _ in _all_items(pack))
    print(f"pack {pack['packVersion']}: {n} items, hash {pack['contentHash'][:12]}")
    print(f"review CSV -> {REVIEW_CSV}")
    if packaged:
        print(f"da approve -> dong goi {PACK_ASSET}")
    else:
        print(f"CHUA APPROVE -> chi ghi staging {STAGING_PACK}. Review mau 10% + "
              "Grok, roi chay `approve --reviewer <ten> --date YYYY-MM-DD`.")
    return 0


def cmd_approve(args) -> int:
    pack = json.loads(STAGING_PACK.read_text(encoding="utf-8"))
    errors = validate_pack(pack)
    if errors or pack.get("contentHash") != content_hash(pack):
        print("Pack khong hop le hoac da bi sua tay - chay lai build.", *errors, sep="\n  ")
        return 1
    try:
        record = approval_record(pack, args.reviewer, args.date, args.note)
    except ValueError as e:
        print(f"approve: {e}")
        return 1
    approvals = [a for a in _load_approvals() if a["contentHash"] != record["contentHash"]]
    approvals.append(record)
    _write_json(APPROVALS, approvals)
    write_outputs(apply_approval(pack, approvals), PACK_ASSET, STAGING_PACK)
    print(f"approved {pack['contentHash'][:12]} by {args.reviewer}")
    return 0


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    sub = ap.add_subparsers(dest="cmd", required=True)
    b = sub.add_parser("build")
    b.add_argument("--csv", help="CEFR-J CSV cuc bo (mac dinh tai ban da pin tu GitHub)")
    a = sub.add_parser("approve")
    a.add_argument("--reviewer", required=True)
    a.add_argument("--date", required=True, help="YYYY-MM-DD")
    a.add_argument("--note", default="")
    args = ap.parse_args()
    return cmd_build(args) if args.cmd == "build" else cmd_approve(args)


if __name__ == "__main__":
    sys.exit(main())
