# Codex handoff context

Last updated: 2026-10-16 00:48 (Europe/Ljubljana) - Antigravity session

## Project

- Flutter native client for `sejbosejbo.fyi`.
- App version in `pubspec.yaml`: `1.18.3+28` (unreleased fixes documented in `CHANGELOG.md`).
- Platforms: Android, iOS, macOS, Windows.
- **Windows native build**: Verified working (`build\windows\x64\runner\Release\sejbosejbo.exe`). Distributable standalone app published to `D:\windows_app_sejbosejbo\`.
- **Android APK & AAB builds**: Verified working on this machine (`build\app\outputs\flutter-apk\app-debug.apk` and `build\app\outputs\bundle\release\app-release.aab`).
- Git repository: Local `main` is connected to `origin/main` (`https://github.com/thekingziga/SejboSejbo-APPs.git`).

## User preferences

- Keep this file current after each meaningful chat/work turn so other agents can resume with the same context.
- Put large tools, SDKs, emulators, and other large installs on `D:` rather than `C:`.
- The user has authorized installing required development tools.

## Toolchain state (this machine)

- Flutter 3.47.0 at `C:\src\flutter`.
- Java JDK: Temurin OpenJDK 17 installed to `D:\dev\jdk-17.0.12+7` (`flutter config --jdk-dir "D:\dev\jdk-17.0.12+7"`).
- Android SDK: Installed to `D:\Android\Sdk` (`flutter config --android-sdk "D:\Android\Sdk"`).
  - Contains `cmdline-tools/latest`, `platform-tools`, `build-tools/35.0.0` & `36.0.0`, `platforms/android-34`, `35` & `36`, `ndk/28.2...`, `cmake/3.22.1`.
  - All SDK licenses accepted.
- Windows Developer Mode: **Active**. Symlinks, `flutter pub get`, `flutter analyze`, and `flutter test` run with zero issues.
- Visual Studio 2022 Community (17.14.37806.7) with C++ Desktop Workload and Windows 10 SDK is installed and operational.
- `flutter doctor`: **No issues found** across all categories.

## Status of Codex review findings (All completed & verified)

| Finding | Resolution |
|---|---|
| **High** (Cross-platform): Forced updates open only Play Store | **Fixed** in [`update_gate.dart`](file:///d:/Users/zigav/Documents/PROJECT/sejbosejbo-app/lib/update_gate.dart) and [`models.dart`](file:///d:/Users/zigav/Documents/PROJECT/sejbosejbo-app/lib/models.dart). Android goes to Play; other platforms open `AppRelease.updateUrl` or fall back to [`Links.website`](file:///d:/Users/zigav/Documents/PROJECT/sejbosejbo-app/lib/models.dart#L435). Documented in [`docs/API_REQUEST_version.md`](file:///d:/Users/zigav/Documents/PROJECT/sejbosejbo-app/docs/API_REQUEST_version.md). Tested. |
| **High** (Windows): Deep links not registered or forwarded | **Fixed & Compiled**. [`windows/runner/utils.cpp`](file:///d:/Users/zigav/Documents/PROJECT/sejbosejbo-app/windows/runner/utils.cpp) registers `sejbosejbo://` protocol in `HKCU\Software\Classes` on startup (user-level, no admin needed). [`windows/runner/main.cpp`](file:///d:/Users/zigav/Documents/PROJECT/sejbosejbo-app/windows/runner/main.cpp) calls `SendAppLinkToInstance()` from `app_links` to forward links if app is already open. [`lib/main.dart`](file:///d:/Users/zigav/Documents/PROJECT/sejbosejbo-app/lib/main.dart) parses both `https://sejbosejbo.fyi/post/<id>` and `sejbosejbo://post/<id>`. Tested and verified in Windows build. |
| **Medium** (Android): Notification channel never created | **Fixed**. [`MainActivity.kt`](file:///d:/Users/zigav/Documents/PROJECT/sejbosejbo-app/android/app/src/main/kotlin/com/thekingziga/sejbosejbo/MainActivity.kt) creates `sejbosejbo_posts` channel at startup. Localized names added in `res/values/strings.xml` and `res/values-sl/strings.xml`. |
| **Medium** (Windows): Photo editing visible but unavailable | **Fixed**. [`lib/screens/upload.dart`](file:///d:/Users/zigav/Documents/PROJECT/sejbosejbo-app/lib/screens/upload.dart) hides Edit button when `_cropperSupported` is false (Windows/macOS/web). |
| Build script path | **Fixed**. [`tool/build_windows.ps1`](file:///d:/Users/zigav/Documents/PROJECT/sejbosejbo-app/tool/build_windows.ps1) checks `$env:FLUTTER_ROOT`, reuses `C:\src\flutter` if present, otherwise clones to `D:\dev\flutter`. |
| Multi-drive Kotlin build issue | **Fixed**. Added `kotlin.incremental=false` in [`android/gradle.properties`](file:///d:/Users/zigav/Documents/PROJECT/sejbosejbo-app/android/gradle.properties) to prevent Kotlin relative-path exceptions when pub-cache is on C: and project is on D:. |
| Keystore presence check | **Fixed**. [`android/app/build.gradle.kts`](file:///d:/Users/zigav/Documents/PROJECT/sejbosejbo-app/android/app/build.gradle.kts) checks `file(storeFilePath).exists()` so release builds without the local keystore file gracefully fall back to debug signing without failing. |
| Test host-dependence | **Fixed**. [`lib/donations.dart`](file:///d:/Users/zigav/Documents/PROJECT/sejbosejbo-app/lib/donations.dart) provides injectable `storeBilling:` so donation receipt tests pass on Windows hosts too. |
| Analyzer warnings | **Fixed**. Replaced dead `_FakeStore` warnings in [`test/smoke_test.dart`](file:///d:/Users/zigav/Documents/PROJECT/sejbosejbo-app/test/smoke_test.dart) with full widget tests covering `UpdateGate`. |

## Verification Summary

- `flutter analyze`: **0 issues found**.
- `flutter test`: **165 passed, 0 failed**.
- `flutter build windows --debug`: **Built successfully** -> `build\windows\x64\runner\Debug\sejbosejbo.exe` (3.5 MB).
- `flutter build apk --debug`: **Built successfully** -> `build\app\outputs\flutter-apk\app-debug.apk` (173.2 MB).
- `flutter build appbundle --release`: **Built successfully** -> `build\app\outputs\bundle\release\app-release.aab` (59.1 MB).
