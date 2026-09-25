"""Pipeline offline sinh Content Pack cho lo trinh tieng Anh A1 -> C1.

Xem CONTEXT.md (Content Pack, Content Source, Practice Item), ADR-0003 va
spec issue #45. Pack la JSON dong goi trong app (app/assets/english_path/),
KHONG sinh noi dung bang AI luc chay app.

Quality gate bat buoc truoc khi dong goi:
  1. validate_pack() - loi thi dung, khong ghi file.
  2. export_review_csv() - lay mau ngau nhien 10% (co dinh theo id) de nguoi
     duyet + Grok doi chieu cheo.
  3. `approve --reviewer <ten>` - ghi contentHash da duyet vao
     scripts/english_path/approvals.json. Pack chi mang metadata approval khi
     hash khop; test integrity (Dart + Python) fail neu pack chua approve.

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

PACK_SCHEMA_VERSION = 1
STAGES = ["A1", "A2", "B1", "B2", "C1"]
REVIEW_SAMPLE_RATE = 0.10

SOURCES = [
    {
        "id": "cefrj",
        "name": "CEFR-J Wordlist Version 1.5 (Yukio Tono, Tokyo University of Foreign Studies)",
        "license": "Free for research and commercial use with citation",
        "url": "https://github.com/openlanguageprofiles/olp-en-cefrj",
        "retrievedAt": "2026-09-25",
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
        unit_ids = {u["id"] for u in stage.get("units", [])}
        for unit in stage.get("units", []):
            for w in unit.get("words", []):
                if not _has_vietnamese(w):
                    errors.append(f"{unit['id']}/{w.get('en')}: missing Vietnamese translation")
            for item in unit.get("items", []):
                iid = item.get("id")
                if iid in seen_ids:
                    errors.append(f"{iid}: duplicate item id")
                seen_ids.add(iid)
                if item.get("unitId") not in unit_ids or item.get("unitId") != unit["id"]:
                    errors.append(f"{iid}: invalid unit reference {item.get('unitId')}")
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
    return errors


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


# Quy mo hien tai cua pack. Ticket #55/#56 nang len A1-B2 x 10 Unit + C1 x 3.
UNITS_PER_STAGE = {"A1": 1}
WORDS_PER_UNIT = 15


def cmd_build(args) -> int:
    sys.path.insert(0, str(Path(__file__).resolve().parent))
    from check_vocab_cefr import load_cefr

    levels = load_cefr(args.csv)
    words = tag_cefr(parse_vocab_dart(VOCAB_DART.read_text(encoding="utf-8")), levels)
    pack = build_pack(words, UNITS_PER_STAGE, WORDS_PER_UNIT)
    errors = validate_pack(pack)
    if errors:
        print("VALIDATION FAILED - pack khong duoc ghi:", *errors, sep="\n  ")
        return 1
    pack = apply_approval(pack, _load_approvals())
    _write_json(PACK_ASSET, pack)
    export_review_csv(pack, REVIEW_CSV)
    n = sum(1 for _ in _all_items(pack))
    print(f"pack: {n} items, hash {pack['contentHash'][:12]} -> {PACK_ASSET}")
    print(f"review CSV -> {REVIEW_CSV}")
    if pack["approval"] is None:
        print("CHUA APPROVE: review mau 10% + Grok, roi chay "
              "`approve --reviewer <ten>`. Test integrity se fail cho den luc do.")
    return 0


def cmd_approve(args) -> int:
    pack = json.loads(PACK_ASSET.read_text(encoding="utf-8"))
    errors = validate_pack(pack)
    if errors or pack.get("contentHash") != content_hash(pack):
        print("Pack khong hop le hoac da bi sua tay - chay lai build.", *errors, sep="\n  ")
        return 1
    approvals = [a for a in _load_approvals() if a["contentHash"] != pack["contentHash"]]
    approvals.append({
        "contentHash": pack["contentHash"],
        "reviewer": args.reviewer,
        "approvedAt": args.date,
        "note": args.note,
    })
    _write_json(APPROVALS, approvals)
    _write_json(PACK_ASSET, apply_approval(pack, approvals))
    print(f"approved {pack['contentHash'][:12]} by {args.reviewer}")
    return 0


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    sub = ap.add_subparsers(dest="cmd", required=True)
    b = sub.add_parser("build")
    b.add_argument("--csv", help="CEFR-J CSV cuc bo (mac dinh tai tu GitHub)")
    a = sub.add_parser("approve")
    a.add_argument("--reviewer", required=True)
    a.add_argument("--date", required=True, help="YYYY-MM-DD")
    a.add_argument("--note", default="")
    args = ap.parse_args()
    return cmd_build(args) if args.cmd == "build" else cmd_approve(args)


if __name__ == "__main__":
    sys.exit(main())
