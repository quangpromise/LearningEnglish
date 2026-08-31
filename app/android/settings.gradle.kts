pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    // Ghim AGP 8.13.0 (khong dung 9.x) - tu AGP 9.0 tro di, viec ~20 file .aar
    // tinh nang tuy chon cua agora_rtc_engine (SDK goi thoai/video) deu khai bao
    // chung 1 namespace Android "io.agora.rtc" (do thiet ke cua Agora, khong sua
    // duoc vi la thu vien nguon dong) bi AGP coi la LOI CUNG (build that bai),
    // trong khi AGP 8.x chi canh bao (co the tat han qua
    // android.packageNamespacingViolationRestriction=NON_FATAL o gradle.properties).
    id("com.android.application") version "8.13.0" apply false
    id("org.jetbrains.kotlin.android") version "2.4.0" apply false
    // Push notification chat (Firebase Cloud Messaging) - chi thuc su duoc
    // apply trong app/build.gradle.kts KHI da co file google-services.json
    // (xem docs/setup-firebase-chat-push.md) - khai bao "apply false" o day
    // khong lam gi neu chua setup, an toan cho build hien tai.
    id("com.google.gms.google-services") version "4.4.2" apply false
}

include(":app")
