"""
Cong gac ban quyen cho pipeline them bai hat (scripts/add_songs.py).

Nguyen tac trung tam - xem docs/research-music-libraries.md §2:

    MOT BAI HAT CO HAI BAN QUYEN TACH ROI
      - ban thu (sound recording)
      - tac pham goc: giai dieu + LOI (musical composition)

    Giay phep CC dan tren 1 track chi bao trum phan NGUOI DANG THUC SU SO
    HUU. Mot nguoi remix dang ban thu cua ho duoi CC-BY nhung loi do nguoi
    khac viet -> CC-BY do KHONG cho ta quyen voi loi bai hat.

App nay dung phan LOI nhieu hon phan nhac (hien thi, dich, cham phat am,
giai thich ngu phap), va viec dich + can gio LA tao tac pham phai sinh.
Nen module nay bat buoc khai bao license RIENG cho tung phan, va tu choi
moi track khong chung minh duoc ca hai.

Quy tac vang: KHONG RO = TU CHOI. Khong co "chac la duoc".
"""

import re
from dataclasses import dataclass, field


@dataclass(frozen=True)
class LicenseTerms:
    """Nhung gi 1 giay phep cho phep, quy ve dung 3 cau hoi app can tra loi."""

    id: str
    name: str
    url: str
    #: Duoc dung cho muc dich thuong mai khong?
    commercial: bool
    #: Duoc tao tac pham phai sinh khong? (dich + can gio = phai sinh)
    derivatives: bool
    #: Phai phat hanh lai ban phai sinh duoi cung giay phep khong?
    share_alike: bool
    #: Bat buoc ghi cong khong?
    attribution: bool


def _cc(id_, name, url, commercial, derivatives, share_alike):
    return LicenseTerms(id_, name, url, commercial, derivatives, share_alike, True)


KNOWN_LICENSES = {
    lic.id: lic
    for lic in [
        LicenseTerms(
            "CC0-1.0",
            "CC0 1.0 Universal",
            "https://creativecommons.org/publicdomain/zero/1.0/",
            commercial=True,
            derivatives=True,
            share_alike=False,
            attribution=False,
        ),
        LicenseTerms(
            "public-domain",
            "Public domain",
            "",
            commercial=True,
            derivatives=True,
            share_alike=False,
            attribution=False,
        ),
        _cc("CC-BY-3.0", "CC Attribution 3.0",
            "https://creativecommons.org/licenses/by/3.0/", True, True, False),
        _cc("CC-BY-4.0", "CC Attribution 4.0",
            "https://creativecommons.org/licenses/by/4.0/", True, True, False),
        _cc("CC-BY-SA-3.0", "CC Attribution-ShareAlike 3.0",
            "https://creativecommons.org/licenses/by-sa/3.0/", True, True, True),
        _cc("CC-BY-SA-4.0", "CC Attribution-ShareAlike 4.0",
            "https://creativecommons.org/licenses/by-sa/4.0/", True, True, True),
        # Cac giay phep duoi day KHONG dung duoc - giu trong bang de bao loi
        # cho ro ("track nay la CC-BY-NC nen bi tu choi") thay vi bao chung
        # chung la "khong biet giay phep gi".
        _cc("CC-BY-NC-3.0", "CC Attribution-NonCommercial 3.0",
            "https://creativecommons.org/licenses/by-nc/3.0/", False, True, False),
        _cc("CC-BY-NC-4.0", "CC Attribution-NonCommercial 4.0",
            "https://creativecommons.org/licenses/by-nc/4.0/", False, True, False),
        _cc("CC-BY-ND-3.0", "CC Attribution-NoDerivatives 3.0",
            "https://creativecommons.org/licenses/by-nd/3.0/", True, False, False),
        _cc("CC-BY-ND-4.0", "CC Attribution-NoDerivatives 4.0",
            "https://creativecommons.org/licenses/by-nd/4.0/", True, False, False),
        _cc("CC-BY-NC-SA-3.0", "CC Attribution-NonCommercial-ShareAlike 3.0",
            "https://creativecommons.org/licenses/by-nc-sa/3.0/", False, True, True),
        _cc("CC-BY-NC-SA-4.0", "CC Attribution-NonCommercial-ShareAlike 4.0",
            "https://creativecommons.org/licenses/by-nc-sa/4.0/", False, True, True),
        _cc("CC-BY-NC-ND-3.0", "CC Attribution-NonCommercial-NoDerivatives 3.0",
            "https://creativecommons.org/licenses/by-nc-nd/3.0/", False, False, False),
        _cc("CC-BY-NC-ND-4.0", "CC Attribution-NonCommercial-NoDerivatives 4.0",
            "https://creativecommons.org/licenses/by-nc-nd/4.0/", False, False, False),
    ]
}

#: Giay phep ho stock-media (Pixabay, Pexels...) - cam phan phoi content
#: "standalone", ma app nay giao nguyen file mp3 cho nguoi dung nghe. Xem
#: docs/research-music-libraries.md §6. De trong bang de bao loi dung ly do.
STOCK_MEDIA_LICENSES = {
    "pixabay": "Pixabay Content License",
    "pexels": "Pexels License",
    "unsplash": "Unsplash License",
    "mixkit": "Mixkit License",
}

_CC_URL_RE = re.compile(
    r"creativecommons\.org/(?:licenses/(?P<code>[a-z-]+)/(?P<ver>\d(?:\.\d)?)"
    r"|(?P<zero>publicdomain/zero/1\.0))",
    re.IGNORECASE,
)


def license_from_url(url: str):
    """Doi link deed Creative Commons thanh id trong [KNOWN_LICENSES].

    Dung khi doc trang track cua FMA/ccMixter: cac trang do link thang toi
    deed CC, nen day la cach xac dinh giay phep dang tin cay nhat - dua vao
    chu hien tren trang ("Attribution") thi de nham lan giua cac bien the.
    """
    if not url:
        return None
    m = _CC_URL_RE.search(url)
    if not m:
        return None
    if m.group("zero"):
        return "CC0-1.0"
    code = m.group("code").lower()
    version = m.group("ver")
    if "." not in version:
        version = f"{version}.0"
    candidate = f"CC-{code.upper()}-{version}"
    return candidate if candidate in KNOWN_LICENSES else None


@dataclass
class LicenseClaim:
    """Khai bao giay phep cho MOT phan cua bai hat (ban thu HOAC phan loi).

    `evidence_url` la trang thuc te chung minh giay phep do - bat buoc co,
    vi 6 thang sau khong ai nho duoc "hoi do doc o dau ra".
    """

    license_id: str = ""
    evidence_url: str = ""
    #: "adapter" = doc tu dong tu trang nguon;
    #: "human"   = nguoi thuc hien tu doc trang goc va khang dinh.
    verified_by: str = ""
    note: str = ""

    @property
    def terms(self):
        return KNOWN_LICENSES.get(self.license_id)

    @classmethod
    def from_dict(cls, data):
        data = data or {}
        return cls(
            license_id=data.get("license_id", ""),
            evidence_url=data.get("evidence_url", ""),
            verified_by=data.get("verified_by", ""),
            note=data.get("note", ""),
        )

    def to_dict(self):
        return {
            "license_id": self.license_id,
            "evidence_url": self.evidence_url,
            "verified_by": self.verified_by,
            "note": self.note,
        }


@dataclass
class LicenseReport:
    errors: list = field(default_factory=list)
    warnings: list = field(default_factory=list)
    obligations: list = field(default_factory=list)

    @property
    def ok(self):
        return not self.errors


VALID_VERIFIERS = ("adapter", "human")

#: Loi duoc chep bang ASR tu chinh ban thu = tao phai sinh cua PHAN LOI.
#: Khi do giay phep phan loi phai duoc NGUOI kiem, khong nhan tu dong tu
#: giay phep ban thu (day dung la cai bay o §2).
ASR_ORIGIN = "asr-transcript"
LYRICS_ORIGINS = (ASR_ORIGIN, "publisher-page", "manual")


def _check_part(report, part_name, claim, allow_share_alike):
    label = "ban thu" if part_name == "recording" else "phan loi"

    if not claim.license_id:
        report.errors.append(
            f"{label}: chua khai bao giay phep. KHONG RO = TU CHOI "
            f"(docs/research-music-libraries.md §2)"
        )
        return
    if claim.license_id in STOCK_MEDIA_LICENSES:
        report.errors.append(
            f"{label}: '{STOCK_MEDIA_LICENSES[claim.license_id]}' cam phan phoi "
            f"content standalone, ma app nay giao nguyen file cho nguoi nghe (§6)"
        )
        return

    terms = claim.terms
    if terms is None:
        report.errors.append(
            f"{label}: giay phep '{claim.license_id}' khong nam trong danh sach "
            f"da tham dinh. Neu that su dung duoc, them vao KNOWN_LICENSES "
            f"kem ly do thay vi bo qua kiem tra"
        )
        return

    if not terms.commercial:
        report.errors.append(
            f"{label}: {terms.name} cam dung thuong mai (NC)"
        )
    if not terms.derivatives:
        report.errors.append(
            f"{label}: {terms.name} cam tao phai sinh (ND) - ma dich sang "
            f"tieng Viet + can gio chinh la tao phai sinh"
        )
    if terms.share_alike:
        if allow_share_alike:
            report.obligations.append(
                f"{label}: {terms.name} co dieu kien ShareAlike - phan lyrics "
                f"Anh-Viet da dich + can gio cua bai nay phai duoc phat hanh "
                f"lai duoi chinh {terms.id} (§5)"
            )
        else:
            report.errors.append(
                f"{label}: {terms.name} co dieu kien ShareAlike. Can quyet dinh "
                f"o cap du an truoc (§5); neu da dong y thi chay lai voi "
                f"--allow-share-alike"
            )
    if terms.attribution:
        report.obligations.append(
            f"{label}: {terms.name} bat buoc ghi cong - phai co du TASL trong "
            f"ATTRIBUTION.md"
        )

    if not claim.evidence_url:
        report.errors.append(
            f"{label}: thieu evidence_url (trang chung minh giay phep)"
        )
    if claim.verified_by not in VALID_VERIFIERS:
        report.errors.append(
            f"{label}: verified_by phai la 1 trong {VALID_VERIFIERS}, "
            f"dang la '{claim.verified_by}'"
        )


def evaluate(record, allow_share_alike=False):
    """Cham 1 ban ghi bai hat. Tra ve [LicenseReport]; `ok` = duoc phep them."""
    report = LicenseReport()
    licenses = record.get("license") or {}
    recording = LicenseClaim.from_dict(licenses.get("recording"))
    lyrics = LicenseClaim.from_dict(licenses.get("lyrics"))

    _check_part(report, "recording", recording, allow_share_alike)
    _check_part(report, "lyrics", lyrics, allow_share_alike)

    # Cai bay chinh: giay phep ban thu KHONG tu dong bao trum phan loi.
    # Neu 2 ben trung id nhung phan loi lai duoc suy ra tu dong, bat nguoi
    # xac nhan - chi dung khi nguoi dang tu viet + tu thu + tu so huu.
    if (
        lyrics.license_id
        and lyrics.license_id == recording.license_id
        and lyrics.verified_by == "adapter"
        and not lyrics.note
    ):
        report.warnings.append(
            "phan loi dang dung chung giay phep voi ban thu ma khong ghi ly do "
            "- chi hop le khi tac gia tu viet + tu thu + tu so huu toan bo. "
            "Ghi ro dieu do vao license.lyrics.note"
        )

    origin = record.get("lyrics_origin", "")
    if origin not in LYRICS_ORIGINS:
        report.errors.append(
            f"lyrics_origin phai la 1 trong {LYRICS_ORIGINS}, dang la '{origin}'"
        )
    elif origin == ASR_ORIGIN and lyrics.verified_by != "human":
        report.errors.append(
            "loi duoc chep bang ASR tu ban thu -> day la phai sinh cua PHAN LOI, "
            "nen giay phep phan loi phai co nguoi kiem "
            "(license.lyrics.verified_by = 'human')"
        )

    for source in record.get("unresolved_sources") or []:
        report.errors.append(
            f"track co nguon goc chua truy duoc: {source}. Voi nen tang remix, "
            f"phai kiem giay phep cua ban goc roi ghi vao license.lyrics (§2)"
        )

    return report
