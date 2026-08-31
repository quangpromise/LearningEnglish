"""
Cac adapter nguon nhac cho pipeline them bai hat.

Moi adapter chia lam 2 phan co chu dich:
  - `parse(html, ref)` — THUAN TUY, khong dung mang, nen test duoc bang
    fixture HTML (xem scripts/test_add_songs.py)
  - `fetch(ref)` — lop mong goi mang roi giao cho `parse`

Adapter TU KHAI BAO duoc bao nhieu thi khai bay nhieu, khong doan. Cho nao
adapter khong the tu biet (dien hinh: giay phep PHAN LOI tren nen tang
nhieu nghe si) thi de trong de cong gac trong song_licensing.py chan lai va
bat nguoi thuc hien tu xac minh.
"""

import json
import re
import urllib.request

from song_licensing import ASR_ORIGIN, license_from_url

USER_AGENT = "Mozilla/5.0 (compatible; LearningEnglish-song-importer/1.0)"


def http_get(url: str) -> bytes:
    req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    with urllib.request.urlopen(req, timeout=60) as resp:
        return resp.read()


def http_get_text(url: str) -> str:
    return http_get(url).decode("utf-8", errors="replace")


# ---------------------------------------------------------------------------
# Tien ich phan tich HTML dung chung
# ---------------------------------------------------------------------------


def strip_tags(text: str) -> str:
    text = re.sub(r"<[^>]+>", "", text)
    return (
        text.replace("&amp;", "&")
        .replace("&#39;", "'")
        .replace("&quot;", '"')
        .replace("&nbsp;", " ")
        .replace("&lt;", "<")
        .replace("&gt;", ">")
        .strip()
    )


def iter_jsonld(html: str):
    """Duyet moi node JSON-LD tren trang (object, mang, hoac boc @graph)."""
    for m in re.finditer(
        r'<script[^>]+type=["\']application/ld\+json["\'][^>]*>(.*?)</script>',
        html,
        re.DOTALL | re.IGNORECASE,
    ):
        try:
            data = json.loads(m.group(1))
        except json.JSONDecodeError:
            continue
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
    if isinstance(value, str):
        return value
    if isinstance(value, dict):
        for key in ("text", "name", "@value"):
            if isinstance(value.get(key), str):
                return value[key]
    if isinstance(value, list) and value:
        return as_text(value[0])
    return ""


def parse_iso_duration(value: str) -> str:
    """'PT3M34S' -> '3:34'."""
    m = re.match(r"^PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?$", value or "")
    if not m:
        return ""
    hours, minutes, seconds = (int(g or 0) for g in m.groups())
    return f"{minutes + hours * 60}:{seconds:02d}"


def find_cc_license(html: str):
    """Tim link deed Creative Commons dau tien tren trang -> (id, url).

    Dua vao link deed chu khong dua vao chu hien tren trang: nhan chu
    ("Attribution") khong phan biet duoc CC-BY voi CC-BY-NC, con link deed
    thi phan biet duoc.
    """
    for m in re.finditer(r'https?://creativecommons\.org/[^\s"\'<>]+', html):
        url = m.group(0).rstrip(".,")
        license_id = license_from_url(url)
        if license_id:
            return license_id, url
    return None, ""


def split_lyric_lines(raw: str) -> list:
    lines = []
    for line in re.split(r"(?:\r?\n|<br\s*/?>)+", raw or ""):
        line = strip_tags(line)
        # Bo dong danh dau cau truc bai ([Chorus], [Verse 2]...) - khong phai
        # loi hat nen khong hien len man hinh.
        if not line or re.fullmatch(r"[\[(].*[\])]", line):
            continue
        lines.append(line)
    return lines


# ---------------------------------------------------------------------------
# Adapter
# ---------------------------------------------------------------------------


class Source:
    """Giao dien chung cho moi nguon nhac."""

    name = ""
    #: Mo ta ngan hien trong `add_songs.py list-sources`
    summary = ""
    #: `ref` nguoi dung truyen vao trong nghia la gi
    ref_help = ""

    def page_url(self, ref: str) -> str:
        raise NotImplementedError

    def parse(self, html: str, ref: str) -> dict:
        raise NotImplementedError

    def fetch(self, ref: str) -> dict:
        url = self.page_url(ref)
        print(f"  [GET] {url}", flush=True)
        return self.parse(http_get_text(url), ref)


class JoshWoodwardSource(Source):
    """joshwoodward.com — ca si tu sang tac, tu thu, tu so huu TOAN BO.

    Day la ly do duy nhat khien adapter nay duoc phep tu dien giay phep cho
    CA phan loi: khi mot nguoi vua viet loi vua thu am vua giu ban quyen,
    giay phep CC 4.0 anh dat len tac pham se bao trum ca hai phan (CC 4.0
    noi ro ap dung cho moi quyen tac gia va quyen lien quan).

    Voi nen tang nhieu nghe si thi KHONG duoc lam vay - xem FmaSource.
    """

    name = "joshwoodward"
    summary = "joshwoodward.com — 200+ bai CC-BY 4.0, co san loi tren trang"
    ref_help = "slug trang bai hat, vd TheSimpleLife"

    LICENSE_PAGE = "https://www.joshwoodward.com/licenses"
    OWNERSHIP_NOTE = (
        "Josh Woodward tu viet loi + tu thu am + tu giu ban quyen ca hai phan, "
        "phat hanh toan bo catalog duoi CC-BY 4.0 (xem trang licenses)"
    )

    def page_url(self, ref):
        return f"https://www.joshwoodward.com/song/{ref}"

    def parse(self, html, ref):
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
            found = re.findall(r'href=["\']([^"\']+\.mp3)["\']', html)
            if len(found) == 1:
                audio_url = found[0]

        page = self.page_url(ref)
        claim = {
            "license_id": "CC-BY-4.0",
            "evidence_url": self.LICENSE_PAGE,
            "verified_by": "adapter",
        }
        lines = split_lyric_lines(lyrics)
        return {
            "title": title,
            "artist": artist or "Josh Woodward",
            "duration": duration,
            "audio_url": audio_url,
            "lines": lines,
            "lyrics_origin": "publisher-page",
            "instrumental": not lines,
            "source": {"adapter": self.name, "page_url": page, "ref": ref},
            "license": {
                "recording": dict(claim),
                # Ghi ro ly do duoc dung chung giay phep - neu de trong,
                # song_licensing.evaluate() se canh bao.
                "lyrics": dict(claim, note=self.OWNERSHIP_NOTE),
            },
        }


class FmaSource(Source):
    """Free Music Archive — nhieu nghe si, giay phep khac nhau tung track.

    Adapter chi doc duoc giay phep BAN THU tu link deed CC tren trang. FMA
    khong dang loi bai hat, va khong noi ai giu ban quyen phan loi -> de
    trong phan `license.lyrics` de nguoi thuc hien tu xac minh.
    """

    name = "fma"
    summary = "freemusicarchive.org — loc CC-BY/CC-BY-SA, KHONG co san loi"
    ref_help = "URL day du cua trang track"

    def page_url(self, ref):
        return ref

    def parse(self, html, ref):
        license_id, license_url = find_cc_license(html)
        title = ""
        artist = ""
        for node in iter_jsonld(html):
            title = title or as_text(node.get("name"))
            artist = artist or as_text(node.get("byArtist") or node.get("author"))
        if not title:
            m = re.search(r"<title[^>]*>(.*?)</title>", html, re.DOTALL | re.I)
            if m:
                title = strip_tags(m.group(1)).split("|")[0].strip()

        audio_url = ""
        found = re.findall(r'https?://[^\s"\'<>]+\.mp3', html)
        if found:
            audio_url = found[0]

        return {
            "title": title,
            "artist": artist,
            "duration": "",
            "audio_url": audio_url,
            "lines": [],
            # FMA khong dang loi -> phai chep tu ban thu bang ASR, ma do la
            # phai sinh cua PHAN LOI nen cong gac se doi nguoi xac minh.
            "lyrics_origin": ASR_ORIGIN,
            "instrumental": bool(re.search(r"\binstrumental\b", html, re.I)),
            "source": {"adapter": self.name, "page_url": ref, "ref": ref},
            "license": {
                "recording": {
                    "license_id": license_id or "",
                    "evidence_url": license_url or ref,
                    "verified_by": "adapter" if license_id else "",
                },
                # CO Y DE TRONG. FMA khong cho biet ai giu ban quyen phan
                # loi. Nguoi thuc hien phai mo trang nghe si, xac nhan ho tu
                # viet + tu so huu, roi dien tay.
                "lyrics": {
                    "license_id": "",
                    "evidence_url": "",
                    "verified_by": "",
                    "note": "",
                },
            },
        }


class CcMixterSource(Source):
    """ccMixter — nen tang REMIX, nen day dung la cho cai bay §2 hay xay ra.

    Rat nhieu track la remix dung acapella cua nguoi khac. Giay phep hien
    tren trang la cua BAN REMIX, khong phai cua phan loi goc. Adapter co
    gang bat danh sach nguon goc va day vao `unresolved_sources` de cong
    gac tu choi cho toi khi co nguoi truy xong chuoi nguon.
    """

    name = "ccmixter"
    summary = "ccmixter.org — ~4.200 track CC-BY, NHUNG la nen tang remix"
    ref_help = "URL day du cua trang track"

    def page_url(self, ref):
        return ref

    def parse(self, html, ref):
        license_id, license_url = find_cc_license(html)
        title = ""
        m = re.search(r"<title[^>]*>(.*?)</title>", html, re.DOTALL | re.I)
        if m:
            title = strip_tags(m.group(1)).split("|")[0].strip()
        artist = ""
        m = re.search(r'/people/([A-Za-z0-9_%-]+)', html)
        if m:
            artist = m.group(1).replace("_", " ")

        # Track co dung nguyen lieu cua nguoi khac: moi link toi 1 track khac
        # trong phan "sources"/"samples" deu la 1 chuoi ban quyen phai truy.
        unresolved = []
        block = re.search(
            r"(?is)>\s*(?:sources?|samples?|uses samples from)\s*<.{0,4000}",
            html,
        )
        if block:
            for link in re.findall(
                r'href=["\'](https?://(?:dig\.)?ccmixter\.org/files/[^"\']+)["\']',
                block.group(0),
            ):
                if link not in unresolved:
                    unresolved.append(link)

        audio_url = ""
        found = re.findall(r'https?://[^\s"\'<>]+\.mp3', html)
        if found:
            audio_url = found[0]

        return {
            "title": title,
            "artist": artist,
            "duration": "",
            "audio_url": audio_url,
            "lines": [],
            "lyrics_origin": ASR_ORIGIN,
            "instrumental": bool(re.search(r"\binstrumental\b", html, re.I)),
            "source": {"adapter": self.name, "page_url": ref, "ref": ref},
            "unresolved_sources": unresolved,
            "license": {
                "recording": {
                    "license_id": license_id or "",
                    "evidence_url": license_url or ref,
                    "verified_by": "adapter" if license_id else "",
                },
                "lyrics": {
                    "license_id": "",
                    "evidence_url": "",
                    "verified_by": "",
                    "note": "",
                },
            },
        }


class ManualSource(Source):
    """Nguon tu nhap — dung khi da tu tay xac minh moi thu.

    Khong goi mang, khong doan gi ca: nguoi thuc hien dien het vao file
    pending roi chay `verify`. Cong gac van chan y het cac nguon khac.
    """

    name = "manual"
    summary = "tu nhap tay — dung khi da tu xac minh giay phep ca 2 phan"
    ref_help = "ten slug se dat cho bai hat"

    def page_url(self, ref):
        return ""

    def parse(self, html, ref):
        return self._blank(ref)

    def fetch(self, ref):
        return self._blank(ref)

    def _blank(self, ref):
        empty = {
            "license_id": "",
            "evidence_url": "",
            "verified_by": "human",
            "note": "",
        }
        return {
            "title": "",
            "artist": "",
            "duration": "",
            "audio_url": "",
            "lines": [],
            "lyrics_origin": "manual",
            "instrumental": False,
            "source": {"adapter": self.name, "page_url": "", "ref": ref},
            "license": {"recording": dict(empty), "lyrics": dict(empty)},
        }


SOURCES = {
    s.name: s
    for s in [
        JoshWoodwardSource(),
        FmaSource(),
        CcMixterSource(),
        ManualSource(),
    ]
}
