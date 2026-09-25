"""Test pipeline sinh Content Pack cho lo trinh tieng Anh (issue #46).

Chay: python -m unittest discover -s scripts -p 'test_*.py' -v
"""

import copy
import csv
import json
import tempfile
import unittest
from pathlib import Path

import english_path_pipeline as pp

VOCAB_DART_SNIPPET = r"""
const kVocabTopics = [
  VocabTopic(
    name: 'Gia đình',
    nameEn: 'Family',
    words: [
      VocabWord(
        en: 'mother',
        ipa: '/ˈmʌðə/',
        vi: 'mẹ',
        exampleEn: 'My mother is a teacher.',
        exampleVi: 'Mẹ tôi là giáo viên.',
        frequency: VocabFrequency.common,
      ),
      VocabWord(
        en: 'father\'s day',
        ipa: '/x/',
        vi: 'ngày của cha',
        exampleEn: 'It is Father\'s Day.',
        exampleVi: 'Hôm nay là Ngày của Cha.',
      ),
    ],
  ),
];
"""


def _word(en, vi, level="A1", topic="Family"):
    return {
        "en": en,
        "ipa": f"/{en}/",
        "vi": vi,
        "exampleEn": f"This is a {en}.",
        "exampleVi": f"Đây là {vi}.",
        "topic": topic,
        "cefr": level,
    }


WORDS = [
    _word("mother", "mẹ"),
    _word("father", "bố"),
    _word("sister", "chị gái"),
    _word("brother", "anh trai"),
    _word("baby", "em bé"),
    _word("son", "con trai"),
    _word("daughter", "con gái"),
]


def _valid_pack():
    return pp.build_pack(WORDS, units_per_stage={"A1": 1}, words_per_unit=5)


class LoadVocabTest(unittest.TestCase):
    def test_reads_words_with_escaped_quotes(self):
        words = pp.parse_vocab_dart(VOCAB_DART_SNIPPET)
        self.assertEqual([w["en"] for w in words], ["mother", "father's day"])
        self.assertEqual(words[0]["vi"], "mẹ")
        self.assertEqual(words[0]["exampleVi"], "Mẹ tôi là giáo viên.")
        self.assertEqual(words[0]["topic"], "Family")
        self.assertEqual(words[1]["exampleEn"], "It is Father's Day.")


class BuildPackTest(unittest.TestCase):
    def test_builds_stage_unit_items_with_sources(self):
        pack = _valid_pack()
        self.assertEqual(pack["schemaVersion"], pp.PACK_SCHEMA_VERSION)
        source_ids = {s["id"] for s in pack["sources"]}
        self.assertIn("cefrj", source_ids)
        (stage,) = pack["stages"]
        self.assertEqual(stage["cefr"], "A1")
        (unit,) = stage["units"]
        self.assertEqual(len(unit["words"]), 5)
        self.assertEqual(len(unit["items"]), 5)
        for item in unit["items"]:
            self.assertEqual(item["type"], "meaning")
            self.assertEqual(len(item["options"]), 4)
            self.assertTrue(set(item["sourceIds"]) <= source_ids)

    def test_is_deterministic(self):
        self.assertEqual(_valid_pack(), _valid_pack())

    def test_item_ids_are_stable_and_unique(self):
        items = _valid_pack()["stages"][0]["units"][0]["items"]
        ids = [i["id"] for i in items]
        self.assertEqual(len(ids), len(set(ids)))
        self.assertIn("a1-u01-meaning-mother", ids)

    def test_skips_words_without_vietnamese(self):
        words = WORDS + [dict(_word("aunt", "cô"), exampleVi="")]
        pack = pp.build_pack(words, units_per_stage={"A1": 1}, words_per_unit=7)
        ens = [w["en"] for w in pack["stages"][0]["units"][0]["words"]]
        self.assertNotIn("aunt", ens)
        self.assertEqual(pp.validate_pack(pack), [])

    def test_valid_pack_has_no_errors(self):
        self.assertEqual(pp.validate_pack(_valid_pack()), [])


class ValidatePackTest(unittest.TestCase):
    def _first_item(self, pack):
        return pack["stages"][0]["units"][0]["items"][0]

    def test_rejects_answer_outside_options(self):
        pack = _valid_pack()
        self._first_item(pack)["answerIndex"] = 9
        self.assertTrue(any("answer" in e for e in pp.validate_pack(pack)))

    def test_rejects_duplicate_options_after_normalising(self):
        pack = _valid_pack()
        item = self._first_item(pack)
        item["options"][1] = " " + item["options"][0].upper() + " "
        self.assertTrue(any("duplicate" in e for e in pp.validate_pack(pack)))

    def test_rejects_missing_vietnamese(self):
        pack = _valid_pack()
        pack["stages"][0]["units"][0]["words"][0]["exampleVi"] = ""
        self.assertTrue(any("Vietnamese" in e for e in pp.validate_pack(pack)))

    def test_rejects_unknown_unit_reference(self):
        pack = _valid_pack()
        self._first_item(pack)["unitId"] = "a1-u99"
        self.assertTrue(any("unit" in e for e in pp.validate_pack(pack)))

    def test_rejects_source_without_license(self):
        pack = _valid_pack()
        pack["sources"][0]["license"] = ""
        self.assertTrue(any("license" in e for e in pp.validate_pack(pack)))

    def test_rejects_unknown_source_id(self):
        pack = _valid_pack()
        self._first_item(pack)["sourceIds"] = ["scraped-site"]
        self.assertTrue(any("source" in e for e in pp.validate_pack(pack)))

    def test_rejects_duplicate_item_ids(self):
        pack = _valid_pack()
        items = pack["stages"][0]["units"][0]["items"]
        items[1]["id"] = items[0]["id"]
        self.assertTrue(any("id" in e for e in pp.validate_pack(pack)))


class ApprovalTest(unittest.TestCase):
    def test_hash_ignores_approval_but_tracks_content(self):
        pack = _valid_pack()
        h = pp.content_hash(pack)
        approved = pp.apply_approval(
            pack, [{"contentHash": h, "reviewer": "maintainer", "approvedAt": "2026-09-25"}]
        )
        self.assertEqual(pp.content_hash(approved), h)
        changed = copy.deepcopy(pack)
        changed["stages"][0]["units"][0]["words"][0]["vi"] = "má"
        self.assertNotEqual(pp.content_hash(changed), h)

    def test_approval_attached_only_for_matching_hash(self):
        pack = _valid_pack()
        h = pp.content_hash(pack)
        record = {"contentHash": h, "reviewer": "maintainer", "approvedAt": "2026-09-25"}
        self.assertEqual(pp.apply_approval(pack, [record])["approval"]["reviewer"], "maintainer")
        stale = dict(record, contentHash="deadbeef")
        self.assertIsNone(pp.apply_approval(pack, [stale])["approval"])

    def test_pack_records_its_content_hash(self):
        pack = pp.apply_approval(_valid_pack(), [])
        self.assertEqual(pack["contentHash"], pp.content_hash(pack))


class ReviewCsvTest(unittest.TestCase):
    def test_exports_every_item_with_deterministic_10_percent_sample(self):
        pack = pp.build_pack(WORDS * 1, units_per_stage={"A1": 1}, words_per_unit=7)
        with tempfile.TemporaryDirectory() as d:
            out = Path(d) / "review.csv"
            pp.export_review_csv(pack, out)
            with out.open(encoding="utf-8") as f:
                rows = list(csv.DictReader(f))
            again = Path(d) / "again.csv"
            pp.export_review_csv(pack, again)
            self.assertEqual(out.read_text(encoding="utf-8"), again.read_text(encoding="utf-8"))
        self.assertEqual(len(rows), 7)
        sampled = [r for r in rows if r["sample"] == "yes"]
        self.assertGreaterEqual(len(sampled), 1)
        self.assertIn("answer", rows[0])


class CommittedPackTest(unittest.TestCase):
    """Pack da dong goi trong app phai hop le va dung hash (khong sua tay JSON)."""

    def test_bundled_pack_is_valid_and_hash_matches(self):
        path = pp.PACK_ASSET
        if not path.exists():
            self.skipTest("chua sinh pack")
        pack = json.loads(path.read_text(encoding="utf-8"))
        self.assertEqual(pp.validate_pack(pack), [])
        self.assertEqual(pack["contentHash"], pp.content_hash(pack))


if __name__ == "__main__":
    unittest.main()
