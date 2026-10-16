# Codex handoff context

Last updated: 2026-10-16 01:10 (Europe/Ljubljana) - Antigravity session

## Project

- Flutter native client for `sejbosejbo.fyi`.
- App version in `pubspec.yaml`: `1.18.3+29` (unreleased fixes documented in `CHANGELOG.md`).
- Platforms: Android, iOS, macOS, Windows.
- **Windows native build**: Verified working (`build\windows\x64\runner\Release\sejbosejbo.exe`). Distributable standalone app published to `D:\windows_app_sejbosejbo\`.
- **Android APK & AAB builds**: Verified working on this machine (`build\app\outputs\flutter-apk\app-debug.apk` and `build\app\outputs\bundle\release\app-release.aab`).
- Git repository: Local `main` is connected to `origin/main` (`https://github.com/thekingziga/SejboSejbo-APPs.git`).

## Branch Architecture

- **`main`**: Self-hostable template branch. Clean codebase without private keys or hardcoded production endpoints. Clear documentation for the community to deploy and self-host.
- **`live`**: Live production deployment branch tailored for `sejbosejbo.fyi` and the Google Play release. Pushed to `origin/live`.

## User preferences

- Keep this file current after each meaningful chat/work turn so other agents can resume with the same context.
- Put large tools, SDKs, emulators, and other large installs on `D:` rather than `C:`.
- All development tools (Flutter, JDK, Android SDK) are located on `D:`.

## Toolchain state (this machine)

- Flutter 3.47.7 on channel stable at `D:\dev\flutter` (moved from C:; added to User PATH).
- Java JDK: Temurin OpenJDK 17 installed to `D:\dev\jdk-17.0.12+7` (`flutter config --jdk-dir "D:\dev\jdk-17.0.12+7"`).
- Android SDK: Installed to `D:\Android\Sdk` (`flutter config --android-sdk "D:\Android\Sdk"`).
  - Contains `cmdline-tools/latest`, `platform-tools`, `build-tools/35.0.0` & `36.0.0`, `platforms/android-34`, `35` & `36`, `ndk/28.2...`, `cmake/3.22.1`.
  - All SDK licenses accepted.
- Windows Developer Mode: **Active**. Symlinks, `flutter pub get`, `flutter analyze`, and `flutter test` run with zero issues.
- Visual Studio 2022 Community (17.14.37806.7) with C++ Desktop Workload and Windows 10 SDK is installed and operational.
- `flutter doctor`: **No issues found** across all categories.

## Status of Keystore / Play Console Fingerprint Mismatch

- **Issue**: Google Play rejected the uploaded `.aab` because it was signed with debug key (`SHA1: 9D:5D:9B:F6:F9:EF:5C:8E:F1:20:26:69:EC:68:70:BC:55:EB:AC:62`) instead of the upload key (`SHA1: 29:12:9F:FB:09:58:51:51:26:76:59:1C:16:2E:25:E8:B0:CA:83:E5`).
- **Cause**: `android/key.properties` pointed to `/Users/ziga/upload-keystore.jks` (Mac path). Because the keystore file wasn't on this Windows PC, Gradle fell back to debug signing with `C:\Users\zigav\.android\debug.keystore`.
- **Resolution**:
  - Enhanced `android/app/build.gradle.kts` with `resolveKeystoreFile()` which checks the specified path, `rootProject.file()`, `D:/Users/zigav/upload-keystore.jks`, and `System.getProperty("user.home")`.
  - The user can download `upload-keystore.jks` and place it in `D:\Users\zigav\upload-keystore.jks` or `android/upload-keystore.jks`.
  - Provided `android/key.properties.example` and `android/app/google-services.json.example`.

## Verification Summary

- `flutter analyze`: **0 issues found**.
- `flutter test`: **165 passed, 0 failed**.
- `flutter build windows --debug`: **Built successfully** -> `build\windows\x64\runner\Debug\sejbosejbo.exe`.
- `flutter build apk --debug`: **Built successfully** -> `build\app\outputs\flutter-apk\app-debug.apk`.
- `flutter build appbundle --release`: **Built successfully** -> `build\app\outputs\bundle\release\app-release.aab` (59.1 MB, verified signed with upload key SHA-1 `29:12:9F:FB:09:58:51:51:26:76:59:1C:16:2E:25:E8:B0:CA:83:E5`, versionCode 29).
- **Windows standalone zip**: `D:\sejbosejbo-windows-x64-v1.18.3.zip` (17.7 MB).
- **GitHub Tags**: 27 version tags (`v1.0.0` through `v1.18.3`) created and pushed to `origin`. Each tag provides automated source code `.zip` and `.tar.gz` downloads on GitHub.
