import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val androidSigningKeystorePath = System.getenv("ANDROID_SIGNING_KEYSTORE_PATH")

if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
} else if (!androidSigningKeystorePath.isNullOrBlank()) {
    // CI: secrets via env (e.g. GitHub Actions), no key.properties on disk
    keystoreProperties["storeFile"] = androidSigningKeystorePath
    keystoreProperties["storePassword"] = System.getenv("ANDROID_KEYSTORE_PASSWORD") ?: ""
    keystoreProperties["keyPassword"] = System.getenv("ANDROID_KEY_PASSWORD") ?: ""
    keystoreProperties["keyAlias"] = System.getenv("ANDROID_KEY_ALIAS") ?: ""
}

val releaseSigningConfigured =
    keystorePropertiesFile.exists() || !androidSigningKeystorePath.isNullOrBlank()

android {
    namespace = "com.example.wizdrobe"
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
        applicationId = "com.example.wizdrobe"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (releaseSigningConfigured) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = rootProject.file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.findByName("release")
                ?: signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
