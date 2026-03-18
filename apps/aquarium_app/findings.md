# Findings — Danio build path cleanup

## 2026-03-18 02:46 GMT
- `android/local.properties` currently points to Linux/WSL paths:
  - `sdk.dir=/mnt/c/Users/larki/AppData/Local/Android/Sdk`
  - `flutter.sdk=/home/tiarnanlarkin/flutter`
- This mismatches the intended Windows-native build flow and explains path-mixing during WSL-side Flutter/Gradle execution.
- Windows-native `flutter run --debug` successfully launched Danio to the consent screen.
- Freshly rebuilt Windows-native `app-debug.apk` cold-launched normally after detach.
- WSL-side `flutter build apk --debug --no-pub` failed in Gradle plugin loading with mixed path resolution against Windows pub cache/plugin paths.
- Desired durable state: Windows repo + Windows-native Flutter for Danio Android builds/tests; WSL only for non-build shell work.
- First wrapper attempt used PowerShell argument pass-through; it reached Windows Flutter, but `--debug` was consumed/misparsed and the build fell back to release.
- Correct fix: keep the PowerShell wrapper, invoke it with PowerShell's end-of-parameters token (`--`), and have the script forward raw `$args` directly to `flutter.bat`.
- Accidental release build surfaced a separate issue: current release compilation fails because generated Android plugin registration references `integration_test` and `patrol` classes in `GeneratedPluginRegistrant.java`.
- Quarantining the stale `android/app/src/main/java/io/flutter/plugins/GeneratedPluginRegistrant.java` resolved that compile blocker; the next Windows-native release build progressed to `:app:packageReleaseBundle`.
- New current blocker is Gradle packaging memory: `PackageBundleTask -> Metaspace`.
- Web results and issue reports suggest a likely Windows-specific factor for the later strip/package failure: project paths containing spaces.
- Testing plan: keep the repo where it is, but create a no-space NTFS junction path for release builds to validate whether path spacing is the remaining trigger.
- The no-space junction reproduced the same failure immediately, so path spacing is not the primary blocker here.
- Next mitigation: disable native symbol stripping for release packaging via `packaging.jniLibs.keepDebugSymbols += "**/*.so"` and re-test the AAB path.
- Direct `gradlew` investigation exposed another environment instability: when Gradle uses local Java 25, Kotlin DSL script evaluation fails immediately (`IllegalArgumentException: 25.0.1`).
- Durable fix: pin `org.gradle.java.home` to the Windows Android Studio JBR 21 path so direct and Flutter-invoked Gradle use the same supported JDK.
