/// Ghi lai ket qua that su cua JustAudioBackground.init() (thanh cong/loi gi)
/// de hien cho nguoi dung xem duoc (man Ho so) - TAM THOI dung de chan doan
/// tai sao thong bao "dang phat nhac"/dieu khien tai nghe Bluetooth khong
/// hoat dong tren 1 so may cu the, khi khong the xem log thiet bi that
/// (logcat/adb). Xoa di sau khi da xac dinh duoc nguyen nhan goc.
class AudioServiceDiagnostics {
  AudioServiceDiagnostics._();

  static bool? succeeded;
  static String? errorMessage;

  static void recordSuccess() {
    succeeded = true;
    errorMessage = null;
  }

  static void recordFailure(Object error) {
    succeeded = false;
    errorMessage = error.toString();
  }
}
