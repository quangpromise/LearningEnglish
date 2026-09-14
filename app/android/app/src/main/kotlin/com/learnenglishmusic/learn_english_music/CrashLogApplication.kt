package com.learnenglishmusic.learn_english_music

import android.app.Application
import android.os.Build
import java.io.File
import java.io.PrintWriter
import java.io.StringWriter
import java.util.Date

// Ghi lai loi crash (Java/Kotlin) vao file TRUOC khi app tat - nguoi dung
// khong cam may vao may tinh de xem logcat duoc, nen lan mo app sau man Ho so
// doc file nay ra de chup man hinh gui dev (xem crash_diagnostics.dart).
// Dat o Application (khong phai Activity) de bat ca loi xay ra khi CHI con
// service chay nen (nhac nen, thong bao) ma khong co man hinh nao dang mo.
class CrashLogApplication : Application() {
    companion object {
        const val CRASH_FILE = "last_crash.txt"
    }

    override fun onCreate() {
        super.onCreate()
        val previous = Thread.getDefaultUncaughtExceptionHandler()
        Thread.setDefaultUncaughtExceptionHandler { thread, error ->
            try {
                val trace = StringWriter().also { error.printStackTrace(PrintWriter(it)) }
                val text = buildString {
                    appendLine("time: ${Date()}")
                    appendLine("thread: ${thread.name}")
                    appendLine("device: ${Build.MANUFACTURER} ${Build.MODEL}, Android ${Build.VERSION.RELEASE} (SDK ${Build.VERSION.SDK_INT})")
                    appendLine()
                    append(trace.toString())
                }
                File(filesDir, CRASH_FILE).writeText(text.take(20000))
            } catch (_: Throwable) {
                // Khong duoc de loi khi ghi log che mat loi goc.
            }
            previous?.uncaughtException(thread, error)
        }
    }
}
