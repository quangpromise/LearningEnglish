"""Test sinh cac dang Practice Item cua Content Pack A1-A2 (issue #55).

Chay: python -m unittest discover -s scripts -p 'test_*.py' -v
"""

import unittest

import english_path_pipeline as pp


def _w(en, vi, topic="Actions", ex=None, exvi=None):
    return {
        "en": en,
        "ipa": f"/{en}/",
        "vi": vi,
        "exampleEn": ex or f"I {en} every day.",
        "exampleVi": exvi or f"Tôi {vi} mỗi ngày.",
        "topic": topic,
        "topicVi": "Hành động",
        "cefr": "A1",
    }


WORDS = [
    _w("run", "chạy"), _w("jump", "nhảy"), _w("lift", "nâng, nhấc"),
    _w("push", "đẩy"), _w("pull", "kéo"), _w("carry", "mang, vác"),
    _w("kick", "đá"), _w("hold", "cầm, giữ"), _w("catch", "bắt, chụp"),
]
TATOEBA = [
    {"en": "Tom likes to run.", "vi": "Tom thích chạy.", "enId": "1", "viId": "2"},
    {"en": "Can you lift this box?", "vi": "Bạn nhấc được cái hộp này không?", "enId": "3", "viId": "4"},
    {"en": "Please hold my bag for a moment.", "vi": "Giữ túi giúp tôi một lát.", "enId": "5", "viId": "6"},
]
GRAMMAR = {
    "A1": [
        {
            "id": "be-present",
            "titleEn": "am / is / are",
            "titleVi": "Động từ to be",
            "explanationVi": "I đi với am.",
            "items": [
                {"prompt": "I ___ ready.", "options": ["am", "is", "are"], "answer": "am"},
                {"prompt": "She ___ ready.", "options": ["am", "is", "are"], "answer": "is"},
                {"prompt": "We ___ ready.", "options": ["am", "is", "are"], "answer": "are"},
            ],
        }
    ]
}


def _pack():
    return pp.build_pack(
        WORDS, {"A1": 1}, 9, tatoeba=TATOEBA, grammar=GRAMMAR,
    )


def _items(pack, type_=None):
    items = pack["stages"][0]["units"][0]["items"]
    return [i for i in items if type_ is None or i["type"] == type_]


class ItemTypesTest(unittest.TestCase):
    def test_every_word_has_meaning_plus_one_practice_item(self):
        pack = _pack()
        self.assertEqual(len(_items(pack, "meaning")), 9)
        second = [i for i in _items(pack) if i["type"] in ("gapFill", "listening", "wordScramble")]
        self.assertEqual(len(second), 9)
        self.assertEqual({i["type"] for i in second}, {"gapFill", "listening", "wordScramble"})
        self.assertEqual(pp.validate_pack(pack), [])

    def test_gap_fill_blanks_the_word_and_prefers_tatoeba_without_names(self):
        for item in _items(_pack(), "gapFill"):
            self.assertEqual(item["prompt"].count("___"), 1)
            answer = item["options"][item["answerIndex"]]
            self.assertNotIn(answer.lower(), item["prompt"].lower().split())
            self.assertTrue(item["hintVi"])
            self.assertNotIn("Tom", item["prompt"])
        lift = [i for i in _items(_pack(), "gapFill") if i["wordEn"] == "lift"]
        if lift:
            self.assertIn("tatoeba", lift[0]["sourceIds"])
            self.assertEqual(lift[0]["sourceRef"], "tatoeba:eng#3/vie#4")

    def test_listening_options_are_english_words_of_the_unit(self):
        unit_words = {w["en"] for w in WORDS}
        for item in _items(_pack(), "listening"):
            self.assertIn(item["prompt"], item["options"])
            self.assertTrue(set(item["options"]) <= unit_words)

    def test_scramble_has_the_word_and_its_meaning(self):
        for item in _items(_pack(), "wordScramble"):
            self.assertEqual(item["options"], [item["wordEn"]])
            self.assertTrue(item["hintVi"])

    def test_grammar_point_and_items_attached_to_the_unit(self):
        pack = _pack()
        unit = pack["stages"][0]["units"][0]
        self.assertEqual(unit["grammar"]["id"], "be-present")
        grammar = _items(pack, "grammar")
        self.assertEqual(len(grammar), 3)
        for g in grammar:
            self.assertEqual(g["sourceIds"], ["gymtalk-grammar"])
            self.assertTrue(g["explanationVi"])

    def test_unit_title_is_the_dominant_topic(self):
        unit = _pack()["stages"][0]["units"][0]
        self.assertEqual(unit["titleEn"], "Actions")


class SynonymDistractorTest(unittest.TestCase):
    def test_meaning_distractors_never_share_a_sense_with_the_answer(self):
        words = WORDS + [_w("keep", "giữ")]
        pack = pp.build_pack(words, {"A1": 1}, 10, tatoeba=TATOEBA, grammar=GRAMMAR)
        self.assertEqual(pp.validate_pack(pack), [])
        for item in _items(pack, "meaning"):
            answer = pp._senses(item["options"][item["answerIndex"]])
            for i, o in enumerate(item["options"]):
                if i != item["answerIndex"]:
                    self.assertFalse(answer & pp._senses(o), (item["id"], o))

    def test_validation_rejects_overlapping_senses(self):
        pack = _pack()
        item = _items(pack, "meaning")[0]
        wrong = (item["answerIndex"] + 1) % 4
        item["options"][wrong] = item["options"][item["answerIndex"]].split(",")[0] + ", khác"
        self.assertTrue(any("synonym" in e for e in pp.validate_pack(pack)))

    def test_validation_rejects_gap_fill_without_blank(self):
        pack = _pack()
        gap = _items(pack, "gapFill")[0]
        gap["prompt"] = gap["prompt"].replace("___", "something")
        self.assertTrue(any("blank" in e for e in pp.validate_pack(pack)))


class ExclusionsTest(unittest.TestCase):
    def test_review_exclusions_drop_words_and_sentences_and_fix_vi(self):
        words, tatoeba = pp.apply_exclusions(WORDS, TATOEBA, {
            "excludeWords": {"kick": "ly do"},
            "excludeSentences": {"Can you lift this box?": "ly do"},
            "fixVietnamese": {"Please hold my bag for a moment.": "Giữ giúp tôi cái túi một lát."},
        })
        self.assertNotIn("kick", [w["en"] for w in words])
        self.assertNotIn("Can you lift this box?", [t["en"] for t in tatoeba])
        hold = next(t for t in tatoeba if t["en"].startswith("Please hold"))
        self.assertEqual(hold["vi"], "Giữ giúp tôi cái túi một lát.")


class TatoebaFilterTest(unittest.TestCase):
    def test_sentence_filter(self):
        self.assertTrue(pp._usable_sentence("Can you lift this box?"))
        self.assertFalse(pp._usable_sentence("Tom likes to run."))
        self.assertFalse(pp._usable_sentence("Run."))
        self.assertFalse(pp._usable_sentence("This is a very long sentence that has far too many words in it."))


if __name__ == "__main__":
    unittest.main()
