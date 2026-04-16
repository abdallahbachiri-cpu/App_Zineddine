plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "ca.cuisinous"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
        isCoreLibraryDesugaringEnabled = true
    }

    kotlin {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_1_8)
        }
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "ca.cuisinous"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = 35
        versionCode = 9
        versionName = "1.0.9"
        multiDexEnabled = true
        
        // Load environment variables from gradle.properties or system environment
        val stripePublishableKey = project.findProperty("STRIPE_PUBLISHABLE_KEY") as String?
            ?: System.getenv("STRIPE_PUBLISHABLE_KEY") ?: ""
        val googleMapsApiKey = project.findProperty("GOOGLE_MAPS_API_KEY") as String?
            ?: System.getenv("GOOGLE_MAPS_API_KEY") ?: ""
        val googleSignInClientId = project.findProperty("GOOGLE_SIGN_IN_CLIENT_ID") as String?
            ?: System.getenv("GOOGLE_SIGN_IN_CLIENT_ID") ?: ""
        
        manifestPlaceholders["stripePublishableKey"] = stripePublishableKey
        manifestPlaceholders["googleMapsApiKey"] = googleMapsApiKey
        manifestPlaceholders["googleSignInClientId"] = googleSignInClientId
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = true
            isShrinkResources = true
            signingConfig = signingConfigs.named("debug").get()
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"))
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
    implementation("com.stripe:stripe-android:21.6.0")
    implementation("com.google.android.gms:play-services-wallet:19.3.0") // Downgraded from 19.4.0
    implementation("com.google.android.gms:play-services-base:18.5.0")   // Downgraded from 18.7.0
    implementation("com.google.android.gms:play-services-auth:21.2.0")
}
flutter {
    source = "../.."
}
