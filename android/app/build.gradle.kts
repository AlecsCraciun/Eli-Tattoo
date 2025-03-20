import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("com.google.gms.google-services") // 🔹 FlutterFire Configuration
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin") // 🔹 Flutter Gradle Plugin
}

android {
    namespace = "com.example.eli_tattoo_clienti"
    compileSdk = 35 // ✅ Actualizat la 35

    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17 // ✅ Actualizat la Java 17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true // ✅ Activare Java desugaring
    }

    kotlinOptions {
        jvmTarget = "17" // ✅ Actualizat la 17
    }

    defaultConfig {
        applicationId = "com.example.eli_tattoo_clienti"
        minSdk = 23
        targetSdk = 35 // ✅ Actualizat la 35
        versionCode = 1
        versionName = "1.3.0" // ✅ Versiune actualizată
    }

    signingConfigs {
        create("release") {
            val keystorePropertiesFile = rootProject.file("key.properties")
            val keystoreProperties = Properties()
            
            if (keystorePropertiesFile.exists()) {
                keystoreProperties.load(FileInputStream(keystorePropertiesFile))
            }

            storeFile = file(keystoreProperties["storeFile"] as? String ?: "")
            storePassword = keystoreProperties["storePassword"] as? String ?: ""
            keyAlias = keystoreProperties["keyAlias"] as? String ?: ""
            keyPassword = keystoreProperties["keyPassword"] as? String ?: ""
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            isShrinkResources = false
            signingConfig = signingConfigs.getByName("release")
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:32.7.3")) // 🔹 Firebase BOM actualizat
    implementation("androidx.core:core-ktx:1.12.0")

    // ✅ Suport pentru Java 8+ desugaring
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4") // ✅ Actualizat
}

flutter {
    source = "../.."
}
