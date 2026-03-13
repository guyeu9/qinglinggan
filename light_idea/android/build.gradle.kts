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
    afterEvaluate {
        if (project.hasProperty("android")) {
            val android = project.extensions.findByName("android")
            if (android != null) {
                try {
                    val namespaceProp = android.javaClass.getDeclaredMethod("getNamespace")
                    val currentNamespace = namespaceProp.invoke(android) as String?
                    if (currentNamespace == null) {
                        val setNamespace = android.javaClass.getDeclaredMethod("setNamespace", String::class.java)
                        val group = project.group.toString()
                        if (group.isNotEmpty() && group != "unspecified") {
                            setNamespace.invoke(android, group)
                        } else {
                            // 为 isar_flutter_libs 设置默认 namespace
                            setNamespace.invoke(android, "dev.isar.isar_flutter_libs")
                        }
                    }
                } catch (e: Exception) {
                    // Ignore if method doesn't exist
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
