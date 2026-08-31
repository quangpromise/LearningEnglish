# Cac plugin Flutter (speech_to_text, flutter_tts, supabase_flutter...) da tu
# kem theo consumer proguard rules rieng trong file .aar cua ho, nen thuong
# khong can khai bao gi them o day. Neu sau nay gap crash chi xay ra o ban
# release (khong xay ra o debug), thu them "-keep class <ten class loi> { *; }"
# tuong ung truoc khi build lai.

# audio_service (dung boi just_audio_background) KHONG kem theo consumer
# proguard rules rieng - Service/Receiver cua no chi duoc tham chieu qua ten
# trong AndroidManifest.xml (Android goi qua reflection luc chay), khong co
# tham chieu truc tiep tu code Kotlin/Java nao trong app. Neu R8 xoa/doi ten
# cac class nay (minifyEnabled=true), foreground service khong bao gio bind
# duoc, khien JustAudioBackground.init() cho vo han va ca app dung yen mai o
# man hinh splash (da xay ra that tren may thuc voi bug nay) - giu nguyen
# toan bo cac class lien quan de tranh loi nay.
-keep class com.ryanheise.audioservice.** { *; }
-keep class androidx.media.** { *; }
-keep class android.support.v4.media.** { *; }
