package com.learnenglishmusic.learn_english_music

import android.app.ActivityManager
import android.app.ApplicationExitInfo
import android.app.KeyguardManager
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.Ringtone
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.PowerManager
import android.provider.Settings
import android.view.WindowManager
import java.io.File
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

        // Danh sach chuong BAO THUC co san tren may (RingtoneManager.TYPE_ALARM)
        // cho cai dat nhac nho Lap ke hoach - xem device_alarm_sounds.dart.
        private const val ALARM_SOUNDS_CHANNEL = "planner/alarm_sounds"

        // Doc nhat ky crash + ly do tien trinh bi tat gan day (xem
        // CrashLogApplication.kt, crash_diagnostics.dart).
        private const val CRASH_LOG_CHANNEL = "app/crash_log"

        // Kiem tra / xin bo toi uu pin cho app (xem background_run_button trong
        // crash_diagnostics.dart).
        private const val BATTERY_CHANNEL = "app/battery"

        // Khop voi FlutterLocalNotificationsPlugin (flutter_local_notifications
        // 22.x): thong bao dung CHUNG 1 PendingIntent cho ca luc bam lan
        // fullScreenIntent, voi action/extra ben duoi.
        private const val SELECT_NOTIFICATION = "SELECT_NOTIFICATION"
        private const val PAYLOAD_EXTRA = "payload"
        private const val NOTIFICATION_ID_EXTRA = "notificationId"
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
        stopAlarmPreview()
    }

    private var previewRingtone: Ringtone? = null

    private fun exitReasonName(reason: Int): String = when (reason) {
        ApplicationExitInfo.REASON_CRASH -> "CRASH (Java/Kotlin)"
        ApplicationExitInfo.REASON_CRASH_NATIVE -> "CRASH_NATIVE (Flutter/C++)"
        ApplicationExitInfo.REASON_ANR -> "ANR (treo, khong phan hoi)"
        ApplicationExitInfo.REASON_LOW_MEMORY -> "LOW_MEMORY (he thong thieu RAM)"
        ApplicationExitInfo.REASON_EXCESSIVE_RESOURCE_USAGE -> "EXCESSIVE_RESOURCE_USAGE (dung qua nhieu CPU/pin)"
        ApplicationExitInfo.REASON_FREEZER -> "FREEZER (he thong dong bang app nen)"
        ApplicationExitInfo.REASON_SIGNALED -> "SIGNALED (bi he thong/OEM kill)"
        ApplicationExitInfo.REASON_USER_REQUESTED -> "USER_REQUESTED (buoc dung / vuot tat)"
        ApplicationExitInfo.REASON_USER_STOPPED -> "USER_STOPPED"
        ApplicationExitInfo.REASON_PERMISSION_CHANGE -> "PERMISSION_CHANGE"
        ApplicationExitInfo.REASON_DEPENDENCY_DIED -> "DEPENDENCY_DIED"
        ApplicationExitInfo.REASON_INITIALIZATION_FAILURE -> "INITIALIZATION_FAILURE"
        ApplicationExitInfo.REASON_EXIT_SELF -> "EXIT_SELF"
        ApplicationExitInfo.REASON_OTHER -> "OTHER"
        else -> "UNKNOWN($reason)"
    }

    /// 5 lan tien trinh app bi ket thuc gan nhat (Android 11+), kem vai dong
    /// dau cua trace neu la ANR.
    private fun readExitReasons(): List<Map<String, String>> {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) return emptyList()
        val am = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        return am.getHistoricalProcessExitReasons(packageName, 0, 5).map { info ->
            val trace = if (info.reason == ApplicationExitInfo.REASON_ANR) {
                try {
                    info.traceInputStream?.bufferedReader()?.use { it.readText().take(4000) } ?: ""
                } catch (_: Throwable) { "" }
            } else ""
            mapOf(
                "time" to java.util.Date(info.timestamp).toString(),
                "reason" to exitReasonName(info.reason),
                "description" to (info.description ?: ""),
                "importance" to info.importance.toString(),
                "process" to info.processName,
                "trace" to trace,
            )
        }
    }

    private fun listAlarmSounds(): List<Map<String, String>> {
        val result = mutableListOf<Map<String, String>>()
        RingtoneManager.getActualDefaultRingtoneUri(this, RingtoneManager.TYPE_ALARM)
            ?.let { uri ->
                val title = RingtoneManager.getRingtone(this, uri)?.getTitle(this) ?: ""
                result.add(mapOf("uri" to uri.toString(), "title" to title, "isDefault" to "1"))
            }
        // PHAI truyen applicationContext, KHONG truyen `this`: `this` la Activity
        // nen Kotlin chon constructor RingtoneManager(Activity) - ban nay lay
        // cursor qua Activity.managedQuery(), tuc Activity tu "quan ly" cursor
        // va requery() lai no moi lan quay lai app (Activity.performRestart).
        // Ma ta close() cursor ngay ben duoi -> lan mo lai app sau khi da vao
        // chon chuong bao thuc bi crash StaleDataException ("Attempted to
        // access a cursor after it has been closed"). Constructor Context thi
        // cursor khong bi Activity quan ly, tu close() la dung.
        val manager = RingtoneManager(applicationContext)
        manager.setType(RingtoneManager.TYPE_ALARM)
        val cursor = manager.cursor
        try {
            while (cursor.moveToNext()) {
                val title = cursor.getString(RingtoneManager.TITLE_COLUMN_INDEX) ?: continue
                val uri = manager.getRingtoneUri(cursor.position).toString()
                result.add(mapOf("uri" to uri, "title" to title, "isDefault" to "0"))
            }
        } finally {
            cursor.close()
        }
        return result
    }

    private fun playAlarmPreview(uri: String) {
        stopAlarmPreview()
        val ringtone = RingtoneManager.getRingtone(this, Uri.parse(uri)) ?: return
        ringtone.audioAttributes = AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_ALARM)
            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
            .build()
        ringtone.play()
        previewRingtone = ringtone
    }

    private fun stopAlarmPreview() {
        previewRingtone?.stop()
        previewRingtone = null
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
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, BATTERY_CHANNEL)
            .setMethodCallHandler { call, result ->
                val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
                when (call.method) {
                    "isIgnoring" -> result.success(pm.isIgnoringBatteryOptimizations(packageName))
                    "request" -> {
                        try {
                            startActivity(
                                Intent(
                                    Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS,
                                    Uri.parse("package:$packageName"),
                                )
                            )
                        } catch (_: Exception) {
                            // 1 so ROM chan hop thoai truc tiep - mo danh sach toi uu pin.
                            try {
                                startActivity(Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS))
                            } catch (_: Exception) {}
                        }
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CRASH_LOG_CHANNEL)
            .setMethodCallHandler { call, result ->
                val crashFile = File(filesDir, CrashLogApplication.CRASH_FILE)
                when (call.method) {
                    "read" -> try {
                        result.success(
                            mapOf(
                                "crash" to (if (crashFile.exists()) crashFile.readText() else null),
                                "exits" to readExitReasons(),
                            )
                        )
                    } catch (e: Exception) {
                        result.error("READ_FAILED", e.message, null)
                    }
                    "clear" -> {
                        crashFile.delete()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ALARM_SOUNDS_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "list" -> try {
                        result.success(listAlarmSounds())
                    } catch (e: Exception) {
                        result.error("LIST_FAILED", e.message, null)
                    }
                    "play" -> {
                        val uri = call.argument<String>("uri")
                        if (uri != null) playAlarmPreview(uri)
                        result.success(null)
                    }
                    "stop" -> {
                        stopAlarmPreview()
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
        // Quiz da tu mo (fullScreenIntent tren man khoa, hoac bam thong bao) -
        // go luon thong bao tuong ung khoi man khoa/thanh trang thai, neu
        // khong nguoi dung bam lai vao no se mo Quiz them 1 lan nua. Lam o
        // phia native vi chay NGAY khi Activity nhan intent, khong phu thuoc
        // Dart da khoi dong xong hay chua.
        val notificationId = intent.getIntExtra(NOTIFICATION_ID_EXTRA, -1)
        if (notificationId != -1) {
            (getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager)
                .cancel(notificationId)
        }
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
