package com.learnenglishmusic.learn_english_music

import android.app.KeyguardManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

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
//
// Hien TREN man hinh khoa: TRUOC DAY gan co dinh android:showWhenLocked/
// turnScreenOn trong AndroidManifest.xml (cho fullScreenIntent cua thong bao
// Quiz) - khien app LUC NAO cung de len man khoa: bam nut nguon khi dang mo
// app thi mo khoa lai van thay app chu khong phai man khoa. Gio CHI bat 2 co
// nay luc chay (xem maybeShowOverLockScreen) khi Activity duoc mo boi thong
// bao Quiz (payload "quiz:" - xem daily_quiz_notifications.dart) VA may dang
// khoa, roi tat lai ngay khi dong man Quiz (Dart goi kenh [LOCK_CHANNEL]) hoac
// khi app roi khoi man hinh (onStop).
class MainActivity : AudioServiceActivity() {
    companion object {
        private const val LOCK_CHANNEL = "gymtalk/lock_screen"

        // Khop voi FlutterLocalNotificationsPlugin (flutter_local_notifications
        // 22.x): thong bao dung CHUNG 1 PendingIntent cho ca luc bam lan
        // fullScreenIntent, voi action/extra ben duoi.
        private const val SELECT_NOTIFICATION = "SELECT_NOTIFICATION"
        private const val PAYLOAD_EXTRA = "payload"
        private const val QUIZ_PAYLOAD_PREFIX = "quiz:"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // savedInstanceState != null: Activity bi tao lai (vd sau khi he thong
        // don tien trinh) - intent cu van con nhung KHONG phai lan bam/den han
        // thong bao moi, khong duoc de len man khoa nua.
        if (savedInstanceState == null) maybeShowOverLockScreen(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        maybeShowOverLockScreen(intent)
    }

    override fun onStop() {
        super.onStop()
        setShowOverLockScreen(false)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, LOCK_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "clearShowWhenLocked" -> {
                        setShowOverLockScreen(false)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun maybeShowOverLockScreen(intent: Intent?) {
        if (intent == null || intent.action != SELECT_NOTIFICATION) return
        if ((intent.flags and Intent.FLAG_ACTIVITY_LAUNCHED_FROM_HISTORY) != 0) return
        val payload = intent.getStringExtra(PAYLOAD_EXTRA) ?: return
        if (!payload.startsWith(QUIZ_PAYLOAD_PREFIX)) return
        val keyguard = getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
        if (!keyguard.isKeyguardLocked) return
        setShowOverLockScreen(true)
    }

    private fun setShowOverLockScreen(enabled: Boolean) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(enabled)
            setTurnScreenOn(enabled)
        } else {
            @Suppress("DEPRECATION")
            val flags = WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
            if (enabled) window.addFlags(flags) else window.clearFlags(flags)
        }
    }
}
