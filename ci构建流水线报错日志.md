Run flutter build apk --release
Running Gradle task 'assembleRelease'...                        
Warning: Flutter support for your project's Android Gradle Plugin version (Android Gradle Plugin version 8.1.1) will soon be dropped. Please upgrade your Android Gradle Plugin version to a version of at least Android Gradle Plugin version 8.6.0 soon.
Alternatively, use the flag "--android-skip-build-dependency-validation" to bypass this check.

Potential fix: Your project's AGP version is typically defined in the plugins block of the `settings.gradle` file (/home/runner/work/qinglinggan/qinglinggan/light_idea/android/settings.gradle), by a plugin with the id of com.android.application. 
If you don't see a plugins block, your project was likely created with an older template version. In this case it is most likely defined in the top-level build.gradle file (/home/runner/work/qinglinggan/qinglinggan/light_idea/android/build.gradle) by the following line in the dependencies block of the buildscript: "classpath 'com.android.tools.build:gradle:<version>'".

Warning: Flutter support for your project's Kotlin version (1.9.0) will soon be dropped. Please upgrade your Kotlin version to a version of at least 2.1.0 soon.
Alternatively, use the flag "--android-skip-build-dependency-validation" to bypass this check.

Potential fix: Your project's KGP version is typically defined in the plugins block of the `settings.gradle` file (/home/runner/work/qinglinggan/qinglinggan/light_idea/android/settings.gradle), by a plugin with the id of org.jetbrains.kotlin.android. 
If you don't see a plugins block, your project was likely created with an older template version, in which case it is most likely defined in the top-level build.gradle file (/home/runner/work/qinglinggan/qinglinggan/light_idea/android/build.gradle) by the ext.kotlin_version property.

Checking the license for package Android SDK Build-Tools 33.0.1 in /usr/local/lib/android/sdk/licenses
License for package Android SDK Build-Tools 33.0.1 accepted.
Preparing "Install Android SDK Build-Tools 33.0.1 v.33.0.1".
"Install Android SDK Build-Tools 33.0.1 v.33.0.1" ready.
Installing Android SDK Build-Tools 33.0.1 in /usr/local/lib/android/sdk/build-tools/33.0.1
"Install Android SDK Build-Tools 33.0.1 v.33.0.1" complete.
"Install Android SDK Build-Tools 33.0.1 v.33.0.1" finished.
Checking the license for package Android SDK Platform 30 in /usr/local/lib/android/sdk/licenses
License for package Android SDK Platform 30 accepted.
Preparing "Install Android SDK Platform 30 (revision 3)".
"Install Android SDK Platform 30 (revision 3)" ready.
Installing Android SDK Platform 30 in /usr/local/lib/android/sdk/platforms/android-30
"Install Android SDK Platform 30 (revision 3)" complete.
"Install Android SDK Platform 30 (revision 3)" finished.
Font asset "MaterialSymbolsOutlined.ttf" was tree-shaken, reducing it from 10461596 to 70232 bytes (99.3% reduction). Tree-shaking can be disabled by providing the --no-tree-shake-icons flag when building your app.
Font asset "MaterialSymbolsRounded.ttf" was tree-shaken, reducing it from 14967396 to 2632 bytes (100.0% reduction). Tree-shaking can be disabled by providing the --no-tree-shake-icons flag when building your app.
Font asset "CupertinoIcons.ttf" was tree-shaken, reducing it from 257628 to 848 bytes (99.7% reduction). Tree-shaking can be disabled by providing the --no-tree-shake-icons flag when building your app.
Font asset "MaterialSymbolsSharp.ttf" was tree-shaken, reducing it from 8698948 to 2380 bytes (100.0% reduction). Tree-shaking can be disabled by providing the --no-tree-shake-icons flag when building your app.
Font asset "MaterialIcons-Regular.otf" was tree-shaken, reducing it from 1645184 to 7172 bytes (99.6% reduction). Tree-shaking can be disabled by providing the --no-tree-shake-icons flag when building your app.
Checking the license for package CMake 3.22.1 in /usr/local/lib/android/sdk/licenses
License for package CMake 3.22.1 accepted.
Preparing "Install CMake 3.22.1 v.3.22.1".
"Install CMake 3.22.1 v.3.22.1" ready.
Installing CMake 3.22.1 in /usr/local/lib/android/sdk/cmake/3.22.1
"Install CMake 3.22.1 v.3.22.1" complete.
"Install CMake 3.22.1 v.3.22.1" finished.
Caught exception: Already watching path: /home/runner/work/qinglinggan/qinglinggan/light_idea/android

FAILURE: Build failed with an exception.

* What went wrong:
Execution failed for task ':isar_flutter_libs:verifyReleaseResources'.
> A failure occurred while executing com.android.build.gradle.tasks.VerifyLibraryResourcesTask$Action
   > Android resource linking failed
     ERROR: /home/runner/work/qinglinggan/qinglinggan/light_idea/build/isar_flutter_libs/intermediates/merged_res/release/values/values.xml:194: AAPT: error: resource android:attr/lStar not found.


* Try:
> Run with --stacktrace option to get the stack trace.
> Run with --info or --debug option to get more log output.
> Run with --scan to get full insights.
> Get more help at https://help.gradle.org.

BUILD FAILED in 4m 53s
Running Gradle task 'assembleRelease'...                          294.2s
Gradle task assembleRelease failed with exit code 1
Error: Process completed with exit code 1.