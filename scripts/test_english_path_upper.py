"""Test noi dung B1-C1: tu C1 tu NAWL, IELTS Micro Exercise (issue #56).

Chay: python -m unittest discover -s scripts -p 'test_*.py' -v
"""

import unittest

import english_path_pipeline as pp


def _w(en, vi, level):
    return {
        "en": en, "ipa": f"/{en}/", "vi": vi,
        "exampleEn": f"The {en} matters.", "exampleVi": f"{vi} quan trọng.",
        "topic": "Health", "topicVi": "Y tế", "cefr": level,
    }


IELTS = {
    "B1": [{
        "id": "b1-water",
        "passage": "Your body loses water when you sweat. Drink small amounts often.",
        "tfng": [
            {"statement": "You lose water when you sweat.", "answer": "True"},
            {"statement": "Sports drinks are always better.", "answer": "False"},
        ],
        "headings": ["Drinking water while you train", "Cooking", "Cars", "Music"],
        "heading": "Drinking water while you train",
    }]
}


class NawlTaggingTest(unittest.TestCase):
    def test_nawl_words_outside_cefrj_become_c1(self):
        words = [{"en": "metabolism"}, {"en": "run"}, {"en": "blorp"}]
        tagged = pp.tag_cefr(words, {"run": "A1"}, nawl={"metabolism"})
        self.assertEqual({w["en"]: w["cefr"] for w in tagged},
                         {"metabolism": "C1", "run": "A1"})

    def test_c1_words_cite_nawl(self):
        words = [_w(f"w{i}", f"nghĩa {i}", "C1") for i in range(6)]
        pack = pp.build_pack(words, {"C1": 1}, 6)
        for item in pack["stages"][0]["units"][0]["items"]:
            if item["type"] == "meaning":
                self.assertIn("nawl", item["sourceIds"])
        self.assertEqual(pp.validate_pack(pack), [])


class IeltsMicroTest(unittest.TestCase):
    def _pack(self, level="B1"):
        words = [_w(f"w{i}", f"nghĩa {i}", level) for i in range(6)]
        return pp.build_pack(words, {level: 1}, 6, ielts={level: IELTS["B1"]})

    def test_b1_unit_gets_two_tfng_and_one_heading_item(self):
        items = [i for i in self._pack()["stages"][0]["units"][0]["items"]
                 if i["type"] == "ieltsMicro"]
        self.assertEqual([i["task"] for i in items], ["tfng", "tfng", "heading"])
        tfng = items[0]
        self.assertEqual(tfng["options"], ["True", "False", "Not Given"])
        self.assertEqual(tfng["options"][tfng["answerIndex"]], "True")
        self.assertTrue(tfng["passage"])
        heading = items[2]
        self.assertEqual(heading["options"][heading["answerIndex"]],
                         "Drinking water while you train")
        self.assertEqual(pp.validate_pack(self._pack()), [])

    def test_no_ielts_items_below_b1(self):
        words = [_w(f"w{i}", f"nghĩa {i}", "A2") for i in range(6)]
        pack = pp.build_pack(words, {"A2": 1}, 6, ielts={"A2": IELTS["B1"]})
        types = {i["type"] for i in pack["stages"][0]["units"][0]["items"]}
        self.assertNotIn("ieltsMicro", types)

    def test_validation_rejects_ielts_without_passage_or_in_a_stage(self):
        pack = self._pack()
        item = next(i for i in pack["stages"][0]["units"][0]["items"]
                    if i["type"] == "ieltsMicro")
        item["passage"] = ""
        self.assertTrue(any("passage" in e for e in pp.validate_pack(pack)))
        pack = self._pack()
        pack["stages"][0]["cefr"] = "A2"
        self.assertTrue(any("IELTS" in e for e in pp.validate_pack(pack)))


if __name__ == "__main__":
    unittest.main()
