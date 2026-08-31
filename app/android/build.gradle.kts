allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// agora_rtc_engine (va mot so plugin Android khac) tu build voi compileSdkVersion
// rieng qua rootProject.ext thay vi ke thua tu app/build.gradle.kts - neu khong set
// o day, no fallback ve 31 va build that bai vi androidx.fragment/window/activity
// (dependency cua Agora) yeu cau compileSdk >= 34.
extra["compileSdkVersion"] = 36

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
