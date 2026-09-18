import java.io.File
import java.io.FileInputStream
import java.time.LocalDate
import java.util.Properties
import org.gradle.api.GradleException

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing, per guideline.md section 2.
//
// The keystore and its passwords live in android/key.properties, which is
// git-ignored and never committed. See android/key.properties.example for the
// format and docs/release_process.md for how to create the keystore.
//
// If key.properties is absent (fresh clone, CI without secrets), the release
// build falls back to the debug key so `flutter run --release` still works.
// A fallback build is NOT distributable — the build prints a warning saying so.
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties().apply {
    if (keystorePropertiesFile.exists()) {
        keystorePropertiesFile.inputStream().use { load(it) }
    }
}
val hasReleaseSigning = keystorePropertiesFile.exists() &&
    keystoreProperties.getProperty("storeFile") != null

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    FileInputStream(localPropertiesFile).use(localProperties::load)
}

val flutterSdkPath = localProperties.getProperty("flutter.sdk")
    ?: System.getenv("FLUTTER_ROOT")
    ?: throw GradleException(
        "Flutter SDK path not found. Set flutter.sdk in android\\local.properties or FLUTTER_ROOT."
    )

val isWindowsHost = System.getProperty("os.name").startsWith("Windows", ignoreCase = true)
val dartExecutable = File(
    flutterSdkPath,
    if (isWindowsHost) "bin\\dart.bat" else "bin/dart",
)
val projectRootDir = rootProject.projectDir.parentFile

val generateBuildMetadata = tasks.register("generateBuildMetadata") {
    group = "build setup"
    description = "Generates About-screen build metadata before Android builds."

    inputs.file(projectRootDir.resolve("pubspec.yaml"))
    inputs.file(projectRootDir.resolve("tool/generate_app_version.dart"))
    inputs.file(projectRootDir.resolve("tool/generate_build_date.dart"))
    inputs.property("metadataBuildDate", LocalDate.now().toString())
    outputs.file(projectRootDir.resolve("lib/core/constants/app_version.g.dart"))
    outputs.file(projectRootDir.resolve("lib/core/constants/build_date.g.dart"))

    doLast {
        if (!dartExecutable.exists()) {
            throw GradleException(
                "Could not find Dart executable at ${dartExecutable.absolutePath}. " +
                    "Check android\\local.properties flutter.sdk or FLUTTER_ROOT."
            )
        }

        project.exec {
            workingDir = projectRootDir
            commandLine(dartExecutable.absolutePath, "run", "tool/generate_app_version.dart")
        }
        project.exec {
            workingDir = projectRootDir
            commandLine(dartExecutable.absolutePath, "run", "tool/generate_build_date.dart")
        }
    }
}

tasks.named("preBuild") {
    dependsOn(generateBuildMetadata)
}

tasks.matching { task ->
    task.name.startsWith("compileFlutterBuild")
}.configureEach {
    dependsOn(generateBuildMetadata)
}

android {
    namespace = "in.sreerajp.sreerajp_journal_vault"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "in.sreerajp.sreerajp_journal_vault"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // AGENTS.md requires Android minimum API 28. Do not fall back to
        // flutter.minSdkVersion (currently 24) — plans/20260725_000000_remediation-plan.md slice A2
        // chose Keystore-backed secret storage on the assumption of API 28+.
        minSdk = 28
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                storeFile = rootProject.file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseSigning) {
                signingConfigs.getByName("release")
            } else {
                logger.warn(
                    "WARNING: android/key.properties not found. Signing the release " +
                        "build with the DEBUG key. This build must not be distributed. " +
                        "See docs/release_process.md to create a release keystore.",
                )
                signingConfigs.getByName("debug")
            }

            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }

    bundle {
        language {
            // REQUIRED (engineering standard §8.1). Play splits App Bundles by language
            // by default, so a phone set to English would get no Malayalam or Sanskrit
            // resources, and the in-app language picker could not switch to them.
            enableSplit = false
        }
    }

    flavorDimensions += "env"
    productFlavors {
        // The app label is the @string/app_name resource in src/dev/res and src/prod/res
        // (release_process.md §9A.1). It is a brand name, so it is not translated.
        create("dev") {
            dimension = "env"
        }
        create("prod") {
            dimension = "env"
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.documentfile:documentfile:1.0.1")
    implementation("androidx.activity:activity:1.9.0")
    implementation("androidx.fragment:fragment:1.8.6")
    implementation("cz.adaptech.tesseract4android:tesseract4android:4.9.0")

    // Test only — never shipped in the APK. Covers the pure-arithmetic OCR
    // reading-order algorithm in OcrReadingOrder.kt.
    testImplementation("junit:junit:4.13.2")
}
