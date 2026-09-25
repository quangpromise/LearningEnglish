/// Cac cong tac san pham GymTalk.
///
/// Hien khu Quan ly tai san (Wealth: vi, crypto, chia bill...) trong nut
/// chuyen app. GymTalk tap trung "tap gym + hoc tieng Anh" nen MAC DINH AN
/// (xem docs/gymtalk-phase4-6.md) - code Wealth van giu nguyen, doi thanh
/// true la hien lai.
const kShowWealthSection = false;

/// Ban redesign UI (docs/design/gymtalk-redesign/, spec #70): shell + 4 tab
/// + man tap/on the/onboarding moi. Moi ticket merge vao main SAU co nay;
/// ticket cuoi (#81) bat co va xoa man cu (ADR-0004).
const kUseRedesign = false;

/// Cho nguoi dung chon giao dien sang. Token light da co (GtTokens.light)
/// nhung KHOA cho toi khi moi man cu bo mau toi hard-code (ADR-0004).
const kEnableLightTheme = false;
