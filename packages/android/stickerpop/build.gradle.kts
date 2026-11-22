plugins {
    id("com.android.library")
    id("org.jetbrains.kotlin.android")
    id("org.jetbrains.kotlin.plugin.compose")
    id("com.vanniktech.maven.publish")
    id("app.cash.paparazzi")
}

// Maven Central coordinates: io.github.stupidly-logical:stickerpop (the
// namespace is proven by the GitHub account). The Kotlin package stays dev.stickerpop.
group = "io.github.stupidly-logical"
version = "0.1.1"

android {
    namespace = "dev.stickerpop"
    compileSdk = 36

    defaultConfig {
        minSdk = 26
    }
    buildFeatures { compose = true }
    testOptions { unitTests.isReturnDefaultValues = true }
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

// Published to Maven Central by the release workflow (see the README's
// "First release on the registries"). For a local try-out:
// ./gradlew :stickerpop:publishToMavenLocal, then depend on
// "io.github.stupidly-logical:stickerpop:0.1.1" with mavenLocal() in your repositories.
mavenPublishing {
    configure(
        com.vanniktech.maven.publish.AndroidSingleVariantLibrary(
            javadocJar = com.vanniktech.maven.publish.JavadocJar.Empty(),
            sourcesJar = com.vanniktech.maven.publish.SourcesJar.Sources(),
            variant = "release",
        ),
    )
    publishToMavenCentral(automaticRelease = true)
    if (providers.gradleProperty("signingInMemoryKey").isPresent) signAllPublications()
    coordinates("io.github.stupidly-logical", "stickerpop", version.toString())
    pom {
        name.set("Sticker Pop for Compose")
        description.set("Sticker Pop, a bold sticker-style design system: tokens and components for Jetpack Compose.")
        url.set("https://stupidly-logical.github.io/sticker-pop/")
        inceptionYear.set("2026")
        licenses {
            license {
                name.set("MIT")
                url.set("https://github.com/stupidly-logical/sticker-pop/blob/main/LICENSE")
            }
        }
        developers {
            developer {
                id.set("stupidly-logical")
                name.set("stupidly-logical")
                url.set("https://github.com/stupidly-logical")
            }
        }
        scm {
            url.set("https://github.com/stupidly-logical/sticker-pop")
            connection.set("scm:git:https://github.com/stupidly-logical/sticker-pop.git")
            developerConnection.set("scm:git:ssh://git@github.com/stupidly-logical/sticker-pop.git")
        }
    }
}
