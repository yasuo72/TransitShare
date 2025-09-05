buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.1.4")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.22")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
        maven {
            url = uri("https://api.mapbox.com/downloads/v2/releases/maven")
            authentication {
                create<BasicAuthentication>("basic")
            }
            credentials {
                username = "mapbox"
                password = project.findProperty("MAPBOX_DOWNLOADS_TOKEN") as String? ?: ""
            }
        }
    }
}

subprojects {
    project.layout.buildDirectory = File(rootProject.projectDir, "../build/" + project.name)
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
