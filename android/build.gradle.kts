allprojects {
    repositories {
        google()
        mavenCentral()
    }
    
    // Force all dependencies to use the same version of androidx.browser:browser
    configurations.all {
        resolutionStrategy {
            force("androidx.browser:browser:1.8.0")
        }
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
