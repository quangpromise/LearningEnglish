"""
Test cho pipeline them bai hat.

    python -m unittest discover -s scripts -p 'test_*.py'

Khong dung mang: cac adapter deu tach `parse(html, ref)` thuan tuy ra khoi
`fetch(ref)`, nen phan doc trang duoc test bang fixture HTML ngay tai day.
"""

import json
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import add_songs  # noqa: E402
import song_licensing as lic  # noqa: E402
import song_sources as src  # noqa: E402


def valid_record(**overrides):
    """Ban ghi hop le hoan toan - moi test lam hong dung 1 cho de xem cong
    gac co bat khong."""
    record = {
        "slug": "a-song",
        "title": "A Song",
        "artist": "An Artist",
        "duration": "3:00",
        "level": "Trung cấp",
        "color": "blue",
        "lyrics_origin": "publisher-page",
        "instrumental": False,
        "source": {"adapter": "manual", "page_url": "https://example.test/s"},
        "license": {
            "recording": {
                "license_id": "CC-BY-4.0",
                "evidence_url": "https://example.test/license",
                "verified_by": "human",
                "note": "",
            },
            "lyrics": {
                "license_id": "CC-BY-4.0",
                "evidence_url": "https://example.test/license",
                "verified_by": "human",
                "note": "tac gia tu viet + tu thu",
            },
        },
        "lines": [{"en": f"line {i}", "vi": f"dòng {i}"} for i in range(5)],
    }
    record.update(overrides)
    return record


class TestLicenseFromUrl(unittest.TestCase):
    def test_phan_biet_duoc_cac_bien_the_cc(self):
        cases = {
            "https://creativecommons.org/licenses/by/4.0/": "CC-BY-4.0",
            "http://creativecommons.org/licenses/by/3.0/": "CC-BY-3.0",
            "https://creativecommons.org/licenses/by-sa/4.0/": "CC-BY-SA-4.0",
            "https://creativecommons.org/licenses/by-nc/4.0/": "CC-BY-NC-4.0",
            "https://creativecommons.org/licenses/by-nc-sa/3.0/": "CC-BY-NC-SA-3.0",
            "https://creativecommons.org/licenses/by-nd/4.0/": "CC-BY-ND-4.0",
            "https://creativecommons.org/publicdomain/zero/1.0/": "CC0-1.0",
        }
        for url, expected in cases.items():
            self.assertEqual(lic.license_from_url(url), expected, url)

    def test_link_la_gi_do_khac_thi_tra_None(self):
        self.assertIsNone(lic.license_from_url("https://example.test/license"))
        self.assertIsNone(lic.license_from_url(""))


class TestLicenseGate(unittest.TestCase):
    def test_ban_ghi_hop_le_thi_qua(self):
        self.assertTrue(lic.evaluate(valid_record()).ok)

    def test_thieu_giay_phep_phan_loi_thi_bi_tu_choi(self):
        record = valid_record()
        record["license"]["lyrics"]["license_id"] = ""
        report = lic.evaluate(record)
        self.assertFalse(report.ok)
        self.assertTrue(any("phan loi" in e for e in report.errors))

    def test_giay_phep_ban_thu_khong_tu_dong_bao_trum_phan_loi(self):
        """Cai bay §2: track CC-BY nhung loi cua nguoi khac."""
        record = valid_record()
        record["license"]["lyrics"] = {
            "license_id": "",
            "evidence_url": "",
            "verified_by": "",
            "note": "",
        }
        self.assertFalse(lic.evaluate(record).ok)

    def test_non_commercial_bi_tu_choi(self):
        record = valid_record()
        record["license"]["recording"]["license_id"] = "CC-BY-NC-4.0"
        report = lic.evaluate(record)
        self.assertFalse(report.ok)
        self.assertTrue(any("NC" in e for e in report.errors))

    def test_no_derivatives_bi_tu_choi_vi_dich_la_phai_sinh(self):
        record = valid_record()
        record["license"]["lyrics"]["license_id"] = "CC-BY-ND-4.0"
        report = lic.evaluate(record)
        self.assertFalse(report.ok)
        self.assertTrue(any("phai sinh" in e for e in report.errors))

    def test_share_alike_can_dong_y_truoc(self):
        record = valid_record()
        record["license"]["recording"]["license_id"] = "CC-BY-SA-4.0"
        record["license"]["lyrics"]["license_id"] = "CC-BY-SA-4.0"
        self.assertFalse(lic.evaluate(record).ok)

        allowed = lic.evaluate(record, allow_share_alike=True)
        self.assertTrue(allowed.ok)
        self.assertTrue(any("ShareAlike" in o for o in allowed.obligations))

    def test_giay_phep_la_thi_bi_tu_choi_chu_khong_cho_qua(self):
        record = valid_record()
        record["license"]["recording"]["license_id"] = "Mot-giay-phep-la"
        self.assertFalse(lic.evaluate(record).ok)

    def test_giay_phep_stock_media_bi_tu_choi_dung_ly_do(self):
        record = valid_record()
        record["license"]["recording"]["license_id"] = "pixabay"
        report = lic.evaluate(record)
        self.assertFalse(report.ok)
        self.assertTrue(any("standalone" in e for e in report.errors))

    def test_thieu_bang_chung_thi_bi_tu_choi(self):
        record = valid_record()
        record["license"]["recording"]["evidence_url"] = ""
        report = lic.evaluate(record)
        self.assertFalse(report.ok)
        self.assertTrue(any("evidence_url" in e for e in report.errors))

    def test_verified_by_phai_hop_le(self):
        record = valid_record()
        record["license"]["recording"]["verified_by"] = "chac-vay"
        self.assertFalse(lic.evaluate(record).ok)

    def test_loi_chep_bang_asr_thi_phai_co_nguoi_kiem(self):
        record = valid_record(lyrics_origin=lic.ASR_ORIGIN)
        record["license"]["lyrics"]["verified_by"] = "adapter"
        report = lic.evaluate(record)
        self.assertFalse(report.ok)
        self.assertTrue(any("ASR" in e for e in report.errors))

        record["license"]["lyrics"]["verified_by"] = "human"
        self.assertTrue(lic.evaluate(record).ok)

    def test_track_remix_chua_truy_het_nguon_thi_bi_tu_choi(self):
        record = valid_record(
            unresolved_sources=["https://ccmixter.org/files/someone/123"]
        )
        report = lic.evaluate(record)
        self.assertFalse(report.ok)
        self.assertTrue(any("chua truy duoc" in e for e in report.errors))

    def test_canh_bao_khi_dung_chung_giay_phep_ma_khong_ghi_ly_do(self):
        record = valid_record()
        record["license"]["lyrics"]["verified_by"] = "adapter"
        record["license"]["lyrics"]["note"] = ""
        report = lic.evaluate(record)
        self.assertTrue(report.ok)  # canh bao, khong phai loi
        self.assertTrue(any("tu viet" in w for w in report.warnings))

    def test_lyrics_origin_la_bi_tu_choi(self):
        self.assertFalse(lic.evaluate(valid_record(lyrics_origin="dau do")).ok)


JW_HTML = """
<html><head>
<script type="application/ld+json">
{"@context":"https://schema.org","@type":"MusicComposition",
 "name":"The Simple Life","composer":{"@type":"Person","name":"Josh Woodward"},
 "duration":"PT3M34S",
 "lyrics":{"@type":"CreativeWork","text":"[Verse 1]\\nCold hands, sore feet\\nYou've been walking\\n\\nDon't close your eyes"}}
</script></head>
<body><a href="https://www.joshwoodward.com/audio/x.mp3">download</a></body></html>
"""

FMA_HTML = """
<html><head><title>Some Song | Free Music Archive</title></head>
<body><a href="https://creativecommons.org/licenses/by/4.0/">CC BY 4.0</a>
<a href="https://files.freemusicarchive.org/x.mp3">mp3</a></body></html>
"""

FMA_NC_HTML = FMA_HTML.replace("licenses/by/4.0", "licenses/by-nc/4.0")

CCMIXTER_HTML = """
<html><head><title>A Remix | ccMixter</title></head>
<body><a href="http://ccmixter.org/people/someone">someone</a>
<a href="https://creativecommons.org/licenses/by/3.0/">CC BY 3.0</a>
<div>sources</div>
<a href="http://ccmixter.org/files/singer/9911">original pella</a>
<a href="http://ccmixter.org/files/other/2201">another sample</a>
<a href="https://ccmixter.org/x.mp3">mp3</a></body></html>
"""


class TestJoshWoodwardSource(unittest.TestCase):
    def setUp(self):
        self.draft = src.SOURCES["joshwoodward"].parse(JW_HTML, "TheSimpleLife")

    def test_doc_duoc_metadata_va_loi(self):
        self.assertEqual(self.draft["title"], "The Simple Life")
        self.assertEqual(self.draft["artist"], "Josh Woodward")
        self.assertEqual(self.draft["duration"], "3:34")
        self.assertEqual(
            self.draft["lines"],
            ["Cold hands, sore feet", "You've been walking", "Don't close your eyes"],
        )

    def test_bo_dong_danh_dau_cau_truc(self):
        self.assertNotIn("[Verse 1]", self.draft["lines"])

    def test_khai_bao_ca_2_phan_va_ghi_ly_do_so_huu(self):
        licenses = self.draft["license"]
        self.assertEqual(licenses["recording"]["license_id"], "CC-BY-4.0")
        self.assertEqual(licenses["lyrics"]["license_id"], "CC-BY-4.0")
        self.assertIn("tu viet", licenses["lyrics"]["note"])

    def test_ban_ghi_sinh_ra_qua_duoc_cong_gac(self):
        record = valid_record(**self.draft)
        record["lines"] = [{"en": line, "vi": "x"} for line in self.draft["lines"]]
        self.assertTrue(lic.evaluate(record).ok)


class TestFmaSource(unittest.TestCase):
    def test_lay_giay_phep_ban_thu_tu_link_deed(self):
        draft = src.SOURCES["fma"].parse(FMA_HTML, "https://fma.test/t")
        self.assertEqual(draft["license"]["recording"]["license_id"], "CC-BY-4.0")

    def test_KHONG_suy_giay_phep_phan_loi(self):
        """FMA khong cho biet ai giu ban quyen phan loi -> phai de trong."""
        draft = src.SOURCES["fma"].parse(FMA_HTML, "https://fma.test/t")
        self.assertEqual(draft["license"]["lyrics"]["license_id"], "")
        self.assertEqual(draft["lyrics_origin"], lic.ASR_ORIGIN)

    def test_ban_ghi_fma_bi_chan_cho_toi_khi_nguoi_dien_phan_loi(self):
        draft = src.SOURCES["fma"].parse(FMA_HTML, "https://fma.test/t")
        record = valid_record(**draft)
        self.assertFalse(lic.evaluate(record).ok)

    def test_track_nc_bi_bat(self):
        draft = src.SOURCES["fma"].parse(FMA_NC_HTML, "https://fma.test/t")
        self.assertEqual(draft["license"]["recording"]["license_id"], "CC-BY-NC-4.0")
        self.assertFalse(lic.evaluate(valid_record(**draft)).ok)


class TestCcMixterSource(unittest.TestCase):
    def setUp(self):
        self.draft = src.SOURCES["ccmixter"].parse(CCMIXTER_HTML, "https://cc.test/t")

    def test_bat_duoc_chuoi_nguon_goc(self):
        self.assertEqual(
            self.draft["unresolved_sources"],
            [
                "http://ccmixter.org/files/singer/9911",
                "http://ccmixter.org/files/other/2201",
            ],
        )

    def test_bi_tu_choi_khi_chua_truy_xong_nguon(self):
        record = valid_record(**self.draft)
        self.assertFalse(lic.evaluate(record).ok)


class TestDartGeneration(unittest.TestCase):
    def test_escape_dau_nhay_gach_cheo_va_dola(self):
        # `$` mo noi suy chuoi trong Dart - khong escape la vo file.
        self.assertEqual(add_songs.dart_string("It's a $5 bill"), '"It\'s a \\$5 bill"')
        self.assertEqual(add_songs.dart_string('say "hi"'), "'say \"hi\"'")
        self.assertEqual(add_songs.dart_string("back\\slash"), "'back\\\\slash'")
        self.assertEqual(
            add_songs.dart_string("both ' and \""), "'both \\' and \"'"
        )

    def test_slugify(self):
        self.assertEqual(add_songs.slugify("Don't Close Your Eyes"), "dont-close-your-eyes")
        self.assertEqual(add_songs.slugify("Café  Del  Mar!"), "cafe-del-mar")

    def test_chen_dung_truoc_dau_dong_danh_sach(self):
        dart = "const kSongs = [\n  Song(\n    title: 'A',\n  ),\n];\n"
        out = add_songs.insert_into_dart(dart, valid_record())
        self.assertTrue(out.rstrip().endswith("];"))
        self.assertIn("title: 'A Song',", out)
        self.assertIn("audioUrl: '${_audioBaseUrl}a-song.mp3',", out)
        self.assertIn("LyricLine(0, 'line 0', 'dòng 0'),", out)


class TestContentGate(unittest.TestCase):
    def test_track_instrumental_bi_tu_choi(self):
        problems = add_songs.content_problems(valid_record(instrumental=True))
        self.assertTrue(any("instrumental" in p for p in problems))

    def test_qua_it_dong_loi_bi_tu_choi(self):
        record = valid_record(lines=[{"en": "a", "vi": "a"}])
        self.assertTrue(any("dong loi" in p for p in add_songs.content_problems(record)))

    def test_level_va_color_phai_thuoc_design_system(self):
        self.assertTrue(add_songs.content_problems(valid_record(level="Sieu cap")))
        self.assertTrue(add_songs.content_problems(valid_record(color="chartreuse")))

    def test_dem_dung_dong_chua_dich(self):
        record = valid_record()
        record["lines"][1]["vi"] = "   "
        self.assertEqual(add_songs.untranslated_lines(record), [2])


class TestAttribution(unittest.TestCase):
    def test_ghi_rieng_giay_phep_2_phan(self):
        out = add_songs.append_attribution("# Ghi công\n", valid_record())
        self.assertIn("Bản thu", out)
        self.assertIn("Phần lời", out)
        self.assertIn(add_songs.ATTRIBUTION_BEGIN, out)
        self.assertIn("A Song — An Artist", out)

    def test_them_bai_thu_hai_van_nam_trong_khoi(self):
        out = add_songs.append_attribution("# Ghi công\n", valid_record())
        out = add_songs.append_attribution(out, valid_record(title="Another"))
        begin = out.index(add_songs.ATTRIBUTION_BEGIN)
        end = out.index(add_songs.ATTRIBUTION_END)
        self.assertIn("Another", out[begin:end])
        self.assertEqual(out.count(add_songs.ATTRIBUTION_BEGIN), 1)


class TestEmitEndToEnd(unittest.TestCase):
    def setUp(self):
        # Tro PENDING_DIR vao thu muc tam de test khong ghi gi vao repo.
        self._tmp = tempfile.TemporaryDirectory()
        self.tmp = Path(self._tmp.name)
        self._real_pending = add_songs.PENDING_DIR
        add_songs.PENDING_DIR = self.tmp / "pending"
        add_songs.PENDING_DIR.mkdir()

    def tearDown(self):
        add_songs.PENDING_DIR = self._real_pending
        self._tmp.cleanup()

    def test_emit_chan_bai_thieu_giay_phep_phan_loi(self):
        record = valid_record(slug="zz-emit-block")
        record["license"]["lyrics"]["license_id"] = ""
        self._write_pending(record)
        code = self._emit(self.tmp, ["zz-emit-block"])
        self.assertEqual(code, 1)
        self.assertNotIn("A Song", (self.tmp / "songs.dart").read_text())

    def test_emit_ghi_ca_dart_lan_attribution(self):
        self._write_pending(valid_record(slug="zz-emit-ok"))
        code = self._emit(self.tmp, ["zz-emit-ok"])
        self.assertEqual(code, 0)
        self.assertIn("title: 'A Song',", (self.tmp / "songs.dart").read_text())
        self.assertIn("Bản thu", (self.tmp / "attr.md").read_text())

    def _write_pending(self, record):
        add_songs.pending_path(record["slug"]).write_text(
            json.dumps(record, ensure_ascii=False), encoding="utf-8"
        )

    def _emit(self, tmp, slugs):
        (tmp / "songs.dart").write_text("const kSongs = [\n];\n", encoding="utf-8")
        (tmp / "attr.md").write_text("# Ghi công\n", encoding="utf-8")
        args = argparse_ns(
            slugs=slugs,
            allow_share_alike=False,
            skip_audio_check=True,
            dart_file=str(tmp / "songs.dart"),
            attribution_file=str(tmp / "attr.md"),
        )
        return add_songs.cmd_emit(args)


class argparse_ns:
    def __init__(self, **kwargs):
        self.__dict__.update(kwargs)


if __name__ == "__main__":
    unittest.main()
