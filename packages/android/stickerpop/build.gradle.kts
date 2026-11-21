plugins {
    id("com.android.library")
    id("org.jetbrains.kotlin.android")
    id("org.jetbrains.kotlin.plugin.compose")
    `maven-publish`
    id("app.cash.paparazzi")
}

group = "dev.stickerpop"
version = "0.1.0"

android {
    namespace = "dev.stickerpop"
    compileSdk = 36

    defaultConfig {
        minSdk = 26
    }
    buildFeatures { compose = true }
    testOptions { unitTests.isReturnDefaultValues = true }
    publishing {
        singleVariant("release") { withSourcesJar() }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
}

// Builds with JDK 21 (Paparazzi needs it); bytecode stays Java 17.
kotlin { compilerOptions { jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17) } }

dependencies {
    val composeBom = platform("androidx.compose:compose-bom:2025.07.00")
    implementation(composeBom)
    api("androidx.compose.ui:ui")
    api("androidx.compose.foundation:foundation")
    implementation("androidx.compose.material:material-icons-extended")
    debugImplementation("androidx.compose.ui:ui-tooling")
    testImplementation("junit:junit:4.13.2")
    testImplementation("org.json:json:20240303")
    implementation("androidx.compose.ui:ui-tooling-preview")
}

// ./gradlew :stickerpop:publishToMavenLocal, then depend on
// "dev.stickerpop:stickerpop:0.1.0" with mavenLocal() in your repositories.
// Or use includeBuild("…/sticker-pop/packages/android") for a source dependency.
publishing {
    publications {
        register<MavenPublication>("release") {
            artifactId = "stickerpop"
            afterEvaluate { from(components["release"]) }
            pom {
                name.set("Sticker Pop for Compose")
                description.set("Sticker Pop design system: tokens and components for Jetpack Compose.")
                url.set("https://stupidly-logical.github.io/sticker-pop/")
                licenses { license { name.set("MIT"); url.set("https://github.com/stupidly-logical/sticker-pop/blob/main/LICENSE") } }
                scm { url.set("https://github.com/stupidly-logical/sticker-pop") }
            }
        }
    }
}
