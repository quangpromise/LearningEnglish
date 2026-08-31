import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Push notification chat (Firebase) - chi apply plugin nay KHI da co file
// google-services.json that (tai tu Firebase Console, xem docs/setup-
// firebase-chat-push.md). Chua co file thi build van chay binh thuong nhu
// truoc, chi la Firebase.initializeApp() se nem loi luc runtime va
// ChatPush tu bo qua trong im lang (xem chat_push.dart) - khong chan build.
if (file("google-services.json").exists()) {
    apply(plugin = "com.google.gms.google-services")
}

// Doc thong tin ky release tu key.properties (local) - file nay KHONG commit len git.
// Tren CI, workflow se tao file key.properties + giai ma keystore tu secret truoc khi build,
// dam bao MOI ban build (local va CI) deu ky bang CUNG 1 keystore -> cung SHA-1 -> Google
// Sign-In luon hoat dong dung voi OAuth Client da dang ky, khong bi doi certificate moi lan CI chay.
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.learnenglishmusic.learn_english_music"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // Bat buoc de flutter_local_notifications build duoc (yeu cau desugaring
        // de dung API java.time tren cac ban Android cu hon API 26).
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.learnenglishmusic.learn_english_music"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                storeFile = rootProject.file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // Ky bang keystore rieng co dinh (khong con dung debug key) de SHA-1 khong doi
            // giua cac lan build local va CI - Google Sign-In can SHA-1 khop voi OAuth Client.
            signingConfig = signingConfigs.getByName("release")
            // Giam dung luong APK: R8 loai code khong dung + rut gon resource.
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

// agora_rtc_engine (SDK goi thoai/video) mac dinh keo ve "full-sdk" - ban Agora
// gom TOAN BO tinh nang tuy chon (AI khu tieng on, xoa phong nen ao, nhan dien
// khuon mat, am thanh khong gian, chia se man hinh, kiem duyet noi dung, codec
// AV1...) khien APK phinh to bat thuong (moi kien truc ~80-100MB thay vi ~20MB).
// GymTalk chi can goi thoai/video co ban nen thay bang "full-rtc-basic" - ban
// toi gian chinh thuc cua Agora (xem docs.agora.io/en/help/integration-issues/
// reduce_app_size_rtc) - chi gom native lib call co ban, khong co extension nao.
configurations.all {
    exclude(group = "io.agora.rtc", module = "full-sdk")
    exclude(group = "io.agora.rtc", module = "full-screen-sharing")
}

dependencies {
    // Yeu cau boi flutter_local_notifications (xem isCoreLibraryDesugaringEnabled
    // o tren) - cho phep dung mot so API Java 8+ (java.time...) tren cac ban
    // Android cu hon API 26.
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
    // Thay the cho full-sdk bi loai o tren - cung version native SDK (4.5.2) ma
    // agora_rtc_engine 6.5.3 dang dung, de khop voi iris-rtc (lop cau noi JNI).
    implementation("io.agora.rtc:full-rtc-basic:4.5.2")
}
