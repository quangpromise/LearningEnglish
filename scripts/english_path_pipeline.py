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
TATOEBA_SNAPSHOT = ROOT / "scripts/english_path/data/tatoeba_eng_vie.tsv"
GRAMMAR_BANK = ROOT / "scripts/english_path/grammar_bank.json"
EXCLUSIONS = ROOT / "scripts/english_path/review/exclusions.json"
NAWL_SNAPSHOT = ROOT / "scripts/english_path/data/nawl_headwords.txt"
IELTS_BANK = ROOT / "scripts/english_path/ielts_micro.json"

PACK_SCHEMA_VERSION = 1
# Phien ban noi dung - tang moi lan doi quy mo/nguon (Placement luu kem).
PACK_VERSION = "0.3.0-a1c1"
STAGES = ["A1", "A2", "B1", "B2", "C1"]
REVIEW_SAMPLE_RATE = 0.10
# Quy mo hien tai cua pack. Ticket #55/#56 nang len A1-B2 x 10 Unit + C1 x 3.
UNITS_PER_STAGE = {"A1": 10, "A2": 10, "B1": 10, "B2": 10, "C1": 3}
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
        "id": "tatoeba",
        "name": "Tatoeba English-Vietnamese sentence pairs",
        "license": "CC BY 2.0 FR (attribution; sentence ids kept in sourceRef)",
        "url": "https://tatoeba.org/en/downloads",
        "retrievedAt": "2026-09-25",
        "files": ["scripts/english_path/data/tatoeba_eng_vie.tsv"],
    },
    {
        "id": "gymtalk-grammar",
        "name": "GymTalk in-house grammar bank (sequence after CEFR-J Grammar Profile)",
        "license": "Proprietary - written by the GymTalk team",
        "url": "scripts/english_path/grammar_bank.json",
        "retrievedAt": "2026-09-25",
        "files": ["grammar_bank.json"],
    },
    {
        "id": "nawl",
        "name": "New Academic Word List 1.2 (Browne, Culligan & Phillips, 2013)",
        "license": "CC BY-SA 4.0 (share-alike; headword snapshot kept as a separate file)",
        "url": "https://www.newgeneralservicelist.com/new-academic-word-list",
        "retrievedAt": "2026-09-25",
        "files": ["scripts/english_path/data/nawl_headwords.txt"],
    },
    {
        "id": "gymtalk-ielts",
        "name": "GymTalk in-house IELTS-style micro exercises (not taken from IELTS papers)",
        "license": "Proprietary - written by the GymTalk team",
        "url": "scripts/english_path/ielts_micro.json",
        "retrievedAt": "2026-09-25",
        "files": ["ielts_micro.json"],
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

# Chu de uu tien xep len dau lo trinh - hop voi nguoi tap gym.
TOPIC_PRIORITY = [
    "Body", "Sports", "Health", "Actions", "Food", "Drinks", "Time",
    "Clothing", "Weather", "Family", "Emotions", "Home & Furniture",
]
# Moi tu co 1 cau Meaning + 1 cau thuc hanh, xoay vong 3 dang nay.
SECOND_TYPES = ["gapFill", "listening", "wordScramble"]
ITEM_TYPES = {"meaning", "listening", "gapFill", "wordScramble", "grammar",
              "ieltsMicro"}
IELTS_STAGES = {"B1", "B2", "C1"}
TFNG_OPTIONS = ["True", "False", "Not Given"]
# Tatoeba: CC BY 2.0 FR - snapshot da loc (cau <= 12 tu, co ban dich Viet).
TATOEBA_SENTENCE_URL = "https://tatoeba.org/en/sentences/show/"

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


def tag_cefr(words: list[dict], levels: dict[str, str],
             nawl: set[str] | None = None) -> list[dict]:
    """Gan cap CEFR-J (thap nhat) cho tu. Tu hoc thuat NAWL nam ngoai CEFR-J
    A1-B2 duoc xep C1; tu khong co o ca 2 nguon bi bo."""
    nawl = nawl or set()
    out, seen = [], set()
    for w in words:
        key = w["en"].strip().lower()
        if key in seen:
            continue
        level = levels.get(key) or ("C1" if key in nawl else None)
        if level is None:
            continue
        seen.add(key)
        out.append(dict(w, cefr=level))
    return out


def _norm(s: str) -> str:
    return re.sub(r"\s+", " ", s).strip().lower()


def _slug(s: str) -> str:
    return re.sub(r"[^a-z0-9]+", "-", s.lower()).strip("-")


def _has_vietnamese(w: dict) -> bool:
    return bool(w.get("vi", "").strip()) and bool(w.get("exampleVi", "").strip())


def _topic_rank(topic: str, size: int) -> tuple:
    prio = TOPIC_PRIORITY.index(topic) if topic in TOPIC_PRIORITY else len(TOPIC_PRIORITY)
    return (prio, -size, topic)


def _pick_unit_words(pool: list[dict], count: int, n_units: int) -> list[list[dict]]:
    """Gom tu theo chu de (chu de gym uu tien, roi chu de nhieu tu) roi cat
    thanh Unit."""
    by_topic: dict[str, list[dict]] = {}
    for w in pool:
        by_topic.setdefault(w["topic"], []).append(w)
    ordered = []
    for topic in sorted(by_topic, key=lambda t: _topic_rank(t, len(by_topic[t]))):
        ordered.extend(sorted(by_topic[topic], key=lambda w: w["en"].lower()))
    return [ordered[i * count:(i + 1) * count] for i in range(n_units)
            if len(ordered) >= (i + 1) * count]


def _word_sources(word: dict) -> list[str]:
    """Tu C1 lay cap tu NAWL, con lai tu CEFR-J."""
    level_src = "nawl" if word.get("cefr") == "C1" else "cefrj"
    return [level_src, "gymtalk-vocab"]


def _meaning_item(unit_id: str, word: dict, unit_words: list[dict],
                  pool: list[dict]) -> dict:
    """Dap an nhieu uu tien tu cung Unit (cung chu de/tu loai) de cau hoi
    khong qua de, thieu thi lay them tu ca Stage."""
    item_id = f"{unit_id}-meaning-{_slug(word['en'])}"
    rng = random.Random(item_id)
    taken = {_norm(word["vi"])}
    answer_senses = _senses(word["vi"])
    same_unit = sorted(unit_words, key=lambda w: w["en"].lower())
    rest = sorted(pool, key=lambda w: w["en"].lower())
    rng.shuffle(same_unit)
    rng.shuffle(rest)
    candidates = same_unit + rest
    distractors = []
    for c in candidates:
        # Bo dap an nhieu trung/giao nghia voi dap an dung (vd "giu" vs
        # "cam, giu") - heuristic nghia tieng Viet, con lai de review nguoi.
        if _norm(c["vi"]) in taken or _senses(c["vi"]) & answer_senses:
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
        "sourceIds": _word_sources(word),
    }


def _senses(vi: str) -> set[str]:
    """Cac nghia tach boi , ; / - de phat hien dap an nhieu dong nghia."""
    return {_norm(p) for p in re.split(r"[,;/]", vi) if _norm(p)}


_PRONOUN_CAPS = {"I", "I'm", "I've", "I'll", "I'd"}
# Ten nhan vat hay gap trong Tatoeba (ca dau cau, khong nhan ra bang chu hoa).
_TATOEBA_NAMES = {
    "Tom", "Mary", "John", "Muiriel", "Ken", "Jack", "Bob", "Jane", "Mike",
    "Alice", "Paul", "Tony", "Lucy", "Maria", "Anna", "Emily", "Jim", "Kate",
    "Sami", "Layla", "Dan", "Linda", "Bill", "Taro", "Hanako", "Yanni",
}


def _usable_sentence(sentence: str) -> bool:
    """4-12 tu, khong co ten rieng (chu hoa giua cau) - cau Tatoeba hay co
    ten Tom/Mary, kho hieu voi nguoi moi hoc."""
    tokens = sentence.split()
    if not 4 <= len(tokens) <= 12:
        return False
    for n, t in enumerate(tokens):
        core = t.strip(".,!?;:\"'()").split("'")[0]
        if core in _TATOEBA_NAMES:
            return False
        if n and core and core[0].isupper() and t.strip(".,!?;:\"'()") not in _PRONOUN_CAPS:
            return False
    return True


def _word_re(word: str):
    return re.compile(r"\b" + re.escape(word) + r"\b", re.IGNORECASE)


def _find_sentence(word: dict, tatoeba: list[dict]) -> dict | None:
    """Cau cho Gap-fill: uu tien Tatoeba (ngan nhat), khong co thi dung cau
    vi du tu soan neu chua dung nguyen tu."""
    rx = _word_re(word["en"])
    hits = [t for t in tatoeba if rx.search(t["en"]) and _usable_sentence(t["en"])]
    if hits:
        best = min(hits, key=lambda t: (len(t["en"]), t["enId"]))
        return {"en": best["en"], "vi": best["vi"], "source": "tatoeba",
                "ref": f"tatoeba:eng#{best['enId']}/vie#{best['viId']}"}
    if rx.search(word["exampleEn"]):
        return {"en": word["exampleEn"], "vi": word["exampleVi"],
                "source": "gymtalk-vocab", "ref": None}
    return None


def _en_distractors(item_id: str, word: dict, unit_words: list[dict],
                    exclude_text: str = "") -> list[str] | None:
    rng = random.Random(item_id)
    others = sorted({w["en"] for w in unit_words if w["en"] != word["en"]})
    rng.shuffle(others)
    picked = [o for o in others if not _word_re(o).search(exclude_text)][:3]
    return picked if len(picked) == 3 else None


def _second_item(unit_id: str, j: int, word: dict, unit_words: list[dict],
                 tatoeba: list[dict]) -> dict | None:
    """Cau thuc hanh thu 2 cua tu: xoay vong Gap-fill / Listening / Scramble,
    dang nao khong lam duoc thi thu dang ke tiep."""
    slug = _slug(word["en"])
    for k in range(len(SECOND_TYPES)):
        kind = SECOND_TYPES[(j + k) % len(SECOND_TYPES)]
        item_id = f"{unit_id}-{kind}-{slug}"
        base = {"id": item_id, "unitId": unit_id, "type": kind,
                "wordEn": word["en"], "sourceIds": _word_sources(word)}
        if kind == "gapFill":
            sent = _find_sentence(word, tatoeba)
            if sent is None:
                continue
            distract = _en_distractors(item_id, word, unit_words, sent["en"])
            if distract is None:
                continue
            options = [word["en"]] + distract
            random.Random(item_id + "o").shuffle(options)
            item = dict(base, prompt=_word_re(word["en"]).sub("___", sent["en"], count=1),
                        options=options, answerIndex=options.index(word["en"]),
                        hintVi=sent["vi"])
            if sent["source"] == "tatoeba":
                item["sourceIds"] = [_word_sources(word)[0], "tatoeba"]
                item["sourceRef"] = sent["ref"]
            return item
        if kind == "listening":
            distract = _en_distractors(item_id, word, unit_words)
            if distract is None:
                continue
            options = [word["en"]] + distract
            random.Random(item_id + "o").shuffle(options)
            return dict(base, prompt=word["en"], options=options,
                        answerIndex=options.index(word["en"]))
        if kind == "wordScramble":
            if not (word["en"].isalpha() and 3 <= len(word["en"]) <= 10):
                continue
            return dict(base, prompt=word["en"], options=[word["en"]],
                        answerIndex=0, hintVi=word["vi"])
    return None


def _grammar_items(unit_id: str, point: dict) -> list[dict]:
    out = []
    for k, g in enumerate(point["items"], 1):
        out.append({
            "id": f"{unit_id}-grammar-{point['id']}-{k}",
            "unitId": unit_id,
            "type": "grammar",
            "prompt": g["prompt"],
            "options": list(g["options"]),
            "answerIndex": g["options"].index(g["answer"]),
            "explanationVi": point["explanationVi"],
            "sourceIds": ["gymtalk-grammar"],
        })
    return out


def _ielts_items(unit_id: str, ex: dict) -> list[dict]:
    """1 doan van: 2 cau True/False/Not Given + 1 cau chon tieu de."""
    items = []
    for k, t in enumerate(ex["tfng"], 1):
        items.append({
            "id": f"{unit_id}-ielts-{ex['id']}-tfng{k}",
            "unitId": unit_id,
            "type": "ieltsMicro",
            "task": "tfng",
            "passage": ex["passage"],
            "prompt": t["statement"],
            "options": list(TFNG_OPTIONS),
            "answerIndex": TFNG_OPTIONS.index(t["answer"]),
            "sourceIds": ["gymtalk-ielts"],
        })
    headings = list(ex["headings"])
    random.Random(ex["id"]).shuffle(headings)
    items.append({
        "id": f"{unit_id}-ielts-{ex['id']}-heading",
        "unitId": unit_id,
        "type": "ieltsMicro",
        "task": "heading",
        "passage": ex["passage"],
        "prompt": "Choose the best heading for the paragraph.",
        "options": headings,
        "answerIndex": headings.index(ex["heading"]),
        "sourceIds": ["gymtalk-ielts"],
    })
    return items


def _unit_title(unit_words: list[dict]) -> tuple[str, str]:
    """Tieu de Unit = toi da 2 chu de chiem nhieu tu nhat (Unit cat ngang
    ranh gioi chu de thi ghi du ca 2, vd "Food · Actions")."""
    order: list[str] = []
    counts: dict[str, int] = {}
    vi: dict[str, str] = {}
    for w in unit_words:
        t = w["topic"]
        if t not in counts:
            order.append(t)
            vi[t] = w.get("topicVi", t)
        counts[t] = counts.get(t, 0) + 1
    top = sorted(order, key=lambda t: (-counts[t], order.index(t)))[:2]
    return " · ".join(top), " · ".join(vi[t] for t in top)


def build_pack(words: list[dict], units_per_stage: dict[str, int],
               words_per_unit: int, tatoeba: list[dict] | None = None,
               grammar: dict | None = None, ielts: dict | None = None) -> dict:
    tatoeba = tatoeba or []
    grammar = grammar or {}
    ielts = ielts or {}
    stages = []
    for cefr in STAGES:
        n_units = units_per_stage.get(cefr, 0)
        if not n_units:
            continue
        pool = [w for w in words if w.get("cefr") == cefr and _has_vietnamese(w)]
        units = []
        for idx, unit_words in enumerate(_pick_unit_words(pool, words_per_unit, n_units), 1):
            unit_id = f"{cefr.lower()}-u{idx:02d}"
            title_en, title_vi = _unit_title(unit_words)
            items = [_meaning_item(unit_id, w, unit_words, pool) for w in unit_words]
            for j, w in enumerate(unit_words):
                second = _second_item(unit_id, j, w, unit_words, tatoeba)
                if second is not None:
                    items.append(second)
            unit = {
                "id": unit_id,
                "index": idx,
                "titleEn": title_en,
                "titleVi": title_vi,
                "words": [
                    {k: w[k] for k in ("en", "ipa", "vi", "exampleEn", "exampleVi")}
                    for w in unit_words
                ],
            }
            points = grammar.get(cefr, [])
            if idx <= len(points):
                point = points[idx - 1]
                unit["grammar"] = {k: point[k] for k in
                                   ("id", "titleEn", "titleVi", "explanationVi")}
                items += _grammar_items(unit_id, point)
            passages = ielts.get(cefr, []) if cefr in IELTS_STAGES else []
            if idx <= len(passages):
                items += _ielts_items(unit_id, passages[idx - 1])
            unit["items"] = items
            units.append(unit)
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
                kind = item.get("type")
                if kind not in ITEM_TYPES:
                    errors.append(f"{iid}: unknown item type {kind}")
                if kind == "meaning" and isinstance(ans, int) and 0 <= ans < len(options):
                    right = _senses(options[ans])
                    for k, o in enumerate(options):
                        if k != ans and _senses(o) & right:
                            errors.append(f"{iid}: synonym distractor '{o}'")
                if kind in ("gapFill", "grammar") and item.get("prompt", "").count("___") != 1:
                    errors.append(f"{iid}: prompt needs exactly one ___ blank")
                if kind == "gapFill" and isinstance(ans, int) and 0 <= ans < len(options):
                    if _word_re(options[ans]).search(item.get("prompt", "")):
                        errors.append(f"{iid}: answer still visible in the prompt")
                if kind in ("gapFill", "wordScramble") and not item.get("hintVi", "").strip():
                    errors.append(f"{iid}: missing Vietnamese hint")
                if kind == "grammar" and not item.get("explanationVi", "").strip():
                    errors.append(f"{iid}: grammar item without Vietnamese explanation")
                if kind == "ieltsMicro":
                    if stage.get("cefr") not in IELTS_STAGES:
                        errors.append(f"{iid}: IELTS Micro Exercise only allowed in B1-C1")
                    if not item.get("passage", "").strip():
                        errors.append(f"{iid}: IELTS item without passage")
                    if item.get("task") == "tfng" and options != TFNG_OPTIONS:
                        errors.append(f"{iid}: T/F/NG options must be True/False/Not Given")
                    if item.get("task") not in ("tfng", "heading"):
                        errors.append(f"{iid}: unknown IELTS task {item.get('task')}")
                if kind == "wordScramble" and len(options) != 1:
                    errors.append(f"{iid}: scramble must have exactly one option")
                if kind == "listening" and item.get("prompt") not in options:
                    errors.append(f"{iid}: listening prompt is not an option")
                if "tatoeba" in (item.get("sourceIds") or []) and not str(
                        item.get("sourceRef", "")).startswith("tatoeba:"):
                    errors.append(f"{iid}: tatoeba item without sentence ids")
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
                    "answer", "hint", "exampleEn", "exampleVi", "sources",
                    "reviewer_note"])
        for cefr, unit, word, item in rows:
            w.writerow([
                "yes" if item["id"] in sampled else "",
                cefr, unit["id"], item["id"], item["type"], item["prompt"],
                " | ".join(item["options"]), item["options"][item["answerIndex"]],
                item.get("hintVi") or item.get("explanationVi")
                or item.get("passage") or "",
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
    words = tag_cefr(parse_vocab_dart(VOCAB_DART.read_text(encoding="utf-8")),
                     levels, nawl=load_nawl())
    words, tatoeba = apply_exclusions(words, load_tatoeba(), load_exclusions())
    pack = build_pack(words, UNITS_PER_STAGE, WORDS_PER_UNIT,
                      tatoeba=tatoeba, grammar=load_grammar(),
                      ielts=load_ielts())
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


def apply_exclusions(words: list[dict], tatoeba: list[dict],
                     exclusions: dict) -> tuple[list[dict], list[dict]]:
    """Ap ket qua review (nguoi + Grok): bo tu / cau loi, sua ban dich Viet.
    Moi sua chua di qua day de chay lai pipeline van giu duoc - KHONG sua
    tay JSON pack."""
    bad_words = {w.lower() for w in exclusions.get("excludeWords", {})}
    bad_sentences = set(exclusions.get("excludeSentences", {}))
    fixes = exclusions.get("fixVietnamese", {})
    words = [w for w in words if w["en"].lower() not in bad_words]
    tatoeba = [dict(t, vi=fixes.get(t["en"], t["vi"])) for t in tatoeba
               if t["en"] not in bad_sentences]
    return words, tatoeba


def load_exclusions() -> dict:
    if not EXCLUSIONS.exists():
        return {}
    return json.loads(EXCLUSIONS.read_text(encoding="utf-8"))


def load_nawl() -> set[str]:
    """Snapshot headword NAWL (CC BY-SA 4.0, file rieng)."""
    return {l.strip().lower() for l in NAWL_SNAPSHOT.read_text(encoding="utf-8").splitlines()
            if l.strip() and not l.startswith("#")}


def load_ielts() -> dict:
    data = json.loads(IELTS_BANK.read_text(encoding="utf-8"))
    return {k: v for k, v in data.items() if not k.startswith("_")}


def load_grammar() -> dict:
    data = json.loads(GRAMMAR_BANK.read_text(encoding="utf-8"))
    return {k: v for k, v in data.items() if not k.startswith("_")}


def load_tatoeba() -> list[dict]:
    """Doc snapshot Tatoeba da loc (commit trong repo -> chay lai ra cung
    ket qua). Tao lai bang `refresh-tatoeba`."""
    out = []
    with TATOEBA_SNAPSHOT.open(encoding="utf-8") as f:
        for line in f:
            en_id, vi_id, en, vi = line.rstrip("\n").split("\t")
            out.append({"enId": en_id, "viId": vi_id, "en": en, "vi": vi})
    return out


def cmd_refresh_tatoeba(args) -> int:
    """Tai export Tatoeba (eng, vie, links vie-eng), giu cap cau ngan dung
    duoc, ghi snapshot TSV (enId, viId, en, vi) sap xep theo enId."""
    import bz2
    import tempfile
    import urllib.request
    base = "https://downloads.tatoeba.org/exports/per_language/"
    tmp = Path(tempfile.gettempdir()) / "tatoeba"
    tmp.mkdir(exist_ok=True)
    files = {"vie": "vie/vie_sentences.tsv.bz2", "links": "vie/vie-eng_links.tsv.bz2",
             "eng": "eng/eng_sentences.tsv.bz2"}
    for rel in files.values():
        dst = tmp / Path(rel).name
        if not dst.exists():
            urllib.request.urlretrieve(base + rel, dst)

    def read(name):
        with bz2.open(tmp / Path(files[name]).name, "rt", encoding="utf-8") as f:
            for line in f:
                yield line.rstrip("\n").split("\t")
    vie = {r[0]: r[2] for r in read("vie")}
    links = [(r[0], r[1]) for r in read("links")]
    need = {b for _, b in links}
    eng = {r[0]: r[2] for r in read("eng") if r[0] in need}
    rows = sorted({(b, a, eng[b], vie[a]) for a, b in links
                   if a in vie and b in eng and _usable_sentence(eng[b])
                   and "\t" not in eng[b] + vie[a]},
                  key=lambda r: int(r[0]))
    TATOEBA_SNAPSHOT.parent.mkdir(parents=True, exist_ok=True)
    with TATOEBA_SNAPSHOT.open("w", encoding="utf-8", newline="\n") as f:
        for r in rows:
            f.write("\t".join(r) + "\n")
    print(f"tatoeba snapshot: {len(rows)} pairs -> {TATOEBA_SNAPSHOT}")
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
    sub.add_parser("refresh-tatoeba")
    a = sub.add_parser("approve")
    a.add_argument("--reviewer", required=True)
    a.add_argument("--date", required=True, help="YYYY-MM-DD")
    a.add_argument("--note", default="")
    args = ap.parse_args()
    return {"build": cmd_build, "approve": cmd_approve,
            "refresh-tatoeba": cmd_refresh_tatoeba}[args.cmd](args)


if __name__ == "__main__":
    sys.exit(main())
