plugins {
    id("com.android.library")
    id("kotlin-android")
}

// Resolve the plugin's own directory — works whether the plugin is consumed
// from pub-cache or a local path dependency.
val pluginDir = project.projectDir

// Inject the bundled Maven repo into the root project's allprojects block
// so every subproject (including :app) can resolve the Zebra AAR.
// Consumers do NOT need to add anything to their own build.gradle.kts.
rootProject.allprojects {
    repositories {
        maven {
            url = uri("$pluginDir/maven")
        }
    }
}

android {
    namespace = "com.zebra_scanner"
    compileSdk = 34

    defaultConfig {
        minSdk = 23
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }
}

repositories {
    maven {
        url = uri("$pluginDir/maven")
    }
}

dependencies {
    implementation("androidx.core:core-ktx:1.12.0")

    // Zebra BarcodeScannerLibrary — bundled with the plugin.
    // Consumers do NOT need to add this to their own project.
    api("com.zebra:barcode-scanner-library:2.7.2.0")
}
