plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.quick.rudra.rudra"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" // Updated NDK version

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        // Enable core library desugaring
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.quick.rudra.rudra"
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        // Add multiDexEnabled if minSdk is below 21
        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    dependencies {
        // Add core library desugaring dependency
        coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    }
}

flutter {
    source = "../.."
}