# Sejbosejbo — App Template (Self-Hostable)

[![Flutter](https://img.shields.io/badge/Flutter-3.47+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Platforms](https://img.shields.io/badge/Platforms-Android%20%7C%20Windows%20%7C%20iOS%20%7C%20macOS-4CAF50)](#platforms)
[![UI Style](https://img.shields.io/badge/Design-Neo--Brutalist-FFEB3B?labelColor=000000&color=FFE500)](#design-system)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

An open-source, neo-brutalist multi-platform native client for the SejboSejbo community media and post platform. Built with **Flutter**, compiling to true native binaries for **Android, Windows, iOS, and macOS** (no web wrappers or WebViews).

---

## 🌟 Features

- **Neo-Brutalist Design System**: High-contrast borders, solid drop shadows, playful typography, and responsive layouts.
- **Media Support**: Image, audio, and video uploads and playback with custom media controls.
- **Community Feed & Gallery**: Infinite feed, sort filters (newest, popular, pinned), tag filtering, voting, and comments.
- **Offline / Demo Mode**: Runs out of the box with bundled sample data when no server is connected.
- **Self-Host Ready**: Easily connect to any instance of the SejboSejbo backend or your custom API via standard environment flags.
- **Native Push Notifications**: Firebase Cloud Messaging (FCM) integration with dedicated notification channels.
- **Deep Linking**: Full support for opening post links on mobile and Windows (`sejbosejbo://` and web URLs).
- **Multi-Platform Donations**: In-app tipping via Google Play / Apple StoreKit on mobile, and direct Stripe Checkout on desktop.

---

## 🚀 Quickstart & Running Locally

### 1. Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.47 or later)
- Git

Verify your setup:
```bash
flutter doctor
```

### 2. Run in Demo Mode (No Server Needed)
You can clone and run the app immediately without configuring any backend or database:
```bash
flutter pub get
flutter run
```
Without an API URL, the app boots into **Demo Mode** with sample posts and features enabled for local testing.

### 3. Run Connected to Your Server
To connect the app to your own self-hosted backend, pass `--dart-define=API_BASE_URL`:
```bash
flutter run --dart-define=API_BASE_URL=https://your-server-domain.com
```

---

## 🌐 Self-Hosting Guide

Connecting this app to your own server takes only a few minutes.

### Step 1: Deploy Your Backend
Deploy the SejboSejbo backend server (Node.js / Docker). The API specifications and contract are documented in [`docs/API_PROMPT.md`](docs/API_PROMPT.md).

### Step 2: Configure Push Notifications (Optional)
If you want push notifications:
1. Create a project in the [Firebase Console](https://console.firebase.google.com/).
2. Add an Android app with package name `com.thekingziga.sejbosejbo` (or your custom package name).
3. Download `google-services.json` and place it at:
   ```text
   android/app/google-services.json
   ```
   (A sample template is provided in [`android/app/google-services.json.example`](android/app/google-services.json.example)).

### Step 3: Configure Android Release Signing
To sign your release builds for Google Play or direct distribution:
1. Generate an upload keystore:
   ```bash
   keytool -genkey -v -keystore android/upload-keystore.jks -alias upload -keyalg RSA -keysize 2048 -validity 10000
   ```
2. Copy [`android/key.properties.example`](android/key.properties.example) to `android/key.properties`:
   ```properties
   storePassword=yourStorePassword
   keyPassword=yourKeyPassword
   keyAlias=upload
   storeFile=upload-keystore.jks
   ```
   *(Note: `key.properties` and `*.jks` are automatically ignored by git and will never be committed).*

---

## 🛠️ Building for Production

### Android (Google Play Bundle & APK)

To build a production release Google Play Bundle (`.aab`):
```bash
# Using the build script (specify your server URL):
API_BASE_URL=https://your-domain.com ./tool/build_android_release.sh
```

Or using standard Flutter CLI:
```bash
flutter build appbundle --release --dart-define=API_BASE_URL=https://your-domain.com
```

To build a standalone installable APK (`.apk`):
```bash
flutter build apk --release --dart-define=API_BASE_URL=https://your-domain.com
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

---

### Windows (Native x64 Desktop)

Prerequisites: Visual Studio 2022 with **Desktop development with C++** workload.

Build using the included PowerShell build script:
```powershell
# Set your server URL and build:
$env:API_BASE_URL = "https://your-domain.com"
.\tool\build_windows.ps1
```
The resulting folder under `build\windows\x64\runner\Release\` is completely self-contained — copy it anywhere and run `sejbosejbo.exe`.

---

### iOS & macOS

```bash
# iOS simulator
flutter build ios --simulator --debug

# macOS desktop
flutter build macos --release --dart-define=API_BASE_URL=https://your-domain.com
```

---

## 🧪 Testing

The test suite runs without needing any backend server, physical devices, or store accounts:
```bash
flutter test
```
All 165+ tests cover widget rendering at various phone aspect ratios, donation handling, API contract parsing, deep link URL decoding, audio/video upload verification, and error edge cases.

To check code style and static analysis:
```bash
flutter analyze
```

---

## 📁 Repository Structure

```text
lib/
├── api.dart              # HTTP client, demo feed, and API contract implementation
├── donations.dart        # Platform-specific donation rails (Stripe / Play Store / StoreKit)
├── main.dart             # App entrypoint, deep link handling, navigation shell
├── models.dart           # Strongly typed data models matching server API
├── theme.dart            # Neo-brutalist theme, buttons, boxes, colors
├── update_gate.dart      # Platform-aware forced version update checker
├── widgets.dart          # Post cards, media player, header, and brutalist components
└── screens/              # Dashboard, gallery, upload, donation, detail screens
tool/
├── build_android_release.sh  # Automated Android AAB build script
└── build_windows.ps1         # Automated Windows MSVC build script
test/
└── smoke_test.dart       # Comprehensive 165+ test suite
```

---

## 🌿 Branches

- **`main`**: The public, self-hostable template branch. Contains clean code, no hardcoded secrets or private API credentials, and configurable server endpoints.
- **`live`**: Production deployment branch tailored for the official live deployment (`sejbosejbo.fyi`).

---

## 📄 License

This project is open-source software licensed under the [MIT License](LICENSE).
Feel free to fork, self-host, and contribute!
