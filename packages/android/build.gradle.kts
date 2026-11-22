plugins {
    id("com.android.library") version "8.11.1" apply false
    id("com.android.application") version "8.11.1" apply false
    id("org.jetbrains.kotlin.android") version "2.2.0" apply false
    id("org.jetbrains.kotlin.plugin.compose") version "2.2.0" apply false
    // Paparazzi 1.3.5 bundles the Android 14 renderer and crashes on compileSdk 36;
    // 2.0.0-alpha03 bundles Android 16 and still works with AGP 8.11 (alpha05 needs AGP 9).
    id("app.cash.paparazzi") version "2.0.0-alpha03" apply false
}
