# Danio Build Rules

## Non-negotiable
- **Danio Android builds run with Windows-native Flutter only.**
- **Do not run `~/flutter/bin/flutter` from WSL against this repo.**
- The repo lives on Windows and Windows is the source of truth.

## Canonical commands
### From Windows
```bat
scripts\flutterw.cmd analyze --no-pub
scripts\flutterw.cmd build apk --debug --no-pub
scripts\flutterw.cmd build appbundle
```

### From WSL (delegates to Windows tooling)
```bash
./scripts/flutterw.sh analyze --no-pub
./scripts/flutterw.sh build apk --debug --no-pub
./scripts/flutterw.sh build appbundle
```

## Important nuance
- `build appbundle` is intentionally routed through **`android\\gradlew.bat bundleRelease`** from the `android/` directory by the wrapper.
- Reason: on this machine, top-level `flutter build appbundle` can emit a false `failed to strip debug symbols` error even when Gradle successfully produces the `.aab`.
- The wrapper uses the **known-good release path** so the default command stays reliable.

## Why
Running Linux/WSL Flutter against this Windows repo can produce mixed-path Gradle/plugin resolution failures and misleading local build artifacts.

## Project config
`android/local.properties` must point at:
- `C:\Users\larki\AppData\Local\Android\sdk`
- `C:\Users\larki\flutter`

`android/gradle.properties` must pin Gradle to the Android Studio JBR 21 install for this project.
