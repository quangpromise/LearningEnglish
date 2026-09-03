package com.learnenglishmusic.learn_english_music

import com.ryanheise.audioservice.AudioServiceActivity

// audio_service (dung boi just_audio_background - xem now_playing_service.dart)
// BAT BUOC Activity phai cung cap dung FlutterEngine da duoc AudioServicePlugin
// giu (qua AudioServicePlugin.getFlutterEngine()) khi ket noi lai UI voi
// background service - doi FlutterActivity mac dinh sang FlutterFragmentActivity
// o lan sua truoc CHUA DU (van thieu buoc override provideFlutterEngine() theo
// dung tai lieu chinh thuc cua audio_service), nen loi
// "PlatformException(The Activity class declared in your AndroidManifest.xml
// is wrong or has not provided the correct FlutterEngine...)" van con nguyen,
// just_audio_background van roi ve che do du phong khong co MediaSession -
// day la nguyen nhan nut Next/Previous tren tai nghe Bluetooth (va thong
// bao/man hinh khoa) khong hoat dong du phat nhac binh thuong trong app.
//
// Fix DUNG theo tai lieu + DA DOC TRUC TIEP source code audio_service
// 0.18.19 (AudioServiceActivity.java trong pub-cache) de xac nhan: ke thua
// thang AudioServiceActivity - class nay da tu FlutterActivity +
// override san provideFlutterEngine() tra ve
// AudioServicePlugin.getFlutterEngine(context), dung 1:1 nhu tai lieu yeu
// cau, khong can tu viet lai gi them.
class MainActivity : AudioServiceActivity()
