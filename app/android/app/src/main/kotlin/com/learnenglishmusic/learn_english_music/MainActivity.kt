package com.learnenglishmusic.learn_english_music

import io.flutter.embedding.android.FlutterFragmentActivity

// audio_service (dung boi just_audio_background - xem now_playing_service.dart)
// BAT BUOC Activity ke thua FlutterFragmentActivity, khong phai FlutterActivity
// mac dinh - neu khong, plugin khong lay duoc dung FlutterEngine khi ket noi
// lai UI voi background service, nem loi
// "PlatformException(The Activity class declared in your AndroidManifest.xml
// is wrong or has not provided the correct FlutterEngine...)" MOI LAN, khien
// just_audio_background luon khoi tao that bai va roi ve che do du phong
// khong co MediaSession - day chinh la nguyen nhan nut Next/Previous tren tai
// nghe Bluetooth (va thong bao/man hinh khoa) khong hoat dong du phat nhac
// binh thuong trong app.
class MainActivity : FlutterFragmentActivity()
