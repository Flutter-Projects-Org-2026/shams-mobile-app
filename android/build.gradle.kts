allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    tasks.configureEach {
        if (name.contains("buildCMake")) {
            doNotTrackState("Bypassing state tracking for CMake tasks to resolve unreadable/missing file issues on different drives")
        }
    }
}





tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

